@IsTest
(SeeAllData=true)
 public class CampaignMemberauto_Test
 {
  static testmethod void MyUnitTest()
  
  {
  
 Campaign testCampaign = new Campaign ( name = 'vtinpofyipt',
                                      StartDate = System.today(),
                                      product__c = 'Event',
                                      Type = 'Biz-Dev',
                                      isActive = True                                                                          
                                      );
        insert testCampaign;
  
   
   }
   
     
    }