public class ro_HomeController {
    public map<String,Community_Content__c> mapContents {get;set;}
    private list<Community__c> lstCommunity;
    private list<Community_Tab__c> lstCommunityTab;
    private list<Community_Content__c> lstCommunityContent;
    private String sTabName = 'Home';
    
    public ro_HomeController(){
        mapContents = new map<String,Community_Content__c>();
        String sPortalName = ro_ConfigHelper.self.sitePrefix ;
        System.debug('sPortalName******'+sPortalName);
        lstCommunity = [select Id, Name from Community__c Where Name =: sPortalName];
        System.debug('lstCommunity******'+lstCommunity);    
        if(lstCommunity.size() > 0 ){
            lstCommunityTab = [Select Id, Name, Description__c, Community__c 
                               From Community_Tab__c 
                               Where Community__c =: lstCommunity[0].Id and Name =: sTabName];
                                   
            if(lstCommunityTab.size() > 0){
                lstCommunityContent = [Select Id, Name, Caption__c, Order__c, Tab__c, Type__c, Value__c 
                                       From Community_Content__c 
                                                Where Tab__c =: lstCommunityTab[0].Id Order By Order__c];
                                                    
                for(Community_Content__c cc: lstCommunityContent){
                    mapContents.put(cc.Name.toLowerCase(),cc);
                }                        
         }
  }
 }
}