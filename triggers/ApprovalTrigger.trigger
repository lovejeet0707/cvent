trigger ApprovalTrigger on sbaa__Approval__c (after insert, after update) {
    
    if(SettingUtil.isTriggerOn('ApprovalTrigger')) {
             if(Trigger.isAfter){
            if(Trigger.isInsert){
                ApprovalTriggerHandler.approvalHistoryTracking(Trigger.new, true);
            }else if(Trigger.isUpdate){
                ApprovalTriggerHandler.approvalHistoryTracking(Trigger.new, false);
            }
        }
    }
   
}