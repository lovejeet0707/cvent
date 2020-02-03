/*
Author : HSR
Created Date : 20th June 2017
Description : Trigger on Alliance_OA_Projects__c Object
Test Class : OnsiteSolutionProjectTriggerTest
*/
trigger OnsiteSolutionProjectTrigger on Alliance_OA_Projects__c (after insert) {
    if(trigger.isAfter && trigger.isInsert)
    {
        //if(!OnsiteSolutionProjectTriggerHandlerClass.checkRecursive)
        /*Calling the handler class */
        OnsiteSolutionProjectTriggerHandlerClass.onAfterInsert(trigger.new);
    }
}