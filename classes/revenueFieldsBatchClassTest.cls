@isTest(SeeAllData=false)
public class revenueFieldsBatchClassTest{
    public static Account instofAcc = new Account();
    public static Contact instofCon =  new Contact();
    public static testMethod void testBatch() {
        
        RecordType rtType = [SELECT r.SobjectType, r.DeveloperName,r.IsActive FROM RecordType r WHERE SobjectType='Account' And DeveloperName='Biz_Ac' And IsActive=true];
        instofAcc.Name = 'Test';
        //instofAcc.CurrencyIsoCode  = 'USD';
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        instofAcc.Account_Status__c = 'Active';
        instofAcc.RecordTypeId = rtType.id;
        instofAcc.BillingCountryCode = 'US';
        instofAcc.BillingStateCode = 'NY';
        insert instofAcc;
        
        instOfCon.LastName = 'Test';
        instOfCon.AccountId = instofAcc.Id;
        insert instOfCon;
        
        RecordType instOfRecType = [SELECT Id FROM RecordType WHERE SobjectType='Opportunity' And DeveloperName='Event' And IsActive=true];
        List <Opportunity> oppList = new List<Opportunity>();
        for(integer i = 0; i<1; i++){
            Opportunity instOfOpp = new Opportunity();
            instOfOpp.Contract_Type_Test__c = 'Renewal';
            instOfOpp.Liquidation_Fee__c  = 10;
            instofOpp.Exchange_Rate__c = 1;
            instOfOpp.Forex_rate__c = 1;
            //instOfOpp.Price_per_lead__c = 1;
            instOfOpp.OptOutDate__c = system.today();
            instOfOpp.Opp_End_Date__c  = system.today();
            instOfOpp.AccountId = instofAcc.id;
            instOfOpp.Name = 'Test';
            instOfOpp.Product__c = 'Event';
            instOfOpp.Contract_Number_New__c = '25512';
            instOfOpp.New_Type__c =  'Upsell-NBB';
            instOfOpp.StageName = 'Closed Won';
            instOfOpp.CloseDate = system.today();
            instOfOpp.RecordTypeId = instOfRecType.Id;
            instOfOpp.Year_1_at_Risk__c = 11;
            instOfOpp.New_Type__c = 'Test';
            instOfOpp.Deal_Booked_In__c = '1';
           // instOfOpp.Price_per_lead__c = 1;
            instOfOpp.Years__c= '1';
            instOfOpp.LeadSource = 'ACD-PS';
            instOfOpp.Contact_Associated__c = instOfCon.Id;
            instOfOpp.Contact_Role__c = 'Primary User';
            //instOfOpp.Contract_Implemented__c = true;
            instOfOpp.ContractReceived__c = system.today();
            instOfOpp.Deal_Year__c = '1';
            instOfOpp.MYD_Deal__c = 'First Year';
            instOfOpp.Deal_Year__c = '1';
            instOfOpp.MaintenanceFee__c = 1000;
            instOfOpp.New_Amount__c = 1000;
           // instOfOpp.Discount__c = 1000;
            instOfOpp.Convinience_Fee__c = 1000;
            instOfOpp.of_Leads_Purchased__c = 1000;
            //instOfOpp.Events__c = 1000; // comment by kumud [Remove field activity]
            instOfOpp.Price_Adjustment__c = 1000;
            instOfOpp.Parent_Upsell__c = 'Primary';
            oppList.add(instOfOpp);
        }
        insert oppList;
        
        
        Test.StartTest();
            revenueFieldsBatchClass testRun = new revenueFieldsBatchClass();
            ID batchprocessid = Database.executeBatch(testRun);
            
            revenueFieldsBatchClass_Scheduler q = new revenueFieldsBatchClass_Scheduler();
            SchedulableContext scq;
            q.execute(scq);  
        Test.StopTest();
   }
}