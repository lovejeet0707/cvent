/**
//////////////////////////////////////
//      @author Abhishek Pandey     //
/////////////////////////////////////
Version :   1.0
Date : 27th June 2014
Version : 2.0
Date : 18th Jan 2016
Description: changes for clubbed opportunity
Modified:  30 May 2018 : Kumud: Remove the Event venue,country,state,city, as a field cleanup activity.
 */

@isTest
//(seeAllData = True)
private class OpportunityTrgHelperClsTest {
    public static Account instofAcc;
    public static BillingCase__c billCase = new BillingCase__c();
    public static Contact instOfCon;
    public static Multi_Property_Bundles__c instOfMulPropBund =  new Multi_Property_Bundles__c();
    public static Multi_Property_Bundles__c instOfMulPropBund_New =  new Multi_Property_Bundles__c();//Code Added
    public static Multi_Property_Bundles__c instOfMulPropBundSec =  new Multi_Property_Bundles__c();
    public static List<Multi_Property_Bundles__c> lstMPB = new List<Multi_Property_Bundles__c>();
    public static List<Multi_Property_Bundles__c> lstMPB_New = new List<Multi_Property_Bundles__c>();//Code Added
    public static RRATracker__c rRATracker;
    public static TrackUser__c trackUser;
    public static HybridPicklistValue__c hybridPickList;
    //public static Opportunity instOfOppFIF;
    public static Superuser__c superUSer;
    static{
        
        billCase.CVII_Number__c = '1231231231';
        billCase.Name = 'Billing Case Test';
        insert billCase;
        
        instofAcc = TestUtil.createAccount('Test Account','Biz_Ac');
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        instofAcc.CVII_ID__c = '1231231231';
        instofAcc.Billing_Case__c = billCase.Id;
        insert instofAcc;
        
        instOfMulPropBund.Name = 'Test';
        //instOfMulPropBund.MSA_Code__c = '9999e';
        insert instOfMulPropBund;
        
        instOfMulPropBundSec.Name = 'Test';
        //instOfMulPropBundSec.MSA_Code__c = '2222e';
        insert instOfMulPropBundSec;
        
        lstMPB = [SELECT Id,MSA_Code__c FROM Multi_Property_Bundles__c WHERE Id =: instOfMulPropBund.Id OR  ID =: instOfMulPropBundSec.Id];
        system.debug('instOfMulPropBund.MSA_Code__cSTAT+++'+lstMPB[0].MSA_Code__c);
        system.debug('instOfMulPropBundSec.MSA_Code__cATAT+++'+lstMPB[0].MSA_Code__c);
        
        //Code Added By Hemant
        instOfMulPropBund_New.Name = 'Test_New';
        insert instOfMulPropBund_New;
        
        lstMPB_New=[SELECT Id,MSA_Code__c FROM Multi_Property_Bundles__c WHERE Id =: instOfMulPropBund_New.Id];
        instOfCon = TestUtil.createContact(String.valueOf(instofAcc.Id));
        insert instOfCon;
        
        HybridPicklistValue__c instOfHydPLV = new HybridPicklistValue__c();
        instOfHydPLV.HybridValue__c = 'Custom Work SLM';
        instOfHydPLV.Name = '1000';
        insert instOfHydPLV;
        
        instOfHydPLV = new HybridPicklistValue__c();
        instOfHydPLV.HybridValue__c = 'Diamond Plus';
        instOfHydPLV.Name = '2000';
        insert instOfHydPLV;
        
        instOfHydPLV = new HybridPicklistValue__c();
        instOfHydPLV.HybridValue__c = ' Diamond Plus SLM';
        instOfHydPLV.Name = '3000';
        insert instOfHydPLV;
        
        Feature__c instOfFeat = new Feature__c();
        instOfFeat.Assignment__c = 'Straightline';
        instOfFeat.Picklist_Values__c = '# of Registrationss';
        instOfFeat.Name = '1000';
        insert instOfFeat;
        
        Feature__c instOfFeatSec = new Feature__c();
        instOfFeatSec.Assignment__c = 'Milestone';
        instOfFeatSec.Picklist_Values__c = '# of Registrations Mils';
        instOfFeatSec.Name = '2000';
        insert instOfFeatSec;
        
        List<Probability__c> listOfProb=new List<Probability__c>();
        Probability__c probabilityObj= new Probability__c();
        probabilityObj.Name='test00';
        probabilityObj.License_Type__c='Diamond';
        probabilityObj.Probability__c=60;
        probabilityObj.Product__c='Event';
        probabilityObj.StageName__c='Up for Renewal';
        listOfProb.add(probabilityObj);
        probabilityObj= new Probability__c();
        probabilityObj.Name='2';
        probabilityObj.NBB_Renewal__c='Test';
        probabilityObj.Probability__c=20;
        probabilityObj.Product__c='Event';
        probabilityObj.StageName__c='At Risk';
        listOfProb.add(probabilityObj);
        
        probabilityObj= new Probability__c();
        probabilityObj.Name='3';
        probabilityObj.Probability__c=20;
        probabilityObj.Product__c='Event';
        probabilityObj.StageName__c='At Risk';
        listOfProb.add(probabilityObj);
        insert listOfProb;
        
        Cancellation_Categorization__c instOfCanCat = new Cancellation_Categorization__c();
        instOfCanCat.Type__c = 'Type 1';
        instOfCanCat.Name = 'Bad Debts';
        insert instOfCanCat;
        
        instOfCanCat = new Cancellation_Categorization__c();
        instOfCanCat.Type__c = 'Type 2';
        instOfCanCat.Name = 'Billing Errors';
        insert instOfCanCat;
        
        instOfCanCat = new Cancellation_Categorization__c();
        instOfCanCat.Type__c = 'Type 3';
        instOfCanCat.Name = 'Withhold Tax Cancellations';
        insert instOfCanCat;
        
        instOfCanCat = new Cancellation_Categorization__c();
        instOfCanCat.Type__c = 'Type 1';
        instOfCanCat.Name = 'Dissatisfactions';
        insert instOfCanCat;
        
        instOfCanCat = new Cancellation_Categorization__c();
        instOfCanCat.Type__c = 'Type 1';
        instOfCanCat.Name = 'Flagged For Revenues';
        insert instOfCanCat;
        
        Cancellation_Assignments__c instOfCanAss = new Cancellation_Assignments__c();
        instOfCanAss.Username__c = 'Abhishek Pandey';
        instOfCanAss.Product__c = 'Event';
        instOfCanAss.UserId__c = UserInfo.getUserId();
        instOfCanAss.Review_Level__c = 'AccLevel1';
        instOfCanAss.Name = '1000';
        insert instOfCanAss;
        
        instOfCanAss = new Cancellation_Assignments__c();
        instOfCanAss.Username__c = 'Abhishek Pandey';
        instOfCanAss.Product__c = 'Event';
        instOfCanAss.UserId__c = UserInfo.getUserId();
        instOfCanAss.Review_Level__c = 'AccLevel2';
        instOfCanAss.Name = '2000';
        insert instOfCanAss;
        
        instOfCanAss = new Cancellation_Assignments__c();
        instOfCanAss.Username__c = 'Abhishek Pandey';
        instOfCanAss.Product__c = 'Event';
        instOfCanAss.UserId__c = UserInfo.getUserId();
        instOfCanAss.Review_Level__c = 'Hybrid';
        instOfCanAss.Name = '3000';
        insert instOfCanAss;
        
        instOfCanAss = new Cancellation_Assignments__c();
        instOfCanAss.Username__c = 'Abhishek Pandey';
        instOfCanAss.UserId__c = UserInfo.getUserId();
        instOfCanAss.Review_Level__c = 'Tax';
        instOfCanAss.Name = '4000';
        insert instOfCanAss;
        
        instOfCanAss = new Cancellation_Assignments__c();
        instOfCanAss.Username__c = 'Abhishek Pandey';
        instOfCanAss.Type_Of_Cancellation__c = 'Implementation Error';
        instOfCanAss.UserId__c = UserInfo.getUserId();
        instOfCanAss.Review_Level__c = 'Review Team';
        instOfCanAss.Name = '5000';
        insert instOfCanAss;
        createCustomSetting('110','110','110','110','Event');
        createCustomSetting('220','220','220','220','CrowdCompass');
        createCustomSetting('330','230','230','230','CSN');
        
        //added by kumud on 30/05/18
        UserAssignment__c instUA = new UserAssignment__c();
        instUA.Name = 'OnArrival';
        instUA.User_id__c = userinfo.getUserID();
        instUA.UserName__c = 'Brett Wischow';
        insert instUA;
        
        //added by kumud on 30/05/18
        FeatureSetsForOnsiteProj__c instFS = new FeatureSetsForOnsiteProj__c();
        instFS.Name = 'testF';
        insert instFS;
    }
    static List<PricebookEntry> createPricebookEntry(){
        //create Product and PriceBook
        List<Product2> prodList= new List<Product2>();

        Product2 prd1 = new Product2 ();

        prd1 = new Product2 ();
        prd1.Name='DG - Creative Services';
        prd1.Description='Test Product Entry 1';
        prd1.productCode = 'ABC';
        prd1.isActive = true;
        prodList.add(prd1);

        prd1 = new Product2 ();
        prd1.Name='Supplier Feature-Meeting Request Form';
        prd1.Description='Test Product Entry 1';
        prd1.productCode = 'ABC';
        prd1.isActive = true;
        prodList.add(prd1);

        prd1 = new Product2 ();
        prd1.Name='Booster-Comp Set';
        prd1.Description='Test Product Entry 1';
        prd1.productCode = 'ABC';
        prd1.isActive = true;
        prodList.add(prd1);

        insert prodList;

        Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 0',Description='Test Pricebook Entry 1', isActive=true);
        insert pbk1;

        //get standard pricebook
        //Pricebook2  standardPb = [select id, name, isActive from Pricebook2 where IsStandard = true limit 1];
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standPriceBook= new PricebookEntry ();
        List<PricebookEntry> stndpricebookEntryList= new List<PricebookEntry>();
        List<PricebookEntry> pricebookEntryList= new List<PricebookEntry>();
        For(Integer i=0; i<prodList.size() ; i++)
        {
            standPriceBook= new PricebookEntry ();
            standPriceBook.Product2ID=prodList[i].id;
            standPriceBook.Pricebook2ID=pricebookId;//standardPb.id;
            standPriceBook.UnitPrice=50;
            standPriceBook.isActive=true;
            stndpricebookEntryList.add(standPriceBook);
        }
        System.debug('stndpricebookEntryList************'+stndpricebookEntryList);
        insert stndpricebookEntryList;

        //Inserting PriceBookEntry.........................
        PricebookEntry pbe1 = new PricebookEntry ();
        For(Integer i=0; i<prodList.size() ; i++)
        {
            pbe1 = new PricebookEntry ();
            pbe1.Product2ID=prodList[i].id;
            pbe1.Pricebook2ID=pbk1.id;
            pbe1.UnitPrice=50;
            pbe1.isActive=true;
            pricebookEntryList.add(pbe1);
        }

        insert pricebookEntryList;
        System.debug('pricebookEntryList************'+pricebookEntryList);
        return pricebookEntryList;
    }
    static Contract instContract;
    static Opportunity instOfMasterOpp;
    static Opportunity instClosedWonOpty;
    static {
        
        RecordType instOfRecType = [SELECT Id FROM RecordType WHERE SobjectType='Opportunity' And DeveloperName='Event' And IsActive=true];
        instOfMasterOpp = TestUtil.createOpportunityNew('Test Opportunity','Tract',instOfCon.Id,instofAcc.Id);
        instOfMasterOpp.Contract_Type_Test__c = 'Renewal';
        instOfMasterOpp.Forex_rate__c = 1;
        instOfMasterOpp.License_Type__c = 'Diamond Plus';
        instOfMasterOpp.Liquidation_Fee__c  = 10;
        instOfMasterOpp.OptOutDate__c = system.today();
        instOfMasterOpp.Opp_End_Date__c  = system.today();
        instOfMasterOpp.Forex_rate__c = 1;
       // instOfMasterOpp.Price_per_lead__c = 1;
        instOfMasterOpp.Counted_sales_Cancellation_Value__c =110;
        instOfMasterOpp.Product__c = 'Event';
        instOfMasterOpp.Team__c = 'BD'; 
        instOfMasterOpp.Product_Category__c = null; 
        instOfMasterOpp.Contract_Number_New__c = '25512';
        instOfMasterOpp.New_Type__c =  'Upsell-NBB';
        instOfMasterOpp.Parent_Upsell__c = 'Upsell';
        instOfMasterOpp.Parent_Contract_Number__c = 123;
        instOfMasterOpp.Contract_Implemented__c = false;
        instOfMasterOpp.CloseDate = system.today();
        instOfMasterOpp.RecordTypeId = instOfRecType.Id;
        instOfMasterOpp.Year_1_at_Risk__c = 11;
        instOfMasterOpp.New_Type__c = 'Test';
        instOfMasterOpp.Deal_Booked_In__c = '5';
        //instOfMasterOpp.Price_per_lead__c = 1;
        instOfMasterOpp.Years__c= '1';
        instOfMasterOpp.LeadSource = 'ACD-PS';
        instOfMasterOpp.Contact_Role__c = 'Executive Sponsor';
        instOfMasterOpp.MSA_Code__c = instOfMulPropBund.MSA_Code__c;
        instOfMasterOpp.ContractReceived__c = system.today();
        instOfMasterOpp.Deal_Year__c = '1';
        instOfMasterOpp.MaintenanceFee__c = 1000;
        instOfMasterOpp.New_Amount__c = 1000;
        //instOfMasterOpp.Discount__c = 1000;
        instOfMasterOpp.Convinience_Fee__c = 1000;
        instOfMasterOpp.of_Leads_Purchased__c = 1000;
        //instOfMasterOpp.Events__c = 1000;
        instOfMasterOpp.Price_Adjustment__c = 1000;
        instOfMasterOpp.MYD_Deal__c = 'First Year';
        instOfMasterOpp.Clubbed_Opportunity__c = true;
        //instOfMasterOpp.Clubbed_Tract_Billing_Account__c = 'abcd1234';
        instOfMasterOpp.ATI_Check__c=true;
        instOfMasterOpp.Pricebook2Id = Test.getStandardPricebookId();
        instOfMasterOpp.Event_Name__c ='evnt';
        instOfMasterOpp.CurrencyIsoCode = 'USD';
        instOfMasterOpp.Set_Cancellation_Status__c = 'Edit Only';
        
        insert instOfMasterOpp;
        
        instContract=TestUtil.CreateContract(instofAcc,instOfMasterOpp.id);
        insert instContract;
        
        instClosedWonOpty = TestUtil.createOpportunityNew('Test Opportunity','Closed Won',instOfCon.Id,instofAcc.Id);
        //instOfOpp.Opportunity_Start_Date__c = system.today();
        instClosedWonOpty.License_Type__c = 'Diamond Plus';
        instClosedWonOpty.Contract_Type_Test__c = 'Renewal';
        instClosedWonOpty.Counted_sales_Cancellation_Value__c =110;
        instClosedWonOpty.Liquidation_Fee__c  = 10;
        instClosedWonOpty.OptOutDate__c = system.today();
        instClosedWonOpty.Opp_End_Date__c  = system.today();
        instClosedWonOpty.Product__c = 'CrowdCompass';
        instClosedWonOpty.Contract_Number_New__c = '255126';
        instClosedWonOpty.New_Type__c =  'Upsell-NBB';
        instClosedWonOpty.CloseDate = system.today();
        //instClosedWonOpty.RecordTypeId = recTypeId;
        instClosedWonOpty.Year_1_at_Risk__c = 11;
        instClosedWonOpty.New_Type__c = 'Test';
        instClosedWonOpty.Deal_Booked_In__c = 'UK Books';
       // instClosedWonOpty.Price_per_lead__c = 1;
        instClosedWonOpty.Years__c= '1';
        instClosedWonOpty.LeadSource = 'ACD-PS';
        instClosedWonOpty.MSA_Code__c = instOfMulPropBund.MSA_Code__c;
        instClosedWonOpty.ContractReceived__c = system.today();
        //instClosedWonOpty.Deal_Year__c = '1';
        instClosedWonOpty.MYD_Deal__c = 'First Year';
        instClosedWonOpty.Deal_Year__c = '1';
        instClosedWonOpty.New_Amount__c = 1000;
        instClosedWonOpty.Parent_Upsell__c = 'Primary';
      //  instClosedWonOpty.Send_This_To_Tract__c = true;        
        instClosedWonOpty.Forex_rate__c = 1;
       // instClosedWonOpty.Price_per_lead__c = 1;
        instClosedWonOpty.Clubbed_Opportunity__c = true;
       // instClosedWonOpty.Clubbed_Tract_Billing_Account__c = 'abcd1234';
        instClosedWonOpty.License_Type__c = '1/2 Diamond';
        instClosedWonOpty.ContractEndDate__c = system.today();
        instClosedWonOpty.recordtypeID=instOfRecType.id;
        //instClosedWonOpty.TRACT2__Tract_Sales_Order__c='179';
        instClosedWonOpty.Pricebook2Id = Test.getStandardPricebookId();
        instClosedWonOpty.Event_Name__c ='Test';
        instClosedWonOpty.CurrencyIsoCode = 'USD';
       
        insert instClosedWonOpty;
      
    }
    static testMethod void AmendedcontractTest(){
        RecordType instOfRecType = [SELECT Id FROM RecordType WHERE SobjectType='Opportunity' And DeveloperName='Event' And IsActive=true];
        List<Opportunity> listOpp=new List<Opportunity>();
        Test.StartTest();
            
            Opportunity instOfOpp = TestUtil.createOpportunityNew('Test Opportunity','Verbal',instOfCon.Id,instofAcc.Id);
            instOfOpp.recordtypeID=instOfRecType.id;
            instOfOpp.Product__c = 'Event';
            instOfOpp.Product_Category__c='';
            instOfOpp.New_Type__c =  'Upsell-NBB';
            instOfOpp.CloseDate = system.today()-5;
            instOfOpp.New_Amount__c = 11;
            instOfOpp.Years__c= '1';
            instOfOpp.LeadSource = 'ACD-PS';
            instOfOpp.MSA_Code__c = lstMPB[0].MSA_Code__c;
            instOfOpp.Contract_Implemented__c = true;
            instOfOpp.ContractReceived__c = system.today();
            instOfOpp.Deal_Year__c = '1';
            instOfOpp.SBQQ__AmendedContract__c=instContract.id;
            instOfOpp.Federal_Tax_Id__c='ID 1233';
            instOfOpp.Mobile_App_Version__c='mobilr 1233';
            instOfOpp.AM_CSN__c='amnr 1233';
            instOfOpp.CVII_Contract_Number__c='1233';
            listOpp.add(instOfOpp);
            insert listOpp;
            instOfOpp.stagename='Closed Won';
            instOfOpp.Contact_Role__c='Influencer';
            update instOfOpp;
        Test.StopTest();        
    }
    static testmethod void RenewedcontractTest(){
        
        List<Opportunity> listOpp=new List<Opportunity>();
        Test.StartTest();
            Opportunity instOfOpp = TestUtil.createOpportunityNew('Test Opportunity','Verbal',instOfCon.Id,instofAcc.Id);
            instOfOpp.Product__c = 'Event';
            instOfOpp.New_Type__c =  'Upsell-NBB';
            instOfOpp.CloseDate = system.today();
            instOfOpp.New_Amount__c = 11;
            instOfOpp.Years__c= '1';
            instOfOpp.LeadSource = 'ACD-PS';
            instOfOpp.MSA_Code__c = lstMPB[0].MSA_Code__c;
            instOfOpp.Contract_Implemented__c = true;
            instOfOpp.ContractReceived__c = system.today();
            instOfOpp.Deal_Year__c = '1';
            instOfOpp.SBQQ__RenewedContract__c=instContract.id;
            
            listOpp.add(instOfOpp);
            
           
            insert listOpp;
            
            instOfOpp.stagename='Closed Won';
            instOfOpp.Contact_Role__c='Decision Maker';
            update instOfOpp;
        Test.StopTest();    
    }
    static testMethod void test()
    {
        
        
        Test.StartTest();
            Opportunity instOfOpp = TestUtil.createOpportunityNew('Test Opportunity','Verbal',instOfCon.Id,instofAcc.Id);
            instOfOpp.Product__c = 'Event';
            instOfOpp.New_Type__c =  'Upsell-NBB';
            instOfOpp.CloseDate = system.today();
            instOfOpp.New_Amount__c = 11;
            instOfOpp.Years__c= '1';
            instOfOpp.LeadSource = 'ACD-PS';
            instOfOpp.MSA_Code__c = lstMPB[0].MSA_Code__c;
            instOfOpp.Contract_Implemented__c = true;
            instOfOpp.ContractReceived__c = system.today();
            instOfOpp.Deal_Year__c = '1';
            
            //instOfOpp.SBQQ__RenewedContract__c=instContract.id;
            //instOfOpp.SBQQ__AmendedContract__c=instContract.id;
            insert instOfOpp;
            
            instOfOpp.MSA_Code__c = lstMPB_New[0].MSA_Code__c;
            update instOfOpp;
            Delete instOfOpp;
            Database.undelete(instOfOpp.Id);
        Test.StopTest();
    }
    
        
    Public static void createCustomSetting(String name,String tractName,String superUserName,string hybridName,String prod){
        
        rRATracker=new RRATracker__c();
        rRATracker.name=name;
        rRATracker.RoundRobinId__c=0;
        rRATracker.User_Name__c= Userinfo.getName();
        insert rRATracker;
        
        // custom setting       
        trackUser =new TrackUser__c();
        trackUser.Name = tractName;
        trackUser.Name__c=Userinfo.getName();
        trackUser.Name_Level_2__c=Userinfo.getName();
        trackUser.Name_Level_3__c=Userinfo.getName();
        trackUser.Product_Name__c= prod;
        insert trackUser;
        
        superUSer=new Superuser__c();
        superUSer.name=superUserName;
        superUSer.SuperUserName__c= Userinfo.getName();
        insert superUSer;
        
       
        hybridPickList=new HybridPicklistValue__c();
        hybridPickList.name=hybridName;
        hybridPickList.HybridValue__c='Test';
        insert hybridPickList;
        
        TractLevel4User__C topLevelUSer=new TractLevel4User__C();
        topLevelUSer.name=name;
        topLevelUSer.name__C=Userinfo.getName();
        insert topLevelUSer;
        
        
    }
    
