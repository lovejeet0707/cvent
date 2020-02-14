@isTest
public class doceboUserTrgHandlerTest{

     public static testMethod void testDoceboUser(){
         
        Account acc1  = new Account();
        acc1.name = 'Test';
        acc1.Product_Mix__c='Event;Inquisium';
        acc1.BillingCountryCode='US';
        acc1.BillingStateCode='TX';
        insert acc1;
        
        Contact conTest = new Contact();
        conTest.LastName = 'Test Contact';
        conTest.AccountId = acc1.Id;
        conTest.email='test@test123.com';
        conTest.Alternate_Email__c ='testing@test.com';
        insert conTest;
        
        conTest.CC_Contact_Status__c = 'Suspect';
        update conTest;
        
         User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
         System.runAs (thisUser) {
    
         user u = new User(
         ProfileId = [SELECT Id FROM Profile WHERE Name = 'Cvent Customer Community User'].Id,
         LastName = 'last',
         Email = 'puser000@amamama.com',
         Username = 'puser000@amamama.com' + System.currentTimeMillis(),
         CompanyName = 'TEST',
         Title = 'title',
         Alias = 'alias',
         TimeZoneSidKey = 'America/Los_Angeles',
         EmailEncodingKey = 'UTF-8',
         LanguageLocaleKey = 'en_US',
         LocaleSidKey = 'en_US',
         contactId = conTest.id,LMS_Groups__c= 'Event'
         );
         insert u;
         
         u=[select id,Account_Id_Dev__c,IsPortalEnabled from user where id = : u.id];
         update u;
         
         system.debug('-----u.Account_Id_Dev__c'+ u.Account_Id_Dev__c);
         system.debug('-----IsPortalEnabled'+ u.IsPortalEnabled);
         
         docebo_v3__DoceboUser__c docebo = new docebo_v3__DoceboUser__c();
         //docebo.docebo_v3__User__c = u.id;
         docebo.docebo_v3__UserId__c=1234567890;
         docebo.docebo_v3__Contact__c = conTest.id;
         insert docebo;
         
         docebo_v3__Course__c course = new docebo_v3__Course__c();
         course.docebo_v3__CourseId__c = 32145;
         course.docebo_v3__Code__c= '1321';
         course.docebo_v3__CreationDate__c = system.today();
         course.docebo_v3__Name__c ='Test Course';
         insert course;
         
         docebo_v3__CourseEnrollment__c doceboCourse = new docebo_v3__CourseEnrollment__c();
        // doceboCourse.Account__c = acc1.Id;
         doceboCourse.docebo_v3__Status__c ='Completed';
        // doceboCourse.Contact__c = conTest.id;
         doceboCourse.docebo_v3__DoceboUser__c = docebo.id;
         doceboCourse.docebo_v3__Course__c = course.id;
         doceboCourse.docebo_v3__EnrolmentId__c= '98745';
         insert doceboCourse;
         
         Mobile_Card__c mobile = new Mobile_Card__c();
         mobile.RecordtypeId = Schema.SObjectType.Mobile_Card__c.getRecordTypeInfosByName().get('Mobile - Onboarding Lite').getRecordTypeId();
         mobile.Primary_Contact__c = conTest.id;
         mobile.Event_Start_Date__c=system.today();
         mobile.Event_End_Date__c=system.today().addDays(10);
         insert mobile;
         
         Mobile_Card__c mobile1 = new Mobile_Card__c();
         mobile1.RecordtypeId = Schema.SObjectType.Mobile_Card__c.getRecordTypeInfosByName().get('Mobile - Onboarding Standard').getRecordTypeId();
         mobile1.Primary_Contact__c = conTest.id;
         mobile1.Event_Start_Date__c=system.today();
         mobile1.Event_End_Date__c=system.today().addDays(10);
         insert mobile1;
         
        }
     }      
}