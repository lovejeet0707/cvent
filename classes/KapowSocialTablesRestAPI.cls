@RestResource(urlMapping='/AccountId/*')
global class KapowSocialTablesRestAPI 
{
@HttpGet
global static Result doGet() 
{
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;
    String migratedRecordId = RestContext.request.params.get('id');
    List<Acquisition__c> acquisition = [SELECT Account__c FROM Acquisition__c WHERE Migrated_Record_ID__c = :migratedRecordId LIMIT 1];
    System.debug('Inside of account id api');
    Result res1 = new Result();
    if(!acquisition.isEmpty())
    {
        res1 .accountId = acquisition[0].Account__c;
    }
    return res1 ;
}

global class Result
{
    public Id accountId{get;set;}
}
}