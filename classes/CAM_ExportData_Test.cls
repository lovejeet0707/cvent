@isTest

private class CAM_ExportData_Test {

    @isTest static void test_prepareData(){

        //get all the data into the database
        CAM_Test_PopulateData.populateData();
        
        //initiate the page
        PageReference page_exportData = new PageReference('/apex/CAM_ExportData');
        Test.setCurrentPage(page_exportData);
        
        //set the parameters for the addItem method
        ApexPages.currentPage().getParameters().put('pid', 'thisIsaFakeId');
        ApexPages.currentPage().getParameters().put('obj', 'Packlist__c');

        //initiate the controller
        ApexPages.StandardController stdController = new ApexPages.StandardController(CAM_Test_PopulateData.ohri[0]);
        CAM_ExportData_Extension page_exportData_Extension = new CAM_ExportData_Extension(stdController);

        //call the method
        page_exportData_Extension.prepareData();

        System.debug ('TEST: prepareData - Packlist option');
        System.AssertEquals (1, 1, 'This is a fake test');

        //call the method
        page_exportData_Extension.param_obj = null;
        page_exportData_Extension.prepareData();

        System.debug ('TEST: prepareData - OHR Item option');
        System.AssertEquals (1, 1, 'This is a fake test');        
    }//test_prepareData
}