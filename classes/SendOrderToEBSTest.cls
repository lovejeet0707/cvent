/**
*    
*   Author: Mohsin Siddiqui
*   Date Added : 08-02-2019
*   This class tests the functionality of SendOrderToEBS.
* 
*/
@istest
public class SendOrderToEBSTest 
{
	  public static testmethod void testCreateServiceOrder()
      {
          Account acc = new Account();
          acc.Name = 'Biz Test Acc 1';   
          acc.EBS_Account_ID__c = '46465464';     
          acc.BillingCountry = 'US'; 
          acc.BillingState = 'AK';
          acc.BillingCity = 'AKat';
          acc.BillingStreet = '172 Palm Ave Apt 2';
          acc.BillingPostalCode='4654';
          acc.Service_Tier__c = 'Gold';
          insert acc;
          
          SMM_Implementations__c smm = new SMM_Implementations__c();
          smm.RecordTypeId = Schema.SObjectType.SMM_Implementations__c.getRecordTypeInfosByDeveloperName().get('SMM_Implementation').getRecordTypeId();
          smm.Contract_Status__c = 'Active';
          smm.Child_Account__c = 'No';
          smm.Type__c = 'Original';
          smm.Implementation_Status__c = 'Completed';
          smm.Legacy_Lanyon__c = 'Yes';
          smm.Account__c = acc.Id;
          insert smm;
          
          smm.Legacy_Lanyon__c = 'No';
          update smm;
          
          Contact con = new Contact();
          con.LastName = 'Test Con 1';
          con.AccountId = acc.Id;
          con.EBS_Account_Id__c = '464654';
          insert con;
          
          List<Address__c> addressList = new List<Address__c>();
          Address__c address = new Address__c();
          address.Type__c = 'Billing';
          address.Account__c = acc.Id;
          address.Country__c = 'US';
          address.State__c = 'NY';
          address.Postal_Code__c = '10001';
          
          Address__c sAddress = new Address__c();
          sAddress.Type__c = 'Shipping';
          sAddress.Account__c = acc.Id;
          
          addressList.add(address);
          addressList.add(SAddress);
          insert addressList;
          Opportunity opp = new Opportunity();
          opp.Name = 'Test Opp 1';
          opp.AccountId = acc.Id;
          opp.StageName = 'Closed Won';
          opp.CloseDate = System.today()+ 30;
          opp.Contact_Associated__c = con.Id;
          opp.Contact_Role__c = 'Influencer';
          opp.ContractReceived__c = System.today()-7;
          opp.Bill_To_Address__c = addressList[0].Id;
          opp.Ship_To_Address__c = addressList[1].Id;
          opp.SF_Org_ID__c = '00Df0000002HJcq';
          
          insert opp;
          test.startTest();
          	SendOrderToEBS.createCustomerAndServiceOrder(opp.Id);
          test.stopTest();
      }
}