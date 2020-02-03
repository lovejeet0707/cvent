/**
 * Created by stevelohrenz on 8/29/17.
 */

@IsTest
private class ProposalMasterControllerTest {
    @isTest static void testBundleAdvertisementsOneYear() {
        PageReference pageRef = Page.QuoteLineTemplateContent;
        Test.setCurrentPage(pageRef);
        
        Account instofAcc = TestUtil.createAccount('Test Account','Biz_Ac');
        insert instofAcc;

        Contact instOfCon = TestUtil.createContact(String.valueOf(instofAcc.Id));
        insert instOfCon;

        Opportunity opportunity = TestUtil.createOpportunityNew('Test Opportunity','Budget',instOfCon.Id,instofAcc.Id);
        opportunity.CloseDate = Date.today();
        insert opportunity;

        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__StartDate__c = System.today();
        quote.SBQQ__EndDate__c = System.today() + 365;
        quote.Contract_Term_Years__c = '5';
        quote.Count_of_HC_Products__c = 0;
        quote.Count_of_EC_Products__c = 1;
        quote.SBQQ__Account__c = instofAcc.Id;
        quote.Current_Year__c = 1;
        //quote.Multiple_Years_Commitment__c = TRUE;
        quote.SBQQ__Opportunity2__c = opportunity.Id;
        insert quote;

        Product2 product1 = new Product2();
        product1.Name = 'Product 1';
        product1.Contract_Output_Grouping__c = 'Bundle Advertisements';
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

        ApexPages.currentPage().getParameters().put('qid', quote.Id);
        ProposalMasterController controller = new ProposalMasterController();
        System.assertNotEquals(controller.eventTable.QLTables.size(), 0);
    }

    @isTest static void testBundleAdvertisementsFiveYears() {
        PageReference pageRef = Page.QuoteLineTemplateContent;
        Test.setCurrentPage(pageRef);

        Account instofAcc = TestUtil.createAccount('Test Account','Biz_Ac');
        insert instofAcc;

        Contact instOfCon = TestUtil.createContact(String.valueOf(instofAcc.Id));
        insert instOfCon;

        Opportunity opportunity = TestUtil.createOpportunityNew('Test Opportunity','Budget',instOfCon.Id,instofAcc.Id);
        opportunity.CloseDate = Date.today();
        insert opportunity;

        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__StartDate__c = System.today();
        quote.SBQQ__EndDate__c = System.today() + 365;
        quote.Effective_Year_1_Start_Date__c = quote.SBQQ__StartDate__c;
        quote.Effective_Year_1_End_Date__c = quote.SBQQ__EndDate__c;
        quote.Effective_Year_2_Start_Date__c = quote.Effective_Year_1_End_Date__c + 1;
        quote.Effective_Year_2_End_Date__c = quote.Effective_Year_2_Start_Date__c + 365;
        quote.Effective_Year_3_Start_Date__c = quote.Effective_Year_2_End_Date__c + 1;
        quote.Effective_Year_3_End_Date__c = quote.Effective_Year_3_Start_Date__c + 365;
        quote.Effective_Year_4_Start_Date__c = quote.Effective_Year_3_End_Date__c + 1;
        quote.Effective_Year_4_End_Date__c = quote.Effective_Year_4_Start_Date__c + 365;
        quote.Effective_Year_5_Start_Date__c = quote.Effective_Year_4_End_Date__c + 1;
        quote.Effective_Year_5_End_Date__c = quote.Effective_Year_5_Start_Date__c + 365;
        quote.Contract_Term_Years__c = '5';
        quote.Count_of_HC_Products__c = 0;
        quote.Count_of_EC_Products__c = 1;
        quote.SBQQ__Account__c = instofAcc.Id;
        quote.Current_Year__c = 1;
        quote.Multiple_Years_Commitment__c = TRUE;
        quote.SBQQ__Opportunity2__c = opportunity.Id;
        insert quote;

        Product2 product1 = new Product2();
        product1.Name = 'Product 1';
        product1.Contract_Output_Grouping__c = 'Bundle Advertisements';
        insert product1;

        SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c();
        ql1.SBQQ__Quantity__c = 1;
        ql1.SBQQ__Product__c = product1.Id;
        ql1.SBQQ__ListPrice__c = 10;
        ql1.SBQQ__NetPrice__c = 10;
        ql1.Rack_Rate__c = 10;
        ql1.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        ql1.Year_2_Quantity__c = 2;
        ql1.Year_2_List_Price__c = 20;
        ql1.Year_2_Net_Amount__c = 40;
        ql1.Year_2_Effective_Amount__c = 40;
        ql1.Year_3_Quantity__c = 2;
        ql1.Year_3_List_Price__c = 20;
        ql1.Year_3_Net_Amount__c = 40;
        ql1.Year_3_Effective_Amount__c = 40;
        ql1.Year_4_Quantity__c = 2;
        ql1.Year_4_List_Price__c = 20;
        ql1.Year_4_Net_Amount__c = 40;
        ql1.Year_4_Effective_Amount__c = 40;
        ql1.Year_5_Quantity__c = 2;
        ql1.Year_5_List_Price__c = 20;
        ql1.Year_5_Net_Amount__c = 40;
        ql1.Year_5_Effective_Amount__c = 40;
        ql1.SBQQ__Quote__c = quote.Id;
        ql1.Notes__c = 'abc';
        ql1.Overage_Fee__c = 2;
        insert ql1;

        ApexPages.currentPage().getParameters().put('qid', quote.Id);
        ProposalMasterController controller = new ProposalMasterController();
        System.assertNotEquals(controller.eventTable.QLTables.size(), 0);

    }

