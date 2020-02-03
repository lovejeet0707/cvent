public class LeadTriggerHelper 
{
    public static void onBeforeUpdate(Map<Id,Lead>oldMapValues ,Map<Id,Lead> newMapValues)
    {
        if(CheckRecursive.runFifty())
        {
            updateBatchFlag(oldMapValues,newMapValues);
        }
    }

    public static void updateBatchFlag(Map<Id,Lead> oldMapValues,Map<Id,Lead> newMapValues)
    {
        Map<String,BatchUpdateContactFields__c> fieldNames = BatchUpdateContactFields__c.getAll();
        for(Lead newLead : newMapValues.values())
        {
            for(String fieldName : fieldNames.keySet())
            {
                if(newLead.get(fieldName) != oldMapValues.get(newLead.Id).get(fieldName) && newLead.BatchFlag__c == FALSE)
                {
                    newLead.BatchFlag__c = true;
                    break;
                }
            }
        }
    }
}