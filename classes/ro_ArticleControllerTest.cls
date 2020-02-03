@isTest
public class ro_ArticleControllerTest {
    @isTest
    public static void unitTest(){
        
        TabConfiguration__c oTabConfiguration = new TabConfiguration__c();
     oTabConfiguration.Name = 'Internal';
     oTabConfiguration.Tabs__c = 'home,articles,training,guides,lanyoncommunities,ideas,support';
     insert oTabConfiguration;
     
     CategoryMapping__c oCategoryMapping = new CategoryMapping__c();
     oCategoryMapping.Name = 'Internal';
     oCategoryMapping.Actual_Community_Name__c = 'Internal';
     oCategoryMapping.Category__c = 'REGONLINE';
     oCategoryMapping.Category_Group__c = 'Products';
     oCategoryMapping.Product__c = 'RegOnline';
     oCategoryMapping.Product_Family_Name__c = 'RegOnline';
     oCategoryMapping.OwnerId__c = userinfo.getUserId();
     insert oCategoryMapping;
     
        list<SObject> lstKAV = new list<SObject>();
        
        set<String> setKAVObjName = new set<String>();
        map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
    for(String s : gd.keySet()) {
        if(s.contains('__kav') && setKAVObjName.size()<10) {
            setKAVObjName.add(s);
        }
    } 
     
     for(String kavObjName : setKAVObjName) {
      System.debug('@Developer --> kavObjName:' + kavObjName);
      
      sObject oKav = Schema.getGlobalDescribe().get(kavObjName).newSObject();
      oKav.put('title',  kavObjName.removeEnd('__kav').replaceAll('_', ' '));
            oKav.put('UrlName', kavObjName.removeEnd('__kav').replaceAll('_', '-') + '-xxx-test');
            oKav.put('Summary', 'test Summary');
            oKav.put('Language', 'en_US');
            
      System.debug('@Developer --> oKav:' + oKav);
      lstKAV.add(oKav);
     } 
     
     
     
     if(lstKAV.size()>0){
        insert lstKAV;
     
     }
         
     System.debug('@Developer --> lstKAV:' + lstKAV);
     
     Integer nIndx = 0;
     list<SObject> lstKAVDataCategorySelection = new list<SObject>();
     for(String kavObjName : setKAVObjName) {
        String sDataCategorySelectionName = kavObjName.removeEnd('__kav') + '__DataCategorySelection';
      System.debug('@Developer --> sDataCategorySelectionName:' + sDataCategorySelectionName);
      
      sObject oKavDataCategorySelection = Schema.getGlobalDescribe().get(sDataCategorySelectionName).newSObject(); 
      oKavDataCategorySelection.put('parentId', lstKAV[nIndx].Id);
      oKavDataCategorySelection.put('DataCategoryName', 'REGONLINE');
      oKavDataCategorySelection.put('DataCategoryGroupName', 'Products');
      lstKAVDataCategorySelection.add(oKavDataCategorySelection);
      nIndx++;
     }
     
     insert lstKAVDataCategorySelection;
     
     list<KnowledgeArticleVersion> kavList = [Select id,KnowledgeArticleId,PublishStatus 
                                                 From KnowledgeArticleVersion 
                                                 Where (PublishStatus='Draft' and language='en_US')];
                                                 
        System.debug('@Developer --> Before publish kavList:' + kavList);
     
     for(KnowledgeArticleVersion oKav : kavList){
      KbManagement.PublishingService.publishArticle(oKav.KnowledgeArticleId, true); 
     }
     
     
     
     
     kavList = [Select id,KnowledgeArticleId,PublishStatus 
                                                 From KnowledgeArticleVersion 
                                                 Where (PublishStatus='Online' and language='en_US')];
                                                 
        System.debug('@Developer --> After publish kavList:' + kavList);
     
        ro_ArticleController cont = new ro_ArticleController();
        cont.sView = 'Articles';
        cont.sSearch = 'test';
        cont.getValidToRender();
        cont.oCategory.lstSubCategory.sort();
        
        cont.sortField = 'ArticleNumber';
        cont.doSort();
        cont.articlePaginator.resultsPerPage = 2;
        cont.searchText = '';
        cont.searchArticle();
        cont.doSort();
        if(cont.articlePaginator.hasNextPage){
         cont.articlePaginator.nextPage();
        }
        
        if(cont.articlePaginator.hasPrevPage){
         cont.articlePaginator.prevPage();
        }
        
        if(cont.articlePaginator.hasFirstPage){
         cont.articlePaginator.firstPage();
        }
        
        if(cont.articlePaginator.hasLastPage){
         cont.articlePaginator.lastPage();
        }
        
        cont.articlePaginator.refresh();
        Integer nCount = cont.articlePaginator.totalResults;
     
     cont.sView = 'Support';
        cont.searchText = 'test';   
     cont.sortField = 'ArticleNumber';
     cont.isAsc = false;
        cont.doSort();
        cont.searchArticle();   
        
        
    }
}