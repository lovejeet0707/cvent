/****************************************************
* Author : Sandeep Kumar
* Date : 13 Dec, 2017
* Description : It tests below mentioned classes
* -> AccountPlanning_ContExt
****************************************************/
@isTest
public class AccountPlanning_ContExt_Test{
    public static Account accObj;
    public static Contact conObj;
    public static ARA__c araObj;
    private static Contract newCon;
    public static Opportunity oppObj1,oppObj2,oppObj3; 
    public static Campaign campObj;
    public static Contact_Role__c conRoleObj;
    public static Customer_Success_Review__c csrObj;  
    private static User depUser = [Select Id, ProfileId from User where Name = 'CRM Deployment User'];   
    public static final Id buyerRoleRectypeId = Schema.SObjectType.Contact_Role__c.getRecordTypeInfosByName().get('Buyer Role').getRecordTypeId();
    
    static testMethod void testAccountPlanningPage(){
        system.runAs(depUser){
            // Create Account Record.
            accObj = TestUtil.createAccount('EB Account 1', 'Biz_Ac');
            accObj.Last_12_month_spent__c = 5000;
            accObj.Wallet_Size_Parent__c = 100000;
            accObj.of_Employees_Range_Parent__c = '2000';
            accObj.Account_Planning_Business_Goals__c = 'Test Goals';
            accObj.Account_Planning_Strategy__c= 'Test Starategy';
            accObj.Back_Office_System__c = 'null';
            insert accObj;  
            
            // Create Contact Record.
            conObj = TestUtil.createContact(accObj.id);
            insert conObj; 
            
            // Create Active ARAs with the Account. 
            araObj = new ARA__c();
            araObj.Account__c = accObj.Id;
            araObj.Status__c = 'Open';
            insert araObj;
            
            // Create Customer Success Review
            csrObj = new Customer_Success_Review__c();
            csrObj.Account__c = accObj.Id;
            csrObj.Goals_with_Cvent__c = 'Cvent Business Goals';
            csrObj.Status__c = 'CSR Conducted';
            insert csrObj;
            
            // Create Campaign record
            campObj = new Campaign();
            campObj.Name = 'Account Planning Campaign';
            campObj.Account_BizDev__c = accObj.Id;
            campObj.Status = 'Attended';
            campObj.Type = 'Live Event';
            insert campObj;
            
            List<Contact_Role__c> buyerRoleList = new List<Contact_Role__c>();
            // Create Buyer Roles for the Account. 
            conRoleObj = new Contact_Role__c();
            conRoleObj.RecordTypeId= buyerRoleRectypeId;
            conRoleObj.Contact__c = conObj.Id;
            conRoleObj.Account_Buyer_Role__c = accObj.Id;
            conRoleObj.Product__c = 'Event';
            conRoleObj.Executive_Sponsor__c = true;
            conRoleObj.Decision_Maker__c = true;
            conRoleObj.Influencer__c = true;
            conRoleObj.Last_Login_Date__c = System.today() - 50;
            buyerRoleList.add(conRoleObj);
            
            conRoleObj = new Contact_Role__c();
            conRoleObj.RecordTypeId= buyerRoleRectypeId;
            conRoleObj.Contact__c = conObj.Id;
            conRoleObj.Account_Buyer_Role__c = accObj.Id;
            conRoleObj.Product__c = 'Event';
            conRoleObj.Executive_Sponsor__c = true;
            conRoleObj.Decision_Maker__c = true;
            conRoleObj.Influencer__c = true;
            conRoleObj.Last_Login_Date__c = System.today() - 50;
            buyerRoleList.add(conRoleObj);        
            insert buyerRoleList;   
            
            // Create Event record.
            Event evtObj = new Event();
            evtObj.Source__c = 'ACD';
            evtObj.DurationInMinutes = 12;
            evtObj.ActivityDateTime = system.now();
            evtObj.Subject = 'Presentation-Onsite';
            evtObj.WhatId = accObj.Id;
            evtObj.WhoId = conObj.Id;
            insert evtObj;
            
            List<Opportunity> oppList = new List<Opportunity>();
            // Create an CPQ Opportuntunity
            oppObj1 = TestUtil.createOpportunity('testOpp1','Event','Presentation');
            oppObj1.Contact_Associated__c = conObj.Id;
            oppObj1.Contact_Role__c = 'Influencer';
            oppObj1.StageName = 'Closed Won';
            oppObj1.AccountId = accObj.Id;
            oppObj1.Event_Planner_Name__c = 'test User';
            oppObj1.Event_Planner_Email__c = 'testuser@cvent.com';
            oppObj1.CloseDate = Date.today().addDays(-380);
            oppList.add(oppObj1);
            
            // Create an CPQ Opportuntunity
            oppObj2 = TestUtil.createOpportunity('testOpp2','Event','Presentation');
            oppObj2.Contact_Associated__c = conObj.Id;
            oppObj2.Contact_Role__c = 'Influencer';
            oppObj2.StageName = 'Up for Renewal';
            oppObj2.AccountId = accObj.Id;
            oppObj2.Event_Planner_Name__c = 'test User';
            oppObj2.Event_Planner_Email__c = 'testuser@cvent.com';
            oppObj2.CloseDate = Date.today().addDays(80);        
            insert oppObj2;
            
            // Reset all Salesforce Governer LIMITS
            Test.startTest();
            
            // Create an CPQ Opportuntunity
            oppObj3 = TestUtil.createOpportunity('testOpp3','Event','Presentation');
            oppObj3.Contact_Associated__c = conObj.Id;
            oppObj3.Contact_Role__c = 'Influencer';
            oppObj3.StageName = 'Closed Won';
            oppObj3.AccountId = accObj.Id;
            oppObj3.Event_Planner_Name__c = 'test User';
            oppObj3.Event_Planner_Email__c = 'testuser@cvent.com';
            oppObj3.CloseDate = Date.today().addDays(-20);
            insert oppObj3;
            
            // Associate Quote 1 To Opp 1
            SBQQ__Quote__c quote1 = new SBQQ__Quote__c();
            quote1.SBQQ__StartDate__c = System.today();
            quote1.SBQQ__Opportunity2__c = oppObj1.Id;
            quote1.SBQQ__EndDate__c = System.today() + 365;
            quote1.Effective_Year_1_Start_Date__c = quote1.SBQQ__StartDate__c;
            quote1.Effective_Year_1_End_Date__c = quote1.SBQQ__EndDate__c;
            quote1.Effective_Year_2_Start_Date__c = quote1.Effective_Year_1_End_Date__c + 1;
            quote1.Effective_Year_2_End_Date__c = quote1.Effective_Year_2_Start_Date__c + 365;
            quote1.Effective_Year_3_Start_Date__c = quote1.Effective_Year_2_End_Date__c + 1;
            quote1.Effective_Year_3_End_Date__c = quote1.Effective_Year_3_Start_Date__c + 365;
            quote1.Effective_Year_4_Start_Date__c = quote1.Effective_Year_3_End_Date__c + 1;
            quote1.Effective_Year_4_End_Date__c = quote1.Effective_Year_4_Start_Date__c + 365;
            quote1.Effective_Year_5_Start_Date__c = quote1.Effective_Year_4_End_Date__c + 1;
            quote1.Effective_Year_5_End_Date__c = quote1.Effective_Year_5_Start_Date__c + 365;
            quote1.Contract_Term_Years__c = '5';
            quote1.Count_of_HC_Products__c = 0;
            quote1.Count_of_EC_Products__c = 1;
            quote1.Multiple_Years_Commitment__c = TRUE;
            quote1.SBQQ__Account__c = accObj.Id;
            quote1.Current_Year__c = 1;
            insert quote1;
            
            List<Product2> products = new List<Product2>();
            Product2 product1 = new Product2();
            product1.Name = 'Product 1';
            product1.Family = 'Event';
            product1.Contract_Output_Grouping__c = 'Bundle Advertisements';
            products.add(product1);
            
            Product2 product2 = new Product2();
            product2.Name = 'Product 2';
            Product2.Family = 'CrowdCompass';
            product2.Contract_Output_Grouping__c = 'Suggested Advertisements';
            products.add(product2);
            
            Product2 product3 = new Product2();
            product3.Name = 'Product 3';
            product3.Family = 'Onsite Solutions';
            product3.Contract_Output_Grouping__c = 'Video Retargeting';
            products.add(product3);
            
            Product2 product4 = new Product2();
            product4.Name = 'Product 4';
            product4.Family = 'CSN';
            product4.Contract_Output_Grouping__c = 'Elite Meetings Alliance';
            products.add(product4);
            
            Product2 product5 = new Product2();
            product5.Name = 'Product 5';
            product5.Family = 'Survey'; 
            product5.Contract_Output_Grouping__c = 'Reporting & Analytics';
            products.add(product5);
            
            Product2 product6 = new Product2();
            product6.Name = 'Product 6';
            product6.Contract_Output_Grouping__c = 'Cvent Passkey, Transient & Lanyon Group';
            products.add(product6);
            
            Product2 product7 = new Product2();
            product7.Name = 'Product 7';
            product7.Contract_Output_Grouping__c = 'Listing Advertisement(s), Software, Services & CONNECT';
            products.add(product7);
            
            Product2 product8 = new Product2();
            product8.Name = 'Product 8';
            product8.Contract_Output_Grouping__c = 'Merchant';
            products.add(product8);        
            insert products;
            
            // Create Contract record
            newCon = new Contract();
            newCon.AccountId = accObj.Id;
            newCon.SBQQ__Opportunity__c = oppObj2.Id;
            
            insert newCon;  
            
            List<Customer_Asset__c> cusAssetList = new List<Customer_Asset__c>();
            // Create Customer Asset record manually
            Customer_Asset__c newAsset;
            for(Integer i=1; i < 11 ;i++){
                newAsset = new Customer_Asset__c();
                newAsset.Account__c = accObj.Id;
                newAsset.Contract__c = newCon.Id;
                newAsset.Annual_Recurring_Revenue__c = 100 * i;
                if(i < 3){
                    newAsset.Product__c = products[0].Id;
                    newAsset.Term_Start_Date__c = Date.today().addDays(-30);
                    newAsset.Term_End_Date__c = Date.today().addDays(30);
                }else if(i > 2 && i < 5){
                    newAsset.Product__c = products[1].Id;
                    newAsset.Term_Start_Date__c = Date.today().addDays(-30);
                    newAsset.Term_End_Date__c = Date.today().addDays(60);
                }else if(i > 4 && i < 7){
                    newAsset.Product__c = products[2].Id;
                    newAsset.Term_Start_Date__c = Date.today().addDays(-30);
                    newAsset.Term_End_Date__c = Date.today().addDays(60);
                }else if(i > 6 && i < 9){
                    newAsset.Product__c = products[3].Id;
                    newAsset.Term_Start_Date__c = Date.today().addDays(-30);
                    newAsset.Term_End_Date__c = Date.today().addDays(60);
                }else if(i > 8 && i < 11){
                    newAsset.Product__c = products[4].Id;
                    newAsset.Term_Start_Date__c = Date.today().addDays(-30);
                    newAsset.Term_End_Date__c = Date.today().addDays(60);
                }                
                cusAssetList.add(newAsset);
            }
            
            insert cusAssetList;
            
            List<PricebookEntry> pbeList = new List<PricebookEntry>();        
            PricebookEntry pbe1 =  TestUtil.createPricebookEntry(products[0],200);
            pbeList.add(pbe1);
            PricebookEntry pbe2 =  TestUtil.createPricebookEntry(products[1],400);
            pbeList.add(pbe2);
            PricebookEntry pbe3 =  TestUtil.createPricebookEntry(products[2],200);
            pbeList.add(pbe3);
            PricebookEntry pbe4 =  TestUtil.createPricebookEntry(products[3],400);
            pbeList.add(pbe4);
            PricebookEntry pbe5 =  TestUtil.createPricebookEntry(products[4],200);
            pbeList.add(pbe5);
            PricebookEntry pbe6 =  TestUtil.createPricebookEntry(products[5],400);
            pbeList.add(pbe6);
            PricebookEntry pbe7 =  TestUtil.createPricebookEntry(products[6],200);
            pbeList.add(pbe7);
            PricebookEntry pbe8 =  TestUtil.createPricebookEntry(products[7],400);
            pbeList.add(pbe8);
            
            insert pbeList;
            
            List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
            SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c();
            SBQQ__QuoteLine__c ql2 = new SBQQ__QuoteLine__c();
            SBQQ__QuoteLine__c ql3 = new SBQQ__QuoteLine__c();
            SBQQ__QuoteLine__c ql4 = new SBQQ__QuoteLine__c();
            SBQQ__QuoteLine__c ql5 = new SBQQ__QuoteLine__c();
            SBQQ__QuoteLine__c ql6 = new SBQQ__QuoteLine__c();
            SBQQ__QuoteLine__c ql7 = new SBQQ__QuoteLine__c();
            SBQQ__QuoteLine__c ql8 = new SBQQ__QuoteLine__c();
            ql1.SBQQ__Quantity__c = 1;
            ql1.SBQQ__Product__c = product1.Id;
            ql1.SBQQ__ListPrice__c = 10;
            ql1.SBQQ__NetPrice__c = 10;
            ql1.SBQQ__SubscriptionPricing__c = 'Fixed Price';
            ql1.Rack_Rate__c = 10;
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
            ql1.SBQQ__Quote__c = quote1.Id;
            ql1.Notes__c = 'abc';
            quoteLines.add(ql1);
            ql2 = ql1.clone();
            ql2.SBQQ__Product__c = product2.Id;
            quoteLines.add(ql2);
            ql3 = ql1.clone();
            ql3.SBQQ__Product__c = product3.Id;
            quoteLines.add(ql3);
            ql4 = ql1.clone();
            ql4.SBQQ__Product__c = product4.Id;
            quoteLines.add(ql4);
            ql5 = ql1.clone();
            ql5.SBQQ__Product__c = product5.Id;
            quoteLines.add(ql5);
            ql6 = ql1.clone();
            ql6.SBQQ__Product__c = product6.Id;
            quoteLines.add(ql6);
            ql7 = ql1.clone();
            ql7.SBQQ__Product__c = product7.Id;
            quoteLines.add(ql7);
            ql8 = ql1.clone();
            ql8.SBQQ__Product__c = product8.Id;
            quoteLines.add(ql8);
            
            insert quoteLines;
            
            SBQQ__Quote__c quoteToUpdate = [Select Id,SBQQ__Primary__c From SBQQ__Quote__c Where Id = :quote1.Id LIMIT 1];
            quoteToUpdate.SBQQ__Primary__c = true;
            update quoteToUpdate;
            
            // Load Account Planning Page.
            Apexpages.StandardController stdCon = new Apexpages.StandardController(accObj);
            AccountPlanning_ContExt controller = new AccountPlanning_ContExt(stdCon);        
            Test.stopTest();
        }
    }
    
    static testMethod void testPageButtons(){
        system.runAs(depUser){
            // Create Account Record.
            accObj = TestUtil.createAccount('EB Account 1', 'Biz_Ac');
            accObj.of_Employees_Range_Parent__c = '2000';
            accObj.Share_of_Wallet__c = 5000000;
            //accObj.Total_of_Events_Year__c = 5;   //Commented By Mohsin on 21st June 2019 - FP Activity
            insert accObj;
            
            List<CVII_Event_Data__c> cviiDataList = new List<CVII_Event_Data__c>();
            CVII_Event_Data__c cviiDataObj;
            for(Integer i = 1; i < 10 ; i++){
                cviiDataObj = new CVII_Event_Data__c();
                cviiDataObj.Account__c = accObj.Id;
                cviiDataObj.Total_Accepted__c = 50*i;
                cviiDataList.add(cviiDataObj);
            }            
            insert cviiDataList;
            
            // Load Account Planning Page.
            Apexpages.StandardController stdCon = new Apexpages.StandardController(accObj);
            AccountPlanning_ContExt controller = new AccountPlanning_ContExt(stdCon);
            
            controller.Save();        
            controller.Cancel();        
            controller.showDetailedView();        
            controller.hideDetailedView();
        }
    }
}