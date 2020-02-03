/**
*    
*   Author: Shanu Aggarwal
*   Date Added : 23-05-2017
*   This class tests the functionality of IntegrationAccount
* 
*/
@istest
public class IntegrationAccountTest {
    
    
    private static void createCustomsetting(){


        // custom setting for opportunity insert
        UserAssignment__c instUA = new UserAssignment__c();
        instUA.Name = 'OnArrival';
        instUA.User_id__c = userinfo.getUserID();
        instUA.UserName__c = 'Brett Wischow';
        insert instUA;

    }
    @testsetup
    public static void CreateTestData(){

        Test.startTest();
        //Inserting User...............
        Profile p = [SELECT Id FROM Profile WHERE Name='Finance - Management']; 
        USerrole[] testroleId=[select id from userRole where name ='AM (Event)' OR name ='Pre Sales - Special Projects' limit 2];

        User instUser=TestUtil.createUser(p.id,'Test_709deploymentuser@cvent.com');
        instUser.userRoleId=testroleId[0].id;
        instUser.firstname='John';



        system.runAs(instUser){
            
            createCustomsetting();
            
            Account instAccount=TestUtil.createAccount('TestAccount','Biz_Ac');       
            insert instAccount;
            

            Contact con=TestUtil.createContact(instAccount.id);
            insert con;
            List<Address__c> listOfAddress=new List<Address__c>();
            listOfAddress.add(TestUtil.createAccountAddress(instAccount.id,'Billing'));
            listOfAddress.add(TestUtil.createAccountAddress(instAccount.id,'Shipping'));
            insert listOfAddress;

            opportunity instOpp=TestUtil.createOpportunity('Test opp','CS_Lead','Opp Identified');
            instOpp.AccountId= instAccount.Id;
            instOpp.Contact_Associated__c = con.Id;
            instOpp.Bill_To_Address__c = listOfAddress[0].Id;
            instOpp.Ship_To_Address__c = listOfAddress[1].Id;
            insert instOpp;
            
            EBS_Order_Sync_Framework__c frameWork = new EBS_Order_Sync_Framework__c();
            framework.Opportunity__c  = instOpp.Id;
            insert frameWork;

            EBS_Integration__c eIntegration=TestUtil.createEbsIntegration('Account Integration','Account');

            insert eIntegration;

        }

        Test.stopTest();

    }
   
   //This method test Handle New Accounts, Resync Accounts
   
   public static testmethod void testResyncAccount(){
       createCustomsetting();
       Account acc = [Select Id,Name,LastModifiedById,EBS_Account_ID__c from Account Limit 1 ];
       acc.EBS_Account_ID__c = '16465478';
       acc.EBS_Update__c=true;
       update acc;
       
       System.assert(acc.EBS_Account_ID__c!=null);
       
       Account acc2 = new Account();
       acc2.Name = 'Biz Test Acc 1';
       acc.EBS_Account_ID__c = '654654654';  
       acc.EBS_Update__c=true;         
       insert acc2;
       
       //Run trigger again to resyncAccount for EBS Order
       EBS_Order_Sync_Framework__c frameWork = [Select Id From EBS_Order_Sync_Framework__c Limit 1 ];
       update frameWork;
       
       //Handle New Account 
       IntegrationAccount.handleNewAccounts(new Map<Id,Account>{acc.Id=>acc});
       IntegrationAccount.handleUpdatedAccounts(new List<Account>{acc},new Map<Id,Account>{acc2.Id=>acc2});
       IntegrationAccount.resyncAccount(acc.Id);
       //Resync Account for EBS Order
       
       
   }
   public static testmethod void testResyncAccount_1(){
       createCustomsetting();
       Account acc = [Select Id,Name,LastModifiedById,EBS_Account_ID__c from Account Limit 1 ];
       acc.EBS_Account_ID__c = '16465478';
       acc.EBS_Update__c=true;
       update acc;
       
       System.assert(acc.EBS_Account_ID__c!=null);
       
       Account acc2 = new Account();
       acc2.Name = 'Biz Test Acc 2';
       acc.EBS_Account_ID__c = '654654654';  
       acc.EBS_Update__c=true;         
       insert acc2;
       
       //Run trigger again to resyncAccount for EBS Order
       EBS_Order_Sync_Framework__c frameWork = [Select Id From EBS_Order_Sync_Framework__c Limit 1 ];
       update frameWork;
       
       //Handle New Account 
       //IntegrationAccount.handleNewAccounts(new Map<Id,Account>{acc.Id=>acc});
       IntegrationAccount.handleUpdatedAccounts(new List<Account>{acc},new Map<Id,Account>{acc.Id=>acc2});
       IntegrationAccount.handleDependentUpdates(new List<Account>{acc},new Map<Id,Account>{acc.Id=>acc2});
       IntegrationAccount.handleAddressUpdates(new List<Account>{acc},new Map<Id,Account>{acc.Id=>acc2});
       
   }   
   //Test BypassTriggerUtilityTest class 
   static testmethod void  testByPassTriggerLogic(){
        
        
        ByPassTrigger__c b = new ByPassTrigger__c();
        b.Name = 'test trigger';
        b.isDisabled__c =false;
        insert b;
        
        BypassTriggerUtility bu = new BypassTriggerUtility();
        bu.isTriggerBypassed();
        
    }
    
    //Test BypassTriggerUtilityTest class 
   static testmethod void  testNegativeByPassTriggerLogic(){
        
        ByPassTrigger__c b = new ByPassTrigger__c();
        b.Name = 'test trigger';
        b.isDisabled__c =true;
        insert b;
        
        BypassTriggerUtility bu = new BypassTriggerUtility();
        bu.isDisabled=true;
        bu.isTriggerBypassed();
        
    }
    
}