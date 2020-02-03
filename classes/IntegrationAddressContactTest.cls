/**
*    
*   Author: Shanu Aggarwal
*   Date Added : 23-05-2017
*   This class tests the functionality of IntegrationAddressContact
* 
*/
@istest
public class IntegrationAddressContactTest{
    
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
           acc.Phone = '(604)440-3665';
           acc.Website = 'https://testWebsite.com/test.jsp?hello=\'asdf\'&test=1';
           acc.BillingStreet = '123';
           acc.BillingCity = 'San Diego';
           acc.BillingCountryCode = 'US';
           acc.BillingPostalCode = '90210';
           acc.BillingStateCode = 'CA';
           acc.EBS_Account_Id__c='99999';
           acc.EBS_Account_Number__c='99999';
           insert acc;
           
           Contact con = TestUtil.createContact(String.valueOf(acc.Id));
           con.EBS_Contact_ID__c='34567';
           //con.EBS_Contact_Number__c='45678';//HJ: Commented for TICCM-1077
           con.EBS_Contact_Party_Site_Id__c='56789';
           con.EBS_Party_ID__c='67890';
           con.MailingStreet='CA';
           con.MailingCity='Texas';
           con.MailingCountryCode='US';
           con.MailingPostalCode='H0H0H0';
           con.MailingStateCode='CA';
           insert con;
           
           Address__c address = new Address__c();
           address.Type__c = 'Billing';
           address.Account__c = acc.Id;
           address.City__c='Burnaby';
           address.Province__c='BC';
           address.Country__c='Canada';
           address.EBS_Site_Use_Id__c=null;
           insert address;
           
           Address__c sAddress = new Address__c();
           sAddress.Type__c = 'Shipping';
           sAddress.Account__c = acc.Id;
           address.City__c='Burnaby';
           address.Province__c='BC';
           address.Country__c='Canada';
           address.EBS_Site_Use_Id__c=null;
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
           eIntegration.Object__c = 'Address_Contact__c';
           eIntegration.Map__c =true;
           eIntegration.Field__c = 'Address__c';
           eIntegration.Validate__c=true;
           insert eIntegration;
           
       }
       
       Test.stopTest();
       
   }
    
   public static testMethod void testContacts(){
        
        Id accId = [Select Id From Account ].Id;
        Id conId = [Select Id From Contact ].Id;
        
        Address__c ad=new Address__c(Address__c='1',City__c='Burnaby',Province__c='BC',Country__c='Canada',Account__c=accId); 
        ad.EBS_Site_Number__c='12345';
        ad.EBS_Site_Use_ID__c='23456';
        insert ad;
        
        Address__c ad2=new Address__c(Address__c='2',City__c='Texas',Province__c='AS',Country__c='USA',Account__c=accId); 
        ad2.EBS_Site_Number__c='65465';
        ad2.EBS_Site_Use_ID__c='4654';
        insert ad2;
        
        
        Address_Contact__c ca=new Address_Contact__c(Account__c=accId,Contact__c=conId,Address__c=ad.Id);
        insert ca;
        
        ca.Address__c = ad2.Id;
        ca.EBS_Address_Contact_Id__c = '5545444';
        update ca;
        
        ca.EBS_Address_Contact_Id__c = '6444665';
        update ca;
        
        IntegrationAddressContact.handleUpdatedContact(new List<Id>{conId});
        
        CustomAccountContactRole__c cacr = new CustomAccountContactRole__c(Account__c=accId,Contact__c=conId,Role__c='Other');
        insert cacr;
        
        cacr.Role__c='Admin';
        update cacr;
        
        delete cacr;
    }

 
    
}