@isTest
private class CventMyd_QuoteJsonController_Test {
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
        
        //Insert Quote
        SBQQ__Quote__c TestQuote1 = new SBQQ__Quote__c();
        TestQuote1.SBQQ__Opportunity2__c = opp.id;
        TestQuote1.Contract_Term_Years__c = '2';
        TestQuote1.SBQQ__Type__c = 'Renewal';
        TestQuote1.Current_Year__c = 2;
        TestQuote1.Contract_Executed__c = true;
        TestQuote1.SBQQ__StartDate__c = System.today().addYears(-1);
        TestQuote1.SBQQ__EndDate__c = System.today();
        TestQuote1.createdFromLegacyContract__c = false;
        //TestQuote.Multiple_Years_Commitment__c = true;
        insert TestQuote1;
        
        //Quote Line Group
        SBQQ__QuoteLineGroup__c qlGroup = new SBQQ__QuoteLineGroup__c();
        qlGroup.Name = 'Group 1';
        qlGroup.SBQQ__Number__c = 10;
        qlGroup.SBQQ__ListTotal__c = 10;
        qlGroup.SBQQ__NetTotal__c = 100;
        qlGroup.SBQQ__CustomerTotal__c = 1000;
        qlGroup.SBQQ__Quote__c = TestQuote.id;
        qlGroup.term__c = 1;
        insert qlGroup;
        
        //Quote Line Group
        SBQQ__QuoteLineGroup__c qlGroup1 = new SBQQ__QuoteLineGroup__c();
        qlGroup1.Name = 'Group 1';
        qlGroup1.SBQQ__Number__c = 10;
        qlGroup1.SBQQ__ListTotal__c = 10;
        qlGroup1.SBQQ__NetTotal__c = 100;
        qlGroup1.SBQQ__CustomerTotal__c = 1000;
        qlGroup1.SBQQ__Quote__c = TestQuote1.id;
        insert qlGroup1;
        
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
        
        integer numberofRecords = 10;
        List<SBQQ__QuoteLine__c> listInsertQuoteLine = new List<SBQQ__QuoteLine__c>();
        for(integer temp = 0; temp<numberofRecords ; temp++){
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
            listInsertQuoteLine.add(testQuoteLine);
        }
        insert listInsertQuoteLine;
        
        integer numberofRecords1 = 5;
        List<SBQQ__QuoteLine__c> listInsertQuoteLine1 = new List<SBQQ__QuoteLine__c>();
        for(integer temp = 0; temp<numberofRecords1 ; temp++){
            //Insert Quote Line
            SBQQ__QuoteLine__c testQuoteLine = new SBQQ__QuoteLine__c();
            testQuoteLine.SBQQ__Quantity__c = 1;
            testQuoteLine.SBQQ__Product__c = product1.Id;
            testQuoteLine.SBQQ__ListPrice__c = 10;
            testQuoteLine.SBQQ__NetPrice__c = 10;
            testQuoteLine.Rack_Rate__c = 10;
            testQuoteLine.SBQQ__SubscriptionPricing__c = 'Fixed Price';
            testQuoteLine.SBQQ__Number__c = 1;
            testQuoteLine.SBQQ__Group__c = qlGroup1.id;
            testQuoteLine.SBQQ__Quote__c = TestQuote1.Id;
            testQuoteLine.Notes__c = 'abc';
            testQuoteLine.SBQQ__UpgradedSubscription__c = sub.id;
            testQuoteLine.jsonString__c = 'test String';
            listInsertQuoteLine1.add(testQuoteLine);
        }
        insert listInsertQuoteLine1;
        //Insert Quote Line
        // SBQQ__QuoteLine__c testQuoteLine = new SBQQ__QuoteLine__c();
        // testQuoteLine.SBQQ__Quantity__c = 1;
        // testQuoteLine.SBQQ__Product__c = product1.Id;
        // testQuoteLine.SBQQ__ListPrice__c = 10;
        // testQuoteLine.SBQQ__NetPrice__c = 10;
        // testQuoteLine.Rack_Rate__c = 10;
        // testQuoteLine.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        // testQuoteLine.SBQQ__Number__c = 1;
        // testQuoteLine.SBQQ__Group__c = qlGroup.id;
        // testQuoteLine.SBQQ__Quote__c = TestQuote.Id;
        // testQuoteLine.Notes__c = 'abc';
        // testQuoteLine.SBQQ__UpgradedSubscription__c = sub.id;
        // testQuoteLine.jsonString__c = 'test String';
        
