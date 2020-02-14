public class ChatterPostNotification 
{
    public static void chatterPost(List<sObject> records,String objectType,String condition1, String condition2,Boolean condition3,String message)
    {
        Map<Id,Schema.RecordTypeInfo> rtMapById;
        if(condition3 == true)
        {
            rtMapById = Schema.SObjectType.Case.getRecordTypeInfosById();
        }
        List<MobileAppNotificationUser__c> allUsers = MobileAppNotificationUser__c.getall().values();
        List<Id> userIds = new List<Id>();
        for(MobileAppNotificationUser__c singleUser : allUsers)
        {
            if(singleUser.Type__c.containsIgnoreCase(objectType))
                userIds.add(Id.valueOf(singleUser.Id__c));
        }
        Map<String,AccountTeamMemberRoles__c> memberRoles = AccountTeamMemberRoles__c.getall();
        //Map<Id,List<FeedItem>> mapOfAccountIdAndFeedPosts = new Map<Id,List<FeedItem>>();
        List<User> listOfUsers = [select id from User where ID in :userIds];
        
        List<FeedItem> posts = new List<FeedItem>();
        Map<Object,sObject> listOfContractAccountsAndMobileCards = new Map<Object,sObject>();
        List<sObject> listOfMobileCardWithoutAccounts = new List<sObject>();
        Map<Object,sObject> createdUserIdWithMobileCard = new Map<Object,sObject>();
        for(sObject record : records)
        {
            Boolean checkForCase = true;
            if(record.get(condition1) == true)  //Condition 1  - Oversold Check
            {
                if(condition3 == true)  //This will only run for Case Chatter
                {
                    if(rtMapById.get((Id)record.get('RecordTypeId')).getDeveloperName() != 'Creative_Services')
                    {
                        if(record.get('Client_Services_Category__c') != 'Web Design Support')
                        {
                            
                        }
                        else
                        {
                            checkForCase = false;
                        }
                    }
                    else
                    {
                        checkForCase = false;
                    }
                }
                System.debug(record.get(condition2)+'<<<Account');
                if(record.get(condition2) != NULL && checkForCase)  //Condition 2 - Account Check
                {
                    listOfContractAccountsAndMobileCards.put(record.get(condition2),record);
                }
                else
                {
                    if(checkForCase)
                        listOfMobileCardWithoutAccounts.add(record);
                }
                if(objectType.equalsIgnoreCase('Onboarding'))
                { 
                    createdUserIdWithMobileCard.put(record.get('LastModifiedById'),record);
                }
                else
                {
                createdUserIdWithMobileCard.put(record.get('CreatedById'),record);
                }
            }
        }
        Set<Id> accounts = new Set<Id>();
        for(Object obj : listOfContractAccountsAndMobileCards.keySet())
        {
            accounts.add((Id)obj);
        }
        Map<Id,Id> mobileCardIdWithManagerId = new Map<Id,Id>();
        if(!createdUserIdWithMobileCard.isEmpty() && createdUserIdWithMobileCard.size() > 0)
        {
            Set<Id> users = new Set<Id>();
            for(Object obj : createdUserIdWithMobileCard.keySet())
            {
                users.add((Id)obj);
            }
            for(User u : [select id,ManagerId from User where ID IN :users])
            {
                mobileCardIdWithManagerId.put(createdUserIdWithMobileCard.get(u.Id).Id,u.ManagerId);
            }
        }
        
        Map<Id,List<Id>> mapOfAccountIdVsUserIds = new Map<Id,List<Id>>();
        for(AccountTeamMember atm: [select id,UserId,AccountId,TeamMemberRole FROM AccountTeamMember where AccountId IN :accounts AND (TeamMemberRole = 'Client Success Manager' OR TeamMemberRole = 'CS - Event')])
        {
            if(mapOfAccountIdVsUserIds.containsKey(atm.AccountId))
            {
                List<Id> listOfSelectedUsers = mapOfAccountIdVsUserIds.get(atm.AccountId);
                listOfSelectedUsers.add(atm.UserId);
                 mapOfAccountIdVsUserIds.put(atm.AccountId,listOfSelectedUsers);
            }
            else
            {
                List<Id> listOfSelectedUsers = new List<Id>();
                listOfSelectedUsers.add(atm.UserId);
                mapOfAccountIdVsUserIds.put(atm.AccountId,listOfSelectedUsers);
            }
        }
        for(Account atm : [SELECT Id,OwnerId,(select id,User.Name,AccountId,TeamMemberRole FROM AccountTeamMembers where TeamMemberRole IN :memberRoles.keySet()) from Account WHERE Id IN :accounts])
        {
            String managers = '';
            
            for(AccountTeamMember accountTeamMember : atm.AccountTeamMembers)
            {
                if(managers == '')
                {
                    managers = accountTeamMember.User.Name+'('+accountTeamMember.TeamMemberRole+')';
                }
                else
                {
                    managers = managers + ', ' + accountTeamMember.User.Name+'('+accountTeamMember.TeamMemberRole+')';
                }
            }
            sObject record = listOfContractAccountsAndMobileCards.get(atm.Id);
            for(User u : listOfUsers)
            {
                FeedItem post = new FeedItem();
                post.ParentId = u.Id;
                post.Body = 'The following '+message+' has been marked Post Purchase Concern.\n'+ 
                    'Post Purchase Reason : '+record.get('Post_Purchase_Reason__c')+
                    '\nComment : '+record.get('Oversold_Comment__c')+
                    '\nPlease review https://cvent.my.salesforce.com/'+record.Id+
                    '\nAccount Manager: '+managers;
                posts.add(post);
            }
            
            //System.debug('mobileCard.Contract_Account_New__r.OwnerId>>>'+record.get('Account__c'));
            FeedItem post1 = new FeedItem();
            post1.ParentId = atm.OwnerId;
            post1.Body = 'The following '+message+' has been marked Post Purchase Concern.\n'+ 
                'Post Purchase Reason : '+record.get('Post_Purchase_Reason__c')+
                '\nComment : '+record.get('Oversold_Comment__c')+
                '\nPlease review https://cvent.my.salesforce.com/'+record.Id+
                '\nAccount Manager: '+managers;
            posts.add(post1);
            
            //System.debug('mobileCard.CreatedBy.ManagerId>>>'+mobileCard.CreatedBy.ManagerId);
            
            FeedItem post2 = new FeedItem();
            post2.ParentId = mobileCardIdWithManagerId.get(record.Id);
            post2.Body = 'The following '+message+' has been marked Post Purchase Concern.\n'+ 
                'Post Purchase Reason : '+record.get('Post_Purchase_Reason__c')+
                '\nComment : '+record.get('Oversold_Comment__c')+
                '\nPlease review https://cvent.my.salesforce.com/'+record.Id+
                '\nAccount Manager: '+managers;
            posts.add(post2);
            
            if(mapOfAccountIdVsUserIds.containsKey(atm.Id))
            {
                for(Id userId : mapOfAccountIdVsUserIds.get(atm.Id))
                {
                    FeedItem post = new FeedItem();
                    post.ParentId = userId;
                    post.Body = 'The following '+message+' has been marked Post Purchase Concern.\n'+ 
                        'Post Purchase Reason : '+record.get('Post_Purchase_Reason__c')+
                        '\nComment : '+record.get('Oversold_Comment__c')+
                        '\nPlease review https://cvent.my.salesforce.com/'+record.Id+
                        '\nAccount Manager: '+managers;
                    posts.add(post);
                }
            }
        }
        
        
        
        for(sObject record : listOfMobileCardWithoutAccounts)
        {
            for(User u : listOfUsers)
            {
                FeedItem post = new FeedItem();
                post.ParentId = u.Id;
                post.Body = 'The following '+message+' has been marked Post Purchase Concern.\n'+ 
                    'Post Purchase Reason : '+record.get('Post_Purchase_Reason__c')+
                    '\nComment : '+record.get('Oversold_Comment__c')+
                    '\nPlease review https://cvent.my.salesforce.com/'+record.Id;
                posts.add(post);
            }
            FeedItem post2 = new FeedItem();
            post2.ParentId = mobileCardIdWithManagerId.get(record.Id);
            post2.Body = 'The following '+message+' has been marked Post Purchase Concern.\n'+ 
                'Post Purchase Reason : '+record.get('Post_Purchase_Reason__c')+
                '\nComment : '+record.get('Oversold_Comment__c')+
                '\nPlease review https://cvent.my.salesforce.com/'+record.Id;
            posts.add(post2);
        }
        System.debug('posts:'+posts);
        if(!posts.IsEmpty() && posts.size() > 0)
        {
            insert posts;
        }
    }
}