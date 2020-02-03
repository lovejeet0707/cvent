/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 
 *******************************************************************************************
 Modified by : Kumud|9march2018
 Desc: Increase test coverage of BatchUpdateAccountTeamMembersOnAccount and BatchUpdateAccountTeamMembers_Scheduler class.

 */
@isTest
private class BatchUpdateAccountTeamOnAccountTest {
    
    /*
    Author : Kumud|kumud.thakur1990@gmail.com
    Desc: Create data set during the load of class. 
    Created Date :9 march 2018
    
    */
    @testSetup
    public static void createData(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User testUser=TestUtil.createUser(p.Id);
        
        insert testUser;
        
      // custom setting for opportunity insert
        UserAssignment__c instUA = new UserAssignment__c();
        instUA.Name = 'OnArrival';
        instUA.User_id__c = userinfo.getUserID();
        instUA.UserName__c = 'Brett Wischow';
        insert instUA;
        Account instAccount=TestUtil.createAccount('TestAccount','Biz_Ac');
        instAccount.Account_Status__c='Active';
        instAccount.BillingCountryCode = 'US';
        instAccount.BillingStateCode = 'NY';
        insert instAccount;
        
        
        AccountTeamMember actm= TestUtil.createATM(instAccount.id,testUser.id);
        actm.TeamMemberRole = 'AM - Event';
        AccountTeamMember actm1 =TestUtil.createATM(instAccount.id,testUser.id);
        actm1.TeamMemberRole = 'CS - Event';
        
        List<AccountTeamMember> actMembers = new List<AccountTeamMember>();
        actMembers.add(actm);
        actMembers.add(actm1);
        insert actMembers;
        
        AccountAndTeamMembersSetting__c setting = new AccountAndTeamMembersSetting__c(Name = 'AM - Event',FieldAPIName__c = 'AM_Event__c');
        AccountAndTeamMembersSetting__c setting1 = new AccountAndTeamMembersSetting__c(Name = 'CS - Event',FieldAPIName__c = 'CS_Rep__c');
        List<AccountAndTeamMembersSetting__c> actSetting = new List<AccountAndTeamMembersSetting__c>();
        actSetting.add(setting);
        actSetting.add(setting1);
        
        insert actSetting;
        
        
        
        
        
    }
    /*
      Test scenarion without an opportunity
    */
    static testMethod void myUnitTest(){
        
        Test.startTest();
         BatchUpdateAccountTeamMembers_Scheduler  sh1 = new BatchUpdateAccountTeamMembers_Scheduler ();

         String sch = '0 0 23 * * ?'; system.schedule('Test Territory Check', sch, sh1); 
        Test.stopTest();
    }
    
    /*
      Test scenarion with an opportunity and account team member having multi-Product team role.
    */
    static testMethod void myUnitTest1() {
        Test.startTest();
        ID AccountID=[select id from account limit 1].id;
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User testUser=TestUtil.createUser(p.Id);
        insert testUser;
        ID userId=testUser.id;
        AccountTeamMember actm2= TestUtil.createATM(AccountID,userId);
        actm2.TeamMemberRole = 'Multi-Product';
        insert actm2;
        opportunity instOpp=TestUtil.createOpportunity('Test opp','CS_Lead','Qualified');
        instOpp.AccountId=AccountID;
        instOpp.ownerID=userId;
        instOpp.Product__c='Event';
        insert instOpp;
        BatchUpdateAccountTeamMembers_Scheduler  sh1 = new BatchUpdateAccountTeamMembers_Scheduler ();

        String sch = '0 0 23 * * ?'; system.schedule('Test Territory Check', sch, sh1); 
        Test.stopTest();
    }
    
    
    
    
}