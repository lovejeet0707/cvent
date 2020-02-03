/**
* Author : Sandeep Kumar
* Date : 12 April, 2017
* Description : It tests below mentioned classes
* 1) EBProjectAutoAssignment_TrigAct
*/
@isTest(seeAllData= true)
public class EBProjectAutoAssignment_TrigAct_Test {
    private static Opportunity opp;
    private static Account acc; 
    private static Contact con;
    private static ARA__c AraObj;
    private static User testUser;
    private static List<User> userList;
    private static Professional_Services_Project__c PSP;    
    private static List<PricebookEntry> pbeList;    
    private static List<EB_Agent_Profile__c> eBAgentProfileList;
    private static List<EB_Project_Score_Setting__c> eBAgentScoreSettingList;
    private static List<EBProjectStageToPendingHrsSetting__c> eBProjectStageToPendingHoursSettingList;
    private static User depUser = [Select Id, ProfileId from User where Name = 'CRM Deployment User'];
    private static Id userProfieId = UserProfileUtil.getProfileIDByName('Customer Care Rep - Product Consultant EB Team');     
    
    public static void setupData() {
        // Create Contact Record.
        con = TestUtil.createContact(acc.id);
        insert con; 
        
        userList = new List<User>();
        // Create Salesforce Users for which will be assigned to EB Agent Profile later.
        User usr1 = TestUtil.createUser(userProfieId);
        usr1.username= 'EBProjectAutoAssignment_TrigAct_Test@test.com';
        userList.add(usr1);
        User usr2 = TestUtil.createUser(userProfieId);
        usr2.username= 'EBProjectAutoAssignment_TrigAct_Test2@test.com';
        userList.add(usr2);
        User usr3 = TestUtil.createUser(userProfieId);
                usr3.username= 'EBProjectAutoAssignment_TrigAct_Test3@test.com';
        userList.add(usr3);
        User usr4 = TestUtil.createUser(userProfieId);
                usr4.username= 'EBProjectAutoAssignment_TrigAct_Test4@test.com';
        userList.add(usr4);
        User usr5 = TestUtil.createUser(userProfieId);
                usr5.username= 'EBProjectAutoAssignment_TrigAct_Test5@test.com';
        userList.add(usr5);
        User usr6 = TestUtil.createUser(userProfieId);
                usr6.username= 'EBProjectAutoAssignment_TrigAct_Test6@test.com';
        userList.add(usr6);
        User usr7 = TestUtil.createUser(userProfieId);
                usr7.username= 'EBProjectAutoAssignment_TrigAct_Test7@test.com';
        userList.add(usr7);
        
        insert userList;  
        
        eBAgentProfileList = new List<EB_Agent_Profile__c>();
        // Create EB Agent Profile Records.   
        EB_Agent_Profile__c EBAgentProfile1 = TestUtil.createEBAgentProfile('Profile 1',userList[0].Id,'1');
        eBAgentProfileList.add(EBAgentProfile1);
        EB_Agent_Profile__c EBAgentProfile2 = TestUtil.createEBAgentProfile('Profile 2',userList[1].Id,'2');
        eBAgentProfileList.add(EBAgentProfile2);
        EB_Agent_Profile__c EBAgentProfile3 = TestUtil.createEBAgentProfile('Profile 3',userList[2].Id,'3');
        eBAgentProfileList.add(EBAgentProfile3);
        EB_Agent_Profile__c EBAgentProfile4 = TestUtil.createEBAgentProfile('Profile 4',userList[3].Id,'ARA');
        eBAgentProfileList.add(EBAgentProfile4);
        EB_Agent_Profile__c EBAgentProfile5 = TestUtil.createEBAgentProfile('Profile 5',userList[4].Id,'ARA');
        eBAgentProfileList.add(EBAgentProfile5);
        EB_Agent_Profile__c EBAgentProfile6 = TestUtil.createEBAgentProfile('Profile 6',userList[5].Id,'Enterprise Project');
        eBAgentProfileList.add(EBAgentProfile6);
        EB_Agent_Profile__c EBAgentProfile7 = TestUtil.createEBAgentProfile('Profile 7',userList[6].Id,'Event Quarterback Project');        
        eBAgentProfileList.add(EBAgentProfile7);        
        insert eBAgentProfileList;        
        
        /*
eBAgentScoreSettingList = new List<EB_Project_Score_Setting__c>(); 
EB_Project_Score_Setting__c EBProjSetting1 = TestUtil.createEBProjScoreSetting('Event Builder - Express','EB Type',8,1);
eBAgentScoreSettingList.add(EBProjSetting1);
EB_Project_Score_Setting__c EBProjSetting2 = TestUtil.createEBProjScoreSetting('Custom Task','EB Type',8,2);
eBAgentScoreSettingList.add(EBProjSetting2);
EB_Project_Score_Setting__c EBProjSetting3 = TestUtil.createEBProjScoreSetting('Event Builder - Premium','EB Type',8,5);
eBAgentScoreSettingList.add(EBProjSetting3);
EB_Project_Score_Setting__c EBProjSetting4 = TestUtil.createEBProjScoreSetting('ARA Re-build','EB Type',8,5);
eBAgentScoreSettingList.add(EBProjSetting4);
EB_Project_Score_Setting__c EBProjSetting5 = TestUtil.createEBProjScoreSetting('2-Medium','Complexity',5,2);
eBAgentScoreSettingList.add(EBProjSetting5);
EB_Project_Score_Setting__c EBProjSetting6 = TestUtil.createEBProjScoreSetting('3-Advanced','Complexity',5,3);
eBAgentScoreSettingList.add(EBProjSetting6);
EB_Project_Score_Setting__c EBProjSetting7 = TestUtil.createEBProjScoreSetting('4-Complex','Complexity',5,5);
eBAgentScoreSettingList.add(EBProjSetting7);
EB_Project_Score_Setting__c EBProjSetting8 = TestUtil.createEBProjScoreSetting('Silver','Tier of Account',7,2);
eBAgentScoreSettingList.add(EBProjSetting8);
EB_Project_Score_Setting__c EBProjSetting9 = TestUtil.createEBProjScoreSetting('Gold','Tier of Account',7,3);
eBAgentScoreSettingList.add(EBProjSetting9);
EB_Project_Score_Setting__c EBProjSetting10 = TestUtil.createEBProjScoreSetting('Platinum','Tier of Account',7,5);
eBAgentScoreSettingList.add(EBProjSetting10);
EB_Project_Score_Setting__c EBProjSetting11 = TestUtil.createEBProjScoreSetting('Event Builder - SU4','EB Type',8,1);
eBAgentScoreSettingList.add(EBProjSetting11);
EB_Project_Score_Setting__c EBProjSetting12 = TestUtil.createEBProjScoreSetting('Internal Event Rebuild','EB Type',8,1);
eBAgentScoreSettingList.add(EBProjSetting12);
EB_Project_Score_Setting__c EBProjSetting13 = TestUtil.createEBProjScoreSetting('Event Builder - Regular','EB Type',8,1);
eBAgentScoreSettingList.add(EBProjSetting13);
EB_Project_Score_Setting__c EBProjSetting14 = TestUtil.createEBProjScoreSetting('Demo Event','EB Type',8,1);
eBAgentScoreSettingList.add(EBProjSetting14);
EB_Project_Score_Setting__c EBProjSetting15 = TestUtil.createEBProjScoreSetting('1-Simple','Complexity',5,1);
eBAgentScoreSettingList.add(EBProjSetting15);
EB_Project_Score_Setting__c EBProjSetting16 = TestUtil.createEBProjScoreSetting('Bronze','Tier of Account',7,1);
eBAgentScoreSettingList.add(EBProjSetting16);
EB_Project_Score_Setting__c EBProjSetting17 = TestUtil.createEBProjScoreSetting('Event Builder - Rush','EB Type',8,1);
eBAgentScoreSettingList.add(EBProjSetting17);

insert eBAgentScoreSettingList;        

eBProjectStageToPendingHoursSettingList = new List<EBProjectStageToPendingHrsSetting__c>();

// Create EBProjectStageToPendingHrsSetting records.
EBProjectStageToPendingHrsSetting__c EBProjectHrsSetting1 = TestUtil.createEbProjectStageToPendingHrsSetting('Fourth Round of Changes Received', 4.87, 5.5, 3.33, 2.05);
eBProjectStageToPendingHoursSettingList.add(EBProjectHrsSetting1);
EBProjectStageToPendingHrsSetting__c EBProjectHrsSetting2 = TestUtil.createEbProjectStageToPendingHrsSetting('Fourth Round of Changes Completed', 4.87, 5.5, 3.33, 2.05);
eBProjectStageToPendingHoursSettingList.add(EBProjectHrsSetting2);
EBProjectStageToPendingHrsSetting__c EBProjectHrsSetting3 = TestUtil.createEbProjectStageToPendingHrsSetting('Additional Round of Changes Received', 3.2, 3.5, 2, 1.75);
eBProjectStageToPendingHoursSettingList.add(EBProjectHrsSetting3);
EBProjectStageToPendingHrsSetting__c EBProjectHrsSetting4 = TestUtil.createEbProjectStageToPendingHrsSetting('All the Changes Completed', 3.2, 3.5, 2, 1.75);
eBProjectStageToPendingHoursSettingList.add(EBProjectHrsSetting4);
EBProjectStageToPendingHrsSetting__c EBProjectHrsSetting5 = TestUtil.createEbProjectStageToPendingHrsSetting('Event Testing', 3.2, 3.5, 2, 1.75);
eBProjectStageToPendingHoursSettingList.add(EBProjectHrsSetting5);
EBProjectStageToPendingHrsSetting__c EBProjectHrsSetting6 = TestUtil.createEbProjectStageToPendingHrsSetting('Event Launched', 1.5, 1.5, 1, 1);
eBProjectStageToPendingHoursSettingList.add(EBProjectHrsSetting6);
EBProjectStageToPendingHrsSetting__c EBProjectHrsSetting7 = TestUtil.createEbProjectStageToPendingHrsSetting('Sign Off Done', 0, 0, 0, 0);
eBProjectStageToPendingHoursSettingList.add(EBProjectHrsSetting7);
EBProjectStageToPendingHrsSetting__c EBProjectHrsSetting8 = TestUtil.createEbProjectStageToPendingHrsSetting('Premium Services - Post Launch Support', 0, 0, 0, 0);
eBProjectStageToPendingHoursSettingList.add(EBProjectHrsSetting8);
EBProjectStageToPendingHrsSetting__c EBProjectHrsSetting9 = TestUtil.createEbProjectStageToPendingHrsSetting('Setup Call Scheduled', 21, 27, 17, 10);
eBProjectStageToPendingHoursSettingList.add(EBProjectHrsSetting9);
EBProjectStageToPendingHrsSetting__c EBProjectHrsSetting10 = TestUtil.createEbProjectStageToPendingHrsSetting('Setup Call Done', 21, 27, 16.25, 9.8);
eBProjectStageToPendingHoursSettingList.add(EBProjectHrsSetting10);
EBProjectStageToPendingHrsSetting__c EBProjectHrsSetting11 = TestUtil.createEbProjectStageToPendingHrsSetting('Working on First Draft', 20, 25.5, 15.5, 9);
eBProjectStageToPendingHoursSettingList.add(EBProjectHrsSetting11);
EBProjectStageToPendingHrsSetting__c EBProjectHrsSetting12 = TestUtil.createEbProjectStageToPendingHrsSetting('First Draft Completed', 12.27, 15, 9.5, 6.05);
eBProjectStageToPendingHoursSettingList.add(EBProjectHrsSetting12);
EBProjectStageToPendingHrsSetting__c EBProjectHrsSetting13 = TestUtil.createEbProjectStageToPendingHrsSetting('First Round of Changes Received', 12.27, 15, 9.5, 6.05);
eBProjectStageToPendingHoursSettingList.add(EBProjectHrsSetting13);
EBProjectStageToPendingHrsSetting__c EBProjectHrsSetting14 = TestUtil.createEbProjectStageToPendingHrsSetting('First Round of Changes Completed', 12.27, 15, 9.5, 6.05);
eBProjectStageToPendingHoursSettingList.add(EBProjectHrsSetting14);
EBProjectStageToPendingHrsSetting__c EBProjectHrsSetting15 = TestUtil.createEbProjectStageToPendingHrsSetting('Second Round of Changes Received', 9.67, 11, 7, 4.38);
eBProjectStageToPendingHoursSettingList.add(EBProjectHrsSetting15);
EBProjectStageToPendingHrsSetting__c EBProjectHrsSetting16 = TestUtil.createEbProjectStageToPendingHrsSetting('Second Round of Changes Completed', 9.67, 11, 7, 4.38);
eBProjectStageToPendingHoursSettingList.add(EBProjectHrsSetting16);
EBProjectStageToPendingHrsSetting__c EBProjectHrsSetting17 = TestUtil.createEbProjectStageToPendingHrsSetting('Third Round of Changes Received', 7.17, 8, 5, 3.05);
eBProjectStageToPendingHoursSettingList.add(EBProjectHrsSetting17);
EBProjectStageToPendingHrsSetting__c EBProjectHrsSetting18 = TestUtil.createEbProjectStageToPendingHrsSetting('Third Round of Changes Completed', 7.17, 8, 5, 3.05);
eBProjectStageToPendingHoursSettingList.add(EBProjectHrsSetting18);
EBProjectStageToPendingHrsSetting__c EBProjectHrsSetting19 = TestUtil.createEbProjectStageToPendingHrsSetting('Information Received', 21, 27, 17, 10);
eBProjectStageToPendingHoursSettingList.add(EBProjectHrsSetting19);

insert eBProjectStageToPendingHoursSettingList;
*/
        // Create Product Record.
        List<Product2> products =  TestUtil.createProducts(new List<String>{'EOY Cvent Event Builder Promotion- Advanced','EOY Cvent Event Builder Promotion- Advanced with Mobile','EOY Cvent Event Builder Promotion- Complex','EOY Cvent Event Builder Promotion- Complex with Mobile','EOY Cvent Event Builder Promotion- Medium','EOY Cvent Event Builder Promotion- Medium with Mobile','EOY Cvent Event Builder Promotion- Simple','EOY Cvent Event Builder Promotion- Simple with Mobile','Event Builder - Additional Round of Changes','Event Builder - Complex','Event Builder-Enterprise-Complex','Event Builder-Enterprise-Medium','Event Builder Premium Services - Advanced','Event Builder Premium Services - Advanced + Event Quarterback','Event Builder Premium Services - Complex','Event Builder Premium Services - Complex + Event Quarterback','Event Builder Premium Services - Complex (with Mobile)','Event Builder Premium Services - Medium','Event Builder Premium Services - Medium + Event Quarterback','Event Builder Premium Services - Simple','Event Builder Premium Services - Simple + Event Quarterback','Event Builder(s)','Event Builder(s) - Advanced','Event Builder(s) - Advanced + Event Quarterback','Event Builder(s) - Advanced with Mobile','Event Builder(s) - Advanced with Mobile + Event Quarterback','Event Builder(s) - Complex','Event Builder(s) - Complex + Event Quarterback','Event Builder(s) - Complex with Mobile','Event Builder(s) - Complex with Mobile + Event Quarterback','Event Builder(s) - Express','Event Builder(s) - Medium','Event Builder(s) - Medium + Event Quarterback','Event Builder(s) - Medium with Mobile','Event Builder(s) - Medium with Mobile + Event Quarterback','Event Builder(s) - Simple','Event Builder(s) - Simple + Event Quarterback','Event Builder(s) - Simple with Mobile','Event Builder(s) - Simple with Mobile + Event Quarterback','Event Builder(s) â€“ Express'});
        insert products;
        pbeList = new List<PricebookEntry>();        
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
        PricebookEntry pbe9 =  TestUtil.createPricebookEntry(products[8],200);
        pbeList.add(pbe9);
        PricebookEntry pbe10 =  TestUtil.createPricebookEntry(products[9],400);
        pbeList.add(pbe10);
        PricebookEntry pbe11 =  TestUtil.createPricebookEntry(products[10],200);
        pbeList.add(pbe11);
        PricebookEntry pbe12 =  TestUtil.createPricebookEntry(products[11],400);
        pbeList.add(pbe12);
        PricebookEntry pbe13 =  TestUtil.createPricebookEntry(products[12],400);
        pbeList.add(pbe13);
        PricebookEntry pbe14 =  TestUtil.createPricebookEntry(products[13],200);
        pbeList.add(pbe14);
        PricebookEntry pbe15 =  TestUtil.createPricebookEntry(products[14],400);
        pbeList.add(pbe15);
        PricebookEntry pbe16 =  TestUtil.createPricebookEntry(products[15],200);
        pbeList.add(pbe16);
        PricebookEntry pbe17 =  TestUtil.createPricebookEntry(products[16],400);
        pbeList.add(pbe17);
        PricebookEntry pbe18 =  TestUtil.createPricebookEntry(products[17],200);
        pbeList.add(pbe18);
        PricebookEntry pbe19 =  TestUtil.createPricebookEntry(products[18],400);
        pbeList.add(pbe19);
        PricebookEntry pbe20 =  TestUtil.createPricebookEntry(products[19],200);
        pbeList.add(pbe20);
        PricebookEntry pbe21 =  TestUtil.createPricebookEntry(products[20],400);
        pbeList.add(pbe21);
        PricebookEntry pbe22 =  TestUtil.createPricebookEntry(products[21],200);
        pbeList.add(pbe22);
        PricebookEntry pbe23 =  TestUtil.createPricebookEntry(products[22],400);
        pbeList.add(pbe23);
        PricebookEntry pbe24 =  TestUtil.createPricebookEntry(products[23],200);
        pbeList.add(pbe24);
        PricebookEntry pbe25 =  TestUtil.createPricebookEntry(products[24],400);
        pbeList.add(pbe25);
        PricebookEntry pbe26 =  TestUtil.createPricebookEntry(products[25],200);
        pbeList.add(pbe26);
        PricebookEntry pbe27 =  TestUtil.createPricebookEntry(products[26],400);
        pbeList.add(pbe27);
        PricebookEntry pbe28 =  TestUtil.createPricebookEntry(products[27],200);
        pbeList.add(pbe28);
        PricebookEntry pbe29 =  TestUtil.createPricebookEntry(products[28],400);
        pbeList.add(pbe29);
        PricebookEntry pbe30 =  TestUtil.createPricebookEntry(products[29],200);
        pbeList.add(pbe30);
        PricebookEntry pbe31 =  TestUtil.createPricebookEntry(products[30],400);
        pbeList.add(pbe31);
        PricebookEntry pbe32 =  TestUtil.createPricebookEntry(products[31],200);
        pbeList.add(pbe32);
        PricebookEntry pbe33 =  TestUtil.createPricebookEntry(products[32],400);
        pbeList.add(pbe33);
        PricebookEntry pbe34 =  TestUtil.createPricebookEntry(products[33],200);
        pbeList.add(pbe34);
        PricebookEntry pbe35 =  TestUtil.createPricebookEntry(products[34],400);
        pbeList.add(pbe35);
        PricebookEntry pbe36 =  TestUtil.createPricebookEntry(products[35],200);
        pbeList.add(pbe36);
        PricebookEntry pbe37 =  TestUtil.createPricebookEntry(products[36],400);
        pbeList.add(pbe37);
        PricebookEntry pbe38 =  TestUtil.createPricebookEntry(products[37],200);
        pbeList.add(pbe38);
        PricebookEntry pbe39 =  TestUtil.createPricebookEntry(products[38],400);
        pbeList.add(pbe39);
        PricebookEntry pbe40 =  TestUtil.createPricebookEntry(products[39],200);
        pbeList.add(pbe40);
        
        insert pbeList;   
        
        Opportunity o1 = TestUtil.createOpportunity('testOpp','Event','Bid Phase');
        o1.Contact_Associated__c = con.Id;
        o1.AccountId = acc.Id;
        o1.Event_Planner_Name__c = 'test User';
        o1.Event_Planner_Email__c = 'testuser@cvent.com';
        o1.CloseDate = Date.today().addDays(80);
        insert o1;
        
        OpportunityLineItem oli1 = TestUtil.createOpportunityLineItems(o1,pbe1);
        OpportunityLineItem oli2 = TestUtil.createOpportunityLineItems(o1,pbe2);
        OpportunityLineItem oli3 = TestUtil.createOpportunityLineItems(o1,pbe3);
        OpportunityLineItem oli4 = TestUtil.createOpportunityLineItems(o1,pbe4);
        OpportunityLineItem oli5 = TestUtil.createOpportunityLineItems(o1,pbe5);
        OpportunityLineItem oli6 = TestUtil.createOpportunityLineItems(o1,pbe6);
        OpportunityLineItem oli7 = TestUtil.createOpportunityLineItems(o1,pbe7);
        OpportunityLineItem oli8 = TestUtil.createOpportunityLineItems(o1,pbe8);
        OpportunityLineItem oli9 = TestUtil.createOpportunityLineItems(o1,pbe9);
        OpportunityLineItem oli10 = TestUtil.createOpportunityLineItems(o1,pbe10);
        OpportunityLineItem oli11 = TestUtil.createOpportunityLineItems(o1,pbe11);
        OpportunityLineItem oli12 = TestUtil.createOpportunityLineItems(o1,pbe12);
        OpportunityLineItem oli13 = TestUtil.createOpportunityLineItems(o1,pbe13);
        OpportunityLineItem oli14 = TestUtil.createOpportunityLineItems(o1,pbe14);
        OpportunityLineItem oli15 = TestUtil.createOpportunityLineItems(o1,pbe15);
        OpportunityLineItem oli16 = TestUtil.createOpportunityLineItems(o1,pbe16);
        OpportunityLineItem oli17 = TestUtil.createOpportunityLineItems(o1,pbe17);
        OpportunityLineItem oli18 = TestUtil.createOpportunityLineItems(o1,pbe18);
        OpportunityLineItem oli19 = TestUtil.createOpportunityLineItems(o1,pbe19);
        OpportunityLineItem oli20 = TestUtil.createOpportunityLineItems(o1,pbe20);
        OpportunityLineItem oli21 = TestUtil.createOpportunityLineItems(o1,pbe21);
        OpportunityLineItem oli22 = TestUtil.createOpportunityLineItems(o1,pbe22);
        OpportunityLineItem oli23 = TestUtil.createOpportunityLineItems(o1,pbe23);
        OpportunityLineItem oli24 = TestUtil.createOpportunityLineItems(o1,pbe24);
        OpportunityLineItem oli25 = TestUtil.createOpportunityLineItems(o1,pbe25);
        OpportunityLineItem oli26 = TestUtil.createOpportunityLineItems(o1,pbe26);
        OpportunityLineItem oli27 = TestUtil.createOpportunityLineItems(o1,pbe27);
        OpportunityLineItem oli28 = TestUtil.createOpportunityLineItems(o1,pbe28);
        OpportunityLineItem oli29 = TestUtil.createOpportunityLineItems(o1,pbe29);
        OpportunityLineItem oli30 = TestUtil.createOpportunityLineItems(o1,pbe30);
        OpportunityLineItem oli31 = TestUtil.createOpportunityLineItems(o1,pbe31);
        OpportunityLineItem oli32 = TestUtil.createOpportunityLineItems(o1,pbe32);
        OpportunityLineItem oli33 = TestUtil.createOpportunityLineItems(o1,pbe33);
        OpportunityLineItem oli34 = TestUtil.createOpportunityLineItems(o1,pbe34);
        OpportunityLineItem oli35 = TestUtil.createOpportunityLineItems(o1,pbe35);
        OpportunityLineItem oli36 = TestUtil.createOpportunityLineItems(o1,pbe36);
        OpportunityLineItem oli37 = TestUtil.createOpportunityLineItems(o1,pbe37);
        OpportunityLineItem oli38 = TestUtil.createOpportunityLineItems(o1,pbe38);
        OpportunityLineItem oli39 = TestUtil.createOpportunityLineItems(o1,pbe39);
        OpportunityLineItem oli40 = TestUtil.createOpportunityLineItems(o1,pbe40);
        
        insert new List <OpportunityLineItem> {oli1,oli2,oli3,oli4,oli5,oli6,oli7,oli8,oli9,oli10,oli11,oli12,oli13,oli14,oli15,oli16,oli17,oli18,oli19,oli20,oli21,oli22,oli23,oli24,oli25,oli26,oli27,oli28,oli29,oli30,oli31,oli32,oli33,oli34,oli35,oli36,oli37,oli38,oli39,oli40};
            opp = [select id, amount from opportunity where id = :o1.id];
    }    
    
