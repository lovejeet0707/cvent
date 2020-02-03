/************************************************************
Scheduler class to execute BatchConvertUpdateLeadContact
************************************************************/
global class ScheduleBatchConvertLead implements Schedulable{
    global void execute(SchedulableContext sc) {
        BatchConvertUpdateLeadContact lc = new BatchConvertUpdateLeadContact();
        ID batchprocessid = Database.executeBatch(lc,200);           
    }
}