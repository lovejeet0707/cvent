@isTest
public class CCMobileAppAssignmentRollup_TrigAct_Test{
     static testMethod void createMobileAppRecord(){
        // Create Account Record.
        Account acc = TestUtil.createAccount('Test Account', 'Biz_Ac');
        acc.BillingCountryCode = 'IN';
        insert acc;    
        
        Id userProfieId = UserProfileUtil.getProfileIDByName('Customer Care Rep - Product Consultant EB Team');    
        List<User> userList = new List<User>();
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
        
        insert userList;
        
        // Create EB Agent Profile Records. 
        List<EB_Agent_Profile__c> eBAgentProfileList = new List<EB_Agent_Profile__c>();

        EB_Agent_Profile__c EBAgentProfile1 = TestUtil.createEBAgentProfile('Profile 1',userList[0].Id,'Low - 1');
        eBAgentProfileList.add(EBAgentProfile1);
        
        EB_Agent_Profile__c EBAgentProfile2 = TestUtil.createEBAgentProfile('Profile 2',userList[1].Id,'Med - 2');
        eBAgentProfileList.add(EBAgentProfile2);
        insert eBAgentProfileList;
        // Create Onboarding Record
        Mobile_Card__c mobileAppObj = new Mobile_Card__c();
        mobileAppObj.RecordTypeId = Schema.SObjectType.Mobile_Card__c.getRecordTypeInfosByDeveloperName().get(Label.Mobile_App_RT_Label_Name).getRecordTypeId();
        mobileAppObj.Contract_Account_New__c = acc.Id;    
        mobileAppObj.Request_Type__c = 'App Build Plus';
        //mobileAppObj.Agent_Profile__c = eBAgentProfileList[0].Id;
        //mobileAppObj.App_Builder__c = userList[0].Id;
        insert mobileAppObj;
        
        mobileAppObj.Agent_Profile__c = eBAgentProfileList[1].Id;
        mobileAppObj.App_Builder__c = userList[1].Id;
        update mobileAppObj;
     }
}