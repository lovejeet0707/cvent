/*    
Author :Kumud thakur
Desc: Test class for ContractTriggerHelper class and AssignReviewerOpptyTriggerHelper . Both these class are use for Tract Requirements

Version 2.0
Date:7th Nov 2016
Description : Migrating FEATURESET to PRODUCT/PRICEBOOK. Below are the name of the field which needs to be replaced - 

OLD FIELD NAME       = NEW FIELD NAME

Feature_Sets__r      = OpportunityLineItems;
R00N00000008aGEXEA2  = OpportunityLineItems;
Feature_Set__c       = OpportunityLineItem;
Feature__c           = Product_Name__c;
Product__c           = Product__c;
Opportunity_N__c     = OpportunityId; 
RecordType.DeveloperName = Product_Family__c; // Changed this from RecordType.DeveloperName to ProductFamily as now the concept of recordtype is finished
//Lines Commented as Can't update CurrencyISOCode of OpportunityLineItem
//Lines Commented as no need to update the PRODUCT NAME as it's a formula field in the OpportunityLineItem and earlier it was Picklist in FEATURESET
//Lines Commented as their is no concept left of recordtype....

Modified BY :kumud |30 may 2018 |Desc : Commented mentioned field :Contract_Total_Year_1_Rev_Rec_Rule_Assgn__c
Contract_Total_Year_2_Rev_Rec_Rule_Assgn__c,Contract_Total_Year_3_Rev_Rec_Rule_Assgn__c,Contract_Total_Year_4_Rev_Rec_Rule_Assgn__c,Contract_Total_Year_5_Rev_Rec_Rule_Assgn__c,Contract_Type_Rev_Rec__c
*/

@isTest(seeAllData=false)
private class ContractTriggerHelperTest {
    
    
    Private Static RRATracker__c rRATracker;
    Private Static TrackUser__c trackUser;
    Private Static Opportunity instOfOppFIF;
    Private static Superuser__c superUSer;
    Private static HybridPicklistValue__c hybridPickList;
    Private static OpportunityLineItem hybridFeature;
    Static List<Opportunity> listOppty;
    Static List<Contract_Reviewing__c> contractReview;
    Static Id pricebookEntryId;
    
    //Added by kumud
    static {
        
        
        UserAssignment__c instUA = new UserAssignment__c();
        instUA.Name = 'Integrated_Events';
        instUA.User_id__c = userinfo.getUserID();
        instUA.UserName__c = 'Brett Wischow';
        insert instUA;
    }
    public static Id createAccount(){
        RecordType rtType = [SELECT r.SobjectType, r.DeveloperName,r.IsActive FROM RecordType r WHERE SobjectType='Account' And DeveloperName='Biz_Ac' And IsActive=true];
        Account instofAcc = new Account();
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        instofAcc.RecordTypeId = rtType.id;
        instofAcc.Name = 'Test';
        instofAcc.Named_Acct__c = 'Cvent Vendor';
        instofAcc.BillingCountryCode = 'US';
        instofAcc.BillingStateCode = 'NY';
        insert instofAcc;
        return instofAcc.id;
    }
    
    Public static void creatOpportunity(){
        
        Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true);
        insert pbk1;
        
        Product2 prd1 = new Product2 (Name='Attendee Hub',Description='Test Product Entry 1',productCode = 'ABC', isActive = true);
        insert prd1;
        
        //get standard pricebook
        //Pricebook2  standardPb = [select id, name, isActive from Pricebook2 where IsStandard = true limit 1];
        Id priceBookId = Test.getStandardPricebookId();
        
