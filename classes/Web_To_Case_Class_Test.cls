/*******************************************
Class Name: Web_To_Case_Class_Test
Created By: Harshit Johar
Description: Test Class for code coverage of Web_To_Case_Class.

*******************************************/

@isTest
Public class Web_To_Case_Class_Test{
    @testSetup
    Public static void testSetupMethod(){
        //TestUtil.createQueue('CRM Management', 'Case');

        Case testCase = new Case();
        testCase.Subject = 'Test Case';
		testCase.Description = 'Test Case Description';
		testCase.Requestor_Department__c = 'Internal';
		testCase.Category__c = 'Meta-Data Enhancements';    
		testCase.SuppliedEmail = 'test@test.com';
		testCase.SuppliedName = 'Test User';
        insert testCase;

    }

    @IsTest
    static void Web2CaseTest(){
        
        Test.startTest();
            Case caserec = [Select id, Subject, Description, Requestor_Department__c, Category__c, SuppliedEmail, SuppliedName, Affected_Records_URL__c, Steps_to_Replicate__c from Case where Subject = 'Test Case' Limit 1];
            Blob testBlob = Blob.valueOf('Test Attachment');

            ApexPages.StandardController sc = new ApexPages.StandardController(caserec);
            Web_To_Case_Class testWeb2Case = new Web_To_Case_Class(sc);

            testWeb2Case.file = testBlob;
            testWeb2Case.fileName = 'Test Attachment';
            testWeb2Case.SaveCase();

        Test.stopTest();
        
    }
}