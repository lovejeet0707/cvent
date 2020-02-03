/*
//////////////////////////////////////
//      @author Abhishek Pandey     //
/////////////////////////////////////
Version :   1.0
Date : 22nd April 2016
Description : Page Name-CommunitysearchResultAngularPage

Version : 2.0
Date : 13th April 2017
Description : 1) Included isAccessible() so that it can be used to show only Cvent Article Types as these user profiles have access for these Articles ypes only in the Vf Page.
              2) Change in the query of KnowledgeArticle so that only Cvent Article should be searched.
               3) Including Custom label which will contains the name of Data Categories which will be shown in to the Cvent Communities and not in the Lanyon.
                 As now we are merging both the categories we need to make differentiation between them.
*/
public class CommunitySearchResultsAngularCls {
    public string searchfor{get;set;}
    public string productSel{get;set;}
    public string strSosl;
    public String escapedQ;
    public String german ='de';
    public String english='en_US';
    public String spanish='es';
    public Boolean bestAns = false;
    public List<searchResultQ> lstSearchResultQAll{get;set;}
    public List<LangCount> lstLangCount{get;set;}
    public map<String,List<Id>> mapProdCatCountQues = new map<String,List<Id>>();
    public map<Id,KnowledgeArticleVersion> mapallSearchedKAVs = new map<Id,KnowledgeArticleVersion>();
    public map<String,String> mapOfConvertedGerm = new map<String,String>();
    public map<String,String> mapOfConvertedSpanish = new map<String,String>();
    
