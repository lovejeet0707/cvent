@isTest private class CventMyd_ReassignmentHandler_Test {

    public static Account createAccount() {
        Account testAccount =TestUtil.createAccount('Test Account','Biz_Ac');
        testAccount.Supplier_Type__c = 'Venue';
        testAccount.Venue_Type__c = 'CVB';
        testAccount.BillingState='AK';
        testAccount.BillingCountryCode='US';            
        insert testAccount; 
        return testAccount; 
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

    public static void updateOpportunityAddresses(Id opportunityId, Id accountId) {
        Id shippingAddressId = createShippingAddress(accountId).Id;  
        Id billingAddressId = createBillingAddress(accountId).Id;
        Opportunity opportunity = new Opportunity(Id = opportunityId, AccountId = accountId);
        opportunity.Bill_To_Address__c = billingAddressId;
        opportunity.Ship_To_Address__c = shippingAddressId;
        update opportunity;     
    }    

    public static Opportunity createOpportunity(Id accountId) {
        Opportunity opportunity=TestUtil.createOpportunity('Test Opp','Event','Qualified');
        opportunity.StageName ='Verbal';
        opportunity.Deal_Year__c ='1';
        opportunity.NBB_Renewal__c = 'NBB';
        opportunity.Parent_Upsell__c = 'Primary';
        opportunity.CloseDate = system.today().addmonths(12);
        // opportunity.Web_Design_Support_Minutes_Purchased__c =0;
        opportunity.Contract_Implemented__c = true;
        opportunity.ContractReceived__c = system.today();
        opportunity.Product__c ='TicketMob';
        opportunity.MYD_Deal__c='First Year';
        opportunity.pricebook2id=Test.getStandardPricebookID();
        Contact testContact =TestUtil.createContact(accountId);
        opportunity.Contact_Associated__c=testContact.id; 
        opportunity.AccountId = accountId;
        //opportunity.SBQQ__PrimaryQuote__c ='';
        //opportunity.SBQQ__RenewedContract__c=con1.Id;
        insert opportunity; 
        updateOpportunityAddresses(opportunity.Id,accountId);
        return opportunity;
    }

    public static SBQQ__Quote__c createQuote(Id opportunityId, Integer currentYear, Integer finalYear, String type, Boolean variable) {
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__Opportunity2__c = opportunityId;
        quote.Current_Year__c = currentYear;
        quote.SBQQ__StartDate__c = Date.today();
        quote.SBQQ__EndDate__c = quote.SBQQ__StartDate__c.addYears(1);
        quote.Contract_Term_Years__c = String.valueOf(finalYear);
        quote.Multiple_Years_Commitment__c = variable;
        insert quote;
        return quote;
    }

    public static Product2 createProduct() {
        Product2 product = new Product2();
        product.Name = 'Product ' + CventMyd_UtilityMethods.getQleId();
        product.Contract_Output_Grouping__c = 'Bundle Advertisements';
        product.Revenue_Type__c = 'Annual Recurring';
        insert product;
        return product;
    }

    public static SBQQ__QuoteLine__c createQuoteLine(Id productId,Id quoteId) {
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
        quoteLine.SBQQ__Quantity__c = 1;
        quoteLine.SBQQ__Product__c = productId;
        quoteLine.SBQQ__ListPrice__c = 10;
        quoteLine.SBQQ__NetPrice__c = 10;
        quoteLine.Rack_Rate__c = 10;
        quoteLine.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        quoteLine.SBQQ__Number__c = 1;
        quoteLine.SBQQ__Quote__c = quoteId;
        quoteLine.Notes__c = 'abc';
        quoteLine.jsonString__c = '{"qleId":"20432_mcw_61405","quoteName":"Q-545439","preCalculationFieldValueMap":{"SBQQ__Quantity__c":[51],"SBQQ__Discount__c":[0],"Custom_Discount__c":[0],"SBQQ__DistributorDiscount__c":[null],"SBQQ__PartnerDiscount__c":[null],"SBQQ__AdditionalDiscountAmount__c":[null],"Discount_Type__c":["%"],"SBQQ__StartDate__c":["2021-04-23"],"SBQQ__EndDate__c":[null],"SBQQ__PricingMethod__c":["List"],"Conversion_Rate__c":[1],"Retargeting_Tracking__c":[null],"MMA_Text__c":[null]},"calculatedFieldValueMap":{"SBQQ__OriginalPrice__c":[9.95],"SBQQ__ListPrice__c":[7.21],"SBQQ__RegularPrice__c":[7.21],"SBQQ__CustomerPrice__c":[7.21],"SBQQ__PartnerPrice__c":[7.21],"SBQQ__NetPrice__c":[7.21],"Rack_Rate__c":[7.21],"SBQQ__ProrateMultiplier__c":[1]},"contractedFieldValueMap":{},"clonedFromQleIds":[],"insertOnNextCurrentYear":false,"requiredByQleId":"24206_npe_45997"}';
        insert quoteLine; 
        return quoteLine;   
    }

    /*
        public testmethod static void testMethod0() {
            Account account = createAccount();
            Opportunity sourceOpportunity = createOpportunity(account.Id);
            SBQQ__Quote__c sourceQuote = createQuote(sourceOpportunity.Id,1,1,'Quote',false);
            sourceOpportunity.SBQQ__PrimaryQuote__c = sourceQuote.Id;
            update sourceOpportunity;
            Product2 product = createProduct();
            createQuoteLine(product.Id,sourceQuote.Id);
            Opportunity targetOpportunity = createOpportunity(account.Id);
            SBQQ__Quote__c targetQuote = createQuote(targetOpportunity.Id,1,1,'Quote',false);
            targetOpportunity.SBQQ__PrimaryQuote__c = targetQuote.Id;
            update targetOpportunity;
            System.debug('sourceOpportunityId being updated: ' + sourceOpportunity.Id);
            System.debug('target Opportunity Id in test class: ' + targetOpportunity.Id);
            sourceOpportunity.Reassigned_To__c = targetOpportunity.Id;
            Test.startTest();
            CheckRecursive.runEight = true;        
            update sourceOpportunity;
            Test.stopTest();
        }
    */

    public testmethod static void testMethod1() {
        Account account = createAccount();
        Opportunity sourceOpportunity = createOpportunity(account.Id);
        SBQQ__Quote__c sourceQuote = createQuote(sourceOpportunity.Id,1,1,'Quote',false);
        sourceOpportunity.SBQQ__PrimaryQuote__c = sourceQuote.Id;
        update sourceOpportunity;
        Product2 sourceProduct = createProduct();
        createQuoteLine(sourceProduct.Id,sourceQuote.Id);
        Opportunity targetOpportunity = createOpportunity(account.Id);
        SBQQ__Quote__c targetQuote = createQuote(targetOpportunity.Id,1,3,'Quote',true);
        Product2 targetProduct = createProduct();
        createQuoteLine(targetProduct.Id,targetQuote.Id);
        targetOpportunity.SBQQ__PrimaryQuote__c = targetQuote.Id;
        update targetOpportunity;
        System.debug('sourceOpportunityId being updated: ' + sourceOpportunity.Id);
        System.debug('target Opportunity Id in test class: ' + targetOpportunity.Id);
        sourceOpportunity.Reassigned_To__c = targetOpportunity.Id;
        Test.startTest();
        CheckRecursive.runEight = true;        
        update sourceOpportunity;
        Test.stopTest();
    }    

}