    static testMethod void myUnitTestSec() {
        DG_DFR_Class.DisableOnTest = true;
        RecordType instOfRecType = [SELECT Id FROM RecordType WHERE SobjectType='Opportunity' And DeveloperName='Event' And IsActive=true];
        
        List<Opportunity> lstOppIns = new List<Opportunity>();
        
        Opportunity instOfOpp = TestUtil.createOpportunityNew('Test Opportunity','Closed Won',instOfCon.Id,instofAcc.Id);
        //instOfOpp.Opportunity_Start_Date__c = system.today();
        instOfOpp.Contract_Type_Test__c = 'Renewal';
        instOfOpp.Liquidation_Fee__c  = 10;
        instOfOpp.Counted_sales_Cancellation_Value__c =110;
        instOfOpp.Forex_rate__c = 1;
      //  instOfOpp.Price_per_lead__c = 1;
        instOfOpp.OptOutDate__c = system.today();
        instOfOpp.Opp_End_Date__c  = system.today();
        instOfOpp.Product__c = 'Event';
        instOfOpp.Contract_Number_New__c = '25512';
        instOfOpp.New_Type__c =  'Upsell-NBB';
        instOfOpp.CloseDate = system.today();
        instOfOpp.RecordTypeId = instOfRecType.Id;
        instOfOpp.Year_1_at_Risk__c = 11;
        instOfOpp.New_Type__c = 'Test';
        instOfOpp.Deal_Booked_In__c = '1';
     //   instOfOpp.Price_per_lead__c = 1;
        instOfOpp.Years__c= '1';
        instOfOpp.LeadSource = 'ACD-PS';
        //instOfOpp.Contact_Associated__c = instOfCon.Id;
        instOfOpp.Contact_Associated__c = null;
        instOfOpp.Contact_Role__c = 'Decision Maker';
        instOfOpp.MSA_Code__c = instOfMulPropBund.MSA_Code__c;
        instOfOpp.Contract_Implemented__c = true;
        instOfOpp.ContractReceived__c = system.today();
        instOfOpp.Deal_Year__c = '1';
        instOfOpp.MYD_Deal__c = 'First Year';
        //instOfOpp.TRACT2__Tract_Sales_Order__c='1112';
        instOfOpp.MaintenanceFee__c = 1000;
        instOfOpp.New_Amount__c = 1000;
        //instOfOpp.Discount__c = 1000;
        instOfOpp.Convinience_Fee__c = 1000;
        instOfOpp.of_Leads_Purchased__c = 1000;
        //instOfOpp.Events__c = 1000;
        instOfOpp.Price_Adjustment__c = 1000;
        instOfOpp.Parent_Upsell__c = 'Upsell'; //added by kumud 30/05/18
        instOfOpp.Clubbed_Opportunity__c = true;
        //instOfOpp.Clubbed_Tract_Billing_Account__c = 'abcd1234';
        instOfOpp.Contract_Implemented__c = true; //added by kumud 30/05/18
        instOfOpp.Set_Cancellation_Status__c = ''; //added by kumud 30/05/18
        instOfOpp.ATI_Check__c=true;
        insert instOfOpp;
        
       
        Contract_Reviewing__c  cObj=new Contract_Reviewing__c ();
        cObj.Contract_Reviewer__c='Amit';
        cobj.Opportunity__C=instOfOpp.id;
        insert cobj;
        
        List<Feature_Set__c> lstFeatureSets = new List<Feature_Set__c>();
        
        
        test.startTest();
        
        Opportunity instOppSec = [SELECT Id,StageName,CloseDate FROM Opportunity WHERE Id =: instOfOpp.Id AND Deal_Year__c=:'1' AND Contract_Number_New__c=: '25512'];
        system.debug('StageName++++++'+instOppSec.StageName);
        system.debug('CloseDate++++++'+instOppSec.CloseDate);
        instOppSec.Contract_Implemented__c = true;
        instOppSec.CFC_Check__c = 'Test11';
        update instOppSec;
        
        test.stopTest();
        DG_DFR_Class.DisableOnTest = false;
    }
    





    
    //added by kumud
    static testMethod void OnBeforeUpdateTest() {
        
        
        CheckRecursive.runThir = true;
        
        Product2 prd1 = new Product2 (Name='DG - Creative Services',Description='Test Product Entry 1',productCode = 'ABC', isActive = true);
        insert prd1;

        //get standard pricebook
        //Pricebook2  standardPb = [select id, name, isActive from Pricebook2 where IsStandard = true limit 1];
        Id pricebookId = Test.getStandardPricebookId();

        /*PricebookEntry standPriceBook= new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=pricebookId,UnitPrice=50, isActive=true);
        insert standPriceBook;*/

        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,CurrencyIsoCode='USD',Pricebook2ID=priceBookId,UnitPrice=50, isActive=true);
        insert pbe1;
        Opportunity instOfOppFIF=instOfMasterOpp;
        
         
        TM_Fee_Structure__c instOfTm = new TM_Fee_Structure__c();
        instOfTm.Name = 'Test';
        instOfTm.Opportunity__c = instOfOppFIF.Id;
        insert instOfTm;
        Test.StartTest();
        OpportunityLineItem  instOfFSetForYearDGSecond = new OpportunityLineItem ();
        //instofFeatSet.Feature__c = 'Data Entry';
        instOfFSetForYearDGSecond.OpportunityID = instOfOppFIF.Id;
        instOfFSetForYearDGSecond.PriceBookEntryID=pbe1.Id;
        instOfFSetForYearDGSecond.Product__c = 'Lead Capture';
        instOfFSetForYearDGSecond.quantity=4;
        instOfFSetForYearDGSecond.totalprice=200;
        insert instOfFSetForYearDGSecond;
        
