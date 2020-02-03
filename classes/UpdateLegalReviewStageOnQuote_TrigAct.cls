/******************************************************************************************
* Author : Sandeep Kumar
* Date : 22 Nov, 2017
* Description : UpdateLegalReviewStageOnQuote_TrigAct class fullfills below functionalities,
* 1) Update Legal Review Stage on associated Quotes when stage is closed won/ Closed Lost.
* Handler called by - EBSBOpportunityAfter Trigger
* Test Class - UpdateLegalReviewStage_TrigAct_Test
******************************************************************************************/
public class UpdateLegalReviewStageOnQuote_TrigAct extends TriggerAction{
    public Set<Id> oppIdsToProcessSet; 
    public List<SBQQ__Quote__c> cpqQuoteToUpdateList; 
    
    public UpdateLegalReviewStageOnQuote_TrigAct(){
        // Call super to set batch variables & context
        super();
        oppIdsToProcessSet = new Set<Id>();
        cpqQuoteToUpdateList = new List<SBQQ__Quote__c>();
    }
    
    public override Boolean shouldRun(){
        if(this.isUpdate() && this.isAfter() && !this.hasRun()){ 
            // Check Closed Won/ Lost Opportunities and update Legal Review stage on all the associated quotes.
            for (Opportunity newOpp: (List<Opportunity>)this.triggerMap.values()){ 
                Opportunity oldOpp = (Opportunity)this.triggerOldMap.get(newOpp.Id);
                // Add the opportunties which are meeting the criteria and process them in doAction method.
                if(oldOpp.StageName != 'Closed Won' && oldOpp.StageName != 'Closed Lost' && (newOpp.StageName == 'Closed Won' || newOpp.StageName == 'Closed Lost')){
                    oppIdsToProcessSet.add(newOpp.Id);
                }
            } 
        }
        // Excecute doAction if set is not empty.
        return !oppIdsToProcessSet.isEmpty();
    }
    
    public override void doAction(){
        // Fetch all quotes associated with opportunities contained in oppIdsToProcessSet.
        for(SBQQ__Quote__c quote : [Select Id,SBQQ__Opportunity2__c,SBQQ__Opportunity2__r.StageName,Legal_Review_Stage__c From SBQQ__Quote__c Where SBQQ__Opportunity2__c IN :oppIdsToProcessSet]){
            // Quote with "Ready for Signature" stage shall be processed.
            if(quote.Legal_Review_Stage__c == 'Ready for Signature'){
                if(quote.SBQQ__Opportunity2__r.StageName == 'Closed Won'){
                    // Update Legal Review Stage To Closed/Executed
                    quote.Legal_Review_Stage__c = 'Closed/Executed';
                    cpqQuoteToUpdateList.add(quote);
                }else if(quote.SBQQ__Opportunity2__r.StageName == 'Closed Lost'){
                    // Update Legal Review Stage To Closed/Not Executed
                    quote.Legal_Review_Stage__c = 'Closed/Not Executed';
                    cpqQuoteToUpdateList.add(quote);
                }                 
            }
        }
        
        // Update quotes and mark the trigger to run only once.
        if(!cpqQuoteToUpdateList.isEmpty()){
            update cpqQuoteToUpdateList;
            this.markRun();
        }
    }    
}