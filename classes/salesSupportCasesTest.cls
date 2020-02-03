/**
//////////////////////////////////////
//      @author Hemant Rana     //
/////////////////////////////////////
Version :   1.0
Date : 23rd OCT 2017
*/
@isTest
private class salesSupportCasesTest {
    static User testUser;
    static{
        Profile instProf =  [Select Id From Profile WHERE Name ='System Administrator'];
        testUser = new User(alias = 'u1', email='u1@testorg.com',emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',localesidkey='en_US', profileid = instProf.Id, 
                            timezonesidkey='America/Los_Angeles', username='salesSupportCasesTest@testorg.com');        
        insert testUser;
    }
    static testMethod void myUnitTest() {
        //Update Case on adding attachment
        Id recTypeCase= [SELECT Id FROM RecordType WHERE DeveloperName = 'Support_Sales_Cases' AND SobjectType = 'Case'].Id ;
        List<Case> caseList = new List<Case>();
        Case c = new Case();
        
        c.recordTypeId = recTypeCase;
        c.Product_Type__c = 'CSN - Planner';
        c.Request_Type__c = 'Customer Care';
        c.Status = 'Open';
        c.Minutesoncase__c = 30; 
        c.OwnerId = testUser.Id;
        caseList.add(c);
        
        c = new Case();
        c.recordTypeId = recTypeCase;
        c.Product_Type__c = 'Genie Connect';
                c.Request_Type__c = 'Customer Care';
        c.Status = 'Open';
        c.Minutesoncase__c = 30; 
        c.OwnerId = testUser.Id;    
        caseList.add(c);

        c = new Case();
        c.recordTypeId = recTypeCase;
        c.Product_Type__c = 'RegOnline';
                c.Request_Type__c = 'Customer Care';
        c.Status = 'Open';
        c.Minutesoncase__c = 30; 
        c.OwnerId = testUser.Id;    
        caseList.add(c);

        c = new Case();
        c.recordTypeId = recTypeCase;
        c.Product_Type__c = 'Meetings';
                c.Request_Type__c = 'Customer Care';
        c.Status = 'Open';
        c.Minutesoncase__c = 30; 
        c.OwnerId = testUser.Id;    
        caseList.add(c);

        c = new Case();
        c.recordTypeId = recTypeCase;
        c.Product_Type__c = 'Business Transient';
                c.Request_Type__c = 'Customer Care';
        c.Status = 'Open';
        c.Minutesoncase__c = 30; 
        c.OwnerId = testUser.Id;    
        caseList.add(c);

        c = new Case();
        c.recordTypeId = recTypeCase;
        c.Product_Type__c = 'Passkey';
                c.Request_Type__c = 'Customer Care';
        c.Status = 'Open';
        c.Minutesoncase__c = 30; 
        c.OwnerId = testUser.Id;    
        caseList.add(c);

        /*c = new Case();
        c.recordTypeId = recTypeCase;
        c.Product_Type__c = 'Travel';
        c.Status = 'Open';
        c.Minutesoncase__c = 30; 
        c.OwnerId = testUser.Id;    
        caseList.add(c);*/
        
        c = new Case();
        c.recordTypeId = recTypeCase;
        c.Product_Type__c = 'CSN - Supplier';
                c.Request_Type__c = 'Customer Care';
        c.Status = 'Open';
        c.Minutesoncase__c = 30; 
        c.OwnerId = testUser.Id;    
        caseList.add(c);
        
        c = new Case();
        c.recordTypeId = recTypeCase;
        c.Product_Type__c = 'eMarketing';
                c.Request_Type__c = 'Customer Care';
        c.Status = 'Open';
        c.Minutesoncase__c = 30; 
        c.OwnerId = testUser.Id;    
        caseList.add(c);
        
        c = new Case();
        c.recordTypeId = recTypeCase;
        c.Product_Type__c = 'Event Blue';
                c.Request_Type__c = 'Customer Care';
        c.Status = 'Open';
        c.Minutesoncase__c = 30; 
        c.OwnerId = testUser.Id;    
        caseList.add(c);
        
        c = new Case();
        c.recordTypeId = recTypeCase;
                c.Request_Type__c = 'Customer Care';
        c.Product_Type__c = 'Surveys';
        c.Status = 'Open';
        c.Minutesoncase__c = 30; 
        c.OwnerId = testUser.Id;    
        caseList.add(c);
        
        c = new Case();
        c.recordTypeId = recTypeCase;
        c.Product_Type__c = 'CrowdCompass';
                c.Request_Type__c = 'Customer Care';
        c.Status = 'Open';
        c.Minutesoncase__c = 30; 
        c.OwnerId = testUser.Id;    
        caseList.add(c);
        
        /*c = new Case();
        c.recordTypeId = recTypeCase;
        c.Product_Type__c = 'CrowdTorch Ticketing';
        c.Status = 'Open';
        c.Minutesoncase__c = 30; 
        c.OwnerId = testUser.Id;    
        caseList.add(c);*/
        
        c = new Case();
        c.recordTypeId = recTypeCase;
        c.Product_Type__c = 'EMI';
                c.Request_Type__c = 'Customer Care';
        c.Status = 'Open';
        c.Minutesoncase__c = 30; 
        c.OwnerId = testUser.Id;    
        caseList.add(c);
        
        c = new Case();
        c.recordTypeId = recTypeCase;
        c.Product_Type__c = 'EMI';
        c.Request_Type__c = 'Strategic Support';
        c.Status = 'Open';
        c.Minutesoncase__c = 30; 
        c.OwnerId = testUser.Id;    
        caseList.add(c);
        
        insert caseList;
    }
}