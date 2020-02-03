@isTest

private class CventMyd_QuoteLineJsonEditor_Test {

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
            testQuoteLine.jsonString__c = '{"qleId":"58914_pua_78378","quoteName":"Q-414311","preCalculationFieldValueMap":{"SBQQ__Quantity__c":[1.00],"SBQQ__Discount__c":[null],"Custom_Discount__c":[-3.267],"SBQQ__DistributorDiscount__c":[null],"SBQQ__PartnerDiscount__c":[null],"SBQQ__AdditionalDiscountAmount__c":[-3.267],"Discount_Type__c":["Amt."],"SBQQ__StartDate__c":["2019-10-20"],"SBQQ__EndDate__c":[null],"SBQQ__PricingMethod__c":["List"]},"calculatedFieldValueMap":{"SBQQ__OriginalPrice__c":[0],"SBQQ__ListPrice__c":[0],"SBQQ__RegularPrice__c":[0],"SBQQ__CustomerPrice__c":[0],"SBQQ__PartnerPrice__c":[0],"SBQQ__NetPrice__c":[3.267],"Rack_Rate__c":[0],"SBQQ__ProrateMultiplier__c":[1]},"contractedFieldValueMap":{},"clonedFromQleIds":[]}';
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
            testQuoteLine.jsonString__c = '{"qleId":"58914_pua_78378","quoteName":"Q-414311","preCalculationFieldValueMap":{"SBQQ__Quantity__c":[1.00],"SBQQ__Discount__c":[null],"Custom_Discount__c":[-3.267],"SBQQ__DistributorDiscount__c":[null],"SBQQ__PartnerDiscount__c":[null],"SBQQ__AdditionalDiscountAmount__c":[-3.267],"Discount_Type__c":["Amt."],"SBQQ__StartDate__c":["2019-10-20"],"SBQQ__EndDate__c":[null],"SBQQ__PricingMethod__c":["List"]},"calculatedFieldValueMap":{"SBQQ__OriginalPrice__c":[0],"SBQQ__ListPrice__c":[0],"SBQQ__RegularPrice__c":[0],"SBQQ__CustomerPrice__c":[0],"SBQQ__PartnerPrice__c":[0],"SBQQ__NetPrice__c":[3.267],"Rack_Rate__c":[0],"SBQQ__ProrateMultiplier__c":[1]},"contractedFieldValueMap":{},"clonedFromQleIds":[]}';
            listInsertQuoteLine1.add(testQuoteLine);
        }
        insert listInsertQuoteLine1;
    
    }	

	private static testMethod void testMethod0() {

		SBQQ__QuoteLine__c quoteLine = [SELECT Id FROM SBQQ__QuoteLine__c LIMIT 1];

		ApexPages.StandardController standardController = new ApexPages.StandardController(quoteLine);

		PageReference pageRef = Page.CventMyd_ContractAmendmentPage;

		Test.setCurrentPage(pageRef);

		CventMyd_QuoteLineJsonEditorController controller = new CventMyd_QuoteLineJsonEditorController(standardController);

		controller.recalculate = false;

		controller.updateJson();

	}

}