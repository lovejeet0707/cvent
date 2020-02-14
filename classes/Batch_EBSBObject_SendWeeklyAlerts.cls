/**
 * @File Name          : Batch_EBSBObject_SendWeeklyAlerts.cls
 * @Description        : Mr Batch Class. Ref Ticket Number JIRA# TICCM-1345
 * @Author             : Nishant Goswami
 * @Group              : CRM Team
 * @Last Modified By   : Nishant Goswami
 * @Last Modified On   : 5/2/2020, 6:58:23 pm
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    21/12/2019   Nishant Goswami     Initial Version
**/
public with sharing class Batch_EBSBObject_SendWeeklyAlerts implements Database.Batchable<sObject> {
    //Declaration block
    public string query;
    public List<Messaging.SingleEmailMessage> mailingList;
    public List<String> toAddressList;
    public Map<String,String> amUserEmailMap;

    //Constructor and query variable setting
    public Batch_EBSBObject_SendWeeklyAlerts() {
        query = 'Select Id';
        query += ',Contact__c';
        query += ',Contact__r.Email';
        query += ',AM_Event__c';
        query += ',Owner.Email';
        query += ',Owner_s_Manager_Email__c';
        query += ' From EB_SB_Builder__c';
        query += ' Where Project_Status_del__c = \'In Progress\'';
        query += ' AND SendWeeklyAlerts__c = TRUE';
    }

    //Data gather
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    /**
    * @description: execution context: Processes Mailing List and sends out the email to the intended recipients 
    * @author Nishant Goswami | 22/12/2019 
    * @param Database.BatchableContext BC 
    * @param List<EB_SB_Builder__c> scope 
    * @return void 
    **/
    public void execute(Database.BatchableContext BC, List<EB_SB_Builder__c> scope){
        if(scope.size()>0){
            //Using a map for optimization
            amUserEmailMap = new Map<String,String>();
            for(User amUser : [Select Id, Name, Email From User Where isActive = TRUE AND UserRoleId = '00E00000006tiKx']){ //Hardcoding Role: AM (Event)
                amUserEmailMap.put(amUser.Name,amUser.Email);
            } 
            //Now for email formulation.
            mailingList = new List<Messaging.SingleEmailMessage>();
            toAddressList = new List<String>();
            for(EB_SB_Builder__c ebsbProject : scope){
                //Creating Recipient List
                toAddressList.add(ebsbProject.Contact__r.Email);
                toAddressList.add(ebsbProject.Owner.Email);
                toAddressList.add(ebsbProject.Owner_s_Manager_Email__c);
                toAddressList.add('eventbuilder@cvent.com');
                if(amUserEmailMap.get(ebsbProject.AM_Event__c) != null){
                    toAddressList.add(amUserEmailMap.get(ebsbProject.AM_Event__c));
                }
                EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name = 'EBSBProject Send Weekly Alerts'];
                //Single Email Creation
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTargetObjectId(ebsbProject.Contact__c);
                mail.setTemplateId(emailTemplate.Id); 
                mail.setToAddresses(toAddressList);
                mail.setWhatId(ebsbProject.Id);
                mail.setOrgWideEmailAddressId('0D2o0000000GpxI'); //Hardcoding EventBuilder OrgWideEmail
                //Adding the formulated email to the mailingList
                mailingList.add(mail);
            }
            if(!Test.isRunningTest() && mailingList.size()>0){
                Messaging.sendEmail(mailingList);
            }
        }
    }
    /**
    * @description: batch processing finish. No activity required.
    * @author Nishant Goswami | 22/12/2019 
    * @param Database.BatchableContext BC 
    * @return void 
    **/
    public void finish(Database.BatchableContext BC){}
}