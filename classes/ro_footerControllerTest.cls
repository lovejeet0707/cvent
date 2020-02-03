@isTest
public class ro_footerControllerTest {
	@isTest
	public static void unitTest(){
		 TabConfiguration__c oTabConfiguration = new TabConfiguration__c();
		 oTabConfiguration.Name = 'Internal';
		 oTabConfiguration.Tabs__c = 'home,articles,training,guides,lanyoncommunities,ideas,support';
		 insert oTabConfiguration;
		 
		 CategoryMapping__c oCategoryMapping = new CategoryMapping__c();
		 oCategoryMapping.Name = 'Internal';
		 oCategoryMapping.Actual_Community_Name__c = 'Internal';
		 oCategoryMapping.Category__c = 'REGONLINE';
		 oCategoryMapping.Category_Group__c = 'CATEGORIES';
		 oCategoryMapping.Product__c = 'RegOnline';
		 oCategoryMapping.Product_Family_Name__c = 'RegOnline';
		 oCategoryMapping.OwnerId__c = userinfo.getUserId();
		 insert oCategoryMapping;
		 
		 Community__c oCommunity = new Community__c();
   oCommunity.Name = 'Internal';
   insert oCommunity;
   
   Community_Tab__c oCommunityTab = new Community_Tab__c();
			oCommunityTab.Name = 'Footer';
			oCommunityTab.Community__c = oCommunity.Id;
			insert oCommunityTab;
			
			Community_Content__c oCommunityContent = new Community_Content__c();
			oCommunityContent.Order__c = 1.1;
			oCommunityContent.Tab__c = oCommunityTab.Id;
			oCommunityContent.Type__c = 'text';
			oCommunityContent.Value__c = 'RegOnline by Lanyon - © 2015 Lanyon Solutions, Inc.';
			insert oCommunityContent;
			
			ro_footerController oController = new ro_footerController();
	}
}