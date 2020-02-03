trigger PSA_DemoScopingRequest on Demo_Scoping_Request__c (before update) {
    
    if(trigger.isBefore) {
        if(trigger.isUpdate) {
                PSA_demoScopingRequestTriggerHandler.setReviewerStatusReady(trigger.newMap, trigger.oldMap);
    			PSA_demoScopingRequestTriggerHandler.scopingReviewsCompleted(trigger.new);
        }
    }
}