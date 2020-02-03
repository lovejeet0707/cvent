@Istest

private class TestLitmosAccessClass{

public static Account instofAcc = new Account();
public static Contact instofCon =  new Contact();

public static testMethod void TestfetchLitmosDetails() {

        Id rtTypeId = Schema.SobjectType.Account.getRecordTypeInfosByName().get('Biz A/c').getRecordTypeId();
    
        instofAcc = new Account();
        instofAcc.Name = 'Test';
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        instofAcc.RecordTypeId = rtTypeId ;
        insert instofAcc;
        
        instofCon =  new Contact();
        instOfCon.LastName = 'Test';
        instOfCon.AccountId = instofAcc.Id;
        insert instOfCon;
       
       Profile p = [SELECT id, Name FROM Profile WHERE UserLicense.Name like '%Customer Community Login%' AND Name like '%Cvent Customer Community User%'] ;
       
       
       User u = new User(Alias = 'standt', Email='fUsercventtest@testorg.com', 
       EmailEncodingKey='UTF-8', FirstName = 'Test' , LastName='User', LanguageLocaleKey='en_US', 
       LocaleSidKey='en_US', ProfileId = p.Id, 
       TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtest@testorg.com',federationIdentifier='ZPUBWZS8SG6',contactId =instOfCon.Id,CommunityNickname = 'testUser123');
       insert u;
       
     
       
       LitmosAccessClass controller = new LitmosAccessClass();
       controller.emailId='fUsercventtest@testorg.com';
       controller.fetchLitmosDetails();
       controller.giveLitmosAccess();
       controller.assignPermissionSet();
       controller.ReSyncLitmos();
       
       
   }
}