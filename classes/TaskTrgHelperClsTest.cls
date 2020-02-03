/**
//////////////////////////////////////
//      @author Abhishek Pandey     //
/////////////////////////////////////
Version :   1.0
Date : 23rd July 2014
Description: Tests the TaskTrgHelperCls . 
*/
@isTest(seeAllData=false)
private class TaskTrgHelperClsTest {    
    public static Sales_Resources__c instOfSalRes = new Sales_Resources__c();
    public static Mobile_Card__c instOfMobCard = new Mobile_Card__c();
    public static CCRole__c instOfCCRole =  new CCRole__c();
    public static Event_Role__c instOfEventRole = new Event_Role__c();
    public static Venue_Sourcing__c instOfVenueRole = new Venue_Sourcing__c();
    public static UserRole instOfUsrRole = new UserRole(name = 'Test');
    public static UserRole instOfUsrRoleSec = new UserRole(name = 'TestEve');
    public static UserRole instOfUsrRoleVen = new UserRole(name = 'TestVenue');
    public static User usrInst = new User();
    public static User instOfUserSec = new User();
    public static User instOfUserThir = new User();
    public static User instOfUserThirVen = new User();
    public static Campaign_Assignment__c instOfCampAss = new Campaign_Assignment__c();
    public static List<Campaign_Assignment__c> instOfCampAssList = new List<Campaign_Assignment__c>();
    public static Campaign_Assignment_Referredby__c instOfCampAssBy = new Campaign_Assignment_Referredby__c();
    public static Campaign_Assignment_Referralfor__c insOfCampAssFor = new Campaign_Assignment_Referralfor__c();
    public static Campaign_Assignment_ReceivedVM__c instOfCampAssVM = new Campaign_Assignment_ReceivedVM__c();
    public static RfpUploadTeam__c rfpObj = new RfpUploadTeam__c();
    
    public static List<OD_PS_Task_Mapping__c> createODPSCustomSetting(){
        List<OD_PS_Task_Mapping__c> ObjListVal= new List<OD_PS_Task_Mapping__c>();
        
        OD_PS_Task_Mapping__c ObjVal= new OD_PS_Task_Mapping__c();
        
        ObjVal.Name='11';
        ObjVal.Subject__c='Attended Event OD-E [date] (1CSNPI,1 offsite event)';
        ObjVal.Status__c='Completed';
        ObjVal.Due_Date__c=30;
        ObjListVal.add(ObjVal);
        
        ObjVal= new OD_PS_Task_Mapping__c();
        ObjVal.Name='111+';
        ObjVal.Subject__c='Attended Event OD-E [date] (No offsite event)';
        ObjVal.Status__c='Completed';
        ObjVal.Due_Date__c=30;
        ObjListVal.add(ObjVal);
        
        ObjVal= new OD_PS_Task_Mapping__c();
        ObjVal.Name='No Response9';
        ObjVal.Subject__c='Attended Event OD-E [date] (No offsite event)';
        ObjVal.Status__c='Completed';
        ObjVal.Due_Date__c=30;
        ObjListVal.add(ObjVal);
        
        ObjVal= new OD_PS_Task_Mapping__c();
        ObjVal.Name='No ResponseNo Response';
        ObjVal.Subject__c='Attended Event OD-E [date]';
        ObjVal.Status__c='Completed';
        ObjVal.Due_Date__c=30;
        ObjListVal.add(ObjVal);
        
        ObjVal= new OD_PS_Task_Mapping__c();
        ObjVal.Name='No Response11+';
        ObjVal.Subject__c='Attended Event OD-E [date] (No offsite event)';
        ObjVal.Status__c='Completed';
        ObjVal.Due_Date__c=30;
        ObjListVal.add(ObjVal);
        
        
        ObjVal= new OD_PS_Task_Mapping__c();
        ObjVal.Name='No ResponseNo Offsite Events';
        ObjVal.Subject__c='Attended Event OD-E [date] (No offsite event)';
        ObjVal.Status__c='Completed';
        ObjVal.Due_Date__c=30;
        ObjListVal.add(ObjVal);
        
        ObjVal= new OD_PS_Task_Mapping__c();
        ObjVal.Name='11+';
        ObjVal.Subject__c='Attended Event OD-E [date] (No offsite event)';
        ObjVal.Status__c='Completed';
        ObjVal.Due_Date__c=30;
        ObjListVal.add(ObjVal);
        
        ObjVal= new OD_PS_Task_Mapping__c();
        ObjVal.Name='1No Response';
        ObjVal.Subject__c='Attended Event OD-E [date] (No offsite event)';
        ObjVal.Status__c='Completed';
        ObjVal.Due_Date__c=30;
        ObjListVal.add(ObjVal);
        
        insert ObjListVal;
        return ObjListVal;
        
    }
    public static Id createContact(string lName){
        
        Contact instContact = new Contact();        
        instContact.LastName = lName;
        instContact.AccountId = createAccount(lName);
        instContact.Last_Attended_Event__c=system.today();
        insert instContact;
        return instContact.id;
    }
    
    public static Id createAccount(String name ){
        RecordType rtType = [SELECT r.SobjectType, r.DeveloperName,r.IsActive FROM RecordType r WHERE SobjectType='Account' And DeveloperName='Biz_Ac' And IsActive=true];
        Account instofAcc = new Account();
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        instofAcc.RecordTypeId = rtType.id;
        instofAcc.Name = name;
        instofAcc.PA_Rep__c = 'Meghan Bean';
        instofAcc.Purchased_License__c = 'Appointments';
        instofAcc.Named_Acct__c = 'Cvent Vendor';
        instofAcc.Account_Status__c = 'Active';
        instofAcc.BillingCountryCode ='US';
        instOfAcc.BillingStateCode ='TX';
        insert instofAcc;
        return instofAcc.id;
    }
    
    public static Id createProjectActivity(){
        Analysis_Projects__c instOfAp =  new Analysis_Projects__c();
        insert instOfAp;
        Project_Activity__c instOfPA = new Project_Activity__c();
        instOfPA.Name = 'Test Activity 1 ';
        instOfPA.Analysis_Project__c = instOfAp.id;
        instOfPA.Component_Owner__c = 'Test';
        instOfPA.Activity_Start_Date__c = System.Today();
        instOfPA.Activity_End_Date__c = System.Today();
        instOfPA.Entitled_Hours__c = 10;
        insert instOfPA;
        return instOfPA.Id;
    }
    
    public static Id createLead(String name){
        Lead instOfLead = new Lead();
        instOfLead.LastName = name;
        instOfLead.Company = 'Test';
        instOfLead.LeadSource = 'Test';
        instOfLead.Product_Desired__c ='Test';
        instOfLead.Status = 'Open';
        instOfLead.Validation_Counter__c=0;
        insert instOfLead;
        return instOfLead.Id;
    }
    
