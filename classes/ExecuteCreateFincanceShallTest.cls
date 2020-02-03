@isTest
private class ExecuteCreateFincanceShallTest {
	
	@isTest static void test_method_one() {
		 Test.startTest();
				Currency_Conversion_Table__c newCCT = new Currency_Conversion_Table__c();
				newCCT.Currency_Conversion_Rate__c = 1.400000;
				newCCT.CurrencyIsoCode = 'USD';
				insert newCCT;
				
		        Account objAccount = CventMYDDataFactory.createAccounts(1);
		        insert objAccount;

		        Contact objContact = CventMYDDataFactory.createContacts(1,objAccount.Id);
		        insert objContact;

		        Opportunity objOpport = CventMYDDataFactory.createOpportunities(1,objAccount.Id,objContact.Id);
		        objOpport.ContractReceived__c = System.today();
		        insert objOpport;
		         
				Profile p = [SELECT Name FROM Profile WHERE Name = 'System Administrator']; 
		        User u1 = new User(Alias = 'standt1', Email='standarduser1@testorg.com', 
		        EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
		        LocaleSidKey='en_US', ProfileId = p.Id, 
		        TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtest1@testorg.com');
		        insert u1;
		        User u2 = new User(Alias = 'standt2', Email='standarduser2@testorg.com', 
		        EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
		        LocaleSidKey='en_US', ProfileId = p.Id, 
		        TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtest2@testorg.com');
		        insert u2;

		        OpportunitySplit objOppSplit1 = new OpportunitySplit();
		        objOppSplit1.OpportunityId = objOpport.Id;
		        objOppSplit1.SplitPercentage = 20;
		        objOppSplit1.SplitOwnerId = u1.Id;
		        objOppSplit1.Lanyon_Migrated_ID__c = 'a123';
		        insert objOppSplit1;
		        OpportunitySplit objOppSplit2 = new OpportunitySplit();
		        objOppSplit2.OpportunityId = objOpport.Id;
		        objOppSplit2.SplitPercentage = 20;
		        objOppSplit2.SplitOwnerId = u2.Id;
		        objOppSplit2.Lanyon_Migrated_ID__c = 'b123';
		        insert objOppSplit2;

		        List<Product2> lstProducts = CventMYDDataFactory.createProducts(2);
		        insert lstProducts; 

		        List<PricebookEntry> lstPBE = CventMYDDataFactory.createPriceBookEntry(lstProducts);
		        insert lstPBE;

		        SBQQ__ProductOption__c objProductOption = new SBQQ__ProductOption__c();
		        //for(Integer i = 0; i< lstProducts.size() ; i++){
		           objProductOption =  CventMYDDataFactory.createProductOptions(lstProducts[0].Id,lstProducts[1].Id,(1));
		        //}
		        insert objProductOption; 
		        
		        SBQQ__Quote__c objQuote = CventMYDDataFactory.createQuote(objAccount.Id,objOpport.Id,true);
                objQuote.jsonString__c = JSON.serialize(getTestQuoteObject());
		        insert objQuote;   

				objOpport.SBQQ__PrimaryQuote__c  = objQuote.Id;
				update objOpport;

		        List<SBQQ__QuoteLine__c> lstQuoteLines= new List<SBQQ__QuoteLine__c>();
		        lstQuoteLines.add(CventMYDDataFactory.createQuoteLine(objQuote,lstProducts[0].Id,500));
		        lstQuoteLines.add(CventMYDDataFactory.createQuoteLine(objQuote,lstProducts[0].Id,null));
		        
		        insert lstQuoteLines;

				Contract_Reviewing__c objContReview = new Contract_Reviewing__c(
					Contract_Review_Ok__c = 'Yes',
					Opportunity__c = objOpport.Id
				);

				insert objContReview;
				Test.stopTest();

				ExecuteCreateFincanceShallFromOppBatch.createFincanceShallFromOpp(objOpport.Id,'Closed Lost - Opted Out/Cancelled');
	}
	@isTest static void test_method_two() {
		 Test.startTest();
				Currency_Conversion_Table__c newCCT = new Currency_Conversion_Table__c();
				newCCT.Currency_Conversion_Rate__c = 1.400000;
				newCCT.CurrencyIsoCode = 'USD';
				insert newCCT;
				
		        Account objAccount = CventMYDDataFactory.createAccounts(1);
		        insert objAccount;

		        Contact objContact = CventMYDDataFactory.createContacts(1,objAccount.Id);
		        insert objContact;

		        Opportunity objOpport = CventMYDDataFactory.createOpportunities(1,objAccount.Id,objContact.Id);
		        objOpport.ContractReceived__c = System.today();
		        insert objOpport;
		         
				Profile p = [SELECT Name FROM Profile WHERE Name = 'System Administrator']; 
		        User u1 = new User(Alias = 'standt1', Email='standarduser1@testorg.com', 
		        EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
		        LocaleSidKey='en_US', ProfileId = p.Id, 
		        TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtest1@testorg.com');
		        insert u1;
		        User u2 = new User(Alias = 'standt2', Email='standarduser2@testorg.com', 
		        EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
		        LocaleSidKey='en_US', ProfileId = p.Id, 
		        TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtest2@testorg.com');
		        insert u2;

		        OpportunitySplit objOppSplit1 = new OpportunitySplit();
		        objOppSplit1.OpportunityId = objOpport.Id;
		        objOppSplit1.SplitPercentage = 20;
		        objOppSplit1.SplitOwnerId = u1.Id;
		        objOppSplit1.Lanyon_Migrated_ID__c = 'a123';
		        insert objOppSplit1;
		        OpportunitySplit objOppSplit2 = new OpportunitySplit();
		        objOppSplit2.OpportunityId = objOpport.Id;
		        objOppSplit2.SplitPercentage = 20;
		        objOppSplit2.SplitOwnerId = u2.Id;
		        objOppSplit2.Lanyon_Migrated_ID__c = 'b123';
		        insert objOppSplit2;

		        List<Product2> lstProducts = CventMYDDataFactory.createProducts(2);
		        insert lstProducts; 

		        List<PricebookEntry> lstPBE = CventMYDDataFactory.createPriceBookEntry(lstProducts);
		        insert lstPBE;

		        SBQQ__ProductOption__c objProductOption = new SBQQ__ProductOption__c();
		        //for(Integer i = 0; i< lstProducts.size() ; i++){
		           objProductOption =  CventMYDDataFactory.createProductOptions(lstProducts[0].Id,lstProducts[1].Id,(1));
		        //}
		        insert objProductOption; 
		        
		        SBQQ__Quote__c objQuote = CventMYDDataFactory.createQuote(objAccount.Id,objOpport.Id,false);
                objQuote.jsonString__c = JSON.serialize(getTestQuoteObject());
		        insert objQuote;   

				objOpport.SBQQ__PrimaryQuote__c  = objQuote.Id;
				update objOpport;

		        List<SBQQ__QuoteLine__c> lstQuoteLines= new List<SBQQ__QuoteLine__c>();
		        lstQuoteLines.add(CventMYDDataFactory.createQuoteLine(objQuote,lstProducts[0].Id,500));
		        lstQuoteLines.add(CventMYDDataFactory.createQuoteLine(objQuote,lstProducts[0].Id,null));
		        
		        insert lstQuoteLines;

				Contract_Reviewing__c objContReview = new Contract_Reviewing__c(
					Contract_Review_Ok__c = 'Yes',
					Opportunity__c = objOpport.Id
				);

				insert objContReview;
				Test.stopTest();

				ExecuteCreateFincanceShallFromOppBatch.createFincanceShallFromOpp(objOpport.Id,'Closed Lost - Opted Out/Cancelled');
	}
	@isTest static void test_method_three() {
		 Test.startTest();
				Currency_Conversion_Table__c newCCT = new Currency_Conversion_Table__c();
				newCCT.Currency_Conversion_Rate__c = 1.400000;
				newCCT.CurrencyIsoCode = 'USD';
				insert newCCT;
				
		        Account objAccount = CventMYDDataFactory.createAccounts(1);
		        insert objAccount;

		        Contact objContact = CventMYDDataFactory.createContacts(1,objAccount.Id);
		        insert objContact;

		        Opportunity objOpport = CventMYDDataFactory.createOpportunities_Stage(1,objAccount.Id,objContact.Id);
		        objOpport.ContractReceived__c = System.today();
		        insert objOpport;
		         
				Profile p = [SELECT Name FROM Profile WHERE Name = 'System Administrator']; 
		        User u1 = new User(Alias = 'standt1', Email='standarduser1@testorg.com', 
		        EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
		        LocaleSidKey='en_US', ProfileId = p.Id, 
		        TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtest1@testorg.com');
		        insert u1;
		        User u2 = new User(Alias = 'standt2', Email='standarduser2@testorg.com', 
		        EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
		        LocaleSidKey='en_US', ProfileId = p.Id, 
		        TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtest2@testorg.com');
		        insert u2;

		        OpportunitySplit objOppSplit1 = new OpportunitySplit();
		        objOppSplit1.OpportunityId = objOpport.Id;
		        objOppSplit1.SplitPercentage = 20;
		        objOppSplit1.SplitOwnerId = u1.Id;
		        objOppSplit1.Lanyon_Migrated_ID__c = 'a123';
		        insert objOppSplit1;
		        OpportunitySplit objOppSplit2 = new OpportunitySplit();
		        objOppSplit2.OpportunityId = objOpport.Id;
		        objOppSplit2.SplitPercentage = 20;
		        objOppSplit2.SplitOwnerId = u2.Id;
		        objOppSplit2.Lanyon_Migrated_ID__c = 'b123';
		        insert objOppSplit2;

		        List<Product2> lstProducts = CventMYDDataFactory.createProducts(2);
		        insert lstProducts; 

		        List<PricebookEntry> lstPBE = CventMYDDataFactory.createPriceBookEntry(lstProducts);
		        insert lstPBE;

		        SBQQ__ProductOption__c objProductOption = new SBQQ__ProductOption__c();
		        //for(Integer i = 0; i< lstProducts.size() ; i++){
		           objProductOption =  CventMYDDataFactory.createProductOptions(lstProducts[0].Id,lstProducts[1].Id,(1));
		        //}
		        insert objProductOption; 
		        
		        SBQQ__Quote__c objQuote = CventMYDDataFactory.createQuote(objAccount.Id,objOpport.Id,true);
                objQuote.jsonString__c = JSON.serialize(getTestQuoteObject());
		        insert objQuote;   

				objOpport.SBQQ__PrimaryQuote__c  = objQuote.Id;
				update objOpport;

		        List<SBQQ__QuoteLine__c> lstQuoteLines= new List<SBQQ__QuoteLine__c>();
		        lstQuoteLines.add(CventMYDDataFactory.createQuoteLine(objQuote,lstProducts[0].Id,500));
		        lstQuoteLines.add(CventMYDDataFactory.createQuoteLine(objQuote,lstProducts[0].Id,null));
		        
		        insert lstQuoteLines;

				Contract_Reviewing__c objContReview = new Contract_Reviewing__c(
					Contract_Review_Ok__c = 'Yes',
					Opportunity__c = objOpport.Id
				);

				insert objContReview;
				Test.stopTest();

				ExecuteCreateFincanceShallFromOppBatch.createFincanceShallFromOpp(objOpport.Id,'Proposal Sent');
	}
	public static CventMyd_QuoteLineObject getTestQuoteLineObject() {

       CventMyd_QuoteLineObject quoteLineObject = new CventMyd_QuoteLineObject();

       quoteLineObject.qleId = CventMyd_UtilityMethods.getQleId();

       quoteLineObject.insertOnNextCurrentYear = false;

	   quoteLineObject.clonedFromQleIds = new List<String>();

       quoteLineObject.deleteThisLine = false;

       quoteLineObject.preCalculationFieldValueMap = new Map<String,List<String>>();

       quoteLineObject.calculatedFieldValueMap = new Map<String,List<String>>();

       for(List<String> fieldNameList : CventMyd_Settings.fieldValueMapFieldNameLists) {

           Integer index = CventMyd_Settings.fieldValueMapFieldNameLists.indexOf(fieldNameList);

           for(String fieldName : fieldNameList) {

               if(index == 0) {
                
                   quoteLineObject.preCalculationFieldValueMap.put(fieldName, new List<String>());

                   quoteLineObject.preCalculationFieldValueMap.get(fieldName).add('2018-01-01');

               }

           }

       }

       quoteLineObject.nextYearQleId = CventMyd_UtilityMethods.getQleId();

       return quoteLineObject;


   }

    public static CventMyd_QuoteObject getTestQuoteObject() {

        CventMyd_QuoteObject quoteObject = new CventMyd_QuoteObject();

        quoteObject.insertionId = CventMyd_UtilityMethods.getQleId();

        quoteObject.settings = new CventMyd_QuoteObject.Settings();

        quoteObject.settings.preCalculationFieldNames = CventMyd_Settings.fieldValueMapFieldNameLists[0];

        quoteObject.settings.calculatedFieldNames = CventMyd_Settings.fieldValueMapFieldNameLists[1];

        quoteObject.settings.msAtLastUpdate = null;

        quoteObject.automationStage = new CventMyd_QuoteAutomationStage();

        quoteObject.automationStage.codeStatus = CventMyd_QuoteAutomationStage.CodeStatus.LAST_UPDATED_BY_TRIGGER;

        quoteObject.outyearMap = new Map<Integer,CventMyd_Outyear>();

        return quoteObject;
    
    }
	
}