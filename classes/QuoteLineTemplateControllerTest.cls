@isTest
private class QuoteLineTemplateControllerTest {
    
    @isTest static void test_EC() {
        PageReference pageRef = Page.QuoteLineTemplateContent;
                Test.setCurrentPage(pageRef);


                Account account = new Account();
                account.Name = 'Account 1';
                account.BillingCountry='MX';
                account.BillingCountryCode = 'MX';
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
                quote.Contract_Term_Years__c = '5';
                quote.Count_of_HC_Products__c = 0;
                quote.Count_of_EC_Products__c = 1;
                quote.SBQQ__Account__c = account.Id;
                quote.Current_Year__c = 1;
                quote.SBQQ__Opportunity2__c = opp.id;
                quote.jsonString__c = '{"settings":{"preCalculationFieldNames":["SBQQ__Quantity__c","SBQQ__Discount__c","SBQQ__DistributorDiscount__c","Custom_Discount__c","Discount_Type__c","Rate__c","Zone_Level__c","Number_of_Guest_Rooms__c","Lanyon_Chain_Affiliation__c","Chain_Affiliation__c","Group_Business_Mix__c","Setup_Days__c","Travel_Days__c","Event_Start_Date__c","Event_End_Date__c","Attendees__c","OnArrival_360_Event_Selection__c","Complexity__c","SBQQ__StartDate__c","SBQQ__EndDate__c","Search_Screen_Region__c","CSN_Tier__c"],"calculatedFieldNames":["SBQQ__OriginalPrice__c","SBQQ__ListPrice__c","SBQQ__RegularPrice__c","SBQQ__CustomerPrice__c","SBQQ__PartnerPrice__c","SBQQ__NetPrice__c","Rack_Rate__c","SBQQ__ProrateMultiplier__c"],"msAtLastUpdate":1528734627259},"previousQuoteType":null,"outyearMap":{"2":{"startDate":"2018-08-01","endDate":"2019-07-31"},"3":{"startDate":"2019-08-01","endDate":"2020-07-31"}},"insertionId":"94257_FQP_87354","currentYearSynced":null,"automationStage":{"outyearProcessingStage":"OUTYEAR_PROCESSING_COMPLETE","codeStatus":"CALCULATION_CYCLE_FINISHED"}}';
                insert quote;

                Product2 product1 = new Product2();
                product1.Name = 'Product 1';
                product1.Contract_Output_Grouping__c = 'Event Cloud';
                product1.ProductCode = 'CV-SW-EC-EVT';
                insert product1;

                SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c();
                ql1.SBQQ__Quantity__c = 1;
                ql1.SBQQ__Product__c = product1.Id;
                ql1.SBQQ__ListPrice__c = 10;
                ql1.SBQQ__NetPrice__c = 10;
                ql1.Rack_Rate__c = 10;
                ql1.SBQQ__SubscriptionPricing__c = 'Fixed Price';
                ql1.SBQQ__Quote__c = quote.Id;
                ql1.Notes__c = 'abc';
                insert ql1;

                QuoteLineTemplateContentController controller = new QuoteLineTemplateContentController(quote.Id);
                controller.MapreturnDates();
                //System.assertNotEquals(controller.eventTable.QLTables.size(), 0);
    }
    
    @isTest static void test_EC_MYD() {
                Account account = new Account();
                account.Name = 'Account 1';
                account.BillingCountry='MX';
                account.BillingCountryCode = 'MX';
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

                PageReference pageRef = Page.QuoteLineTemplateContent;
                Test.setCurrentPage(pageRef);
                ApexPages.currentPage().getParameters().put('qid',quote.Id);
                QuoteLineTemplateContentController controller = new QuoteLineTemplateContentController();
                controller.MapreturnDates();
                //System.assertNotEquals(controller.eventTable.QLTables.size(), 0);
    }

