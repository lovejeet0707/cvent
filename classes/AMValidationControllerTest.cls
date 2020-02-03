// ===============================
// Name             : AMValidationControllerTest
// AUTHOR           : Shanu Aggarwal    
// CREATED DATE     : 20 Sep 2016
// CLASS            : AMValidationController
// SPECIAL NOTES    :
// ===============================
@istest
public class AMValidationControllerTest {
    
    
    public static testmethod void testvalidationController(){        
        
        //Inserting User...............
        Profile p = [SELECT Id FROM Profile WHERE Name='Finance - Management']; 
        
        USerrole[] testroleId=[select id from userRole where name ='AM (Event)' limit 1];
        USerrole[] testrole2Id=[select id from userRole where name = '' limit 1];
        
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Sops', LanguageLocaleKey='en_US', FirstName='TestUser',
                          LocaleSidKey='en_US', ProfileId = p.Id, userRoleId=testroleId[0].id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='Test'+'deploymentuser@cvent.com');
        
        
        system.runAs(u){            
            Account acc= new Account();
            acc.Name = 'Test Account 1';
            acc.Supplier_Type__c = 'Venue';
            acc.AM_Event__c = 'TestUser Sops';
            acc.Account_Status__c = 'Active';
            acc.BillingCountryCode='US';
            acc.BillingStateCode = 'NY';
            insert acc;
            
            Contact con = new Contact();
            con.AccountId = acc.Id; 
            con.LastName = 'Contact 1';
            con.Product_Desired__c  = 'CrowdCompass';
            insert con;
            
            Contact con2 = new Contact();
            con2.AccountId = acc.Id; 
            con2.LastName = 'Contact 1';
            con2.Product_Desired__c  = 'CrowdCompass';
            insert con2;
            
            Contact_Role__c cr = new Contact_Role__c();
            cr.RecordTypeId = Schema.SObjectType.Contact_Role__c.getRecordTypeInfosByName().get('Buyer Role').getRecordTypeId();
            cr.Contact__c = con.Id;
            cr.Account_Buyer_Role__c = acc.Id;
            
            insert cr;
            
            Contact_Role__c cr3 = new Contact_Role__c();
            cr3.RecordTypeId = Schema.SObjectType.Contact_Role__c.getRecordTypeInfosByName().get('Buyer Role').getRecordTypeId();
            cr3.Contact__c = con2.Id;
            cr3.Account_Buyer_Role__c = acc.Id;
           
            insert cr3;
            
            PageReference pgRef = Page.AMValidation;
            pgRef.getParameters().put('id',acc.id);
            Test.setCurrentPageReference(pgRef);
            
            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(acc);
            Map <Id,Contact_Role__c> selectedMap = new Map <Id,Contact_Role__c>();
            selectedMap.put(cr.Id, cr);
            AMValidationController aController = new AMValidationController(stdCtrl);
            aController.selectedcontactRoleMap = selectedMap;
            aController.getContactRoles();
            aController.pageNumber = 1;
            aController.ValidateSelected();
            aController.noOfRecords = 10;
            aController.ValidateAll();
            aController.pageNumber = 1;
            
            PageReference pgRef1 = Page.validateBuyerRole;
            pgRef1.getParameters().put('id',con.id);
            Test.setCurrentPageReference(pgRef1);
            
            ApexPages.StandardController stdCtrl1 = new ApexPages.StandardController(con);
            validateBuyerRoleOnContact obj = new validateBuyerRoleOnContact(stdCtrl1);
            obj.validateContact();
            obj.callNo();
            obj.editBuyerRole();            
            obj.selectedcontactRoleMap = selectedMap;
            obj.getContactRoles();
            obj.pageNumber = 1;
            obj.ValidateSelected();
            obj.noOfRecords = 10;
            obj.ValidateAll();
            obj.pageNumber = 1;
            validateBuyerRoleOnContact.WrapperContactRoleWrapper testWrap=new validateBuyerRoleOnContact.WrapperContactRoleWrapper(cr,false); 

        }
    }
}