global without sharing class CventMyd_DeleteGhostQuotes implements Schedulable {

    global Set<Id> quoteIds ;

    global String jobName ;

    global CventMyd_DeleteGhostQuotes(Set<Id> quoteIds,String jobName) {

        this.quoteIds = quoteIds;

        this.jobName = jobName;

    }

    global void execute(SchedulableContext sc) {

        try {

            List<SBQQ__Quote__c> quotesToDelete = new List<SBQQ__Quote__c>();

            for(Id id : quoteIds) {

                quotesToDelete.add(new SBQQ__Quote__c(Id = id));

            }

            delete quotesToDelete;

            CventMyd_UtilityMethods.abortSchedulableJobs(true,'blah',jobName,false);

        }

        catch(Exception e) {

            CventMyd_UtilityMethods.abortSchedulableJobs(true,'blah',jobName,false);

        }

    }

}