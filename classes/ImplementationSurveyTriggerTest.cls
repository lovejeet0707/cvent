@isTest
public class ImplementationSurveyTriggerTest{
    public static testMethod void testInsertSurvey(){
        
        Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true);
        insert pbk1;

        Product2 prd1 = new Product2 (Name='Data Entry',Description='Test Product Entry 1',productCode = 'ABC', isActive = true);
        insert prd1;

        //get standard pricebook
        Id pricebookId = Test.getStandardPricebookId();
        //Pricebook2  standardPb = [select id, name, isActive from Pricebook2 where IsStandard = true limit 1];

        PricebookEntry standPriceBook= new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=pricebookId,UnitPrice=50, isActive=true);
        insert standPriceBook;

        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=pbk1.id,UnitPrice=50, isActive=true);
        insert pbe1;
        
        
        Account instofAcc = TestUtil.createAccount('Test Account','Biz_Ac');
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        instofAcc.Named_Acct__c = 'Cvent Vendor';
        instofAcc.Share_of_Wallet_Tier_Max__c=1100;
        instOfAcc.HC_Share_of_Wallet_Client__c=500;
        insert instofAcc;
        
        Contact instofCon =  TestUtil.createContact(String.valueOf(instofAcc.Id));
        insert instOfCon;
        
        Opportunity instOfOppThird  = TestUtil.createOpportunityNew('test','Verbal',instofCon.Id,instofAcc.Id);
        instOfOppThird.Product__c = 'Event';
        instOfOppThird.New_Type__c =  'Upsell-NBB';
        instOfOppThird.New_Amount__c = 11;
        instOfOppThird.Years__c= '1';
        instOfOppThird.LeadSource = 'ACD-PS';
        instOfOppThird.Contract_Implemented__c = true;
        instOfOppThird.ContractReceived__c = system.today();
        instOfOppThird.Deal_Year__c = '1';
        instOfOppThird.Pricebook2Id = pbe1.Pricebook2Id;
        insert instOfOppThird;
        
        SBQQ__Quote__c qouteObj = new SBQQ__Quote__c();
        qouteObj.Contract_Term_Years__c = '1';
        qouteObj.SBQQ__StartDate__c = system.today();
        qouteObj.SBQQ__EndDate__c = system.today();
        qouteObj.SBQQ__Opportunity2__c = instOfOppThird.Id;
        insert qouteObj;
        
       instOfOppThird.SBQQ__PrimaryQuote__c = qouteObj.Id;
       update instOfOppThird;
         
       
        
        
        
        Implementation_Survey__c implementSurvey = new Implementation_Survey__c();
        implementSurvey.Quote__c = qouteObj.Id;
        implementSurvey.Opportunity__c=instOfOppThird.Id;
        implementSurvey.Account__c = instofAcc.id;
        implementSurvey.Seed_Account__c = 'Full Seed';
        implementSurvey.Specify_data_center_for_implementation__c='Override Default Location';
        insert implementSurvey;
        
        implementSurvey.Specify_data_center_for_implementation__c='Default based on Customer\'s Bill To';
        implementSurvey.Tax_Exempt__c = 'Yes';
        implementSurvey.Seed_Account__c = 'Cvent Payment Services';
        update implementSurvey;
        
    }
}