@isTest

private class CAM_PreparePacklist_Test {

    @isTest static void test_newLine(){
        
        //get all the data into the database
        CAM_Test_PopulateData.populateData();
        
        //initiate the page
        PageReference PreparePacklist = new PageReference('/apex/CAM_PreparePacklist');
        Test.setCurrentPage(PreparePacklist);

        //initiate the controller
        ApexPages.StandardSetController stdController = new ApexPages.StandardSetController(CAM_Test_PopulateData.ohri);
        CAM_PreparePacklist_Extension PreparePacklist_Extension = new CAM_PreparePacklist_Extension(stdController);

        
        System.debug ('TEST: newLine - positive outcome');
        System.AssertNotEquals (null, PreparePacklist_Extension.newLine, 'New Line should not be null');

    }//test_newLine

    @isTest static void test_splitItem(){
        
        //get all the data into the database
        CAM_Test_PopulateData.populateData();
        integer originalCount = CAM_Test_PopulateData.ohri.size();
        originalCount++;
        
        //initiate the page
        PageReference PreparePacklist = new PageReference('/apex/CAM_PreparePacklist');
        ApexPages.currentPage().getParameters().put('id', CAM_Test_PopulateData.ohr[0].id);
        Test.setCurrentPage(PreparePacklist);

        //set the parameters for the addItem method
        ApexPages.currentPage().getParameters().put('itemIdToBeSplit', CAM_Test_PopulateData.ohri[0].id);
        ApexPages.currentPage().getParameters().put('L1index', '0');
        ApexPages.currentPage().getParameters().put('L2index', '0');

        //initiate the controller
        ApexPages.StandardSetController stdController = new ApexPages.StandardSetController(CAM_Test_PopulateData.ohri);
        CAM_PreparePacklist_Extension PreparePacklist_Extension = new CAM_PreparePacklist_Extension(stdController);

        

        //call the method
        PreparePacklist_Extension.pageID = CAM_Test_PopulateData.ohr[0].id;
        PreparePacklist_Extension.refreshTheRequest();
        PreparePacklist_Extension.refreshItems();
        PreparePacklist_Extension.getWarehouses();
        PreparePacklist_Extension.splitItem();

        //get the new count of items
        List<Onsite_Hardware_Request_Item__c> ohri_new = new List<Onsite_Hardware_Request_Item__c>();
        ohri_new = [SELECT id, Name FROM Onsite_Hardware_Request_Item__c WHERE Onsite_Hardware_Request__c =:CAM_Test_PopulateData.ohr[0].id];

        System.debug ('TEST: splitItem - positive outcome');
        System.AssertEquals (originalCount, ohri_new.size(), 'The item count did not increase by one as expected');

    }//test_splitItem

    @isTest static void test_createPacklists(){
        
        //get all the data into the database
        CAM_Test_PopulateData.populateData();
        integer originalCount = CAM_Test_PopulateData.packlists.size();
        originalCount++;
        
        //initiate the page
        PageReference PreparePacklist = new PageReference('/apex/CAM_PreparePacklist');
        ApexPages.currentPage().getParameters().put('id', CAM_Test_PopulateData.ohr[0].id);
        Test.setCurrentPage(PreparePacklist);

        //set the parameters for the addItem method
        ApexPages.currentPage().getParameters().put('itemIdToBeSplit', CAM_Test_PopulateData.ohri[0].id);
        ApexPages.currentPage().getParameters().put('L1index', '0');
        ApexPages.currentPage().getParameters().put('L2index', '0');

        //initiate the controller
        ApexPages.StandardSetController stdController = new ApexPages.StandardSetController(CAM_Test_PopulateData.ohri);
        CAM_PreparePacklist_Extension PreparePacklist_Extension = new CAM_PreparePacklist_Extension(stdController);

        //initiate the Lists and imitate selecting the warehouses
        PreparePacklist_Extension.pageID = CAM_Test_PopulateData.ohr[0].id;
        PreparePacklist_Extension.refreshTheRequest();
        PreparePacklist_Extension.refreshItems();
        PreparePacklist_Extension.getWarehouses();
        for (integer i1=0; i1<PreparePacklist_Extension.assets.size(); i1++){
            for (integer i2=0; i2<PreparePacklist_Extension.assets[i1].lst.size(); i2++){
                PreparePacklist_Extension.assets[i1].lst[i2].warehouse = CAM_Test_PopulateData.warehouses[0].id;
                PreparePacklist_Extension.assets[i1].lst[i2].reqItem.Packlist_Quantity__c = 1;
            }
        }

        //call the method
        PreparePacklist_Extension.createPacklists();

        //get the new count of Packlists
        List<Packlist__c> packlists_new = new List<Packlist__c>();
        packlists_new = [SELECT id, Name FROM Packlist__c WHERE Onsite_Hardware_Request__c =:CAM_Test_PopulateData.ohr[0].id];

        System.debug ('TEST: createPacklists - positive outcome');
        System.AssertEquals (originalCount, packlists_new.size(), 'The packlist count did not increase by one as expected');

    }//test_createPacklists



}