/**
*    
*   Author: Shanu Aggarwal
*   Date Added : 23-05-2017
*   This class tests the functionality of IntegrationOpportunity
* 
*/
@istest
public class IntegrationOpportunityTest{
    
   @testsetup
   public static void CreateTestData(){
        
        
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
           eIntegration.Name = 'Opp Integration1';
           eIntegration.Object__c = 'Opportunity';
           eIntegration.Map__c =true;
           eIntegration.Field__c = 'StageName';
           eIntegration.Validate__c=true;
       
           
           EBS_Integration__c eIntegration2 = new EBS_Integration__c();
           eIntegration2.Name = 'Opp Integration2';
           eIntegration2.Object__c = 'Opportunity';
           eIntegration2.Map__c =true;
           eIntegration2.Field__c = 'AccountId';
           eIntegration2.Validate__c=true;
           
        EBS_Integration__c eIntegration3 = new EBS_Integration__c();
        eIntegration3.Name = 'Opp Integration3';
        eIntegration3.Object__c = 'Opportunity';
        eIntegration3.Map__c =true;
        eIntegration3.Field__c = 'Bill_to_Address__c';
        eIntegration3.Validate__c=true;

        EBS_Integration__c eIntegration4 = new EBS_Integration__c();
        eIntegration4.Name = 'Opp Integration4';
        eIntegration4.Object__c = 'Opportunity';
        eIntegration4.Map__c =true;
        eIntegration4.Field__c = 'Ship_To_Address__c';
        eIntegration4.Validate__c=true;

        EBS_Integration__c eIntegration5 = new EBS_Integration__c();
        eIntegration5.Name = 'Opp Integration5';
        eIntegration5.Object__c = 'Opportunity';
        eIntegration5.Map__c =true;
        eIntegration5.Field__c = 'Bill_To_Contact__c';
        eIntegration5.Validate__c=true;

        EBS_Integration__c eIntegration6 = new EBS_Integration__c();
        eIntegration6.Name = 'Opp Integration6';
        eIntegration6.Object__c = 'Opportunity';
        eIntegration6.Map__c =true;
        eIntegration6.Field__c = 'Ship_To_Contact__c';
        eIntegration6.Validate__c=true;

        EBS_Integration__c eIntegration7 = new EBS_Integration__c();
        eIntegration7.Name = 'Opp Integration7';
        eIntegration7.Object__c = 'Opportunity';
        eIntegration7.Map__c =true;
        eIntegration7.Field__c = 'Name';
        eIntegration7.Validate__c=true;

       
        EBS_Integration__c eIntegration8 = new EBS_Integration__c();
        eIntegration8.Name = 'Opp Integration8';
        eIntegration8.Object__c = 'Opportunity';
        eIntegration8.Map__c =true;
        eIntegration8.Field__c = 'Account.EBS_Account_Id__c';
        eIntegration8.Validate__c=true;

        EBS_Integration__c eIntegration9 = new EBS_Integration__c();
        eIntegration9.Name = 'Opp Integration9';
        eIntegration9.Object__c = 'Opportunity';
        eIntegration9.Map__c =true;
        eIntegration9.Field__c = 'Ship_To_Address__r.EBS_Site_Use_ID__c';
        eIntegration9.Validate__c=true;
            
        EBS_Integration__c eIntegration10 = new EBS_Integration__c();
        eIntegration10.Name = 'Opp Integration10';
        eIntegration10.Object__c = 'Opportunity';
        eIntegration10.Map__c =true;
        eIntegration10.Field__c = 'Bill_to_Address__r.EBS_Site_Use_ID__c';
        eIntegration10.Validate__c=true;

        
        EBS_Integration__c eIntegration11 = new EBS_Integration__c();
        eIntegration11.Name = 'Opp Integration11';
        eIntegration11.Object__c = 'Opportunity';
        eIntegration11.Map__c =true;
        eIntegration11.Field__c = 'Bill_To_Contact__r.EBS_Contact_Id__c';
        eIntegration11.Validate__c=true;

        EBS_Integration__c eIntegration12 = new EBS_Integration__c();
        eIntegration12.Name = 'Opp Integration12';
        eIntegration12.Object__c = 'Opportunity';
        eIntegration12.Map__c =true;
        eIntegration12.Field__c = 'Ship_To_Contact__r.EBS_Contact_ID__c';
        eIntegration12.Validate__c=true;
        

        
            
           ebsList.add(eIntegration);
           ebsList.add(eIntegration2);
           ebsList.add(eIntegration3);
           ebsList.add(eIntegration4);
           ebsList.add(eIntegration5);
           ebsList.add(eIntegration6);
           ebsList.add(eIntegration7);
           ebsList.add(eIntegration8);
           ebsList.add(eIntegration9);
           ebsList.add(eIntegration10);
           ebsList.add(eIntegration11);
           ebsList.add(eIntegration12);

           insert ebsList;
           
           
           Account acc = TestUtil.createAccount('Test Account','Biz_Ac');
           acc.EBS_Account_ID__c = '46465464';     
           acc.BillingCity = 'AKat';
           acc.BillingStreet = '172 Palm Ave Apt 2';
           insert acc;
           
           List<Address__c> addressList = new List<Address__c>();
           Address__c address = new Address__c();
           address.Type__c = 'Billing';
           address.Account__c = acc.Id;
           
           Address__c sAddress = new Address__c();
           sAddress.Type__c = 'Shipping';
           sAddress.Account__c = acc.Id;

           addressList.add(address);
           addressList.add(SAddress);
           insert addressList;
           
           Contact con = TestUtil.createContact(String.valueOf(acc.Id));
           con.EBS_Account_Id__c = '464654';
           insert con;
           
           
           test.startTest();
            
           List<Opportunity> oppList = new List<Opportunity> ();

           Opportunity opp = TestUtil.createOpportunityNew('Test Opp 1','Verbal',con.Id,acc.Id);
           opp.CloseDate = System.today()+ 30;
           opp.ContractReceived__c = System.today()-7;
           opp.Bill_To_Address__c = addressList[0].Id;
           opp.Ship_To_Address__c = addressList[1].Id;
           opp.Logo_Classification__c = 'True New Logo';
           opp.StageName = 'Closed Won';
            
           Opportunity opp2 = TestUtil.createOpportunityNew('Test Opp 2','Opp Identified',con.Id,acc.Id);
           opp2.CloseDate = System.today()+ 30;
           opp2.ContractReceived__c = System.today()-7;
           opp2.Bill_To_Address__c = address.Id;
           opp2.Ship_To_Address__c = sAddress.Id;
           opp2.Bill_To_Address__c = addressList[0].Id;
           opp2.Ship_To_Address__c = addressList[1].Id;
           opp2.Logo_Classification__c = 'True New Logo';
           //opp2.StageName = 'Closed Won';
           
           oppList.add(opp);
           oppList.add(opp2);
           insert oppList;

           Product2 prd1 = new Product2 (Name='DG - Creative Services',Product_Line__c='RegOnline by Lanyon',Description='Test Product Entry 1',productCode = 'ABC', isActive = true);
           insert prd1;
           
           PricebookEntry standPriceBook = new PricebookEntry();
           standPriceBook.Product2ID=prd1.Id;
           standPriceBook.Pricebook2ID=Test.getStandardPricebookId();//standardPb.id;
           standPriceBook.UnitPrice=50;
           standPriceBook.isActive=true;
           insert standPriceBook;
           
           List<OpportunityLineItem> lineItemList = new List<OpportunityLineItem>();
           OpportunityLineItem lineItem = new OpportunityLineItem();
           lineItem.OpportunityID = oppList[0].Id;
           lineItem.PriceBookEntryID=standPriceBook.Id;
           lineItem.quantity=-2;
           lineItem.TotalPrice = 50;
           
           
           OpportunityLineItem lineItem2 = new OpportunityLineItem();
           lineItem2.OpportunityID = oppList[1].Id;
           lineItem2.PriceBookEntryID=standPriceBook.Id;
           lineItem2.quantity=-2;
           lineItem2.TotalPrice = 50;
           
           lineItemList.add(lineItem);
           lineItemList.add(lineItem2);
           insert lineItem;
           
           
           //Update opp;
           Test.stopTest();

       }
       
       
       
    }
   
  
    public static testmethod void testhandleNewOpportunities(){

        
        Opportunity opp = [Select Id,Name,Bill_to_Address__c,Ship_To_Address__c,Bill_To_Contact__c,Ship_To_Contact__c,Account.EBS_Account_Id__c,Bill_to_Address__r.EBS_Site_Use_ID__c,StageName,
                            Number_of_Products__c,Migrated_to_EBS__c,Ship_To_Address__r.EBS_Site_Use_ID__c,Bill_To_Contact__r.EBS_Contact_Id__c,Ship_To_Contact__r.EBS_Contact_ID__c,(Select Id From OpportunityLineItems) From Opportunity Where StageName = 'Closed Won' ];
        test.startTest();
        
        
        //Handle New Opportunity 
        IntegrationOpportunity.handleNewOpportunities(new List<Opportunity>{opp});
        IntegrationOpportunity.handleUpdatedOpportunities(new List<Opportunity>{opp},new Map<Id,Opportunity>());
        
        Opportunity opp2 = opp.clone(false,false);
        
        IntegrationOpportunity.handleNewOpportunities(new List<Opportunity>{opp2});
       
        test.stopTest();
       
    }

    public static testmethod void testhandleUpdatedOpportunities(){

        Contact c = [Select Id From Contact Limit 1];
        Opportunity oldOpp = [Select Id,Name,Bill_to_Address__c,Ship_To_Address__c,Bill_To_Contact__c,Ship_To_Contact__c,Account.EBS_Account_Id__c,Bill_to_Address__r.EBS_Site_Use_ID__c,StageName,
                            Number_of_Products__c,Migrated_to_EBS__c,Ship_To_Address__r.EBS_Site_Use_ID__c,Bill_To_Contact__r.EBS_Contact_Id__c,Ship_To_Contact__r.EBS_Contact_ID__c,(Select Id From OpportunityLineItems) From Opportunity Where StageName != 'Closed Won'];
           
        Account acc = TestUtil.createAccount('Test Account','Biz_Ac');
        acc.EBS_Account_ID__c = '12131133';     
        acc.BillingCity = 'AKat';
        acc.BillingStreet = '172 Palm Ave Apt 2';
        insert acc;
        
        
        List<Address__c> addressList = new List<Address__c>();
        Address__c address = new Address__c();
        address.Type__c = 'Billing';
        address.Account__c = acc.Id;
        
        
        Address__c sAddress = new Address__c();
        sAddress.Type__c = 'Shipping';
        sAddress.Account__c = acc.Id;
        
        addressList.add(address);
        addressList.add(SAddress);
        insert addressList;
        
        
        
           
        EBS_Order_Sync_Framework__c frameWork = new EBS_Order_Sync_Framework__c();
        framework.Opportunity__c  = oldOpp.Id;
        insert frameWork;
        
       
        test.startTest();
        
       
       
        Opportunity newOpp = oldOpp.clone(true,true);
        newOpp.StageName = 'Closed Won';
        newOpp.AccountId =  acc.Id;
        newOpp.Bill_To_Address__c = addressList[0].Id;
        newOpp.Ship_To_Address__c = addressList[1].Id;
        update newOpp;
        
        
           
        //Handle Opportunity Updates
        IntegrationOpportunity.handleUpdatedOpportunities(new List<Opportunity>{newOpp},new Map<Id,Opportunity>{oldOpp.Id=>oldOpp});
        
        IntegrationOpportunity.updateParentAccount(new List<Opportunity>{newOpp},null);
        IntegrationOpportunity.updateParentAccount(new List<Opportunity>{newOpp},new Map<Id,Opportunity>{oldOpp.Id=>oldOpp});
        
        test.stopTest();
       
    }
    
    public static testmethod void testEnqueueOrders(){
        
        Opportunity newOpp = [Select Id,Name,Bill_to_Address__c,Ship_To_Address__c,Bill_To_Contact__c,Ship_To_Contact__c,Account.EBS_Account_Id__c,Bill_to_Address__r.EBS_Site_Use_ID__c,StageName,
                            Number_of_Products__c,Migrated_to_EBS__c,Ship_To_Address__r.EBS_Site_Use_ID__c,Bill_To_Contact__r.EBS_Contact_Id__c,Ship_To_Contact__r.EBS_Contact_ID__c,(Select Id From OpportunityLineItems) From Opportunity Where StageName != 'Closed Won'];
        test.startTest();
            EBS_Order_Sync_Framework__c frameWork = new EBS_Order_Sync_Framework__c();
            framework.Opportunity__c  = newOpp.Id;
            insert frameWork;
            
            IntegrationOpportunity.enqueueOrders(new Map <Id, EBS_Order_Sync_Framework__c> {frameWork.Id=>frameWork});
            IntegrationOpportunity.resyncOpportunity(newOpp.Id);
            IntegrationOpportunity.resyncOpportunityForOrderSync(newOpp.Id,frameWork.Id);
        test.stopTest();
    }
    
    public static testmethod void testNegativeAddtoQueue(){

        Contact c = [Select Id From Contact Limit 1];
       
        
        Opportunity newOpp = [Select Id,Name,Bill_to_Address__c,Ship_To_Address__c,Bill_To_Contact__c,Ship_To_Contact__c,Account.EBS_Account_Id__c,Bill_to_Address__r.EBS_Site_Use_ID__c,StageName,
                            Number_of_Products__c,Migrated_to_EBS__c,Ship_To_Address__r.EBS_Site_Use_ID__c,Bill_To_Contact__r.EBS_Contact_Id__c,Ship_To_Contact__r.EBS_Contact_ID__c,(Select Id From OpportunityLineItems) From Opportunity Where StageName != 'Closed Won'];
        test.startTest();
        
            newopp.Bill_To_Contact__c = c.Id;
            newopp.Ship_To_Contact__c = c.Id;
            update newOpp;
            
            EBS_Order_Sync_Framework__c frameWork = new EBS_Order_Sync_Framework__c();
            framework.Opportunity__c  = newOpp.Id;
            insert frameWork;
            
            IntegrationOpportunity.enqueueOrders(new Map <Id, EBS_Order_Sync_Framework__c> {frameWork.Id=>frameWork});
            IntegrationOpportunity.resyncOpportunity(newOpp.Id);
            IntegrationOpportunity.resyncOpportunityForOrderSync(newOpp.Id,frameWork.Id);
        test.stopTest();
       
    }
   
  
}