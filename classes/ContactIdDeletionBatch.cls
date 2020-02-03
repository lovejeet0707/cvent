global class ContactIdDeletionBatch implements Database.Batchable<sObject>{
    Set<Id> contactIdSet;
    global Database.querylocator start(Database.BatchableContext BC){
        String query='SELECT Id,ContactId__c FROM Contact_Id__c';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Contact_Id__c> scope){
        /*contactIdSet = new Set<Id>();
        For(Contact_Id__c conId : scope)
        {
            contactIdSet.add(conId.ContactId__c);
        }
        List<Contact> contactObj = new List<Contact>([SELECT Id FROM Contact WHERE Id IN : contactIdSet]);
        //.......................Deleting Contact records.........
        Database.DeleteResult[] deleteContactList = Database.delete(contactObj , false);*/
        Database.DeleteResult[] deleteContactIdList = Database.delete(scope , false);
    }
    global void finish(Database.BatchableContext BC){
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email, CreatedBy.Name , ExtendedStatus  from AsyncApexJob where Id = :BC.getJobId()]; 
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
        String[] toAddresses = new String[] {a.CreatedBy.Email,'SBhalla@cvent.com','hrana@cvent.com'};  
        mail.setToAddresses(toAddresses);  
        mail.setSubject('Contact deletion BatchJob Status: ' + a.Status);
        String body='<span style='+'\''+'color:#1F497D; font-size:11.0pt;font-family:"Calibri",sans-serif;'+'\''+'><b>Hi '+a.CreatedBy.Name+',  </b></br></br>Contact Id which needs to deleted has been inserted in <I>Contact Id</I> Object.</br></br><b>Total Batch Processed:</b> '+a.JobItemsProcessed+'</span></br><span style='+'\''+'font-size:11.0pt;font-family:"Calibri",sans-serif;color:#000000'+'\''+'><b>Thanks,</br>'+'Salesforce'+'<o:p></o:p></b></span>';
        mail.setHtmlBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}