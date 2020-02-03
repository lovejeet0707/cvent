global class autoCloseItunesEmailBatch implements Database.Batchable<sobject>{
    
    global Date q = System.today()-15;
    global String email1 = 'iTunesconnect@apple.com';
    global String email2 = 'do_not_reply@apple.com';
    global String recId = '0120000000099RT';
    global string query='select SuppliedEmail,Id,Client_Services_Category__c,Status,Case_Reason__c from Case where (SuppliedEmail=:email1 OR SuppliedEmail=:email2) and CreatedDate<=:q and recordTypeId=:recid';
    global Database.querylocator start(Database.BatchableContext BC){
        system.debug('@@@@@Query results '+database.getquerylocator(query));
        return database.getquerylocator(query);
    }
    global void execute(Database.BatchableContext BC, List<sobject> scope){
        List<Case> caseIds = new List<Case>();
        List<Case> toCloseCases = new List<Case>();
        for(sobject s : scope){
            Case c = (Case)s;
            if(c.Status=='Open')
                caseIds.add(c);
        }
        system.debug('@@@@caseIds: '+caseIds);
        if(caseIds.size()>0){
          for(Case c : caseIds){
              c.Status = 'Closed';
              c.Client_Services_Category__c = 'General';
              c.Case_Reason__c = 'iTunes Notification';
              toCloseCases.add(c);
          }
        }
        if(toCloseCases.size()>0)
            update toCloseCases;
    }
    global void finish(Database.BatchableContext BC){
        ID idJob = BC.getJobId();
        AsyncApexJob apexjobUP =  [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
                                    FROM AsyncApexJob WHERE Id = :idJob];
         Messaging.SingleEmailMessage emailNotify = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {apexjobUP.CreatedBy.Email};
        emailNotify.setToAddresses(toAddresses);
        emailNotify.setSubject('Auto Close iTunes Email Completed with Errors');
        emailNotify.setPlainTextBody(
            'Your Auto Close iTunes Cases request completed, however the job reported ' + apexjobUP.NumberOfErrors + 
            ' errors. If your Auto Close iTunes Cases still fails, contact your system administrator.');
            
        if (apexjobUP.Status == 'Failed'){
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { emailNotify });
        }
    }
}