    static{
        Campaign instOfCamp =  new Campaign();
        instOfCamp.Name = 'Test';
        insert instOfCamp;
        
        instOfCampAssBy.Name = '12';
        instOfCampAssBy.Assigned_Role__c = 'Test';
        instOfCampAssBy.Campaign_Id__c = instOfCamp.id;
        insert instOfCampAssBy;
        
        rfpObj.Name ='1';
        rfpObj.Subject__c='Shut Down Event Free Trial Account?';
        rfpObj.Campaign_Id__c=instOfCamp.id;
        insert rfpObj;
        
        insOfCampAssFor.Name = '231';
        insOfCampAssFor.Assigned_Role__c = 'Test';
        insOfCampAssFor.Campaign_Id__c = instOfCamp.id;
        insert insOfCampAssFor;
        
        instOfCampAssVM.Name = '231';
        instOfCampAssVM.Assigned_Role__c = 'Test';
        instOfCampAssVM.Campaign_Id__c = instOfCamp.id;
        insert instOfCampAssVM;
        
        User thisUser = [ SELECT Id FROM User WHERE Id !=: UserInfo.getUserId() And Profile.Name =: 'System Administrator'  AND IsActive= true Limit 1];
        system.runAs ( thisUser ) {
            insert instOfUsrRole;
            insert instOfUsrRoleSec;
            insert instOfUsrRoleVen;
        }
        instOfSalRes.Request_Received_Date__c = system.today();
        instOfSalRes.RFP_Due_Date__c = system.today();
        instOfSalRes.Name = 'Test';
        insert instOfSalRes; 
        
        instOfCampAss.Name = '1';
        instOfCampAss.Lead_Source__c = 'WEB-Chat (CrowdCompass)';
        instOfCampAss.Campaign_Id__c = instOfCamp.Id;
        instOfCampAss.Assigned_Role__c = 'Test';
        instOfCampAss.Product__c='Chat Transcript';
        instOfCampAssList.add(instOfCampAss);
        
        instOfCampAss = new Campaign_Assignment__c();
        instOfCampAss.Name = '2';
        instOfCampAss.Lead_Source__c = 'WEB-Chat (CrowdCompass)';
        instOfCampAss.Campaign_Id__c = instOfCamp.Id;
        instOfCampAss.Assigned_Role__c = 'Test';
        instOfCampAssList.add(instOfCampAss);
        
        insert instOfCampAssList;
        
        RecordType instOfRecType = [SELECT Id FROM RecordType WHERE SobjectType = 'Mobile_Card__c' And IsActive = true Limit 1];
        instOfMobCard.Name = 'Test';
        instOfMobCard.Primary_Contact__c = createContact('Con1');
        insert instOfMobCard;
        
        Profile p = [SELECT id from profile WHERE name='System Administrator'];
        
        User thisUserSec = [ select Id FROM User where Id =: UserInfo.getUserId()];
        system.runAs ( thisUserSec ) {
            instOfUserSec = new User(alias = 'u1', email='u1@testorg875.com',userRoleId = instOfUsrRole.Id,
                                     emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                     localesidkey='en_US', profileid = p.Id, 
                                     timezonesidkey='America/Los_Angeles', username='u1@testorg76.com');
            
            instOfUserThir = new User(alias = 'u1', email='u1@testorg87587.com',userRoleId = instOfUsrRoleSec.Id,
                                      emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                      localesidkey='en_US', profileid = p.Id, 
                                      timezonesidkey='America/Los_Angeles', username='u1@testorg67.com');
            
            instOfUserThirVen = new User(alias = 'u1', email='u1@testorg87587.com',userRoleId = instOfUsrRoleVen.Id,
                                         emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                         localesidkey='en_US', profileid = p.Id, 
                                         timezonesidkey='America/Los_Angeles', username='u1@testorg617.com');
            
            insert instOfUserSec;
            insert instOfUserThir;
            insert instOfUserThirVen;
        }
        
        instOfCCRole.Name = 'Test';
        instOfCCRole.CCRole__c = 'Test';
        insert instOfCCRole;
        
        instOfEventRole.Name = 'TestEve';
        instOfEventRole.Event_Role__c = 'TestEve';
        insert instOfEventRole;
        
        instOfVenueRole.Name = 'TestVenue';
        instOfVenueRole.Venue_Role__c = 'TestVenue';
        insert instOfVenueRole;
        
    }
    
    
    static testMethod void myUnitTest() {
        
        Profile instOfProf = [SELECT ID FROM Profile WHERE Name like '%Sales Representative%' Limit 1];
        User instOfUser = new User(alias = 'u1', email='u19898@testorg.com',emailencodingkey='UTF-8', firstname='Sops',lastname='Testing', languagelocalekey='en_US',localesidkey='en_US', profileid = instOfProf.Id, 
                                   timezonesidkey='America/Los_Angeles', username='u1287@testorg.com');
        insert instOfUser;
        
        RecordType rtType = [SELECT r.SobjectType, r.DeveloperName,r.IsActive FROM RecordType r WHERE SobjectType='Account' And DeveloperName='Biz_Ac' And IsActive=true];
        
        Account instofAcc = new Account();
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        instofAcc.RecordTypeId = rtType.id;
        instofAcc.Name = 'BAcc';
        instofAcc.BillingCountryCode='US';
        instOfAcc.BillingState='TX';
        insert instofAcc;
        
        Campaign instOfCam = new Campaign();
        instOfCam.Name = 'Testcampaign';
        instOfCam.IsActive = TRUE;
        insert instOfCam;
        
        CampaignMember instOfCampaignMem = new CampaignMember();
        instOfCampaignMem.ContactId = createContact('Con2');
        instOfCampaignMem.CampaignId = instOfCam.Id;
        insert instOfCampaignMem;
        
        System.runAs(instOfUser){
            Test.startTest();
            Task instOfTsk= new Task();
            instOfTsk.OwnerId = instOfUserThir.Id;
            instOfTsk.WhoId = createContact('Con3');
            instOfTsk.WhatId = createAccount('Acc2');
            instOfTsk.Subject = 'Referral Attended Shut Down Event Free Trial Account? Test';
            instOfTsk.ActivityDate = system.Today().addDays(-4);
            instOfTsk.Priority = 'Normal';
            instOfTsk.Status = 'Not Started';
            instOfTsk.Task_Type__c='Attended';
            instOfTsk.Campaign_ID__c = string.valueOf(instOfCam.id);
            insert instOfTsk;
            //Task instOfTskSec = [SELECT ID FROM Task WHERE Id=:instOfTsk.id];
            instOfTsk.Subject = 'No Show';
            instOfTsk.WhoId = createContact('Con4');
            update instOfTsk;
            //Task instOfTskThird = [SELECT ID FROM Task WHERE Id=:instOfTskSec.id];
            
            delete instOfTsk;
            Test.stopTest();
        }
    }
    