    @isTest static void test_EC_MYD2() {
        PageReference pageRef = Page.QuoteLineTemplateContent;
                Test.setCurrentPage(pageRef);


                Account account = new Account();
                account.Name = 'Account 1';
                account.BillingCountry='MX';
                account.BillingCountryCode = 'MX';
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
                quote.Multiple_Years_Commitment__c = TRUE;
                quote.SBQQ__Opportunity2__c = opp.id;
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

                //wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Year_4_Effective_Quantity__c, rackRate, rackRate * ql.Year_4_Effective_Quantity__c, ql.Year_4_Effective_Amount__c / ql.Year_4_Effective_Quantity__c, ql.Year_4_Net_Amount__c, rackRate * ql.Year_4_Quantity__c - ql.Year_4_Net_Amount__c);
                //System.debug('QuoteLineTemplateControllerTest:' + ql1.SBQQ__ProductName__c + ':' + ql1.Year_4_Effective_Quantity__c + ':' + ql1.Year_4_Effective_Amount__c + ':' + ql1.Year_4_Net_Amount__c + ':' + ql1.Year_4_Quantity__c);

                QuoteLineTemplateContentController controller = new QuoteLineTemplateContentController(quote.Id);
                controller.MapreturnDates();
                //System.assertNotEquals(controller.eventTable.QLTables.size(), 0);
    }

    @isTest static void test_EC_NONMYD() {
        PageReference pageRef = Page.QuoteLineTemplateContent;
                Test.setCurrentPage(pageRef);


                Account account = new Account();
                account.Name = 'Account 1';
                account.BillingCountry='MX';
                account.BillingCountryCode = 'MX';
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
                quote.Count_of_EC_Products__c = 5;
                quote.SBQQ__Account__c = account.Id;
                quote.Current_Year__c = 1;
                quote.SBQQ__Opportunity2__c = opp.id;
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

                QuoteLineTemplateContentController controller = new QuoteLineTemplateContentController(quote.Id);
                controller.MapreturnDates();
                //System.assertNotEquals(controller.eventTable.QLTables.size(), 0);
    }


