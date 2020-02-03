Public Class ChatterCaseFeedController
{ 
      Id caseId ;
      
      Public ChatterCaseFeedController(ApexPages.StandardController sc ){ 
          caseId =  sc.getId();
      }
      
      Public PageReference Go(){

          Case_Chatter_Restricted_Profiles__c cFeed = Case_Chatter_Restricted_Profiles__c.getValues(UserInfo.getProfileId());    
          
          If( cFeed == null ){
          //Redirecting to Standard Case Detail Page
          return new PageReference('/' + caseId + '?nooverride=1');
          }
          else{
          return null;
          }
      }
         
}