    static testMethod void myUnitTest_Venue() {
        
        Profile instOfProf = [SELECT ID FROM Profile WHERE Name like '%Sales Representative%' Limit 1];
        User instOfUser = new User(alias = 'u11', email='u19898@testorg.com',emailencodingkey='UTF-8', firstname='Sops1',lastname='Testing1', languagelocalekey='en_US',localesidkey='en_US', profileid = instOfProf.Id, timezonesidkey='America/Los_Angeles', username='u12871@testorg.com');
        insert instOfUser;
        
        Id contactId = createContact('Con2');
        Campaign instOfCam = new Campaign();
        instOfCam.Name = 'Testcampaign';
        instOfCam.IsActive = TRUE;
        insert instOfCam;
        
        CampaignMember instOfCampaignMem = new CampaignMember();
        instOfCampaignMem.ContactId = contactId;
        instOfCampaignMem.CampaignId = instOfCam.Id;
        insert instOfCampaignMem;
        
        createODPSCustomSetting();
        Id accountId = createAccount('Acc2');
        System.runAs(instOfUser){
            List<Task> taskListInsert = new List<Task>();
            Task instOfTsk= new Task();
            instOfTsk.OwnerId = instOfUserThirVen.Id;
            instOfTsk.WhoId = contactId;//createContact('Con3');
            instOfTsk.WhatId = accountId;//createAccount('Acc2');
            instOfTsk.Subject = 'Attended Shut Down Event Free Trial Account? Test';
            instOfTsk.ActivityDate = system.Today().addDays(-4);
            instOfTsk.Priority = 'Normal';
            instOfTsk.Status = 'Not Started';
            instOfTsk.Task_Type__c='Attended';
            taskListInsert.add(instOfTsk);
            
            instOfTsk= new Task();
            instOfTsk.OwnerId = instOfUserThirVen.Id;
            instOfTsk.WhoId = contactId;//createContact('Con3');
            instOfTsk.WhatId = accountId;//createAccount('Acc2');
            instOfTsk.Subject = 'Attended Shut Down Event Free Trial Account? Test';
            instOfTsk.ActivityDate = system.Today().addDays(-4);
            instOfTsk.Priority = 'Normal';
            instOfTsk.Status = 'Completed';
            instOfTsk.Mood__c='1 - Irate';
            instOfTsk.Task_Type__c='Attended';
            instOfTsk.of_Offsite_Events__c='11+';
            taskListInsert.add(instOfTsk);
            
            insert taskListInsert;
            //Task instOfTskSec = [SELECT ID FROM Task WHERE Id=:instOfTsk.id];
            //instOfTsk.Subject = 'Test1';
            // update instOfTsk;
            //Task instOfTskThird = [SELECT ID FROM Task WHERE Id=:instOfTskSec.id];
            //Test.startTest();
            //delete instOfTsk;
            //Test.stopTest();
        }
    }
    static testMethod void myUnitTest_Venue1() {
        
        Profile instOfProf = [SELECT ID FROM Profile WHERE Name like '%Sales Representative%' Limit 1];
        User instOfUser = new User(alias = 'u11', email='u19898@testorg.com',emailencodingkey='UTF-8', firstname='Sops1',lastname='Testing1', languagelocalekey='en_US',localesidkey='en_US', profileid = instOfProf.Id, timezonesidkey='America/Los_Angeles', username='u12871@testorg.com');
        insert instOfUser;
        
        createODPSCustomSetting();
        
        System.runAs(instOfUser){
            List<Task> taskListInsert = new List<Task>();
            Task instOfTsk= new Task();
            instOfTsk.OwnerId = instOfUserThirVen.Id;
            instOfTsk.WhoId = createContact('Con3');
            instOfTsk.WhatId = createAccount('Acc2');
            instOfTsk.Subject = 'Attended Shut Down Event Free Trial Account? Test';
            instOfTsk.ActivityDate = system.Today().addDays(-4);
            instOfTsk.Priority = 'Normal';
            instOfTsk.Status = 'Completed';
            instOfTsk.Mood__c='1 - Irate';
            instOfTsk.Task_Type__c='Attended';
            instOfTsk.of_Offsite_Events__c='11+';
            taskListInsert.add(instOfTsk);            
            insert taskListInsert;
        }
    }
    static testMethod void myUnitTest_Venue2() {
        
        Profile instOfProf = [SELECT ID FROM Profile WHERE Name like '%Sales Representative%' Limit 1];
        User instOfUser = new User(alias = 'u11', email='u19898@testorg.com',emailencodingkey='UTF-8', firstname='Sops1',lastname='Testing1', languagelocalekey='en_US',localesidkey='en_US', profileid = instOfProf.Id, timezonesidkey='America/Los_Angeles', username='u12871@testorg.com');
        insert instOfUser;
        
        createODPSCustomSetting();
        
        System.runAs(instOfUser){
            List<Task> taskListInsert = new List<Task>();
            Task instOfTsk= new Task();
            instOfTsk.OwnerId = instOfUserThirVen.Id;
            instOfTsk.WhoId = createContact('Con3');
            instOfTsk.WhatId = createAccount('Acc2');
            instOfTsk.Subject = 'Attended Shut Down Event Free Trial Account? Test';
            instOfTsk.ActivityDate = system.Today().addDays(-4);
            instOfTsk.Priority = 'Normal';
            instOfTsk.Status = 'Completed';
            instOfTsk.Mood__c='1 - Irate';
            instOfTsk.Task_Type__c='Attended';
            instOfTsk.of_Offsite_Events__c='11+';
            taskListInsert.add(instOfTsk);            
            insert taskListInsert;
        }
    }
    static testMethod void myUnitTest_Venue3() {
        
        Profile instOfProf = [SELECT ID FROM Profile WHERE Name like '%Sales Representative%' Limit 1];
        User instOfUser = new User(alias = 'u11', email='u19898@testorg.com',emailencodingkey='UTF-8', firstname='Sops1',lastname='Testing1', languagelocalekey='en_US',localesidkey='en_US', profileid = instOfProf.Id, timezonesidkey='America/Los_Angeles', username='u12871@testorg.com');
        insert instOfUser;
        
        createODPSCustomSetting();
        System.runAs(instOfUser){
            List<Task> taskListInsert = new List<Task>();
            Task instOfTsk= new Task();
            instOfTsk.OwnerId = instOfUserThirVen.Id;
            instOfTsk.WhoId = createContact('Con3');
            instOfTsk.WhatId = createAccount('Acc2');
            instOfTsk.Subject = 'Attended Shut Down Event Free Trial Account? Test';
            instOfTsk.ActivityDate = system.Today().addDays(-4);
            instOfTsk.Priority = 'Normal';
            instOfTsk.Status = 'Completed';
            instOfTsk.Mood__c='1 - Irate';
            instOfTsk.Task_Type__c='Attended';
            instOfTsk.CSN_PI__c = '1';
            //instOfTsk.of_Offsite_Events__c='11+';
            taskListInsert.add(instOfTsk);            
            insert taskListInsert;
        }
    }
    static testMethod void myUnitTest_Venue5() {
        
        Profile instOfProf = [SELECT ID FROM Profile WHERE Name like '%Sales Representative%' Limit 1];
        User instOfUser = new User(alias = 'u11', email='u19898@testorg.com',emailencodingkey='UTF-8', firstname='Sops1',lastname='Testing1', languagelocalekey='en_US',localesidkey='en_US', profileid = instOfProf.Id, timezonesidkey='America/Los_Angeles', username='u12871@testorg.com');
        insert instOfUser;
        
        createODPSCustomSetting();
        
        System.runAs(instOfUser){
            List<Task> taskListInsert = new List<Task>();
            Task instOfTsk= new Task();
            instOfTsk.OwnerId = instOfUserThirVen.Id;
            instOfTsk.WhoId = createContact('Con3');
            instOfTsk.WhatId = createAccount('Acc2');
            instOfTsk.Subject = 'Attended Shut Down Event Free Trial Account? Test';
            instOfTsk.ActivityDate = system.Today().addDays(-4);
            instOfTsk.Priority = 'Normal';
            instOfTsk.Status = 'Completed';
            instOfTsk.Mood__c='1 - Irate';
            instOfTsk.Task_Type__c='Attended';
            instOfTsk.of_Offsite_Events__c='9';
            taskListInsert.add(instOfTsk);            
            insert taskListInsert;
        }
    }
    static testMethod void myUnitTest_Venue4() {
        
        Profile instOfProf = [SELECT ID FROM Profile WHERE Name like '%Sales Representative%' Limit 1];
        User instOfUser = new User(alias = 'u11', email='u19898@testorg.com',emailencodingkey='UTF-8', firstname='Sops1',lastname='Testing1', languagelocalekey='en_US',localesidkey='en_US', profileid = instOfProf.Id, timezonesidkey='America/Los_Angeles', username='u12871@testorg.com');
        insert instOfUser;
        
        createODPSCustomSetting();
        Id contactId = createContact('Con3');
        System.runAs(instOfUser){
            List<Task> taskListInsert = new List<Task>();
            Task instOfTsk= new Task();
            instOfTsk.OwnerId = instOfUserThirVen.Id;
            instOfTsk.WhoId = contactId;//createContact('Con3');
            instOfTsk.WhatId = createAccount('Acc2');
            instOfTsk.Subject = 'Attended Shut Down Event Free Trial Account? Test';
            instOfTsk.ActivityDate = system.Today().addDays(-4);
            instOfTsk.Priority = 'Normal';
            instOfTsk.Status = 'Completed';
            instOfTsk.Mood__c='1 - Irate';
            instOfTsk.Task_Type__c='Attended';
            instOfTsk.CSN_PI__c = '1';
            instOfTsk.of_Offsite_Events__c='11+';
            taskListInsert.add(instOfTsk);            
            insert taskListInsert;
        }
    }
    static testMethod void myUnitTestNew() {
        
        Profile instOfProf = [SELECT ID FROM Profile WHERE Name like '%Sales Representative%' Limit 1];
        
        User instOfUser = new User(alias = 'u1', email='u19898@testorg.com',emailencodingkey='UTF-8', firstname='Sops',lastname='Testing', languagelocalekey='en_US',localesidkey='en_US', profileid = instOfProf.Id, 
                                   timezonesidkey='America/Los_Angeles', username='u1287@testorg.com');
        insert instOfUser;
        
        //RecordType rtType = [SELECT r.SobjectType, r.DeveloperName,r.IsActive FROM RecordType r WHERE SobjectType='Account' And DeveloperName='Biz_Ac' And IsActive=true];
      
        Id contactId = createContact('Con4');
        Id projectId =createProjectActivity();
        
        List<Task> lstTskInsert = new List<Task>();
        
        Task instOfTskRingDNA= new Task();
        instOfTskRingDNA.OwnerId = instOfUserSec.Id;//instOfUserSec.Id;
        instOfTskRingDNA.WhoId = contactId;
        instOfTskRingDNA.Subject = 'Test';
        instOfTskRingDNA.ActivityDate = system.Today().addDays(3);
        instOfTskRingDNA.WhatId = createAccount('Acc3');
        instOfTskRingDNA.Priority = 'Normal';
        instOfTskRingDNA.Subject = 'Chat is';
        instOfTskRingDNA.Status = 'Completed';
        instOfTskRingDNA.Mood__c = '2 - Frustrated';
        instOfTskRingDNA.ringdna__Call_Disposition__c = 'Spoke';
        instOfTskRingDNA.ringdna__Created_by_RingDNA__c = TRUE;
        instOfTskRingDNA.Campaign_ID__c = '123456789123451';
        //insert instOfTsk;
        lstTskInsert.add(instOfTskRingDNA);
        
        
        Task instOfTsk= new Task();
        instOfTsk.OwnerId = instOfUserSec.Id;//instOfUserSec.Id;
        instOfTsk.WhoId = contactId;
        instOfTsk.Subject = 'Test';
        instOfTsk.ActivityDate = system.Today();
        instOfTsk.WhatId = createAccount('Acc3');
        instOfTsk.Priority = 'Normal';
        instOfTsk.Subject = 'Chat is';
        instOfTsk.Status = 'Not Started';
        instOfTsk.Status = 'Completed';
        instOfTsk.Mood__c = '2 - Frustrated';
        instOfTsk.Campaign_ID__c = '123456789123451';
        //insert instOfTsk;
        lstTskInsert.add(instOfTsk);
        system.debug('instOfTsk+++'+instOfTsk.WhoId);
        
        Task instOfTskThir = new Task();
        instOfTskThir.OwnerId = instOfUserSec.Id;
        instOfTskThir.WhatId = instOfSalRes.id;
        instOfTskThir.Subject = 'Test New';
        instOfTskThir.ActivityDate = system.Today().addDays(-4);
        instOfTskThir.Priority = 'Normal';
        instOfTskThir.Minutes_on_tasks__c = 10;
        instOfTskThir.Status = 'Completed';
        instOfTskThir.Campaign_ID__c = '123456789123451';
        //insert instOfTskThir;
        lstTskInsert.add(instOfTskThir);
        
        Task instOfTskSix = new Task();
        instOfTskSix.OwnerId = instOfUser.Id;
        instOfTskSix.WhatId = instOfMobCard.id;
        instOfTskSix.Subject = 'Test';
        instOfTskSix.ActivityDate = system.Today().addDays(-4);
        instOfTskSix.Priority = 'Normal';
        instOfTskSix.Status = 'Not Started';
        instOfTskSix.Minutes_on_tasks__c = 10;
        instOfTskSix.Minutes_on_Case__c = 10;
        instOfTskSix.Status = 'Completed';
        instOfTskSix.Campaign_ID__c = '123456789123451';
        //insert instOfTskSix;
        lstTskInsert.add(instOfTskSix);
        
        Task instOfTskSev = new Task();
        instOfTskSev.OwnerId = instOfUserSec.Id;
        instOfTskSev.WhoId = createLead('Lead1');
        instOfTskSev.Subject = 'Test';
        instOfTskSev.ActivityDate = system.Today();
        instOfTskSev.Priority = 'Normal';
        instOfTskSev.Minutes_on_tasks__c = 10;
        instOfTskSev.Minutes_on_Case__c = 10;
        //instOfTskSev.WhatId = createAccount();
        instOfTskSev.Status = 'Completed';
        instOfTskSev.Subject = 'Chat is';
        instOfTskSev.Campaign_ID__c = '123456789123451';
        //insert instOfTskSev;
        lstTskInsert.add(instOfTskSev);
        
        Task instOfTskEight = new Task();
        instOfTskEight.OwnerId = instOfUserThir.Id;
        instOfTskEight.WhoId = instOfTskSev.WhoId;
        instOfTskEight.Subject = 'Test';
        instOfTskEight.ActivityDate = system.Today();
        //instOfTskSev.WhatId = createAccount();
        instOfTskEight.Priority = 'Normal';
        instOfTskEight.Minutes_on_tasks__c = 10;
        instOfTskEight.Minutes_on_Case__c = 10;
        instOfTskEight.Status = 'Completed';
        instOfTskEight.Campaign_ID__c = '123456789123451';
        //insert instOfTskEight;
        lstTskInsert.add(instOfTskEight);
        
        Task instOfTskNin = new Task();
        instOfTskNin.OwnerId = instOfUser.Id;
        instOfTskNin.WhatId = instOfMobCard.id;
        instOfTskNin.Subject = 'Test';
        instOfTskNin.ActivityDate = system.Today().addDays(-4);
        instOfTskNin.Priority = 'Normal';
        instOfTskNin.Status = 'Not Started';
        instOfTskNin.Minutes_on_tasks__c = 10;
        instOfTskNin.Minutes_on_Case__c = 10;
        instOfTskNin.Status = 'Not Started';
        instOfTskNin.Campaign_ID__c = '123456789123451';
        //insert instOfTskNin;
        lstTskInsert.add(instOfTskNin);
        
        Task instOfTskTen = new Task();
        instOfTskTen.OwnerId = instOfUser.Id;
        instOfTskTen.WhatId = projectId;
        instOfTskTen.Subject = 'Test';
        instOfTskTen.ActivityDate = system.Today().addDays(-4);
        instOfTskTen.Priority = 'Normal';
        instOfTskTen.Status = 'Not Started';
        instOfTskTen.Minutes_on_tasks__c = 10;
        instOfTskTen.Minutes_on_Case__c = 10;
        instOfTskTen.Status = 'Not Started';
        instOfTskTen.Campaign_ID__c = '123456789123451';
        //insert instOfTskTen;
        lstTskInsert.add(instOfTskTen);
        
        Task instOfTskEle = new Task();
        instOfTskEle.OwnerId = instOfUser.Id;
        instOfTskEle.WhoId = contactId;
        instOfTskEle.Subject = '(CSG) and (VS) and Attended';
        instOfTskEle.ActivityDate = system.Today().addDays(-4);
        instOfTskEle.Priority = 'Normal';
        instOfTskEle.Status = 'Not Started';
        instOfTskEle.Minutes_on_tasks__c = 10;
        instOfTskEle.Minutes_on_Case__c = 10;
        instOfTskEle.Status = 'Not Started';
        instOfTskEle.Campaign_ID__c = '123456789123451';
        lstTskInsert.add(instOfTskEle);
        
        Test.startTest();
        
        insert lstTskInsert;
        
        //RecordType instRecType = [SELECT ID FROM RecordType WHERE SobjectType= 'Event' AND IsActive= true LIMIT 1];
        //RecordType instRecTypeThir = [SELECT Name, IsActive, DeveloperName, SobjectType FROM RecordType WHERE SobjectType='Event' And IsActive = true And DeveloperName = 'SMM_BD_Presentations' ];
        Id instRecTypeThir = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Enterprise Presentations').getRecordTypeId();
        
        List<Event> eventList=new List<Event>();
        
        
        Event instOfEvent = new Event();
        instOfEvent.RecordTypeId = instRecTypeThir;
        instOfEvent.WhoId = contactId;
        instOfEvent.OwnerId = instOfUser.Id;
        instOfEvent.Subject = 'Test';
        instOfEvent.Source__c = 'ACD';
        instOfEvent.DurationInMinutes = 12;
        instOfEvent.ActivityDateTime = system.now();
        eventList.add(instOfEvent);
        
        //Event instOfEventSec = new Event();
        instOfEvent = new Event();
        instOfEvent.RecordTypeId = instRecTypeThir;
        instOfEvent.WhoId = contactId;
        instOfEvent.OwnerId = instOfUser.Id;
        instOfEvent.Subject = 'Test';
        instOfEvent.Source__c = 'ACD';
        instOfEvent.DurationInMinutes = 12;
        instOfEvent.ActivityDateTime = system.now();
        eventList.add(instOfEvent);
       
        lstTskInsert[1].Minutes_on_tasks__c = 34;
    //update lstTskInsert[1];
        
        // delete lstTskInsert[1];
        
        lstTskInsert[2].Minutes_on_Case__c = 20;
        lstTskInsert[2].Minutes_on_tasks__c = 20;
        //update lstTskInsert[2];
        
        lstTskInsert[4].OwnerId = instOfUserSec.Id;
       // update lstTskInsert[4];
        
        system.debug('=================================================SOQL Limit======================================'+LIMITS.getLimitQueries());
        
        lstTskInsert[5].Subject = 'App Preview Sent to Customer';
        lstTskInsert[5].Status = 'Completed';
        update lstTskInsert[5];
        
        lstTskInsert[5].Minutes_on_tasks__c = 20;
        //update lstTskInsert[5];
        
        Event instOfEventFif = new Event();
        
        instOfEventFif.WhatId = projectId;
        instOfEventFif.OwnerId = UserInfo.getUserId();
        instOfEventFif.Subject = 'Test';
        instOfEventFif.Source__c = 'Chat';
        instOfEventFif.StartDateTime = system.today();
        instOfEventFif.EndDateTime = system.today();
        instOfEventFif.Minutes_on_tasks__c = 80;
        instOfEventFif.RecordTypeId = instRecTypeThir;
        insert instOfEventFif;
        
        delete instOfTskSix;
       // delete instOfTskTen;
        Test.stopTest();
    }
    static testMethod void myUnitTestSec() {
        test.starttest();
        Profile instOfProf = [SELECT ID FROM Profile WHERE Name like '%Sales Representative%' Limit 1];
        User instOfUser = new User(alias = 'u1', email='u19898@testorg.com',emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',localesidkey='en_US', profileid = instOfProf.Id, 
                                   timezonesidkey='America/Los_Angeles', username='u1287@testorg.com');
        insert instOfUser;
        RecordType rtType = [SELECT r.SobjectType, r.DeveloperName,r.IsActive FROM RecordType r WHERE SobjectType='Account' And DeveloperName='Biz_Ac' And IsActive=true];
        Account instofAcc = new Account();
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        instofAcc.RecordTypeId = rtType.id;
        instofAcc.Name = 'DAcc';
         instofAcc.BillingCountryCode='US';
        instOfAcc.BillingState='TX';
        insert instofAcc;
        
        Contact instContact = new Contact();        
        instContact.LastName = 'EC';
        instContact.AccountId = instofAcc.Id;
        insert instContact;
        
        System.runAs(instOfUser){
            Task instOfTsk= new Task();
            instOfTsk.OwnerId = instOfUser.Id;
            instOfTsk.WhoId = instContact.id;
            instOfTsk.Subject = 'Test';
            instOfTsk.ActivityDate = system.Today();
            instOfTsk.Priority = 'Normal';
            try{
                insert instOfTsk;
            }catch(Exception e){
                
            }           
        }
        
        T_D__c instOfTd = new T_D__c();
        
        instOfTd.Name = 'Test';
        instOfTd.Requestor_Name__c = 'Test';
        instOfTd.Goal__c = 'Test';
        instOfTd.Deliverables__c = 'Test';
        insert instOfTd;
        
        Task instOfTsk= new Task();
        
        instOfTsk.OwnerId = instOfUser.Id;
        instOfTsk.WhatId = instOfTd.id;
        instOfTsk.Subject = 'Test';
        instOfTsk.ActivityDate = system.Today();
        instOfTsk.Priority = 'Normal';
        instOfTsk.Minutes_on_tasks__c = 60;
        instOfTsk.Status = 'Completed';
        insert instOfTsk;
        
        //Task instOfTskSec = [SELECT ID,Minutes_on_tasks__c FROM Task WHERE Id =: instOfTsk.id LIMIT 1];
        
        instOfTsk.Minutes_on_Case__c = 45;
        update instOfTsk;
        
        //Task instOfTskThir = [SELECT ID,Minutes_on_tasks__c FROM Task WHERE Id =: instOfTskSec.id LIMIT 1];
        delete instOfTsk;
        
        //Task instOfTskFor = [SELECT ID,Minutes_on_tasks__c FROM Task WHERE Id =: instOfTskThir.id LIMIT 1 ALL ROWS];
        undelete instOfTsk;
        test.stoptest();
    }
    
