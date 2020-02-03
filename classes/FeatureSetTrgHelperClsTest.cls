/**
//////////////////////////////////////
//      @author Abhishek Pandey     //
/////////////////////////////////////
Version :   1.0
Date : 6th Jan 2015
Description : To test FeatureSetTrgHelperCls
*/
@isTest
//(seeAllData= True)
private class FeatureSetTrgHelperClsTest {
    
    public static Feature__c instOfFeat = new Feature__c();
    static{
        instOfFeat.Assignment__c = 'Milestone';
        instOfFeat.Picklist_Values__c = 'Data Entry Test';
        instOfFeat.Name = '1000';
        insert instOfFeat;
        
        FeatureSetsForOnsiteProj__c instOfFeatSet =  new FeatureSetsForOnsiteProj__c();
        instOfFeatSet.Name = 'Lead Capture Test';
        insert instOfFeatSet;
        
        instOfFeatSet =  new FeatureSetsForOnsiteProj__c();
        instOfFeatSet.Name = 'Lead Capture (Direct to exhibitr)';
        insert instOfFeatSet;
        
        instOfFeatSet =  new FeatureSetsForOnsiteProj__c();
        instOfFeatSet.Name = 'OA360 Test';
        insert instOfFeatSet;
        
    }
    static testMethod void myUnitTest() {
        
        Account instofAcc = TestUtil.createAccount('Test Account','Biz_Ac');
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        insert instofAcc;
        
        Contact instofCon =  TestUtil.createContact(String.valueOf(instofAcc.Id));
        instOfCon.Creation_Source_System__c = 'test';
        insert instOfCon;
        
        Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true);
        insert pbk1;
        
        Product2 prd1 = new Product2 (Name='Data Entry Test',Description='Test Product Entry 1',productCode = 'ABC', isActive = true);
        insert prd1;
        
        //get standard pricebook
        //Pricebook2  standardPb = [select id, name, isActive from Pricebook2 where IsStandard = true limit 1];
        
        Id pricebookId = Test.getStandardPricebookId();
        
