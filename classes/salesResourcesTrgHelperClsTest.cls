/**
///////////////////////////////
//    @author Rohit Saxena    //
///////////////////////////////

Version 1.0
Date: 10th July 2015
Description : To test salesResourcesTrgHelperCls
*/
@isTest
private class salesResourcesTrgHelperClsTest {
    
    public static Id createAccount(String methodName){
        ISOSetting__c instSetting = new ISOSetting__c();
        instSetting.Country_Name__c = 'IN';
        instSetting.ISO__c = 'IN';
        instSetting.Name = 'Australia';
        insert instSetting;
        
        Profile p = [SELECT Name FROM Profile WHERE Name = 'System Administrator']; 
        
        User user1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                              EmailEncodingKey='UTF-8', FirstName='Ericson', LastName='Smith', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = p.Id, 
                              TimeZoneSidKey='America/Los_Angeles', UserName='feUsercventtest'+methodName+'@testorg.com');
        insert user1;
        System.debug('user1>>>'+user1);
        System.assertEquals('Ericson', user1.FirstName);
        ISOSetting__c instSettingSec = new ISOSetting__c();
        instSettingSec.Country_Name__c = 'Afghanistan';
        instSettingSec.ISO__c = 'AFG';
        instSettingSec.Name = 'Afghanistan';
        insert instSettingSec;    
        
        RecordType rtType = [SELECT r.SobjectType, r.DeveloperName,r.IsActive FROM RecordType r WHERE SobjectType = 'Account' And DeveloperName = 'Biz_Ac' And IsActive=true];
        Account instofAcc = new Account();
        instofAcc.Back_Office_System__c = '123Signup';
        instofAcc.API_connected_with__c= '44fish.com';
        instofAcc.RecordTypeId = rtType.id;
        //instofAcc.BillingState = 'Queensland';
        //instofAcc.BillingStreet = 'Delhi';
        //instofAcc.BillingCountry = 'Australia';
        instofAcc.Name = 'Test';
        instofAcc.BillingCountryCode='IN';
        instofAcc.CVII_ID__c='4654654';
        instofAcc.Federal_Tax_ID_VAT_Number__c='46544654';
        instofAcc.Region__c='Test';
        instofAcc.AM_CrowdCompass__c='Brandon Beall';
        //instofAcc.AM_CrowdTorch__c='Brandon Beall';  //Commented By Mohsin on 21st June 2019 - FP Activity
        instofAcc.AM_CSN__c='Brandon Beall';
        //instofAcc.AM_CT_TM__c='Brandon Beall';       //Commented By Mohsin on 21st June 2019 - FP Activity
        instofAcc.AM_Event__c='Brandon Beall';
        instofAcc.AM_PA__c='Brandon Beall';
        instofAcc.AM_Survey__c='Brandon Beall';
        instofAcc.CS_Rep__c='Brandon Beall';
        instOfAcc.PA_Rep__c = 'Ericson Smith';
        
        Country_Phone_Codes__c setting = new Country_Phone_Codes__c();
        setting.Name = 'IN';
        setting.ISD_Code__c = '91';
        insert setting;
        
        CountryCode__c cCode = new CountryCode__c();
        cCode.Name = 'IN';
        cCode.Code__c = 'INDIA';
        insert cCode;
        
        instofAcc.Phone = '056465465465';
        insert instofAcc;
        
        
        //inserting HODI record
        HODI_Inventory__c HODIInventory=new HODI_Inventory__c();
        HODIInventory.Name='Test User';
        HODIInventory.Head_of_Department__c=UserInfo.getUserId();
        HODIInventory.Pool_Point__c=50;
        insert HODIInventory;
        
