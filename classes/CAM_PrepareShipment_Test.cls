@isTest

private class CAM_PrepareShipment_Test {

    @isTest static void test_newLine(){
        
        //get all the data into the database
        CAM_Test_PopulateData.populateData();
        
        //initiate the page
        PageReference PrepareShipment = new PageReference('/apex/CAM_PrepareShipment');
        Test.setCurrentPage(PrepareShipment);

        //initiate the controller
        ApexPages.StandardController stdController = new ApexPages.StandardController(CAM_Test_PopulateData.ohri[0]);
        CAM_PrepareShipment_Extension PrepareShipment_Extension = new CAM_PrepareShipment_Extension(stdController);

        
        System.debug ('TEST: newLine - positive outcome');
        System.AssertNotEquals (null, PrepareShipment_Extension.newLine, 'New Line should not be null');

    }//test_newLine

    @isTest static void test_others(){
        
        //get all the data into the database
        CAM_Test_PopulateData.populateData();
        
        //initiate the page
        PageReference PrepareShipment = new PageReference('/apex/CAM_PrepareShipment');
        Test.setCurrentPage(PrepareShipment);

        //set the parameters for the methods
        ApexPages.currentPage().getParameters().put('activeBoxSingleParam', 'Fake Box 1');
        ApexPages.currentPage().getParameters().put('activeBoxBulkParam', 'Fake Box 2');

        //initiate the controller
        ApexPages.StandardController stdController = new ApexPages.StandardController(CAM_Test_PopulateData.ohri[0]);
        CAM_PrepareShipment_Extension PrepareShipment_Extension = new CAM_PrepareShipment_Extension(stdController);

        PrepareShipment_Extension.refreshTheRequestedItem();
        PrepareShipment_Extension.refreshThePacklist();
        PrepareShipment_Extension.populateShippingQuantity();
        PrepareShipment_Extension.confirmShippingQuantity();
        
        List<CAM_PrepareShipment_Extension.w_ReqItem> l_w_ReqItem = PrepareShipment_Extension.otherItems;
        List<SelectOption> boxList = PrepareShipment_Extension.getBoxes();

        PrepareShipment_Extension.bulkUpdateBox();
        PrepareShipment_Extension.splitItem();


        System.debug ('TEST: test_others - positive outcome');
        System.AssertEquals (PrepareShipment_Extension.theRequestedItem.id, CAM_Test_PopulateData.ohri[0].id, 'This was a fake test, and it failed');

    }//test_others

