/**
//////////////////////////////////////
//      @author Abhishek Pandey     //
/////////////////////////////////////
Version :   1.0
Date : 27th June 2014
 */
@isTest
private class OpportunityRecordTypeSelClsTest {

    static testMethod void myUnitTest() {
        Opportunity instOfOpp = new Opportunity();
        
        Account instofAcc = new Account();
        
        RecordType rtType = [SELECT r.SobjectType, r.DeveloperName,r.IsActive FROM RecordType r WHERE SobjectType='Account' And DeveloperName='Biz_Ac' And IsActive=true];
        instofAcc.Name = 'Test';
        //instofAcc.CurrencyIsoCode  = 'USD';
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        instofAcc.RecordTypeId = rtType.id;
        insert instofAcc;
        
        Contact instofCon =  new Contact();
        instOfCon.LastName = 'Test';
        instOfCon.AccountId = instofAcc.Id;
        insert instOfCon;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(instOfOpp);
        Apexpages.currentPage().getParameters().put('conid', instOfCon.id);
        OpportunityRecordTypeSelCls instOfOppREcTyCls = new OpportunityRecordTypeSelCls(sc);
        instOfOppREcTyCls.cancel();
        instOfOppREcTyCls.continueMeth();
        instOfOppREcTyCls.testMethod_New();
        instOfOppREcTyCls.testMethod_New1();
    }
}