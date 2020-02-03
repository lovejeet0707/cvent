//Test Class for "ScheduledDeleteLeadBatch"/"ScheduledDeleteRFPBatch"/"ScheduledDeleteUniqueRFPBatch"
@isTest
public class TestScheduleClass{
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    public static testMethod void testschedule() {
        Test.StartTest();
       // Schedule the ScheduledDeleteLeadBatch
       System.schedule('ScheduledDeleteLeadBatch',CRON_EXP,new ScheduledDeleteLeadBatch());
        //Schedule ScheduledDeleteRFPBatch class
        System.schedule('ScheduledDeleteRFPBatch',CRON_EXP,new ScheduledDeleteRFPBatch());
        //Schedule ScheduledDeleteUniqueRFPBatch class
        System.schedule('ScheduledDeleteUniqueRFPBatch',CRON_EXP,new ScheduledDeleteUniqueRFPBatch ());
        Test.stopTest(); 
    }
}