global class ACMRestIntegrationSchedulerCls implements Schedulable{
   global void execute(SchedulableContext SC) {
      ACMRestIntegrationcls.Call();  
   }
}