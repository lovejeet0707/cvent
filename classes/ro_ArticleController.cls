/*
Version 1
Author : HSR
Date : 13th April 2017
Description : Included isAccessible() so that it can be used to show only Lanyon Article Types as these user profiles have access for these Articles ypes only in the Vf Page.

*/
public class ro_ArticleController {
    
    public list<cArticleType> lstArticleType {get;set;}
    public String selectedArticleTypes{get;set;}
    public transient cCategory oCategory {get;set;}
    public String selectedCategory{get;set;}
    public String sView {get;set;}
    public String sCategoryGroup {get;set;}
    public String sCategory  {get;set;}
    public String sSearch  {get;set;}
    public String searchText{get;set;}
    public String sortField{get;set;}
    public String previousSortField {get;set;}
    public Boolean isAsc {get;set;}
    public Boolean bSearchInitiated {get;set;}
    public list<cArticle> articleSearchResults {get;set;}
    public list<cArticle> articleCurrentRecordSet {get;set;}
    public Paginator articlePaginator {get;set;}
    public String errMessage {get;set;}
    private map < String, String > mapObjPrefixWiseArticleType = new map < String, String > ();
    private list < String > lstCategoryGroup = new list < String > ();
    private String sDefCategoryGroup = ro_ConfigHelper.self.categoryGroup;
    private String sDefCategory = ro_ConfigHelper.self.category;
    private String sDefArticleTypes = '';
    private String sObjectName = 'KnowledgeArticleVersion';
    private Boolean isInitialized;

    public ro_ArticleController() {
        System.debug('@Developer -->ro_ArticleController');
        isInitialized = false;
        System.debug('@Developer -->ro_ArticleController -->isInitialized:' + isInitialized);
    }

    public Boolean getValidToRender() {
        System.debug('@Developer -->getValidToRender -->isInitialized:' + isInitialized);
        System.debug('@Developer -->sView:' + sView);
        System.debug('@Developer -->sCategoryGroup:' + sCategoryGroup);
        System.debug('@Developer -->sCategory:' + sCategory);
        System.debug('@Developer -->searchText:' + searchText);

        System.debug('@Developer -->selectedCategory:' + selectedCategory);
        System.debug('@Developer -->selectedArticleTypes:' + selectedArticleTypes);

        if (!isInitialized) {

            if (sCategoryGroup == null) {
                sCategoryGroup = sDefCategoryGroup;
            }

            if (sCategory == null) {
                sCategory = sDefCategory;
            }

            init();

            selectedCategory = sCategory;
            selectedArticleTypes = sDefArticleTypes;
            if (sSearch != null && sSearch != '') {
                searchText = sSearch;
            }

            if (sView == 'Articles') {
                searchArticle();
            }

            isInitialized = true;
        }

        return true;
    }

    public void doSort() {
        System.debug('@Developer -->previousSortField:' + previousSortField);
        System.debug('@Developer -->sortField:' + sortField);
        if (previousSortField != sortField) {
            isAsc = true;
            previousSortField = sortField;
        } else {
            isAsc = !isAsc;
        }
        searchArticle();
    }

