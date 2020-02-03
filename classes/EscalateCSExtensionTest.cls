@isTest
public class EscalateCSExtensionTest{
    static testmethod void validateStandardController(){
        Case caseObj=new Case();
        caseObj.Requestor_Department__c='Finance';
        caseObj.Status='New';
        caseObj.Description='Test Case';
        caseObj.Subject='Test Subject';
        insert caseObj;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(caseObj);
        EscalateCSExtension extensionClass=new EscalateCSExtension(sc);
        PageReference pageRef = Page.EscalateCS;
        pageRef.getParameters().put('id', String.valueOf(caseObj.Id));
        Test.setCurrentPage(pageRef);
    
        extensionClass.save();
        extensionClass.cancel();
    }
}