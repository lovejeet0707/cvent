trigger ReflagTrigger on Rebrand_Reflag__c (before insert, before update, before delete, after insert, after update, after delete, after undelete){
   if(Trigger.isAfter)
   {
       if(Trigger.isInsert)
       {
          ReflagTriggerHelper.onAfterInsert(Trigger.newMap);
       }
   } 
}