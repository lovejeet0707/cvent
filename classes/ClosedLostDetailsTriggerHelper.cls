public class ClosedLostDetailsTriggerHelper 
{
    public static void onAfterUpdate(Map<Id,Account_Shut_Down_Details__c> newMap, Map<Id,Account_Shut_Down_Details__c> oldMap)
    {
        Map<Id,Account_Shut_Down_Details__c> selectedClosedLostRecords = new Map<Id,Account_Shut_Down_Details__c>();
        Set<Id> oppIds =new Set<Id>();
        
        for(Account_Shut_Down_Details__c closedLostRec : newMap.values())
        {
            if(closedLostRec.Opportunity_Stage__c!= oldMap.get(closedLostRec.Id).Opportunity_Stage__c && closedLostRec.Opportunity_Stage__c == 'Closed Lost')
            {
                oppIds.add(closedLostRec.Opportunity__c);
            }
        }
        List<Opportunity> oppToBeUpdated = new List<Opportunity>();
        if(!oppIds.isEmpty())
        {
            for(Opportunity opp: [select id,stagename from Opportunity where Id IN :oppIds])
            {
                opp.stagename = 'Closed Lost';
                oppToBeUpdated.add(opp);
            }
        }
        
        if(!oppToBeUpdated.isEmpty())
        {
            update oppToBeUpdated;
        }
    }
}