    public void searchArticle() {
        bSearchInitiated = true;
        errMessage = '';
        if (sView == 'Support') {
            selectedArticleTypes = sDefArticleTypes;
            selectedCategory = sCategory;
        }

        System.debug('@Developer -->selectedArticleTypes:' + selectedArticleTypes);
        System.debug('@Developer -->selectedCategory:' + selectedCategory);
        System.debug('@Developer -->searchText:' + searchText);

        list < string > articleTypes = new list < String > ();
        if (selectedArticleTypes != '') {
            for (String sTmp: selectedArticleTypes.split(',')) {
                articleTypes.add(sTmp + 'v');
            }
        }
        System.debug('@Developer -->articleTypes:' + articleTypes);

        list < KnowledgeArticleVersion > lstKAV = new List < KnowledgeArticleVersion > ();
        String categoryFilter = '';
        if (selectedCategory != '') {
            categoryFilter = ' WITH DATA CATEGORY ' + sCategoryGroup + '__c ABOVE_OR_BELOW ' + selectedCategory + '__c';

        }

        if (searchText == null || searchText == '') {
            String sSoql = '';
            sSoql = ' SELECT Id,knowledgeArticleId, ArticleNumber,ArticleType, title, UrlName ';
            sSoql += ' FROM KnowledgeArticleVersion';
            sSoql += ' WHERE ( PublishStatus = \'online\' and Language = \'en_US\'';

            if (articleTypes.size() > 0) {
                sSoql += ' And ArticleType In:articleTypes ';
            }
            sSoql += ' ) ';
            sSoql += categoryFilter;

            if (sortField != '') {
                sSoql += ' order by ' + sortField;

                if (isAsc) {
                    sSoql += ' asc';
                } else {
                    sSoql += ' desc';
                }
            }

            sSoql += ' Limit 1001';
            System.debug('@Developer -->sSoql:' + sSoql);

            lstKAV = Database.query(sSoql);
        } else if (searchText != '' && searchText.length() == 1) {
            errMessage = 'Search text should be more than one character';
        } else if (searchText != '' && searchText.length() > 1) {
            String sTmp = searchText.replaceAll('\\\'', '\\\\\\\'');
            String sSosl = '';
            sSosl = 'FIND \'' + sTmp + '*\'IN ALL FIELDS ';
            sSosl += ' RETURNING KnowledgeArticleVersion(Id,knowledgeArticleId, ArticleNumber,ArticleType, title, UrlName';
            sSosl += ' Where PublishStatus =\'online\' and Language = \'en_US\' ';

            if (articleTypes.size() > 0) {
                sSosl += ' And ArticleType In:articleTypes ';
            }

            if (sortField != '') {
                sSosl += ' order by ' + sortField;

                if (isAsc) {
                    sSosl += ' asc';
                } else {
                    sSosl += ' desc';
                }
            }

            sSosl += ' ) ';
            sSosl += categoryFilter;

            sSosl += ' Limit 1001';
            System.debug('@Developer -->sSosl:' + sSosl);

            List < List < SObject >> result = search.query(sSosl);
            lstKAV = (List < KnowledgeArticleVersion > ) result[0];
        }

        System.debug('@Developer -->lstKAV.size:' + lstKAV.size());
        articleSearchResults.clear();

        if (lstKAV.size() > 1000) {
            articlePaginator.moreThan1000 = true;
            lstKAV.remove(1000);
        } else {
            articlePaginator.moreThan1000 = false;
        }

        for (KnowledgeArticleVersion kav: lstKAV) {
            articleSearchResults.add(new cArticle(kav));
        }

        articlePaginator.firstPage();

    }

    private void init() {
        bSearchInitiated = false;
        errMessage = '';
        sortField = '';
        previousSortField = '';
        isAsc = false;

        lstArticleType = new list < cArticleType > ();
        fetchArticleTypes();

        fetchCategoryGroups();
        System.debug('@Developer -->lstCategoryGroup:' + lstCategoryGroup);
        fetchCategories();
        System.debug('@Developer -->oCategory:' + oCategory);

        articleSearchResults = new List < cArticle > ();
        articleCurrentRecordSet = new List < cArticle > ();
        articlePaginator = new Paginator();
        articlePaginator.resultsPerPage = 10;
        articlePaginator.searchResults = (list < cArticle > ) articleSearchResults;
        articlePaginator.currentRecordSet = (list < cArticle > ) articleCurrentRecordSet;
    }

    private void fetchCategoryGroups() {
        List < DescribeDataCategoryGroupResult > describeCategoryResult;
        List < String > objType = new List < String > ();
        objType.add(sObjectName);
        //Describe Call
        describeCategoryResult = Schema.describeDataCategoryGroups(objType);
        //Using the results and retrieving the information
        for (DescribeDataCategoryGroupResult singleResult: describeCategoryResult) {
            lstCategoryGroup.add(singleResult.getName());
            /*System.debug('Name >>>'+singleResult.getName());    
            System.debug('Label >>>'+singleResult.getLabel());
            System.debug('Desc >>>'+singleResult.getDescription());*/
        }
    }