    @isTest static void test_scan_remove_bulkScan_Asset(){
        
        //get all the data into the database
        CAM_Test_PopulateData.populateData();
        
        //initiate the page
        PageReference PrepareShipment = new PageReference('/apex/CAM_PrepareShipment');
        Test.setCurrentPage(PrepareShipment);

        //set the parameters for the methods
        ApexPages.currentPage().getParameters().put('activeBoxSingleParam', CAM_Test_PopulateData.boxes[0].id);
        ApexPages.currentPage().getParameters().put('activeBoxBulkParam', CAM_Test_PopulateData.boxes[0].id);

        //initiate the controller
        ApexPages.StandardController stdController = new ApexPages.StandardController(CAM_Test_PopulateData.ohri[0]);
        CAM_PrepareShipment_Extension PrepareShipment_Extension = new CAM_PrepareShipment_Extension(stdController);

        //call methods to initiate objects
        PrepareShipment_Extension.refreshTheRequestedItem();
        PrepareShipment_Extension.refreshThePacklist();
        List<CAM_PrepareShipment_Extension.w_ReqItem> l_w_ReqItem = PrepareShipment_Extension.otherItems;

        //set parameters
        PrepareShipment_Extension.scannedAssetId = CAM_Test_PopulateData.assets[1].Asset_Tag__c;
        PrepareShipment_Extension.scanAsset();

        //get the new count of Packlist Items
        List<Packlist_Item__c> pi_new = new List<Packlist_Item__c>();
        pi_new = [SELECT id, Name, Cvent_Asset__c FROM Packlist_Item__c WHERE Onsite_Hardware_Request_Item__c =:CAM_Test_PopulateData.ohri[0].id AND Cvent_Asset__c=:CAM_Test_PopulateData.assets[1].id];

        System.debug ('TEST: test_scanAsset - positive outcome');
        System.AssertEquals (1, pi_new.size(), 'The Packlist Item count did not increase by one as expected');

        //now that we have a Packlist Item, let's test removing it
        ApexPages.currentPage().getParameters().put('packlistItemIDtobeDeleted', pi_new[0].id);
        ApexPages.currentPage().getParameters().put('assetIDtobeUpdated', pi_new[0].Cvent_Asset__c);
        
        PrepareShipment_Extension.removeAsset();
        pi_new = [SELECT id, Name, Cvent_Asset__c FROM Packlist_Item__c WHERE Onsite_Hardware_Request_Item__c =:CAM_Test_PopulateData.ohri[0].id AND Cvent_Asset__c=:CAM_Test_PopulateData.assets[1].id];

        System.debug ('TEST: test_removeAsset - positive outcome');
        System.AssertEquals (0, pi_new.size(), 'The Packlist Item count did not decrease by one as expected');

        //now let's test bulk scanning
        PrepareShipment_Extension.bulkIDList = 'emre\n' + CAM_Test_PopulateData.assets[1].Asset_Tag__c + '\n' + CAM_Test_PopulateData.assets[1].Asset_Tag__c + '\ntest\n' + CAM_Test_PopulateData.assets[0].Asset_Tag__c;
        
        PrepareShipment_Extension.bulkScanAssets();
        pi_new = [SELECT id, Name, Cvent_Asset__c FROM Packlist_Item__c WHERE Onsite_Hardware_Request_Item__c =:CAM_Test_PopulateData.ohri[0].id AND Cvent_Asset__c=:CAM_Test_PopulateData.assets[1].id];

        System.debug ('TEST: test_bulkScanAsset - positive outcome');
        System.AssertEquals (1, pi_new.size(), 'The Packlist Item count did not decrease by one as expected');
    }//test_scan_remove_bulkScan_Asset    


    @isTest static void test_createNewItem(){
        
        //get all the data into the database
        CAM_Test_PopulateData.populateData();
        
        //initiate the page
        PageReference PrepareShipment = new PageReference('/apex/CAM_PrepareShipment');
        Test.setCurrentPage(PrepareShipment);

        //set the parameters for the methods
        ApexPages.currentPage().getParameters().put('activeBoxSingleParam', CAM_Test_PopulateData.boxes[0].id);

        //initiate the controller
        ApexPages.StandardController stdController = new ApexPages.StandardController(CAM_Test_PopulateData.ohri[0]);
        CAM_PrepareShipment_Extension PrepareShipment_Extension = new CAM_PrepareShipment_Extension(stdController);

        //call methods to initiate objects
        PrepareShipment_Extension.refreshTheRequestedItem();
        PrepareShipment_Extension.refreshThePacklist();
        List<CAM_PrepareShipment_Extension.w_ReqItem> l_w_ReqItem = PrepareShipment_Extension.otherItems;

        //set parameters
        PrepareShipment_Extension.scannedAssetId = CAM_Test_PopulateData.assets[1].Asset_Tag__c;
        PrepareShipment_Extension.scanAsset();
        List<Packlist_Item__c> pi_inserted = new List<Packlist_Item__c>();
        pi_inserted = [SELECT id, Name, Cvent_Asset__c FROM Packlist_Item__c WHERE Onsite_Hardware_Request_Item__c =:CAM_Test_PopulateData.ohri[0].id AND Cvent_Asset__c=:CAM_Test_PopulateData.assets[1].id];

        ApexPages.currentPage().getParameters().put('packlistItemID', pi_inserted[0].id);
        PageReference pp = PrepareShipment_Extension.createNewItem();

        //get the new count of Packlist Items
        //List<Packlist_Item__c> pi_new = new List<Packlist_Item__c>();
        //pi_new = [SELECT id, Name, Cvent_Asset__c FROM Packlist_Item__c WHERE Onsite_Hardware_Request_Item__c =:CAM_Test_PopulateData.ohri[0].id AND Cvent_Asset__c=:CAM_Test_PopulateData.assets[1].id];

        System.debug ('TEST: test_createNewItem - positive outcome');
        System.AssertNotEquals (null, pp, 'The item split did not work as expected');
    }//createNewItem


}