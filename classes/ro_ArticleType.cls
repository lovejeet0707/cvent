public with sharing class ro_ArticleType {
	public static ro_ArticleType self {get; private set;}
 	static {
    	// Static block used for transparent Singleton setup. the "self" static variable
    	// will be ready as soon as class will be loaded in memory.
    	self = new ro_ArticleType();  
  	}
  
  	// NOTE: the constructor is marked "PRIVATE"
  	// so that no Apex code outside this class can create 
  	// the instance
  
	@TestVisible private ro_ArticleType() {
		map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
		set<String> keySet = gd.keySet();
		for(String key : keySet) {
			schema.SObjectType objectType = gd.get(key);
	   		if(key.endsWith('ka') || key.endsWith('kb')){
	    		mapArticleNameWiseLabel.put(objectType.getDescribe().getName(),objectType.getDescribe().getLabel());	    
	   		}
		}
  	}

  	public map<String,String> mapArticleNameWiseLabel = new map<String,String>();
}