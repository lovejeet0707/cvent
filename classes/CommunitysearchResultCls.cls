/*
//////////////////////////////////////
//      @author Abhishek Pandey     //
/////////////////////////////////////
Version :   1.0
Date : 7th April 2015
Description-Test Class Name-CommunitysearchResultClsTest
            Page Name-CommunitysearchResultPage
Version : 2.0
Dated : 22 Nov 2015
Description-Release Notes Article type enhancement 
*/
public class CommunitysearchResultCls {

    public string searchfor{get;set;}
    public List<searchResultKA> lstSearchResultKA{get;set;}
    public List<searchResultKA> lstSearchResultKAAll{get;set;}
    public List<searchResultQ> lstSearchResultQ{get;set;}
    public List<searchResultQ> lstSearchResultQAll{get;set;}
    public List<productCatCount> lstProdCatCount{get;set;}
    public List<articleTypeCount> lstarticleTypeCount{get;set;}
    public List<String> lstLang{get;set;}
    public List<LangCount> lstLangCount{get;set;}
    public Boolean boolforTest{get;set;}
    public List<searchResultKA> lstSearchResultKAAllCls = new List<searchResultKA>();
    public List<searchResultQ> lstSearchResultQAllCls = new List<searchResultQ>();
    
    
    public Integer totalResults{get;set;}
    public map<Id,KnowledgeArticleVersion> mapallSearchedKAVs = new map<Id,KnowledgeArticleVersion>();
    public map<String,String> mapOfConvertedGerm = new map<String,String>();
    public map<Id,Question> mapallSearchedQues = new map<Id,Question>();
    
    public map<string,Set<Id>> mapProdCatCount = new map<string,Set<Id>>();
    public map<string,Set<Id>> mapKAVType = new map<string,Set<Id>>();
    
    public map<String,List<Id>> mapProdCatCountQues = new map<String,List<Id>>();
    public String idOfVal{get;set;}
    public Boolean articleFlag;
    public Boolean quesFlag;
    public String viewAllVar{get;set;}
    public Integer articleSize{get;set;}
    public Integer quesSize{get;set;}
    public static Set<String> kavNames = new Set<String>();
    public static Map<String,Schema.SOBjectType> gd = Schema.getGlobalDescribe();
    public static Map<String,Schema.DescribeSObjectResult> kavObjPrefixMap = new Map<String,Schema.DescribeSObjectResult>();
    public static map<String,String> mapArticleTypeName{get;set;}
    public String productSel{get;set;}
    public String articleTypeSel{get;set;}
    public String langSel{get;set;}
    public Boolean showKav{get;set;}
    public Boolean showQues{get;set;}
    public String Lang{get;set;}
    
    public static map<String,List<searchResultKA>> mapArtTypeSec = new map<String,List<searchResultKA>>();
    public static Set<String> lstId = new Set<String>();
    
    public static map<String,String> mapprodCatNameLabel = new map<String,String>();
    public static List<String> lstProdCat = new List<String>();
    //public static map<String,String> mapLangCode = new map<String,String>();
    
    static{
        //Language addition
        
        //Language addition
        gd = Schema.getGlobalDescribe();
        for(String s : gd.keySet()) {
            if (s.contains('__kav')) {
                kavNames.add(s);
            }
        }
        
        mapArticleTypeName = new Map<String,String>();
        Schema.DescribeSObjectResult sor;
        for (String s : kavNames) {
            //system.debug(s);
            sor = gd.get(s).getDescribe();
            //system.debug(sor);
            mapArticleTypeName.put(sor.getName(),sor.getLabel());
            //system.debug(mapArticleTypeName);
            kavObjPrefixMap.put(sor.getKeyPrefix().toLowerCase(), sor);
            //system.debug(sor.getKeyPrefix().toLowerCase());
        }
        //system.debug('mapArticleTypeName******************'+mapArticleTypeName);
        
        List<DescribeDataCategoryGroupResult> describeCategoryResult;
        List<DescribeDataCategoryGroupStructureResult> describeCategoryStructureResult;
        List<String> objType = new List<String>();
        objType.add('KnowledgeArticleVersion');
        describeCategoryResult = Schema.describeDataCategoryGroups(objType);
        List<DataCategoryGroupSobjectTypePair> pairs = new List<DataCategoryGroupSobjectTypePair>();
        for(DescribeDataCategoryGroupResult singleResult : describeCategoryResult){
            DataCategoryGroupSobjectTypePair p = new DataCategoryGroupSobjectTypePair();
            p.setSobject(singleResult.getSobject());
            p.setDataCategoryGroupName(singleResult.getName());
            pairs.add(p);
        }
        describeCategoryStructureResult = Schema.describeDataCategoryGroupStructures(pairs, false);
        
        for(DescribeDataCategoryGroupStructureResult singleResult : describeCategoryStructureResult){
            //system.debug(singleResult.getName());
            DataCategory [] toplevelCategories = singleResult.getTopCategories();
            List<DataCategory> allCategories = getAllCategories(toplevelCategories);
            for(DataCategory category : allCategories) {
                DataCategory [] childCategories = category.getChildCategories();
                for(DataCategory instDataCat : childCategories){
                    //system.debug(instDataCat.getlabel());
                    //system.debug(instDataCat.getName());
                    mapprodCatNameLabel.put(instDataCat.getName(),instDataCat.getlabel());
                    lstProdCat.add(instDataCat.getName());
                }
            }
        }
        //system.debug(lstProdCat);
        lstProdCat.Sort();
        
    }
    
