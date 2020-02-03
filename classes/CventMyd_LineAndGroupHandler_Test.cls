@isTest(SeeAllData=false)

private class CventMyd_LineAndGroupHandler_Test {

    private static void updateOpportunityAddresses(Id opportunityId, Id accountId) {

        Id shippingAddressId = createShippingAddress(accountId).Id;  
        Id billingAddressId = createBillingAddress(accountId).Id;
        Opportunity opportunity = new Opportunity(Id = opportunityId, AccountId = accountId);
        opportunity.Bill_To_Address__c = billingAddressId;
        opportunity.Ship_To_Address__c = shippingAddressId;
        update opportunity;     

    } 

    private static Address__c createBillingAddress(Id accountId) {
        Address__c billingAddress = new Address__c(Account__c = accountId);
        billingAddress.Type__c = 'Billing';
        insert billingAddress;
        return billingAddress;
    }

    private static Address__c createShippingAddress(Id accountId) {
        Address__c shippingAddress = new Address__c(Account__c = accountId);
        shippingAddress.Type__c = 'Shipping';
        insert shippingAddress;
        return shippingAddress;
    }       
    
    private static testMethod void test1() {
                
        Id RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Parent Contract').getRecordTypeId();
        Id ChildRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Child Contract').getRecordTypeId();

        SBQQ.TriggerControl.disable();
        
        Account TestAccount = new Account();
        TestAccount.Name = 'Test Account';
        TestAccount.BillingCountryCode = 'US';
        TestAccount.BillingStateCode = 'NY';
        TestAccount.BillingPostalCode = '4654';
        insert TestAccount;
        
        Opportunity opp0 = TestUtil.createOpportunity('Test Opp', 'Renewal', 'Closed Won');
        opp0.CurrencyIsoCode  = 'USD';
        opp0.AccountId = TestAccount.id;
        insert opp0;
        updateOpportunityAddresses(opp0.Id,TestAccount.Id);

        SBQQ__Quote__c testQuote0 = new SBQQ__Quote__c();
        testQuote0.SBQQ__Opportunity2__c = opp0.id;
        testQuote0.SBQQ__Type__c = 'Quote';
        testQuote0.Current_Year__c = 1;
        testQuote0.Contract_Term_Years__c = '3';
        testQuote0.SBQQ__StartDate__c = System.today();
        testQuote0.SBQQ__EndDate__c = testQuote0.SBQQ__StartDate__c.addMonths(12);
        testQuote0.Contract_Executed__c = true;
        testQuote0.Multiple_Years_Commitment__c = true;

        insert testQuote0;

        List<SBQQ__QuoteLineGroup__c> groups = new List<SBQQ__QuoteLineGroup__c>();

        for(Integer i = 1; i <=3; i++) {

            SBQQ__QuoteLineGroup__c qlGroup = new SBQQ__QuoteLineGroup__c();
            qlGroup.Name = 'Group ' + String.valueOf(i);
            qlGroup.SBQQ__Number__c = i;
            qlGroup.SBQQ__ListTotal__c = 10;
            qlGroup.SBQQ__NetTotal__c = 100;
            qlGroup.SBQQ__CustomerTotal__c = 1000;
            qlGroup.SBQQ__Quote__c = testQuote0.id;
            qlGroup.term__c = (Decimal)i;  
            groups.add(qlGroup);

        }

        insert(groups);

        testQuote0.SBQQ__Opportunity2__c = opp0.Id;

        update testQuote0;

        //Product
        Product2 product1 = new Product2();
        product1.Name = 'Product 1';
        product1.Contract_Output_Grouping__c = 'Bundle Advertisements';
        product1.Revenue_Type__c = 'Non-Recurring';
        insert product1;   

        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();

        for(SBQQ__QuoteLineGroup__c qlg : groups) {
        
            //Insert Quote Line
            SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c();
            ql.SBQQ__Quantity__c = 1;
            ql.SBQQ__Product__c = product1.Id;
            ql.SBQQ__ListPrice__c = 10;
            ql.SBQQ__NetPrice__c = 10;
            ql.Rack_Rate__c = 10;
            ql.SBQQ__SubscriptionPricing__c = 'Fixed Price';
            ql.SBQQ__Number__c = 1;
            ql.SBQQ__Group__c = qlg.id;
            ql.SBQQ__Quote__c = testQuote0.Id;
            ql.Notes__c = 'abc';
            ql.jsonString__c = JSON.serialize(getTestQuoteLineObject());
            quoteLines.add(ql);

        }

        insert quoteLines;
        
        //Parent Contract to have Parent_Contract_Term_Years__c, Upcoming_Renewal_Type__c, Parent_Contract_Term_Years__c

        Contract ParentCont = new Contract();
        ParentCont.AccountId = TestAccount.id;
        ParentCont.Contract_Term_Years__c = '3';
        ParentCont.RecordTypeId = RecordTypeId;
        ParentCont.SBQQ__Opportunity__c = opp0.id;
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
        cont.Multiple_Years_Commitment__c = true;
        cont.SBQQ__RenewalQuoted__c = true;
        cont.SBQQ__Quote__c = testQuote0.Id;

        insert cont;

        System.debug('childContract.Id: ' + cont.Id);

        System.debug('childContract currentYear0 : ' + cont.Current_Year__c);

        Opportunity opp1 = TestUtil.createOpportunity('Test Opp', 'Renewal', 'Closed Won');
        opp1.CurrencyIsoCode  = 'USD';
        opp1.AccountId = TestAccount.id;

        
        insert opp1;

        opp1.SBQQ__RenewedContract__c = cont.id;

        update opp1;
        updateOpportunityAddresses(opp1.Id,TestAccount.Id);

        System.debug('childContract currentYear1 : ' + cont.Current_Year__c);

        SBQQ.TriggerControl.enable();
        
        //Normal Quote
        //Try inserting a Quote SBQQ__Type__c == Renewal
        SBQQ__Quote__c testQuote1 = new SBQQ__Quote__c();
        testQuote1.SBQQ__Opportunity2__c = opp1.id;
        testQuote1.Contract_Term_Years__c = '2';
        testQuote1.SBQQ__Type__c = 'Renewal';
        testQuote1.Current_Year__c = 2;
        testQuote1.Contract_Term_Years__c = '3';
        testQuote1.SBQQ__EndDate__c = System.today();
        testQuote1.Contract_Executed__c = true;
        testQuote1.Multiple_Years_Commitment__c = true;
        
        Test.startTest();
        
        insert testQuote1;

        SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c();
        ql1.SBQQ__Quantity__c = 1;
        ql1.SBQQ__Product__c = product1.Id;
        ql1.SBQQ__ListPrice__c = 10;
        ql1.SBQQ__NetPrice__c = 10;
        ql1.Rack_Rate__c = 10;
        ql1.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        ql1.SBQQ__Number__c = 1;
        ql1.SBQQ__Quote__c = testQuote1.Id;
        ql1.Notes__c = 'abc';
        ql1.jsonString__c = JSON.serialize(getTestQuoteLineObject());

        insert ql1;

        Test.stopTest();
        
        
        //Insert Subscription
        SBQQ__Subscription__c sub = new SBQQ__Subscription__c();
        sub.SBQQ__Product__c = product1.id;
        sub.SBQQ__Account__c = TestAccount.id;
        sub.SBQQ__Contract__c = ParentCont.id;
        sub.SBQQ__Quantity__c = 1;
        // insert sub;
        
    }

