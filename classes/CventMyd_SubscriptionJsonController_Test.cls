@isTest
private class CventMyd_SubscriptionJsonController_Test {
    @testSetup static void setup() {
        Id RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Parent Contract').getRecordTypeId();
	    
	    //Account
	    Account TestAccount = new Account();
        TestAccount.Name = 'Test Account';
        insert TestAccount;
	    
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
        insert TestQuote;
        
        //Quote Line Group
        SBQQ__QuoteLineGroup__c qlGroup = new SBQQ__QuoteLineGroup__c();
        qlGroup.Name = 'Group 1';
        qlGroup.SBQQ__Number__c = 10;
        qlGroup.SBQQ__ListTotal__c = 10;
        qlGroup.SBQQ__NetTotal__c = 100;
        qlGroup.SBQQ__CustomerTotal__c = 1000;
        qlGroup.SBQQ__Quote__c = TestQuote.id;
        insert qlGroup;
        
        TestQuote.Multiple_Years_Commitment__c = true;
        update TestQuote;
        
        //Parent Contract to have Parent_Contract_Term_Years__c, Upcoming_Renewal_Type__c, Parent_Contract_Term_Years__c
        Contract ParentCont = new Contract();
        ParentCont.AccountId = TestAccount.id;
        ParentCont.Contract_Term_Years__c = '1';
        ParentCont.RecordTypeId = RecordTypeId;
        ParentCont.SBQQ__Opportunity__c = opp.id;
        insert ParentCont;
        
        //Product
        Product2 product1 = new Product2();
        product1.Name = 'Product 1';
        product1.Contract_Output_Grouping__c = 'Bundle Advertisements';
        insert product1;
        
        //Insert Subscription
        SBQQ__Subscription__c sub = new SBQQ__Subscription__c();
        sub.SBQQ__Product__c = product1.id;
        sub.SBQQ__Account__c = TestAccount.id;
        sub.SBQQ__Contract__c = ParentCont.id;
        sub.SBQQ__Quantity__c = 1;
        sub.jsonString__c='test';
        insert sub;
    
    }
	private static testMethod void testNullUrlParam() {

	   SBQQ__Subscription__c sub = [SELECT Id FROM SBQQ__Subscription__c limit 1 ];

        test.startTest();

        ApexPages.StandardController sc = new ApexPages.StandardController(sub);
        CventMyd_SubscriptionJsonController con = new CventMyd_SubscriptionJsonController(sc);
        
        test.stopTest();

	}
	private static testMethod void testUrlParam() {

	   SBQQ__Subscription__c sub = [SELECT Id FROM SBQQ__Subscription__c limit 1 ];

        test.startTest();
        PageReference pageRef = Page.CventMyd_SubscriptionJsonView;
        pageRef.getParameters().put('subscriptionId', sub.Id);
        Test.setCurrentPage(pageRef);
        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(sub);
        CventMyd_SubscriptionJsonController con = new CventMyd_SubscriptionJsonController(sc);
        
        test.stopTest();

	}

}