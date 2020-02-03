// ===============================
// AUTHOR           : Shanu Aggarwal    
// CREATED DATE     : 20 July 2016
// PURPOSE          : Schedule Batch SetupAuditTrailReportBatch
// TEST CLASS       :   SetupAuditTrailReportTest
// SPECIAL NOTES    :
// ===============================

//SeeAllData is true because we can not create SetupAuditTrail object from Apex Code.
@istest(seeAllData=true)
public class SetupAuditTrailReportTest{

    static{
         
        Map<String,Setup_Audit_Filters__c> customSetting =  Setup_Audit_Filters__c.getAll();
        
        if( customSetting.get('Date Filter')==null){
            Setup_Audit_Filters__c sFilter = new Setup_Audit_Filters__c();
            sFilter.Name =  'Date Filter';
            sFilter.Filter_Value__c = '= TODAY';
            insert sFilter;
         }     
    
    }

    static testmethod void testBatch(){
    
          
      
        /*SchedulableContext sc;
        SetupAuditTrailReportScheduler schedulerClass =  new SetupAuditTrailReportScheduler();
        schedulerClass.execute(sc);
        */
        
        Test.startTest();
        
            Id batchId = Database.ExecuteBatch(new SetupAuditTrailReportBatch());
            System.abortJob(batchId);
        
        Test.stopTest();
        
        
    }
    
    
     static testmethod void testScheduler(){

        String CRON_EXP = '0 0 0 15 3 ? 2022';
        
        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('ScheduleApexClassTest',
                        CRON_EXP, 
                        new SetupAuditTrailReportScheduler());

        Test.stopTest();
        
        
    }
    
}