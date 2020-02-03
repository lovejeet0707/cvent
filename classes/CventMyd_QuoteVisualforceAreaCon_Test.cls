@isTest
private class CventMyd_QuoteVisualforceAreaCon_Test {
    
   @testSetup static void setup() {
        Id RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Parent Contract').getRecordTypeId();
        
        //Account
        Account TestAccount = new Account();
        TestAccount.Name = 'Test Account';
        insert TestAccount;
        
        //Insert Opp
        Opportunity opp = TestUtil.createOpportunity('Test Opp', 'Renewal', 'Closed Won');
        //opp.SBQQ__Contracted__c = true;
        opp.CurrencyIsoCode  = 'USD';
        insert opp;
        
        //List<SBQQ__Quote__c> newQuotes = new List<SBQQ__Quote__c>();
        //Insert Quote
        SBQQ__Quote__c TestQuote = new SBQQ__Quote__c();
        TestQuote.SBQQ__Opportunity2__c = opp.id;
        TestQuote.Contract_Term_Years__c = '2';
        TestQuote.SBQQ__Type__c = 'Renewal';
        TestQuote.Current_Year__c = 2;
        TestQuote.Contract_Executed__c = true;
        TestQuote.SBQQ__StartDate__c = System.today();
        TestQuote.SBQQ__EndDate__c = System.today().addYears(1);
        //TestQuote.Multiple_Years_Commitment__c = true;
        insert TestQuote;
        
        //Insert Quote
        SBQQ__Quote__c TestQuote1 = new SBQQ__Quote__c();
        TestQuote1.SBQQ__Opportunity2__c = opp.id;
        TestQuote1.Contract_Term_Years__c = '2';
        TestQuote1.SBQQ__Type__c = 'Amendment';
        TestQuote1.Current_Year__c = 2;
        TestQuote1.Contract_Executed__c = true;
        TestQuote1.SBQQ__StartDate__c = System.today().addYears(-1);
        TestQuote1.SBQQ__EndDate__c = System.today();
        //TestQuote.Multiple_Years_Commitment__c = true;
        //newQuotes.add(TestQuote1);
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
   
    }

    private static testMethod void testQuoteRenewal(){
        SBQQ__Quote__c newQuote = [SELECT Id FROM SBQQ__Quote__c WHERE SBQQ__Type__c = 'Renewal' limit 1];
       
        test.startTest();
            PageReference pageRef = Page.CventMyd_QuoteVisualforceAreaPage;
            pageRef.getParameters().put('quoteId', newQuote.Id);
            Test.setCurrentPage(pageRef);
            
            
            ApexPages.StandardController sc = new ApexPages.StandardController(newQuote);
            CventMyd_QuoteVisualforceAreaController con = new CventMyd_QuoteVisualforceAreaController(sc);
            // con.updateControllerDates();
            //con.saveQuote();
        test.stopTest();
    }
    private static testMethod void testQuoteAmend(){
        SBQQ__Quote__c newQuote = [SELECT Id FROM SBQQ__Quote__c WHERE SBQQ__Type__c = 'Amendment' limit 1];
       
        test.startTest();

            ApexPages.StandardController sc = new ApexPages.StandardController(newQuote);
            CventMyd_QuoteVisualforceAreaController con = new CventMyd_QuoteVisualforceAreaController(sc);
        test.stopTest();
    }
    private static testMethod void testQuoteWithOutYearMapTrue(){
        SBQQ__Quote__c newQuote = [SELECT Id FROM SBQQ__Quote__c WHERE SBQQ__Type__c = 'Amendment' limit 1];
       
        test.startTest();
            PageReference pageRef = Page.CventMyd_QuoteVisualforceAreaPage;
            pageRef.getParameters().put('quoteId', newQuote.Id);
            pageRef.getParameters().put('outyearMap', '{"2":{"startDate":"2020-5-10","endDate":"2021-5-9"},"3":{"startDate":"2021-5-10","endDate":"2022-5-9"},"4":{"startDate":"2022-5-10","endDate":"2023-5-9"},"5":{"startDate":"2023-5-10","endDate":"2024-5-9"}}');
            pageRef.getParameters().put('currentYearChange', String.valueOf(True));
            Test.setCurrentPage(pageRef);
            
            ApexPages.StandardController sc = new ApexPages.StandardController(newQuote);
            CventMyd_QuoteVisualforceAreaController con = new CventMyd_QuoteVisualforceAreaController(sc);
            con.updateControllerDates();
        test.stopTest();
    }
     private static testMethod void testQuoteWithOutYearMapFalse(){
        SBQQ__Quote__c newQuote = [SELECT Id FROM SBQQ__Quote__c WHERE SBQQ__Type__c = 'Amendment' limit 1];
       
        test.startTest();
            PageReference pageRef = Page.CventMyd_QuoteVisualforceAreaPage;
            pageRef.getParameters().put('quoteId', newQuote.Id);
            pageRef.getParameters().put('outyearMap', '{"2":{"startDate":"2020-5-10","endDate":"2021-5-9"},"3":{"startDate":"2021-5-10","endDate":"2022-5-9"},"4":{"startDate":"2022-5-10","endDate":"2023-5-9"},"5":{"startDate":"2023-5-10","endDate":"2024-5-9"}}');
            pageRef.getParameters().put('currentYearChange', String.valueOf(False));
            Test.setCurrentPage(pageRef);
            
            ApexPages.StandardController sc = new ApexPages.StandardController(newQuote);
            CventMyd_QuoteVisualforceAreaController con = new CventMyd_QuoteVisualforceAreaController(sc);
            CventMyd_ValidationHandler.settings.ruleNameToIsActive.put('Quote_Dates_Validity',false);
            con.updateControllerDates();
            con.saveQuote();
        test.stopTest();
    }

}