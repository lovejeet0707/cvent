@isTest
private class QuoteLinesFilteredControllerTest {
    
    @isTest
    static void testGetQuoteLinesList() {
        
        List<SBQQ__QuoteLine__c> lst_ql= new List<SBQQ__QuoteLine__c>();
        Account account = new Account(); 
        account.Name = 'Account 1';
        account.BillingCountry='MX';

        insert account;

        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__StartDate__c = System.today();
        quote.SBQQ__EndDate__c = System.today() + 365;
        quote.Contract_Term_Years__c = '5';
        quote.Count_of_HC_Products__c = 0;
        quote.Count_of_EC_Products__c = 1;
        quote.SBQQ__Account__c = account.Id;
        quote.Current_Year__c = 1;
        quote.Multiple_Years_Commitment__c = TRUE;
        insert quote;

        //adding Groups
        Map<Integer, SBQQ__QuoteLineGroup__c> map_qlg = new Map<Integer, SBQQ__QuoteLineGroup__c>();
        for (Integer i = 0, j = 0; i < 5; i++) 
        {
            SBQQ__QuoteLineGroup__c qlg = new SBQQ__QuoteLineGroup__c();
            qlg.Name = 'Year'+i;
            qlg.SBQQ__Number__c = i;
            qlg.SBQQ__ListTotal__c = 0.00;
            qlg.SBQQ__CustomerTotal__c = 0.00;
            qlg.SBQQ__NetTotal__c = 0.00;
            qlg.CurrencyIsoCode = 'USD';
            qlg.SBQQ__Quote__c = quote.id;
            insert qlg;
            map_qlg.put(i, qlg);
        }
        //create new OnArrival_360_Events__c for logic
        OnArrival_360_Events__c newOnArrival360 = new OnArrival_360_Events__c();
        newOnArrival360.Account__c = account.id;
        newOnArrival360.Name = 'TESTnewOnArrival360';
        insert newOnArrival360;

        Product2 product1 = new Product2();
        product1.Name = 'Product 1';
        product1.Contract_Output_Grouping__c = 'Event Cloud';
        product1.ProductCode = 'CBP-123-456-ABC';
        insert product1;
        Product2 product_2 = new Product2();
        product_2.Name = 'Product 2';
        product_2.Contract_Output_Grouping__c = 'Event Cloud';
        product_2.ProductCode = 'CV-SW-EC-EVT-CCMOB';
        insert product_2;
        for (Integer i = 0, j = 0; i < 5; i++) 
        {
            SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c();
            ql1.SBQQ__Quantity__c = 2;
            ql1.SBQQ__PriorQuantity__c = 0;
            ql1.SBQQ__Product__c = product1.Id;
            ql1.SBQQ__RegularPrice__c = 10;
            ql1.SBQQ__NetPrice__c = 10;
            ql1.OnArrival_360_Event_Selection__c = newOnArrival360.id;
            ql1.Rack_Rate__c = 10;
            if(i>2)
            {
                ql1.SBQQ__RegularPrice__c = 0.00;
            }
            ql1.SBQQ__SubscriptionPricing__c = 'Fixed Price';
            ql1.SBQQ__ListPrice__c = 20;
            ql1.SBQQ__Quote__c = quote.Id;
            ql1.Notes__c = 'abc';
            ql1.Overage_Fee__c = 2;
            ql1.SBQQ__Group__c = map_qlg.get(i).id;
            lst_ql.add(ql1);
        }
        insert lst_ql;
        for (Integer i = 0, j = 0; i < 5; i++) 
        {
            SBQQ__QuoteLine__c ql2 = new SBQQ__QuoteLine__c();
            ql2.SBQQ__Quantity__c = 2;
            ql2.SBQQ__PriorQuantity__c = 0;
            ql2.SBQQ__Product__c = product_2.Id;
            ql2.SBQQ__NetPrice__c = 10;
            ql2.Rack_Rate__c = 10;
            ql2.OnArrival_360_Event_Selection__c = newOnArrival360.id;
            ql2.SBQQ__SubscriptionPricing__c = 'Fixed Price';
            ql2.SBQQ__ListPrice__c = 20;
            ql2.Notes__c = 'abc';
            ql2.Overage_Fee__c = 2;
            if(i>2)
            {
                ql2.SBQQ__RegularPrice__c = 0.00;
            }
            ql2.SBQQ__Quote__c = quote.Id;
            ql2.SBQQ__Group__c = map_qlg.get(i).id;
            ql2.SBQQ__RequiredBy__c = lst_ql[i].id;
            lst_ql.add(ql2);
        }
        upsert lst_ql;

        QuoteLinesFilteredController controller = new QuoteLinesFilteredController();
        controller.objId = quote.Id;
        
        List<QuoteLinesFilteredController.DisplayWrapper> qlList = controller.getQuoteLineList();
        System.assertNotEquals(null, qlList.size());
        System.assertNotEquals(0, qlList.size());
    }
    @isTest
    static void testGetQuoteLinesListOA360() {
        
        List<SBQQ__QuoteLine__c> lst_ql= new List<SBQQ__QuoteLine__c>();
        Account account = new Account(); 
        account.Name = 'Account 1';
        account.BillingCountry='MX';
        insert account;

        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__StartDate__c = System.today();
        quote.SBQQ__EndDate__c = System.today() + 365;
        quote.Contract_Term_Years__c = '5';
        quote.Count_of_HC_Products__c = 0;
        quote.Count_of_EC_Products__c = 1;
        quote.SBQQ__Account__c = account.Id;
        quote.Current_Year__c = 1;
        quote.Multiple_Years_Commitment__c = TRUE;
        insert quote;

        //adding Groups
        Map<Integer, SBQQ__QuoteLineGroup__c> map_qlg = new Map<Integer, SBQQ__QuoteLineGroup__c>();
        for (Integer i = 0, j = 0; i < 5; i++) 
        {
            SBQQ__QuoteLineGroup__c qlg = new SBQQ__QuoteLineGroup__c();
            qlg.Name = 'Year'+i;
            qlg.SBQQ__Number__c = i;
            qlg.SBQQ__ListTotal__c = 0.00;
            qlg.SBQQ__CustomerTotal__c = 0.00;
            qlg.SBQQ__NetTotal__c = 0.00;
            qlg.CurrencyIsoCode = 'USD';
            qlg.SBQQ__Quote__c = quote.id;
            insert qlg;
            map_qlg.put(i, qlg);
        }
        //create new OnArrival_360_Events__c for logic
        OnArrival_360_Events__c newOnArrival360 = new OnArrival_360_Events__c();
        newOnArrival360.Account__c = account.id;
        newOnArrival360.Name = 'TESTnewOnArrival360';
        insert newOnArrival360;

        Product2 product1 = new Product2();
        product1.Name = 'Product 1';
        product1.Contract_Output_Grouping__c = 'OA 360 Software';
        product1.ProductCode = 'CV-PS-HC-OSS-OA360';
        insert product1;
        Product2 product_2 = new Product2();
        product_2.Name = 'Product 2';
        product_2.Contract_Output_Grouping__c = 'OA 360 Software';
        product_2.ProductCode = 'CV-PS-HC-OSS-OA360';
        insert product_2;
        for (Integer i = 0, j = 0; i < 5; i++) 
        {
            SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c();
            ql1.SBQQ__Quantity__c = 2;
            ql1.SBQQ__PriorQuantity__c = 0;
            ql1.SBQQ__Product__c = product1.Id;
            ql1.SBQQ__RegularPrice__c = 10;
            ql1.SBQQ__NetPrice__c = 10;
            ql1.OnArrival_360_Event_Selection__c = newOnArrival360.id;
            ql1.Rack_Rate__c = 10;
            if(i>2)
            {
                ql1.SBQQ__RegularPrice__c = 0.00;
            }
            ql1.SBQQ__SubscriptionPricing__c = 'Fixed Price';
            ql1.SBQQ__ListPrice__c = 20;
            ql1.SBQQ__Quote__c = quote.Id;
            ql1.Notes__c = 'abc';
            ql1.Overage_Fee__c = 2;
            ql1.SBQQ__Group__c = map_qlg.get(i).id;
            lst_ql.add(ql1);
        }
        insert lst_ql;
        for (Integer i = 0, j = 0; i < 5; i++) 
        {
            SBQQ__QuoteLine__c ql2 = new SBQQ__QuoteLine__c();
            ql2.SBQQ__Quantity__c = 2;
            ql2.SBQQ__PriorQuantity__c = 0;
            ql2.SBQQ__Product__c = product_2.Id;
            ql2.SBQQ__NetPrice__c = 10;
            ql2.Rack_Rate__c = 10;
            ql2.OnArrival_360_Event_Selection__c = newOnArrival360.id;
            ql2.SBQQ__SubscriptionPricing__c = 'Fixed Price';
            ql2.SBQQ__ListPrice__c = 20;
            ql2.Notes__c = 'abc';
            ql2.Overage_Fee__c = 2;
            //if(i>2)
            //{
                ql2.SBQQ__RegularPrice__c = 0.00;
            //}
            ql2.SBQQ__Quote__c = quote.Id;
            ql2.SBQQ__Group__c = map_qlg.get(i).id;
            ql2.SBQQ__RequiredBy__c = lst_ql[i].id;
            lst_ql.add(ql2);
        }
        upsert lst_ql;

        QuoteLinesFilteredController controller = new QuoteLinesFilteredController();
        controller.objId = quote.Id;
        
        List<QuoteLinesFilteredController.DisplayWrapper> qlList = controller.getQuoteLineList();
        System.assertNotEquals(null, qlList.size());
        System.assertNotEquals(0, qlList.size());
    }
    @isTest
    static void testGetCrowdCompass() {
        
        List<SBQQ__QuoteLine__c> lst_ql= new List<SBQQ__QuoteLine__c>();
        Account account = new Account(); 
        account.Name = 'Account 1';
        account.BillingCountry='MX';
        insert account;

        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__StartDate__c = System.today();
        quote.SBQQ__EndDate__c = System.today() + 365;
        quote.Contract_Term_Years__c = '5';
        quote.Count_of_HC_Products__c = 0;
        quote.Count_of_EC_Products__c = 1;
        quote.SBQQ__Account__c = account.Id;
        quote.Current_Year__c = 1;
        quote.Multiple_Years_Commitment__c = TRUE;
        insert quote;

        //adding Groups
        Map<Integer, SBQQ__QuoteLineGroup__c> map_qlg = new Map<Integer, SBQQ__QuoteLineGroup__c>();
        for (Integer i = 0, j = 0; i < 5; i++) 
        {
            SBQQ__QuoteLineGroup__c qlg = new SBQQ__QuoteLineGroup__c();
            qlg.Name = 'Year'+i;
            qlg.SBQQ__Number__c = i;
            qlg.SBQQ__ListTotal__c = 0.00;
            qlg.SBQQ__CustomerTotal__c = 0.00;
            qlg.SBQQ__NetTotal__c = 0.00;
            qlg.CurrencyIsoCode = 'USD';
            qlg.SBQQ__Quote__c = quote.id;
            insert qlg;
            map_qlg.put(i, qlg);
        }
        //create new OnArrival_360_Events__c for logic
        OnArrival_360_Events__c newOnArrival360 = new OnArrival_360_Events__c();
        newOnArrival360.Account__c = account.id;
        newOnArrival360.Name = 'TESTnewOnArrival360';
        insert newOnArrival360;

        Product2 product1 = new Product2();
        product1.Name = 'Product 1';
        product1.Contract_Output_Grouping__c = 'Event Cloud';
        product1.ProductCode = 'CV-SW-EC-EVT-CCMOBAPP';
        insert product1;
        Product2 product_2 = new Product2();
        product_2.Name = 'Product 2';
        product_2.Contract_Output_Grouping__c = 'Event Cloud';
        product_2.ProductCode = 'CV-SW-EC-CC-CCMBAP51-CCMBAP51';
        insert product_2;
        for (Integer i = 0, j = 0; i < 5; i++) 
        {
            SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c();
            ql1.SBQQ__Quantity__c = 2;
            ql1.SBQQ__PriorQuantity__c = 0;
            ql1.SBQQ__Product__c = product1.Id;
            
            ql1.SBQQ__RegularPrice__c = 10;
            ql1.SBQQ__NetPrice__c = 10;
            ql1.OnArrival_360_Event_Selection__c = newOnArrival360.id;
            ql1.Rack_Rate__c = 10;
            if(i>2)
            {
                ql1.SBQQ__RegularPrice__c = 0.00;
            }
            ql1.SBQQ__SubscriptionPricing__c = 'Fixed Price';
            ql1.SBQQ__ListPrice__c = 20;
            ql1.SBQQ__Quote__c = quote.Id;
            ql1.Notes__c = 'abc';
            ql1.Overage_Fee__c = 2;
            ql1.SBQQ__Group__c = map_qlg.get(i).id;
            lst_ql.add(ql1);
        }
        insert lst_ql;
        for (Integer i = 0, j = 0; i < 5; i++) 
        {
            SBQQ__QuoteLine__c ql2 = new SBQQ__QuoteLine__c();
            ql2.SBQQ__Quantity__c = 2;
            ql2.SBQQ__PriorQuantity__c = 0;
            ql2.SBQQ__Product__c = product_2.Id;
            ql2.SBQQ__NetPrice__c = 10;
            ql2.Rack_Rate__c = 10;
            ql2.OnArrival_360_Event_Selection__c = newOnArrival360.id;
            ql2.SBQQ__SubscriptionPricing__c = 'Fixed Price';
            ql2.SBQQ__ListPrice__c = 20;
            ql2.Notes__c = 'abc';
            ql2.Overage_Fee__c = 2;
            //if(i>2)
            //{
                ql2.SBQQ__RegularPrice__c = 0.00;
            //}
            ql2.SBQQ__Quote__c = quote.Id;
            ql2.SBQQ__Group__c = map_qlg.get(i).id;
            ql2.SBQQ__RequiredBy__c = lst_ql[i].id;
            lst_ql.add(ql2);
        }
        upsert lst_ql;

        QuoteLinesFilteredController controller = new QuoteLinesFilteredController();
        controller.objId = quote.Id;
        
        List<QuoteLinesFilteredController.DisplayWrapper> qlList = controller.getQuoteLineList();
        System.assertNotEquals(null, qlList.size());
        System.assertNotEquals(0, qlList.size());
    }

}