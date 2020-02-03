// ===============================
// Name				: AMValidationBatchScheduler
// AUTHOR           : Shanu Aggarwal    
// CREATED DATE     : 20 Sep 2016
// TEST CLASS       		: AMValidationBacthTest
// SPECIAL NOTES    :
// ===============================
global class AMValidationBatchScheduler implements Schedulable{
    
    global void execute(SchedulableContext SC) {
     AMValidationBacth ab= new AMValidationBacth() ;
     Database.executeBatch(ab,200);
  }

}