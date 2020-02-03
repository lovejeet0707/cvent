@isTest

private class CAM_ReturnShipment_Test {

    @isTest static void test_others(){
        
        //get all the data into the database
        CAM_Test_PopulateData.populateData();
        
        //initiate the page
        PageReference ReturnShipment = new PageReference('/apex/CAM_ReturnShipment');
        Test.setCurrentPage(ReturnShipment);

        //set the parameters for the methods
        ApexPages.currentPage().getParameters().put('id', CAM_Test_PopulateData.ohri[0].id);
        ApexPages.currentPage().getParameters().put('warehouse', CAM_Test_PopulateData.warehouses[0].id);

        //initiate the controller
        ApexPages.StandardController stdController = new ApexPages.StandardController(CAM_Test_PopulateData.ohri[0]);
        CAM_ReturnShipment_E ReturnShipment_Extension = new CAM_ReturnShipment_E(stdController);

        ReturnShipment_Extension.refreshPacklist();
        ReturnShipment_Extension.refreshPacklistItems();
        String s1 = ReturnShipment_Extension.newLine;
        
        List<SelectOption> warehouseList = ReturnShipment_Extension.getWarehouses();

        //ReturnShipment_Extension.bulkUpdateBox();
        //ReturnShipment_Extension.splitItem();


        System.debug ('TEST: test_others - positive outcome');
        System.AssertEquals (CAM_Test_PopulateData.ohri[0].id, ReturnShipment_Extension.pageID, 'This was a fake test, and it failed');

    }//test_others

    @isTest static void test_returnAsset(){
        
        //get all the data into the database
        CAM_Test_PopulateData.populateData();
        
        //initiate the page
        PageReference ReturnShipment = new PageReference('/apex/CAM_ReturnShipment');
        Test.setCurrentPage(ReturnShipment);

        //set the parameters for the methods
        ApexPages.currentPage().getParameters().put('id', CAM_Test_PopulateData.ohri[0].id);
        ApexPages.currentPage().getParameters().put('warehouse', CAM_Test_PopulateData.warehouses[0].id);

        //initiate the controller
        ApexPages.StandardController stdController = new ApexPages.StandardController(CAM_Test_PopulateData.ohri[0]);
        CAM_ReturnShipment_E ReturnShipment_Extension = new CAM_ReturnShipment_E(stdController);

        ReturnShipment_Extension.refreshPacklist();
        ReturnShipment_Extension.refreshPacklistItems();
        
        List<SelectOption> warehouseList = ReturnShipment_Extension.getWarehouses();

        //set the parameters for the methods
        ApexPages.currentPage().getParameters().put('packlistItemIDtobeReturned', CAM_Test_PopulateData.packlistItems[0].id);
        ApexPages.currentPage().getParameters().put('assetIDtobeReturned', CAM_Test_PopulateData.assets[0].id);

        ReturnShipment_Extension.returnAsset();

        //get the new count of Packlist Items
        List<Packlist_Item__c> pi_new = new List<Packlist_Item__c>();
        pi_new = [SELECT id, Name, Cvent_Asset__c FROM Packlist_Item__c WHERE Onsite_Hardware_Request_Item__c =:CAM_Test_PopulateData.ohri[0].id AND Cvent_Asset__c=:CAM_Test_PopulateData.assets[0].id AND Date_Actual_Return__c = null];

        System.debug ('TEST: test_returnAsset - positive outcome');
        System.AssertEquals (0, pi_new.size(), 'The Packlist Item has not been returned as expected');

    }//test_returnAsset

