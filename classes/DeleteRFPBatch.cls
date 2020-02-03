/**@author Hemant Rana
Batch Class for the Deletion of RFP Purge on some conditions
Version 1.0
Date: 26th April1 2016
*/
global class DeleteRFPBatch implements Database.Batchable<sObject>{
    Date createdDateYearBack;
    //Public String s;
    //public datetime m=system.now();
    //Public string k='RPF Id';
    global DeleteRFPBatch()
    {
        createdDateYearBack=system.today().addYears(-2);
    }
    global Database.querylocator start(Database.BatchableContext BC){
        String query='SELECT Id FROM RFP__c WHERE CreatedDate<:createdDateYearBack AND Response_Date__c<:createdDateYearBack AND Status__c!='+'\''+'Awaiting Proposal'+'\'';//+'and id='+'\''+'a0Co0000002bOY4EAM'+'\'';
        System.debug('query======>>>>>>>'+query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<RFP__c> scope){
        //System.debug('scope===>'+scope);
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
        delete scope;
       // System.debug('scope====>'+scope);
    }
    global void finish(Database.BatchableContext BC){
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email, CreatedBy.Name , ExtendedStatus  from AsyncApexJob where Id = :BC.getJobId()]; 
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
        String[] toAddresses = new String[] {a.CreatedBy.Email};  
        mail.setToAddresses(toAddresses);  
        mail.setSubject('RFPs deletion BatchJob Status: ' + a.Status);  
        String body='<span style='+'\''+'color:#1F497D; font-size:11.0pt;font-family:"Calibri",sans-serif;'+'\''+'><b>Hi '+a.CreatedBy.Name+',  </b></br></br>RFPs has been deleted through a Batch Job with the below conditions :</br>1) RFPsthat are created 2 years back from today.</br>2) RFPs that have no response due date falling in last 2 years from today.</br>3) RFPs status should not be equal to Awaiting Proposal</br></br><b>Total Batch Processed:</b> '+a.JobItemsProcessed+'</span></br><span style='+'\''+'font-size:11.0pt;font-family:"Calibri",sans-serif;color:#000000'+'\''+'><b>Thanks,</br>'+'Salesforce'+'<o:p></o:p></b></span>';
        mail.setHtmlBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}