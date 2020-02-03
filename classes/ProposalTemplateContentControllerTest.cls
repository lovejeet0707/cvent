@isTest(SeeAllData=false)

private class ProposalTemplateContentControllerTest {
    
    @testSetup static void createTestData() {

        Account account = new Account();

        account.Name = 'Biz Test Acc 1';

        insert account;

        Contact contact = new Contact();

        contact.LastName = 'Test Con 1';

        contact.AccountId = account.Id;

        contact.EBS_Account_Id__c = '464654';

        insert contact;

        LicenseVsProductSetting__c license = new LicenseVsProductSetting__c();

        license.Name = 'Prepayment - Events Fee';

        license.Product__c = 'Prepayment - Events Fee';      

        insert license;

        Opportunity opportunity = new Opportunity();

        opportunity.Name = 'Test Opp 1';

        opportunity.AccountId = account.Id;

        opportunity.StageName = 'Closed Won Verbal';

        //opportunity.Ship_To_Address__c = addressId;

        opportunity.CloseDate = System.today()+ 30;

        opportunity.Contact_Associated__c = contact.Id;

        opportunity.Contact_Role__c = 'Influencer';

        opportunity.ContractReceived__c = System.today()-7;

        opportunity.Product__c = 'CrowdCompass';

        opportunity.License_Type__c = 'Prepayment - Events Fee';

        opportunity.New_Amount__c = 150;

        opportunity.MaintenanceFee__c = 10;

        opportunity.Convinience_Fee__c = 10;

        opportunity.Discount__c = 10;
           
        opportunity.of_Leads_Purchased__c= 10;

        opportunity.Per_Registration_Fee__c= 10;

        opportunity.of_Complimentary_Leads__c= 10;

        insert opportunity; 

        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Primary__c = true, SBQQ__Opportunity2__c = opportunity.Id, SBQQ__StartDate__c = System.today(), Contract_Term_Years__c = '4', SBQQ__EndDate__c = System.today());

        insert quote; 

        SBQQ__QuoteLineGroup__c quoteLineGroup = new SBQQ__QuoteLineGroup__c(SBQQ__Quote__c = quote.Id);

        quoteLineGroup.groupType__c = 'Proposal Comparison Group';

        quoteLineGroup.termLength__c = String.valueOf(2);

        insert quoteLineGroup;

        List<Product2> testProducts = new List<Product2>();

        Integer numberOfTestProducts = 3;

        for(Integer i = 0; i < numberOfTestProducts; i++) {

            Product2 product = new Product2();

            product.Name = 'Product 0';

            product.Contract_Output_Grouping__c = 'Event Cloud';

            product.doMatrixComparison__c = false;

            product.ProductCode = 'CBP-123-456-ABC' + String.valueOf(i);

            testProducts.add(product);

        }

        testProducts[0].doMatrixComparison__c = true;

        testProducts[0].ProductCode = 'CV-SW-EC-EVT-CCMOBAPP';

        insert testProducts;

        Id pricebookId = Test.getStandardPricebookId();

        List<PricebookEntry> priceBookEntries = new List<PricebookEntry>();

        for(Product2 p : testProducts) {priceBookEntries.add(new PricebookEntry(Product2Id=p.Id,Pricebook2Id=pricebookId,UnitPrice=50,isActive=true));}

        insert priceBookEntries;

        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();

        Id quoteId = [SELECT Id FROM SBQQ__Quote__c LIMIT 1].Id;

        for(PricebookEntry pbe : priceBookEntries)   {

            SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();

            quoteLine.SBQQ__Quantity__c = 1;

            quoteLine.SBQQ__Product__c = pbe.Product2Id;

            quoteLine.SBQQ__RegularPrice__c = 10;

            quoteLine.SBQQ__NetPrice__c = 10;

            quoteLine.Rack_Rate__c = 10;

            quoteLine.SBQQ__SubscriptionPricing__c = 'Fixed Price';

            quoteLine.SBQQ__Quote__c = quoteId;

            quoteLine.Notes__c = 'abc';

            quoteLine.Overage_Fee__c = 2;

            quoteLine.SBQQ__Group__c = quoteLineGroup.Id;

            quoteLine.SBQQ__Bundled__c = false;

            quoteLine.SBQQ__Hidden__c = false;

            quoteLines.add(quoteLine);

        }    

        insert quoteLines;

    }

    @isTest static void testProposalControllerConstructor() {

        PageReference pageReference = Page.EventCloudProposalContent;

        Test.setCurrentPage(pageReference);

        Id quoteId = [SELECT Id FROM SBQQ__Quote__c LIMIT 1].Id;

        pageReference.getParameters().put('qid',String.valueOf(quoteId));       

        Test.startTest();   

        ProposalTemplateContentController proposalTemplateContentController = new ProposalTemplateContentController();

        System.assertEquals(proposalTemplateContentController.proposalTables.size(),1);

        QuoteLineTableController quoteLineTableController = new QuoteLineTableController();

        quoteLineTableController.quoteLines = proposalTemplateContentController.additionalQuoteLines;

        quoteLineTableController.isWithMatrixProducts = true;

        quoteLineTableController.getTitle();

        quoteLineTableController.getDescriptionText();

        quoteLineTableController.getCurrencySign();

        quoteLineTableController.getColumns();

        quoteLineTableController.getRows();

        QuoteDocumentGenerationHelper quoteDocumentGenerationHelper = new QuoteDocumentGenerationHelper();

        Test.stopTest();

    }

}