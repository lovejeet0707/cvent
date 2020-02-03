global with sharing class ScheduleAccountService_Batch implements Schedulable {
global void execute(SchedulableContext sc) {
  ID BatchId = Database.executeBatch(new AccountServiceTierAssignment_Batch(), 500);
}
 
Public static void SchedulerMethod() {
  string timeinterval = '0 30 * * * ?';
  System.schedule('BatchApexDemo-Every15mins',timeinterval, new ScheduleAccountService_Batch ());
  }
}