    public static CventMyd_QuoteLineObject getTestQuoteLineObject() {

        CventMyd_QuoteLineObject quoteLineObject = new CventMyd_QuoteLineObject();

        quoteLineObject.qleId = CventMyd_UtilityMethods.getQleId();

        quoteLineObject.insertOnNextCurrentYear = false;

        quoteLineObject.deleteThisLine = false;

        quoteLineObject.preCalculationFieldValueMap = new Map<String,List<String>>();

        quoteLineObject.calculatedFieldValueMap = new Map<String,List<String>>();

        for(List<String> fieldNameList : CventMyd_Settings.fieldValueMapFieldNameLists) {

            Integer index = CventMyd_Settings.fieldValueMapFieldNameLists.indexOf(fieldNameList);

            for(String fieldName : fieldNameList) {

                if(index == 0) {

                    quoteLineObject.preCalculationFieldValueMap.put(fieldName, new List<String>());

                    quoteLineObject.preCalculationFieldValueMap.get(fieldName).add('dummyString');

                }

                else if(index == 1) {
                    
                    quoteLineObject.calculatedFieldValueMap.put(fieldName, new List<String>());

                    quoteLineObject.calculatedFieldValueMap.get(fieldName).add('dummyString');


                }

            }

        }

        quoteLineObject.nextYearQleId = CventMyd_UtilityMethods.getQleId();

        return quoteLineObject;


    }

}