    @isTest static void testBundleAdvertisementsFiveYears2() {
        PageReference pageRef = Page.QuoteLineTemplateContent;
        Test.setCurrentPage(pageRef);


        Account instofAcc = TestUtil.createAccount('Test Account','Biz_Ac');
        insert instofAcc;

        Contact instOfCon = TestUtil.createContact(String.valueOf(instofAcc.Id));
        insert instOfCon;

        Opportunity opportunity = TestUtil.createOpportunityNew('Test Opportunity','Budget',instOfCon.Id,instofAcc.Id);
        opportunity.CloseDate = Date.today();
        insert opportunity;

        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__StartDate__c = System.today();
        quote.SBQQ__EndDate__c = System.today() + 365;
        quote.Effective_Year_1_Start_Date__c = quote.SBQQ__StartDate__c;
        quote.Effective_Year_1_End_Date__c = quote.SBQQ__EndDate__c;
        quote.Effective_Year_2_Start_Date__c = quote.Effective_Year_1_End_Date__c + 1;
        quote.Effective_Year_2_End_Date__c = quote.Effective_Year_2_Start_Date__c + 365;
        quote.Effective_Year_3_Start_Date__c = quote.Effective_Year_2_End_Date__c + 1;
        quote.Effective_Year_3_End_Date__c = quote.Effective_Year_3_Start_Date__c + 365;
        quote.Effective_Year_4_Start_Date__c = quote.Effective_Year_3_End_Date__c + 1;
        quote.Effective_Year_4_End_Date__c = quote.Effective_Year_4_Start_Date__c + 365;
        quote.Effective_Year_5_Start_Date__c = quote.Effective_Year_4_End_Date__c + 1;
        quote.Effective_Year_5_End_Date__c = quote.Effective_Year_5_Start_Date__c + 365;
        quote.Contract_Term_Years__c = '5';
        quote.Count_of_HC_Products__c = 0;
        quote.Count_of_EC_Products__c = 1;
        quote.SBQQ__Account__c = instofAcc.Id;
        quote.Current_Year__c = 1;
        quote.Multiple_Years_Commitment__c = TRUE;
        quote.SBQQ__Opportunity2__c = opportunity.Id;
        insert quote;

        Product2 product1 = new Product2();
        product1.Name = 'Product 1';
        product1.Contract_Output_Grouping__c = 'Bundle Advertisements';
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
        ql1.Year_2_Effective_Amount__c = 40;
        ql1.Year_3_Effective_Amount__c = 40;
        ql1.Year_4_Effective_Amount__c = 40;
        ql1.Year_5_Effective_Amount__c = 40;
        ql1.Year_2_Quantity__c = 2;
        ql1.Year_2_List_Price__c = 20;
        ql1.Year_2_Net_Amount__c = 40;
        ql1.Year_3_Quantity__c = 2;
        ql1.Year_3_List_Price__c = 20;
        ql1.Year_3_Net_Amount__c = 40;
        ql1.Year_4_Quantity__c = 2;
        ql1.Year_4_List_Price__c = 20;
        ql1.Year_4_Net_Amount__c = 40;
        ql1.Year_5_Quantity__c = 2;
        ql1.Year_5_List_Price__c = 20;
        ql1.Year_5_Net_Amount__c = 40;
        insert ql1;

        //wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Year_4_Effective_Quantity__c, rackRate, rackRate * ql.Year_4_Effective_Quantity__c, ql.Year_4_Effective_Amount__c / ql.Year_4_Effective_Quantity__c, ql.Year_4_Net_Amount__c, rackRate * ql.Year_4_Quantity__c - ql.Year_4_Net_Amount__c);
        System.debug('QuoteLineTemplateControllerTest:' + ql1.SBQQ__ProductName__c + ':' + ql1.Year_4_Effective_Quantity__c + ':' + ql1.Year_4_Effective_Amount__c + ':' + ql1.Year_4_Net_Amount__c + ':' + ql1.Year_4_Quantity__c);

        ApexPages.currentPage().getParameters().put('qid', quote.Id);
        ProposalMasterController controller = new ProposalMasterController();
        System.assertNotEquals(controller.eventTable.QLTables.size(), 0);
    }

