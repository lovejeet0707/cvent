trigger EBSBOpportunityAfter on Opportunity (before update,after insert, after update,after delete, after undelete) {
    
    Boolean triggerControl = Boolean.valueOf(Label.EB_Project_Trigger_Control);
    
     /* Skip execution if this user is setup to exempt triggers. This helps in one time data load as well */
    if(!BypassTriggerUtility.isTriggerEnabledForThisUserOrProfileId(UserInfo.getUserId())){
        return;
    } 
    
    // Execute EBSB Automation Process - Description of functionality is mentioned in the called class.
    CreatePSPOnOppLineItemInsertion_TrigAct createPSPRec = new CreatePSPOnOppLineItemInsertion_TrigAct();
    if(triggerControl && createPSPRec.shouldRun()){
        createPSPRec.doAction();
    }  
    // Update Legal Review Stage on Quote Object - Description of functionality is mentioned in the called class.
    UpdateLegalReviewStageOnQuote_TrigAct updateQuote = new UpdateLegalReviewStageOnQuote_TrigAct();
    if(triggerControl && updateQuote.shouldRun()){
        updateQuote.doAction();
    } 
}