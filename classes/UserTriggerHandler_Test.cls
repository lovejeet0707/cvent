@isTest
Public Class UserTriggerHandler_Test{
// ===============================
// AUTHOR     : Shanu Aggarwal    
// CREATED DATE     : 02/03/2016
// PURPOSE     :  To Test Handler
// TRIGGER :     UserTrigger
// CLASS : UserTriggerHandler
// SPECIAL NOTES:
// ===============================
// Change History:
// HSR : 30th Jan 2018 : Added test method for "updateInactiveuserFields"/"removePackageLicense" method in "UserTriggerHandler"
//==================================
    @testsetup
    public static void createUserHistory(){
    //Inserting Quota Type
    Quota__c qType = new Quota__c();
    qType.Name = 'NBB Quota';
    qType.Comments__c = 'Test Comments';
    
    Insert qType;
    
    Quota_User_History__c qHistory = new Quota_User_History__c();
    qHistory.Effective_Date__c =  Date.Today();
    qHistory.Is_Current__c = true;
                    
    qHistory.User__c = UserInfo.getUserId(); 
    qHistory.Title__c = 'Salesforce Developer';
    qHistory.Role__c =  'Sales Dev';
    
    insert qHistory;
    }
    public static testmethod void BeforeUpdateTest(){
        
        User u = [ Select Title from User Where Id =:UserInfo.getUserId()];
        u.Title= 'Sr. Salesforce Developer' ;
        Update u;
    }
    //Test method for "removePackageLicense" & "updateInactiveuserFields" methods
    public static testmethod void removePackageLicenseTest(){
    User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
    User userRec;
    System.runAs ( thisUser ) {
        Account acc = new Account(Name='Test Account');
        acc.BillingCountry = 'IN';
        insert acc;
        Contact con = new Contact(LastName='Test',Product_Desired__c='Event',AccountId=acc.Id);
        insert con;
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id;
        Id profileId1 = [SELECT Id FROM Profile WHERE Name = 'Custom:High Volume Community Portal User'].Id;
        //Fetching User from the TestUtil Class......
        userRec = TestUtil.createUser(profileId);
       // userRec.ContactId = con.id;
        userRec.FederationIdentifier = 'F8ECWVJWT98';
        insert userRec;
        //Deactivating User....
        userRec.IsActive = False;}
        update userRec;
    }   
     public static testmethod void profileChange()
     {  User instUsr = new User();
          Account acc = new Account(Name='Test Account');
        acc.BillingCountry = 'IN';
        insert acc;
        
        Contact c = new Contact();
        c.LastName = 'Test Contact User';
        c.AccountId = acc.Id;
        insert c;
         
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id;
      //  Profile []p = [SELECT id, Name FROM Profile WHERE UserLicense.Name like '%Customer Community Login%' AND Name like '%Cvent Customer Community User%'] ;
        //Fetching User from the TestUtil Class......
      //  User userRec = TestUtil.createUser(p[0].Id);
      //  userRec.Account_Id_Dev__c = acc.Id;
       // userRec.ContactId = c.Id;
       // userRec.federationIdentifier = 'tmartin';
        //insert userRec;
       // userRec.ProfileId = profileId;
        //update userRec;
        Id profileId1 = [SELECT Id FROM Profile WHERE Name = 'Custom:High Volume Community Portal User'].Id;
        Contact con = new Contact(LastName='Test',Product_Desired__c='Event',AccountId=acc.Id);
        insert con;
        Profile p = [SELECT id FROM profile WHERE name='Cvent Customer Community User'];
        instUsr = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p.Id,
                timezonesidkey='America/Los_Angeles', username='test123@noemail.com',ContactId=con.id);
        insert instUsr;
        instUsr.profileid=profileId1;
        instUsr = [SELECT Id FROM USER WHERE Id=:instUsr.Id AND isPortalEnabled =true];
        
        
        Account acc1 = new Account(Name='Test Account');
       acc1.BillingCountry = 'IN';
       insert acc1;

       Contact c1 = new Contact();
       c1.LastName = 'Test Contact User';
       c1.AccountId = acc1.Id;
       insert c1;

       Id mobileCardRTId = Schema.SObjectType.Mobile_Card__c.getRecordTypeInfosByName().get('Mobile - Onboarding Lite').getRecordTypeId();
       Mobile_Card__c mobileCard = new Mobile_Card__c();
       mobileCard.Name = 'Test Mobile App 1';
       mobileCard.RecordTypeId = mobileCardRTId;
       mobileCard.Oversold__c = true;
       mobileCard.Event_Start_Date__c = System.today();
       mobileCard.Event_End_Date__c = System.today() + 10;
       mobileCard.Contract_Account_New__c = acc1.Id;
       insert mobileCard;
       
       instUsr.IsActive=False;
       //update instUsr;
       
    }
}