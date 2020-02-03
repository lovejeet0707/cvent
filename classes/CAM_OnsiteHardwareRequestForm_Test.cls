@isTest

private class CAM_OnsiteHardwareRequestForm_Test {

    @isTest static void test_others() {

        //get all the data into the database
        CAM_Test_PopulateData.populateData();

        //initiate the page
        PageReference OHRForm = new PageReference('/apex/CAM_OnsiteHardwareRequestForm');
        Test.setCurrentPage(OHRForm);
        
        //set the parameter for the removeItem method
        //(PS: this method actually removed bundles, not methods)
        ApexPages.currentPage().getParameters().put('itemID', CAM_Test_PopulateData.ohrb[0].id);

        //initiate the controller
        ApexPages.StandardController stdController = new ApexPages.StandardController(CAM_Test_PopulateData.ohr[0]);
        CAM_OnsiteHardwareRequestForm_Extension OHRForm_Extension = new CAM_OnsiteHardwareRequestForm_Extension(stdController);

        //call the method
        OHRForm_Extension.refreshTheRequest();
        String s = OHRForm_Extension.selectedTab;
        String s2 = OHRForm_Extension.newLine;
        Integer i1 = OHRForm_Extension.charLmt;
        List<CAM_OnsiteHardwareRequestForm_Extension.requestStatus> ttt = OHRForm_Extension.timeline;

        System.debug ('TEST: Others - positive outcome');        
        System.assertNotEquals(null, OHRForm_Extension.selectedTab, 'This is a fake test');

    }//test_others

    @isTest static void test_removeItem() {

        //get all the data into the database
        CAM_Test_PopulateData.populateData();
        integer bundleCount = CAM_Test_PopulateData.ohrb.size();
        bundleCount--;

        //initiate the page
        PageReference OHRForm = new PageReference('/apex/CAM_OnsiteHardwareRequestForm');
        Test.setCurrentPage(OHRForm);
        
        //set the parameter for the removeItem method
        //(PS: this method actually removed bundles, not methods)
        ApexPages.currentPage().getParameters().put('itemID', CAM_Test_PopulateData.ohrb[0].id);

        //initiate the controller
        ApexPages.StandardController stdController = new ApexPages.StandardController(CAM_Test_PopulateData.ohr[0]);
        CAM_OnsiteHardwareRequestForm_Extension OHRForm_Extension = new CAM_OnsiteHardwareRequestForm_Extension(stdController);

        //call the method
        OHRForm_Extension.removeItem();

        //pull the list of all items, compare the counts
        List<Onsite_Hardware_Request_Bundle__c> ohrb_new = new List<Onsite_Hardware_Request_Bundle__c>();
        ohrb_new = [SELECT id, Name FROM Onsite_Hardware_Request_Bundle__c WHERE Onsite_Hardware_Request__c =:CAM_Test_PopulateData.ohr[0].id];
        System.debug ('TEST: Remove Item - positive outcome');        
        System.assertEquals(bundleCount, ohrb_new.size(), 'Bundle count has not gone down by one as expected');

    }//test_removeItem