        //instofAcc.BillingCountry = 'Afghanistan';
        instofAcc.IsHODI_Dev__c = true;
        instofAcc.HODI_Approver_Dev__c=UserInfo.getUserId();
        instofAcc.Service_Tier__c='Basic';
        instofAcc.HODI_Request_Date_Dev__c=system.today();
        instofAcc.IsRejected_Dev__c=false;
        instofAcc.HODI_Id_Dev__c= HODIInventory.Id;
        instofAcc.Desired_Tier_Dev__c='464644';
        instofAcc.HOD_Comment_Dev__c='test';
        instofAcc.HODI_Count_Dev__c= 464646;
        instofAcc.Previous_Tier_Dev__c='464644';
        update instofAcc;
        return instofAcc.id;
    }
    
    static testMethod void muUnitTest(){
        Id accid = createAccount('myUnitTest');
        
        List<Sales_Resources__c>lstSalRes = new lIst<Sales_Resources__c>();
        RecordType instRecType=[SELECT ID FROM RecordType WHERE SobjectType='Sales_Resources__c' AND DeveloperName='Sales_Engineering' AND isActive=true LIMIT 1];
        
        Sales_Resources__c instOfSalRes = new Sales_Resources__c();
        instOfSalRes.Back_Office_System_New__c = '123Signup';
        instOfSalRes.API_connected_with__c = '44fish.com';
        instOfSalRes.RecordTypeId = instRecType.Id;
        instOfSalRes.Account__c = createAccount('myUnitTest1');
        lstSalRes.add(instOfSalRes);
        
        Sales_Resources__c instOfSalResSec = new Sales_Resources__c();
        instOfSalResSec.Back_Office_System_New__c = 'Blackboard';
        instOfSalResSec.API_connected_with__c = 'Advanced CRM';
        instOfSalResSec.RecordTypeId = instRecType.Id;
        instOfSalResSec.Account__c = createAccount('myUnitTest2');
        lstSalRes.add(instOfSalResSec);
        
        Insert lstSalRes;
        
        
        lstSalRes[0].Back_Office_System_New__c = 'aMember Pro';
        lstSalRes[0].API_connected_with__c = 'Advanced CRM';
        lstSalRes[0].RecordTypeId = instRecType.Id;
        
        
        Update lstSalRes[0];
        
    }
    
    static testMethod void testPrimarySyncAddressFunc(){
        Id accid = createAccount('testPrimarySyncAddressFunc');
        
        ClientAccountDelete__c cc = new ClientAccountDelete__c();
        cc.Name = 'CRM Deployment User';
        cc.userId__c = UserInfo.getUserId();
        insert cc;
        
        Address__c adr = new Address__c();
        adr.Account__c = accid;
        adr.Primary_Sync__c=true;
        insert adr;
        
        Account acc = new Account(Id=accid);
        delete acc;
    }
    static testMethod void passwordresettest(){
        /******** Create Customer portal user without having any role in test class -START *********/           
        Set<String> customerUserTypes = new Set<String> {'CspLitePortal'};
        Account acc = new Account (
        Name = 'newAcc1',
        Product_Mix__c = 'Event',
                BillingCountryCode='IN'
        );  
        insert acc;
        Contact con = new Contact (
        AccountId = acc.id,
        LastName = 'portalTestUser'
        );
        insert con;
        Profile p = [select Id,name from Profile where Name='Cvent Customer Community User' limit 1];

        User newUser = new User(
        profileId = p.id,
        username = 'newUser@yahoo.com',
        email = 'pb@ff.com',
        emailencodingkey = 'UTF-8',
        localesidkey = 'en_US',
        languagelocalekey = 'en_US',
        timezonesidkey = 'America/Los_Angeles',
        alias='nuser',
        lastname='lastname',
        contactId = con.id
        );
        insert newUser;

        system.runAs(new User(Id = UserInfo.getUserId())){
        acc.Product_Mix__c = 'Inquisium';
                    update acc;}
        /******** Create Customer portal user without having any role in test class - END *********/
    }
    
    static testMethod void batchUpdateAccountCSN()
    {
        Account instofAcc1 = new Account();
        Contact instContact = new Contact();
        RecordType rtType = [SELECT r.SobjectType, r.DeveloperName,r.IsActive FROM RecordType r WHERE SobjectType='Account' AND DeveloperName='Biz_Ac' And IsActive = true];
        StopCloudMDMExe.stopExecutionCloudMdm = false;
        instofAcc1.Supplier_Type__c = 'Venue';
        instofAcc1.Venue_Type__c = 'CVB';
        instofAcc1.RecordTypeId = rtType.id;
        instofAcc1.Name = 'Test';
        instofAcc1.BillingCountryCode = 'IN';
        instofAcc1.Phone = '056465465465';
        instofAcc1.Dedicated_Ent_Support_Minutes_Used__c = 0;
        instofAcc1.CSN_P_Account_Status__c='Closed Won';
        insert instofAcc1;
        
        Contact instContactFif1 = new Contact();
        instContactFif1.LastName = 'Test';
        instContactFif1.AccountId = instofAcc1.Id;
        instContactFif1.CT_Contact_Status__c= 'E - Attended';
        instContactFif1.Event_Contact_Status__c = 'Trash';//'E - Attended';
        instContactFif1.TM_Contact_Status__c = 'E - Attended';
        instContactFif1.LeadSource = 'WEB-Chat (CT-Mobile)';
        instContactFif1.Mood_Level__c = 4;
        instContactFif1.Attended__c = 'CSG';
        instContactFif1.Purchasing_Interest_Inquisium__c = '3 - Somewhat interested';
        instContactFif1.Dedicated_Ent_Support_Minutes_Purchased__c = 0;
        instContactFif1.Dedicated_Ent_Support_Minutes_Used__c = 0;
        instContactFif1.AdvocateHub__Date_Joined_AdvocateHub__c= SYSTEM.TODAY();
        insert instContactFif1;
        
        Test.startTest();
        String CRON_EXP1 = '0 0 0 1 1 ? 2025';  
        String jobId1 = System.schedule('schedulerBatchUpdateAccountCSN', CRON_EXP1, new schedulerBatchUpdateAccountCSN() );
        
        CronTrigger ct1 = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId1];
        
        System.assertEquals(CRON_EXP1, ct1.CronExpression); 
        System.assertEquals(0, ct1.TimesTriggered);
        System.assertEquals('2025-01-01 00:00:00', String.valueOf(ct1.NextFireTime));
        Test.stopTest();
    }
        
    
}