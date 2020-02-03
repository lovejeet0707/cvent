global class CampaignROIAttributionDeleteBatch implements Database.Batchable<sObject>{
    
    
    List<Opportunity_Campaign_Attribution__c> oppCampObj_List;

    Id batchId;
    
    global CampaignROIAttributionDeleteBatch( Id batchId )
    {
     this.batchId = batchId;
    }
    
    global Database.querylocator start(Database.BatchableContext BC){
        String query='SELECT Id FROM Opportunity_Campaign_Attribution__c where BatchId__c = : batchId';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity_Campaign_Attribution__c> scope){
        delete scope;
    }
    
    global void finish(Database.BatchableContext BC){
    }
}