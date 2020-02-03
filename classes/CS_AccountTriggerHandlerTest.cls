/**
*    
*   Author: Shanu Aggarwal
*   Date Added : 23-05-2017
*   This class tests the functionality of CS_AccountTriggerHandler
* 
*/
@istest
public class CS_AccountTriggerHandlerTest {
   
   @testsetup
   public static void CreateTestData(){
        
        Test.startTest();
        //Inserting User...............
        Profile p = [SELECT Id FROM Profile WHERE Name='Finance - Management']; 
    
        USerrole[] testroleId=[select id from userRole where name ='AM (Event)' OR name ='Pre Sales - Special Projects' limit 2];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Sops', LanguageLocaleKey='en_US', FirstName='TestUser',
        LocaleSidKey='en_US', ProfileId = p.Id, userRoleId=testroleId[0].id,
        TimeZoneSidKey='America/Los_Angeles', UserName='Test'+'deploymentuser@cvent.com');
        
        
        system.runAs(u){
            
           Account acc = TestUtil.createAccount('Test Account','Biz_Ac');   
           insert acc;
           
           Contact con = new Contact();
           con.LastName = 'Test Con 1';
           con.AccountId = acc.Id;
           insert con;
           
           Address__c address = new Address__c();
           address.Type__c = 'Billing';
           address.Account__c = acc.Id;
           insert address;
           
           Address__c sAddress = new Address__c();
           sAddress.Type__c = 'Shipping';
           sAddress.Account__c = acc.Id;
           insert sAddress;
           
           Opportunity opp = new Opportunity();
           opp.Name = 'Test Opp 1';
           opp.AccountId = acc.Id;
           opp.StageName = 'Opp Identified';
           opp.CloseDate = System.today()+ 30;
           opp.Contact_Associated__c = con.Id;
           opp.Bill_To_Address__c = address.Id;
           opp.Ship_To_Address__c = sAddress.Id;
           insert opp;
           
           
           List<EBS_Orders__c> orderList = new List<EBS_Orders__c>();
           //Order 1
           EBS_Orders__c order1 = new EBS_Orders__c();
           order1.Opportunity__c = opp.Id;
           order1.EBS_Order_Number__c = 'OR-54564';
           order1.EBS_Order_Status__c = 'New';
           order1.EBS_Quote_Number__c = 'QA-154455';
           order1.EBS_Header_ID__c = '646546';
           order1.Product_Line__c = 'Event';
           
         
           
           //Order 2
           EBS_Orders__c order2 = new EBS_Orders__c();
           order2.Opportunity__c = opp.Id;
           order2.EBS_Order_Number__c = 'OR-54565';
           order2.EBS_Order_Status__c = 'New';
           order2.EBS_Quote_Number__c = 'QA-154456';
           order2.EBS_Header_ID__c = '21311';
           order2.Product_Line__c = 'Event';
           
           orderList.add(order1);
           orderList.add(order2);
           
           //insert orderList;
           
           EBS_Order_Sync_Framework__c frameWork = new EBS_Order_Sync_Framework__c();
           framework.Opportunity__c  = opp.Id;
           insert frameWork;
           
           EBS_Integration__c eIntegration = new EBS_Integration__c();
           eIntegration.Name = 'Account Integration';
           eIntegration.Object__c = 'Account';
           eIntegration.Map__c =true;
           eIntegration.Field__c = 'Name';
           eIntegration.Validate__c=true;
           insert eIntegration;
           
       }
       
       Test.stopTest();
       
   }
    
   //This method tests account address
   public static testmethod void testAccountAddress(){
       Account acc = [Select Id,Name,ShippingStreet,LastModifiedById,EBS_Account_ID__c from Account Limit 1 ];
       acc.ShippingStreet = 'CA';
       acc.BillingStreet = 'SA';
       
       update acc;
   }
   
   public static testMethod void testFake(){
       CS_AccountTriggerHandler.fakeMethod();
   }
    
}