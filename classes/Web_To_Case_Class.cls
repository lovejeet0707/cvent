/*******************************************
Class Name: Web_To_Case_Class
Created By: Harshit Johar
Description: Class is being used as controller for Web to Case page/public site.

*******************************************/

public class Web_To_Case_Class {

	//Initialising variables
	public Case caseRec { get; set; }
	Public Boolean showfields { get; set; }
	public transient blob file { get; set; }
	public String fileName { get; set; }

	//Constructor
	public Web_To_Case_Class(ApexPages.StandardController controller) {
		this.caseRec = (Case) Controller.getRecord();
		caseRec.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CRM_Management').getRecordTypeId();
		showfields = true;
	}

	//Submit button method
	Public void SaveCase() {
		//Quering the 'CRM Management' queue as the cases will be assigned to the queue
		QueueSObject QueueID = [Select Queue.Id, Queue.Name, Queue.Type from QueueSObject WHERE Queue.Type = 'Queue' AND Queue.DeveloperName = 'CRM_Management' Limit 1];

		//Initializing new Case to be inserted and passing the values that user has entered
		Case caseRecCreate = new Case();
		caseRecCreate.Subject = caseRec.Subject;
		caseRecCreate.Description = caseRec.Description;
		//caseRecCreate.Requestor_Department__c = caseRec.Requestor_Department__c;
		caseRecCreate.Category__c = caseRec.Category__c;
		caseRecCreate.RecordTypeID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CRM_Management').getRecordTypeId();
		caseRecCreate.OwnerID = QueueID.Queue.Id;
		caseRecCreate.Origin = 'Web2Case';
		caseRecCreate.Status = 'Open';
		caseRecCreate.SuppliedEmail = caseRec.SuppliedEmail;
		//caseRecCreate.SuppliedName = caseRec.SuppliedName;
		caseRecCreate.Affected_Records_URL__c = caseRec.Affected_Records_URL__c;
		//caseRecCreate.Steps_to_Replicate__c = caseRec.Steps_to_Replicate__c;

		try{
			//Inserting the case
			insert caseRecCreate;

			//Adding the attachment if there is any
			if(String.isNotBlank(fileName)) {
				//Used Content version so as to make it compatible for Lightning as well
				ContentVersion conVer = new ContentVersion();
				conVer.ContentLocation = 'S';
				conVer.PathOnClient = fileName;
				conVer.Title = fileName;
				conVer.VersionData = file;
				insert conVer;

				Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :conVer.Id].ContentDocumentId;

				ContentDocumentLink cDe = new ContentDocumentLink();
				cDe.ContentDocumentId = conDoc;
				cDe.LinkedEntityId = caseRecCreate.id;
				cDe.ShareType = 'V';
				cDe.Visibility = 'AllUsers';
				insert cDe;
			}
		} Catch(Exception e) {
			//Exception handling
			system.debug('Exception : ' + e.getMessage());
		}

	}

}