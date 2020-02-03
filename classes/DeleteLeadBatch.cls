/**@author Hemant Rana
Batch Class for the Deletion of Lead on some conditions
Version 1.0
Date: 26th April1 2016
*/
global class DeleteLeadBatch implements Database.Batchable<sObject>{
    Date createdDateYearBack;
    Date todayDate;
    List<Lead> leadRecDeletedList=new LIst<Lead>();
    //Public String s;
    //public datetime m=system.now();

    //Public string k='LeadId';
    global DeleteLeadBatch()
    {
        todayDate=system.today();
        createdDateYearBack=system.today().addYears(-1);
    }
    global Database.querylocator start(Database.BatchableContext BC){
        //SELECT Id, ActivityDate FROM Task WHERE IsDeleted = false LIMIT 1000 ALL ROWS 
        String query='SELECT Id,Name,(SELECT Id FROM Events WHERE CreatedDate>=:createdDateYearBack AND CreatedDate<=:todayDate LIMIT 1),(SELECT Id FROM Tasks WHERE CreatedDate>=:createdDateYearBack AND CreatedDate<=:todayDate  LIMIT 1),(SELECT Id FROM ActivityHistories WHERE CreatedDate>=:createdDateYearBack AND CreatedDate<=:todayDate LIMIT 1) FROM Lead WHERE createdDate<:createdDateYearBack AND Isconverted=False AND Marketo_Active__c=False';// limit 100';
        System.debug('query======>>>>>>>'+query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Lead> scope){
        System.debug('scope====>'+scope);
        For(Lead leadRec : scope){
            if(leadRec.Events.size()==0 && leadRec.Tasks.size()==0 && leadRec.ActivityHistories.size()==0)
            {
                leadRecDeletedList.add(leadRec);
            }
        }
    /*    For(integer j=0;j<leadRecDeletedList.size();j++)
        {
            if(j==0){                     
                s +=k+'\n'+ leadRecDeletedList[j].Id;
            } else{                    
                s +=+'\n'+ leadRecDeletedList[j].Id;
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
        delete leadRecDeletedList;
        //System.debug('leadRecDeletedList===>'+leadRecDeletedList[0].id);
    }
    global void finish(Database.BatchableContext BC){
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email, CreatedBy.Name , ExtendedStatus  from AsyncApexJob where Id = :BC.getJobId()]; 
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        /*if(s!=null){
            Blob b=Blob.valueOf(s);
            System.debug('s===>'+s);
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName(m+'attachment.csv');
            efa.setBody(b);
            mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});  
        }*/
        String[] toAddresses = new String[] {a.CreatedBy.Email};  //a.CreatedBy.Email
        mail.setToAddresses(toAddresses);  
        mail.setSubject('Lead deletion BatchJob Status: ' + a.Status);  
        String body='<span style='+'\''+'color:#1F497D; font-size:11.0pt;font-family:"Calibri",sans-serif;'+'\''+'><b>Hi '+a.CreatedBy.Name+',  </b></br></br>Lead has been deleted through a Batch Job with the below conditions :</br>1) Leads that are not converted.</br>2) Leads that are not created in last one year.</br>3) Leads that have no activity in last one year.</br></br><b>Total Batch Processed:</b> '+a.JobItemsProcessed+'</br></span></br><span style='+'\''+'font-size:11.0pt;font-family:"Calibri",sans-serif;color:#000000'+'\''+'></br><b>Thanks,</br>'+'Salesforce'+'<o:p></o:p></b></span>';
        mail.setHtmlBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}