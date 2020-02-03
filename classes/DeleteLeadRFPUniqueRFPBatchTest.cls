/**@author Hemant Rana
Test Class for "DeleteLeadBatch/DeleteRFPBatch/DeleteUniqueRFPBatch"
Version 1.0
Date: 17th Feb 2016
*/
@isTest
private class DeleteLeadRFPUniqueRFPBatchTest{
    List<Task> taskObjInsert=new List<Task>();
    static Id InsertUser(integer i)
    {
         //inserting User
        Profile p = [SELECT Name FROM Profile WHERE Name = 'System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtest@testorg.com'+i);
        insert u;
        return u.Id;
    }
    
     static Id InsertAccount()
   {
        Account instofAcc = new Account();
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        //instofAcc.RecordTypeId = rtType.id;
        instofAcc.Name = 'Test';
        instofAcc.Named_Acct__c = 'Cvent Vendor';
        instofAcc.Share_of_Wallet_Tier_Max__c=2000;
        instofAcc.Purchased_License__c='Attendee Hub';
        instofAcc.HODI_Count_Dev__c=5;
        instofAcc.Supplier_Status__c='test';
        instofAcc.Account_Status__c='Test';
        //instofAcc.HODI_Id_Dev__c=HODIInventory.Id;
        insert instofAcc;
        return instofAcc.Id;
   }
    static Id InsertContact()
    {
        Contact instofCon =  new Contact();
        instOfCon.LastName = 'Test';
        instOfCon.AccountId = InsertAccount();
        instOfCon.Marketo_Active__c=false;
        insert instOfCon;
        return instOfCon.Id;
        
    }
    static Id InsertPortalUser(integer i)
    {
         //inserting User
        Profile p = [SELECT Name FROM Profile WHERE Name LIKE '%Community User%' LIMIT 1]; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, ContactId = InsertContact(),
        TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtest@testorg.com'+i);
        insert u;
        return u.Id;
    }
   
    static testMethod void TestDeleteLead()
    {
        Datetime yearBackDate = Date.today().addYears(-2);
        //Lead insert
        Lead leadObj=new Lead();
        leadObj.LastName='Test Lead';
        leadObj.Company='Test Company';
        leadObj.Product_Desired__c='CSN';
        leadObj.Status='Open';
        insert leadObj;
        Test.setCreatedDate(leadObj.Id, yearBackDate);
        //Task insert
        Task taskObj = new Task();
        Map<String,Id> rtNameVsId_Map=new Map<String,Id>();
        For(RecordType rtType_Task : [SELECT Id,SobjectType, DeveloperName, IsActive FROM RecordType WHERE SobjectType='Task' And IsActive=true])
        {
            rtNameVsId_Map.put(rtType_Task.DeveloperName,rtType_Task.Id);
        }
        taskObj.WhoId=leadObj.Id;
        //taskObj.RecordTypeId=rtNameVsId_Map.get(recordTypeName);//getTaskRecordType().get(recordTypeName).getRecordTypeId();
        taskObj.OwnerId=insertUser(1);
        taskObj.Subject='Build Task';
        taskObj.ActivityDate=system.today();
        taskObj.Priority='Low';
        taskObj.Minutes_on_tasks__c=0;
        taskObj.Status='Completed';
        insert taskObj;
        Test.setCreatedDate(taskObj.Id, yearBackDate);
        //Closed Task Inserted
        taskObj = new Task();
        taskObj.WhoId=leadObj.Id;
        //taskObj.RecordTypeId=rtNameVsId_Map.get(recordTypeName);//getTaskRecordType().get(recordTypeName).getRecordTypeId();
        taskObj.OwnerId=insertUser(2);
        taskObj.Subject='Build Task';
        taskObj.ActivityDate=system.today();
        taskObj.Priority='High';
        taskObj.Minutes_on_tasks__c=0;
        taskObj.Status='Cancelled';
        insert taskObj;
        Test.setCreatedDate(taskObj.Id, yearBackDate);
        //Event insert
        Event eventObj=new Event();
        /*Map<String,Id> eventRtNameVsId_Map=new Map<String,Id>();
        For(RecordType rtType_Task : [SELECT Id,SobjectType, DeveloperName, IsActive FROM RecordType WHERE SobjectType='Event' And IsActive=true])
        {
            eventRtNameVsId_Map.put(rtType_Task.DeveloperName,rtType_Task.Id);
        }
        eventObj.WhoId=leadObj.Id;
        eventObj.RecordTypeId=eventRtNameVsId_Map.get(recordTypeName);//getTaskRecordType().get(recordTypeName).getRecordTypeId();*/
        eventObj.OwnerId=insertUser(3);
        eventObj.Subject='Build Task';
        eventObj.StartDateTime=system.now();
        eventObj.EndDateTime=system.now();
        eventObj.Source__c='Low';
        insert eventObj;
        Test.setCreatedDate(eventObj.Id, yearBackDate);
        Test.startTest();
        DeleteLeadBatch deleteLead=new DeleteLeadBatch();
        Database.executeBatch(deleteLead);
        Test.stopTest();
    }
    static testMethod void TestDeleteRFP()
    {
        Datetime yearBackDateTime = Date.today().addYears(-4);
        Date yearBackDate = date.newinstance(yearBackDateTime.year(), yearBackDateTime.month(), yearBackDateTime.day());
        RFP__c rfpObj=new RFP__c();
        rfpObj.Name='Test RPF';
        rfpObj.RFP_Code__c='Test12345';
        rfpObj.Unique_Code__c='TestUnique12345';
        rfpObj.Response_Date__c=yearBackDate;
        rfpObj.Supplier_Account__c=InsertAccount();
        rfpObj.Status__c='Awarded';
        insert rfpObj;
        Test.setCreatedDate(rfpObj.Id, yearBackDateTime);
        Test.startTest();
        DeleteRFPBatch deleteRFP=new DeleteRFPBatch();
        Database.executeBatch(deleteRFP);
        Test.stopTest();
    }
    static testMethod void TestDeleteUniqueRFP()
    {
        Datetime yearBackDateTime = Date.today().addYears(-4);
        Date yearBackDate = date.newinstance(yearBackDateTime.year(), yearBackDateTime.month(), yearBackDateTime.day());
        Unique_RFPs__c uniqueRFPObj=new Unique_RFPs__c();
        uniqueRFPObj.Name='Test Unique RPF';
        uniqueRFPObj.RFP_Code__c='Test12345';
        uniqueRFPObj.Contact__c=InsertContact();
        uniqueRFPObj.Planner_Ac__c=InsertAccount();
        uniqueRFPObj.Original_Send_Date__c=yearBackDate;
        uniqueRFPObj.Event_Start_Date__c= yearBackDate;
        uniqueRFPObj.Status__c='Awaiting';
        insert uniqueRFPObj;
        //Test.setCreatedDate(uniqueRFPObj.Id, yearBackDateTime);
        Test.startTest();
        DeleteUniqueRFPBatch deleteRFP=new DeleteUniqueRFPBatch();
        Database.executeBatch(deleteRFP);
        Test.stopTest();
    }
    static testMethod void TestContactDeletionBatch()
    {
        InsertContact();
        InsertPortalUser(1);
        Test.startTest();
        ContactDeletionBatch deleteContact=new ContactDeletionBatch();
        Database.executeBatch(deleteContact);
        Test.stopTest();
    }
}