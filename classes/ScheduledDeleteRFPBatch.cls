/*Schedule class for calling the "DeleteRFPBatch " class*/
global class ScheduledDeleteRFPBatch implements Schedulable {
   global void execute(SchedulableContext SC) {
        DeleteRFPBatch accService=new DeleteRFPBatch();
        Database.executeBatch(accService,200);
   }
}