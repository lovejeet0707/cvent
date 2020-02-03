/**
*    
*   Author: Shanu Aggarwal
*   Date Added : 23-05-2017
*   This class tests the functionality of IntegrationAddress
* 
*/
@istest
public class IntegrationAddressTest{
    
   @testsetup
   public static void CreateTestData(){
        
        Test.startTest();
        
        //enable sync
        ByPassTrigger__c bp = new ByPassTrigger__c();
        bp.SetupOwnerId = UserInfo.getUserId();
        bp.Enable_EBS_Sync__c =true;
        insert bp;
        
        //Inserting User...............
        /*Profile p = [SELECT Id FROM Profile WHERE Name='Finance - Management']; 
    
        USerrole[] testroleId=[select id from userRole where name ='AM (Event)' OR name ='Pre Sales - Special Projects' limit 2];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Sops', LanguageLocaleKey='en_US', FirstName='TestUser',
        LocaleSidKey='en_US', ProfileId = p.Id, userRoleId=testroleId[0].id,
        TimeZoneSidKey='America/Los_Angeles', UserName='Test'+'deploymentuser@cvent.com');*/
       
        User u = [Select Id From User Where Name like '%deployment%' limit 1];
        
        CountryCode__c country = new CountryCode__c();
        country.Name = 'US';
        country.Code__c  = 'US';
        insert country;
            
        CountryCode__c country2 = new CountryCode__c();
        country2.Name = 'United States';
        country2.Code__c  = 'US';
        insert country2;
            
        CountryCode__c country3 = new CountryCode__c();
        country3.Name = 'CA';
        country3.Code__c  = 'CA';
        insert country3;
        
        
        system.runAs(u){
            
           Account acc = new Account();
           acc.Name = 'Biz Account Test 1';
           acc.Phone = '(604)440-3665';
           acc.Website = 'https://testWebsite.com/test.jsp?hello=\'asdf\'&test=1';
           acc.BillingStreet = '123';
           acc.BillingCity = 'San Diego';
           acc.BillingCountry = 'US';
           acc.BillingPostalCode = '90210';
           acc.BillingState = 'CA';
           acc.EBS_Account_Id__c='99999';      
           insert acc;
           
           Contact con = new Contact();
           con.LastName = 'Test Con 1';
           con.AccountId = acc.Id;
           insert con;
           
           Address__c address = new Address__c();
           address.Type__c = 'Billing';
           address.Account__c = acc.Id;
           address.City__c='Burnaby';
           address.Province__c='BC';
           address.Country__c='CA';
           address.EBS_Site_Use_Id__c=null;
           address.CountryCode__c = 'US';
           insert address;
           
           Address__c sAddress = new Address__c();
           sAddress.Type__c = 'Shipping';
           sAddress.Account__c = acc.Id;
           saddress.City__c='Burnaby';
           saddress.Province__c='BC';
           saddress.Country__c='CA';
           saddress.EBS_Site_Use_Id__c=null;
           saddress.CountryCode__c = 'US';
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
           eIntegration.Name = 'Address Integration';
           eIntegration.Object__c = 'Address__c';
           eIntegration.Map__c =true;
           eIntegration.Field__c = 'City__c';
           eIntegration.Validate__c=true;
           insert eIntegration;
           
       }
       
       Test.stopTest();
       
   }
   
   //This method test Handle New Accounts, Resync Accounts
   
   public static testmethod void testAddress(){
       
        
        Id accId = [Select Id From Account Limit 1].Id;
        
        CountryCode__c country = new CountryCode__c();
        
        country.Name = 'Canada';
        country.Code__c  = 'CA';
        insert country;
        
        CountryCode__c country2 = new CountryCode__c();
        
        country2.Name = 'PU';
        country2.Code__c  = 'PU';
        insert country2;
        
        Address__c aad=new Address__c(City__c='Burnaby',Province__c='BC',Country__c='CA',Account__c=accId,CountryCode__c='US'); //Name='Test',Address__c='1',
        insert aad;
        
        aad.Province__c='USA';
        aad.City__c='Texas';
        update aad;
        
        aad.Country__c='PU';
        aad.City__c='Sintra';
        aad.EBS_Site_Use_Id__c = '465464';
        update aad;
        
        
        IntegrationAddress.handleUpdatedAddresses(new List<Address__c>{aad},new Map<Id,Address__c>{aad.Id=>aad});
        IntegrationAddress.resyncAddress(aad.Id);
        
        delete aad; 
   }


    
}