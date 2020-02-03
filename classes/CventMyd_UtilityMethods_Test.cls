@isTest
private class CventMyd_UtilityMethods_Test {    

	private static testMethod void testMethod0() {
	    //Create Account
	    Account newAccount = new Account(Name = 'Test Account',BillingCountryCode='US',BillingState='AK');
	    insert newAccount;
	    //Create Opportunity
	    Opportunity newOpportunity = new Opportunity(AccountId = newAccount.Id, 
    	    RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CSN-Supplier').getRecordTypeId(), 
    	    Name = 'Test Opportunity', 
    	   // Product = 'CSN',
    	   StageName = 'Legal',
    	    CloseDate = Date.newInstance(2019, 01, 01)
	    );
	    insert newOpportunity;

        updateOpportunityAddresses(newOpportunity.Id,newAccount.Id);

        
        // Instantiate the Pricebook2 record first, setting the Id
        Pricebook2 standardPricebook = new Pricebook2(
        	Id = Test.getStandardPricebookId(),
        	IsActive = true
        );
        update standardPricebook;
        
        // Re-Query for the Pricebook2 record, for debugging
        standardPricebook = [SELECT IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];

        // Create the Product
        Product2 testProduct = new Product2(
        	Name = 'Test Product', 
        	IsActive = true
        );
        insert testProduct;
        
        // Create the PricebookEntry
        PricebookEntry testPbe = new PricebookEntry(
        	Pricebook2Id = standardPricebook.Id,
        	Product2Id = testProduct.Id,
        	UnitPrice = 100,
        	IsActive = true
        );
        insert testPbe;

        Id recordTypeIdParent = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Parent Contract').getRecordTypeId();
	    Id ChildRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Child Contract').getRecordTypeId();
        
        //Parent Contract to have Parent_Contract_Term_Years__c, Upcoming_Renewal_Type__c, Parent_Contract_Term_Years__c
        Contract ParentCont = new Contract();
        ParentCont.AccountId = newOpportunity.accountId;
        ParentCont.Contract_Term_Years__c = '2';
        ParentCont.Year_2_End_Date__c = newOpportunity.CloseDate;
        //Parent_Contract_Term_Years__c = 1
        ParentCont.RecordTypeId = recordTypeIdParent;
        ParentCont.SBQQ__Opportunity__c = newOpportunity.id;
        ParentCont.EndDate = newOpportunity.CloseDate;
        ParentCont.Current_Year__c = 1;
        insert ParentCont;
        
        //Child Contract
        Contract cont = new Contract();
        cont.RecordTypeId = ChildRecordTypeId;
        cont.AccountId = newOpportunity.accountId;
        cont.Parent_Contract__c = ParentCont.id;
        cont.SBQQ__Opportunity__c = newOpportunity.id;
        //cont.Upcoming_Renewal_Type__c = 'Contract Renewal';
        cont.EndDate = newOpportunity.CloseDate;
        cont.Year_2_End_Date__c = newOpportunity.CloseDate;
        //cont.Remaining_Master_Term__c = 0;
        cont.Current_Year__c = 1;
        insert cont;
        
        // Create subscription
   
        SBQQ__Subscription__c newSubscription = new SBQQ__Subscription__c(
            SBQQ__Quantity__c = 11,
            SBQQ__Product__c = testProduct.Id, 
            SBQQ__Account__c = newOpportunity.AccountId, 
            SBQQ__Contract__c = cont.Id
        );
        insert newSubscription;
        
        SBQQ__Subscription__c newSubscription1 = new SBQQ__Subscription__c(
            SBQQ__Quantity__c = 11,
            SBQQ__Product__c = testProduct.Id, 
            SBQQ__Account__c = newOpportunity.AccountId, 
            SBQQ__Contract__c = cont.Id,
            SBQQ__RevisedSubscription__c = newSubscription.Id
        );
        insert newSubscription1;
        
        // newOpportunity.SBQQ__RenewedContract__c = ParentCont.id;
        // update opp;
        
        //Normal Quote
        //Try inserting a Quote SBQQ__Type__c == Renewal
        List<SBQQ__Quote__c> listNewQuote = new List<SBQQ__Quote__c>();
        SBQQ__Quote__c TestQuote = new SBQQ__Quote__c();
        TestQuote.SBQQ__Opportunity2__c = newOpportunity.id;
        TestQuote.Contract_Term_Years__c = '2';
        TestQuote.SBQQ__Type__c = 'Quote';
        TestQuote.Current_Year__c = 1;
        TestQuote.SBQQ__EndDate__c = System.today();
        TestQuote.Contract_Executed__c = true;
        insert TestQuote;
        
        SBQQ__Quote__c TestQuote2 = new SBQQ__Quote__c();
        TestQuote2.SBQQ__Opportunity2__c = newOpportunity.id;
        TestQuote2.Contract_Term_Years__c = '2';
        TestQuote2.SBQQ__Type__c = 'Renewal';
        TestQuote2.Current_Year__c = 1;
        TestQuote2.SBQQ__EndDate__c = System.today();
        TestQuote2.Contract_Executed__c = true;
        TestQuote2.Multiple_Years_Commitment__c = true;
        insert TestQuote2;
  
        
        CpqAudit__c newCpqAudit = new CpqAudit__c(Name = 'test', jobsInChain__c = 2);
        insert newCpqAudit;
        
	    test.startTest();
            CventMyd_Settings cS = new CventMyd_Settings();
            //CventMyd_UtilityMethods.getAndSetLegacySubscriptions(new Set<Id>{ParentCont.Id});
            //CventMyd_UtilityMethods.searchForFieldValue
            Map<Id,Id> newQuoteId = new Map<Id,Id>();
            newQuoteId.put(TestQuote.Id,TestQuote2.Id);
            CventMyd_UtilityMethods.updatePreviousQuotes(newQuoteId);
            List<String> testString = CventMyd_UtilityMethods.getEndDateFieldNames(cont);
            //CventMyd_UtilityMethods.getYearToEndDateFieldName(cont);
            try{
                insert new Account();
            }catch(Exception ex){
                CventMyd_UtilityMethods.getExceptionString(ex);
            }
            
            CventMyd_UtilityMethods.getFormattedDateTimeString(System.now(), true, true);
            CventMyd_UtilityMethods.getRenewalChainMasterJobName(System.now(),System.now());
            CventMyd_UtilityMethods.getRenewalChainLinkJobName(System.now());
            //CventMyd_UtilityMethods.getAuditRecord(cont.id,cont.id);
            //CventMyd_UtilityMethods.getAuditRecord(null,31.5,'test');
            //CventMyd_UtilityMethods.getAuditRecord(newCpqAudit.Id,31.5,'test');
            CventMyd_UtilityMethods.getExpectedNumberOfQuoteLineGroups(TestQuote);
            CventMyd_UtilityMethods.getQuoteIdToAllOutyears(new List<SBQQ__Quote__c>{TestQuote});
            CventMyd_UtilityMethods.getQuoteOutyears(TestQuote2,true);
            CventMyd_UtilityMethods.getQuoteOutyears(TestQuote2,false);
            CventMyd_UtilityMethods.updatePrimaryQuoteFieldOnOpportunities(new set<Id>{TestQuote.Id}, True);
            CventMyd_UtilityMethods.recalculateQuotes(new set<Id>{TestQuote.Id},true);
            //CventMyd_UtilityMethods.getExpectedQuoteLineCount(new List<SBQQ__Subscription__c>{newSubscription});
            //CventMyd_UtilityMethods.getProrateMultiplier(Date.newInstance(2018, 03, 03),Date.newInstance(2019, 03, 03));

        Test.stopTest();
 	}   
 	