    @isTest static void test_EC_NONMYD() {
        PageReference pageRef = Page.QuoteLineTemplateContent;
        Test.setCurrentPage(pageRef);


        Account instofAcc = TestUtil.createAccount('Test Account','Biz_Ac');
        insert instofAcc;

        Contact instOfCon = TestUtil.createContact(String.valueOf(instofAcc.Id));
        insert instOfCon;

        Opportunity opportunity = TestUtil.createOpportunityNew('Test Opportunity','Budget',instOfCon.Id,instofAcc.Id);
        opportunity.CloseDate = Date.today();
        insert opportunity;

        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__StartDate__c = System.today();
        quote.SBQQ__EndDate__c = System.today() + 365;
        quote.Effective_Year_1_Start_Date__c = quote.SBQQ__StartDate__c;
        quote.Effective_Year_1_End_Date__c = quote.SBQQ__EndDate__c;
        quote.Effective_Year_2_Start_Date__c = quote.Effective_Year_1_End_Date__c + 1;
        quote.Effective_Year_2_End_Date__c = quote.Effective_Year_2_Start_Date__c + 365;
        quote.Effective_Year_3_Start_Date__c = quote.Effective_Year_2_End_Date__c + 1;
        quote.Effective_Year_3_End_Date__c = quote.Effective_Year_3_Start_Date__c + 365;
        quote.Effective_Year_4_Start_Date__c = quote.Effective_Year_3_End_Date__c + 1;
        quote.Effective_Year_4_End_Date__c = quote.Effective_Year_4_Start_Date__c + 365;
        quote.Effective_Year_5_Start_Date__c = quote.Effective_Year_4_End_Date__c + 1;
        quote.Effective_Year_5_End_Date__c = quote.Effective_Year_5_Start_Date__c + 365;
        quote.Contract_Term_Years__c = '5';
        quote.Count_of_HC_Products__c = 0;
        quote.Count_of_EC_Products__c = 1;
        quote.SBQQ__Account__c = instofAcc.Id;
        quote.Current_Year__c = 1;
        quote.SBQQ__Opportunity2__c = opportunity.Id;
        quote.Multiple_Years_Commitment__c = TRUE;
        insert quote;

        Product2 product1 = new Product2();
        product1.Name = 'Product 1';
        product1.Contract_Output_Grouping__c = 'Bundle Advertisements';
        insert product1;

        SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c();
        ql1.SBQQ__Quantity__c = 1;
        ql1.SBQQ__Product__c = product1.Id;
        ql1.SBQQ__ListPrice__c = 10;
        ql1.SBQQ__NetPrice__c = 10;
        ql1.Rack_Rate__c = 10;
        ql1.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        //ql1.Year_2_Quantity__c = 2;
        //ql1.Year_2_List_Price__c = 20;
        //ql1.Year_2_Net_Amount__c = 40;
        //ql1.Year_3_Quantity__c = 2;
        //ql1.Year_3_List_Price__c = 20;
        //ql1.Year_3_Net_Amount__c = 40;
        //ql1.Year_4_Quantity__c = 2;
        //ql1.Year_4_List_Price__c = 20;
        //ql1.Year_4_Net_Amount__c = 40;
        //ql1.Year_5_Quantity__c = 2;
        //ql1.Year_5_List_Price__c = 20;
        //ql1.Year_5_Net_Amount__c = 40;
        ql1.SBQQ__Quote__c = quote.Id;
        ql1.Notes__c = 'abc';
        insert ql1;

        ApexPages.currentPage().getParameters().put('qid', quote.Id);
        ProposalMasterController controller = new ProposalMasterController();
        System.assertNotEquals(controller.eventTable.QLTables.size(), 0);
    }


    @isTest static void testAbunchFiveYears1() {
        PageReference pageRef = Page.QuoteLineTemplateContent;
        Test.setCurrentPage(pageRef);


        Account instofAcc = TestUtil.createAccount('Test Account','Biz_Ac');
        insert instofAcc;

        Contact instOfCon = TestUtil.createContact(String.valueOf(instofAcc.Id));
        insert instOfCon;

        Opportunity opportunity = TestUtil.createOpportunityNew('Test Opportunity','Budget',instOfCon.Id,instofAcc.Id);
        opportunity.CloseDate = Date.today();
        insert opportunity;

        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__StartDate__c = System.today();
        quote.SBQQ__EndDate__c = System.today() + 365;
        quote.Effective_Year_1_Start_Date__c = quote.SBQQ__StartDate__c;
        quote.Effective_Year_1_End_Date__c = quote.SBQQ__EndDate__c;
        quote.Effective_Year_2_Start_Date__c = quote.Effective_Year_1_End_Date__c + 1;
        quote.Effective_Year_2_End_Date__c = quote.Effective_Year_2_Start_Date__c + 365;
        quote.Effective_Year_3_Start_Date__c = quote.Effective_Year_2_End_Date__c + 1;
        quote.Effective_Year_3_End_Date__c = quote.Effective_Year_3_Start_Date__c + 365;
        quote.Effective_Year_4_Start_Date__c = quote.Effective_Year_3_End_Date__c + 1;
        quote.Effective_Year_4_End_Date__c = quote.Effective_Year_4_Start_Date__c + 365;
        quote.Effective_Year_5_Start_Date__c = quote.Effective_Year_4_End_Date__c + 1;
        quote.Effective_Year_5_End_Date__c = quote.Effective_Year_5_Start_Date__c + 365;
        quote.Contract_Term_Years__c = '5';
        quote.Count_of_HC_Products__c = 0;
        quote.Count_of_EC_Products__c = 1;
        quote.SBQQ__Account__c = instofAcc.Id;
        quote.Current_Year__c = 1;
        quote.Multiple_Years_Commitment__c = TRUE;
        quote.SBQQ__Opportunity2__c = opportunity.Id;
        insert quote;

        List<Product2> products = new List<Product2>();
        Product2 product1 = new Product2();
        product1.Name = 'Product 1';
        product1.Contract_Output_Grouping__c = 'Bundle Advertisements';
        products.add(product1);
        Product2 product2 = new Product2();
        product2.Name = 'Product 2';
        product2.Contract_Output_Grouping__c = 'Suggested Advertisements';
        products.add(product2);
        Product2 product3 = new Product2();
        product3.Name = 'Product 3';
        product3.Contract_Output_Grouping__c = 'Video Retargeting';
        products.add(product3);
        Product2 product4 = new Product2();
        product4.Name = 'Product 4';
        product4.Contract_Output_Grouping__c = 'Elite Meetings Alliance';
        products.add(product4);
        Product2 product5 = new Product2();
        product5.Name = 'Product 5';
        product5.Contract_Output_Grouping__c = 'Reporting & Analytics';
        products.add(product5);
        Product2 product6 = new Product2();
        product6.Name = 'Product 6';
        product6.Contract_Output_Grouping__c = 'Cvent Passkey, Transient & Lanyon Group';
        products.add(product6);
        Product2 product7 = new Product2();
        product7.Name = 'Product 7';
        product7.Contract_Output_Grouping__c = 'Listing Advertisement(s), Software, Services & CONNECT';
        products.add(product7);
        Product2 product8 = new Product2();
        product8.Name = 'Product 8';
        product8.Contract_Output_Grouping__c = 'Merchant';
        products.add(product8);

        insert products;

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
        ql1.Year_2_Quantity__c = 2;
        ql1.Year_2_List_Price__c = 20;
        ql1.Year_2_Net_Amount__c = 40;
        ql1.Year_2_Effective_Amount__c = 40;
        ql1.Year_3_Quantity__c = 2;
        ql1.Year_3_List_Price__c = 20;
        ql1.Year_3_Net_Amount__c = 40;
        ql1.Year_3_Effective_Amount__c = 40;
        ql1.Year_4_Quantity__c = 2;
        ql1.Year_4_List_Price__c = 20;
        ql1.Year_4_Net_Amount__c = 40;
        ql1.Year_4_Effective_Amount__c = 40;
        ql1.Year_5_Quantity__c = 2;
        ql1.Year_5_List_Price__c = 20;
        ql1.Year_5_Net_Amount__c = 40;
        ql1.Year_5_Effective_Amount__c = 40;
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

        ApexPages.currentPage().getParameters().put('qid', quote.Id);
        ProposalMasterController controller = new ProposalMasterController();
        System.assertNotEquals(controller.eventTable.QLTables.size(), 0);
    }

