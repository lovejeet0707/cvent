@isTest
private class PriceRuleAnalyticsBatch_TEST {
	
	@isTest static void test_method_one() {
		Account account = CventMYDDataFactory.createAccounts(1);
		//account.Name = 'Account 1';
		insert account;
        
        Id addressRecordTypeId = Schema.SObjectType.Address__c.getRecordTypeInfosByName().get('Address').getRecordTypeId();
        List<Address__c> addresses = new List<Address__c>();
        Address__c newAddress = new Address__c(Type__c = 'Billing', Account__c = account.Id, Address__c = '720 South Michigan Avenue', City__c = 'Chicago',
                                              Postal_Code__c = '60605', Country__c = 'US', State__c = 'IL', RecordTypeId = addressRecordTypeId);
        addresses.add(newAddress);
        newAddress = new Address__c(Type__c = 'Shipping', Account__c = account.Id, Address__c = '720 South Michigan Avenue', City__c = 'Chicago',
                                              Postal_Code__c = '60605', Country__c = 'US', State__c = 'IL', RecordTypeId = addressRecordTypeId);
        addresses.add(newAddress);
        insert addresses;
        
		Opportunity opp = new Opportunity();
		opp.name = 'test opp';
		opp.Product__c = 'Event';
		opp.StageName = 'Verbal';
		opp.CloseDate = System.today();
		opp.CurrencyIsoCode = 'USD'; 
		opp.AccountId = account.Id;
        opp.contractedDateTime__c = datetime.now().addDays(-1); //ADD J.DECASTRO 03.27.2019  to be able to include on batch.
        opp.Bill_To_Address__c = addresses[0].Id;
        opp.Ship_To_Address__c = addresses[1].Id;
		insert opp;
		SBQQ__Quote__c quote = new SBQQ__Quote__c();
		quote.SBQQ__StartDate__c = System.today();
		quote.SBQQ__EndDate__c = System.today() + 365;
		quote.jsonString__c = '{"settings":{"preCalculationFieldNames":["SBQQ__Quantity__c","SBQQ__Discount__c","SBQQ__DistributorDiscount__c","Custom_Discount__c","Discount_Type__c","Rate__c","Zone_Level__c","Number_of_Guest_Rooms__c","Lanyon_Chain_Affiliation__c","Chain_Affiliation__c","Group_Business_Mix__c","Setup_Days__c","Travel_Days__c","Event_Start_Date__c","Event_End_Date__c","Attendees__c","OnArrival_360_Event_Selection__c","Complexity__c","SBQQ__StartDate__c","SBQQ__EndDate__c","Search_Screen_Region__c","CSN_Tier__c"],"calculatedFieldNames":["SBQQ__OriginalPrice__c","SBQQ__ListPrice__c","SBQQ__RegularPrice__c","SBQQ__CustomerPrice__c","SBQQ__PartnerPrice__c","SBQQ__NetPrice__c","Rack_Rate__c","SBQQ__ProrateMultiplier__c"],"msAtLastUpdate":1528734627259},"previousQuoteType":null,"outyearMap":{"2":{"startDate":"2018-08-01","endDate":"2019-07-31"},"3":{"startDate":"2019-08-01","endDate":"2020-07-31"}},"insertionId":"94257_FQP_87354","currentYearSynced":null,"automationStage":{"outyearProcessingStage":"OUTYEAR_PROCESSING_COMPLETE","codeStatus":"CALCULATION_CYCLE_FINISHED"}}';
		quote.Contract_Term_Years__c = '5';
		quote.Count_of_HC_Products__c = 0;
		quote.Count_of_EC_Products__c = 1;
		quote.SBQQ__Account__c = account.Id;
		quote.Current_Year__c = 1;
		quote.SBQQ__Opportunity2__c = opp.id;
		quote.Multiple_Years_Commitment__c = TRUE;
		quote.Included_in_Primary_Batch_AW__c = true;
		insert quote;
		//adding Groups
		List<SBQQ__QuoteLine__c> lst_ql= new List<SBQQ__QuoteLine__c>();
		Map<Integer, SBQQ__QuoteLineGroup__c> map_qlg = new Map<Integer, SBQQ__QuoteLineGroup__c>();
		for (Integer i = 0, j = 0; i < 5; i++) 
		{
			SBQQ__QuoteLineGroup__c qlg = new SBQQ__QuoteLineGroup__c();
			qlg.Name = 'Year'+(i+1);
			qlg.SBQQ__Number__c = i+1;
			qlg.SBQQ__ListTotal__c = 0.00;
			qlg.SBQQ__CustomerTotal__c = 0.00;
			qlg.SBQQ__NetTotal__c = 0.00;
			qlg.CurrencyIsoCode = 'USD';
			qlg.SBQQ__Quote__c = quote.id;
			qlg.term__c =i+1; 
			insert qlg;
			map_qlg.put(i, qlg);
		}
		Product2 product1 = new Product2();
		product1.Name = 'Product 1';
		product1.Contract_Output_Grouping__c = 'Event Cloud';
		product1.ProductCode = 'CV-SW-EC-EVT';
		insert product1;

		//List<SBQQ__QuoteLine__c> lst_qls = new List<SBQQ__QuoteLine__c>();
		Date startdate =System.today();
		Date endsdate = System.today() + 365;
		for (Integer i = 0, j = 0; i < 5; i++) 
		{
				SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c();
				ql1.SBQQ__Quantity__c = 1;
				ql1.SBQQ__Product__c = product1.Id;
				ql1.SBQQ__ListPrice__c = 10;
				ql1.SBQQ__NetPrice__c = 10;
				ql1.Rack_Rate__c = 10;
				ql1.SBQQ__SubscriptionPricing__c = 'Fixed Price';
				ql1.SBQQ__Quote__c = quote.Id;
				ql1.Notes__c = 'abc';
				ql1.Overage_Fee__c = i+1;
				ql1.SBQQ__Group__c = map_qlg.get(i).id;
				ql1.priceRuleDebug__c = 'null:Hospitality Cloud Markup - Original Price Inject;Populate Currency on Init.;Clear Out QL Start/End Dates on Init:HC Property Bundled;Set notes for retired products;Approvals: Line Item Disc (Max);Apply discount;Set Quote Line Proration Dates;Reset Quote Line Proration Dates;Rack Rate Management;**Volume (Block) Discount @[-3500]-[0];Aggregate Quote Information';
				lst_ql.add(ql1);
		}
		insert lst_ql;

		/*test.startTest();
			PriceRuleAnalyticsBatch b=new PriceRuleAnalyticsBatch();
			database.executeBatch(b);
		test.stopTest();*/
        
        Test.startTest();
        PriceRuleAnalyticsSchedulable sh1 = new PriceRuleAnalyticsSchedulable();
        String sch = '0 0 3 7 1/1 ? *';  //ADD J.DECASTRO 03.27.2019 run every 7th day of the month at 3am EST
        system.schedule('Test Price Ryle Analytics Schedulable', sch, sh1);
        Test.stopTest();
	}
}