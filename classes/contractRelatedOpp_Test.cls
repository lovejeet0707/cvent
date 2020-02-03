@isTest
public class contractRelatedOpp_Test{
    static testMethod void testAccountPlanningPage(){
        // Create Account Record.
        Account accObj = TestUtil.createAccount('EB Account 1', 'Biz_Ac');
        accObj.Last_12_month_spent__c = 5000;
        accObj.Wallet_Size_Parent__c = 100000;
        accObj.of_Employees_Range_Parent__c = '2000';
        accObj.Account_Planning_Business_Goals__c = 'Test Goals';
        accObj.Account_Planning_Strategy__c= 'Test Starategy';
        accObj.Back_Office_System__c = 'null';
        insert accObj;  
        
        // Create Contact Record.
        Contact conObj = TestUtil.createContact(accObj.id);
        insert conObj; 
        
        // Create Active ARAs with the Account. 
        ARA__c araObj = new ARA__c();
        araObj.Account__c = accObj.Id;
        araObj.Status__c = 'Open';
        insert araObj;
        
        // Create Customer Success Review
        Customer_Success_Review__c csrObj = new Customer_Success_Review__c();
        csrObj.Account__c = accObj.Id;
        csrObj.Goals_with_Cvent__c = 'Cvent Business Goals';
        csrObj.Status__c = 'CSR Conducted';
        insert csrObj;
        
        // Create Campaign record
        Campaign campObj = new Campaign();
        campObj.Name = 'Account Planning Campaign';
        campObj.Account_BizDev__c = accObj.Id;
        campObj.Status = 'Attended';
        campObj.Type = 'Live Event';
        insert campObj;
        
        /*List<Contact_Role__c> buyerRoleList = new List<Contact_Role__c>();
        // Create Buyer Roles for the Account. 
        Contact_Role__c conRoleObj = new Contact_Role__c();
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
        insert buyerRoleList;  */ 
        
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
        Opportunity oppObj1 = TestUtil.createOpportunity('testOpp1','Event','Presentation');
        oppObj1.Contact_Associated__c = conObj.Id;
        oppObj1.Contact_Role__c = 'Influencer';
        oppObj1.StageName = 'Closed Won';
        oppObj1.AccountId = accObj.Id;
        oppObj1.Event_Planner_Name__c = 'test User';
        oppObj1.Event_Planner_Email__c = 'testuser@cvent.com';
        oppObj1.CloseDate = Date.today().addDays(-380);
        insert oppObj1;
        
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
        
        // Create Contract record
        Contract newCon = new Contract();
        newCon.AccountId = accObj.Id;
        newCon.SBQQ__Opportunity__c = oppObj1.Id;
        newCon.Primary_Opportunity__c = oppObj1.Id;
        insert newCon; 

        PageReference pageRef = Page.accViewContracts;
        pageRef.getParameters().put('id', String.valueOf(newCon.Id));
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(newCon);
        contractRelatedOpp testAccPlan = new contractRelatedOpp(sc);

        


        //testAccPlan.getaccountContact();
        //testAccPlan.save();       
    }
}