    @isTest static void testAbunchFiveYears2() {
        PageReference pageRef = Page.QuoteLineTemplateContent;
        Test.setCurrentPage(pageRef);


        Account instofAcc = TestUtil.createAccount('Test Account','Biz_Ac');
        insert instofAcc;

        Contact instOfCon = TestUtil.createContact(String.valueOf(instofAcc.Id));
        insert instOfCon;

        Opportunity opportunity = TestUtil.createOpportunityNew('Test Opportunity','Budget',instOfCon.Id,instofAcc.Id);
        opportunity.CloseDate = Date.today();
        insert opportunity;

        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__StartDate__c = System.today();
        quote.SBQQ__EndDate__c = System.today() + 365;
        quote.Effective_Year_1_Start_Date__c = quote.SBQQ__StartDate__c;
        quote.Effective_Year_1_End_Date__c = quote.SBQQ__EndDate__c;
        quote.Effective_Year_2_Start_Date__c = quote.Effective_Year_1_End_Date__c + 1;
        quote.Effective_Year_2_End_Date__c = quote.Effective_Year_2_Start_Date__c + 365;
        quote.Effective_Year_3_Start_Date__c = quote.Effective_Year_2_End_Date__c + 1;
        quote.Effective_Year_3_End_Date__c = quote.Effective_Year_3_Start_Date__c + 365;
        quote.Effective_Year_4_Start_Date__c = quote.Effective_Year_3_End_Date__c + 1;
        quote.Effective_Year_4_End_Date__c = quote.Effective_Year_4_Start_Date__c + 365;
        quote.Effective_Year_5_Start_Date__c = quote.Effective_Year_4_End_Date__c + 1;
        quote.Effective_Year_5_End_Date__c = quote.Effective_Year_5_Start_Date__c + 365;
        quote.Contract_Term_Years__c = '5';
        quote.Count_of_HC_Products__c = 0;
        quote.Count_of_EC_Products__c = 1;
        quote.SBQQ__Account__c = instofAcc.Id;
        quote.Current_Year__c = 1;
        quote.SBQQ__Opportunity2__c = opportunity.Id;
        quote.Multiple_Years_Commitment__c = TRUE;
        insert quote;

        List<Product2> products = new List<Product2>();
        Product2 product1 = new Product2();
        product1.Name = 'Product 1';
        product1.Contract_Output_Grouping__c = 'Bundle Advertisements';
        products.add(product1);
        Product2 product2 = new Product2();
        product2.Name = 'Product 2';
        product2.Contract_Output_Grouping__c = 'Suggested Advertisements';
        products.add(product2);
        Product2 product3 = new Product2();
        product3.Name = 'Product 3';
        product3.Contract_Output_Grouping__c = 'Video Retargeting';
        products.add(product3);
        Product2 product4 = new Product2();
        product4.Name = 'Product 4';
        product4.Contract_Output_Grouping__c = 'Elite Meetings Alliance';
        products.add(product4);
        Product2 product5 = new Product2();
        product5.Name = 'Product 5';
        product5.Contract_Output_Grouping__c = 'Reporting & Analytics';
        products.add(product5);
        Product2 product6 = new Product2();
        product6.Name = 'Product 6';
        product6.Contract_Output_Grouping__c = 'Cvent Passkey, Transient & Lanyon Group';
        products.add(product6);
        Product2 product7 = new Product2();
        product7.Name = 'Product 7';
        product7.Contract_Output_Grouping__c = 'Listing Advertisement(s), Software, Services & CONNECT';
        products.add(product7);
        Product2 product8 = new Product2();
        product8.Name = 'Product 8';
        product8.Contract_Output_Grouping__c = 'Merchant';
        products.add(product8);

        insert products;

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

        ApexPages.currentPage().getParameters().put('qid', quote.Id);
        ProposalMasterController controller = new ProposalMasterController();
        System.assertNotEquals(controller.eventTable.QLTables.size(), 0);
    }

