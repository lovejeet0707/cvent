global class AccountRecordDeletionBatch implements Database.Batchable<sObject>{
    Set<Id> accountIdSet;
    global Database.querylocator start(Database.BatchableContext BC){
        String query='SELECT Id,Account_Id__c FROM DeletedAccountId__c';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<DeletedAccountId__c> scope){
        /*accountIdSet = new Set<Id>();
        For(DeletedAccountId__c conId : scope)
        {
            accountIdSet.add(conId.Account_Id__c);
        }
        List<Account> accountObj = new List<Account>([SELECT Id FROM Account WHERE Id IN : accountIdSet]);
        //.......................Deleting Account records.........
        Database.DeleteResult[] deleteContactList = Database.delete(accountObj , false);*/
        //.......................Deleting DeletedAccountId__c records...................
        Database.DeleteResult[] deleteContactIdList = Database.delete(scope, false);
    }
    global void finish(Database.BatchableContext BC){
         AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email, CreatedBy.Name , ExtendedStatus  from AsyncApexJob where Id = :BC.getJobId()]; 
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
        String[] toAddresses = new String[] {a.CreatedBy.Email,'SBhalla@cvent.com','hrana@cvent.com'};  
        mail.setToAddresses(toAddresses);  
        mail.setSubject('Account deletion BatchJob Status: ' + a.Status);
        String body='<span style='+'\''+'color:#1F497D; font-size:11.0pt;font-family:"Calibri",sans-serif;'+'\''+'><b>Hi '+a.CreatedBy.Name+',  </b></br></br>Account Id which needs to be deleted has been inserted in the <i>DeletedAccountId</i> Object.</br></br><b>Total Batch Processed:</b> '+a.JobItemsProcessed+'</span></br><span style='+'\''+'font-size:11.0pt;font-family:"Calibri",sans-serif;color:#000000'+'\''+'><b>Thanks,</br>'+'Salesforce'+'<o:p></o:p></b></span>';
        mail.setHtmlBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}