   /* static TestMethod void myUnitTestThir(){
        
        EB_SB_Builder__c instOfEB =  new EB_SB_Builder__c();
        instOfEB.Project__c = 'Event Builder';
        instOfEB.Project_Status__c = 'Information Pending';
        instOfEB.Project_Type_del__c = 'Demo Event';
        instOfEB.Project_Complexity__c = '1-Simple';
        insert instOfEB;
        
        //RecordType instRecTypeThir = [SELECT SobjectType,Id,name,DeveloperName FROM RecordType WHERE SobjectType='Case' And IsActive=true And DeveloperName = 'Eventbuilder' Limit 1];
        Id instRecTypeThir = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Eventbuilder').getRecordTypeId();
        Id billingcaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Billing Cases').getRecordTypeId();
        
        List<Case> listCase = new List<Case>();
        
        Case instOfCaseSec = new Case();
        
        instOfCaseSec.RecordTypeId = instRecTypeThir;
        instOfCaseSec.Status = 'Open';
        instOfCaseSec.Description = 'Test';
        instOfCaseSec.Product_Type__c = 'Event Management & Surveys';
        instOfCaseSec.Topic__c = 'Reports';
        instOfCaseSec.Subtopic__c = 'Other';
        instOfCaseSec.Subject = 'Test';
        instOfCaseSec.Min_s_Spent__c = 20;
        instOfCaseSec.Event_Survey_Builder__c = instOfEB.Id;
        //instOfCase.RecordTypeId = instRecTypeSec.id;
        listCase.add(instOfCaseSec);
        
        instOfCaseSec = new Case();
        instOfCaseSec.RecordTypeId = billingcaseRecTypeId;
        instOfCaseSec.Status = 'Open';
        instOfCaseSec.Description = 'Test';
        instOfCaseSec.Product_Type__c = 'Event Management & Surveys';
        instOfCaseSec.Topic__c = 'Reports';
        instOfCaseSec.Subtopic__c = 'Other';
        instOfCaseSec.Subject = 'Test';
        instOfCaseSec.Min_s_Spent__c = 20;
        instOfCaseSec.Event_Survey_Builder__c = instOfEB.Id;
        listCase.add(instOfCaseSec);
        
        insert listCase;
        
        //RecordType instRecType = [SELECT Name, IsActive, DeveloperName, SobjectType FROM RecordType WHERE SobjectType='Event' And IsActive = true And DeveloperName = 'SMM_BD_Presentations' ];
        Id instRecType = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Enterprise Presentations').getRecordTypeId();
        
        Event instOfEvent = new Event();
        instOfEvent.WhatId = instOfEB.Id;
        instOfEvent.OwnerId = UserInfo.getUserId();
        instOfEvent.Subject = 'Test';
        instOfEvent.Source__c = 'Chat';
        instOfEvent.StartDateTime = system.today();
        instOfEvent.EndDateTime = system.today();
        instOfEvent.Minutes_on_tasks__c = 80;
        //instOfEvent.CurrencyIsoCode = 'USD';
        instOfEvent.RecordTypeId = instRecType;
        insert instOfEvent;
        
        List<Task> taskList=new List<Task>();
        Task instOfTsk = new Task();
        instOfTsk.OwnerId = UserInfo.getUserId();
        instOfTsk.WhatId = instOfEB.id;
        instOfTsk.Subject = 'Test Chat Transcript';
        instOfTsk.ActivityDate = system.Today();
        instOfTsk.Priority = 'Normal';
        instOfTsk.Minutes_on_tasks__c = 60;
        instOfTsk.Status = 'Completed';
        taskList.add(instOfTsk);
        
        instOfTsk = new Task();
        instOfTsk.OwnerId = UserInfo.getUserId();
        instOfTsk.WhatId = instOfCaseSec.id;
        instOfTsk.Subject = 'Test';
        instOfTsk.ActivityDate = system.Today();
        instOfTsk.Priority = 'Normal';
        instOfTsk.Minutes_on_tasks__c = 60;
        instOfTsk.Status = 'Completed';
        taskList.add(instOfTsk);
        
        insert taskList;     
        
        instOfCaseSec.Min_s_Spent__c = 20;
        update instOfCaseSec;
        
        Test.starttest();
        
        instOfEvent.Minutes_on_tasks__c = 40;
        update instOfEvent;
        
        taskList[0].Minutes_on_tasks__c = 50;
        update taskList[0];
        
        try{
            delete instOfCaseSec;
            delete instOfEvent;
        }catch(DmlException e){
            
        }
        //Task instOfTskFor = [SELECT ID,Minutes_on_tasks__c FROM Task WHERE Id =: instOfTsk.id LIMIT 1];
        //taskList[0].Minutes_on_tasks__c = 90;
        //update taskList[0];         
        test.stoptest();
    } */
    