    // Updates exisitng EB Projects in Salesforce.
    // Testing Without ARA Accounts and Sevice Tier "Bronze"
    static testMethod void testAutoAssignmentWithBronze(){
        System.runAs(depUser){
            Test.startTest();           
            // Create Account Record.
            acc = TestUtil.createAccount('EB Account 1', 'Biz_Ac');
            insert acc;            
            
            // Call SetupData Method
            setupData(); 
            List<EB_SB_Builder__c> eBProjList = new List<EB_SB_Builder__c>();
            for(EB_SB_Builder__c  EbProj : [Select Id,Project_Received_Date__c,Project_Stage__c,EB_Agent_Profile__c,Project_Complexity__c From EB_SB_Builder__c Where AccountCustom__c =:acc.Id]){
                EbProj.Project_Received_Date__c = Date.today();
                EbProj.Survey_Feedback__c = 'Ref Id          # a0B0S000000KCIHUA4  Cvent Account Number (If you don\'t have an Account Number, please provide your full organization name)          # CVENTEB002  Day of the week preference for a Kick Off Call          # Tuesday  Time of day preference for a Kick Off Call          # Early Afternoon (11am-1pm)  Or let us know a date and time preference for the 60 minute Project Kick Off Call          # May  2 2017  4:48AM  Select your Time Zone          # MET Middle East Time GMT-6:00  Is this your first time using our EventBuild service?          # Yes  Type of Event?          # Conference – 3,000 attendees or more  Who is the audience?          # Customers  Where does your event take place?          # Offsite at a venue like a hotel or a conference center  What is the purpose of your event?          # Lead generation, Fundraising  Is this event part of a series?          # Monthly, One time, no reoccurrence  Event Info          # Event Title:: Test Event(Please Ignore), Time Zone, including GMT Difference:: Test Time Zone  What is your event Start Date?          # May 11 2017 10:10PM  When will your event end?          # Dec 10 2017  6:03PM  When would you like to close your online registration? (RSVP Date)          # Jun 11 2017 10:10PM  When do you need to launch your event (website and online registration)?          # 02 May 2017  Do you want to limit registration to a certain number of attendees?          # No  Is this event open to the public?          # No, an invite list will be provided and only those on the list can register to attend  Does your event require multiple languages?          # No  Are you interested in charging or collecting fees for any part of your event?(*Required).          # No  What type of Agenda items do you have?          # Tracks - specific bundles of registrations that are registered for all at once  How will invitees register?          # Event website (by posting a weblink)  Do you want to allow registrants to:          # Modify (change or update) their registration?: Yes<br />Cancel their registration?: Yes<br />Sign up for a waitlist when the event closes?: Yes<br />Sign up for a waitlist when the event reaches capacity?: Yes<br />Sign up for a waitlist when a session reaches capacity?: Yes<br />Register on someone\'s behalf (example: Admin registering on behalf of their Director who will be attending).: Yes  Please specify the last date people can make changes or updates (Modifications) to their registration.          # 10 Aug 2017  Please specify the last date a person can cancel his or her own registration. (Planners can cancel an attendee at any point regardless of this date.)          # 09 Sep 2017  Guests - Will attendees be able to register guests?  Guests will be tied to the primary contact’s registration. Guests are typically spouses, children or friends, who would not be attending without the primary registrant. If person A cancels, person B will be cancelled as well.          # No  Group Registration - Will attendees be able to register other attendees in a group?  This option allows your attendees to register more than one registrant at a time and pay one time. Registrants will not be tied to each other. If person A cancels, person B will still be registered.          # No  Would you like us to implement a mobile website of the event? Note: Mobile website is a simpler version with minimalist graphics and content architecture. Not all functionality and complex aesthetics elements are achievable in the mobile website. Click here to learn more.          # No, I prefer consistency and want to use the non-responsive desktop version  Select the Website Pages you would like to display to your invitees in addition to the Summary (landing) Page:          # Fees Page  The Event Landing/Summary Page has the ability to display widgets and areas that reflect important information about your event. Select the information/links you would like to display.          # Add to Calendar  Social Media Follow Bar:          # No  Select your Website Design preferences          # I will not be using Cvent website design service for my Event Website  Please indicate your Website and Registration Look and Feel preferences below:  NOTE: using an Event Theme is limited to 3 total hours of customization. Any additional customization is charged at $150/hour.          # Use our Premium Design service to design your custom website from scratch. This is a paid services for $150/hour  (This option may extend the Build by 10 business days)  Is there a website or event that would like to use as inspiration? Please provide your requirements below          # asfdasdadasd  Do you have brand standards or guidelines that need to be followed in the design of your event?          # No, I don\'t have branding instructions.  Would you like your event to appear in search engine results like Google and Bing? Once this functionality is turned on it can’t be turned off.          # No  PRIMARY From Name & Email Address for Emails (Invitation, Reminders, etc):  From Name & Email Address will appear in emails going out to invitees. Choose something your invitees will recognize (e.g. event name/title or CEO\'s name).          # Name:: Sandeep Kumar, Email Address:: sandeepk@cvent.com  Which registrant emails will you be using?          # Invitation Reminder  – Use to follow up with undecided registrants  Please select the email alerts you wish to receive:          # Registration accepted  Are you using a CrowdCompass mobile app for this event?          # No  Are you using another mobile app provider for this event?          # No  Do you need to keep track of attendance at your event?          # No  Will you be printing Name Badges?          # No  What, if anything did not go well with your last event website and registration? What are you hoping to improve?          # sadfafafasf  Do you have additional event information that was not collected, is not available yet or you did not provide in the proceeding form?          # No  I understand that filling out this form guarantees that the Cvent EventBuild team will make its best efforts to match your requested functionality and design needs but it\'s possible that certain requests may not be feasible within the Cvent platform due to functionality or design limitations.          # I understand the above statement ';
                EbProj.Project_Stage__c = 'First Draft Completed';
                eBProjList.add(EbProj);                
            }
            update eBProjList;                                    
            Test.stopTest();     
        }   
    }
    
