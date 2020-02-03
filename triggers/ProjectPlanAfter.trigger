trigger ProjectPlanAfter on Project_Plan_SOW_EB__c (after insert,after update,after delete,after undelete) {
    // Updates Expected Launch Date on associated EB SB Project.
    EBProjUpdateExpLaunchDateFrmPP_TrigAct updateExpectedLaunchDate = new EBProjUpdateExpLaunchDateFrmPP_TrigAct();
    if(updateExpectedLaunchDate.shouldRun()){
        updateExpectedLaunchDate.doAction();
    }
}