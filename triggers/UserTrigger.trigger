trigger UserTrigger on User ( Before Insert, After Insert, Before Update, After Update ) {

// ===============================
// AUTHOR     : Shanu Aggarwal    
// CREATED DATE   : 07/03/2016
// PURPOSE     :   To Handle User Events
// HANDLER CLASS:  Quota_User_History_Trigger_Handler
// TEST CLASS :   
// SPECIAL NOTES:
// ===============================
    
    TriggerManagementSetting__c triggerSetting = TriggerManagementSetting__c.getValues('UserTrigger');
      
        if( (triggerSetting!=null && triggerSetting.Is_Active__c == true) ||  triggerSetting==null ){
        
        UserTriggerHandler handler = new UserTriggerHandler ();
        
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
            /*DocusignUserMangementService_TrigAct runDocuSignSync = new DocusignUserMangementService_TrigAct();
            if(runDocuSignSync.shouldRun()){
                runDocuSignSync.doAction();
            } */           
        }    
    }
}