    /*
    // Updates exisitng EB Projects in Salesforce.
    // Testing Without ARA Accounts and Sevice Tier "Silver"
    static testMethod void testAutoAssignmentWithSilver(){
        System.runAs(depUser){
            acc = new Account();
            acc.RecordTypeId = RecordtypeUtil.getRecordTypeIDByDevName('Account', 'Biz_Ac');
            acc.Name = 'EB Account 1';
            acc.Service_Tier__c = 'Silver';
            insert acc;
            
            Test.startTest();           
            // Call SetupData Method
            setupData(); 
            List<EB_SB_Builder__c> eBProjList = new List<EB_SB_Builder__c>();
            for(EB_SB_Builder__c  EbProj : [Select Id,Project_Received_Date__c,Project_Stage__c,EB_Agent_Profile__c,Project_Complexity__c From EB_SB_Builder__c Where AccountCustom__c =:acc.Id]){
                system.debug('EbProj.Silver'+EbProj.Project_Received_Date__c);
                EbProj.Project_Received_Date__c = Date.today(); 
                EbProj.Survey_Feedback__c = 'Ref Id          # a0B0S000000KCIHUA4  Cvent Account Number (If you don\'t have an Account Number, please provide your full organization name)          # CVENTEB002  Day of the week preference for a Kick Off Call          # Tuesday  Time of day preference for a Kick Off Call          # Early Afternoon (11am-1pm)  Or let us know a date and time preference for the 60 minute Project Kick Off Call          # May  2 2017  4:48AM  Select your Time Zone          # CST Central Standard Time GMT-6:00  Is this your first time using our EventBuild service?          # Yes  Type of Event?          # Conference – 3,000 attendees or more  Who is the audience?          # Customers  Where does your event take place?          # Offsite at a venue like a hotel or a conference center  What is the purpose of your event?          # Lead generation, Fundraising  Is this event part of a series?          # Monthly, One time, no reoccurrence  Event Info          # Event Title:: Test Event(Please Ignore), Time Zone, including GMT Difference:: Test Time Zone  What is your event Start Date?          # May 11 2017 10:10PM  When will your event end?          # Dec 10 2017  6:03PM  When would you like to close your online registration? (RSVP Date)          # Jun 11 2017 10:10PM  When do you need to launch your event (website and online registration)?          # 02 May 2017  Do you want to limit registration to a certain number of attendees?          # No  Is this event open to the public?          # No, an invite list will be provided and only those on the list can register to attend  Does your event require multiple languages?          # No  Are you interested in charging or collecting fees for any part of your event?(*Required).          # No  What type of Agenda items do you have?          # Tracks - specific bundles of registrations that are registered for all at once  How will invitees register?          # Event website (by posting a weblink)  Do you want to allow registrants to:          # Modify (change or update) their registration?: Yes<br />Cancel their registration?: Yes<br />Sign up for a waitlist when the event closes?: Yes<br />Sign up for a waitlist when the event reaches capacity?: Yes<br />Sign up for a waitlist when a session reaches capacity?: Yes<br />Register on someone\'s behalf (example: Admin registering on behalf of their Director who will be attending).: Yes  Please specify the last date people can make changes or updates (Modifications) to their registration.          # 10 Aug 2017  Please specify the last date a person can cancel his or her own registration. (Planners can cancel an attendee at any point regardless of this date.)          # 09 Sep 2017  Guests - Will attendees be able to register guests?  Guests will be tied to the primary contact’s registration. Guests are typically spouses, children or friends, who would not be attending without the primary registrant. If person A cancels, person B will be cancelled as well.          # No  Group Registration - Will attendees be able to register other attendees in a group?  This option allows your attendees to register more than one registrant at a time and pay one time. Registrants will not be tied to each other. If person A cancels, person B will still be registered.          # No  Would you like us to implement a mobile website of the event? Note: Mobile website is a simpler version with minimalist graphics and content architecture. Not all functionality and complex aesthetics elements are achievable in the mobile website. Click here to learn more.          # No, I prefer consistency and want to use the non-responsive desktop version  Select the Website Pages you would like to display to your invitees in addition to the Summary (landing) Page:          # Fees Page  The Event Landing/Summary Page has the ability to display widgets and areas that reflect important information about your event. Select the information/links you would like to display.          # Add to Calendar  Social Media Follow Bar:          # No  Select your Website Design preferences          # I will not be using Cvent website design service for my Event Website  Please indicate your Website and Registration Look and Feel preferences below:  NOTE: using an Event Theme is limited to 3 total hours of customization. Any additional customization is charged at $150/hour.          # Use our Premium Design service to design your custom website from scratch. This is a paid services for $150/hour  (This option may extend the Build by 10 business days)  Is there a website or event that would like to use as inspiration? Please provide your requirements below          # asfdasdadasd  Do you have brand standards or guidelines that need to be followed in the design of your event?          # No, I don\'t have branding instructions.  Would you like your event to appear in search engine results like Google and Bing? Once this functionality is turned on it can’t be turned off.          # No  PRIMARY From Name & Email Address for Emails (Invitation, Reminders, etc):  From Name & Email Address will appear in emails going out to invitees. Choose something your invitees will recognize (e.g. event name/title or CEO\'s name).          # Name:: Sandeep Kumar, Email Address:: sandeepk@cvent.com  Which registrant emails will you be using?          # Invitation Reminder  – Use to follow up with undecided registrants  Please select the email alerts you wish to receive:          # Registration accepted  Are you using a CrowdCompass mobile app for this event?          # No  Are you using another mobile app provider for this event?          # No  Do you need to keep track of attendance at your event?          # No  Will you be printing Name Badges?          # No  What, if anything did not go well with your last event website and registration? What are you hoping to improve?          # sadfafafasf  Do you have additional event information that was not collected, is not available yet or you did not provide in the proceeding form?          # No  I understand that filling out this form guarantees that the Cvent EventBuild team will make its best efforts to match your requested functionality and design needs but it\'s possible that certain requests may not be feasible within the Cvent platform due to functionality or design limitations.          # I understand the above statement ';
                EbProj.Project_Stage__c = 'First Draft Completed';
                eBProjList.add(EbProj);                
            }
            update eBProjList;
            Test.startTest();
        }
    }
    
    // Updates exisitng EB Projects in Salesforce.
    // Testing Without ARA Accounts and Sevice Tier "Gold"
    static testMethod void testAutoAssignmentWithGold(){
        System.runAs(depUser){
            acc = new Account();
            acc.RecordTypeId = RecordtypeUtil.getRecordTypeIDByDevName('Account', 'Biz_Ac');
            acc.Name = 'EB Account 1';
            acc.Service_Tier__c = 'Gold';
            insert acc;
            
            Test.startTest();
            // Call SetupData Method
            setupData();
            List<EB_SB_Builder__c> eBProjList = new List<EB_SB_Builder__c>();
            for(EB_SB_Builder__c  EbProj : [Select Id,Project_Received_Date__c,Project_Stage__c,EB_Agent_Profile__c,Project_Complexity__c From EB_SB_Builder__c Where AccountCustom__c =:acc.Id]){
                system.debug('EbProj.Gold'+EbProj.Project_Received_Date__c);
                EbProj.Project_Received_Date__c = Date.today(); 
                EbProj.Survey_Feedback__c = 'Ref Id          # a0B0S000000KCIHUA4  Cvent Account Number (If you don\'t have an Account Number, please provide your full organization name)          # CVENTEB002  Day of the week preference for a Kick Off Call          # Tuesday  Time of day preference for a Kick Off Call          # Early Afternoon (11am-1pm)  Or let us know a date and time preference for the 60 minute Project Kick Off Call          # May  2 2017  4:48AM  Select your Time Zone          # CST Central Standard Time GMT-6:00  Is this your first time using our EventBuild service?          # Yes  Type of Event?          # Conference – 3,000 attendees or more  Who is the audience?          # Customers  Where does your event take place?          # Offsite at a venue like a hotel or a conference center  What is the purpose of your event?          # Lead generation, Fundraising  Is this event part of a series?          # Monthly, One time, no reoccurrence  Event Info          # Event Title:: Test Event(Please Ignore), Time Zone, including GMT Difference:: Test Time Zone  What is your event Start Date?          # May 11 2017 10:10PM  When will your event end?          # Dec 10 2017  6:03PM  When would you like to close your online registration? (RSVP Date)          # Jun 11 2017 10:10PM  When do you need to launch your event (website and online registration)?          # 02 May 2017  Do you want to limit registration to a certain number of attendees?          # No  Is this event open to the public?          # No, an invite list will be provided and only those on the list can register to attend  Does your event require multiple languages?          # No  Are you interested in charging or collecting fees for any part of your event?(*Required).          # No  What type of Agenda items do you have?          # Tracks - specific bundles of registrations that are registered for all at once  How will invitees register?          # Event website (by posting a weblink)  Do you want to allow registrants to:          # Modify (change or update) their registration?: Yes<br />Cancel their registration?: Yes<br />Sign up for a waitlist when the event closes?: Yes<br />Sign up for a waitlist when the event reaches capacity?: Yes<br />Sign up for a waitlist when a session reaches capacity?: Yes<br />Register on someone\'s behalf (example: Admin registering on behalf of their Director who will be attending).: Yes  Please specify the last date people can make changes or updates (Modifications) to their registration.          # 10 Aug 2017  Please specify the last date a person can cancel his or her own registration. (Planners can cancel an attendee at any point regardless of this date.)          # 09 Sep 2017  Guests - Will attendees be able to register guests?  Guests will be tied to the primary contact’s registration. Guests are typically spouses, children or friends, who would not be attending without the primary registrant. If person A cancels, person B will be cancelled as well.          # No  Group Registration - Will attendees be able to register other attendees in a group?  This option allows your attendees to register more than one registrant at a time and pay one time. Registrants will not be tied to each other. If person A cancels, person B will still be registered.          # No  Would you like us to implement a mobile website of the event? Note: Mobile website is a simpler version with minimalist graphics and content architecture. Not all functionality and complex aesthetics elements are achievable in the mobile website. Click here to learn more.          # No, I prefer consistency and want to use the non-responsive desktop version  Select the Website Pages you would like to display to your invitees in addition to the Summary (landing) Page:          # Fees Page  The Event Landing/Summary Page has the ability to display widgets and areas that reflect important information about your event. Select the information/links you would like to display.          # Add to Calendar  Social Media Follow Bar:          # No  Select your Website Design preferences          # I will not be using Cvent website design service for my Event Website  Please indicate your Website and Registration Look and Feel preferences below:  NOTE: using an Event Theme is limited to 3 total hours of customization. Any additional customization is charged at $150/hour.          # Use our Premium Design service to design your custom website from scratch. This is a paid services for $150/hour  (This option may extend the Build by 10 business days)  Is there a website or event that would like to use as inspiration? Please provide your requirements below          # asfdasdadasd  Do you have brand standards or guidelines that need to be followed in the design of your event?          # No, I don\'t have branding instructions.  Would you like your event to appear in search engine results like Google and Bing? Once this functionality is turned on it can’t be turned off.          # No  PRIMARY From Name & Email Address for Emails (Invitation, Reminders, etc):  From Name & Email Address will appear in emails going out to invitees. Choose something your invitees will recognize (e.g. event name/title or CEO\'s name).          # Name:: Sandeep Kumar, Email Address:: sandeepk@cvent.com  Which registrant emails will you be using?          # Invitation Reminder  – Use to follow up with undecided registrants  Please select the email alerts you wish to receive:          # Registration accepted  Are you using a CrowdCompass mobile app for this event?          # No  Are you using another mobile app provider for this event?          # No  Do you need to keep track of attendance at your event?          # No  Will you be printing Name Badges?          # No  What, if anything did not go well with your last event website and registration? What are you hoping to improve?          # sadfafafasf  Do you have additional event information that was not collected, is not available yet or you did not provide in the proceeding form?          # No  I understand that filling out this form guarantees that the Cvent EventBuild team will make its best efforts to match your requested functionality and design needs but it\'s possible that certain requests may not be feasible within the Cvent platform due to functionality or design limitations.          # I understand the above statement ';
                EbProj.Project_Stage__c = 'First Draft Completed';
                eBProjList.add(EbProj);                
            }
            update eBProjList;
            Test.startTest();
        }
    }
    
    // Updates exisitng EB Projects in Salesforce.
    // Testing Without ARA Accounts and Sevice Tier "Platinum"
    static testMethod void testAutoAssignmentWithPlatinum(){
        System.runAs(depUser){
            acc = new Account();
            acc.RecordTypeId = RecordtypeUtil.getRecordTypeIDByDevName('Account', 'Biz_Ac');
            acc.Name = 'EB Account 1';
            acc.Service_Tier__c = 'Platinum';
            insert acc;

            Test.startTest();
            // Call SetupData Method
            setupData();
            
            List<EB_SB_Builder__c> eBProjList = new List<EB_SB_Builder__c>();
            for(EB_SB_Builder__c  EbProj : [Select Id,Project_Received_Date__c,Project_Stage__c,EB_Agent_Profile__c,Project_Complexity__c From EB_SB_Builder__c Where AccountCustom__c =:acc.Id]){
                system.debug('EbProj.Platinum'+EbProj.Project_Received_Date__c);
                EbProj.Project_Received_Date__c = Date.today(); 
                EbProj.Survey_Feedback__c = 'Ref Id          # a0B0S000000KCIHUA4  Cvent Account Number (If you don\'t have an Account Number, please provide your full organization name)          # CVENTEB002  Day of the week preference for a Kick Off Call          # Tuesday  Time of day preference for a Kick Off Call          # Early Afternoon (11am-1pm)  Or let us know a date and time preference for the 60 minute Project Kick Off Call          # May  2 2017  4:48AM  Select your Time Zone          # CST Central Standard Time GMT-6:00  Is this your first time using our EventBuild service?          # Yes  Type of Event?          # Conference – 3,000 attendees or more  Who is the audience?          # Customers  Where does your event take place?          # Offsite at a venue like a hotel or a conference center  What is the purpose of your event?          # Lead generation, Fundraising  Is this event part of a series?          # Monthly, One time, no reoccurrence  Event Info          # Event Title:: Test Event(Please Ignore), Time Zone, including GMT Difference:: Test Time Zone  What is your event Start Date?          # May 11 2017 10:10PM  When will your event end?          # Dec 10 2017  6:03PM  When would you like to close your online registration? (RSVP Date)          # Jun 11 2017 10:10PM  When do you need to launch your event (website and online registration)?          # 02 May 2017  Do you want to limit registration to a certain number of attendees?          # No  Is this event open to the public?          # No, an invite list will be provided and only those on the list can register to attend  Does your event require multiple languages?          # No  Are you interested in charging or collecting fees for any part of your event?(*Required).          # No  What type of Agenda items do you have?          # Tracks - specific bundles of registrations that are registered for all at once  How will invitees register?          # Event website (by posting a weblink)  Do you want to allow registrants to:          # Modify (change or update) their registration?: Yes<br />Cancel their registration?: Yes<br />Sign up for a waitlist when the event closes?: Yes<br />Sign up for a waitlist when the event reaches capacity?: Yes<br />Sign up for a waitlist when a session reaches capacity?: Yes<br />Register on someone\'s behalf (example: Admin registering on behalf of their Director who will be attending).: Yes  Please specify the last date people can make changes or updates (Modifications) to their registration.          # 10 Aug 2017  Please specify the last date a person can cancel his or her own registration. (Planners can cancel an attendee at any point regardless of this date.)          # 09 Sep 2017  Guests - Will attendees be able to register guests?  Guests will be tied to the primary contact’s registration. Guests are typically spouses, children or friends, who would not be attending without the primary registrant. If person A cancels, person B will be cancelled as well.          # No  Group Registration - Will attendees be able to register other attendees in a group?  This option allows your attendees to register more than one registrant at a time and pay one time. Registrants will not be tied to each other. If person A cancels, person B will still be registered.          # No  Would you like us to implement a mobile website of the event? Note: Mobile website is a simpler version with minimalist graphics and content architecture. Not all functionality and complex aesthetics elements are achievable in the mobile website. Click here to learn more.          # No, I prefer consistency and want to use the non-responsive desktop version  Select the Website Pages you would like to display to your invitees in addition to the Summary (landing) Page:          # Fees Page  The Event Landing/Summary Page has the ability to display widgets and areas that reflect important information about your event. Select the information/links you would like to display.          # Add to Calendar  Social Media Follow Bar:          # No  Select your Website Design preferences          # I will not be using Cvent website design service for my Event Website  Please indicate your Website and Registration Look and Feel preferences below:  NOTE: using an Event Theme is limited to 3 total hours of customization. Any additional customization is charged at $150/hour.          # Use our Premium Design service to design your custom website from scratch. This is a paid services for $150/hour  (This option may extend the Build by 10 business days)  Is there a website or event that would like to use as inspiration? Please provide your requirements below          # asfdasdadasd  Do you have brand standards or guidelines that need to be followed in the design of your event?          # No, I don\'t have branding instructions.  Would you like your event to appear in search engine results like Google and Bing? Once this functionality is turned on it can’t be turned off.          # No  PRIMARY From Name & Email Address for Emails (Invitation, Reminders, etc):  From Name & Email Address will appear in emails going out to invitees. Choose something your invitees will recognize (e.g. event name/title or CEO\'s name).          # Name:: Sandeep Kumar, Email Address:: sandeepk@cvent.com  Which registrant emails will you be using?          # Invitation Reminder  – Use to follow up with undecided registrants  Please select the email alerts you wish to receive:          # Registration accepted  Are you using a CrowdCompass mobile app for this event?          # No  Are you using another mobile app provider for this event?          # No  Do you need to keep track of attendance at your event?          # No  Will you be printing Name Badges?          # No  What, if anything did not go well with your last event website and registration? What are you hoping to improve?          # sadfafafasf  Do you have additional event information that was not collected, is not available yet or you did not provide in the proceeding form?          # No  I understand that filling out this form guarantees that the Cvent EventBuild team will make its best efforts to match your requested functionality and design needs but it\'s possible that certain requests may not be feasible within the Cvent platform due to functionality or design limitations.          # I understand the above statement ';
                EbProj.Project_Stage__c = 'First Draft Completed';
                eBProjList.add(EbProj);                
            }
            update eBProjList;
            Test.startTest();
        }
    }
    */
    // Updates exisitng EB Projects in Salesforce.
    // Testing Without ARA Accounts.
    static testMethod void updateExistingEBRecordsWithARAs(){
        System.runAs(depUser){
            // Create Account Record.
            acc = TestUtil.createAccount('EB Account 2', 'Biz_Ac');
            acc.Active_ARA__c = true;   
            insert acc;     
            
            // Create Active ARAs with the Account. 
            AraObj = new ARA__c();
            AraObj.Account__c = acc.Id;
            AraObj.Status__c = 'Open';
            insert AraObj;
            
            // Call SetupData Method
            setupData(); 
            Test.startTest();            
            List<EB_SB_Builder__c> eBProjList = new List<EB_SB_Builder__c>();
            for(EB_SB_Builder__c  EbProj : [Select Id,Project_Received_Date__c,Project_Status_del__c,Project_Stage__c,EB_Agent_Profile__c,Project_Complexity__c From EB_SB_Builder__c Where AccountCustom__c =:acc.Id LIMIT 50]){
                EbProj.Project_Received_Date__c = Date.today(); 
                EbProj.Survey_Feedback__c = 'Ref Id          # a0B0S000000KCIHUA4  Cvent Account Number (If you don\'t have an Account Number, please provide your full organization name)          # CVENTEB002  Day of the week preference for a Kick Off Call          # Tuesday  Time of day preference for a Kick Off Call          # Early Afternoon (11am-1pm)  Or let us know a date and time preference for the 60 minute Project Kick Off Call          # May  2 2017  4:48AM  Select your Time Zone          # CST Central Standard Time GMT-6:00  Is this your first time using our EventBuild service?          # Yes  Type of Event?          # Conference – 3,000 attendees or more  Who is the audience?          # Customers  Where does your event take place?          # Offsite at a venue like a hotel or a conference center  What is the purpose of your event?          # Lead generation, Fundraising  Is this event part of a series?          # Monthly, One time, no reoccurrence  Event Info          # Event Title:: Test Event(Please Ignore), Time Zone, including GMT Difference:: Test Time Zone  What is your event Start Date?          # May 11 2017 10:10PM  When will your event end?          # Dec 10 2017  6:03PM  When would you like to close your online registration? (RSVP Date)          # Jun 11 2017 10:10PM  When do you need to launch your event (website and online registration)?          # 02 May 2017  Do you want to limit registration to a certain number of attendees?          # No  Is this event open to the public?          # No, an invite list will be provided and only those on the list can register to attend  Does your event require multiple languages?          # No  Are you interested in charging or collecting fees for any part of your event?(*Required).          # No  What type of Agenda items do you have?          # Tracks - specific bundles of registrations that are registered for all at once  How will invitees register?          # Event website (by posting a weblink)  Do you want to allow registrants to:          # Modify (change or update) their registration?: Yes<br />Cancel their registration?: Yes<br />Sign up for a waitlist when the event closes?: Yes<br />Sign up for a waitlist when the event reaches capacity?: Yes<br />Sign up for a waitlist when a session reaches capacity?: Yes<br />Register on someone\'s behalf (example: Admin registering on behalf of their Director who will be attending).: Yes  Please specify the last date people can make changes or updates (Modifications) to their registration.          # 10 Aug 2017  Please specify the last date a person can cancel his or her own registration. (Planners can cancel an attendee at any point regardless of this date.)          # 09 Sep 2017  Guests - Will attendees be able to register guests?  Guests will be tied to the primary contact’s registration. Guests are typically spouses, children or friends, who would not be attending without the primary registrant. If person A cancels, person B will be cancelled as well.          # No  Group Registration - Will attendees be able to register other attendees in a group?  This option allows your attendees to register more than one registrant at a time and pay one time. Registrants will not be tied to each other. If person A cancels, person B will still be registered.          # No  Would you like us to implement a mobile website of the event? Note: Mobile website is a simpler version with minimalist graphics and content architecture. Not all functionality and complex aesthetics elements are achievable in the mobile website. Click here to learn more.          # No, I prefer consistency and want to use the non-responsive desktop version  Select the Website Pages you would like to display to your invitees in addition to the Summary (landing) Page:          # Fees Page  The Event Landing/Summary Page has the ability to display widgets and areas that reflect important information about your event. Select the information/links you would like to display.          # Add to Calendar  Social Media Follow Bar:          # No  Select your Website Design preferences          # I will not be using Cvent website design service for my Event Website  Please indicate your Website and Registration Look and Feel preferences below:  NOTE: using an Event Theme is limited to 3 total hours of customization. Any additional customization is charged at $150/hour.          # Use our Premium Design service to design your custom website from scratch. This is a paid services for $150/hour  (This option may extend the Build by 10 business days)  Is there a website or event that would like to use as inspiration? Please provide your requirements below          # asfdasdadasd  Do you have brand standards or guidelines that need to be followed in the design of your event?          # No, I don\'t have branding instructions.  Would you like your event to appear in search engine results like Google and Bing? Once this functionality is turned on it can’t be turned off.          # No  PRIMARY From Name & Email Address for Emails (Invitation, Reminders, etc):  From Name & Email Address will appear in emails going out to invitees. Choose something your invitees will recognize (e.g. event name/title or CEO\'s name).          # Name:: Sandeep Kumar, Email Address:: sandeepk@cvent.com  Which registrant emails will you be using?          # Invitation Reminder  – Use to follow up with undecided registrants  Please select the email alerts you wish to receive:          # Registration accepted  Are you using a CrowdCompass mobile app for this event?          # No  Are you using another mobile app provider for this event?          # No  Do you need to keep track of attendance at your event?          # No  Will you be printing Name Badges?          # No  What, if anything did not go well with your last event website and registration? What are you hoping to improve?          # sadfafafasf  Do you have additional event information that was not collected, is not available yet or you did not provide in the proceeding form?          # No  I understand that filling out this form guarantees that the Cvent EventBuild team will make its best efforts to match your requested functionality and design needs but it\'s possible that certain requests may not be feasible within the Cvent platform due to functionality or design limitations.          # I understand the above statement ';
                EbProj.Project_Stage__c = 'First Draft Completed';
                EbProj.Project_Status_del__c = 'Completed';
                eBProjList.add(EbProj);                
            }
            update eBProjList;
            Test.stopTest();     
        }   
    }    
}