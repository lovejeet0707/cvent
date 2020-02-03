@isTest
private class CustomSplitsController_Test {

   @testSetup static void setup() {
        Id RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Parent Contract').getRecordTypeId();
        
        //Account
        Account TestAccount = new Account();
        TestAccount.Name = 'Test Account';
        TestAccount.BillingStateCode='AK';
        TestAccount.BillingCountryCode='US';          
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
        List<Booking_Classification__c> bookingClassifications = [SELECT Id,Opportunity__c,Product_Family__c FROM Booking_Classification__c];
        System.assertEquals(bookingClassifications.size(),1);
        delete [select id from Custom_Opportunity_Splits__c];
        Booking_Classification__c bcRecord = bookingClassifications[0];
        Custom_Opportunity_Splits__c splitRecord = new Custom_Opportunity_Splits__c();
        splitRecord.Credit_Type__c = 'Brand';
        splitRecord.Split_Type__c = 'Revenue';
        splitRecord.Team_Member__c = UserInfo.getUserId();
        splitRecord.Opportunity__c = bcRecord.Opportunity__c;
        splitRecord.Booking_Classification_Record__c = bcRecord.Id;
        splitRecord.Split_Amount__c = 30;
        splitRecord.Product_Family__c = bcRecord.Product_Family__c;
        splitRecord.index__c = 0;
        splitRecord.BCT_Factor_Total__c = 30;
        splitRecord.Bookings_Classification__c = 'NBB';
        insert splitRecord;        
        PageReference pageRef = Page.CustomSplits;
        Id opportunityId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        pageRef.getParameters().put('opportunityIdString', String.valueOf(opportunityId));
        Test.setCurrentPage(pageRef);
        CustomSplitsController splitsController = new CustomSplitsController();
        List<CustomSplitsController.SplitRow> splitRows = splitsController.splitRows;
        splitsController.validateUserUniqueness(splitRows);
        String splitRowMapJson = splitsController.splitRowMapJson;
        pageRef.getParameters().put('splitRowMapJson', splitRowMapJson);
        pageRef.getParameters().put('trySave','true');
        pageRef.getParameters().put('splittingBy','Amount');
        splitsController.receiveSplitRowMap();
    }   

}