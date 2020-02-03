/**=====================================================================
 * Cvent
 * Name: ScheduledAccountRecordDeletionBatch 
 * Description: Schedule class for calling the "AccountRecordDeletionBatch" class
 * Created Date: [11/05/2016]
 * Created By: Hemant Rana
 * 
 * Date Modified                Modified By                  Description of the update
 * [MON DD, YYYY]               [FirstName LastName]         [Short description for changes]
 =====================================================================*/ 
global class ScheduledAccountRecordDeletionBatch implements Schedulable {
   global void execute(SchedulableContext SC) {
        AccountRecordDeletionBatch contactDelete=new AccountRecordDeletionBatch ();
        Database.executeBatch(contactDelete,1000);
   }
}