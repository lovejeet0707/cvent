@isTest
private class CventMyd_CpqAuditTriggerHandler_Test {

    private static testMethod void testInsertAudit() {
        
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
        insert testAudit;
    
    }
    
        private static testMethod void testInsertAudit2() {
        
        //Insert Opp
        Opportunity opp = TestUtil.createOpportunity('Test Opp', 'Renewal', 'Closed Won');
        opp.CurrencyIsoCode  = 'USD';
        insert opp;
        
        //Account
        Account TestAccount = new Account();
        TestAccount.Name = 'Test Account';
        insert TestAccount;
        
        Id RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Parent Contract').getRecordTypeId();
        
        //Parent Contract to have Parent_Contract_Term_Years__c, Upcoming_Renewal_Type__c, Parent_Contract_Term_Years__c
        Contract ParentCont = new Contract();
        ParentCont.AccountId = TestAccount.id;
        ParentCont.Contract_Term_Years__c = '1';
        ParentCont.RecordTypeId = RecordTypeId;
        ParentCont.SBQQ__Opportunity__c = opp.id;
        insert ParentCont;
        
        //Insert Quote
        SBQQ__Quote__c TestQuote = new SBQQ__Quote__c();
        TestQuote.SBQQ__Opportunity2__c = opp.id;
        TestQuote.Contract_Term_Years__c = '2';
        TestQuote.SBQQ__Type__c = 'Amendment';
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
        testAudit.contract__c = ParentCont.id;
        insert testAudit;
    
    }
    
        private static testMethod void testInsertAudit3() {
        
        //Insert Opp
        Opportunity opp = TestUtil.createOpportunity('Test Opp', 'Renewal', 'Closed Won');
        opp.CurrencyIsoCode  = 'USD';
        insert opp;
        
        //Account
        Account TestAccount = new Account();
        TestAccount.Name = 'Test Account';
        insert TestAccount;
        
        Id RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Parent Contract').getRecordTypeId();
        
        //Parent Contract to have Parent_Contract_Term_Years__c, Upcoming_Renewal_Type__c, Parent_Contract_Term_Years__c
        Contract ParentCont = new Contract();
        ParentCont.AccountId = TestAccount.id;
        ParentCont.Contract_Term_Years__c = '1';
        ParentCont.RecordTypeId = RecordTypeId;
        ParentCont.SBQQ__Opportunity__c = opp.id;
        insert ParentCont;
        
        //Insert Quote
        SBQQ__Quote__c TestQuote = new SBQQ__Quote__c();
        TestQuote.SBQQ__Opportunity2__c = opp.id;
        TestQuote.Contract_Term_Years__c = '2';
        TestQuote.SBQQ__Type__c = 'Amendment';
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
        
        //CventMyd_Settings__mdt settingsRecord = [SELECT Id, quoteLineMaxCount__c FROM CventMyd_Settings__mdt];
        
        //settingsRecord.quoteLineMaxCount__c = -1;
    
        //Insert CPQ Audit record
        CpqAudit__c testAudit = new CpqAudit__c();
        testAudit.Name = 'Test Audit';
        testAudit.quote__c = TestQuote.id;
        testAudit.contract__c = ParentCont.id;
        insert testAudit;
    
    }

}