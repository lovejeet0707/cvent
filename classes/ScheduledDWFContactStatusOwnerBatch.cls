/**@author Hemant Rana
Schedule Class for calling the Batch Class "DWFContactStatusOwner_Batch"
Version 1.0
Date: 18th July 2016
*/
global class ScheduledDWFContactStatusOwnerBatch implements Schedulable {
   global void execute(SchedulableContext SC) {
        DWFContactStatusOwnerBatch DWFContactStatusBatch=new DWFContactStatusOwnerBatch();
        Id BatchId=Database.executeBatch(DWFContactStatusBatch,200);

   }
}