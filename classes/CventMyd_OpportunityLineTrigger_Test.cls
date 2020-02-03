@isTest
private class CventMyd_OpportunityLineTrigger_Test {

    public static testMethod void getOliCoverage() {

        Product2 prd1 = new Product2 (Name='Data Entry Test',Description='Test Product Entry 1',productCode = 'CV-SU-EC-EVT-WEBDESSUP', isActive = true);
        insert prd1;

        Account instofAcc = TestUtil.createAccount('Test Account','Biz_Ac');
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        insert instofAcc;

        Id pricebookId = Test.getStandardPricebookId();

        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=pricebookId,UnitPrice=50, isActive=true);
        insert pbe1;

        Contact instofCon =  TestUtil.createContact(String.valueOf(instofAcc.Id));
        instOfCon.Creation_Source_System__c = 'ROL test';
        insert instOfCon;

        Opportunity instOfOppThird  = TestUtil.createOpportunityNew('Test Opportunity','Verbal',instOfCon.Id,instofAcc.Id);
        instOfOppThird.Product__c = 'Event';
        instOfOppThird.New_Type__c =  'Upsell-NBB';
        instOfOppThird.StageName = 'Verbal';
        instOfOppThird.New_Amount__c = 11;
        instOfOppThird.Years__c= '1';
        instOfOppThird.LeadSource = 'ACD-PS';
        instOfOppThird.Contract_Implemented__c = true;
        instOfOppThird.ContractReceived__c = system.today();
        instOfOppThird.Deal_Year__c = '1';
        instOfOppThird.Pricebook2Id = pbe1.Pricebook2Id;
        test.startTest();
        insert instOfOppThird;


        OpportunityLineItem  instofFeatSet = new OpportunityLineItem ();
        //instofFeatSet.Feature__c = 'Data Entry';
        instofFeatSet.OpportunityID = instOfOppThird.Id;
        instofFeatSet.PriceBookEntryID=pbe1.Id;
        instofFeatSet.Product__c = 'Lead Capture';
        instofFeatSet.quantity=4;
        instofFeatSet.totalprice=200;

        insert instofFeatSet;
        
        update instOfFeatset;
        
        delete instOfFeatset;

    }

}