    @isTest static void testBundleAdvertisementsFiveYears3() {
        PageReference pageRef = Page.QuoteLineTemplateContent;
        Test.setCurrentPage(pageRef);


        Account instofAcc = TestUtil.createAccount('Test Account','Biz_Ac');
        insert instofAcc;

        Contact instOfCon = TestUtil.createContact(String.valueOf(instofAcc.Id));
        insert instOfCon;

        Opportunity opportunity = TestUtil.createOpportunityNew('Test Opportunity','Budget',instOfCon.Id,instofAcc.Id);
        opportunity.CloseDate = Date.today();
        insert opportunity;

        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__StartDate__c = System.today();
        quote.SBQQ__EndDate__c = System.today() + 365;
        quote.Effective_Year_1_Start_Date__c = quote.SBQQ__StartDate__c;
        quote.Effective_Year_1_End_Date__c = quote.SBQQ__EndDate__c;
        quote.Effective_Year_2_Start_Date__c = quote.Effective_Year_1_End_Date__c + 1;
        quote.Effective_Year_2_End_Date__c = quote.Effective_Year_2_Start_Date__c + 365;
        quote.Effective_Year_3_Start_Date__c = quote.Effective_Year_2_End_Date__c + 1;
        quote.Effective_Year_3_End_Date__c = quote.Effective_Year_3_Start_Date__c + 365;
        quote.Effective_Year_4_Start_Date__c = quote.Effective_Year_3_End_Date__c + 1;
        quote.Effective_Year_4_End_Date__c = quote.Effective_Year_4_Start_Date__c + 365;
        quote.Effective_Year_5_Start_Date__c = quote.Effective_Year_4_End_Date__c + 1;
        quote.Effective_Year_5_End_Date__c = quote.Effective_Year_5_Start_Date__c + 365;
        quote.Contract_Term_Years__c = '5';
        quote.Count_of_HC_Products__c = 0;
        quote.Count_of_EC_Products__c = 1;
        quote.SBQQ__Account__c = instofAcc.Id;
        quote.Current_Year__c = 1;
        quote.Multiple_Years_Commitment__c = TRUE;
        quote.SBQQ__Opportunity2__c = opportunity.Id;
        insert quote;

        Product2 product1 = new Product2();
        product1.Name = 'Product 1';
        product1.Contract_Output_Grouping__c = 'Bundle Advertisements';
        insert product1;

        SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c();
        ql1.SBQQ__Quantity__c = 1;
        ql1.SBQQ__Product__c = product1.Id;
        ql1.SBQQ__ListPrice__c = 10;
        ql1.SBQQ__NetPrice__c = 10;
        ql1.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        ql1.Rack_Rate__c = 10;
        ql1.Year_2_Effective_Amount__c = 40;
        ql1.Year_3_Effective_Amount__c = 40;
        ql1.Year_4_Effective_Amount__c = 40;
        ql1.Year_5_Effective_Amount__c = 40;
        ql1.Year_2_Quantity__c = 2;
        ql1.Year_2_List_Price__c = 20;
        ql1.Year_2_Net_Amount__c = 40;
        ql1.Year_3_Quantity__c = 2;
        ql1.Year_3_List_Price__c = 20;
        ql1.Year_3_Net_Amount__c = 40;
        ql1.Year_4_Quantity__c = 2;
        ql1.Year_4_List_Price__c = 20;
        ql1.Year_4_Net_Amount__c = 40;
        ql1.Year_5_Quantity__c = 2;
        ql1.Year_5_List_Price__c = 20;
        ql1.Year_5_Net_Amount__c = 40;
        ql1.SBQQ__Quote__c = quote.Id;
        ql1.Notes__c = 'abc';
        insert ql1;

        ApexPages.currentPage().getParameters().put('qid', quote.Id);
        ProposalMasterController controller = new ProposalMasterController();
        System.assertNotEquals(controller.eventTable.QLTables.size(), 0);
    }

    @isTest static void test_OA360() {
        PageReference pageRef = Page.QuoteLineTemplateContent;
        Test.setCurrentPage(pageRef);


        Account instofAcc = TestUtil.createAccount('Test Account','Biz_Ac');
        insert instofAcc;

        Contact instOfCon = TestUtil.createContact(String.valueOf(instofAcc.Id));
        insert instOfCon;

        Opportunity opportunity = TestUtil.createOpportunityNew('Test Opportunity','Budget',instOfCon.Id,instofAcc.Id);
        opportunity.CloseDate = Date.today();
        insert opportunity;

        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__StartDate__c = System.today();
        quote.SBQQ__EndDate__c = System.today() + 365;
        quote.Effective_Year_1_Start_Date__c = quote.SBQQ__StartDate__c;
        quote.Effective_Year_1_End_Date__c = quote.SBQQ__EndDate__c;
        quote.Effective_Year_2_Start_Date__c = quote.Effective_Year_1_End_Date__c + 1;
        quote.Effective_Year_2_End_Date__c = quote.Effective_Year_2_Start_Date__c + 365;
        quote.Effective_Year_3_Start_Date__c = quote.Effective_Year_2_End_Date__c + 1;
        quote.Effective_Year_3_End_Date__c = quote.Effective_Year_3_Start_Date__c + 365;
        quote.Effective_Year_4_Start_Date__c = quote.Effective_Year_3_End_Date__c + 1;
        quote.Effective_Year_4_End_Date__c = quote.Effective_Year_4_Start_Date__c + 365;
        quote.Effective_Year_5_Start_Date__c = quote.Effective_Year_4_End_Date__c + 1;
        quote.Effective_Year_5_End_Date__c = quote.Effective_Year_5_Start_Date__c + 365;
        quote.Contract_Term_Years__c = '5';
        quote.Count_of_HC_Products__c = 0;
        quote.Count_of_EC_Products__c = 1;
        quote.SBQQ__Account__c = instofAcc.Id;
        quote.Current_Year__c = 1;
        quote.Multiple_Years_Commitment__c = TRUE;
        quote.SBQQ__Opportunity2__c = opportunity.Id;
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
        product1.Contract_Output_Grouping__c = 'OA360 Support';
        product1.ProductCode = 'CV-SW-EC-OSS-OA360(OSS)';
        products.add(product1);
        Product2 product2 = new Product2();
        product2.Name = 'Product 2';
        product2.Contract_Output_Grouping__c = 'OA360 Equipment';
        products.add(product2);
        Product2 product3 = new Product2();
        product3.Name = 'Product 3';
        product3.Contract_Output_Grouping__c = 'OA360 Supplies';
        products.add(product3);
        Product2 product4 = new Product2();
        product4.Name = 'Product 4';
        product4.Contract_Output_Grouping__c = 'OA 360 Software';
        product4.ProductCode = 'CV-SW-EC-OSS-OA360(OSS)';
        products.add(product4);
        Product2 product5 = new Product2();
        product5.Name = 'Product 5';
        product5.Contract_Output_Grouping__c = 'Software Platform';
        products.add(product5);
        Product2 product6 = new Product2();
        product6.Name = 'Product 6';
        product6.Contract_Output_Grouping__c = 'Cvent Passkey, Transient & Lanyon Group';
        products.add(product6);
        Product2 product7 = new Product2();
        product7.Name = 'Product 7';
        product7.Contract_Output_Grouping__c = 'Listing Advertisement(s), Software, Services & CONNECT';
        products.add(product7);
        Product2 product8 = new Product2();
        product8.Name = 'Product 8';
        product8.Contract_Output_Grouping__c = 'Merchant';
        products.add(product8);

        insert products;

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
        ql1.Year_2_Quantity__c = 2;
        ql1.Year_2_List_Price__c = 20;
        ql1.Year_2_Net_Amount__c = 40;
        ql1.Year_2_Effective_Amount__c = 40;
        ql1.Year_3_Quantity__c = 2;
        ql1.Year_3_List_Price__c = 20;
        ql1.Year_3_Net_Amount__c = 40;
        ql1.Year_3_Effective_Amount__c = 40;
        ql1.Year_4_Quantity__c = 2;
        ql1.Year_4_List_Price__c = 20;
        ql1.Year_4_Net_Amount__c = 40;
        ql1.Year_4_Effective_Amount__c = 40;
        ql1.Year_5_Quantity__c = 2;
        ql1.Year_5_List_Price__c = 20;
        ql1.Year_5_Net_Amount__c = 40;
        ql1.Year_5_Effective_Amount__c = 40;
        ql1.SBQQ__Quote__c = quote.Id;
        ql1.Notes__c = 'abc';
        ql1.OnArrival_360_Event_Selection__c = event.Id;
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

        ApexPages.currentPage().getParameters().put('qid', quote.Id);
        ProposalMasterController controller = new ProposalMasterController();
        System.assertNotEquals(controller.eventTable.QLTables.size(), 0);

    }

