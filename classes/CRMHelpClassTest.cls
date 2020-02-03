@isTest
public class CRMHelpClassTest{
    static testMethod void unitMethod(){
        CRM_Help__c crmHelp = new CRM_Help__c();
        crmHelp.Category__c = 'CPQ';
        crmHelp.Issue__c = 'Test';
        crmHelp.Keywords__c = 'Test';
        crmHelp.Problem__c = 'Test';
        crmHelp.Process__c = 'Opportunity';
        crmHelp.Resolution__c = 'Test';
        crmHelp.Responsible_Team__c = 'CRM';
        
        insert crmHelp;
        
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = crmHelp.Id;
        Test.setFixedSearchResults(fixedSearchResults);
        
        Test.setCurrentPageReference(new PageReference('Page.CRMSearch')); 
        System.currentPageReference().getParameters().put('searchFor', 'Test');
        List<List<SObject>> searchList = [FIND 'CPQ' IN ALL FIELDS RETURNING CRM_Help__c(Id,Category__c,Keywords__c,Resolution__c,Issue__c)];

        CRMHelpClass cc= new CRMHelpClass();
    }
}