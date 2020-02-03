@isTest
private class cloneRelated_Test {

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

    private static void updateOpportunityAddresses(Id opportunityId, Id accountId) {

        Id shippingAddressId = createShippingAddress(accountId).Id;  
        Id billingAddressId = createBillingAddress(accountId).Id;
        Opportunity opportunity = new Opportunity(Id = opportunityId, AccountId = accountId);
        opportunity.Bill_To_Address__c = billingAddressId;
        opportunity.Ship_To_Address__c = shippingAddressId;
        update opportunity;     

    }    
	
	@isTest static void test_EC_MYD() {
        Account account = new Account();
        account.Name = 'Account 1';
        account.BillingStateCode='AK';
        account.BillingCountryCode='US';          
        insert account;
        Opportunity opp = new Opportunity();
        opp.name = 'test opp';
        opp.Product__c = 'Event';
        opp.StageName = 'Verbal';
        opp.CloseDate = System.today();
        opp.CurrencyIsoCode = 'USD'; 
        opp.AccountId = account.Id;
        insert opp;

        updateOpportunityAddresses(opp.Id,account.Id);

        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__StartDate__c = System.today();
        quote.SBQQ__EndDate__c = System.today() + 365;
        quote.jsonString__c = '{"settings":{"preCalculationFieldNames":["SBQQ__Quantity__c","SBQQ__Discount__c","SBQQ__DistributorDiscount__c","Custom_Discount__c","Discount_Type__c","Rate__c","Zone_Level__c","Number_of_Guest_Rooms__c","Lanyon_Chain_Affiliation__c","Chain_Affiliation__c","Group_Business_Mix__c","Setup_Days__c","Travel_Days__c","Event_Start_Date__c","Event_End_Date__c","Attendees__c","OnArrival_360_Event_Selection__c","Complexity__c","SBQQ__StartDate__c","SBQQ__EndDate__c","Search_Screen_Region__c","CSN_Tier__c"],"calculatedFieldNames":["SBQQ__OriginalPrice__c","SBQQ__ListPrice__c","SBQQ__RegularPrice__c","SBQQ__CustomerPrice__c","SBQQ__PartnerPrice__c","SBQQ__NetPrice__c","Rack_Rate__c","SBQQ__ProrateMultiplier__c"],"msAtLastUpdate":1528734627259},"previousQuoteType":null,"outyearMap":{"2":{"startDate":"2018-08-01","endDate":"2019-07-31"},"3":{"startDate":"2019-08-01","endDate":"2020-07-31"}},"insertionId":"94257_FQP_87354","currentYearSynced":null,"automationStage":{"outyearProcessingStage":"OUTYEAR_PROCESSING_COMPLETE","codeStatus":"CALCULATION_CYCLE_FINISHED"}}';
        quote.Contract_Term_Years__c = '5';
        quote.Count_of_HC_Products__c = 0;
        quote.Count_of_EC_Products__c = 1;
        quote.SBQQ__Account__c = account.Id;
        quote.Current_Year__c = 1;
        quote.SBQQ__Opportunity2__c = opp.id;
        quote.Multiple_Years_Commitment__c = TRUE;
        insert quote;
        //adding Groups
        List<SBQQ__QuoteLine__c> lst_ql= new List<SBQQ__QuoteLine__c>();
        Map<Integer, SBQQ__QuoteLineGroup__c> map_qlg = new Map<Integer, SBQQ__QuoteLineGroup__c>();
        for (Integer i = 0, j = 0; i < 5; i++) 
        {
            SBQQ__QuoteLineGroup__c qlg = new SBQQ__QuoteLineGroup__c();
            qlg.Name = 'Year'+(i+1);
            qlg.SBQQ__Number__c = i+1;
            qlg.SBQQ__ListTotal__c = 0.00;
            qlg.SBQQ__CustomerTotal__c = 0.00;
            qlg.SBQQ__NetTotal__c = 0.00;
            qlg.CurrencyIsoCode = 'USD';
            qlg.SBQQ__Quote__c = quote.id;
            qlg.term__c =i+1; 
            insert qlg;
            map_qlg.put(i, qlg);
        }
        Product2 product1 = new Product2();
        product1.Name = 'Product 1';
        product1.Contract_Output_Grouping__c = 'Event Cloud';
        product1.ProductCode = 'CV-SW-EC-EVT';
        insert product1;

        //List<SBQQ__QuoteLine__c> lst_qls = new List<SBQQ__QuoteLine__c>();
        Date startdate =System.today();
        Date endsdate = System.today() + 365;
        for (Integer i = 0, j = 0; i < 5; i++) 
        {
                SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c();
                ql1.SBQQ__Quantity__c = 1;
                ql1.SBQQ__Product__c = product1.Id;
                ql1.SBQQ__ListPrice__c = 10;
                ql1.SBQQ__NetPrice__c = 10;
                ql1.Rack_Rate__c = 10;
                ql1.SBQQ__SubscriptionPricing__c = 'Fixed Price';
                ql1.SBQQ__Quote__c = quote.Id;
                ql1.Notes__c = 'abc';
                ql1.Overage_Fee__c = i+1;
                ql1.SBQQ__Group__c = map_qlg.get(i).id;
                lst_ql.add(ql1);
        }
        insert lst_ql;

        PageReference pageRef = Page.cloneWithRelated;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stc = new ApexPages.StandardController(quote);
        cloneRelated controller = new cloneRelated(stc);
        controller.cloneQuote();
	}
	
}