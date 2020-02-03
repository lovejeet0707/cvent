Trigger EBSBProjectBefore on EB_SB_Builder__c (before insert,before update,before delete){
    
    Boolean triggerControl = Boolean.valueOf(Label.EB_Project_Trigger_Control);
    
    // Below class is reponsible for updating pending hours on EB Projects.
    EBProjectUpdatePendingHrsForCompletion hrsToUpdate = new EBProjectUpdatePendingHrsForCompletion();
    if(triggerControl && hrsToUpdate.shouldRun()){
        hrsToUpdate.doAction();
    }
    
    //Update Project Risk Category Factor............
    Boolean runMethod = Boolean.valueOf(Label.Project_RiskCategory_Control);
    if(runMethod && ((Trigger.IsInsert || Trigger.IsUpdate) && Trigger.IsBefore)){
        UpdateProjectRiskCategoryClass.UpdateProjectRiskCategory(trigger.new);
    }
}