    @isTest static void test_returnAssets(){
        
        //get all the data into the database
        CAM_Test_PopulateData.populateData();
        
        //initiate the page
        PageReference ReturnShipment = new PageReference('/apex/CAM_ReturnShipment');
        Test.setCurrentPage(ReturnShipment);

        //set the parameters for the methods
        ApexPages.currentPage().getParameters().put('id', CAM_Test_PopulateData.ohri[0].id);
        ApexPages.currentPage().getParameters().put('warehouse', CAM_Test_PopulateData.warehouses[0].id);

        //initiate the controller
        ApexPages.StandardController stdController = new ApexPages.StandardController(CAM_Test_PopulateData.ohri[0]);
        CAM_ReturnShipment_E ReturnShipment_Extension = new CAM_ReturnShipment_E(stdController);

        ReturnShipment_Extension.refreshPacklist();
        ReturnShipment_Extension.refreshPacklistItems();
        
        List<SelectOption> warehouseList = ReturnShipment_Extension.getWarehouses();

        //set the parameters for the methods
        ApexPages.currentPage().getParameters().put('packlistItemIDtobeReturned', CAM_Test_PopulateData.packlistItems[0].id);
        ApexPages.currentPage().getParameters().put('assetIDtobeReturned', CAM_Test_PopulateData.assets[0].Asset_Tag__c);
        ReturnShipment_Extension.scannedIdList = 'emre\n' + CAM_Test_PopulateData.assets[1].Asset_Tag__c + '\n' + CAM_Test_PopulateData.assets[1].Asset_Tag__c + '\ntest\n' + CAM_Test_PopulateData.assets[0].Asset_Tag__c;

        ReturnShipment_Extension.returnAssets();

        //get the new count of Packlist Items
        List<Packlist_Item__c> pi_new = new List<Packlist_Item__c>();
        pi_new = [SELECT id, Name, Cvent_Asset__c FROM Packlist_Item__c WHERE Onsite_Hardware_Request_Item__c =:CAM_Test_PopulateData.ohri[0].id AND Cvent_Asset__c=:CAM_Test_PopulateData.assets[0].id AND Date_Actual_Return__c = null];

        System.debug ('TEST: test_returnAssets - positive outcome');
        System.AssertEquals (0, pi_new.size(), 'The Packlist Item has not been returned as expected');

    }//test_returnAssets

    @isTest static void test_confirmReturnedQuantity(){
        
        //get all the data into the database
        CAM_Test_PopulateData.populateData();
        
        //initiate the page
        PageReference ReturnShipment = new PageReference('/apex/CAM_ReturnShipment');
        Test.setCurrentPage(ReturnShipment);

        //set the parameters for the methods
        ApexPages.currentPage().getParameters().put('id', CAM_Test_PopulateData.ohri[0].id);
        ApexPages.currentPage().getParameters().put('warehouse', CAM_Test_PopulateData.warehouses[0].id);

        //initiate the controller
        ApexPages.StandardController stdController = new ApexPages.StandardController(CAM_Test_PopulateData.ohri[0]);
        CAM_ReturnShipment_E ReturnShipment_Extension = new CAM_ReturnShipment_E(stdController);

        ReturnShipment_Extension.refreshPacklist();
        ReturnShipment_Extension.refreshPacklistItems();
        ReturnShipment_Extension.theItem.Returned_Quantity_Others__c = 10;
        
        List<SelectOption> warehouseList = ReturnShipment_Extension.getWarehouses();

        //set the parameters for the methods
        ApexPages.currentPage().getParameters().put('packlistItemIDtobeReturned', CAM_Test_PopulateData.packlistItems[0].id);
        ApexPages.currentPage().getParameters().put('assetIDtobeReturned', CAM_Test_PopulateData.assets[0].id);

        ReturnShipment_Extension.confirmReturnedQuantity();

        //get the new count of Packlist Items
        Onsite_Hardware_Request_Item__c item = [SELECT id, Name, Returned_Quantity_Others__c FROM Onsite_Hardware_Request_Item__c WHERE id =:CAM_Test_PopulateData.ohri[0].id LIMIT 1];

        System.debug ('TEST: test_confirmReturnedQuantity - positive outcome');
        System.AssertEquals (10, item.Returned_Quantity_Others__c, 'Returned Quantity for the Item has not been set as expected');

    }//test_confirmReturnedQuantity

    @isTest static void test_redirect(){
        
        //get all the data into the database
        CAM_Test_PopulateData.populateData();
        
        //initiate the page
        PageReference ReturnShipment = new PageReference('/apex/CAM_ReturnShipment');
        Test.setCurrentPage(ReturnShipment);

        //set the parameters for the methods
        ApexPages.currentPage().getParameters().put('Packlist__c', CAM_Test_PopulateData.packlists[0].id);

        //initiate the controller
        ApexPages.StandardController stdController = new ApexPages.StandardController(CAM_Test_PopulateData.ohri[0]);
        CAM_ReturnShipment_E ReturnShipment_Extension = new CAM_ReturnShipment_E(stdController);

        System.debug ('TEST: test_redirect - positive outcome');
        System.AssertNotEquals (null, ReturnShipment_Extension.thePacklist, 'The redirectMe method did not populate the Packlist as expected');

    }//test_redirect
}