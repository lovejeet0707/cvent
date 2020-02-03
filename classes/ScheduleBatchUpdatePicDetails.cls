/************************************************************
Scheduler class to execute BatchUpdatePicDetails
************************************************************/
global class ScheduleBatchUpdatePicDetails implements Schedulable{
    global void execute(SchedulableContext sc) {
        BatchUpdatePicDetails lc = new BatchUpdatePicDetails(null);
        ID batchprocessid = Database.executeBatch(lc,10);           
    }
}