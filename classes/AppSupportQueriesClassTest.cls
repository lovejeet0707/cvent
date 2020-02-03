@isTest
public class AppSupportQueriesClassTest{
    static testmethod void validateStandardController(){
        Id recTypeCase  = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Event').getRecordTypeId();
        //Insert Custom Setting...
        App_Support_Custom_Setting__c appCus = new App_Support_Custom_Setting__c();
        appCus.Name = 'Event';
        appCus.Product_Type__c = 'Event';
        appCus.App_Support_Case_Record_Type__c = '0120000000099RQ';
        insert appCus;
        
        
         //Insert Account record..........
        Account instofAcc = new Account();
        instofAcc.Name = 'TestCaseSegeration';
        instofAcc.Supplier_Type__c = 'Venue';
        instofAcc.Venue_Type__c = 'CVB';
        insert instofAcc;
        
        //Insert Case Record..............
        Case caseObj = new Case();
        caseObj.recordTypeId = recTypeCase ;
        //caseObj.Product_Type__c = 'Event Tool';
        caseObj.Status = 'Open';
        caseObj.Minutesoncase__c = 30; 
        caseObj.OwnerId = userInfo.getUserId();
        caseObj.AccountId=instofAcc.Id;
        caseObj.subject='Test Hosp Cloud Implementation Survey';
        caseObj.Origin ='Email';       
        caseObj.description='The details of Francisco De Asis Grageras response are below.Dear Francisco De Asis Gragera,Thank you for completing the Hosp Cloud Implementation Survey! We appreciate the time you spent to provide us with the contract details. Given below is a snaphot of the survey response. Respondent Information Survey Title: Hosp Cloud Implementation Survey Response Number: 50104104 Total Score: 0.00/0.00 Start Date: 01/09/2017 1:07 PM Completion Date: 01/09/2017 1:25 PM Response Information Question Answer Score Contract Type CSN Bundle 0.00 Please provide the Salesforce link to the Contract Signer https://cvent.my.salesforce.com/'+instofAcc.Id+' 0.00 Bundle Type Single Property Bundle 0.00 Salesforce Account Link: https://cvent.my.salesforce.com/00100000008DBY3 0.00';
        insert caseObj;
        
        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(caseObj);
        AppSupportQueriesClass testAccPlan = new AppSupportQueriesClass(sc);
        
        PageReference pageRef = Page.AppSupportQueries;
        //pageRef.getParameters().put('id', String.valueOf(testAccountPlanInsert.Id));
        Test.setCurrentPage(pageRef);
        testAccPlan.findSuggestions();
    }
}