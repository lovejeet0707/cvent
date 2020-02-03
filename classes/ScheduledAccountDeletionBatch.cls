/**=====================================================================
 * Cvent
 * Name: ScheduledAccountDeletionBatch 
 * Description: Schedule class for calling the "AccountDeletionBatch" class
 * Created Date: [11/05/2016]
 * Created By: Hemant Rana
 * 
 * Date Modified                Modified By                  Description of the update
 * [MON DD, YYYY]               [FirstName LastName]         [Short description for changes]
 =====================================================================*/ 
global class ScheduledAccountDeletionBatch implements Schedulable {
   global void execute(SchedulableContext SC) {
        AccountDeletionBatch contactDelete=new AccountDeletionBatch();
        Database.executeBatch(contactDelete,1000);
   }
}