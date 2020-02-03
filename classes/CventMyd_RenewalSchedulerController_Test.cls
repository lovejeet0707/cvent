@isTest
private class CventMyd_RenewalSchedulerController_Test {
    
     @testSetup static void setup() {
        List<Account> newAccount = new List<Account>();
       //Account
        Account TestAccount = new Account();
        TestAccount.Name = 'Test Account';
        TestAccount.First_Response_Date__c = (DateTime.now()).addDays(5);
        TestAccount.Last_Response_Date__c = (DateTime.now()).addDays(3);
        newAccount.add(TestAccount);
        
        //Account
       // Account TestAccount1 = new Account();
    //     TestAccount1.Name = 'Test Account1';
    //     TestAccount1.First_Response_Date__c = (DateTime.now()).addDays(-5);
    //     TestAccount1.Last_Response_Date__c = (DateTime.now()).addDays(3);
    //     newAccount.add(TestAccount1);
        
        insert newAccount;
        
       //Insert Opp
        Opportunity opp = TestUtil.createOpportunity('Test Opp', 'Renewal', 'Closed Won');
        opp.CurrencyIsoCode  = 'USD';
        insert opp;
        
        //Insert Quote
        SBQQ__Quote__c TestQuote = new SBQQ__Quote__c();
        TestQuote.SBQQ__Opportunity2__c = opp.id;
        TestQuote.Contract_Term_Years__c = '2';
        TestQuote.SBQQ__Type__c = 'Renewal';
        TestQuote.Current_Year__c = 2;
        TestQuote.Contract_Executed__c = true;
        TestQuote.SBQQ__StartDate__c = System.today().addYears(-1);
        TestQuote.SBQQ__EndDate__c = System.today();
        TestQuote.createdFromLegacyContract__c = true;
        //TestQuote.Multiple_Years_Commitment__c = true;
        TestQuote.statusCheckCount__c = 0;
        insert TestQuote;
        
        TestQuote.Multiple_Years_Commitment__c = true;
        update TestQuote;
    
        //Insert CPQ Audit record
        CpqAudit__c testAudit = new CpqAudit__c();
        testAudit.Name = 'Test Audit';
        testAudit.quote__c = TestQuote.id;
        testAudit.isChainMaster__c = true;
        insert testAudit;
    }

    private static testMethod void testDoAmendsTrue() {
        test.startTest();
            CventMyd_RenewalSchedulerController con = new CventMyd_RenewalSchedulerController();
            con.doAmendments = True;
            con.scheduleJob();
        test.stopTest();
    }
    private static testMethod void testRefreshRecords() {
        test.startTest();
            CventMyd_RenewalSchedulerController con = new CventMyd_RenewalSchedulerController();
            con.doAmendments = True;
            con.dateTimeAtScheduling = (DateTime.now()).addDays(-5);
            con.refreshAuditRecords();
        test.stopTest();
    }
    private static testMethod void testScheduledJobsElse() {
        test.startTest();
            CventMyd_RenewalSchedulerController con = new CventMyd_RenewalSchedulerController();
            con.account = [SELECT First_Response_Date__c,Last_Response_Date__c FROM Account WHERE First_Response_Date__c >: DateTime.now() limit 1];
            try{
            
                con.scheduleJob();
                
                }
                
            catch(Exception e){
                
                Boolean expectedExceptionThrown =  e.getMessage().contains('You cannot schedule a job that starts in the past') ? true : false;
                
                System.AssertEquals(expectedExceptionThrown, true);
                } 
            
        test.stopTest();
    }
//  private static testMethod void testScheduledJobs() {
//      test.startTest();
//          CventMyd_RenewalSchedulerController con = new CventMyd_RenewalSchedulerController();
//             con.account = [SELECT First_Response_Date__c,Last_Response_Date__c FROM Account WHERE First_Response_Date__c <: DateTime.now() limit 1];
//          con.scheduleJob();
//      test.stopTest();
        
//  }

}