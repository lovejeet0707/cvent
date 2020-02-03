@isTest
private class CventMyd_QuoteRouter_Test {

    private static testMethod void QuoteRouterTest() {
        
        Id RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Parent Contract').getRecordTypeId();
        Id ChildRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Child Contract').getRecordTypeId();
        
        //Account
        Account TestAccount = new Account();
        TestAccount.Name = 'Test Account';
        insert TestAccount;

        Contact contactPerson = TestUtil.createContact('Test FirstName', 'Lastname', 'test@mojonestworks.com', String.valueOf(TestAccount.id));
        contactPerson.MailingCountry = 'US';
        contactPerson.MailingCountryCode = 'US';
        contactPerson.MailingState = 'NY';
        contactPerson.MailingStateCode = 'NY';          
            
        insert contactPerson;              
        
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
        ParentCont.Contract_Term_Years__c = '3';
        ParentCont.RecordTypeId = RecordTypeId;
        ParentCont.SBQQ__Opportunity__c = opp.id;
        insert ParentCont;

        //Child Contract
        Contract cont = new Contract();
        cont.RecordTypeId = ChildRecordTypeId;
        cont.AccountId = TestAccount.id;
        cont.Parent_Contract__c = ParentCont.id;
        //cont.Upcoming_Renewal_Type__c = 'Contract Renewal';
        cont.EndDate = System.today();
        //cont.Remaining_Master_Term__c = 0;
        cont.Current_Year__c = 1;
        cont.StartDate = System.today().addMonths(-12);
        insert cont;  

        //Product
        Product2 product1 = new Product2();
        product1.Name = 'Product 1';
        product1.Contract_Output_Grouping__c = 'Bundle Advertisements';
        insert product1;
        
        //Insert Subscription
        SBQQ__Subscription__c sub = new SBQQ__Subscription__c();
        sub.SBQQ__Product__c = product1.id;
        sub.SBQQ__Account__c = TestAccount.id;
        sub.SBQQ__Contract__c = cont.id;
        sub.SBQQ__Quantity__c = 0;
        insert sub;        

        CventMyd_ContractAmendmentController.contractIdsBeingAmended.add(cont.Id);        

        CventMyd_LegacyContractHandler.getAndSetLegacySubscriptions(CventMyd_ContractAmendmentController.contractIdsBeingAmended);

        opp.SBQQ__AmendedContract__c = cont.Id;

        opp.Contact_Associated__c = contactPerson.Id;

        //opp.SBQQ__RenewedContract__c = cont.Id;

        update opp;
        
        //Insert Quote Line
        SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c();
        ql1.SBQQ__Quantity__c = 1;
        ql1.SBQQ__Product__c = product1.Id;
        ql1.SBQQ__ListPrice__c = 10;
        ql1.SBQQ__NetPrice__c = 10;
        ql1.Rack_Rate__c = 10;
        ql1.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        ql1.SBQQ__Number__c = 1;
        ql1.SBQQ__Group__c = qlGroup.id;
        ql1.SBQQ__Quote__c = TestQuote.Id;
        ql1.Notes__c = 'abc';
        ql1.SBQQ__RenewedSubscription__c = sub.id;
        insert ql1;
        
        //Quote2
        SBQQ__Quote__c TestQuote2 = new SBQQ__Quote__c();
        TestQuote2.createdFromLegacyContract__c = true;
        TestQuote2.SBQQ__Opportunity2__c = opp.id;
        TestQuote2.Contract_Term_Years__c = '2';
        TestQuote2.Current_Year__c = 2;
        TestQuote2.SBQQ__Type__c = 'Amendment';
        TestQuote2.Contract_Executed__c = true;
        TestQuote2.SBQQ__StartDate__c = System.today().addYears(-1);
        TestQuote2.SBQQ__EndDate__c = System.today();
        //TestQuote2.Multiple_Years_Commitment__c = true;
        TestQuote2.previousQuote__c = null;
        insert TestQuote2;
        
        TestQuote2.Multiple_Years_Commitment__c = true;
        update TestQuote2;
        
        //Insert Quote Line2
        SBQQ__QuoteLine__c ql2 = new SBQQ__QuoteLine__c();
        ql2.SBQQ__Quantity__c = 1;
        ql2.SBQQ__Product__c = product1.Id;
        ql2.SBQQ__ListPrice__c = 10;
        ql2.SBQQ__NetPrice__c = 10;
        ql2.Rack_Rate__c = 10;
        ql2.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        ql2.SBQQ__Number__c = 1;
        ql2.SBQQ__Group__c = qlGroup.id;
        ql2.SBQQ__Quote__c = TestQuote2.Id;
        ql2.Notes__c = 'abc';
        ql2.SBQQ__UpgradedSubscription__c = sub.id;
        insert ql2;

    }

