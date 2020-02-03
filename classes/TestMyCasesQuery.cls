@Istest

private class TestMyCasesQuery {

public static Account instofAcc = new Account();
public static Contact instofCon =  new Contact();
    
@testsetup
static void createData(){
    
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
       
       
    Id recTypeCase  = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Event').getRecordTypeId();
    
    Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
    //Create a Test User
    User u = new User(Alias = 'testUX', Email='ggg@torg.com', 
    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
    LocaleSidKey='en_US', ProfileId = p.Id, 
    TimeZoneSidKey='America/Los_Angeles', UserName='deploymenttest@torg.com');
        
    System.RunAs(u) {
        Case c = new Case();
        c.recordTypeId = recTypeCase;
        c.Product_Type__c = 'Event Tool';
        c.Status = 'Open';
        c.Minutesoncase__c = 30; 
        c.ContactId = instOfCon.Id;
        c.OwnerId = u.Id;       
        insert c;
    }
    
}

public static testMethod void TestMyCasesQuery() {
       
       Profile p = [SELECT id, Name FROM Profile WHERE UserLicense.Name like '%Customer Community Login%' AND Name like '%Cvent Customer Community User%'] ;
       Contact c = [Select Id From Contact Limit 1 ];
       
       
       System.debug(' $$$$ Con $$$ ' +  instOfCon);
       User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
       EmailEncodingKey='UTF-8', FirstName = 'Test' , LastName='User', LanguageLocaleKey='en_US', 
       LocaleSidKey='en_US', ProfileId = p.Id, 
       TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtest@testorg.com',federationIdentifier='1233454',contactId =c.Id,CommunityNickname = 'testUser123');
       
       //Use the PageReference Apex class to instantiate a page
       PageReference pageRef = Page.Mycases;
       
       //In this case, the Visualforce page named 'Mycases' is the starting point of this test method. 
       Test.setCurrentPage(pageRef);
     
       //Instantiate and construct the controller class.
       system.runAs(u){
       
       MyCasesQuery controller = new MyCasesQuery();
       controller.getItems();
       controller.processRequests();
    }
       
   }
}