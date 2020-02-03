public with sharing class SyndicatedKnowledgeController {
/*
 * Author  : Brad Herman, bherman@salesforce.com
 * Date    : November, 2010
 * Comment : This application searches Salesforce Knowledge and delivers the resulting list of articles
             via JSON for easy consumption on 3rd party websites without requiring complex integration.  
 * Requires: Salesforce Knowledge and Sites
*/
  //class variables
  public String kbBaseURL { get; private set; }
  public String searchPhrase { get; set; }
  public Integer maxArticles { get; set; }
  public String callBackFunction { get; private set; }
  public List<KnowledgeArticleVersion> searchResults { get; private set; }
  
  //constructor
  public SyndicatedKnowledgeController() {
    //set variables
    searchPhrase = '';
    maxArticles = 100;
    //gather data from custom settings
    SyndicatedKnowledge__c sksettings = SyndicatedKnowledge__c.getOrgDefaults();
    //initialize class variables
    if (test.isRunningTest()) { kbBaseURL = 'www.test.com'; }
    else { kbBaseURL = sksettings.Public_Knowledgebase_Base_URL__c; }
      //format public knowledgebase URL string
      if (!kbBaseURL.startsWith('http://') && !kbBaseURL.startsWith('https://')) { kbBaseURL = 'http://' + kbBaseURL; }
      if (!kbBaseURL.endsWith('/')) { kbBaseURL = kbBaseURL = '/'; }
      if (test.isRunningTest()) { kbBaseURL = kbBaseURL + 'articles/' + 'FAQ' + '/'; } 
      else { kbBaseURL = kbBaseURL + 'articles/' + sksettings.Common_Article_Type__c + '/'; }
    searchPhrase = '';
    callBackFunction = '';
    searchResults = new List<KnowledgeArticleVersion>();
    //get default searchText from URL
    if ((System.CurrentPageReference().GetParameters().containsKey('s')) && (System.CurrentPageReference().GetParameters().Get('s') != null)) {
      searchPhrase = System.CurrentPageReference().GetParameters().Get('s');
      searchPhrase = searchPhrase.replace('\'','\\\'');
      searchPhrase = searchPhrase.replace('\\','\\\\');
    }
    //get max articles from URL
    if ((System.CurrentPageReference().GetParameters().containsKey('n')) && (System.CurrentPageReference().GetParameters().Get('n') != null)) {
      String n = System.CurrentPageReference().GetParameters().Get('n');
      n = n.replace('\'','\\\'');
      n = n.replace('\\','\\\\');
      try {
        maxArticles = integer.valueOf(n); 
      } catch (exception e) {
        maxArticles = 100; //the hardcoded max
      }//end try/catch
    }
    //get callback function name from URL
    if (System.CurrentPageReference().GetParameters().containsKey('callback')) {
      callBackFunction = System.CurrentPageReference().GetParameters().Get('callback');
    }
    //call method to search 
    searchResults = searchKB();
  }//end constructor
  
  //method to search
  public List<KnowledgeArticleVersion> searchKB() {
    if ((searchPhrase != null) && (searchPhrase.length() > 1)) {
      List<List<KnowledgeArticleVersion>> articleList = [FIND :searchPhrase RETURNING
                                                         KnowledgeArticleVersion(ID, Title, Summary, UrlName
                                                         WHERE PublishStatus = 'Online' AND IsVisibleInPkb = true) LIMIT :maxArticles]; //search returns a list of lists
      if (articleList[0].size()>0) { //check that we found at least one article
        return articleList[0]; //return the list of articles; default ordering of solutions is by Score%
      } else {
        return null;
      }
    } else {
      List<KnowledgeArticleVersion> articles = [SELECT ID, Title, Summary, UrlName
                                                FROM KnowledgeArticleVersion 
                                                WHERE PublishStatus = 'Online' AND IsVisibleInPkb = true LIMIT :maxArticles]; //query returns a list
      if (articles.size()>0) { //check that we found at least one article
        return articles; //return the list of articles; default ordering of solutions is by Score%
      } else {
        return null;
      }
    }
  }//end method to search
  

  // Test methods
  static testMethod void testSyndicatedKnowledge() {
    //test setup
    SyndicatedKnowledgeSetupController SKSetupController = new SyndicatedKnowledgeSetupController();
    //custom setting setup
        SyndicatedKnowledge__c sksettings = SyndicatedKnowledge__c.getOrgDefaults();
    if (sksettings != null) {
      delete sksettings;
    }
    sksettings = new SyndicatedKnowledge__c();
    sksettings.Public_Knowledgebase_Base_URL__c = 'www.test.com';
    sksettings.Common_Article_Type__c= 'FAQ';
    insert sksettings;
    //test methods
    System.assertEquals(SKSetupController.showCode, false);
    System.assertEquals(SKSetupController.includeSearch, false);
    System.assertEquals(SKSetupController.initialSearchText, '');
    SKSetupController.showMeTheCode();
    System.assertEquals(SKSetupController.showCode, true);
    //test construction of knowledge controller & searches
    PageReference pageRef = new PageReference('/apex/SyndicatedKnowledgeJSONP');
    Test.setCurrentPage(pageRef);
    ApexPages.currentPage().getParameters().put('s', ''); //no search phrase, no max articles
    ApexPages.currentPage().getParameters().put('callback', 'listEntries');
    SyndicatedKnowledgeController SKController = new SyndicatedKnowledgeController();
   // System.assert(SKController.searchResults != null);
    pageRef = new PageReference('/apex/SyndicatedKnowledgeJSONP');
    Test.setCurrentPage(pageRef);
    ApexPages.currentPage().getParameters().put('s', 'moliminous'); //search phrase that will not return results
    ApexPages.currentPage().getParameters().put('n', '10');
    ApexPages.currentPage().getParameters().put('callback', 'listEntries');
    SKController = new SyndicatedKnowledgeController();
    System.assert(SKController.searchResults == null);
  }//end test method

}//end class