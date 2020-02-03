/*
//////////////////////////////////////
//      @author Vaibhav Jain     //
/////////////////////////////////////
Version :   1.0
Date : 14th July 2015
*/
@isTest
public class backlogItemTrgHelperClsTest{
    public static Backlog_Item__c instOfBI = new Backlog_Item__c();
    static{
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User usrId = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='stansdfsddarduser@testorg.com');
        insert usrId;
        
        Account instofAcc = new Account();
        RecordType rtType = [SELECT r.SobjectType, r.DeveloperName,r.IsActive FROM RecordType r WHERE SobjectType='Account' And DeveloperName='Biz_Ac' And IsActive=true];
        instofAcc.Name = 'Test';
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        instofAcc.RecordTypeId = rtType.id;
        insert instofAcc;
        
        AccountTeamMember acctTM = new AccountTeamMember();
        acctTM.AccountId = instofAcc.Id;
        acctTM.TeamMemberRole = 'CS - CrowdCompass';
        acctTM.userId = usrId.Id;
        insert acctTM;
        
        Contact instofCon =  new Contact();
        instOfCon.LastName = 'Test';
        instOfCon.AccountId = instofAcc.Id;
        insert instOfCon;
        
        
        instOfBI.Name = 'Test';
        instOfBI.Product__c = 'API';
        instOfBI.Status__c = 'On Ice';
        instOfBI.Business_Case__c = 'Test';
        instOfBI.Approach__c = 'Test';
        insert instOfBI;
        
        Enhancement_Request__c instOfER = new Enhancement_Request__c();
        instOfER.Name = 'Test';
        instOfER.Product__c = 'CrowdCompass';
        instOfER.Requesters_Priority__c = 'High';
        instOfER.Date_Requested__c = system.today();
        instOfER.Request_Status__c = 'Reviewed - New';
        instOfER.Related_Backlog_Item__c = instOfBI.Id;
        instOfER.Contact__c = instOfCon.Id;
        insert instOfER;
    }
    static testMethod void myUnitTest() {
        instOfBI.Status__c = 'Closed - Released';
        update instOfBI;
    }
}