        // insert testQuoteLine;
        
        // //Insert Quote Line
        // SBQQ__QuoteLine__c testQuoteLine1 = new SBQQ__QuoteLine__c();
        // testQuoteLine1.SBQQ__Quantity__c = 1;
        // testQuoteLine1.SBQQ__Product__c = product1.Id;
        // testQuoteLine1.SBQQ__ListPrice__c = 10;
        // testQuoteLine1.SBQQ__NetPrice__c = 10;
        // testQuoteLine1.Rack_Rate__c = 10;
        // testQuoteLine1.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        // testQuoteLine1.SBQQ__Number__c = 1;
        // testQuoteLine1.SBQQ__Group__c = qlGroup.id;
        // testQuoteLine1.SBQQ__Quote__c = TestQuote.Id;
        // testQuoteLine1.Notes__c = 'abc';
        // testQuoteLine1.SBQQ__UpgradedSubscription__c = sub.id;
        // testQuoteLine1.SBQQ__Number__c = 500;
        // insert testQuoteLine1;       
    }

    private static testMethod void testQuoteLessThanSeven(){
        SBQQ__Quote__c newQuote = [SELECT Id FROM SBQQ__Quote__c WHERE createdFromLegacyContract__c = true limit 1];
       
        test.startTest();
        PageReference pageRef = Page.CventMyd_QuoteJsonView;
        pageRef.getParameters().put('quoteId', newQuote.Id);
        system.debug('This is from the testclass'+pageRef);
        Test.setCurrentPage(pageRef);
        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(newQuote);
        CventMyd_QuoteJsonController con = new CventMyd_QuoteJsonController(sc);
        test.stopTest();
    }
     private static testMethod void testQuoteGreaterThanSeven(){
        SBQQ__Quote__c newQuote = [SELECT Id FROM SBQQ__Quote__c WHERE createdFromLegacyContract__c = false limit 1];
       
        test.startTest();
        PageReference pageRef = Page.CventMyd_QuoteJsonView;
        pageRef.getParameters().put('quoteId', newQuote.Id);
        system.debug('This is from the testclass'+pageRef);
        Test.setCurrentPage(pageRef);
        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(newQuote);
        CventMyd_QuoteJsonController con = new CventMyd_QuoteJsonController(sc);
        con.toggleEditForm();
        con.quote.jsonString__c = '{"settings":{"preCalculationFieldNames":["SBQQ__Quantity__c","SBQQ__Discount__c","Custom_Discount__c","SBQQ__DistributorDiscount__c","SBQQ__PartnerDiscount__c","SBQQ__AdditionalDiscountAmount__c","Discount_Type__c","SBQQ__StartDate__c","SBQQ__EndDate__c","SBQQ__PricingMethod__c"],"numberFieldNames":["SBQQ__Quantity__c","SBQQ__Discount__c","Custom_Discount__c","SBQQ__DistributorDiscount__c","SBQQ__PartnerDiscount__c","SBQQ__OriginalPrice__c","SBQQ__ListPrice__c","SBQQ__RegularPrice__c","SBQQ__CustomerPrice__c","SBQQ__PartnerPrice__c","SBQQ__NetPrice__c","Rack_Rate__c","SBQQ__ProrateMultiplier__c","SBQQ__AdditionalDiscountAmount__c"],"msAtLastUpdate":1545430132643,"calculatedFieldNames":["SBQQ__OriginalPrice__c","SBQQ__ListPrice__c","SBQQ__RegularPrice__c","SBQQ__CustomerPrice__c","SBQQ__PartnerPrice__c","SBQQ__NetPrice__c","Rack_Rate__c","SBQQ__ProrateMultiplier__c"]},"previousQuoteType":"Quote","outyearMap":{},"insertionId":"75716_OVL_66139","currentYearSynced":true,"calculationIdString":"NOT_IN_CALCULATION_CONTEXT_Synchronous","automationStage":{"outyearProcessingStage":"NEWLY_INSERTED_NON_VARIABLE","codeStatus":"CALCULATION_CYCLE_FINISHED"}}';
        con.saveQuoteJson();        
        test.stopTest();
    }
}