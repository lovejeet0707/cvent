public with sharing class ro_navbarController {
 public Boolean isSite {
  get{
  	return ro_ConfigHelper.self.isSite;
  }
 }
 public String sitePrefix {
  get{
  	return ro_ConfigHelper.self.sitePrefix;
  }
 }
 public list<String> lstTab {
  get{
  	return ro_ConfigHelper.self.lstTab;
  }
 }
 public String sCategoryGroup {
	 get{
	  return ro_ConfigHelper.self.categoryGroup;
	 }
 }
 
 public String sCategory {
 	get{
   return ro_ConfigHelper.self.category; 	
 	}
 }
 
 public ro_navbarController(){}
}