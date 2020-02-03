/**
//////////////////////////////////////
//      @author Abhishek Pandey     //
/////////////////////////////////////
Version :   1.0
Date : 23rd July 2014
 */
@isTest
private class AttachmentTrgHelperClsEventHelperClsTest {
    static User testUser;
    static User testUserSec;    
    static{
        Profile instProf =  [Select Id From Profile WHERE Name ='System Administrator'];
        testUser = new User(alias = 'u1', email='u1@testorg.com',emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',localesidkey='en_US', profileid = instProf.Id, 
                            timezonesidkey='America/Los_Angeles', username='u11111@testorg.com');        
        insert testUser;
        
        Account instofAcc = new Account();
        
        RecordType rtType = [SELECT r.SobjectType, r.DeveloperName,r.IsActive FROM RecordType r WHERE SobjectType='Account' And DeveloperName='Biz_Ac' And IsActive=true];
        instofAcc.Name = 'Test';
        //instofAcc.CurrencyIsoCode  = 'USD';
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        instofAcc.RecordTypeId = rtType.id;
        insert instofAcc;
         
        Contact con = new Contact();         
        con.LastName = 'Test';
        con.AccountId = instofAcc.id;
        insert con;
        
        UserRole instUserRole = [SELECT Id FROM UserRole Limit 1];
        Profile insProfSec = [SELECT Id FROM Profile WHERE Name = 'Cvent Customer Community User'];
        testUserSec = new User(alias = 'u1', email='u13434@testorg.com',emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',localesidkey='en_US', profileid = insProfSec.Id,
                            timezonesidkey='America/Los_Angeles', username='u113434111@testorg.com',contactid=con.id);
        insert testUserSec;
         
    }
    static testMethod void myUnitTest() {
        /*
        //Insert Contract Status record
        Contract_Status_Values__c contractStatusRecord= new Contract_Status_Values__c();
        contractStatusRecord.Custom_Field_Api__c='Status';
        contractStatusRecord.Picklist_Values_del__c='Received';
        insert contractStatusRecord;
        
        //insert Account Record
        Account instofAccRecord = new Account();
        RecordType rtType = [SELECT r.SobjectType, r.DeveloperName,r.IsActive FROM RecordType r WHERE SobjectType='Account' And DeveloperName='Biz_Ac' And IsActive=true];
        instofAccRecord.Name = 'Test';
        instofAccRecord.Supplier_Type__c = 'Venue';
        instofAccRecord.Venue_Type__c = 'CVB';
        instofAccRecord.RecordTypeId = rtType.id;
        insert instofAccRecord;
        //insert contract record
        Contract contractRecord= new Contract();
        contractRecord.AccountId=instofAccRecord.Id;
        contractRecord.Contract_Request_Date__c=system.today();
        contractRecord.CurrencyIsoCode='USD';
        contractRecord.Status='Received';
        insert contractRecord;
        */
        //Update Case on adding attachment
        
        Id recTypeCase= [SELECT Id from RecordType where SObjectType='Case' and Name='Event'].Id ;
        Case c = new Case();
        c.recordTypeId = recTypeCase;
            c.Product_Type__c = 'Event Tool';
            c.Status = 'Open';
            c.Minutesoncase__c = 30; 
            c.OwnerId = testUser.Id;       
            insert c;
        
        //Update Case on adding attachment
        EB_SB_Builder__c instOfEB =  new EB_SB_Builder__c();
        instOfEB.Project__c = 'Event Builder';
        instOfEB.Project_Status__c = 'Information Pending';
        instOfEB.Project_Type_del__c = 'Demo Event';
        instOfEB.Project_Complexity__c = '1-Simple';
        insert instOfEB;
        
        RecordType instRecType = [SELECT Name, IsActive, DeveloperName, SobjectType FROM RecordType WHERE SobjectType='Event' And IsActive = true And DeveloperName = 'SMM_BD_Presentations' ];
        Event instOfEvent = new Event();
        instOfEvent.WhatId = instOfEB.Id;
        instOfEvent.OwnerId = UserInfo.getUserId();
        instOfEvent.Subject = 'Test';
        instOfEvent.Source__c = 'Chat';
        instOfEvent.StartDateTime = system.today();
        instOfEvent.EndDateTime = system.today();
        instOfEvent.Minutes_on_tasks__c = 80;
        //instOfEvent.CurrencyIsoCode = 'USD';
        instOfEvent.RecordTypeId = instRecType.id;
        insert instOfEvent;
        

        
        //Insert attachment for Contract Record
        Attachment attachContract = new Attachment();       
        attachContract.Name='Unit Test Attachment Of Contract';
        Blob bodyBlobContract = Blob.valueOf('Unit Test Attachment Body of Contract');
        attachContract.body = bodyBlobContract;
        //attachContract.parentId = contractRecord.id;
        attachContract.parentId = c.id;
        insert attachContract;
        
        Test.startTest();
        Attachment attach = new Attachment();       
        attach.Name='Unit Test Attachment';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attach.body = bodyBlob;
        attach.parentId = instOfEvent.id;
        insert attach;
        
        delete attach;
        undelete attach;
        Event instOfEventSec = [SELECT Id FROM Event WHERE Id =: instOfEvent.Id];
        
        Attachment attachSec = new Attachment();    
        attachSec.Name='Unit Test Attachment';
        Blob bodyBlobSec = Blob.valueOf('Unit Test Attachment Body');
        attachSec.body = bodyBlobSec;
        attachSec.parentId = instOfEventSec.id;
        insert attachSec;
        
        Attachment instAttach =  [SELECT Id,Name FROM Attachment WHERE Id=:attachSec.Id];
        instAttach.Name = 'Test';
        update instAttach;
        
        
       
        
        system.runAs(testUserSec){
            RecordType instRecTypeSec = [SELECT SobjectType,Id,name,DeveloperName FROM RecordType WHERE SobjectType='Case' And IsActive=true And DeveloperName = 'Portal_Cases' Limit 1];
            Case instOfCase = new Case();
            instOfCase.Status = 'Open';
            instOfCase.Description = 'Test';
            instOfCase.Product_Type__c = 'Event Management';
            instOfCase.Topic__c = 'Reports';
            instOfCase.Subtopic__c = 'Other';
            instOfCase.Subject = 'Test';
            //instOfCase.RecordTypeId = instRecTypeSec.id;
            insert instOfCase;
            
            Case instOfCaseThir  = [SELECT Id FROM Case WHERE Id=:instOfCase.id];
            Test.stopTest();
            Attachment attachThird = new Attachment();    
            attachThird.Name='Unit Test Attachment';
            Blob bodyBlobThird = Blob.valueOf('Unit Test Attachment Body');
            attachThird.body = bodyBlobThird;
            attachThird.parentId = instOfCaseThir.id;
            try{        
                insert attachThird;
            }catch(Exception e){
                system.debug('');
            }
        }
        
    }
    static testMethod void myUnitTestSec() {
        EB_SB_Builder__c instOfEB =  new EB_SB_Builder__c();
        instOfEB.Project__c = 'Event Builder';
        instOfEB.Project_Status__c = 'Information Pending';
        instOfEB.Project_Type_del__c = 'Demo Event';
        instOfEB.Project_Complexity__c = '1-Simple';
        insert instOfEB;
        
        Event_Attachment_Email_Sending_Mapping__c insTEventAESM = new Event_Attachment_Email_Sending_Mapping__c();
        insTEventAESM.User_Creating__c = UserInfo.getUserId();
        insTEventAESM.User_Mapped__c =  UserInfo.getUserId();
        insTEventAESM.Name = 'Test';
        insert insTEventAESM;
        
        Task instOfTsk = new Task();
        instOfTsk.OwnerId = UserInfo.getUserId();
        instOfTsk.WhatId = instOfEB.Id;
        instOfTsk.Subject = 'Test';
        instOfTsk.ActivityDate = system.Today();
        instOfTsk.Priority = 'Normal';
        instOfTsk.Minutes_on_tasks__c = 60;
        instOfTsk.Status = 'Completed';
        insert instOfTsk;
        Test.startTest(); 
        RecordType instRecTypeThir = [SELECT SobjectType,Id,name,DeveloperName FROM RecordType WHERE SobjectType='Case' And IsActive=true And DeveloperName = 'Eventbuilder' Limit 1];
        Case instOfCaseSec = new Case();
        instOfCaseSec.RecordTypeId = instRecTypeThir.Id;
        instOfCaseSec.Status = 'Open';
        instOfCaseSec.Description = 'Test';
        instOfCaseSec.Product_Type__c = 'Event Management';
        instOfCaseSec.Topic__c = 'Reports';
        instOfCaseSec.Subtopic__c = 'Other';
        instOfCaseSec.Subject = 'Test';
        instOfCaseSec.Min_s_Spent__c = 20;
        instOfCaseSec.Event_Survey_Builder__c = instOfEB.Id;
        //instOfCase.RecordTypeId = instRecTypeSec.id;
        insert instOfCaseSec;
      
        
        /*
        RecordType instRecType = [SELECT Name, IsActive, DeveloperName, SobjectType FROM RecordType WHERE SobjectType='Event' And IsActive = true And DeveloperName = 'SMM_BD_Presentations' ];
        Event instOfEvent = new Event();
        instOfEvent.WhatId = instOfEB.Id;
        instOfEvent.OwnerId = UserInfo.getUserId();
        instOfEvent.Subject = 'Test';
        instOfEvent.Source__c = 'Chat';
        instOfEvent.StartDateTime = system.today();
        instOfEvent.EndDateTime = system.today();
        instOfEvent.Minutes_on_tasks__c = 80;
        //instOfEvent.CurrencyIsoCode = 'USD';
        instOfEvent.RecordTypeId = instRecType.id;
        insert instOfEvent;
        
        Event instOfEventThir = [SELECT ID,Minutes_on_tasks__c FROM Event WHERE Id=: instOfEvent.Id];
        instOfEventThir.Minutes_on_tasks__c = 60;
        update instOfEventThir;
        */
        Task instOfTskSec = [SELECT ID,Minutes_on_tasks__c FROM Task WHERE Id=: instOfTsk.Id];
        instOfTskSec.Minutes_on_tasks__c = 55;
        update instOfTskSec;
        
        Case instOfCaseFor = [SELECT ID,Min_s_Spent__c FROM Case WHERE Id=: instOfCaseSec.Id];
        instOfCaseFor.Min_s_Spent__c = 30;
        update instOfCaseFor;
        Test.stopTest();  
        /*
        delete instOfTskSec;
        delete instOfCaseFor;
        
        delete instOfEventThir;
        */
        
    }
    
