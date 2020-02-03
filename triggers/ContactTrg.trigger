trigger ContactTrg on Contact (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    
    /* Skip execution if this user is not setup for EBS Data Sync */
    /*Name: EBSContactTrigger Merge with this trigger.
* Description: This trigger is created during BOSS implementation and used exclusively for Salesforce to EBS Integration related functionality. 
*              It performs the following functions:
*              - Trigger a Sync with EBS If the parent Account EBS Id is available (new contacts)
*              - Watch for any updates to EBS Integration related fields and trigger a Sync with EBS
*              - ROL related Portal User creation*/
    
    boolean syncEnabled = BypassTriggerUtility.isEBSSyncEnabledForThisUserOrProfileId(UserInfo.getUserId());
    System.debug('syncEnabled*******'+syncEnabled);
    if(syncEnabled || test.isRunningTest()) {//UserInfo.getUserId()=='005o0000002QzQsAAK'
        
        Set<Id> contactIdSet = new Set<Id>();
        if(Trigger.isInsert && Trigger.isBefore){
            
            IntegrationContact.handleAddressUpdates(trigger.new,new Map<Id,Contact>());  // nothing is happen this method
            
        }else if(Trigger.isInsert && Trigger.isAfter){
            
            IntegrationContact.handleNewContacts(Trigger.newMap);
            if(!Test.isRunningTest()){
                //Deactivated until ROL Go Live
                CustomerPortal.addContactUsers(contactIdSet, Trigger.new);
            }
            
        }
        else if(Trigger.isUpdate && Trigger.isBefore)
        {
            
            
            IntegrationContact.handleAddressUpdates(Trigger.new,Trigger.oldMap);
            CustomAccountContactRoleHelper.handleUpdatedContact(Trigger.newMap, Trigger.oldMap);
            
        }else if(Trigger.isUpdate && Trigger.isAfter){
            
            // System.debug('------------------------------------------- IntegrationContact.handleUpdatedContacts '+newList);
            List<Id> newContactIdList=new List<Id>(Trigger.newMap.keySet());
            if(!Test.isRunningTest()){
                IntegrationContact.handleUpdatedContacts(Trigger.new,trigger.oldmap);
                IntegrationAddressContact.handleUpdatedContact(newContactIdList);
            }
        }
        
    }// end of ESB Trigger Code
    
    /* Skip execution if this user is setup to exempt triggers. This helps in one time data load as well */
    if(!BypassTriggerUtility.isTriggerEnabledForThisUserOrProfileId(UserInfo.getUserId())){
        return;
    } 
    
    /*
Add below code from DG_DFR_Contact_Trigger to merge as code clean activity
Author :kumud
*/
    Boolean Disable_DFR = false;
    if(System.Label.Disable_DFR == '1'){
        Disable_DFR = true;
    }
    ContactTrgHelperCls handler = new ContactTrgHelperCls();
    
    if(Trigger.isInsert && Trigger.isBefore){
        handler.OnBeforeInsert(Trigger.new);          
    }
    else if(Trigger.isInsert && Trigger.isAfter){
        handler.OnAfterInsert(Trigger.newMap); 
        // Add from DG_DFR_Contact_Trigger     
        if(!Disable_DFR){
            DG_DFR_Class.DFR_ContactStatusChange(trigger.new, Null);  }     
    }
    else if(Trigger.isUpdate && Trigger.isBefore){
        handler.OnBeforeUpdate(Trigger.oldMap, Trigger.newMap);  
        // Add from DG_DFR_Contact_Trigger      
        if(!Disable_DFR && (DG_DFR_Class.ContactAfterUpdate_FirstRun || test.isRunningTest())){           
            DG_DFR_Class.DFR_ContactStatusChange(trigger.new, trigger.oldMap);  
            DG_DFR_Class.ContactAfterUpdate_FirstRun=false;
        }                 
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