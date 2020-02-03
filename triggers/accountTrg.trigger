trigger accountTrg on Account (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    
      /*
    
    * Description: This trigger is created during BOSS implementation and used exclusively for Salesforce to EBS Integration related functionality. 
 *              It performs the following functions:
 *              - Auto generate Shipping and Billing Address related records upon Account creation
 *              - Auto Update Shipping and Billing Address related records upon EBS Account ID generation
 *              - Watch for any updates to EBS Integration related fields and trigger a Sync with EBS
 **********************************************************************************************************
    DESC: Merge EBS Trigger with the trigger and EBS logic needs to be execute (Code cleanup activity)
    Date :8 Feb 208
    
    */
    final boolean syncEnabled = BypassTriggerUtility.isEBSSyncEnabledForThisUserOrProfileId(UserInfo.getUserId());
    if(syncEnabled){
        
        if(Trigger.isInsert &&  Trigger.isBefore){
            
            Map<Id,Account> oldMap=new Map<Id,Account>();
            IntegrationAccount.handleAddressUpdates(Trigger.new,Trigger.oldMap);
        }else if(Trigger.isInsert &&  Trigger.isAfter){
        
            CS_AccountTriggerHandler.handleAccountAddressModify(Trigger.new,new Map<Id,Account>(), true);
            IntegrationAccount.handleNewAccounts(Trigger.newMap);
            
        }else if(Trigger.isUpdate && Trigger.isBefore){
        
            CS_AccountTriggerHandler.handleAccountAddressModify(Trigger.new,Trigger.oldMap, false);
            IntegrationAccount.handleAddressUpdates(Trigger.new,Trigger.oldMap);
        
        }else if(Trigger.isUpdate && Trigger.isAfter){
        
            IntegrationAccount.handleDependentUpdates(Trigger.new,Trigger.oldMap);
            IntegrationAccount.handleUpdatedAccounts(Trigger.new,Trigger.oldMap);
        
        }
        
    }else if(BypassTriggerUtility.isTriggerEnabledForThisUserOrProfileId(UserInfo.getUserId())){
        
            if(Trigger.isInsert && Trigger.isAfter){
            
                CS_AccountTriggerHandler.handleAccountAddressModify(Trigger.new,new Map<Id,Account>(), true);
            }
            else if(Trigger.isUpdate && Trigger.isBefore){
            
                CS_AccountTriggerHandler.handleAccountAddressModify(Trigger.new, Trigger.oldMap, false);
            }    
        
    }
    
     /* Skip execution if this user is setup to exempt triggers. This helps in one time data load as well */
    if(!BypassTriggerUtility.isTriggerEnabledForThisUserOrProfileId(UserInfo.getUserId())){
        return;
    }
    
    accountTrgHelper handler = new accountTrgHelper();
    
    if(Trigger.isInsert && Trigger.isBefore){
        handler.OnBeforeInsert(Trigger.new);          
    }
    else if(Trigger.isInsert && Trigger.isAfter){
        handler.OnAfterInsert(Trigger.newMap);        
    }
    else if(Trigger.isUpdate && Trigger.isBefore){
        handler.OnBeforeUpdate(Trigger.oldMap, Trigger.newMap);        
    }
    else if(Trigger.isUpdate && Trigger.isAfter){
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