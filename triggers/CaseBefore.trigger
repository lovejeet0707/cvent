trigger CaseBefore on Case (before insert,before update,before delete) {
    
    Boolean triggerControl = Boolean.valueOf(Label.EB_Project_Time_Entry_Trigger_Control);
    
    PopulateTimerDataOnEBProject_TrigAct populateTimerFlag = new PopulateTimerDataOnEBProject_TrigAct();
    if(triggerControl && populateTimerFlag.shouldRun()){
        populateTimerFlag.doAction();
    }
}