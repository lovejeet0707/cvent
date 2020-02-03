@istest
public class OpportunityLineItemToSKUsTest{
    
  
   static testmethod void testSKUSWithProducts(){
        
        
        //Inserting User...............
        Profile p = [SELECT Id FROM Profile WHERE Name='Finance - Management']; 
    
        USerrole[] testroleId=[select id from userRole where name ='AM (Event)' OR name ='Pre Sales - Special Projects' limit 2];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Sops', LanguageLocaleKey='en_US', FirstName='TestUser',
        LocaleSidKey='en_US', ProfileId = p.Id, userRoleId=testroleId[0].id,
        TimeZoneSidKey='America/Los_Angeles', UserName='Test'+'deploymentuser@cvent.com',Enable_EBS_Sync__c=true);
        
        
        system.runAs(u){
        
            Account acc = TestUtil.createAccount('Biz Test Acc 1','Biz_Ac');
            acc.EBS_Account_ID__c = '46465464';     
            acc.BillingCity = 'AKat';
            acc.BillingStreet = '172 Palm Ave Apt 2';
            insert acc;


            Contact con = TestUtil.createContact(String.valueOf(acc.Id));
            con.EBS_Account_Id__c = '464654';
            insert con;


            LicenseVsProductSetting__c license = new LicenseVsProductSetting__c();
            license.Name = 'Prepayment - Events Fee';
            license.Product__c = 'Prepayment - Events Fee';      
            insert license;
            
            ProductVsFamilySetting__c product = new ProductVsFamilySetting__c();
            product.Name = 'CrowdCompass';
            product.Family__c = 'CrowdCompass';
            insert product;


         


            Opportunity opp = TestUtil.createOpportunityNew('Test Opportunity','Verbal',con.Id,acc.Id);
            opp.CloseDate = System.today()+ 30;
            opp.ContractReceived__c = System.today()-7;
            opp.Product__c = 'CrowdCompass';
            opp.License_Type__c = 'Prepayment - Events Fee';
            opp.New_Amount__c = 150;
            opp.MaintenanceFee__c = 10;
            opp.Convinience_Fee__c = 10;
            //opp.Discount__c = 10;
           
            //opp.of_Registrations__c= 10;// comment by kumud field cleanup activity
           // opp.Events__c= 10;// comment by kumud field cleanup activity
           // opp.of_Transactions__c= 10; // comment by kumud field cleanup activity
            opp.of_Leads_Purchased__c= 10;
            opp.Per_Registration_Fee__c= 10;
            /*opp.Per_Event_Fee__c= 10;
            opp.Per_Transaction_Fee__c= 10;
            opp.Price_per_lead__c= 10;
            opp.of_Free_Registrations__c= 10;
            opp.of_Free_Events__c= 10;
            opp.of_Free_Transactions__c= 10;*/ // field cleanu activity
            opp.of_Complimentary_Leads__c= 10;


            test.startTest();
            insert opp;
            
            List<Product2> prodList = new List<Product2>();
            
            Product2 prd1 = new Product2 (Name='Convenience Fee', Family='CrowdCompass', Description='Test Product Entry 1',productCode = 'Prepayment - Events Fee',isActive = true);
            
            
            prodList.add(prd1);
            insert prodList;
            
    
            List<PricebookEntry> entryList = new List<PricebookEntry>();
            
            PricebookEntry standPriceBook1 = new PricebookEntry();
            standPriceBook1.Product2ID=prodList[0].Id;
            standPriceBook1.Pricebook2ID=Test.getStandardPricebookId();
            standPriceBook1.UnitPrice=50;
            standPriceBook1.isActive=true;
            
         
            
            entryList.add(standPriceBook1);
           
            
            insert entryList;
           

            List<OpportunityLineItem> lineItemList = new List<OpportunityLineItem>();
            OpportunityLineItem lineItem = new OpportunityLineItem();
            lineItem.OpportunityID = opp.Id;
            lineItem.PricebookEntryId=entryList[0].Id;
            lineItem.quantity=3;
            lineItem.TotalPrice = 50;

            insert lineItem;
            
            OpportunityLineItemToSKUs.MoveItemstoSKUs(opp.Id);

            test.stopTest();
        
        }
        
    }
    
    static testmethod void testSKUSWithourProducts(){
        
        
        //Inserting User...............
        Profile p = [SELECT Id FROM Profile WHERE Name='Finance - Management']; 
    
        USerrole[] testroleId=[select id from userRole where name ='AM (Event)' OR name ='Pre Sales - Special Projects' limit 2];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Sops', LanguageLocaleKey='en_US', FirstName='TestUser',
        LocaleSidKey='en_US', ProfileId = p.Id, userRoleId=testroleId[0].id,
        TimeZoneSidKey='America/Los_Angeles', UserName='Test'+'deploymentuser@cvent.com',Enable_EBS_Sync__c=true);
        
        
        system.runAs(u){
        
            Account acc = TestUtil.createAccount('Biz Test Acc 1','Biz_Ac');
            acc.EBS_Account_ID__c = '46465464';     
            acc.BillingCity = 'AKat';
            acc.BillingStreet = '172 Palm Ave Apt 2';
            insert acc;


            Contact con = TestUtil.createContact(String.valueOf(acc.Id));
            con.EBS_Account_Id__c = '464654';
            insert con;


            LicenseVsProductSetting__c license = new LicenseVsProductSetting__c();
            license.Name = 'Prepayment - Events Fee';
            license.Product__c = 'Prepayment - Events Fee';      
            insert license;
            
            ProductVsFamilySetting__c product = new ProductVsFamilySetting__c();
            product.Name = 'CrowdCompass';
            product.Family__c = 'CrowdCompass';
            insert product;


         


            Opportunity opp = TestUtil.createOpportunityNew('Test Opportunity','Closed Won',con.Id,acc.Id);
            opp.CloseDate = System.today()+ 30;
            opp.ContractReceived__c = System.today()-7;

            opp.Product__c = 'CrowdCompass';
            opp.License_Type__c = 'Prepayment - Events Fee';
            opp.New_Amount__c = 150;
            opp.MaintenanceFee__c = 10;
            opp.Convinience_Fee__c = 10;
           // opp.Discount__c = 10;// comment by kumud field cleanup activity
           // opp.of_Registrations__c= 10;// comment by kumud field cleanup activity
           // opp.Events__c= 10;// comment by kumud field cleanup activity
            //opp.of_Transactions__c= 10;// comment by kumud field cleanup activity
            opp.of_Leads_Purchased__c= 10;
            opp.Per_Registration_Fee__c= 10;
            /*opp.Per_Event_Fee__c= 10;
            opp.Per_Transaction_Fee__c= 10;
            opp.Price_per_lead__c= 10;
            opp.of_Free_Registrations__c= 10;
            opp.of_Free_Events__c= 10;
            opp.of_Free_Transactions__c= 10;*/ // comment by kumud field cleanup activity
            opp.of_Complimentary_Leads__c= 10;


            test.startTest();
            insert opp;
           
            List<Product2> prodList = new List<Product2>();
            
            Product2 prd1 = new Product2 (Name='Convenience Fee', Family='CrowdCompass', Description='Test Product Entry 1',productCode = 'Prepayment - Events Fee',isActive = true);
            Product2 prd2 = new Product2 (Name='Maintenance Fee', Family='Event', Description='Test Product Entry 1',productCode = 'Prepayment - Events Fee',isActive = true);
            Product2 prd3 = new Product2 (Name='Discount', Family='CrowdCompass' ,Description='Test Product Entry 1',productCode = 'Prepayment - Events Fee',isActive = true);
            Product2 prd4 = new Product2 (Name='Prepayment - Events Fee', Family='Prepayment - Events Fee' ,Description='Test Product Entry 1',productCode = 'Prepayment - Events Fee',isActive = true);
            
            prodList.add(prd1);
            prodList.add(prd2);
            prodList.add(prd3);
            prodList.add(prd4);
            insert prodList;
           
            List<PricebookEntry> entryList = new List<PricebookEntry>();
            
            PricebookEntry standPriceBook1 = new PricebookEntry();
            standPriceBook1.Product2ID=prodList[0].Id;
            standPriceBook1.Pricebook2ID=Test.getStandardPricebookId();
            standPriceBook1.UnitPrice=50;
            standPriceBook1.isActive=true;
            
            PricebookEntry standPriceBook2 = new PricebookEntry();
            standPriceBook2.Product2ID=prodList[1].Id;
            standPriceBook2.Pricebook2ID=Test.getStandardPricebookId();
            standPriceBook2.UnitPrice=50;
            standPriceBook2.isActive=true;
            
            PricebookEntry standPriceBook3 = new PricebookEntry();
            standPriceBook3.Product2ID=prodList[2].Id;
            standPriceBook3.Pricebook2ID=Test.getStandardPricebookId();
            standPriceBook3.UnitPrice=50;
            standPriceBook3.isActive=true;
            
            PricebookEntry standPriceBook4 = new PricebookEntry();
            standPriceBook4.Product2ID=prodList[3].Id;
            standPriceBook4.Pricebook2ID=Test.getStandardPricebookId();
            standPriceBook4.UnitPrice=50;
            standPriceBook4.isActive=true;
            
            entryList.add(standPriceBook1);
            entryList.add(standPriceBook2);
            entryList.add(standPriceBook3);
            entryList.add(standPriceBook4);
            
            insert entryList;
            
            OpportunityLineItemToSKUs.MoveItemstoSKUs(opp.Id);

            test.stopTest();
        
        }
        
    }
   

}