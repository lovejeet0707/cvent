@isTest

private class CventMyd_QuoteLineTriggerHandler_Test {

    @testSetup static void setup() {
        Id RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Parent Contract').getRecordTypeId();
        
        //Account
        Account TestAccount = new Account();
        TestAccount.Name = 'Test Account';
        insert TestAccount;
        
        //Insert Opp
        Opportunity opp = TestUtil.createOpportunity('Test Opp', 'Renewal', 'Closed Won');
        opp.CurrencyIsoCode  = 'USD';
        insert opp;
    
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
        
    }

    private static testMethod void testQuoteLineInsertion(){

        Product2 product1 = new Product2();
        product1.Name = 'Product 1';
        product1.Contract_Output_Grouping__c = 'Bundle Advertisements';
        insert product1;

        integer numberofRecords = 10;
        List<SBQQ__QuoteLine__c> listInsertQuoteLine = new List<SBQQ__QuoteLine__c>();
        Id quoteId = [SELECT Id FROM SBQQ__Quote__c LIMIT 1].Id;
        for(integer temp = 0; temp<numberofRecords ; temp++){
            //Insert Quote Line
            SBQQ__QuoteLine__c testQuoteLine = new SBQQ__QuoteLine__c();
            testQuoteLine.SBQQ__Quantity__c = 1;
            testQuoteLine.SBQQ__Product__c = product1.Id;
            testQuoteLine.SBQQ__ListPrice__c = 10;
            testQuoteLine.SBQQ__NetPrice__c = 10;
            testQuoteLine.Rack_Rate__c = 10;
            testQuoteLine.SBQQ__SubscriptionPricing__c = 'Fixed Price';
            testQuoteLine.SBQQ__Number__c = 1;
            testQuoteLine.SBQQ__Quote__c = quoteId;
            testQuoteLine.Notes__c = 'abc';
            testQuoteLine.jsonString__c = 'test String';
            listInsertQuoteLine.add(testQuoteLine);
        }
        insert listInsertQuoteLine; 

    }   
}