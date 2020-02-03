@isTest
public class ro_navbarControllerTest {
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
  
  ro_navbarController oController = new ro_navbarController();   
  Boolean isSite = oController.isSite;
  String sitePrefix = oController.sitePrefix;
  String sCategory = oController.sCategory;
  String sCategoryGroup = oController.sCategoryGroup;   
  list<String> lstTab = oController.lstTab;
	}
 
}