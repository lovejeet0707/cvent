/**
//////////////////////////////////////
//      @author Abhishek Pandey     //
/////////////////////////////////////
Version :   1.0
Date : 23rd July 2014
Description: Tests the ContactTrgHelperCls , stopping the creation of Task depending on campaign members "Member Status Updated"  date value . 
 */
@isTest
public class ContactTrgHelperClsTest {
    public static Account instofAcc = new Account();
    public static Account instofAcc1 = new Account();
    public static Contact instContact = new Contact();
    public static Contact_Role__c conRoleObj;
    public static Contact contactObj;
    public static List<Contact> contactList; 
    public static List<Contact_Role__c> conRoleList; 
    public static Contact instContactFif = new Contact();   
    public static Campaign_Assignment__c instOfCampAss = new Campaign_Assignment__c();  
    public static ISOSetting__c instOfIso = new ISOSetting__c();
    public static ISOSetting__c instOfIsoSec = new ISOSetting__c();
    public static Country_Phone_Codes__c setting1 = new Country_Phone_Codes__c();
        
    
    static{
        instOfIso.Name = '1';
        instOfIso.Country_Name__c = 'America';
        instOfIso.ISO__c = 'USA';
        insert instOfIso;
        
        instOfIsoSec.Name = '2';
        instOfIsoSec.Country_Name__c = 'India';
        instOfIsoSec.ISO__c = 'IND';
        insert instOfIsoSec;
        
        setting1.Name = 'IN';
        setting1.ISD_Code__c = '91';
        setting1.Country_Name__c = 'India';
        insert setting1;
        
        Campaign instOfCamp = new Campaign();
        instOfCamp.Name = 'Test';
        insert instOfCamp;
        
        instOfCampAss.Name = '1';
        instOfCampAss.Lead_Source__c = 'WEB-Chat (CrowdCompass)';
        instOfCampAss.Campaign_Id__c = instOfCamp.Id;
        instOfCampAss.Assigned_Role__c = 'CrowdTorch';
        insert instOfCampAss;
        
        Id custRecTypeId = Schema.SObjectType.Contact_Role__c.getRecordTypeInfosByName().get('Customer Role').getRecordTypeId();
        
        RecordType rtType = [SELECT r.SobjectType, r.DeveloperName,r.IsActive FROM RecordType r WHERE SobjectType='Account' AND DeveloperName='Biz_Ac' And IsActive = true];
        StopCloudMDMExe.stopExecutionCloudMdm = false;
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        instofAcc.RecordTypeId = rtType.id;
        instofAcc.Name = 'Test';
        instofAcc.BillingCountryCode = 'IN';
        instofAcc.Phone = '056465465465';
        instOfAcc.Dedicated_Ent_Support_Minutes_Used__c = 0;
        insert instofAcc;
        
        Lead le = new Lead();
        le.LastName = 'Test Lead 25';
        le.CountryCode = 'IN';
        le.Phone = '056465465465';
        le.MobilePhone = '056465465465';
        le.Other_Phone__c = '056465465465';
        
        insert le;
        
        contactList = new List<Contact>();        
        instContact.LastName = 'Test';
        instContact.AccountId = instofAcc.Id;
        instContact.CT_Contact_Status__c= 'Open Opportunity';
        instContact.Event_Contact_Status__c = 'Open Opportunity';
        instContact.TM_Contact_Status__c = 'Open Opportunity';
        instContact.LeadSource = 'WEB-Chat (CrowdCompass)';
        instContact.Mood_Level__c = 2;
        instContact.Purchasing_Interest_CSNP__c = '4 - Very interested';
        instContact.Purchasing_Interest_PK__c='3 - Somewhat interested';
        instContact.Attended__c = 'CSG';
        instContact.MailingCountryCode = 'IN';
        instContact.AdvocateHub__Date_Joined_AdvocateHub__c= SYSTEM.TODAY();
        
        Country_Phone_Codes__c setting = new Country_Phone_Codes__c();
        setting.Name = 'IN';
        setting.ISD_Code__c = '91';
        setting.Country_Name__c = 'India';
        insert setting;
        
        instContact.Phone = '056465465465';
        instContact.MobilePhone = '056465465465';
        instContact.OtherPhone = '056465465465';
        contactList.add(instContact);
        
        instContactFif.LastName = 'Test';
        instContactFif.AccountId = instofAcc.Id;
        instContactFif.CT_Contact_Status__c= 'E - Attended';
        instContactFif.Event_Contact_Status__c = 'Trash';//'E - Attended';
        instContactFif.TM_Contact_Status__c = 'E - Attended';
        instContactFif.LeadSource = 'WEB-Chat (CT-Mobile)';
        instContactFif.Mood_Level__c = 4;
        instContactFif.Attended__c = 'OD/PS';
        instContactFif.Purchasing_Interest_CSNP__c = '4 - Very interested';
        contactList.add(instContactFif);
        
        contactObj = new Contact();       
        contactObj.LastName = 'Test';
        contactObj.AccountId = instofAcc.Id;
        contactObj.Mood_Level__c = 2;
        contactObj.Event_Contact_Status__c= 'Trash';
        contactObj.Event_Recycle_Reason__c = 'NO longer there';
        contactObj.Survey_Contact_Status__c = 'Trash';
        contactObj.Survey_Recycle_Reason__c = 'NO longer there';
        contactObj.CSN_P_Contact_Status__c= 'Trash';
        contactObj.CSN_P_Status_Details__c = 'NO longer there';
        contactObj.SMM_Contact_Status__c = 'Trash';
        contactObj.SMM_Recycle_Trash_Reason__c = 'NO longer there';
        contactObj.CSNS_Contact_Status__c= 'Trash';
        contactObj.CSN_S_Recycle_Trash__c = 'NO longer there';
        contactObj.CC_Contact_Status__c = 'Trash';
        contactObj.CC_Recycle_Trash_Reason__c = 'NO longer there';
        contactObj.TM_Contact_Status__c= 'Trash';
        contactObj.TM_Recycle_Trash_Reason__c = 'NO longer there';
        contactObj.CT_Contact_Status__c= 'J - Trash';
        contactObj.CT_Recycle_Trash_Reason__c = 'NO longer there'; 
        contactObj.Purchasing_Interest_PK__c='3 - Somewhat interested';
        contactObj.Attended__c = 'CSG';
        contactObj.Purchasing_Interest_Inquisium__c ='3 - Somewhat interested';
        
        instContactFif = new Contact();
        instContactFif.LastName = 'Test';
        instContactFif.AccountId = instofAcc.Id;
        instContactFif.CT_Contact_Status__c= 'E - Attended';
        instContactFif.Event_Contact_Status__c = 'Trash';//'E - Attended';
        instContactFif.TM_Contact_Status__c = 'E - Attended';
        instContactFif.LeadSource = 'WEB-Chat (CT-Mobile)';
        instContactFif.Mood_Level__c = 4;
        instContactFif.Attended__c = 'CSG';
        instContactFif.Purchasing_Interest_CSNP__c = '4 - Very interested';
        contactList.add(instContactFif);
        contactList.add(contactObj);
        
        instContactFif = new Contact();
        instContactFif.LastName = 'Test';
        instContactFif.AccountId = instofAcc.Id;
        instContactFif.CT_Contact_Status__c= 'E - Attended';
        instContactFif.Event_Contact_Status__c = 'Trash';//'E - Attended';
        instContactFif.TM_Contact_Status__c = 'E - Attended';
        instContactFif.LeadSource = 'WEB-Chat (CT-Mobile)';
        instContactFif.Mood_Level__c = 4;
        instContactFif.Attended__c = 'CSG';
        instContactFif.Purchasing_Interest_Inquisium__c = '3 - Somewhat interested';
        contactList.add(instContactFif);
        
        insert contactList;
        
        conRoleList = new List<Contact_Role__c>();        
        conRoleObj = new Contact_Role__c();        
        conRoleObj.Account_Customer_Role__c = instofAcc.Id;
        conRoleObj.Contact__c = contactList[2].Id;
        conRoleObj.RecordTypeId = custRecTypeId;
        conRoleObj.User__c = false;
        conRoleObj.User_Sub_Role__c = 'Administrator;Community Portal Administrator'; // added by Vaibhav Jain (2nd Mar 2017 8:51 pm IST)
        conRoleList.add(conRoleObj);        
        
        conRoleObj = new Contact_Role__c();
        conRoleObj.Account_Customer_Role__c = instofAcc.Id;
        conRoleObj.Contact__c = contactList[2].Id;
        conRoleObj.RecordTypeId = custRecTypeId;
        conRoleObj.User_Sub_Role__c = 'Administrator;Community Portal Administrator'; // added by Vaibhav Jain (2nd Mar 2017 8:51 pm IST)
        conRoleObj.User__c = false;
        conRoleList.add(conRoleObj); 
        
        insert conRoleList;
    }
    
