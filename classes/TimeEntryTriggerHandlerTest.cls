@isTest
public class TimeEntryTriggerHandlerTest 
{
    static testmethod void timeEntry()
    {
        Account acc = new Account(Name='Test Account');
        Acc.BillingCountryCode='US';
        Acc.BillingStateCode='TX';
        insert acc;
        
        Contact con = new Contact(LastName = 'Test Contact',AccountId = acc.Id);
        insert con;
        
        Mobile_Card__c mobileCard = new Mobile_Card__c();
        mobileCard.Name = 'Test Mobile App 1';
        mobileCard.Contract_Account_New__c = acc.Id;
        insert mobileCard;
        
        Case oCase = new Case();
        oCase.AccountId = acc.id;
        oCase.ContactId = con.id;
        oCase.Origin = 'test@test.com';
        oCase.Status = 'Open';
        oCase.Subject = 'Testing Subject';
        oCase.Description = 'Testing Description';
        oCase.Mobile_App__c = mobileCard.Id;
        insert oCase;
        
        Bundle_Card__c bundleCard = new Bundle_Card__c();
        bundleCard.Account__c = acc.Id;
        insert bundleCard;
        
        Bundle_Card_Item__c bundleCardItemObj = new Bundle_Card_Item__c();
        bundleCardItemObj.Bundle_Card__c = bundleCard.Id;
        insert bundleCardItemObj;
        
        WorkIt2__Timing__c timingObj1 = new WorkIt2__Timing__c();
        timingObj1.Mobile_App__c = mobileCard.Id;
        insert timingObj1;
        
        // create Time Entry record for the above Timing
        WorkIt2__Time_Entry__c timeEntryObj1 = new WorkIt2__Time_Entry__c();
        timeEntryObj1.WorkIt2__Timing__c = timingObj1.Id;
        timeEntryObj1.WorkIt2__Start__c = System.now().addHours(-10);
        timeEntryObj1.WorkIt2__Heartbeat__c = System.now().addHours(-9);
        insert timeEntryObj1;
        
        WorkIt2__Timing__c timingObj2 = new WorkIt2__Timing__c();
        timingObj2.WorkIt2__Case__c = oCase.Id;
        insert timingObj2;
        
        // create Time Entry record for the above Timing
        WorkIt2__Time_Entry__c timeEntryObj2 = new WorkIt2__Time_Entry__c();
        timeEntryObj2.WorkIt2__Timing__c = timingObj2.Id;
        timeEntryObj2.WorkIt2__Start__c = System.now().addHours(-10);
        timeEntryObj2.WorkIt2__Heartbeat__c = System.now().addHours(-9);
        insert timeEntryObj2;
        
        WorkIt2__Timing__c timingObj3 = new WorkIt2__Timing__c();
        timingObj3.BundleCard__c = bundleCard.Id;
        insert timingObj3;
        
        // create Time Entry record for the above Timing
        WorkIt2__Time_Entry__c timeEntryObj3 = new WorkIt2__Time_Entry__c();
        timeEntryObj3.WorkIt2__Timing__c = timingObj3.Id;
        timeEntryObj3.WorkIt2__Start__c = System.now().addHours(-10);
        timeEntryObj3.WorkIt2__Heartbeat__c = System.now().addHours(-9);
        insert timeEntryObj3;
        
        WorkIt2__Timing__c timingObj4 = new WorkIt2__Timing__c();
        timingObj4.BundleCardItem__c = bundleCardItemObj.Id;
        insert timingObj4;
        
        // create Time Entry record for the above Timing
        WorkIt2__Time_Entry__c timeEntryObj4 = new WorkIt2__Time_Entry__c();
        timeEntryObj4.WorkIt2__Timing__c = timingObj4.Id;
        timeEntryObj4.WorkIt2__Start__c = System.now().addHours(-10);
        timeEntryObj4.WorkIt2__Heartbeat__c = System.now().addHours(-9);
        insert timeEntryObj4;
        
    }
}