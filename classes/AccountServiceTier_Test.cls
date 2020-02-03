/**@author Hemant Rana
Test Class for "AccountServiceTierAssignment_Batch" && "AccountHODIPage_Controller"
Version 1.0
Date: 17th Feb 2016
*/
@isTest
private class AccountServiceTier_Test{
   Private Static Service_Tier_Mapping__c serviceTier;
   Private Static Account instofAcc = new Account();
   Private Static RecordType rtType = [SELECT r.SobjectType, r.DeveloperName,r.IsActive FROM RecordType r WHERE SobjectType='Account' And DeveloperName='Biz_Ac' And IsActive=true];

   private static void insertServiceTier()
   {
        List<Service_Tier_Mapping__c> serviceTierList=new List<Service_Tier_Mapping__c>();
        //inserting Service Tier Mapping Record
        serviceTier=new Service_Tier_Mapping__c();
        serviceTier.Name='Bronze';
        serviceTier.Min_Amount__c =0;
        serviceTier.Max_Amount__c=5000;
        serviceTier.Event_Cloud_Vs_Hospitality_Cloud__c='Event';
        serviceTierList.add(serviceTier);
        
        serviceTier=new Service_Tier_Mapping__c();
        serviceTier.Name='Silver';
        serviceTier.Min_Amount__c =5000;
        serviceTier.Max_Amount__c=10000;
        serviceTier.Event_Cloud_Vs_Hospitality_Cloud__c='Event';
        serviceTierList.add(serviceTier);
        
        serviceTier=new Service_Tier_Mapping__c();
        serviceTier.Name='Gold';
        serviceTier.Min_Amount__c =10000;
        serviceTier.Max_Amount__c=12000;
        serviceTier.Event_Cloud_Vs_Hospitality_Cloud__c='Event';
        serviceTierList.add(serviceTier);
        
        serviceTier=new Service_Tier_Mapping__c();
        serviceTier.Name='Platinum';
        serviceTier.Min_Amount__c =12000;
        serviceTier.Max_Amount__c=15000;
        serviceTier.Event_Cloud_Vs_Hospitality_Cloud__c='Event';
        serviceTierList.add(serviceTier);
        
        serviceTier=new Service_Tier_Mapping__c();
        serviceTier.Name='Uber';
        serviceTier.Min_Amount__c =12000;
        serviceTier.Max_Amount__c=20000;
        serviceTier.Event_Cloud_Vs_Hospitality_Cloud__c='Event';
        serviceTierList.add(serviceTier);
        
        serviceTier=new Service_Tier_Mapping__c();
        serviceTier.Name='Bronze';
        serviceTier.Min_Amount__c =0;
        serviceTier.Max_Amount__c=5000;
        serviceTier.Event_Cloud_Vs_Hospitality_Cloud__c='Hospitality';
        serviceTierList.add(serviceTier);
        
        serviceTier=new Service_Tier_Mapping__c();
        serviceTier.Name='Silver';
        serviceTier.Min_Amount__c =5000;
        serviceTier.Max_Amount__c=10000;
        serviceTier.Event_Cloud_Vs_Hospitality_Cloud__c='Hospitality';
        serviceTierList.add(serviceTier);
        
        serviceTier=new Service_Tier_Mapping__c();
        serviceTier.Name='Gold';
        serviceTier.Min_Amount__c =10000;
        serviceTier.Max_Amount__c=12000;
        serviceTier.Event_Cloud_Vs_Hospitality_Cloud__c='Hospitality';
        serviceTierList.add(serviceTier);
        
        serviceTier=new Service_Tier_Mapping__c();
        serviceTier.Name='Platinum';
        serviceTier.Min_Amount__c =12000;
        serviceTier.Max_Amount__c=15000;
        serviceTier.Event_Cloud_Vs_Hospitality_Cloud__c='Hospitality';
        serviceTierList.add(serviceTier);
        
        insert serviceTierList;
        
       
   }
   
   
    static testMethod void test_EventVsHospitalityCloud(){
        //inserting User
        Profile p = [SELECT Name FROM Profile WHERE Name = 'System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtest@testorg.com');
        insert u;
        
        //inserting HODI record
        HODI_Inventory__c HODIInventory=new HODI_Inventory__c();
        HODIInventory.Name='Test User';
        HODIInventory.Head_of_Department__c=u.Id;
        HODIInventory.Pool_Point__c=50;
        insert HODIInventory;
        
        insertServiceTier();
        
        instofAcc = new Account();
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        instofAcc.RecordTypeId = rtType.id;
        instofAcc.Name = 'Test';
        instofAcc.Named_Acct__c = 'Cvent Vendor';
        instofAcc.Share_of_Wallet_Tier_Max__c=1100;
        instOfAcc.HC_Share_of_Wallet_Client__c=500;
        //instofAcc.Service_Tier__c ='Bronze';
        insert instofAcc;
        Test.startTest();
        AccountServiceTierAssignment_Batch accHelper = new AccountServiceTierAssignment_Batch();
        Database.executeBatch(accHelper);
        Test.stopTest();
    }
    static testMethod void test_EventCloud_NoTier(){
        //inserting User
        Profile p = [SELECT Name FROM Profile WHERE Name = 'System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtest@testorg.com');
        insert u;
        
        //inserting HODI record
        HODI_Inventory__c HODIInventory=new HODI_Inventory__c();
        HODIInventory.Name='Test User';
        HODIInventory.Head_of_Department__c=u.Id;
        HODIInventory.Pool_Point__c=50;
        insert HODIInventory;
        
        insertServiceTier();
        
        instofAcc = new Account();
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        instofAcc.RecordTypeId = rtType.id;
        instofAcc.Name = 'Test';
        instofAcc.Named_Acct__c = 'Cvent Vendor';
        instofAcc.Share_of_Wallet_Tier_Max__c=400;
        insert instofAcc;
        
        Test.startTest();
        AccountServiceTierAssignment_Batch accHelper = new AccountServiceTierAssignment_Batch();
        Database.executeBatch(accHelper);
        Test.stopTest();
    }
    static testMethod void test_EventCloud_WithTier(){
        //inserting User
        Profile p = [SELECT Name FROM Profile WHERE Name = 'System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtest@testorg.com');
        insert u;
        
        //inserting HODI record
        HODI_Inventory__c HODIInventory=new HODI_Inventory__c();
        HODIInventory.Name='Test User';
        HODIInventory.Head_of_Department__c=u.Id;
        HODIInventory.Pool_Point__c=50;
        insert HODIInventory;
        
        insertServiceTier();
        
        instofAcc = new Account();
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        instofAcc.RecordTypeId = rtType.id;
        instofAcc.Name = 'Test';
        instofAcc.Named_Acct__c = 'Cvent Vendor';
        instofAcc.Share_of_Wallet_Tier_Max__c=9999;
        instofAcc.Service_Tier__c ='Bronze';
        insert instofAcc;
        
        Test.startTest();
        AccountServiceTierAssignment_Batch accHelper = new AccountServiceTierAssignment_Batch();
        Database.executeBatch(accHelper);
        Test.stopTest();
    }
    static testMethod void test_EventCloud_WithTierDowngrade(){
        //inserting User
        Profile p = [SELECT Name FROM Profile WHERE Name = 'System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtest@testorg.com');
        insert u;
        
        //inserting HODI record
        HODI_Inventory__c HODIInventory=new HODI_Inventory__c();
        HODIInventory.Name='Test User';
        HODIInventory.Head_of_Department__c=u.Id;
        HODIInventory.Pool_Point__c=50;
        insert HODIInventory;
        
        insertServiceTier();
        
        instofAcc = new Account();
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        instofAcc.RecordTypeId = rtType.id;
        instofAcc.Name = 'Test';
        instofAcc.Named_Acct__c = 'Cvent Vendor';
        instofAcc.Share_of_Wallet_Tier_Max__c=400;
        instofAcc.Service_Tier__c ='Gold';
        insert instofAcc;
        
        Test.startTest();
        AccountServiceTierAssignment_Batch accHelper = new AccountServiceTierAssignment_Batch();
        Database.executeBatch(accHelper);
        Test.stopTest();
    }
    static testMethod void test_batchClass_Hospitality_NoTier(){
        //inserting User
        Profile p = [SELECT Name FROM Profile WHERE Name = 'System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtest@testorg.com');
        insert u;
        
        //inserting HODI record
        HODI_Inventory__c HODIInventory=new HODI_Inventory__c();
        HODIInventory.Name='Test User';
        HODIInventory.Head_of_Department__c=u.Id;
        HODIInventory.Pool_Point__c=50;
        insert HODIInventory;
        
        insertServiceTier();
        
        instofAcc = new Account();
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        instofAcc.RecordTypeId = rtType.id;
        instofAcc.Name = 'Test';
        instofAcc.Named_Acct__c = 'Cvent Vendor';
        instOfAcc.HC_Share_of_Wallet_Client__c=550;
        insert instofAcc;
        
        Test.startTest();
        AccountServiceTierAssignment_Batch accHelper = new AccountServiceTierAssignment_Batch();
        Database.executeBatch(accHelper);
        Test.stopTest();
    }
    static testMethod void test_batchClass_Hospitality_WithTier(){
        //inserting User
        Profile p = [SELECT Name FROM Profile WHERE Name = 'System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtest@testorg.com');
        insert u;
        
        //inserting HODI record
        HODI_Inventory__c HODIInventory=new HODI_Inventory__c();
        HODIInventory.Name='Test User';
        HODIInventory.Head_of_Department__c=u.Id;
        HODIInventory.Pool_Point__c=50;
        insert HODIInventory;
        
        insertServiceTier();
        
        instofAcc = new Account();
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        instofAcc.RecordTypeId = rtType.id;
        instofAcc.Name = 'Test';
        instofAcc.Named_Acct__c = 'Cvent Vendor';
        instOfAcc.HC_Share_of_Wallet_Client__c=5600;
        instofAcc.Service_Tier__c ='Bronze';
        insert instofAcc;
        
        Test.startTest();
        AccountServiceTierAssignment_Batch accHelper = new AccountServiceTierAssignment_Batch();
        Database.executeBatch(accHelper);
        Test.stopTest();
    }