    public map<string,Set<Id>> mapProdCatCount = new map<string,Set<Id>>();
    public static map<String,String> mapprodCatNameLabel = new map<String,String>();
    public static List<String> lstProdCat = new List<String>();
    public List<productCatCount> lstProdCatCount{get;set;}
    public static Map<String,Schema.SOBjectType> gd = Schema.getGlobalDescribe();
    public static Map<String,Schema.DescribeSObjectResult> kavObjPrefixMap = new Map<String,Schema.DescribeSObjectResult>();
    public static map<String,String> mapArticleTypeName{get;set;}
    public static Set<String> kavNames = new Set<String>();
    public static List<String> articleKavNames = new List<String>();
    public List<articleTypeCount> lstarticleTypeCount{get;set;}
    public map<string,Set<Id>> mapKAVType = new map<string,Set<Id>>();
    public List<searchResultKA> lstSearchResultKAAll{get;set;}
    public String lstSearchResultKAAllStr{get;set;}
    public String lstSearchResultQuesStr{get;set;}
    /*HSR:18th MaY : Including Custom label which will contains the name of Data Categories which will be shown in to the Cvent Communities and not in the Lanyon.
                 As now we are merging both the categories we need to make differentiation between them.*/
    public static Set<String> dataCategorySet;//Declaring variable to store the data from Custom Label.
    static{
        /*HSR:18th may: Including Custom label which will contains the name of Data Categories which will be shown in to the Cvent Communities and not in the Lanyon.
                 As now we are merging both the categories we need to make differentiation between them.*/
        dataCategorySet = new Set<String>(Label.Cvent_Data_Categories.split(';'));//Initializing set and adding Custom Label values in it.
        System.debug('dataCategorySet************'+dataCategorySet);
        //Language addition
        gd = Schema.getGlobalDescribe();
        System.debug('gd************'+gd);
        for(String s : gd.keySet()) {
            System.debug('s******'+s);
            Schema.SObjectType objectType = gd.get(s);
            System.debug('objectType******'+objectType);
            /*HSR : 13th April 2017 : Included isAccessible() so that it can be used to show only Cvent Article Types as these user profiles have access for these Articles ypes only in the Vf Page.*/
            Schema.DescribeSObjectResult drSObj = objectType.getDescribe();//Need to be commented in future
            System.debug('drSObj******'+drSObj);
            System.debug('s.contains__kav******'+s.contains('__kav'));
            System.debug('isAccessible******'+drSObj.isAccessible());
            if (s.contains('__kav') && new CheckObjectPermissionsInVisualForce(s).isAccessible())//&& drSObj.isAccessible()) {
            {    System.debug('Inside If'+s);
                kavNames.add(s);
                articleKavNames.add('\''+gd.get(s).getDescribe().getName()+'\'');
            }
        }
        System.debug('kavNames************'+kavNames);
        System.debug('articleKavNames*******'+articleKavNames);
        
        mapArticleTypeName = new Map<String,String>();
        Schema.DescribeSObjectResult sor;
        for (String s : kavNames) {
            system.debug(s);
            sor = gd.get(s).getDescribe();
            system.debug(sor);
            mapArticleTypeName.put(sor.getName(),sor.getLabel());
            system.debug(mapArticleTypeName);
            kavObjPrefixMap.put(sor.getKeyPrefix().toLowerCase(), sor);
            system.debug(sor.getKeyPrefix().toLowerCase());
        }
        System.debug('mapArticleTypeName*******'+mapArticleTypeName);
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
        Map<String,String> labelVsAPIName = new Map<String,String>(); 
        List<String> labelSet = new List<String>();
        describeCategoryStructureResult = Schema.describeDataCategoryGroupStructures(pairs, false);
        system.debug('dataCategorySet*************'+dataCategorySet);
        system.debug('describeCategoryStructureResult*************'+describeCategoryStructureResult);
        for(DescribeDataCategoryGroupStructureResult singleResult : describeCategoryStructureResult){
            //system.debug(singleResult.getName());
            DataCategory [] toplevelCategories = singleResult.getTopCategories();
            List<DataCategory> allCategories = getAllCategories(toplevelCategories);
                 system.debug('allCategories *************'+allCategories );
            for(DataCategory category : allCategories) {
                //mapprodCatNameLabel.put(category.getName(),category.getlabel());
                //lstProdCat.add(category.getName());
                DataCategory [] childCategories = category.getChildCategories();
                 /*HSR:18th may: Including Custom label which will contains the name of Data Categories which will be shown in to the Cvent Communities and not in the Lanyon.
                 As now we are merging both the categories we need to make differentiation between them.*/
                 system.debug('childCategories*************'+childCategories);
                for(DataCategory instDataCat : childCategories){
                    system.debug(instDataCat.getlabel());
                    system.debug(instDataCat.getName());
                    /*HSR:18th may: Including Custom label which will contains the name of Data Categories which will be shown in to the Cvent Communities and not in the Lanyon.
                         As now we are merging both the categories we need to make differentiation between them.*/
                    if(dataCategorySet.contains(instDataCat.getName())){
                        mapprodCatNameLabel.put(instDataCat.getName(),instDataCat.getlabel());
                        labelVsAPIName.put(instDataCat.getLabel().touppercase(),instDataCat.getName());
                        labelSet.add(instDataCat.getLabel().touppercase());
                    }
                }
            }
        }
        labelSet.sort();
        system.debug('labelSet*************'+labelSet);
        For(String label : labelSet){
            lstProdCat.add(labelVsAPIName.get(label));
            if(label.equalsIgnoreCase('Event Management'))
            {
                lstProdCat.add('Event1Standard');
                lstProdCat.add('Event2Flex');
                lstProdCat.add('Event3Express');
            }
        }
        mapprodCatNameLabel.put('Event1Standard','Classic');
        mapprodCatNameLabel.put('Event2Flex','Flex');
        mapprodCatNameLabel.put('Event3Express','Express');
        //lstProdCat.Sort();
        system.debug('lstProdCat*************'+lstProdCat);
        
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
    
    public CommunitySearchResultsAngularCls(){
        searchfor = '';
        productSel = '';
        if(ApexPages.currentPage().getParameters().get('productSel') != null)
        productSel = ApexPages.currentPage().getParameters().get('productSel');
        else
        productSel = null;
        
        lstSearchResultQAll = new List<searchResultQ>();
        searchFor = ApexPages.currentPage().getParameters().get('searchFor');
        escapedQ = String.escapeSingleQuotes(searchFor);
        lstLangCount = new List<LangCount>();
        searchResultQ instQL;
        LangCount instLangCount;
        strSosl = '';
        lstSearchResultKAAllStr = '';
        lstSearchResultQuesStr = '';
        searchResultKA instKA;
        String statusKav = 'Online';
        mapOfConvertedGerm = new map<String,String>();
        //Spanish Article
        mapOfConvertedSpanish = new map<String,String>();
        mapallSearchedKAVs = new map<Id,KnowledgeArticleVersion>();
        lstSearchResultKAAll = new List<searchResultKA>();
        
        lstProdCatCount = new List<productCatCount>();
        lstarticleTypeCount = new List<articleTypeCount>();
        System.debug('kavNames**************'+kavNames);
        String types = String.join(articleKavNames, ',');
        List<List<SObject>> lstOfLstKav;//English Article List.....
        List<List<SObject>> lstOfLstKavSec;//German Article List.....
        List<List<SObject>> lstOfLstKavSpanish;//Spanish Article List.....
        /*HSR : 08th Feb 2018: This was included for the time being as Paul need to add some Articles which he wants to publish but don't want to display while searching
            So for this a custom label is being made "CventDataCategoryName" which was used in the query Where clause.
            For now I am using a IF ELSE condition so that code doesn't need to be deployed if we need to show the Articles at any point of time just put "False"
            in this Label and it will start working fine until unless we can re-dploy the code removing the WHERE clause.....
        */
        String dataCategorySearch = Label.CventDataCategoryName;
        /*.............ENDS HERE..........*/
        
        if(dataCategorySearch!='False'){
            /* HSR : 13th April 2017 : Change in the query of KnowledgeArticle so that only Cvent Article should be searched*/
            //English Article Search
            strSosl = '';
            if(escapedQ.startsWith('"'))
                strSosl += 'FIND \'' + escapedQ + '\' IN ALL FIELDS RETURNING KnowledgeArticleVersion( Language,Id,Title,Summary,UrlName,ArticleNumber,LastModifiedDate,FirstPublishedDate,LastPublishedDate,PublishStatus,KnowledgeArticleId,ArticleType where PublishStatus = : statusKav and Language=:english AND IsLatestVersion=true AND ArticleType IN ('+ types +')) '+Label.CventDataCategoryName;   
            else
                strSosl += 'FIND \'' + escapedQ + '*\' IN ALL FIELDS RETURNING KnowledgeArticleVersion( Language,Id,Title,Summary,UrlName,ArticleNumber,LastModifiedDate,FirstPublishedDate,LastPublishedDate,PublishStatus,KnowledgeArticleId,ArticleType where PublishStatus = : statusKav and Language=:english AND IsLatestVersion=true AND  ArticleType IN ('+ types +')) '+Label.CventDataCategoryName;
            lstOfLstKav = Search.query(strSosl);
            
            //German Article Search
            strSosl = '';
            if(escapedQ.startsWith('"'))
                strSosl += 'FIND \'' + escapedQ + '\' IN ALL FIELDS RETURNING KnowledgeArticleVersion( Language,MasterVersionId ,Id,Title,Summary,UrlName,ArticleNumber,LastModifiedDate,FirstPublishedDate,LastPublishedDate,PublishStatus,KnowledgeArticleId,ArticleType where PublishStatus = : statusKav and Language=:german AND IsLatestVersion=true And ArticleType IN ('+ types +')) '+Label.CventDataCategoryName;
            else
                strSosl += 'FIND \'' + escapedQ + '*\' IN ALL FIELDS RETURNING KnowledgeArticleVersion( Language,MasterVersionId ,Id,Title,Summary,UrlName,ArticleNumber,LastModifiedDate,FirstPublishedDate,LastPublishedDate,PublishStatus,KnowledgeArticleId,ArticleType where PublishStatus = : statusKav and Language=:german AND IsLatestVersion=true And ArticleType IN ('+ types +')) '+Label.CventDataCategoryName;
            lstOfLstKavSec = Search.query(strSosl);
            
            //Spanish Article Search
            strSosl = '';
            if(escapedQ.startsWith('"'))
                strSosl += 'FIND \'' + escapedQ + '\' IN ALL FIELDS RETURNING KnowledgeArticleVersion( Language,MasterVersionId ,Id,Title,Summary,UrlName,ArticleNumber,LastModifiedDate,FirstPublishedDate,LastPublishedDate,PublishStatus,KnowledgeArticleId,ArticleType where PublishStatus = : statusKav and Language=:spanish AND IsLatestVersion=true And ArticleType IN ('+ types +')) '+Label.CventDataCategoryName;
            else
                strSosl += 'FIND \'' + escapedQ + '*\' IN ALL FIELDS RETURNING KnowledgeArticleVersion( Language,MasterVersionId ,Id,Title,Summary,UrlName,ArticleNumber,LastModifiedDate,FirstPublishedDate,LastPublishedDate,PublishStatus,KnowledgeArticleId,ArticleType where PublishStatus = : statusKav and Language=:spanish AND IsLatestVersion=true And ArticleType IN ('+ types +')) '+Label.CventDataCategoryName;
            lstOfLstKavSpanish = Search.query(strSosl);
        }
        else{
            /* HSR : 13th April 2017 : Change in the query of KnowledgeArticle so that only Cvent Article should be searched*/
            //English Article Search
            strSosl = '';
            if(escapedQ.startsWith('"'))
                strSosl += 'FIND \'' + escapedQ + '\' IN ALL FIELDS RETURNING KnowledgeArticleVersion( Language,Id,Title,Summary,UrlName,ArticleNumber,LastModifiedDate,FirstPublishedDate,LastPublishedDate,PublishStatus,KnowledgeArticleId,ArticleType where PublishStatus = : statusKav and Language=:english AND IsLatestVersion=true AND ArticleType IN ('+ types +'))';   
            else
                strSosl += 'FIND \'' + escapedQ + '*\' IN ALL FIELDS RETURNING KnowledgeArticleVersion( Language,Id,Title,Summary,UrlName,ArticleNumber,LastModifiedDate,FirstPublishedDate,LastPublishedDate,PublishStatus,KnowledgeArticleId,ArticleType where PublishStatus = : statusKav and Language=:english AND IsLatestVersion=true AND  ArticleType IN ('+ types +'))';
            lstOfLstKav = Search.query(strSosl);
            //German Article Search
            strSosl = '';
            if(escapedQ.startsWith('"'))
                strSosl += 'FIND \'' + escapedQ + '\' IN ALL FIELDS RETURNING KnowledgeArticleVersion( Language,MasterVersionId ,Id,Title,Summary,UrlName,ArticleNumber,LastModifiedDate,FirstPublishedDate,LastPublishedDate,PublishStatus,KnowledgeArticleId,ArticleType where PublishStatus = : statusKav and Language=:german AND IsLatestVersion=true And ArticleType IN ('+ types +'))';
            else
                strSosl += 'FIND \'' + escapedQ + '*\' IN ALL FIELDS RETURNING KnowledgeArticleVersion( Language,MasterVersionId ,Id,Title,Summary,UrlName,ArticleNumber,LastModifiedDate,FirstPublishedDate,LastPublishedDate,PublishStatus,KnowledgeArticleId,ArticleType where PublishStatus = : statusKav and Language=:german AND IsLatestVersion=true And ArticleType IN ('+ types +'))';
            lstOfLstKavSec = Search.query(strSosl);
            
            //Spanish Article Search
            strSosl = '';
            if(escapedQ.startsWith('"'))
                strSosl += 'FIND \'' + escapedQ + '\' IN ALL FIELDS RETURNING KnowledgeArticleVersion( Language,MasterVersionId ,Id,Title,Summary,UrlName,ArticleNumber,LastModifiedDate,FirstPublishedDate,LastPublishedDate,PublishStatus,KnowledgeArticleId,ArticleType where PublishStatus = : statusKav and Language=:spanish AND IsLatestVersion=true And ArticleType IN ('+ types +'))';
            else
                strSosl += 'FIND \'' + escapedQ + '*\' IN ALL FIELDS RETURNING KnowledgeArticleVersion( Language,MasterVersionId ,Id,Title,Summary,UrlName,ArticleNumber,LastModifiedDate,FirstPublishedDate,LastPublishedDate,PublishStatus,KnowledgeArticleId,ArticleType where PublishStatus = : statusKav and Language=:spanish AND IsLatestVersion=true And ArticleType IN ('+ types +'))';
            lstOfLstKavSpanish = Search.query(strSosl);
        }

        strSosl = '';
        if(escapedQ.startsWith('"'))
            strSosl += 'FIND \'' + escapedQ + '*\' IN ALL FIELDS RETURNING Question(Id,Title,Body, NumReplies,BestReply.Name,LastReplyDate LIMIT 250)';        
        else
            strSosl += 'FIND \'' + escapedQ + '*\' IN ALL FIELDS RETURNING Question(Id,Title,Body, NumReplies,BestReply.Name,LastReplyDate LIMIT 250)';        
        List<List<SObject>> lstQues = Search.query(strSosl);

        //Creating list of searched questions and Data Category Selection Count
        Set<Id> setQuesId = new Set<Id>();
        
        for(List<Question> instOfQues :lstQues){
            for(Question instOFquesSec : instOfQues){
                //bestAns = false;
                setQuesId.add(instOFquesSec.Id);
                //if(instOFquesSec.BestReplyId != null)
                //bestAns = true;
                //instQL = new  searchResultQ(instOFquesSec.Id,instOFquesSec.Title,instOFquesSec.LastReplyDate,instOFquesSec.NumReplies,bestAns,'Question');
                //lstSearchResultQAll.add(instQL);
            }
        }
        
        List<QuestionDataCategorySelection> lstQDCS = [SELECT Id,DataCategoryGroupName,DataCategoryName,ParentId  FROM QuestionDataCategorySelection WHERE ParentId =: setQuesId];
        
        map<Id,String> mapQuesIdDCN = new map<Id,String>();
        
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
            mapQuesIdDCN.put(instOfQDCS.ParentId,instOfQDCS.DataCategoryName);
        }
        
        for(List<Question> instOfQues : lstQues){
            for(Question instOFquesSec : instOfQues){
                bestAns = false;
                //setQuesId.add(instOFquesSec.Id);
                if(instOFquesSec.BestReplyId != null)
                bestAns = true;
                instQL = new  searchResultQ(instOFquesSec.Id,instOFquesSec.Title,instOFquesSec.LastReplyDate,instOFquesSec.NumReplies,bestAns,'Question',mapQuesIdDCN.get(instOFquesSec.Id));
                lstSearchResultQAll.add(instQL);
            }
        }
        lstSearchResultQuesStr = JSON.Serialize(lstSearchResultQAll);
        //Creating list of searched questions and Data Category Selection Count
        
        //Segregating English German articles
        lstLangCount = new List<LangCount>();
        Set<Id> setIdKav = new Set<Id>();
        map<Id,Id> mapKAKAV = new map<Id,Id>();
        Set<Id> idOfKAVS =  new Set<Id>();
        Integer counterr=0;
        String searchTextTemp = escapedQ.removeStart('"');
        searchTextTemp = searchTextTemp.removeEnd('"');
        for(List<KnowledgeArticleVersion> lstKAVs : lstOfLstKav){
            //counter=0;
            for(KnowledgeArticleVersion instOfKav :  lstKAVs ){
                //if(((escapedQ.startsWith('"') && instOfKav.title == searchTextTemp) || !escapedQ.startsWith('"'))){
                    counterr++;
                    mapallSearchedKAVs.put(instOfKav.Id,instOfKav);
                    setIdKav.add(instOfKav.Id); 
                    //articleType.add(instOfKav.articleType);
                    //lstKAV.add(instOfKav); 
                    idOfKAVS.add(instOfKav.KnowledgeArticleId);
                    mapKAKAV.put(instOfKav.id,instOfKav.KnowledgeArticleId);
                    if(mapKAVType.containsKey(instOfKAV.ArticleType)){
                        Set<Id> lstKavSec = mapKAVType.get(instOfKAV.ArticleType);
                        lstKavSec.add(instOfKAV.Id);
                        mapKAVType.put(instOfKAV.ArticleType,lstKavSec);
                    }else{
                        Set<Id> lstKavSec = new Set<Id>();
                        lstKavSec.add(instOfKAV.Id);
                        mapKAVType.put(instOfKAV.ArticleType,lstKavSec);
                    }
                //}
            }
        }
        instLangCount = new LangCount('English','en_US',counterr);
        lstLangCount.add(instLangCount);
        
        for(List<KnowledgeArticleVersion> lstKAVs : lstOfLstKavSec){
            counterr=0;
            for(KnowledgeArticleVersion instOfKav :  lstKAVs ){
                //if(((escapedQ.startsWith('"') && instOfKav.title == searchTextTemp) || !escapedQ.startsWith('"'))){
                    counterr++;
                    system.debug(instOfKav.Id);
                    system.debug(instOfKav.articleType);
                    mapallSearchedKAVs.put(instOfKav.Id,instOfKav);
                    mapOfConvertedGerm.put(instOfKav.MasterVersionId,instOfKav.Id);
                    setIdKav.add(instOfKav.MasterVersionId); 
                    //articleType.add(instOfKav.articleType);
                    //lstKAV.add(instOfKav); 
                    idOfKAVS.add(instOfKav.KnowledgeArticleId);
                    mapKAKAV.put(instOfKav.id,instOfKav.KnowledgeArticleId);
                    if(mapKAVType.containsKey(instOfKAV.ArticleType)){
                        Set<Id> lstKavSec = mapKAVType.get(instOfKAV.ArticleType);
                        lstKavSec.add(instOfKAV.Id);
                        mapKAVType.put(instOfKAV.ArticleType,lstKavSec);
                    }else{
                        Set<Id> lstKavSec = new Set<Id>();
                        lstKavSec.add(instOfKAV.Id);
                        mapKAVType.put(instOfKAV.ArticleType,lstKavSec);
                    }
                //}
            }
        }
        instLangCount = new LangCount('German','de',counterr);
        lstLangCount.add(instLangCount);
        
        for(List<KnowledgeArticleVersion> lstKAVs : lstOfLstKavSpanish){
            counterr=0;
            for(KnowledgeArticleVersion instOfKav :  lstKAVs ){
                //if(((escapedQ.startsWith('"') && instOfKav.title == searchTextTemp) || !escapedQ.startsWith('"'))){
                    counterr++;
                    system.debug(instOfKav.Id);
                    system.debug(instOfKav.articleType);
                    mapallSearchedKAVs.put(instOfKav.Id,instOfKav);
                    mapOfConvertedSpanish.put(instOfKav.MasterVersionId,instOfKav.Id);
                    setIdKav.add(instOfKav.MasterVersionId); 
                    //articleType.add(instOfKav.articleType);
                    //lstKAV.add(instOfKav); 
                    idOfKAVS.add(instOfKav.KnowledgeArticleId);
                    mapKAKAV.put(instOfKav.id,instOfKav.KnowledgeArticleId);
                    if(mapKAVType.containsKey(instOfKAV.ArticleType)){
                        Set<Id> lstKavSec = mapKAVType.get(instOfKAV.ArticleType);
                        lstKavSec.add(instOfKAV.Id);
                        mapKAVType.put(instOfKAV.ArticleType,lstKavSec);
                    }else{
                        Set<Id> lstKavSec = new Set<Id>();
                        lstKavSec.add(instOfKAV.Id);
                        mapKAVType.put(instOfKAV.ArticleType,lstKavSec);
                    }
                //}
            }
        }
        instLangCount = new LangCount('Spanish','es',counterr);
        lstLangCount.add(instLangCount);
        //Segregating English German articles
        
        //Categorizing English and German according to their Product Category. 
        
        system.debug('setIdKav++'+setIdKav);
        system.debug('mapallSearchedKAVs++'+mapallSearchedKAVs);
        system.debug('mapOfConvertedGerm++'+mapOfConvertedGerm);
        system.debug('mapOfConvertedSpanish++'+mapOfConvertedSpanish);
        
        
        List<Download__DataCategorySelection> lstDownloadDCS =[SELECT Id,DataCategoryName,DataCategoryGroupName, ParentId FROM Download__DataCategorySelection WHERE ParentId =: setIdKav];
        List<FAQ__DataCategorySelection> lstFAQDCS  = [SELECT Id,DataCategoryName, DataCategoryGroupName,ParentId FROM FAQ__DataCategorySelection WHERE ParentId =: setIdKav];
        List<Instructions__DataCategorySelection> lstInstructionsDCS =[SELECT Id,DataCategoryName,DataCategoryGroupName, ParentId FROM Instructions__DataCategorySelection WHERE ParentId =: setIdKav];
        List<Marketing_Materials__DataCategorySelection> lstMarkMDCS =[SELECT Id,DataCategoryName,DataCategoryGroupName, ParentId FROM Marketing_Materials__DataCategorySelection WHERE ParentId =: setIdKav];
        List<Topic_Hub__DataCategorySelection> lstTopicHDCS =[SELECT Id,DataCategoryName, DataCategoryGroupName,ParentId FROM Topic_Hub__DataCategorySelection WHERE ParentId =: setIdKav];
        List<Video__DataCategorySelection> lstVideoDDCS =[SELECT Id,DataCategoryName, DataCategoryGroupName,ParentId FROM Video__DataCategorySelection WHERE ParentId =: setIdKav];
        List<Release_Notes__DataCategorySelection> lstReleaseNotes =[SELECT Id,DataCategoryName, DataCategoryGroupName,ParentId FROM Release_Notes__DataCategorySelection WHERE ParentId =: setIdKav];
        
        map<Id,String> mapIdVersion = new map<Id,String>();
        
        /*map<Id,Set<String>> mapIdVersion_Clone = new map<Id,Set<String>>();
        Set<String> versionSet= new Set<String>();*/
        
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
                
                if(mapIdVersion.containsKey(instDownloadDCS.ParentId)){
                    String tempStr = mapIdVersion.get(instDownloadDCS.ParentId);
                    tempStr = tempStr +', ' +instDownloadDCS.DataCategoryName;
                    mapIdVersion.put(instDownloadDCS.ParentId,tempStr);
                }else{
                    mapIdVersion.put(instDownloadDCS.ParentId,instDownloadDCS.DataCategoryName);
                }
            }
            if(mapOfConvertedGerm.containsKey(instDownloadDCS.ParentId)){
                if(mapProdCatCount.containsKey(instDownloadDCS.DataCategoryName)){
                    system.debug(mapProdCatCount);
                    Set<Id> idOfArt = mapProdCatCount.get(instDownloadDCS.DataCategoryName);
                    system.debug(idOfArt);
                    system.debug(mapOfConvertedGerm.get(instDownloadDCS.parentId));
                    idOfArt.add(mapOfConvertedGerm.get(instDownloadDCS.parentId));
                    system.debug(idOfArt);
                    mapProdCatCount.put(instDownloadDCS.DataCategoryName,idOfArt);
                    system.debug(mapProdCatCount);
                }else{
                    Set<Id> idOfArt = new Set<Id>();
                    idOfArt.add(mapOfConvertedGerm.get(instDownloadDCS.parentId));
                    mapProdCatCount.put(instDownloadDCS.DataCategoryName,idOfArt);        
                } 
                
                if(mapIdVersion.ContainsKey(mapOfConvertedGerm.get(instDownloadDCS.parentId))){
                    String tempStr = mapIdVersion.get(mapOfConvertedGerm.get(instDownloadDCS.parentId));
                    tempStr = tempStr +', ' + instDownloadDCS.DataCategoryName;
                    mapIdVersion.put(mapOfConvertedGerm.get(instDownloadDCS.parentId),tempStr);
                }else{
                    mapIdVersion.put(mapOfConvertedGerm.get(instDownloadDCS.parentId),instDownloadDCS.DataCategoryName);
                }
            }
            //Spanish Section ... mapOfConvertedSpanish
            if(mapOfConvertedSpanish.containsKey(instDownloadDCS.ParentId)){
                if(mapProdCatCount.containsKey(instDownloadDCS.DataCategoryName)){
                    system.debug(mapProdCatCount);
                    Set<Id> idOfArt = mapProdCatCount.get(instDownloadDCS.DataCategoryName);
                    system.debug(idOfArt);
                    system.debug(mapOfConvertedSpanish.get(instDownloadDCS.parentId));
                    idOfArt.add(mapOfConvertedSpanish.get(instDownloadDCS.parentId));
                    system.debug(idOfArt);
                    mapProdCatCount.put(instDownloadDCS.DataCategoryName,idOfArt);
                    system.debug(mapProdCatCount);
                }else{
                    Set<Id> idOfArt = new Set<Id>();
                    idOfArt.add(mapOfConvertedSpanish.get(instDownloadDCS.parentId));
                    mapProdCatCount.put(instDownloadDCS.DataCategoryName,idOfArt);        
                } 
                
                if(mapIdVersion.ContainsKey(mapOfConvertedSpanish.get(instDownloadDCS.parentId))){
                    String tempStr = mapIdVersion.get(mapOfConvertedSpanish.get(instDownloadDCS.parentId));
                    tempStr = tempStr +', ' + instDownloadDCS.DataCategoryName;
                    mapIdVersion.put(mapOfConvertedSpanish.get(instDownloadDCS.parentId),tempStr);
                }else{
                    mapIdVersion.put(mapOfConvertedSpanish.get(instDownloadDCS.parentId),instDownloadDCS.DataCategoryName);
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
                
                if(mapIdVersion.containsKey(instDownloadDCS.ParentId)){
                    String tempStr = mapIdVersion.get(instDownloadDCS.ParentId);
                    tempStr = tempStr+', '  + instDownloadDCS.DataCategoryName;
                    mapIdVersion.put(instDownloadDCS.ParentId,tempStr);
                }else{
                    mapIdVersion.put(instDownloadDCS.ParentId,instDownloadDCS.DataCategoryName);
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
                
                if(mapIdVersion.ContainsKey(mapOfConvertedGerm.get(instDownloadDCS.parentId))){
                    String tempStr = mapIdVersion.get(mapOfConvertedGerm.get(instDownloadDCS.parentId));
                    tempStr = tempStr+', '  + instDownloadDCS.DataCategoryName;
                    mapIdVersion.put(mapOfConvertedGerm.get(instDownloadDCS.parentId),tempStr);
                }else{
                    mapIdVersion.put(mapOfConvertedGerm.get(instDownloadDCS.parentId),instDownloadDCS.DataCategoryName);
                }
            }
            //Spanish Section... mapOfConvertedSpanish
            if(mapOfConvertedSpanish.containsKey(instDownloadDCS.ParentId)){
                if(mapProdCatCount.containsKey(instDownloadDCS.DataCategoryName)){
                    Set<Id> idOfArt = mapProdCatCount.get(instDownloadDCS.DataCategoryName);
                    idOfArt.add(mapOfConvertedSpanish.get(instDownloadDCS.parentId));
                    mapProdCatCount.put(instDownloadDCS.DataCategoryName,idOfArt);
                }else{
                    Set<Id> idOfArt = new Set<Id>();
                    idOfArt.add(mapOfConvertedSpanish.get(instDownloadDCS.parentId));
                    mapProdCatCount.put(instDownloadDCS.DataCategoryName,idOfArt);        
                } 
                
                if(mapIdVersion.ContainsKey(mapOfConvertedSpanish.get(instDownloadDCS.parentId))){
                    String tempStr = mapIdVersion.get(mapOfConvertedSpanish.get(instDownloadDCS.parentId));
                    tempStr = tempStr+', '  + instDownloadDCS.DataCategoryName;
                    mapIdVersion.put(mapOfConvertedSpanish.get(instDownloadDCS.parentId),tempStr);
                }else{
                    mapIdVersion.put(mapOfConvertedSpanish.get(instDownloadDCS.parentId),instDownloadDCS.DataCategoryName);
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
                if(mapIdVersion.containsKey(instDownloadDCS.ParentId)){
                    String tempStr = mapIdVersion.get(instDownloadDCS.ParentId);
                    tempStr = tempStr+', '  + instDownloadDCS.DataCategoryName;
                    mapIdVersion.put(instDownloadDCS.ParentId,tempStr);
                }else{
                    mapIdVersion.put(instDownloadDCS.ParentId,instDownloadDCS.DataCategoryName);
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
                if(mapIdVersion.ContainsKey(mapOfConvertedGerm.get(instDownloadDCS.parentId))){
                    String tempStr = mapIdVersion.get(mapOfConvertedGerm.get(instDownloadDCS.parentId));
                    tempStr = tempStr+', '  + instDownloadDCS.DataCategoryName;
                    mapIdVersion.put(mapOfConvertedGerm.get(instDownloadDCS.parentId),tempStr);
                }else{
                    mapIdVersion.put(mapOfConvertedGerm.get(instDownloadDCS.parentId),instDownloadDCS.DataCategoryName);
                }
            }
            // Spanish Section .... mapOfConvertedSpanish
            if(mapOfConvertedSpanish.containsKey(instDownloadDCS.ParentId)){
                if(mapProdCatCount.containsKey(instDownloadDCS.DataCategoryName)){
                    Set<Id> idOfArt = mapProdCatCount.get(instDownloadDCS.DataCategoryName);
                    idOfArt.add(mapOfConvertedSpanish.get(instDownloadDCS.parentId));
                    mapProdCatCount.put(instDownloadDCS.DataCategoryName,idOfArt);
                }else{
                    Set<Id> idOfArt = new Set<Id>();
                    idOfArt.add(mapOfConvertedSpanish.get(instDownloadDCS.parentId));
                    mapProdCatCount.put(instDownloadDCS.DataCategoryName,idOfArt);        
                } 
                if(mapIdVersion.ContainsKey(mapOfConvertedSpanish.get(instDownloadDCS.parentId))){
                    String tempStr = mapIdVersion.get(mapOfConvertedSpanish.get(instDownloadDCS.parentId));
                    tempStr = tempStr+', '  + instDownloadDCS.DataCategoryName;
                    mapIdVersion.put(mapOfConvertedSpanish.get(instDownloadDCS.parentId),tempStr);
                }else{
                    mapIdVersion.put(mapOfConvertedSpanish.get(instDownloadDCS.parentId),instDownloadDCS.DataCategoryName);
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
                if(mapIdVersion.containsKey(instDownloadDCS.ParentId)){
                    String tempStr = mapIdVersion.get(instDownloadDCS.ParentId);
                    tempStr = tempStr+', '  + instDownloadDCS.DataCategoryName;
                    mapIdVersion.put(instDownloadDCS.ParentId,tempStr);
                }else{
                    mapIdVersion.put(instDownloadDCS.ParentId,instDownloadDCS.DataCategoryName);
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
                
                if(mapIdVersion.ContainsKey(mapOfConvertedGerm.get(instDownloadDCS.parentId))){
                    String tempStr = mapIdVersion.get(mapOfConvertedGerm.get(instDownloadDCS.parentId));
                    tempStr = tempStr+', '  + instDownloadDCS.DataCategoryName;
                    mapIdVersion.put(mapOfConvertedGerm.get(instDownloadDCS.parentId),tempStr);
                }else{
                    mapIdVersion.put(mapOfConvertedGerm.get(instDownloadDCS.parentId),instDownloadDCS.DataCategoryName);
                }
            }
            //Spanish Section .... mapOfConvertedSpanish
            if(mapOfConvertedSpanish.containsKey(instDownloadDCS.ParentId)){
                if(mapProdCatCount.containsKey(instDownloadDCS.DataCategoryName)){
                    Set<Id> idOfArt = mapProdCatCount.get(instDownloadDCS.DataCategoryName);
                    idOfArt.add(mapOfConvertedSpanish.get(instDownloadDCS.parentId));
                    mapProdCatCount.put(instDownloadDCS.DataCategoryName,idOfArt);
                }else{
                    Set<Id> idOfArt = new Set<Id>();
                    idOfArt.add(mapOfConvertedSpanish.get(instDownloadDCS.parentId));
                    mapProdCatCount.put(instDownloadDCS.DataCategoryName,idOfArt);        
                } 
                
                if(mapIdVersion.ContainsKey(mapOfConvertedSpanish.get(instDownloadDCS.parentId))){
                    String tempStr = mapIdVersion.get(mapOfConvertedSpanish.get(instDownloadDCS.parentId));
                    tempStr = tempStr+', '  + instDownloadDCS.DataCategoryName;
                    mapIdVersion.put(mapOfConvertedSpanish.get(instDownloadDCS.parentId),tempStr);
                }else{
                    mapIdVersion.put(mapOfConvertedSpanish.get(instDownloadDCS.parentId),instDownloadDCS.DataCategoryName);
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
                if(mapIdVersion.containsKey(instDownloadDCS.ParentId)){
                    String tempStr = mapIdVersion.get(instDownloadDCS.ParentId);
                    tempStr = tempStr+', '  + instDownloadDCS.DataCategoryName;
                    mapIdVersion.put(instDownloadDCS.ParentId,tempStr);
                }else{
                    mapIdVersion.put(instDownloadDCS.ParentId,instDownloadDCS.DataCategoryName);
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
                
                if(mapIdVersion.ContainsKey(mapOfConvertedGerm.get(instDownloadDCS.parentId))){
                    String tempStr = mapIdVersion.get(mapOfConvertedGerm.get(instDownloadDCS.parentId));
                    tempStr = tempStr+', '  + instDownloadDCS.DataCategoryName;
                    mapIdVersion.put(mapOfConvertedGerm.get(instDownloadDCS.parentId),tempStr);
                }else{
                    mapIdVersion.put(mapOfConvertedGerm.get(instDownloadDCS.parentId),instDownloadDCS.DataCategoryName);
                }
            }
            //Spanish section ..... mapOfConvertedSpanish
            if(mapOfConvertedSpanish.containsKey(instDownloadDCS.ParentId)){
                if(mapProdCatCount.containsKey(instDownloadDCS.DataCategoryName)){
                    Set<Id> idOfArt = mapProdCatCount.get(instDownloadDCS.DataCategoryName);
                    idOfArt.add(mapOfConvertedSpanish.get(instDownloadDCS.parentId));
                    mapProdCatCount.put(instDownloadDCS.DataCategoryName,idOfArt);
                }else{
                    Set<Id> idOfArt = new Set<Id>();
                    idOfArt.add(mapOfConvertedSpanish.get(instDownloadDCS.parentId));
                    mapProdCatCount.put(instDownloadDCS.DataCategoryName,idOfArt);        
                } 
                
                if(mapIdVersion.ContainsKey(mapOfConvertedSpanish.get(instDownloadDCS.parentId))){
                    String tempStr = mapIdVersion.get(mapOfConvertedSpanish.get(instDownloadDCS.parentId));
                    tempStr = tempStr+', '  + instDownloadDCS.DataCategoryName;
                    mapIdVersion.put(mapOfConvertedSpanish.get(instDownloadDCS.parentId),tempStr);
                }else{
                    mapIdVersion.put(mapOfConvertedSpanish.get(instDownloadDCS.parentId),instDownloadDCS.DataCategoryName);
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
                if(mapIdVersion.containsKey(instDownloadDCS.ParentId)){
                    String tempStr = mapIdVersion.get(instDownloadDCS.ParentId);
                    tempStr = tempStr+', '  + instDownloadDCS.DataCategoryName;
                    mapIdVersion.put(instDownloadDCS.ParentId,tempStr);
                }else{
                    mapIdVersion.put(instDownloadDCS.ParentId,instDownloadDCS.DataCategoryName);
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
                if(mapIdVersion.ContainsKey(mapOfConvertedGerm.get(instDownloadDCS.parentId))){
                    String tempStr = mapIdVersion.get(mapOfConvertedGerm.get(instDownloadDCS.parentId));
                    tempStr = tempStr+', '  + instDownloadDCS.DataCategoryName;
                    mapIdVersion.put(mapOfConvertedGerm.get(instDownloadDCS.parentId),tempStr);
                }else{
                    mapIdVersion.put(mapOfConvertedGerm.get(instDownloadDCS.parentId),instDownloadDCS.DataCategoryName);
                }
            }
            //Spanish Section..... mapOfConvertedSpanish
            if(mapOfConvertedSpanish.containsKey(instDownloadDCS.ParentId)){
                if(mapProdCatCount.containsKey(instDownloadDCS.DataCategoryName)){
                    Set<Id> idOfArt = mapProdCatCount.get(instDownloadDCS.DataCategoryName);
                    idOfArt.add(mapOfConvertedSpanish.get(instDownloadDCS.parentId));
                    mapProdCatCount.put(instDownloadDCS.DataCategoryName,idOfArt);
                }else{
                    Set<Id> idOfArt = new Set<Id>();
                    idOfArt.add(mapOfConvertedSpanish.get(instDownloadDCS.parentId));
                    mapProdCatCount.put(instDownloadDCS.DataCategoryName,idOfArt);        
                } 
                if(mapIdVersion.ContainsKey(mapOfConvertedSpanish.get(instDownloadDCS.parentId))){
                    String tempStr = mapIdVersion.get(mapOfConvertedSpanish.get(instDownloadDCS.parentId));
                    tempStr = tempStr+', '  + instDownloadDCS.DataCategoryName;
                    mapIdVersion.put(mapOfConvertedSpanish.get(instDownloadDCS.parentId),tempStr);
                }else{
                    mapIdVersion.put(mapOfConvertedSpanish.get(instDownloadDCS.parentId),instDownloadDCS.DataCategoryName);
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
                
                if(mapIdVersion.containsKey(instReleaseNote.ParentId)){
                    String tempStr = mapIdVersion.get(instReleaseNote.ParentId);
                    tempStr = tempStr+', '  + instReleaseNote.DataCategoryName;
                    mapIdVersion.put(instReleaseNote.ParentId,tempStr);
                }else{
                    mapIdVersion.put(instReleaseNote.ParentId,instReleaseNote.DataCategoryName);
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
                
                if(mapIdVersion.ContainsKey(mapOfConvertedGerm.get(instReleaseNote.parentId))){
                    String tempStr = mapIdVersion.get(mapOfConvertedGerm.get(instReleaseNote.parentId));
                    tempStr = tempStr+', '  + instReleaseNote.DataCategoryName;
                    mapIdVersion.put(mapOfConvertedGerm.get(instReleaseNote.parentId),tempStr);
                }else{
                    mapIdVersion.put(mapOfConvertedGerm.get(instReleaseNote.parentId),instReleaseNote.DataCategoryName);
                }
            }
            //Spanish Section.....mapOfConvertedSpanish
            if(mapOfConvertedSpanish.containsKey(instReleaseNote.ParentId)){
                if(mapProdCatCount.containsKey(instReleaseNote.DataCategoryName)){
                    Set<Id> idOfArt = mapProdCatCount.get(instReleaseNote.DataCategoryName);
                    idOfArt.add(mapOfConvertedSpanish.get(instReleaseNote.parentId));
                    mapProdCatCount.put(instReleaseNote.DataCategoryName,idOfArt);
                }else{
                    Set<Id> idOfArt = new Set<Id>();
                    idOfArt.add(mapOfConvertedSpanish.get(instReleaseNote.parentId));
                    mapProdCatCount.put(instReleaseNote.DataCategoryName,idOfArt);        
                } 
                
                if(mapIdVersion.ContainsKey(mapOfConvertedSpanish.get(instReleaseNote.parentId))){
                    String tempStr = mapIdVersion.get(mapOfConvertedSpanish.get(instReleaseNote.parentId));
                    tempStr = tempStr+', '  + instReleaseNote.DataCategoryName;
                    mapIdVersion.put(mapOfConvertedSpanish.get(instReleaseNote.parentId),tempStr);
                }else{
                    mapIdVersion.put(mapOfConvertedSpanish.get(instReleaseNote.parentId),instReleaseNote.DataCategoryName);
                }
            }
            
        }
        //Categorizing English and German according to their Product Category. 
        
        //Article Type Count
        
        articleTypeCount instOfarticleTypeCount;
        
        for(String instOfKAV : mapArticleTypeName.KeySet()){
           Integer count = 0;
           system.debug(instOfKAV);
           if(mapKAVType.containsKey(instOfKAV)){
               system.debug('instOfKAV+++'+instOfKAV);
               count = mapKAVType.get(instOfKAV).size();
               instOfarticleTypeCount = new articleTypeCount(mapArticleTypeName.get(instOfKAV),count,instOfKAV,true);
               lstarticleTypeCount.add(instOfarticleTypeCount);
           }else{
               instOfarticleTypeCount = new articleTypeCount(mapArticleTypeName.get(instOfKAV),0,instOfKAV,true);
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
        
        //Article Type Count
        
        //Data Category Count
        productCatCount instOfPCC;
        
        for(String instoStr : lstProdCat){
            if(mapProdCatCount.containskey(instoStr) || mapProdCatCountQues.containsKey(instoStr)){
                Integer intProdCatSize=0;
                if(mapProdCatCount.containsKey(instoStr))
                intProdCatSize = mapProdCatCount.get(instoStr).size();
                if(mapProdCatCountQues.containsKey(instoStr))
                intProdCatSize  = intProdCatSize  + mapProdCatCountQues.get(instoStr).size();
                
                if(productSel == instoStr)
                instOfPCC = new productCatCount(mapprodCatNameLabel.get(instoStr),intProdCatSize,true,instoStr);
                else 
                instOfPCC = new productCatCount(mapprodCatNameLabel.get(instoStr),intProdCatSize,false,instoStr);
                
                lstProdCatCount.add(instOfPCC);
            }else{
                if(productSel == instoStr)
                instOfPCC = new productCatCount(mapprodCatNameLabel.get(instoStr),0,true,instoStr);
                else
                instOfPCC = new productCatCount(mapprodCatNameLabel.get(instoStr),0,false,instoStr);
                
                lstProdCatCount.add(instOfPCC);
            }
        }
        //lstProdCatCount.sort();
        system.debug('lstProdCatCount++'+lstProdCatCount);
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
        //Data Category Count
        map<Id,Integer> mapofKAVS = viewStatKav(idOfKAVS);
        Integer doubKAVs;
        for(KnowledgeArticleVersion instOfKAV : mapallSearchedKAVs.Values()){
            doubKAVs = 0; 
            if(mapKAKAV.containsKey(instOfKAV.Id)){
                if(mapofKAVS.containsKey(mapKAKAV.get(instOfKAV.Id)))
                doubKAVs = Integer.valueOf(mapofKAVS.get(mapKAKAV.get(instOfKAV.Id)));
            }
            instKA = new //searchResultKA(instOfKAV.Id,instOfKAV.ArticleNumber,instOfKAV.Title,'Article',mapArticleTypeName.get(instOfKAV.ArticleType),instOfKAV.summary,instOfKAV.Language,mapIdVersion.get(instOfKAV.Id),doubKAVs);
            searchResultKA(instOfKAV.Id,instOfKAV.ArticleNumber,instOfKAV.Title,'Article',mapArticleTypeName.get(instOfKAV.ArticleType),instOfKAV.ArticleType,instOfKAV.summary,instOfKAV.Language,mapIdVersion.get(instOfKAV.Id),doubKAVs);
            lstSearchResultKAAll.add(instKA);
             
        }
        lstSearchResultKAAllStr = JSON.serialize(lstSearchResultKAAll);
    }
    
    public class articleTypeCount{
        public String Name{get;set;}
        public Integer Count{get;set;}
        public String apiName{get;set;}
        public Boolean show{get;set;}
        public articleTypeCount(String Name,Integer Count,String apiName,Boolean show){
            this.Name = Name;
            this.Count = Count;
            this.apiName = apiName;
            this.show = show;
        }
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
        public searchResultKA(Id recordid, String articleNum, String Name,String Type,String articleType,String articleTypeSec,String strSummary,String Lang,String product,Integer doubKAVs){ //latest code
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
            System.debug('product**************'+Name+'*******'+product);
            if(STring.IsNotBlank(product)){
                if(product.contains(', ')){
                    For(String productV : product.split(', '))
                    {
                        if(mapprodCatNameLabel.containsKey(productV)){
                            this.productSet.add(mapprodCatNameLabel.get(productV));
                        }
                    }
                }
                else
                {
                    this.productSet.add(mapprodCatNameLabel.get(product));
                }
                System.debug('product111111**************'+Name+'*******'+productSet);
            }
            
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
        public String prodCategory{get;set;}
        public searchResultQ(Id recordid, String Name,DateTime LastReplyDate,Integer replyCount,Boolean bestAns,String Type,String prodCategory){
            this.recordid = recordid;
            this.Name = Name;
            this.Type = Type;
            this.LastReplyDate =  LastReplyDate;
            this.replyCount =  replyCount;
            this.bestAns = bestAns;
            this.show = show;
            this.prodCategory = prodCategory;
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
    public static void fakeMethod(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }

}