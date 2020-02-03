@isTest
public class ChatterPostNotificationTest 
{
    static testMethod void testMethod1()
    {
        Profile p = [SELECT Name FROM Profile WHERE Name = 'System Administrator']; 
        
        User user1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                              EmailEncodingKey='UTF-8', FirstName='Sherlin', LastName='Lauren', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = p.Id, 
                              TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtest@testorg.com');
        insert user1;
        
        User user2 = new User(Alias = 'standt', Email='standarduser1@testorg.com', 
                              EmailEncodingKey='UTF-8', FirstName='Daniel', LastName='Shregg', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = p.Id, 
                              TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtest1@testorg.com');
        insert user2;
        
        Account acc = new Account(Name='Test Account');
        Acc.BillingCountryCode='US';
        Acc.BillingState='TX';
        Acc.BillingStateCode ='TX';
        insert acc;
        
        Contact con = new Contact(LastName = 'Test Contact',AccountId = acc.Id);
        insert con;
        
        AccountTeamMemberRoles__c atms = new AccountTeamMemberRoles__c();
        atms.Name = 'AM - Event Cloud';
        insert atms;
        
        MobileAppNotificationUser__c users = new MobileAppNotificationUser__c();
        users.Name = 'Test User';
        users.Type__c = 'MobileApp';
        users.Id__c = user1.Id;
        insert users;
        
        AccountTeamMember atm = new AccountTeamMember();
        atm.AccountId = acc.Id;
        atm.TeamMemberRole = 'AM - Event Cloud';
        atm.UserId = user1.Id; 
        insert atm;
        
        Mobile_Card__c mobileCard = new Mobile_Card__c();
        mobileCard.Name = 'Test Mobile App 1';
        mobileCard.Oversold__c = true;
        mobileCard.Contract_Account_New__c = acc.Id;
        insert mobileCard;
        
        Mobile_Card__c mobileCard1 = new Mobile_Card__c();
        mobileCard1.Name = 'Test Mobile App 2';
        mobileCard1.Oversold__c = true;
        insert mobileCard1;
        
    }
    
    static testMethod void testMethod3()
    {
        Profile p = [SELECT Name FROM Profile WHERE Name = 'System Administrator']; 
        
        User user1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                              EmailEncodingKey='UTF-8', FirstName='Sherlin', LastName='Lauren', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = p.Id, 
                              TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtest@testorg.com');
        insert user1;
        
        User user2 = new User(Alias = 'standt', Email='standarduser1@testorg.com', 
                              EmailEncodingKey='UTF-8', FirstName='Daniel', LastName='Shregg', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = p.Id, 
                              TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtest1@testorg.com');
        insert user2;
        
        Account acc = new Account(Name='Test Account');
        acc.BillingCountryCode='US';
        acc.BillingState='TX';
        insert acc;
        
        Contact con = new Contact(LastName = 'Test Contact',AccountId = acc.Id);
        insert con;
        
        AccountTeamMemberRoles__c atms = new AccountTeamMemberRoles__c();
        atms.Name = 'AM - Event Cloud';
        insert atms;
        
        MobileAppNotificationUser__c users = new MobileAppNotificationUser__c();
        users.Name = 'Test User';
        users.Type__c = 'MobileApp';
        users.Id__c = user1.Id;
        insert users;
        
        AccountTeamMember atm = new AccountTeamMember();
        atm.AccountId = acc.Id;
        atm.TeamMemberRole = 'AM - Event Cloud';
        atm.UserId = user1.Id; 
        insert atm;
        
        Mobile_Card__c mobileCard1 = new Mobile_Card__c();
        mobileCard1.Name = 'Test Mobile App 2';
        mobileCard1.Oversold__c = true;
        insert mobileCard1;
    }
    
    static testMethod void testMethod4()
    {
        Profile p = [SELECT Name FROM Profile WHERE Name = 'System Administrator']; 
        
        User user1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                              EmailEncodingKey='UTF-8', FirstName='Sherlin', LastName='Lauren', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = p.Id, 
                              TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtest@testorg.com');
        insert user1;
        
        User user2 = new User(Alias = 'standt', Email='standarduser1@testorg.com', 
                              EmailEncodingKey='UTF-8', FirstName='Daniel', LastName='Shregg', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = p.Id, 
                              TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtest1@testorg.com');
        insert user2;
        
        Account acc = new Account(Name='Test Account');
        acc.BillingCountryCode='US';
        acc.BillingState='TX';
        insert acc;
        
        Contact con = new Contact(LastName = 'Test Contact',AccountId = acc.Id);
        insert con;
        
        AccountTeamMemberRoles__c atms = new AccountTeamMemberRoles__c();
        atms.Name = 'AM - Event Cloud';
        insert atms;
        
        MobileAppNotificationUser__c users = new MobileAppNotificationUser__c();
        users.Name = 'Test User';
        users.Type__c = 'EB SB Project';
        users.Id__c = user1.Id;
        insert users;
        
        AccountTeamMember atm = new AccountTeamMember();
        atm.AccountId = acc.Id;
        atm.TeamMemberRole = 'AM - Event Cloud';
        atm.UserId = user1.Id; 
        insert atm;
        
        EB_SB_Builder__c instOfEB =  new EB_SB_Builder__c();
        instOfEB.Project__c = 'Event Builder';
        instOfEB.Project_Status__c = 'Information Pending';
        instOfEB.Project_Type_del__c = 'Demo Event';
        instOfEB.Project_Complexity__c = '1-Simple';
        instOfEB.Integration__c = 'Marketo';
        instOfEB.AccountCustom__c = acc.Id;
        instOfEB.Contact__c = con.id;
        instOfEB.Oversold__c = true;
        insert instOfEB;
    }
    
    //This method covering Survey_Invitation_Sent__c for Mobile App, EBSB Project and Case Object
    static testMethod void testMethod5()
    {
        Profile p = [SELECT Name FROM Profile WHERE Name = 'System Administrator']; 
        
        User user1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                              EmailEncodingKey='UTF-8', FirstName='Sherlin', LastName='Lauren', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = p.Id, 
                              TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtest@testorg.com');
        insert user1;
        
        User user2 = new User(Alias = 'standt', Email='standarduser1@testorg.com', 
                              EmailEncodingKey='UTF-8', FirstName='Daniel', LastName='Shregg', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = p.Id, 
                              TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtest1@testorg.com');
        insert user2;
        
        Account acc = new Account(Name='Test Account');
        acc.BillingCountryCode='US';
        acc.BillingState='TX';
        insert acc;
        
        Contact con = new Contact(LastName = 'Test Contact',AccountId = acc.Id,Last_Experiential_Survey_Invitation__c=system.today()+10/*,Profile_Name__c='temp profile'*/);
        insert con;
        
        AccountTeamMemberRoles__c atms = new AccountTeamMemberRoles__c();
        atms.Name = 'AM - Event Cloud';
        insert atms;
        
        MobileAppNotificationUser__c users = new MobileAppNotificationUser__c();
        users.Name = 'Test User';
        users.Type__c = 'MobileApp';
        users.Id__c = user1.Id;
        insert users;
        
        AccountTeamMember atm = new AccountTeamMember();
        atm.AccountId = acc.Id;
        atm.TeamMemberRole = 'AM - Event Cloud';
        atm.UserId = user1.Id; 
        insert atm;
        
        Mobile_Card__c mobileCard1 = new Mobile_Card__c();
        mobileCard1.Name = 'Test Mobile App 2';
        mobileCard1.Primary_Contact__c = con.Id;
        mobileCard1.Survey_Invitation_Sent__c = system.today();
        mobileCard1.Oversold__c = true;
        insert mobileCard1;
        
        mobileCard1.Survey_Invitation_Sent__c = system.today()+5;
        update mobileCard1;
        
        EB_SB_Builder__c instOfEB =  new EB_SB_Builder__c();
        instOfEB.Project__c = 'Event Builder';
        instOfEB.Project_Status__c = 'Information Pending';
        instOfEB.Project_Type_del__c = 'Demo Event';
        instOfEB.Project_Complexity__c = '1-Simple';
        instOfEB.Integration__c = 'Marketo';
        instOfEB.AccountCustom__c = acc.Id;
        instOfEB.Contact__c = con.id;
        instOfEB.Survey_Invitation_Sent__c = system.today();
        insert instOfEB;
        
        instOfEB.Survey_Invitation_Sent__c = system.today()+5;
        update instOfEB;
        
        Case caseObj = new Case();
        caseObj.Status = 'Open';
        caseObj.Minutesoncase__c = 30; 
        caseObj.OwnerId = userInfo.getUserId();
        caseObj.AccountId=acc.Id;
        caseObj.subject='Test Hosp Cloud Implementation Survey';
        caseObj.Origin ='Email';       
        caseObj.description='The details of Francisco De Asis Grageras response are below.Dear Francisco De Asis Gragera,Thank you for completing the Hosp Cloud Implementation Survey! We appreciate the time you spent to provide us with the contract details. Given below is a snaphot of the survey response. Respondent Information Survey Title: Hosp Cloud Implementation Survey Response Number: 50104104 Total Score: 0.00/0.00 Start Date: 01/09/2017 1:07 PM Completion Date: 01/09/2017 1:25 PM Response Information Question Answer Score Contract Type CSN Bundle 0.00 Please provide the Salesforce link to the Contract Signer https://cvent.my.salesforce.com/'+acc.Id+' 0.00 Bundle Type Single Property Bundle 0.00 Salesforce Account Link: https://cvent.my.salesforce.com/00100000008DBY3 0.00';
        caseObj.Survey_Invitation_Sent__c = system.today();
        caseObj.ContactId = con.Id;
        caseObj.Date_Closed__c = system.today();
        insert caseObj;
        
        caseObj.Survey_Invitation_Sent__c = system.today()+5;
        caseObj.status = 'Pending for Closure Confirmation';
        update caseObj;
        caseObj.Survey_Invitation_Sent__c = system.today()+10;
        caseObj.status = 'Closed';
        //update caseObj;
        System.debug(caseObj.Status);
        
    }
    
     static testMethod void testMethod6()
    {
        Profile p = [SELECT Name FROM Profile WHERE Name = 'System Administrator']; 
        
        User user1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                              EmailEncodingKey='UTF-8', FirstName='Sherlin', LastName='Lauren', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = p.Id, 
                              TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtest@testorg.com');
        insert user1;
        
        User user2 = new User(Alias = 'standt', Email='standarduser1@testorg.com', 
                              EmailEncodingKey='UTF-8', FirstName='Daniel', LastName='Shregg', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = p.Id, 
                              TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtest1@testorg.com');
        insert user2;
        
        Account acc = new Account(Name='Test Account');
        acc.BillingCountryCode='US';
        acc.BillingState='TX';
        insert acc;
        
        Contact con = new Contact(LastName = 'Test Contact',AccountId = acc.Id,Last_Experiential_Survey_Invitation__c=system.today()+10/*,Profile_Name__c='temp profile'*/);
        insert con;
        
        AccountTeamMemberRoles__c atms = new AccountTeamMemberRoles__c();
        atms.Name = 'AM - Event Cloud';
        insert atms;
        
        MobileAppNotificationUser__c users = new MobileAppNotificationUser__c();
        users.Name = 'Test User';
        users.Type__c = 'MobileApp';
        users.Id__c = user1.Id;
        insert users;
        
        AccountTeamMember atm = new AccountTeamMember();
        atm.AccountId = acc.Id;
        atm.TeamMemberRole = 'AM - Event Cloud';
        atm.UserId = user1.Id; 
        insert atm;
        
         Case caseObj = new Case();
        caseObj.Status = 'Open';
        caseObj.Minutesoncase__c = 30; 
        caseObj.OwnerId = userInfo.getUserId();
        caseObj.AccountId=acc.Id;
        caseObj.subject='Test Hosp Cloud Implementation Survey';
        caseObj.Origin ='Email';       
        caseObj.description='The details of Francisco De Asis Grageras response are below.Dear Francisco De Asis Gragera,Thank you for completing the Hosp Cloud Implementation Survey! We appreciate the time you spent to provide us with the contract details. Given below is a snaphot of the survey response. Respondent Information Survey Title: Hosp Cloud Implementation Survey Response Number: 50104104 Total Score: 0.00/0.00 Start Date: 01/09/2017 1:07 PM Completion Date: 01/09/2017 1:25 PM Response Information Question Answer Score Contract Type CSN Bundle 0.00 Please provide the Salesforce link to the Contract Signer https://cvent.my.salesforce.com/'+acc.Id+' 0.00 Bundle Type Single Property Bundle 0.00 Salesforce Account Link: https://cvent.my.salesforce.com/00100000008DBY3 0.00';
        insert caseObj;
        
        caseObj.Oversold__c = true;
        update caseObj;
    }
    
     static testMethod void testMethod7()
    {
        Profile p = [SELECT Name FROM Profile WHERE Name = 'System Administrator']; 
        
        User user1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                              EmailEncodingKey='UTF-8', FirstName='Sherlin', LastName='Lauren', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = p.Id, 
                              TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtest@testorg.com');
        insert user1;
        
        User user2 = new User(Alias = 'standt', Email='standarduser1@testorg.com', 
                              EmailEncodingKey='UTF-8', FirstName='Daniel', LastName='Shregg', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = p.Id, 
                              TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtest1@testorg.com');
        insert user2;
        
        Account acc = new Account(Name='Test Account');
        acc.BillingCountryCode='US';
        acc.BillingState='TX';
        insert acc;
        
        Contact con = new Contact(LastName = 'Test Contact',AccountId = acc.Id);
        insert con;
        
        AccountTeamMemberRoles__c atms = new AccountTeamMemberRoles__c();
        atms.Name = 'AM - Event Cloud';
        insert atms;
        
        MobileAppNotificationUser__c users = new MobileAppNotificationUser__c();
        users.Name = 'Test User';
        users.Type__c = 'EB SB Project';
        users.Id__c = user1.Id;
        insert users;
        
        AccountTeamMember atm = new AccountTeamMember();
        atm.AccountId = acc.Id;
        atm.TeamMemberRole = 'AM - Event Cloud';
        atm.UserId = user1.Id; 
        insert atm;
        
        Onboarding__c onboardingObj = new Onboarding__c();
        onboardingObj.Account_Name__c = acc.Id;
        onboardingObj.Oversold__c = true;
        insert onboardingObj;
        
        Bundle_Card__c bundleCard = new Bundle_Card__c();
        bundleCard.Account__c = acc.Id;
        bundleCard.Oversold__c = true;
        insert bundleCard;
    }
    
    static testMethod void testMethod8()
    {
        Profile p = [SELECT Name FROM Profile WHERE Name = 'System Administrator']; 
        
        User user1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                              EmailEncodingKey='UTF-8', FirstName='Sherlin', LastName='Lauren', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = p.Id, 
                              TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtest@testorg.com');
        insert user1;
        
        User user2 = new User(Alias = 'standt', Email='standarduser1@testorg.com', 
                              EmailEncodingKey='UTF-8', FirstName='Daniel', LastName='Shregg', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = p.Id, 
                              TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtest1@testorg.com');
        insert user2;
        
        Account acc = new Account(Name='Test Account');
        acc.BillingCountryCode='US';
        acc.BillingState='TX';
        insert acc;
        
        Contact con = new Contact(LastName = 'Test Contact',AccountId = acc.Id,Last_Experiential_Survey_Invitation__c=system.today()+10/*,Profile_Name__c='temp profile'*/);
        insert con;
        
        AccountTeamMemberRoles__c atms = new AccountTeamMemberRoles__c();
        atms.Name = 'AM - Event Cloud';
        insert atms;
        
        MobileAppNotificationUser__c users = new MobileAppNotificationUser__c();
        users.Name = 'Test User';
        users.Type__c = 'MobileApp';
        users.Id__c = user1.Id;
        insert users;
        
        AccountTeamMember atm = new AccountTeamMember();
        atm.AccountId = acc.Id;
        atm.TeamMemberRole = 'AM - Event Cloud';
        atm.UserId = user1.Id; 
        insert atm;
        
        Onboarding__c onboardingObj = new Onboarding__c();
        onboardingObj.Account_Name__c = acc.Id;
        insert onboardingObj;
        
        onboardingObj.Oversold__c = true;
        update onboardingObj;
        
        Bundle_Card__c bundleCard = new Bundle_Card__c();
        bundleCard.Account__c = acc.Id;
        insert bundleCard;
        
        bundleCard.Oversold__c = true;
        update bundleCard;
    }
    
}