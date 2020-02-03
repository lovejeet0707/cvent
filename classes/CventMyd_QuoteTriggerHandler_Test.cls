@isTest
private class CventMyd_QuoteTriggerHandler_Test {

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

    //Uses Quote type Renewal and Contract = Contract Renewal
    private static testMethod void BeforeInsert_test1() {
        
        Id RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Parent Contract').getRecordTypeId();
        Id ChildRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Child Contract').getRecordTypeId();
       
        Account TestAccount = new Account();
        testAccount.FirstName = 'First friggin';
        testAccount.LastName = 'Last friggin';
        TestAccount.BillingState='NY';
        TestAccount.BillingCountryCode='US'; 
        testAccount.BillingStateCode='NY';        
        testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('GDPR').getRecordTypeId();
        insert TestAccount;  

        //Id shippingAddressId = createShippingAddress(TestAccount.Id).Id;  
        //Id billingAddressId = createBillingAddress(TestAccount.Id).Id;
        
        Opportunity opp = TestUtil.createOpportunity('Test Opp', 'Renewal', 'Closed Won');
        opp.CurrencyIsoCode  = 'USD';
        opp.RenewalDate__c  = Date.today();
        opp.AccountId = TestAccount.Id;
        insert opp;

        updateOpportunityAddresses(opp.Id,TestAccount.Id);
        
        /*
        Account TestAccount = new Account();
        TestAccount.Name = 'Test Account';
        insert TestAccount;
        */
        
        //Parent Contract to have Parent_Contract_Term_Years__c, Upcoming_Renewal_Type__c, Parent_Contract_Term_Years__c
        Contract ParentCont = new Contract();
        ParentCont.AccountId = TestAccount.id;
        ParentCont.Contract_Term_Years__c = '1';
        ParentCont.RecordTypeId = RecordTypeId;
        ParentCont.SBQQ__Opportunity__c = opp.id;
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
        insert cont;
        
        opp.SBQQ__RenewedContract__c = cont.id;
        update opp;
        
        //Normal Quote
        //Try inserting a Quote SBQQ__Type__c == Renewal
        SBQQ__Quote__c TestQuote = new SBQQ__Quote__c();
        TestQuote.SBQQ__Opportunity2__c = opp.id;
        TestQuote.Contract_Term_Years__c = '2';
        TestQuote.SBQQ__Type__c = 'Renewal';
        TestQuote.Current_Year__c = 1;
        TestQuote.Contract_Term_Years__c = '2';
        TestQuote.SBQQ__EndDate__c = System.today();
        TestQuote.Contract_Executed__c = true;
        
        insert TestQuote;
        TestQuote.Certification_SKU__c = 5;
        update TestQuote;
    }

    //Uses Quote type Renewal and Contract = MYD Renewal
    private static testMethod void BeforeInsert_test2() {
        
        Id RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Parent Contract').getRecordTypeId();
        Id ChildRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Child Contract').getRecordTypeId();
        
        Opportunity opp = TestUtil.createOpportunity('Test Opp', 'Renewal', 'Closed Won');
        opp.CurrencyIsoCode  = 'USD';
        insert opp;
        
        /*
        Account TestAccount = TestUtil.createAccount('Test Account', 'Biz A/c');
        insert TestAccount;
        */
        
        Account TestAccount = new Account();
        testAccount.FirstName = 'First friggin';
        testAccount.LastName = 'Last friggin';
        testAccount.BillingState='NY';
        testAccount.BillingCountryCode='US';  
        testAccount.BillingStateCode='NY';       
        testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('GDPR').getRecordTypeId();
        testAccount.EBS_Account_ID__c = 'asdfasdfdsadasf';
        insert TestAccount; 

        updateOpportunityAddresses(opp.Id,TestAccount.Id);
        
        //Parent Contract to have Parent_Contract_Term_Years__c, Upcoming_Renewal_Type__c, Parent_Contract_Term_Years__c
        Contract ParentCont = new Contract();
        ParentCont.AccountId = TestAccount.id;
        ParentCont.Contract_Term_Years__c = '5';
        ParentCont.RecordTypeId = RecordTypeId;
        ParentCont.SBQQ__Opportunity__c = opp.id;
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
        insert cont;
        
        opp.SBQQ__RenewedContract__c = cont.id;
        update opp;
        
        //Normal Quote
        //Try inserting a Quote SBQQ__Type__c == Renewal
        SBQQ__Quote__c TestQuote = new SBQQ__Quote__c();
        TestQuote.SBQQ__Opportunity2__c = opp.id;
        TestQuote.Contract_Term_Years__c = '2';
        TestQuote.SBQQ__Type__c = 'Renewal';
        TestQuote.Current_Year__c = 1;
        TestQuote.Contract_Term_Years__c = '2';
        TestQuote.SBQQ__EndDate__c = System.today();
        TestQuote.Contract_Executed__c = true;
        insert TestQuote;
        
    }    