        /*PricebookEntry standPriceBook= new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPb.Id,UnitPrice=50, isActive=true);
insert standPriceBook;*/
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=priceBookId,UnitPrice=50, isActive=true);
        insert pbe1;
        pricebookEntryId = pbe1.Id;
        
        listOppty=new List<Opportunity>();
        contractReview=new List<Contract_Reviewing__c>();
        instOfOppFIF = new Opportunity();
        //instOfOpp.Opportunity_Start_Date__c = system.today();
        instOfOppFIF.Contract_Type_Test__c = 'Renewal';
        instOfOppFIF.Forex_rate__c = 1;
        instOfOppFIF.Liquidation_Fee__c  = 10;
        instOfOppFIF.OptOutDate__c = system.today();
        instOfOppFIF.Opp_End_Date__c  = system.today();
        instOfOppFIF.AccountId =createAccount() ;
        instOfOppFIF.Forex_rate__c = 1;
        //  instOfOppFIF.Price_per_lead__c = 1;
        instOfOppFIF.Name = 'Test_Oppty1';
        instOfOppFIF.Counted_sales_Cancellation_Value__c =110;
        instOfOppFIF.Product__c = 'Event';
        instOfOppFIF.Contract_Number_New__c = '12345';
        instOfOppFIF.New_Type__c =  'Upsell-NBB';
        instOfOppFIF.StageName = 'Verbal';
        instOfOppFIF.CloseDate = system.today();
        // instOfOppFIF.RecordTypeId = instOfRecType.Id;
        instOfOppFIF.Year_1_at_Risk__c = 11;
        instOfOppFIF.New_Type__c = 'Test';
        instOfOppFIF.Deal_Booked_In__c = '5';
        // instOfOppFIF.Price_per_lead__c = 1;
        instOfOppFIF.Years__c= '1';
        instOfOppFIF.LeadSource = 'ACD-PS';
        //instOfOppFIF.Contact_Associated__c = instOfCon.Id;
        instOfOppFIF.Contact_Role__c = 'Influencer';
        //instOfOppFIF.MSA_Code__c = instOfMulPropBund.MSA_Code__c;
        instOfOppFIF.Contract_Implemented__c = false;
        instOfOppFIF.ContractReceived__c = system.today();
        instOfOppFIF.Deal_Year__c = '4';
        instOfOppFIF.MaintenanceFee__c = 1000;
        instOfOppFIF.New_Amount__c = 1000;
        //instOfOppFIF.Discount__c = 1000;
        instOfOppFIF.Convinience_Fee__c = 1000;
        instOfOppFIF.of_Leads_Purchased__c = 1000;
        instOfOppFIF.Price_Adjustment__c = 1000;
        //instOfOppFIF.Contract_Total_Tract_Review__c=100000000;
        //instOfOppFIF.Rev_Rec_Rule_Assigned__c='1.Standard Contract';
        instOfOppFIF.MYD_Deal__c = 'First Year';
        instOfOppFIF.Parent_Upsell__c = 'Primary';
        
        
        instOfOppFIF.Pricebook2Id = pbe1.Pricebook2Id;
        insert instOfOppFIF;
        
        test.startTest();
        createFeature();
        User instUsr = TestUtil.CreateDeploymentUser();
        insert instUsr;
        
        
        //instOfOppFIF.Contract_Implemented__c=true;
        //update instOfOppFIF;
        
        Contract_Reviewing__c oppContract=new Contract_Reviewing__c();
        oppContract.Opportunity__c=instOfOppFIF.Id;
        oppContract.Accounting_Review_Ok__c='Re-Review';
        oppContract.Acc_Review_Post_Rev_Rec_OK__c='Re-Review';
        oppContract.Contract_Value_50k_review_Ok__c='Re-Review';
        
        
        
        insert oppContract;
        
        test.stopTest();
        
    }
    
    Public static void createFeature(){
        hybridFeature=new OpportunityLineItem ();
        //hybridFeature.Feature__c='Test';
        hybridFeature.OpportunityID=instOfOppFIF.Id;
        hybridFeature.PriceBookEntryID=pricebookEntryId;
        hybridFeature.quantity=4;
        hybridFeature.totalprice=200;
        insert hybridFeature;
    }
    
    Public static void createCustomSetting(String name,String tractName,String superUserName,string hybridName){
        
        rRATracker=new RRATracker__c();
        rRATracker.name=name;
        rRATracker.RoundRobinId__c=0;
        rRATracker.User_Name__c='Harish Arora';
        insert rRATracker;
        
        // custom setting       
        trackUser =new TrackUser__c();
        trackUser.Name=tractName;
        trackUser.Name__c='Sumit Jain';
        trackUser.Name_Level_2__c='Jitendra Kumar';
        trackUser.Name_Level_3__c='Abhishek Oberoi';
        trackUser.Product_Name__c='Event';
        insert trackUser;
        
        superUSer=new Superuser__c();
        superUSer.name=superUserName;
        superUSer.SuperUserName__c='Jitendra Kumar';
        insert superUSer;
        
        
        hybridPickList=new HybridPicklistValue__c();
        hybridPickList.name=hybridName;
        hybridPickList.HybridValue__c='Test';
        insert hybridPickList;
        
        TractLevel4User__C topLevelUSer=new TractLevel4User__C();
        topLevelUSer.name=name;
        topLevelUSer.name__C='Courtney Hansen';
        insert topLevelUSer;
        
        Cancellation_Categorization__c instOfCanCat = new Cancellation_Categorization__c();
        instOfCanCat.Type__c = 'Type 1';
        instOfCanCat.Name = 'Bad Debts';
        insert instOfCanCat;
        
        instOfCanCat = new Cancellation_Categorization__c();
        instOfCanCat.Type__c = 'Type 2';
        instOfCanCat.Name = 'Billing Error';
        insert instOfCanCat;
        
        instOfCanCat = new Cancellation_Categorization__c();
        instOfCanCat.Type__c = 'Type 3';
        instOfCanCat.Name = 'Withhold Tax Cancellation';
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
        
        
        Cancellations_Super_Users__c cc= new Cancellations_Super_Users__c();        
        cc.Name = UserInfo.getUserId();     
        cc.Username__c = UserInfo.getUserName();        
        insert cc;      
        
        
    }
    static Contract_Reviewing__c cReviewTract;
    static  Opportunity TractOpp;
    
    Public static testMethod void validateContractCreate_level1(){
        creatOpportunity();
        
        createCustomSetting('3Tests','3Tests','3Tests','3Tests');       
        
        // Get contract insert on contract implement at opportuity
        Contract_Reviewing__c cReview=[select Contract_Reviewer__c,Contract_Review_Ok__c,Accounting_Review_Ok__c from Contract_Reviewing__c where Opportunity__c =:instOfOppFIF.id  LIMIT 1];
        if(cReview.Contract_Reviewer__c==null)
            cReview.Contract_Reviewer__c='Jitendra Kumar';
        
        System.runAs(createUSer(cReview.Contract_Reviewer__c,1)) {
            Contract_Reviewing__c cReviewUpdate=[select Contract_Reviewer__c,Contract_Review_Ok__c,Accounting_Review_Ok__c from Contract_Reviewing__c where Opportunity__c =:instOfOppFIF.id  LIMIT 1];
            // cReviewUpdate.Contract_Review_Ok__c='Yes';
            cReviewUpdate.Accounting_Review_Ok__c='No';
            cReviewUpdate.AR_Level_1_Rejection_Reason__c='Revenue Rule Error';
            
            update cReviewUpdate;
            
            
            
        }
        
        
    }
    
    Public static testMethod void validateContractCreate_level2(){
        creatOpportunity();
        createCustomSetting('3Test','3Test','3Test','3Test');       
        
        // Get contract insert on contract implement at opportuity
        Contract_Reviewing__c cReview=[select Contract_Reviewer__c,Contract_Review_Ok__c,Acc_Review_Post_Rev_Rec_OK__c from Contract_Reviewing__c where Opportunity__c =:instOfOppFIF.id  LIMIT 1];
        if(cReview.Contract_Reviewer__c==null)
            cReview.Contract_Reviewer__c='Jitendra Kumar';  
        System.runAs(createUSer(cReview.Contract_Reviewer__c,1)) {
            Contract_Reviewing__c cReviewUpdate=[select Contract_Reviewer__c,Contract_Review_Ok__c,Acc_Review_Post_Rev_Rec_OK__c from Contract_Reviewing__c where Opportunity__c =:instOfOppFIF.id  LIMIT 1];
            // cReviewUpdate.Contract_Review_Ok__c='Yes';
            cReviewUpdate.Acc_Review_Post_Rev_Rec_OK__c='No';
            cReviewUpdate.AR_Level_2_Rejection_Reason__c='Revenue Rule Error';
            
            update cReviewUpdate;
            //Opportunity oppty=[select id from Opportunity where recordtype.name='Tract'];
            // system.debug('****************........oppty'+oppty);
            
        }
        
        
    }
    
    Private static testmethod void ValidateContractTractLevel3(){
        
        createCustomSetting('1Test','1Test','1Test','1Test');
        
        creatOpportunity();
        cReviewTract=[select Contract_Value_50k__c,Contract_Value_50k_review_Ok__c from Contract_Reviewing__c where Opportunity__c =:instOfOppFIF.id LIMIT 1];
        if(cReviewTract.Contract_Value_50k__c==null)
            cReviewTract.Contract_Value_50k__c='Jitendra Kumar';
        System.runAs(createUSer(cReviewTract.Contract_Value_50k__c,4)) {
            
            cReviewTract.Contract_Value_50k_review_Ok__c='No';
            cReviewTract.AR_Level_3_Rejection_Reason__c='Test';
            update cReviewTract;
            
        }    
    }   
    Private static testmethod void ValidateContractTractLevel4(){
        creatOpportunity(); 
        cReviewTract=[select Contract_Value_100k_review_Ok__c,Contract_Value_100k__c from Contract_Reviewing__c where Opportunity__c =:instOfOppFIF.id  LIMIT 1];
        if(cReviewTract.Contract_Value_100k__c==null)
            cReviewTract.Contract_Value_100k__c='Jitendra Kumar';
        System.runAs(createUSer(cReviewTract.Contract_Value_100k__c,4)) {
            
            cReviewTract.Contract_Value_100k_review_Ok__c='Yes';
            cReviewTract.AR_Level_4_Rejection_Reason__c='Test';
            update cReviewTract;
            
        }    
        
    }    
    
    Private static testmethod void ValidateContractTractLevel4_No(){
        creatOpportunity(); 
        cReviewTract=[select Contract_Value_100k_review_Ok__c,Contract_Value_100k__c from Contract_Reviewing__c where Opportunity__c =:instOfOppFIF.id  LIMIT 1];
        if(cReviewTract.Contract_Value_100k__c==null)
            cReviewTract.Contract_Value_100k__c='Jitendra Kumar';
        System.runAs(createUSer(cReviewTract.Contract_Value_100k__c,4)) {
            
            cReviewTract.Contract_Value_100k_review_Ok__c='No';
            cReviewTract.AR_Level_4_Rejection_Reason__c='Test';
            update cReviewTract;
            
        }    
        
    }   
    
    Public static testMethod void validateContractCreate_5(){
        creatOpportunity();
        createCustomSetting('3Testss','3Testss','3Testss','3Testss');       
        
        
        System.runAs(createUSer('Jitendra Kumar',1)) {
            Contract_Reviewing__c cReview=[select Contract_Reviewer__c,Contract_Value_50k_review_Ok__c,Accounting_Review_Ok__c,Acc_Review_Post_Rev_Rec_OK__c from Contract_Reviewing__c where Opportunity__c =:instOfOppFIF.id  LIMIT 1];
            // cReviewUpdate.Contract_Review_Ok__c='Yes';
            cReview.Accounting_Review_Ok__c='Yes';
            cReview.Contract_Value_50k_review_Ok__c='Yes';
            cReview.Acc_Review_Post_Rev_Rec_OK__c='Yes';
            
            update cReview;
            
            
        }
        
        
    }   
    
    
    Private  static testMethod void validateContractCreate_hybrid(){
        creatOpportunity(); 
        createCustomSetting('2Test','2Test','2Test','2Test');
        Contract_Reviewing__c cReview_hybrid=new Contract_Reviewing__c();
        cReview_hybrid.Accounting_Reviewer_Hybrid_Feature__c='Sumit Jain';
        cReview_hybrid.Opportunity__c=instOfOppFIF.id;
        insert cReview_hybrid;
        System.runAs(createUSer(cReview_hybrid.Accounting_Reviewer_Hybrid_Feature__c,0)) {
            Contract_Reviewing__c cReviewUpdate=[select Accounting_Reviewer_Hybrid_Feature__c,Accounting_Hybrid_Review_Ok__c from Contract_Reviewing__c where id =:cReview_hybrid.id  LIMIT 1];
            cReviewUpdate.Accounting_Hybrid_Review_Ok__c='Yes';
            
            update cReviewUpdate;
            
            
            
        }
        
        
    }
    Private  static testMethod void validateContractCreate_hybrid_No(){
        creatOpportunity(); 
        createCustomSetting('2Test','2Test','2Test','2Test');
        Contract_Reviewing__c cReview_hybrid=new Contract_Reviewing__c();
        cReview_hybrid.Accounting_Reviewer_Hybrid_Feature__c='Sumit Jain';
        cReview_hybrid.Opportunity__c=instOfOppFIF.id;
        cReview_hybrid.Acc_Reviewer_Comments_Hybrid__c='testHybrid comment';
        insert cReview_hybrid;
        // Get contract insert on contract implement at opportuity
        // Contract_Reviewing__c cReview=[select Accounting_Reviewer_Hybrid_Feature__c,Accounting_Hybrid_Review_Ok__c from Contract_Reviewing__c where id=:cReview_hybrid.id];
        System.runAs(createUSer(cReview_hybrid.Accounting_Reviewer_Hybrid_Feature__c,1)) {
            Contract_Reviewing__c cReviewUpdate=[select Accounting_Reviewer_Hybrid_Feature__c,Accounting_Hybrid_Review_Ok__c from Contract_Reviewing__c where id =:cReview_hybrid.id  LIMIT 1];
            cReviewUpdate.Accounting_Hybrid_Review_Ok__c='No';
            
            update cReviewUpdate;
        }       
    }
    
    
    
    Private  static testMethod void validateContractCreate_withouthybridNO(){
        creatOpportunity(); 
        Contract_Reviewing__c objcReview =new Contract_Reviewing__c();
        objcReview.Contract_Reviewer__c='Sumit Jain';
        objcReview.Opportunity__c=instOfOppFIF.id;
        objcReview.Contract_Review_Ok__c='Re-Review';
        //objcReview.Accounting_Review_Ok__c=null;
        insert objcReview;
        // Get contract insert on contract implement at opportuity
        //  Contract_Reviewing__c cReview=[select Accounting_Reviewer_Hybrid_Feature__c,Accounting_Hybrid_Review_Ok__c from Contract_Reviewing__c where id=:cReview_hybrid.id];
        System.runAs(createUSer(objcReview.Contract_Reviewer__c,10)) {
            Contract_Reviewing__c cReviewUpdate=[select Contract_Reviewer__c,Contract_Review_Ok__c from Contract_Reviewing__c where id =:objcReview.id  LIMIT 1];
            cReviewUpdate.Contract_Review_Ok__c='No';
            cReviewUpdate.Contract_Review_Comments__c='test';
            // objcReview.Accounting_Review_Ok__c='No';
            update cReviewUpdate;
            
        }
        
    }   
    
    
    Private static User createUSer(String Name,integer userCode){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; //Finance - Contract Implementation Team
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName=Name, LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName=userCode+'deploymentuser@cvent.com');
        return u;
    }
    
    Private static void createTractOpportunity(){
        
        
        
        createCustomSetting('2Testss','2Testss','2Testss','2Testss');
        
        RecordType instOfRecType = [SELECT Id FROM RecordType WHERE SobjectType='Opportunity' And DeveloperName='Event' And IsActive=true];
        TractOpp = new Opportunity();
        //instOfOpp.Opportunity_Start_Date__c = system.today();
        TractOpp.Contract_Type_Test__c = 'Renewal';
        TractOpp.recordtypeid=instOfRecType.id;
        TractOpp.Forex_rate__c = 1;
        TractOpp.Liquidation_Fee__c  = 10;
        TractOpp.OptOutDate__c = system.today();
        TractOpp.Opp_End_Date__c  = system.today();
        TractOpp.AccountId =createAccount() ;
        TractOpp.Forex_rate__c = 1;
        // TractOpp.Price_per_lead__c = 1;
        TractOpp.Name = 'Test';
        TractOpp.Counted_sales_Cancellation_Value__c =110;
        TractOpp.Product__c = 'Event';
        TractOpp.Contract_Number_New__c = '6789';
        TractOpp.New_Type__c =  'Upsell-NBB';
        TractOpp.StageName = 'Verbal';
        TractOpp.CloseDate = system.today();
        // TractOpp.RecordTypeId = instOfRecType.Id;
        TractOpp.Year_1_at_Risk__c = 11;
        TractOpp.New_Type__c = 'Test';
        TractOpp.Deal_Booked_In__c = '5';
        // TractOpp.Price_per_lead__c = 1;
        TractOpp.Years__c= '1';
        TractOpp.LeadSource = 'ACD-PS';
        //TractOpp.Contact_Associated__c = instOfCon.Id;
        TractOpp.Contact_Role__c = 'Influencer';
        //TractOpp.MSA_Code__c = instOfMulPropBund.MSA_Code__c;
        TractOpp.Contract_Implemented__c = false;
        TractOpp.ContractReceived__c = system.today();
        TractOpp.Deal_Year__c = '4';
        TractOpp.MaintenanceFee__c = 1000;
        TractOpp.New_Amount__c = 1000;
        // TractOpp.Discount__c = 1000;
        TractOpp.Convinience_Fee__c = 1000;
        TractOpp.of_Leads_Purchased__c = 1000;
        //TractOpp.Events__c = 1000;
        TractOpp.Price_Adjustment__c = 1000;
        TractOpp.MYD_Deal__c = 'second Year';
        TractOpp.Parent_Upsell__c = 'Primary';
        TractOpp.Exchange_Rate__c=10;
        TractOpp.Contract_Total_Tract__c=10000000;
        
        insert TractOpp;
        
        Contract_Reviewing__c oppContract=new Contract_Reviewing__c();
        oppContract.Opportunity__c=TractOpp.Id;
        oppContract.Accounting_Team_Reviewer__c='Sumit Jain';
        insert oppContract;
        
    }
    public static testmethod void Tract(){
        
        createTractOpportunity();
        
        Contract_Reviewing__c cObj = new Contract_Reviewing__c();
        cObj.Canx_Contract_Reviewer__c ='Abhishek Pandey';
        cobj.Opportunity__C= TractOpp.Id;
        cobj.Type_Of_Cancellation__c = 'Billing Error';
        cobj.Is_Cancellation__c = true;
        cobj.Is_Hybrid__c =true;
        cobj.Canx_Contract_Review_Ok__c ='No';
        insert cobj;
        
        
        cobj.Canx_Contract_Review_Ok__c ='No';
        update cobj;
        
    }
    
    public static testmethod void validateCancellation(){
        
        createCustomSetting('2Testss','2Testss','2Testss','2Testss');
        creatOpportunity();
        
        Contract_Reviewing__c cObj = new Contract_Reviewing__c();
        cObj.Canx_Contract_Reviewer__c ='Abhishek Pandey';
        cobj.Opportunity__C= instOfOppFIF.id;
        cobj.Type_Of_Cancellation__c = 'Billing Error';
        cobj.Is_Cancellation__c = true;
        cobj.Is_Hybrid__c =true;
        cobj.Write_Off_Associated__c='Test';
        insert cobj;
        
        cobj.Canx_Contract_Review_Ok__c = 'No';
        update cobj;
        
        cObj = new Contract_Reviewing__c();
        cObj.Canx_Contract_Reviewer__c ='Abhishek Pandey';
        cobj.Opportunity__C= instOfOppFIF.id;
        cobj.Type_Of_Cancellation__c = 'Withhold Tax Cancellation';
        cobj.Is_Cancellation__c = true;
        insert cobj;
        
        cobj.Canx_Contract_Review_Ok__c = 'No';
        update cobj;
        
        cObj = new Contract_Reviewing__c();
        cObj.Canx_Contract_Reviewer__c ='Abhishek Pandey';
        cobj.Opportunity__C= instOfOppFIF.id;
        cobj.Type_Of_Cancellation__c = 'Bad Debt';
        cobj.Is_Cancellation__c = true;
        cobj.Is_Hybrid__c =true;
        insert cobj;
        
        cobj.Canx_Contract_Review_Ok__c = 'No';
        update cobj;
        
        cObj = new Contract_Reviewing__c();
        cObj.Tax_Reviewer__c ='Abhishek Pandey';
        cobj.Opportunity__C= instOfOppFIF.id;
        cobj.Type_Of_Cancellation__c = 'Bad Debt';
        cobj.Is_Cancellation__c = true;
        cobj.Is_Hybrid__c =true;
        insert cobj;
        
        cobj.Tax_Review_Ok__c = 'No';
        //cobj.Is_Cancellation__c=false;
        update cobj;
        
        
        cObj = new Contract_Reviewing__c();
        cObj.Tax_Reviewer__c ='Abhishek Pandey';
        cobj.Opportunity__C= instOfOppFIF.id;
        cobj.Type_Of_Cancellation__c = 'Bad Debt';
        cobj.Is_Cancellation__c = true;
        cobj.Is_Hybrid__c =true;
        insert cobj;
        
        cobj.Tax_Review_Ok__c = 'No';
        update cobj;
        
        cObj = new Contract_Reviewing__c();
        cObj.Canx_Implementation_Team__c ='Abhishek Pandey';
        cobj.Opportunity__C= instOfOppFIF.id;
        cobj.Type_Of_Cancellation__c = 'Withhold Tax Cancellation';
        cobj.Is_Cancellation__c = true;
        cobj.Is_Hybrid__c = true;
        cobj.Canx_Team_OK__c = 'Re-Review';
        insert cobj;
        
        cobj.Canx_Team_OK__c = 'Yes';
        update cobj;
        
        cObj = new Contract_Reviewing__c();
        cObj.Canx_Accounting_Reviewer_Hybrid_Feature__c ='Abhishek Pandey';
        cobj.Opportunity__C= instOfOppFIF.id;
        cobj.Type_Of_Cancellation__c = 'Withhold Tax Cancellation';
        cobj.Is_Cancellation__c = true;
        cobj.Is_Hybrid__c =true;
        insert cobj;
        
        cobj.Canx_Accounting_Hybrid_Review_Ok__c = 'Yes';
        cobj.Canx_Contract_Review_Ok__c ='Yes';
        update cobj;
        
        
        cObj = new Contract_Reviewing__c();
        cObj.Canx_Accounting_Reviewer_Hybrid_Feature__c ='Abhishek Pandey';
        cobj.Opportunity__C= instOfOppFIF.id;
        cobj.Type_Of_Cancellation__c = 'Withhold Tax Cancellation';
        cobj.Is_Cancellation__c = true;
        cobj.Is_Hybrid__c =true;
        insert cobj;
        
        cobj.Canx_Accounting_Hybrid_Review_Ok__c = 'No';
        cobj.Canx_Contract_Review_Ok__c ='No';
        update cobj;
        
        
    }
    //Chnages 13th june
    
    
    private  static testmethod void method1()
    {
        creatOpportunity();
        createCustomSetting('3Test','3Test','3Test','3Test');       
        
        // Get contract insert on contract implement at opportuity
        Contract_Reviewing__c cReview=[select Contract_Reviewer__c,Contract_Review_Ok__c,Acc_Review_Post_Rev_Rec_OK__c from Contract_Reviewing__c where Opportunity__c =:instOfOppFIF.id  LIMIT 1];
        
        System.runAs(createUSer('Jitendra Kumar',1)) {
            if(cReview.Contract_Reviewer__c==null)
                cReview.Contract_Reviewer__c='Jitendra Kumar';
            cReview.Accounting_Review_Ok__c='Error Correct';
            cReview.Is_Cancellation__c =false;
            update cReview;
            
            Contract_Reviewing__c cReviewUpdate=[select Contract_Reviewer__c,Contract_Review_Ok__c,Acc_Review_Post_Rev_Rec_OK__c from Contract_Reviewing__c where Opportunity__c =:instOfOppFIF.id  LIMIT 1];
            cReviewUpdate.Accounting_Review_Ok__c='Yes';
            //cReviewUpdate.Acc_Review_Post_Rev_Rec_OK__c='No';
            //cReviewUpdate.AR_Level_2_Rejection_Reason__c='Revenue Rule Error';
            
            update cReviewUpdate;
            try{
                delete cReviewUpdate;}
            catch(exception e)
            {
                
            }
        }
        
        
        
        
    }
    
    private testmethod  Static void ReReviewYesLevel2()
    {
        creatOpportunity();
        instOfOppFIF.StageName ='Tract';
        instofOppFif.Product_Category_Tract__c='test prod';
        instofOppFif.Contract_Number_New__c='123';
        update instofOppFif;
        
        createCustomSetting('3Test','3Test','3Test','3Test');
        Contract_Reviewing__c cReview = new Contract_Reviewing__c();
        System.runAs(createUSer('Jitendra Kumar',1)) {
            cReview.Opportunity__c =instOfOppFIF.id;
            //cReview.Product_Category_Tract__c ='';
            //cReview.Opportunity_Contract__c='';
            
            
            cReview.Accounting_Review_Ok__c='Re-Review';
            //cReview.Acc_Review_Post_Rev_Rec_OK__c ='Re-Review';
            insert cReview;
            
            
            if(cReview.Contract_Reviewer__c==null)
                cReview.Contract_Reviewer__c='Jitendra Kumar';
            cReview.Accounting_Review_Ok__c='yes';
            //cReview.Acc_Review_Post_Rev_Rec_OK__c ='Yes';
            
            
            update cReview;
        }
    }
    private static testmethod void ReReviewYesLevel3(){
        
        creatOpportunity();
        createCustomSetting('3Test','3Test','3Test','3Test');
        Contract_Reviewing__c cReview = new Contract_Reviewing__c();
        System.runAs(createUSer('Jitendra Kumar',1)) {
            
            cReview.Opportunity__c =instOfOppFIF.id;
            //cReview.Accounting_Review_Ok__c='Re-Review';
            cReview.Acc_Review_Post_Rev_Rec_OK__c ='Re-Review';
            insert cReview;
            if(cReview.Contract_Reviewer__c==null)
                cReview.Contract_Reviewer__c='Jitendra Kumar';
            //cReview.Accounting_Review_Ok__c='yes';
            cReview.Acc_Review_Post_Rev_Rec_OK__c ='Yes';
            
            
            update cReview;
        }
        
        
        
    }
    
    private testmethod static void validateCancellation2(){
        
        createCustomSetting('2Testss','2Testss','2Testss','2Testss');
        creatOpportunity();
        
        Contract_Reviewing__c  cObj = new Contract_Reviewing__c();
        cObj.Canx_Contract_Reviewer__c ='Abhishek Pandey';
        cobj.Opportunity__C= instOfOppFIF.id;
        cobj.Type_Of_Cancellation__c = 'Bad Debts';
        cobj.Is_Cancellation__c = true;
        cobj.Is_Hybrid__c = true;
        insert cobj;
        
        
        cobj.Canx_Contract_Review_Ok__c = 'Yes';
        update cobj;
        
        cObj = new Contract_Reviewing__c();
        cObj.Canx_Contract_Reviewer__c ='Abhishek Pandey';
        cobj.Opportunity__C= instOfOppFIF.id;
        cobj.Tax_Review_Ok__c ='No';
        cobj.Write_Off_Associated__c='test';
        cobj.Type_Of_Cancellation__c = 'Bad Debts';
        cobj.Is_Cancellation__c = true;
        cobj.Is_Hybrid__c = true;
        insert cobj;
        
        cobj.Tax_Review_Ok__c ='yes';
        cobj.Canx_Contract_Review_Ok__c = 'Yes';
        update cobj;
        
        cObj = new Contract_Reviewing__c();
        cObj.Canx_Contract_Reviewer__c ='Abhishek Pandey';
        cobj.Opportunity__C= instOfOppFIF.id;
        cobj.Type_Of_Cancellation__c = 'Withhold Tax Cancellation';
        cobj.Is_Cancellation__c = true;
        cobj.Is_Hybrid__c = true;
        insert cobj;
        
        cobj.Canx_Contract_Review_Ok__c = 'Yes';
        update cobj;
        /*For Accounting hybrid review  when changed to yes set type*/
        cObj = new Contract_Reviewing__c();
        cObj.Canx_Contract_Reviewer__c ='Abhishek Pandey';
        cobj.Opportunity__C= instOfOppFIF.id;
        cobj.Type_Of_Cancellation__c = 'Bad Debts';// for set type 1
        cobj.Is_Cancellation__c = true;
        cobj.Is_Hybrid__c = true;
        cobj.Canx_Accounting_Hybrid_Review_Ok__c='No';
        insert cobj;
        
        cobj.Canx_Accounting_Hybrid_Review_Ok__c='Yes';
        //cobj.Canx_Contract_Review_Ok__c = 'Yes';
        update cobj;
        
        cObj = new Contract_Reviewing__c();
        cObj.Canx_Contract_Reviewer__c ='Abhishek Pandey';
        cobj.Opportunity__C= instOfOppFIF.id;
        cobj.Type_Of_Cancellation__c = 'Billing Error';// for set type 2
        cobj.Is_Cancellation__c = true;
        cobj.Is_Hybrid__c = true;
        cobj.Canx_Accounting_Hybrid_Review_Ok__c='No';
        insert cobj;
        
        cobj.Canx_Accounting_Hybrid_Review_Ok__c='Yes';
        //cobj.Canx_Contract_Review_Ok__c = 'Yes';
        update cobj;
        
        
        /*ends*/
        /*Canx contract review set to No set type 1 Bad Debts */
        cObj = new Contract_Reviewing__c();
        cObj.Canx_Contract_Reviewer__c ='Abhishek Pandey';
        cobj.Opportunity__C= instOfOppFIF.id;
        cobj.Canx_Contract_Review_Comments__c='Test';
        cobj.Type_Of_Cancellation__c = 'Bad Debts';// for set type 1
        cobj.Is_Cancellation__c = true;
        cobj.Is_Hybrid__c = true;
        cobj.Canx_Contract_Review_Ok__c ='Yes';
        //cobj.Canx_Accounting_Hybrid_Review_Ok__c='Yes';
        insert cobj;
        cobj.Canx_Contract_Review_Ok__c ='Yes';
        update cobj;
        /* Ends*/
        cobj.Canx_Accounting_Hybrid_Review_Ok__c='No';
        //cobj.Canx_Contract_Review_Ok__c = 'Yes';
        update cobj;
        
        
        /*For Accounting hybrid review  when changed to No set type*/
        cObj = new Contract_Reviewing__c();
        cObj.Canx_Contract_Reviewer__c ='Abhishek Pandey';
        cobj.Opportunity__C= instOfOppFIF.id;
        cobj.Type_Of_Cancellation__c = 'Bad Debts';// for set type 1
        cobj.Is_Cancellation__c = true;
        cobj.Is_Hybrid__c = true;
        cobj.Canx_Accounting_Hybrid_Review_Ok__c='Yes';
        insert cobj;
        
        cobj.Canx_Accounting_Hybrid_Review_Ok__c='No';
        //cobj.Canx_Contract_Review_Ok__c = 'Yes';
        update cobj;
        
        cObj = new Contract_Reviewing__c();
        cObj.Canx_Contract_Reviewer__c ='Abhishek Pandey';
        cobj.Opportunity__C= instOfOppFIF.id;
        cobj.Type_Of_Cancellation__c = 'Billing Error';// for set type 2
        cobj.Is_Cancellation__c = true;
        cobj.Is_Hybrid__c = true;
        cobj.Canx_Accounting_Hybrid_Review_Ok__c='Yes';
        insert cobj;
        
        cobj.Canx_Accounting_Hybrid_Review_Ok__c='No';
        //cobj.Canx_Contract_Review_Ok__c = 'Yes';
        update cobj;
        
        
        /*ends*/
        cObj = new Contract_Reviewing__c();
        cObj.Canx_Implementation_Team__c ='Abhishek Pandey';
        cobj.Opportunity__C= instOfOppFIF.id;
        cobj.Type_Of_Cancellation__c = 'Withhold Tax Cancellation';
        cobj.Is_Cancellation__c = true;
        cobj.Is_Hybrid__c = true;
        cobj.Canx_Team_OK__c = 'Re-Review';
        insert cobj;
        
        cobj.Canx_Team_OK__c = 'Yes';
        update cobj;
        
        cObj = new Contract_Reviewing__c();
        cObj.Canx_Accounting_Reviewer_Hybrid_Feature__c ='Abhishek Pandey';
        cobj.Opportunity__C= instOfOppFIF.id;
        cobj.Type_Of_Cancellation__c = 'Withhold Tax Cancellation';
        cobj.Is_Cancellation__c = true;
        cobj.Is_Hybrid__c = true;
        insert cobj;
        
        cobj.Canx_Accounting_Hybrid_Review_Ok__c = 'Yes';
        update cobj;
        
        
        cObj = new Contract_Reviewing__c();
        cObj.Canx_Accounting_Reviewer_Hybrid_Feature__c ='Abhishek Pandey';
        cobj.Opportunity__C= instOfOppFIF.id;
        cobj.Type_Of_Cancellation__c = 'Billing Error';
        cobj.Is_Cancellation__c = true;
        cobj.Is_Hybrid__c = true;
        insert cobj;
        
        cobj.Canx_Accounting_Hybrid_Review_Ok__c = 'No';
        update cobj;
        
        cObj = new Contract_Reviewing__c();
        cObj.Canx_Accounting_Reviewer_Hybrid_Feature__c ='Abhishek Pandey';
        cobj.Canx_Contract_Review_Ok__c='Re-Review';
        cobj.Opportunity__C= instOfOppFIF.id;
        cobj.Type_Of_Cancellation__c = 'Billing Error';
        cobj.Is_Cancellation__c = true;
        cobj.Is_Hybrid__c = true;
        insert cobj;
        
        cobj.Canx_Contract_Review_Ok__c='Yes';
        cobj.Canx_Accounting_Hybrid_Review_Ok__c = 'No';
        update cobj;
        
    }
    
    public  static testmethod void cancellation(){
        
        createCustomSetting('3Test','3Test','3Test','3Test');
        
        RecordType instOfRecType = [SELECT Id FROM RecordType WHERE SobjectType='Opportunity' And DeveloperName='Event' And IsActive=true];
        
        Opportunity instOfOppSec = new Opportunity();
        //instOfOpp.Opportunity_Start_Date__c = system.today();
        instOfOppSec.License_Type__c = 'Diamond Plus';
        instOfOppSec.Contract_Type_Test__c = 'Renewal';
        instOfOppSec.Counted_sales_Cancellation_Value__c =110;
        instOfOppSec.Liquidation_Fee__c  = 10;
        instOfOppSec.OptOutDate__c = system.today();
        instOfOppSec.Opp_End_Date__c  = system.today();
        //instOfOppSec.AccountId = instofAcc.id;
        instOfOppSec.Name = 'Test';
        instOfOppSec.Product__c = 'CrowdCompass';
        instOfOppSec.Contract_Number_New__c = '255122';
        instOfOppSec.New_Type__c =  'Upsell-NBB';
        instOfOppSec.StageName = 'Closed Won';
        instOfOppSec.CloseDate = system.today();
        instOfOppSec.RecordTypeId = instOfRecType.Id;
        instOfOppSec.Year_1_at_Risk__c = 11;
        instOfOppSec.New_Type__c = 'Test';
        instOfOppSec.Deal_Booked_In__c = 'UK Books';
        // instOfOppSec.Price_per_lead__c = 1;
        instOfOppSec.Years__c= '1';
        instOfOppSec.LeadSource = 'ACD-PS';
        //instOfOppSec.Contact_Associated__c = instOfCon.Id;
        instOfOppSec.Contact_Role__c = 'Influencer';
        //instOfOppSec.MSA_Code__c = instOfMulPropBund.MSA_Code__c;
        instOfOppSec.ContractReceived__c = system.today();
        //instOfOppSec.Deal_Year__c = '1';
        instOfOppSec.MYD_Deal__c = 'First Year';
        instOfOppSec.Deal_Year__c = '1';
        instOfOppSec.New_Amount__c = 1000;
        instOfOppSec.Parent_Upsell__c = 'Primary';
        instOfOppSec.Send_This_To_Tract__c = true;
        //instOfOppSec.TRACT2__Tract_Sales_Order__c='179';
        instOfOppSec.Forex_rate__c = 1;
        // instOfOppSec.Price_per_lead__c = 1;
        instOfOppSec.Clubbed_Opportunity__c = true;
        // instOfOppSec.Clubbed_Tract_Billing_Account__c = 'abcd1234';
        instOfOppSec.License_Type__c = '1/2 Diamond';
        instOfOppSec.ContractEndDate__c = system.today();
        instOfOppSec.AccountId = createAccount();
        insert instOfOppSec;
        
        
        Contract_Reviewing__c cObj = new Contract_Reviewing__c();
        cObj.Canx_Contract_Reviewer__c ='Jitendra Kumar';
        cobj.Opportunity__C= instOfOppSec.id;
        cobj.Accounting_Hybrid_Review_Ok__c ='No';
        cobj.Type_Of_Cancellation__c = 'Billing Error';
        cobj.Is_Cancellation__c = true;
        cobj.Canx_Implementation_Team__c ='Prachi Tanwar';
        cobj.Canx_Team_Comments__c ='test comments';
        cobj.Canx_Contract_Reviewer__c ='Deepshikha Sharma';
        cobj.Canx_Contract_Review_Ok__c='Yes';
        cobj.Type_Of_Cancellation__c='Cancelled';
        cobj.Contract_Review_Ok__c='Error in other opp';
        cobj.Tax_Review_Ok__c ='Yes';
        cobj.Acc_Reviewer_Comments_Hybrid__c ='test';
        insert cobj;
        
        cobj.Canx_Contract_Review_Ok__c = 'No';
        cobj.Contract_Review_Ok__c='Error in other opp';
        cobj.Tax_Review_Ok__c ='No';
        //cobj.Canx_Team_Comments__c ='changed comments';
        update cobj;    
    }
    public  static testmethod void cancellationReviewElse(){
        
        createCustomSetting('3Test','3Test','3Test','3Test');
        
        RecordType instOfRecType = [SELECT Id FROM RecordType WHERE SobjectType='Opportunity' And DeveloperName='Event' And IsActive=true];
        
        Opportunity instOfOppSec = new Opportunity();
        //instOfOpp.Opportunity_Start_Date__c = system.today();
        instOfOppSec.License_Type__c = 'Diamond Plus';
        instOfOppSec.Contract_Type_Test__c = 'Renewal';
        instOfOppSec.Counted_sales_Cancellation_Value__c =110;
        instOfOppSec.Liquidation_Fee__c  = 10;
        instOfOppSec.OptOutDate__c = system.today();
        instOfOppSec.Opp_End_Date__c  = system.today();
        //instOfOppSec.AccountId = instofAcc.id;
        instOfOppSec.Name = 'Test';
        instOfOppSec.Product__c = 'CrowdCompass';
        instOfOppSec.Contract_Number_New__c = '255122';
        instOfOppSec.New_Type__c =  'Upsell-NBB';
        instOfOppSec.StageName = 'Tract';
        instOfOppSec.CloseDate = system.today();
        instOfOppSec.RecordTypeId = instOfRecType.Id;
        instOfOppSec.Year_1_at_Risk__c = 11;
        instOfOppSec.New_Type__c = 'Test';
        instOfOppSec.Deal_Booked_In__c = 'UK Books';
        // instOfOppSec.Price_per_lead__c = 1;
        instOfOppSec.Years__c= '1';
        instOfOppSec.LeadSource = 'ACD-PS';
        //instOfOppSec.Contact_Associated__c = instOfCon.Id;
        instOfOppSec.Contact_Role__c = 'Influencer';
        //instOfOppSec.MSA_Code__c = instOfMulPropBund.MSA_Code__c;
        instOfOppSec.ContractReceived__c = system.today();
        //instOfOppSec.Deal_Year__c = '1';
        instOfOppSec.MYD_Deal__c = 'First Year';
        instOfOppSec.Deal_Year__c = '1';
        instOfOppSec.New_Amount__c = 1000;
        instOfOppSec.Parent_Upsell__c = 'Primary';
        instOfOppSec.Send_This_To_Tract__c = true;
        //instOfOppSec.TRACT2__Tract_Sales_Order__c='179';
        instOfOppSec.Forex_rate__c = 1;
        // instOfOppSec.Price_per_lead__c = 1;
        instOfOppSec.Clubbed_Opportunity__c = true;
        // instOfOppSec.Clubbed_Tract_Billing_Account__c = 'abcd1234';
        instOfOppSec.License_Type__c = '1/2 Diamond';
        instOfOppSec.ContractEndDate__c = system.today();
        instOfOppSec.AccountId = createAccount();
        
        insert instOfOppSec;        
        
        Contract_Reviewing__c cObj = new Contract_Reviewing__c();
        cObj.Canx_Contract_Reviewer__c ='Jitendra Kumar';
        cobj.Opportunity__C= instOfOppSec.id;
        
        cobj.Type_Of_Cancellation__c = 'Billing Error';
        cobj.Is_Cancellation__c = true;
        cobj.Canx_Implementation_Team__c ='Prachi Tanwar';
        cobj.Canx_Team_Comments__c ='test comments';
        cobj.Canx_Contract_Reviewer__c ='Deepshikha Sharma';
        cobj.Canx_Contract_Review_Ok__c='No';
        
        cobj.Tax_Review_Ok__c ='No';
        cobj.Accounting_Team_Reviewer__c='No';
        insert cobj;
        
        cobj.Canx_Contract_Review_Ok__c = 'Yes';
        cobj.Accounting_Team_Reviewer__c ='Yes';
        cobj.Tax_Review_Ok__c='Yes';
        //cobj.Canx_Team_Comments__c ='changed comments';
        update cobj;    }
    public  static testmethod void canx_ContarctReview()
    {
        createCustomSetting('3Test','3Test','3Test','3Test');
        
        RecordType instOfRecType = [SELECT Id FROM RecordType WHERE SobjectType='Opportunity' And DeveloperName='Event' And IsActive=true];
        
        Opportunity instOfOppSec = new Opportunity();
        //instOfOpp.Opportunity_Start_Date__c = system.today();
        instOfOppSec.License_Type__c = 'Diamond Plus';
        instOfOppSec.Contract_Type_Test__c = 'Renewal';
        instOfOppSec.Counted_sales_Cancellation_Value__c =110;
        instOfOppSec.Liquidation_Fee__c  = 10;
        instOfOppSec.OptOutDate__c = system.today();
        instOfOppSec.Opp_End_Date__c  = system.today();
        //instOfOppSec.AccountId = instofAcc.id;
        instOfOppSec.Name = 'Test';
        instOfOppSec.Product__c = 'CrowdCompass';
        instOfOppSec.Contract_Number_New__c = '255122';
        instOfOppSec.New_Type__c =  'Upsell-NBB';
        instOfOppSec.StageName = 'Closed';
        instOfOppSec.CloseDate = system.today();
        instOfOppSec.RecordTypeId = instOfRecType.Id;
        instOfOppSec.Year_1_at_Risk__c = 11;
        instOfOppSec.New_Type__c = 'Test';
        instOfOppSec.Deal_Booked_In__c = 'UK Books';
        // instOfOppSec.Price_per_lead__c = 1;
        instOfOppSec.Years__c= '1';
        instOfOppSec.LeadSource = 'ACD-PS';
        //instOfOppSec.Contact_Associated__c = instOfCon.Id;
        instOfOppSec.Contact_Role__c = 'Influencer';
        //instOfOppSec.MSA_Code__c = instOfMulPropBund.MSA_Code__c;
        instOfOppSec.ContractReceived__c = system.today();
        //instOfOppSec.Deal_Year__c = '1';
        instOfOppSec.MYD_Deal__c = 'First Year';
        instOfOppSec.Deal_Year__c = '1';
        instOfOppSec.New_Amount__c = 1000;
        instOfOppSec.Parent_Upsell__c = 'Primary';
        instOfOppSec.Send_This_To_Tract__c = true;
        //instOfOppSec.TRACT2__Tract_Sales_Order__c='179';
        instOfOppSec.Forex_rate__c = 1;
        // instOfOppSec.Price_per_lead__c = 1;
        instOfOppSec.Clubbed_Opportunity__c = true;
        // instOfOppSec.Clubbed_Tract_Billing_Account__c = 'abcd1234';
        instOfOppSec.License_Type__c = '1/2 Diamond';
        instOfOppSec.ContractEndDate__c = system.today();
        instOfOppSec.AccountId = createAccount();
        
        insert instOfOppSec;        
        
        Contract_Reviewing__c cObj = new Contract_Reviewing__c();
        cObj.Canx_Contract_Reviewer__c ='Jitendra Kumar';
        cobj.Opportunity__C= instOfOppSec.id;
        
        cobj.Type_Of_Cancellation__c = 'Billing Error';
        cobj.Is_Hybrid__c = False;
        cobj.Canx_Team_OK__c ='Re-review';
        cobj.Is_Cancellation__c = true;
        cobj.Canx_Implementation_Team__c ='Prachi Tanwar';
        cobj.Canx_Team_Comments__c ='test comments';
        cobj.Canx_Contract_Reviewer__c ='Deepshikha Sharma';
        cobj.Canx_Contract_Review_Ok__c='Error Correct';
        cobj.Canx_Team_Comments__c='test canx commnet';
        
        cobj.Tax_Review_Ok__c ='No';
        cobj.Accounting_Team_Reviewer__c='No';
        cobj.Type_Of_Cancellation__c='Bad Debts';
        insert cobj;
        
        cobj.Canx_Contract_Review_Ok__c = 'Yes';
        cobj.Canx_Team_OK__c='Yes';
        cobj.Accounting_Team_Reviewer__c ='Yes';
        cobj.Tax_Review_Ok__c='Yes';
        //cobj.Canx_Team_Comments__c ='changed comments';
        update cobj;    }
    
    public  static testmethod void canx_Project()
    {
        createCustomSetting('3Test','3Test','3Test','3Test');
        
        RecordType instOfRecType = [SELECT Id FROM RecordType WHERE SobjectType='Opportunity' And DeveloperName='Event' And IsActive=true];
        
        Opportunity instOfOppSec = new Opportunity();
        //instOfOpp.Opportunity_Start_Date__c = system.today();
        instOfOppSec.License_Type__c = 'Diamond Plus';
        instOfOppSec.Contract_Type_Test__c = 'Renewal';
        instOfOppSec.Counted_sales_Cancellation_Value__c =110;
        instOfOppSec.Liquidation_Fee__c  = 10;
        instOfOppSec.OptOutDate__c = system.today();
        instOfOppSec.Opp_End_Date__c  = system.today();
        //instOfOppSec.AccountId = instofAcc.id;
        instOfOppSec.Name = 'Test';
        instOfOppSec.Product__c = 'CrowdCompass';
        instOfOppSec.Contract_Number_New__c = '255122';
        instOfOppSec.New_Type__c =  'Upsell-NBB';
        instOfOppSec.StageName = 'Closed';
        instOfOppSec.CloseDate = system.today();
        instOfOppSec.RecordTypeId = instOfRecType.Id;
        instOfOppSec.Year_1_at_Risk__c = 11;
        instOfOppSec.New_Type__c = 'Test';
        instOfOppSec.Deal_Booked_In__c = 'UK Books';
        // instOfOppSec.Price_per_lead__c = 1;
        instOfOppSec.Years__c= '1';
        instOfOppSec.LeadSource = 'ACD-PS';
        //instOfOppSec.Contact_Associated__c = instOfCon.Id;
        instOfOppSec.Contact_Role__c = 'Influencer';
        //instOfOppSec.MSA_Code__c = instOfMulPropBund.MSA_Code__c;
        instOfOppSec.ContractReceived__c = system.today();
        //instOfOppSec.Deal_Year__c = '1';
        instOfOppSec.MYD_Deal__c = 'First Year';
        instOfOppSec.Deal_Year__c = '1';
        instOfOppSec.New_Amount__c = 1000;
        instOfOppSec.Parent_Upsell__c = 'Primary';
        instOfOppSec.Send_This_To_Tract__c = true;
        //instOfOppSec.TRACT2__Tract_Sales_Order__c='179';
        instOfOppSec.Forex_rate__c = 1;
        // instOfOppSec.Price_per_lead__c = 1;
        instOfOppSec.Clubbed_Opportunity__c = true;
        // instOfOppSec.Clubbed_Tract_Billing_Account__c = 'abcd1234';
        instOfOppSec.License_Type__c = '1/2 Diamond';
        instOfOppSec.ContractEndDate__c = system.today();
        instOfOppSec.AccountId = createAccount();
        
        insert instOfOppSec;        
        
        Contract_Reviewing__c cObj = new Contract_Reviewing__c();
        cObj.Canx_Contract_Reviewer__c ='Jitendra Kumar';
        cobj.Opportunity__C= instOfOppSec.id;
        
        cobj.Type_Of_Cancellation__c = 'Billing Error';
        cobj.Is_Hybrid__c = False;
        cobj.Canx_Team_OK__c ='Re-review';
        cobj.Is_Cancellation__c = true;
        cobj.Canx_Implementation_Team__c ='Prachi Tanwar';
        cobj.Canx_Team_Comments__c ='test comments';
        cobj.Canx_Contract_Reviewer__c ='Deepshikha Sharma';
        cobj.Canx_Contract_Review_Ok__c='Error Correct';
        cobj.Canx_Team_Comments__c='test canx commnet';
        
        //cobj.Tax_Review_Ok__c ='No';
        cobj.Accounting_Team_Reviewer__c='No';
        cobj.Type_Of_Cancellation__c='Bad Debts';
        insert cobj;
        
        cobj.Canx_Contract_Review_Ok__c = 'Yes';
        //cobj.Canx_Team_OK__c='Yes';
        cobj.Accounting_Team_Reviewer__c ='Yes';
        cobj.Tax_Review_Ok__c='Yes';
        //cobj.Canx_Team_Comments__c ='changed comments';
        update cobj;   
    }
    public  static testmethod void SetType2Tract(){
        createCustomSetting('3Test','3Test','3Test','3Test');
        
        RecordType instOfRecType = [SELECT Id FROM RecordType WHERE SobjectType='Opportunity' And DeveloperName='Event' And IsActive=true];
        
        Opportunity instOfOppSec = new Opportunity();
        //instOfOpp.Opportunity_Start_Date__c = system.today();
        instOfOppSec.License_Type__c = 'Diamond Plus';
        instOfOppSec.Contract_Type_Test__c = 'Renewal';
        instOfOppSec.Counted_sales_Cancellation_Value__c =110;
        instOfOppSec.Liquidation_Fee__c  = 10;
        instOfOppSec.OptOutDate__c = system.today();
        instOfOppSec.Opp_End_Date__c  = system.today();
        //instOfOppSec.AccountId = instofAcc.id;
        instOfOppSec.Name = 'Test';
        instOfOppSec.Product__c = 'CrowdCompass';
        instOfOppSec.Contract_Number_New__c = '255122';
        instOfOppSec.New_Type__c =  'Upsell-NBB';
        instOfOppSec.StageName = 'Closed';
        instOfOppSec.CloseDate = system.today();
        instOfOppSec.RecordTypeId = instOfRecType.Id;
        instOfOppSec.Year_1_at_Risk__c = 11;
        instOfOppSec.New_Type__c = 'Test';
        instOfOppSec.Deal_Booked_In__c = 'UK Books';
        // instOfOppSec.Price_per_lead__c = 1;
        instOfOppSec.Years__c= '1';
        instOfOppSec.LeadSource = 'ACD-PS';
        //instOfOppSec.Contact_Associated__c = instOfCon.Id;
        instOfOppSec.Contact_Role__c = 'Influencer';
        //instOfOppSec.MSA_Code__c = instOfMulPropBund.MSA_Code__c;
        instOfOppSec.ContractReceived__c = system.today();
        //instOfOppSec.Deal_Year__c = '1';
        instOfOppSec.MYD_Deal__c = 'First Year';
        instOfOppSec.Deal_Year__c = '1';
        instOfOppSec.New_Amount__c = 1000;
        instOfOppSec.Parent_Upsell__c = 'Primary';
        instOfOppSec.Send_This_To_Tract__c = true;
        //instOfOppSec.TRACT2__Tract_Sales_Order__c='179';
        instOfOppSec.Forex_rate__c = 1;
        // instOfOppSec.Price_per_lead__c = 1;
        instOfOppSec.Clubbed_Opportunity__c = true;
        // instOfOppSec.Clubbed_Tract_Billing_Account__c = 'abcd1234';
        instOfOppSec.License_Type__c = '1/2 Diamond';
        instOfOppSec.ContractEndDate__c = system.today();
        instOfOppSec.AccountId = createAccount();
        insert instOfOppSec;        
        
        Contract_Reviewing__c cObj = new Contract_Reviewing__c();
        cObj.Canx_Contract_Reviewer__c ='Jitendra Kumar';
        cobj.Opportunity__C= instOfOppSec.id;
        
        cobj.Type_Of_Cancellation__c = 'Billing Error';
        cobj.Tax_Review_Ok__c='No';
        cobj.Is_Hybrid__c = False;
        cobj.Canx_Team_OK__c ='Re-review';
        cobj.Is_Cancellation__c = true;
        cobj.Canx_Implementation_Team__c ='Prachi Tanwar';
        cobj.Canx_Team_Comments__c ='test comments';
        cobj.Canx_Contract_Reviewer__c ='Deepshikha Sharma';
        cobj.Canx_Contract_Review_Ok__c='Error Correct';
        cobj.Canx_Team_Comments__c='test canx commnet';
        cobj.Contract_Review_Ok__c='Error Correct';
        
        //cobj.Tax_Review_Ok__c ='No';
        cobj.Accounting_Team_Reviewer__c='No';
        //cobj.Type_Of_Cancellation__c='Bad Debts';
        insert cobj;
        
        cobj.Canx_Contract_Review_Ok__c = 'Yes';
        //cobj.Canx_Team_OK__c='Yes';
        cobj.Contract_Review_Ok__c='Error in other opp';
        cobj.Accounting_Team_Reviewer__c ='Yes';
        cobj.Tax_Review_Ok__c='Yes';
        //cobj.Canx_Team_Comments__c ='changed comments';
        update cobj; 
        
        
        
        
        
    }
    
    public  static testmethod void SetType3Tract(){
        createCustomSetting('3Test','3Test','3Test','3Test');
        
        RecordType instOfRecType = [SELECT Id FROM RecordType WHERE SobjectType='Opportunity' And DeveloperName='Event' And IsActive=true];
        
        Opportunity instOfOppSec = new Opportunity();
        //instOfOpp.Opportunity_Start_Date__c = system.today();
        instOfOppSec.License_Type__c = 'Diamond Plus';
        instOfOppSec.Contract_Type_Test__c = 'Renewal';
        instOfOppSec.Counted_sales_Cancellation_Value__c =110;
        instOfOppSec.Liquidation_Fee__c  = 10;
        instOfOppSec.OptOutDate__c = system.today();
        instOfOppSec.Opp_End_Date__c  = system.today();
        //instOfOppSec.AccountId = instofAcc.id;
        instOfOppSec.Name = 'Test';
        instOfOppSec.Product__c = 'CrowdCompass';
        instOfOppSec.Contract_Number_New__c = '255122';
        instOfOppSec.New_Type__c =  'Upsell-NBB';
        instOfOppSec.StageName = 'Closed';
        instOfOppSec.CloseDate = system.today();
        instOfOppSec.RecordTypeId = instOfRecType.Id;
        instOfOppSec.Year_1_at_Risk__c = 11;
        instOfOppSec.New_Type__c = 'Test';
        instOfOppSec.Deal_Booked_In__c = 'UK Books';
        // instOfOppSec.Price_per_lead__c = 1;
        instOfOppSec.Years__c= '1';
        instOfOppSec.LeadSource = 'ACD-PS';
        //instOfOppSec.Contact_Associated__c = instOfCon.Id;
        instOfOppSec.Contact_Role__c = 'Influencer';
        //instOfOppSec.MSA_Code__c = instOfMulPropBund.MSA_Code__c;
        instOfOppSec.ContractReceived__c = system.today();
        //instOfOppSec.Deal_Year__c = '1';
        instOfOppSec.MYD_Deal__c = 'First Year';
        instOfOppSec.Deal_Year__c = '1';
        instOfOppSec.New_Amount__c = 1000;
        instOfOppSec.Parent_Upsell__c = 'Primary';
        instOfOppSec.Send_This_To_Tract__c = true;
        //instOfOppSec.TRACT2__Tract_Sales_Order__c='179';
        instOfOppSec.Forex_rate__c = 1;
        // instOfOppSec.Price_per_lead__c = 1;
        instOfOppSec.Clubbed_Opportunity__c = true;
        // instOfOppSec.Clubbed_Tract_Billing_Account__c = 'abcd1234';
        instOfOppSec.License_Type__c = '1/2 Diamond';
        instOfOppSec.ContractEndDate__c = system.today();
        instOfOppSec.AccountId = createAccount();
        
        insert instOfOppSec;        
        
        Contract_Reviewing__c cObj = new Contract_Reviewing__c();
        cObj.Canx_Contract_Reviewer__c ='Jitendra Kumar';
        cobj.Opportunity__C= instOfOppSec.id;
        
        cobj.Type_Of_Cancellation__c ='Withhold Tax Cancellation';
        cobj.Tax_Review_Ok__c='No';
        cobj.Is_Hybrid__c = False;
        cobj.Canx_Team_OK__c ='Re-review';
        cobj.Is_Cancellation__c = true;
        cobj.Canx_Implementation_Team__c ='Prachi Tanwar';
        cobj.Canx_Team_Comments__c ='test comments';
        cobj.Canx_Contract_Reviewer__c ='Deepshikha Sharma';
        cobj.Canx_Contract_Review_Ok__c='Error Correct';
        cobj.Canx_Team_Comments__c='test canx commnet';
        cobj.Contract_Review_Ok__c='Error Correct';
        
        //cobj.Tax_Review_Ok__c ='No';
        cobj.Accounting_Team_Reviewer__c='No';
        //cobj.Type_Of_Cancellation__c='Bad Debts';
        insert cobj;
        
        cobj.Canx_Contract_Review_Ok__c = 'Yes';
        //cobj.Canx_Team_OK__c='Yes';
        cobj.Contract_Review_Ok__c='Error in other opp';
        cobj.Accounting_Team_Reviewer__c ='Yes';
        cobj.Tax_Review_Ok__c='Yes';
        //cobj.Canx_Team_Comments__c ='changed comments';
        update cobj; 
        
    }   
    
    
    public  static testmethod void TractOpp(){
        
        createCustomSetting('3Test','3Test','3Test','3Test');
        
        RecordType instOfRecType = [SELECT Id FROM RecordType WHERE SobjectType='Opportunity' And DeveloperName='Event' And IsActive=true];
        
        Opportunity instOfOppSec = new Opportunity();
        //instOfOpp.Opportunity_Start_Date__c = system.today();
        instOfOppSec.License_Type__c = 'Diamond Plus';
        instOfOppSec.Contract_Type_Test__c = 'Renewal';
        instOfOppSec.Counted_sales_Cancellation_Value__c =110;
        instOfOppSec.Liquidation_Fee__c  = 10;
        instOfOppSec.OptOutDate__c = system.today();
        instOfOppSec.Opp_End_Date__c  = system.today();
        //instOfOppSec.AccountId = instofAcc.id;
        instOfOppSec.Name = 'Test';
        instOfOppSec.Product__c = 'CrowdCompass';
        instOfOppSec.Contract_Number_New__c = '255122';
        instOfOppSec.New_Type__c =  'Upsell-NBB';
        instOfOppSec.StageName = 'Tract';
        instOfOppSec.CloseDate = system.today();
        instOfOppSec.RecordTypeId = instOfRecType.Id;
        instOfOppSec.Year_1_at_Risk__c = 11;
        instOfOppSec.New_Type__c = 'Test';
        instOfOppSec.Deal_Booked_In__c = 'UK Books';
        // instOfOppSec.Price_per_lead__c = 1;
        instOfOppSec.Years__c= '1';
        instOfOppSec.LeadSource = 'ACD-PS';
        //instOfOppSec.Contact_Associated__c = instOfCon.Id;
        instOfOppSec.Contact_Role__c = 'Influencer';
        //instOfOppSec.MSA_Code__c = instOfMulPropBund.MSA_Code__c;
        instOfOppSec.ContractReceived__c = system.today();
        //instOfOppSec.Deal_Year__c = '1';
        instOfOppSec.MYD_Deal__c = 'First Year';
        instOfOppSec.Deal_Year__c = '1';
        instOfOppSec.New_Amount__c = 1000;
        instOfOppSec.Parent_Upsell__c = 'Primary';
        instOfOppSec.Send_This_To_Tract__c = true;
        //instOfOppSec.TRACT2__Tract_Sales_Order__c='179';
        instOfOppSec.Forex_rate__c = 1;
        // instOfOppSec.Price_per_lead__c = 1;
        instOfOppSec.Clubbed_Opportunity__c = true;
        // instOfOppSec.Clubbed_Tract_Billing_Account__c = 'abcd1234';
        instOfOppSec.License_Type__c = '1/2 Diamond';
        instOfOppSec.ContractEndDate__c = system.today();
        instOfOppSec.AccountId = createAccount();
        
        insert instOfOppSec;        
        
        Contract_Reviewing__c cObj = new Contract_Reviewing__c();
        cObj.Canx_Contract_Reviewer__c ='Jitendra Kumar';
        cobj.Canx_Accounting_Team_Level_1_Review_Ok__c ='Yes';
        cobj.Opportunity__C= instOfOppSec.id;
        
        
        insert cobj;
        cobj.Canx_Accounting_Team_Level_1_Review_Ok__c='No';
        update cobj; 
        
        
    }
    
    public  static testmethod void otherStage(){
        
        createCustomSetting('3Test','3Test','3Test','3Test');
        
        RecordType instOfRecType = [SELECT Id FROM RecordType WHERE SobjectType='Opportunity' And DeveloperName='Event' And IsActive=true];
        
        Opportunity instOfOppSec = new Opportunity();
        //instOfOpp.Opportunity_Start_Date__c = system.today();
        instOfOppSec.License_Type__c = 'Diamond Plus';
        instOfOppSec.Contract_Type_Test__c = 'Renewal';
        instOfOppSec.Counted_sales_Cancellation_Value__c =110;
        instOfOppSec.Liquidation_Fee__c  = 10;
        instOfOppSec.OptOutDate__c = system.today();
        instOfOppSec.Opp_End_Date__c  = system.today();
        //instOfOppSec.AccountId = instofAcc.id;
        instOfOppSec.Name = 'Test';
        instOfOppSec.Product__c = 'CrowdCompass';
        instOfOppSec.Contract_Number_New__c = '255122';
        instOfOppSec.New_Type__c =  'Upsell-NBB';
        instOfOppSec.StageName = 'Tract';
        instOfOppSec.CloseDate = system.today();
        instOfOppSec.RecordTypeId = instOfRecType.Id;
        instOfOppSec.Year_1_at_Risk__c = 11;
        instOfOppSec.New_Type__c = 'Test';
        instOfOppSec.Deal_Booked_In__c = 'UK Books';
        // instOfOppSec.Price_per_lead__c = 1;
        instOfOppSec.Years__c= '1';
        instOfOppSec.LeadSource = 'ACD-PS';
        
        //instOfOppSec.Contact_Associated__c = instOfCon.Id;
        instOfOppSec.Contact_Role__c = 'Influencer';
        //instOfOppSec.MSA_Code__c = instOfMulPropBund.MSA_Code__c;
        instOfOppSec.ContractReceived__c = system.today();
        //instOfOppSec.Deal_Year__c = '1';
        instOfOppSec.MYD_Deal__c = 'First Year';
        instOfOppSec.Deal_Year__c = '1';
        instOfOppSec.New_Amount__c = 1000;
        instOfOppSec.Parent_Upsell__c = 'Primary';
        instOfOppSec.Send_This_To_Tract__c = true;
        //instOfOppSec.TRACT2__Tract_Sales_Order__c='179';
        instOfOppSec.Forex_rate__c = 1;
        // instOfOppSec.Price_per_lead__c = 1;
        instOfOppSec.Clubbed_Opportunity__c = true;
        // instOfOppSec.Clubbed_Tract_Billing_Account__c = 'abcd1234';
        instOfOppSec.License_Type__c = '1/2 Diamond';
        instofOppSec.Product_Category_Tract__c ='Test';
        instOfOppSec.ContractEndDate__c = system.today();
        instOfOppSec.AccountId = createAccount();
        
        insert instOfOppSec; 
        
        
        
        Contract_Reviewing__c cObj = new Contract_Reviewing__c();
        cObj.Canx_Contract_Reviewer__c ='Jitendra Kumar';
        cobj.Canx_Accounting_Team_Level_1_Review_Ok__c ='Yes';
        cobj.Opportunity__C= instOfOppSec.id;
        //cobj.Product_Category_Tract__c ='Test';
        
        
        insert cobj;
        
        
        cobj.Canx_Accounting_Team_Level_1_Review_Ok__c='No';
        
        update cobj; 
        
        
    }
    
    public  static testmethod void ReviewContractOK(){
        
        creatOpportunity(); 
        createCustomSetting('2Test','2Test','2Test','2Test');
        Contract_Reviewing__c cReview_hybrid=new Contract_Reviewing__c();
        cReview_hybrid.Accounting_Reviewer_Hybrid_Feature__c='Sumit Jain';
        cReview_hybrid.Opportunity__c=instOfOppFIF.id;
        cReview_hybrid.Acc_Reviewer_Comments_Hybrid__c='testHybrid comment';
        cReview_hybrid.Accounting_Review_Ok__c='No';
        cReview_hybrid.Implementation_Review_ok__c='Re-Review';
        cReview_hybrid.AR_Level_1_Rejection_Reason__c='End Date Error';
        cReview_hybrid.Is_Error_in_Other_Opp__c =True;
        insert cReview_hybrid;
        // Get contract insert on contract implement at opportuity
        // Contract_Reviewing__c cReview=[select Accounting_Reviewer_Hybrid_Feature__c,Accounting_Hybrid_Review_Ok__c from Contract_Reviewing__c where id=:cReview_hybrid.id];
        System.runAs(createUSer(cReview_hybrid.Accounting_Reviewer_Hybrid_Feature__c,1)) {
            Contract_Reviewing__c cReviewUpdate=[select Is_Error_in_Other_Opp__c,Opportunity_Contract__c, Accounting_Reviewer_Hybrid_Feature__c,Implementation_Review_ok__c,Contract_Review_Ok__c,Accounting_Hybrid_Review_Ok__c from Contract_Reviewing__c where id =:cReview_hybrid.id  LIMIT 1];
            cReviewUpdate.Accounting_Hybrid_Review_Ok__c='Error in other opp';
            cReviewUpdate.Implementation_Review_ok__c='Yes';
            
            update cReviewUpdate;
        }        
    }
    public  static testmethod void ReviewContractOKElse(){
        
        creatOpportunity(); 
        Contract_Reviewing__c objcReview =new Contract_Reviewing__c();
        objcReview.Contract_Reviewer__c='Sumit Jain';
        objcReview.Opportunity__c=instOfOppFIF.id;
        objcReview.Contract_Review_Ok__c='Re-Review';
        //objcReview.Accounting_Review_Ok__c=null;
        insert objcReview;
        // Get contract insert on contract implement at opportuity
        //  Contract_Reviewing__c cReview=[select Accounting_Reviewer_Hybrid_Feature__c,Accounting_Hybrid_Review_Ok__c from Contract_Reviewing__c where id=:cReview_hybrid.id];
        System.runAs(createUSer(objcReview.Contract_Reviewer__c,10)) {
            Contract_Reviewing__c cReviewUpdate=[select Contract_Reviewer__c,Contract_Review_Ok__c from Contract_Reviewing__c where id =:objcReview.id  LIMIT 1];
            cReviewUpdate.Contract_Review_Ok__c='Error in other opp';
            cReviewUpdate.Contract_Review_Comments__c='test';
            // objcReview.Accounting_Review_Ok__c='No';
            update cReviewUpdate;
            
            
        }        
        
    }    
    
    public static  testmethod void ReviewContractOkYes(){
        
        creatOpportunity();
        createCustomSetting('2Test','2Test','2Test','2Test');
        Contract_Reviewing__c objcReview =new Contract_Reviewing__c();
        objcReview.Contract_Reviewer__c='Sumit Jain';
        objcReview.Opportunity__c=instOfOppFIF.id;
        objcReview.Contract_Review_Ok__c='Re-Review';
        //objcReview.Accounting_Review_Ok__c=null;
        insert objcReview;
        // Get contract insert on contract implement at opportuity
        //  Contract_Reviewing__c cReview=[select Accounting_Reviewer_Hybrid_Feature__c,Accounting_Hybrid_Review_Ok__c from Contract_Reviewing__c where id=:cReview_hybrid.id];
        System.runAs(createUSer(objcReview.Contract_Reviewer__c,10)) {
            Contract_Reviewing__c cReviewUpdate=[select Contract_Reviewer__c,Contract_Review_Ok__c from Contract_Reviewing__c where id =:objcReview.id  LIMIT 1];
            cReviewUpdate.Contract_Review_Ok__c='yes';
            cReviewUpdate.Contract_Review_Comments__c='test';
            // objcReview.Accounting_Review_Ok__c='No';
            try{
                update cReviewUpdate;}
            catch(exception e)
            {
                system.debug('cannot update this record');
            }
            
        }
    }
    
    public static  testmethod void ReviewDateChnages(){
        
        creatOpportunity();
        RecordType instOfRecType = [SELECT Id FROM RecordType WHERE SobjectType='Account' And DeveloperName='Biz_Ac' And IsActive=true];
        
        account acc = new account();
        acc.Name='test account';
        acc.RecordTypeId=instOfRecType.id;
        acc.BillingCountryCode = 'US';
        acc.BillingStateCode = 'NY';
        insert acc;
        
        contact con = new contact();
        con.LastName='Testcontact';
        con.CurrencyIsoCode='USD';
        con.AccountId = acc.Id;
        insert con;
        
        Invoicing_Details__c inv =new Invoicing_Details__c();
        inv.Opportunity__c = instOfOppFIF.id;
        inv.Billing_POC__c =con.Id;
        
        insert inv;
        date dt1 = date.newInstance(2018, 6, 13);
        Invoicing_Line_Items__c invLineItem = new Invoicing_Line_Items__c();
        invLineItem.Billing_Date__c =dt1;
        invLineItem.Invoicing_Details__c =inv.id;
        invlineItem.Installment_description__c='test Description';
        insert invLineItem;
        createCustomSetting('2Test','2Test','2Test','2Test');
        Contract_Reviewing__c objcReview =new Contract_Reviewing__c();
        objcReview.Contract_Reviewer__c='Sumit Jain';
        objcReview.Opportunity__c=instOfOppFIF.id;
        objcReview.Contract_Review_Ok__c='Re-Review';
        //objcReview.Accounting_Review_Ok__c=null;
        insert objcReview;
        // Get contract insert on contract implement at opportuity
        //  Contract_Reviewing__c cReview=[select Accounting_Reviewer_Hybrid_Feature__c,Accounting_Hybrid_Review_Ok__c from Contract_Reviewing__c where id=:cReview_hybrid.id];
        System.runAs(createUSer(objcReview.Contract_Reviewer__c,10)) {
            Contract_Reviewing__c cReviewUpdate=[select Contract_Reviewer__c,Contract_Review_Ok__c from Contract_Reviewing__c where id =:objcReview.id  LIMIT 1];
            cReviewUpdate.Contract_Review_Ok__c='yes';
            cReviewUpdate.Contract_Review_Comments__c='test';
            // objcReview.Accounting_Review_Ok__c='No';
            try{
                update cReviewUpdate;}
            catch(exception e)
            {
                system.debug('cannot update this record');
            }
            
        }
    }
    public static testmethod void canx_ProjectTract(){
        
        createCustomSetting('3Test','3Test','3Test','3Test');
        
        RecordType instOfRecType = [SELECT Id FROM RecordType WHERE SobjectType='Opportunity' And DeveloperName='Event' And IsActive=true];
        
        Opportunity instOfOppSec = new Opportunity();
        //instOfOpp.Opportunity_Start_Date__c = system.today();
        instOfOppSec.License_Type__c = 'Diamond Plus';
        instOfOppSec.Contract_Type_Test__c = 'Renewal';
        instOfOppSec.Counted_sales_Cancellation_Value__c =110;
        instOfOppSec.Liquidation_Fee__c  = 10;
        instOfOppSec.OptOutDate__c = system.today();
        instOfOppSec.Opp_End_Date__c  = system.today();
        //instOfOppSec.AccountId = instofAcc.id;
        instOfOppSec.Name = 'Test';
        instOfOppSec.Product__c = 'CrowdCompass';
        instOfOppSec.Contract_Number_New__c = '255122';
        instOfOppSec.New_Type__c =  'Upsell-NBB';
        instOfOppSec.StageName = 'Tract';
        instOfOppSec.CloseDate = system.today();
        instOfOppSec.RecordTypeId = instOfRecType.Id;
        instOfOppSec.Year_1_at_Risk__c = 11;
        instOfOppSec.New_Type__c = 'Test';
        instOfOppSec.Deal_Booked_In__c = 'UK Books';
        // instOfOppSec.Price_per_lead__c = 1;
        instOfOppSec.Years__c= '1';
        instOfOppSec.LeadSource = 'ACD-PS';
        //instOfOppSec.Contact_Associated__c = instOfCon.Id;
        instOfOppSec.Contact_Role__c = 'Influencer';
        //instOfOppSec.MSA_Code__c = instOfMulPropBund.MSA_Code__c;
        instOfOppSec.ContractReceived__c = system.today();
        //instOfOppSec.Deal_Year__c = '1';
        instOfOppSec.MYD_Deal__c = 'First Year';
        instOfOppSec.Deal_Year__c = '1';
        instOfOppSec.New_Amount__c = 1000;
        instOfOppSec.Parent_Upsell__c = 'Primary';
        instOfOppSec.Send_This_To_Tract__c = true;
        //instOfOppSec.TRACT2__Tract_Sales_Order__c='179';
        instOfOppSec.Forex_rate__c = 1;
        // instOfOppSec.Price_per_lead__c = 1;
        instOfOppSec.Clubbed_Opportunity__c = true;
        // instOfOppSec.Clubbed_Tract_Billing_Account__c = 'abcd1234';
        instOfOppSec.License_Type__c = '1/2 Diamond';
        instOfOppSec.ContractEndDate__c = system.today();
        instOfOppSec.AccountId = createAccount();
        
        insert instOfOppSec;        
        
        Contract_Reviewing__c cObj = new Contract_Reviewing__c();
        cObj.Canx_Contract_Reviewer__c ='Jitendra Kumar';
        cobj.Opportunity__C= instOfOppSec.id;
        
        cobj.Type_Of_Cancellation__c ='Bad Debts';
        cobj.Is_Hybrid__c = False;
        cobj.Canx_Team_OK__c ='Re-review';
        cobj.Is_Cancellation__c = true;
        cobj.Canx_Implementation_Team__c ='Prachi Tanwar';
        cobj.Canx_Team_Comments__c ='test comments';
        cobj.Canx_Contract_Reviewer__c ='Deepshikha Sharma';
        cobj.Canx_Contract_Review_Ok__c='Error Correct';
        cobj.Canx_Team_Comments__c='test canx commnet';
        cobj.Canx_Accounting_Team_Level_1_Review_Ok__c='No';
        //cobj.Tax_Review_Ok__c ='No';
        cobj.Accounting_Team_Reviewer__c='No';
        //cobj.Canx_Contract_Review_Ok__c='Yes';
        //cobj.Type_Of_Cancellation__c='Bad Debts';
        insert cobj;
        
        cobj.Canx_Contract_Review_Ok__c ='Yes';
        cobj.Canx_Accounting_Team_Level_1_Review_Ok__c='Yes';
        //cobj.Canx_Team_OK__c='Yes';
        //cobj.Accounting_Team_Reviewer__c ='Yes';
        //cobj.Tax_Review_Ok__c='Yes';
        //cobj.Canx_Team_Comments__c ='changed comments';
        update cobj;  
        
        cObj = new Contract_Reviewing__c();
        cObj.Canx_Contract_Reviewer__c ='Jitendra Kumar';
        cobj.Canx_Accounting_Team_Level_2_Review_OK__c ='No';
        cobj.Opportunity__C= instOfOppSec.id;
        cobj.Canx_Accounting_Team_Level_1_Review_Ok__c ='Re-Review';
        insert cobj;
        
        cobj.Canx_Accounting_Team_Level_1_Review_Ok__c = 'Yes';
        update cobj;
    }
    
}