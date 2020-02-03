/**@author Hemant Rana
Batch Class for the Deletion of Unique RFP Purge on some conditions
Version 1.0
Date: 26th April1 2016
*/
global class DeleteUniqueRFPBatch implements Database.Batchable<sObject>{
    Date createdDateYearBack;
    List<LogsWarehouse__c> errorlogList;
    LogsWarehouse__c errorLog;
/*    Public String s;
    public datetime m=system.now();
    Public string k='UniqueRPF Id';*/
    global DeleteUniqueRFPBatch()
    {
        errorlogList=new List<LogsWarehouse__c>();
        createdDateYearBack=system.today().addYears(-2);
    }
    global Database.querylocator start(Database.BatchableContext BC){
        String query='SELECT Id FROM Unique_RFPs__c WHERE Event_Start_Date__c<:createdDateYearBack AND (Status__c!='+'\''+'Active'+'\''+' AND Status__c!='+'\''+'Awarded'+'\''+')';
        System.debug('query======>>>>>>>'+query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Unique_RFPs__c> scope){
        /*For(integer j=0;j<scope.size();j++)
        {
            if(j==0){                     
                s +=k+'\n'+ scope[j].Id;
            } else{                    
                s +=+'\n'+ scope[j].Id;
            }
        }
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        if(s!=null){
            Blob b=Blob.valueOf(s);
            System.debug('s===>'+s);
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName(m+'attachment.csv');
            efa.setBody(b);
            mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});  
        }
        String[] toAddresses = new String[] {'rhemant1990@gmail.com'};  //a.CreatedBy.Email
        mail.setToAddresses(toAddresses);  
        mail.setSubject('Lead deletion BatchJob Status: ');  
        String body='LEad Job CSV';
        mail.setHtmlBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });*/
        //delete scope;
        Database.DeleteResult[] drList = Database.delete(scope, false);    
        // Iterate through each returned result
/*        for(Database.DeleteResult dr : drList) {
            /*if (dr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully deleted account with ID: ' + dr.getId());
            }
            else {
            if(!dr.isSuccess()){
                // Operation failed, so get all errors                
                for(Database.Error err : dr.getErrors()) {
                    errorLog=new LogsWarehouse__c();
                    errorLog.Record_Id__c=err.getId();
                    errorLog.Error_description__c=err.getMessage();
                    errorLog.Batch_Class_Name__c='DeleteUniqueRFPBatch';
                    errorlogList.add(errorLog);
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Account fields that affected this error: ' + err.getFields());                    
                }
            }
        //}
        }
    insert errorlogList;*/
    }

    
    global void finish(Database.BatchableContext BC){
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email, CreatedBy.Name , ExtendedStatus  from AsyncApexJob where Id = :BC.getJobId()]; 
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
        String[] toAddresses = new String[] {a.CreatedBy.Email};  
        mail.setToAddresses(toAddresses);  
        mail.setSubject('Unique RFPs deletion BatchJob Status: ' + a.Status);  
        String body='<span style='+'\''+'color:#1F497D; font-size:11.0pt;font-family:"Calibri",sans-serif;'+'\''+'><b>Hi '+a.CreatedBy.Name+',  </b></br></br>Unique RFPs has been deleted through a Batch Job with the below conditions :</br>1) RFPs with original sent date 2 years back from today.</br>2) RFP status should not be equal to Active.</br></br><b>Total Batch Processed:</b> '+a.JobItemsProcessed+'</span></br><span style='+'\''+'font-size:11.0pt;font-family:"Calibri",sans-serif;color:#000000'+'\''+'><b>Thanks,</br>'+'Salesforce'+'<o:p></o:p></b></span>';
        mail.setHtmlBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}