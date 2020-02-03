@isTest
private class RemoveSubscriptionReference_Test {

    private static testMethod void BatchTest() {   
    
     Id RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Parent Contract').getRecordTypeId();
        Id ChildRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Child Contract').getRecordTypeId();
        
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
        
        Quote_Reconfigure__c qr = new Quote_Reconfigure__c();
        qr.Batch__c = 'DeleteSubscription';
        qr.Subscription_Id__c = sub.Id;
        insert qr;
        
        Database.executeBatch(new RemoveSubscriptionReference());
    }
}