    public static DataCategory[] getAllCategories(DataCategory [] categories){
        if(categories.isEmpty()){
            return new DataCategory[]{};
        } else {
            DataCategory [] categoriesClone = categories.clone();
            DataCategory category = categoriesClone[0];
            DataCategory[] allCategories = new DataCategory[]{category};
            categoriesClone.remove(0);
            categoriesClone.addAll(category.getChildCategories());
            allCategories.addAll(getAllCategories(categoriesClone));
            return allCategories;
        }
    }    
    public CommunitysearchResultCls(){
        showKav = true;
        showQues = true;
        productSel = '';
        articleTypeSel = '';
        langSel = '';
        lstLang = new List<String>();
        Lang= '';
        boolforTest= true;
        lstSearchResultQ = new List<searchResultQ>();
        lstSearchResultKA = new List<searchResultKA>();
        lstSearchResultKAAll = new List<searchResultKA>();
        lstProdCatCount = new List<productCatCount>();
        lstarticleTypeCount = new List<articleTypeCount>();
        lstSearchResultQAll = new List<searchResultQ>();
        lstLangCount = new List<LangCount>();
        idOfVal = '';
        mapallSearchedKAVs = new map<Id,KnowledgeArticleVersion>();
        mapOfConvertedGerm = new map<String,String>();
        searchResultKA instKA;
        searchResultQ instQL;
        searchFor ='';
        totalResults  = 0;
        articleSize = 0;
        quesSize = 0;
        LangCount instLangCount;
        
        searchFor = ApexPages.currentPage().getParameters().get('searchFor');
        
        
       // system.debug('searchFor++'+searchFor);
        User u=[SELECT LanguageLocaleKey  from user where id =:userinfo.getUserId() limit 1];
        Lang=u.LanguageLocaleKey;
        System.debug('Lang********'+Lang);
        //String strLike= '%'+String.escapeSingleQuotes(searchFor) + '%';
        //String lang = 'en_US';
        //Language addition
        //lang = ApexPages.currentPage().getParameters().get('Lang');
        
        //Language addition
        
        //List<KnowledgeArticleVersion> lstKAV = [SELECT id,Title,Summary,UrlName,ArticleNumber,LastModifiedDate,FirstPublishedDate,LastPublishedDate,Language,PublishStatus,KnowledgeArticleId FROM KnowledgeArticleVersion WHERE (Title like : strLike ) AND PublishStatus='Online' AND Language = :'en_US' LIMIT 200];
        
        ////String selectedLanguage;
        //selectedLanguage = mapLangCode.get(ApexPages.currentPage().getParameters().get('Lang'));
        //Lang = selectedLanguage ;
        String p = '';
        String statusKav = 'Online';
        String escapedQ = String.escapeSingleQuotes(searchFor);
        //String strLike = String.escapeSingleQuotes(searchFor);
        List<String> lstLangSec = new List<String>();
        String german ='de';
        String english='en_US';
        if(Test.isRunningTest())
            KnowledgeArticleVersion instKAV = [SELECT ID,PublishStatus FROM KnowledgeArticleVersion WHERE PublishStatus='Online' AND Language = 'en_US' AND IsLatestVersion=true LIMIT 1 ];
        
        p += 'FIND \'' + escapedQ + '*\' IN ALL FIELDS RETURNING KnowledgeArticleVersion( Language,Id,Title,Summary,UrlName,ArticleNumber,LastModifiedDate,FirstPublishedDate,LastPublishedDate,PublishStatus,KnowledgeArticleId,ArticleType where PublishStatus = : statusKav and Language=:english AND IsLatestVersion=true LIMIT 125) ';
        List<List<SObject>> lstOfLstKav = Search.query(p);
        
        p = '';
        p += 'FIND \'' + escapedQ + '*\' IN ALL FIELDS RETURNING KnowledgeArticleVersion( Language,MasterVersionId ,Id,Title,Summary,UrlName,ArticleNumber,LastModifiedDate,FirstPublishedDate,LastPublishedDate,PublishStatus,KnowledgeArticleId,ArticleType where PublishStatus = : statusKav and Language=:german AND IsLatestVersion=true LIMIT 125) ';
        List<List<SObject>> lstOfLstKavSec = Search.query(p);
        String q = '';
        
        q += 'FIND \'' + escapedQ + '*\' IN ALL FIELDS RETURNING Question(Id,Title,Body, NumReplies,BestReply.Name,LastReplyDate LIMIT 250)';        
        List<List<SObject>> lstQues = Search.query(q);
        Boolean bestAns = false;
        Set<Id> setQuesId = new Set<Id>();
        Integer counter= 0;
        for(List<Question> instOfQues :lstQues){
            for(Question instOFquesSec : instOfQues){
                counter++;
                bestAns = false;
                mapallSearchedQues.put(instOFquesSec.Id,instOFquesSec);
                setQuesId.add(instOFquesSec.Id);
                //system.debug('instOFquesSec+++'+instOFquesSec);
                if(instOFquesSec.BestReplyId != null)
                bestAns = true;
                
                instQL = new  searchResultQ(instOFquesSec.Id,instOFquesSec.Title,instOFquesSec.LastReplyDate,instOFquesSec.NumReplies,bestAns,'Question');
                if(counter<21)
                lstSearchResultQ.add(instQL);

                lstSearchResultQAll.add(instQL);
            }
        }
        //lstSearchResultQAll.addAll(lstSearchResultQ);
        
        Set<Id> setIdKav = new Set<Id>(); 
        List<String> articleType = new List<String>();
        List<KnowledgeArticleVersion> lstKAV = new List<KnowledgeArticleVersion>();
        
        Set<Id> idOfKAVS =  new Set<Id>();
        map<Id,Id> mapKAKAV = new map<Id,Id>();
        
        //To reduce execution time
        //To reduct execution time
        lstLangCount = new List<LangCount>();
        
        Integer counterr=0;
        for(List<KnowledgeArticleVersion> lstKAVs : lstOfLstKav){
            counter=0;
            for(KnowledgeArticleVersion instOfKav :  lstKAVs ){
                counterr++;
                mapallSearchedKAVs.put(instOfKav.Id,instOfKav);
                setIdKav.add(instOfKav.Id); 
                articleType.add(instOfKav.articleType);
                lstKAV.add(instOfKav); 
                idOfKAVS.add(instOfKav.KnowledgeArticleId);
                mapKAKAV.put(instOfKav.id,instOfKav.KnowledgeArticleId);
            }
        }
        instLangCount = new LangCount(System.Label.English,'en_US',counterr);
        lstLangCount.add(instLangCount);
        
        for(List<KnowledgeArticleVersion> lstKAVs : lstOfLstKavSec){
            counterr=0;
            for(KnowledgeArticleVersion instOfKav :  lstKAVs ){
                counterr++;
                //system.debug(instOfKav.Id);
                //system.debug(instOfKav.articleType);
                mapallSearchedKAVs.put(instOfKav.Id,instOfKav);
                mapOfConvertedGerm.put(instOfKav.MasterVersionId,instOfKav.Id);
                setIdKav.add(instOfKav.MasterVersionId); 
                articleType.add(instOfKav.articleType);
                lstKAV.add(instOfKav); 
                idOfKAVS.add(instOfKav.KnowledgeArticleId);
                mapKAKAV.put(instOfKav.id,instOfKav.KnowledgeArticleId);
            }
        }
        instLangCount = new LangCount(System.Label.German,'de',counterr);
        lstLangCount.add(instLangCount);
        
        map<Integer,string> mapRating = new map<Integer,string>();
        mapRating.put(0,'/img/samples/stars_000.gif');
        mapRating.put(1,'/img/samples/stars_100.gif');
        mapRating.put(2,'/img/samples/stars_200.gif');
        mapRating.put(3,'/img/samples/stars_300.gif');
        mapRating.put(4,'/img/samples/stars_400.gif');
        mapRating.put(5,'/img/samples/stars_500.gif');
        
        //Set<Id> idOfKAVS =  new Set<Id>();
        //for(Id instOKAV :setIdKav){
            //system.debug('instOKAV+++'+instOKAV);
            //idOfKAVS.add(instOKAV);
        //}
        
        //List<KnowledgeArticleViewStat> lstOFKAVS = [SELECT ViewCount,ParentId FROM KnowledgeArticleViewStat WHERE ParentId=: idOfKAVS];
        //map<Id,Integer> mapofKAVS = new map<Id,Integer>();
        
        //for(KnowledgeArticleViewStat instOfKAVS : lstOFKAVS){
            //mapofKAVS.put(instOfKAVS.ParentId,instOfKAVS.ViewCount);
        //}
        map<Id,Integer> mapofKAVS = viewStatKav(idOfKAVS);
        map<Id,Double> mapofKAVoS = voteStatKav(idOfKAVS);
        
        //List<KnowledgeArticleVoteStat> lstKAVoS = [SELECT NormalizedScore,ParentId FROM KnowledgeArticleVoteStat WHERE ParentId=: idOfKAVS];
        //map<Id,Double> mapofKAVoS = new map<Id,Double>();
        //for(KnowledgeArticleVoteStat instOfKAVoS : lstKAVoS){
            //mapofKAVoS.put(instOfKAVoS.ParentId,instOfKAVoS.NormalizedScore);
        //}
        
        Integer doubKAoVS = 0;
        Integer doubKAVs = 0; 
        counter= 0;
        
        for(KnowledgeArticleVersion instOfKAV : lstKAV){
            
            if(mapKAVType.containsKey(instOfKAV.ArticleType)){
                Set<Id> lstKavSec = mapKAVType.get(instOfKAV.ArticleType);
                lstKavSec.add(instOfKAV.Id);
                mapKAVType.put(instOfKAV.ArticleType,lstKavSec);
            }else{
                Set<Id> lstKavSec = new Set<Id>();
                lstKavSec.add(instOfKAV.Id);
                mapKAVType.put(instOfKAV.ArticleType,lstKavSec);
            }
            doubKAoVS = 0;
            doubKAVs = 0; 
            //system.debug('instOfKAV+++'+instOfKAV.Id);
            counter++;
            //if(mapofKAVoS.containskey(instOfKAV.Id))
            //doubKAoVS  = Integer.valueOf(mapofKAVoS.get(instOfKAV.Id));
            //system.debug('instOfKAV.Id+++'+instOfKAV.Id);
            //system.debug('mapKAKAV.containsKey(instOfKAV.Id)+++'+mapKAKAV.containsKey(instOfKAV.Id));
            if(mapKAKAV.containsKey(instOfKAV.Id)){
                //system.debug('mapofKAVS.containsKey(mapKAKAV.get(instOfKAV.Id))++++'+mapofKAVS.containsKey(mapKAKAV.get(instOfKAV.Id)));
                if(mapofKAVS.containsKey(mapKAKAV.get(instOfKAV.Id))){
                    //system.debug('mapofKAVoS.get(mapKAKAV.get(instOfKAV.Id))+++'+mapofKAVoS.get(mapKAKAV.get(instOfKAV.Id)));
                    doubKAoVS  = Integer.valueOf(mapofKAVoS.get(mapKAKAV.get(instOfKAV.Id)));
                }
            }
            
            if(mapKAKAV.containsKey(instOfKAV.Id)){
                if(mapofKAVS.containsKey(mapKAKAV.get(instOfKAV.Id)))
                doubKAVs = Integer.valueOf(mapofKAVS.get(mapKAKAV.get(instOfKAV.Id)));
            }
            
            //if(mapofKAVS.containsKey(instOfKAV.Id))
            //doubKAVs = mapofKAVS.get(instOfKAV.Id);
            
            String ratingLink = mapRating.get(doubKAoVS);
            
            //system.debug('doubKAVs++'+doubKAVs);
            //system.debug('doubKAoVS++'+doubKAoVS);
            //system.debug('mapArticleTypeName++'+mapArticleTypeName);
            //system.debug('instOfKAV.ArticleType++'+instOfKAV.ArticleType);
            String tempArticleType;
            if(Lang=='de')
            {
                System.debug('Inside If');
                if(mapArticleTypeName.get(instOfKAV.ArticleType)=='Release Notes')
                    tempArticleType  = System.Label.Release_Notes;
                else if(mapArticleTypeName.get(instOfKAV.ArticleType)=='Topic Hub')
                    tempArticleType  = System.Label.Topic_Hub;
                else if(mapArticleTypeName.get(instOfKAV.ArticleType)=='Video')
                    tempArticleType  = System.Label.Video;
                else if(mapArticleTypeName.get(instOfKAV.ArticleType)=='Troubleshooting')
                    tempArticleType  = System.Label.Troubleshooting;
                else if(mapArticleTypeName.get(instOfKAV.ArticleType)=='Instructions')
                    tempArticleType  = System.Label.Instructions;
                else if(mapArticleTypeName.get(instOfKAV.ArticleType)=='FAQ')
                    tempArticleType  = System.Label.FAQ;
                else if(mapArticleTypeName.get(instOfKAV.ArticleType)=='Download')
                    tempArticleType  = System.Label.Download;
            }
            else
            {
                tempArticleType=mapArticleTypeName.get(instOfKAV.ArticleType);
            }
            
            instKA = new  searchResultKA(instOfKAV.Id,instOfKAV.ArticleNumber,instOfKAV.Title,ratingLink,doubKAVs,'Article',tempArticleType,instOfKAV.summary,instOfKAV.Language);
            if(counter<21)
            lstSearchResultKA.add(instKA);
            
            lstSearchResultKAAll.add(instKA);
        }
        //lstSearchResultKAAll.addAll(lstSearchResultKA);
        articleTypeCount instOfarticleTypeCount;
        
        for(String instOfKAV : mapArticleTypeName.KeySet()){
           Integer count = 0;
           //system.debug(instOfKAV);
           if(mapKAVType.containsKey(instOfKAV)){
               system.debug('instOfKAV+++'+instOfKAV);
               count = mapKAVType.get(instOfKAV).size();
                //instLangCount = new LangCount(System.Label.English,'en_US',counterr);
                //instLangCount = new LangCount(System.Label.German,'de',counterr);
                //System.debug('mapArticleTypeName.get(instOfKAV)**********'+mapArticleTypeName.get(instOfKAV));
                if(Lang=='de')
                {
                    if(mapArticleTypeName.get(instOfKAV)=='Release Notes')
                        instOfarticleTypeCount = new articleTypeCount(System.Label.Release_Notes,count,instOfKAV,true);
                    else if(mapArticleTypeName.get(instOfKAV)=='Topic Hub')
                        instOfarticleTypeCount = new articleTypeCount(System.Label.Topic_Hub,count,instOfKAV,true);
                    else if(mapArticleTypeName.get(instOfKAV)=='Video')
                        instOfarticleTypeCount = new articleTypeCount(System.Label.Video,count,instOfKAV,true);
                    else if(mapArticleTypeName.get(instOfKAV)=='Troubleshooting')
                        instOfarticleTypeCount = new articleTypeCount(System.Label.Troubleshooting,count,instOfKAV,true);
                    else if(mapArticleTypeName.get(instOfKAV)=='Instructions')
                        instOfarticleTypeCount = new articleTypeCount(System.Label.Instructions,count,instOfKAV,true);
                    else if(mapArticleTypeName.get(instOfKAV)=='FAQ')
                        instOfarticleTypeCount = new articleTypeCount(System.Label.FAQ,count,instOfKAV,true);
                    else if(mapArticleTypeName.get(instOfKAV)=='Download')
                        instOfarticleTypeCount = new articleTypeCount(System.Label.Download,count,instOfKAV,true);
                    /*else{
                        String tempVar=mapArticleTypeName.get(instOfKAV);
                        instOfarticleTypeCount = new articleTypeCount(System.Label.tempVar,count,instOfKAV,true);
                    }*/
                }
                else{
                    instOfarticleTypeCount = new articleTypeCount(mapArticleTypeName.get(instOfKAV),count,instOfKAV,true);
                }
               lstarticleTypeCount.add(instOfarticleTypeCount);
           }else{
               //System.debug('mapArticleTypeName.get(instOfKAV)ELSE**********'+mapArticleTypeName.get(instOfKAV));
               if(Lang=='de')
                {
                    if(mapArticleTypeName.get(instOfKAV)=='Release Notes')
                        instOfarticleTypeCount = new articleTypeCount(System.Label.Release_Notes,count,instOfKAV,true);
                    else if(mapArticleTypeName.get(instOfKAV)=='Topic Hub')
                        instOfarticleTypeCount = new articleTypeCount(System.Label.Topic_Hub,count,instOfKAV,true);
                    else if(mapArticleTypeName.get(instOfKAV)=='Video')
                        instOfarticleTypeCount = new articleTypeCount(System.Label.Video,count,instOfKAV,true);
                    else if(mapArticleTypeName.get(instOfKAV)=='Troubleshooting')
                        instOfarticleTypeCount = new articleTypeCount(System.Label.Troubleshooting,count,instOfKAV,true);
                    else if(mapArticleTypeName.get(instOfKAV)=='Instructions')
                        instOfarticleTypeCount = new articleTypeCount(System.Label.Instructions,count,instOfKAV,true);
                    else if(mapArticleTypeName.get(instOfKAV)=='FAQ')
                        instOfarticleTypeCount = new articleTypeCount(System.Label.FAQ,count,instOfKAV,true);
                    else if(mapArticleTypeName.get(instOfKAV)=='Download')
                        instOfarticleTypeCount = new articleTypeCount(System.Label.Download,count,instOfKAV,true);
                    /*else{
                        String tempVar=mapArticleTypeName.get(instOfKAV);
                        instOfarticleTypeCount = new articleTypeCount(System.Label.tempVar,count,instOfKAV,true);
                    }*/
                }
                else{
                    instOfarticleTypeCount = new articleTypeCount(mapArticleTypeName.get(instOfKAV),0,instOfKAV,true);
                }
               lstarticleTypeCount.add(instOfarticleTypeCount);
           }
        }
        
        List<String> lstNameSec = new List<String>();
        for(articleTypeCount instOfProdCat : lstarticleTypeCount){
            if(instOfProdCat!=null)
            lstNameSec.add(instOfProdCat.Name);
        }
        lstNameSec.sort();
        List<articleTypeCount> lstarticleTypeCountSec = new List<articleTypeCount>();
        for(String strName : lstNameSec){
            for(articleTypeCount instOfProdCat : lstarticleTypeCount){
                if(strName == instOfProdCat.Name){
                    instOfarticleTypeCount = new articleTypeCount(instOfProdCat.Name,instOfProdCat.Count,instOfProdCat.apiName,instOfProdCat.show);
                    lstarticleTypeCountSec.add(instOfarticleTypeCount);
                }
            }
        }
        lstarticleTypeCount = new List<articleTypeCount>();
        lstarticleTypeCount.addAll(lstarticleTypeCountSec);
        
        totalResults = lstSearchResultKAAll.size() + lstSearchResultQAll.size();
        articleSize = lstSearchResultKAAll.size();
        quesSize = lstSearchResultQAll.size();
        
        lstSearchResultKAAllCls.addAll(lstSearchResultKAAll);
        lstSearchResultQAllCls.addAll(lstSearchResultQAll);
        
        //system.debug('setIdKav++'+setIdKav);
        //system.debug('mapallSearchedKAVs++'+mapallSearchedKAVs);
        //system.debug('mapOfConvertedGerm++'+mapOfConvertedGerm);
        List<Download__DataCategorySelection> lstDownloadDCS =[SELECT Id,DataCategoryName,DataCategoryGroupName, ParentId FROM Download__DataCategorySelection WHERE ParentId =: setIdKav];
        List<FAQ__DataCategorySelection> lstFAQDCS  = [SELECT Id,DataCategoryName, DataCategoryGroupName,ParentId FROM FAQ__DataCategorySelection WHERE ParentId =: setIdKav];
        List<Instructions__DataCategorySelection> lstInstructionsDCS =[SELECT Id,DataCategoryName,DataCategoryGroupName, ParentId FROM Instructions__DataCategorySelection WHERE ParentId =: setIdKav];
        List<Marketing_Materials__DataCategorySelection> lstMarkMDCS =[SELECT Id,DataCategoryName,DataCategoryGroupName, ParentId FROM Marketing_Materials__DataCategorySelection WHERE ParentId =: setIdKav];
        List<Topic_Hub__DataCategorySelection> lstTopicHDCS =[SELECT Id,DataCategoryName, DataCategoryGroupName,ParentId FROM Topic_Hub__DataCategorySelection WHERE ParentId =: setIdKav];
        List<Video__DataCategorySelection> lstVideoDDCS =[SELECT Id,DataCategoryName, DataCategoryGroupName,ParentId FROM Video__DataCategorySelection WHERE ParentId =: setIdKav];
        List<Release_Notes__DataCategorySelection> lstReleaseNotes =[SELECT Id,DataCategoryName, DataCategoryGroupName,ParentId FROM Release_Notes__DataCategorySelection WHERE ParentId =: setIdKav];
        
        for(Download__DataCategorySelection instDownloadDCS : lstDownloadDCS){
            if(mapallSearchedKAVs.containsKey(instDownloadDCS.ParentId)){
                if(mapProdCatCount.containsKey(instDownloadDCS.DataCategoryName)){
                    Set<Id> idOfArt = mapProdCatCount.get(instDownloadDCS.DataCategoryName);
                    idOfArt.add(instDownloadDCS.parentId);
                    mapProdCatCount.put(instDownloadDCS.DataCategoryName,idOfArt);
                }else{
                    Set<Id> idOfArt = new Set<Id>();
                    idOfArt.add(instDownloadDCS.parentId);
                    mapProdCatCount.put(instDownloadDCS.DataCategoryName,idOfArt);        
                } 
            }
            if(mapOfConvertedGerm.containsKey(instDownloadDCS.ParentId)){
                if(mapProdCatCount.containsKey(instDownloadDCS.DataCategoryName)){
                   // system.debug(mapProdCatCount);
                    Set<Id> idOfArt = mapProdCatCount.get(instDownloadDCS.DataCategoryName);
                    //system.debug(idOfArt);
                    //system.debug(mapOfConvertedGerm.get(instDownloadDCS.parentId));
                    idOfArt.add(mapOfConvertedGerm.get(instDownloadDCS.parentId));
                    //system.debug(idOfArt);
                    mapProdCatCount.put(instDownloadDCS.DataCategoryName,idOfArt);
                    //system.debug(mapProdCatCount);
                }else{
                    Set<Id> idOfArt = new Set<Id>();
                    idOfArt.add(mapOfConvertedGerm.get(instDownloadDCS.parentId));
                    mapProdCatCount.put(instDownloadDCS.DataCategoryName,idOfArt);        
                } 
            }
        }
        
        for(FAQ__DataCategorySelection instDownloadDCS : lstFAQDCS){
            if(mapallSearchedKAVs.containsKey(instDownloadDCS.ParentId)){
                if(mapProdCatCount.containsKey(instDownloadDCS.DataCategoryName)){
                    Set<Id> idOfArt = mapProdCatCount.get(instDownloadDCS.DataCategoryName);
                    idOfArt.add(instDownloadDCS.parentId);
                    mapProdCatCount.put(instDownloadDCS.DataCategoryName,idOfArt);
                }else{
                    Set<Id> idOfArt = new Set<Id>();
                    idOfArt.add(instDownloadDCS.parentId);
                    mapProdCatCount.put(instDownloadDCS.DataCategoryName,idOfArt);        
                } 
            }
            if(mapOfConvertedGerm.containsKey(instDownloadDCS.ParentId)){
                if(mapProdCatCount.containsKey(instDownloadDCS.DataCategoryName)){
                    Set<Id> idOfArt = mapProdCatCount.get(instDownloadDCS.DataCategoryName);
                    idOfArt.add(mapOfConvertedGerm.get(instDownloadDCS.parentId));
                    mapProdCatCount.put(instDownloadDCS.DataCategoryName,idOfArt);
                }else{
                    Set<Id> idOfArt = new Set<Id>();
                    idOfArt.add(mapOfConvertedGerm.get(instDownloadDCS.parentId));
                    mapProdCatCount.put(instDownloadDCS.DataCategoryName,idOfArt);        
                } 
            }
        }
        
        for(Instructions__DataCategorySelection instDownloadDCS : lstInstructionsDCS){
            if(mapallSearchedKAVs.containsKey(instDownloadDCS.ParentId)){
                if(mapProdCatCount.containsKey(instDownloadDCS.DataCategoryName)){
                    Set<Id> idOfArt = mapProdCatCount.get(instDownloadDCS.DataCategoryName);
                    idOfArt.add(instDownloadDCS.parentId);
                    mapProdCatCount.put(instDownloadDCS.DataCategoryName,idOfArt);
                }else{
                    Set<Id> idOfArt = new Set<Id>();
                    idOfArt.add(instDownloadDCS.parentId);
                    mapProdCatCount.put(instDownloadDCS.DataCategoryName,idOfArt);        
                } 
            }
            if(mapOfConvertedGerm.containsKey(instDownloadDCS.ParentId)){
                if(mapProdCatCount.containsKey(instDownloadDCS.DataCategoryName)){
                    Set<Id> idOfArt = mapProdCatCount.get(instDownloadDCS.DataCategoryName);
                    idOfArt.add(mapOfConvertedGerm.get(instDownloadDCS.parentId));
                    mapProdCatCount.put(instDownloadDCS.DataCategoryName,idOfArt);
                }else{
                    Set<Id> idOfArt = new Set<Id>();
                    idOfArt.add(mapOfConvertedGerm.get(instDownloadDCS.parentId));
                    mapProdCatCount.put(instDownloadDCS.DataCategoryName,idOfArt);        
                } 
            }
        }
        
        for(Marketing_Materials__DataCategorySelection instDownloadDCS : lstMarkMDCS){
            if(mapallSearchedKAVs.containsKey(instDownloadDCS.ParentId)){
                if(mapProdCatCount.containsKey(instDownloadDCS.DataCategoryName)){
                    Set<Id> idOfArt = mapProdCatCount.get(instDownloadDCS.DataCategoryName);
                    idOfArt.add(instDownloadDCS.parentId);
                    mapProdCatCount.put(instDownloadDCS.DataCategoryName,idOfArt);
                }else{
                    Set<Id> idOfArt = new Set<Id>();
                    idOfArt.add(instDownloadDCS.parentId);
                    mapProdCatCount.put(instDownloadDCS.DataCategoryName,idOfArt);        
                } 
            }
            if(mapOfConvertedGerm.containsKey(instDownloadDCS.ParentId)){
                if(mapProdCatCount.containsKey(instDownloadDCS.DataCategoryName)){
                    Set<Id> idOfArt = mapProdCatCount.get(instDownloadDCS.DataCategoryName);
                    idOfArt.add(mapOfConvertedGerm.get(instDownloadDCS.parentId));
                    mapProdCatCount.put(instDownloadDCS.DataCategoryName,idOfArt);
                }else{
                    Set<Id> idOfArt = new Set<Id>();
                    idOfArt.add(mapOfConvertedGerm.get(instDownloadDCS.parentId));
                    mapProdCatCount.put(instDownloadDCS.DataCategoryName,idOfArt);        
                } 
            }
        }
        
        for(Topic_Hub__DataCategorySelection instDownloadDCS : lstTopicHDCS){
            if(mapallSearchedKAVs.containsKey(instDownloadDCS.ParentId)){
                if(mapProdCatCount.containsKey(instDownloadDCS.DataCategoryName)){
                    Set<Id> idOfArt = mapProdCatCount.get(instDownloadDCS.DataCategoryName);
                    idOfArt.add(instDownloadDCS.parentId);
                    mapProdCatCount.put(instDownloadDCS.DataCategoryName,idOfArt);
                }else{
                    Set<Id> idOfArt = new Set<Id>();
                    idOfArt.add(instDownloadDCS.parentId);
                    mapProdCatCount.put(instDownloadDCS.DataCategoryName,idOfArt);        
                } 
            }
            if(mapOfConvertedGerm.containsKey(instDownloadDCS.ParentId)){
                if(mapProdCatCount.containsKey(instDownloadDCS.DataCategoryName)){
                    Set<Id> idOfArt = mapProdCatCount.get(instDownloadDCS.DataCategoryName);
                    idOfArt.add(mapOfConvertedGerm.get(instDownloadDCS.parentId));
                    mapProdCatCount.put(instDownloadDCS.DataCategoryName,idOfArt);
                }else{
                    Set<Id> idOfArt = new Set<Id>();
                    idOfArt.add(mapOfConvertedGerm.get(instDownloadDCS.parentId));
                    mapProdCatCount.put(instDownloadDCS.DataCategoryName,idOfArt);        
                } 
            }
        }
        
        for(Video__DataCategorySelection instDownloadDCS : lstVideoDDCS){
            if(mapallSearchedKAVs.containsKey(instDownloadDCS.ParentId)){
                if(mapProdCatCount.containsKey(instDownloadDCS.DataCategoryName)){
                    Set<Id> idOfArt = mapProdCatCount.get(instDownloadDCS.DataCategoryName);
                    idOfArt.add(instDownloadDCS.parentId);
                    mapProdCatCount.put(instDownloadDCS.DataCategoryName,idOfArt);
                }else{
                    Set<Id> idOfArt = new Set<Id>();
                    idOfArt.add(instDownloadDCS.parentId);
                    mapProdCatCount.put(instDownloadDCS.DataCategoryName,idOfArt);        
                } 
            }
            if(mapOfConvertedGerm.containsKey(instDownloadDCS.ParentId)){
                if(mapProdCatCount.containsKey(instDownloadDCS.DataCategoryName)){
                    Set<Id> idOfArt = mapProdCatCount.get(instDownloadDCS.DataCategoryName);
                    idOfArt.add(mapOfConvertedGerm.get(instDownloadDCS.parentId));
                    mapProdCatCount.put(instDownloadDCS.DataCategoryName,idOfArt);
                }else{
                    Set<Id> idOfArt = new Set<Id>();
                    idOfArt.add(mapOfConvertedGerm.get(instDownloadDCS.parentId));
                    mapProdCatCount.put(instDownloadDCS.DataCategoryName,idOfArt);        
                } 
            }
        }
        for(Release_Notes__DataCategorySelection instReleaseNote : lstReleaseNotes){
            if(mapallSearchedKAVs.containsKey(instReleaseNote.ParentId)){
                if(mapProdCatCount.containsKey(instReleaseNote.DataCategoryName)){
                    Set<Id> idOfArt = mapProdCatCount.get(instReleaseNote.DataCategoryName);
                    idOfArt.add(instReleaseNote.parentId);
                    mapProdCatCount.put(instReleaseNote.DataCategoryName,idOfArt);
                }else{
                    Set<Id> idOfArt = new Set<Id>();
                    idOfArt.add(instReleaseNote.parentId);
                    mapProdCatCount.put(instReleaseNote.DataCategoryName,idOfArt);        
                } 
            }
            if(mapOfConvertedGerm.containsKey(instReleaseNote.ParentId)){
                if(mapProdCatCount.containsKey(instReleaseNote.DataCategoryName)){
                    Set<Id> idOfArt = mapProdCatCount.get(instReleaseNote.DataCategoryName);
                    idOfArt.add(mapOfConvertedGerm.get(instReleaseNote.parentId));
                    mapProdCatCount.put(instReleaseNote.DataCategoryName,idOfArt);
                }else{
                    Set<Id> idOfArt = new Set<Id>();
                    idOfArt.add(mapOfConvertedGerm.get(instReleaseNote.parentId));
                    mapProdCatCount.put(instReleaseNote.DataCategoryName,idOfArt);        
                } 
            }
        }
        
        /*system.debug('lstDownloadDCS +++'+lstDownloadDCS);
        system.debug('lstFAQDCS  +++'+lstFAQDCS);
        system.debug('lstInstructionsDCS +++'+lstInstructionsDCS);
        system.debug('lstMarkMDCS +++'+lstMarkMDCS);
        system.debug('lstTopicHDCS+++'+lstTopicHDCS);
        system.debug('lstVideoDDCS+++'+lstVideoDDCS);*/
        
        List<QuestionDataCategorySelection> lstQDCS = [SELECT Id,DataCategoryGroupName,DataCategoryName,ParentId  FROM QuestionDataCategorySelection WHERE ParentId =: setQuesId];
        
        
        
        for(QuestionDataCategorySelection instOfQDCS : lstQDCS){
            if(mapProdCatCountQues.containsKey(instOfQDCS.DataCategoryName)){
                List<Id> lstQDCSSec = mapProdCatCountQues.get(instOfQDCS.DataCategoryName);
                lstQDCSSec.add(instOfQDCS.ParentId);
                mapProdCatCountQues.put(instOfQDCS.DataCategoryName,lstQDCSSec);
            }else{
                List<Id> lstQDCSSec = new List<Id>();
                lstQDCSSec.add(instOfQDCS.ParentId);
                mapProdCatCountQues.put(instOfQDCS.DataCategoryName,lstQDCSSec);
            }
        }
        
        productCatCount instOfPCC;
        //instOfPCC = new productCatCount('All',totalResults);
        //lstProdCatCount.add(instOfPCC);
        //String[] lstDataCat = new String[]{'CSN_Planner','CSN_Supplier','eMarketing','Event','Survey','CrowdTorch_Ticketing','OnArrival','SocialWall','CrowdCompass'};
        //,'OnArrival','SocialWall','CrowdCompass'
        
        for(String instoStr : lstProdCat){
            if(mapProdCatCount.containskey(instoStr) || mapProdCatCountQues.containsKey(instoStr)){
                Integer intProdCatSize=0;
                if(mapProdCatCount.containsKey(instoStr))
                intProdCatSize = mapProdCatCount.get(instoStr).size();
                if(mapProdCatCountQues.containsKey(instoStr))
                intProdCatSize  = intProdCatSize  + mapProdCatCountQues.get(instoStr).size();
                
                instOfPCC = new productCatCount(mapprodCatNameLabel.get(instoStr),intProdCatSize,false,instoStr);
                lstProdCatCount.add(instOfPCC);
            }else{
                instOfPCC = new productCatCount(mapprodCatNameLabel.get(instoStr),0,false,instoStr);
                lstProdCatCount.add(instOfPCC);
            }
        }
        //lstProdCatCount.sort();
        //system.debug('lstProdCatCount++'+lstProdCatCount);
        List<String> lstName = new List<String>();
        for(productCatCount instOfProdCat : lstProdCatCount){
            if(instOfProdCat!=null)
            lstName.add(instOfProdCat.Name);
        }
        lstName.sort();
        List<productCatCount> lstProdCatCountSec = new List<productCatCount>();
        for(String strName : lstName){
            for(productCatCount instOfProdCat : lstProdCatCount){
                if(strName == instOfProdCat.Name){
                    instOfPCC = new productCatCount(instOfProdCat.Name,instOfProdCat.Count,instOfProdCat.show,instOfProdCat.ApiName);
                    lstProdCatCountSec.add(instOfPCC);
                }
            }
        }
        lstProdCatCount = new List<productCatCount>();
        lstProdCatCount.addAll(lstProdCatCountSec);
        //system.debug('mapKAVType111111++'+mapKAVType);
    }
    
