@isTest
public class ApprovalsTableControllerTest {
    @isTest
    static void testGetQuoteLinesList() {
        
        Account account = new Account();
        account.Name = 'Account 1';
        insert account;

        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__StartDate__c = System.today();
        quote.SBQQ__EndDate__c = System.today() + 365;
        quote.Effective_Year_1_Start_Date__c = quote.SBQQ__StartDate__c;
        quote.Effective_Year_1_End_Date__c = quote.SBQQ__EndDate__c;
        quote.Effective_Year_2_Start_Date__c = quote.Effective_Year_1_End_Date__c + 1;
        quote.Effective_Year_2_End_Date__c = quote.Effective_Year_2_Start_Date__c + 365;
        quote.Effective_Year_3_Start_Date__c = quote.Effective_Year_2_End_Date__c + 1;
        quote.Effective_Year_3_End_Date__c = quote.Effective_Year_3_Start_Date__c + 365;
        quote.Effective_Year_4_Start_Date__c = quote.Effective_Year_3_End_Date__c + 1;
        quote.Effective_Year_4_End_Date__c = quote.Effective_Year_4_Start_Date__c + 365;
        quote.Effective_Year_5_Start_Date__c = quote.Effective_Year_4_End_Date__c + 1;
        quote.Effective_Year_5_End_Date__c = quote.Effective_Year_5_Start_Date__c + 365;
        quote.Contract_Term_Years__c = '5';
        quote.Count_of_HC_Products__c = 0;
        quote.Count_of_EC_Products__c = 1;
        quote.SBQQ__Account__c = account.Id;
        quote.Current_Year__c = 1;
        quote.Multiple_Years_Commitment__c = TRUE;
        insert quote;

        Product2 product1 = new Product2();
        product1.Name = 'Product 1';
        product1.Contract_Output_Grouping__c = 'Event Cloud';
        insert product1;

        SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c();
        ql1.SBQQ__Quantity__c = 1;
        ql1.SBQQ__Product__c = product1.Id;
        ql1.SBQQ__ListPrice__c = 10;
        ql1.SBQQ__NetPrice__c = 10;
        ql1.Rack_Rate__c = 10;
        ql1.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        ql1.Year_2_Quantity__c = 2;
        ql1.Year_2_List_Price__c = 20;
        ql1.Year_2_Net_Amount__c = 40;
        ql1.Year_2_Effective_Amount__c = 40;
        ql1.Year_3_Quantity__c = 2;
        ql1.Year_3_List_Price__c = 20;
        ql1.Year_3_Net_Amount__c = 40;
        ql1.Year_3_Effective_Amount__c = 40;
        ql1.Year_4_Quantity__c = 2;
        ql1.Year_4_List_Price__c = 20;
        ql1.Year_4_Net_Amount__c = 40;
        ql1.Year_4_Effective_Amount__c = 40;
        ql1.Year_5_Quantity__c = 2;
        ql1.Year_5_List_Price__c = 20;
        ql1.Year_5_Net_Amount__c = 40;
        ql1.Year_5_Effective_Amount__c = 40;
        ql1.SBQQ__Quote__c = quote.Id;
		ql1.Notes__c = 'abc';
		ql1.Overage_Fee__c = 2;
        insert ql1;
    	
        ApprovalsTableController controller = new ApprovalsTableController();
        controller.objId = quote.Id;
        
        List<sbaa__Approval__c> qlList = controller.getApprovalsList();
        //System.assertNotEquals(null, qlList.size());
        //System.assertNotEquals(0, qlList.size());
    }

}