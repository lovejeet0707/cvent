/*
***
Author : Aparna Thapliyal
Created Date : 14th July 2017
Description : Updates Oportunity, Account, Contact details.
Test Class : "ImplementationSurveyTriggerTest". Coverage : 100%
***
*/
trigger ImplementationSurveyTrigger on Implementation_Survey__c (before insert,after update,after insert) {
    if(trigger.isbefore && trigger.isInsert){
        ImplementationSurveyTriggerHandler.handlebeforeInsert(trigger.new);
    }
    else if(trigger.isAfter && (trigger.isUpdate || trigger.isInsert)){
        ImplementationSurveyTriggerHandler.handleAfterUpdate(trigger.new,trigger.oldMap);
    }
}