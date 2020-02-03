@isTest
private class MergingCallsFromSFtoCVIITest 
{
    static testmethod void testCallout() 
    {
        Test.setMock(HttpcalloutMock.class, new MergingCallsFromSFMock());
        
        account instofAcc1 = TestUtil.createAccount('Test Account','Biz_Ac');
        instofAcc1.Supplier_Type__c = 'Venue';
        instofAcc1.Venue_Type__c = 'CVB';
        instofAcc1.Phone = '056465465465';
        instofAcc1.Dedicated_Ent_Support_Minutes_Used__c = 0;
        insert instofAcc1;
        
        Contact instContactFif1 = TestUtil.createContact(String.valueOf(instofAcc1.Id));
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
        
        Contact  contactObj = TestUtil.createContact(String.valueOf(instofAcc1.Id));
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
        insert contactObj;
        
        merge instContactFif1 contactObj;
        MergingCallsFromSFtoCVII obj = new MergingCallsFromSFtoCVII();
        map<id,id> testMap = new map<id,id>();
        testMap.put(instContactFif1.id,contactObj.id);
        
        
        Test.startTest();
        
        String JSONMsg = '{"pastId" : "'+instContactFif1.id +'","presentId:"' + contactObj.id+'}';
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = 'https://login-service-development.us-east-1.lb.cvent.com/staging/login/v1/users/sync/contacts';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JSONMsg);
        
        RestContext.request = req;
        RestContext.response= res;
        
        MergingCallsFromSFtoCVII.sendIdToCVII(testMap,'Contact');
        Test.StopTest();   
    }
}