/************************************************
* Author : Sandeep Kumar
* Date : 23 November, 2017
* Description : It tests below mentioned classes
* 1) UpdateLegalReviewStageOnQuote_TrigAct
*************************************************/
@isTest
public class UpdateLegalReviewStage_TrigAct_Test {    
    
    public static testMethod void updateLeagalReviewStageOnClosedWon(){
        Account account = new Account(); 
        account.Name = 'Account 1';
        insert account;
        
        // Create Contact Record.
        Contact con = TestUtil.createContact(account.id);
        insert con;
        
        Opportunity opp = TestUtil.createOpportunity('testOpp','Event','Presentation');
        opp.Contact_Associated__c = con.Id;
        opp.AccountId = account.Id;
        opp.Event_Planner_Name__c = 'test User';
        opp.Event_Planner_Email__c = 'testuser@cvent.com';
        opp.CloseDate = Date.today().addDays(80);
        insert opp;
        
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
        quote.SBQQ__Opportunity2__c = opp.Id;
        quote.Legal_Review_Stage__c = 'Ready for Signature';
        quote.Current_Year__c = 1;
        quote.Multiple_Years_Commitment__c = TRUE;
        insert quote;
        
        Product2 product1 = new Product2();
        product1.Name = 'Product 1';
        product1.Contract_Output_Grouping__c = 'Event Cloud';
        product1.ProductCode = 'CBP-123-456-ABC';
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
        
        Product2 product2 = new Product2();
        product2.Name = 'Product 2';
        product2.Contract_Output_Grouping__c = 'Event Cloud';
        product2.ProductCode = 'CV-SW-EC-EVT-CCMOB';
        insert product2;   
        
        Test.startTest();
        
        PricebookEntry pbe1 =  TestUtil.createPricebookEntry(product2,200);
        insert pbe1;
        
        OpportunityLineItem oli1 = TestUtil.createOpportunityLineItems(opp,pbe1);
        insert oli1;
        
        SBQQ__QuoteLine__c ql2 = new SBQQ__QuoteLine__c();
        ql2.SBQQ__Quantity__c = 1;
        ql2.SBQQ__Product__c = product2.Id;
        ql2.SBQQ__ListPrice__c = 10;
        ql2.SBQQ__NetPrice__c = 10;
        ql2.Rack_Rate__c = 10;
        ql2.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        ql2.Year_2_Quantity__c = 2;
        ql2.Year_2_List_Price__c = 20;
        ql2.Year_2_Net_Amount__c = 40;
        ql2.Year_2_Effective_Amount__c = 40;
        ql2.Year_3_Quantity__c = 2;
        ql2.Year_3_List_Price__c = 20;
        ql2.Year_3_Net_Amount__c = 40;
        ql2.Year_3_Effective_Amount__c = 40;
        ql2.Year_4_Quantity__c = 2;
        ql2.Year_4_List_Price__c = 20;
        ql2.Year_4_Net_Amount__c = 40;
        ql2.Year_4_Effective_Amount__c = 40;
        ql2.Year_5_Quantity__c = 2;
        ql2.Year_5_List_Price__c = 20;
        ql2.Year_5_Net_Amount__c = 40;
        ql2.Year_5_Effective_Amount__c = 40;
        ql2.SBQQ__Quote__c = quote.Id;
        ql2.Notes__c = 'abc';
        ql2.Overage_Fee__c = 2;
        insert ql2;
        
        // Execute the contract before closing the opportunity stage.
        SBQQ__Quote__c quoteToUpdate = [Select Id,Contract_Executed__c From SBQQ__Quote__c Where Id=:quote.Id];
        quoteToUpdate.Contract_Executed__c = true;
        update quoteToUpdate;
        
        Opportunity oppToUpdate = [Select Id,StageName From Opportunity Where Id=:opp.Id];
        oppToUpdate.StageName = 'Closed Won';
        update oppToUpdate;
        Test.stopTest();
    }
    
    public static testMethod void updateLeagalReviewStageOnClosedLost(){
        Account account = new Account(); 
        account.Name = 'Account 1';
        insert account;
        
        // Create Contact Record.
        Contact con = TestUtil.createContact(account.id);
        insert con;
        
        Opportunity opp = TestUtil.createOpportunity('testOpp','Event','Presentation');
        opp.Contact_Associated__c = con.Id;
        opp.AccountId = account.Id;
        opp.Event_Planner_Name__c = 'test User';
        opp.Event_Planner_Email__c = 'testuser@cvent.com';
        opp.CloseDate = Date.today().addDays(80);
        insert opp;
        
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
        quote.SBQQ__Opportunity2__c = opp.Id;
        quote.Legal_Review_Stage__c = 'Ready for Signature';
        quote.Current_Year__c = 1;
        quote.Multiple_Years_Commitment__c = TRUE;
        insert quote;
        
        Product2 product1 = new Product2();
        product1.Name = 'Product 1';
        product1.Contract_Output_Grouping__c = 'Event Cloud';
        product1.ProductCode = 'CBP-123-456-ABC';
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
        
        Product2 product2 = new Product2();
        product2.Name = 'Product 2';
        product2.Contract_Output_Grouping__c = 'Event Cloud';
        product2.ProductCode = 'CV-SW-EC-EVT-CCMOB';
        insert product2;
        
        PricebookEntry pbe1 =  TestUtil.createPricebookEntry(product2,200);
        insert pbe1;
        
        Test.startTest();
        
        OpportunityLineItem oli1 = TestUtil.createOpportunityLineItems(opp,pbe1);
        insert oli1;
        
        SBQQ__QuoteLine__c ql2 = new SBQQ__QuoteLine__c();
        ql2.SBQQ__Quantity__c = 1;
        ql2.SBQQ__Product__c = product2.Id;
        ql2.SBQQ__ListPrice__c = 10;
        ql2.SBQQ__NetPrice__c = 10;
        ql2.Rack_Rate__c = 10;
        ql2.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        ql2.Year_2_Quantity__c = 2;
        ql2.Year_2_List_Price__c = 20;
        ql2.Year_2_Net_Amount__c = 40;
        ql2.Year_2_Effective_Amount__c = 40;
        ql2.Year_3_Quantity__c = 2;
        ql2.Year_3_List_Price__c = 20;
        ql2.Year_3_Net_Amount__c = 40;
        ql2.Year_3_Effective_Amount__c = 40;
        ql2.Year_4_Quantity__c = 2;
        ql2.Year_4_List_Price__c = 20;
        ql2.Year_4_Net_Amount__c = 40;
        ql2.Year_4_Effective_Amount__c = 40;
        ql2.Year_5_Quantity__c = 2;
        ql2.Year_5_List_Price__c = 20;
        ql2.Year_5_Net_Amount__c = 40;
        ql2.Year_5_Effective_Amount__c = 40;
        ql2.SBQQ__Quote__c = quote.Id;
        ql2.Notes__c = 'abc';
        ql2.Overage_Fee__c = 2;
        insert ql2;
        
        // Execute the contract before closing the opportunity stage.
        SBQQ__Quote__c quoteToUpdate = [Select Id,Contract_Executed__c From SBQQ__Quote__c Where Id=:quote.Id];
        quoteToUpdate.Contract_Executed__c = true;
        update quoteToUpdate;
        // Close the Opportunity
        Opportunity oppToUpdate = [Select Id,StageName From Opportunity Where Id=:opp.Id];
        oppToUpdate.StageName = 'Closed Lost';
        update oppToUpdate;        
        Test.stopTest();
    }
}