trigger DG_DFR_Opportunity_Trigger on Opportunity (after insert, after update) {

    /* Skip execution if this user is setup to exempt triggers. This helps in one time data load as well */
    if(!BypassTriggerUtility.isTriggerEnabledForThisUserOrProfileId(UserInfo.getUserId())){
            return;
    } 
    
    Boolean Disable_DFR = false;
    
    try{
        if(System.Label.Disable_DFR == '1'){
            Disable_DFR = true;
        }
    }catch(exception e){}
    
    if(!Disable_DFR){
        if(trigger.isInsert && trigger.isAfter){
            DG_DFR_Class.OpportunityStageChange(trigger.new, Null); 
        }
    
        if(trigger.isUpdate && trigger.isAfter){
            DG_DFR_Class.OpportunityStageChange(trigger.new, trigger.oldMap);  
        }
    }
}