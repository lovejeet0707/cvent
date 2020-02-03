@isTest

private class ContractTrgHelperClsTest {
    
    public static testMethod void testMethod0() {

        Id RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Parent Contract').getRecordTypeId();       

        Id ChildRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Child Contract').getRecordTypeId();  

        Account TestAccount = new Account();
        TestAccount.Name = 'Test Account' + String.valueOf(Math.random());
        TestAccount.BillingCountryCode='US';
        TestAccount.BillingState='AK';
        insert TestAccount;            

        Opportunity opp = TestUtil.createOpportunity('Test Opp', 'Renewal', 'Closed Won');
        opp.CurrencyIsoCode  = 'USD';
        opp.RenewalDate__c = Date.today();
        insert opp;
        updateOpportunityAddresses(opp.Id,TestAccount.Id);

        Contract ParentCont = new Contract();
        ParentCont.AccountId = TestAccount.id;
        ParentCont.Contract_Term_Years__c = '5';
        ParentCont.RecordTypeId = RecordTypeId;
        ParentCont.SBQQ__Opportunity__c = opp.id;
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
        cont.Parent_Contract__c = ParentCont.id;
        //cont.Upcoming_Renewal_Type__c = 'Contract Renewal';
        cont.EndDate = System.today();
        //cont.Remaining_Master_Term__c = 0;
        cont.Current_Year__c = 1;
        //cont.Is_Legacy__c = true;
        cont.SBQQ__RenewalQuoted__c = false;
        cont.Failed_Auto_Renew__c = false;
        cont.Multiple_years_Commitment__c = false;
        cont.Renewal_Creation_Date__c = Date.newInstance(2018,9,5); //System.today().addYears(1);
        cont.SBQQ__RenewalQuoted__c = false;
        
        insert cont;

        SBQQ__Subscription__c sub = new SBQQ__Subscription__c();
        sub.SBQQ__Product__c = product1.id;
        sub.SBQQ__Account__c = TestAccount.id;
        sub.SBQQ__Contract__c = cont.id;
        sub.SBQQ__Quantity__c = 1;    

        insert sub;       

        Test.setCreatedDate(cont.Id,DateTime.newinstance(2015,9,5));

        cont.SBQQ__RenewalQuoted__c = true;

        Id contId = cont.Id ;

        Test.startTest();

        cont = [select parent_contract_term_years__c from contract where Id =: contId];

        update cont;

        Map<Id,Date> accountIdToDate = new Map<Id,Date>();

        accountIdToDate.put(TestAccount.Id,Date.today());

        ContractTrgHelperCls.updateEndDatesOnAccounts(accountIdToDate);

        try {

            ContractTrgHelperCls.throwRenewalException(cont.Id,true);

        }

        catch (Exception e) {



        }

        SBQQ__Quote__c TestQuote = new SBQQ__Quote__c();
        TestQuote.SBQQ__Opportunity2__c = opp.id;
        TestQuote.Contract_Term_Years__c = '5';
        TestQuote.SBQQ__Type__c = 'Quote';
        TestQuote.Current_Year__c = 1;
        TestQuote.Contract_Executed__c = true;
        TestQuote.SBQQ__StartDate__c = System.today().addYears(-1);
        TestQuote.SBQQ__EndDate__c = System.today();
        TestQuote.createdFromLegacyContract__c = true;
        TestQuote.Multiple_years_Commitment__c = false;
        TestQuote.SBQQ__MasterContract__c = cont.Id;
        insert TestQuote;      

        TestQuote.SBQQ__Type__c = 'Amendment';
        update TestQuote;

        CventMyd_Settings.contractingInForeground = true;
        ContractTrgHelperCls.childContractIdsInserted = new Set<Id>();
        ContractTrgHelperCls.opportunityIdsContracted.add(opp.Id);
        SBQQ.TriggerControl.disable();
        CventMyd_Settings.mydTriggersAreActive = false;
        opp.SBQQ__AmendedContract__c = cont.Id;
        opp.SBQQ__RenewedContract__c = null;
        opp.SBQQ__Contracted__c = true;
        opp.SBQQ__PrimaryQuote__c = TestQuote.Id;
        update opp;
        SBQQ.TriggerControl.enable();
        CventMyd_Settings.mydTriggersAreActive = true;
        System.debug('getting ready to try something....: ');
        update cont;

        Test.stopTest();

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

    public static testMethod void testMethod1() {

        Opportunity opp = TestUtil.createOpportunity('Test Opp', 'Renewal', 'Closed Won');

        opp.CurrencyIsoCode  = 'USD';

        opp.contractedDateTime__c = DateTime.now().addMinutes(-2);

        insert opp; 

        ContractTrgHelperCls.opportunityIdsContracted = new Set<Id>{opp.Id};

    }

    public static testMethod void testMethod2() {

        Opportunity opp = TestUtil.createOpportunity('Test Opp', 'Renewal', 'Closed Won');

        opp.CurrencyIsoCode  = 'USD';

        opp.contractedDateTime__c = DateTime.now().addMinutes(-2);

        insert opp; 

        SBQQ__Quote__c testQuote = createQuote();

        Set<Id> quoteIds = new Set<Id>{testQuote.Id};

        scheduleSomeJobs(quoteIds);

        ContractTrgHelperCls.opportunityIdsContracted = new Set<Id>{opp.Id};   

    }

    public static testMethod void testMethod3() {

        Id RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Parent Contract').getRecordTypeId();       

        Id ChildRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Child Contract').getRecordTypeId();    

        Account TestAccount = new Account();
        TestAccount.Name = 'Test Account' + String.valueOf(Math.random());
        TestAccount.BillingState='AK';
        TestAccount.BillingCountryCode='US';
        insert TestAccount;           

        Opportunity opp = TestUtil.createOpportunity('Test Opp', 'Renewal', 'Closed Won');
        opp.CurrencyIsoCode  = 'USD';
        insert opp;   

        updateOpportunityAddresses(opp.Id,TestAccount.Id);      

        Contract ParentCont = new Contract();
        ParentCont.AccountId = TestAccount.id;
        ParentCont.Contract_Term_Years__c = '5';
        ParentCont.RecordTypeId = RecordTypeId;
        ParentCont.SBQQ__Opportunity__c = opp.id;
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
        cont.Parent_Contract__c = ParentCont.id;
        //cont.Upcoming_Renewal_Type__c = 'Contract Renewal';
        cont.EndDate = System.today();
        cont.StartDate = System.today().addMonths(-12);
        //cont.Remaining_Master_Term__c = 0;
        cont.Current_Year__c = 1;
        //cont.Is_Legacy__c = true;
        cont.SBQQ__RenewalQuoted__c = false;
        cont.Failed_Auto_Renew__c = false;
        cont.Multiple_years_Commitment__C = true;
        cont.Renewal_Creation_Date__c = Date.newInstance(2018,9,5); //System.today().addYears(1);
        cont.SBQQ__RenewalQuoted__c = false;
        
        insert cont;

        SBQQ__Subscription__c sub = new SBQQ__Subscription__c();
        sub.SBQQ__Product__c = product1.id;
        sub.SBQQ__Account__c = TestAccount.id;
        sub.SBQQ__Contract__c = cont.id;
        sub.SBQQ__Quantity__c = 1;    

        insert sub;       

        Test.setCreatedDate(cont.Id,DateTime.newinstance(2015,9,5));

        System.debug('in test method, is renewal quoted checked: ' + cont.SBQQ__RenewalQuoted__c);

        Id contId = cont.Id ;

        cont = [select parent_contract_term_years__c from contract where Id =: contId];

        System.debug('contract Parent_Contract_Term_Years__c: ' + cont.Parent_Contract_Term_Years__c);

        cont.SBQQ__RenewalQuoted__c = true;

        update cont;

    }

    public static SBQQ__Quote__c createQuote() {

        Opportunity opp = TestUtil.createOpportunity('Test Opp', 'Renewal', 'Closed Won');
        opp.CurrencyIsoCode  = 'USD';
        insert opp;     

        SBQQ__Quote__c TestQuote = new SBQQ__Quote__c();
        TestQuote.SBQQ__Opportunity2__c = opp.id;
        TestQuote.Contract_Term_Years__c = '2';
        TestQuote.SBQQ__Type__c = 'Amendment';
        TestQuote.Current_Year__c = 2;
        TestQuote.Contract_Executed__c = true;
        TestQuote.SBQQ__StartDate__c = System.today().addYears(-1);
        TestQuote.SBQQ__EndDate__c = System.today();
        TestQuote.createdFromLegacyContract__c = true;
        //TestQuote.Multiple_Years_Commitment__c = true;
        TestQuote.statusCheckCount__c = 0;
        insert TestQuote;

        return TestQuote;

    }   

    public static void scheduleSomeJobs(Set<Id> quoteIds) {

        Decimal minutesBetweenJobs = .2;

        Integer numberOfJobs = 81;

        List<Integer> secondsBeforeJobs = new List<Integer>();

        for(Integer i = 1; i <= numberOfJobs; i++) {

            Integer secondsBeforeThisJob = (Integer) ( (Decimal)i * 60.00 * minutesBetweenJobs );
            
            DateTime dateTimeForThisJob = DateTime.now().addSeconds(secondsBeforeThisJob);
            
            String cronString = CventMyd_UtilityMethods.getCronString(secondsBeforeThisJob);
            
            String dateTimeString = CventMyd_UtilityMethods.getFormattedDateTimeString(dateTimeForThisJob,true,false);

            String jobName = 'Dummy Schedulable Job @ ' + dateTimeString;

            CventMyd_DeleteGhostQuotes dummySchedulableClass = new CventMyd_DeleteGhostQuotes(quoteIds,jobName);
            
            System.schedule(jobName,cronString,dummySchedulableClass);
            
        }  

    }

    public static testMethod void testMethod4() {

        Id ParentRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Parent Contract').getRecordTypeId();
        Id ChildRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Child Contract').getRecordTypeId();

        String jsonString = '{"qleId":"49186_dvm_64921","quoteName":"Q-367375","preCalculationFieldValueMap":{"SBQQ__Quantity__c":[1,1],"SBQQ__Discount__c":[null,null],"Custom_Discount__c":[1500,1500],"SBQQ__DistributorDiscount__c":[null,null],"SBQQ__PartnerDiscount__c":[null,null],"SBQQ__AdditionalDiscountAmount__c":[1500,1500],"Discount_Type__c":["Amt.","Amt."],"SBQQ__StartDate__c":["2018-08-13","2019-08-13"],"SBQQ__EndDate__c":["2019-08-12","2020-08-12"]},"calculatedFieldValueMap":{"SBQQ__OriginalPrice__c":[2500,2500],"SBQQ__ListPrice__c":[2500,2500],"SBQQ__RegularPrice__c":[2500,2500],"SBQQ__CustomerPrice__c":[1000,1000],"SBQQ__PartnerPrice__c":[1000,1000],"SBQQ__NetPrice__c":[1000,1000],"Rack_Rate__c":[2500,2500],"SBQQ__ProrateMultiplier__c":[1,1]},"contractedFieldValueMap":{},"clonedFromQleIds":[],"insertOnNextCurrentYear":false,"nextYearQleId":"62402_znc_00435"}';
        
        //Account
        Account TestAccount = new Account();
        TestAccount.Name = 'Test Account';
        TestAccount.BillingCountryCode='US';
        TestAccount.BillingState='AK';
        insert TestAccount;
        
        //Insert Opp
        Opportunity opp = TestUtil.createOpportunity('Test Opp', 'Renewal', 'Closed Won');
        opp.CurrencyIsoCode  = 'USD';
        insert opp;
        updateOpportunityAddresses(opp.Id,TestAccount.Id);
    
        //Insert Quote
        SBQQ__Quote__c TestQuote = new SBQQ__Quote__c();
        TestQuote.SBQQ__Opportunity2__c = opp.id;
        TestQuote.SBQQ__Type__c = 'Quote';
        TestQuote.Current_Year__c = 1;
        TestQuote.Contract_Term_Years__c = '3';
        TestQuote.Contract_Executed__c = true;
        TestQuote.SBQQ__StartDate__c = System.today().addYears(-1);
        TestQuote.SBQQ__EndDate__c = System.today();
        TestQuote.createdFromLegacyContract__c = true;
        TestQuote.Multiple_Years_Commitment__c = true;
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
        ParentCont.RecordTypeId = ParentRecordTypeId;
        ParentCont.SBQQ__Opportunity__c = opp.id;
        insert ParentCont;

        Contract childContract = new Contract();
        childContract.RecordTypeId = ChildRecordTypeId;
        childContract.AccountId = TestAccount.id;
        childContract.Parent_Contract__c = ParentCont.id;
        childContract.EndDate = System.today();
        childContract.StartDate = System.today().addMonths(-12);
        childContract.Current_Year__c = 1;
        childContract.SBQQ__Quote__c = TestQuote.Id;
        childContract.SBQQ__Opportunity__c = opp.Id;
        childContract.SBQQ__RenewalQuoted__c = false;
        childContract.Failed_Auto_Renew__c = false;
        childContract.Multiple_years_Commitment__C = true;
        childContract.Renewal_Creation_Date__c = Date.newInstance(2018,9,5); //System.today().addYears(1);
        childContract.SBQQ__Quote__c = TestQuote.Id;
        childContract.SBQQ__RenewalQuoted__c = false;
        
        insert childContract;        
        
        //Product
        Product2 product1 = new Product2();
        product1.Name = 'Product 1';
        product1.Contract_Output_Grouping__c = 'Bundle Advertisements';
        insert product1;
        
        //Insert Subscription
        SBQQ__Subscription__c sub = new SBQQ__Subscription__c();
        sub.SBQQ__Product__c = product1.id;
        sub.SBQQ__Account__c = TestAccount.id;
        sub.SBQQ__Contract__c = childContract.id;
        sub.jsonString__c = jsonString;
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
        ql1.jsonString__c = jsonString;
        ql1.SBQQ__UpgradedSubscription__c = sub.id;
        insert ql1;

        Opportunity amendmentOpportunity = TestUtil.createOpportunity('Test Opp', 'Event', 'Verbal');
        amendmentOpportunity.CurrencyIsoCode  = 'USD';
        amendmentOpportunity.SBQQ__AmendedContract__c = childContract.Id;
        insert amendmentOpportunity;
        updateOpportunityAddresses(amendmentOpportunity.Id,TestAccount.Id);    
        
        //Quote2
        SBQQ__Quote__c TestQuote2 = new SBQQ__Quote__c();
        TestQuote2.SBQQ__Opportunity2__c = amendmentOpportunity.id;
        TestQuote2.Contract_Term_Years__c = '3';
        TestQuote2.Current_Year__c = 1;
        TestQuote2.SBQQ__Type__c = 'Amendment';
        TestQuote2.Contract_Executed__c = true;
        TestQuote2.SBQQ__StartDate__c = System.today().addYears(-1);
        TestQuote2.SBQQ__EndDate__c = System.today();
        TestQuote2.Multiple_Years_Commitment__c = true;
        TestQuote2.SBQQ__MasterContract__c = childContract.Id;
        TestQuote2.previousQuote__c = TestQuote.id;
        insert TestQuote2;

        List<SBQQ__QuoteLineGroup__c> amendmentGroups = new List<SBQQ__QuoteLineGroup__c>();

        for(Integer i = (Integer)TestQuote2.Current_Year__c; i <= Integer.valueOf(TestQuote2.Contract_Term_Years__c); i++) {
            SBQQ__QuoteLineGroup__c amendmentGroup = new SBQQ__QuoteLineGroup__c();
            amendmentGroup.Name = 'Year ' + i;
            amendmentGroup.SBQQ__Number__c = i;
            amendmentGroup.SBQQ__ListTotal__c = 10;
            amendmentGroup.SBQQ__NetTotal__c = 100;
            amendmentGroup.SBQQ__CustomerTotal__c = 1000;
            amendmentGroup.SBQQ__Quote__c = TestQuote2.id;
            amendmentGroup.term__c = i;    
            amendmentGroups.add(amendmentGroup);        
        }
        insert amendmentGroups;
        List<SBQQ__QuoteLine__c> amendmentLines = new List<SBQQ__QuoteLine__c>();
        for(Integer i=0; i< amendmentGroups.size(); i++) {
            SBQQ__QuoteLineGroup__c quoteLineGroup = amendmentGroups[i];
            SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
            quoteLine.SBQQ__Quantity__c = 1;
            quoteLine.SBQQ__Product__c = product1.Id;
            quoteLine.SBQQ__ListPrice__c = 10;
            quoteLine.SBQQ__NetPrice__c = 10;
            quoteLine.Rack_Rate__c = 10;
            quoteLine.SBQQ__SubscriptionPricing__c = 'Fixed Price';
            quoteLine.SBQQ__Number__c = 1;
            quoteLine.SBQQ__Group__c = quoteLineGroup.id;
            quoteLine.SBQQ__Quote__c = quoteLineGroup.SBQQ__Quote__c;
            quoteLine.Notes__c = 'abc';
            quoteLine.jsonString__c = jsonString;
            if(i == 0) {
                quoteLine.SBQQ__UpgradedSubscription__c = sub.id;
            }
            amendmentLines.add(quoteLine);
        }      
        insert amendmentLines;        
        Map<Id,Id> amendmentQuoteIdToChildContractId = new Map<Id,Id>{};
        amendmentQuoteIdToChildContractId.put(TestQuote2.Id,TestQuote2.SBQQ__MasterContract__c);
        ContractTrgHelperCls.handleAmendmentChangesOnContract(amendmentQuoteIdToChildContractId,new Set<Id>{TestQuote2.SBQQ__MasterContract__c});

    }        

}