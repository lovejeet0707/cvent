/*
//////////////////////////////////////
//      @author Abhishek Pandey     //
/////////////////////////////////////
Version :   1.0
Date : 22nd April 2016
Description : Page Name-CommunitysearchResultAngularPage
*/
public class CRMHelpClass {
    public string searchfor{get;set;}
    public string productSel{get;set;}
    public string strSosl;
    public String escapedQ;
    public String german ='de';
    public String english='en_US';
    public String spanish='es';
    public Boolean bestAns = false;
    //public List<searchResultQ> lstSearchResultQAll{get;set;}
    public List<LangCount> lstLangCount{get;set;}
    public map<String,List<Id>> mapProdCatCountQues = new map<String,List<Id>>();
    public map<Id,CRM_Help__c> mapallSearchedKAVs = new map<Id,CRM_Help__c>();
    public map<String,String> mapOfConvertedGerm = new map<String,String>();
    public map<String,String> mapOfConvertedSpanish = new map<String,String>();
    public map<string,Set<Id>> mapProdCatCount = new map<string,Set<Id>>();
    public static map<String,String> mapprodCatNameLabel = new map<String,String>();
    public static List<String> lstProdCat = new List<String>();
    public static Map<String,String> categoryNameVsAPI = new Map<String,String>();
    public List<productCatCount> lstProdCatCount{get;set;}
    public static Map<String,Schema.SOBjectType> gd = Schema.getGlobalDescribe();
    public static Map<String,Schema.DescribeSObjectResult> kavObjPrefixMap = new Map<String,Schema.DescribeSObjectResult>();
    //public static map<String,String> mapArticleTypeName{get;set;}
    public static Set<String> kavNames = new Set<String>();
    public static List<String> articleKavNames = new List<String>();
    //public List<articleTypeCount> lstarticleTypeCount{get;set;}
    public map<string,Set<Id>> mapKAVType = new map<string,Set<Id>>();
    public List<searchResultKA> lstSearchResultKAAll{get;set;}
    public String lstSearchResultKAAllStr{get;set;}
    public String lstSearchResultQuesStr{get;set;}
    public static Set<String> dataCategorySet;//Declaring variable to store the data from Custom Label.
    public Id caseId {get;set;}
    static{
        /*dataCategorySet = new Set<String>(Label.Cvent_Data_Categories.split(';'));
        for(String s : gd.keySet()) {
             Schema.SObjectType objectType = gd.get(s);
            Schema.DescribeSObjectResult drSObj = objectType.getDescribe();//Need to be commented in future
            if (s.contains('__kav') && drSObj.isAccessible()) {
                kavNames.add(s);
                articleKavNames.add('\''+gd.get(s).getDescribe().getName()+'\'');
            }
        }
        mapArticleTypeName = new Map<String,String>();
        Schema.DescribeSObjectResult sor;
        for (String s : kavNames) {
            sor = gd.get(s).getDescribe();
            mapArticleTypeName.put(sor.getName(),sor.getLabel());
            system.debug(mapArticleTypeName);
            kavObjPrefixMap.put(sor.getKeyPrefix().toLowerCase(), sor);
        }*/
        
        //List<DescribeDataCategoryGroupResult> describeCategoryResult;
        //List<DescribeDataCategoryGroupStructureResult> describeCategoryStructureResult;
        /*List<String> objType = new List<String>();
        objType.add('KnowledgeArticleVersion');
        describeCategoryResult = Schema.describeDataCategoryGroups(objType);*/
        //List<DataCategoryGroupSobjectTypePair> pairs = new List<DataCategoryGroupSobjectTypePair>();
        /*for(DescribeDataCategoryGroupResult singleResult : describeCategoryResult){
            DataCategoryGroupSobjectTypePair p = new DataCategoryGroupSobjectTypePair();
            p.setSobject(singleResult.getSobject());
            p.setDataCategoryGroupName(singleResult.getName());
            pairs.add(p);
        }*/
        //describeCategoryStructureResult = Schema.describeDataCategoryGroupStructures(pairs, false);
        /*for(DescribeDataCategoryGroupStructureResult singleResult : describeCategoryStructureResult){
            DataCategory [] toplevelCategories = singleResult.getTopCategories();
            List<DataCategory> allCategories = getAllCategories(toplevelCategories);
            for(DataCategory category : allCategories) {
                DataCategory [] childCategories = category.getChildCategories();
                for(DataCategory instDataCat : childCategories){
                    if(dataCategorySet.contains(instDataCat.getName())){
                        mapprodCatNameLabel.put(instDataCat.getName(),instDataCat.getlabel());
                        lstProdCat.add(instDataCat.getName());
                    }
                }
            }
        }*/
        categoryNameVsAPI.put('CPQ','CPQ');
        categoryNameVsAPI.put('FinancialForce','FinancialForce');
        categoryNameVsAPI.put('Troubleshooting','Troubleshooting');
        categoryNameVsAPI.put('DocuSign','DocuSign');
        categoryNameVsAPI.put('EBS','EBS');
        categoryNameVsAPI.put('Core Processes','Core_Processes');
        categoryNameVsAPI.put('Multi Currency','Multi_Currency');
        
        lstProdCat.add('CPQ');
        lstProdCat.add('FinancialForce');
        lstProdCat.add('Troubleshooting');
        lstProdCat.add('DocuSign');
        lstProdCat.add('EBS');
        lstProdCat.add('Core Processes');
        lstProdCat.add('Multi Currency');
        lstProdCat.Sort();
    }
    /*public static DataCategory[] getAllCategories(DataCategory [] categories){
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
    }*/
    