    static testMethod void myUnitTestThir(){
        
        //RecordType instRecType = [SELECT Name, IsActive, DeveloperName, SobjectType FROM RecordType WHERE SobjectType='Event' And IsActive = true And DeveloperName = 'SMM_BD_Presentations' ];
        RecordType instRecType = [SELECT Name, IsActive, DeveloperName, SobjectType FROM RecordType WHERE SobjectType='Event' And IsActive = true And DeveloperName = 'SMM_BD_Presentations' ];
        
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
        Test.startTest();  
        Task instOfTskThir = new Task();
        instOfTskThir.OwnerId = UserInfo.getUserId();
        instOfTskThir.WhatId = instOfPA.Id;
        instOfTskThir.Subject = 'Test';
        instOfTskThir.ActivityDate = system.Today();
        instOfTskThir.Priority = 'Normal';
        instOfTskThir.Minutes_on_tasks__c = 60;
        instOfTskThir.Status = 'Completed';
        insert instOfTskThir;
        
        Event instOfEventFort = new Event();
        instOfEventFort.WhatId = instOfPA.Id;
        instOfEventFort.OwnerId = UserInfo.getUserId();
        instOfEventFort.Subject = 'Test';
        instOfEventFort.Source__c = 'Chat';
        instOfEventFort.StartDateTime = system.today();
        instOfEventFort.EndDateTime = system.today();
        instOfEventFort.Minutes_on_tasks__c = 80;
        //instOfEvent.CurrencyIsoCode = 'USD';
        instOfEventFort.RecordTypeId = instRecType.id;
        insert instOfEventFort;
        test.stopTest();
        instOfTskThir.Minutes_on_tasks__c = 10;
        update instOfTskThir;
        
        instOfEventFort.Minutes_on_tasks__c = 34;
        update instOfEventFort;
        
        delete instOfTskThir;
        delete instOfEventFort;
    }
    
    
    static testMethod void myUnitTestFor() {
    
        EB_SB_Builder__c instOfEB =  new EB_SB_Builder__c();
        instOfEB.Project__c = 'Event Builder';
        instOfEB.Project_Status__c = 'Information Pending';
        instOfEB.Project_Type_del__c = 'Demo Event';
        instOfEB.Project_Complexity__c = '1-Simple';
        insert instOfEB;
        
          
        Case c = new Case();        
        c.Product_Type__c = 'Event Tool';
        c.Status = 'Open';
        c.Minutesoncase__c = 30; 
        c.OwnerId = testUser.Id;       
        c.Min_s_Spent__c = 10;
        c.Event_Survey_Builder__c = instOfEB.Id;
        insert c;
        
        
        Event_Attachment_Email_Sending_Mapping__c insTEventAESM = new Event_Attachment_Email_Sending_Mapping__c();
        insTEventAESM.User_Creating__c = UserInfo.getUserId();
        insTEventAESM.User_Mapped__c =  UserInfo.getUserId();
        insTEventAESM.Name = 'Test';
        insert insTEventAESM;
        
        Task instOfTsk = new Task();
        instOfTsk.OwnerId = UserInfo.getUserId();
        instOfTsk.WhatId = instOfEB.Id;
        instOfTsk.Subject = 'Test';
        instOfTsk.ActivityDate = system.Today();
        instOfTsk.Priority = 'Normal';
        instOfTsk.Minutes_on_tasks__c = 60;
        instOfTsk.Status = 'Completed';
        insert instOfTsk;
        /* 
        RecordType instRecTypeThir = [SELECT SobjectType,Id,name,DeveloperName FROM RecordType WHERE SobjectType='Case' And IsActive=true And DeveloperName = 'Eventbuilder' Limit 1];
        Case instOfCaseSec = new Case();
        instOfCaseSec.RecordTypeId = instRecTypeThir.Id;
        instOfCaseSec.Status = 'Open';
        instOfCaseSec.Description = 'Test';
        instOfCaseSec.Product_Type__c = 'Event Management';
        instOfCaseSec.Topic__c = 'Reports';
        instOfCaseSec.Subtopic__c = 'Other';
        instOfCaseSec.Subject = 'Test';
        instOfCaseSec.Min_s_Spent__c = 20;
        instOfCaseSec.Event_Survey_Builder__c = instOfEB.Id;
        //instOfCase.RecordTypeId = instRecTypeSec.id;
        insert instOfCaseSec;
       */
        Test.startTest(); 
        
        RecordType instRecType = [SELECT Name, IsActive, DeveloperName, SobjectType FROM RecordType WHERE SobjectType='Event' And IsActive = true And DeveloperName = 'SMM_BD_Presentations' ];
        
         //Added on 11/22/2019 
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
      
        List<Event> eventList = new List<Event>();
        
        Event instOfEvent = new Event();
        instOfEvent.WhatId = instOfEB.Id;
        instOfEvent.OwnerId = UserInfo.getUserId();
        instOfEvent.Subject = 'Test';
        instOfEvent.Source__c = 'Chat';
        instOfEvent.StartDateTime = system.today();
        instOfEvent.EndDateTime = system.today();
        instOfEvent.Minutes_on_tasks__c = 80;
        //instOfEvent.CurrencyIsoCode = 'USD';
        instOfEvent.RecordTypeId = instRecType.id;
        
        Event instOfEvent2 = new Event();
        instOfEvent2.WhatId = instOfPA.Id;
        instOfEvent2.OwnerId = UserInfo.getUserId();
        instOfEvent2.Subject = 'Test';
        instOfEvent2.Source__c = 'Chat';
        instOfEvent2.StartDateTime = system.today();
        instOfEvent2.EndDateTime = system.today();
        instOfEvent2.Minutes_on_tasks__c = 80;
        //instOfEvent.CurrencyIsoCode = 'USD';
        instOfEvent2.RecordTypeId = instRecType.id;
        
        eventList.add(instOfEvent);
        eventList.add(instOfEvent2);
        
        insert eventList;
        
        
        //Event instOfEventThir = [SELECT ID,Minutes_on_tasks__c FROM Event WHERE Id=: instOfEvent.Id];
        eventList[0].Minutes_on_tasks__c = 60;
        eventList[1].Minutes_on_tasks__c = 60;
        update eventList;
        
        
       
        
        
        Task instOfTskSec = [SELECT ID,Minutes_on_tasks__c FROM Task WHERE Id=: instOfTsk.Id];
        instOfTskSec.Minutes_on_tasks__c = 55;
        update instOfTskSec;
        /*
        Case instOfCaseFor = [SELECT ID,Min_s_Spent__c FROM Case WHERE Id=: instOfCaseSec.Id];
        instOfCaseFor.Min_s_Spent__c = 30;
        update instOfCaseFor;
         */
        Test.stopTest();  
        
        delete instOfTskSec;
        /*
        delete instOfCaseFor;
        */
        delete eventList;
        
        
    }
}