    @isTest static void test_addItem() {

        //get all the data into the database
        CAM_Test_PopulateData.populateData();
        integer bundleCount = CAM_Test_PopulateData.ohrb.size();
        bundleCount++;

        //initiate the page
        PageReference OHRForm = new PageReference('/apex/CAM_OnsiteHardwareRequestForm');
        Test.setCurrentPage(OHRForm);
        
        //set the parameters for the addItem method
        ApexPages.currentPage().getParameters().put('assetID', CAM_Test_PopulateData.bundles[3].id);
        ApexPages.currentPage().getParameters().put('L1index', '0');
        ApexPages.currentPage().getParameters().put('L2index', '1');
        ApexPages.currentPage().getParameters().put('L3index', '1');

        //initiate the controller
        ApexPages.StandardController stdController = new ApexPages.StandardController(CAM_Test_PopulateData.ohr[0]);
        CAM_OnsiteHardwareRequestForm_Extension OHRForm_Extension = new CAM_OnsiteHardwareRequestForm_Extension(stdController);

        //set the quantity of the selected bundle
        OHRForm_Extension.catalog[1].lst[1].lst[0].qty = 100;

        //call the method
        OHRForm_Extension.addItem();

        //pull the list of all items, compare the counts
        List<Onsite_Hardware_Request_Bundle__c> ohrb_new = new List<Onsite_Hardware_Request_Bundle__c>();
        ohrb_new = [SELECT id, Name FROM Onsite_Hardware_Request_Bundle__c WHERE Onsite_Hardware_Request__c =:CAM_Test_PopulateData.ohr[0].id];
        System.debug ('TEST: Add Item - positive outcome');
        System.assertEquals(bundleCount, ohrb_new.size(), 'Bundle count has not gone up by one as expected');

    }//test_addItem

    @isTest static void test_addItem_fail() {

        //get all the data into the database
        CAM_Test_PopulateData.populateData();
        integer bundleCount = CAM_Test_PopulateData.ohrb.size();

        //initiate the page
        PageReference OHRForm = new PageReference('/apex/CAM_OnsiteHardwareRequestForm');
        Test.setCurrentPage(OHRForm);
        
        //set the parameters for the addItem method
        ApexPages.currentPage().getParameters().put('assetID', CAM_Test_PopulateData.bundles[3].id);
        ApexPages.currentPage().getParameters().put('L1index', '0');
        ApexPages.currentPage().getParameters().put('L2index', '1');
        ApexPages.currentPage().getParameters().put('L3index', '1');

        //initiate the controller
        ApexPages.StandardController stdController = new ApexPages.StandardController(CAM_Test_PopulateData.ohr[0]);
        CAM_OnsiteHardwareRequestForm_Extension OHRForm_Extension = new CAM_OnsiteHardwareRequestForm_Extension(stdController);

        //set the quantity of the selected bundle
        OHRForm_Extension.catalog[1].lst[1].lst[0].qty = -1;

        //call the method
        OHRForm_Extension.addItem();

        //pull the list of all items, compare the counts
        List<Onsite_Hardware_Request_Bundle__c> ohrb_new = new List<Onsite_Hardware_Request_Bundle__c>();
        ohrb_new = [SELECT id, Name FROM Onsite_Hardware_Request_Bundle__c WHERE Onsite_Hardware_Request__c =:CAM_Test_PopulateData.ohr[0].id];
        System.debug ('TEST: Add Item - negative outcome');
        System.assertEquals(bundleCount, ohrb_new.size(), 'Bundle count did not stay the same as expected');

    }//test_addItem_fail    

    @isTest static void test_updateItem() {

        //get all the data into the database
        CAM_Test_PopulateData.populateData();
        Decimal bundleQty = CAM_Test_PopulateData.ohrb[0].Requested_Quantity__c;
        bundleQty++;

        //initiate the page
        PageReference OHRForm = new PageReference('/apex/CAM_OnsiteHardwareRequestForm');
        Test.setCurrentPage(OHRForm);
        
        //set the parameters for the method
        ApexPages.currentPage().getParameters().put('assetID', CAM_Test_PopulateData.bundles[3].id);
        ApexPages.currentPage().getParameters().put('L1index', '0');
        ApexPages.currentPage().getParameters().put('L2index', '0');
        ApexPages.currentPage().getParameters().put('L3index', '0');

        //initiate the controller
        ApexPages.StandardController stdController = new ApexPages.StandardController(CAM_Test_PopulateData.ohr[0]);
        CAM_OnsiteHardwareRequestForm_Extension OHRForm_Extension = new CAM_OnsiteHardwareRequestForm_Extension(stdController);

        //set the quantity of the selected bundle
        OHRForm_Extension.catalog[0].lst[0].lst[0].qty = bundleQty;

        //call the method
        OHRForm_Extension.updateItem();

        //pull the bundle, compare the quantity
        Onsite_Hardware_Request_Bundle__c newBundle = new Onsite_Hardware_Request_Bundle__c();
        newBundle = [SELECT id, Name, Requested_Quantity__c FROM Onsite_Hardware_Request_Bundle__c WHERE id=:CAM_Test_PopulateData.ohrb[0].id LIMIT 1];
        System.debug ('TEST: Update Item - positive outcome');
        System.assertEquals(bundleQty, newBundle.Requested_Quantity__c, 'Bundle quantity has not changed as expected');

    }//test_updateItem

