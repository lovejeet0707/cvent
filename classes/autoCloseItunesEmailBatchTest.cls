@isTest(SeeAllData=false)
public class autoCloseItunesEmailBatchTest{
    public static testMethod void testBatch() {
        List<Case> c = new List<Case>{ new Case(Status='Open',subject='Test',SuppliedEmail='iTunesconnect@apple.com',RecordtypeId='0120000000099RT'),
                                                         new Case(Status='Open',subject='Test',SuppliedEmail='iTunesconnect@apple.com',RecordtypeId='0120000000099RT'),
                                                         new Case(Status='Open',subject='Test',SuppliedEmail='iTunesconnect@apple.com',RecordtypeId='0120000000099RT'),
                                                         new Case(Status='Open',subject='Test',SuppliedEmail='iTunesconnect@apple.com',RecordtypeId='0120000000099RT'),
                                                         new Case(Status='Open',subject='Test',SuppliedEmail='iTunesconnect@apple.com',RecordtypeId='0120000000099RT'),
                                                         new Case(Status='Open',subject='Test',SuppliedEmail='do_not_reply@apple.com',RecordtypeId='0120000000099RT'),
                                                         new Case(Status='Open',subject='Test',SuppliedEmail='do_not_reply@apple.com',RecordtypeId='0120000000099RT'),
                                                         new Case(Status='Open',subject='Test',SuppliedEmail='do_not_reply@apple.com',RecordtypeId='0120000000099RT'),
                                                         new Case(Status='Open',subject='Test',SuppliedEmail='do_not_reply@apple.com',RecordtypeId='0120000000099RT'),
                                                         new Case(Status='Open',subject='Test',SuppliedEmail='do_not_reply@apple.com',RecordtypeId='0120000000099RT')};
        insert c;  
                
        Test.StartTest();
            autoCloseItunesEmailBatch testClose = new autoCloseItunesEmailBatch();
            ID batchprocessid = Database.executeBatch(testClose);
            
            autoCloseItunesEmailBatch_Scheduler q = new autoCloseItunesEmailBatch_Scheduler();
            SchedulableContext scq;
            q.execute(scq);  
        Test.StopTest();
   }
}