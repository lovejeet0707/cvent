/**
* Author : Sandeep Kumar
* Date : 17 April, 2017
* Description : It tests below mentioned classes
* 1) EBProjectCustomRelatedList_ContExt
*/
@isTest (seeAllData=false)
public class EBProjectCustomRelatedList_ContExt_Test {
    private static Opportunity o2;
    private static Account acc; 
    private static Contact con;
    private static EB_SB_Builder__c EBSBRec;
    private static EB_Agent_Profile__c EBAgentProfile1;
    private static Professional_Services_Project__c PSPRec;
    private static List<User> userList;
    private static List<EB_Agent_Profile__c> eBAgentProfileList;    
    private static User depUser = [Select Id, ProfileId from User where Name = 'CRM Deployment User']; 
    private static Id userProfieId = UserProfileUtil.getProfileIDByName('Customer Care Rep - Product Consultant EB Team'); 
    
    public static void setupData(){        
        // Create Account Record.
        acc = TestUtil.createAccount('EB Account 1', 'Biz_Ac');
        acc.BillingCountryCode='US';
        acc.BillingState='TX';
        insert acc;     
        
        // Create Contact Record.
        con = TestUtil.createContact(acc.id);
        insert con;   
        
        // Create PSP Record.
        PSPRec = new Professional_Services_Project__c();
        PSPRec.Account__c = acc.Id;
        PSPRec.of_EB__c = 5;
        insert PSPRec;  
        
        o2 = TestUtil.createOpportunity('testOpp','Event','Bid Phase');
        o2.Contact_Associated__c = con.Id;
        o2.AccountId = acc.Id;
        o2.CloseDate = Date.today().addDays(80);
        insert o2;
        
        // Create Salesforce User for which will be assigned to EB Agent Profile later.
        User usr1 = TestUtil.createUser(userProfieId);            
        insert usr1;  
        
        // Create EB Agent Profile Records.
        EBAgentProfile1 = TestUtil.createEBAgentProfile('Profile 1',usr1.Id,'Event Quarterback Project');        
        insert EBAgentProfile1; 
        
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
        EBSBRec.EB_Agent_Profile__c = EBAgentProfile1.Id;
        insert EBSBRec; 
        
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
        EBSBRec.EB_Agent_Profile__c = EBAgentProfile1.Id;
        insert EBSBRec;
        
      }
    
    // Method is used to test the CustomRelatedList Page.
    static testmethod void CustomRelatedList(){
         
        acc = TestUtil.createAccount('EB Account 1', 'Biz_Ac');
        acc.BillingCountryCode='US';
        acc.BillingState='TX';
        insert acc;     
        
        // Create Contact Record.
        con = TestUtil.createContact(acc.id);
        con.Email ='puser000@amamama.com';
        insert con;   
        
        User usr1 = TestUtil.createUser(userProfieId);      
        usr1.Email = 'puser000@amamama.com';      
        insert usr1;
         
       /*  UserRole r = new UserRole(DeveloperName = 'Administrator', Name = 'Administrator');
         insert r;

         User u = new User(
         ProfileId = [SELECT Id FROM Profile WHERE Name = 'Customer Community User'].Id,
         LastName = 'last',
         Email = 'puser000@amamama.com',
         Username = 'puser000@amamama.com' + System.currentTimeMillis(),
         CompanyName = 'TEST',
         Title = 'title',
         Alias = 'alias',
         TimeZoneSidKey = 'America/Los_Angeles',
         EmailEncodingKey = 'UTF-8',
         LanguageLocaleKey = 'en_US',
         LocaleSidKey = 'en_US',
         UserRoleId = r.Id,ContactId = con.id
         );*/
         
       
         
        System.runAs(depUser){
        Test.startTest();
        setupData();
        apexpages.currentpage().getparameters().put('id', EBAgentProfile1.Id);  
        ApexPages.StandardController sc = new ApexPages.standardController(EBAgentProfile1);
        EBProjectCustomRelatedList_ContExt controller = new EBProjectCustomRelatedList_ContExt(sc);          
        Test.stopTest();
        }
    }    
    
    // Method is used to test the EBProjectCapacityDashboard Page.
    static testmethod void EBProjectCapacityDashboard(){
        System.runAs(depUser){
        Test.startTest();
        setupData();            
        ApexPages.StandardController sc = new ApexPages.standardController(EBSBRec);
        EBProjectCustomRelatedList_ContExt controller = new EBProjectCustomRelatedList_ContExt(sc); 
        Test.stopTest();
        }
    }    
}