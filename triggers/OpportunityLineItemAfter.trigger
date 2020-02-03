trigger OpportunityLineItemAfter on OpportunityLineItem (after insert, after update,after delete, after undelete){
    
    Boolean triggerControl = Boolean.valueOf(Label.EB_Project_Trigger_Control);
    
    CreatePSPOnOppLineItemInsertion_TrigAct createPSPRec = new CreatePSPOnOppLineItemInsertion_TrigAct();
    if(triggerControl && createPSPRec.shouldRun()){
        createPSPRec.doAction();
    }  
}