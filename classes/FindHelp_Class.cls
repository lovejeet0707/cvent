public class FindHelp_Class{
    public String searchTerm{get;set;}
    public static String articleJSONString{get;set;}
    public static List<searchResultKA> lstSearchResultKAAll{get;set;}

    public PageReference updateNoTrackerCount(){
        Id trackerId = apexpages.currentpage().getparameters().get('id');
        if(trackerId!=null){
            Case_Deflection_Track__c caseDeflectTrack = new Case_Deflection_Track__c(id=trackerId);
            caseDeflectTrack.No_I_found_my_Answer_Count__c = 1;
            update caseDeflectTrack;
            System.debug('trackerId**'+trackerId);
        }

        PageReference pr = new PageReference('/');
        pr.setRedirect(TRUE);
        return pr;
        
    }
    public PageReference updateTrackerCount(){
        Id trackerId = apexpages.currentpage().getparameters().get('id');
        String subject  = Apexpages.currentPage().getParameters().get('subject');
        String productType = Apexpages.currentPage().getParameters().get('productType');
        System.debug('trackerId********'+trackerId);
        if(trackerId!=null){
            Case_Deflection_Track__c caseDeflectTrack = new Case_Deflection_Track__c(id=trackerId);
            caseDeflectTrack.Yes__c = 1;
            update caseDeflectTrack;
            System.debug('trackerId**'+trackerId);
        }
        else{
            Case_Deflection_Track__c caseDeflectTrack = new Case_Deflection_Track__c();
            caseDeflectTrack.Yes__c = 1;
            insert caseDeflectTrack;
            trackerId = caseDeflectTrack.Id;
            System.debug('trackerId**'+trackerId);
        }
        
        String url = '/apex/CreateNewCase?Subject='+subject+'&prod='+productType+'&id='+trackerId;
        PageReference pr = new PageReference(url);
        pr.setRedirect(True);
        return pr;
    }
    @remoteaction
    public static string  actfast(String trackerId,string productType,String searchText){
        //Case Deflection Tracker Id from url....
        /*Id trackerId = apexpages.currentpage().getparameters().get('id'); */
        System.debug('trackerId********'+trackerId);
        if(String.isNotBlank(trackerId)){
            Case_Deflection_Track__c caseDeflectTrack = new Case_Deflection_Track__c(id=trackerId);
            caseDeflectTrack.Continue_Count__c = 1;
            update caseDeflectTrack;
            System.debug('trackerId**'+trackerId);
        }
        List<String> articleKavNames = new List<String>();
        Map<String,Schema.SOBjectType> gd = Schema.getGlobalDescribe();
        for(String s : gd.keySet()) {
            Schema.SObjectType objectType = gd.get(s);
            /*HSR : 13th April 2017 : Included isAccessible() so that it can be used to show only Cvent Article Types as these user profiles have access for these Articles ypes only in the Vf Page.*/
            Schema.DescribeSObjectResult drSObj = objectType.getDescribe();//Need to be commented in future
            if (s.contains('__kav') && drSObj.isAccessible()) {
                articleKavNames.add('\''+gd.get(s).getDescribe().getName()+'\'');
            }
        }
        String types = String.join(articleKavNames, ',');
        
        map<Id,KnowledgeArticleVersion> mapallSearchedKAVs = new map<Id,KnowledgeArticleVersion>();
        lstSearchResultKAAll = new List<searchResultKA>();
        System.debug('productType***********'+productType);
        
        if(productType=='Event__c' && Label.DeflectionEventManagement=='True')
        {
            productType = productType+',Event1Standard__c,Event2Flex__c,Event3Express__c';
        }
        String searchStr1 = '*'+searchText+'*';
        String english  = 'en_US';
        String statusKav = 'Online';
        String dataCategory = 'WITH DATA CATEGORY Products__c AT ('+productType+')';
        System.debug('dataCategory***********'+dataCategory);
        String searchQuery;
        if(!Test.isRunningTest())
        searchQuery = 'FIND \'' + searchStr1 + '\' IN ALL FIELDS RETURNING KnowledgeArticleVersion( Language,MasterVersionId ,Id,Title,Summary,UrlName,ArticleNumber,LastModifiedDate,FirstPublishedDate,LastPublishedDate,PublishStatus,KnowledgeArticleId,ArticleType where PublishStatus = : statusKav and Language=:english AND IsLatestVersion=true AND ArticleType IN ('+ types +'))'+dataCategory+'LIMIT 5';
        else
        searchQuery = 'FIND \'' + searchStr1 + '\' IN ALL FIELDS RETURNING KnowledgeArticleVersion( Language,MasterVersionId ,Id,Title,Summary,UrlName,ArticleNumber,LastModifiedDate,FirstPublishedDate,LastPublishedDate,PublishStatus,KnowledgeArticleId,ArticleType) LIMIT 5';
        System.debug('searchQuery*****'+searchQuery);
        List<List <sObject>> lstOfLstKav = search.query(searchQuery);
        System.debug('lstOfLstKav*****'+lstOfLstKav);
        for(List<KnowledgeArticleVersion> lstKAVs : lstOfLstKav){
            for(KnowledgeArticleVersion instOfKav :  lstKAVs ){
                mapallSearchedKAVs.put(instOfKav.Id,instOfKav);
            }
        }
        System.debug('mapallSearchedKAVs*****'+mapallSearchedKAVs);
        searchResultKA instKA;
        
        for(KnowledgeArticleVersion instOfKAV : mapallSearchedKAVs.Values()){
            instKA = new searchResultKA(instOfKAV.Id,instOfKAV.ArticleNumber,instOfKAV.Title,'Article',instOfKAV.UrlName,instOfKAV.ArticleType,instOfKAV.summary,instOfKAV.Language);
            lstSearchResultKAAll.add(instKA);
        }
        System.debug('lstSearchResultKAAll*****'+lstSearchResultKAAll);
        articleJSONString =JSON.serializePretty(lstSearchResultKAAll);
        return articleJSONString ;
    }
    public class searchResultKA{
        public Id recordid{get;set;}
        public String articleNum{get;set;} //latest Code
        public String Name{get;set;}
        public String Type{get;set;}
        public String ratingLink{get;set;}
        public Integer doubKAVs{get;set;}
        public String articleType{get;set;}
        //public Boolean show{get;set;}
        public String strSummary{get;set;}
        public String Lang{get;set;}
        public Set<String> productSet{get;set;}
        public String product{get;set;}
        public String articleTypeSec{get;set;}
        public searchResultKA(Id recordid, String articleNum, String Name,String Type,String articleType,String articleTypeSec,String strSummary,String Lang){ //latest code
            productSet = new Set<String>();
            this.recordid = recordid;
            this.articleNum = articleNum; //latest code
            this.Name = Name;
            this.Type = Type;
            this.ratingLink = ratingLink;
            this.doubKAVs = doubKAVs;  
            this.articleType = articleType;
            this.articleTypeSec = articleTypeSec;
            //this.show = show;
            this.strSummary = strSummary;
            this.Lang = Lang;
            this.product = product;
        }
    }
}