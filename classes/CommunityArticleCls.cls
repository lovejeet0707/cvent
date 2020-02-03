/*
//////////////////////////////////////
//      @author Abhishek Pandey     //
/////////////////////////////////////
Version :   1.0
Date : 21st April 2015
Description-Test Class Name-CommunitysearchResultClsTest
Version :   2.0
Date : 22 Nov 2015
Description-Release Notes Article type enhancement
*/
public class CommunityArticleCls {
    public User usr{get;set;}
    public String articleTitle{get;set;}
    public string articleId{get;set;}
    public string articlenum{get;set;}  //latest code
    public String kbarticleId{get;set;} //latest code
    public String lang{get;set;}
    public KnowledgeArticleVersion instOfKAV{get;set;}
    
    public KnowledgeArticleViewStat Viewcount {get;set;}
    public Sobject KavObject{get;set;} 
    public knowledgeData kavDat{get;set;}
    public List<LstResponses> lstRes{get;set;}
    public String body{get;set;}
    public String relatedArticle{get;set;}
    public PKB_Article_Feedback_Deflection__c instPAFD{get;set;}
    public Boolean flag{get;set;}
    public Download__kav instOFDK{get;set;}
    public String yesNo{get;set;}
    public String statusKav;
    public List<String> lstStrDataCatName{get;set;}
    public String kavParentId{get;set;}
    public String ratingAlready{get;set;}
    
    public String strArtType{get;set;}
    public static map<String,String> mapprodCatNameLabel = new map<String,String>();
    public static map<String,String> mapArticleTypeName{get;set;}
    public static Map<String,Schema.SOBjectType> gd = Schema.getGlobalDescribe();
    public static Set<String> kavNames = new Set<String>();
    
    public String productSel {get; set;}
    public String searchTerm {get; set;}
    public static Set<String> dataCategorySet;//Declaring variable to store the data from Custom Label.