    static TestMethod void myUnitTestTenth(){
        Test.StartTest();
        User userObj = [SELECT Id FROM User WHERE Name LIKE '%deployment%' AND IsActive = TRUE LIMIT 1];
        System.runAs(userObj){
        TaskRoleVsCMProduct__c taskCustSet = new TaskRoleVsCMProduct__c();
        taskCustSet.Name = 'AM (CSN)';
        taskCustSet.Product__c = 'CSN';
        insert taskCustSet;
        
        Task_Subject_Vs_CM_Status__c taskSubCM = new Task_Subject_Vs_CM_Status__c();
        taskSubCM.Name = 'Task1';
        taskSubCM.Task_Subject_Line__c = 'Attended - Self Registered';
        taskSubCM.Member_Status__c = 'Attended';
        insert taskSubCM;
        
        Analysis_Projects__c instOfAp =  new Analysis_Projects__c();
        insert instOfAp;
        
        Project_Activity__c instOfPA = new Project_Activity__c();
        instOfPA.Name = 'Test';
        instOfPA.Analysis_Project__c = instOfAp.id;
        instOfPA.Component_Owner__c = 'Test';
        instOfPA.Activity_Start_Date__c = System.Today();
        instOfPA.Activity_End_Date__c = System.Today();
        instOfPA.Entitled_Hours__c = 10;
        insert instOfPA;
        
        Id contactId = createContact('Con70');
                
        Task instOfTskSEC = new Task();
        instOfTskSEC.OwnerId = UserInfo.getUserId();
        instOfTskSEC.WhatId = instOfPA.id;
        instOfTskSEC.WhoId = contactId;
        instOfTskSEC.Subject = 'Attended - Self Registered';
        instOfTskSEC.ActivityDate = system.Today();
        instOfTskSEC.Priority = 'Normal';
        instOfTskSEC.Minutes_on_tasks__c = 60;
        instOfTskSEC.Status = 'Completed';
        insert instOfTskSEC;
        
        CheckRecursive.runTwelve = true;
        

        
        Campaign instOfCam = new Campaign();
        instOfCam.Name = 'Testcampaign';
        instOfCam.IsActive = TRUE;
        insert instOfCam;
        
        Task instOfTskThir = [SELECT ID,Minutes_on_tasks__c,WhoId FROM Task WHERE Id =: instOfTskSEC.id LIMIT 1];
        instOfTskThir.Campaign_Id__c = instOfCam.Id;
        instOfTskThir.Minutes_on_tasks__c = 98;
        instOfTskThir.Product__c ='Event';
        update instOfTskThir;
        
        List<Task> taskList = new List<Task>();
        taskList.add(instOfTskThir);
        TaskTrgHelperCls.updateProductOnCM(taskList);
        
        Event evtObj2 = new Event();
        evtObj2.OwnerId = instOfUserThir.Id;
        evtObj2.WhatId = instOfPA.id;
        evtObj2.CSN_Show__c = true;
        evtObj2.ActivityDateTime = System.now();
        evtObj2.DurationInMinutes = 10;
        evtObj2.Subject = 'Attended Shut Down Event Free Trial Account? Test';
        evtObj2.ActivityDate = system.Today().addDays(-4);
        
        insert evtObj2;   
        
        Event evtToUpdate = [SELECT ID,Minutes_on_tasks__c FROM Event WHERE Id =: evtObj2.id LIMIT 1];
        evtToUpdate.DurationInMinutes = 28;
        update evtToUpdate;        
        
        try{
            delete instOfPA;
            delete instOfTskThir;
        }catch(DmlException e){
            
        }
        Test.StopTest();
        }
    }  
    
