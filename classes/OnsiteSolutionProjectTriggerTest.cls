/*
****
Author : HSR
Created Date : 29th June 2017
Description : Test class for "OnsiteSolutionProjectTrigger" and "OnsiteSolutionProjectTriggerHandlerClass".......
****
*/
@isTest
private class OnsiteSolutionProjectTriggerTest{
    static{
        Onsite_Solution_Project__c custSetting = new Onsite_Solution_Project__c();
        custSetting.Name = '1';
        custSetting.Subject__c = 'Test Subject';
        custSetting.Due_Days__c = 10;
        custSetting.Priority__c = 'Normal';
        custSetting.Status__c = 'Open';
        insert custSetting;
        
    }
    private static testMethod void testOnsiteInsert(){
        Id recordTypeId = Schema.SObjectType.Alliance_OA_Projects__c.getRecordTypeInfosByName().get('OnArrival').getRecordTypeId();
        Alliance_OA_Projects__c onsiteObj = new Alliance_OA_Projects__c();
        onsiteObj.RecordTypeId = recordTypeId;
        onsiteObj.Event_Start_Date__c = system.today();
        insert onsiteObj;
    }


}