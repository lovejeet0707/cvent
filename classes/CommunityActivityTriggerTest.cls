@isTest
private class CommunityActivityTriggerTest{
    static testMethod void myUnitTest() {
        
        //Insert Account......
        Account acctA1 = new Account(Name = 'AAA-Account');
        insert acctA1;
        //Insert Contact..........
        Contact instContact = new Contact();
        instContact.LastName = 'Test';
        instContact.AccountId = acctA1.Id;
        instContact.CT_Contact_Status__c= 'Open Opportunity';
        instContact.Event_Contact_Status__c = 'Open Opportunity';
        instContact.TM_Contact_Status__c = 'Open Opportunity';
        instContact.LeadSource = 'WEB-Chat (CrowdCompass)';
        instContact.Mood_Level__c = 2;
        instContact.Purchasing_Interest_CSNP__c = '4 - Very interested';
        instContact.Purchasing_Interest_PK__c='3 - Somewhat interested';
        instContact.Attended__c = 'CSG';
        instContact.MailingCountryCode = 'IN';
        insert instContact;

        HL_Community_Activity__c HLObject = new HL_Community_Activity__c();
        HLObject.Account__c = acctA1.Id;
        HLObject.Activity_Type__c= 'Test Type';
        HLObject.Activity_Date__c= system.now();
        HLObject.Contact__c= instContact.Id;
        HLObject.Description__c= 'Test Description';
        insert HLObject;
    }
}