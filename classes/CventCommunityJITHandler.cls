/*
    Version: 1.0
    Description: This class acts as a JIT Provisioning Handler for Single Sign On feature on Cvent Salesforce instance. In the first phase; this is 
                 used specifically for our Customer Community SSO. 
                 To use custom logic for user provisioning during SAML single sign-on, you must create a class that implements Auth.SamlJitHandler. This allows 
                 you to incorporate organization-specific logic (such as populating custom fields) when users log in to Salesforce with single sign-on. Keep in mind 
                 that your class must perform the logic of creating and updating user data as appropriate, including any associated account and contact records.
                 The minimum number of attributes required in the SAML assertion are following:
                    User.FirstName
                    User.LastName
                    User.Email
                    User.CompanyName
                    User.FederationIdentifier
                    User.LanguageLocaleKey
                    User.LocaleSidKey
                    User.TimeZoneSidKey
        
    Created Date: April 26, 2016
    Author: Praveen Kaushik

*/
global class CventCommunityJITHandler implements Auth.SamlJitHandler {
    private class JitException extends Exception{
        
    }

    /*
     * Returns a User object using the specified Federation ID. The User object corresponds to the user information and may be a new user that hasn’t t been inserted in the database or may represent an existing user record in the database.
    */    
    global User createUser(Id samlSsoProviderId, Id communityId, Id portalId,
        String federationIdentifier, Map<String, String> attributes, String assertion) {
            
        captureLog('samlSsoProviderId: '+samlSsoProviderId + '  communityId: '+communityId + ' portalId: '+portalId
                    + ' federationIdentifier: '+federationIdentifier + ' attributes:'+attributes + ' assertion:'+assertion,
                   'CreateUser');
        
        
        /* Check if an active user already exists */
        User ssoUser;
        List<User> usrList = [SELECT Id, isActive, federationIdentifier FROM User WHERE federationIdentifier=:federationIdentifier limit 1];    
        IF(usrList.size() > 0 && usrList[0].isActive){
            ssoUser = usrList[0];        
        } else {
            ssoUser = new User();
            handleJit(true, ssoUser, samlSsoProviderId, communityId, portalId,
                federationIdentifier, attributes, assertion);
        }    
        return ssoUser;
    }

    /*
        Updates the specified user’s information. This method is called if the user has logged in before with SAML single sign-on and then logs in again, or if your application is using the Existing User Linking URL.
    */
    global void updateUser(Id userId, Id samlSsoProviderId, Id communityId, Id portalId,
        String federationIdentifier, Map<String, String> attributes, String assertion) {
            
        captureLog('samlSsoProviderId: '+samlSsoProviderId + '  communityId: '+communityId + ' portalId: '+portalId
                    + ' federationIdentifier: '+federationIdentifier + ' attributes:'+attributes + ' assertion:'+assertion,
                   'UpdateUser');

        /* Check if an active user already exists */
        User ssoUser;
        List<User> usrList = [SELECT Id, isActive, federationIdentifier FROM User WHERE federationIdentifier=:federationIdentifier limit 1];    
        IF(usrList.size() > 0 && usrList[0].isActive){
            ssoUser = usrList[0];        
            handleJit(false, ssoUser, samlSsoProviderId, communityId, portalId,
                federationIdentifier, attributes, assertion);
        }    
    }

    private void handleUser(boolean create, User u, Map<String, String> attributes,
        String federationIdentifier, String contactId, boolean isStandard) {
            
        String userName = attributes.get('User.Username');
        String firstName = attributes.get('User.FirstName');
        String lastName = attributes.get('User.LastName');
        String email = attributes.get('User.Email');
        String phone= attributes.get('User.Phone');
        String company = attributes.get('User.CompanyName');
        String userContactId = contactId;
        String languageLocaleKey = attributes.get('User.LanguageLocaleKey');
        String localeSidKey = attributes.get('User.LocaleSidKey');
        String timeZoneSidKey = attributes.get('User.TimeZoneSidKey');
        String userProfileId = attributes.get('User.ProfileId');
        String userRoleId = attributes.get('User.UserRoleId');
        String userFederationIdentifier = attributes.get('User.FederationIdentifier') != null ? attributes.get('User.FederationIdentifier') : federationIdentifier;
        
        try
        {
            if(create)
            {
                u.Username = userName != null ? userName : email + '.cvent';
                u.FederationIdentifier = userFederationIdentifier;
                u.CommunityNickname = firstName.SubString(0,1) + DateTime.now().getTime() + crypto.getRandomInteger();  
                u.Alias = firstName.SubString(0,1) + lastName.substring(0,4) + Integer.valueOf((Math.random() + 1) * 10); 
                u.ContactId = userContactId;
                
                /* Find the right Community License profile */
                List<Profile> profileList = new List<Profile>([SELECT p.name, p.id FROM Profile p WHERE p.UserLicense.Name like '%Customer Community Login%' AND p.Name like '%Cvent Customer Community User%']);
                if(profileList.size() > 0)
                {
                    u.ProfileId = profileList[0].Id;
                } else {
                    throw new JitException('Error Code CCP103: No valid Portal Profile available');                    
                }
            }
            
            //These should be set even for existing users
            u.FirstName = firstName != null ? firstName : 'Unavailable';
            u.LastName = lastName;
            u.Email = email;
            u.Phone = phone;
            u.CompanyName = company;
            u.emailencodingkey='UTF-8';                               
            u.UserPermissionsChatterAnswersUser=true;    
            u.languagelocalekey= languageLocaleKey != null ? languageLocaleKey : 'en_US'; 
            u.localesidkey=localeSidKey != null ? localeSidKey : 'en_US'; 
            u.timezonesidkey=timeZoneSidKey != null ? timeZoneSidKey :'America/Chicago';
            
            if(!create){
                captureLog('Updating existing User: '+u,'handleUser');                
                update u;                
            } else {
                captureLog('Insert User: '+u,'handleUser');                
                insert u;                
            }
            
            
        } catch (JITException e){
            captureLog(e.getMessage(),'Exception in method handleUser');      
            throw new JitException(e.getMessage());         
        } catch (Exception e){
            captureLog('Error Code CCP200: '+e.getMessage(),'Exception in method handleUser');      
            throw new JitException('Error Code CCP200: '+e.getMessage());         
        }
            
    }

    private String handleContact(boolean create, Account customerAccount, Map<String, String> attributes){
        String firstName = attributes.get('User.FirstName');
        String lastName = attributes.get('User.LastName');
        String email = attributes.get('User.Email');
        String phone= attributes.get('User.Phone');

        List<Contact> contactList = new List<Contact>([Select Id FROM Contact WHERE Email=:email AND LastName=:lastName AND FirstName=:firstName AND AccountId=:customerAccount.Id]);
        String contactId = contactList.size() > 0 ? contactList[0].Id : null;        
        //Create a Contact if one doesnt exist
        if(contactId == null) 
        {
            Contact cont = new Contact(FirstName=firstName,
                                           LastName=lastName,
                                           LeadSource='Other',
                                           Email=email,
                                           AccountId=customerAccount.Id               
                                          );            
            insert cont;
            contactId = cont.Id;
        }        
        return contactId;
    }
    
    private void handleJit(boolean create, User u, Id samlSsoProviderId, Id communityId, Id portalId,
        String federationIdentifier, Map<String, String> attributes, String assertion) {
        if(communityId != null || portalId != null) {
           /* Find Account based on Company Name - We have not enabled Self Registration so a new account should not be created */ 
            Account customerAccount;
            if(attributes.get('User.CompanyName') != null){
                List<Account> accountList = new List<Account>([Select Id, IsCustomerPortal FROM Account WHERE Name = :attributes.get('User.CompanyName') limit 1]);
                if(accountList.size() > 0)
                {
                    customerAccount = accountList[0];
                } else {
                    captureLog('Error Code CCP102: No matching account found for Company Name in SAML Request','Exception in method handleJit');     
                    throw new JitException('Error Code CCP102: No matching account found for Company Name in SAML Request');                                             
                }
            } else {
                captureLog('Error Code CCP101: Company/Customer Name is unavailable in SAML Request','Exception in method handleJit');     
                throw new JitException('Error Code CCP101: Company/Customer Name is unavailable in SAML Request');                         
            } 
            String contactId = handleContact(create, customerAccount, attributes);
            
            //attributes.put('User.UserContactId', contactId);
            handleUser(create, u, attributes, federationIdentifier, contactId, false);
        } else {
            //No portal: Employee SSO
            handleUser(create, u, attributes, federationIdentifier, null, true);
        }
    }
    
    global void captureLog(String msg, String label){
        if(label == null){
            label = '<-';            
        }
        insert new LogsWarehouse__c(Error_description__c=msg,ExternalUserID__c=label);
        System.debug(label + ' -> '+ msg);        
    }
}