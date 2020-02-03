global class revenueFieldsBatchClass_Scheduler implements Schedulable{ 
    global void execute(SchedulableContext SC) {
     revenueFieldsBatchClass firstbatch = new revenueFieldsBatchClass() ;
     Database.executeBatch(firstbatch,50);
  }
}