@isTest
private class ro_HomeControllerTest {
	@isTest
 static void unitTest() {
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
		oCommunityTab.Name = 'Home';
		oCommunityTab.Community__c = oCommunity.Id;
		insert oCommunityTab;
		
		list<Community_Content__c> lstCommunityContent = new list<Community_Content__c>();
		for(Integer indx = 0 ;indx < 10 ; indx++){
			Community_Content__c oCommunityContent = new Community_Content__c();
			oCommunityContent.Order__c = indx;
			oCommunityContent.Tab__c = oCommunityTab.Id;
			oCommunityContent.Type__c = 'Text';
			oCommunityContent.Value__c = 'Test' + indx;
			lstCommunityContent.add(oCommunityContent);
		}
		insert lstCommunityContent;		
		
		ro_HomeController oController = new ro_HomeController();
		map<String,Community_Content__c> mapContents = oController.mapContents;
 }	
}