    //Quote type Amendment and Contract = 
    private static testMethod void BeforeInsert_test3() {
        
        Id RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Parent Contract').getRecordTypeId();
        Id ChildRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Child Contract').getRecordTypeId();

        Account TestAccount = new Account();
        testAccount.FirstName = 'First friggin';
        testAccount.LastName = 'Last friggin';
        testAccount.BillingState='NY';
        testAccount.BillingCountryCode='US';     
        testAccount.BillingStateCode='NY';    
        testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('GDPR').getRecordTypeId();
        testAccount.EBS_Account_ID__c = 'asdfasdfdsadasf';
        insert TestAccount;         
        
        Opportunity opp = TestUtil.createOpportunity('Test Opp', 'Renewal', 'Closed Won');
        opp.CurrencyIsoCode  = 'USD';
        insert opp;

        updateOpportunityAddresses(opp.Id,TestAccount.Id);
        
        Address__c addr = new Address__c();
        addr.Address__c = 'Test Address';
        addr.Type__c = 'Billing';
        insert addr;
        
        Opportunity opp2 = TestUtil.createOpportunity('Test Opp', 'Renewal', 'Closed Won');
        opp2.CurrencyIsoCode  = 'USD';
        opp2.Bill_To_Address__c = addr.id;
        insert opp2;

        updateOpportunityAddresses(opp2.Id,TestAccount.Id);
        
        //Parent Contract to have Parent_Contract_Term_Years__c, Upcoming_Renewal_Type__c, Parent_Contract_Term_Years__c
        Contract ParentCont = new Contract();
        ParentCont.AccountId = TestAccount.id;
        ParentCont.Contract_Term_Years__c = '1';
        ParentCont.RecordTypeId = RecordTypeId;
        ParentCont.SBQQ__Opportunity__c = opp.id;
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
        cont.SBQQ__Opportunity__c = opp2.id;
        insert cont;
        
        opp.SBQQ__AmendedContract__c = cont.id;
        update opp;
        
        //Normal Quote
        //Try inserting a Quote SBQQ__Type__c == Renewal

        CventMyd_ContractAmendmentController.contractIdsBeingAmended.add(cont.Id);

        SBQQ__Quote__c TestQuote = new SBQQ__Quote__c();
        TestQuote.SBQQ__Opportunity2__c = opp.id;
        TestQuote.Contract_Term_Years__c = '2';
        TestQuote.SBQQ__Type__c = 'Amendment';
        TestQuote.Current_Year__c = 1;
        TestQuote.Contract_Term_Years__c = '2';
        TestQuote.Contract_Executed__c = true;
        
        //Date newDate = System.today().addYears(1);
        
        TestQuote.SBQQ__StartDate__c = System.today().addYears(-1); //System.today().year() - 1;
        TestQuote.SBQQ__EndDate__c = System.today();
        insert TestQuote;
        
    }

