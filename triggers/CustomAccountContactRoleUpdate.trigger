trigger CustomAccountContactRoleUpdate on CustomAccountContactRole__c (before insert, after insert, before update, after update, before delete, after delete)
{
    //Added by JBarrameda - 07/20/2015
    BypassTriggerUtility u = new BypassTriggerUtility();  
    if (u.isTriggerBypassed()) {
         return;
    }   
    //End

    System.Debug(Logginglevel.DEBUG,'Trigger.CustomAccountContactRoleUpdate - START');
    if(Trigger.isInsert)
    {
        if(Trigger.isBefore)
        {
            CustomAccountContactRoleHelper.handleNewCACR(Trigger.New);
        }
        if(Trigger.isAfter)
        {
            //Dispatcher.handleEvent(Trigger.newMap,null,Trigger.isInsert,Trigger.isUpdate,Trigger.isDelete,Trigger.isUndelete,Trigger.isBefore,Trigger.isAfter,Trigger.isExecuting);
        }
    }
    if(Trigger.isUpdate)
    {

        if(Trigger.isBefore)
        {
            CustomAccountContactRoleHelper.handleUpdatedCustomAccountContactRole(Trigger.newMap, Trigger.oldMap);
        }
        if(Trigger.isAfter)
        {
            //Dispatcher.handleEvent(Trigger.newMap,null,Trigger.isInsert,Trigger.isUpdate,Trigger.isDelete,Trigger.isUndelete,Trigger.isBefore,Trigger.isAfter,Trigger.isExecuting);
        }
    }
    if (Trigger.isDelete)
    {
        if(Trigger.isBefore)
        {
            for (CustomAccountContactRole__c cacr:Trigger.old)
            {
                if (cacr.Role__c == 'System')
                {
                    cacr.addError ('"System" is the default account contact role.  You cannot delete the default role!');
                }
            }
            CustomAccountContactRoleHelper.handleDeletedCustomAccountContactRole(Trigger.oldMap);
            //Dispatcher.handleEvent(null,Trigger.oldMap,Trigger.isInsert,Trigger.isUpdate,Trigger.isDelete,Trigger.isUndelete,Trigger.isBefore,Trigger.isAfter,Trigger.isExecuting);
        }
    }
    System.Debug(Logginglevel.DEBUG,'Trigger.CustomAccountContactRoleUpdate - END');
}