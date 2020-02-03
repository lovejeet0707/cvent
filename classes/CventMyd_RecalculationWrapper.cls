public class CventMyd_RecalculationWrapper {
	
	public Map<Id,Boolean> mapOfQuotesToRecalculate {get;set;}

	public Map<Id,Id> opportunityIdToPrimaryQuoteId {get;set;}

	public List<SBQQ__Quote__c> quotes {get;set;}

}