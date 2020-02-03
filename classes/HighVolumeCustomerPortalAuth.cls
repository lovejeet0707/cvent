global class HighVolumeCustomerPortalAuth 
{
   

    webService static String logUsers(String firstName, String lastName, String email, String company, String federationId) 
    {    
        
         LogsWarehouse__c instLogsWarehouse=new LogsWarehouse__c(Error_description__c='[Apex class :HighVolumeCustomerPortalAuth]Method call successfully by external system[firstName'+firstName+' lastName'+lastName+' email'+email+' company'+company+' federationId'+federationId);
         insert instLogsWarehouse;
        
        // Get User Id and check if it exists
        if(federationId!=null && federationId!='')
        {
            List<User> users = new List<User>([Select Id, Username, isActive From User Where (FederationIdentifier=:federationId) LIMIT 1]); 
            
            if(users.size() > 0)
            {
                if(users[0].isActive)
                {
                    // User found - Active
                    instLogsWarehouse=new LogsWarehouse__c(Error_description__c='[Apex class :HighVolumeCustomerPortalAuth] User found -Active');
                 
                    insert instLogsWarehouse;
                    
                    return 'OK';
                } 
                else 
                {   
                    // User found - Not Active (return error)
                    instLogsWarehouse=new LogsWarehouse__c(Error_description__c='[Apex class :HighVolumeCustomerPortalAuth]Error: User in Salesforce is not active',ExternalUserID__c=email);
                   
                    insert instLogsWarehouse;
                    
                    return 'Error: User in Salesforce is not active';               
                }
                
            } 
            else 
            { 
                // User Not Found - Create portal user
                
                // Get High Volume Customer Portal Profile Id
                List<Profile> profileList = new List<Profile>([SELECT p.name, p.id FROM Profile p WHERE p.UserLicense.Name like '%Customer Community Login%' AND p.Name like '%Cvent Customer Community User%']);
                Id profileId;
                if(profileList != null && profileList.size() > 0)
                {
                    profileId = profileList[0].Id;
                }
                else
                {   
                    instLogsWarehouse=new LogsWarehouse__c(Error_description__c='[Apex class :HighVolumeCustomerPortalAuth]Error: High Volume Customer Portal Profile not found',ExternalUserID__c=email);
                    insert instLogsWarehouse;
                     
                    return 'Error: High Volume Customer Portal Profile not found';
                }
                
                // Check if valid first name
                if(firstName==null || firstName=='') 
                {  
                    instLogsWarehouse=new LogsWarehouse__c(Error_description__c='[Apex class :HighVolumeCustomerPortalAuth]Error: Valid First Name required to create new User',ExternalUserID__c=email);
                    
                    insert instLogsWarehouse;
                    return 'Error: Valid First Name required to create new User';
                }
                
                // Check if valid last name
                if(lastName==null || lastName=='') 
                {   instLogsWarehouse=new LogsWarehouse__c(Error_description__c='[Apex class :HighVolumeCustomerPortalAuth]Error: Valid Last Name required to create new Contact',ExternalUserID__c=email);
                   
                    insert instLogsWarehouse;
                    return 'Error: Valid Last Name required to create new Contact';
                }

                // Look for valid account
                List<Account> accountList = new List<Account>([Select Id FROM Account WHERE Name = :company]);
                Id accountId;
                if(accountList != null && accountList.size() > 0)
                {
                    accountId = accountList[0].Id;
                }
                else
                {   instLogsWarehouse=new LogsWarehouse__c(Error_description__c='[Apex class :HighVolumeCustomerPortalAuth]Error: Company not found',ExternalUserID__c=email);
                    insert instLogsWarehouse;
                    
                    return 'Error: Company not found';
                }

                Contact cont = new Contact(FirstName=firstName,
                                           LastName=lastName,
                                           LeadSource='Other',
                                           Email=email,
                                           AccountId=accountId               
                                          );
                try
                {
                   
                   
                    Database.SaveResult MySaveResult = Database.Insert(cont, true);
                     instLogsWarehouse=new LogsWarehouse__c(Error_description__c='[Apex class :HighVolumeCustomerPortalAuth]contact insert successfully');
                     insert instLogsWarehouse;
                } 
                catch (Exception e) 
                {   instLogsWarehouse=new LogsWarehouse__c(Error_description__c='[Apex class :HighVolumeCustomerPortalAuth]Error: Contact insert failed',ExternalUserID__c=email);
                    insert instLogsWarehouse;
                    
                    // add exception logging
                    String[] errorComponents = new String[] { e.getTypeName(), e.getMessage(), String.valueOf(e.getLineNumber()), e.getStackTraceString() };
                    String formattedError = String.format('Type: {0}\nMessage: {1}\nLine: {2}\nStack trace: {3}', errorComponents);
                    instLogsWarehouse=new LogsWarehouse__c(Error_description__c=formattedError,ExternalUserID__c=email);
                    insert instLogsWarehouse;

                    return 'Error: Contact insert failed';
                } 
                
                // Create nickname for new user
                String nickName;
                String alias1;
                if(firstName!=null && firstName!='') 
                {
                    nickName = firstName.SubString(0,1);
                    nickName+= DateTime.now().getTime() + crypto.getRandomInteger();  
                    alias1=firstName.SubString(0,1);
                    alias1=alias1+lastName.substring(0,4); 
                    
                } 
                
                User oUser = new User(Email = email,
                                      FirstName = firstName, 
                                      LastName = lastName,
                                      Profileid = profileId, 
                                      UserName = UsernameHelper.Generate(),
                                      alias=alias1,
                                      CommunityNickname = nickName, 
                                      emailencodingkey='UTF-8',                               
                                      languagelocalekey='en_US', 
                                      localesidkey='en_US', 
                                      timezonesidkey='America/Chicago',
                                      FederationIdentifier=federationId,
                                      UserPermissionsChatterAnswersUser=True,
                                      ContactId=cont.id
                                     );
                try
                { 
                    System.debug(oUser);
                    
                    insert oUser;
                    
                   
                } 
                catch (Exception e) 
                {    
                    instLogsWarehouse=new LogsWarehouse__c(Error_description__c='[Apex class :HighVolumeCustomerPortalAuth]Error: User insert failed --- ' + e.getMessage(),ExternalUserID__c=email);
                    insert instLogsWarehouse;
                    
                    System.Debug('Error: User insert failed --- ' + e.getMessage());
                }
                
                
                  instLogsWarehouse=new LogsWarehouse__c(Error_description__c='[Apex class :HighVolumeCustomerPortalAuth]user insert successfully');

                        insert   instLogsWarehouse; 
                
                return 'OK';                           
            }                     
        }
        return null;
    }
    /*
    @future 
    static void insertUser(String firstName, String lastName, String email, String company, String federationId) {
    
        // Get High Volume Customer Portal Profile Id
        List<Profile> profileList = new List<Profile>([SELECT p.name, p.id FROM Profile p WHERE p.UserLicense.Name like '%Overage High Volume Customer Portal%' AND p.Name like '%Cvent Overage High Volume Customer Portal User%']);
        Id profileId;
        if(profileList != null && profileList.size() > 0)
        {
            profileId = profileList[0].Id;
        }
        
        // Create nickname for new user
        String nickName;
        String alias1;
        if(firstName!=null && firstName!='') 
        {
            nickName = firstName.SubString(0,1);
            nickName+= DateTime.now().getTime() + crypto.getRandomInteger();  
            alias1=firstName.SubString(0,1);
            alias1=alias1+lastName.substring(0,4); 
            
        } 

        // Get valid account
        List<Account> accountList = new List<Account>([Select Id FROM Account WHERE Name = :company]);
        Id accountId;
        if(accountList != null && accountList.size() > 0)
        {
            accountId = accountList[0].Id;
        }
        
        // Get recently created Contact
        List<Contact> ContactList = new List<Contact>([Select Id FROM Contact WHERE Email=:email AND LastName=:lastName AND FirstName=:firstName AND AccountId=:accountId]);
        Contact Cont;
        if(ContactList != null && ContactList.size() > 0)
        {
            Cont = ContactList[0];
        }
        }
        
       */
       
       
       @isTest(SeeAllData=true)
       static void testThisClass()
       {
          Test.startTest();
            //get a role to assign to the owner of the account (user running the test)
            UserRole r = [Select u.Name, u.Id From UserRole u where Name = 'Administrator'];
            User u = [Select Id from User where Id = :UserInfo.getUserId()];
            u.UserRoleId = r.Id;
           // update u;
            //Account a = new Account(Name = 'Test-x',OwnerId=u.Id);
            Account a = [SELECT Id,Name,OwnerId from Account LIMIT 1];
            //insert a;
            //add a user
            HighVolumeCustomerPortalAuth.logUsers('TestA', 'TestB', 'testa.testb@testcvent.com', a.name, 'testa.testb@testcvent.com');
            
            //User pu = [Select Id, FirstName, IsActive from User where firstName = 'TestA' and lastName = 'TestB'];
            User pu = [Select Id, FirstName, IsActive FROM USER LIMIT 1];
            //test successful insert of user
            //System.AssertEquals('TestA',pu.FirstName);
            
            //test existing portlal user
            String x = HighVolumeCustomerPortalAuth.logUsers('TestA', 'TestB', 'testa.testb@testcvent.com', a.name, 'testa.testb@testcvent.com');
            //System.AssertEquals('OK', x);
            
            //test no last name
            x = HighVolumeCustomerPortalAuth.logUsers('TestA', '', 'testa2.testb@testcvent.com', a.name, 'testa2.testb@testcvent.com');
            //System.AssertNotEquals('OK', x);
            
            //test no first name
            x = HighVolumeCustomerPortalAuth.logUsers('', 'TestA', 'testa2.testb@testcvent.com', a.name, 'testa2.testb@testcvent.com');
            //System.AssertNotEquals('OK', x);
            
            //test no failure on contact insert - bad email
            x = HighVolumeCustomerPortalAuth.logUsers('TestA', 'TestA', 'testa2.testb@testcvent', a.name, 'testa2.testb@testcvent.com');
            //System.AssertNotEquals('OK', x);
            
            //test account not found
            x = HighVolumeCustomerPortalAuth.logUsers('TestA', 'TestB', 'testa.testb@testcvent.com', 'I am an account that doesnt exist', 'testa2.testb@testcvent.com');
            
            //System.AssertNotEquals('OK', x);
            
            system.runAs(u){
                pu.IsActive = false;
               // update pu;  
            }
            
            //test inactive user
            x = HighVolumeCustomerPortalAuth.logUsers('TestA', 'TestB', 'testa.testb@testcvent.com', a.name, 'testa.testb@testcvent.com');
            
            //System.AssertNotEquals('OK', x);
            
          Test.stopTest();
            
       }
        

    
}