    private static testMethod void testBatch() {
        
        Id RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Parent Contract').getRecordTypeId();
        
        Account TestAccount = new Account();
        testAccount.FirstName = 'First friggin';
        testAccount.LastName = 'Last friggin';
        testAccount.BillingState='NY';
        testAccount.BillingCountryCode='US'; 
        testAccount.BillingStateCode='NY';        
        testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('GDPR').getRecordTypeId();
        testAccount.EBS_Account_ID__c = 'asdfasdfdsadasf';
        insert TestAccount; 
        
        //Insert Opp
        Opportunity opp = TestUtil.createOpportunity('Test Opp', 'Renewal', 'Closed Won');
        opp.CurrencyIsoCode  = 'USD';
        insert opp;

        updateOpportunityAddresses(opp.Id,TestAccount.Id);
    
        //Insert Quote
        SBQQ__Quote__c TestQuote = new SBQQ__Quote__c();
        TestQuote.SBQQ__Opportunity2__c = opp.id;
        TestQuote.Contract_Term_Years__c = '2';
        TestQuote.SBQQ__Type__c = 'Renewal';
        TestQuote.Current_Year__c = 2;
        TestQuote.Contract_Executed__c = true;
        TestQuote.SBQQ__StartDate__c = System.today().addYears(-1);
        TestQuote.SBQQ__EndDate__c = System.today();
        TestQuote.createdFromLegacyContract__c = true;
        //TestQuote.Multiple_Years_Commitment__c = true;
        insert TestQuote;
        
        //Quote Line Group
        SBQQ__QuoteLineGroup__c qlGroup = new SBQQ__QuoteLineGroup__c();
        qlGroup.Name = 'Group 1';
        qlGroup.SBQQ__Number__c = 1;
        qlGroup.SBQQ__ListTotal__c = 10;
        qlGroup.SBQQ__NetTotal__c = 100;
        qlGroup.SBQQ__CustomerTotal__c = 1000;
        qlGroup.SBQQ__Quote__c = TestQuote.id;
        insert qlGroup;
        
        TestQuote.Multiple_Years_Commitment__c = true;
        update TestQuote;
        
        //Parent Contract to have Parent_Contract_Term_Years__c, Upcoming_Renewal_Type__c, Parent_Contract_Term_Years__c
        Contract ParentCont = new Contract();
        ParentCont.AccountId = TestAccount.id;
        ParentCont.Contract_Term_Years__c = '1';
        ParentCont.RecordTypeId = RecordTypeId;
        ParentCont.SBQQ__Opportunity__c = opp.id;
        insert ParentCont;
        
        //Product
        Product2 product1 = new Product2();
        product1.Name = 'Product 1';
        product1.Contract_Output_Grouping__c = 'Bundle Advertisements';
        insert product1;
        
        //Insert Subscription
        SBQQ__Subscription__c sub = new SBQQ__Subscription__c();
        sub.SBQQ__Product__c = product1.id;
        sub.SBQQ__Account__c = TestAccount.id;
        sub.SBQQ__Contract__c = ParentCont.id;
        sub.SBQQ__Quantity__c = 1;
        insert sub;
        
        //Insert Quote Line
        SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c();
        ql1.SBQQ__Quantity__c = 1;
        ql1.SBQQ__Product__c = product1.Id;
        ql1.SBQQ__ListPrice__c = 10;
        ql1.SBQQ__NetPrice__c = 10;
        ql1.Rack_Rate__c = 10;
        ql1.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        ql1.SBQQ__Number__c = 1;
        ql1.SBQQ__Group__c = qlGroup.id;
        ql1.SBQQ__Quote__c = TestQuote.Id;
        ql1.Notes__c = 'abc';
        ql1.SBQQ__UpgradedSubscription__c = sub.id;
        insert ql1;
        
        //Quote2
        SBQQ__Quote__c TestQuote2 = new SBQQ__Quote__c();
        TestQuote2.SBQQ__Opportunity2__c = opp.id;
        TestQuote2.Contract_Term_Years__c = '2';
        TestQuote2.Current_Year__c = 2;
        TestQuote2.SBQQ__Type__c = 'Renewal';
        TestQuote2.Contract_Executed__c = true;
        TestQuote2.SBQQ__StartDate__c = System.today().addYears(-1);
        TestQuote2.SBQQ__EndDate__c = System.today();
        //TestQuote2.Multiple_Years_Commitment__c = true;
        TestQuote2.previousQuote__c = TestQuote.id;
        insert TestQuote2;
        
        TestQuote2.Multiple_Years_Commitment__c = true;
        update TestQuote2;
        
        //Insert Quote Line2
        SBQQ__QuoteLine__c ql2 = new SBQQ__QuoteLine__c();
        ql2.SBQQ__Quantity__c = 1;
        ql2.SBQQ__Product__c = product1.Id;
        ql2.SBQQ__ListPrice__c = 10;
        ql2.SBQQ__NetPrice__c = 10;
        ql2.Rack_Rate__c = 10;
        ql2.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        ql2.SBQQ__Number__c = 1;
        ql2.SBQQ__Group__c = qlGroup.id;
        ql2.SBQQ__Quote__c = TestQuote2.Id;
        ql2.Notes__c = 'abc';
        ql2.SBQQ__UpgradedSubscription__c = sub.id;
        insert ql2;

        //Insert CPQ Audit record
        CpqAudit__c testAudit = new CpqAudit__c();
        testAudit.Name = 'Test Audit';
        insert testAudit;
        
        Set<Id> quoteIdsBatch = new Set<Id>();
        quoteIdsBatch.add(TestQuote.id);
        quoteIdsBatch.add(TestQuote2.id);
        
        //String JobName = 'Test Batch Quote';
        
        //Test.startTest();
        
        //Run batch
        CventMyd_QuoteSchedulable BatchRun = new CventMyd_QuoteSchedulable(quoteIdsBatch, 'Test Batch Run', testAudit.id);
        //CventMyd_QuoteSchedulable renewalQuoteSchedulable = new CventMyd_QuoteSchedulable(renewalQuoteMap.keySet(),renewalJobName,renewalJobAuditRecord.Id);
        //ID batchprocessid = Database.executeBatch(BatchRun,200);
        String sch = '0 0 23 * * ?';
        system.schedule('Test Run', sch, BatchRun);
        
        //Test.stopTest();
    
    }  

