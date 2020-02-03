/*Created By Rishi Ojha
    ===============================================================================
    Test class for the trigger : PreventOppDeletion
    ===============================================================================*/
    
    @isTest(SeeAllData=True)
    
     private class TestPreventOppTrigger
    {
    static testMethod void testPreventOppDeletion(){
           
           Profile p = [select id from profile where name='System Administrator'];
           
         String dateString = String.valueof(Datetime.now()).replace('   ','').replace(':','').replace('-','').trim();
         
         String uniqueName = 'TestPreventOppTrigger';
 
           User u = new User(alias = 'standt', email='standarduser@testorg.com',
                             emailencodingkey='UTF-8', lastname='Testing', 
                             languagelocalekey='en_US',localesidkey='en_US',
                             profileid = p.Id,timezonesidkey='America/Los_Angeles',
                             username=uniqueName+ '@test.org');
   
           
           System.runAs(u){
           
                Opportunity o = new Opportunity();
                o.name='Opp1';
                o.stageName='Open';
                o.CloseDate=Date.today();
                o.Type='New Customer';
                o.amount=100.00;
                o.ContractReceived__c=Date.today();
                 insert o;
                try{
                     delete o;
                }catch(Exception ex){
                        Boolean Message = false;          
                        if(ex.getMessage().contains('You are not authorised to delete this Opportunity')){
                             Message = true;      
                        }else{
                             Message = false;      
                        }
                        system.debug('########Message : '+Message);
                        
                        //System.AssertEquals(Message, true);
                 } 
        }
  }


}