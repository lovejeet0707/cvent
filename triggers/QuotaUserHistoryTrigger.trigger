trigger QuotaUserHistoryTrigger on Quota_User_History__c ( Before Insert, After Insert, Before Update, After Update ) {
// ===============================
// AUTHOR     : Shanu Aggarwal    
// CREATED DATE     : 02/03/2016
// PURPOSE     :   To handle Quota User History record events
// HANDLER CLASS:  Quota_User_History_Trigger_Handler
// TEST CLASS :   
// SPECIAL NOTES:
// ===============================
    
    TriggerManagementSetting__c triggerSetting = TriggerManagementSetting__c.getValues('QuotaUserHistoryTrigger');
      
    if( (triggerSetting!=null && triggerSetting.Is_Active__c == true) ||  triggerSetting==null ){
    
        Quota_User_History_Trigger_Handler handler = new Quota_User_History_Trigger_Handler();
        
        if(Trigger.isInsert && Trigger.isBefore){
            handler.OnBeforeInsert(Trigger.new);          
        }
        
        else if(Trigger.isInsert && Trigger.isAfter){
            handler.OnAfterInsert(Trigger.newMap);          
        }
           
        else if(Trigger.isUpdate && Trigger.isBefore){
            handler.OnBeforeUpdate(Trigger.newMap, Trigger.OldMap);          
        }
        
        else if(Trigger.isUpdate && Trigger.isAfter){
            handler.OnAfterUpdate(Trigger.newMap, Trigger.OldMap);          
        }
    
    }
    
    
}