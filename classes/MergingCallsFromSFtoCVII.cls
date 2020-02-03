public class MergingCallsFromSFtoCVII{
    @future(callout=true)
    public static void sendIdToCVII(Map<Id,Id> deletedVsMasterRecordId, String ObjectReference){
        //Sending the Contact Id
        String Account_Contact_Merging_Calls_from_SF_to_CVII = Label.Account_Contact_Merging_Calls_from_SF_to_CVII;
        if(ObjectReference == 'Contact'){
            String body = '[';
            
            For(Id deletedId : deletedVsMasterRecordId.keySet()){
                body = body + '{"pastId":"'+deletedId+'","presentId":"'+deletedVsMasterRecordId.get(deletedId)+'"},';
            }
            body = body.removeEnd(',')+']'; 
            
            HTTPRequest feedRequest = new HTTPRequest();
            feedRequest.setEndpoint(Account_Contact_Merging_Calls_from_SF_to_CVII);
            feedRequest.setHeader('Authorization', 'API_KEY 59b3899b350479835902fdaece04581b');
            feedRequest.setHeader('Content-type', 'application/json');
            feedRequest.setBody(body);
            feedRequest.setMethod('POST');
            HTTP http = new HTTP();
            HTTPResponse feedResponse = http.send(feedRequest);
            System.debug(feedResponse.getBody());
            List<SF_to_CVII_Calls_Logs__c> logsRecList = new List<SF_to_CVII_Calls_Logs__c>();
            if(feedResponse.getStatusCode()!=200){
                SF_to_CVII_Calls_Logs__c logsRec = new SF_to_CVII_Calls_Logs__c();
                logsRec.ResponseBody__c = feedResponse.getBody();
                logsRecList.add(logsRec);
            }
            if(logsRecList.size()>0)
                insert logsRecList;
        }
    }
}