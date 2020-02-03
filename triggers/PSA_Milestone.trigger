trigger PSA_Milestone on pse__Milestone__c (before insert, before update, after insert, after update) {
	if(PSA_Utils.IsDataLoadMode && !test.IsRunningTest()) return;
    if(trigger.isAfter) {
        
        PSA_MilestoneTriggerHandler.sumMilestoneWeight(trigger.new);
    }
    
}