@istest
public class ScrubGDPRRepositoryClassTest{
    // this method is for class : GDPRRequestManagementController
    public static String[] csvFileLines;
    public static Blob csvFileBody;

    public static testMethod void GDPRController(){

        case caseObj = new case();
        caseObj.SuppliedEmail  = 'test@gmail.com';
        caseObj.Type = 'Request to rectify';
        caseObj.Developer_Use_GDPR__c  = 'WebToCase-GDPR';
        caseObj.Status ='Open';
        caseObj.Subject='Open case';
        insert caseObj;

        GDPRRequestManagementController cont = new GDPRRequestManagementController();
        PageReference pref = Page.GDPRRequestManagement;
        pref.getParameters().put('caseID', caseObj.id);
        Test.setCurrentPage(pref);
        cont.approveRequest();
        cont.ignoreRequest();
        cont.checkExpiration() ;

        caseObj.Is_GDPR__c  = true;
        update caseObj;   

        String str = 'EmailId \n test@gmail.com'; 
        csvFileBody = Blob.valueOf(str);
        String csvAsString = csvFileBody.toString();
        csvFileLines = csvAsString.split('\n');
        
        ScrubGDPRRepositoryClass scrub = new ScrubGDPRRepositoryClass();
        scrub.csvFileBody = csvFileBody;
        scrub.compareRecords();

    }
}