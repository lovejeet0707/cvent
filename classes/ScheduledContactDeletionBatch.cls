/**=====================================================================
 * Cvent
 * Name: ScheduledContactDeletionBatch
 * Description: Schedule class for calling the "ContactDeletionBatch" class
 * Created Date: [11/05/2016]
 * Created By: Hemant Rana
 * 
 * Date Modified                Modified By                  Description of the update
 * [MON DD, YYYY]               [FirstName LastName]         [Short description for changes]
 =====================================================================*/ 
global class ScheduledContactDeletionBatch implements Schedulable {
   global void execute(SchedulableContext SC) {
        ContactDeletionBatch contactDelete=new ContactDeletionBatch();
        Database.executeBatch(contactDelete,1000);
   }
}