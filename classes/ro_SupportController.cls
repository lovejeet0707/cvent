public class ro_SupportController {   // nikhil --> /*with sharing*/
 public list<Case> caseRecordSet {get;set;}
 public list<Case> caseCurrentRecordSet {get;set;}
 public Paginator casePaginator {get;set;}
 public String sortField{get;set;}
 public String previousSortField {get;set;}
 public Boolean isAsc {get;set;}
 public String errMessage {get;set;}
 public Boolean bNewCase {get;set;}
 public CaseView__c selectedCaseView {get;set;}
 public String selectedCaseViewName {get;set;}
 public list<CaseView__c> lstCaseView {get;set;}
 public User oUser{get;set;}
 public String subject {get;set;}
 public String description {get;set;}
 public String event {get;set;}
 
 private map<String,CaseView__c> mapCaseView = new map <String,CaseView__c>();
 
 public ro_SupportController(){
   if(ro_ConfigHelper.self.isSite){
     bNewCase = true;
   }
   else{
     lstCaseView = new list<CaseView__c>();
     caseRecordSet = new List<Case>();
    caseCurrentRecordSet = new List<Case>();
    casePaginator = new Paginator();
    casePaginator.resultsPerPage = 10;
    casePaginator.searchResults = (list<Case>)caseRecordSet;
    casePaginator.currentRecordSet = (list<Case>)caseCurrentRecordSet;
    sortField = 'LastModifiedDate';
    previousSortField = 'LastModifiedDate';
    isAsc = false;
    
    fetchCaseViews();
    loadView();
   }
 }
 
 public PageReference newCase(){
  bNewCase = true;
  return null;  
 }
 
 public void createNewDeflection(){
   errMessage = '';
  try{
  User oUser;
  for(User u :[Select Id,ContactId From User Where Id = :userinfo.getUserId()]){
   oUser = u;  
  }
  
  // Suraj:   Category_Name__c logic needs to be changed to generalized dynamic value based
  // on source of this entry
  Case_Deflection__c  oDeflection = new Case_Deflection__c();
  oDeflection.Deflection__c = true;
  oDeflection.Subject__c = subject;
  oDeflection.Description__c = description;
  oDeflection.User__c = oUser.Id;
  oDeflection.Contact__c = oUser.ContactId;
  oDeflection.Event__c = event;
  oDeflection.Category_Name__c = ro_ConfigHelper.self.sitePrefix;    
  insert oDeflection;
  }
  catch(Exception ex){
    errMessage = ex.getMessage();
  }
 }
 
 public void doSort(){
    System.debug('@Developer -->previousSortField:' + previousSortField);
    System.debug('@Developer -->sortField:' + sortField);
    System.debug('@Developer -->isAsc:' + isAsc);
    if(previousSortField != sortField){
     isAsc = true;  
     previousSortField = sortField;
    }
    else{
     isAsc = !isAsc;    
    }
    
    loadView();
 }
 
 public void loadView(){
   System.debug('@Developer -->loadView'); 
   System.debug('@Developer -->sortField:' + sortField);
   System.debug('@Developer -->isAsc:' + isAsc);  
   
   errMessage = '';
   
   String sSoql = 'Select Id,CaseNumber,Subject,Status,AccountId,Account.Name,createdDate';
   sSoql += ' From Case';
   
   String sWhere = '';
   
   for(User sTempUser:[Select Name, Id, ContactId From User where Id=:userInfo.getUserId()]){
     oUser = sTempUser;
   }
   
   if(selectedCaseViewName == null || selectedCaseViewName =='' ){
     if(lstCaseView.size() > 0){
       selectedCaseView = lstCaseView[0];
       selectedCaseViewName = lstCaseView[0].ViewName__c;
       if(selectedCaseView.Criteria__c != null && selectedCaseView.Criteria__c != ''){
         String sTmp = selectedCaseView.Criteria__c.replaceAll('(?i)\\$user.id',oUser.Id);
         
         if(oUser.ContactId != null){
         sTmp = sTmp.replaceAll('(?i)\\$user.contactid',oUser.ContactId);
         }
        sWhere = ' Where ' + sTmp;
       }
     }
   }
   else{
     if(mapCaseView.containsKey(selectedCaseViewName)){
       selectedCaseView = mapCaseView.get(selectedCaseViewName);
       if(selectedCaseView.Criteria__c != null && selectedCaseView.Criteria__c != ''){
         String sTmp = selectedCaseView.Criteria__c.replaceAll('(?i)\\$user.id',oUser.Id);
             if(oUser.ContactId != null){
         sTmp = sTmp.replaceAll('(?i)\\$user.contactid',oUser.ContactId);
         }
        sWhere = ' Where ' + sTmp ;
       }  
     }
   }
   
   System.debug('@Developer -->sWhere:' + sWhere);
   
   sSoql += sWhere;
   System.debug('@Developer -->[Intermediate] sSoql:' + sSoql);
   System.debug('@Developer -->selectedCaseViewName:' + selectedCaseViewName);
   System.debug('@Developer -->selectedCaseView:' + selectedCaseView);
   
   if(sortField != ''){
   sSoql += ' order by ' + sortField;
   
   if(isAsc){
    sSoql += ' asc';   
   }   
   else{
    sSoql += ' desc';
   }
  }
   
   sSoql += ' Limit 999';
  System.debug('@Developer -->sSoql:' + sSoql);
  
  list<Case>lstResult;
  try{
    caseRecordSet.clear();
    caseCurrentRecordSet.clear();
    system.debug('The query is'+sSoql);
   lstResult = Database.query(sSoql);
  }
  catch(Exception ex){
    errMessage = ex.getMessage();
    return;
  }
  
  System.debug('@Developer -->lstResult.size:' + lstResult.size());
  
  
  if(lstResult.size() > 1000){
   casePaginator.moreThan1000 = true;
   lstResult.remove(1000);
  }
  else{
   casePaginator.moreThan1000 = false;
  }
  
  for(Case c: lstResult){
   caseRecordSet.add(c);
  }
  
  casePaginator.firstPage(); 
 }
 
 @testVisible private void fetchCaseViews(){
   System.debug('@Developer -->fetchCaseViews');
   lstCaseView.clear();
   for(CaseView__c cv : [Select Id,Name,ViewLabel__c,ViewName__c,Criteria__c From CaseView__c order By ViewName__c asc limit 999]){
     lstCaseView.add(cv);
     mapCaseView.put(cv.ViewName__c,cv);
   }
   
   System.debug('@Developer -->lstCaseView:' + lstCaseView);
   System.debug('@Developer -->mapCaseView:' + mapCaseView);
 }
 
 
 public class Paginator {
  public list<Object> searchResults {get;set;}
  public list<Object> currentRecordSet {get;set;}
  public Integer resultsPerPage {get;set;}
  public Integer pageNumber {get;set;}
  
  public Boolean moreThan1000 {get;set;}
  public Integer showingFrom {get;set;}
  public Integer showingTo {get;set;}
  
  @testVisible private Integer currentPageNumber;
  
  public Paginator(){}
  
  public Integer totalResults {
   get {
    return searchResults.size();
   }
   set;
  }
  
  @testVisible private void reflact(){
   Integer startIndx = (currentPageNumber-1) * resultsPerPage ;
   for(Object obj:currentRecordSet){
    searchResults[startIndx] = obj;
    startIndx++;
   }
  }
  
  public void refresh(){
   reflact();
   currentRecordSet.clear();
   Integer startIndx = (pageNumber-1) * resultsPerPage + 1 ;
   Integer stopIndx = startIndx+(resultsPerPage-1);
   if(searchResults.size()<stopIndx){
    stopIndx = searchResults.size();
   }
   showingFrom = startIndx;
   showingTo = stopIndx;
   Integer indx =1;
   for(Object obj:searchResults){
    if(indx>=startIndx){
     currentRecordSet.add(obj);
     if(startIndx==stopIndx){
      break;
     }
     startIndx++;
    }
    indx++;
   }
  }
  
  @testVisible private void moveNext(){
   reflact();
   currentRecordSet.clear();
   Integer startIndx = pageNumber * resultsPerPage + 1 ;
   Integer stopIndx = startIndx+(resultsPerPage-1);
   if(searchResults.size()<stopIndx){
    stopIndx = searchResults.size();
   }
   showingFrom = startIndx;
   showingTo = stopIndx;
   pageNumber++;
   Integer indx =1;
   for(Object obj:searchResults){
    if(indx>=startIndx){
     currentRecordSet.add(obj);
     if(startIndx==stopIndx){
      break;
     }
     startIndx++;
    }
    indx++;
   }
  }

  @testVisible private void movePrevious(){
   reflact();
   currentRecordSet.clear();
   pageNumber--;
   Integer startIndx = (pageNumber-1) * resultsPerPage + 1 ;
   Integer stopIndx = startIndx+(resultsPerPage-1);
   showingFrom = startIndx;
   showingTo = stopIndx;
   Integer indx =1;
   for(Object obj:searchResults){
    if(indx>=startIndx){
     currentRecordSet.add(obj);
     if(startIndx==stopIndx){
      break;
     }
     startIndx++;
    }
    indx++;
   }
  }

  @testVisible private void moveFirst(){
   currentRecordSet.clear();
   Integer startIndx = 1;
   Integer stopIndx = resultsPerPage;
   
   if(searchResults.size()<stopIndx){
    stopIndx = searchResults.size();
   }
   
   showingFrom = startIndx;
   showingTo = stopIndx;
   pageNumber = 1;
   Integer indx =1;
   for(Object obj:searchResults){
    if(indx>=startIndx){
     currentRecordSet.add(obj);
     if(startIndx==stopIndx){
      break;
     }
     startIndx++;
    }
    indx++;
   }
  }

  @testVisible private void moveLast(){
   reflact();
   currentRecordSet.clear();
   Integer startIndx = (totalPage-1) * resultsPerPage + 1 ;
   Integer stopIndx = searchResults.size();
   showingFrom = startIndx;
   showingTo = stopIndx;
   Integer indx =1;
   pageNumber=totalPage;
   for(Object obj:searchResults){
    if(indx>=startIndx){
     currentRecordSet.add(obj);
     if(startIndx==stopIndx){
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
    return Math.mod(searchResults.size(),resultsPerPage) > 0 ? pagecount + 1 : pagecount;
   }
   set;
  }

  public Integer currentPage{
   get {
    currentPageNumber = pageNumber;
    return pageNumber;
   }
   set;
  }
  
  public Boolean hasNextPage{
   get{
    if(currentPage < totalPage){
     return true;
    }
    else{
     return false;
    }
   }
   set;
  }

  public Boolean hasPrevPage{
   get{
    if(currentPage > 1){
     return true;
    }
    else{
     return false;
    }
   }
  }

  public Boolean hasFirstPage{
   get{return hasPrevPage;}
  }

  public Boolean hasLastPage{
   get{return hasNextPage;}
  }

  public void nextPage(){
   moveNext();
  }

  public void prevPage(){
   movePrevious();
  }

  public void firstPage(){
   moveFirst();
  }

  public void lastPage(){
   moveLast();
  }
  
  public void goToPage(){
   refresh();
  }
 }
}