@isTest
private class CventMyd_AllRemainingCode_Test {

    private static testMethod void testDeleteGhostQuotes() {

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

        Set<Id> quoteIds = new Set<Id>{TestQuote.Id};

        String jobName = 'My Nice Job Name';

        CventMyd_DeleteGhostQuotes deleteGhostQuotes = new CventMyd_DeleteGhostQuotes(quoteIds,jobName);

        String cronString = '0 0 23 * * ?';

        Test.startTest();

        System.schedule(jobName, cronString, deleteGhostQuotes);

        Test.stopTest();

    }

    public static testMethod void testRenewalChainMonitor0() {

        CpqAudit__c chainMaster = new CpqAudit__c(isChainMaster__c = true,jobsInChain__c = 0);

        insert chainMaster;

        String jobName = 'My nice job name';

        CventMyd_RenewalChainMonitor renewalChainMonitor = new CventMyd_RenewalChainMonitor(jobName,chainMaster.Id,true);

        String cronString = '0 0 23 * * ?';

        Test.startTest();

        System.schedule(jobName, cronString, renewalChainMonitor);

        Test.stopTest();

    }

    public static testMethod void testRenewalChainMonitor1() {

        CpqAudit__c chainMaster = new CpqAudit__c(isChainMaster__c = true,jobsInChain__c = 1,chainFinished__c=true);

        insert chainMaster;

        String jobName = 'My nice job name';

        CventMyd_RenewalChainMonitor renewalChainMonitor = new CventMyd_RenewalChainMonitor(jobName,chainMaster.Id,false);

        String cronString = '0 0 23 * * ?';

        Test.startTest();

        System.schedule(jobName, cronString, renewalChainMonitor);

        Test.stopTest();

    }

    public static testMethod void addContractTrgCoverage() {

        Id RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Parent Contract').getRecordTypeId();       

        Id ChildRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Child Contract').getRecordTypeId();      

        Opportunity opp = TestUtil.createOpportunity('Test Opp', 'Renewal', 'Closed Won');
        opp.CurrencyIsoCode  = 'USD';
        insert opp;     

        Account TestAccount = new Account();
        TestAccount.Name = 'Test Account' + String.valueOf(Math.random());
        insert TestAccount;     

        Contract ParentCont = new Contract();
        ParentCont.AccountId = TestAccount.id;
        ParentCont.Contract_Term_Years__c = '5';
        ParentCont.RecordTypeId = RecordTypeId;
        ParentCont.SBQQ__Opportunity__c = opp.id;
        //ParentCont.Is_Legacy__c = true;
        ParentCont.SBQQ__RenewalQuoted__c = false;
        ParentCont.Failed_Auto_Renew__c = false;
        ParentCont.Renewal_Creation_Date__c = System.today().addYears(1); 

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

        Test.stopTest();



    }

    public static testmethod void legacyValidationQueueableTest() {

        SBQQ__Quote__c quote0 = createTestData(true,false);

        

        SBQQ__Quote__c quote1 = createTestData(true,false);

        CventMyd_Settings.quotesPerLegacyValidationJob = 1;

        List<Id> quoteIds = new List<Id>{quote0.Id,quote1.Id};

        CventMyd_LegacyValidationQueueable legacyValidationQueueable = new CventMyd_LegacyValidationQueueable(quoteIds,false);

        Test.startTest();

        System.enqueueJob(legacyValidationQueueable);

        Test.stopTest();

    }

