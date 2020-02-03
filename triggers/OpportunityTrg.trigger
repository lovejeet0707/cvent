/*
//////////////////////////////////////
//      @author Abhishek Pandey     //
/////////////////////////////////////
Version :   1.0
Date : 20th June 2014

version : 1.1
Modified date : 28 June 2018
Modified by :Kumud
*/
trigger OpportunityTrg on Opportunity (after delete, after insert, after undelete,after update, before delete, before insert, before update) {
    
     /* Skip execution if this user is setup to exempt triggers. This helps in one time data load as well */
    if(!BypassTriggerUtility.isTriggerEnabledForThisUserOrProfileId(UserInfo.getUserId())){
            return;
    } 
    OpportunityTriggerDispatcher instOptyTrgDis=new OpportunityTriggerDispatcher();
    if(Trigger.isInsert && Trigger.isBefore){
        
            instOptyTrgDis.OnBeforeInsert(Trigger.new);
        
    }
    else if(Trigger.isInsert && Trigger.isAfter){
       
            instOptyTrgDis.OnAfterInsert(Trigger.new,Trigger.newMap); 
    }
    else if(Trigger.isUpdate && Trigger.isBefore){
        
            instOptyTrgDis.OnBeforeUpdate(Trigger.new,Trigger.newMap,Trigger.oldMap); 
    }
    else if(Trigger.isUpdate && Trigger.isAfter){
        
           instOptyTrgDis.OnAfterUpdate(Trigger.new,Trigger.newMap,Trigger.oldMap); 
    }
    else if(Trigger.isDelete && Trigger.isBefore){
        
            instOptyTrgDis.OnBeforeDelete(Trigger.old, Trigger.oldMap); 
                     
    }
    else if(Trigger.isDelete && Trigger.isAfter){
            
            instOptyTrgDis.OnAfterDelete(Trigger.old, Trigger.oldMap);    
             
    }    
    else if(Trigger.isUnDelete){
        
        instOptyTrgDis.OnUndelete(Trigger.new); 
          
    }// end
    
} // end here