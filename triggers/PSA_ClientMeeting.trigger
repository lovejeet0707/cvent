trigger PSA_ClientMeeting on Client_Meeting__c (before insert, before update, after insert, after update, before delete, after delete) {
    if(PSA_Utils.IsDataLoadMode && !test.IsRunningTest()) return;
    if(trigger.isBefore && !trigger.isDelete) {
        
        PSA_clientMeetingTriggerHandler.deactivateMeeting(trigger.new);
    }

}