global class updateContractCountScheduler implements Schedulable {
   global void execute(SchedulableContext sc) {
      updateContractCount b = new updateContractCount(); 
      database.executebatch(b);
   }
}