    @isTest static void testCrowdCompass() {
        PageReference pageRef = Page.QuoteLineTemplateContent;
        Test.setCurrentPage(pageRef);

        Account instofAcc = TestUtil.createAccount('Test Account','Biz_Ac');
        insert instofAcc;

        Contact instOfCon = TestUtil.createContact(String.valueOf(instofAcc.Id));
        insert instOfCon;

        Opportunity opportunity = TestUtil.createOpportunityNew('Test Opportunity','Budget',instOfCon.Id,instofAcc.Id);
        opportunity.CloseDate = Date.today();
        insert opportunity;

        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__StartDate__c = System.today();
        quote.SBQQ__EndDate__c = System.today() + 365;
        quote.Effective_Year_1_Start_Date__c = quote.SBQQ__StartDate__c;
        quote.Effective_Year_1_End_Date__c = quote.SBQQ__EndDate__c;
        quote.Effective_Year_2_Start_Date__c = quote.Effective_Year_1_End_Date__c + 1;
        quote.Effective_Year_2_End_Date__c = quote.Effective_Year_2_Start_Date__c + 365;
        quote.Effective_Year_3_Start_Date__c = quote.Effective_Year_2_End_Date__c + 1;
        quote.Effective_Year_3_End_Date__c = quote.Effective_Year_3_Start_Date__c + 365;
        quote.Effective_Year_4_Start_Date__c = quote.Effective_Year_3_End_Date__c + 1;
        quote.Effective_Year_4_End_Date__c = quote.Effective_Year_4_Start_Date__c + 365;
        quote.Effective_Year_5_Start_Date__c = quote.Effective_Year_4_End_Date__c + 1;
        quote.Effective_Year_5_End_Date__c = quote.Effective_Year_5_Start_Date__c + 365;
        quote.Contract_Term_Years__c = '5';
        quote.Count_of_HC_Products__c = 0;
        quote.Count_of_EC_Products__c = 1;
        quote.SBQQ__Account__c = instofAcc.Id;
        quote.Current_Year__c = 1;
        quote.SBQQ__Opportunity2__c = opportunity.Id;
        quote.Multiple_Years_Commitment__c = TRUE;
        insert quote;

        List<Product2> products = new List<Product2>();
        Product2 product1 = new Product2();
        product1.Name = 'Product 1';
        product1.Contract_Output_Grouping__c = 'Bundle Advertisements';
        product1.ProductCode = 'CV-SW-EC-EVT-CCMOBAPP';
        products.add(product1);
        Product2 product2 = new Product2();
        product2.Name = 'Product 2';
        product2.Contract_Output_Grouping__c = 'Bundle Advertisements';
        product2.ProductCode = 'CV-SW-EC-CC-CCMBAPxxx';
        products.add(product2);
        insert products;

        //List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c();
        ql1.SBQQ__Quote__c = quote.Id;
        ql1.SBQQ__Quantity__c = 1;
        ql1.SBQQ__Product__c = product1.Id;
        ql1.SBQQ__ListPrice__c = 10;
        ql1.SBQQ__NetPrice__c = 10;
        ql1.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        ql1.Rack_Rate__c = 10;
        ql1.Year_2_Quantity__c = 2;
        ql1.Year_2_List_Price__c = 20;
        ql1.Year_2_Net_Amount__c = 40;
        ql1.Year_2_Effective_Amount__c = 40;
        ql1.Year_3_Quantity__c = 2;
        ql1.Year_3_List_Price__c = 20;
        ql1.Year_3_Net_Amount__c = 40;
        ql1.Year_3_Effective_Amount__c = 40;
        ql1.Year_4_Quantity__c = 2;
        ql1.Year_4_List_Price__c = 20;
        ql1.Year_4_Net_Amount__c = 40;
        ql1.Year_4_Effective_Amount__c = 40;
        ql1.Year_5_Quantity__c = 2;
        ql1.Year_5_List_Price__c = 20;
        ql1.Year_5_Net_Amount__c = 40;
        ql1.Year_5_Effective_Amount__c = 40;
        //quoteLines.add(ql1);
        insert ql1;
        SBQQ__QuoteLine__c ql2 = ql1.clone();
        ql2.SBQQ__Product__c = product2.Id;
        ql2.SBQQ__RequiredBy__c = ql1.Id;
        //quoteLines.add(ql2);
        insert ql2;
        //insert quoteLines;

        ApexPages.currentPage().getParameters().put('qid', quote.Id);
        ProposalMasterController controller = new ProposalMasterController();
        System.assertNotEquals(controller.eventTable.QLTables.size(), 0);

    }

