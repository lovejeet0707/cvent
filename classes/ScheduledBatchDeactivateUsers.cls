/*
Author :kumud thakur
Desc: Schedule class for calling the "BatchDeactivateUsers" class


*/

global class ScheduledBatchDeactivateUsers implements Schedulable {

    global void execute(SchedulableContext SC) {
        BatchDeactivateUsers instdeactivateUser=new BatchDeactivateUsers ();
        if(!Test.isRunningTest())
            Database.executeBatch(instdeactivateUser,200);
    }
}