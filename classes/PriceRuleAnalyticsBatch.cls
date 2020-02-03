global class PriceRuleAnalyticsBatch implements Database.Batchable<sObject> {
	
	String query;
	// static List<QL_Price_Rule__c> updateParentList = new List<QL_Price_Rule__c>();
	global PriceRuleAnalyticsBatch() {
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		List<SBQQ__QuoteLine__c> lst_QuoteLine = [SELECT Id,Name, SBQQ__NetPrice__c, SBQQ__RegularPrice__c, SBQQ__Quote__r.CurrencyIsoCode, SBQQ__CustomerPrice__c, priceRuleDebug__c, SBQQ__Quote__r.Included_in_Primary_Batch_AW__c, SBQQ__Quote__c FROM SBQQ__QuoteLine__c WHERE ID = 'aFT1N0000005roh'];
		
        /* UPDATE J.DECASTRO 03.27.2019 
         * Filter quotelines with the parent Quote is Primary equals true
         * Filter quotelines with the parent Opportunity ContractedDateTime for the Last 31 Days
		*/
        return Database.getQueryLocator([SELECT Id,Name, SBQQ__NetPrice__c, SBQQ__RegularPrice__c, SBQQ__Quote__r.CurrencyIsoCode, SBQQ__CustomerPrice__c, priceRuleDebug__c, SBQQ__Quote__r.Included_in_Primary_Batch_AW__c, SBQQ__Quote__c FROM SBQQ__QuoteLine__c 
                                         WHERE SBQQ__Quote__r.SBQQ__Primary__c = true AND 
                                         SBQQ__Quote__r.SBQQ__Opportunity2__r.contractedDateTime__c = LAST_N_DAYS:31]);
	}

			//[SELECT Id,Name, SBQQ__NetPrice__c, SBQQ__RegularPrice__c, SBQQ__Quote__r.CurrencyIsoCode, SBQQ__CustomerPrice__c, priceRuleDebug__c, SBQQ__Quote__r.Included_in_Primary_Batch_AW__c, SBQQ__Quote__c FROM SBQQ__QuoteLine__c WHERE ID = 'aFT1N0000005roh']);
			

   	global void execute(Database.BatchableContext BC, List<SBQQ__QuoteLine__c> scope) {
	
		List<QL_Price_Rule__c> insertList = new List<QL_Price_Rule__c> ();
		Map<String, QL_Price_Rule__c> map_QLPRidQLid = new Map<String, QL_Price_Rule__c>();
		//RecordType rt= [SELECT id FROM RecordType WHERE Name='Child'];
		Set<String> findQLPRrelated = new Set<String>();
		for(SBQQ__QuoteLine__c lp : scope)
		{
			String str = lp.priceRuleDebug__c;
            if(str != null)
            {
               	if(str.contains('**'))
                {
					findQLPRrelated.add(lp.Id);
				} 
            }	
		}
		//search for QLPR records and delete parent( create trigger on QLPR if parent is deleted, delete children)
		delete [SELECT Id FROM QL_Price_Rule__c WHERE Quote_Line__c IN :findQLPRrelated];
		
		for(SBQQ__QuoteLine__c lp : scope)
		{
            String str = lp.priceRuleDebug__c;
            if(str != null)
            {
               	if(str.contains('**'))
                {
					insertList.addAll(createQLPR(lp.priceRuleDebug__c,lp, map_QLPRidQLid));
                }
            }
		}
		if(insertList.size()>0)
		{
			insert insertList;
		}
		
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	public static List<QL_Price_Rule__c> createQLPR(String str, SBQQ__QuoteLine__c QL, Map<String, QL_Price_Rule__c> map_idQLPR_Parent)
	{
		List<QL_Price_Rule__c> returnList = new List<QL_Price_Rule__c> ();
		List<String> lst_Str = str.split(';');
		System.debug(lst_Str.size());
		Integer num = 0;
		Decimal[] lst_NumbersOfamounts = new List<Decimal>();
		for(String lp : lst_Str)
		{
			if(lp.contains('**')){
				num +=1;
				String testString = lp.remove('**');
				List<String> splitString = testString.split('@');
				System.debug('Price Rule Name : '+splitString[0]); 
				System.debug('QL Id : '+QL.Id); 
				String valuesNumbers = splitString[1];
				valuesNumbers = valuesNumbers.removeEnd(']');
				valuesNumbers = valuesNumbers.removeStart('[');
				valuesNumbers = valuesNumbers.replace(']-[', '@');
				List<String> splitNumbers = valuesNumbers.split('@');
				QL_Price_Rule__c newQLPR = new QL_Price_Rule__c();
				newQLPR.PriceRuleName__c = splitString[0];
				//newQLPR.RecordTypeId = rtId;
				newQLPR.Order__c = num;
				//put RecordTypeId for Child 
				newQLPR.PriceBefore__c = Decimal.valueOf(splitNumbers[0]);
				newQLPR.PriceAfter__c = Decimal.valueOf(splitNumbers[1]);
				newQLPR.Quote_Line__c = QL.Id;
				newQLPR.Quote__c = QL.SBQQ__Quote__c;
				newQLPR.CurrencyIsoCode = QL.SBQQ__Quote__r.CurrencyIsoCode;
				//newQLPR.Parent_QLPR__c = map_idQLPR_Parent.get(QL.Id).id;
				//newQLPR.Discount_Type__c
				returnList.add(newQLPR);
				lst_NumbersOfamounts.add(newQLPR.PriceBefore__c);
				lst_NumbersOfamounts.add(newQLPR.PriceAfter__c);
			}
		}
		Decimal MaxValue = 0.00;
		Decimal MinValue = 0.00;
		if(lst_NumbersOfamounts.size()>0)
		{
			lst_NumbersOfamounts.sort();
			Integer last = lst_NumbersOfamounts.size()-1;
			MaxValue = lst_NumbersOfamounts[last];
			MinValue = lst_NumbersOfamounts[0];
            Decimal[] lst_PricesCompare = new List<Decimal>();
            lst_PricesCompare.add(QL.SBQQ__NetPrice__c);
            lst_PricesCompare.add(QL.SBQQ__RegularPrice__c);
            lst_PricesCompare.add(QL.SBQQ__CustomerPrice__c);
            lst_PricesCompare.sort();
            Integer lastPricesCompare = lst_PricesCompare.size()-1;
            if(lst_PricesCompare[lastPricesCompare]> MaxValue)
            {
                MaxValue = lst_PricesCompare[lastPricesCompare];
            }
            if(lst_PricesCompare[0]< MinValue)
            {
                MinValue = lst_PricesCompare[0];
            }
		}
		for(QL_Price_Rule__c lp : returnList)
		{
			lp.Max_Price__c = MaxValue;
			lp.Min_Price__c = MinValue;
		}
		return returnList;
	}
}