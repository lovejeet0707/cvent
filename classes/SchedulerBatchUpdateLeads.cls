global class SchedulerBatchUpdateLeads implements Schedulable{
    global void execute(SchedulableContext sc){
        List<List<sObject>> lstWrapper = new List<List<sObject>>();
        Id batchJobId = Database.executeBatch(new BatchUpdateLeads(false,0,lstWrapper,0,new Map<Id,String>()), 200);
    }
}