public with sharing class ro_ConfigHelper {
  public String sitePrefix ;
 public list<String> lstTab;
 public Boolean isSite;
 
 public CategoryMapping__c oCategoryMapping;
 public String categoryGroup;
 public String category;
 
 public String sDescriptionSeparator = '----------------------------------------';
  
 public final String RegOnline = 'RegOnline';
 
  public static ro_ConfigHelper self {get; private set;}
   static {
      // Static block used for transparent Singleton setup. the "self" static variable
      // will be ready as soon as class will be loaded in memory.
      self = new ro_ConfigHelper();  
    }
  
    // NOTE: the constructor is marked "PRIVATE"
    // so that no Apex code outside this class can create 
    // the instance
 private map<string, CategoryMapping__c> mapCategoryMapping;
 private ro_ConfigHelper() {
   isSite = false;
    sitePrefix = 'Internal';
   System.debug('@Developer --> Site.getPathPrefix() :' + Site.getPathPrefix());
   System.debug('@Developer --> userinfo.getUserType():' + userinfo.getUserType());
   
   categoryGroup = 'Products';
   category = RegOnline;
     
   if(Site.getPathPrefix() != null && Site.getPathPrefix() != ''){
    sitePrefix = Site.getPathPrefix();   
    if(userinfo.getUserType() == 'Guest'){
      isSite = true;
    }
   }
   
  sitePrefix = sitePrefix.removeStart('/');
  
   mapCategoryMapping = CategoryMapping__c.getAll();
   oCategoryMapping = mapCategoryMapping.get(sitePrefix);
     
   categoryGroup = oCategoryMapping.Category_Group__c;
   category = oCategoryMapping.Category__c;
   
   
   lstTab = new list<String>();
   for(TabConfiguration__c tc: [Select Id ,Name,Tabs__c From TabConfiguration__c Where Name =:sitePrefix]){
     if(tc.Tabs__c != null && tc.Tabs__c != ''){
      lstTab.addAll(tc.Tabs__c.split(','));  
     }
   }
 }
  
}