 	private static testMethod void testMethod1() {
	    //Create Account
	    Account newAccount = new Account(Name = 'Test Account',BillingCountryCode='US',BillingState='AK');
	    insert newAccount;
	    //Create Opportunity
	    Opportunity newOpportunity = new Opportunity(AccountId = newAccount.Id, 
    	    RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CSN-Supplier').getRecordTypeId(), 
    	    Name = 'Test Opportunity', 
    	   // Product = 'CSN',
    	   StageName = 'Legal',
    	    CloseDate = Date.newInstance(2022, 01, 01)
	    );
	    insert newOpportunity;

        
        // Instantiate the Pricebook2 record first, setting the Id
        Pricebook2 standardPricebook = new Pricebook2(
        	Id = Test.getStandardPricebookId(),
        	IsActive = true
        );
        update standardPricebook;
        
        // Re-Query for the Pricebook2 record, for debugging
        standardPricebook = [SELECT IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];

        // Create the Product
        Product2 testProduct = new Product2(
        	Name = 'Test Product', 
        	IsActive = true
        );
        insert testProduct;
        
        // Create the PricebookEntry
        PricebookEntry testPbe = new PricebookEntry(
        	Pricebook2Id = standardPricebook.Id,
        	Product2Id = testProduct.Id,
        	UnitPrice = 100,
        	IsActive = true
        );
        insert testPbe;

        Id recordTypeIdParent = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Parent Contract').getRecordTypeId();
	    Id ChildRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Child Contract').getRecordTypeId();
        
        //Parent Contract to have Parent_Contract_Term_Years__c, Upcoming_Renewal_Type__c, Parent_Contract_Term_Years__c
        Contract ParentCont = new Contract();
        ParentCont.AccountId = newOpportunity.accountId;
        ParentCont.Contract_Term_Years__c = '2';
        ParentCont.Year_2_End_Date__c = newOpportunity.CloseDate;
        ParentCont.RecordTypeId = recordTypeIdParent;
        ParentCont.SBQQ__Opportunity__c = newOpportunity.id;
        ParentCont.EndDate = newOpportunity.CloseDate;
        ParentCont.StartDate = System.today();
        ParentCont.Current_Year__c = 1;
        insert ParentCont;
        
        //Child Contract
        Contract cont = new Contract();
        cont.RecordTypeId = ChildRecordTypeId;
        cont.AccountId = newOpportunity.accountId;
        cont.Parent_Contract__c = ParentCont.id;
        cont.SBQQ__Opportunity__c = newOpportunity.id;
        cont.EndDate = newOpportunity.CloseDate;
        cont.Year_2_End_Date__c = newOpportunity.CloseDate;
        cont.Current_Year__c = 1;
        cont.StartDate = System.today();
        insert cont;
        
        //Create subscription
        SBQQ__Subscription__c newSubscription = new SBQQ__Subscription__c(
            SBQQ__Quantity__c = 11,
            SBQQ__Product__c = testProduct.Id, 
            SBQQ__Account__c = newOpportunity.AccountId, 
            SBQQ__Contract__c = cont.Id
        );
        insert newSubscription;
        
	    test.startTest();
            CventMyd_Settings cS = new CventMyd_Settings();
            //CventMyd_UtilityMethods.getAndSetLegacySubscriptions(new Set<Id>{cont.Id});

        Test.stopTest();
 	}

