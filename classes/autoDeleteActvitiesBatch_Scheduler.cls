global class autoDeleteActvitiesBatch_Scheduler implements Schedulable{ 
  global void execute(SchedulableContext SC) {
     autoDeleteActvitiesBatch firstbatch= new autoDeleteActvitiesBatch() ;
     Database.executeBatch(firstbatch,200);
  }
}