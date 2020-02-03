public with sharing class SyndicatedKnowledgeSetupController {
  //class variables
  public Boolean showCode { get; private set; }
  public Boolean showSettingsError { get; private set; }
  public Boolean includeSearch { get; set; }
  public String initialSearchText { get; set; }
  public String maxArticles { get; set; }
  public String siteBaseURL { get; private set; }
  private SyndicatedKnowledge__c sksettings;
 
  //constructor
  public SyndicatedKnowledgeSetupController() {
    showCode = false;
    showSettingsError = false;
  	includeSearch = false;
  	initialSearchText = '';
  	maxArticles = '';
  	//gather data from custom settings
  	sksettings = SyndicatedKnowledge__c.getOrgDefaults();
  	if (sksettings != null) {
  	  siteBaseURL = sksettings.Public_Knowledgebase_Base_URL__c;
  	  //format URL string
  	  if (!siteBaseURL.startsWith('http://') && !siteBaseURL.startsWith('https://')) { siteBaseURL = 'http://' + siteBaseURL; }
  	  if (!siteBaseURL.endsWith('/')) { siteBaseURL = siteBaseURL + '/'; }
  	}
  }//end Constructor
  
  //method to capture ShowMeTheCode button click
  public Void showMeTheCode() {
  	if (sksettings == null && !test.isRunningTest()) {
	  showSettingsError = true;
  	} else {
  	  showCode = true;
  	}
  }//end ShowMeTheCode
  
}// end class