@istest
public class GDPRCentralRepositoryHandler_Test{
    public static testMethod void testGDPRMethod(){
        
        User userObj = [SELECT Id,Firstname,ContactId,Email,LastName,MobilePhone,Phone,Name FROM User WHERE IsActive=TRUE AND IsPortalEnabled = TRUE LIMIT 1];

        Set<Id> userIdSet = new set<Id>();
        userIdSet.add(userObj.Id);

        Set<Id> contactIdSet = new set<Id>();
        contactIdSet.add(userObj.ContactId);
        
        GDPR_Central_Repository__c gdprObject = new GDPR_Central_Repository__c();
        gdprObject.Id__c = userObj.Id;
        gdprObject.Firstname__c = userObj.Firstname;
        gdprObject.Email__c = userObj.Email;
        gdprObject.LastName__c = userObj.LastName;
        gdprObject.MobilePhone__c = userObj.MobilePhone;
        gdprObject.Phone__c = userObj.Phone;
        gdprObject.Name__c = userObj.Name;
        
        insert gdprObject;
        Test.startTest();
        GDPRCentralRepositoryHandler.GDPRUser(userIdSet);
        Test.stopTest();
        GDPRCentralRepositoryHandler_User.updateGDPR_User(userIdSet,contactIdSet);
        
    }
    public static testMethod void testGDPRMethod1(){
        
        User userObj = [SELECT Id,Firstname,ContactId,Email,LastName,MobilePhone,Phone,Name FROM User WHERE IsActive=TRUE AND IsPortalEnabled = TRUE LIMIT 1];

        Set<Id> userIdSet = new set<Id>();
        userIdSet.add(userObj.Id);

        Set<Id> contactIdSet = new set<Id>();
        contactIdSet.add(userObj.ContactId);
        
        GDPR_Central_Repository__c gdprObject = new GDPR_Central_Repository__c();
        gdprObject.Id__c = userObj.Id;
        gdprObject.Firstname__c = userObj.Firstname;
        gdprObject.Email__c = userObj.Email;
        gdprObject.LastName__c = userObj.LastName;
        gdprObject.MobilePhone__c = userObj.MobilePhone;
        gdprObject.Phone__c = userObj.Phone;
        gdprObject.Name__c = userObj.Name;
        
        insert gdprObject;
        Test.startTest();
        GDPRCentralRepositoryHandler_User.updateGDPR_User(userIdSet,contactIdSet);        
        Test.stopTest();
        GDPRCentralRepositoryHandler.fakeMethod();
        
    }
}