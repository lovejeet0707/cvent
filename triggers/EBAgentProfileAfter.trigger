trigger EBAgentProfileAfter on EB_Agent_Profile__c (after insert,after update,after delete,after undelete) {
    
    Boolean EBAgentProfileTriggerControl = Boolean.valueOf(Label.EBAgentProfile_Trigger_Control);
    
    EBAgentProfileManualShare_TrigAct profileSharing = new EBAgentProfileManualShare_TrigAct();
    if(EBAgentProfileTriggerControl && profileSharing.shouldRun()){
        profileSharing.doAction();
    }
}