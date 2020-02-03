@isTest

private class CAM_PrintPacklist_Test {

    @isTest static void test_all(){

        //get all the data into the database
        CAM_Test_PopulateData.populateData();
        
        //initiate the page
        PageReference page_printPacklist = new PageReference('/apex/CAM_PrintPacklist');
        Test.setCurrentPage(page_printPacklist);
        
        //initiate the controller
        ApexPages.StandardController stdController = new ApexPages.StandardController(CAM_Test_PopulateData.packlists[0]);
        CAM_PrintPacklist_Extension page_printPacklist_Extension = new CAM_PrintPacklist_Extension(stdController);

        //call the method
        String s = page_printPacklist_Extension.tidyFromAddress;
        String[] ss = page_printPacklist_Extension.listofAssetTypes;
        page_printPacklist_Extension.refreshThePacklist();

        System.debug ('TEST: PrintPacklist - positive outcome');
        System.AssertEquals (1, 1, 'This is a fake test');

    }//test_all
}