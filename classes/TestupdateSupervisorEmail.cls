@isTest
private class TestupdateSupervisorEmail {
   static testMethod void updateSupervisorEmailTest(){
       User u = [Select id from User where profile.name = 'System Administrator' limit 1];
       Sales_Resources__c s = new Sales_Resources__c(Name='test',
                                                                               Request_Received_Date__c = system.today(),
                                                                               recordtypeId = '0120000000099Kb',
                                                                               Sales_Requestor__c = u.id);
        insert s;
        
        s.Sales_Requestor__c = Userinfo.getUserId();
        update s;
   }
}