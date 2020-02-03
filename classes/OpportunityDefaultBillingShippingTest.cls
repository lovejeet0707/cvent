/**
*    
*   Author: Shanu Aggarwal
*   Date Added : 23-05-2017
*   This class tests the functionality of OpportunityDefaultBillingShipping
* 
*/
@istest
public class OpportunityDefaultBillingShippingTest{
    
    //This method tests Billing Shipping Addresses Update      
    public static testmethod void testBillingShipping(){
        
        Test.startTest();
        //Inserting User...............
        Profile p = [SELECT Id FROM Profile WHERE Name='Finance - Management']; 
        
        USerrole[] testroleId=[select id from userRole where name ='AM (Event)' OR name ='Pre Sales - Special Projects' limit 2];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Sops', LanguageLocaleKey='en_US', FirstName='TestUser',
                          LocaleSidKey='en_US', ProfileId = p.Id, userRoleId=testroleId[0].id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='Test'+'deploymentuser@cvent.com',Enable_EBS_Sync__c=true);
        
        
        system.runAs(u){
            
            //Create Account
            Account acc = TestUtil.createAccount('Biz Test Acc 1','Biz_Ac');
            acc.EBS_Account_ID__c = '46465464';        
            insert acc;
            
            //Create Addresses 
            List<Address__c> addressList = new List<Address__c>();
            
            Address__c address = new Address__c();
            address.Type__c = 'Billing';
            address.Account__c = acc.Id;
            address.EBS_Site_Use_ID__c = '65465314654';
            address.Operating_Unit_Name__c = 'CVINC';
            address.Primary_Sync__c=true;
            
            
            Address__c sAddress = new Address__c();
            sAddress.Type__c = 'Shipping';
            sAddress.Account__c = acc.Id;
            sAddress.EBS_Site_Use_ID__c = '6464646';
            sAddress.Operating_Unit_Name__c = 'CVUK';
            saddress.Primary_Sync__c=true;
            
            //addressList.add(address);
            addressList.add(sAddress);
            insert addressList;
            
            //Create Contact
            Contact con = TestUtil.createContact(String.valueOf(acc.Id));
            con.EBS_Account_Id__c = '464654';
            con.EBS_Party_ID__c = '64646';
            insert con;
            
            
            Opportunity opp = TestUtil.createOpportunityNew('Test Opportunity','Opp Identified',con.Id,acc.Id);
            opp.CloseDate = System.today()+ 30;
            insert opp;           
            
            OpportunityDefaultBillingShipping.UpdateOppBillingShipping(new List<Opportunity>{opp});
            system.assertEquals(saddress.Id,opp.Ship_To_Address__c);
            system.assertEquals(con.Id, opp.Contact_Associated__c);
        }
        Test.stopTest();
    }
    public static testmethod void testBilling(){
        
        Test.startTest();
        //Inserting User...............
        Profile p = [SELECT Id FROM Profile WHERE Name='Finance - Management']; 
        
        USerrole[] testroleId=[select id from userRole where name ='AM (Event)' OR name ='Pre Sales - Special Projects' limit 2];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Sops', LanguageLocaleKey='en_US', FirstName='TestUser',
                          LocaleSidKey='en_US', ProfileId = p.Id, userRoleId=testroleId[0].id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='Test'+'deploymentuser@cvent.com',Enable_EBS_Sync__c=true);
        
        
        system.runAs(u){
            
            //Create Account
            Account acc = TestUtil.createAccount('Biz Test Acc 2','Biz_Ac');
            acc.EBS_Account_ID__c = '4646546412';        
            insert acc;
            
            //Create Addresses 
            List<Address__c> addressList = new List<Address__c>();
            
            Address__c address = new Address__c();
            address.Type__c = 'Billing';
            address.Account__c = acc.Id;
            address.EBS_Site_Use_ID__c = '65465314231';
            address.Operating_Unit_Name__c = 'CVIAV';
            //address.Primary_Sync__c=true;
            insert address;
            
            /*Address__c sAddress = new Address__c();
sAddress.Type__c = 'Shipping';
sAddress.Account__c = acc.Id;
sAddress.EBS_Site_Use_ID__c = '6464646';
sAddress.Operating_Unit_Name__c = 'CVUK';
saddress.Primary_Sync__c=true;*/
            
            //addressList.add(address);
            addressList.add(Address);
            //insert addressList;
            
            //Create Contact
            Contact con = TestUtil.createContact(String.valueOf(acc.Id));
            con.EBS_Account_Id__c = '464654';
            con.EBS_Party_ID__c = '64646';
            insert con;
            
            
            Opportunity opp = TestUtil.createOpportunityNew('Test Opportunity','Opp Identified',con.Id,acc.Id);
            opp.CloseDate = System.today()+ 30;
            insert opp; 
            
            OpportunityDefaultBillingShipping.UpdateOppBillingShipping(new List<Opportunity>{opp});
            //system.assertEquals(address.Id,opp.Bill_To_Address__c);
        }
        Test.stopTest();  
    } 
}