        /*PricebookEntry standPriceBook= new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=pricebookId,UnitPrice=50, isActive=true);
insert standPriceBook;*/
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=pricebookId,UnitPrice=50, isActive=true);
        insert pbe1;
        
        test.startTest();
        Opportunity instOfOppThird  = TestUtil.createOpportunityNew('test','Verbal',instofCon.Id,instofAcc.Id);
        instOfOppThird.CurrencyIsoCode='USD';
        instOfOppThird.Product__c ='Survey';
        instOfOppThird.New_Type__c ='Upsell-NBB';
        instOfOppThird.New_Amount__c = 11;
        instOfOppThird.Years__c= '1';
        instOfOppThird.LeadSource = 'ACD-PS';
        instOfOppThird.Contact_Associated__c = instOfCon.Id;
        instOfOppThird.Contract_Implemented__c = true;
        instOfOppThird.ContractReceived__c = system.today();
        instOfOppThird.Deal_Year__c = '1';
        instOfOppThird.Pricebook2Id = pbe1.Pricebook2Id;
        insert instOfOppThird;
        
        OpportunityLineItem  instofFeatSet = new OpportunityLineItem ();
        //instofFeatSet.Feature__c = 'Data Entry';
        instofFeatSet.OpportunityID = instOfOppThird.Id;
        instofFeatSet.PriceBookEntryID=pbe1.Id;
        instofFeatSet.quantity=4;
        instofFeatSet.Product__c='Event';
        //instofFeatSet.Product_Name__c='';
        instofFeatSet.totalprice=200;
        insert instofFeatSet;
        
        instofFeatSet.Tickets_Sold__c = 12;
        update instofFeatSet;  
         OpportunityLineItem oliQuery = [Select Id,Product__c,ReassignedFromOpportunityId__c,ProductCode,CurrencyIsoCode,NBB_Value__c,Product_Name__c,opportunityId,
                                        Product_Family__c from OpportunityLineItem where opportunityId =:instOfOppThird.Id limit 1][0];
        oliquery.Tickets_Sold__c=1;
        update oliquery;
        list<OpportunityLineItem> oli = new list<OpportunityLineItem>();
        oli.add(oliquery);
        FeatureSetTrgHelperCls ftset = new FeatureSetTrgHelperCls();
        ftset.OnBeforeInsert(oli);
        
        test.stopTest();
        // TO DO: implement unit test
    }
    /*static testMethod void myUnitTestSec() {

Profile p = [SELECT Id FROM Profile WHERE Name='Finance - Management']; 

User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
LocaleSidKey='en_US', ProfileId = p.Id, Enable_EBS_Sync__c=false,
TimeZoneSidKey='America/Los_Angeles', UserName='498798deploymentuser@cvent.com');

system.runAs(u){
Account instofAcc = new Account();
Id rtTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Biz A/c').getRecordTypeId();
instofAcc.Name = 'Test';
instofAcc.Supplier_Type__c = 'Venue';
instofAcc.Venue_Type__c = 'CVB';
instofAcc.RecordTypeId = rtTypeId;
insert instofAcc;

Contact instofCon =  new Contact();
instOfCon.LastName = 'Test';
instOfCon.AccountId = instofAcc.Id;
instOfCon.email = 'test@test.com';
instOfCon.Creation_Source_System__c = 'ROL test';
insert instOfCon;

Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true);
insert pbk1;

Product2 prd1 = new Product2 (Name='Lead Capture',Description='Test Product Entry 1',productCode = 'ABC', isActive = true);
insert prd1;

//get standard pricebook
//Pricebook2  standardPb = [select id, name, isActive from Pricebook2 where IsStandard = true limit 1];

Id pricebookId = Test.getStandardPricebookId();

PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=pricebookId,UnitPrice=50, isActive=true);
insert pbe1;


Opportunity instOfOppThird  = new Opportunity();
instOfOppThird.AccountId = instofAcc.id;
instOfOppThird.Name = 'Test';
instOfOppThird.Product__c = 'Event';
instOfOppThird.New_Type__c =  'Upsell-NBB';
instOfOppThird.StageName = 'Verbal';
instOfOppThird.CloseDate = system.today();
instOfOppThird.New_Amount__c = 11;
instOfOppThird.Years__c= '1';
instOfOppThird.LeadSource = 'ACD-PS';
instOfOppThird.Contact_Associated__c = instOfCon.Id;
instOfOppThird.Contact_Role__c = 'Primary User';
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

instofFeatSet.Product__c = 'OA360';
update instofFeatSet; 
test.stopTest();
delete instofFeatSet;

}
}*/
    
    static testMethod void OnBeforeInserttest() {
        test.startTest();
        
        Account instofAcc = TestUtil.createAccount('Test Account','Biz_Ac');
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        insert instofAcc;
        
        Contact instofCon =  TestUtil.createContact(String.valueOf(instofAcc.Id));
        instOfCon.Creation_Source_System__c = 'test';
        insert instOfCon;
        
        Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true);
        insert pbk1;
        
        Product2 prd1 = new Product2 (Name='Data Entry Test',Description='Test Product Entry 1',productCode = 'CV-SU-EC-EVT-WEBDESSUP', isActive = true);
        insert prd1;
        
        //get standard pricebook
        //Pricebook2  standardPb = [select id, name, isActive from Pricebook2 where IsStandard = true limit 1];
        
        Id pricebookId = Test.getStandardPricebookId();
        
        /*PricebookEntry standPriceBook= new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=pricebookId,UnitPrice=50, isActive=true);
insert standPriceBook;*/
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=pricebookId,UnitPrice=50, isActive=true);
        insert pbe1;
        
        Opportunity instOfOppThird  = TestUtil.createOpportunityNew('test','Closed Won - PreAcquisition',instofCon.Id,instofAcc.Id);
        instOfOppThird.CurrencyIsoCode='USD';
        instOfOppThird.Product__c ='Survey';
        instOfOppThird.New_Type__c ='Upsell-NBB';
        instOfOppThird.New_Amount__c = 11;
        instOfOppThird.Years__c= '1';
        instOfOppThird.LeadSource = 'ACD-PS';
        instOfOppThird.Contact_Associated__c = instOfCon.Id;
        instOfOppThird.Contract_Implemented__c = true;
        instOfOppThird.ContractReceived__c = system.today();
        instOfOppThird.Deal_Year__c = '1';
        instOfOppThird.Pricebook2Id = pbe1.Pricebook2Id;
        insert instOfOppThird;
        
        OpportunityLineItem  instofFeatSet = new OpportunityLineItem ();
        //instofFeatSet.Feature__c = 'Data Entry';
        instofFeatSet.OpportunityID = instOfOppThird.Id;
        instofFeatSet.PriceBookEntryID=pbe1.Id;
        instofFeatSet.quantity=4;
        //instofFeatSet.ProductCode='CV-SU-EC-EVT-WEBDESSUP';
        instOfFeatSet.NBB_Value__c=12.00;
        
        //instofFeatSet.Product_Name__c='';
        instofFeatSet.Product__c='Lead Capture Test';
        instofFeatSet.totalprice=200;
        
        insert instofFeatSet;
        
        
        
        /*For the beforeUpdateMethod FeatureSerTrgHelperCls*/
        
        OpportunityLineItem oliQuery = [Select Id,Product__c,ReassignedFromOpportunityId__c,ProductCode,CurrencyIsoCode,NBB_Value__c,Product_Name__c,opportunityId,
                                        Product_Family__c from OpportunityLineItem where opportunityId =:instOfOppThird.Id limit 1][0];
        
        
        map<id,OpportunityLineItem> oldMapValue = new map<id,OpportunityLineItem>();
        oldMapValue.put(instofFeatSet.Id, instofFeatSet);
        
        list<OpportunityLineItem> oliList = new list<OpportunityLineItem>();
        olilist.add(oliQuery);
        FeatureSetTrgHelperCls ftset = new FeatureSetTrgHelperCls();
        ftset.OnBeforeInsert(oliList);
        system.assert(oliQuery.Milestone_Check__c=True);
        
        oliquery.NBB_Value__c=14.00;
        oliQuery.Tickets_Sold__c = 12;
        oliQuery.ReassignedFromOpportunityId__c='test reference';
        update oliquery;
        map<id,OpportunityLineItem> NewmapValue = new map<id,OpportunityLineItem>();
        NewmapValue.put(oliquery.Id,oliquery);
        ftset.OnBeforeUpdate(newMapValue,oldmapValue);
        /*For RollupWebDesignSupportOnOpp*/
        set<id>oppId = new set<id>();
        oppId.add(oliquery.Id);
        FeatureSetTrgHelperCls.RollupWebDesignSupportOnOpp(oppId);
        test.stopTest();
        
    }
    static testMethod void Deletetest() {
        test.startTest();
        
        Account instofAcc = TestUtil.createAccount('Test Account','Biz_Ac');
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        insert instofAcc;
        
        Contact instofCon =  TestUtil.createContact(String.valueOf(instofAcc.Id));
        instOfCon.Creation_Source_System__c = 'test';
        insert instOfCon;
        
        Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true);
        insert pbk1;
        
        Product2 prd1 = new Product2 (Name='Data Entry Test',Description='Test Product Entry 1',productCode = 'CV-SU-EC-EVT-WEBDESSUP', isActive = true);
        insert prd1;
        
        //get standard pricebook
        //Pricebook2  standardPb = [select id, name, isActive from Pricebook2 where IsStandard = true limit 1];
        
        Id pricebookId = Test.getStandardPricebookId();
        
        /*PricebookEntry standPriceBook= new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=pricebookId,UnitPrice=50, isActive=true);
insert standPriceBook;*/
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=pricebookId,UnitPrice=50, isActive=true);
        insert pbe1;
        
        Opportunity instOfOppThird  = TestUtil.createOpportunityNew('test','Closed Won - PreAcquisition',instofCon.Id,instofAcc.Id);
        instOfOppThird.CurrencyIsoCode='USD';
        instOfOppThird.Product__c ='Survey';
        instOfOppThird.New_Type__c ='Upsell-NBB';
        instOfOppThird.New_Amount__c = 11;
        instOfOppThird.Years__c= '1';
        instOfOppThird.LeadSource = 'ACD-PS';
        instOfOppThird.Contact_Associated__c = instOfCon.Id;
        instOfOppThird.Contract_Implemented__c = true;
        instOfOppThird.ContractReceived__c = system.today();
        instOfOppThird.Deal_Year__c = '1';
        instOfOppThird.Pricebook2Id = pbe1.Pricebook2Id;
        insert instOfOppThird;
        
        OpportunityLineItem  instofFeatSet = new OpportunityLineItem ();
        //instofFeatSet.Feature__c = 'Data Entry';
        instofFeatSet.OpportunityID = instOfOppThird.Id;
        instofFeatSet.PriceBookEntryID=pbe1.Id;
        instofFeatSet.quantity=4;
        //instofFeatSet.ProductCode='CV-SU-EC-EVT-WEBDESSUP';
        instOfFeatSet.NBB_Value__c=12.00;
        
        //instofFeatSet.Product_Name__c='';
        instofFeatSet.Product__c='Lead Capture Test';
        instofFeatSet.totalprice=200;
        insert instofFeatSet;
        
        list<OpportunityLineItem> oliList = new list<OpportunityLineItem>();
        olilist.add(instofFeatSet);
        
        OpportunityLineItem oliQuery = [Select Id,Product__c,ProductCode,CurrencyIsoCode,NBB_Value__c,Product_Name__c,opportunityId,
                                        Product_Family__c from OpportunityLineItem where opportunityId =:instOfOppThird.Id limit 1][0];
        oliQuery.Tickets_Sold__c = 12;
        oliquery.ReassignedFromOpportunityId__c=instOfOppThird.id;
        update oliQuery;
        
        map<id,OpportunityLineItem> oldMapValue = new map<id,OpportunityLineItem>();
        oldMapValue.put(oliQuery.Id, oliQuery);
        
        FeatureSetTrgHelperCls ftset = new FeatureSetTrgHelperCls();
        ftset.OnAfterDelete(olilist,oldMapValue);
        
        test.stopTest();
        
    }
    static testMethod void AfterEventtest() {
        test.startTest();
       
        Account instofAcc = TestUtil.createAccount('Test Account','Biz_Ac');
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        insert instofAcc;
        
        Contact instofCon =  TestUtil.createContact(String.valueOf(instofAcc.Id));
        instOfCon.Creation_Source_System__c = 'test';
        insert instOfCon;
        
       Customer_Asset__c  cstAssetRec = new Customer_Asset__c();
       cstAssetRec.Account__c=instofAcc.Id;
        cstAssetRec.Asset_Status__c='Active';
        insert cstAssetRec;
        
         Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true);
        insert pbk1;

        Product2 prd1 = new Product2 (Name='Data Entry Test',Description='Test Product Entry 1',productCode = 'CV-SU-EC-EVT-WEBDESSUP', isActive = true);
        insert prd1;

        //get standard pricebook
        //Pricebook2  standardPb = [select id, name, isActive from Pricebook2 where IsStandard = true limit 1];
        
        Id pricebookId = Test.getStandardPricebookId();

        /*PricebookEntry standPriceBook= new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=pricebookId,UnitPrice=50, isActive=true);
        insert standPriceBook;*/

        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=pricebookId,UnitPrice=50, isActive=true);
        insert pbe1;

        Opportunity instOfOppThird  = TestUtil.createOpportunityNew('test','Closed Won - PreAcquisition',instofCon.Id,instofAcc.Id);
        instOfOppThird.CurrencyIsoCode='USD';
        instOfOppThird.Product__c ='Survey';
        instOfOppThird.New_Type__c ='Upsell-NBB';
        instOfOppThird.New_Amount__c = 11;
        instOfOppThird.Years__c= '1';
        instOfOppThird.LeadSource = 'ACD-PS';
        instOfOppThird.Contact_Associated__c = instOfCon.Id;
        instOfOppThird.Contract_Implemented__c = true;
        instOfOppThird.ContractReceived__c = system.today();
        instOfOppThird.Deal_Year__c = '1';
        instOfOppThird.Pricebook2Id = pbe1.Pricebook2Id;
        insert instOfOppThird;
        
        OpportunityLineItem  instofFeatSet = new OpportunityLineItem ();
        //instofFeatSet.Feature__c = 'Data Entry';
        instofFeatSet.OpportunityID = instOfOppThird.Id;
        instofFeatSet.PriceBookEntryID=pbe1.Id;
        instofFeatSet.quantity=4;
         //instofFeatSet.ProductCode='CV-SU-EC-EVT-WEBDESSUP';
         instOfFeatSet.NBB_Value__c=12.00;
         instOfFeatSet.ReassignedFromOpportunityId__c ='testReference';
         //instofFeatSet.Product_Name__c='';
        instofFeatSet.Product__c='Lead Capture Test';
        instofFeatSet.totalprice=200;
        insert instofFeatSet;

         
        OpportunityLineItem oliQuery = [Select Id,Product__c,ReassignedFromOpportunityId__c,ProductCode,CurrencyIsoCode,NBB_Value__c,Product_Name__c,opportunityId,
                                        Product_Family__c from OpportunityLineItem where opportunityId =:instOfOppThird.Id limit 1][0];
        oliQuery.Tickets_Sold__c = 12;
        update oliQuery;
         
         map<id,OpportunityLineItem> oldMapValue = new map<id,OpportunityLineItem>();
         oldMapValue.put(oliQuery.Id, oliQuery);
         
        list<OpportunityLineItem> oliList = new list<OpportunityLineItem>();
        olilist.add(oliQuery);
         map<id,OpportunityLineItem> NewmapValue = new map<id,OpportunityLineItem>();
         NewmapValue.put(oliquery.Id,oliquery);
         FeatureSetTrgHelperCls ftset = new FeatureSetTrgHelperCls();
     ftset.OnAfterInsert(NewmapValue);
        test.stopTest();
 
 }
    static testMethod void updateReportingClassificationTest() {
        test.startTest();
       
        Account instofAcc = TestUtil.createAccount('Test Account','Biz_Ac');
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        insert instofAcc;
        
        Contact instofCon =  TestUtil.createContact(String.valueOf(instofAcc.Id));
        instOfCon.Creation_Source_System__c = 'test';
        insert instOfCon;
        
        Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true);
        insert pbk1;

        Product2 prd1 = new Product2 (Name='Data Entry Test',Description='Test Product Entry 1',productCode = 'CV-SU-EC-EVT-WEBDESSUP', isActive = true);
        prd1.Family='Event';
        insert prd1;
        
       Customer_Asset__c  cstAssetRec = new Customer_Asset__c();
       cstAssetRec.Account__c=instofAcc.Id;
        cstAssetRec.Asset_Status__c='Active';
        cstAssetRec.Product__c=prd1.Id;
        //cstAssetRec.Product_Family__c='Event';
    insert cstAssetRec;
        
        Customer_Asset__c csRec = [select Id ,Asset_Status__c,Product__c,Product_Family__c 
                                   from Customer_Asset__c where Product__c=:prd1.Id limit 1][0];
        
        csRec.Name__c='TestName';
        update csRec;
        

        //get standard pricebook
        //Pricebook2  standardPb = [select id, name, isActive from Pricebook2 where IsStandard = true limit 1];
        
        Id pricebookId = Test.getStandardPricebookId();

        /*PricebookEntry standPriceBook= new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=pricebookId,UnitPrice=50, isActive=true);
        insert standPriceBook;*/

        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=pricebookId,UnitPrice=50, isActive=true);
        insert pbe1;

        Opportunity instOfOppThird  = TestUtil.createOpportunityNew('Test Opp 2','Closed Won - PreAcquisition',instofCon.Id,instofAcc.Id);
        instOfOppThird.CurrencyIsoCode='USD';
        instOfOppThird.Product__c ='Survey';
        instOfOppThird.New_Type__c ='Upsell-NBB';
        instOfOppThird.New_Amount__c = 11;
        instOfOppThird.Years__c= '1';
        instOfOppThird.LeadSource = 'ACD-PS';
        instOfOppThird.Contract_Implemented__c = true;
        instOfOppThird.ContractReceived__c = system.today();
        instOfOppThird.Deal_Year__c = '1';
        instOfOppThird.Pricebook2Id = pbe1.Pricebook2Id;
        insert instOfOppThird;
    //Sbqq quote insertion
    SBQQ__Quote__c sbqq = new SBQQ__Quote__c();
                sbqq.SBQQ__Opportunity2__c = instOfOppThird.id;
                sbqq.Contract_Term_Years__c = '1';
                insert sbqq;
    
        
        OpportunityLineItem  instofFeatSet = new OpportunityLineItem ();
        //instofFeatSet.Feature__c = 'Data Entry';
        instofFeatSet.OpportunityID = instOfOppThird.Id;
        instofFeatSet.PriceBookEntryID=pbe1.Id;
        instofFeatSet.quantity=4;
        //instofFeatSet.Product_Family__c='TestFamily';
         //instofFeatSet.ProductCode='CV-SU-EC-EVT-WEBDESSUP';
         instOfFeatSet.NBB_Value__c=12.00;
         instOfFeatSet.ReassignedFromOpportunityId__c ='testReference';
         //instofFeatSet.Product_Name__c='';
        instofFeatSet.Product__c='Lead Capture Test';
        instofFeatSet.totalprice=200;
        insert instofFeatSet;

         
        OpportunityLineItem oliQuery = [Select Id,Product__c,NBB_Cross_Sell__c,NBB_Upsell__c,ReassignedFromOpportunityId__c,ProductCode,CurrencyIsoCode,NBB_Value__c,Product_Name__c,opportunityId,
                                        Product_Family__c from OpportunityLineItem where opportunityId =:instOfOppThird.Id limit 1][0];
        oliQuery.Tickets_Sold__c = 12;
        update oliQuery;
         map<id,OpportunityLineItem> oldMapValue = new map<id,OpportunityLineItem>();
         oldMapValue.put(oliQuery.Id, oliQuery);
         
        list<OpportunityLineItem> oliList = new list<OpportunityLineItem>();
        olilist.add(oliQuery);
         map<id,OpportunityLineItem> NewmapValue = new map<id,OpportunityLineItem>();
         NewmapValue.put(oliquery.Id,oliquery);
         FeatureSetTrgHelperCls ftset = new FeatureSetTrgHelperCls();
        //ftset.updateReportingClassification(oliList);
    
        test.stopTest();
 
 }
}