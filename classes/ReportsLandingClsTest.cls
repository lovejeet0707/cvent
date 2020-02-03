/**
//////////////////////////////////////
//      @author Abhishek Pandey     //
/////////////////////////////////////
Version :   1.0
Date : 23th June 2014
Description : To test class ReportsLandingCls,QuotaAttainmentScreenCls,QuotaVsBudgetReportCls
 */
@isTest
private class ReportsLandingClsTest {
    static User testUser;
    static User testUserSec; 
    static User testUserThir;    
    static User testUserFor;
    static{
        Profile p = [select id from profile where name='System Administrator'];

        testUser = new User(alias = 'u1', email='u1@testorg.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = p.Id, 
        timezonesidkey='America/Los_Angeles', username='u1asdfed@testorg.com');
        
        insert testUser;
        

        testUserSec = new User(alias = 'u1', email='u1@testorg.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = p.Id, 
        timezonesidkey='America/Los_Angeles', username='u1ewwxex@testorg.com');
        
        insert testUserSec;
        
        testUserThir = new User(alias = 'u1', email='u1@testorg.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = p.Id, 
        timezonesidkey='America/Los_Angeles', username='u1ewdddwxex@testorg.com');
        
        insert testUserThir;
        
        testUserFor = new User(alias = 'u1', email='u1@testorg.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = p.Id, 
        timezonesidkey='America/Los_Angeles', username='u1ewddddddwxex@testorg.com');
        
        insert testUserFor;
        
        List<Quota_Attainment__c> qAttainmentList = new List<Quota_Attainment__c> ();
        
        Quota_Attainment__c instOFQA = new Quota_Attainment__c();
        instOFQA.Name = '1';
        instOFQA.User_Id__c = testUser.Id;
        instOFQA.Team_Role__c = 'Event';
        instOFQA.Quota_Year__c = integer.valueOf(system.now().year() + '.0');
        instOFQA.User_Name__c = 'Test';
        instOFQA.NBB_Licensing_Monthly__c = '100;100;100;100;100;100;100;100;100;100;100;100';
        instOFQA.NBB_PSG_Monthly__c = '100;100;100;100;100;100;100;100;100;100;100;100';
        instOFQA.Renewal_Monthly__c = '100;100;100;100;100;100;100;100;100;100;100;100';
        instOFQA.Role__c = 'Direct Sales';
        qAttainmentList.Add(instOFQA);
        
        Quota_Attainment__c instOFQASec = new Quota_Attainment__c();
        instOFQASec.Name = '2';
        instOFQASec.User_Id__c = testUserSec.Id;
        instOFQASec.Team_Role__c = 'Survey';
        instOFQASec.Quota_Year__c = integer.valueOf(system.now().year() + '.0');
        instOFQASec.User_Name__c = 'Test2';
        instOFQASec.NBB_Licensing_Monthly__c = '100;100;100;100;100;100;100;100;100;100;100;100';
        instOFQASec.NBB_PSG_Monthly__c = '100;100;100;100;100;100;100;100;100;100;100;100';
        instOFQASec.Renewal_Monthly__c = '100;100;100;100;100;100;100;100;100;100;100;100';
        instOFQASec.Role__c = 'AM';
        qAttainmentList.Add(instOFQASec);
        
        Quota_Attainment__c instOFQAThir = new Quota_Attainment__c();
        instOFQAThir.Name = '3';
        instOFQAThir.User_Id__c = testUserThir.Id;
        instOFQAThir.Team_Role__c = 'Event';
        instOFQAThir.Quota_Year__c = integer.valueOf(system.now().year() + '.0');
        instOFQAThir.User_Name__c = 'Test';
        instOFQAThir.NBB_Licensing_Monthly__c = '100;100;100;100;100;100;100;100;100;100;100;100';
        instOFQAThir.NBB_PSG_Monthly__c = '100;100;100;100;100;100;100;100;100;100;100;100';
        instOFQAThir.Renewal_Monthly__c = '100;100;100;100;100;100;100;100;100;100;100;100';
        instOFQAThir.Role__c = 'Direct Sales';
        qAttainmentList.Add(instOFQAThir);
        
        Quota_Attainment__c instOFQAFor = new Quota_Attainment__c();
        instOFQAFor.Name = '4';
        instOFQAFor.User_Id__c = testUserFor.Id;
        instOFQAFor.Team_Role__c = 'Survey';
        instOFQAFor.Quota_Year__c = integer.valueOf(system.now().year() + '.0');
        instOFQAFor.User_Name__c = 'Test';
        instOFQAFor.NBB_Licensing_Monthly__c = '100;100;100;100;100;100;100;100;100;100;100;100';
        instOFQAFor.NBB_PSG_Monthly__c = '100;100;100;100;100;100;100;100;100;100;100;100';
        instOFQAFor.Renewal_Monthly__c = '100;100;100;100;100;100;100;100;100;100;100;100';
        instOFQAFor.Role__c = 'AM';
        qAttainmentList.Add(instOFQAFor);
        
        Account instofAcc = new Account();
        RecordType rtType = [SELECT r.SobjectType, r.DeveloperName,r.IsActive FROM RecordType r WHERE SobjectType='Account' And DeveloperName='Biz_Ac' And IsActive=true];
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
        
        List<Opportunity> oppstoInsertList = new List<Opportunity> ();
        
        
        Opportunity instOfOpp = new Opportunity();
        instOfOpp.AccountId = instofAcc.id;
        instOfOpp.Name = 'Test';
        instOfOpp.Product__c = 'Event';
        instOfOpp.Contract_Type_Test__c = 'NBB';
        instOfOpp.StageName = 'Closed Won';
        instOfOpp.CloseDate = system.today();
        instOfOpp.New_Amount__c = 110;
        instOfOpp.Years__c= '1';
        instOfOpp.LeadSource = 'ACD-PS';
        instOfOpp.Contact_Associated__c = instOfCon.Id;
        instOfOpp.Contact_Role__c = 'Primary User';
        instOfOpp.Contract_Implemented__c = true;
        instOfOpp.ContractReceived__c = system.today();
        instOfOpp.OwnerId = instOFQA.User_Id__c;
        
        insert instOfOpp;
        
        /*oppstoInsertList.Add(instOfOpp);
        
        Opportunity instOfOppSec = new Opportunity();
        instOfOppSec.AccountId = instofAcc.id;
        instOfOppSec.Name = 'Test';
        instOfOppSec.Product__c = 'Event';
        instOfOppSec.Contract_Type_Test__c = 'NBB';
        instOfOppSec.StageName = 'Closed Won';
        instOfOppSec.CloseDate = system.today();
        instOfOppSec.New_Amount__c = 110;
        instOfOppSec.Years__c= '1';
        instOfOppSec.LeadSource = 'ACD-PS';
        instOfOppSec.Contact_Associated__c = instOfCon.Id;
        instOfOppSec.Contact_Role__c = 'Primary User';
        instOfOppSec.Contract_Implemented__c = true;
        instOfOppSec.ContractReceived__c = system.today();
        instOfOppSec.OwnerId = instOFQASec.User_Id__c;
        oppstoInsertList.Add(instOfOppSec);
        
        Opportunity instOfOppThir = new Opportunity();
        instOfOppThir.AccountId = instofAcc.id;
        instOfOppThir.Name = 'Test';
        instOfOppThir.Product__c = 'Event';
        instOfOppThir.Contract_Type_Test__c = 'Renewal';
        instOfOppThir.StageName = 'Closed Won';
        instOfOppThir.CloseDate = system.today();
        instOfOppThir.New_Amount__c = 110;
        instOfOppThir.Years__c= '1';
        instOfOppThir.LeadSource = 'ACD-PS';
        instOfOppThir.Contact_Associated__c = instOfCon.Id;
        instOfOppThir.Contact_Role__c = 'Primary User';
        instOfOppThir.Contract_Implemented__c = true;
        instOfOppThir.ContractReceived__c = system.today();
        instOfOppThir.OwnerId = instOFQASec.User_Id__c;
        oppstoInsertList.Add(instOfOppThir);
        
        Opportunity instOfOppFourth = new Opportunity();
        instOfOppFourth.AccountId = instofAcc.id;
        instOfOppFourth.Name = 'Test';
        instOfOppFourth.Product__c = 'Survey';
        instOfOppFourth.Contract_Type_Test__c = 'NBB';
        instOfOppFourth.StageName = 'Closed Won';
        instOfOppFourth.CloseDate = system.today();
        instOfOppFourth.New_Amount__c = 110;
        instOfOppFourth.Years__c= '1';
        instOfOppFourth.LeadSource = 'ACD-PS';
        instOfOppFourth.Contact_Associated__c = instOfCon.Id;
        instOfOppFourth.Contact_Role__c = 'Primary User';
        instOfOppFourth.Contract_Implemented__c = true;
        instOfOppFourth.ContractReceived__c = system.today();
        instOfOppFourth.OwnerId = instOFQASec.User_Id__c;
        instOfOppFourth.License_Type__c = 'Professional Services';
        oppstoInsertList.Add(instOfOppFourth);        
        
        Opportunity instOfOppFifth = new Opportunity();
        instOfOppFifth.AccountId = instofAcc.id;
        instOfOppFifth.Name = 'Test';
        instOfOppFifth.Product__c = 'Survey';
        instOfOppFifth.Contract_Type_Test__c = 'NBB';
        instOfOppFifth.StageName = 'Closed Won';
        instOfOppFifth.CloseDate = system.today();
        instOfOppFifth.New_Amount__c = 110;
        instOfOppFifth.Years__c= '1';
        instOfOppFifth.LeadSource = 'ACD-PS';
        instOfOppFifth.Contact_Associated__c = instOfCon.Id;
        instOfOppFifth.Contact_Role__c = 'Primary User';
        instOfOppFifth.Contract_Implemented__c = true;
        instOfOppFifth.ContractReceived__c = system.today();
        instOfOppFifth.OwnerId = instOFQASec.User_Id__c;
        instOfOppFifth.License_Type__c = 'Professional Services';
        oppstoInsertList.Add(instOfOppFifth);
        
        Opportunity instOfOppSix = new Opportunity();
        instOfOppSix.AccountId = instofAcc.id;
        instOfOppSix.Name = 'Test';
        instOfOppSix.Product__c = 'Event';
        instOfOppSix.Contract_Type_Test__c = 'NBB';
        instOfOppSix.StageName = 'Closed Won';
        instOfOppSix.CloseDate = system.today();
        instOfOppSix.New_Amount__c = 110;
        instOfOppSix.Years__c= '1';
        instOfOppSix.LeadSource = 'ACD-PS';
        instOfOppSix.Contact_Associated__c = instOfCon.Id;
        instOfOppSix.Contact_Role__c = 'Primary User';
        instOfOppSix.Contract_Implemented__c = true;
        instOfOppSix.ContractReceived__c = system.today();
        instOfOppSix.OwnerId = instOFQA.User_Id__c;
        oppstoInsertList.Add(instOfOppSix);
        
        insert oppstoInsertList; */
        
    }
    
