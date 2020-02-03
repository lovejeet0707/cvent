Trigger EBSBProjectAfter on EB_SB_Builder__c (after insert,after update,after delete,after undelete){
    
    Boolean triggerControl = Boolean.valueOf(Label.EB_Project_Trigger_Control);
    
   // Below class is reponsible for auto-assignment of EB Projects.
    EBProjectAutoAssignment_TrigAct EBAssignment = new EBProjectAutoAssignment_TrigAct();
    if(triggerControl && EBAssignment.shouldRun()){
        EBAssignment.doAction();
    }
    // Below class is reponsible for updating pending hours on EB Projects.
    EBProjectUpdatePendingHrsForCompletion hrsToUpdate = new EBProjectUpdatePendingHrsForCompletion();
    if(triggerControl && hrsToUpdate.shouldRun()){
        hrsToUpdate.doAction();
    }
    // Below class is for updating rollup fields on EB_Project_Assignment__c 
    EBProjectAssignmentRollup_TrigAct EBAssignmentRollup = new EBProjectAssignmentRollup_TrigAct();
    if(triggerControl && EBAssignmentRollup .shouldRun()){
        EBAssignmentRollup .doAction();
    }

}