    //public map<string,List<Id>> mapProdCatCount = new map<string,List<Id>>();
    //public map<String,List<Id>> mapProdCatCountQues = new map<String,List<Id>>();
    public map<String,String> mapProdSel = new map<String,String>();
    public map<String,String> mapArticleType = new map<String,String>();
    public map<String,String> mapidCheck = new map<String,String>();
    public Set<String> setLangSel = new set<String>();
    
    public List<String> lstProductSel{get;set;}
    public List<String> lstArticleTypeSel = new List<String>();
    
    Public void test(){
        
         system.debug('********************>test callmethod');
    }   

   public PageReference updateWithFilters() {
       
        boolforTest = false;
        //system.debug(lstSearchResultKAAllCls);
        //system.debug(lstSearchResultQAllCls);
        lstSearchResultKAAll = new List<searchResultKA>();
        lstSearchResultQAll = new List<searchResultQ>();
        lstSearchResultKA = new List<searchResultKA>();
        lstSearchResultQ = new List<searchResultQ>();
        
        lstSearchResultKAAll.addAll(lstSearchResultKAAllCls);
        lstSearchResultQAll.addAll(lstSearchResultQAllCls);
        /*
        system.debug('productSel++'+productSel);
        system.debug('articleTypeSel++'+articleTypeSel);
        system.debug('langSel++'+langSel);
        
        system.debug('viewAllVar++'+viewAllVar);*/
        setLangSel = new set<String>();
        mapArticleType = new map<String,String>();
        mapProdSel = new map<String,String>();
        mapidCheck = new map<String,String>();
        lstProductSel = new List<String>();
        lstArticleTypeSel = new List<String>();
        List<String> lstLangSel = new List<String>();
        Set<String> articleCount = new Set<String>();
        
        if(!productSel.contains('All')){
        
            if(langSel.contains(';')){
                lstLangSel = langSel.split(';',-2);
                for(String str : lstLangSel){
                    setLangSel.add(str);
                }
            }else{
                //lstLangSel.add(langSel);
                if(langSel !=null && langSel !='')
                setLangSel.add(langSel);
            }  
            
            if(productSel.contains(';')){
                lstProductSel =  productSel.split(';',-2);
                for(String str : lstProductSel){
                    mapProdSel.put(str,str);
                }
            }else{
                lstProductSel.add(productSel);
                if(productSel != null && productSel != '')
                mapProdSel.put(productSel,productSel);
            }
            if(articleTypeSel.contains(';')){
                lstArticleTypeSel = articleTypeSel.split(';',-2);
                for(String str : lstArticleTypeSel){
                    mapArticleType.put(str,str);
                }
            }else{
                lstArticleTypeSel.add(articleTypeSel);
                if(articleTypeSel !=null && articleTypeSel !='')
                mapArticleType.put(articleTypeSel,articleTypeSel);
            }   
            
        }else{
            mapProdSel.put(productSel,productSel);
            mapArticleType.put(articleTypeSel,articleTypeSel);
        }
        //system.debug('mapProdSel++'+mapProdSel);
        //system.debug('mapArticleType++'+mapArticleType);
        
        Integer counter=0;
        Integer counterSec=0;
        articleSize = 0;
        quesSize = 0;
        lstSearchResultKA = new List<searchResultKA>();
        lstSearchResultQ = new List<searchResultQ>();
        
        //mapArticleTypeName
        //system.debug('mapKAVType2222++'+mapKAVType);
        
        
        //For lang filter
        if(mapProdSel.KeySet().size()==0 && mapArticleType.KeySet().size()==0){
            for(searchResultKA instOfSearchQ : lstSearchResultKAAll){
                if(!mapidCheck.containsKey(instOfSearchQ.recordid)){
                    if(viewAllVar == null){
                        if(setLangSel.size() == 0){
                            if(counter < 20){
                                mapidCheck.put(instOfSearchQ.recordid,instOfSearchQ.recordid);
                                lstSearchResultKA.add(instOfSearchQ);
                            }
                            counter++;
                            articleCount.add(instOfSearchQ.recordid);
                        }else if(setLangSel.size() >0 ){
                            if(setLangSel.contains(instOfSearchQ.Lang)){
                                if(counter < 20){
                                    mapidCheck.put(instOfSearchQ.recordid,instOfSearchQ.recordid);
                                    lstSearchResultKA.add(instOfSearchQ);                               
                                }   
                                counter++;
                                articleCount.add(instOfSearchQ.recordid);                               
                            }
                        }
                    }else if(viewAllVar=='KAV'){
                        if(setLangSel.size() == 0){
                            mapidCheck.put(instOfSearchQ.recordid,instOfSearchQ.recordid);
                            lstSearchResultKA.add(instOfSearchQ);
                        }else if(setLangSel.size() >0 ){
                            if(setLangSel.contains(instOfSearchQ.Lang)){            
                                mapidCheck.put(instOfSearchQ.recordid,instOfSearchQ.recordid);
                                lstSearchResultKA.add(instOfSearchQ);
                            }
                        }
                    }
                    //counter++;
                }
            }
            for(searchResultQ instOfSearchQ : lstSearchResultQAll){
                //system.debug('idOfQ++'+idOfQ);
                //system.debug('instOfSearchQ.recordid++'+instOfSearchQ.recordid);
                //if(idOfQ == instOfSearchQ.recordid){
                    counterSec++;
                    if(counterSec < 21 && viewAllVar==null){
                        lstSearchResultQ.add(instOfSearchQ);
                    }else if(viewAllVar == 'Ques'){
                        lstSearchResultQ.add(instOfSearchQ);
                    }
                //}
            }           
        }
        
        //system.debug('counter+++'+counter);
        //system.debug('lstSearchResultKA.size()+++'+lstSearchResultKA.size());
        //For lang filter
        
        if(mapProdSel.KeySet().size()==0){
            for(String instStr : mapKAVType.Keyset()){
                /*system.debug('instStr+++'+instStr);
                system.debug('mapArticleType++'+mapArticleType.KeySet());
                system.debug('mapArticleType.containsKey(instStr)++'+mapArticleType.containsKey(instStr));*/
                if(mapArticleType.containsKey(instStr)){
                    for(searchResultKA instOfSearchQ : lstSearchResultKAAll){
                        //for(Id idOfKAV : mapKAVType.get(instStr)){
                             Set<Id> setMapKAVId = mapKAVType.get(instStr);
                             //if(idOfKAV == instOfSearchQ.recordid){
                             if(setMapKAVId.contains(instOfSearchQ.recordid)){
                                if(!mapidCheck.containsKey(instOfSearchQ.recordid)){
                                    //system.debug('counter++'+counter);
                                    //system.debug('counter++'+articleCount.size());
                                    if(viewAllVar == null){
                                        if(setLangSel.size() == 0){
                                            if(counter < 20){
                                                mapidCheck.put(instOfSearchQ.recordid,instOfSearchQ.recordid);
                                                lstSearchResultKA.add(instOfSearchQ);
                                            }   
                                            articleCount.add(instOfSearchQ.recordid);
                                            counter++;
                                        }else if(setLangSel.size() >0){
                                            if(setLangSel.contains(instOfSearchQ.Lang)){
                                                if(counter < 20){
                                                    mapidCheck.put(instOfSearchQ.recordid,instOfSearchQ.recordid);
                                                    lstSearchResultKA.add(instOfSearchQ);
                                                }   
                                                counter++;
                                                articleCount.add(instOfSearchQ.recordid);
                                            }
                                        }
                                    }else if(viewAllVar=='KAV'){
                                        if(setLangSel.size() == 0){
                                            mapidCheck.put(instOfSearchQ.recordid,instOfSearchQ.recordid);
                                            lstSearchResultKA.add(instOfSearchQ);
                                        }else if(setLangSel.size() >0){
                                            if(setLangSel.contains(instOfSearchQ.Lang)){
                                                mapidCheck.put(instOfSearchQ.recordid,instOfSearchQ.recordid);
                                                lstSearchResultKA.add(instOfSearchQ);
                                            }
                                        }
                                    }   
                                    //counter++;
                                }
                             }
                            //}
                        //}
                    }
                }
            }
        }
        system.debug('articleCount+++'+articleCount);
        system.debug('counter+++'+counter);
        system.debug('lstSearchResultKA.size()+++'+lstSearchResultKA.size());
        if(mapProdSel.containsKey('All')){
            for(searchResultKA instOfSearchQ : lstSearchResultKAAll){
                counter++;    
                
                //system.debug('instOfSearchQ.recordid++'+instOfSearchQ.recordid);
                
                if(counter<21 && viewAllVar==null){
                    if(setLangSel.size() == 0){
                        lstSearchResultKA.add(instOfSearchQ);
                    }else if(setLangSel.size() >0){
                        if(setLangSel.contains(instOfSearchQ.Lang)){
                            lstSearchResultKA.add(instOfSearchQ);
                        }
                    }
                }else if(viewAllVar!=null){
                    if(setLangSel.size() == 0){
                        lstSearchResultKA.add(instOfSearchQ);
                    }else if(setLangSel.size() >0){
                        if(setLangSel.contains(instOfSearchQ.Lang)){
                            lstSearchResultKA.add(instOfSearchQ);
                        }
                    }
                }
            }
                
            
            for(searchResultQ instOfSearchQ : lstSearchResultQAll){
                //system.debug('instOfSearchQ.recordid++'+instOfSearchQ.recordid);
                counterSec++;
                if(counterSec<21 && viewAllVar==null){
                    lstSearchResultQ.add(instOfSearchQ);    
                }else if(viewAllVar == 'Ques'){
                    lstSearchResultQ.add(instOfSearchQ);
                }
            }
        }
        
        
        /*system.debug('counter+++'+counter);
        system.debug('lstSearchResultKA.size()+++'+lstSearchResultKA.size());
        system.debug('lstSearchResultQ.size()++'+lstSearchResultQ.size());*/
        
        String[] lstDataCat = new String[]{'CSN_Planner','CSN_Supplier','eMarketing','Event','Survey','CrowdTorch_Ticketing','OnArrival','SocialWall','CrowdCompass','Meetings_Management'};
        
        //List<String> lstId = new List<String>();
        //Enhancing Search
        for(String instStr : mapKAVType.Keyset()){
            /*system.debug('instStr+++'+instStr);
            system.debug('mapArticleType.containsKey(instStr)+++'+mapArticleType.containsKey(instStr));*/
            if(mapArticleType.containsKey(instStr)){
                for(searchResultKA instOfSearchQ : lstSearchResultKAAll){
                    //system.debug(instOfSearchQ);
                    //for(Id idOfKAV : mapKAVType.get(instStr)){
                    Set<Id> setMapKAVId = mapKAVType.get(instStr);
                        //if(idOfKAV == instOfSearchQ.recordid){
                        if(setMapKAVId.contains(instOfSearchQ.recordid)){
                            lstId.add(instOfSearchQ.recordid);
                            //system.debug(lstId);
                        }
                        //}
                    //}
                }
            }
        } 
        //Enhancing Search
        for(String str : lstDataCat){
            if(mapProdSel.containsKey(str)){
                //lstSearchResultKA = new List<searchResultKA>();
                idOfVal = str;
                if(mapProdCatCount.containsKey(idOfVal)){
                    for(searchResultKA instOfSearchQ : lstSearchResultKAAll){
                        //for(Id idOfKAV : mapProdCatCount.get(idOfVal)){
                            Set<Id> setTempArticleIds =  mapProdCatCount.get(idOfVal);
                            //system.debug('idOfKAV++'+idOfKAV);
                            //system.debug('instOfSearchQ.recordid++'+instOfSearchQ.recordid);
                            //if(idOfKAV == instOfSearchQ.recordid){
                            if(setTempArticleIds.contains(instOfSearchQ.recordid)){
                                if(mapArticleType.Keyset().size()>0){
                                    //for(String idOfKAVSec: lstId){
                                    if(lstId.contains(instOfSearchQ.recordid)){
                                        //if(instOfSearchQ.recordid == idOfKAVSec){
                                            if(!mapidCheck.containsKey(instOfSearchQ.recordid)){
                                                if(viewAllVar == null){
                                                    //if(counter < 20){
                                                        if(setLangSel.size() == 0){
                                                            if(counter < 20){
                                                                mapidCheck.put(instOfSearchQ.recordid,instOfSearchQ.recordid);
                                                                lstSearchResultKA.add(instOfSearchQ);
                                                            }        
                                                            counter++;
                                                            articleCount.add(instOfSearchQ.recordid);
                                                        }else if(setLangSel.size() >0){
                                                            if(setLangSel.contains(instOfSearchQ.Lang)){
                                                                if(counter < 20){
                                                                    mapidCheck.put(instOfSearchQ.recordid,instOfSearchQ.recordid);
                                                                    lstSearchResultKA.add(instOfSearchQ);
                                                                }
                                                                counter++;
                                                                articleCount.add(instOfSearchQ.recordid);
                                                            }
                                                        }
                                                    //}                                          
                                                }else if(viewAllVar == 'KAV'){
                                                    if(setLangSel.size() == 0){
                                                        mapidCheck.put(instOfSearchQ.recordid,instOfSearchQ.recordid);
                                                        lstSearchResultKA.add(instOfSearchQ);
                                                    }else if(setLangSel.size() >0){
                                                        if(setLangSel.contains(instOfSearchQ.Lang)){
                                                            mapidCheck.put(instOfSearchQ.recordid,instOfSearchQ.recordid);
                                                            lstSearchResultKA.add(instOfSearchQ);
                                                        }
                                                    }
                                                    
                                                }   
                                                //counter++;
                                            }           
                                        //}
                                    }
                                    //}
                                }else{
                                    if(!mapidCheck.containsKey(instOfSearchQ.recordid)){
                                        if(viewAllVar == null){
                                            //if(counter < 20){
                                                if(setLangSel.size() == 0){
                                                    if(counter < 20){
                                                        mapidCheck.put(instOfSearchQ.recordid,instOfSearchQ.recordid);
                                                        lstSearchResultKA.add(instOfSearchQ);
                                                    }
                                                    counter++;
                                                    articleCount.add(instOfSearchQ.recordid);
                                                }else if(setLangSel.size() >0){
                                                    if(setLangSel.contains(instOfSearchQ.Lang)){
                                                        if(counter < 20){
                                                            mapidCheck.put(instOfSearchQ.recordid,instOfSearchQ.recordid);
                                                            lstSearchResultKA.add(instOfSearchQ);
                                                        }
                                                        counter++;
                                                        articleCount.add(instOfSearchQ.recordid);
                                                    }
                                                }                                                   
                                            //}                                              
                                        }else if(viewAllVar == 'KAV'){
                                            if(setLangSel.size() == 0){
                                                mapidCheck.put(instOfSearchQ.recordid,instOfSearchQ.recordid);
                                                lstSearchResultKA.add(instOfSearchQ);
                                            }else if(setLangSel.size() >0){
                                                if(setLangSel.contains(instOfSearchQ.Lang)){
                                                    mapidCheck.put(instOfSearchQ.recordid,instOfSearchQ.recordid);
                                                    lstSearchResultKA.add(instOfSearchQ);
                                                }
                                            }                                            
                                        }   
                                        //counter++;
                                    }
                                }
                            }
                            //}
                        //}
                    }
                }
                
                
                //lstSearchResultQ = new List<searchResultQ>();
                if(mapProdCatCountQues.containsKey(idOfVal)){
                    for(Id idOfQ : mapProdCatCountQues.get(idOfVal)){
                        for(searchResultQ instOfSearchQ : lstSearchResultQAll){
                            //system.debug('idOfQ++'+idOfQ);
                            //system.debug('instOfSearchQ.recordid++'+instOfSearchQ.recordid);
                            if(idOfQ == instOfSearchQ.recordid){
                                counterSec++;
                                if(counterSec < 21 && viewAllVar==null){
                                    lstSearchResultQ.add(instOfSearchQ);
                                }else if(viewAllVar == 'Ques'){
                                    lstSearchResultQ.add(instOfSearchQ);
                                }
                            }
                        }
                    }
                }
            }
        }
        /*system.debug('counter+++'+counter);
        system.debug('lstSearchResultKA.size()+++'+lstSearchResultKA.size());
        
        system.debug('lstSearchResultQ++'+lstSearchResultQ);
        system.debug('lstSearchResultKA++'+lstSearchResultKA);
        system.debug('counter+++'+counter);
        system.debug('lstSearchResultKAAll.size()+++'+lstSearchResultKAAll.size());
        system.debug('lstSearchResultKA.size()+++'+lstSearchResultKA.size());
        system.debug('lstSearchResultQ.size()++'+lstSearchResultQ.size());*/
        if(mapProdSel.containsKey('All')){
            articleSize = lstSearchResultKAAll.size();
            quesSize = lstSearchResultQAll.size();
        }else{
            if(viewAllVar!= null)
            articleSize = lstSearchResultKA.size();
            else
            articleSize = articleCount.size();
            quesSize = counterSec;
            
            //system.debug('quesSize++'+quesSize);
            //system.debug('lstSearchResultQ.size()++'+lstSearchResultQ.size());
        }
        return null;
    }
    