    static testMethod void myUnitTest() {
        /*Contact instOfContactThir = [SELECT Id,CT_Contact_Status__c,Event_Contact_Status__c,TM_Contact_Status__c FROM Contact WHERE Id =: instContact.id LIMIT 1];
        instOfContactThir.CT_Contact_Status__c= 'H - Closed Won';
        instOfContactThir.Event_Contact_Status__c = 'Closed Won';
        instOfContactThir.TM_Contact_Status__c = 'H - Closed Won';
        update instOfContactThir;*/
        
        contactList[0].Purchasing_Interest_CSNP__c = '3 - Somewhat interested';
        contactList[0].Purchasing_Interest_PK__c = '4 - Very interested';
        contactList[0].Last_Attended_Event__c = System.today();
        
        contactList[1].Purchasing_Interest_CSNP__c = '3 - Somewhat interested';
        contactList[1].Last_Attended_Event__c = System.today();
        
        contactList[2].Purchasing_Interest_PK__c = '4 - Very interested';
        contactList[2].Purchasing_Interest_Inquisium__c = '4 - Very interested';
        contactList[2].Last_Attended_Event__c = System.today();
                
        contactList[3].Purchasing_Interest_CSNP__c = '3 - Somewhat interested';
        contactList[3].Last_Attended_Event__c = System.today();
        
        contactList[4].Purchasing_Interest_Inquisium__c = '4 - Very interested';
        contactList[4].Last_Attended_Event__c = System.today();
                
        update contactList;
        
        Contact instOfContactSEC = [SELECT Id,CT_Contact_Status__c,Event_Contact_Status__c,TM_Contact_Status__c FROM Contact WHERE Id =: instContact.id LIMIT 1];
        delete instOfContactSEC;
        
    }
    