    static TestMethod void myUnitTestFor(){
        createODPSCustomSetting();
        List<Task> lstTask = new List<Task>();
        List<Task> lstTskInsert =  new List<Task>();
        
        Id contactId = createContact('Con7');
        Task instOfTsk1 = new Task();
        instOfTsk1 .OwnerId = instOfUserSec.Id;
        instOfTsk1 .WhoId = contactId;
        instOfTsk1 .Mood__c = '3';
        instOfTsk1.Status = 'Completed';
        instOfTsk1 .Client_Proficiency_Level__c ='Basic';
        instOfTsk1 .Subject = 'Attended 11';
        instOfTsk1 .CSN_PI__c='1';
        instOfTsk1 .of_Offsite_Events__c ='1';
        instOfTsk1 .ActivityDate = system.Today();
        instOfTsk1 .Priority = 'Normal';
        instOfTsk1 .Minutes_on_tasks__c = 60;
        instOfTsk1 .Status = 'Not Started';
        instOfTsk1.Campaign_ID__c = '1213412345675321';
        lstTask.add(instOfTsk1);
        
        instOfTsk1 = new Task();
        instOfTsk1 .OwnerId = instOfUserSec.Id;
        instOfTsk1 .WhoId = contactId;
        instOfTsk1 .Client_Proficiency_Level__c ='Basic';
        instOfTsk1 .Subject = 'Attended 111';
        instOfTsk1 .ActivityDate = system.Today();
        instOfTsk1 .Priority = 'Normal';
        instOfTsk1 .Minutes_on_tasks__c = 60;
        instOfTsk1 .Status = 'Not Started';
        instOfTsk1 .of_Offsite_Events__c ='11+';
        instOfTsk1.Campaign_ID__c = '1213812385675321';
        lstTask.add(instOfTsk1 );
        
        instOfTsk1 = new Task();
        instOfTsk1 .OwnerId = instOfUserSec.Id;
        instOfTsk1 .WhoId = contactId;
        instOfTsk1 .Client_Proficiency_Level__c ='Basic';
        instOfTsk1 .Subject = 'Attended 11';
        //instOfTsk1 .CSN_PI__c='1';
        instOfTsk1 .of_Offsite_Events__c ='No Offsite Events';
        instOfTsk1 .ActivityDate = system.Today();
        instOfTsk1 .Priority = 'Normal';
        instOfTsk1 .Minutes_on_tasks__c = 60;
        instOfTsk1 .Status = 'Not Started';
        instOfTsk1.Campaign_ID__c = '1212452345675321';
        lstTask.add(instOfTsk1 );
        
        
        Task instOfTsk = new Task();
        instOfTsk.OwnerId = instOfUserSec.Id;
        instOfTsk.WhoId = contactId;
        instOfTsk.Client_Proficiency_Level__c ='Basic';
        instOfTsk.Subject = 'Received VM';
        instOfTsk.ActivityDate = system.Today();
        instOfTsk.Priority = 'Normal';
        instOfTsk.Minutes_on_tasks__c = 60;
        instOfTsk.Status = 'Not Started';
        instOfTsk.Campaign_ID__c = '1213116345675321';
        lstTask.add(instOfTsk);
        //insert instOfTsk;
        
        Task instOfTskSec = new Task();
        instOfTskSec.OwnerId = instOfUserSec.Id;
        instOfTskSec.WhoId = contactId;//createContact('Con8');
        instOfTskSec.Subject = 'Referral for who attended';
        instOfTskSec.ActivityDate = system.Today();
        instOfTskSec.Priority = 'Normal';
        instOfTskSec.Minutes_on_tasks__c = 60;
        instOfTskSec.Status = 'Not Started';
        instOfTskSec.Campaign_ID__c = '1213412345656321';
        lstTask.add(instOfTskSec);
        
        Task instOfTskThir = new Task();
        instOfTskThir.OwnerId = instOfUserSec.Id;
        instOfTskThir.WhoId = contactId;//createContact('Con9');
        instOfTskThir.Subject = 'Referred as who attended';
        instOfTskThir.ActivityDate = system.Today();
        instOfTskThir.Priority = 'Normal';
        instOfTskThir.Minutes_on_tasks__c = 60;
        instOfTskThir.Status = 'Not Started';
        instOfTskThir.Campaign_ID__c = '1213412135675321';
        lstTask.add(instOfTskThir);
        
        insert lstTask;
        
        Task instOfTskSev = new Task();
        
        instOfTskSev.OwnerId = instOfUserSec.Id;
        instOfTskSev.WhoId = createLead('Lead2');
        instOfTskSev.Subject = 'Test';
        instOfTskSev.ActivityDate = system.Today();
        instOfTskSev.Priority = 'Normal';
        instOfTskSev.Minutes_on_tasks__c = 10;
        instOfTskSev.Minutes_on_Case__c = 10;
        instOfTskSev.Status = 'Completed';
        instOfTskSev.Subject = 'Chat is';
        instOfTskSev.Campaign_ID__c = '1213412181675321';
        lstTskInsert.add(instOfTskSev);
        
        Task instOfTskSevSec = new Task();
        instOfTskSevSec.OwnerId = instOfUserSec.Id;
        instOfTskSevSec.WhoId = instOfTskSev.WhoId;
        instOfTskSevSec.Subject = 'Test';
        instOfTskSevSec.ActivityDate = system.Today();
        instOfTskSevSec.Priority = 'Normal';
        instOfTskSevSec.Minutes_on_tasks__c = 10;
        instOfTskSevSec.Minutes_on_Case__c = 10;
        instOfTskSevSec.Status = 'Completed';
        instOfTskSevSec.Subject = 'Chat is';
        instOfTskSevSec.Campaign_ID__c = '1211492135675321';
        //insert instOfTskSev;
        lstTskInsert.add(instOfTskSevSec);
        Test.startTest();
        insert lstTskInsert;        
        delete lstTskInsert[0];        
        undelete lstTskInsert[0];
        //delete lstTskInsert;        
        lstTskInsert.clear();
        
        Task instOfTskSevCon = new Task();
        instOfTskSevCon.OwnerId = instOfUserSec.Id;
        instOfTskSevCon.WhoId = contactId;//createContact('Con10');
        instOfTskSevCon.Subject = 'Test Chat Transcript';
        instOfTskSevCon.ActivityDate = system.Today();
        instOfTskSevCon.Priority = 'Normal';
        instOfTskSevCon.Minutes_on_tasks__c = 10;
        instOfTskSevCon.Minutes_on_Case__c = 10;
        instOfTskSevCon.Status = 'Completed';
        instOfTskSevCon.Subject = 'Chat is Chat Transcript';
        instOfTskSevCon.Campaign_ID__c = '12134112181675321';
        lstTskInsert.add(instOfTskSevCon);
        
        Task instOfTskSevConSec = new Task();
        instOfTskSevConSec.OwnerId = instOfUserSec.Id;
        instOfTskSevConSec.WhoId = instOfTskSevCon.WhoId;
        instOfTskSevConSec.Subject = 'Test';
        instOfTskSevConSec.ActivityDate = system.Today();
        instOfTskSevConSec.Priority = 'Normal';
        instOfTskSevConSec.Minutes_on_tasks__c = 10;
        instOfTskSevConSec.Minutes_on_Case__c = 10;
        instOfTskSevConSec.Status = 'Completed';
        instOfTskSevConSec.Subject = 'Chat is';
        instOfTskSevConSec.Campaign_ID__c = '12134112181675321';
        lstTskInsert.add(instOfTskSevConSec);
        
        instOfTskSevConSec = new Task();
        instOfTskSevConSec.OwnerId = instOfUserSec.Id;
        instOfTskSevConSec.WhoId = instOfTskSevCon.WhoId;
        instOfTskSevConSec.Subject = 'Test';
        instOfTskSevConSec.ActivityDate = system.Today();
        instOfTskSevConSec.Priority = 'Normal';
        instOfTskSevConSec.Minutes_on_tasks__c = 10;
        instOfTskSevConSec.Minutes_on_Case__c = 10;
        instOfTskSevConSec.Status = 'Completed';
        instOfTskSevConSec.Subject = '(VS) Attended 11/23/16 PS-E (CSG)';
        instOfTskSevConSec.Campaign_ID__c = '12134112181675321';
        lstTskInsert.add(instOfTskSevConSec);
        
        insert lstTskInsert;        
        delete lstTskInsert[0];        
        undelete lstTskInsert[0];
        Test.stopTest();
        //delete lstTskInsert;
    }
        
