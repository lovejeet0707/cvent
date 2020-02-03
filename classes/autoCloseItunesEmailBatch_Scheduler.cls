global class autoCloseItunesEmailBatch_Scheduler implements Schedulable{ 
  global void execute(SchedulableContext SC) {
     autoCloseItunesEmailBatch firstbatch= new autoCloseItunesEmailBatch() ;
     Database.executeBatch(firstbatch,200);
  }
}