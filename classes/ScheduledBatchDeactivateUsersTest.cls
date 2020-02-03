/*
Author :kumud thakur
Desc:Test class for "ScheduledBatchDeactivateUsers " class


*/


@isTest
Private class ScheduledBatchDeactivateUsersTest{
     public static String CRON_EXP = '0 0 0 15 3 ? 2022';
     public static testMethod void testschedule() {
        
        Id batchID;
     
        Test.StartTest();
        System.debug('batchID 1st====>'+batchID);
       
        ScheduledBatchDeactivateUsers sh1 = new ScheduledBatchDeactivateUsers();
       
         system.schedule('ScheduledBatchDeactivateUsers', CRON_EXP, sh1); 
       /* List<CronTrigger> cronTriggersReadyToFireAgain = [SELECT Id FROM CronTrigger WHERE NextFireTime != null]; //create a list of CronTrigger records that are scheduled to fire again
            if (!cronTriggersReadyToFireAgain.isEmpty()) { //if the list is not empty
                for (CronTrigger t : cronTriggersReadyToFireAgain) { //for each record
                    System.abortJob(t.Id); //abort the job
                }
            }*/
        
        Test.stopTest(); 
    }
}