trigger doceboUserTrg on docebo_v3__DoceboUser__c (before insert, before update) {
   
   doceboUserTrgHandler handler = new doceboUserTrgHandler();
    
    if(Trigger.isInsert && Trigger.isBefore){
        handler.OnBeforeInsert(Trigger.new);          
    }
     if(Trigger.isUpdate && Trigger.isBefore){
        handler.OnBeforeUpdate(Trigger.new,Trigger.oldMap);          
    }
}