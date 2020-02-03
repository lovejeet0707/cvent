// ===============================
// AUTHOR     : Shanu Aggarwal    
// CREATED DATE     : 04/26/2016
// PURPOSE     :  JIT handler
// CLASS :   CventCommunityJITHandler
// SPECIAL NOTES:
// ===============================
@istest
public class CventCommunityJITHandlerTest{

     static testmethod void UserWithFederationTest(){
     
     
        Account acc= new Account();
        acc.Name = 'Cvent Test';
        Insert acc;
        
        Contact c = new Contact();
        c.LastName = 'Test Con';
        c.AccountId = acc.Id;
        insert c;
        
        User runningUser = [Select Id From User Where Id =: UserInfo.getUserId()];
        
        
        Profile []p = [SELECT id, Name FROM Profile WHERE UserLicense.Name like '%Customer Community Login%' AND Name like '%Cvent Customer Community User%'] ;

        System.assert(p.size()>0, 'Portal Profile Not Found');
        
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', FirstName = 'Test' , LastName='User', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p[0].Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='fUsercventtest@testorg.com',federationIdentifier='1233454',contactId =c.Id,CommunityNickname = 'testUser123');
        
        system.runAs(runningUser){
            insert u;

        Map<String, String> attributes = new Map<String, String>();
        attributes.put('User.Username' , 'fUsercventtest@testorg.com');
        attributes.put('User.FirstName' , 'Test');
        attributes.put('User.LastName' , 'User');
        attributes.put('User.Email' , 'standarduser@testorg.com');

        
    
        CventCommunityJITHandler cHandler = new CventCommunityJITHandler();
        cHandler.createUser(null,null,null,'1233454',attributes,null);
        User createdUser = cHandler.createUser(null,null,null,'1233454',attributes,null);
        
        cHandler.updateUser(createdUser.Id,null,null,null,'1233454',attributes,null);        
        
       }
    }
    
    static testmethod void UserWithoutFederationTest(){
        
        Account acc= new Account();
        acc.Name = 'Cvent Test';
        Insert acc;
        
        User runningUser = [Select Id From User Where Id =: UserInfo.getUserId()];
        
        
        Profile p = [SELECT Name FROM Profile WHERE Name = 'System Administrator']; 
        
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', FirstName = 'Test' , LastName='User', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, CompanyName = 'Cvent Test',
        TimeZoneSidKey='America/Los_Angeles', UserName='testuser@cvent.com',federationIdentifier='445666');

        system.runAs(runningUser){
            insert u;
        }

    
        Map<String, String> attributes = new Map<String, String>();
        attributes.put('User.Username' , 'fUsercventtest@testorg.com');
        attributes.put('User.FirstName' , 'Test');
        attributes.put('User.LastName' , 'User');
        attributes.put('User.Email' , 'standarduser@testorg.com');
        attributes.put('User.CompanyName' , 'Cvent Test');
    
        CventCommunityJITHandler cHandler = new CventCommunityJITHandler();
        cHandler.createUser('01p17000000FQiU','01p17000000FQiU','01p17000000FQiU','1233454',attributes,null);

    }
    
}