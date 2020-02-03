@isTest

private with sharing class CventMyd_RecalculateQuotes_Test {

    private static testMethod void testMethod0() {

        Map<Id,Integer> quoteIdToRecalculationAttempts = new Map<Id,Integer>();

        for(SBQQ__Quote__c quote : [SELECT Id FROM SBQQ__Quote__c]) {

            quoteIdToRecalculationAttempts.put(quote.Id,0);

        }

        CventMyd_QuoteTriggerHandler.handleQuoteRecalculation(quoteIdToRecalculationAttempts);

    }

    @TestSetup

    static void makeData(){

        Id RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Parent Contract').getRecordTypeId();
        
        //Account
        Account TestAccount = new Account();
        TestAccount.Name = 'Test Account';
        insert TestAccount;
        
        //Insert Opp
        Opportunity opp = TestUtil.createOpportunity('Test Opp', 'Renewal', 'Closed Won');
        opp.CurrencyIsoCode  = 'USD';
        opp.RenewalDate__c = Date.today();
        insert opp;

        String jsonString = '{"qleId":"08118_dse_20882","quoteName":"Q-250271","preCalculationFieldValueMap":{"SBQQ__Quantity__c":[50],"SBQQ__Discount__c":[0],"Custom_Discount__c":[null],"SBQQ__DistributorDiscount__c":[null],"SBQQ__PartnerDiscount__c":[null],"SBQQ__AdditionalDiscountAmount__c":[null],"Discount_Type__c":["%"],"SBQQ__StartDate__c":["2018-08-09"],"SBQQ__EndDate__c":[null]},"calculatedFieldValueMap":{"SBQQ__OriginalPrice__c":[9.95],"SBQQ__ListPrice__c":[9.79],"SBQQ__RegularPrice__c":[9.79],"SBQQ__CustomerPrice__c":[9.79],"SBQQ__PartnerPrice__c":[9.79],"SBQQ__NetPrice__c":[9.79],"Rack_Rate__c":[9.79],"SBQQ__ProrateMultiplier__c":[1]},"contractedFieldValueMap":{},"clonedFromQleIds":[],"deleteThisLine":true}';
    
        //Insert Quote
        SBQQ__Quote__c TestQuote = new SBQQ__Quote__c();
        TestQuote.SBQQ__Opportunity2__c = opp.id;
        TestQuote.Contract_Term_Years__c = '3';
        TestQuote.SBQQ__Type__c = 'Renewal';
        TestQuote.Current_Year__c = 1;
        TestQuote.Contract_Executed__c = true;
        TestQuote.SBQQ__StartDate__c = System.today().addYears(-1);
        TestQuote.SBQQ__EndDate__c = System.today();
        TestQuote.msaUpload__c = true;
        TestQuote.createdFromLegacyContract__c = false;
        TestQuote.Multiple_Years_Commitment__c = false;
        insert TestQuote;

    }

}