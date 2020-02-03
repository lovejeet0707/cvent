@isTest
private class CloneWithContractGroupsQueryMakerTest {
	
	@isTest static void testGetOuterQueryForQuoteLines() {
	CloneQuoteWithContractGroupsQueryMaker.getOuterQueryForQuoteLines('SBQQ__Quote__c' , 'ID = \'TestId\'');
	}

	@isTest static void testGetQueryWithAllFields() {
	CloneQuoteWithContractGroupsQueryMaker.getQueryWithAllFields('SBQQ__Quote__c');
	}
}