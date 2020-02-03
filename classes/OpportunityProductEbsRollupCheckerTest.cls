@isTest(SeeAllData=false)

private class OpportunityProductEbsRollupCheckerTest {

    @testSetup static void createBaseRecords() {

        Account account = new Account();

        account.Name = 'Biz Test Acc 1';

        account.EBS_Account_ID__c = '46465464';
            
        account.BillingCountry = 'US';
            
        account.BillingState = 'AK';

        account.BillingCity = 'Anchorage';
            
        account.BillingStreet = '172 Palm Ave Apt 2';

        account.BillingPostalCode='46511';

        account.ShippingCountry = 'US';
            
        account.ShippingState = 'AK';

        account.ShippingCity = 'Anchorage';
            
        account.ShippingStreet = '172 Palm Ave Apta 2';

        account.ShippingPostalCode='46543';        

        insert account;

        Id addressId = [SELECT Id FROM Address__c WHERE Account__c =: account.Id AND Type__c = 'Shipping'].Id;

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

        opportunity.Ship_To_Address__c = addressId;

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

        List<Product2> testProducts = new List<Product2>();

        Integer numberOfTestProducts = 3;

        for(Integer i = 0; i < numberOfTestProducts; i++) {

            Product2 product = new Product2();

            product.Name = 'Product 0';

            product.Contract_Output_Grouping__c = 'Event Cloud';

            product.ProductCode = 'CBP-123-456-ABC' + String.valueOf(i);

            testProducts.add(product);

        }

        testProducts[0].Send_Rollup_To_EBS__c = true;

        testProducts[1].rollupIntoBundleForEbs__c = true;

        testProducts[2].rollupIntoBundleForEbs__c = true;

        insert testProducts;

        Id pricebookId = Test.getStandardPricebookId();

        List<PricebookEntry> priceBookEntries = new List<PricebookEntry>();

        for(Product2 p : testProducts) {priceBookEntries.add(new PricebookEntry(Product2Id=p.Id,Pricebook2Id=pricebookId,UnitPrice=50,isActive=true));}

        insert priceBookEntries;        

    }

    static List<SBQQ__QuoteLine__c> createQuoteLines() {

       List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();

        List<PricebookEntry> priceBookEntries = [SELECT Id, Product2Id, Pricebook2Id,UnitPrice,isActive FROM PriceBookEntry];

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

      quoteLines.add(quoteLine);

    }

    return quoteLines;

  }

  static void createNestedEbsBundle() {

    List<SBQQ__QuoteLine__c> quoteLines = createQuoteLines();

    insert quoteLines;

        Integer ebsBundleIndex;

        Integer ebsNormalChildIndex;

        Integer ebsLoneChildIndex;

        quoteLines = [SELECT Id, Send_Rollup_To_EBS__c FROM SBQQ__QuoteLine__c];

    for(Integer i = 0; i < quoteLines.size(); i++) {

      SBQQ__QuoteLine__c ql = quoteLines[i];

      if(ql.Send_Rollup_To_EBS__c) {ebsBundleIndex = i;}

      else if (ebsNormalChildIndex == null) {ebsNormalChildIndex = i;}

      else {ebsLoneChildIndex = i;}      

    }

        quoteLines[ebsNormalChildIndex].SBQQ__RequiredBy__c = quoteLines[ebsBundleIndex].Id;

        quoteLines[ebsLoneChildIndex].SBQQ__RequiredBy__c = quoteLines[ebsNormalChildIndex].Id;

        update quoteLines;      

    }

    @isTest static void testDeletionOfEbsNestedBundle() {

        createNestedEbsBundle();    

        SBQQ__QuoteLine__c quoteLine = [SELECT Id FROM SBQQ__QuoteLine__c WHERE Send_Rollup_To_EBS__c = TRUE];

        Test.startTest();

        delete quoteLine;

        Test.stopTest();

        List<SBQQ__QuoteLine__c> quoteLines = [SELECT Id FROM SBQQ__QuoteLine__c WHERE isDeleted = FALSE];

        List<OpportunityLineItem> opportunityLineItems = [SELECT Id,SBQQ__QuoteLine__c,SBQQ__QuoteLine__r.Send_Rollup_To_EBS__c,SBQQ__QuoteLine__r.SBQQ__RequiredBy__c,isMissingParentBundle__c FROM OpportunityLineItem];

        System.assertEquals(opportunityLineItems.size(),quoteLines.size());

        for(OpportunityLineItem ole : opportunityLineItems) {System.assert(ole.isMissingParentBundle__c);}      

    }
    
}