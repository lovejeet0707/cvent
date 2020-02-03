/*****************************************************************
* Author : Sandeep Kumar
* Date : 12 April, 2017
* Description : It tests below mentioned classes
* 1) CreatePSPOnOppLineItemInsertion_TrigAct
* 2) EBProjectUpdatePendingHrsForCompletion
* 3) EBProjectAssignmentRollup_TrigAct
*******************************************************************/
@isTest(seeAllData= true)
public class CreatePSPOnOppLineItem_TrigAct_Test {    
    private static Opportunity opp;
    private static Account acc; 
    private static Contact con;
    private static User testUser;
    private static List<User> userList;
    private static SBQQ__Quote__c testQuote;
    private static Implementation_Survey__c impSurvey;
    private static Professional_Services_Project__c PSP;    
    private static List<EB_Agent_Profile__c> eBAgentProfileList;
    private static List<PricebookEntry> pbeList;
    private static User depUser = [Select Id, ProfileId from User where Name = 'CRM Deployment User'];
    private static Id userProfieId = UserProfileUtil.getProfileIDByName('Customer Care Rep - Product Consultant EB Team');    
    
    public static void setupData(){
        // Create Contact Record.
        con = TestUtil.createContact(acc.id);
        insert con;
        
        userList = new List<User>();
        // Create Salesforce Users for which will be assigned to EB Agent Profile later.
        User usr1 = TestUtil.createUser(userProfieId);
        usr1.username= 'CreatePSPOnOppLineItem_TrigAct_Test@test.com';
        //usr1.ContactId = con.Id;
        usr1.FederationIdentifier = 'F8ECWVJWT98C';
        userList.add(usr1);
        
        User usr2 = TestUtil.createUser(userProfieId);
        usr2.username= 'CreatePSPOnOppLineItem_TrigAct_Test2@test.com';
        //usr1.ContactId = con.Id;
        usr1.FederationIdentifier = 'F8ECWVJWT98D';
        userList.add(usr2);
        
        User usr3 = TestUtil.createUser(userProfieId);
        usr3.username= 'CreatePSPOnOppLineItem_TrigAct_Test3@test.com';
        //usr1.ContactId = con.Id;
        usr1.FederationIdentifier = 'F8ECWVJWT98E';
        userList.add(usr3);
        
        User usr4 = TestUtil.createUser(userProfieId);
        usr4.username= 'CreatePSPOnOppLineItem_TrigAct_Test4@test.com';
        //usr1.ContactId = con.Id;
        usr1.FederationIdentifier = 'F8ECWVJWT98F';
        userList.add(usr4);
        
        User usr5 = TestUtil.createUser(userProfieId);
        usr5.username= 'CreatePSPOnOppLineItem_TrigAct_Test5@test.com';
        //usr1.ContactId = con.Id;
        usr1.FederationIdentifier = 'F8ECWVJWT98G';
        userList.add(usr5);
        
        User usr6 = TestUtil.createUser(userProfieId);
        usr6.username= 'CreatePSPOnOppLineItem_TrigAct_Test6@test.com';
        //usr1.ContactId = con.Id;
        usr1.FederationIdentifier = 'F8ECWVJWT98H';
        userList.add(usr6);
        
        User usr7 = TestUtil.createUser(userProfieId);
        usr7.username= 'CreatePSPOnOppLineItem_TrigAct_Test7@test.com';
        //usr1.ContactId = con.Id;
        usr1.FederationIdentifier = 'F8ECWVJWT98I';
        userList.add(usr7);
        
        insert userList;  
        
        eBAgentProfileList = new List<EB_Agent_Profile__c>();
        // Create EB Agent Profile Records.   
        EB_Agent_Profile__c EBAgentProfile1 = TestUtil.createEBAgentProfile('Profile 1',userList[0].Id,'Low - 1');
        eBAgentProfileList.add(EBAgentProfile1);
        EB_Agent_Profile__c EBAgentProfile2 = TestUtil.createEBAgentProfile('Profile 2',userList[1].Id,'Med - 2');
        eBAgentProfileList.add(EBAgentProfile2);
        EB_Agent_Profile__c EBAgentProfile3 = TestUtil.createEBAgentProfile('Profile 3',userList[2].Id,'Top - 3');
        eBAgentProfileList.add(EBAgentProfile3);
        EB_Agent_Profile__c EBAgentProfile4 = TestUtil.createEBAgentProfile('Profile 4',userList[3].Id,'ARA - Inactive');
        eBAgentProfileList.add(EBAgentProfile4);
        EB_Agent_Profile__c EBAgentProfile5 = TestUtil.createEBAgentProfile('Profile 5',userList[4].Id,'ARA - Active');
        eBAgentProfileList.add(EBAgentProfile5);
        EB_Agent_Profile__c EBAgentProfile6 = TestUtil.createEBAgentProfile('Profile 6',userList[5].Id,'Enterprise Project1');
        eBAgentProfileList.add(EBAgentProfile6);
        EB_Agent_Profile__c EBAgentProfile7 = TestUtil.createEBAgentProfile('Profile 7',userList[6].Id,'Event Quarterback Project');        
        eBAgentProfileList.add(EBAgentProfile7);        
        insert eBAgentProfileList;          
                        
        // Create Product Record.
        List<Product2> products =  TestUtil.createProducts(
            new List<String>{
                'Event Builder(s) - Simple',
                    'Event Builder(s) - Medium',
                    'Event Builder(s) - Complex',
                    'Event Builder(s) - Advanced',
                    'Event Builder Rush Services – Simple',
                    'Event Builder Rush Services – Medium',
                    'Event Builder Rush Services – Complex',
                    'Event Builder Rush Services – Advanced',
                    'App Build',
                    'CrowdCompass Mobile App'
                    }
        );
        
        products[8].Family = 'CrowdCompass';
        products[9].Family = 'CrowdCompass';
        insert products;
        
        pbeList = new List<PricebookEntry>();        
        PricebookEntry pbe1 =  TestUtil.createPricebookEntry(products[0],200);
        pbeList.add(pbe1);
        PricebookEntry pbe2 =  TestUtil.createPricebookEntry(products[1],400);
        pbeList.add(pbe2);
        PricebookEntry pbe3 =  TestUtil.createPricebookEntry(products[2],200);
        pbeList.add(pbe3); 
        PricebookEntry pbe4 =  TestUtil.createPricebookEntry(products[3],200);
        pbeList.add(pbe4);
        PricebookEntry pbe5 =  TestUtil.createPricebookEntry(products[4],400);
        pbeList.add(pbe5);
        PricebookEntry pbe6 =  TestUtil.createPricebookEntry(products[5],200);
        pbeList.add(pbe6);
        PricebookEntry pbe7 =  TestUtil.createPricebookEntry(products[6],200);
        pbeList.add(pbe7);
        PricebookEntry pbe8 =  TestUtil.createPricebookEntry(products[7],400);
        pbeList.add(pbe8);
        PricebookEntry pbe9 =  TestUtil.createPricebookEntry(products[8],200);
        pbeList.add(pbe9); 
        PricebookEntry pbe10 =  TestUtil.createPricebookEntry(products[9],200);
        pbeList.add(pbe10);
        insert pbeList;   
        
        Opportunity o1 = TestUtil.createOpportunity('testOpp','Event','Bid Phase');
        o1.Contact_Associated__c = con.Id;
        o1.AccountId = acc.Id;
        o1.Event_Planner_Name__c = 'test User';
        o1.Event_Planner_Email__c = 'testuser@cvent.com';
        o1.Contract_Implemented__c = false;
        o1.CloseDate = Date.today().addDays(80);
        insert o1;
        
        testQuote = new SBQQ__Quote__c();
        testQuote.SBQQ__Opportunity2__c = o1.id;
        testQuote.Contract_Term_Years__c = '2';
        testQuote.SBQQ__Type__c = 'Amendment';
        testQuote.Current_Year__c = 2;
        testQuote.Contract_Executed__c = true;
        testQuote.SBQQ__StartDate__c = System.today().addYears(-1);
        testQuote.SBQQ__EndDate__c = System.today();
        //testQuote.createdFromLegacyContract__c = true;
        // testQuote.statusCheckCount__c = 0;
        insert testQuote;
        
        impSurvey = new Implementation_Survey__c();
        impSurvey.Account__c = acc.Id;
        impSurvey.Contact__c = con.Id;
        impSurvey.Opportunity__c = o1.Id;
        impSurvey.Primary_User__c = con.Id;
        impSurvey.Quote__c = testQuote.Id;
        impSurvey.Rush_Request__c = 'Yes';        
        impSurvey.Mobile_Delivery_Date__c = 'AttendeeHub';
        impSurvey.Additional_Comments__c = 'Test Comments';        
        impSurvey.First_Mobile_Event_Date__c = Date.today();
        impSurvey.First_Mobile_Event_Launch_Date__c = Date.today();
        impSurvey.Did_this_deal_use_the_Mid_Year_Promo__c = 'Yes';
        impSurvey.K_has_mult_Bill_to_or_Ship_to_addresses__c = 'Yes';
        impSurvey.Provide_Cvent_Account_ID_If_Applicable__c = 'Test';
        impSurvey.RecordtypeId = Schema.SObjectType.Implementation_Survey__c.getRecordTypeInfosByDeveloperName().get('Event_Cloud').getRecordTypeId();
        insert impSurvey;
        
        OpportunityLineItem oli1 = TestUtil.createOpportunityLineItems(o1,pbe1);
        oli1.Quantity = 3;
        OpportunityLineItem oli2 = TestUtil.createOpportunityLineItems(o1,pbe2);
        oli1.Quantity = 3;
        OpportunityLineItem oli3 = TestUtil.createOpportunityLineItems(o1,pbe3);
        oli1.Quantity = 3;
        OpportunityLineItem oli4 = TestUtil.createOpportunityLineItems(o1,pbe4);
        oli1.Quantity = 3;
        
        // Rush Request - Simple,Medium,Advanced and Complex opportunity products 
        OpportunityLineItem oli5 = TestUtil.createOpportunityLineItems(o1,pbe5);
        OpportunityLineItem oli6 = TestUtil.createOpportunityLineItems(o1,pbe6);
        OpportunityLineItem oli7 = TestUtil.createOpportunityLineItems(o1,pbe7);
        OpportunityLineItem oli8 = TestUtil.createOpportunityLineItems(o1,pbe8);
        
        // create crowdcompass opportunity products
        OpportunityLineItem oli9 = TestUtil.createOpportunityLineItems(o1,pbe9);
        oli9.Complexity__c = 'Standard';        
        OpportunityLineItem oli10 = TestUtil.createOpportunityLineItems(o1,pbe9);
        oli10.Complexity__c = 'Medium';        
        OpportunityLineItem oli11 = TestUtil.createOpportunityLineItems(o1,pbe9);
        oli11.Complexity__c = 'Advanced';        
        OpportunityLineItem oli12 = TestUtil.createOpportunityLineItems(o1,pbe9);
        oli12.Complexity__c = 'Complex';        
        OpportunityLineItem oli13 = TestUtil.createOpportunityLineItems(o1,pbe10); 
        
        insert new List<OpportunityLineItem>{oli1,oli2,oli3,oli4,oli5,oli6,oli7,oli8,oli9,oli10,oli11,oli12,oli13};
            
            opp = o1;//[Select Id, Amount From Opportunity where Id =:o1.Id];
    }
    
