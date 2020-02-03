public with sharing class ro_footerController {
 
 public String sCopyright {get;set;}
 
 private list<Community__c> lstCommunity;
 private list<Community_Tab__c> lstCommunityTab;
 private list<Community_Content__c> lstCommunityContent{get;set;}
 
 public ro_footerController(){	
 	String sPortalName = ro_ConfigHelper.self.sitePrefix ;
		 
		lstCommunity = [select Id, Name from Community__c Where Name =: sPortalName limit 1];
		if(lstCommunity.size() > 0){
			lstCommunityTab = [Select Id, Name, Description__c, Community__c 
			                 From Community_Tab__c 
			                 Where Community__c =: lstCommunity[0].Id 
			                 And Name = 'Footer' limit 1];
		 if(lstCommunityTab.size() > 0){
		  lstCommunityContent = [Select Id, Name, Caption__c, Order__c, Tab__c, Type__c, Value__c 
		                         From Community_Content__c 
		                    					Where Tab__c =: lstCommunityTab[0].Id Order By Order__c];
			 if(lstCommunityContent.size() > 0){
			  sCopyright = lstCommunityContent[0].Value__c;
			 }
		 }
		}
		
 }
}