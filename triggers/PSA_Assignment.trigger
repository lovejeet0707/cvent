trigger PSA_Assignment on pse__Assignment__c (before insert, before update, after insert, after update) {
	if(PSA_Utils.IsDataLoadMode && !test.IsRunningTest()) return;    
    if(trigger.isAfter) {     
        
        if(trigger.isInsert) {
            PSA_AssignmentTriggerHandler.followProject(trigger.newMap.keyset());
        }  
    }
}