trigger PSA_TimecardSplit on pse__Timecard__c (before insert, before update, after insert, after update) {
    if(PSA_Utils.IsDataLoadMode && !test.IsRunningTest()) return;
    if(trigger.isBefore && trigger.isUpdate) {
        PSA_TimecardSplitTriggerHandler.populateTimePeriod(trigger.new);
    }

}