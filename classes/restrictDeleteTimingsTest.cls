/*
//////////////////////////////////////
//      @author Vaibhav Jain     //
/////////////////////////////////////
Version :   1.0
Date : 18th nov 2015
Description : Tests restrictDeleteTimings & restrictDeleteTimeEntry
*/
@isTest
private class restrictDeleteTimingsTest {
    static User testUser;
    static User testUserSec;
    static Case instOfCase; 
    static Case instOfCaseSec;
    static{
        Profile instProf =  [Select Id From Profile WHERE Name ='System Administrator'];
        testUser = new User(alias = 'u1', email='u1@testorg.com',emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',localesidkey='en_US', profileid = instProf.Id, 
                            timezonesidkey='America/Los_Angeles', username='u11122311@testorg.com');        
        insert testUser;
        
        Profile insProfSec = [SELECT Id FROM Profile WHERE Name = 'Client Services Leadership'];
        testUserSec = new User(alias = 'u1', email='u13434@testorg.com',emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',localesidkey='en_US', profileid = insProfSec.Id,
                            timezonesidkey='America/Los_Angeles', username='u113433354111@testorg.com');
        insert testUserSec;
        
        Id recTypeCase = [SELECT Id from RecordType where SObjectType='Case' and DeveloperName='New_Event'].Id ;
        
        instOfCaseSec = new Case();
        instOfCaseSec.recordTypeId = recTypeCase;
        instOfCaseSec.Product_Type__c = 'Event Blue';
        instOfCaseSec.Status = 'Open';
        instOfCaseSec.Minutesoncase__c = 30; 
        instOfCaseSec.OwnerId = testUser.Id;
        insert instOfCaseSec;
        
        instOfCase = new Case();
        instOfCase.recordTypeId = recTypeCase;
        instOfCase.Product_Type__c = 'Event Blue';
        instOfCase.Status = 'Open';
        instOfCase.Minutesoncase__c = 30; 
        instOfCase.OwnerId = testUser.Id;
        instOfCase.ParentId = instOfCaseSec.Id;
        insert instOfCase;
        
        
    }
    static testMethod void myUnitTest() {
        
        system.runAs(testUser){
            WorkIt2__Timing__c instofTiming = new WorkIt2__Timing__c();
            instofTiming.WorkIt2__Case__c = instOfCase.Id;
            insert instofTiming;
            
            WorkIt2__Time_Entry__c instofTimeEntry = new WorkIt2__Time_Entry__c();
            instofTimeEntry.WorkIt2__Timing__c = instofTiming.Id;
            insert instofTimeEntry;
            
            instofTimeEntry.WorkIt2__Business_Calculated_Seconds__c = 150;
            update instofTimeEntry;
            
            delete instofTimeEntry;
            delete instofTiming;
        }
        
        system.runAs(testUserSec){
            WorkIt2__Timing__c instofTiming = new WorkIt2__Timing__c();
            instofTiming.WorkIt2__Case__c = instOfCase.Id;
            insert instofTiming;

            WorkIt2__Time_Entry__c instofTimeEntry = new WorkIt2__Time_Entry__c();
            instofTimeEntry.WorkIt2__Timing__c = instofTiming.Id;
            insert instofTimeEntry;

            try{
                delete instofTimeEntry;
            }
            catch(Exception e){
                system.debug('Exception error: '+e.getMessage());
            }
            try{
                delete instofTiming;
            }
            catch(Exception e){
                system.debug('Exception error: '+e.getMessage());
            }
        }
    }    
}