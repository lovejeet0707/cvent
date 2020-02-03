trigger PSA_TimecardHeader on pse__Timecard_Header__c (before insert, before update, after insert, after update) {
    if(PSA_Utils.IsDataLoadMode && !test.IsRunningTest()) return;
    if(trigger.isBefore) {
        PSA_TimecardHeaderTriggerHandler.nonBillableMilestone(trigger.new); 
        PSA_TimecardHeaderTriggerHandler.populateApprover(trigger.new);
    }
}