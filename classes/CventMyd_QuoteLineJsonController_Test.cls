@isTest
private class CventMyd_QuoteLineJsonController_Test {
    
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
        insert sub;
        
        //Insert Quote Line
        SBQQ__QuoteLine__c testQuoteLine = new SBQQ__QuoteLine__c();
        testQuoteLine.SBQQ__Quantity__c = 1;
        testQuoteLine.SBQQ__Product__c = product1.Id;
        testQuoteLine.SBQQ__ListPrice__c = 10;
        testQuoteLine.SBQQ__NetPrice__c = 10;
        testQuoteLine.Rack_Rate__c = 10;
        testQuoteLine.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        testQuoteLine.SBQQ__Number__c = 1;
        testQuoteLine.SBQQ__Group__c = qlGroup.id;
        testQuoteLine.SBQQ__Quote__c = TestQuote.Id;
        testQuoteLine.Notes__c = 'abc';
        testQuoteLine.SBQQ__UpgradedSubscription__c = sub.id;
        testQuoteLine.jsonString__c = 'test String';
        
        insert testQuoteLine;
        
        //Insert Quote Line
        SBQQ__QuoteLine__c testQuoteLine1 = new SBQQ__QuoteLine__c();
        testQuoteLine1.SBQQ__Quantity__c = 1;
        testQuoteLine1.SBQQ__Product__c = product1.Id;
        testQuoteLine1.SBQQ__ListPrice__c = 10;
        testQuoteLine1.SBQQ__NetPrice__c = 10;
        testQuoteLine1.Rack_Rate__c = 10;
        testQuoteLine1.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        testQuoteLine1.SBQQ__Number__c = 1;
        testQuoteLine1.SBQQ__Group__c = qlGroup.id;
        testQuoteLine1.SBQQ__Quote__c = TestQuote.Id;
        testQuoteLine1.Notes__c = 'abc';
        testQuoteLine1.SBQQ__UpgradedSubscription__c = sub.id;
        
        insert testQuoteLine1;       
    }

	private static testMethod void testNullJsonString() {
	    SBQQ__QuoteLine__c getQuoteLine = new SBQQ__QuoteLine__c();
	    for(SBQQ__QuoteLine__c eachQuoteLine : [SELECT Id, jsonString__c from SBQQ__QuoteLine__c]){
	        if(eachQuoteLine.jsonString__c == null){
	            getQuoteLine.Id = eachQuoteLine.Id;
	            getQuoteLine.jsonString__c = eachQuoteLine.jsonString__c;
	        }
	        
	    }

        test.startTest();
        // PageReference pageRef = Page.CventMyd_QuoteLineJsonView;
        // pageRef.getParameters().put('quoteLineId', getQuoteLine.Id);
        // system.debug('This is from the testclass'+pageRef);
        // Test.setCurrentPage(pageRef);
        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(getQuoteLine);
        CventMyd_QuoteLineJsonController con = new CventMyd_QuoteLineJsonController(sc);
        
        test.stopTest();
	}
	private static testMethod void testJsonString() {
	    SBQQ__QuoteLine__c getQuoteLine = new SBQQ__QuoteLine__c();
	    for(SBQQ__QuoteLine__c eachQuoteLine : [SELECT Id, jsonString__c from SBQQ__QuoteLine__c]){
	        if(eachQuoteLine.jsonString__c != null){
	            getQuoteLine.Id = eachQuoteLine.Id;
	            getQuoteLine.jsonString__c = eachQuoteLine.jsonString__c;
	        }
	        
	    }

        test.startTest();
        PageReference pageRef = Page.CventMyd_QuoteLineJsonView;
        pageRef.getParameters().put('quoteLineId', getQuoteLine.Id);
        system.debug('This is from the testclass'+pageRef);
        Test.setCurrentPage(pageRef);
        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(getQuoteLine);
        CventMyd_QuoteLineJsonController con = new CventMyd_QuoteLineJsonController(sc);
        
        test.stopTest();
	}

}