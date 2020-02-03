trigger PayGoSummaryTrigger on PayGo_Summary__c (before delete) {
    if(trigger.isBefore && trigger.isDelete){
        PayGoSummaryTriggerHelper.beforeDelete(trigger.old,trigger.oldMap);
    }
}