trigger QuotaAllocationTrigger on Quota_Allocation__c (Before Insert, After Insert, Before Update, After Update) {

// ===============================
// AUTHOR     : Shanu Aggarwal    
// CREATED DATE     : 26/02/2016
// PURPOSE     :  To handle trigger events
// TEST CLASS : Quota_Allocation_Trigger_Handler_Test
// HANDLER CLASS: Quota_Allocation_Trigger_Handler
// SPECIAL NOTES:
// ===============================
    
    // Custom setting TriggerManagementSetting indicating whether Trigger should be fired .
    
    TriggerManagementSetting__c triggerSetting = TriggerManagementSetting__c.getValues('QuotaAllocationTrigger');
      
    if( (triggerSetting!=null && triggerSetting.Is_Active__c == true) ||  triggerSetting==null ){

        Quota_Allocation_Trigger_Handler handler = new Quota_Allocation_Trigger_Handler();
        
        //Before Insert
        if(Trigger.isInsert && Trigger.isBefore){
            handler.OnBeforeInsert(Trigger.New);          
        }
        
        //After Insert
        else if(Trigger.isInsert && Trigger.isAfter){
            handler.OnAfterInsert(Trigger.NewMap);          
        }
        
        //Before Update    
        else if(Trigger.isUpdate && Trigger.isBefore){
            handler.OnBeforeUpdate(Trigger.NewMap, Trigger.OldMap);          
        }
        
        //After Update
        else if(Trigger.isUpdate && Trigger.isAfter){
            handler.OnAfterUpdate(Trigger.NewMap, Trigger.OldMap);          
        }
    
    }
    

}