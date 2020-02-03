@RestResource(urlMapping='/OpenOpportunitiesCheckboxUpdateRestAPI/*')
global class OpenOpportunitiesCheckboxUpdateRestAPI 
{
    @HttpPost
    global static void doPost() 
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        String jsonBody;
        if (req.requestBody != NULL) 
        {
            jsonBody = req.requestBody.toString();
        }
        Map<String, Object> deserilizeBody = (Map<String, Object>)JSON.deserializeUntyped(jsonBody);
        System.debug('deserilizeBody>>>'+deserilizeBody);
        List<Acquisition__c> acquisitionsToBeUpdated = new List<Acquisition__c>();
        for(Acquisition__c acquisitionInstance : [SELECT Account_Type_for_Aquired_Org__c,Migrated_Record_ID__c FROM Acquisition__c WHERE Migrated_Record_ID__c IN :deserilizeBody.keySet()])
        {
            acquisitionInstance.Open_Opportunities__c = Boolean.valueOf(deserilizeBody.get(acquisitionInstance.Migrated_Record_ID__c));
            acquisitionsToBeUpdated.add(acquisitionInstance);
        }
        System.debug('acquisitionsToBeUpdated>>>'+acquisitionsToBeUpdated);
        if(!acquisitionsToBeUpdated.isEmpty())
        {
            update acquisitionsToBeUpdated;
        }
    }
}