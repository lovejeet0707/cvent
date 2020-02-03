@isTest
private class CventMyd_LegacyContractHandler_Test {
    
    @testSetup static void setup() {
        Id ParentRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Parent Contract').getRecordTypeId();
        Id ChildRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Child Contract').getRecordTypeId();
        //Account
        Account TestAccount = TestUtil.createAccount('Test Account','Biz_Ac');
        insert TestAccount;
        
        //Insert Opp
        Opportunity opp = TestUtil.createOpportunity('Test Opp', 'Renewal', 'Closed Won');
        opp.CurrencyIsoCode  = 'USD';
        insert opp;

        System.debug('opportunity id in test class: ' + opp.Id);
    
        //Insert Quote
        SBQQ__Quote__c TestQuote = new SBQQ__Quote__c();
        TestQuote.SBQQ__Opportunity2__c = opp.id;
        TestQuote.Contract_Term_Years__c = '2';
        TestQuote.SBQQ__Type__c = 'Renewal';
        TestQuote.Current_Year__c = 1;
        TestQuote.Contract_Executed__c = true;
        TestQuote.SBQQ__StartDate__c = Date.today().addDays(-5);
        TestQuote.SBQQ__EndDate__c = Date.today().addYears(1);
        TestQuote.createdFromLegacyContract__c = true;
        TestQuote.Multiple_Years_Commitment__c = true;
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
        
        //Parent Contract to have Parent_Contract_Term_Years__c, Upcoming_Renewal_Type__c, Parent_Contract_Term_Years__c
        Contract ParentCont = new Contract();
        ParentCont.AccountId = TestAccount.id;
        ParentCont.Contract_Term_Years__c = '2';
        ParentCont.RecordTypeId = ParentRecordTypeId;
        ParentCont.SBQQ__Opportunity__c = opp.id;
        ParentCont.Current_Year__c = 1;
        ParentCont.Year_2_End_Date__c = Date.today().addYears(1);
        ParentCont.EndDate = Date.today().addYears(1);
        insert ParentCont;
        
        //Parent Contract to have Parent_Contract_Term_Years__c, Upcoming_Renewal_Type__c, Parent_Contract_Term_Years__c
        Contract ParentCont1 = new Contract();
        ParentCont1.AccountId = TestAccount.id;
        ParentCont1.Contract_Term_Years__c = '1';
        ParentCont1.RecordTypeId = ParentRecordTypeId;
        ParentCont1.SBQQ__Opportunity__c = opp.id;
        ParentCont1.Current_Year__c = 1;
        ParentCont1.Year_2_End_Date__c = Date.today().addYears(1);
        ParentCont1.EndDate = Date.today().addYears(1);
        insert ParentCont1;
        
        Contract ChildCont = new Contract();
        ChildCont.AccountId = TestAccount.id;
        ChildCont.Contract_Term_Years__c = ParentCont.Contract_Term_Years__c;
        ChildCont.RecordTypeId = ChildRecordTypeId;
        ChildCont.Parent_Contract__c = ParentCont.Id;
        ChildCont.SBQQ__Opportunity__c = opp.id;
        ChildCont.Current_Year__c = 1;
        ChildCont.Year_2_End_Date__c = ParentCont.Year_2_End_Date__c;
        ChildCont.EndDate = ParentCont.EndDate;
        insert ChildCont;
        
        Contract ChildCont1 = new Contract();
        ChildCont1.AccountId = TestAccount.id;
        ChildCont1.Contract_Term_Years__c = ParentCont1.Contract_Term_Years__c;
        ChildCont1.RecordTypeId = ChildRecordTypeId;
        ChildCont1.Parent_Contract__c = ParentCont1.Id;
        ChildCont1.SBQQ__Opportunity__c = opp.id;
        ChildCont1.Current_Year__c = 1;
        ChildCont1.Year_2_End_Date__c = ParentCont.Year_2_End_Date__c;
        ChildCont1.EndDate = ParentCont.EndDate;
        insert ChildCont1;
        
        //Product
        Product2 product0 = new Product2();
        product0.Name = 'Product 0';
        product0.Contract_Output_Grouping__c = 'Bundle Advertisements';
        insert product0;

        Product2 product1 = new Product2();
        product1.Name = 'Product 1';
        product1.Contract_Output_Grouping__c = 'Bundle Advertisements';
        insert product1;        
        
        //Insert Subscription
        SBQQ__Subscription__c parentSub = new SBQQ__Subscription__c();
        parentSub.SBQQ__Product__c = product0.id;
        parentSub.SBQQ__Account__c = TestAccount.id;
        parentSub.SBQQ__Contract__c = ParentCont1.id;
        parentSub.SBQQ__Quantity__c = 1;
        parentSub.SBQQ__SubscriptionStartDate__c = Date.today().addDays(-5);
        insert parentSub;
        
        //Insert Subscription
        SBQQ__Subscription__c sub = new SBQQ__Subscription__c();
        sub.SBQQ__Product__c = product1.id;
        sub.SBQQ__Account__c = TestAccount.id;
        sub.SBQQ__Contract__c = ChildCont.id;
        sub.SBQQ__Quantity__c = 1;
        sub.SBQQ__SubscriptionStartDate__c = Date.today().addDays(-5);
        insert sub;
        
        //Insert Subscription
        SBQQ__Subscription__c sub1 = new SBQQ__Subscription__c();
        sub1.SBQQ__Product__c = product1.id;
        sub1.SBQQ__Account__c = TestAccount.id;
        sub1.SBQQ__Contract__c = ChildCont.id;
        sub1.SBQQ__Quantity__c = 1;
        sub1.SBQQ__SubscriptionStartDate__c = Date.today().addDays(-5);
        sub1.SBQQ__RequiredById__c = String.valueOf(sub.Id);
        sub1.SBQQ__TerminatedDate__c = ChildCont.EndDate;
        sub1.SBQQ__RenewalQuantity__c = 0;
        insert sub1;
        
        //Insert Quote Line
        SBQQ__QuoteLine__c testQuoteLine = new SBQQ__QuoteLine__c();
        testQuoteLine.SBQQ__Quantity__c = 1;
        testQuoteLine.SBQQ__Product__c = product0.Id;
        testQuoteLine.SBQQ__ListPrice__c = 10;
        testQuoteLine.SBQQ__NetPrice__c = 10;
        testQuoteLine.Rack_Rate__c = 10;
        testQuoteLine.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        testQuoteLine.SBQQ__Number__c = 1;
        testQuoteLine.SBQQ__Group__c = qlGroup.id;
        testQuoteLine.SBQQ__Quote__c = TestQuote.Id;
        testQuoteLine.Notes__c = 'abc';
        testQuoteLine.SBQQ__UpgradedSubscription__c = sub.id;
        testQuoteLine.jsonString__c = '{"deleteThisLine": true,"startDate":"2018-04-17","settings":{"preCalculationFieldNames":["SBQQ__Quantity__c","SBQQ__Discount__c","Custom_Discount__c","Discount_Type__c","SBQQ__AdditionalDiscount__c","Rate__c","Zone_Level__c","Number_of_Guest_Rooms__c","Lanyon_Chain_Affiliation__c","Chain_Affiliation__c","Setup_Days__c","Travel_Days__c","Event_Start_Date__c","Event_End_Date__c","Attendees__c","OnArrival_360_Event_Selection__c"],"calculatedFieldNames":["SBQQ__OriginalPrice__c","SBQQ__ListPrice__c","SBQQ__RegularPrice__c","SBQQ__NetPrice__c","Rack_Rate__c"],"msAtLastUpdate":1525180814312},"outyearMap":{"2":{"year":2,"startDate":"2019-04-17","endDate":"2020-04-16"},"3":{"year":3,"startDate":"2020-04-17","endDate":"2021-04-16"},"4":{"year":4,"startDate":"2021-04-17","endDate":"2022-04-16"},"5":{"year":5,"startDate":"2022-04-17","endDate":"2023-04-16"}},"isManuallyCreatedFirstYear":null,"endDate":"2019-04-16","automationStage":{"renewalStage":null,"codeStatus":"CALCULATION_CYCLE_FINISHED"}}';
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
        testQuoteLine1.SBQQ__UpgradedSubscription__c = sub1.id;
        testQuoteLine1.jsonString__c = '{"deleteThisLine": true}';
        testQuoteLine1.SBQQ__RequiredBy__c = String.valueOf(testQuoteLine.Id);
        testQuoteLine1.SBQQ__Number__c = 2;

        SBQQ.TriggerControl.disable();

        insert testQuoteLine1;       

        SBQQ.TriggerControl.enable();
    }

