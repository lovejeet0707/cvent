@isTest
public class SandboxPostCreationAndRefreshScript_Test {
    public final String profileIdToUpdate = [Select Id from Profile where Name = 'System Administrator' LIMIT 1].Id;
    
    public static @isTest void runTest(){
        User testUser = new user(firstName = 'User',Lastname = 'Post Refresh (Sops)',Email ='testpostrefresh@cvent.com.invalid',Alias= 'tpos',userName = 'testpostrefresh=cvent.com@example.com.ref',EmailEncodingKey='UTF-8',LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = [Select Id from Profile where Name = 'System Administrator' LIMIT 1].Id, FederationIdentifier = 'testpostrefresh=cvent.com@example.com',TimeZoneSidKey='America/Los_Angeles');
        insert testUser;
            
        SandboxPostCreationAndRefreshScript refreshScript = new SandboxPostCreationAndRefreshScript();
        Test.testSandboxPostCopyScript(refreshScript, UserInfo.getOrganizationId(), '00Dp00000000hjM', 'sandbox2');
    }
}