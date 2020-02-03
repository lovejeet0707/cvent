/**********************************************************************************************************
      UPDATED BY: Rong Bin on Jul 30, 2014
      CHANGE: To exclude AWO users from user contact relation logic 
      TEST CLASS/METHOD: CustomAccountContactRoleHelper_Test.cls
**********************************************************************************************************/


trigger UserUpdateTrigger on User (after insert, after update)  {
    if(Trigger.isInsert && Trigger.isAfter){
       Set<Id> uSet =  new Set<Id>(); 
       for (User u:Trigger.New)
       {
           if (!u.Username.contains('@awo.com'))
           {
                uSet.add(u.Id);
           }
       }
       
       if (uSet.Size() > 0)
       {
           ManageUserContactsRelation.addUserContactsRelation(uSet); 
       }
       //Dispatcher.handleEvent(Trigger.newMap,null,Trigger.isInsert,Trigger.isUpdate,Trigger.isDelete,Trigger.isUndelete,Trigger.isBefore,Trigger.isAfter,Trigger.isExecuting);
    }    
}