    private static testMethod void test() {
        
        CventMyd_LegacyContractHandler con = new CventMyd_LegacyContractHandler();
        Map<Id,Contract> newCont = new Map<Id,Contract>([SELECT Id,recordTypeName__c,RecordTypeId,Current_Year__c,Contract_Term_Years__c,Parent_Contract__c,Parent_Contract_Term_Years__c,Parent_Contract__r.RecordTypeId,Parent_Contract__r.recordTypeName__c,Parent_Contract__r.Current_Year__c,Parent_Contract__r.Contract_Term_Years__c,Parent_Contract__r.Parent_Contract_Term_Years__c,Upcoming_Renewal_Type__c,EndDate,Parent_Contract__r.EndDate FROM Contract WHERE RecordType.Name = 'Child Contract']);
        List<SBQQ__QuoteLine__c> newQuoteLines = [SELECT Id,jsonString__c,SBQQ__Quote__c,SBQQ__Quote__r.createdFromLegacyContract__c,SBQQ__Quote__r.Multiple_Years_Commitment__c,SBQQ__Quote__r.Contract_Term_Years__c,SBQQ__Quote__r.SBQQ__Type__c,SBQQ__Quote__r.Current_Year__c,SBQQ__Quote__r.numberOfQuoteLineGroups__c,SBQQ__RequiredBy__c,SBQQ__Number__c FROM SBQQ__QuoteLine__c];
        List<SBQQ__Subscription__c> newsubs = [SELECT Id,SBQQ__Contract__c,SBQQ__Contract__r.Upcoming_Renewal_Type__c,SBQQ__Contract__r.Multiple_Years_Commitment__c,SBQQ__Product__r.Revenue_Type__c,SBQQ__Number__c,SBQQ__Contract__r.Current_Year__c,SBQQ__RevisedSubscription__c,SBQQ__Quantity__c FROM SBQQ__Subscription__c];
        List<SBQQ__Subscription__c> newsubswithRecId = [SELECT Id,SBQQ__Contract__c,SBQQ__Contract__r.Upcoming_Renewal_Type__c,SBQQ__Contract__r.Multiple_Years_Commitment__c,SBQQ__Product__r.Revenue_Type__c,SBQQ__Number__c,SBQQ__Contract__r.Current_Year__c,SBQQ__RevisedSubscription__c,SBQQ__Quantity__c,SBQQ__RequiredById__c,SBQQ__TerminatedDate__c, SBQQ__RenewalQuantity__c FROM SBQQ__Subscription__c WHERE SBQQ__RequiredById__c != null];
        CventMyd_QuoteLineObject quoteLineObject = new CventMyd_QuoteLineObject();
        quoteLineObject.deleteThisLine = true;
        Set<Id> newCon = newCont.keySet();
        
        system.debug('these are the subs'+newsubs);
        CventMyd_LegacyContractHandler.getAndSetLegacySubscriptions(newCon);
        CventMyd_LegacyContractHandler.getQuoteLinesToDeleteOnIntratermRenewal(newQuoteLines);
        CventMyd_LegacyContractHandler.getRenewableLineCount(newsubs);
        CventMyd_LegacyContractHandler.getExpectedQuoteLineCount(newsubswithRecId,'Renewal');
        CventMyd_LegacyContractHandler.getQuoteLinesToRenumber(newQuoteLines);
        list<SBQQ__Quote__c> newQuote = [SELECT Id,Current_Year__c,SBQQ__StartDate__c FROM SBQQ__Quote__c];
        List<CventMyd_LineAndGroupHandler.QuoteLineWrapper> quoteLineWrappers = new List<CventMyd_LineAndGroupHandler.QuoteLineWrapper>();
        quoteLineWrappers.add(new CventMyd_LineAndGroupHandler.QuoteLineWrapper(newQuoteLines[0],newQuote[0].Id));
        CventMyd_LegacyContractHandler.getOrderedQuoteLineWrappers(quoteLineWrappers);
        
        CventMyd_LegacyContractHandler.getEndDateForQuoteCreatedFromLegacyContract(newQuote[0],newCont.get(new List<Id>(newCon)[0]));
    }
}