    static{
        dataCategorySet = new Set<String>(Label.Cvent_Data_Categories.split(';'));//Initializing set and adding Custom Label values in it.
        gd = Schema.getGlobalDescribe();
        for(String s : gd.keySet()){
            if (s.contains('__kav')) {
                kavNames.add(s);
            }
        }
        
        mapArticleTypeName = new Map<String,String>();
        Schema.DescribeSObjectResult sor;
        for (String s : kavNames) {
            system.debug(s);
            sor = gd.get(s).getDescribe();
            system.debug(sor);
            mapArticleTypeName.put(sor.getName(),sor.getLabel());
            //system.debug(mapArticleTypeName);
            //kavObjPrefixMap.put(sor.getKeyPrefix().toLowerCase(), sor);
            //system.debug(sor.getKeyPrefix().toLowerCase());
        }
        
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
                    system.debug(instDataCat.getlabel());
                    system.debug(instDataCat.getName());
                    if(dataCategorySet.contains(instDataCat.getName())){
                        mapprodCatNameLabel.put(instDataCat.getName(),instDataCat.getlabel());
                    }
                    //lstProdCat.add(instDataCat.getName());
                }
            }
        }

        if(Boolean.ValueOf(Label.RemoveChildCategory)){
        mapprodCatNameLabel.put('Event1Standard','Classic');
        mapprodCatNameLabel.put('Event2Flex','Flex');
        mapprodCatNameLabel.put('Event3Express','Express');
        }
        System.debug('dataCategorySet************'+dataCategorySet);

        
    }
    public PageReference search() {
        system.debug(searchTerm);
        system.debug(productSel);        
        PageReference pageRef = new PageReference('/apex/CommunitysearchResultPage?searchFor='+searchTerm+'&productSel='+productSel);
        pageRef.setRedirect(true);
        system.debug(pageRef);        
        return pageRef;
        
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
    public CommunityArticleCls(){
        usr = [SELECT ID,smallphotoURl,ShowLitmosTab__c,Name FROM User WHERE Id=: UserInfo.getUserId()]; 
        yesNo = '';
        statusKav = '';
        strArtType = '';
        kavParentId = '';
        ratingAlready = '';
        flag = false;
        
        Schema.DescribeFieldResult fieldResult = PKB_Article_Feedback_Deflection__c.Response_if_No__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        //lstRes = new
        LstResponses instRes;
        lstRes = new List<LstResponses>(); 
        for( Schema.PicklistEntry f : ple){
          //options.add(new SelectOption(f.getLabel(), f.getValue()));
          instRes = new LstResponses(f.getLabel());
          lstRes.add(instRes);
        }     
        //articleId = ApexPages.currentPage().getParameters().get('Id');
        kbarticleId = ApexPages.currentPage().getParameters().get('Id'); //latest code
        
        if(ApexPages.currentPage().getParameters().get('Lang') != null)
        lang = ApexPages.currentPage().getParameters().get('Lang');
        
        if(ApexPages.currentPage().getParameters().get('Lang') == null)
        lang = 'en_US';
        
        //articlenum = [Select Id from KnowledgeArticle WHERE ArticleNumber=:kbarticleId].get(0).Id; //latest code
        //articleId = [Select Id from KnowledgeArticleVersion WHERE PublishStatus='Online' AND KnowledgeArticleId=:articlenum].get(0).Id; //latest code
        instOfKAV = new KnowledgeArticleVersion();
        instPAFD = new PKB_Article_Feedback_Deflection__c();
        Download__kav instOFDK = new Download__kav();
        statusKav = 'Online';
        List<KnowledgeArticleVersion> sobjList = Database.query('SELECT KnowledgeArticleId,Summary,ArticleType,title,ArticleNumber,MasterVersionId FROM KnowledgeArticleVersion WHERE PublishStatus = :statusKav AND ArticleNumber=:kbarticleId AND IsLatestVersion=true AND Language =:lang update Viewstat');
        instOfKAV = sobjList[0];
        
        articleTitle = instOfKAV.title.remove('\'');
        
        system.debug('articleId+++'+articleId);
        kavParentId = instOfKAV.KnowledgeArticleId;
        
        List<Vote> userVote = [SELECT CreatedById, ParentId,Type FROM Vote WHERE CreatedById = :UserInfo.getUserId() AND ParentId = :kavParentId];
        
        if( userVote.size() > 0){
            ratingAlready = userVote[0].Type;
        }else{
            ratingAlready = '0';
        }
        
        strArtType = mapArticleTypeName.get(instOfKAV.ArticleType);
        Id idTempKAVId;
        
        if(instOfKAV.MasterVersionId != null)
        idTempKAVId = instOfKAV.MasterVersionId;
        else
        idTempKAVId = instOfKAV.Id;
        
        List<Download__DataCategorySelection> lstDownloadDCS =[SELECT Id,DataCategoryName,DataCategoryGroupName, ParentId FROM Download__DataCategorySelection WHERE ParentId =: idTempKAVId];
        List<FAQ__DataCategorySelection> lstFAQDCS  = [SELECT Id,DataCategoryName, DataCategoryGroupName,ParentId FROM FAQ__DataCategorySelection WHERE ParentId =: idTempKAVId];
        List<Instructions__DataCategorySelection> lstInstructionsDCS =[SELECT Id,DataCategoryName,DataCategoryGroupName, ParentId FROM Instructions__DataCategorySelection WHERE ParentId =: idTempKAVId];
        List<Marketing_Materials__DataCategorySelection> lstMarkMDCS =[SELECT Id,DataCategoryName,DataCategoryGroupName, ParentId FROM Marketing_Materials__DataCategorySelection WHERE ParentId =: idTempKAVId];
        List<Topic_Hub__DataCategorySelection> lstTopicHDCS =[SELECT Id,DataCategoryName, DataCategoryGroupName,ParentId FROM Topic_Hub__DataCategorySelection WHERE ParentId =: idTempKAVId];
        List<Video__DataCategorySelection> lstVideoDDCS =[SELECT Id,DataCategoryName, DataCategoryGroupName,ParentId FROM Video__DataCategorySelection WHERE ParentId =: idTempKAVId];
        List<Release_Notes__DataCategorySelection> lstReleaseNotes =[SELECT Id,DataCategoryName, DataCategoryGroupName,ParentId FROM Release_Notes__DataCategorySelection WHERE ParentId =: idTempKAVId];
        
        lstStrDataCatName = new List<String>();
        system.debug('lstDownloadDCS++'+lstDownloadDCS);
        system.debug('lstFAQDCS++'+lstFAQDCS);
        system.debug('lstInstructionsDCS++'+lstInstructionsDCS);
        system.debug('lstMarkMDCS++'+lstMarkMDCS);
        system.debug('lstTopicHDCS++'+lstTopicHDCS);
        system.debug('lstVideoDDCS++'+lstVideoDDCS);
        system.debug('lstReleaseNotes++'+lstReleaseNotes);
        system.debug('mapprodCatNameLabel++'+mapprodCatNameLabel);
        //system.debug('mapprodCatNameLabel++'+lstDownloadDCS[0].DataCategoryName);
        for(Download__DataCategorySelection instOfDCS : lstDownloadDCS)
        lstStrDataCatName.add(mapprodCatNameLabel.get(instOfDCS.DataCategoryName));
        for(FAQ__DataCategorySelection instOfDCS : lstFAQDCS)
        lstStrDataCatName.add(mapprodCatNameLabel.get(instOfDCS.DataCategoryName));
        for(Marketing_Materials__DataCategorySelection instOfDCS : lstMarkMDCS)
        lstStrDataCatName.add(mapprodCatNameLabel.get(instOfDCS.DataCategoryName));
        for(Topic_Hub__DataCategorySelection instOfDCS : lstTopicHDCS)
        lstStrDataCatName.add(mapprodCatNameLabel.get(instOfDCS.DataCategoryName));
        for(Video__DataCategorySelection instOfDCS : lstVideoDDCS)
        lstStrDataCatName.add(mapprodCatNameLabel.get(instOfDCS.DataCategoryName));
        for(Release_Notes__DataCategorySelection instOfDCS : lstReleaseNotes)
        lstStrDataCatName.add(mapprodCatNameLabel.get(instOfDCS.DataCategoryName));
        for(Instructions__DataCategorySelection instOfDCS : lstInstructionsDCS)
        lstStrDataCatName.add(mapprodCatNameLabel.get(instOfDCS.DataCategoryName));
        system.debug('lstStrDataCatName++'+lstStrDataCatName);
        //instOfKAV= [SELECT KnowledgeArticleId,Summary,ArticleType,title,ArticleNumber FROM KnowledgeArticleVersion WHERE Id=:articleId AND IsLatestVersion=true update Viewstat];
        //Viewcount = [SELECT Id, NormalizedScore, Parent.Id FROM KnowledgeArticleViewStat];
        String status = 'Online';
        //String lang = 'en_US';
        String objectTemp = instOfKAV.ArticleType;
        system.debug(objectTemp);
        
        String IdOfKav = instOfKAV.KnowledgeArticleId;
        knowledgeData kavDat;
        body = '';
        relatedArticle = '';
        
        //sobject KavObject = new sobject();
        
        
        if(instOfKAV.ArticleType == 'FAQ__kav'){
            KavObject = Database.query('Select id,Question__c,Related_Article__c,FirstPublishedDate,LastModifiedDate,LastPublishedDate,Summary from '+objectTemp+' where PublishStatus =:status AND Language =:lang AND KnowledgeArticleId =:IdOfKav');
            //body = KavObject.Body__c;
            //relatedArticle = KavObject.Related_Articles__c;
            body = String.valueof(KavObject.get('Related_Article__c'));
            relatedArticle = String.valueof(KavObject.get('Related_Article__c'));
            //kavDat = new knowledgeData(String.valueof(KavObject.get('Question__c')),String.valueof(KavObject.get('Related_Articles__c'))); 
        }
        articleId = instOfKAV.KnowledgeArticleId;
        
        if(instOfKAV.ArticleType == 'Instructions__kav'){
            KavObject = Database.query('Select id,Body__c,Chat_Text__c,Related_Articles__c,FirstPublishedDate,LastModifiedDate,LastPublishedDate,Summary from '+objectTemp+' where PublishStatus =:status AND Language =:lang AND KnowledgeArticleId =:IdOfKav');        
            system.debug(String.valueof(KavObject.get('Body__c')));
            system.debug(String.valueof(KavObject.get('Related_Articles__c')));
            body = String.valueof(KavObject.get('Body__c'));
            relatedArticle = String.valueof(KavObject.get('Related_Articles__c'));
            kavDat = new knowledgeData(String.valueof(KavObject.get('Body__c')),String.valueof(KavObject.get('Related_Articles__c'))); 
        }
        
        if(instOfKAV.ArticleType == 'Marketing_Materials__kav'){
            KavObject = Database.query('Select id,Body__c,Chat_Text__c,Related_Articles__c,FirstPublishedDate,LastModifiedDate,LastPublishedDate,Summary from '+objectTemp+' where PublishStatus =:status AND Language =:lang AND KnowledgeArticleId =:IdOfKav');
            body = String.valueof(KavObject.get('Body__c'));
            relatedArticle = String.valueof(KavObject.get('Related_Articles__c'));
        }
        if(instOfKAV.ArticleType == 'Download__kav'){
            instOFDK = Database.query('Select id,Body__c,Download_File__Body__s,FirstPublishedDate,LastModifiedDate,LastPublishedDate,Download_File__Name__s,Summary from '+objectTemp+' where PublishStatus =:status AND Language =:lang AND KnowledgeArticleId =:IdOfKav');
            //body = String.valueof(KavObject.get('Body__c'));
            //relatedArticle = String.valueof(KavObject.get('Download_File__c'));
            body = instOFDK.Body__c;
            relatedArticle  = instOFDK.Download_File__Name__s;
            //kavDat = new knowledgeData(String.valueof(KavObject.get('Body__c')),String.valueof(KavObject.get('Download_File__c')));
        }
        
        if(instOfKAV.ArticleType == 'Topic_Hub__kav'){
            KavObject = Database.query('Select id,Body__c,FirstPublishedDate,LastModifiedDate,LastPublishedDate,Summary from '+objectTemp+' where PublishStatus =:status AND Language =:lang AND KnowledgeArticleId =:IdOfKav');
            body = String.valueof(KavObject.get('Body__c'));
            //kavDat = new knowledgeData(String.valueof(KavObject.get('Body__c')),'Blank');
        }
        if(instOfKAV.ArticleType == 'Video__kav'){
            KavObject = Database.query('Select id,Body__c,Related_Article__c,FirstPublishedDate,LastModifiedDate,LastPublishedDate,Summary from '+objectTemp+' where PublishStatus =:status AND Language =:lang AND KnowledgeArticleId =:IdOfKav');
            body = String.valueof(KavObject.get('Body__c'));
            relatedArticle = String.valueof(KavObject.get('Related_Article__c'));
            //kavDat = new knowledgeData(String.valueof(KavObject.get('Body__c')),'Blank');
        }
        if(instOfKAV.ArticleType == 'Release_Notes__kav'){
            KavObject = Database.query('Select id,Body__c,Related_Article__c,FirstPublishedDate,LastModifiedDate,LastPublishedDate,Summary from '+objectTemp+' where PublishStatus =:status AND Language =:lang AND KnowledgeArticleId =:IdOfKav');
            body = String.valueof(KavObject.get('Body__c'));
            relatedArticle = String.valueof(KavObject.get('Related_Article__c'));
            //kavDat = new knowledgeData(String.valueof(KavObject.get('Body__c')),'Blank');
        }// End here 
        
        //if()
    }
    
    public PageReference yesNo() {
        //system.debug('yesNo++'+yesNo);
        //flag = true;
        return null;
    }
    
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('Yes','Yes')); 
        options.add(new SelectOption('No','No')); 
        return options; 
    }
    @RemoteAction
    public static String save(String articleId,String articleTitle, String articleNumber,String source,String comments){//,String responseIfNo){
        //system.debug('yesNo++'+yesNo);
        //yesNo = yesNo;
        PKB_Article_Feedback_Deflection__c instPAFD = new PKB_Article_Feedback_Deflection__c ();
        instPAFD.Article_ID__c = articleId;
        instPAFD.Article_Title__c = articleTitle;
        instPAFD.Article_Number__c = articleNumber;
        instPAFD.Feedback_Source__c = source;
        instPAFD.comments__c = comments;    
        //instPAFD.Response_if_No__c = responseIfNo;
        //flag = true;
        insert instPAFD;
        
        return null;
    }
    public class knowledgeData{
        public String body{get;set;}
        public String RelatedArt{get;set;}
        public knowledgeData(String body,String RelatedArt){
            this.body = body;
            this.RelatedArt = RelatedArt;
        }
    }
    
    public class LstResponses{
        public String values{get;set;}
        public LstResponses(String values){
            this.values= values;
        }
    }
    
    @RemoteAction
    public static String updateRatings(String num,String parentId){
        Vote instOfVote = new Vote();
        instOfVote.Type = num;
        instOfVote.ParentId = parentId;
        insert instOfVote;
        return null;
    }
}