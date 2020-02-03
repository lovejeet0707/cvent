trigger TimeEntryAfter on WorkIt2__Time_Entry__c (after Insert,after update,after delete,after undelete) {

    Boolean triggerControl = Boolean.valueOf(Label.EB_Project_Time_Entry_Trigger_Control);
    
    PopulateTimerDataOnEBProject_TrigAct populateTimerData = new PopulateTimerDataOnEBProject_TrigAct();
    if(triggerControl && populateTimerData.shouldRun()){
        populateTimerData.doAction();
    }
    
    if(Trigger.isAfter &&  Trigger.isInsert)
    {
        TimeEntryTriggerHandler.onAfterInsert(Trigger.newMap);
    }
}