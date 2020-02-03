@isTest
private class OpportunitySplitsController_Test {

   @testSetup static void setup() {
        Id RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Parent Contract').getRecordTypeId();
        
        //Account
        Account TestAccount = new Account();
        TestAccount.Name = 'Test Account';
        insert TestAccount;
        
        //Insert Opp
        Opportunity opp = TestUtil.createOpportunity('Test Opp', 'Renewal', 'Budget');
        //opp.SBQQ__Contracted__c = true;
        opp.CurrencyIsoCode  = 'USD';
        insert opp;

        //Product
        Product2 product1 = new Product2();
        product1.Name = 'Product 1';
        product1.Contract_Output_Grouping__c = 'Bundle Advertisements';
        insert product1;

        PricebookEntry customPrice = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(), Product2Id = product1.Id,
            UnitPrice = 12000, IsActive = true
        );
        insert customPrice;

        OpportunityLineItem lineItem = new OpportunityLineItem(opportunityId = opp.Id, Product2Id = product1.Id, Quantity = 5, UnitPrice = 6);
        lineItem.PricebookEntryId = customPrice.Id;
        insert lineItem;        
   }

    private static testMethod void testStuff() {
        List<Booking_Classification__c> bookingClassifications = [SELECT Id FROM Booking_Classification__c];
        System.assertEquals(bookingClassifications.size(),1);
        PageReference pageRef = Page.OpportunitySplits;
        Id opportunityId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        pageRef.getParameters().put('opportunityIdString', String.valueOf(opportunityId));
        Test.setCurrentPage(pageRef);
        OpportunitySplitsController splitsController = new OpportunitySplitsController();
        List<OpportunitySplitsController.SplitRow> splitRows = splitsController.splitRows;
        OpportunitySplitsController.getBcIdToBcWrapper(splitRows);
        splitsController.getSplitRowIds(splitRows);
        splitsController.validateUserUniqueness(splitRows);
        String splitRowMapJson = splitsController.splitRowMapJson;
        pageRef.getParameters().put('splitRowMapJson', splitRowMapJson);
        pageRef.getParameters().put('trySave','true');
        pageRef.getParameters().put('splittingBy','Amount');
        splitsController.receiveSplitRowMap();
    }

}