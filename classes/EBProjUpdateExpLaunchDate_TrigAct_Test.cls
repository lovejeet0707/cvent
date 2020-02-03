/**
* Author : Sandeep Kumar
* Date : 23 May 2017
* Description : It tests below mentioned class
* 1) EBProjUpdateExpLaunchDateFrmPP_TrigAct
*/
@isTest(seeAllData=false)
public class EBProjUpdateExpLaunchDate_TrigAct_Test {
    private static Opportunity opp;
    private static Account acc; 
    private static Contact con;
    private static Project_Plan_Milestone__c projPlanMilestone;
    private static Professional_Services_Project__c PSP;
    private static EB_SB_Builder__c EBSBRec;
    private static Project_Plan_SOW_EB__c projPlanObj;
    private static Id userProfieId = UserProfileUtil.getProfileIDByName('Customer Care Rep - Product Consultant EB Team');     
    private static User depUser = [Select Id, ProfileId from User where Name = 'CRM Deployment User'];   
    
    // Test for the manualShareRead method
    static testMethod void testExpectedLaunchDateUpdate(){
        system.runAs(depUser){
            Test.startTest();        
            User usr = TestUtil.createUser(userProfieId);          
            insert usr;  
            // Create Account Record.
            acc = TestUtil.createAccount('EB Account 1', 'Biz_Ac');
            insert acc;     
            
            // Create Contact Record.
            con = TestUtil.createContact(acc.id);
            insert con;   
            
            // Create PSP Record.
            Professional_Services_Project__c PSPRec = new Professional_Services_Project__c();
            PSPRec.Account__c = acc.Id;
            PSPRec.of_EB__c = 0;
            insert PSPRec;  
            
            Opportunity o2 = TestUtil.createOpportunity('testOpp','Event','Bid Phase');
            o2.Contact_Associated__c = con.Id;
            o2.AccountId = acc.Id;
            o2.CloseDate = Date.today().addDays(80);
            insert o2;
            
            projPlanMilestone = new Project_Plan_Milestone__c();
            projPlanMilestone.Name = 'Regular Simple';
            projPlanMilestone.Addnl_Info_Received_Expected_Date__c = 0;
            projPlanMilestone.Event_Launch_Expected_Date__c = 17;
            projPlanMilestone.Event_Setup_Call_Expected_Date__c = 0;
            projPlanMilestone.Event_Testing_Expected_Date__c = 16;
            projPlanMilestone.FD_Completed_Expected_Date__c = 3;
            projPlanMilestone.X1st_ROC_Completed_Expected_Date__c = 7;
            projPlanMilestone.X1st_ROC_Received_Expected_Date__c = 5;
            projPlanMilestone.X2nd_ROC_Completed_Expected_Date__c = 11;
            projPlanMilestone.X2nd_ROC_Received_Expected_Date__c = 9;
            projPlanMilestone.X3rd_ROC_Completed_Expected_Date__c = 15;
            projPlanMilestone.X3rd_ROC_Received_Expected_Date__c = 13;
            insert projPlanMilestone;
            
            // Create Eb Project.
            EBSBRec = new EB_SB_Builder__c();
            EBSBRec.PSP_ID__c = PSPRec.Id;
            EBSBRec.Contact__c = con.Id;
            EBSBRec.Opportunity__c = o2.Id;
            EBSBRec.AccountCustom__c = acc.Id;                 
            EBSBRec.Project__c = 'Event Builder';
            EBSBRec.Project_Status_del__c = 'In Progress';            
            EBSBRec.Project_Stage__c = 'Information Received';
            EBSBRec.Project_Complexity__c = '3-Advanced';
            EBSBRec.Project_Type_del__c = 'Event Builder - Regular';            
            EBSBRec.Event_Title__c = '';
            insert EBSBRec;
            
            projPlanObj = new Project_Plan_SOW_EB__c();
            projPlanObj.EBSB_Builders_Name__c = EBSBRec.Id;
            projPlanObj.Expected_Launch_Date__c = Date.today();
            projPlanObj.Project_Received_Date__c = Date.today();
            projPlanObj.Information_Received__c = Date.today();
            projPlanobj.Request_Type__c = 'Regular';
            projPlanobj.Project_Complexity__c = '1-Simple';
            projPlanobj.Project_Plan_Status__c = 'Generate Project plan';
            insert projPlanObj;
            
            // Assertion when Project Plan is created.
            EB_SB_Builder__c eBProject = [Select Id,Expected_Launch_Date__c from EB_SB_Builder__c where Id=:EBSBRec.Id];
            System.assertEquals(Date.today(), eBProject.Expected_Launch_Date__c);
            
            // Update Expected Launch Date on Project Plan Object.
            projPlanObj.Expected_Launch_Date__c = Date.today().addDays(30);
            update projPlanObj;
            
            // Assertion when Project Plan is updated with new Expected launch Date.
            eBProject = [Select Id,Expected_Launch_Date__c from EB_SB_Builder__c where Id=:EBSBRec.Id];
            System.assertEquals(Date.today().addDays(30), eBProject.Expected_Launch_Date__c);  
            
            // Update Expected Launch Date on Project Plan Object.
            projPlanObj.Event_Launch_Revised_Timeline__c = Date.today().addDays(50);
            update projPlanObj;
            
            // Assertion when Project Plan is updated with new Expected launch Date.
            eBProject = [Select Id,Expected_Launch_Date__c from EB_SB_Builder__c where Id=:EBSBRec.Id];
            System.assertEquals(Date.today().addDays(50), eBProject.Expected_Launch_Date__c);                      
            Test.stopTest();
        }        
    }    
}