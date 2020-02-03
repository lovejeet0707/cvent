/*Schedule class for calling the "DeleteUniqueRFPBatch" class*/
global class ScheduledDeleteUniqueRFPBatch implements Schedulable {
   global void execute(SchedulableContext SC) {
        DeleteUniqueRFPBatch accService=new DeleteUniqueRFPBatch();
        Database.executeBatch(accService,200);
   }
}