    static testMethod void myUnitTest() {
        
        QuotaAttainmentScreenCls instOFQASC = new QuotaAttainmentScreenCls();
        QuotaAttainmentScreenCls.loadOppsSec();
        QuotaAttainmentScreenCls.loadOpps();
        
        instOFQASC.test();
        ReportsLandingCls instOFRepLan = new ReportsLandingCls();
        instOFRepLan.text  = 'BudVsAc';
        instOFRepLan.setRedirections();
        instOFRepLan.text  = 'QuotaA';
        instOFRepLan.setRedirections();
        instOFRepLan.text  = 'LSCR';
        instOFRepLan.setRedirections();
        
        QuotaVsBudgetReportCls instOfQVBRC = new QuotaVsBudgetReportCls();
        QuotaVsBudgetReportCls.monthFrom = 'Test';
        QuotaVsBudgetReportCls.monthTo = 'test';
        QuotaVsBudgetReportCls.masterTypeSelection = 'test';
        QuotaVsBudgetReportCls.topScorerSelection = 'test';
        QuotaVsBudgetReportCls.quotaYearSel = 'test';
        QuotaVsBudgetReportCls.roleSel = 'test';
        QuotaVsBudgetReportCls.teamSelected = 'Direct Sales';
        QuotaVsBudgetReportCls.productSelection = 'Survey';
        instOfQVBRC.qTypVal();
        
        QuotaVsBudgetReportCls.teamSelected = 'AM';
        QuotaVsBudgetReportCls.productSelection = 'Survey';
        instOfQVBRC.qTypVal();
        
        QuotaVsBudgetReportCls.teamSelected = 'AM';
        QuotaVsBudgetReportCls.productSelection = 'Event';
        instOfQVBRC.qTypVal();
        
        QuotaVsBudgetReportCls.teamSelected = 'AM';
        QuotaVsBudgetReportCls.productSelection = 'Event';
        instOfQVBRC.qTypVal();
        
        QuotaVsBudgetReportCls.teamSelected = 'Direct Sales';
        QuotaVsBudgetReportCls.productSelection = 'Event';
        instOfQVBRC.qTypVal();
        
        String teamValue = null;
        Integer monthFromJs = null;
        Integer monthToJs = null;
        String product = null;
        String masterTypeSec = null;
        String topScorerSec = null;
        String teamRole = 'Survey';
        String quotaYear = '2014';
        Test.startTest();
        QuotaVsBudgetReportCls.loadOpps(teamValue, monthFromJs, monthToJs, product, masterTypeSec, topScorerSec ,teamRole ,quotaYear );
        
        teamValue = null;
        monthFromJs = 1;
        monthToJs = 12;
        product = null;
        masterTypeSec = null;
        topScorerSec = null;
        teamRole = 'Survey';
        quotaYear = '2014';
        QuotaVsBudgetReportCls.loadOpps(teamValue, monthFromJs, monthToJs, product, masterTypeSec, topScorerSec,teamRole ,quotaYear);
        
        teamValue = 'Direct Sales';
        monthFromJs = 1;
        monthToJs = 12;
        product = null;
        masterTypeSec = null;
        topScorerSec = null;
        teamRole = 'Event';
        quotaYear = '2014';
        QuotaVsBudgetReportCls.loadOpps(teamValue, monthFromJs, monthToJs, product, masterTypeSec, topScorerSec,teamRole ,quotaYear);
        
        teamValue = 'AM';
        monthFromJs = 1;
        monthToJs = 12;
        product = null;
        masterTypeSec = null;
        topScorerSec = null;
        teamValue = null;
        teamRole = 'Event';
        quotaYear = '2014';
        QuotaVsBudgetReportCls.loadOpps(teamValue, monthFromJs, monthToJs, product, masterTypeSec, topScorerSec,teamRole ,quotaYear);
        
        teamValue = 'Direct Sales';
        monthFromJs = 1;
        monthToJs = 12;
        product = 'Event';
        masterTypeSec = 'NBB Licensing';
        topScorerSec = '5';
        teamRole = 'Event';
        quotaYear = '2014';
        QuotaVsBudgetReportCls.loadOpps(teamValue, monthFromJs, monthToJs, product, masterTypeSec, topScorerSec,teamRole ,quotaYear);
        
        teamValue = 'Direct Sales';
        monthFromJs = 1;
        monthToJs = 12;
        product = 'Survey';
        masterTypeSec = 'PSG Licensing';
        topScorerSec = '5';
        teamRole = 'Event';
        quotaYear = '2014';
        QuotaVsBudgetReportCls.loadOpps(teamValue, monthFromJs, monthToJs, product, masterTypeSec, topScorerSec,teamRole ,quotaYear);
        
        teamValue = 'AM';
        monthFromJs = 1;
        monthToJs = 12;
        product = 'Survey';
        masterTypeSec = 'Renewal';
        topScorerSec = '5';
        teamRole = 'Event';
        quotaYear = '2014';
        QuotaVsBudgetReportCls.loadOpps(teamValue, monthFromJs, monthToJs, product, masterTypeSec, topScorerSec,teamRole ,quotaYear);
        Test.stopTest();
    }
}