@isTest
public class CventCommunityHeaderClassTest{
    static testmethod void unitTest(){
        
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'Cvent Community Profile'];
        UserRole ur = new UserRole(Name = 'Finance Approver');
        insert ur;

        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
       
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User tuser = new User(  firstname = 'firstTestName',
                                lastName = 'lastTestName',
                                email = uniqueName + '@test' + orgId + '.org',
                                Username = uniqueName + '@test' + orgId + '.org',
                                EmailEncodingKey = 'ISO-8859-1',
                                Alias = uniqueName.substring(18, 23),
                                TimeZoneSidKey = 'America/Los_Angeles',
                                LocaleSidKey = 'en_US',
                                LanguageLocaleKey = 'en_US',
                                ProfileId = pf.Id,
                                UserRoleId = ur.Id);
        CventCommunityHeaderClass cc = new CventCommunityHeaderClass();
    }
}