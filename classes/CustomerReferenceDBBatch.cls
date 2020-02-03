public class CustomerReferenceDBBatch implements Database.Batchable<sObject>{
	boolean accountBatch = false;    
    
    public CustomerReferenceDBBatch(boolean accountBatch0){
        accountBatch = accountBatch0;
    }
    public Database.querylocator start(Database.BatchableContext BC){
        String query='';
        if(accountBatch)
            query = 'SELECT Id from Account where Account_Status__c =\'Active\'';
        else
        	query='SELECT Id from Contact where account.Account_Status__c =\'Active\' and lastmodifieddate < today';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        update scope;
    }

    public void finish(Database.BatchableContext BC){
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email, CreatedBy.Name , ExtendedStatus  from AsyncApexJob where Id = :BC.getJobId()]; 
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
        String[] toAddresses = new String[] {a.CreatedBy.Email,'pkaushik@cvent.com'};  
        mail.setToAddresses(toAddresses);  
        mail.setSubject('One time Batch processes for Customer Reference DB '+ (accountBatch?'Account Object': 'Contact Object')+': ' + a.Status);
        String body='<span style='+'\''+'color:#1F497D; font-size:11.0pt;font-family:"Calibri",sans-serif;'+'\''+'><b>Hi '+a.CreatedBy.Name+',  </b></br></br>Batch process has been completed.</br></br><b>Total Batch Processed:</b> '+a.JobItemsProcessed+'</span></br><span style='+'\''+'font-size:11.0pt;font-family:"Calibri",sans-serif;color:#000000'+'\''+'><b>Thanks,</br>'+'Salesforce'+'<o:p></o:p></b></span>';
        mail.setHtmlBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}