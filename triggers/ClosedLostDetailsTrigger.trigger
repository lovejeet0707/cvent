trigger ClosedLostDetailsTrigger on Account_Shut_Down_Details__c (after update) 
{
    if(Trigger.isAfter)
    {
        if(Trigger.isUpdate)
        {
            if(Boolean.valueOf(Label.ClosedLostDetailTrigger))
            {
                ClosedLostDetailsTriggerHelper.onAfterUpdate(Trigger.newMap,Trigger.oldMap);
            }
        }
    }
}