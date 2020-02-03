@isTest
public class ContactSupportClsTest{
    static testMethod void unitTest(){
        Community_Country_ISD_Codes__c cc = new Community_Country_ISD_Codes__c();
        cc.Name='IN';
        cc.Country_Name__c='India';
        cc.ISD_Code__c='91';
        insert cc;
        
        Account oAccount = new Account();
        oAccount.Name = 'Lanyon Master';
        insert oAccount;
        
        Contact oContact = new Contact();
        oContact.AccountID = oAccount.id;
        oContact.FirstName = 'Fname';
        oContact.LastName = 'Lname';  
        oContact.Email = 'test@test.com';
        insert oContact;
        
        Id caseRecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Case' LIMIT 1].Id;
        Case oCase = new Case();
        oCase.AccountId = oAccount.id;
        oCase.ContactId = oContact.id;
        oCase.Origin = 'test@test.com';
        oCase.Status = 'Closed';
        oCase.Subject = 'Test Subject';
        oCase.RecordTypeId = caseRecordTypeId;
        insert oCase;
        
        PageReference pageRef = Page.ContactSupport;
        pageRef.getParameters().put('id', String.valueOf(oCase.Id));
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(oCase);
        ContactSupportCls contactSupportClass = new ContactSupportCls(sc);
        //Test.startTest();
        List<SelectOption> options = contactSupportClass.getCountryCode();
        //Test.stopTest();
        contactSupportClass.selectedname = 'IN';
        contactSupportClass.phoneNumber = '9716549377';
        contactSupportClass.selectedLanguage = 'English';
        contactSupportClass.search();
        contactSupportClass.requestCall();
        
 
    }
}