    private void fetchCategories() {
        System.debug('@Developer -->fetchCategories()');

        list < DataCategoryGroupSobjectTypePair > lstoDataCategoryGroupSObjectTypePair = new list < DataCategoryGroupSobjectTypePair > ();
        Schema.DataCategoryGroupSObjectTypePair oDataCategoryGroupSObjectTypePair = new Schema.DataCategoryGroupSObjectTypePair();
        System.debug('@Developer -->sObjectName:' + sObjectName);
        System.debug('@Developer -->sCategoryGroup:' + sCategoryGroup);
        System.debug('@Developer -->sCategory:' + sCategory);

        oDataCategoryGroupSObjectTypePair.sObject = sObjectName;
        oDataCategoryGroupSObjectTypePair.dataCategoryGroupName = sCategoryGroup;
        lstoDataCategoryGroupSObjectTypePair.add(oDataCategoryGroupSObjectTypePair);
        System.debug('@Developer -->lstoDataCategoryGroupSObjectTypePair:' + lstoDataCategoryGroupSObjectTypePair);

        DataCategory[] toplevelCategories;
        
        for (DescribeDataCategoryGroupStructureResult singleResult: Schema.describeDataCategoryGroupStructures(lstoDataCategoryGroupSObjectTypePair, false)) {
            System.debug('@Developer -->singleResult:' + singleResult);
            System.debug('@Developer -->singleResult.getName():' + singleResult.getName());
            toplevelCategories = singleResult.getTopCategories();
        }
  
  Boolean bHasAllAccess = false;
        System.debug('@Developer -->toplevelCategories:' + toplevelCategories);
        System.debug('@Developer -->toplevelCategories[0].getName():' + toplevelCategories[0].getName());
        
        bHasAllAccess = toplevelCategories[0].getName().toLowerCase() == 'all'?true:false;
        System.debug('@Developer -->bHasAllAccess:' + bHasAllAccess);
        
  if(bHasAllAccess){
            for (DataCategory oDataCategory: toplevelCategories[0].getChildCategories()) {
                System.debug('@Developer -->oDataCategory.getName():' + oDataCategory.getName());
                System.debug('@Developer -->sCategory:' + sCategory);
                if (oDataCategory.getName() == sCategory) {
                    oCategory = new cCategory(oDataCategory);
                    System.debug('@Developer -->oCategory:' + oCategory);
                    fillDataCategoryTree(oCategory);
                    break;
                }
            }
  }
  else{
    oCategory = new cCategory(toplevelCategories[0]);
            System.debug('@Developer -->oCategory:' + oCategory);
            System.debug('@Developer -->sCategory:' + sCategory);
            fillDataCategoryTree(oCategory);
  }
        
        System.debug('@Developer -->oCategory.oDataCategory.getName():' + oCategory.oDataCategory.getName());
        for(cCategory oCat:oCategory.lstSubCategory){
         System.debug('@Developer -->oCat.oDataCategory.getName():-' + oCat.oDataCategory.getName());
         for(cCategory oSubCat:oCat.lstSubCategory){
          System.debug('@Developer -->oSubCat.oDataCategory.getName():--' + oSubCat.oDataCategory.getName());
         }  
        }
        
    }
    
    private void fillDataCategoryTree(cCategory oCat){
  System.debug('@Developer -->oCat:' + oCat);
  System.debug('@Developer -->oCat.oDataCategory.getChildCategories().size():' + oCat.oDataCategory.getChildCategories().size());
  System.debug('@Developer -->oCat.oDataCategory.getChildCategories():' + oCat.oDataCategory.getChildCategories());
  
  if(oCat.oDataCategory.getChildCategories().size() == 0){
    return;
  }
  else{
   for(DataCategory oSubDataCategory :oCat.oDataCategory.getChildCategories()){
    system.debug('@Developer -->oSubDataCategory.getName():' + oSubDataCategory.getName());
    cCategory subcat = new cCategory(oSubDataCategory);
    oCat.lstSubCategory.add(subcat);
    fillDataCategoryTree(subcat);   
   }
  }
 }