    private static SBQQ__Quote__c createTestData(Boolean variableOptions,Boolean termRenewal) {

        //Insert Opp
        Opportunity opp = TestUtil.createOpportunity('Test Opp', 'Renewal', 'Closed Won');
        opp.CurrencyIsoCode  = 'USD';
        insert opp;
        
        //Account
        Account TestAccount = new Account();
        TestAccount.Name = 'Test Account' + String.valueOf(Math.random());
        insert TestAccount;
        
        Id RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Parent Contract').getRecordTypeId();
        Id ChildRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Child Contract').getRecordTypeId();
        
        //Parent Contract to have Parent_Contract_Term_Years__c, Upcoming_Renewal_Type__c, Parent_Contract_Term_Years__c
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

        Test.setCreatedDate(parentCont.Id,DateTime.newInstance(2015,1,1));
        
        //Child Contract
        Contract cont = new Contract();
        cont.RecordTypeId = ChildRecordTypeId;
        cont.AccountId = TestAccount.id;
        cont.Parent_Contract__c = ParentCont.id;
        //cont.Upcoming_Renewal_Type__c = 'Contract Renewal';
        cont.EndDate = System.today();
        //cont.Remaining_Master_Term__c = 0;
        cont.Current_Year__c = (termRenewal) ? 5 : 1;
        //cont.Is_Legacy__c = true;
        cont.SBQQ__RenewalQuoted__c = false;
        cont.Failed_Auto_Renew__c = false;
        cont.Multiple_years_Commitment__C = variableOptions;
        cont.Renewal_Creation_Date__c = Date.newInstance(2018,9,5); //System.today().addYears(1);
        
        insert cont;

        Id contId = cont.Id;

        cont = [SELECT Upcoming_Renewal_Type__c from contract where Id =: contId];

        System.debug('childContract.Upcoming_Renewal_Type__c: ' + cont.Upcoming_Renewal_Type__c);



        Test.setCreatedDate(cont.Id,DateTime.newInstance(2015,1,1));
        
        opp.SBQQ__RenewedContract__c = cont.id;
        update opp;
        
        //Product
        Product2 product1 = new Product2();
        product1.Name = 'Product 1';
        product1.Contract_Output_Grouping__c = 'Bundle Advertisements';
        product1.Revenue_Type__c = 'Non-Recurring';
        insert product1;
        
        //Insert Subscription
        SBQQ__Subscription__c sub = new SBQQ__Subscription__c();
        sub.SBQQ__Product__c = product1.id;
        sub.SBQQ__Account__c = TestAccount.id;
        sub.SBQQ__Contract__c = cont.id;
        sub.SBQQ__Quantity__c = 1;
        sub.SBQQ__NetPrice__c = 1;
        sub.Year_2_Net_Amount_X__c = 1;
        sub.Year_3_Net_Amount_X__c = 1;
        sub.Year_4_Net_Amount_X__c = 1;
        sub.Year_5_Net_Amount_X__c = 1;

        insert sub;
        
        //Insert Quote
        SBQQ__Quote__c TestQuote = new SBQQ__Quote__c();
        TestQuote.SBQQ__Opportunity2__c = opp.id;
        TestQuote.Contract_Term_Years__c = '2';
        TestQuote.SBQQ__Type__c = 'Amendment';
        TestQuote.Current_Year__c = (termRenewal) ? 5 : 2;
        TestQuote.Contract_Executed__c = true;
        TestQuote.SBQQ__StartDate__c = System.today().addYears(-1);
        TestQuote.SBQQ__EndDate__c = System.today();
        TestQuote.createdFromLegacyContract__c = true;
        TestQuote.Multiple_Years_Commitment__c = variableOptions;
        TestQuote.statusCheckCount__c = 0;
        insert TestQuote;
        
        SBQQ__Quote__c TestQuote2 = new SBQQ__Quote__c();
        TestQuote2.SBQQ__Opportunity2__c = opp.id;
        TestQuote2.Contract_Term_Years__c = (termRenewal) ? '5' : '2';
        TestQuote2.SBQQ__Type__c = 'Renewal';
        TestQuote.Current_Year__c = 2;
        TestQuote2.Contract_Executed__c = true;
        TestQuote2.SBQQ__StartDate__c = System.today().addYears(-1);
        TestQuote2.SBQQ__EndDate__c = System.today();
        TestQuote2.createdFromLegacyContract__c = true;
        TestQuote2.statusCheckCount__c = 0;
        insert TestQuote2;
        
        Datetime yesterday = Datetime.now().addDays(-1);
        Test.setCreatedDate(TestQuote.Id, yesterday);     

        return TestQuote;   

    }

    public static testMethod void getOliCoverage() {

        Product2 prd1 = new Product2 (Name='Data Entry Test',Description='Test Product Entry 1',productCode = 'CV-SU-EC-EVT-WEBDESSUP', isActive = true);
        insert prd1;

        Account instofAcc = new Account();
        Id rtTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Biz A/c').getRecordTypeId();
        instofAcc.Name = 'Test';
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        instofAcc.RecordTypeId = rtTypeId;
        insert instofAcc;

        Id pricebookId = Test.getStandardPricebookId();

        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=pricebookId,UnitPrice=50, isActive=true);
        insert pbe1;

        Contact instofCon =  new Contact();
        instOfCon.LastName = 'Test';
        instOfCon.AccountId = instofAcc.Id;
        instOfCon.email = 'test@test.com';
        instOfCon.Creation_Source_System__c = 'ROL test';
        insert instOfCon;

        Opportunity instOfOppThird  = new Opportunity();
        instOfOppThird.AccountId = instofAcc.id;
        instOfOppThird.Name = 'Test';
        instOfOppThird.Product__c = 'Event';
        instOfOppThird.New_Type__c =  'Upsell-NBB';
        instOfOppThird.StageName = 'Verbal';
        instOfOppThird.CloseDate = system.today();
        instOfOppThird.New_Amount__c = 11;
        instOfOppThird.Years__c= '1';
        instOfOppThird.LeadSource = 'ACD-PS';
        instOfOppThird.Contact_Associated__c = instOfCon.Id;
        instOfOppThird.Contact_Role__c = 'Primary User';
        instOfOppThird.Contract_Implemented__c = true;
        instOfOppThird.ContractReceived__c = system.today();
        instOfOppThird.Deal_Year__c = '1';
        instOfOppThird.Pricebook2Id = pbe1.Pricebook2Id;
        test.startTest();
        insert instOfOppThird;


        OpportunityLineItem  instofFeatSet = new OpportunityLineItem ();
        //instofFeatSet.Feature__c = 'Data Entry';
        instofFeatSet.OpportunityID = instOfOppThird.Id;
        instofFeatSet.PriceBookEntryID=pbe1.Id;
        instofFeatSet.Product__c = 'Lead Capture';
        instofFeatSet.quantity=4;
        instofFeatSet.totalprice=200;

        insert instofFeatSet;

    }

}