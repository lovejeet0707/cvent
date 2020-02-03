/*
Author : HSR
Created Date : 20th June 2017
Description : Handler class for OnsiteSolutionProjectTrigger trigger.......
Test Class : OnsiteSolutionProjectTriggerTest
*/
public class OnsiteSolutionProjectTriggerHandlerClass{
    //public static Boolean checkRecursive = false;
    public static void onAfterInsert(List<Alliance_OA_Projects__c> allianceProjectList){
        //checkRecursive = true;
        List<Task> createTaskList = new List<Task>();
        Task taskObj;
        Id recordTypeId = Schema.SObjectType.Alliance_OA_Projects__c.getRecordTypeInfosByName().get('OnArrival').getRecordTypeId();
        //System.debug('recordTypeId************'+recordTypeId);
        For(Alliance_OA_Projects__c allianceProjectRec : allianceProjectList)
        {
            //System.debug('allianceProjectRec.RecordTypeId************'+allianceProjectRec.RecordTypeId);
            //System.debug('allianceProjectRec.Event_Start_Date__c************'+allianceProjectRec.Event_Start_Date__c);
            if(allianceProjectRec.Event_Start_Date__c!=null && allianceProjectRec.RecordTypeId == recordTypeId){
                //System.debug('#Checkpoint inside this');
                For(Onsite_Solution_Project__c onsiteCustomSetting : Onsite_Solution_Project__c.getAll().values())
                {
                    //System.debug('#Checkpoint inside this 1111');
                    taskObj = new Task();
                    taskObj.Subject = onsiteCustomSetting.Subject__c;
                    taskObj.ActivityDate = allianceProjectRec.Event_Start_Date__c.addDays(Integer.Valueof(onsiteCustomSetting.Due_Days__c));
                    taskObj.Priority = onsiteCustomSetting.Priority__c;
                    taskObj.Status = onsiteCustomSetting.Status__c;
                    taskObj.WhatId = allianceProjectRec.Id;
                    createTaskList.add(taskObj);
                }
            }
        }
        System.debug('createTaskList*****'+createTaskList);
        if(createTaskList.size()>0)
            insert createTaskList;
    }
}