    @testVisible private void fetchArticleTypes() {
        sDefArticleTypes = '';
        map < String, Schema.SObjectType > gd = Schema.getGlobalDescribe();
        set < String > keySet = gd.keySet();
        for (String key: keySet) {
            Schema.SObjectType objectType = gd.get(key);
            /*HSR : 13th April 2017 : Included isAccessible() so that it can be used to show only Lanyon Article Types as these user profiles have access for these Articles ypes only in the Vf Page.*/
            Schema.DescribeSObjectResult drSObj = objectType.getDescribe();//Need to be commented in future
            if ((key.endsWith('ka') || key.endsWith('kb')) && drSObj.isAccessible()) {
                mapObjPrefixWiseArticleType.put(objectType.getDescribe().getKeyPrefix(), objectType.getDescribe().getLabel());
                lstArticleType.add(new cArticleType(objectType.getDescribe().getName(), objectType.getDescribe().getLabel()));
                sDefArticleTypes += objectType.getDescribe().getName() + ',';
            }
        }

        lstArticleType.sort();
    }

    public class cArticle {
        public KnowledgeArticleVersion oKnowledgeArticleVersion {get;set;}
        public String articleTypeLabel {get;set;}
        public String articleTypeForUrl {get;set;}

        public cArticle(KnowledgeArticleVersion kav) {
            oKnowledgeArticleVersion = kav;
            articleTypeForUrl = kav.ArticleType.removeEndIgnoreCase('__kav');
            String sTmp = kav.ArticleType.removeEndIgnoreCase('v');
            if (ro_ArticleType.self.mapArticleNameWiseLabel.containsKey(sTmp)) {
                articleTypeLabel = ro_ArticleType.self.mapArticleNameWiseLabel.get(sTmp);
            } else {
                articleTypeLabel = kav.ArticleType;
            }
        }

    }

    public class cArticleType implements Comparable {
        public String sArticleName {get;set;}
        public String sArticleLabel {get;set;}

        public cArticleType(String sArtNm, String sArtLbl) {
            sArticleName = sArtNm;
            sArticleLabel = sArtLbl;
        }

        public Integer compareTo(Object compareTo) {
            cArticleType oArticle = (cArticleType) compareTo;
            if (this.sArticleName == oArticle.sArticleName) return 0;
            if (this.sArticleName > oArticle.sArticleName) return 1;
            return -1;
        }
    }

    public class cCategory implements Comparable {
        public DataCategory oDataCategory {get;set;}
        public list <cCategory> lstSubCategory {get;set;}

        public cCategory(DataCategory cat) {
            oDataCategory = cat;
            lstSubCategory = new list < cCategory > ();
        }

        public Integer compareTo(Object compareTo) {
            cCategory oCategory = (cCategory) compareTo;
            if (this.oDataCategory.getName() == oCategory.oDataCategory.getName()) return 0;
            if (this.oDataCategory.getName() > oCategory.oDataCategory.getName()) return 1;
            return -1;
        }
    }

    public class Paginator {
        
        public list < Object > searchResults {get;set;}
        public list < Object > currentRecordSet {get;set;}
        public Integer resultsPerPage {get;set;}
        public Integer pageNumber {get;set;}
        public Boolean moreThan1000 {get;set;}
        public Integer showingFrom {get;set;}
        public Integer showingTo {get;set;}
        private Integer currentPageNumber;

        public Paginator() {}

        public Integer totalResults {
            get {
                return searchResults.size();
            }
            set;
        }

        private void reflact() {
            Integer startIndx = (currentPageNumber - 1) * resultsPerPage;
            for (Object obj: currentRecordSet) {
                searchResults[startIndx] = obj;
                startIndx++;
            }
        }