      //Method for testing the process builder class "AccountServiceHelperClass"
   static testMethod void test_AccountServiceHelperClass()
   {
                       //inserting User
        Profile p = [SELECT Name FROM Profile WHERE Name = 'System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtest@testorg.com');
        insert u;
        
        //inserting HODI record
        HODI_Inventory__c HODIInventory=new HODI_Inventory__c();
        HODIInventory.Name='Test User';
        HODIInventory.Head_of_Department__c=u.Id;
        HODIInventory.Pool_Point__c=50;
        insert HODIInventory;
        
        List<Id> accountIds=new List<Id>();
        instofAcc = new Account();
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        instofAcc.RecordTypeId = rtType.id;
        instofAcc.Name = 'Test';
        instofAcc.Named_Acct__c = 'Cvent Vendor';
        instofAcc.Share_of_Wallet_Tier_Max__c=2000;
        instofAcc.Purchased_License__c='Attendee Hub';
        instofAcc.HODI_Count_Dev__c=5;
        instofAcc.HODI_Id_Dev__c=HODIInventory.Id;
        insert instofAcc;
        accountIds.add(instofAcc.Id);
        AccountServiceHelperClass.AccountServiceHelperMethod(accountIds);
   }
    //test Method for the "ScheduledAccountServiceTier" class
   static testMethod void test_schedulerClass()
   {
       Test.startTest();
       ScheduledAccountServiceTier schedulerVar=new ScheduledAccountServiceTier();
       String sch = '0 0 23 * * ?'; 
       system.schedule('Test Account ServiceTier Batch', sch, schedulerVar); 
       Test.stopTest();
   }
   //Method for only used for testing the "AccountServiceTierAssignment_Batch" Batch Class
   
