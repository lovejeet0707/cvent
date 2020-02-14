/**
 * @File Name          : TestBatch_EBSBObject_SendWeeklyAlerts.cls
 * @Description        : 
 * @Author             : Nishant Goswami
 * @Group              : 
 * @Last Modified By   : Nishant Goswami
 * @Last Modified On   : 25/12/2019, 4:27:26 pm
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    25/12/2019   Nishant Goswami     Initial Version
**/
@isTest
private class TestBatch_EBSBObject_SendWeeklyAlerts{
	

	@testSetup static void setup(){
		//Test Declaration
		Account account;
		Contact contact;
		Professional_Services_Project__c psp;
		Eb_sb_builder__c ebsbbuilder;
		account = new Account(
			Name = 'Test Account'
			,AM_Event__c = 'CRM Deployment User'
			,BillingCountryCode = 'US'
			,BillingStateCode = 'MA'
		);
		insert account;
		
		contact = new Contact(
			Email = 'testCvent@yopmail.com'
			,FirstName = 'Test'
			,LastName = 'Contact'
			,AccountId = account.Id
		);
		insert contact;

		psp = new Professional_Services_Project__c(
			Account__c = account.Id
			,Contact__c = contact.Id
		);
		insert psp;
		
		ebsbbuilder = new Eb_sb_builder__c (
			SendWeeklyAlerts__c = TRUE
			,Project_Status_del__c = 'In Progress'
			,Contact__c = contact.Id
			,PSP_ID__c = psp.id
			,Integration__c = 'Crowd Compass'
		);
		insert ebsbbuilder;
		System.assertNotEquals(null,ebsbbuilder.Id);
	}

	@isTest static void testMethod1() {
		Account account;
		Contact contact;
		Professional_Services_Project__c psp;
		Eb_sb_builder__c ebsbbuilder;
		account = [Select Id, AM_Event__c FROM Account limit 1];
		contact = [Select Id, Email From Contact limit 1];
		psp = [Select Id, Account__c From Professional_Services_Project__c limit 1];
		ebsbbuilder = [Select Id, PSP_Id__c From Eb_sb_builder__c limit 1];
		Test.StartTest();
		Batch_EBSBObject_SendWeeklyAlerts batch = new Batch_EBSBObject_SendWeeklyAlerts();
        Database.executeBatch(batch); 
		Test.StopTest();
	}

	/* @isTest static void testMethod2() {
		// code_block	
	} */
}