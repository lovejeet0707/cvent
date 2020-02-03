global class BatchUpdateAccountTeamMembers_Scheduler implements Schedulable{ 
  global void execute(SchedulableContext SC) {
     BatchUpdateAccountTeamMembersOnAccount firstbatch= new BatchUpdateAccountTeamMembersOnAccount() ;
     Database.executeBatch(firstbatch,50);
  }
}