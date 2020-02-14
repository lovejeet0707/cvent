/**
//////////////////////////////////////
//      @author Abhishek Pandey     //
/////////////////////////////////////
Version :   1.0
Date : 27th October 2014
 */
@isTest
private class MassEditOppControllerTest {

    static testMethod void myUnitTest() {
        apexpages.currentpage().getparameters().put('retURL','www.google.com');
        RecordType rtType = [SELECT r.SobjectType, r.DeveloperName,r.IsActive FROM RecordType r WHERE SobjectType='Account' And DeveloperName='Biz_Ac' And IsActive=true];
        Account instofAcc = new Account();
        instofAcc.Name = 'Test';
        //instofAcc.CurrencyIsoCode  = 'USD';
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        instofAcc.RecordTypeId = rtType.id;
        insert instofAcc;
        Contact instOfCon = new Contact();
        instOfCon.LastName = 'Test';
        instOfCon.AccountId = instofAcc.Id;
        insert instOfCon;
        
        Opportunity instOfOpp = new Opportunity();
        instOfOpp.AccountId = instofAcc.id;
        instOfOpp.Name = 'Test';
        instOfOpp.Product__c = 'Event';
        instOfOpp.New_Type__c =  'Upsell-NBB';
        instOfOpp.StageName = 'Verbal';
        instOfOpp.CloseDate = system.today();
        instOfOpp.New_Amount__c = 11;
        instOfOpp.Years__c= '1';
        instOfOpp.LeadSource = 'ACD-PS';
        instOfOpp.Contact_Associated__c = instOfCon.Id;
        instOfOpp.Contact_Role__c = 'Primary User';
        instOfOpp.Contract_Implemented__c = true;
        instOfOpp.ContractReceived__c = system.today();
        instOfOpp.Deal_Year__c = '1';
        insert instOfOpp;
        List<Opportunity> lstOpp = new List<Opportunity>();
        lstOpp.add(instOfOpp); 
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(lstOpp);
        MassEditOppController instOfMEOC = new MassEditOppController (sc);
        instOfMEOC.save();
    }
    
    static testMethod void myUnitTestSec() {
        apexpages.currentpage().getparameters().put('retURL','www.google.com');
        RecordType rtType = [SELECT r.SobjectType, r.DeveloperName,r.IsActive FROM RecordType r WHERE SobjectType='Account' And DeveloperName='Biz_Ac' And IsActive=true];
        Account instofAcc = new Account();
        instofAcc.Name = 'Test';
        //instofAcc.CurrencyIsoCode  = 'USD';
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        instofAcc.RecordTypeId = rtType.id;
        insert instofAcc;
        Contact instOfCon = new Contact();
        instOfCon.LastName = 'Test';
        instOfCon.AccountId = instofAcc.Id;
        insert instOfCon;
        
        Opportunity instOfOpp = new Opportunity();
        instOfOpp.AccountId = instofAcc.id;
        instOfOpp.Name = 'Test';
        instOfOpp.Product__c = 'Event';
        instOfOpp.New_Type__c =  'Upsell-NBB';
        instOfOpp.StageName = 'Verbal';
        instOfOpp.CloseDate = system.today().adddays(40);
        instOfOpp.New_Amount__c = 11;
        instOfOpp.Years__c= '1';
        instOfOpp.LeadSource = 'ACD-PS';
        instOfOpp.Contact_Associated__c = instOfCon.Id;
        instOfOpp.Contact_Role__c = 'Primary User';
        instOfOpp.Contract_Implemented__c = false;
        instOfOpp.ContractReceived__c = system.today();
        instOfOpp.Deal_Year__c = '1';
        insert instOfOpp;
        List<Opportunity> lstOpp = new List<Opportunity>();
        lstOpp.add(instOfOpp); 
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(lstOpp);
        MassEditOppController instOfMEOC = new MassEditOppController (sc);
        instOfOpp.StageName = 'Closed Won';
        instOfMEOC.selected.add(instOfOpp);
        instOfMEOC.save();
    }
}