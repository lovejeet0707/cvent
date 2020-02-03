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
        Account instofAcc = TestUtil.createAccount('Test Account','Biz_Ac');
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        insert instofAcc;
        Contact instOfCon = TestUtil.createContact(String.valueOf(instofAcc.Id));
        insert instOfCon;
        
        Opportunity instOfOpp = TestUtil.createOpportunityNew('test','Verbal',instOfCon.Id,instofAcc.Id);
        instOfOpp.Product__c = 'Event';
        instOfOpp.New_Type__c =  'Upsell-NBB';
        instOfOpp.CloseDate = system.today();
        instOfOpp.New_Amount__c = 11;
        instOfOpp.Years__c= '1';
        instOfOpp.LeadSource = 'ACD-PS';
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
        Account instofAcc = TestUtil.createAccount('Test Account','Biz_Ac');
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        insert instofAcc;
        Contact instOfCon = TestUtil.createContact(String.valueOf(instofAcc.Id));
        insert instOfCon;
        
        Opportunity instOfOpp = TestUtil.createOpportunityNew('test','Verbal',instOfCon.Id,instofAcc.Id);
        instOfOpp.Product__c = 'Event';
        instOfOpp.New_Type__c =  'Upsell-NBB';
        instOfOpp.CloseDate = system.today().adddays(40);
        instOfOpp.New_Amount__c = 11;
        instOfOpp.Years__c= '1';
        instOfOpp.LeadSource = 'ACD-PS';
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