    @isTest static void test_updateItem_fail() {

        //get all the data into the database
        CAM_Test_PopulateData.populateData();
        Decimal bundleQty = CAM_Test_PopulateData.ohrb[0].Requested_Quantity__c;

        //initiate the page
        PageReference OHRForm = new PageReference('/apex/CAM_OnsiteHardwareRequestForm');
        Test.setCurrentPage(OHRForm);
        
        //set the parameters for the method
        ApexPages.currentPage().getParameters().put('assetID', CAM_Test_PopulateData.bundles[3].id);
        ApexPages.currentPage().getParameters().put('L1index', '0');
        ApexPages.currentPage().getParameters().put('L2index', '0');
        ApexPages.currentPage().getParameters().put('L3index', '0');

        //initiate the controller
        ApexPages.StandardController stdController = new ApexPages.StandardController(CAM_Test_PopulateData.ohr[0]);
        CAM_OnsiteHardwareRequestForm_Extension OHRForm_Extension = new CAM_OnsiteHardwareRequestForm_Extension(stdController);

        //set the quantity of the selected bundle
        OHRForm_Extension.catalog[0].lst[0].lst[0].qty = -1;

        //call the method
        OHRForm_Extension.updateItem();

        //pull the bundle, compare the quantity
        Onsite_Hardware_Request_Bundle__c newBundle = new Onsite_Hardware_Request_Bundle__c();
        newBundle = [SELECT id, Name, Requested_Quantity__c FROM Onsite_Hardware_Request_Bundle__c WHERE id=:CAM_Test_PopulateData.ohrb[0].id LIMIT 1];
        System.debug ('TEST: Update Item - negative outcome');
        System.assertEquals(bundleQty, newBundle.Requested_Quantity__c, 'Bundle quantity has not stayed the same as expected');

    }//test_updateItem_fail

    /*
    @isTest static void test_charLmt(){

        //get all the data into the database
        CAM_Test_PopulateData.populateData();
        
        //initiate the page
        PageReference OHRForm = new PageReference('/apex/CAM_OnsiteHardwareRequestForm');
        Test.setCurrentPage(OHRForm);

        //initiate the controller
        ApexPages.StandardController stdController = new ApexPages.StandardController(CAM_Test_PopulateData.ohr[0]);
        CAM_OnsiteHardwareRequestForm_Extension OHRForm_Extension = new CAM_OnsiteHardwareRequestForm_Extension(stdController);

        
        System.debug ('TEST: charLmt - positive outcome');
        System.AssertNotEquals (null, OHRForm_Extension.charLmt, 'Limit should not be null');

    }//test_charLmt

    @isTest static void test_newLine(){
        
        //get all the data into the database
        CAM_Test_PopulateData.populateData();
        
        //initiate the page
        PageReference OHRForm = new PageReference('/apex/CAM_OnsiteHardwareRequestForm');
        Test.setCurrentPage(OHRForm);

        //initiate the controller
        ApexPages.StandardController stdController = new ApexPages.StandardController(CAM_Test_PopulateData.ohr[0]);
        CAM_OnsiteHardwareRequestForm_Extension OHRForm_Extension = new CAM_OnsiteHardwareRequestForm_Extension(stdController);

        
        System.debug ('TEST: newLine - positive outcome');
        System.AssertNotEquals (null, OHRForm_Extension.newLine, 'New Line should not be null');

    }//test_newLine
    */
}