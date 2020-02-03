global class CRMHelp_Controller {
    public static String searchHelpArticleJSON{get;set;}
    public String subject{get;set;}
    public String searchTerm{get;set;}
    public static String articleJSONString{get;set;}
    public static List<searchResultKA> lstSearchResultKAAll;
    global CRMHelp_Controller(){
        searchTerm = apexpages.currentpage().getparameters().get('subject');
    }
    
    @remoteaction
    global static String searchArticle(string searchTerm){
        map<Id,CRM_Help__c> mapallSearchedKAVs = new map<Id,CRM_Help__c>();
        lstSearchResultKAAll = new List<searchResultKA>();
        
        
        String searchStr1 = '*'+searchTerm+'*';
        
        String searchQuery = 'FIND \'' + searchStr1 + '\' IN ALL FIELDS RETURNING CRM_Help__c(Id,Category__c,Keywords__c,Resolution__c,Issue__c)';
        System.debug('searchQuery*****'+searchQuery);
        List<List <sObject>> lstOfLstKav = search.query(searchQuery);
        System.debug('lstOfLstKav*****'+lstOfLstKav);
        for(List<CRM_Help__c> lstKAVs : lstOfLstKav){
            for(CRM_Help__c instOfKav :  lstKAVs ){
                mapallSearchedKAVs.put(instOfKav.Id,instOfKav);
            }
        }
        System.debug('mapallSearchedKAVs*****'+mapallSearchedKAVs);
        searchResultKA instKA;
        
        for(CRM_Help__c instOfKAV : mapallSearchedKAVs.Values()){
            instKA = new searchResultKA(instOfKAV.Id,instOfKAV.Category__c,instOfKAV.Keywords__c,instOfKAV.Resolution__c,instOfKAV.Issue__c);
            lstSearchResultKAAll.add(instKA);
        }
        System.debug('lstSearchResultKAAll*****'+lstSearchResultKAAll);
        searchHelpArticleJSON =JSON.serializePretty(lstSearchResultKAAll);
        return searchHelpArticleJSON;
    }
    public class searchResultKA{
        public Id recordid{get;set;}
        public String category{get;set;} //latest Code
        public String keywords{get;set;}
        public String resolutions{get;set;}
        public String issue{get;set;}
        
        
        public searchResultKA(Id recordid, String category, String keywords,String resolutions,String issue){ //latest code
            this.recordid = recordid;
            this.category = category; //latest code
            this.keywords = keywords;
            this.resolutions = resolutions;
            this.issue = issue;
        }
    }
}