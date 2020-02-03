/**********************************************************************************
Class to convert leads under CrowdTorch-EloquaForm-CTQuick-Registration campaign
Updaing Account and Contact Status fields
**********************************************************************************/
global class BatchConvertUpdateLeadContact implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        if(Test.isRunningTest()) {
          return Database.getQueryLocator([select id,LeadId,contactId,/*Contact.CTQ_Contact_Status__c,*/contact.AccountId/*,contact.Account.CTQ_Account_Status__c*/ from campaignmember]);//UD:Commented for FP:4thApril //Commented By Mohsin on 21st June 2019 - FP Activity
        } else {
          return Database.getQueryLocator([select id,LeadId,contactId,/*Contact.CTQ_Contact_Status__c,*/contact.AccountId/*,contact.Account.CTQ_Account_Status__c*/ from campaignmember where campaignId =: Label.LeadBatchCampaignIDToProcess]);//UD:Commented for FP:4thApril //Commented By Mohsin on 21st June 2019 - FP Activity
        }
        
    }
    
    global void execute(Database.BatchableContext BC, List<CampaignMember> scope) {
        //List of leadIds to conert
        List<Id> leadIds = new List<Id>();
        List<Id> contactIds = new List<Id>();
        List<Id> accountIds = new List<Id>();
        for(CampaignMember cmp : scope) {
            if(cmp.leadId != null) {
                leadIds.add(cmp.leadId); 
            }
            if(cmp.contactId != null /*&& cmp.Contact.CTQ_Contact_Status__c != 'H - Closed Won'*/) {//UD:Commented for FP:4thApril
                contactIds.add(cmp.contactId);
            }
        }
        //Lead Conversion process
        List<Lead> leadsToConvert = new List<Lead>();
        if(Test.isRunningTest()) {
          leadsToConvert = [Select Id,/*CTQ_Account_Status__c,CTQ_Contact_Status__c,*/(Select Id, Subject from Tasks where Subject like '%Marketo Submission: CT_Quick_Registration%') from Lead where ID IN:leadIds and isconverted = false];//HSR:Commented for FP:4thApril//UD:Commented for FP:4thApril
        } else {
          leadsToConvert = [Select Id,/*CTQ_Account_Status__c,CTQ_Contact_Status__c,*/(Select Id, Subject from Tasks where Subject like '%Marketo Submission: CT_Quick_Registration%' and RecordTypeID =: Label.TaskRecordTypeID) from Lead where ID IN:leadIds and isconverted = false];//HSR:Commented for FP:4thApril//UD:Commented for FP:4thApril
        }
        
        system.debug('<<<<<<<'+leadsToConvert.size());
        List<Lead> leadsToUpdate = new List<Lead>();
        for(Lead ld: leadsToConvert) {
            if(ld.Tasks.size() > 0) {
                //ld.CTQ_Account_Status__c = 'H - Closed Won';//HSR:Commented for FP:4thApril
                //ld.CTQ_Contact_Status__c = 'H - Closed Won';//HSR:Commented for FP:4thApril
                leadsToUpdate.add(ld);
            }
            
        }
        update leadsToUpdate;
         //List of leads to convert
         List<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>();
         for(Lead cmpLead : leadsToUpdate) {
            Database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(cmpLead.id);
            lc.ConvertedStatus = 'Qualified';
            lc.setDoNotCreateOpportunity(true);
            leadConverts.add(lc);
         }
         List<Database.LeadConvertResult> lcr = Database.convertLead(leadConverts);  
         
         //Updating contact and account
         List<Contact> contToUpdate = new List<Contact>();
         List<Contact> tempContToUpdate = new List<Contact>();
         if(Test.isRunningTest()) {
           contToUpdate = [Select Id,/*CTQ_Contact_Status__c,*/Account_ID__c,/*Account.CTQ_Account_Status__c,*/(Select Id from Tasks where Subject like '%Marketo Submission: CT_Quick_Registration%') FROM contact where Id IN:contactIds];//UD:Commented for FP:4thApril //Commented By Mohsin on 21st June 2019 - FP Activity
         } else{
           //Two queries due to person account issue
           tempContToUpdate = [Select Id,/*CTQ_Contact_Status__c,*/Account_ID__c,/*Account.CTQ_Account_Status__c,*/(Select Id from Tasks where Subject like '%Marketo Submission: CT_Quick_Registration%' and RecordTypeID =: Label.TaskRecordTypeID) FROM contact where Id IN:contactIds];//UD:Commented for FP:4thApril //Commented By Mohsin on 21st June 2019 - FP Activity
           contToUpdate = [Select Id,/*CTQ_Contact_Status__c,*/(Select Id from Tasks where Subject like '%Marketo Submission: CT_Quick_Registration%' and RecordTypeID =: Label.TaskRecordTypeID) FROM contact where Id IN:contactIds];//UD:Commented for FP:4thApril
         }
         
         List<Contact> contUpdate = new List<Contact>();
         for(Contact con:contToUpdate) {
            if(con.Tasks.size() > 0) {
               /* if(con.CTQ_Contact_Status__c != 'H - Closed Won') { //UD:Commented for FP:4thApril
                    con.CTQ_Contact_Status__c = 'H - Closed Won';
                    contUpdate.add(con);
                }*/
              
            }
         }
         //Extra loop for getting account Id
          for(Contact cons:tempContToUpdate) {
            if(cons.Tasks.size() > 0) {
             /*  if(cons.Account_ID__c != null && cons.Account.CTQ_Account_Status__c != 'H - Closed Won') { //Commented By Mohsin on 21st June 2019 - FP Activity
                    accountIds.add(cons.Account_ID__c);
                } */
            } 
         }
         system.debug('>>>>'+contUpdate.size());
         if(contUpdate.size() > 0) {
            update contUpdate;
         }
         
         
         List<Account> accToUpdate = [Select Id/*,CTQ_Account_Status__c*/ FROM Account where Id IN:accountIds];
         for(Account accs:accToUpdate) {
            //accs.CTQ_Account_Status__c = 'H - Closed Won';
         }
         system.debug('######'+accToUpdate.size());
         if(accToUpdate != null && accToUpdate.size() > 0) {
            update accToUpdate;
         }
    }   
    global void finish(Database.BatchableContext BC) {
    } 
}