    public static testMethod void testUpdateStatusSQL(){
        // Create Custom Setting.
        List<DWF_Product_Vs_Status_Vs_Owner_Field__c> customSettingList = new List<DWF_Product_Vs_Status_Vs_Owner_Field__c>();
        
        DWR_Role_ContactStatus__c roleSetting = new DWR_Role_ContactStatus__c();
        roleSetting.Name = 'Administrator';
        roleSetting.Contact_Owner_Field__c = 'Contact_Owner_for_Event__c';
        roleSetting.Contact_Status_Field__c = 'Event_Contact_Status__c';
        insert  roleSetting;  
        
        
        DWF_Product_Vs_Status_Vs_Owner_Field__c customSetting = new DWF_Product_Vs_Status_Vs_Owner_Field__c();
        customSetting.Name = 'Event';
        customSetting.Contact_Owner_Field__c = 'Contact_Owner_for_Event__c';
        customSetting.Contact_Status_Field__c = 'Event_Contact_Status__c';
        customSettingList.add(customSetting);
        
        customSetting = new DWF_Product_Vs_Status_Vs_Owner_Field__c();
        customSetting.Name = 'EMI';
        customSetting.Contact_Owner_Field__c = 'Contact_Owner_for_CSN_S__c';
        customSetting.Contact_Status_Field__c = 'CSNS_Contact_Status__c';
        customSettingList.add(customSetting);

        customSetting = new DWF_Product_Vs_Status_Vs_Owner_Field__c();
        customSetting.Name = 'TestEve';
        customSetting.Contact_Owner_Field__c = 'Contact_Owner_for_Event__c';
        customSetting.Contact_Status_Field__c = 'Event_Contact_Status__c';
        customSettingList.add(customSetting);
                
        insert customSettingList;
        
        DWF_Contact_Status_Order__c orderSetting = new DWF_Contact_Status_Order__c();
        orderSetting.Name = 'Inquiry';
        orderSetting.Order__c = 1;
        insert orderSetting;
        
        List<Event> evntList = new List<Event>();
        
        Event evtObj = new Event();
        evtObj.OwnerId = instOfUserThir.Id;
        evtObj.WhoId = createContact('Con3');
        evtObj.WhatId = createAccount('Acc2');
        evtObj.CSN_Show__c = true;
        evtObj.ActivityDateTime = System.now();
        evtObj.Product__c = 'Event;EMI';
        evtObj.DurationInMinutes = 10;
        evtObj.RecordTypeId = [SELECT Name, IsActive, DeveloperName, SobjectType FROM RecordType WHERE SobjectType='Event' And IsActive = true And DeveloperName = 'SMM_BD_Presentations'].Id;
        evtObj.Subject = 'Attended Shut Down Event Free Trial Account? Test';
        evtObj.ActivityDate = system.Today().addDays(-4);        
        evntList.add(evtObj);
        
        Event evtObj2 = new Event();
        evtObj2.OwnerId = instOfUserThir.Id;
        evtObj2.WhoId = createContact('Con3');
        evtObj2.WhatId = createAccount('Acc2');
        evtObj2.CSN_Show__c = true;
        evtObj2.Product__c = 'Event;EMI';
        evtObj2.ActivityDateTime = System.now();
        evtObj2.DurationInMinutes = 10;
        evtObj2.Subject = 'Attended Shut Down Event Free Trial Account? Test';
        evtObj2.ActivityDate = system.Today().addDays(-4);
        evntList.add(evtObj2);
        
        insert evntList;
        
        
        
        
        Attachment attach = new Attachment();  
        attach.OwnerId = instOfUserThir.Id;
        attach.Name='Unit Test Attachment';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attach.body = bodyBlob;
        attach.parentId=evntList[0].Id;
        insert attach;
        
        Event_Attachment_Email_Sending_Mapping__c evtAttchEmailSendingSetting = new Event_Attachment_Email_Sending_Mapping__c();
        evtAttchEmailSendingSetting.Name = 'Test User';
        evtAttchEmailSendingSetting.User_Creating__c = UserInfo.getUserId();
        evtAttchEmailSendingSetting.User_Mapped__c = UserInfo.getUserId();
        insert evtAttchEmailSendingSetting;
        
        TaskTrgHelperCls.fakemethod();
    }
}