    public CRMHelpClass(){
        searchfor = '';
        //productSel = '';
        if(ApexPages.currentPage().getParameters().get('id') != null)
            caseId = ApexPages.currentPage().getParameters().get('id');
        
        /*if(ApexPages.currentPage().getParameters().get('productSel') != null)
            productSel = ApexPages.currentPage().getParameters().get('productSel');
        else
            productSel = null;*/
        //lstSearchResultQAll = new List<searchResultQ>();
        searchFor = ApexPages.currentPage().getParameters().get('searchFor');
        escapedQ = String.escapeSingleQuotes(searchFor);
        lstLangCount = new List<LangCount>();
        //searchResultQ instQL;
        LangCount instLangCount;
        strSosl = '';
        lstSearchResultKAAllStr = '';
        searchResultKA instKA;
        String statusKav = 'Online';
        mapOfConvertedGerm = new map<String,String>();
        mapOfConvertedSpanish = new map<String,String>();
        mapallSearchedKAVs = new map<Id,CRM_Help__c>();
        lstSearchResultKAAll = new List<searchResultKA>();
        lstProdCatCount = new List<productCatCount>();
        //lstarticleTypeCount = new List<articleTypeCount>();
        String types = String.join(articleKavNames, ',');
        List<List<SObject>> lstOfLstKav;//English Article List.....
        //List<List<SObject>> lstOfLstKavSec;//German Article List.....
        //List<List<SObject>> lstOfLstKavSpanish;//Spanish Article List.....
        //String dataCategorySearch = Label.CventDataCategoryName;
        strSosl = '';
        strSosl += 'FIND \'' + escapedQ + '\' IN ALL FIELDS RETURNING CRM_Help__c( Id,Category__c,Keywords__c,Resolution__c,Issue__c,Problem__c)';   
    
        lstOfLstKav = Search.query(strSosl);

        lstLangCount = new List<LangCount>();
        Set<Id> setIdKav = new Set<Id>();
        map<Id,Id> mapKAKAV = new map<Id,Id>();
        Set<Id> idOfKAVS =  new Set<Id>();
        Integer counterr=0;
        String searchTextTemp = escapedQ.removeStart('"');
        searchTextTemp = searchTextTemp.removeEnd('"');
        Map<String,Integer> categoryVsIssueSize = new Map<String,Integer>(); // This map will store the count of issue with respect to the Category.....
        Integer issueCount = 0;
        for(List<CRM_Help__c> lstKAVs : lstOfLstKav){
            for(CRM_Help__c instOfKav :  lstKAVs ){
                    counterr++;
                    mapallSearchedKAVs.put(instOfKav.Id,instOfKav);
                    setIdKav.add(instOfKav.Id); 
                    idOfKAVS.add(instOfKav.Id);
                    mapKAKAV.put(instOfKav.id,instOfKav.Id);
                    
                    if(!categoryVsIssueSize.containsKey(instOfKav.Category__c))
                    {    
                        issueCount = 1;
                        categoryVsIssueSize.put(instOfKav.Category__c,issueCount);
                    }
                    else
                    {
                        categoryVsIssueSize.put(instOfKav.Category__c,categoryVsIssueSize.get(instOfKav.Category__c)+1);
                    }
                    /*if(mapKAVType.containsKey(instOfKAV.ArticleType)){
                        Set<Id> lstKavSec = mapKAVType.get(instOfKAV.ArticleType);
                        lstKavSec.add(instOfKAV.Id);
                        mapKAVType.put(instOfKAV.ArticleType,lstKavSec);
                    }else{
                        Set<Id> lstKavSec = new Set<Id>();
                        lstKavSec.add(instOfKAV.Id);
                        mapKAVType.put(instOfKAV.ArticleType,lstKavSec);
                    }*/
            }
        }
        instLangCount = new LangCount('English','en_US',counterr);
        lstLangCount.add(instLangCount);
        
        /*--List<Download__DataCategorySelection> lstDownloadDCS =[SELECT Id,DataCategoryName,DataCategoryGroupName, ParentId FROM Download__DataCategorySelection WHERE ParentId =: setIdKav];--*/
        
        
        map<Id,String> mapIdVersion = new map<Id,String>();
        
        /*map<Id,Set<String>> mapIdVersion_Clone = new map<Id,Set<String>>();
        Set<String> versionSet= new Set<String>();*/
        /*
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
        }*/
        
        //articleTypeCount instOfarticleTypeCount;
        
        /*for(String instOfKAV : mapArticleTypeName.KeySet()){
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
        }*/
        
        /*List<String> lstNameSec = new List<String>();
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
        lstarticleTypeCount.addAll(lstarticleTypeCountSec);*/
        
        //Article Type Count
        
        //Data Category Count
        productCatCount instOfPCC;
        for(String instoStr : lstProdCat){//This list has the hard core value of the Category field picklist value
            if(categoryVsIssueSize.containsKey(instoStr))
                instOfPCC = new productCatCount(instoStr,categoryVsIssueSize.get(instoStr),false,categoryNameVsAPI.get(instoStr));
            else
                instOfPCC = new productCatCount(instoStr,0,false,categoryNameVsAPI.get(instoStr));
            lstProdCatCount.add(instOfPCC);
        }
        //lstProdCatCount.sort();
        system.debug('lstProdCatCount++'+lstProdCatCount);
        List<String> lstName = new List<String>();
        for(productCatCount instOfProdCat : lstProdCatCount){
            if(instOfProdCat!=null)
            lstName.add(instOfProdCat.Name);
        }
        lstName.sort();
        /*List<productCatCount> lstProdCatCountSec = new List<productCatCount>();
        for(String strName : lstName){
            for(productCatCount instOfProdCat : lstProdCatCount){
                if(strName == instOfProdCat.Name){
                    instOfPCC = new productCatCount(instOfProdCat.Name,instOfProdCat.Count,instOfProdCat.show,instOfProdCat.ApiName);
                    lstProdCatCountSec.add(instOfPCC);
                }
            }
        }*/
        //Data Category Count
        /*map<Id,Integer> mapofKAVS = viewStatKav(idOfKAVS);
        */

        for(CRM_Help__c instOfKAV : mapallSearchedKAVs.Values()){
            
            /*doubKAVs = 0; 
            if(mapKAKAV.containsKey(instOfKAV.Id)){
                if(mapofKAVS.containsKey(mapKAKAV.get(instOfKAV.Id)))
                doubKAVs = Integer.valueOf(mapofKAVS.get(mapKAKAV.get(instOfKAV.Id)));
            }*/
            
            instKA = new searchResultKA(instOfKAV.Id,categoryNameVsAPI.get(instOfKAV.Category__c),instOfKAV.Keywords__c,instOfKAV.Resolution__c,instOfKAV.Issue__c,instOfKAV.Problem__c,instOfKAV.Category__c);//'Article',mapArticleTypeName.get(instOfKAV.ArticleType),instOfKAV.ArticleType,instOfKAV.summary,instOfKAV.Language,mapIdVersion.get(instOfKAV.Id),
            lstSearchResultKAAll.add(instKA);
             
        }
        lstSearchResultKAAllStr = JSON.serialize(lstSearchResultKAAll);
    }
    
    /*public class articleTypeCount{
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
    }*/
    
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
        public String category{get;set;} //latest Code
        public String kewords{get;set;}
        public String resolution{get;set;}
        public String issue{get;set;}
        public String problemStatement{get;set;}
        public Integer doubKAVs{get;set;}
        public String categoryName{get;set;}
        /*public String articleType{get;set;}
        //public Boolean show{get;set;}
        public String strSummary{get;set;}
        public String Lang{get;set;}
        public Set<String> productSet{get;set;}
        public String product{get;set;}
        public String articleTypeSec{get;set;}*/
        public searchResultKA(Id recordid, String category, String kewords,String resolution,String issue,String problemStatement,String categoryName){ //latest code,String articleTypeSec,String strSummary,String Lang,String product,Integer doubKAVs
            //productSet = new Set<String>();
            this.recordid = recordid;
            this.category = category; //latest code
            this.kewords = kewords;
            this.resolution = resolution;
            this.issue = issue;
            this.problemStatement = problemStatement;
            this.categoryName = categoryName;
            
            /*
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
            }*/
            
        }
    }
    
    /*public class searchResultQ{
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
    }*/
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
    
    /*public map<Id,Integer> viewStatKav(Set<Id> idOfKAVS){
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
    }*/
}