@isTest

private class CAM_PrepareShipmentFromPacklist_Test {

    @isTest static void test_all(){

        //get all the data into the database
        CAM_Test_PopulateData.populateData();
        
        //initiate the page
        PageReference page_prepareShipmentFromPacklist = new PageReference('/apex/CAM_PrepareShipmentFromPacklist');
        Test.setCurrentPage(page_prepareShipmentFromPacklist);
        
        //initiate the controller
        ApexPages.StandardController stdController = new ApexPages.StandardController(CAM_Test_PopulateData.packlists[0]);
        CAM_PrepareShipmentFromPacklist_E page_prepareShipmentFromPacklist_Extension = new CAM_PrepareShipmentFromPacklist_E(stdController);

        //call the method
        page_prepareShipmentFromPacklist_Extension.refreshthePacklist();
        PageReference p = page_prepareShipmentFromPacklist_Extension.redirectMe();

        System.debug ('TEST: PrepareShipmentFromPacklist - positive outcome');
        System.AssertNotEquals (null, p, 'PageReference should not be null');

    }//test_all
}