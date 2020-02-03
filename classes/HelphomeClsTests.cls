@isTest
public class HelphomeClsTests {

    public static testMethod void testMyController() {
        PageReference pageRef = Page.helphome;
        Test.setCurrentPage(pageRef);
      
      Cvent_product__c obj = new Cvent_product__c();
      obj.Name = 'test';
      obj.IsActive__c = TRUE;
      obj.Order__c = 1;
            insert obj;
            
            Popular_Article__c popObj = new Popular_Article__c();
            popObj.Article_URL__c = '/apex/test';
            popObj.Name = 'Test';
            popObj.Cvent_Product__c = obj.Id;
            popObj.Order__c = 1;
            popObj.IsActive__c=TRUE;
            insert popObj;
            
            Announcements__c annObj = new Announcements__c();
            annObj.Data__c = 'Test';
            annObj.Is_it_Pime__c = TRUE;
            annObj.Is_Active__c = TRUE;
            insert annObj;
            
            Community_Country_ISD_Codes__c cc = new Community_Country_ISD_Codes__c();
            cc.Country_Name__c   = 'United States';
            cc.Name = 'USA';
            cc.ISD_Code__c = '1';
            insert cc;
            
        HelphomeCls thecontroller = new HelphomeCls();
        thecontroller.selectedname = 'USA';
        thecontroller.phoneNumber = '09716549377';
        thecontroller.selectedLanguage = 'English';
        thecontroller.search();
        thecontroller.requestCall();
        thecontroller.pageDirect();
        //String nextPage = controller.save().getUrl();

        // Verify that page fails without parameters
        //System.assertEquals('/apex/failure?error=noParam', nextPage);

        // Add parameters to page URL
        //ApexPages.currentPage().getParameters().put('qp', 'yyyy');
      
        // Instantiate a new controller with all parameters in the page
        
        
    }
}