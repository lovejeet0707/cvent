//**************************Created by Rishi Ojha ; Dated 24/07/2013****************************

//*******************This test class is created for the Trigger PreventAccDelete***************

@istest
private class TestAccdelete 

{
    private static testMethod void testPreventAccDelete()
    {      
        Profile instOfProf = [SELECT ID FROM Profile WHERE Name like '%Sales Representative%' Limit 1];
        User instOfUser = new User(alias = 'u1', email='u19898@testorg.com',emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',localesidkey='en_US', profileid = instOfProf.Id,
                                    timezonesidkey='America/Los_Angeles', username='u1287@testorg.com');
          insert instOfUser;
           Account acc=new Account(Name='Test Account',Account_Status__c='Test');
           insert acc;
             
           // This should be succeeding 
           system.runas(instOfUser){
               try
               {
                   delete acc;
               }catch(Exception ex){
               }
           }
        }

    /*private static testMethod void testPreventAccDeleteFail()
    {
           Account acc=new Account(Name='Test Account',Ownership='test owner');
           insert acc;
 
           try
           {
              delete acc;
              // Throw an error
               //  System.assert(false);
            }catch(Exception ex){
                        Boolean Message = false;          
                        if(ex.getMessage().contains('You cannot Delete/Merge a Client Account , Please contact CVENT Reporting Team/Paras Bhateja for assistance.')){
                             Message = true;      
                        }else{
                             Message = false;      
                        }
                        system.debug('########Message : '+Message);
                        
                        //System.AssertEquals(Message, true);

           }
        }*/
}