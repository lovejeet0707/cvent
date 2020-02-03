@istest
public class CustomerRoleTriggerTest{

   
   static testmethod void testCustomerRole(){
   
        //Inserting User...............
        Profile p = [SELECT Id FROM Profile WHERE Name='Finance - Management']; 

        USerrole[] testroleId=[select id from userRole where name ='AM (Event)' OR name ='Pre Sales - Special Projects' limit 2];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='DeploymentUser', LanguageLocaleKey='en_US', FirstName='Testing',
        LocaleSidKey='en_US', ProfileId = p.Id, userRoleId=testroleId[0].id,
        TimeZoneSidKey='America/Los_Angeles', UserName='Test'+'deploymentuser@cvent.com');
        
        Id custRectypeId = Schema.SObjectType.Contact_Role__c.getRecordTypeInfosByName().get('Customer Role').getRecordTypeId();
        
        
        
            system.runAs(u){
                
                Account acc = new Account();
                acc.Name = 'Test Account 1';
                acc.Supplier_Type__c = 'Venue';
                acc.Account_Status__c = 'Active';
                acc.BillingCountry='MX';
                insert acc;
            
                Contact con = new Contact();
                con.AccountId = acc.Id; 
                con.LastName = 'Contact 1';
                con.Product_Desired__c  = 'Event';
                insert con;
    
            
                test.startTest();
                    
                    system.runAs(u){
                        
                        AdvocateHub__AdvocacyActivity__c cHub = new AdvocateHub__AdvocacyActivity__c();
                        cHub.AdvocateHub__Contact__c = con.Id;
                        cHub.AdvocateHub__ExternalId__c = 22456;
                        insert cHub;
                        
                        Case c = new Case();
                        c.Product_Type__c = 'Event Tool';
                        c.ContactId = con.Id;
                        c.Subject = 'Test Subject';
                        c.Description = 'Test Desc';
                        c.Status = 'Open';
                        c.Minutesoncase__c = 30; 
                        insert c;
                        
                        Task t = new Task();
                        t.Subject = 'test';
                        t.Whoid = con.Id;
                        t.Priority = 'Normal';
                        t.ActivityDate = System.Today();
                        insert t;
                        
                        Invoicing_Details__c inv = new Invoicing_Details__c();
                        inv.Billing_POC__c = con.Id;
                        inv.Payment_Mode__c = 'Cash';
                        inv.Payment_Terms__c = 'Net 15';
                        insert inv;
                        
                        
                        Contact_Role__c cr = new Contact_Role__c();
                        cr.RecordTypeId= custRectypeId;
                        cr.Contact__c = con.Id;
                        cr.Account_Customer_Role__c = acc.Id;
                        cr.Product__c = 'Event';
                        cr.Last_Login_Date__c = System.today() - 50;
                        cr.User_Sub_Role__c = 'Community Portal Administrator';
                       
                        insert cr;
                        
                        update cr;
                    }
                    SchedulableContext sc;
                    ContactRoleSyncBatch cBatch = new ContactRoleSyncBatch();
                    Database.executeBatch(cBatch,100);
                    cBatch.execute(sc);
                    
                test.stopTest();
            }
   
    } 
        
    static testmethod void testBuyerRole(){

        //Inserting User...............
        Profile p = [SELECT Id FROM Profile WHERE Name='Finance - Management']; 

        USerrole[] testroleId=[select id from userRole where name ='AM (Event)' OR name ='Pre Sales - Special Projects' limit 2];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='DeploymentUser', LanguageLocaleKey='en_US', FirstName='Testing',
        LocaleSidKey='en_US', ProfileId = p.Id, userRoleId=testroleId[0].id,
        TimeZoneSidKey='America/Los_Angeles', UserName='Test'+'deploymentuser@cvent.com');
        
        Id buyerRecTypeId = Schema.SObjectType.Contact_Role__c.getRecordTypeInfosByName().get('Buyer Role').getRecordTypeId();
        
        
        
            system.runAs(u){
                
                
                Account acc = new Account();
                acc.Name = 'Test Account 1';
                acc.Supplier_Type__c = 'Venue';
                acc.Account_Status__c = 'Active';
                acc.BillingCountry='MX';
                insert acc;
            
                Contact con = new Contact();
                con.AccountId = acc.Id; 
                con.LastName = 'Contact 1';
                con.Product_Desired__c  = 'Event';
                insert con;

        
                test.startTest();
                
                AdvocateHub__AdvocacyActivity__c cHub = new AdvocateHub__AdvocacyActivity__c();
                cHub.AdvocateHub__Contact__c = con.Id;
                cHub.AdvocateHub__ExternalId__c = 22456;
                insert cHub;
                
                Case c = new Case();
                c.Product_Type__c = 'Event Tool';
                c.ContactId = con.Id;
                c.Subject = 'Test Subject';
                c.Description = 'Test Desc';
                c.Status = 'Open';
                c.Minutesoncase__c = 30; 
                insert c;
                
                Task t = new Task();
                t.Subject = 'test';
                t.Whoid = con.Id;
                t.Priority = 'Normal';
                t.ActivityDate = System.Today();
                insert t;
                
                Invoicing_Details__c inv = new Invoicing_Details__c();
                inv.Billing_POC__c = con.Id;
                inv.Payment_Mode__c = 'Cash';
                inv.Payment_Terms__c = 'Net 15';
                insert inv;
                
                Contact_Role__c Oldcr = new Contact_Role__c();
                Oldcr.RecordTypeId= buyerRecTypeId;
                Oldcr.Contact__c = con.Id;
                Oldcr.Account_Buyer_Role__c = acc.Id;
                insert oldcr;

                Contact_Role__c cr = new Contact_Role__c();
                cr.RecordTypeId= buyerRecTypeId;
                cr.Contact__c = con.Id;
                cr.Account_Buyer_Role__c = acc.Id;
                insert cr;
                    

                test.stopTest();
            }
   
    }  

    
    static testmethod void testBuyerRoleDuplicates(){

        //Inserting User...............
        Profile p = [SELECT Id FROM Profile WHERE Name='Finance - Management']; 

        USerrole[] testroleId=[select id from userRole where name ='AM (Event)' OR name ='Pre Sales - Special Projects' limit 2];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='DeploymentUser', LanguageLocaleKey='en_US', FirstName='Testing',
        LocaleSidKey='en_US', ProfileId = p.Id, userRoleId=testroleId[0].id,
        TimeZoneSidKey='America/Los_Angeles', UserName='Test'+'deploymentuser@cvent.com');
        
        Id custRectypeId = Schema.SObjectType.Contact_Role__c.getRecordTypeInfosByName().get('Customer Role').getRecordTypeId();
        
        
        
            system.runAs(u){
                
                
                Account acc = new Account();
                acc.Name = 'Test Account 1';
                acc.Supplier_Type__c = 'Venue';
                acc.Account_Status__c = 'Active';
                acc.BillingCountry='MX';
                insert acc;
            
                Contact con = new Contact();
                con.AccountId = acc.Id; 
                con.LastName = 'Contact 1';
                con.Product_Desired__c  = 'Event';
                insert con;

            
                test.startTest();
                
                Case c = new Case();
                c.Product_Type__c = 'Event Tool';
                c.ContactId = con.Id;
                c.Subject = 'Test Subject';
                c.Description = 'Test Desc';
                c.Status = 'Open';
                c.Minutesoncase__c = 30; 
                insert c;


                List<Contact_Role__c> oldList= new List<Contact_Role__c>();

                Contact_Role__c Oldcr = new Contact_Role__c();
                Oldcr.RecordTypeId= custRectypeId;
                Oldcr.Contact__c = con.Id;
                Oldcr.Account_Customer_Role__c = acc.Id;
                Oldcr.Product__c = 'Event';
                Oldcr.Last_Login_Date__c = System.today() - 50;
                Oldcr.User_Sub_Role__c = 'Community Portal Administrator';

                Contact_Role__c Oldcr2 = new Contact_Role__c();
                Oldcr2.RecordTypeId= custRectypeId;
                Oldcr2.Contact__c = con.Id;
                Oldcr2.Account_Customer_Role__c = acc.Id;
                Oldcr2.Product__c = 'Event';
                Oldcr2.Last_Login_Date__c = System.today() - 50;
                Oldcr2.User_Sub_Role__c = 'Community Portal Administrator';
                
                oldList.add(Oldcr);
                oldList.add(Oldcr2);

                insert oldList;
                
                Contact_Role__c cr = new Contact_Role__c();
                cr.RecordTypeId= custRectypeId;
                cr.Contact__c = con.Id;
                cr.Account_Customer_Role__c = acc.Id;
                cr.Product__c = 'Event';
                cr.Last_Login_Date__c = System.today() - 50;
                cr.User_Sub_Role__c = 'Community Portal Administrator';

                insert cr;
                    

                test.stopTest();
            }
   
    }
}