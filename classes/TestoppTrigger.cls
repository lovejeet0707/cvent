@isTest(SeeAllData = true)
private class TestoppTrigger
{
    static testMethod void testpreventoppdelete(){
           
           Profile p = [select id from profile where name='System Administrator'];
           User u = new User(alias = 'standt', email='standarduser@testorg.com',
                             emailencodingkey='UTF-8', lastname='Testing', 
                             languagelocalekey='en_US',localesidkey='en_US',
                             profileid = p.Id,timezonesidkey='America/Los_Angeles',
                             username='345deploymentuser@cvent.com');
   
   
           System.runAs(u){
           
                Opportunity o = new Opportunity();
                o.name='Opp1';
                o.stageName='Closed Won';
                o.CloseDate=Date.today();
                o.Type='New Customer';
                o.amount=100.00;
                o.Rating__c = 'TEst';
                o.ContractReceived__c=Date.today();
                o.Leadsource = 'Client Services';
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
                        
                        System.AssertEquals(Message, false);
                 }
        }
  }


}