    public PageReference viewAll(){
        
        lstSearchResultKAAll = new List<searchResultKA>();
        lstSearchResultQAll = new List<searchResultQ>();
        lstSearchResultKA = new List<searchResultKA>();
        lstSearchResultQ = new List<searchResultQ>();
        
        lstSearchResultKAAll.addAll(lstSearchResultKAAllCls);
        lstSearchResultQAll.addAll(lstSearchResultQAllCls);
        
        
        /*system.debug('viewAllVar++'+viewAllVar);
        system.debug('mapArticleType++'+mapArticleType);
        system.debug('productSel++'+productSel);
        system.debug('articleTypeSel++'+articleTypeSel);
        system.debug('mapProdCatCount++'+mapProdCatCount);
        system.debug('mapProdCatCountQues++'+mapProdCatCountQues);
        */
        
        mapidCheck = new map<String,String>();
        
        
        lstProdCatCount = new List<productCatCount>();
        productCatCount instOfPCC;
        if(viewAllVar == 'KAV'){
            
            String[] lstDataCat = new String[]{'CSN_Planner','CSN_Supplier','eMarketing','Event','Survey','CrowdTorch_Ticketing','OnArrival','SocialWall','CrowdCompass','Meetings_Management'};
            //,'OnArrival','SocialWall','CrowdCompass'
            for(String instoStr : lstProdCat){
                if(mapProdCatCount.containskey(instoStr)){
                    Integer intProdCatSize=0;
                    if(mapProdCatCount.containsKey(instoStr))
                    intProdCatSize = mapProdCatCount.get(instoStr).size();
                    instOfPCC = new productCatCount(mapprodCatNameLabel.get(instoStr),intProdCatSize,false,instoStr);
                    lstProdCatCount.add(instOfPCC);
                }else{
                    instOfPCC = new productCatCount(mapprodCatNameLabel.get(instoStr),0,false,instoStr);
                    lstProdCatCount.add(instOfPCC);
                }
            }
            
            
            //system.debug('lstProdCatCount++'+lstProdCatCount);
            List<String> lstName = new List<String>();
            for(productCatCount instOfProdCat : lstProdCatCount){
                if(instOfProdCat!=null)
                lstName.add(instOfProdCat.Name);
            }
            lstName.sort();
            List<productCatCount> lstProdCatCountSec = new List<productCatCount>();
            for(String strName : lstName){
                for(productCatCount instOfProdCat : lstProdCatCount){
                    if(strName == instOfProdCat.Name){
                        instOfPCC = new productCatCount(instOfProdCat.Name,instOfProdCat.Count,instOfProdCat.show,instOfProdCat.ApiName);
                        lstProdCatCountSec.add(instOfPCC);
                    }
                }
            }
            lstProdCatCount = new List<productCatCount>();
            lstProdCatCount.addAll(lstProdCatCountSec);
            
            totalResults = lstSearchResultKAAll.size();
            if(productSel =='' && articleTypeSel == ''){
                mapProdSel.put('All','All');
                mapArticleType.put('All','All');
            }
            
            showQues = false;
            //system.debug('showQues++'+showQues);
            Integer counter=0;
            Integer counterSec=0;
            articleSize = 0;
            quesSize = 0;
            lstSearchResultKA = new List<searchResultKA>();
            lstSearchResultQ = new List<searchResultQ>();
           // system.debug('mapKAVType+++'+mapKAVType);
            //system.debug('mapArticleType+++'+mapArticleType);
            //mapArticleTypeName
            /*
            if(productSel != null && productSel != ''){
                for(String instStr : mapKAVType.Keyset()){
                    if(mapArticleType.containsKey(instStr)){
                        for(searchResultKA instOfSearchQ : lstSearchResultKAAll){
                            //for(Id idOfKAV : mapKAVType.get(instStr)){
                            Set<Id> setMapKAVId = mapKAVType.get(instStr);
                                 //if(idOfKAV == instOfSearchQ.recordid){
                                 if(){
                                    if(!mapidCheck.containsKey(idOfKAV)){
                                        //if(counter < 20){
                                            mapidCheck.put(idOfKAV,idOfKAV);
                                            lstSearchResultKA.add(instOfSearchQ);   
                                        //} 
                                        counter++;
                                    }
                                 }
                                //}
                            //}
                        }
                    }
                }   
            }*/
            //Enhancing Search
            for(String instStr : mapKAVType.Keyset()){
               // system.debug('instStr+++'+instStr);
                //system.debug('mapArticleType.containsKey(instStr)+++'+mapArticleType.containsKey(instStr));
                if(mapArticleType.containsKey(instStr)){
                    for(searchResultKA instOfSearchQ : lstSearchResultKAAll){
                        //system.debug(instOfSearchQ);
                        //for(Id idOfKAV : mapKAVType.get(instStr)){
                            Set<Id> setMapKAVId = mapKAVType.get(instStr);
                            //if(idOfKAV == instOfSearchQ.recordid){
                            if(setMapKAVId.contains(instOfSearchQ.recordid)){
                                lstId.add(instOfSearchQ.recordid);
                                //system.debug(lstId);
                            }
                            //}
                        //}
                    }
                }
            } 
            //Enhancing Search
            
            if(mapProdSel.containsKey('All')){
                
                for(searchResultKA instOfSearchQ : lstSearchResultKAAll){
                    counter++;    
                    
                    //system.debug('instOfSearchQ.recordid++'+instOfSearchQ.recordid);
                    if(setLangSel.size() == 0){
                        lstSearchResultKA.add(instOfSearchQ);
                    }else if(setLangSel.size() > 0){
                        if(setLangSel.contains(instOfSearchQ.Lang)){
                            lstSearchResultKA.add(instOfSearchQ);
                        }
                    }
                   
                }
                    
            }
            
            for(String str : lstDataCat){
                if(mapProdSel.containsKey(str)){
                    //lstSearchResultKA = new List<searchResultKA>();
                    idOfVal=str;
                    if(mapProdCatCount.containsKey(idOfVal)){
                        for(searchResultKA instOfSearchQ : lstSearchResultKAAll){
                            //for(Id idOfKAV : mapProdCatCount.get(idOfVal)){
                            Set<Id> setTempArticleIds = mapProdCatCount.get(idOfVal);
                                //system.debug('idOfKAV++'+idOfKAV);
                                //system.debug('instOfSearchQ.recordid++'+instOfSearchQ.recordid);
                                //if(idOfKAV == instOfSearchQ.recordid){
                                if(setTempArticleIds.contains(instOfSearchQ.recordid)){
                                    if(mapArticleType.Keyset().size()>0){
                                        //for(String idOfKAVSec: lstId){
                                        if(lstId.contains(instOfSearchQ.recordid)){
                                            //(instOfSearchQ.recordid == idOfKAVSec){
                                                if(!mapidCheck.containsKey(instOfSearchQ.recordid)){
                                                    //if(counter < 20){
                                                    if(setLangSel.size() == 0){
                                                        mapidCheck.put(instOfSearchQ.recordid,instOfSearchQ.recordid);
                                                        lstSearchResultKA.add(instOfSearchQ); 
                                                        counter++;
                                                    }else if(setLangSel.size() > 0){
                                                        if(setLangSel.contains(instOfSearchQ.Lang)){
                                                            mapidCheck.put(instOfSearchQ.recordid,instOfSearchQ.recordid);
                                                            lstSearchResultKA.add(instOfSearchQ);
                                                            counter++;
                                                        }
                                                    }
                                                    //} 
                                                    
                                                }       
                                            //}
                                        }
                                        //}
                                    }else{
                                        if(!mapidCheck.containsKey(instOfSearchQ.recordid)){
                                            //if(counter < 20){
                                                if(setLangSel.size() == 0){
                                                    mapidCheck.put(instOfSearchQ.recordid,instOfSearchQ.recordid);
                                                    lstSearchResultKA.add(instOfSearchQ);
                                                    counter++;
                                                }else if(setLangSel.size() > 0){
                                                    if(setLangSel.contains(instOfSearchQ.Lang)){
                                                        mapidCheck.put(instOfSearchQ.recordid,instOfSearchQ.recordid);
                                                        lstSearchResultKA.add(instOfSearchQ);
                                                        counter++;
                                                    }
                                                }
                                                   
                                            //} 
                                            //counter++;
                                        }   
                                    }
                                }
                                //}
                            //}
                        }
                    }
                   
                    
                    //for(searchResultKA instOfSearchQ : lstSearchResultKAAll){
                        //system.debug('instOfSearchQ.recordid++++'+instOfSearchQ.recordid);
                    //}
                }
            }
            
            if(mapProdSel.containsKey('All')){
                articleSize = lstSearchResultKAAll.size();
                quesSize = lstSearchResultQAll.size();
            }else{
                articleSize = counter;
                quesSize = counterSec;
            }
            
        }else{
            showKav = false;
            //system.debug('showKav++'+showKav);
            Integer counter=0;
            Integer counterSec=0;
            articleSize = 0;
            quesSize = 0;
            totalResults = lstSearchResultQAll.size();
            lstSearchResultQ = new List<searchResultQ>();
            
            if(productSel ==''){
                mapProdSel.put('All','All');
                mapArticleType.put('All','All');
            }
            
            String[] lstDataCat = new String[]{'CSN_Planner','CSN_Supplier','eMarketing','Event','Survey','CrowdTorch_Ticketing','OnArrival','SocialWall','CrowdCompass'};
            //,'OnArrival','SocialWall','CrowdCompass'
            for(String instoStr : lstProdCat){
                if(mapProdCatCountQues.containsKey(instoStr)){
                    Integer intProdCatSize=0;
                    //if(mapProdCatCount.containsKey(instoStr))
                    //intProdCatSize = mapProdCatCount.get(instoStr).size();
                    if(mapProdCatCountQues.containsKey(instoStr))
                    intProdCatSize  =  mapProdCatCountQues.get(instoStr).size();
                    
                    instOfPCC = new productCatCount(mapprodCatNameLabel.get(instoStr),intProdCatSize,false,instoStr);
                    lstProdCatCount.add(instOfPCC);
                }else{
                    instOfPCC = new productCatCount(mapprodCatNameLabel.get(instoStr),0,false,instoStr);
                    lstProdCatCount.add(instOfPCC);
                }
            }
            //mapArticleTypeName
            //system.debug('lstProdCatCount++'+lstProdCatCount);
            List<String> lstName = new List<String>();
            for(productCatCount instOfProdCat : lstProdCatCount){
                if(instOfProdCat!=null)
                lstName.add(instOfProdCat.Name);
            }
            lstName.sort();
            List<productCatCount> lstProdCatCountSec = new List<productCatCount>();
            for(String strName : lstName){
                for(productCatCount instOfProdCat : lstProdCatCount){
                    if(strName == instOfProdCat.Name){
                        instOfPCC = new productCatCount(instOfProdCat.Name,instOfProdCat.Count,instOfProdCat.show,instOfProdCat.ApiName);
                        lstProdCatCountSec.add(instOfPCC);
                    }
                }
            }
            lstProdCatCount = new List<productCatCount>();
            lstProdCatCount.addAll(lstProdCatCountSec);
            
            if(mapProdSel.containsKey('All')){
                for(searchResultQ instOfSearchQ : lstSearchResultQAll){
                    //system.debug('idOfQ++'+idOfQ);
                    //system.debug('instOfSearchQ.recordid++'+instOfSearchQ.recordid);
                    //if(idOfQ == instOfSearchQ.recordid){
                        counterSec++;
                        //if(counterSec<21)
                        lstSearchResultQ.add(instOfSearchQ);
                    //}
                }
            }
            
            for(String str : lstDataCat){
                if(mapProdSel.containsKey(str)){
                    //lstSearchResultKA = new List<searchResultKA>();
                    idOfVal = str;
                    if(mapProdCatCountQues.containsKey(idOfVal)){
                        for(Id idOfQ : mapProdCatCountQues.get(idOfVal)){
                            for(searchResultQ instOfSearchQ : lstSearchResultQAll){
                                /*system.debug('idOfQ++'+idOfQ);
                                system.debug('instOfSearchQ.recordid++'+instOfSearchQ.recordid);*/
                                if(idOfQ == instOfSearchQ.recordid){
                                    counterSec++;
                                    //if(counterSec<21)
                                    lstSearchResultQ.add(instOfSearchQ);
                                }
                            }
                        }
                    }
                }
            }
            if(mapProdSel.containsKey('All')){
                articleSize = lstSearchResultKAAll.size();
                quesSize = lstSearchResultQAll.size();
            }else{
                articleSize = counter;
                quesSize = counterSec;
            }
        }
        /*system.debug('lstSearchResultQ++'+lstSearchResultQ);
        system.debug('lstSearchResultKA++'+lstSearchResultKA);
        System.debug('lstSearchResultKA*************************'+lstSearchResultKA);
        System.debug('#Checkpoint...............');*/
        return null;
        /*
        system.debug('viewAllVar++'+viewAllVar);
        system.debug('searchfor+'+searchfor);
        system.debug('idOfVal+++'+idOfVal);
        if(idOfVal=='')
        idOfVal = 'All';
        Pagereference pageRef = new PageReference('/apex/communityShowAll');
        //?searchfor='+searchfor+'&viewAll='+viewAllVar+'&productCat='+productSel+'&articleTypeSel='+articleTypeSel
        pageRef.getParameters().put('searchfor',searchfor);
        pageRef.getParameters().put('viewAll',viewAllVar);
        pageRef.getParameters().put('productSel',productSel);
        pageRef.getParameters().put('articleTypeSel',articleTypeSel);
        pageRef.setRedirect(true);
        return pageRef;
        */
    }
    