        instOfOppFIF.NBB_Renewal__c = 'Renewal';
        instOfOppFIF.License_Type__c = 'Basic';
        instOfOppFIF.Set_Cancellation_Status__c = 'Edit and Remove TRACT Order #';
        //instOfOppFIF.Alliance_Tech_CheckBox__c = true;
        instOfOppFIF.CurrencyIsoCode = 'USD';
        instOfOppFIF.CloseDate = system.today()-1;
        instOfOppFIF.StageName = 'Closed Won';
        instOfOppFIF.Contract_Implemented__c = true;
        update instOfOppFIF;
        
        Invoicing_Details__c instOfInvDet =  new Invoicing_Details__c();
        //instOfInvDet.Name = 'Tset';
        instOfInvDet.Opportunity__c  = instOfOppFIF.Id;
        instOfInvDet.Billing_POC__c = instOfCon.Id;
        insert instOfInvDet;
        
        Invoicing_Line_Items__c instOfILV = new Invoicing_Line_Items__c();
        instOfILV.Invoicing_Details__c = instOfInvDet.Id;
        instOfILV.Installment_description__c = 'Test';
        insert instOfILV;
        
        RecordType instOfRectypeMPB = [SELECT SobjectType, Name,developerName FROM RecordType WHERE SobjectType='Multi_Property_Bundles__c' AND DeveloperName = 'MSA'];
        
        Multi_Property_Bundles__c instOfMPB = new Multi_Property_Bundles__c();
        instOfMPB.RecordTypeId = instOfRectypeMPB.id;
        instOfMPB.Name = 'Test';
        insert instOfMPB;
        
