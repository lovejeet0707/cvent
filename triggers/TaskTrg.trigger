/*
//////////////////////////////////////
//      @author Abhishek Pandey     //
/////////////////////////////////////
Version :   1.0
Date : 28th June 2014
*/
trigger TaskTrg on Task (after delete, after insert, after undelete,after update, before delete, before insert, before update) {


    /* Skip execution if this user is setup to exempt triggers. This helps in one time data load as well */
    if(!BypassTriggerUtility.isTriggerEnabledForThisUserOrProfileId(UserInfo.getUserId())){
            return;
    } 
    
    //Cloud MDM Deactivation Code
    StopCloudMDMExe.stopExecutionCloudMdm = true;
    //Cloud MDM Deactivation Code
    TaskTrgHelperCls handler = new TaskTrgHelperCls();
    
    if(Trigger.isInsert && Trigger.isBefore){
        handler.OnBeforeInsert(Trigger.new);          
    }
    else if(Trigger.isInsert && Trigger.isAfter){
        handler.OnAfterInsert(Trigger.newMap);        
    }
    else if(Trigger.isUpdate && Trigger.isBefore){
        handler.OnBeforeUpdate(Trigger.oldMap, Trigger.newMap);        
    }
    else if(Trigger.isUpdate && Trigger.isAfter && createGDPRPersonaBatch.bypassGDPR == false ){   // createGDPRPersonaBatch.bypassGDPR added by Udita to bypass the trigger for GDPR Processed records (5/23/2018)
        handler.OnAfterUpdate(Trigger.oldMap, Trigger.newMap);        
    }    
    else if(Trigger.isDelete && Trigger.isBefore){
        handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);        
    }
    else if(Trigger.isDelete && Trigger.isAfter){
        handler.OnAfterDelete(Trigger.old, Trigger.oldMap);        
    }    
    else if(Trigger.isUnDelete){
        handler.OnUndelete(Trigger.new);          
    }
    
}