    public map<Id,Integer> viewStatKav(Set<Id> idOfKAVS){
        List<KnowledgeArticleViewStat> lstOFKAVS = new List<KnowledgeArticleViewStat>();
        lstOFKAVS = [SELECT ViewCount,ParentId FROM KnowledgeArticleViewStat WHERE ParentId=: idOfKAVS And Channel='Csp'];
        map<Id,Integer> mapofKAVS = new map<Id,Integer>();
        
        for(KnowledgeArticleViewStat instOfKAVS : lstOFKAVS){
            system.debug('instOfKAVS.ViewCount++'+instOfKAVS.ViewCount);
            system.debug('instOfKAVS.ParentId++'+instOfKAVS.ParentId);
            if(mapofKAVS.containsKey(instOfKAVS.ParentId)){
                Integer intii = mapofKAVS.get(instOfKAVS.ParentId);
                intii = intii + instOfKAVS.ViewCount;
                mapofKAVS.put(instOfKAVS.ParentId,intii);
            }else{
                mapofKAVS.put(instOfKAVS.ParentId,instOfKAVS.ViewCount);
            }
            
        }
        
        return mapofKAVS;
    }
    
    public map<Id,Double> voteStatKav(Set<Id> idOfKAVS){
        List<KnowledgeArticleVoteStat> lstKAVoS = new List<KnowledgeArticleVoteStat>();
        lstKAVoS = [SELECT NormalizedScore,ParentId FROM KnowledgeArticleVoteStat WHERE ParentId=: idOfKAVS AND Channel='Csp'];
        map<Id,Double> mapofKAVoS = new map<Id,Double>();
        for(KnowledgeArticleVoteStat instOfKAVoS : lstKAVoS){
            system.debug('instOfKAVoS.ParentId+++'+instOfKAVoS.ParentId);
            system.debug('instOfKAVoS.NormalizedScore+++'+instOfKAVoS.NormalizedScore);
            mapofKAVoS.put(instOfKAVoS.ParentId,instOfKAVoS.NormalizedScore);
        }    
        return mapofKAVoS;
    }
    
