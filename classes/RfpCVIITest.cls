@istest
public class RfpCVIITest{
    
    static testMethod void myUnitTest() {
        Account instofAcc = new Account();
        
        RecordType rtType = [SELECT r.SobjectType, r.DeveloperName,r.IsActive FROM RecordType r WHERE SobjectType='Account' And DeveloperName='Biz_Ac' And IsActive=true];
        instofAcc.Name = 'Test';
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        instofAcc.RecordTypeId = rtType.id;
        insert instofAcc;
        Rfp__c instOfRfp = new Rfp__c();
        instOfRfp.Supplier_Account__c = instofAcc.Id;
        instOfRfp.Name = 'Test';
        instOfRfp.RFP_Code__c= 'acder';
        instOfRfp.Unique_Code__c = '23de';
        insert instOfRfp;
        ApexPages.StandardController sc = new ApexPages.StandardController(instOfRfp);
        Apexpages.currentPage().getParameters().put('id', instOfRfp.id);
        RfpCVII instII = new RfpCVII (sc );
    }
}