    @isTest static void test_HC_MYD() {
        PageReference pageRef = Page.QuoteLineTemplateContent;
                Test.setCurrentPage(pageRef);


                Account account = new Account();
                account.Name = 'Account 1';
                account.BillingCountry='MX';
                account.BillingCountryCode = 'MX';
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
                quote.Count_of_HC_Products__c = 5;
                quote.Count_of_EC_Products__c = 0;
                quote.SBQQ__Account__c = account.Id;
                quote.Current_Year__c = 2;
                quote.Multiple_Years_Commitment__c = TRUE;
                quote.SBQQ__Opportunity2__c = opp.id;
                insert quote;

                List<Product2> products = new List<Product2>();
                Product2 product1 = new Product2();
                product1.Name = 'Product 1';
                product1.Contract_Output_Grouping__c = 'Bundle Advertisements';
                product1.ProductCode = 'CV-SW-EC-EVT';
                products.add(product1);
                Product2 product2 = new Product2();
                product2.Name = 'Product 2';
                product2.Contract_Output_Grouping__c = 'Suggested Advertisements';
                product2.ProductCode = 'CV-SW-EC-EVT';
                products.add(product2);
                Product2 product3 = new Product2();
                product3.Name = 'Product 3';
                product3.Contract_Output_Grouping__c = 'Video Retargeting';
                product3.ProductCode = 'CV-SW-EC-EVT';
                products.add(product3);
                Product2 product4 = new Product2();
                product4.Name = 'Product 4';
                product4.Contract_Output_Grouping__c = 'Elite Meetings Alliance';
                product4.ProductCode = 'CV-SW-EC-EVT';
                products.add(product4);
                Product2 product5 = new Product2();
                product5.Name = 'Product 5';
                product5.Contract_Output_Grouping__c = 'Reporting & Analytics';
                product5.ProductCode = 'CV-SW-EC-EVT';
                products.add(product5);
                Product2 product6 = new Product2();
                product6.Name = 'Product 6';
                product6.Contract_Output_Grouping__c = 'Cvent Passkey, Transient & Lanyon Group';
                product6.ProductCode = 'CV-SW-EC-EVT';
                products.add(product6);
                Product2 product7 = new Product2();
                product7.Name = 'Product 7';
                product7.Contract_Output_Grouping__c = 'Listing Advertisement(s), Software, Services & CONNECT';
                product7.ProductCode = 'CV-SW-EC-EVT';
                products.add(product7);
                Product2 product8 = new Product2();
                product8.Name = 'Product 8';
                product8.Contract_Output_Grouping__c = 'Merchant';
                product8.ProductCode = 'CV-SW-EC-EVT';
                products.add(product8);
                
                insert products;
                SBQQ__QuoteLineGroup__c qlg = new SBQQ__QuoteLineGroup__c();
                qlg.Name = 'Year 1';
                qlg.SBQQ__Number__c = 1;
                qlg.SBQQ__ListTotal__c = 0.00;
                qlg.SBQQ__CustomerTotal__c = 0.00;
                qlg.SBQQ__NetTotal__c = 0.00;
                qlg.CurrencyIsoCode = 'USD';
                qlg.SBQQ__Quote__c = quote.id;
                qlg.term__c =1; 
                insert qlg;

                List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
                SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c();
                SBQQ__QuoteLine__c ql2 = new SBQQ__QuoteLine__c();
                SBQQ__QuoteLine__c ql3 = new SBQQ__QuoteLine__c();
                SBQQ__QuoteLine__c ql4 = new SBQQ__QuoteLine__c();
                SBQQ__QuoteLine__c ql5 = new SBQQ__QuoteLine__c();
                SBQQ__QuoteLine__c ql6 = new SBQQ__QuoteLine__c();
                SBQQ__QuoteLine__c ql7 = new SBQQ__QuoteLine__c();
                SBQQ__QuoteLine__c ql8 = new SBQQ__QuoteLine__c();
                ql1.SBQQ__Quantity__c = 1;
                ql1.SBQQ__Product__c = product1.Id;
                ql1.SBQQ__ListPrice__c = 10;
                ql1.SBQQ__NetPrice__c = 10;
                ql1.SBQQ__SubscriptionPricing__c = 'Fixed Price';
                ql1.Rack_Rate__c = 10;
                ql1.SBQQ__Group__c = qlg.Id;
                //ql1.Year_2_Quantity__c = 2;
                //ql1.Year_2_List_Price__c = 20;
                //ql1.Year_2_Net_Amount__c = 40;
                //ql1.Year_2_Effective_Amount__c = 40;
                //ql1.Year_3_Quantity__c = 2;
                //ql1.Year_3_List_Price__c = 20;
                //ql1.Year_3_Net_Amount__c = 40;
                //ql1.Year_3_Effective_Amount__c = 40;
                //ql1.Year_4_Quantity__c = 2;
                //ql1.Year_4_List_Price__c = 20;
                //ql1.Year_4_Net_Amount__c = 40;
                //ql1.Year_4_Effective_Amount__c = 40;
                //ql1.Year_5_Quantity__c = 2;
                //ql1.Year_5_List_Price__c = 20;
                //ql1.Year_5_Net_Amount__c = 40;
                //ql1.Year_5_Effective_Amount__c = 40;
                ql1.SBQQ__Quote__c = quote.Id;
                ql1.Notes__c = 'abc';
                quoteLines.add(ql1);
                ql2 = ql1.clone();
                ql2.SBQQ__Product__c = product2.Id;
                quoteLines.add(ql2);
                ql3 = ql1.clone();
                ql3.SBQQ__Product__c = product3.Id;
                quoteLines.add(ql3);
                ql4 = ql1.clone();
                ql4.SBQQ__Product__c = product4.Id;
                quoteLines.add(ql4);
                ql5 = ql1.clone();
                ql5.SBQQ__Product__c = product5.Id;
                quoteLines.add(ql5);
                ql6 = ql1.clone();
                ql6.SBQQ__Product__c = product6.Id;
                quoteLines.add(ql6);
                ql7 = ql1.clone();
                ql7.SBQQ__Product__c = product7.Id;
                quoteLines.add(ql7);
                ql8 = ql1.clone();
                ql8.SBQQ__Product__c = product8.Id;
                quoteLines.add(ql8);

                insert quoteLines;

                QuoteLineTemplateContentController controller = new QuoteLineTemplateContentController(quote.Id);
                controller.MapreturnDates();
                //System.assertNotEquals(controller.eventTable.QLTables.size(), 0);
    }