    public class productCatCount{
        public String Name{get;set;}
        public Integer Count{get;set;}
        public Boolean show{get;set;}
        public String ApiName{get;set;}
        public productCatCount(String Name,Integer Count,Boolean show,String ApiName){
            this.Name = Name;
            this.Count = Count;
            this.show = show;
            this.ApiName = ApiName;
        }
    }
    
    public class articleTypeCount{
        //public string lang{get;set;}
        public String Name{get;set;}
        public Integer Count{get;set;}
        public String apiName{get;set;}
        public Boolean show{get;set;}
        public articleTypeCount(String Name,Integer Count,String apiName,Boolean show){//String lang,
            //this.lang = lang;
            this.Name = Name;
            this.Count = Count;
            this.apiName = apiName;
            this.show = show;
        }
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
        public searchResultKA(Id recordid, String articleNum, String Name,String ratingLink,Integer doubKAVs,String Type,String articleType,String strSummary,String Lang){ //latest code
            this.recordid = recordid;
            this.articleNum = articleNum; //latest code
            this.Name = Name;
            this.Type = Type;
            this.ratingLink = ratingLink;
            this.doubKAVs = doubKAVs;
            this.articleType = articleType;
            //this.show = show;
            this.strSummary = strSummary;
            this.Lang = Lang;
        }
    }
    
    public class searchResultQ{
        public Id recordid{get;set;}
        public String Name{get;set;}
        public String Type{get;set;}
        public DateTime LastReplyDate{get;set;}
        public Integer replyCount{get;set;}
        public Boolean bestAns{get;set;}
        public Boolean show{get;set;}
        public searchResultQ(Id recordid, String Name,DateTime LastReplyDate,Integer replyCount,Boolean bestAns,String Type){
            this.recordid = recordid;
            this.Name = Name;
            this.Type = Type;
            this.LastReplyDate =  LastReplyDate;
            this.replyCount =  replyCount;
            this.bestAns = bestAns;
            this.show = show;
        }
    }
    public class LangCount{
        public string lang{get;set;}
        public Integer count{get;set;}
        public String isoLang{get;set;}
        public Boolean show{get;set;}
        public LangCount(String lang,String isoLang,Integer count){
            this.lang = lang;
            this.count = count;
            this.isoLang = isoLang;
            this.show = show;
        }
    }
}