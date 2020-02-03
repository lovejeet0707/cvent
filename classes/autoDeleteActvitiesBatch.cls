global class autoDeleteActvitiesBatch implements Database.Batchable<sobject>{
    //global string query;
    /*global autoDeleteActvitiesBatch(){
        query='select ActivityId,ParentId from EmailMessage where ParentId!=null and CreatedDate>=:System.today() and ActivityId!=null';
    }*/
    global Date q = System.today()-1;
    global string query='select ActivityId,ParentId from EmailMessage where ParentId!=null and CreatedDate>=:q and ActivityId!=null';
    global Database.querylocator start(Database.BatchableContext BC){
        system.debug('@@@@@Query results '+database.getquerylocator(query));
        return database.getquerylocator(query);
    }
    global void execute(Database.BatchableContext BC, List<sobject> scope){
        List<ID> taskIds = new List<ID>();
        List<Task> toDeleteActs = new List<Task>();
        for(sobject s : scope){
            EmailMessage e = (EmailMessage)s;
            if(e.ActivityId!=null)
                taskIds.add(e.ActivityId);
        }
        system.debug('@@@@taskIds : '+taskIds);
        if(taskIds.size()>0){
	        for(Task t : [Select id from Task where id in: taskIds and Isclosed=true and CreatedDate>=:q and Subject LIKE 'Email:%' AND Subject LIKE '%[ ref:%']){
	            toDeleteActs.add(t);
	        }
        }
        if(toDeleteActs.size()>0)
            delete toDeleteActs;
    }
    global void finish(Database.BatchableContext BC){
        ID idJob = BC.getJobId();
        AsyncApexJob apexjobUP =  [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
                                    FROM AsyncApexJob WHERE Id = :idJob];
         Messaging.SingleEmailMessage emailNotify = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {apexjobUP.CreatedBy.Email};
        emailNotify.setToAddresses(toAddresses);
        emailNotify.setSubject('Auto Delete Activity - Completed with Errors');
        emailNotify.setPlainTextBody(
            'Your Auto Delete Activity request completed, however the job reported ' + apexjobUP.NumberOfErrors + 
            ' errors. If your Auto Delete Activity still fails, contact your system administrator.');
            
        if (apexjobUP.Status == 'Failed'){
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { emailNotify });
        }
    }
}