    @isTest static void test_HC_NONMYD() {
        PageReference pageRef = Page.QuoteLineTemplateContent;
                Test.setCurrentPage(pageRef);


                Account account = new Account();
                account.Name = 'Account 1';
                account.BillingCountry='MX';
                account.BillingCountryCode = 'MX';
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
                quote.Count_of_HC_Products__c = 5;
                quote.Count_of_EC_Products__c = 1;
                quote.SBQQ__Account__c = account.Id;
                quote.Current_Year__c = 1;
                quote.SBQQ__Opportunity2__c = opp.id;
                insert quote;

                List<Product2> products = new List<Product2>();
                Product2 product1 = new Product2();
                product1.Name = 'Product 1';
                product1.Contract_Output_Grouping__c = 'Bundle Advertisements';
                product1.ProductCode = 'CV-SW-EC-EVT';
                products.add(product1);
                Product2 product2 = new Product2();
                product2.Name = 'Product 2';
                product2.Contract_Output_Grouping__c = 'Suggested Advertisements';
                product2.ProductCode = 'CV-SW-EC-EVT';
                products.add(product2);
                Product2 product3 = new Product2();
                product3.Name = 'Product 3';
                product3.Contract_Output_Grouping__c = 'Video Retargeting';
                product3.ProductCode = 'CV-SW-EC-EVT';
                products.add(product3);
                Product2 product4 = new Product2();
                product4.Name = 'Product 4';
                product4.Contract_Output_Grouping__c = 'Elite Meetings Alliance';
                product4.ProductCode = 'CV-SW-EC-EVT';
                products.add(product4);
                Product2 product5 = new Product2();
                product5.Name = 'Product 5';
                product5.Contract_Output_Grouping__c = 'Reporting & Analytics';
                product5.ProductCode = 'CV-SW-EC-EVT';
                products.add(product5);
                Product2 product6 = new Product2();
                product6.Name = 'Product 6';
                product6.Contract_Output_Grouping__c = 'Cvent Passkey, Transient & Lanyon Group';
                product6.ProductCode = 'CV-SW-EC-EVT';
                products.add(product6);
                Product2 product7 = new Product2();
                product7.Name = 'Product 7';
                product7.Contract_Output_Grouping__c = 'Listing Advertisement(s), Software, Services & CONNECT';
                product7.ProductCode = 'CV-SW-EC-EVT';
                products.add(product7);
                Product2 product8 = new Product2();
                product8.Name = 'Product 8';
                product8.Contract_Output_Grouping__c = 'Merchant';
                product8.ProductCode = 'CV-SW-EC-EVT';
                products.add(product8);
                
                insert products;

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
                for (Integer i = 0, j = 0; i < 8; i++) 
                {
                        SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c();
                        ql1.SBQQ__Quantity__c = 1;
                        if(i==0)
                        {
                                ql1.SBQQ__Product__c = product1.Id;
                                ql1.SBQQ__Group__c = map_qlg.get(i).id;
                        }
                        else if(i==1)
                        {
                                ql1.SBQQ__Product__c = product2.Id;
                                ql1.SBQQ__Group__c = map_qlg.get(i).id;
                        }
                        else if(i==2)
                        {
                                ql1.SBQQ__Product__c = product3.Id;
                                ql1.SBQQ__Group__c = map_qlg.get(i).id;
                        }
                        else if(i==3)
                        {
                                ql1.SBQQ__Product__c = product4.Id;
                                ql1.SBQQ__Group__c = map_qlg.get(i).id;
                        }
                        else if(i==4)
                        {
                                ql1.SBQQ__Product__c = product5.Id;
                                ql1.SBQQ__Group__c = map_qlg.get(i).id;
                        }
                        else if(i==5)
                        {
                                ql1.SBQQ__Product__c = product6.Id;
                                ql1.SBQQ__Group__c = map_qlg.get(0).id;
                        }
                        else if(i==6)
                        {
                                ql1.SBQQ__Product__c = product7.Id;
                                ql1.SBQQ__Group__c = map_qlg.get(1).id;
                        }
                        else if(i==7)
                        {
                                ql1.SBQQ__Product__c = product8.Id;
                                ql1.SBQQ__Group__c = map_qlg.get(2).id;
                        }
                        ql1.SBQQ__ListPrice__c = 10;
                        ql1.SBQQ__NetPrice__c = 10;
                        ql1.Rack_Rate__c = 10;
                        ql1.SBQQ__SubscriptionPricing__c = 'Fixed Price';
                        ql1.SBQQ__Quote__c = quote.Id;
                        ql1.Notes__c = 'abc';
                        lst_ql.add(ql1);
                }
                insert lst_ql;
                

                QuoteLineTemplateContentController controller = new QuoteLineTemplateContentController(quote.Id);
                controller.MapreturnDates();
                //System.assertNotEquals(controller.eventTable.QLTables.size(), 0);
    }