        Test.stopTest();
    }
    
    static testMethod void myUnitTestFif() {
        updateDate__c instUD = new updateDate__c();
        instUD.Name = '1000';
        instUD.DateTimeFrom__c = system.now().adddays(-4);  
        instUD.DateTimeTo__c =  system.now().adddays(-1);
        insert instUD;
        RecordType instOfRecType = [SELECT Id FROM RecordType WHERE SobjectType='Opportunity' And DeveloperName='Event' And IsActive=true];
        
        
        Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 2',Description='Test Pricebook Entry 1', isActive=true);
        insert pbk1;

        Product2 prd1 = new Product2 (Name='DG - Creative Service',Description='Test Product Entry 1',productCode = 'ABC', isActive = true);
        insert prd1;

        //get standard pricebook
        //Pricebook2  standardPb = [select id, name, isActive from Pricebook2 where IsStandard = true limit 1];
        Id pricebookId = Test.getStandardPricebookId();
        
        /*PricebookEntry standPriceBook= new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=pricebookId,UnitPrice=50, isActive=true);
        insert standPriceBook;*/

        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=priceBookId,UnitPrice=50, isActive=true,currencyisocode='USD');
        insert pbe1;
        
        Opportunity instOfOppFIF=instOfMasterOpp;
       
        
        TM_Fee_Structure__c instOfTm = new TM_Fee_Structure__c();
        instOfTm.Name = 'Test';
        instOfTm.Opportunity__c = instOfOppFIF.Id;
        insert instOfTm;
        
        OpportunityLineItem  instOfFSetForYearDGSecond = new OpportunityLineItem ();
        //instofFeatSet.Feature__c = 'Data Entry';
        instOfFSetForYearDGSecond.OpportunityID = instOfOppFIF.Id;
        instOfFSetForYearDGSecond.PriceBookEntryID=pbe1.Id;
        //instOfFSetForYearDGSecond.Product__c = 'Lead Capture';
        instOfFSetForYearDGSecond.quantity=4;
        instOfFSetForYearDGSecond.totalprice=200;
        insert instOfFSetForYearDGSecond;
        
        //instOfOppFIF.stagename='Closed Won';
        //instOfOppFIF.Contact_Role__c='Decision Maker';
        instOfOppFIF.Contract_Implemented__c = true;
        update instOfOppFIF;
        
        Invoicing_Details__c instOfInvDet =  new Invoicing_Details__c();
        //instOfInvDet.Name = 'Tset';
        instOfInvDet.Opportunity__c  = instOfOppFIF.Id;
        instOfInvDet.Billing_POC__c = instOfCon.Id;
        insert instOfInvDet;
        
        Invoicing_Line_Items__c instOfILV = new Invoicing_Line_Items__c();
        instOfILV.Invoicing_Details__c = instOfInvDet.Id;
        instOfILV.Installment_description__c = 'Test';
        insert instOfILV;
        
        CSN_Credit__c instOfCsn = new CSN_Credit__c();
        insert instOfCsn;
        
        RecordType instOfRectypeMPB = [SELECT SobjectType, Name,developerName FROM RecordType WHERE SobjectType='Multi_Property_Bundles__c' AND DeveloperName = 'MSA'];
        
        Multi_Property_Bundles__c instOfMPB = new Multi_Property_Bundles__c();
        instOfMPB.RecordTypeId = instOfRectypeMPB.id;
        instOfMPB.Name = 'Test';
        insert instOfMPB;
        Test.StartTest();
        UpdateOppsTem instOfUCBOC = new UpdateOppsTem();
        Id bc = Database.executeBatch(instOfUCBOC);
        System.abortJob(bc);
        Test.stopTest();
    }
    static testMethod void myUnitTestSix() {
        RecordType instOfRecType = [SELECT Id FROM RecordType WHERE SobjectType='Opportunity' And DeveloperName='Event' And IsActive=true];
         /*.....................Cancellations_Super_Users__c record insert.............................*/               
        Cancellations_Super_Users__c cc= new Cancellations_Super_Users__c();        
        cc.Name = UserInfo.getUserId();     
        cc.Username__c = UserInfo.getUserName();        
        insert cc;      
        /*.............................ENDS HERE........................................*/
        Opportunity instOfOppSec = TestUtil.createOpportunityNew('Test Opportunity','Closed Won',instOfCon.Id,instofAcc.Id);
        //instOfOpp.Opportunity_Start_Date__c = system.today();
        instOfOppSec.License_Type__c = 'Diamond Plus';
        instOfOppSec.Contract_Type_Test__c = 'Renewal';
        instOfOppSec.Counted_sales_Cancellation_Value__c =110;
        instOfOppSec.Liquidation_Fee__c  = 10;
        instOfOppSec.OptOutDate__c = system.today();
        instOfOppSec.Opp_End_Date__c  = system.today();
        instOfOppSec.Product__c = 'CSN';
        instOfOppSec.Contract_Number_New__c = '25512';
        instOfOppSec.New_Type__c =  'Upsell-NBB';
        instOfOppSec.CloseDate = system.today();
        instOfOppSec.RecordTypeId = instOfRecType.Id;
        instOfOppSec.Year_1_at_Risk__c = 11;
        instOfOppSec.New_Type__c = 'Test';
        instOfOppSec.Deal_Booked_In__c = '1';
        instOfOppSec.Event_Name__c ='Event';
       // instOfOppSec.Price_per_lead__c = 1;
        instOfOppSec.Years__c= '1';
        instOfOppSec.LeadSource = 'ACD-PS';
       instOfOppSec.MSA_Code__c = instOfMulPropBund.MSA_Code__c;
        instOfOppSec.Contract_Implemented__c = true;
        instOfOppSec.ContractReceived__c = system.today();
        //instOfOppSec.Deal_Year__c = '1';
        instOfOppSec.MYD_Deal__c = 'First Year';
        instOfOppSec.Deal_Year__c = '2';
        instOfOppSec.New_Amount__c = 1000;
        instOfOppSec.Parent_Upsell__c = 'Primary';
       // instOfOppSec.Send_This_To_Tract__c = true;
        
        instOfOppSec.Forex_rate__c = 1;
       // instOfOppSec.Price_per_lead__c = 1;
        instOfOppSec.Clubbed_Opportunity__c = true;
        //instOfOppSec.Clubbed_Tract_Billing_Account__c = 'abcd1234';
        //instOfOppSec.TRACT2__Tract_Sales_Order__c='179';
        insert instOfOppSec;
        instOfOppSec.CFC_Check__c = 'Tanuj'; 
        test.startTest();
        update instOfOppSec;
        
        //Cancellation Testing
        instOfOppSec.Set_Cancellation_Status__c = 'Edit & Clone';
        update instOfOppSec;
        //Cancellation Testing
        
        BillingCase__c instOfBilC = new BillingCase__c();
        instOfBilC.CustomersAccount__c = instofAcc.id;
        instOfBilC.CVII_Number__c = '32323';
        instOfBilC.Name = 'Test';
        insert instOfBilC;
        
        //added by kumud on 30/05/18
        User instUsr = TestUtil.CreateDeploymentUser();
        insert instUsr;
        
        system.RunAs(instUsr){
        WriteOff__c instOfWriteOff = new WriteOff__c();
        instOfWriteOff.Type_of_Cancellation__c = 'Bad Debt';
        instOfWriteOff.Product__c = 'Event';
        instOfWriteOff.Contract__c = '25512';
        instOfWriteOff.Write_Off_Status__c = 'Initially Approved';
        instOfWriteOff.New_TCV_To_Be_Moved__c ='Yes';
        instOfWriteOff.Customer_Name__c = instOfBilC.id;
        instOfWriteOff.Office_Location__c = 'US';
        insert instOfWriteOff;
        
        
        instOfWriteOff.Write_Off_Status__c = 'Submitted for Review';
        
        update instOfWriteOff;
        
        instOfWriteOff.New_TCV_To_Be_Moved__c ='No';
        
        update instOfWriteOff;
        instOfWriteOff.New_TCV_To_Be_Moved__c ='Yes';
        update instOfWriteOff;
        
        delete instOfWriteOff;
        }
        ApexPages.currentPage().getParameters().put('ContrNum', '25512');
        List<String> str= new List<String>();
        List<String> str2= new List<String>();
        List<String> str2SetCancellationStatusVal = new List<String>();
        str2SetCancellationStatusVal.add(instOfOppSec.Id+';Edit & Clone');
        str.add(String.valueOf(instOfOppSec.Id));
        OpportunitySelectCls instOfOppSel = new OpportunitySelectCls();
        instOfOppSel.SubmitSec();
        OpportunitySelectCls.updateAnnualPickListsOnly('25512');
        instOfOppSel.Search();
        OpportunitySelectCls.updateAnnualOpps(str,str2,str2SetCancellationStatusVal);
        Test.stopTest();
    }
    //New Code added by Hemant Singh Rana
    static testMethod void myUnitTestSeven() {
        instofAcc.Billing_Case__c=null;
        update instofAcc;
        
        RecordType instOfRecType = [SELECT Id FROM RecordType WHERE SobjectType='Opportunity' And DeveloperName='Event' And IsActive=true];
        
        Opportunity instOfOppSec = TestUtil.createOpportunityNew('Test Opportunity','Closed Won',instOfCon.Id,instofAcc.Id);
        //instOfOpp.Opportunity_Start_Date__c = system.today();
        instOfOppSec.License_Type__c = 'Diamond Plus';
        instOfOppSec.Contract_Type_Test__c = 'Renewal';
        instOfOppSec.Counted_sales_Cancellation_Value__c =110;
        instOfOppSec.Liquidation_Fee__c  = 10;
        instOfOppSec.OptOutDate__c = system.today();
        instOfOppSec.Opp_End_Date__c  = system.today();
        instOfOppSec.Product__c = 'CrowdCompass';
        instOfOppSec.Contract_Number_New__c = '25512';
        instOfOppSec.New_Type__c =  'Upsell-NBB';
        instOfOppSec.CloseDate = system.today();
        instOfOppSec.RecordTypeId = instOfRecType.Id;
        instOfOppSec.Year_1_at_Risk__c = 11;
        instOfOppSec.New_Type__c = 'Test';
        instOfOppSec.Deal_Booked_In__c = 'US Books';
       // instOfOppSec.Price_per_lead__c = 1;
        instOfOppSec.Years__c= '1';
        instOfOppSec.LeadSource = 'ACD-PS';
        instOfOppSec.MSA_Code__c = instOfMulPropBund.MSA_Code__c;
        instOfOppSec.ContractReceived__c = system.today();
        instOfOppSec.ContractStartDate__c = system.today(); 
        //instOfOppSec.End_Date__c = system.today();
        //instOfOppSec.Deal_Year__c = '1';
        instOfOppSec.MYD_Deal__c = 'First Year';
        instOfOppSec.Deal_Year__c = '1';
        instOfOppSec.New_Amount__c = 1000;
        instOfOppSec.Parent_Upsell__c = 'Primary';
        instOfOppSec.Event_Name__c = 'TestEvent';
      //  instOfOppSec.Send_This_To_Tract__c = true;
        //instOfOppSec.TRACT2__Tract_Sales_Order__c='1112';
        instOfOppSec.Forex_rate__c = 1;
        //instOfOppSec.Price_per_lead__c = 1;
        instOfOppSec.Clubbed_Opportunity__c = true;
        //instOfOppSec.Clubbed_Tract_Billing_Account__c = 'abcd1234';
        //instOfOppSec.TRACT2__Tract_Sales_Order__c='179';
        insert instOfOppSec;
        instOfOppSec.Contract_Implemented__c = true;
        test.startTest();
        update instOfOppSec;
        
        instOfOppSec.CFC_Check__c = 'Tanuj';        
        update instOfOppSec;
        
        BillingCase__c instOfBilC = new BillingCase__c();
        instOfBilC.CustomersAccount__c = instofAcc.id;
        instOfBilC.CVII_Number__c = '32323';
        instOfBilC.Name = 'Test';
        insert instOfBilC;
        WriteOff__c instOfWriteOff = new WriteOff__c();
        instOfWriteOff.Type_of_Cancellation__c = 'Bad Debt';
        instOfWriteOff.Product__c = 'Event';
        instOfWriteOff.Contract__c = '25512';
        instOfWriteOff.Write_Off_Status__c = 'Declined';
        instOfWriteOff.New_TCV_To_Be_Moved__c ='Yes';
        instOfWriteOff.Customer_Name__c = instOfBilC.id;
        insert instOfWriteOff;
        instOfWriteOff.New_TCV_To_Be_Moved__c ='No';
        update instOfWriteOff;
        
        instOfWriteOff.New_TCV_To_Be_Moved__c ='Yes';
        update instOfWriteOff;
        test.stopTest();
        delete instOfWriteOff;
        ApexPages.currentPage().getParameters().put('ContrNum', '25512');
        List<String> str= new List<String>();
        List<String> str2= new List<String>();
        str.add(String.valueOf(instOfOppSec.Id));
        List<String> str2SetCancellationStatusVal = new List<String>();
        str2SetCancellationStatusVal.add(instOfOppSec.Id+';Edit & Clone');
        OpportunitySelectCls instOfOppSel = new OpportunitySelectCls();
        instOfOppSel.Search();
        OpportunitySelectCls.updateAnnualOpps(str,str2,str2SetCancellationStatusVal);
    }
    static testMethod void myUnitTestEight() {
        RecordType instOfRecType = [SELECT Id FROM RecordType WHERE SobjectType='Opportunity' And DeveloperName='Event' And IsActive=true];
        
        Opportunity instOfOppSec = TestUtil.createOpportunityNew('Test Opportunity','Closed Won',instOfCon.Id,instofAcc.Id);
        //instOfOpp.Opportunity_Start_Date__c = system.today();
        instOfOppSec.License_Type__c = 'Diamond Plus';
        instOfOppSec.Contract_Type_Test__c = 'Renewal';
        instOfOppSec.Counted_sales_Cancellation_Value__c =110;
        instOfOppSec.Liquidation_Fee__c  = 10;
        instOfOppSec.OptOutDate__c = system.today();
        instOfOppSec.Opp_End_Date__c  = system.today();
        instOfOppSec.Product__c = 'CrowdCompass';
        instOfOppSec.Contract_Number_New__c = '25512';
        instOfOppSec.New_Type__c =  'Upsell-NBB';
        instOfOppSec.CloseDate = system.today();
        instOfOppSec.RecordTypeId = instOfRecType.Id;
        instOfOppSec.Year_1_at_Risk__c = 11;
        instOfOppSec.New_Type__c = 'Test';
        instOfOppSec.Deal_Booked_In__c = 'UK Books';
       // instOfOppSec.Price_per_lead__c = 1;
        instOfOppSec.Years__c= '1';
        instOfOppSec.LeadSource = 'ACD-PS';
        instOfOppSec.MSA_Code__c = instOfMulPropBund.MSA_Code__c;
        instOfOppSec.Contract_Implemented__c = true;
        instOfOppSec.ContractReceived__c = system.today();
        instOfOppSec.Event_Name__c ='Test';
        //instOfOppSec.Deal_Year__c = '1';
        instOfOppSec.MYD_Deal__c = 'First Year';
        instOfOppSec.Deal_Year__c = '1';
        instOfOppSec.New_Amount__c = 1000;
        instOfOppSec.Parent_Upsell__c = 'Primary';
       // instOfOppSec.Send_This_To_Tract__c = true;
        //instOfOppSec.TRACT2__Tract_Sales_Order__c='1112';
        instOfOppSec.Forex_rate__c = 1;
      //  instOfOppSec.Price_per_lead__c = 1;
        instOfOppSec.Clubbed_Opportunity__c = true;
        //instOfOppSec.Clubbed_Tract_Billing_Account__c = 'abcd1234';
        //instOfOppSec.TRACT2__Tract_Sales_Order__c='179';
        insert instOfOppSec;
        //instOfOppSec.MSA_Code__c ='12345'; 
        //instOfOppSec.CloseDate = system.today().AddDays(1);
        instOfOppSec.Contract_Implemented__c = true;
        update instOfOppSec;
        
        Test.startTest();
        Contract_Reviewing__c instOfContrRev = new Contract_Reviewing__c();
        instOfContrRev.Opportunity__c =  instOfOppSec.Id;
        insert instOfContrRev;
        
        instOfOppSec.CFC_Check__c = 'Tanuj';        
        update instOfOppSec;
        
        BillingCase__c instOfBilC = new BillingCase__c();
        instOfBilC.CustomersAccount__c = instofAcc.id;
        instOfBilC.CVII_Number__c = '32323';
        instOfBilC.Name = 'Test';
        insert instOfBilC;
        WriteOff__c instOfWriteOff = new WriteOff__c();
        instOfWriteOff.Type_of_Cancellation__c = 'Bad Debt';
        instOfWriteOff.Product__c = 'Event';
        instOfWriteOff.Contract__c = '25512';
        instOfWriteOff.Write_Off_Status__c = 'Declined';
        instOfWriteOff.New_TCV_To_Be_Moved__c ='Yes';
        instOfWriteOff.Customer_Name__c = instOfBilC.id;
        insert instOfWriteOff;
        instOfWriteOff.New_TCV_To_Be_Moved__c ='No';
        
        update instOfWriteOff;
        instOfWriteOff.New_TCV_To_Be_Moved__c ='Yes';
        update instOfWriteOff;
        Test.stopTest();
        delete instOfWriteOff;
        ApexPages.currentPage().getParameters().put('ContrNum', '25512');
        List<String> str = new List<String>();
        List<String> str2 = new List<String>();
        List<String> str2SetCancellationStatusVal = new List<String>();
        str2SetCancellationStatusVal.add(instOfOppSec.Id+';Edit & Clone');
        str.add(String.valueOf(instOfOppSec.Id));
        OpportunitySelectCls instOfOppSel = new OpportunitySelectCls();
        instOfOppSel.Search();
        OpportunitySelectCls.updateAnnualOpps(str,str2,str2SetCancellationStatusVal);
    }
   
    static testMethod void myUnitTestTen() {
        RecordType instOfRecType = [SELECT Id FROM RecordType WHERE SobjectType='Opportunity' And DeveloperName='Event' And IsActive=true];
         /*.....................Cancellations_Super_Users__c record insert.............................*/               
        Cancellations_Super_Users__c cc= new Cancellations_Super_Users__c();        
        cc.Name = UserInfo.getUserId();     
        cc.Username__c = UserInfo.getUserName();        
        insert cc;      
        /*.............................ENDS HERE........................................*/
        Opportunity instOfOppSec = TestUtil.createOpportunityNew('Test Opportunity','Closed Won',instOfCon.Id,instofAcc.Id);
        //instOfOpp.Opportunity_Start_Date__c = system.today();
        instOfOppSec.License_Type__c = 'Diamond Plus';
        instOfOppSec.Contract_Type_Test__c = 'Renewal';
        instOfOppSec.Counted_sales_Cancellation_Value__c =110;
        instOfOppSec.Liquidation_Fee__c  = 10;
        instOfOppSec.OptOutDate__c = system.today();
        instOfOppSec.Opp_End_Date__c  = system.today();
        instOfOppSec.Product__c = 'CrowdCompass';
        instOfOppSec.Contract_Number_New__c = '25512';
        instOfOppSec.New_Type__c =  'Upsell-NBB';
        instOfOppSec.CloseDate = system.today();
        instOfOppSec.RecordTypeId = instOfRecType.Id;
        instOfOppSec.Year_1_at_Risk__c = 11;
        instOfOppSec.New_Type__c = 'Test';
        instOfOppSec.Deal_Booked_In__c = 'UK Books';
       // instOfOppSec.Price_per_lead__c = 1;
        instOfOppSec.Years__c= '1';
        instOfOppSec.LeadSource = 'ACD-PS';
        instOfOppSec.MSA_Code__c = instOfMulPropBund.MSA_Code__c;
        instOfOppSec.ContractReceived__c = system.today();
        //instOfOppSec.Deal_Year__c = '1';
        instOfOppSec.MYD_Deal__c = 'First Year';
        instOfOppSec.Deal_Year__c = '1';
        instOfOppSec.New_Amount__c = 1000;
        instOfOppSec.Parent_Upsell__c = 'Primary';
        instOfOppSec.Event_Name__c = 'TestE';
        //instOfOppSec.Send_This_To_Tract__c = true;
        
        instOfOppSec.Forex_rate__c = 1;
     //   instOfOppSec.Price_per_lead__c = 1;
        instOfOppSec.Clubbed_Opportunity__c = true;
       // instOfOppSec.Clubbed_Tract_Billing_Account__c = 'abcd1234';
        instOfOppSec.License_Type__c = '1/2 Diamond';
        instOfOppSec.ContractEndDate__c = system.today();
        //instOfOppSec.TRACT2__Tract_Sales_Order__c='179';
        test.startTest();
        insert instOfOppSec;   
        
        instOfOppSec.Contract_Implemented__c = true;
        update instOfOppSec;
        
        List<Contract_Reviewing__c> lstContrRevFirst =  new List<Contract_Reviewing__c>();
        lstContrRevFirst = [SELECT ID,Contract_Review_Ok__c,Opportunity_Stage__c FROM Contract_Reviewing__c WHERE Opportunity_Contract__c ='25512' ];
        
        List<Contract_Reviewing__c> lstContrRevUpdFirst =  new List<Contract_Reviewing__c>();
        
        for(Contract_Reviewing__c instOfContRev : lstContrRevFirst){
            instOfContRev.Contract_Review_Ok__c = 'Yes';
            lstContrRevUpdFirst.add(instOfContRev);
        }
        
        BillingCase__c instOfBilC = new BillingCase__c();
        instOfBilC.CustomersAccount__c = instofAcc.id;
        instOfBilC.CVII_Number__c = '32323';
        instOfBilC.Name = 'Test';
        insert instOfBilC;
        
        test.stopTest();
        
        //added by kumud on 30/05/18
        /*User instUsr = TestUtil.CreateDeploymentUser();
        insert instUsr;
        
        system.RunAs(instUsr){
        WriteOff__c instOfWriteOff = new WriteOff__c();
        instOfWriteOff.Type_of_Cancellation__c = 'Billing Error';
        instOfWriteOff.Product__c = 'Event';
        instOfWriteOff.Contract__c = '25512';
        instOfWriteOff.Write_Off_Status__c = 'Initially Approved';
        instOfWriteOff.New_TCV_To_Be_Moved__c ='Yes';
        instOfWriteOff.Customer_Name__c = instOfBilC.id;
        insert instOfWriteOff;
        
        instOfWriteOff.Write_Off_Status__c = 'Submitted for Review';
        update instOfWriteOff;
        
        
        instOfWriteOff.Write_Off_Status__c = 'Error in Form';
        instOfWriteOff.Type_of_Cancellation__c = 'Withhold Tax Cancellation';
        update instOfWriteOff;
        instOfWriteOff.Type_of_Cancellation__c = 'Submitted for Review';
        update instOfWriteOff;
        }
        List<Contract_Reviewing__c> lstContrRev =  new List<Contract_Reviewing__c>();
        lstContrRev = [SELECT ID,Canx_Accounting_Hybrid_Review_Ok__c,Opportunity_Stage__c FROM Contract_Reviewing__c WHERE Opportunity_Contract__c ='25512' ];
        
        List<Contract_Reviewing__c> lstContrRevUpd = new List<Contract_Reviewing__c>();
        for(Contract_Reviewing__c instOfContRev : lstContrRev){
            if(instOfContRev.Opportunity_Stage__c != 'Tract'){
                instOfContRev.Canx_Accounting_Hybrid_Review_Ok__c  = 'Yes';
                lstContrRevUpd.add(instOfContRev);
            }else if(instOfContRev.Opportunity_Stage__c == 'Tract'){
                instOfContRev.Canx_Accounting_Team_Level_1_Review_Ok__c = 'Yes';
                lstContrRevUpd.add(instOfContRev);
            }
        }
        
        if(lstContrRevUpd.size()>0)
        update lstContrRevUpd;
        
        lstContrRev =  new List<Contract_Reviewing__c>();
        for(Contract_Reviewing__c instOfContRev : lstContrRevUpd){
            if(instOfContRev.Opportunity_Stage__c != 'Tract'){
                instOfContRev.Canx_Contract_Review_Ok__c  = 'Yes';
                lstContrRev.add(instOfContRev);
            }else if(instOfContRev.Opportunity_Stage__c == 'Tract'){
                instOfContRev.Canx_Accounting_Team_Level_2_Review_OK__c = 'Yes';
                lstContrRev.add(instOfContRev);
            }
        }
        
        if(lstContrRev.size()>0)
        update lstContrRev;
        
        lstContrRevUpd = new List<Contract_Reviewing__c>();
        
        for(Contract_Reviewing__c instOfContRev : lstContrRev){
            if(instOfContRev.Opportunity_Stage__c != 'Tract'){
                instOfContRev.Tax_Review_Ok__c  = 'Yes';
                lstContrRevUpd.add(instOfContRev);
            }
        }
        
        if(lstContrRevUpd.size()>0){
            try{
                update lstContrRevUpd;
            }catch(Exception e){
                system.debug('Debug Only');
            }   
        }*/
    }
    static testMethod void myUnitTestEleven() {
        
        Opportunity instOpp= instClosedWonOpty;
        Contract_Reviewing__c oppContract=new Contract_Reviewing__c();
        oppContract.Opportunity__c=instOpp.Id;
        //oppContract.Opportunity_Contract__c='255126';
        oppContract.Accounting_Review_Ok__c='Re-Review';
        oppContract.Acc_Review_Post_Rev_Rec_OK__c='Re-Review';
        oppContract.Contract_Value_50k_review_Ok__c='Re-Review';
        insert oppContract;
        
        List<Contract_Reviewing__c> lstContrRevFirst =  new List<Contract_Reviewing__c>();
        lstContrRevFirst = [SELECT ID,Contract_Review_Ok__c,Opportunity_Stage__c FROM Contract_Reviewing__c WHERE Opportunity_Contract__c =:instOpp.Contract_Number_New__c ];
        
        List<Contract_Reviewing__c> lstContrRevUpdFirst =  new List<Contract_Reviewing__c>();
        
        for(Contract_Reviewing__c instOfContRev : lstContrRevFirst){
            instOfContRev.Contract_Review_Ok__c = 'Yes';
            lstContrRevUpdFirst.add(instOfContRev);
        }
        BillingCase__c instOfBilC = new BillingCase__c();
        instOfBilC.CustomersAccount__c = instofAcc.id;
        instOfBilC.CVII_Number__c = '32323';
        instOfBilC.Name = 'Test';
        Test.startTest();          
        insert instOfBilC;
        
        //added by kumud on 30/05/18
        User instUsr = TestUtil.CreateDeploymentUser();
        insert instUsr;
        
        system.RunAs(instUsr){
            WriteOff__c instOfWriteOff = new WriteOff__c();
            instOfWriteOff.Type_of_Cancellation__c = 'Withhold Tax Cancellation';
            instOfWriteOff.Product__c = 'Event';
            instOfWriteOff.Contract__c = '255126';
            instOfWriteOff.Write_Off_Status__c = 'Initially Approved';
            instOfWriteOff.New_TCV_To_Be_Moved__c ='Yes';
            instOfWriteOff.Customer_Name__c = instOfBilC.id;
            instOfWriteOff.Office_Location__c = 'US';
            insert instOfWriteOff;
        
        
        Cancellations_Super_Users__c cc= new Cancellations_Super_Users__c();        
        cc.Name = UserInfo.getUserId();     
        cc.Username__c = UserInfo.getUserName();        
        insert cc;      
        
        instOfWriteOff.Write_Off_Status__c = 'Submitted for Review';
        update instOfWriteOff;
        }
        
    }
    static testMethod void myUnitTestTwelve() {
        RecordType instOfRecType = [SELECT Id FROM RecordType WHERE SobjectType='Opportunity' And DeveloperName='Event' And IsActive=true];
         /*.....................Cancellations_Super_Users__c record insert.............................*/               
        Cancellations_Super_Users__c cc= new Cancellations_Super_Users__c();        
        cc.Name = UserInfo.getUserId();     
        cc.Username__c = UserInfo.getUserName();        
        insert cc;      
        /*.............................ENDS HERE........................................*/
        Opportunity instOfOppSec=instClosedWonOpty;
       
        instOfOppSec.Contract_Implemented__c=true;
        instOfOppSec.Contract_Number_New__c = '2551234';
        //instOfOppSec.Send_This_To_Tract__c = true;
        update instOfOppSec;
        
        Feature_Set__c instOfFSetForYearDGSecond = new Feature_Set__c();
        instOfFSetForYearDGSecond.Opportunity_N__c = instOfOppSec.Id;
        instOfFSetForYearDGSecond.Feature__c = 'Custom Work SLM' ;
        insert instOfFSetForYearDGSecond;
        
        BillingCase__c instOfBilC = new BillingCase__c();
        instOfBilC.CustomersAccount__c = instofAcc.id;
        instOfBilC.CVII_Number__c = '32323';
        instOfBilC.Name = 'Test';
        insert instOfBilC;
        
        //added by kumud on 30/05/18
        Test.StartTest();
        User instUsr = TestUtil.CreateDeploymentUser();
        insert instUsr;
        
        WriteOff__c instOfWriteOff = new WriteOff__c();
        system.RunAs(instUsr){
        
        //instOfWriteOff.Type_of_Cancellation__c = 'Withhold Tax Cancellation';
        instOfWriteOff.Type_of_Cancellation__c = 'Bad Debts';
        instOfWriteOff.Product__c = 'Event';
        instOfWriteOff.Contract__c = '2551234';
        instOfWriteOff.Shut_Down_Required__c = 'No';
        instOfWriteOff.Write_Off_Status__c = 'Initially Approved';
        instOfWriteOff.New_TCV_To_Be_Moved__c ='Yes';
        instOfWriteOff.Customer_Name__c = instOfBilC.id;
        instOfWriteOff.Sale_Impact__c = 'No';
        instOfWriteOff.Commission_Impact__c = 'No';
        instOfWriteOff.Time_taken_for_Cancellation__c = 10;
        instOfWriteOff.Office_Location__c = 'US';
        insert instOfWriteOff;
        }
        
        instOfWriteOff.Write_Off_Status__c = 'Submitted for Review';
        update instOfWriteOff;
        Test.StopTest();
       
    }
    
   
    static testMethod void myUnitTestFourteen() {
        
        RecordType instOfRecType = [SELECT Id FROM RecordType WHERE SobjectType='Opportunity' And DeveloperName='Event' And IsActive=true];
         /*.....................Cancellations_Super_Users__c record insert.............................*/               
        Cancellations_Super_Users__c cc= new Cancellations_Super_Users__c();        
        cc.Name = UserInfo.getUserId();     
        cc.Username__c = UserInfo.getUserName();        
        insert cc;      
        /*.............................ENDS HERE........................................*/
        Opportunity instOfOppSec = TestUtil.createOpportunityNew('Test Opportunity','Closed Won',instOfCon.Id,instofAcc.Id);
        //instOfOpp.Opportunity_Start_Date__c = system.today();
        instOfOppSec.License_Type__c = 'Diamond Plus';
        instOfOppSec.Contract_Type_Test__c = 'Renewal';
        instOfOppSec.Counted_sales_Cancellation_Value__c =110;
        instOfOppSec.Liquidation_Fee__c  = 10;
        instOfOppSec.OptOutDate__c = system.today();
        instOfOppSec.Opp_End_Date__c  = system.today();
        instOfOppSec.Product__c = 'CrowdCompass';
        instOfOppSec.Contract_Number_New__c = '255122';
        instOfOppSec.New_Type__c =  'Upsell-NBB';
        instOfOppSec.CloseDate = system.today();
        instOfOppSec.RecordTypeId = instOfRecType.Id;
        instOfOppSec.Year_1_at_Risk__c = 11;
        instOfOppSec.New_Type__c = 'Test';
        instOfOppSec.Deal_Booked_In__c = 'UK Books';
      //  instOfOppSec.Price_per_lead__c = 1;
        instOfOppSec.Years__c= '1';
        instOfOppSec.LeadSource = 'ACD-PS';
        instOfOppSec.MSA_Code__c = instOfMulPropBund.MSA_Code__c;
        instOfOppSec.ContractReceived__c = system.today();
        //instOfOppSec.Deal_Year__c = '1';
        instOfOppSec.MYD_Deal__c = 'First Year';
        instOfOppSec.Deal_Year__c = '1';
        instOfOppSec.New_Amount__c = 1000;
        instOfOppSec.Parent_Upsell__c = 'Primary';
       // instOfOppSec.Send_This_To_Tract__c = true;
        
        instOfOppSec.Forex_rate__c = 1;
       // instOfOppSec.Price_per_lead__c = 1;
        instOfOppSec.Clubbed_Opportunity__c = true;
       // instOfOppSec.Clubbed_Tract_Billing_Account__c = 'abcd1234';
        instOfOppSec.License_Type__c = '1/2 Diamond';
        instOfOppSec.ContractEndDate__c = system.today();
        //instOfOppSec.TRACT2__Tract_Sales_Order__c='179';
        insert instOfOppSec;   
        
      //  instOfOppSec.Contract_Implemented__c = true;
       // update instOfOppSec;
        Contract_Reviewing__c oppContract=new Contract_Reviewing__c();
        oppContract.Opportunity__c=instOfOppSec.Id;
        //oppContract.Opportunity_Contract__c='255126';
        oppContract.Accounting_Review_Ok__c='Re-Review';
        oppContract.Acc_Review_Post_Rev_Rec_OK__c='Re-Review';
        oppContract.Contract_Value_50k_review_Ok__c='Re-Review';
        insert oppContract;
        
       
        
        BillingCase__c instOfBilC = new BillingCase__c();
        instOfBilC.CustomersAccount__c = instofAcc.id;
        instOfBilC.CVII_Number__c = '32323';
        instOfBilC.Name = 'Test';
        insert instOfBilC;
        //added by kumud on 30/05/18
        User instUsr = TestUtil.CreateDeploymentUser();
        insert instUsr;
        system.RunAs(instUsr){
        
        WriteOff__c instOfWriteOff = new WriteOff__c();
        instOfWriteOff.Type_of_Cancellation__c = 'Withhold Tax Cancellation';
        instOfWriteOff.Product__c = 'Event';
        instOfWriteOff.Contract__c = '255122';
        instOfWriteOff.Write_Off_Status__c = 'Initially Approved';
        instOfWriteOff.New_TCV_To_Be_Moved__c ='Yes';
        instOfWriteOff.Customer_Name__c = instOfBilC.id;
        instOfWriteOff.Office_Location__c = 'US';
        insert instOfWriteOff;
        Test.startTest();
        instOfWriteOff.Write_Off_Status__c = 'Submitted for Review';
        update instOfWriteOff;
        Test.stopTest();
        
      
            
        }
        
    }
    
    static testMethod void myUnitTestFifteen() {
        RecordType instOfRecType = [SELECT Id FROM RecordType WHERE SobjectType='Opportunity' And DeveloperName='Event' And IsActive=true];
        
        Opportunity instOfOppSec = TestUtil.createOpportunityNew('Test Opportunity','Closed Won',instOfCon.Id,instofAcc.Id);
        //instOfOpp.Opportunity_Start_Date__c = system.today();
        instOfOppSec.License_Type__c = 'Diamond Plus';
        instOfOppSec.Contract_Type_Test__c = 'Renewal';
        instOfOppSec.Counted_sales_Cancellation_Value__c =110;
        instOfOppSec.Liquidation_Fee__c  = 10;
        instOfOppSec.OptOutDate__c = system.today();
        instOfOppSec.Opp_End_Date__c  = system.today();
        instOfOppSec.Product__c = 'CrowdCompass';
        instOfOppSec.Contract_Number_New__c = '255122';
        instOfOppSec.New_Type__c =  'Upsell-NBB';
        instOfOppSec.CloseDate = system.today();
        instOfOppSec.RecordTypeId = instOfRecType.Id;
        instOfOppSec.Year_1_at_Risk__c = 11;
        instOfOppSec.New_Type__c = 'Test';
        instOfOppSec.Deal_Booked_In__c = 'UK Books';
       // instOfOppSec.Price_per_lead__c = 1;
        instOfOppSec.Years__c= '1';
        instOfOppSec.LeadSource = 'ACD-PS';
        instOfOppSec.MSA_Code__c = instOfMulPropBund.MSA_Code__c;
        instOfOppSec.ContractReceived__c = system.today();
        //instOfOppSec.Deal_Year__c = '1';
        instOfOppSec.MYD_Deal__c = 'First Year';
        instOfOppSec.Deal_Year__c = '1';
        instOfOppSec.New_Amount__c = 1000;
        instOfOppSec.Parent_Upsell__c = 'Primary';
       // instOfOppSec.Send_This_To_Tract__c = true;
        //instOfOppSec.TRACT2__Tract_Sales_Order__c='179';
        instOfOppSec.Forex_rate__c = 1;
        //instOfOppSec.Price_per_lead__c = 1;
        instOfOppSec.Clubbed_Opportunity__c = true;
        //instOfOppSec.Clubbed_Tract_Billing_Account__c = 'abcd1234';
        instOfOppSec.License_Type__c = '1/2 Diamond';
        instOfOppSec.ContractEndDate__c = system.today();
        insert instOfOppSec;   
        
        //instOfOppSec.Contract_Implemented__c = true;
        //update instOfOppSec;
        
        Feature_Set__c instOfFSetForYearDGSecond = new Feature_Set__c();
        instOfFSetForYearDGSecond.Opportunity_N__c = instOfOppSec.Id;
        instOfFSetForYearDGSecond.Feature__c = 'Testing' ;
        insert instOfFSetForYearDGSecond;
        
        TM_Fee_Structure__c instOfTMFee = new TM_Fee_Structure__c();
        instOfTMFee.Opportunity__c = instOfOppSec.Id;
        insert instOfTMFee;
        
        Invoicing_Details__c instOfInvDet =  new Invoicing_Details__c();
        //instOfInvDet.Name = 'Tset';
        instOfInvDet.Opportunity__c  = instOfOppSec.Id;
        instOfInvDet.Billing_POC__c = instOfCon.Id;
        insert instOfInvDet;
        
        Invoicing_Line_Items__c instOfILV = new Invoicing_Line_Items__c();
        instOfILV.Invoicing_Details__c = instOfInvDet.Id;
        instOfILV.Installment_description__c = 'Test';
        insert instOfILV;
        
        CSN_Credit__c  instOfCSNCred = new CSN_Credit__c();
        instOfCSNCred.Opportunity__c = instOfOppSec.Id;
        insert instOfCSNCred;
        
        RecordType instOfRectypeMPB = [SELECT SobjectType, Name,developerName FROM RecordType WHERE SobjectType='Multi_Property_Bundles__c' AND DeveloperName = 'MSA'];
        Multi_Property_Bundles__c instOfMPB = new Multi_Property_Bundles__c();
        instOfMPB.RecordTypeId = instOfRectypeMPB.id;
        instOfMPB.Opportunity__c = instOfOppSec.Id;
        instOfMPB.Name = 'Test';
        insert instOfMPB;
        
        instOfOppSec.CurrencyIsoCode = 'GBP';
        update instOfOppSec;
    }
    static testMethod void myUnitTestSixteen() {
        RecordType instOfRecType = [SELECT Id FROM RecordType WHERE SobjectType='Opportunity' And DeveloperName='Event' And IsActive=true];
        Opportunity instOfOppFIF = TestUtil.createOpportunityNew('Test Opportunity','Closed Won',instOfCon.Id,instofAcc.Id);
        //instOfOpp.Opportunity_Start_Date__c = system.today();
        instOfOppFIF.Contract_Type_Test__c = 'Renewal';
        instOfOppFIF.Forex_rate__c = 1;
        instOfOppFIF.Counted_sales_Cancellation_Value__c =110;
        instOfOppFIF.Liquidation_Fee__c  = 10;
        instOfOppFIF.OptOutDate__c = system.today();
        instOfOppFIF.Opp_End_Date__c  = system.today();
        instOfOppFIF.Forex_rate__c = 1;
       // instOfOppFIF.Price_per_lead__c = 1;
        instOfOppFIF.Product__c = 'CSN';
        instOfOppFIF.Contract_Number_New__c = '25512l1111';
        instOfOppFIF.New_Type__c =  'Upsell-NBB';
        instOfOppFIF.CloseDate = system.today();
        instOfOppFIF.RecordTypeId = instOfRecType.Id;
        instOfOppFIF.Year_1_at_Risk__c = 11;
        instOfOppFIF.New_Type__c = 'Test';
        instOfOppFIF.Deal_Booked_In__c = '5';
        //instOfOppFIF.Price_per_lead__c = 1;
        instOfOppFIF.Years__c= '1';
        instOfOppFIF.LeadSource = 'ACD-PS';
        instOfOppFIF.MSA_Code__c = instOfMulPropBund.MSA_Code__c;
        instOfOppFIF.ContractReceived__c = system.today();
        instOfOppFIF.Deal_Year__c = '1';
        instOfOppFIF.MaintenanceFee__c = 1000;
        instOfOppFIF.New_Amount__c = 0;
        //instOfOppFIF.Discount__c = 1000;
        instOfOppFIF.Convinience_Fee__c = 1000;
        instOfOppFIF.of_Leads_Purchased__c = 1000;
        //instOfOppFIF.Events__c = 1000;
        instOfOppFIF.Price_Adjustment__c = 1000;
        instOfOppFIF.MYD_Deal__c = 'First Year';
        instOfOppFIF.Parent_Upsell__c = 'Primary';
        instOfOppFIF.Clubbed_Opportunity__c = true;
        instOfOppFIF.Event_Name__c = 'Event';       // instOfOppFIF.Clubbed_Tract_Billing_Account__c = 'abcd1234';
        instOfOppFIF.License_Type__c = 'Diamond Plus';
        //instOfOppFIF.TRACT2__Tract_Sales_Order__c='179';
        instOfOppFIF.ContractReceived__c = system.today();
        instOfOppFIF.ContractStartDate__c = system.today(); 
        //instOfOppFIF.End_Date__c = system.today();
        instOfOppFIF.ATI_Check__c=true;
        
        test.startTest();
        insert instOfOppFIF;
        
        instOfOppFIF.Contract_Implemented__c = true;
        update instOfOppFIF;
        
        instOfOppFIF.CFC_Check__c = 'TEST@@@';
        update instOfOppFIF;
        
        test.stopTest();
        
        instOfOppFIF.CFC_Check__c = 'TDDDDEST@@@';
        update instOfOppFIF;
        
        instOfOppFIF.Set_Cancellation_Status__c = 'Edit & Clone';
        update instOfOppFIF;
        
    }
    
    static testMethod void Seventeen(){
        RecordType instOfRecType = [SELECT Id FROM RecordType WHERE SobjectType='Opportunity' And DeveloperName='Event' And IsActive=true];
        Opportunity instOfOppSec = TestUtil.createOpportunityNew('Test Opportunity','Closed Won',instOfCon.Id,instofAcc.Id);
        //instOfOpp.Opportunity_Start_Date__c = system.today();
        instOfOppSec.License_Type__c = 'Diamond Plus';
        instOfOppSec.Contract_Type_Test__c = 'Renewal';
        instOfOppSec.Counted_sales_Cancellation_Value__c =110;
        instOfOppSec.Liquidation_Fee__c  = 10;
        instOfOppSec.OptOutDate__c = system.today();
        instOfOppSec.Opp_End_Date__c  = system.today();
        instOfOppSec.Product__c = 'CrowdCompass';
        instOfOppSec.Contract_Number_New__c = '255122';
        instOfOppSec.New_Type__c =  'Upsell-NBB';
        instOfOppSec.CloseDate = system.today();
        instOfOppSec.RecordTypeId = instOfRecType.Id;
        instOfOppSec.Year_1_at_Risk__c = 11;
        instOfOppSec.New_Type__c = 'Test';
        instOfOppSec.Deal_Booked_In__c = 'UK Books';
        //instOfOppSec.Price_per_lead__c = 1;
        instOfOppSec.Years__c= '1';
        instOfOppSec.LeadSource = 'ACD-PS';
        instOfOppSec.MSA_Code__c = instOfMulPropBund.MSA_Code__c;
        instOfOppSec.ContractReceived__c = system.today();
        //instOfOppSec.Deal_Year__c = '1';
        instOfOppSec.MYD_Deal__c = 'First Year';
        instOfOppSec.Deal_Year__c = '1';
        instOfOppSec.New_Amount__c = 1000;
        instOfOppSec.Parent_Upsell__c = 'Primary';
       // instOfOppSec.Send_This_To_Tract__c = true;
        //instOfOppSec.TRACT2__Tract_Sales_Order__c='179';
        instOfOppSec.Forex_rate__c = 1;
       // instOfOppSec.Price_per_lead__c = 1;
        instOfOppSec.Clubbed_Opportunity__c = true;
       // instOfOppSec.Clubbed_Tract_Billing_Account__c = 'abcd1234';
        instOfOppSec.License_Type__c = '1/2 Diamond';
        instOfOppSec.ContractEndDate__c = system.today();
        insert instOfOppSec; 
        
        Contract_Reviewing__c  cObj = new Contract_Reviewing__c();
        cObj.Canx_Contract_Reviewer__c ='Abhishek Pandey';
        cobj.Opportunity__C= instOfOppSec.id;
        cobj.Type_Of_Cancellation__c = 'Bad Debt';
        cobj.Is_Cancellation__c = true;
        cobj.Is_Hybrid__c = true;
        insert cobj;
        
        cobj.Canx_Contract_Review_Ok__c = 'Yes';
        update cobj;
        
        cObj = new Contract_Reviewing__c();
        cObj.Canx_Contract_Reviewer__c ='Abhishek Pandey';
        cobj.Opportunity__C= instOfOppSec.id;
        cobj.Type_Of_Cancellation__c = 'Withhold Tax Cancellation';
        cobj.Is_Cancellation__c = true;
        cobj.Is_Hybrid__c = true;
        insert cobj;
        
        cobj.Canx_Contract_Review_Ok__c = 'Yes';
        update cobj;
        
        cObj = new Contract_Reviewing__c();
        cObj.Canx_Implementation_Team__c ='Abhishek Pandey';
        cobj.Opportunity__C= instOfOppSec.id;
        cobj.Type_Of_Cancellation__c = 'Withhold Tax Cancellation';
        cobj.Is_Cancellation__c = true;
        cobj.Is_Hybrid__c = true;
        cobj.Canx_Team_OK__c = 'Re-Review';
        insert cobj;
        test.startTest();
        cobj.Canx_Team_OK__c = 'Yes';
        update cobj;
        
        cObj = new Contract_Reviewing__c();
        cObj.Canx_Accounting_Reviewer_Hybrid_Feature__c ='Abhishek Pandey';
        cobj.Opportunity__C= instOfOppSec.id;
        cobj.Type_Of_Cancellation__c = 'Withhold Tax Cancellation';
        cobj.Is_Cancellation__c = true;
        cobj.Is_Hybrid__c = true;
        insert cobj;
        
        cobj.Canx_Accounting_Hybrid_Review_Ok__c = 'Yes';
        update cobj;
        
        
        cObj = new Contract_Reviewing__c();
        cObj.Canx_Accounting_Reviewer_Hybrid_Feature__c ='Abhishek Pandey';
        cobj.Opportunity__C= instOfOppSec.id;
        cobj.Type_Of_Cancellation__c = 'Withhold Tax Cancellation';
        cobj.Is_Cancellation__c = true;
        cobj.Is_Hybrid__c = true;
        insert cobj;
        
        cobj.Canx_Accounting_Hybrid_Review_Ok__c = 'No';
        update cobj;
        test.stopTest();
    }
    
    
    static testMethod void Eighteen(){
        RecordType instOfRecType = [SELECT Id FROM RecordType WHERE SobjectType='Opportunity' And DeveloperName='Event' And IsActive=true];
        Opportunity instOfOppSec = TestUtil.createOpportunityNew('Test Opportunity','Closed Won',instOfCon.Id,instofAcc.Id);
        //instOfOpp.Opportunity_Start_Date__c = system.today();
        instOfOppSec.License_Type__c = 'Diamond Plus';
        instOfOppSec.Contract_Type_Test__c = 'Renewal';
        instOfOppSec.Counted_sales_Cancellation_Value__c =110;
        instOfOppSec.Liquidation_Fee__c  = 10;
        instOfOppSec.OptOutDate__c = system.today();
        instOfOppSec.Opp_End_Date__c  = system.today();
        instOfOppSec.Product__c = 'CrowdCompass';
        instOfOppSec.Contract_Number_New__c = '255122';
        instOfOppSec.New_Type__c =  'Upsell-NBB';
        instOfOppSec.CloseDate = system.today();
        instOfOppSec.RecordTypeId = instOfRecType.Id;
        instOfOppSec.Year_1_at_Risk__c = 11;
        instOfOppSec.New_Type__c = 'Test';
        instOfOppSec.Deal_Booked_In__c = 'UK Books';
        //instOfOppSec.Price_per_lead__c = 1;
        instOfOppSec.Years__c= '1';
        instOfOppSec.LeadSource = 'ACD-PS';
        instOfOppSec.MSA_Code__c = instOfMulPropBund.MSA_Code__c;
        instOfOppSec.ContractReceived__c = system.today();
        //instOfOppSec.Deal_Year__c = '1';
        instOfOppSec.MYD_Deal__c = 'First Year';
        instOfOppSec.Deal_Year__c = '1';
        instOfOppSec.New_Amount__c = 1000;
        instOfOppSec.Parent_Upsell__c = 'Primary';
       // instOfOppSec.Send_This_To_Tract__c = true;
        //instOfOppSec.TRACT2__Tract_Sales_Order__c='179';
        instOfOppSec.Forex_rate__c = 1;
       // instOfOppSec.Price_per_lead__c = 1;
        instOfOppSec.Clubbed_Opportunity__c = true;
       // instOfOppSec.Clubbed_Tract_Billing_Account__c = 'abcd1234';
        instOfOppSec.License_Type__c = '1/2 Diamond';
        instOfOppSec.ContractEndDate__c = system.today();
        insert instOfOppSec;
        
        Contract_Reviewing__c  cObj = new Contract_Reviewing__c();
        cObj.Canx_Contract_Reviewer__c ='Abhishek Pandey';
        cobj.Opportunity__C= instOfOppSec.id;
        cobj.Type_Of_Cancellation__c = 'Bad Debt';
        cobj.Is_Cancellation__c = true;
        cobj.Is_Hybrid__c = true;
        insert cobj;
        
        cobj.Canx_Contract_Review_Ok__c = 'No';
        update cobj;
        
        
        cObj = new Contract_Reviewing__c();
        cObj.Canx_Contract_Reviewer__c ='Abhishek Pandey';
        cobj.Opportunity__C= instOfOppSec.id;
        cobj.Type_Of_Cancellation__c = 'Withhold Tax Cancellation';
        cobj.Is_Cancellation__c = true;
        cobj.Is_Hybrid__c = true;
        insert cobj;
        
        cobj.Canx_Contract_Review_Ok__c = 'No';
        update cobj;
        
        cObj = new Contract_Reviewing__c();
        cObj.Canx_Contract_Reviewer__c ='Abhishek Pandey';
        cobj.Opportunity__C= instOfOppSec.id;
        cobj.Type_Of_Cancellation__c = 'Billing Error';
        cobj.Is_Cancellation__c = true;
        cobj.Is_Hybrid__c = true;
        insert cobj;
        
        cobj.Canx_Contract_Review_Ok__c = 'No';
        update cobj;
        
        test.startTest();
        cObj = new Contract_Reviewing__c();
        cObj.Canx_Contract_Reviewer__c ='Abhishek Pandey';
        cobj.Opportunity__C= instOfOppSec.id;
        cobj.Type_Of_Cancellation__c = 'Billing Error';
        cobj.Is_Cancellation__c = true;
        insert cobj;
        
        cobj.Canx_Contract_Review_Ok__c = 'Yes';
        update cobj;
        
        cObj = new Contract_Reviewing__c();
        cObj.Canx_Contract_Reviewer__c ='Abhishek Pandey';
        cobj.Opportunity__C= instOfOppSec.id;
        cobj.Type_Of_Cancellation__c = 'Withhold Tax Cancellation';
        cobj.Is_Cancellation__c = true;
        insert cobj;
        
        cobj.Canx_Contract_Review_Ok__c = 'Yes';
        update cobj;
        
        cObj = new Contract_Reviewing__c();
        cObj.Canx_Contract_Reviewer__c ='Abhishek Pandey';
        cobj.Opportunity__C= instOfOppSec.id;
        cobj.Type_Of_Cancellation__c = 'Bad Debt';
        cobj.Is_Cancellation__c = true;
        insert cobj;
        
        cobj.Canx_Contract_Review_Ok__c = 'Yes';
        update cobj;
        test.stopTest();
    }
    static testMethod void Nineteen(){
        RecordType instOfRecType = [SELECT Id FROM RecordType WHERE SobjectType='Opportunity' And DeveloperName='Event' And IsActive=true];
        Opportunity instOfOppSec = TestUtil.createOpportunityNew('Test Opportunity','Closed Won',instOfCon.Id,instofAcc.Id);
        //instOfOpp.Opportunity_Start_Date__c = system.today();
        instOfOppSec.License_Type__c = 'Diamond Plus';
        instOfOppSec.Contract_Type_Test__c = 'Renewal';
        instOfOppSec.Counted_sales_Cancellation_Value__c =110;
        instOfOppSec.Liquidation_Fee__c  = 10;
        instOfOppSec.OptOutDate__c = system.today();
        instOfOppSec.Opp_End_Date__c  = system.today();
        instOfOppSec.Product__c = 'CrowdCompass';
        instOfOppSec.Contract_Number_New__c = '255122';
        instOfOppSec.New_Type__c =  'Upsell-NBB';
        instOfOppSec.CloseDate = system.today();
        instOfOppSec.RecordTypeId = instOfRecType.Id;
        instOfOppSec.Year_1_at_Risk__c = 11;
        instOfOppSec.New_Type__c = 'Test';
        instOfOppSec.Deal_Booked_In__c = 'UK Books';
       // instOfOppSec.Price_per_lead__c = 1;
        instOfOppSec.Years__c= '1';
        instOfOppSec.LeadSource = 'ACD-PS';
        instOfOppSec.MSA_Code__c = instOfMulPropBund.MSA_Code__c;
        instOfOppSec.ContractReceived__c = system.today();
        //instOfOppSec.Deal_Year__c = '1';
        instOfOppSec.MYD_Deal__c = 'First Year';
        instOfOppSec.Deal_Year__c = '1';
        instOfOppSec.New_Amount__c = 1000;
        instOfOppSec.Parent_Upsell__c = 'Primary';
       // instOfOppSec.Send_This_To_Tract__c = true;
        //instOfOppSec.TRACT2__Tract_Sales_Order__c='179';
        instOfOppSec.Forex_rate__c = 1;
       // instOfOppSec.Price_per_lead__c = 1;
        instOfOppSec.Clubbed_Opportunity__c = true;
       // instOfOppSec.Clubbed_Tract_Billing_Account__c = 'abcd1234';
        instOfOppSec.License_Type__c = '1/2 Diamond';
        instOfOppSec.ContractEndDate__c = system.today();
        insert instOfOppSec;
        
        //test.startTest();
        Contract_Reviewing__c cObj = new Contract_Reviewing__c();
        cObj.Canx_Contract_Reviewer__c ='Abhishek Pandey';
        cobj.Opportunity__C= instOfOppSec.id;
        cobj.Type_Of_Cancellation__c = 'Billing Error';
        cobj.Is_Cancellation__c = true;
        insert cobj;
        
        cobj.Canx_Contract_Review_Ok__c = 'No';
        update cobj;
        
        cObj = new Contract_Reviewing__c();
        cObj.Canx_Contract_Reviewer__c ='Abhishek Pandey';
        cobj.Opportunity__C= instOfOppSec.id;
        cobj.Type_Of_Cancellation__c = 'Withhold Tax Cancellation';
        cobj.Is_Cancellation__c = true;
        insert cobj;
        
        cobj.Canx_Contract_Review_Ok__c = 'No';
        update cobj;
        
        cObj = new Contract_Reviewing__c();
        cObj.Canx_Contract_Reviewer__c ='Abhishek Pandey';
        cobj.Opportunity__C= instOfOppSec.id;
        cobj.Type_Of_Cancellation__c = 'Bad Debt';
        cobj.Is_Cancellation__c = true;
        insert cobj;
        
        cobj.Canx_Contract_Review_Ok__c = 'No';
        update cobj;
        
        cObj = new Contract_Reviewing__c();
        cObj.Tax_Reviewer__c ='Abhishek Pandey';
        cobj.Opportunity__C= instOfOppSec.id;
        cobj.Type_Of_Cancellation__c = 'Bad Debt';
        cobj.Is_Cancellation__c = true;
        insert cobj;
        
        cobj.Tax_Review_Ok__c = 'No';
        update cobj;
        
        test.startTest();
        cObj = new Contract_Reviewing__c();
        cObj.Tax_Reviewer__c ='Abhishek Pandey';
        cobj.Opportunity__C= instOfOppSec.id;
        cobj.Type_Of_Cancellation__c = 'Bad Debt';
        cobj.Is_Cancellation__c = true;
        insert cobj;
        
        cobj.Tax_Review_Ok__c = 'No';
        update cobj;
        
        cObj = new Contract_Reviewing__c();
        cObj.Canx_Implementation_Team__c ='Abhishek Pandey';
        cobj.Opportunity__C= instOfOppSec.id;
        cobj.Type_Of_Cancellation__c = 'Withhold Tax Cancellation';
        cobj.Is_Cancellation__c = true;
        cobj.Is_Hybrid__c = true;
        cobj.Canx_Team_OK__c = 'Re-Review';
        insert cobj;
        
        cobj.Canx_Team_OK__c = 'Yes';
        update cobj;
        
        cObj = new Contract_Reviewing__c();
        cObj.Canx_Accounting_Reviewer_Hybrid_Feature__c ='Abhishek Pandey';
        cobj.Opportunity__C= instOfOppSec.id;
        cobj.Type_Of_Cancellation__c = 'Withhold Tax Cancellation';
        cobj.Is_Cancellation__c = true;
        insert cobj;
        
        cobj.Canx_Accounting_Hybrid_Review_Ok__c = 'Yes';
        update cobj;
        
        
        cObj = new Contract_Reviewing__c();
        cObj.Canx_Accounting_Reviewer_Hybrid_Feature__c ='Abhishek Pandey';
        cobj.Opportunity__C= instOfOppSec.id;
        cobj.Type_Of_Cancellation__c = 'Withhold Tax Cancellation';
        cobj.Is_Cancellation__c = true;
        insert cobj;
        
        cobj.Canx_Accounting_Hybrid_Review_Ok__c = 'No';
        update cobj;
        test.stopTest();
    }
    
    static testMethod void Twenty(){
        RecordType instOfRecType = [SELECT Id FROM RecordType WHERE SobjectType='Opportunity' And DeveloperName='Event' And IsActive=true];
                    
        Cancellations_Super_Users__c cc= new Cancellations_Super_Users__c();        
        cc.Name = UserInfo.getUserId();     
        cc.Username__c = UserInfo.getUserName();        
        insert cc;      
     
     
        Opportunity instOfOppSec = TestUtil.createOpportunityNew('Test Opportunity','Closed Won',instOfCon.Id,instofAcc.Id);
        //instOfOpp.Opportunity_Start_Date__c = system.today();
        instOfOppSec.License_Type__c = 'Diamond Plus';
        instOfOppSec.Contract_Type_Test__c = 'Renewal';
        instOfOppSec.Counted_sales_Cancellation_Value__c =110;
        instOfOppSec.Liquidation_Fee__c  = 10;
        instOfOppSec.OptOutDate__c = system.today();
        instOfOppSec.Opp_End_Date__c  = system.today();
        instOfOppSec.Product__c = 'CrowdCompass';
        instOfOppSec.Contract_Number_New__c = '2551234';
        instOfOppSec.New_Type__c =  'Upsell-NBB';
        instOfOppSec.CloseDate = system.today();
        instOfOppSec.RecordTypeId = instOfRecType.Id;
        instOfOppSec.Year_1_at_Risk__c = 11;
        instOfOppSec.New_Type__c = 'Test';
        instOfOppSec.Deal_Booked_In__c = 'UK Books';
        //instOfOppSec.Price_per_lead__c = 1;
        instOfOppSec.Years__c= '1';
        instOfOppSec.LeadSource = 'ACD-PS';
        instOfOppSec.MSA_Code__c = instOfMulPropBund.MSA_Code__c;
        instOfOppSec.ContractReceived__c = system.today();
        //instOfOppSec.Deal_Year__c = '1';
        instOfOppSec.MYD_Deal__c = 'First Year';
        instOfOppSec.Deal_Year__c = '1';
        instOfOppSec.New_Amount__c = 1000;
        instOfOppSec.Parent_Upsell__c = 'Primary';
       // instOfOppSec.Send_This_To_Tract__c = true;
        
        instOfOppSec.Forex_rate__c = 1;
       // instOfOppSec.Price_per_lead__c = 1;
        instOfOppSec.Clubbed_Opportunity__c = true;
        //instOfOppSec.Clubbed_Tract_Billing_Account__c = 'abcd1234';
        instOfOppSec.License_Type__c = '1/2 Diamond';
        instOfOppSec.ContractEndDate__c = system.today();
        //instOfOppSec.TRACT2__Tract_Sales_Order__c='179';
        insert instOfOppSec;   
        
        //instOfOppSec.Contract_Implemented__c = true;
        //update instOfOppSec;
        Feature_Set__c instOfFSetForYearDGSecond = new Feature_Set__c();
        instOfFSetForYearDGSecond.Opportunity_N__c = instOfOppSec.Id;
        instOfFSetForYearDGSecond.Feature__c = 'Custom Work SLM' ;
        insert instOfFSetForYearDGSecond;
        
        BillingCase__c instOfBilC = new BillingCase__c();
        instOfBilC.CustomersAccount__c = instofAcc.id;
        instOfBilC.CVII_Number__c = '32323';
        instOfBilC.Name = 'Test';
        insert instOfBilC;
        
        //added by kumud on 30/05/18
        WriteOff__c instOfWriteOff = new WriteOff__c();
        //instOfWriteOff.Type_of_Cancellation__c = 'Withhold Tax Cancellation';
        instOfWriteOff.Type_of_Cancellation__c = 'Billing Errors';
        instOfWriteOff.Product__c = 'Event';
        instOfWriteOff.Contract__c = '2551234';
        instOfWriteOff.Shut_Down_Required__c = 'No';
        instOfWriteOff.Write_Off_Status__c = 'Initially Approved';
        instOfWriteOff.New_TCV_To_Be_Moved__c ='Yes';
        instOfWriteOff.Customer_Name__c = instOfBilC.id;
        instOfWriteOff.Sale_Impact__c = 'No';
        instOfWriteOff.Commission_Impact__c = 'No';
        instOfWriteOff.Time_taken_for_Cancellation__c = 10;       
        insert instOfWriteOff;
        
        
        instOfWriteOff.Write_Off_Status__c = 'Submitted for Review';
        update instOfWriteOff;
        
        delete instOfWriteOff;
        undelete instOfWriteOff;
        
    }


    // Returns a dynamic SOQL statement for the whole object, includes only creatable fields since we will be inserting a cloned result of this query
    public static string getCreatableFieldsSOQL(String objectName){
         
        String selects = '';
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
         
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.isCreateable()){ // field is creatable
                    selectFields.add(fd.getName());
                }
            }
        }
         
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
             
        }
         
        return 'SELECT ' + selects + ' FROM ' + objectName + ' WHERE Id=: ';
         
    }
    // Returns a dynamic SOQL statement for the whole object, includes only creatable fields since we will be inserting a cloned result of this query
        
}