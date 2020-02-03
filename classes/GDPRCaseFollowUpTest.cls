@istest
public class GDPRCaseFollowUpTest{

    static testmethod void runtest(){
        
        Account acc = new Account();
        acc.name = 'Test GDPR';
        acc.BillingCountry='MX';
        insert acc;
        
        Contact con = new Contact();
        con.AccountId = acc.id;
        con.LastName = 'GDPR Testing';
        insert con;
        
        
        case c = new case();
        c.ContactId = con.id;
        //c.Requester_s_Email__c = 'udwivedi@cvent.com';
        c.Subject = 'testCase For GDPR enhancements';
        c.Type ='Request to be forgotten';
        c.SuppliedEmail= 'udwivedi@cvent.com';
        c.Origin = 'Web2Case';
        c.Developer_Use_GDPR__c ='WebToCase-GDPR' ;
        c.RecordTypeId  = Schema.SObjectType.Case.getRecordTypeInfosByName().get('GDPR Request').getRecordTypeId() ;
        c.Status = 'Open – Approved';
        insert c;
        case caseObj = new case(id =c.id);
        caseObj.status ='Open – Approved';
        update caseObj;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(caseObj);        
        GDPRCaseFollowUpClass controller = new GDPRCaseFollowUpClass(sc);
        
        controller.editGDPRRecords();
        controller.saveGDPRRecords();
        controller.Cancel();
        
     
    }

}