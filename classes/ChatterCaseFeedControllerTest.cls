@isTest
Public Class ChatterCaseFeedControllerTest
{

  Public static testmethod void createChatterTest(){
  
      Case c =  new Case();
      c.Requestor_Department__c = 'Test';
      c.Subject = 'Test';
      c.Description = 'Test';
      Insert c ;
      
      
      
      ApexPages.StandardController sc = new ApexPages.StandardController(c);
      ChatterCaseFeedController cCase = new ChatterCaseFeedController(sc);
      cCase.Go();
      
      
     
      Case_Chatter_Restricted_Profiles__c setting = new Case_Chatter_Restricted_Profiles__c();
      setting.SetupOwnerId = UserInfo.getProfileId();
      Insert setting;
      
      cCase.Go();
  
  
  }


}