    //Method used for "AccountServiceTierAssignment_Batch" Batch class as well as "AccountHODIPage_Controller"
    static testMethod void test_upgradeService_EventCloud(){
        
        //inserting User
        Profile p = [SELECT Name FROM Profile WHERE Name = 'System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtest@testorg.com');
        insert u;
        
        //inserting HODI record
        HODI_Inventory__c HODIInventory=new HODI_Inventory__c();
        HODIInventory.Name='Test User';
        HODIInventory.Head_of_Department__c=u.Id;
        HODIInventory.Pool_Point__c=50;
        insert HODIInventory;
        
        //Call this methdo to insert Service_tier_mapping Records
        insertServiceTier();
       
        //inserting Account Record 
        
        instofAcc = new Account();
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        instofAcc.RecordTypeId = rtType.id;
        instofAcc.Name = 'Test';
        instofAcc.Named_Acct__c = 'Cvent Vendor';
        instofAcc.Share_of_Wallet_Tier_Max__c=5600;
        instofAcc.Service_Tier__c ='Bronze';
        instofAcc.Purchased_License__c='Attendee Hub';
        insert instofAcc;
        
        Test.startTest();
        AccountServiceTierAssignment_Batch accHelper = new AccountServiceTierAssignment_Batch();
        Database.executeBatch(accHelper);
        Test.stopTest();
        
        PageReference pageRef=Page.AccountHODIPage;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController controller=new ApexPages.StandardController(instofAcc);
        AccountHODIPage_Controller pageExtension=new AccountHODIPage_Controller(controller);
        ApexPages.currentPage().getParameters().put('Id',instofAcc.Id);
        pageExtension.tierName = 'Gold';
        pageExtension.HODIName = u.id;
        pageExtension.getHODIList();
        pageExtension.getTierList();
        pageExtension.submitForApproval();
        /*pageExtension.tierName = 'Platinum';
        pageExtension.HODIName = u.id;
        
        pageExtension.submitForApproval();*/
        
        
    }
    static testMethod void test_upgradeService_HospitalityCloud(){
        
        //inserting User
        Profile p = [SELECT Name FROM Profile WHERE Name = 'System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtest@testorg.com');
        insert u;
        
        //inserting HODI record
        HODI_Inventory__c HODIInventory=new HODI_Inventory__c();
        HODIInventory.Name='Test User';
        HODIInventory.Head_of_Department__c=u.Id;
        HODIInventory.Pool_Point__c=50;
        insert HODIInventory;
        
        //Call this methdo to insert Service_tier_mapping Records
        insertServiceTier();
       
        //inserting Account Record 
        
        instofAcc = new Account();
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        instofAcc.RecordTypeId = rtType.id;
        instofAcc.Name = 'Test';
        instofAcc.Named_Acct__c = 'Cvent Vendor';
        instofAcc.HC_Share_of_Wallet_Client__c=5600;
        instofAcc.Service_Tier__c ='Bronze';
        instofAcc.Purchased_License__c='Attendee Hub';
        insert instofAcc;
        
        Test.startTest();
        AccountServiceTierAssignment_Batch accHelper = new AccountServiceTierAssignment_Batch();
        Database.executeBatch(accHelper);
        Test.stopTest();
        
        PageReference pageRef=Page.AccountHODIPage;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController controller=new ApexPages.StandardController(instofAcc);
        AccountHODIPage_Controller pageExtension=new AccountHODIPage_Controller(controller);
        ApexPages.currentPage().getParameters().put('Id',instofAcc.Id);
        pageExtension.tierName = 'Gold';
        pageExtension.HODIName = u.id;
        pageExtension.getHODIList();
        pageExtension.getTierList();
        pageExtension.submitForApproval();
        /*pageExtension.tierName = 'Platinum';
        pageExtension.HODIName = u.id;
        
        pageExtension.submitForApproval();*/
        
        
    }
    //Below Method used for "AccountHODIPage_Controller" Class
    static testMethod void test_NoShareOfWalletException(){
        //inserting User
        Profile p = [SELECT Name FROM Profile WHERE Name = 'System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtest@testorg.com');
        insert u;
        
        //inserting account
        
        instofAcc = new Account();
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        instofAcc.RecordTypeId = rtType.id;
        instofAcc.Name = 'Test';
        instofAcc.Named_Acct__c = 'Cvent Vendor';
        //instofAcc.Share_of_Wallet_Tier_Max__c=4600;
        instofAcc.Purchased_License__c='Attendee Hub';
        insert instofAcc;
        
        
        PageReference pageRef=Page.AccountHODIPage;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController controller=new ApexPages.StandardController(instofAcc);
        AccountHODIPage_Controller pageExtension=new AccountHODIPage_Controller(controller);
        ApexPages.currentPage().getParameters().put('Id',instofAcc.Id);
        pageExtension.tierName = 'Silver';
        pageExtension.HODIName = u.id;
        pageExtension.getHODIList();
        pageExtension.getTierList();
        //pageExtension.submitForApproval();
    }
    static testMethod void test_Exception(){
        
        List<Service_Tier_Mapping__c> serviceTierList=new List<Service_Tier_Mapping__c>();
        
        //inserting User
        Profile p = [SELECT Name FROM Profile WHERE Name = 'System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtest@testorg.com');
        insert u;
        
        //inserting HODI record
        HODI_Inventory__c HODIInventory=new HODI_Inventory__c();
        HODIInventory.Name='Test User';
        HODIInventory.Head_of_Department__c=u.Id;
        HODIInventory.Pool_Point__c=50;
        insert HODIInventory;
        
        //Call this methdo to insert Service_tier_mapping Records
        insertServiceTier();
        
        //inserting Account Record 
        
        instofAcc = new Account();
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        instofAcc.RecordTypeId = rtType.id;
        instofAcc.Name = 'Test';
        instofAcc.Named_Acct__c = 'Cvent Vendor';
        instofAcc.Share_of_Wallet_Tier_Max__c=4600;
        instofAcc.Service_Tier__c ='Gold';
        instofAcc.Purchased_License__c='Attendee Hub';
        insert instofAcc;
        
        PageReference pageRef=Page.AccountHODIPage;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController controller=new ApexPages.StandardController(instofAcc);
        AccountHODIPage_Controller pageExtension=new AccountHODIPage_Controller(controller);
        ApexPages.currentPage().getParameters().put('Id',instofAcc.Id);
        pageExtension.tierName = 'Silver';
        pageExtension.HODIName = u.id;
        pageExtension.getHODIList();
        pageExtension.getTierList();
        pageExtension.submitForApproval();
    }
    static testMethod void test_noPoolPoint(){
        
        List<Service_Tier_Mapping__c> serviceTierList=new List<Service_Tier_Mapping__c>();
        
        //inserting User
        Profile p = [SELECT Name FROM Profile WHERE Name = 'System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtest@testorg.com');
        insert u;
        
        //inserting HODI record
        HODI_Inventory__c HODIInventory=new HODI_Inventory__c();
        HODIInventory.Name='Test User';
        HODIInventory.Head_of_Department__c=u.Id;
        HODIInventory.Pool_Point__c=0;
        insert HODIInventory;
        
        //Call this methdo to insert Service_tier_mapping Records
        insertServiceTier();
        
        //inserting Account Record 
        
        instofAcc = new Account();
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        instofAcc.RecordTypeId = rtType.id;
        instofAcc.Name = 'Test';
        instofAcc.Named_Acct__c = 'Cvent Vendor';
        instofAcc.Share_of_Wallet_Tier_Max__c=4600;
        instofAcc.Service_Tier__c ='Bronze';
        instofAcc.Purchased_License__c='Attendee Hub';
        insert instofAcc;
        
        PageReference pageRef=Page.AccountHODIPage;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController controller=new ApexPages.StandardController(instofAcc);
        AccountHODIPage_Controller pageExtension=new AccountHODIPage_Controller(controller);
        ApexPages.currentPage().getParameters().put('Id',instofAcc.Id);
        pageExtension.tierName = 'Bronze';
        pageExtension.HODIName = u.id;
        pageExtension.getHODIList();
        pageExtension.getTierList();
        pageExtension.submitForApproval();
    }
        static testMethod void test_insufficientPoolPoint(){
        
        List<Service_Tier_Mapping__c> serviceTierList=new List<Service_Tier_Mapping__c>();
        
        //inserting User
        Profile p = [SELECT Name FROM Profile WHERE Name = 'System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtest@testorg.com');
        insert u;
        
        //inserting HODI record
        HODI_Inventory__c HODIInventory=new HODI_Inventory__c();
        HODIInventory.Name='Test User';
        HODIInventory.Head_of_Department__c=u.Id;
        HODIInventory.Pool_Point__c=0;
        insert HODIInventory;
        
        //Call this methdo to insert Service_tier_mapping Records
        insertServiceTier();
        
        //inserting Account Record 
        
        instofAcc = new Account();
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        instofAcc.RecordTypeId = rtType.id;
        instofAcc.Name = 'Test';
        instofAcc.Named_Acct__c = 'Cvent Vendor';
        instofAcc.Share_of_Wallet_Tier_Max__c=5600;
        instofAcc.Service_Tier__c ='Silver';
        instofAcc.Purchased_License__c='Attendee Hub';
        insert instofAcc;
        
        PageReference pageRef=Page.AccountHODIPage;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController controller=new ApexPages.StandardController(instofAcc);
        AccountHODIPage_Controller pageExtension=new AccountHODIPage_Controller(controller);
        ApexPages.currentPage().getParameters().put('Id',instofAcc.Id);
        pageExtension.tierName = 'Bronze';
        pageExtension.HODIName = u.id;
        pageExtension.getHODIList();
        pageExtension.getTierList();
        pageExtension.submitForApproval();
    }
    