    static testMethod void myUnitTestGDPR(){
        contactList[0].Is_GDPR__c = true;
        update contactList;
    }
    static testMethod void myUnitTestDedicatedEntMinutes()
    {
        
         RecordType rtType = [SELECT r.SobjectType, r.DeveloperName,r.IsActive FROM RecordType r WHERE SobjectType='Account' AND DeveloperName='Biz_Ac' And IsActive = true];
        StopCloudMDMExe.stopExecutionCloudMdm = false;
        instofAcc1.Supplier_Type__c = 'Venue';
        instofAcc1.Venue_Type__c = 'CVB';
        instofAcc1.RecordTypeId = rtType.id;
        instofAcc1.Name = 'Test';
        instofAcc1.BillingCountryCode = 'IN';
        instofAcc1.Phone = '056465465465';
        instofAcc1.Dedicated_Ent_Support_Minutes_Used__c = 0;
        insert instofAcc1;
        
        Contact instContactFif1 = new Contact();
        instContactFif1.LastName = 'Test';
        instContactFif1.AccountId = instofAcc1.Id;
        instContactFif1.CT_Contact_Status__c= 'E - Attended';
        instContactFif1.Event_Contact_Status__c = 'Trash';//'E - Attended';
        instContactFif1.TM_Contact_Status__c = 'E - Attended';
        instContactFif1.LeadSource = 'WEB-Chat (CT-Mobile)';
        instContactFif1.Mood_Level__c = 4;
        instContactFif1.Attended__c = 'CSG';
        instContactFif1.Purchasing_Interest_Inquisium__c = '3 - Somewhat interested';
        instContactFif1.Dedicated_Ent_Support_Minutes_Purchased__c = 0;
        instContactFif1.Dedicated_Ent_Support_Minutes_Used__c = 0;
        instContactFif1.AdvocateHub__Date_Joined_AdvocateHub__c= SYSTEM.TODAY();
        insert instContactFif1;
        instContactFif1.Dedicated_Ent_Support_Minutes_Purchased__c = 5;
        instContactFif1.Dedicated_Ent_Support_Minutes_Used__c = 5;
        instContact.AdvocateHub__Date_Joined_AdvocateHub__c= SYSTEM.TODAY().addDays(1);
        update instContactFif1;
        Id buyRecTypeId = Schema.SObjectType.Contact_Role__c.getRecordTypeInfosByName().get('Buyer Role').getRecordTypeId();
        
        Contact_Role__c cr = new Contact_Role__c();
        cr.RecordtypeId = buyRecTypeId;
        cr.Decision_Maker_Products__c = '';
        cr.Influencer__c = true;
        cr.Influencer_Products__c = 'Onsite Solutions';
        cr.Contact__c = instContactFif1.id;
        cr.Account_Buyer_Role__c = instofAcc1.Id;
        insert cr;
        
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        instofAcc.RecordTypeId = rtType.id;
        instofAcc.Name = 'Test';
        instofAcc.BillingCountryCode = 'IN';
        instofAcc.Phone = '056465465465';
        instOfAcc.Dedicated_Ent_Support_Minutes_Used__c = 0;
       // insert instofAcc;
        
        instContactFif1.AccountId = instofAcc.Id;
        
        update instContactFif1;
        
        FormPos__Former_Position__c form = new FormPos__Former_Position__c ();
        form.FormPos__Account__c = instofAcc1.Id;
        form.FormPos__Start_Date__c = system.today().addDays(-110);
        form.FormPos__End_Date__c =system.today().addDays(-50);
        form.FormPos__Contact__c= instContactFif1.id;
        insert form;
        
        //Contact con = new Contact();
        Test.startTest();
        
        PageReference pageRef = Page.FormerContactView;
        // Add required parameters.
        pageRef.getParameters().put('Id', instContactFif1.Id);
        Test.setCurrentPageReference(pageRef);
    
        ApexPages.StandardController stdController = new ApexPages.StandardController(instContactFif1);
        FormerContactViewController former = new FormerContactViewController(stdController);
        former.accName = '0015400000JvlcJ';
        former.fetchActivities();
        former.getselectValues();
        FormerContactViewController.eEventTTask event = new FormerContactViewController.eEventTTask('test','test1','test2',System.today(),instContactFif1.Id,'test3','test4',true,instOfAcc.Id);
        Test.stopTest();
        
    }
}