    private static testMethod void testMethod2() {

        CventMyd_UtilityMethods.queryScheduledJobCount();

        Messaging.SingleEmailMessage singleEmailMessage = CventMyd_UtilityMethods.getSingleEmailMessage(null,'sup dude','hey scrub',null);

        CventMyd_UtilityMethods.sendEmail(singleEmailMessage);

    }

    private static testMethod void testMethod3() {

        Account newAccount = new Account(Name = 'Test Account',BillingCountryCode='US',BillingState='AK');
        insert newAccount;
        //Create Opportunity
        Opportunity newOpportunity = new Opportunity(AccountId = newAccount.Id, 
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CSN-Supplier').getRecordTypeId(), 
            Name = 'Test Opportunity', 
           // Product = 'CSN',
           StageName = 'Legal',
            CloseDate = Date.newInstance(2019, 01, 01)
        );
        insert newOpportunity;

        
        // Instantiate the Pricebook2 record first, setting the Id
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        
        // Re-Query for the Pricebook2 record, for debugging
        standardPricebook = [SELECT IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];

        // Create the Product
        Product2 testProduct = new Product2(
            Name = 'Test Product', 
            IsActive = true
        );
        insert testProduct;
        
        // Create the PricebookEntry
        PricebookEntry testPbe = new PricebookEntry(
            Pricebook2Id = standardPricebook.Id,
            Product2Id = testProduct.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert testPbe;

        Id recordTypeIdParent = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Parent Contract').getRecordTypeId();
        Id ChildRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Child Contract').getRecordTypeId();
        
        //Parent Contract to have Parent_Contract_Term_Years__c, Upcoming_Renewal_Type__c, Parent_Contract_Term_Years__c
        Contract ParentCont = new Contract();
        ParentCont.AccountId = newOpportunity.accountId;
        ParentCont.Contract_Term_Years__c = '2';
        ParentCont.Year_2_End_Date__c = newOpportunity.CloseDate;
        //Parent_Contract_Term_Years__c = 1
        ParentCont.RecordTypeId = recordTypeIdParent;
        ParentCont.SBQQ__Opportunity__c = newOpportunity.id;
        ParentCont.EndDate = newOpportunity.CloseDate;
        ParentCont.Current_Year__c = 1;
        insert ParentCont;
        
        //Child Contract
        Contract cont = new Contract();
        cont.RecordTypeId = ChildRecordTypeId;
        cont.AccountId = newOpportunity.accountId;
        cont.Parent_Contract__c = ParentCont.id;
        cont.SBQQ__Opportunity__c = newOpportunity.id;
        //cont.Upcoming_Renewal_Type__c = 'Contract Renewal';
        cont.EndDate = newOpportunity.CloseDate;
        cont.Year_2_End_Date__c = newOpportunity.CloseDate;
        //cont.Remaining_Master_Term__c = 0;
        cont.Current_Year__c = 1;
        insert cont;

        SBQQ__Subscription__c newSubscription = new SBQQ__Subscription__c(
            SBQQ__Quantity__c = 11,
            SBQQ__Product__c = testProduct.Id, 
            SBQQ__Account__c = newOpportunity.AccountId, 
            SBQQ__Contract__c = cont.Id
        );
        insert newSubscription;        

        Test.startTest();

        CventMyd_UtilityMethods.clearSubscriptionJsonStrings(cont.Id);

        Test.stopTest();

    }

    private static testMethod void testMethod4() {

        CpqAudit__c testAuditRecord = new CpqAudit__c(Name ='testRec',jobsInChain__c = 1);

        insert testAuditRecord;

        Id chainMasterRecordId = testAuditRecord.Id;

        DateTime scheduledFinishDateTime = DateTime.now().addHours(2);

        CventMyd_UtilityMethods.getAuditRecord(chainMasterRecordId,scheduledFinishDateTime,'nice job name');

        CventMyd_UtilityMethods.getAuditRecord(null,scheduledFinishDateTime,'nice job name');

        CventMyd_UtilityMethods.getAuditRecord(chainMasterRecordId,chainMasterRecordId,chainMasterRecordId);

    }

    private static testMethod void testMethod5() {

        String jsonString = '{"qleId":"72573_mnx_68862","quoteName":"Q-374886","preCalculationFieldValueMap":{"SBQQ__Quantity__c":[5],"SBQQ__Discount__c":[0],"Custom_Discount__c":[null],"SBQQ__DistributorDiscount__c":[null],"SBQQ__PartnerDiscount__c":[null],"SBQQ__AdditionalDiscountAmount__c":[null],"Discount_Type__c":["%"],"SBQQ__StartDate__c":[null],"SBQQ__EndDate__c":[null],"SBQQ__PricingMethod__c":["List"]},"calculatedFieldValueMap":{"SBQQ__OriginalPrice__c":[199],"SBQQ__ListPrice__c":[199],"SBQQ__RegularPrice__c":[199],"SBQQ__CustomerPrice__c":[199],"SBQQ__PartnerPrice__c":[199],"SBQQ__NetPrice__c":[199],"Rack_Rate__c":[199],"SBQQ__ProrateMultiplier__c":[1]},"contractedFieldValueMap":{},"clonedFromQleIds":[],"insertOnNextCurrentYear":false,"requiredByQleId":"73607_dss_59373"}';

        createTestData();

        List<SBQQ__Subscription__c> subscriptions = [SELECT Id,SBQQ__PricingMethod__c FROM SBQQ__Subscription__c];

        List<Opportunity> opportunities = [SELECT AccountId,Id FROM Opportunity];
        Map<Id,Id> keyIdToValueId = new Map<Id,Id>();
        SBQQ__Subscription__c subscription = subscriptions[0];
        Opportunity opportunity = opportunities[0];
        keyIdToValueId.put(subscription.Id,opportunity.Id);
        keyIdToValueId.put(opportunity.Id,opportunity.Id);
        try {
            CventMyd_UtilityMethods.getKeyIdsToValueId(keyIdToValueId,opportunity.Id,true);
        }
        catch(Exception e) {
            System.debug('i am expecting an exception here');
        }

        Set<Id> opportunityIds = CventMyd_UtilityMethods.getIdSet((List<SObject>)opportunities);

        CventMyd_ValidationHandler.settings.closedAttachmentSettings.isActive = false;
        CventMyd_UtilityMethods.closeWinOpportunity(opportunities[0].Id);

        CventMyd_UtilityMethods.getParentIdToChildrenIdSet(opportunities,'AccountId');

        Set<Id> quoteIds = CventMyd_UtilityMethods.getIdSet((List<SObject>)[SELECT Id FROM SBQQ__Quote__c]);

        Test.startTest();

        CventMyd_UtilityMethods.recalculateQuotes(quoteIds,true);
        CventMyd_UtilityMethods.getIntegerSetBetween(1,2);
        CventMyd_UtilityMethods.getIntegerListBetween(1,2);

        Test.stopTest();

    }

    public static testMethod void testMethod6() {
        
        DateTime dateTime0 = DateTime.now().addHours(-1);

        DateTime dateTime1 = DateTime.now().addHours(11);
        
        CventMyd_UtilityMethods.getHoursBetweenDateTimes(dateTime0,dateTime1);

    }

    public static void createTestData() {

        //Create Account
        Account newAccount = new Account(Name = 'Test Account',BillingCountryCode='US',BillingState='AK');
        insert newAccount;
        //Create Opportunity
        Opportunity newOpportunity = new Opportunity(AccountId = newAccount.Id, 
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CSN-Supplier').getRecordTypeId(), 
            Name = 'Test Opportunity', 
           // Product = 'CSN',
           StageName = 'Legal',
            CloseDate = Date.newInstance(2019, 01, 01)
        );
        insert newOpportunity;

        updateOpportunityAddresses(newOpportunity.Id,newAccount.Id);
        
        // Instantiate the Pricebook2 record first, setting the Id
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        
        // Re-Query for the Pricebook2 record, for debugging
        standardPricebook = [SELECT IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];

        // Create the Product
        Product2 testProduct = new Product2(
            Name = 'Test Product', 
            IsActive = true
        );
        insert testProduct;
        
        // Create the PricebookEntry
        PricebookEntry testPbe = new PricebookEntry(
            Pricebook2Id = standardPricebook.Id,
            Product2Id = testProduct.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert testPbe;

        Id recordTypeIdParent = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Parent Contract').getRecordTypeId();
        Id ChildRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Child Contract').getRecordTypeId();
        
        //Parent Contract to have Parent_Contract_Term_Years__c, Upcoming_Renewal_Type__c, Parent_Contract_Term_Years__c
        Contract ParentCont = new Contract();
        ParentCont.AccountId = newOpportunity.accountId;
        ParentCont.Contract_Term_Years__c = '2';
        ParentCont.Year_2_End_Date__c = newOpportunity.CloseDate;
        //Parent_Contract_Term_Years__c = 1
        ParentCont.RecordTypeId = recordTypeIdParent;
        ParentCont.SBQQ__Opportunity__c = newOpportunity.id;
        ParentCont.EndDate = newOpportunity.CloseDate;
        ParentCont.Current_Year__c = 1;
        insert ParentCont;
        
        //Child Contract
        Contract cont = new Contract();
        cont.RecordTypeId = ChildRecordTypeId;
        cont.AccountId = newOpportunity.accountId;
        cont.Parent_Contract__c = ParentCont.id;
        cont.SBQQ__Opportunity__c = newOpportunity.id;
        //cont.Upcoming_Renewal_Type__c = 'Contract Renewal';
        cont.EndDate = newOpportunity.CloseDate;
        cont.Year_2_End_Date__c = newOpportunity.CloseDate;
        //cont.Remaining_Master_Term__c = 0;
        cont.Current_Year__c = 1;
        insert cont;
        
        // Create subscription
   
        SBQQ__Subscription__c newSubscription = new SBQQ__Subscription__c(
            SBQQ__Quantity__c = 11,
            SBQQ__Product__c = testProduct.Id, 
            SBQQ__Account__c = newOpportunity.AccountId, 
            SBQQ__PricingMethod__c = 'Slab',
            SBQQ__Contract__c = cont.Id
        );
        insert newSubscription;
        
        SBQQ__Subscription__c newSubscription1 = new SBQQ__Subscription__c(
            SBQQ__Quantity__c = 11,
            SBQQ__Product__c = testProduct.Id, 
            SBQQ__Account__c = newOpportunity.AccountId, 
            SBQQ__Contract__c = cont.Id,
            SBQQ__PricingMethod__c = 'Slab',
            SBQQ__RevisedSubscription__c = newSubscription.Id
        );
        insert newSubscription1;

        List<SBQQ__Quote__c> listNewQuote = new List<SBQQ__Quote__c>();
        SBQQ__Quote__c TestQuote = new SBQQ__Quote__c();
        TestQuote.SBQQ__Opportunity2__c = newOpportunity.id;
        TestQuote.Contract_Term_Years__c = '2';
        TestQuote.SBQQ__Type__c = 'Quote';
        TestQuote.Current_Year__c = 1;
        TestQuote.SBQQ__EndDate__c = System.today();
        TestQuote.Contract_Executed__c = true;
        insert TestQuote;        

    }

    public static testMethod void createTestData0() {

        CventMyd_UtilityMethods.createTestAccounts(3);

        String accountIdString = CventMyd_UtilityMethods.getIdString([SELECT Id FROM Account],';');

        CventMyd_UtilityMethods.createTestOpportunities(accountIdString, false);

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

    private static void updateOpportunityAddresses(Id opportunityId, Id accountId) {

        Id shippingAddressId = createShippingAddress(accountId).Id;  
        Id billingAddressId = createBillingAddress(accountId).Id;
        Opportunity opportunity = new Opportunity(Id = opportunityId, AccountId = accountId);
        opportunity.Bill_To_Address__c = billingAddressId;
        opportunity.Ship_To_Address__c = shippingAddressId;
        update opportunity;     

    }

    public static testMethod void testMethod7() {

        String jsonString = '{"requiredBySubscriptionIdString":null,"requiredByQleId":null,"quoteName":null,"qleId":"29068_ENU_32153","preCalculationFieldValueMap":{"SBQQ__Quantity__c":[1,2],"SBQQ__Discount__c":[null],"Custom_Discount__c":[null],"SBQQ__DistributorDiscount__c":[null],"SBQQ__PartnerDiscount__c":[null],"SBQQ__AdditionalDiscountAmount__c":[null],"Discount_Type__c":[null],"SBQQ__StartDate__c":["2017-10-01"],"SBQQ__EndDate__c":[null],"SBQQ__PricingMethod__c":["List"],"Conversion_Rate__c":[1]},"nextYearQleId":null,"legacySubscriptionUpdated":null,"insertOnNextCurrentYear":false,"insertedWithApex":true,"deleteThisLine":null,"contractedFieldValueMap":{},"clonedFromQleIds":["29068_ENU_32153"],"calculatedFieldValueMap":{"SBQQ__OriginalPrice__c":[1000],"SBQQ__ListPrice__c":[1000],"SBQQ__RegularPrice__c":[0],"SBQQ__CustomerPrice__c":[0],"SBQQ__PartnerPrice__c":[0],"SBQQ__NetPrice__c":[0],"Rack_Rate__c":[1000],"SBQQ__ProrateMultiplier__c":[1]}}';
        CventMyd_UtilityMethods.replaceJsonStringKeyValue(jsonString,'SBQQ__Quantity__c','2',0);
        CventMyd_UtilityMethods.replaceJsonStringKeyValue(jsonString,'SBQQ__Quantity__c','2',1);

    }

}