    @isTest static void test_HC_MYD2() {
        PageReference pageRef = Page.QuoteLineTemplateContent;
                Test.setCurrentPage(pageRef);


                Account account = new Account();
                account.Name = 'Account 1';
                account.BillingCountry='MX';
                account.BillingCountryCode = 'MX';
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
                quote.Count_of_HC_Products__c = 2;
                quote.Count_of_EC_Products__c = 0;
                quote.SBQQ__Account__c = account.Id;
                quote.Current_Year__c = 1;
                quote.Multiple_Years_Commitment__c = false;
                quote.SBQQ__Opportunity2__c = opp.id;
                insert quote;

                List<Product2> products = new List<Product2>();
                Product2 product1 = new Product2();
                product1.Name = 'Product 1';
                product1.Contract_Output_Grouping__c = 'Bundle Advertisements';
                product1.ProductCode = 'CV-SW-EC-EVT';
                products.add(product1);
                Product2 product2 = new Product2();
                product2.Name = 'Product 2';
                product2.Contract_Output_Grouping__c = 'Suggested Advertisements';
                product2.ProductCode = 'CV-SW-EC-EVT';
                products.add(product2);
                Product2 product3 = new Product2();
                product3.Name = 'Product 3';
                product3.Contract_Output_Grouping__c = 'Video Retargeting';
                product3.ProductCode = 'CV-SW-EC-EVT';
                products.add(product3);
                Product2 product4 = new Product2();
                product4.Name = 'Product 4';
                product4.Contract_Output_Grouping__c = 'Elite Meetings Alliance';
                product4.ProductCode = 'CV-SW-EC-EVT';
                products.add(product4);
                Product2 product5 = new Product2();
                product5.Name = 'Product 5';
                product5.Contract_Output_Grouping__c = 'Reporting & Analytics';
                product5.ProductCode = 'CV-SW-EC-EVT';
                products.add(product5);
                Product2 product6 = new Product2();
                product6.Name = 'Product 6';
                product6.Contract_Output_Grouping__c = 'Cvent Passkey, Transient & Lanyon Group';
                product6.ProductCode = 'CV-SW-EC-EVT';
                products.add(product6);
                Product2 product7 = new Product2();
                product7.Name = 'Product 7';
                product7.Contract_Output_Grouping__c = 'Listing Advertisement(s), Software, Services & CONNECT';
                product7.ProductCode = 'CV-SW-EC-EVT';
                products.add(product7);
                Product2 product8 = new Product2();
                product8.Name = 'Product 8';
                product8.Contract_Output_Grouping__c = 'Merchant';
                product8.ProductCode = 'CV-SW-EC-EVT';
                products.add(product8);
                
                insert products;
                //adding Groups
                List<SBQQ__QuoteLine__c> lst_ql= new List<SBQQ__QuoteLine__c>();
                Map<Integer, SBQQ__QuoteLineGroup__c> map_qlg = new Map<Integer, SBQQ__QuoteLineGroup__c>();
                for (Integer i = 0, j = 0; i < 5; i++) 
                {
                    SBQQ__QuoteLineGroup__c qlg = new SBQQ__QuoteLineGroup__c();
                    qlg.Name = 'Year'+(i+1);
                    qlg.SBQQ__Number__c = (i+1);
                    qlg.SBQQ__ListTotal__c = 0.00;
                    qlg.SBQQ__CustomerTotal__c = 0.00;
                    qlg.SBQQ__NetTotal__c = 0.00;
                    qlg.CurrencyIsoCode = 'USD';
                    qlg.SBQQ__Quote__c = quote.id;
                    qlg.term__c =i+1; 
                    insert qlg;
                    map_qlg.put(i, qlg);
                }
                for (Integer i = 0, j = 0; i < 8; i++) 
                {
                        SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c();
                        ql1.SBQQ__Quantity__c = 1;
                        if(i==0)
                        {
                                ql1.SBQQ__Product__c = product1.Id;
                        }
                        else if(i==1)
                        {
                                ql1.SBQQ__Product__c = product2.Id;
                        }
                        else if(i==2)
                        {
                                ql1.SBQQ__Product__c = product3.Id;
                        }
                        else if(i==3)
                        {
                                ql1.SBQQ__Product__c = product4.Id;
                        }
                        else if(i==4)
                        {
                                ql1.SBQQ__Product__c = product5.Id;
                        }
                        else if(i==5)
                        {
                                ql1.SBQQ__Product__c = product6.Id;
                        }
                        else if(i==6)
                        {
                                ql1.SBQQ__Product__c = product7.Id;
                        }
                        else if(i==7)
                        {
                                ql1.SBQQ__Product__c = product8.Id;
                        }
                        ql1.SBQQ__ListPrice__c = 10;
                        ql1.SBQQ__NetPrice__c = 10;
                        ql1.Rack_Rate__c = 10;
                        ql1.SBQQ__SubscriptionPricing__c = 'Fixed Price';
                        ql1.SBQQ__Quote__c = quote.Id;
                        ql1.Notes__c = 'abc';
                        ql1.Overage_Fee__c = i+1;
                        ql1.SBQQ__Group__c = map_qlg.get(0).id;
                        lst_ql.add(ql1);
                }
                insert lst_ql;

                QuoteLineTemplateContentController controller = new QuoteLineTemplateContentController(quote.Id);
                controller.MapreturnDates();
                //System.assertNotEquals(controller.eventTable.QLTables.size(), 0);
    }

