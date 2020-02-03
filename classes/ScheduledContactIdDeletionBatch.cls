/**=====================================================================
 * Cvent
 * Name: ScheduledContactIdDeletionBatch
 * Description: Schedule class for calling the "ContactIdDeletionBatch" class
 * Created Date: [11/05/2016]
 * Created By: Hemant Rana
 * 
 * Date Modified                Modified By                  Description of the update
 * [MON DD, YYYY]               [FirstName LastName]         [Short description for changes]
 =====================================================================*/ 
global class ScheduledContactIdDeletionBatch implements Schedulable {
   global void execute(SchedulableContext SC) {
        ContactIdDeletionBatch contactDelete=new ContactIdDeletionBatch();
        Database.executeBatch(contactDelete,1000);
   }
}