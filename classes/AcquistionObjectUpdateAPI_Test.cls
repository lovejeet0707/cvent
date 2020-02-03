@istest
public class AcquistionObjectUpdateAPI_Test 
{
    static testMethod void  updateMethodTest(){
        
        Account accRec = new Account();
        accRec.Name = 'Test Account';
        accRec.BillingCountryCode = 'US';
        accRec.BillingStateCode = 'NY';
        insert accRec;
        
        Acquisition__c acquisitionObj= new Acquisition__c();
        acquisitionObj.Account__c = accRec.Id;
        acquisitionObj.Account_Owner_for_Acquired_Org__c ='Test Owner';
        acquisitionObj.Account_Type_for_Aquired_Org__c = 'Client';
        acquisitionObj.Company_Name__c = 'QuickMobile';
        acquisitionObj.Migrated_Record_ID__c = '123456789012345';
        acquisitionObj.Migrated_Record__c = 'Migrated';
        insert acquisitionObj;
        
        Test.startTest();
       
        String reqst = '{"123456789012345":"Client"}';
        //String JsonMsg=JSON.serialize(reqst);
        System.debug('JsonMsg>>>'+reqst);
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/AcquistionUpdateForOpp';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(reqst);
        RestContext.request = req;
        RestContext.response= res;
        AcquistionObjectUpdate.doPost();
        Test.stopTest();
        
    }
    
    static testMethod void  updateMethodTest2(){
        
        Account accRec = new Account();
        accRec.Name = 'Test Account';
        accRec.BillingCountryCode = 'US';
        accRec.BillingStateCode = 'NY';
        insert accRec;
        
        Acquisition__c acquisitionObj= new Acquisition__c();
        acquisitionObj.Account__c = accRec.Id;
        acquisitionObj.Account_Owner_for_Acquired_Org__c ='Test Owner';
        acquisitionObj.Account_Type_for_Aquired_Org__c = 'Client';
        acquisitionObj.Company_Name__c = 'QuickMobile';
        acquisitionObj.Migrated_Record_ID__c = '123456789012345';
        acquisitionObj.Migrated_Record__c = 'Migrated';
        insert acquisitionObj;
        
        Test.startTest();
       
        String reqst = '{"123456789012345":"Test Owner"}';
        //String JsonMsg=JSON.serialize(reqst);
        System.debug('JsonMsg>>>'+reqst);
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/AccountOwnerSyncRestAPI';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(reqst);
        RestContext.request = req;
        RestContext.response= res;
        AccountOwnerSyncRestAPI.doPost();
        Test.stopTest();
        
    }
    
    static testMethod void  updateMethodTest3(){
        
        Account accRec = new Account();
        accRec.Name = 'Test Account';
        accRec.BillingCountryCode = 'US';
        accRec.BillingStateCode = 'NY';
        insert accRec;
        
        Acquisition__c acquisitionObj= new Acquisition__c();
        acquisitionObj.Account__c = accRec.Id;
        acquisitionObj.Account_Owner_for_Acquired_Org__c ='Test Owner';
        acquisitionObj.Account_Type_for_Aquired_Org__c = 'Client';
        acquisitionObj.Company_Name__c = 'QuickMobile';
        acquisitionObj.Migrated_Record_ID__c = '123456789012345';
        acquisitionObj.Migrated_Record__c = 'Migrated';
        insert acquisitionObj;
        
        Test.startTest();
       
        String reqst = '{"123456789012345":"TRUE"}';
        //String JsonMsg=JSON.serialize(reqst);
        System.debug('JsonMsg>>>'+reqst);
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/OpenOpportunitiesCheckboxUpdateRestAPI';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(reqst);
        RestContext.request = req;
        RestContext.response= res;
        OpenOpportunitiesCheckboxUpdateRestAPI.doPost();
        Test.stopTest();
        
    }
}