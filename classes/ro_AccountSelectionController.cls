public with sharing class ro_AccountSelectionController {
	public list<User_contact_Relation__c> UCRList{get;set;}
	
	public ro_AccountSelectionController(){
		UCRList = new list<User_contact_Relation__c>();
		UCRList = [SELECT Id, Name, Related_Contact__c, Related_Contact__r.AccountId, Account__c,Primary__c FROM User_Contact_Relation__c 	
					WHERE User__c =: Userinfo.getUserId()];
	}
}