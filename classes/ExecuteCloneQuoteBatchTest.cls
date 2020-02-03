@isTest
private class ExecuteCloneQuoteBatchTest {
	
	@isTest static void testButtonCall() {
		Test.startTest();
        Account objAccount = CventMYDDataFactory.createAccounts(1);
        insert objAccount;

        Contact objContact = CventMYDDataFactory.createContacts(1,objAccount.Id);
        insert objContact;

        Opportunity objOpport = CventMYDDataFactory.createOpportunities(1,objAccount.Id,objContact.Id);
        insert objOpport;
        System.debug('objOpport-->' + objOpport);

        List<Product2> lstProducts = CventMYDDataFactory.createProducts(2);
        insert lstProducts; 

        List<PricebookEntry> lstPBE = CventMYDDataFactory.createPriceBookEntry(lstProducts);
        insert lstPBE;

        SBQQ__ProductOption__c objProductOption = new SBQQ__ProductOption__c();
		objProductOption =  CventMYDDataFactory.createProductOptions(lstProducts[0].Id,lstProducts[1].Id,(1));
        insert objProductOption; 
        
        SBQQ__Quote__c objQuote = CventMYDDataFactory.createQuote(objAccount.Id,objOpport.Id,true);
        insert objQuote;   

		Test.stopTest();

		ExecuteCloneQuoteBatch.cloneQuoteAndGroups('','',objQuote.Id);
	}
	
}