    @isTest static void testMatrixedProductsMultipleYears() {
        PageReference pageRef = Page.QuoteLineTemplateContent;
        Test.setCurrentPage(pageRef);


        Account instofAcc = TestUtil.createAccount('Test Account','Biz_Ac');
        insert instofAcc;

        Contact instOfCon = TestUtil.createContact(String.valueOf(instofAcc.Id));
        insert instOfCon;

        Opportunity opportunity = TestUtil.createOpportunityNew('Test Opportunity','Budget',instOfCon.Id,instofAcc.Id);
        opportunity.CloseDate = Date.today();
        insert opportunity;

        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__StartDate__c = System.today();
        quote.SBQQ__EndDate__c = System.today() + 365;
        quote.Effective_Year_1_Start_Date__c = quote.SBQQ__StartDate__c;
        quote.Effective_Year_1_End_Date__c = quote.SBQQ__EndDate__c;
        quote.Effective_Year_2_Start_Date__c = quote.Effective_Year_1_End_Date__c + 1;
        quote.Effective_Year_2_End_Date__c = quote.Effective_Year_2_Start_Date__c + 365;
        quote.Effective_Year_3_Start_Date__c = quote.Effective_Year_2_End_Date__c + 1;
        quote.Effective_Year_3_End_Date__c = quote.Effective_Year_3_Start_Date__c + 365;
        quote.Effective_Year_4_Start_Date__c = quote.Effective_Year_3_End_Date__c + 1;
        quote.Effective_Year_4_End_Date__c = quote.Effective_Year_4_Start_Date__c + 365;
        quote.Effective_Year_5_Start_Date__c = quote.Effective_Year_4_End_Date__c + 1;
        quote.Effective_Year_5_End_Date__c = quote.Effective_Year_5_Start_Date__c + 365;
        quote.Contract_Term_Years__c = '5';
        quote.Count_of_HC_Products__c = 0;
        quote.Count_of_EC_Products__c = 1;
        quote.SBQQ__Account__c = instofAcc.Id;
        quote.Current_Year__c = 1;
        quote.Multiple_Years_Commitment__c = TRUE;
        quote.SBQQ__Opportunity2__c = opportunity.Id;
        insert quote;

        Product2 product1 = new Product2();
        product1.Name = 'Product 1';
        product1.ProductCode = 'CV-SW-EC-EVT-EXPPREPAYREG';
        product1.Contract_Output_Grouping__c = 'Bundle Advertisements';
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
        ql1.Year_2_Effective_Amount__c = 40;
        ql1.Year_3_Effective_Amount__c = 40;
        ql1.Year_4_Effective_Amount__c = 40;
        ql1.Year_5_Effective_Amount__c = 40;
        ql1.Year_2_Quantity__c = 2;
        ql1.Year_2_List_Price__c = 20;
        ql1.Year_2_Net_Amount__c = 40;
        ql1.Year_3_Quantity__c = 2;
        ql1.Year_3_List_Price__c = 20;
        ql1.Year_3_Net_Amount__c = 40;
        ql1.Year_4_Quantity__c = 2;
        ql1.Year_4_List_Price__c = 20;
        ql1.Year_4_Net_Amount__c = 40;
        ql1.Year_5_Quantity__c = 2;
        ql1.Year_5_List_Price__c = 20;
        ql1.Year_5_Net_Amount__c = 40;
        insert ql1;

        //wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Year_4_Effective_Quantity__c, rackRate, rackRate * ql.Year_4_Effective_Quantity__c, ql.Year_4_Effective_Amount__c / ql.Year_4_Effective_Quantity__c, ql.Year_4_Net_Amount__c, rackRate * ql.Year_4_Quantity__c - ql.Year_4_Net_Amount__c);
        System.debug('QuoteLineTemplateControllerTest:' + ql1.SBQQ__ProductName__c + ':' + ql1.Year_4_Effective_Quantity__c + ':' + ql1.Year_4_Effective_Amount__c + ':' + ql1.Year_4_Net_Amount__c + ':' + ql1.Year_4_Quantity__c);

        ApexPages.currentPage().getParameters().put('qid', quote.Id);
        ProposalMasterController controller = new ProposalMasterController();
        System.assertNotEquals(controller.eventTable.QLTables.size(), 0);
    }