    @isTest static void test_OA360() {
        CventMyd_ValidationHandler.settings.groupingValidationSettings.validateOnDocument = false;
        PageReference pageRef = Page.QuoteLineTemplateContent;
                Test.setCurrentPage(pageRef);


                Account account = new Account();
                account.Name = 'Account 1';
                account.BillingCountry='MX';
                account.BillingCountryCode = 'MX';
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
                quote.Multiple_Years_Commitment__c = TRUE;
                quote.SBQQ__Opportunity2__c = opp.id;
                insert quote;

                OnArrival_360_Events__c event = new OnArrival_360_Events__c();
                event.Name = 'abc';
                event.Address_of_Event__c = 'abc';
                event.Dates__c = 'abc';
                event.Venue_Name__c = 'abc';
                insert event;

                List<Product2> products = new List<Product2>();
                Product2 product1 = new Product2();
                product1.Name = 'Product 1';
                product1.Contract_Output_Grouping__c = 'Bundle Advertisements';
                product1.ProductCode = 'CV-SW-EC-EVT';
                products.add(product1);
                Product2 product2 = new Product2();
                product2.Name = 'Product 2';
                product2.Contract_Output_Grouping__c = 'Suggested Advertisements';
                product2.ProductCode = 'CV-SW-EC-EVT';
                products.add(product2);
                Product2 product3 = new Product2();
                product3.Name = 'Product 3';
                product3.Contract_Output_Grouping__c = 'Video Retargeting';
                product3.ProductCode = 'CV-SW-EC-EVT';
                products.add(product3);
                Product2 product4 = new Product2();
                product4.Name = 'Product 4';
                product4.Contract_Output_Grouping__c = 'OA360 Equipment';
                product4.ProductCode = 'CV-SW-EC-EVT';
                products.add(product4);
                Product2 product5 = new Product2();
                product5.Name = 'Product 5';
                product5.Contract_Output_Grouping__c = 'OA360 Support';
                product5.ProductCode = 'CV-SW-EC-EVT';
                products.add(product5);
                Product2 product6 = new Product2();
                product6.Name = 'Product 6';
                product6.Contract_Output_Grouping__c = 'Event Cloud';
                product6.ProductCode = 'CV-SW-EC-EVT';
                products.add(product6);
                Product2 product7 = new Product2();
                product7.Name = 'Product 7';
                product7.Contract_Output_Grouping__c = 'Professional';
                product7.ProductCode = 'CV-SW-EC-EVT';
                products.add(product7);
                Product2 product8 = new Product2();
                product8.Name = 'Product 8';
                product8.Contract_Output_Grouping__c = 'OnDemand';
                product8.ProductCode = 'CV-SW-EC-EVT';
                products.add(product8);
                
                insert products;

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
                        ql1.OnArrival_360_Event_Selection__c = event.Id;
                        ql1.Notes__c = 'abc';
                        ql1.SBQQ__Group__c = map_qlg.get(i).id;
                        lst_ql.add(ql1);
                }
                for (Integer i = 0, j = 0; i < 5; i++) 
                {
                        SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c();
                        ql1.SBQQ__Quantity__c = 1;
                        ql1.SBQQ__Product__c = product2.Id;  
                        ql1.SBQQ__ListPrice__c = 10;
                        ql1.SBQQ__NetPrice__c = 10;
                        ql1.Rack_Rate__c = 10;
                        ql1.SBQQ__SubscriptionPricing__c = 'Fixed Price';
                        ql1.SBQQ__Quote__c = quote.Id;
                        ql1.OnArrival_360_Event_Selection__c = event.Id;
                        ql1.Notes__c = 'abc';
                        ql1.SBQQ__Group__c = map_qlg.get(i).id;
                        lst_ql.add(ql1);
                }
                for (Integer i = 0, j = 0; i < 5; i++) 
                {
                        SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c();
                        ql1.SBQQ__Quantity__c = 1;
                        ql1.SBQQ__Product__c = product3.Id;  
                        ql1.SBQQ__ListPrice__c = 10;
                        ql1.SBQQ__NetPrice__c = 10;
                        ql1.Rack_Rate__c = 10;
                        ql1.SBQQ__SubscriptionPricing__c = 'Fixed Price';
                        ql1.SBQQ__Quote__c = quote.Id;
                        ql1.OnArrival_360_Event_Selection__c = event.Id;
                        ql1.Notes__c = 'abc';
                        ql1.SBQQ__Group__c = map_qlg.get(i).id;
                        lst_ql.add(ql1);
                }
                for (Integer i = 0, j = 0; i < 5; i++) 
                {
                        SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c();
                        ql1.SBQQ__Quantity__c = 1;
                        ql1.SBQQ__Product__c = product4.Id;  
                        ql1.SBQQ__ListPrice__c = 10;
                        ql1.SBQQ__NetPrice__c = 10;
                        ql1.Rack_Rate__c = 10;
                        ql1.SBQQ__SubscriptionPricing__c = 'Fixed Price';
                        ql1.SBQQ__Quote__c = quote.Id;
                        ql1.OnArrival_360_Event_Selection__c = event.Id;
                        ql1.Notes__c = 'abc';
                        ql1.SBQQ__Group__c = map_qlg.get(i).id;
                        lst_ql.add(ql1);
                }
                for (Integer i = 0, j = 0; i < 5; i++) 
                {
                        SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c();
                        ql1.SBQQ__Quantity__c = 1;
                        ql1.SBQQ__Product__c = product5.Id;  
                        ql1.SBQQ__ListPrice__c = 10;
                        ql1.SBQQ__NetPrice__c = 10;
                        ql1.Rack_Rate__c = 10;
                        ql1.SBQQ__SubscriptionPricing__c = 'Fixed Price';
                        ql1.SBQQ__Quote__c = quote.Id;
                        ql1.OnArrival_360_Event_Selection__c = event.Id;
                        ql1.Notes__c = 'abc';
                        ql1.SBQQ__Group__c = map_qlg.get(i).id;
                        lst_ql.add(ql1);
                }
                for (Integer i = 0, j = 0; i < 5; i++) 
                {
                        SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c();
                        ql1.SBQQ__Quantity__c = 1;
                        ql1.SBQQ__Product__c = product6.Id;  
                        ql1.SBQQ__ListPrice__c = 10;
                        ql1.SBQQ__NetPrice__c = 10;
                        ql1.Rack_Rate__c = 10;
                        ql1.SBQQ__SubscriptionPricing__c = 'Fixed Price';
                        ql1.SBQQ__Quote__c = quote.Id;
                        ql1.OnArrival_360_Event_Selection__c = event.Id;
                        ql1.Notes__c = 'abc';
                        ql1.SBQQ__Group__c = map_qlg.get(i).id;
                        lst_ql.add(ql1);
                }
                for (Integer i = 0, j = 0; i < 5; i++) 
                {
                        SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c();
                        ql1.SBQQ__Quantity__c = 1;
                        ql1.SBQQ__Product__c = product7.Id;  
                        ql1.SBQQ__ListPrice__c = 10;
                        ql1.SBQQ__NetPrice__c = 10;
                        ql1.Rack_Rate__c = 10;
                        ql1.SBQQ__SubscriptionPricing__c = 'Fixed Price';
                        ql1.SBQQ__Quote__c = quote.Id;
                        ql1.OnArrival_360_Event_Selection__c = event.Id;
                        ql1.Notes__c = 'abc';
                        ql1.SBQQ__Group__c = map_qlg.get(i).id;
                        lst_ql.add(ql1);
                }
                for (Integer i = 0, j = 0; i < 5; i++) 
                {
                        SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c();
                        ql1.SBQQ__Quantity__c = 1;
                        ql1.SBQQ__Product__c = product8.Id;  
                        ql1.SBQQ__ListPrice__c = 10;
                        ql1.SBQQ__NetPrice__c = 10;
                        ql1.Rack_Rate__c = 10;
                        ql1.SBQQ__SubscriptionPricing__c = 'Fixed Price';
                        ql1.SBQQ__Quote__c = quote.Id;
                        ql1.OnArrival_360_Event_Selection__c = event.Id;
                        ql1.Notes__c = 'abc';
                        ql1.SBQQ__Group__c = map_qlg.get(i).id;
                        lst_ql.add(ql1);
                }
                insert lst_ql;

