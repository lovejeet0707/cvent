// ===============================
// AUTHOR     : Shanu Aggarwal    
// CREATED DATE     : 26/02/2016
// PURPOSE     :  To handle trigger events
// TEST CLASS :  TestARATrigger
// HANDLER CLASS: ARATriggerHandler
// SPECIAL NOTES:
// ===============================


trigger ARATrigger on ARA__c (before insert, after Insert, after update) {

   if(Trigger.isBefore && Trigger.IsInsert){
       ARATriggerHandler objTriggerHandler =new ARATriggerHandler ();
       objTriggerHandler.onBeforeInsert(trigger.new);
   }
  
   
   if(Trigger.isAfter && Trigger.IsInsert){
       ARATriggerHandler objTriggerHandler =new ARATriggerHandler ();
       objTriggerHandler.onAfterInsert(trigger.new);
   }
   else if(Trigger.isAfter && Trigger.isupdate){
        ARATriggerHandler objTriggerHandler =new ARATriggerHandler ();
        objTriggerHandler.onAfterUpdate(trigger.newMap,trigger.oldMap);
   }

}// End of trigger