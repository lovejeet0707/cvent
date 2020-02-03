@isTest
public class CRMHelp_ControllerTest{

    public static testMethod void testMyController() {
        
        Case caseRec = new Case();
        caseRec.Subject = 'Test';
        insert caseRec;
        
        CRM_Help__c crmObj = new CRM_Help__c();
        crmObj.Category__c = 'CPQ';
        crmObj.Issue__c = 'CPQ';
        crmObj.Keywords__c = 'CPQ';
        crmObj.Process__c= 'Opportunity';
        crmObj.Resolution__c= 'CPQ';
        
        
        insert crmObj;
        
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = crmObj.Id;
        Test.setFixedSearchResults(fixedSearchResults);
        
        PageReference pageRef = Page.CRMHelp;
        Test.setCurrentPage(pageRef);
      
        CRMHelp_Controller controller = new CRMHelp_Controller();
        

        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('subject', 'CPQ');
        List<List<SObject>> searchList = [FIND 'CPQ' IN ALL FIELDS RETURNING CRM_Help__c(Id,Category__c,Keywords__c,Resolution__c,Issue__c)];
  
        CRMHelp_Controller.searchArticle('CPQ');
        
        
        
        
        PageReference pref = Page.CRMHelpDetail;
        pref.getParameters().put('id',crmObj.id);
        pref.getParameters().put('caseId',caseRec.id);
        Test.setCurrentPage(pref);
        
        Salesforce_Article__c sfArticle = new Salesforce_Article__c();
        sfArticle.Case_Number__c = caseRec.Id;
        sfArticle.CRM_Help__c = crmObj.Id;
        insert sfArticle;
        
        ApexPages.StandardController con = new ApexPages.StandardController(crmObj);
        CRMHelpDetailController ext = new CRMHelpDetailController(con);
        ext.attachCase();
    }
}