    @isTest static void testAbunchMatrixedFiveYears2() {
        PageReference pageRef = Page.QuoteLineTemplateContent;
        Test.setCurrentPage(pageRef);


        Account instofAcc = TestUtil.createAccount('Test Account','Biz_Ac');
        insert instofAcc;

        Contact instOfCon = TestUtil.createContact(String.valueOf(instofAcc.Id));
        insert instOfCon;

        Opportunity opportunity = TestUtil.createOpportunityNew('Test Opportunity','Budget',instOfCon.Id,instofAcc.Id);
        opportunity.CloseDate = Date.today();
        insert opportunity;

        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__StartDate__c = System.today();
        quote.SBQQ__EndDate__c = System.today() + 365;
        quote.Effective_Year_1_Start_Date__c = quote.SBQQ__StartDate__c;
        quote.Effective_Year_1_End_Date__c = quote.SBQQ__EndDate__c;
        quote.Effective_Year_2_Start_Date__c = quote.Effective_Year_1_End_Date__c + 1;
        quote.Effective_Year_2_End_Date__c = quote.Effective_Year_2_Start_Date__c + 365;
        quote.Effective_Year_3_Start_Date__c = quote.Effective_Year_2_End_Date__c + 1;
        quote.Effective_Year_3_End_Date__c = quote.Effective_Year_3_Start_Date__c + 365;
        quote.Effective_Year_4_Start_Date__c = quote.Effective_Year_3_End_Date__c + 1;
        quote.Effective_Year_4_End_Date__c = quote.Effective_Year_4_Start_Date__c + 365;
        quote.Effective_Year_5_Start_Date__c = quote.Effective_Year_4_End_Date__c + 1;
        quote.Effective_Year_5_End_Date__c = quote.Effective_Year_5_Start_Date__c + 365;
        quote.Contract_Term_Years__c = '5';
        quote.Count_of_HC_Products__c = 0;
        quote.Count_of_EC_Products__c = 1;
        quote.SBQQ__Account__c = instofAcc.Id;
        quote.Current_Year__c = 1;
        quote.SBQQ__Opportunity2__c = opportunity.Id;
        quote.Multiple_Years_Commitment__c = TRUE;
        insert quote;

        List<Product2> products = new List<Product2>();
        Product2 product1 = new Product2();
        product1.Name = 'Product 1';
        product1.Contract_Output_Grouping__c = 'Bundle Advertisements';
        product1.ProductCode = 'CV-SW-EC-EVT-EXPPREPAYREG';
        products.add(product1);
        Product2 product2 = new Product2();
        product2.Name = 'Product 2';
        product2.Contract_Output_Grouping__c = 'Suggested Advertisements';
        product2.ProductCode = 'CV-SW-EC-EVT-PRPYMTREGF';
        products.add(product2);
        Product2 product3 = new Product2();
        product3.Name = 'Product 3';
        product3.Contract_Output_Grouping__c = 'Video Retargeting';
        product3.ProductCode = 'CV-SW-EC-EVT-USERFUL';
        products.add(product3);
        Product2 product4 = new Product2();
        product4.Name = 'Product 4';
        product4.Contract_Output_Grouping__c = 'Elite Meetings Alliance';
        product4.ProductCode = 'CV-SW-EC-EVT-USERF';
        products.add(product4);
        Product2 product5 = new Product2();
        product5.Name = 'Product 5';
        product5.Contract_Output_Grouping__c = 'Reporting & Analytics';
        product5.ProductCode = 'CV-SW-EC-EVT-PRPYMTTRNF';
        products.add(product5);
        Product2 product6 = new Product2();
        product6.Name = 'Product 6';
        product6.Contract_Output_Grouping__c = 'Cvent Passkey, Transient & Lanyon Group';
        product6.ProductCode = 'CV-SW-EC-EVT-PRPYMTEVTF';
        products.add(product6);
        Product2 product7 = new Product2();
        product7.Name = 'Product 7';
        product7.Contract_Output_Grouping__c = 'Listing Advertisement(s), Software, Services & CONNECT';
        product7.ProductCode = 'CV-SW-EC-EVT-PRPYMTEVTF';
        products.add(product7);
        Product2 product8 = new Product2();
        product8.Name = 'Product 8';
        product8.Contract_Output_Grouping__c = 'Merchant';
        product8.ProductCode = 'CV-SW-EC-EVT-PRPYMTEVTF';
        products.add(product8);
        Product2 product9 = new Product2();
        product9.Name = 'Product 9';
        product9.Contract_Output_Grouping__c = 'OnDemand';
        product9.ProductCode = 'CV-SW-EC-EVT-PRPYMTEVTF';
        products.add(product9);
        Product2 product10 = new Product2();
        product10.Name = 'Product 10';
        product10.Contract_Output_Grouping__c = 'Professional';
        product10.ProductCode = 'CV-SW-EC-EVT-PRPYMTEVTF';
        products.add(product10);

        insert products;

        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c();
        SBQQ__QuoteLine__c ql2 = new SBQQ__QuoteLine__c();
        SBQQ__QuoteLine__c ql3 = new SBQQ__QuoteLine__c();
        SBQQ__QuoteLine__c ql4 = new SBQQ__QuoteLine__c();
        SBQQ__QuoteLine__c ql5 = new SBQQ__QuoteLine__c();
        SBQQ__QuoteLine__c ql6 = new SBQQ__QuoteLine__c();
        SBQQ__QuoteLine__c ql7 = new SBQQ__QuoteLine__c();
        SBQQ__QuoteLine__c ql8 = new SBQQ__QuoteLine__c();
        SBQQ__QuoteLine__c ql9 = new SBQQ__QuoteLine__c();
        SBQQ__QuoteLine__c ql10 = new SBQQ__QuoteLine__c();
        ql1.SBQQ__Quantity__c = 1;
        ql1.SBQQ__Product__c = product1.Id;
        ql1.SBQQ__ListPrice__c = 10;
        ql1.SBQQ__NetPrice__c = 10;
        ql1.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        ql1.Rack_Rate__c = 10;
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
        ql9 = ql1.clone();
        ql9.SBQQ__Product__c = product9.Id;
        quoteLines.add(ql9);
        ql10 = ql1.clone();
        ql10.SBQQ__Product__c = product10.Id;
        quoteLines.add(ql10);

        insert quoteLines;

        ApexPages.currentPage().getParameters().put('qid', quote.Id);
        ProposalMasterController controller = new ProposalMasterController();
        System.assertNotEquals(controller.eventTable.QLTables.size(), 0);
    }


}