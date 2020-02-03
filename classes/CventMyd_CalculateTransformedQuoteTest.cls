/**
 * Created by ryandraper on 2018-07-07.
 */
@IsTest
public with sharing class CventMyd_CalculateTransformedQuoteTest {

    static testmethod void testBatch(){

        Id RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Parent Contract').getRecordTypeId();
        Id ChildRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Child Contract').getRecordTypeId();


        Opportunity opp = TestUtil.createOpportunity('Test Opp', 'Renewal', 'Closed Won');
        opp.CurrencyIsoCode  = 'USD';
        insert opp;

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
        insert cont;

        opp.SBQQ__RenewedContract__c = cont.id;
        update opp;

        //Normal Quote
        //Try inserting a Quote SBQQ__Type__c == Renewal
        SBQQ__Quote__c testQuote1 = new SBQQ__Quote__c();
        testQuote1.SBQQ__Opportunity2__c = opp.id;
        testQuote1.Contract_Term_Years__c = '2';
        testQuote1.SBQQ__Type__c = 'Renewal';
        testQuote1.Current_Year__c = 1;
        testQuote1.Contract_Term_Years__c = '2';
        testQuote1.SBQQ__EndDate__c = System.today();
        testQuote1.Contract_Executed__c = true;
        testQuote1.SBQQ__Primary__c = true;
        insert testQuote1;

        SBQQ__Quote__c testQuote2 = new SBQQ__Quote__c();
        testQuote2.Contract_Term_Years__c = '2';
        testQuote2.SBQQ__Type__c = 'Renewal';
        testQuote2.Current_Year__c = 1;
        testQuote2.Contract_Term_Years__c = '2';
        testQuote2.SBQQ__EndDate__c = System.today();
        testQuote2.Contract_Executed__c = true;
        testQuote2.Cloned_from_Quote__c = testQuote1.Id;
        testQuote2.SBQQ__Primary__c = false;
        testQuote2.Included_in_Primary_Batch_AW__c = true;
        testQuote2.recalculationToggler__c = false;
        insert testQuote2;

        Test.startTest();
            Database.executeBatch(new CventMyd_CalculateTransformedQuoteBatch(1),1);
        Test.stopTest();

    }
}