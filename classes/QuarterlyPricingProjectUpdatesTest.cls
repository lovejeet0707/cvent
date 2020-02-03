/*------------------------------------------------------------------------------------------------------------------------------+
Simplus(info@Simplus.com)
Purpose: Unit test
 
Details: Unit test for QuarterlyConversionUpdatesBatch and QuarterlyBlockPricingUpdatesBatch classes
 
History:
10/16/2018  CJ Abreu
	Created
 
-------------------------------------------------------------------------------------------------------------------------------+*/
@isTest
public class QuarterlyPricingProjectUpdatesTest {
	
	static testMethod void test_method_one() {
		Product2 product1 = new Product2();
        product1.Name = 'Product 1';
        product1.Contract_Output_Grouping__c = 'Event Cloud';
        product1.ProductCode = 'CBP-123-456-ABC';
        insert product1;
		List<DatedConversionRate> lst= [SELECT ConversionRate,IsoCode FROM DatedConversionRate ];
		System.debug(lst.size());
		CreateBlockP(product1);
		CreateCurrencyConverationTable();
		Id batchJobId = Database.executeBatch(new QuarterlyConversionUpdatesBatch(),1);
		System.assert(batchJobId != null);
	}
	static void CreateBlockP(Product2 product1)
	{
		List<SBQQ__BlockPrice__c> lstBP = new List<SBQQ__BlockPrice__c>();
		SBQQ__BlockPrice__c newBlockP = new SBQQ__BlockPrice__c();
		newBlockP.SBQQ__Price__c = 0;
		newBlockP.SBQQ__UpperBound__c = (1000);
		newBlockP.CurrencyIsoCode = 'ZAR';
		newBlockP.SBQQ__Product__c = product1.id;
		lstBP.add(newBlockP);
		SBQQ__BlockPrice__c newBlockP2 = new SBQQ__BlockPrice__c();
		newBlockP2.SBQQ__Price__c = 0;
		newBlockP2.SBQQ__UpperBound__c = (1000);
		newBlockP2.CurrencyIsoCode = 'USD';
		newBlockP2.SBQQ__Product__c = product1.id;
		lstBP.add(newBlockP2);
		insert lstBP;

	} 
	static void CreateCurrencyConverationTable()
	{
		List<Currency_Conversion_Table__c> lst = new List<Currency_Conversion_Table__c>();
		Currency_Conversion_Table__c newCCT = new Currency_Conversion_Table__c();
		newCCT.Currency_Conversion_Rate__c = 14.083800;
		newCCT.CurrencyIsoCode = 'ZAR';
		lst.add(newCCT);
		Currency_Conversion_Table__c newCCT2 = new Currency_Conversion_Table__c();
		newCCT2.Currency_Conversion_Rate__c = 1.000000;
		newCCT2.CurrencyIsoCode = 'USD';
		lst.add(newCCT2);
		insert lst;
	}
}