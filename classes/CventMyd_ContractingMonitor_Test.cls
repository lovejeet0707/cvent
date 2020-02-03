@isTest

private class CventMyd_ContractingMonitor_Test {

    private static testMethod void testMethod0() {    

        List<Opportunity> opportunities = [SELECT Id,contractedDateTime__c,SBQQ__Contracted__c FROM Opportunity];

        for(Opportunity opp : opportunities) {

            opp.SBQQ__Contracted__c = true;
        
        }

        SBQQ.TriggerControl.disable();

        update opportunities;

        for(Opportunity opp : opportunities) {

            System.debug('contracted date time population....: ');
            System.debug('DateTime.now(): ' + DateTime.now());
            DateTime tenMinutesAgo = DateTime.now().addMinutes(-100);
            System.debug('tenMinutesAgo: ' + tenMinutesAgo);

            opp.contractedDateTime__c = tenMinutesAgo;

            System.debug('opp0.Id: ' + opp.Id);

            System.debug('opp0.SBQQ__Contracted__c: ' + opp.SBQQ__Contracted__c);

            System.debug('opp0.contractedDateTime__c: ' + opp.contractedDateTime__c);         

        }

        update opportunities;

        SBQQ.TriggerControl.enable();

        // CventMyd_ContractingMonitorHandler.generateReport(null);         

        Test.startTest();

            CventMyd_ContractingMonitorHandler.scheduleNextContractingMonitor(true, null);

        Test.stopTest();
    
    }

    @TestSetup

    static void makeData(){

        Id RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Parent Contract').getRecordTypeId();
        Id ChildRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Child Contract').getRecordTypeId();
        
        Opportunity opp = TestUtil.createOpportunity('Test Opp', 'Renewal', 'Closed Won');
        opp.CurrencyIsoCode  = 'USD';
        insert opp;
        
        Address__c addr = new Address__c();
        addr.Address__c = 'Test Address';
        addr.Type__c = 'Billing';
        insert addr;
        
        Opportunity opp2 = TestUtil.createOpportunity('Test Opp', 'Renewal', 'Closed Won');
        opp2.CurrencyIsoCode  = 'USD';
        opp2.Bill_To_Address__c = addr.id;
        opp2.SBQQ__Contracted__c = true;
        insert opp2;
        
        /*
        Account TestAccount = TestUtil.createAccount('Test Account', 'Biz A/c');
        insert TestAccount;
        */
        
        Account TestAccount = new Account();
        TestAccount.Name = 'Test Account';
        insert TestAccount;
        
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
        
        CventMyd_ContractAmendmentController.contractIdsBeingAmended.add(cont.Id);
        
        SBQQ__Quote__c TestQuote2 = new SBQQ__Quote__c();
        TestQuote2.SBQQ__Opportunity2__c = opp.id;
        TestQuote2.Contract_Term_Years__c = '2';
        TestQuote2.SBQQ__Type__c = 'Renewal';
        TestQuote2.Contract_Executed__c = true;
        TestQuote2.SBQQ__StartDate__c = System.today().addYears(-1);
        TestQuote2.SBQQ__EndDate__c = System.today();
        insert TestQuote2;
        
        cont.contractedAmendmentQuote__c = TestQuote2.id;
        update cont;
    }
}