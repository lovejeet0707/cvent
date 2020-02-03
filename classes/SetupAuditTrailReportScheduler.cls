// ===============================
// AUTHOR           : Shanu Aggarwal    
// CREATED DATE     : 19 July 2016
// PURPOSE          : Schedule Batch SetupAuditTrailReportBatch
// TEST CLASS       :   
// SPECIAL NOTES    :
// ===============================
global class SetupAuditTrailReportScheduler implements Schedulable{


    public void execute(SchedulableContext sc){
    
        if(!Test.isRunningTest())    
            Database.ExecuteBatch(new SetupAuditTrailReportBatch());
    
    }

}