    static testMethod void test_Degrade_EventCloud(){
        
        List<Service_Tier_Mapping__c> serviceTierList=new List<Service_Tier_Mapping__c>();

        //inserting User
        Profile p = [SELECT Name FROM Profile WHERE Name = 'System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtest@testorg.com');
        insert u;
        
        //inserting HODI record
        HODI_Inventory__c HODIInventory=new HODI_Inventory__c();
        HODIInventory.Name='Test User';
        HODIInventory.Head_of_Department__c=u.Id;
        HODIInventory.Pool_Point__c=50;
        insert HODIInventory;
        
        //Call this methdo to insert Service_tier_mapping Records
        insertServiceTier();
        
        //inserting Account Record 
        
        instofAcc = new Account();
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        instofAcc.RecordTypeId = rtType.id;
        instofAcc.Name = 'Test';
        instofAcc.Named_Acct__c = 'Cvent Vendor';
        instofAcc.Share_of_Wallet_Tier_Max__c=4600;
        instofAcc.Service_Tier__c ='Gold';
        instofAcc.Purchased_License__c='Attendee Hub';
        insert instofAcc;
        
        //inserting Account_HODI__c record
        Account_HODI__c accountHODI= new Account_HODI__c();
        accountHODI.Account__c=instofAcc.id;
        accountHODI.Desired_Tier__c='Gold';
        accountHODI.HODI_Inventory__c=HODIInventory.Id;
        accountHODI.Points__c=2;
        accountHODI.Previous_Tier__c='Bronze';
        insert accountHODI;
        
        PageReference pageRef=Page.AccountHODIPage;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController controller=new ApexPages.StandardController(instofAcc);
        AccountHODIPage_Controller pageExtension=new AccountHODIPage_Controller(controller);
        ApexPages.currentPage().getParameters().put('Id',instofAcc.Id);
        pageExtension.tierName = 'Silver';
        pageExtension.HODIName = u.id;
        pageExtension.getHODIList();
        pageExtension.getTierList();
        pageExtension.submitForApproval();
    }
        static testMethod void test_Degrade_HospitalityCloud(){
        
        List<Service_Tier_Mapping__c> serviceTierList=new List<Service_Tier_Mapping__c>();

        //inserting User
        Profile p = [SELECT Name FROM Profile WHERE Name = 'System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtest@testorg.com');
        insert u;
        
        //inserting HODI record
        HODI_Inventory__c HODIInventory=new HODI_Inventory__c();
        HODIInventory.Name='Test User';
        HODIInventory.Head_of_Department__c=u.Id;
        HODIInventory.Pool_Point__c=50;
        insert HODIInventory;
        
        //Call this methdo to insert Service_tier_mapping Records
        insertServiceTier();
        
        //inserting Account Record 
        
        instofAcc = new Account();
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        instofAcc.RecordTypeId = rtType.id;
        instofAcc.Name = 'Test';
        instofAcc.Named_Acct__c = 'Cvent Vendor';
        instofAcc.HC_Share_of_Wallet_Client__c=4600;
        instofAcc.Service_Tier__c ='Gold';
        instofAcc.Purchased_License__c='Attendee Hub';
        insert instofAcc;
        
        //inserting Account_HODI__c record
        Account_HODI__c accountHODI= new Account_HODI__c();
        accountHODI.Account__c=instofAcc.id;
        accountHODI.Desired_Tier__c='Gold';
        accountHODI.HODI_Inventory__c=HODIInventory.Id;
        accountHODI.Points__c=2;
        accountHODI.Previous_Tier__c='Bronze';
        insert accountHODI;
        
        PageReference pageRef=Page.AccountHODIPage;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController controller=new ApexPages.StandardController(instofAcc);
        AccountHODIPage_Controller pageExtension=new AccountHODIPage_Controller(controller);
        ApexPages.currentPage().getParameters().put('Id',instofAcc.Id);
        pageExtension.tierName = 'Silver';
        pageExtension.HODIName = u.id;
        pageExtension.getHODIList();
        pageExtension.getTierList();
        pageExtension.submitForApproval();
    }
}