    // Creates new PSP record in Salesforce.
    static testMethod void createNewEBSBProjectsOnOppClosure(){
        System.runAs(depUser){
            // Create Account Record.
            acc = TestUtil.createAccount('EB Account', 'Biz_Ac');
            acc.BillingCountry = 'US';
            insert acc;           
            // Call SetupData Method
            setupData();
            System.debug('===createNewEBSBProjectsOnOppClosure====>>>>Before'+LIMITS.getLimitQueries());
            Test.startTest();            
            opp.StageName = 'Closed Won';
            opp.Contract_Implemented__c = true;
            opp.Contract_Number_New__c = '123456';
            update opp;
            System.debug('===createNewEBSBProjectsOnOppClosure====>>>>After'+LIMITS.getLimitQueries());
            Test.stopTest();  
        }      
    }
    
    // create new PSP and EBSB Project for ARA Account
    static testMethod void createEBSBProjectsOnOppClosure(){
        System.runAs(depUser){
            OpportunityTrgHelperCls_Version_2.isComingfromTestHandler1=true;         
            // create Account Record.
            acc = TestUtil.createAccount('EB Account 1', 'Biz_Ac');
            acc.Active_ARA__c = true;
            acc.BillingCountry = 'US';
            insert acc;
             
            // create ara record
            ARA__c araObj = new ARA__c();
            araObj.Account__c =acc.Id;
            araObj.Status__c = 'Open';
            insert araObj;
            
            // create PSP record.
            PSP = new Professional_Services_Project__c();
            PSP.Account__c = acc.Id;
            PSP.of_EB__c = 2;
            insert PSP;  
            
            // call SetupData Method
            setupData();
             System.debug('===createEBSBProjectsOnOppClosure====>>>>Before'+LIMITS.getLimitQueries());
                     
            opp.StageName = 'Closed Won';
            opp.Contract_Number_New__c = '123456';
            opp.Contract_Implemented__c = false;
            Test.startTest(); 
            //update opp;
             System.debug('===createEBSBProjectsOnOppClosure====>>>>After'+LIMITS.getLimitQueries());
            Test.stopTest();  
        }      
    }   
    
