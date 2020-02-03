/**********************************************************************************
Class to Send Email Alerts to AM ( Created on 26 Sep 2016 )
**********************************************************************************/
global class AMValidationBacth implements Database.Batchable<sObject>,Database.Stateful {
        
    //Set of AM's
    Set<String> AMNamesSet;
    Id templateId;
    
    public AMValidationBacth(){
        AMNamesSet = new Set<String>();
        //Getting template Id
        templateId = [Select Id From EmailTemplate Where DeveloperName = 'AM_Validation_HTML_Template'].Id;
    }
        
        
    global Database.QueryLocator start(Database.BatchableContext BC) {
        if(test.isRunningTest()){
             return Database.getQueryLocator([Select Id,Contact__r.Account.AM_CrowdCompass__c,/*Contact__r.Account.AM_CrowdTorch__c,*/
                                         Contact__r.Account.AM_CSN__c,/*Contact__r.Account.AM_CT_TM__c,*/
                                         Contact__r.Account.AM_Event__c,Contact__r.Account.AM_Survey__c,
                                         Contact__r.Account.AM_PA__c,/*Contact__r.Account.AM_TicketMob__c,*/
                                         Contact__r.Account.AM_Pre_Sales_Event__c,Contact__r.Account.CS_Rep__c From
                                         Contact_Role__c LIMIT 1]);
        }
        else{
        //Fetching account and its associated team members
        return Database.getQueryLocator([Select Id,Contact__r.Account.AM_CrowdCompass__c,/*Contact__r.Account.AM_CrowdTorch__c,*/
                                         Contact__r.Account.AM_CSN__c,/*Contact__r.Account.AM_CT_TM__c,*/
                                         Contact__r.Account.AM_Event__c,Contact__r.Account.AM_Survey__c,
                                         Contact__r.Account.AM_PA__c,/*Contact__r.Account.AM_TicketMob__c,*/
                                         Contact__r.Account.AM_Pre_Sales_Event__c,Contact__r.Account.CS_Rep__c From
                                         Contact_Role__c Where Contact_Validated__c = false And
                                         Contact__c IN ( Select Id From Contact Where Account.Account_Status__c Like 'Active%')]);
        }
        
    }
    
    global void execute(Database.BatchableContext BC, List<Contact_Role__c> scope) {
                
       
        
        //Adding all AM's Names into Set "AMNamesSet"
        for(Contact_Role__c cr : scope ){
                
            AMNamesSet.add(cr.Contact__r.Account.AM_CrowdCompass__c);
            //AMNamesSet.add(cr.Contact__r.Account.AM_CrowdTorch__c);     //Commented By Mohsin on 21st June 2019 - FP Activity
            AMNamesSet.add(cr.Contact__r.Account.AM_CSN__c);
            //AMNamesSet.add(cr.Contact__r.Account.AM_CT_TM__c);            //Commented By Mohsin on 21st June 2019 - FP Activity
            AMNamesSet.add(cr.Contact__r.Account.AM_Event__c);
            AMNamesSet.add(cr.Contact__r.Account.AM_Survey__c);
            AMNamesSet.add(cr.Contact__r.Account.AM_PA__c);
            //AMNamesSet.add(cr.Contact__r.Account.AM_TicketMob__c);     //Commented By Mohsin on 21st June 2019 - FP Activity
            AMNamesSet.add(cr.Contact__r.Account.AM_Pre_Sales_Event__c);
            
        }
        
        //Remove any null values inserted into set
        AMNamesSet.remove(null);
    }
    global void finish(Database.BatchableContext BC) {
        Messaging.SingleEmailMessage[] mails = new List<Messaging.SingleEmailMessage>();        
        
        //Fetching User Id of AM's and Sending Emails 
        for(User u :  [Select Id From User Where Name IN: AMNamesSet and IsActive=true and IsPortalEnabled=false]){
            
            //Creating Single Email Message
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.saveAsActivity  =false;
            mail.setSenderDisplayName('Salesforce Admin');
            System.debug('****templateId****' + templateId);
            mail.setTemplateId(templateId);
            mail.setTargetObjectId(u.Id);
            mails.add(mail);
            
        }
        

  
        //Sending Emails to AM
        if(mails.size()>0){
           Messaging.SendEmailResult[] result = Messaging.sendEmail(mails);
            system.debug('***result***' + result);
        }
    } 
    
}