        public void refresh() {
            reflact();
            currentRecordSet.clear();
            Integer startIndx = (pageNumber - 1) * resultsPerPage + 1;
            Integer stopIndx = startIndx + (resultsPerPage - 1);
            if (searchResults.size() < stopIndx) {
                stopIndx = searchResults.size();
            }
            showingFrom = startIndx;
            showingTo = stopIndx;
            Integer indx = 1;
            for (Object obj: searchResults) {
                if (indx >= startIndx) {
                    currentRecordSet.add(obj);
                    if (startIndx == stopIndx) {
                        break;
                    }
                    startIndx++;
                }
                indx++;
            }
        }

        private void moveNext() {
            reflact();
            currentRecordSet.clear();
            Integer startIndx = pageNumber * resultsPerPage + 1;
            Integer stopIndx = startIndx + (resultsPerPage - 1);
            if (searchResults.size() < stopIndx) {
                stopIndx = searchResults.size();
            }
            showingFrom = startIndx;
            showingTo = stopIndx;
            pageNumber++;
            Integer indx = 1;
            for (Object obj: searchResults) {
                if (indx >= startIndx) {
                    currentRecordSet.add(obj);
                    if (startIndx == stopIndx) {
                        break;
                    }
                    startIndx++;
                }
                indx++;
            }
        }

        private void movePrevious() {
            reflact();
            currentRecordSet.clear();
            pageNumber--;
            Integer startIndx = (pageNumber - 1) * resultsPerPage + 1;
            Integer stopIndx = startIndx + (resultsPerPage - 1);
            showingFrom = startIndx;
            showingTo = stopIndx;
            Integer indx = 1;
            for (Object obj: searchResults) {
                if (indx >= startIndx) {
                    currentRecordSet.add(obj);
                    if (startIndx == stopIndx) {
                        break;
                    }
                    startIndx++;
                }
                indx++;
            }
        }

        private void moveFirst() {
            currentRecordSet.clear();
            Integer startIndx = 1;
            Integer stopIndx = resultsPerPage;

            if (searchResults.size() < stopIndx) {
                stopIndx = searchResults.size();
            }

            showingFrom = startIndx;
            showingTo = stopIndx;
            pageNumber = 1;
            Integer indx = 1;
            for (Object obj: searchResults) {
                if (indx >= startIndx) {
                    currentRecordSet.add(obj);
                    if (startIndx == stopIndx) {
                        break;
                    }
                    startIndx++;
                }
                indx++;
            }
        }

        private void moveLast() {
            reflact();
            currentRecordSet.clear();
            Integer startIndx = (totalPage - 1) * resultsPerPage + 1;
            Integer stopIndx = searchResults.size();
            showingFrom = startIndx;
            showingTo = stopIndx;
            Integer indx = 1;
            pageNumber = totalPage;
            for (Object obj: searchResults) {
                if (indx >= startIndx) {
                    currentRecordSet.add(obj);
                    if (startIndx == stopIndx) {
                        break;
                    }
                    startIndx++;
                }
                indx++;
            }
        }

        public Integer totalPage {
            get {
                integer pagecount = searchResults.size() / resultsPerPage;
                return Math.mod(searchResults.size(), resultsPerPage) > 0 ? pagecount + 1 : pagecount;
            }
            set;
        }

        public Integer currentPage {
            get {
                currentPageNumber = pageNumber;
                return pageNumber;
            }
            set;
        }

        public Boolean hasNextPage {
            get {
                if (currentPage < totalPage) {
                    return true;
                } else {
                    return false;
                }
            }
            set;
        }

        public Boolean hasPrevPage {
            get {
                if (currentPage > 1) {
                    return true;
                } else {
                    return false;
                }
            }
        }

        public Boolean hasFirstPage {
            get {
                return hasPrevPage;
            }
        }

        public Boolean hasLastPage {
            get {
                return hasNextPage;
            }
        }

        public void nextPage() {
            moveNext();
        }

        public void prevPage() {
            movePrevious();
        }

        public void firstPage() {
            moveFirst();
        }

        public void lastPage() {
            moveLast();
        }

        public void goToPage() {
            refresh();
        }
    }
}