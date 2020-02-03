/*Schedule class for calling the "AccountServiceTierAssignment_Batch" class*/
global class ScheduledAccountServiceTier implements Schedulable {
   global void execute(SchedulableContext SC) {
        AccountServiceTierAssignment_Batch accService=new AccountServiceTierAssignment_Batch();
        Database.executeBatch(accService,200);
   }
}