    public testmethod static void testContractedValidations() {
        User instUsr = TestUtil.CreateDeploymentUser();
        system.RunAs(instUsr){        
            System.debug('testContractedValidations execution is starting....');
            Account testAccount =TestUtil.createAccount('Test Account','Biz_Ac');
            testAccount.Supplier_Type__c = 'Venue';
            testAccount.Venue_Type__c = 'CVB';
            testAccount.BillingState='NY';
            testAccount.BillingCountryCode='US'; 
            testAccount.BillingStateCode='NY';            
            insert testAccount;
            Opportunity instOpp=TestUtil.createOpportunity('Test Opp','Event','Qualified');
            instOpp.StageName ='Closed Won';
            instOpp.Deal_Year__c ='1';
            instOpp.NBB_Renewal__c = 'NBB';
            instOpp.Parent_Upsell__c = 'Primary';
            instOpp.CloseDate = system.today().addmonths(12);
            // instOpp.Web_Design_Support_Minutes_Purchased__c =0;
            instOpp.Contract_Implemented__c = false;
            instOpp.ContractReceived__c = system.today();
            instOpp.Product__c ='TicketMob';
            instOpp.MYD_Deal__c='First Year';
            instOpp.pricebook2id=Test.getStandardPricebookID();
            Contact testContact =TestUtil.createContact(testAccount.id);
            instOpp.Contact_Associated__c=testContact.id; 
            //instopp.SBQQ__PrimaryQuote__c ='';
            //instopp.SBQQ__RenewedContract__c=con1.Id;
            insert instOpp;
            SBQQ__Quote__c sbqq = new SBQQ__Quote__c();
            sbqq.SBQQ__Opportunity2__c = instopp.id;
            sbqq.Current_Year__c = 4;
            sbqq.SBQQ__StartDate__c = Date.today();
            sbqq.SBQQ__EndDate__c = sbqq.SBQQ__StartDate__c.addYears(1);
            sbqq.Contract_Term_Years__c = '5';
            //sbqq.SBQQ__RenewedContract__c='';
            insert sbqq;
            instopp.SBQQ__PrimaryQuote__c=sbqq.id;
            sbqq.Contract_Executed__c = true;
            //instopp.SBQQ__RenewedContract__c=conId;
            Id RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Parent Contract').getRecordTypeId();       
            Id ChildRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Child Contract').getRecordTypeId();          
            Contract ParentCont = new Contract();
            ParentCont.AccountId = TestAccount.id;
            ParentCont.Contract_Term_Years__c = '5';
            ParentCont.RecordTypeId = RecordTypeId;
            ParentCont.SBQQ__Opportunity__c = instOpp.id;
            //ParentCont.Is_Legacy__c = true;
            ParentCont.SBQQ__RenewalQuoted__c = false;
            ParentCont.Failed_Auto_Renew__c = false;
            ParentCont.Renewal_Creation_Date__c = System.today().addYears(1);
            insert ParentCont;
            Product2 product1 = new Product2();
            product1.Name = 'Product 1';
            product1.Contract_Output_Grouping__c = 'Bundle Advertisements';
            product1.Revenue_Type__c = 'Annual Recurring    ';
            insert product1;       
            Contract cont = new Contract();
            cont.RecordTypeId = ChildRecordTypeId;
            cont.AccountId = TestAccount.id;
            System.debug('ParentContract: ' + ParentCont);
            cont.Parent_Contract__c = ParentCont.id;
            cont.SBQQ__Opportunity__c = instOpp.Id;
            //cont.Upcoming_Renewal_Type__c = 'Contract Renewal';
            cont.EndDate = sbqq.SBQQ__EndDate__c;
            //cont.Remaining_Master_Term__c = 0;
            cont.Current_Year__c = 4;
            //cont.Is_Legacy__c = true;
            cont.SBQQ__RenewalQuoted__c = false;
            cont.Failed_Auto_Renew__c = false;
            cont.Multiple_years_Commitment__C = false;
            cont.Renewal_Creation_Date__c = Date.newInstance(2018,9,5); //System.today().addYears(1);
            cont.SBQQ__RenewalQuoted__c = false;          
            insert cont;
            sbqq.SBQQ__MasterContract__c = cont.Id;
            sbqq.SBQQ__MasterContract__r = cont;
            update sbqq;
            instOpp.SBQQ__AmendedContract__c = cont.Id;
            instOpp.SBQQ__Contracted__c = true;  
            try {
                update instOpp;
            }
            catch(Exception e0) {
                Boolean containsTypeError = e0.getMessage().contains('cannot contract an opportunity that has been used as both a renewal and an amendment');
                System.assert(containsTypeError);
                sbqq.SBQQ__Type__c = 'Amendment';
                Id quoteId = sbqq.Id;
                String jsonString = [SELECT jsonString__c FROM SBQQ__Quote__c where Id =: quoteId].jsonString__c;
                CventMyd_QuoteObject quoteObject = CventMyd_UtilityMethods.getQuoteObject(jsonString);
                quoteObject.outyearMap = new Map<Integer,CventMyd_Outyear>();
                sbqq.jsonString__c = JSON.serialize(quoteObject);
                System.debug('new jsonstring 0: ' + sbqq.jsonString__c);
                CventMyd_ValidationHandler.settings.ruleNameToIsActive.put('Quote_Missing_Outyears',false);
                update sbqq;
                System.debug('new jsonstring 1: ' + sbqq.jsonString__c);
                CventMyd_ValidationHandler.validatedOpportunityIds = new Set<Id>();
                CventMyd_ValidationHandler.settings.ruleNameToIsActive.put('Quote_Missing_Outyears',true);
                instOpp.SBQQ__Contracted__c = true;
                System.debug('now proceeding to contract the opportunity again 0...');
                try {
                    update instOpp;
                }
                catch(Exception e1) {
                    Boolean containsOutyearError = e1.getMessage().contains('is missing outyear dates for year(s)');
                    System.assert(containsOutyearError);
                    sbqq.jsonString__c = jsonString;
                    update sbqq;
                    CventMyd_ValidationHandler.validatedOpportunityIds = new Set<Id>();
                    instOpp.SBQQ__Contracted__c = true;
                    System.debug('now proceeding to contract the opportunity again 1...');    
                    update instOpp;              
                }
            }

            CventMyd_ValidationHandler.getErrorStrings(sbqq);
            ParentCont.Contract_Term_Years__c = '3';  
            Boolean containsInvalidTermError;
            try {
                update parentCont;
            }          
            catch (Exception e) {
                containsInvalidTermError = e.getMessage().contains('has a current year less than its term');          
            }
            System.assert(containsInvalidTermError);
            //Insert Quote Line
            SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c();
            ql1.SBQQ__Quantity__c = 1;
            ql1.SBQQ__Product__c = product1.Id;
            ql1.SBQQ__ListPrice__c = 10;
            ql1.SBQQ__NetPrice__c = 10;
            ql1.Rack_Rate__c = 10;
            ql1.SBQQ__SubscriptionPricing__c = 'Fixed Price';
            ql1.SBQQ__Number__c = 1;
            ql1.SBQQ__Quote__c = sbqq.Id;
            ql1.Notes__c = 'abc';
            insert ql1;

            CventMyd_ValidationHandler.getErrors(ql1,false);        
            CventMyd_ValidationHandler.getErrors(ql1,true);
            
        }

    }        

}