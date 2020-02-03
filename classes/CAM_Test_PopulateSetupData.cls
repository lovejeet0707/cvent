@isTest

public class CAM_Test_PopulateSetupData {
    public static User pm;
    public static User pm_manager;

    @future public static void populateSetupData() {
        //User Role
        UserRole ur = [SELECT Id FROM UserRole WHERE Name = 'Administrator'];

        //Profile
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator']; 
        
        //User
        User u2 = new User(
                            LastName = 'Test User 2',
                            CommunityNickname = 'Test User 2',
                            Username = 'testuser2@cvent.com',
                            email = 'testuser2@cvent.com',
                            alias = 'test2',
                            SenderEmail = 'emre.yenier@cvent.com',
                            SenderName = 'Test User 2',
                            TimeZoneSidKey = 'America/Los_Angeles',
                            EmailEncodingKey = 'UTF-8',
                            LanguageLocaleKey = 'en_US',
                            LocaleSidKey = 'en_US',
                            UserRoleId = ur.id,
                            ProfileId = pf.id,
                            Validation_Bypass__c = TRUE
                        );
        insert u2;
        pm_manager = u2;

        User u1 = new User(
                            LastName = 'Test User 1',
                            CommunityNickname = 'Test User 1',
                            Username = 'testuser1@cvent.com',
                            email = 'testuser1@cvent.com',
                            alias = 'test1',
                            SenderEmail = 'emre.yenier@cvent.com',
                            SenderName = 'Test User 1',
                            TimeZoneSidKey = 'America/Los_Angeles',
                            EmailEncodingKey = 'UTF-8',
                            LanguageLocaleKey = 'en_US',
                            LocaleSidKey = 'en_US',
                            UserRoleId = ur.id,
                            ProfileId = pf.id,
                            ManagerId = u2.id,
                            Validation_Bypass__c = TRUE
                        );
        insert u1;
        pm = u1;

    }

    /*
    public static void setPMUser(String i){
        if (pm_manager == null || pm == null ){ 
            populateSetupData();
        } else {
        }
            //System.runAs (pm_manager) {
                Contact c = [SELECT id, Name, pse__Salesforce_User__c FROM Contact WHERE id =:i];
                User u = [SELECT id, Name FROM User WHERE Username = 'testuser1@cvent.com' LIMIT 1];
                c.pse__Salesforce_User__c = u.id;
                update c;
            //}
        //}
    
    }*/
}