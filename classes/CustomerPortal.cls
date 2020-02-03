public class CustomerPortal
{
    
    public static void addContactUsers(Set<Id> cIdList,List<Contact> cList)
    {
        
        System.Debug(Logginglevel.DEBUG,'CUSTOMERPORTAL.ADDCONTACTUSERS - Start');
        
        List<Contact> rolList = new List<Contact>();
        /* Portal user creation functionality is only for ROL Contacts */
        for(Contact c:cList)
        {
            if(!String.isBlank(c.Creation_Source_System_External_ID__c) && c.Creation_Source_System_External_ID__c.startsWith('ROL')){
                String rolPortalUserId = c.Creation_Source_System_External_ID__c.substringAfterLast('_');
                if(!String.isBlank(rolPortalUserId) && rolPortalUserId.length() > 1){
                    rolList.add(c);
                }
            }
        }
        
        if(rolList.size() > 0){
            Profile PortalUser = [SELECT Id FROM Profile WHERE Name = 'RegOnline:High Volume Community Portal User' LIMIT 1]; //Custom: High Volume Customer Portal User
            //Profile inPortalUser=[SELECT Id FROM Profile WHERE Name='Internal High Volume Community Portal User' LIMIT 1]; //Custom: Internal High Volume Customer Portal User
            List<User> newUsers=new List<User>();
            System.Debug(Logginglevel.DEBUG,'CUSTOMERPORTAL.ADDCONTACTUSERS - Adding users for: '+String.join(cList,','));
            Map<String,String> existing=new Map<String,String>();
            List<String> emailList=new List<String>();
            for(Contact c:rolList)
            {
                if(!String.isBlank(c.email))
                    emailList.Add(c.email);
            }
            for(User u:[SELECT userName FROM User WHERE userName IN :emailList])
            {
                System.Debug(Logginglevel.FINER,'CUSTOMERPORTAL.ADDCONTACTUSERS - Found existing user: '+u.userName);
                existing.Put(u.userName,u.userName);
            }
            for(Contact c:rolList)
            {
                System.Debug(Logginglevel.FINER,'CUSTOMERPORTAL.ADDCONTACTUSERS - Checking contact: '+c);
                if(String.isNotBlank(c.email)&&String.isNotBlank(c.AccountId)&&!existing.containsKey(c.email))
                {
                    System.Debug(Logginglevel.FINER,'CUSTOMERPORTAL.ADDCONTACTUSERS - Processing contact: '+c);
                    String strAlias='';
                    if(String.IsNotBlank(c.firstname))
                        strAlias+=c.firstName.left(1);
                    if(String.IsNotBlank(c.lastname))
                        strAlias+=c.lastname;
                    if(strAlias.length()>8)
                        strAlias=strAlias.left(8);
                    else if(String.IsBlank(strAlias))
                        strAlias='user';
                    User u = new User(isActive=TRUE,alias = strAlias,email=c.email,emailencodingkey='UTF-8',firstName=c.firstName,lastName=c.lastName,languagelocalekey='en_US',localesidkey='en_US',profileid=PortalUser.Id,contactId=c.Id,timezonesidkey='America/Los_Angeles',username=c.email);
                    // if(c.Portal_Accounts__c!='eteamz'&&c.Portal_Accounts__c!='FellowshipOne'&&c.Portal_Accounts__c!='RegCenter'&&c.Portal_Accounts__c!='ServiceU'&&c.Portal_Accounts__c!='StarCite'&&c.Portal_Accounts__c!='StarCite Supplier'&&c.Portal_Accounts__c!='M&M')
                    //if(c.Active_Portal_Product_Count__c>0)
                    //u.isActive=TRUE;
                    //else
                    //u.isActive=FALSE;
                    if(String.ValueOf(c.AccountId).left(15)=='001d000000UDD7N'||String.ValueOf(c.AccountId).left(15)=='001d000000WZW9J')
                    {
                        //u.ProfileId=inPortalUser.id;
                        //u.userName+='.portal';
                    }
                    System.Debug(Logginglevel.FINER,'CUSTOMERPORTAL.ADDCONTACTUSERS - Adding '+u.userName+' as new user');
                    newUsers.Add(u);
                }
                else
                    System.Debug(Logginglevel.FINER,'CUSTOMERPORTAL.ADDCONTACTUSERS - Contact ('+c+' does not match criterias required...skipping');
            }
            if(!newUsers.isEmpty())
            {
                System.Debug(Logginglevel.FINE,'CUSTOMERPORTAL.ADDCONTACTUSERS - Inserting users: '+String.join(newUsers,':'));
                try
                {
                    insert newUsers;
                }
                catch (exception err)
                {
                    System.Debug(Logginglevel.ERROR,'CUSTOMERPORTAL.ADDCONTACTUSERS - Error inserting new users!'+err.getMessage()+'\n'+newUsers);
                    //sendExceptionEmail('CUSTOMERPORTAL.ADDCONTACTUSERS - Error inserting new users!'+err.getMessage()+'\n'+newUsers);
                }
            }
        }
        System.Debug(Logginglevel.DEBUG,'CUSTOMERPORTAL.ADDCONTACTUSERS - End');
    }
    
    
    public static void sendExceptionEmail(String message)
    {
        try{
            Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
            String[] emailRecipient=new String[]{'hong.yan@activenetwork.com'};
                mail.setToAddresses(emailRecipient);
            mail.setReplyTo('ApexError@activenetwork.com');
            mail.setSenderDisplayName('Apex Error');
            mail.setSubject('Apex error encountered');
            mail.setHtmlBody(message);
            Messaging.sendEmail(new Messaging.Email[] {mail});
        }catch (exception err){
            
        }
    }
}