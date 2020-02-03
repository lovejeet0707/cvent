@isTest

public class ProposalDocControllerTest {

    static testMethod void test_SingleYear_NoGroup_Term1() {
        Account account = insertAccount(true);
        Opportunity opportunity = insertOpportunity(true, account.Id);

        SBQQ__Quote__c quote = insertQuote(false, opportunity.Id, account.Id);
        quote.Count_of_HC_Products__c = 1;
        quote.Count_of_EC_Products__c = 0;
        quote.Count_of_RegOnline_Products__c = 0;
        quote.Count_of_Crowd_Compass_ProdFamily__c = 0;
        quote.Count_of_Survey_Inquisium_Products__c = 0;
        insert quote;


        Product2 product1 = insertProduct(false);
        product1.Contract_Output_Grouping__c = 'Bundle Advertisements';
        product1.ProductCode = 'CV-SW-EC-EVT';
        insert product1;

        SBQQ__QuoteLine__c quoteLine = insertQuoteLine(true, quote.Id, product1.Id);

        SBQQ__Quote__c insertedQuote = new SBQQ__Quote__c();
        insertedQuote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];

        Test.startTest();
            PageReference pageRef = Page.ProposalTemplateContent;
            pageRef.getParameters().put('qid',insertedQuote.Id);
            Test.setCurrentPage(pageRef);
            ProposalDocController controller = new ProposalDocController();
        Test.stopTest();
    }

    static testMethod void test_SingleYear() {
        Account account = insertAccount(true);
        Opportunity opportunity = insertOpportunity(true, account.Id);

        SBQQ__Quote__c quote = insertQuote(false, opportunity.Id, account.Id);
        quote.Multiple_Years_Commitment__c = FALSE;
        insert quote;


        Product2 product1 = insertProduct(false);
        product1.Contract_Output_Grouping__c = 'Bundle Advertisements';
        product1.ProductCode = 'CV-SW-EC-EVT';
        insert product1;

        SBQQ__QuoteLine__c quoteLine = insertQuoteLine(true, quote.Id, product1.Id);

        SBQQ__Quote__c insertedQuote = new SBQQ__Quote__c();
        insertedQuote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];

        Test.startTest();
            PageReference pageRef = Page.ProposalTemplateContent;
            pageRef.getParameters().put('qid',insertedQuote.Id);
            Test.setCurrentPage(pageRef);
            ProposalDocController controller = new ProposalDocController();
        Test.stopTest();
    }

    static testMethod void test_SingleYear_NoGroup() {
        Account account = insertAccount(true);
        Opportunity opportunity = insertOpportunity(true, account.Id);
        List<Product2> lstProducts = new List<Product2>();
        
        SBQQ__Quote__c quote = insertQuote(false, opportunity.Id, account.Id);
        quote.Multiple_Years_Commitment__c = FALSE;
        //quote.Count_of_HC_Products__c = 1;
        quote.Count_of_EC_Products__c = 0;
        quote.Count_of_RegOnline_Products__c = 0;
        quote.Count_of_Crowd_Compass_ProdFamily__c = 0;
        quote.Count_of_Survey_Inquisium_Products__c = 0;
        quote.Current_Year__c = 2;
        insert quote;

        Product2 product1 = insertProduct(false);
        product1.Contract_Output_Grouping__c = 'Event Cloud';
        product1.ProductCode = 'CV-SW-EC-EVT-CCMOBAPP';
        lstProducts.add(product1);

        Product2 product2 = insertProduct(false);
        product2.Contract_Output_Grouping__c = 'Event Cloud';
        product2.ProductCode = 'CV-OT-HC-CSN-CVNCFEE';
        lstProducts.add(product2);

        Product2 product3 = insertProduct(false);
        product3.Contract_Output_Grouping__c = 'Event Cloud';
        product3.ProductCode = 'CV-SW-EC-CC-CCMBAP';
        lstProducts.add(product3);
        insert lstProducts;
        SBQQ__QuoteLine__c quoteLine1 = insertQuoteLine(true, quote.Id, product1.Id);
        SBQQ__QuoteLine__c quoteLine2 = insertQuoteLine(true, quote.Id, product2.Id);
        SBQQ__QuoteLine__c quoteLine3 = insertQuoteLine(false, quote.Id, product3.Id);
        quoteLine3.SBQQ__RequiredBy__c = quoteLine2.Id;
        insert quoteLine3;

        List<String> lstGroupNames = new List<String>();
        lstGroupNames.add('Bundle Advertisements');
        lstGroupNames.add('Suggested Advertisements');
        lstGroupNames.add('Video Retargeting');
        lstGroupNames.add('Elite Meetings Alliance');
        lstGroupNames.add('Reporting & Analytics');
        lstGroupNames.add('Cvent Passkey, Transient & Lanyon Group');
        lstGroupNames.add('Merchant');
        lstGroupNames.add('OnDemand');
        lstGroupNames.add('Professional');
        lstGroupNames.add('Listing Advertisement(s), Software, Services & CONNECT');

        List<Product2> lstProducts2 = new List<Product2>();
        for(String groupName : lstGroupNames) {
            for(Integer i = 0; i < lstGroupNames.size(); i++) {
                Product2 product4 = insertProduct(false);
                product4.ProductCode = 'CV-SW-EC-EVT';
                product4.Contract_Output_Grouping__c = groupName;
                lstProducts2.add(product4);
            }
        }
        system.debug('>>> lstProducts: '+lstProducts2);
        insert lstProducts2;

        /*List<SBQQ__QuoteLine__c> lstQuoteLines = new List<SBQQ__QuoteLine__c>();
        for(Product2 product: lstProducts) {
            SBQQ__QuoteLine__c quoteLine = insertQuoteLine(false, quote.Id, product.Id);
            lstQuoteLines.add(quoteLine);
        }
        insert lstQuoteLines;*/

        SBQQ__Quote__c insertedQuote = new SBQQ__Quote__c();
        insertedQuote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];

        Test.startTest();
            PageReference pageRef = Page.ProposalTemplateContent;
            pageRef.getParameters().put('qid',insertedQuote.Id);
            Test.setCurrentPage(pageRef);
            ProposalDocController controller = new ProposalDocController();
        Test.stopTest();
    }

    static testMethod void test_MYD_MultiGroup() {
        Account account = insertAccount(true);

        Opportunity opportunity = insertOpportunity(true, account.Id);

        SBQQ__Quote__c quote = insertQuote(false, opportunity.Id, account.Id);
        quote.Count_of_HC_Products__c = 1;
        quote.Count_of_EC_Products__c = 0;
        quote.Count_of_RegOnline_Products__c = 0;
        quote.Count_of_Crowd_Compass_ProdFamily__c = 0;
        quote.Count_of_Survey_Inquisium_Products__c = 0;
        insert quote;

        List<SBQQ__QuoteLine__c> lstQuoteLines= new List<SBQQ__QuoteLine__c>();
        Map<Integer, SBQQ__QuoteLineGroup__c> mapQuoteLineGroups = new Map<Integer, SBQQ__QuoteLineGroup__c>();
        for (Integer i = 0, j = 0; i < 5; i++)
        {
            SBQQ__QuoteLineGroup__c quoteLineGroup = new SBQQ__QuoteLineGroup__c();
            quoteLineGroup.Name = 'Year'+i;
            quoteLineGroup.SBQQ__Number__c = i;
            quoteLineGroup.SBQQ__ListTotal__c = 0.00;
            quoteLineGroup.SBQQ__CustomerTotal__c = 0.00;
            quoteLineGroup.SBQQ__NetTotal__c = 0.00;
            quoteLineGroup.CurrencyIsoCode = 'USD';
            quoteLineGroup.SBQQ__Quote__c = quote.Id;
            insert quoteLineGroup;
            mapQuoteLineGroups.put(i, quoteLineGroup);
        }

        Product2 product1 = new Product2();
        product1.Name = 'Test Product';
        product1.Contract_Output_Grouping__c = 'Event Cloud';
        product1.ProductCode = 'CV-SW-EC-EVT';
        product1.Show_True_Quantity__c = true;
        insert product1;

        //List<SBQQ__QuoteLine__c> lst_qls = new List<SBQQ__QuoteLine__c>();
        Date startdate =System.today();
        Date endsdate = System.today() + 365;
        for (Integer i = 0, j = 0; i < 5; i++)
            {
                SBQQ__QuoteLine__c quoteLine = insertQuoteLine(false, quote.Id, product1.Id);
                quoteLine.Overage_Fee__c = i+1;
                quoteLine.SBQQ__Group__c = mapQuoteLineGroups.get(i).Id;
                lstQuoteLines.add(quoteLine);
            }
        insert lstQuoteLines;

        SBQQ__Quote__c insertedQuote = new SBQQ__Quote__c();
        insertedQuote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];

        Test.startTest();
            PageReference pageRef = Page.ProposalTemplateContent;
            pageRef.getParameters().put('qid',insertedQuote.Id);
            Test.setCurrentPage(pageRef);
            ProposalDocController controller = new ProposalDocController();
        Test.stopTest();
    }

    static testMethod void test_MYD_SingleGroup() {
        Account account = insertAccount(true);
        Opportunity opportunity = insertOpportunity(true, account.Id);

        SBQQ__Quote__c quote = insertQuote(false, opportunity.Id, account.Id);
        quote.Count_of_HC_Products__c = 1;
        quote.Count_of_EC_Products__c = 0;
        quote.Count_of_RegOnline_Products__c = 0;
        quote.Count_of_Crowd_Compass_ProdFamily__c = 0;
        quote.Count_of_Survey_Inquisium_Products__c = 0;
        insert quote;

        List<String> lstGroupNames = new List<String>();
        lstGroupNames.add('Bundle Advertisements');
        lstGroupNames.add('Suggested Advertisements');
        lstGroupNames.add('Video Retargeting');
        lstGroupNames.add('Elite Meetings Alliance');
        lstGroupNames.add('Reporting & Analytics');
        lstGroupNames.add('Cvent Passkey, Transient & Lanyon Group');
        lstGroupNames.add('Merchant');
        lstGroupNames.add('OnDemand');
        lstGroupNames.add('Professional');

        List<Product2> lstProducts = new List<Product2>();
        for(String groupName : lstGroupNames) {
            for(Integer i = 0; i < lstGroupNames.size(); i++) {
                Product2 product1 = insertProduct(false);
                product1.ProductCode = 'CV-SW-EC-EVT';
                product1.Contract_Output_Grouping__c = groupName;
                lstProducts.add(product1);
            }
        }
        system.debug('>>> lstProducts: '+lstProducts);
        insert lstProducts;

        SBQQ__QuoteLineGroup__c quoteLineGroup = new SBQQ__QuoteLineGroup__c();
        quoteLineGroup.Name = 'Year 1';
        quoteLineGroup.SBQQ__Number__c = 1;
        quoteLineGroup.SBQQ__ListTotal__c = 0.00;
        quoteLineGroup.SBQQ__CustomerTotal__c = 0.00;
        quoteLineGroup.SBQQ__NetTotal__c = 0.00;
        quoteLineGroup.CurrencyIsoCode = 'USD';
        quoteLineGroup.SBQQ__Quote__c = quote.Id;
        insert quoteLineGroup;

        List<SBQQ__QuoteLine__c> lstQuoteLines = new List<SBQQ__QuoteLine__c>();

        for(Product2 product: lstProducts) {
            SBQQ__QuoteLine__c quoteLine = insertQuoteLine(false, quote.Id, product.Id);
            lstQuoteLines.add(quoteLine);
        }
        system.debug('>>> Quotelines list'+lstQuoteLines);
        if(!lstQuoteLines.isEmpty()) {
            insert lstQuoteLines;
        }

        SBQQ__Quote__c insertedQuote = new SBQQ__Quote__c();
        insertedQuote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];

        Test.startTest();
            PageReference pageRef = Page.ProposalTemplateContent;
            pageRef.getParameters().put('qid',insertedQuote.Id);
            Test.setCurrentPage(pageRef);
            ProposalDocController controller = new ProposalDocController();
        Test.stopTest();
    }

    static testMethod void test_NONMYD() {
        Account account = insertAccount(true);

        Opportunity opportunity = insertOpportunity(true, account.Id);

        SBQQ__Quote__c quote = insertQuote(false, opportunity.Id, account.Id);
        quote.Multiple_Years_Commitment__c = FALSE;
        quote.Count_of_HC_Products__c = 1;
        quote.Count_of_EC_Products__c = 0;
        quote.Count_of_RegOnline_Products__c = 0;
        quote.Count_of_Crowd_Compass_ProdFamily__c = 0;
        quote.Count_of_Survey_Inquisium_Products__c = 0;
        insert quote;

        List<SBQQ__QuoteLine__c> lstQuoteLines= new List<SBQQ__QuoteLine__c>();
        Map<Integer, SBQQ__QuoteLineGroup__c> mapQuoteLineGroups = new Map<Integer, SBQQ__QuoteLineGroup__c>();
        for (Integer i = 0; i < 5; i++)
        {
            SBQQ__QuoteLineGroup__c quoteLineGroup = new SBQQ__QuoteLineGroup__c();
            quoteLineGroup.Name = 'Year'+i;
            quoteLineGroup.SBQQ__Number__c = i;
            quoteLineGroup.SBQQ__ListTotal__c = 0.00;
            quoteLineGroup.SBQQ__CustomerTotal__c = 0.00;
            quoteLineGroup.SBQQ__NetTotal__c = 0.00;
            quoteLineGroup.CurrencyIsoCode = 'USD';
            quoteLineGroup.SBQQ__Quote__c = quote.Id;
            quoteLineGroup.term__c = i+1;
            insert quoteLineGroup;
            System.debug('>>> TERM: '+quoteLineGroup.term__c);
            mapQuoteLineGroups.put(i, quoteLineGroup);
        }


        Product2 product1 = new Product2();
        product1.Name = 'Test Product';
        product1.Contract_Output_Grouping__c = 'Event Cloud';
        product1.ProductCode = 'CV-SW-EC-EVT';
        insert product1;

        //List<SBQQ__QuoteLine__c> lst_qls = new List<SBQQ__QuoteLine__c>();
        Date startdate =System.today();
        Date endsdate = System.today() + 365;
        for (Integer i = 0, j = 0; i < 5; i++)
        {
            SBQQ__QuoteLine__c quoteLine = insertQuoteLine(false, quote.Id, product1.Id);
            quoteLine.Overage_Fee__c = i+1;
            quoteLine.SBQQ__Group__c = mapQuoteLineGroups.get(i).Id;
            lstQuoteLines.add(quoteLine);
        }
        insert lstQuoteLines;

        SBQQ__Quote__c insertedQuote = new SBQQ__Quote__c();
        insertedQuote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];

        Test.startTest();
            PageReference pageRef = Page.ProposalTemplateContent;
            pageRef.getParameters().put('qid',insertedQuote.Id);
            Test.setCurrentPage(pageRef);
            ProposalDocController controller = new ProposalDocController();
        Test.stopTest();
    }

    static testMethod void test_MYD_HC() {
        Account account = insertAccount(true);
        Opportunity opportunity = insertOpportunity(true, account.Id);

        SBQQ__Quote__c quote = insertQuote(false, opportunity.Id, account.Id);
        quote.Hide_Unit_Prices_on_Contract__c  = TRUE;
        quote.Count_of_HC_Products__c = 1;
        quote.Count_of_EC_Products__c = 0;
        quote.Count_of_RegOnline_Products__c = 0;
        quote.Count_of_Crowd_Compass_ProdFamily__c = 0;
        quote.Count_of_Survey_Inquisium_Products__c = 0;

        insert quote;

        Product2 product1 = insertProduct(false);
        product1.Contract_Output_Grouping__c = 'Listing Advertisement(s), Software, Services & CONNECT';
        product1.ProductCode = 'CV-SW-EC-EVT';
        insert product1;

        SBQQ__QuoteLine__c quoteLine = insertQuoteLine(true, quote.Id, product1.Id);
        System.debug('>>> 6 QL Term'+quoteLine.term__c);

        SBQQ__Quote__c insertedQuote = new SBQQ__Quote__c();
        insertedQuote = [SELECT Id
                              , HC_Logo_Conditional_Print__c
                              , Contract_Remaining_Term__c
                              , Count_of_RegOnline_Products__c
                              , Count_of_EC_Products__c
                              , Count_of_Crowd_Compass_ProdFamily__c
                              , Count_of_Survey_Inquisium_Products__c
                              , Count_of_HC_Products__c
                              , Current_Year__c
                              , Multiple_Years_Commitment__c
                              FROM SBQQ__Quote__c LIMIT 1];
        System.debug('>>> 6 HC_Logo_Conditional_Print__c: '+insertedQuote.HC_Logo_Conditional_Print__c);
        System.debug('>>> 6 Contract_Remaining_Term__c'+insertedQuote.Contract_Remaining_Term__c);
        System.debug('>>> Count_of_RegOnline_Products__c: '+insertedQuote.Count_of_RegOnline_Products__c);
        System.debug('>>> Count_of_EC_Products__c: '+insertedQuote.Count_of_EC_Products__c);
        System.debug('>>> Count_of_Crowd_Compass_ProdFamily__c: '+insertedQuote.Count_of_Crowd_Compass_ProdFamily__c);
        System.debug('>>> Count_of_Survey_Inquisium_Products__c: '+insertedQuote.Count_of_Survey_Inquisium_Products__c);
        System.debug('>>> Count_of_HC_Products__c: '+insertedQuote.Count_of_HC_Products__c);
        System.debug('>>> Current_Year__c: '+insertedQuote.Current_Year__c);
        System.debug('>>> 6 Multiple_Years_Commitment '+insertedQuote.Multiple_Years_Commitment__c);

        Test.startTest();
            PageReference pageRef = Page.ProposalTemplateContent;
            pageRef.getParameters().put('qid',insertedQuote.Id);
            Test.setCurrentPage(pageRef);
            ProposalDocController controller = new ProposalDocController();
        Test.stopTest();
    }

    // --------- TEST DATA CREATION  --------- //
    public static Account insertAccount(Boolean isInsert) {
        Account accountObj = new Account();
        accountObj.Name = 'Test Account';
        accountObj.BillingCountry='MX';
        if(isInsert == true) {
            insert accountObj;
        }
        return accountObj;
    }

    public static Opportunity insertOpportunity(Boolean isInsert, Id accountId) {
        Opportunity opportunityObj = new Opportunity();
        opportunityObj.Name = 'Test Opportunity';
        opportunityObj.CloseDate = date.today();
        opportunityObj.AccountId = accountId;
        opportunityObj.StageName = 'Draft';

        if(isInsert == true) {
            insert opportunityObj;
        }
        return opportunityObj;
    }

    public static SBQQ__Quote__c insertQuote(Boolean isInsert, Id oppId, Id accountId) {
        SBQQ__Quote__c quoteObj = new SBQQ__Quote__c();
        quoteObj.SBQQ__Primary__c = true;
        quoteObj.SBQQ__StartDate__c = System.today();
        quoteObj.SBQQ__EndDate__c = System.today() + 365;
        quoteObj.Contract_Term_Years__c = '5';
        quoteObj.Count_of_HC_Products__c = 0;
        quoteObj.Count_of_EC_Products__c = 1;
        quoteObj.Current_Year__c = 1;
        quoteObj.SBQQ__Opportunity2__c = oppId;
        quoteObj.SBQQ__Account__c = accountId;
        quoteObj.Multiple_Years_Commitment__c = false;

        if(isInsert == true) {
            insert quoteObj;
        }
        return quoteObj;
    }

    public static Product2 insertProduct(Boolean isInsert) {
        Product2 productObj = new Product2();
        productObj.Name = 'Test Product';
        productObj.Contract_Output_Grouping__c = 'Event Cloud';
        productObj.ProductCode = 'CV-SW-EC-EVT';
        if(isInsert == true) {
            insert productObj;
        }
        return productObj;
    }

    public static SBQQ__QuoteLine__c insertQuoteLine(Boolean isInsert, Id quoteId, Id productId) {
        SBQQ__QuoteLine__c quoteLineObj = new SBQQ__QuoteLine__c();
        quoteLineObj.CurrencyIsoCode = 'USD';
        quoteLineObj.SBQQ__StartDate__c = date.today();
        quoteLineObj.SBQQ__EndDate__c = date.today();
        quoteLineObj.SBQQ__Quote__c = quoteId;
        quoteLineObj.SBQQ__Quantity__c = 1;
        quoteLineObj.SBQQ__Product__c = productId;
        quoteLineObj.SBQQ__ListPrice__c = 10;
        quoteLineObj.SBQQ__NetPrice__c = 10;
        quoteLineObj.Rack_Rate__c = 10;
        quoteLineObj.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        quoteLineObj.Notes__c = 'Test Notes';

        if(isInsert == true) {
            insert quoteLineObj;
        }
        return quoteLineObj;
    }
}