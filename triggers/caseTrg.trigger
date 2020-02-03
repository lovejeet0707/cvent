/*
//////////////////////////////////////
//      @author Vaibhav Jain     //
/////////////////////////////////////
Version :   1.0
Date : 13th July 2015
*/
trigger caseTrg on Case (after delete, after insert, after undelete,after update, before delete, before insert, before update) {
//trigger caseTrg on Case (after update) {

    /* Skip execution if this user is setup to exempt triggers. This helps in one time data load as well */
    if(!BypassTriggerUtility.isTriggerEnabledForThisUserOrProfileId(UserInfo.getUserId())){
            return;
    } 
    
    caseTrgHelperCls handler = new caseTrgHelperCls();
       
    if(Trigger.isInsert && Trigger.isBefore){
        handler.OnBeforeInsert(Trigger.new);          
        //caseTrgHelperCls.setOwnerforContractCases(Trigger.new);// furture method call on case insert       
    }
    else if(Trigger.isInsert && Trigger.isAfter){
        handler.OnAfterInsert(Trigger.newMap);  
    }
    else if(Trigger.isUpdate && Trigger.isBefore){
        handler.OnBeforeUpdate(Trigger.oldMap, Trigger.newMap);        
    }
    if(Trigger.isUpdate && Trigger.isAfter){
        System.debug('Passing to the Class');
        handler.OnAfterUpdate(Trigger.oldMap, Trigger.newMap);        
        System.debug('Passing to the Class Check');
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