    private static testMethod void QuoteRouterTest2() {
        
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
        //TestQuote.nonOptionalLineCount__c = 1;
        //TestQuote.createdFromLegacyContract__c = false;
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
        SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c();
        ql1.SBQQ__Quantity__c = 1;
        ql1.SBQQ__Product__c = product1.Id;
        ql1.SBQQ__ListPrice__c = 10;
        ql1.SBQQ__NetPrice__c = 10;
        ql1.Rack_Rate__c = 10;
        ql1.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        ql1.SBQQ__Number__c = 1;
        ql1.SBQQ__Group__c = qlGroup.id;
        ql1.SBQQ__Quote__c = TestQuote.Id;
        ql1.Notes__c = 'abc';
        ql1.SBQQ__UpgradedSubscription__c = sub.id;
        insert ql1;
        
                //Insert Quote Line
        SBQQ__QuoteLine__c ql3 = new SBQQ__QuoteLine__c();
        ql3.SBQQ__Quantity__c = 1;
        ql3.SBQQ__Product__c = product1.Id;
        ql3.SBQQ__ListPrice__c = 10;
        ql3.SBQQ__NetPrice__c = 10;
        ql3.Rack_Rate__c = 10;
        ql3.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        ql3.SBQQ__Number__c = 1;
        ql3.SBQQ__Group__c = qlGroup.id;
        ql3.SBQQ__Quote__c = TestQuote.Id;
        ql3.Notes__c = 'abc';
        ql3.SBQQ__UpgradedSubscription__c = sub.id;
        insert ql3;
        
        //Quote2
        SBQQ__Quote__c TestQuote2 = new SBQQ__Quote__c();
        TestQuote2.SBQQ__Opportunity2__c = opp.id;
        TestQuote2.Contract_Term_Years__c = '2';
        TestQuote2.Current_Year__c = 2;
        TestQuote2.SBQQ__Type__c = 'Renewal';
        TestQuote2.Contract_Executed__c = true;
        TestQuote2.SBQQ__StartDate__c = System.today().addYears(-1);
        TestQuote2.SBQQ__EndDate__c = System.today();
        //TestQuote2.Multiple_Years_Commitment__c = true;
        TestQuote.createdFromLegacyContract__c = false;
        TestQuote2.previousQuote__c = TestQuote.id;
        insert TestQuote2;
        
        TestQuote2.Multiple_Years_Commitment__c = true;
        update TestQuote2;
        
        //Insert Quote Line2
        SBQQ__QuoteLine__c ql2 = new SBQQ__QuoteLine__c();
        ql2.SBQQ__Quantity__c = 1;
        ql2.SBQQ__Product__c = product1.Id;
        ql2.SBQQ__ListPrice__c = 10;
        ql2.SBQQ__NetPrice__c = 10;
        ql2.Rack_Rate__c = 10;
        ql2.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        ql2.SBQQ__Number__c = 1;
        ql2.SBQQ__Group__c = qlGroup.id;
        ql2.SBQQ__Quote__c = TestQuote2.Id;
        ql2.Notes__c = 'abc';
        ql2.SBQQ__UpgradedSubscription__c = sub.id;
        insert ql2;

    }

}