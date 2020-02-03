trigger PSA_ResourceRequest on pse__Resource_Request__c (before insert, before update, after insert, after update) {
    if(PSA_Utils.IsDataLoadMode && !test.IsRunningTest()) return;
    if(trigger.isBefore) {
        
        PSA_ResourceRequestTriggerHandler.setResourceManager(trigger.new);
        
    }

}