                QuoteLineTemplateContentController controller = new QuoteLineTemplateContentController(quote.Id);
                controller.MapreturnDates();
                controller.OA360GROUP(lst_ql[1], 1,TRUE, quote);
                controller.OA360GROUP(lst_ql[1], 2,TRUE, quote);
                //System.assertNotEquals(controller.eventTable.QLTables.size(), 0);

    }

    @isTest static void testCrowdCompass() {
        PageReference pageRef = Page.QuoteLineTemplateContent;
        Test.setCurrentPage(pageRef);

        Account account = new Account();
        account.Name = 'Account 1';
        account.BillingCountry='MX';
        account.BillingCountryCode = 'MX';
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
        quote.Multiple_Years_Commitment__c = TRUE;
        quote.SBQQ__Opportunity2__c = opp.id;
        insert quote;

        List<Product2> products = new List<Product2>();
        Product2 product1 = new Product2();
        product1.Name = 'Product 1';
        product1.Contract_Output_Grouping__c = 'Event Cloud';
        product1.ProductCode = 'CV-SW-EC-EVT-CCMOBAPP';
        products.add(product1);
        Product2 product2 = new Product2();
        product2.Name = 'Product 2';
        product2.Contract_Output_Grouping__c = 'Event Cloud';
        product2.ProductCode = 'CV-SW-EC-CC-CCMBAPxxx';
        products.add(product2);
        insert products;
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
        
        SBQQ__QuoteLine__c ql2 = lst_ql[0].clone();
        ql2.SBQQ__Product__c = product2.Id;
        ql2.SBQQ__RequiredBy__c = lst_ql[0].Id;
        //quoteLines.add(ql2);
        insert ql2;
        //insert quoteLines;

        QuoteLineTemplateContentController controller = new QuoteLineTemplateContentController(quote.Id);
        controller.MapreturnDates();
        //System.assertNotEquals(controller.eventTable.QLTables.size(), 0);
    }

    @isTest static void testOverage() {
        PageReference pageRef = Page.QuoteLineTemplateContent;
        Test.setCurrentPage(pageRef);

        Account account = new Account();
        account.Name = 'Account 1';
        account.BillingCountry='MX';
        account.BillingCountryCode = 'MX';
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
        quote.Multiple_Years_Commitment__c = TRUE;
        quote.SBQQ__Opportunity2__c = opp.id;
        insert quote;

        List<Product2> products = new List<Product2>();
        Product2 product1 = new Product2();
        product1.Name = 'On Arrival Prem';
        product1.Contract_Output_Grouping__c = 'Event Cloud';
        product1.ProductCode = 'CV-SW-EC-EVT-OAPREM';
        products.add(product1);
        Product2 product2 = new Product2();
        product2.Name = 'Product 2';
        product2.Contract_Output_Grouping__c = 'Event Cloud';
        product2.ProductCode = 'CV-SW-EC-EVT-OAPREM50';
        products.add(product2);
        insert products;
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
                ql1.Rollup_Quantity__c = 1;
                ql1.Notes__c = 'abc';
                ql1.Overage_Fee__c = i+1;
                ql1.SBQQ__Group__c = map_qlg.get(i).id;
                lst_ql.add(ql1);
        }
        insert lst_ql;
        
        SBQQ__QuoteLine__c ql2 = lst_ql[0].clone();
        ql2.SBQQ__Product__c = product2.Id;
        ql2.SBQQ__RequiredBy__c = lst_ql[0].Id;
        //quoteLines.add(ql2);
        insert ql2;
        QuoteLineTemplateContentController controller = new QuoteLineTemplateContentController(quote.Id);
        
        QuoteLineInfoController  controller1 = new QuoteLineInfoController();
        controller1.objId = quote.Id;
        controller1.getquoteLines1();
    }   


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

    
}