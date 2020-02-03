/**
*    
*   Author: Shanu Aggarwal
*   Date Added : 23-05-2017
*   This class tests the functionality of IntegrationHelper
* 
*/
@istest
public class IntegrationHelperTest{
    
   @testsetup
   public static void CreateTestData(){
        
        Test.startTest();
        //Inserting User...............
        Profile p = [SELECT Id FROM Profile WHERE Name='Finance - Management']; 
    
        USerrole[] testroleId=[select id from userRole where name ='AM (Event)' OR name ='Pre Sales - Special Projects' limit 2];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Sops', LanguageLocaleKey='en_US', FirstName='TestUser',
        LocaleSidKey='en_US', ProfileId = p.Id, userRoleId=testroleId[0].id,
        TimeZoneSidKey='America/Los_Angeles', UserName='Test'+'deploymentuser@cvent.com',Enable_EBS_Sync__c=true);
        
        
        system.runAs(u){
            
            
           List<EBS_Integration__c> ebsList = new List<EBS_Integration__c>();
           EBS_Integration__c eIntegration = new EBS_Integration__c();
           eIntegration.Name = 'Contact Integration1';
           eIntegration.Object__c = 'Contact';
           eIntegration.Map__c =true;
           eIntegration.Map_To__c = 'Name';
           eIntegration.Field__c = 'Name';
           eIntegration.Validate__c=true;
       
           
           EBS_Integration__c eIntegration2 = new EBS_Integration__c();
           eIntegration2.Name = 'Contact Integration2';
           eIntegration2.Object__c = 'Contact';
           eIntegration2.Map__c =true;
           eIntegration2.Map_To__c = 'Name';
           eIntegration2.Field__c = 'Account.Name';
           eIntegration2.Validate__c=true;
           
           ebsList.add(eIntegration);
           ebsList.add(eIntegration2);
           insert ebsList;
            
           Account acc = new Account();
           acc.Name = 'Biz Test Acc 1';   
           acc.EBS_Account_ID__c = '46465464';        
           insert acc;
           
           Contact con = new Contact();
           con.LastName = 'Test Con 1';
           con.AccountId = acc.Id;
           con.EBS_Account_Id__c = '464654';
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
           
           
           
       }
       
       Test.stopTest();
       
   }
   

    public static testmethod void testIntegratioHelper(){
       
       List<EBS_Integration__c> ebsList = [Select Id,Map_To__c From EBS_Integration__c];
       Id accId = [Select Id From Account Limit 1].Id;
       Contact con = [Select Id,Name,LastName,LastModifiedById,EBS_Account_Id__c from Contact Limit 1 ];
       
       Integration_Queue__c iq = new Integration_Queue__c();
       iq.Type__c = 'New';
       iq.Object_Id__c = con.Id;
       iq.Status__c = 'Queued';
       iq.Queue__c = 'Contact';
       insert iq;
       
       
       
       IntegrationHelper.copyQueueItem(iq,iq,ebsList);
       IntegrationHelper.addToQueue(new Map<String,Integration_Queue__c>{con.Id=>iq},ebsList,'Contact');
      
       con.LastName = 'testing';
       con.EBS_Account_Id__c = '16465478';
       con.AccountId = accId;
       con.EBS_Party_Id__c = '4654646';
       update con;
       
       
     
       
       
       
    }
    
    //Test EBSIntegrationQueueTrigger 
    public static testmethod void testEBSIntegrationQueueTrigger(){
     
       Contact con = [Select Id,Name,LastName,LastModifiedById,EBS_Account_Id__c from Contact Limit 1 ];
       
       EBS_Order_Sync_Framework__c frameWork = [Select Id From EBS_Order_Sync_Framework__c Limit 1];
           
           
       Integration_Queue__c iq = new Integration_Queue__c();
       iq.Type__c = 'New';
       iq.Object_Id__c = con.Id;
       iq.Status__c = 'Queued';
       iq.EBS_Order_Sync_Process_Id__c = frameWork.Id;
       iq.Queue__c = 'Contact';
       insert iq;
      
       iq.Status__c = 'Processed';
       update iq;
       
       
       
    }
    
   
    
    
  
}