    // Updates exisitng PSP record in Salesforce.
    static testMethod void updateExistingEBSBProjectsOnOppClosure(){
        System.runAs(depUser){  
            OpportunityTrgHelperCls_Version_2.isComingfromTestHandler1=true;          
            // create Account Record.
            acc = TestUtil.createAccount('EB Account 1', 'Biz_Ac');
            acc.Active_ARA__c = true;
            acc.BillingCountry = 'US';
            insert acc;
            
            // create ara record            
            ARA__c araObj = new ARA__c();
            araObj.Account__c =acc.Id;
            araObj.Status__c = 'Open';
            insert araObj;
            
            // create PSP record.
            PSP = new Professional_Services_Project__c();
            PSP.Account__c = acc.Id;
            PSP.of_EB__c = 2;
            insert PSP;       
            
            System.debug('===updateExistingEBSBProjectsOnOppClosure====>>>>Before'+LIMITS.getLimitQueries());
            // call SetupData Method
            setupData();
                     
            opp.StageName = 'Closed Won';
            opp.Contract_Number_New__c = '123456';
            opp.Contract_Implemented__c = true;
            Test.startTest();   
            //update opp;
            System.debug('===updateExistingEBSBProjectsOnOppClosure====>>>>After'+LIMITS.getLimitQueries());
            Test.stopTest();  
        }      
    }     
}