@isTest(SeeAllData=false)
public class autoDeleteBatchTest{
    public static testMethod void testBatch() {
        List<Case> c = new List<Case>{ new Case(
                           Status='Open',subject='Test')};
        insert c;  
        List <EmailMessage> emails = new List<EmailMessage>();
        for(integer i = 0; i<200; i++){
            EmailMessage a = new EmailMessage(Subject = 'testBatch'+i, 
            FromAddress = 'test@test.com',
            ToAddress = 'test@test.com',
            ParentId=c[0].id); 
            emails.add(a);
        }
        insert emails;
        system.debug('@@@Email Message: '+emails[0]);
        system.debug('@@@Email Message: '+emails[1]);
        system.debug('@@@Email Message: '+emails[0].activityId);
        system.debug('@@@Email Message: '+emails[1].activityId);
        
        Test.StartTest();
            autoDeleteActvitiesBatch testDelete = new autoDeleteActvitiesBatch();
            ID batchprocessid = Database.executeBatch(testDelete);
            
            autoDeleteActvitiesBatch_Scheduler q = new autoDeleteActvitiesBatch_Scheduler();
            SchedulableContext scq;
            q.execute(scq);  
        Test.StopTest();
   }
}