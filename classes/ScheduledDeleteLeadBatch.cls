/*Schedule class for calling the "DeleteLeadBatch" class*/
global class ScheduledDeleteLeadBatch implements Schedulable {
   global void execute(SchedulableContext SC) {
        DeleteLeadBatch accService=new DeleteLeadBatch();
        Database.executeBatch(accService,200);
   }
}