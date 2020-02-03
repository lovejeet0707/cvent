trigger PSA_Project on pse__Proj__c (before insert, before update, after insert, after update) {
	if(PSA_Utils.IsDataLoadMode && !test.IsRunningTest()) return;
    if(trigger.isBefore) {
        PSA_ProjectTriggerHandler.populatePMsMgr(trigger.new);
    }
    
    if(trigger.isAfter) {
        if(trigger.isUpdate) {
            PSA_ProjectTriggerHandler.pendingCompletionPost(trigger.newMap, trigger.oldMap);
        }
    }
    
}