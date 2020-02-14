@isTest
private class CventMyd_LegacyContractValidator_Test {

    private static testMethod void test() {

    Id test = CventMyd_LegacyContractValidator.createOrGetMasterReport();
    
    }
    
    private static testMethod void test2() {
        
        //Insert Opp
        Opportunity opp = TestUtil.createOpportunity('Test Opp', 'Renewal', 'Closed Won');
        opp.CurrencyIsoCode  = 'USD';
        insert opp;
        
        //Account
        Account TestAccount = new Account();
        TestAccount.Name = 'Test Account';
        insert TestAccount;
        
        Id RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Parent Contract').getRecordTypeId();
        Id ChildRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Child Contract').getRecordTypeId();
        
        //Parent Contract to have Parent_Contract_Term_Years__c, Upcoming_Renewal_Type__c, Parent_Contract_Term_Years__c
        Contract ParentCont = new Contract();
        ParentCont.AccountId = TestAccount.id;
        ParentCont.Contract_Term_Years__c = '1';
        ParentCont.RecordTypeId = RecordTypeId;
        ParentCont.SBQQ__Opportunity__c = opp.id;
        //ParentCont.Is_Legacy__c = true;
        ParentCont.SBQQ__RenewalQuoted__c = false;
        ParentCont.Failed_Auto_Renew__c = false;
        ParentCont.Renewal_Creation_Date__c = System.today().addYears(1);
        insert ParentCont;

        Test.setCreatedDate(parentCont.Id,DateTime.newInstance(2015,1,1));
        
        CventMyd_LegacyContractValidator.createGenerationFailureReport(ParentCont, 'Test', true);
    } 
    
    private static testMethod void test3() {
        
        SBQQ__Quote__c TestQuote = createTestData(false,false);
        
        Test.startTest();
        CventMyd_LegacyContractValidator.validateAgainstLegacyContract(TestQuote.id, true);
        CventMyd_LegacyContractValidator.validateAgainstAllLegacyContracts(true);
        
        CventMyd_LegacyContractValidator.LegacyContractWrapper lcw = new CventMyd_LegacyContractValidator.LegacyContractWrapper();
        //lcw.contract = cont;
        lcw.quote = TestQuote;
        lcw.isAmendment = true;
        
        //CventMyd_LegacyContractValidator.getExpectedEndDate(lcw);
        Test.stopTest();
    }

    private static testMethod void test4() {
        
        SBQQ__Quote__c TestQuote = createTestData(true,false);
        
        Test.startTest();
        CventMyd_LegacyContractValidator.validateAgainstLegacyContract(TestQuote.id, true);
        CventMyd_LegacyContractValidator.validateAgainstAllLegacyContracts(true);

        Test.stopTest();

    }

    private static testMethod void test5() {
        
        SBQQ__Quote__c TestQuote = createTestData(true,true);
        
        Test.startTest();
        CventMyd_LegacyContractValidator.validateAgainstLegacyContract(TestQuote.id, true);
        CventMyd_LegacyContractValidator.validateAgainstAllLegacyContracts(true);

        Test.stopTest();

    }

    private static testMethod void test6() {

        CventMyd_LegacyContractValidator.getProrateMultiplier(Date.today(), Date.today().addDays(1));

        Map<Integer,String> quoteYearToEndDateFieldName = new Map<Integer,String>();

        quoteYearToEndDateFieldName.put(1,'Cvent');

        CventMyd_LegacyContractValidator.replaceYearWithEffectiveYear(quoteYearToEndDateFieldName);

        CventMyd_LegacyContractValidator.LegacyContractWrapper legacyContractWrapper = new CventMyd_LegacyContractValidator.LegacyContractWrapper();

        SBQQ__Quote__c quote = new SBQQ__Quote__c();

        Contract contract = new Contract();

        legacyContractWrapper.quote = quote;

        legacyContractWrapper.contract = contract;

        CventMyd_LegacyContractValidator.ComparisonType comparisonTypeEnum = CventMyd_LegacyContractValidator.ComparisonType.OPPORTUNITY_LINE_CHECK;

        CventMyd_LegacyContractValidator.getOpportunityLineCheck(legacyContractWrapper,comparisonTypeEnum);

    }

    private static SBQQ__Quote__c createTestData(Boolean variableOptions,Boolean termRenewal) {

        //Insert Opp
        Opportunity opp = TestUtil.createOpportunity('Test Opp', 'Renewal', 'Closed Won');
        opp.CurrencyIsoCode  = 'USD';
        insert opp;
        
        //Account
        Account TestAccount = new Account();
        TestAccount.Name = 'Test Account';
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
    
}