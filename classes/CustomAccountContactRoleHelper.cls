/**********************************************************************************************************
NAME: CustomAccountContactRoleHelper
CREATED: July 15, 2014
CREATED BY: Hong Yan
PURPOSE: Create a Custom Account Contact Role object to manage relationships between contacts and accounts
         with additional functionality not available in the standard object.
         A standard acr will be created as a mirror of the custom acr so that there will be no impact to
         reporting or other standard functionality.
         Default acr will be created and managed for each contact that reflects the standard account
         contact relationship that exists (contact.account).

UPDATED BY: Rong Bin on Jul 17, 2014
CHANGE: To complete this apex class

UPDATED BY: Rong Bin on Sep 18, 2014
CHANGE: To change the user creation logic from contact role creation to contact creation.
**********************************************************************************************************/


public class CustomAccountContactRoleHelper
{
//Creates a standard account contact role and relates it to the custom one, whenever a custom account contact role is created.
//This is expected to be run on a before insert call.
    public static void handleNewCACR(List<CustomAccountContactRole__c> cacrList)
    {
//Create a new map for the standard acr and the custom acr
//Map uses an integer so we can relate the two objects since custom acr doesn't have an id as it is on before insert
        Map<Integer,AccountContactRole> NewAcrMap=new Map<Integer,AccountContactRole>();
        Map<Integer,CustomAccountContactRole__c> newCACR=new Map<Integer,CustomAccountContactRole__c>();
        Map<Id, Id> contactIdCACRIdMap = new Map<Id, Id>();

        Integer counter=0;
        Integer ii=0;
        
        for(CustomAccountContactRole__c cacr : cacrList)
        {
//Create a new standard acr and add to the map. Both maps use the same id so that we can relate them after the insert.
//This is necessary to bulkify the dml statements to prevent governor limit exceptions.
            cacr.Unique_Check__c = cacr.Account__c + '-' + cacr.Contact__c + '-' + cacr.Role__c;
            NewAcrMap.Put(counter,New AccountContactRole(AccountId=cacr.Account__c,ContactId=cacr.Contact__c,Role=cacr.Role__c,IsPrimary=cacr.Primary__c));
            newCACR.Put(counter,cacr);
            counter++;
            
            if (cacr.Role__c == 'Idea User')
            {
                //contactIdCACRIdMap format (ContactId, ContactId) 
                if (contactIdCACRIdMap.get(cacr.Contact__c) == null)
                    contactIdCACRIdMap.put(cacr.Contact__c, cacr.Contact__c);
            }
                   
        }
//Check that we have items before insert
        if(!NewAcrMap.isEmpty())
        {
            insert NewAcrMap.Values();
        }
//Using the counter, we iterate through the collection, using the counter as a common id.
//Add the Id of the standard acr to the custom acr to make it easier when we do updates and deletes.
//This is necessary because the standard acr is not a regular object where we can add new fields and such.
        
        while (ii<counter)
        {
            AccountContactRole acr=NewAcrMap.get(ii);
            CustomAccountContactRole__c cacr=newCACR.get(ii);
            cacr.System_Contact_Role__c=acr.Id;
            ii++;
        }

        //Handle User Permission Set -- Add Permission Set
        if (!contactIdCACRIdMap.isEmpty()) 
        {
            handlePermissionSetAssignment (contactIdCACRIdMap, True);
        }
        
    }
    
//When the custom account contact role is updated, update the related standard object as well
//If the default role is updated, it will revert back to the appropriate relationship based on the account/contact relationship
//Expected that this would be called on before update

/* 
Due to native AccountContactRole doesn't support updating on AccountId, it has to delete the existing record and create a new record 
in any case the contact has been assigned to a different account
*/
    public static void handleUpdatedCustomAccountContactRole(Map<Id,CustomAccountContactRole__c> newMap, Map<Id,CustomAccountContactRole__c> oldMap)
    {
        List<AccountContactRole> updateACRList = new List<AccountContactRole>();
        List<AccountContactRole> deleteACRList = new List<AccountContactRole>();
        AccountContactRole updateACR;
        AccountContactRole deleteACR;
        Map<Integer,AccountContactRole> NewAcrMap=new Map<Integer,AccountContactRole>();
        Map<Integer,CustomAccountContactRole__c> updateCACR=new Map<Integer,CustomAccountContactRole__c>();

        
        Map<Id, Id> contactIdCACRIdMap = new Map<Id, Id>();
        Map<Id, Id> contactIdCACRIdMap2 = new Map<Id, Id>();
        

        Integer counter=0;
        Integer ii=0;

        for(CustomAccountContactRole__c cacr:newMap.Values())
        {
            cacr.Unique_Check__c = cacr.Account__c + '-' + cacr.Contact__c + '-' + cacr.Role__c;
            CustomAccountContactRole__c oldCACR = oldMap.Get(cacr.Id);
            if (cacr.System_Contact_Role__c != null) 
            {
                if (cacr.Account__c == oldCACR.Account__c) 
                {
                    updateACR = new AccountContactRole(Id=cacr.System_Contact_Role__c,AccountId=cacr.Account__c,ContactId=cacr.Contact__c
                        ,Role=cacr.Role__c,IsPrimary=cacr.Primary__c);
                    updateACRList.add(updateACR);
                }
                else
                {
                    // Reassign the contact default role
                    if (cacr.Role__c == 'System') 
                    {
                        deleteACR = new AccountContactRole(Id=cacr.System_Contact_Role__c, Role='System');
                        deleteACRList.add(deleteACR);
                   
                        NewAcrMap.Put(counter,New AccountContactRole(AccountId=cacr.Account__c,ContactId=cacr.Contact__c,Role='System'
                            ,IsPrimary=cacr.Primary__c));
                        updateCACR.Put(counter,cacr);
                        counter++;
                    }
                }
            } 

            if (cacr.Role__c == 'Idea User' && oldMap.get(cacr.Id).Role__c != cacr.Role__c)
            {
                //contactIdCACRIdMap is used to keep new permission set candidate
                //contactIdCACRIdMap format (ContactId, ContactId) 
                if (contactIdCACRIdMap.get(cacr.Contact__c) == null)
                    contactIdCACRIdMap.put(cacr.Contact__c, cacr.Contact__c);
            } 
            else if (oldMap.get(cacr.Id).Role__c == 'Idea User' && oldMap.get(cacr.Id).Role__c != cacr.Role__c)
            {
                //contactIdCACRIdMap2 is used to keep remove permission set candidate
                //contactIdCACRIdMap2 format (CACRId, ContactId) 
                contactIdCACRIdMap2.put(cacr.Id, cacr.Contact__c); 
            }
        }

        if(!deleteACRList.isEmpty())
        {
            delete deleteACRList;
        }

        if(!NewAcrMap.isEmpty())
        {
            insert NewAcrMap.Values();
        }

        while (ii<counter)
        {
            AccountContactRole acr = NewAcrMap.get(ii);
            CustomAccountContactRole__c cacr = updateCACR.get(ii);
            cacr.System_Contact_Role__c = acr.Id;
            ii++;
        }

        if(!updateACRList.isEmpty())
        {
            update updateACRList;
        }

        //Handle User Permission Set -- Add Permission Set
        if (!contactIdCACRIdMap.isEmpty()) 
        {
           handlePermissionSetAssignment (contactIdCACRIdMap, True);
        }

        //Handle User Permission Set -- Remove Permission Set
        if (!contactIdCACRIdMap2.isEmpty()) 
        {
            handlePermissionSetAssignment (contactIdCACRIdMap2, False);
        }
    }

//When the custom account contact role is deleted, delete the standard object as well
//Also prevent deletion of the default role
//Expected that this would be called on before delete
    public static void handleDeletedCustomAccountContactRole(Map<Id,CustomAccountContactRole__c> oldMap)
    {
        List<AccountContactRole> deleteACRList = new List<AccountContactRole>();
        AccountContactRole deleteACR;
        Map<Id, Id> contactIdCACRIdMap = new Map<Id, Id>();
        
        for(CustomAccountContactRole__c cacr:oldMap.Values())
        {
            if (cacr.System_Contact_Role__c != null)
            {
                deleteACR = new AccountContactRole(Id=cacr.System_Contact_Role__c);
                deleteACRList.add(deleteACR);
            }

            if (cacr.Role__c == 'Idea User')
            {
                // contactIdCACRIdMap format (CACRId, ContactId) 
                contactIdCACRIdMap.put(cacr.Id, cacr.Contact__c);
            }

        }

        if(!deleteACRList.isEmpty())
        {
            delete deleteACRList;
        }

        //Handle User Permission Set -- Remove Permission Set
        if (!contactIdCACRIdMap.isEmpty()) 
        {
            handlePermissionSetAssignment (contactIdCACRIdMap, False);
        }



    }

//Creates a default role when a contact is created.
//We tag it with a custom creation source system of 'SYS' so we can tell it's one that was auto-created.
//This default role will be updated if the account on the contact is changed.    
    public static void handleNewContact(List<Contact> cList)
    {
        List<CustomAccountContactRole__c> newCACRList=new List<CustomAccountContactRole__c>();
        List<String> uAliasList = new List<String>();
        List<String> uEmailList = new List<String>();
        List<String> uLastName = new List<String>();
        List<String> uFirstName = new List<String>();
        List<ID> uProfileList = new List<ID>();
        List<String> uUserNameList = new List<String>();
        List<Boolean> uIsActiveList = new List<Boolean>();
        List<ID> uContactIdList = new List<ID>();
        String Creation_Source_System_External_ID;

        Profile p = [SELECT Id FROM Profile WHERE Name='AWO Community' LIMIT 1]; 

        for(Contact c:cList)
        {
            newCACRList.Add(New CustomAccountContactRole__c(Account__c=c.AccountId,Contact__c=c.Id,Role__c='System'
                ,Creation_Source_System__c='SYS',Creation_Source_System_External_Id__c='SYS_'+c.Id));
            if (c.Creation_Source_System__c == 'AWO' || c.Creation_Source_System__c == 'AWOCDN')
            {
                Creation_Source_System_External_ID = c.Creation_Source_System_External_Id__c.toLowerCase();
                uAliasList.add(Creation_Source_System_External_ID) ;
                uEmailList.add(c.Email == null?Creation_Source_System_External_ID + '@activenetwork.com':c.Email);
                uLastName.add(c.LastName);
                uFirstName.add(c.FirstName);
                uProfileList.add(p.Id);
                uUserNameList.add(Creation_Source_System_External_ID + '@awo.com'); 
                uIsActiveList.add(true);
                uContactIdList.add(c.Id);
            }

        }

        //Handle User creation
        if(!uUserNameList.isEmpty()) // create new users
        {
            runUserCreation (uAliasList, uEmailList, uLastName, uFirstName, uProfileList, uUserNameList, uIsActiveList, uContactIdList);
            System.debug (logginglevel.INFO, '---------------------------create user size : ' + uUserNameList.size());
        }

        if(!newCACRList.isEmpty())
        {
            insert newCACRList;
        }
    }

//Changes the default role to associate to the new account when the account on a contact is changed.
    public static void handleUpdatedContact(Map<Id,Contact> newCMap, Map<Id,Contact> oldCMap)
    {
//Identify all contacts where the account was updated
        Map<String,Contact> extIdMap=new Map<String,Contact>();
        Map<String,Contact> userNameContactMap = new Map<String,Contact>();
        List<User> userList = new List<User>();

        List<ID> uIDList = new List<ID>(); 
        List<String> uAliasList = new List<String>();
        List<String> uEmailList = new List<String>();
        List<String> uLastName = new List<String>();
        List<String> uFirstName = new List<String>();
        List<String> uUserNameList = new List<String>();
        String EmailAddress;

        List<String> uAliasList2 = new List<String>();
        List<String> uEmailList2 = new List<String>();
        List<String> uLastName2 = new List<String>();
        List<String> uFirstName2 = new List<String>();
        List<ID> uProfileList2 = new List<ID>();
        List<String> uUserNameList2 = new List<String>();
        List<Boolean> uIsActiveList2 = new List<Boolean>();
        List<ID> uContactIdList2 = new List<ID>();
        String Creation_Source_System_External_ID;

        Profile p = new Profile();


        for(Contact c:newCMap.Values())
        {
            Contact oldC = oldCMap.Get(c.Id);
            if(oldC != null && c.AccountId != oldC.AccountId)
            {
                extIdMap.Put('SYS_'+oldC.Id,c);
            }

            if (c.Creation_Source_System__c == 'AWO' || c.Creation_Source_System__c == 'AWOCDN')
            {
                userNameContactMap.put(
                    c.Creation_Source_System_External_ID__c.toLowerCase() + '@awo.com', c);
            }
        }
//Get the list of default custom acrs and update them with the new account id.
        if(!extIdMap.isEmpty())
        {
            List<CustomAccountContactRole__c> existingCACRList=[SELECT Id, Account__c, Contact__c, Creation_Source_System_External_Id__c 
                    FROM CustomAccountContactRole__c WHERE Creation_Source_System_External_Id__c IN :extIdMap.keySet()];
            if(!existingCACRList.isEmpty())
            {
                for(CustomAccountContactRole__c cacr:existingCACRList)
                {
                    Contact c=extIdMap.Get(cacr.Creation_Source_System_External_Id__c);
                    if(c != null)
                    {
                        cacr.Account__c=c.AccountId;
                        cacr.Creation_Source_System_External_Id__c='SYS_'+c.Id;
                    }
                }
                update existingCACRList;
            }
        }

        //Handle User update
        if (!userNameContactMap.isEmpty()) {
            userList = [SELECT Id, IsActive, ProfileId, Alias, Email, EmailEncodingKey, LastName, FirstName, LanguageLocaleKey
                , LocaleSidKey, TimeZoneSidKey, UserName FROM User WHERE UserName IN :userNameContactMap.keySet() AND IsActive = True];
            
            for (User u:userList)
            {
                EmailAddress = userNameContactMap.get(u.UserName).Email==null?userNameContactMap.get(u.UserName).Creation_Source_System_External_Id__c.toLowerCase() + '@activenetwork.com':userNameContactMap.get(u.UserName).Email;
                uIDList.add(u.Id);
                uAliasList.add(userNameContactMap.get(u.UserName).Creation_Source_System_External_Id__c.toLowerCase());
                uEmailList.add(EmailAddress);
                uLastName.add(userNameContactMap.get(u.UserName).LastName);
                uFirstName.add(userNameContactMap.get(u.UserName).FirstName);
                uUserNameList.add(userNameContactMap.get(u.UserName).Creation_Source_System_External_Id__c.toLowerCase() + '@awo.com'); 
                userNameContactMap.remove(u.UserName); // prepare portal user non-existing cases
            }

            if (!uIDList.isEmpty())
            {
                runUserUpdate (uIDList, uAliasList, uEmailList, uLastName, uFirstName);
                System.debug (logginglevel.INFO, '---------------------------update user size : ' + uIDList.size());
            }

            if (!userNameContactMap.isEmpty())
            {   
                p = [SELECT Id FROM Profile WHERE Name='AWO Community' LIMIT 1]; 
                for (String uUserName:userNameContactMap.keySet())
                {
                    EmailAddress = userNameContactMap.get(uUserName).Email==null?userNameContactMap.get(uUserName).Creation_Source_System_External_Id__c.toLowerCase() + '@activenetwork.com':userNameContactMap.get(uUserName).Email;
                    uAliasList2.add(userNameContactMap.get(uUserName).Creation_Source_System_External_ID__c.toLowerCase()) ;
                    uEmailList2.add(EmailAddress);
                    uLastName2.add(userNameContactMap.get(uUserName).LastName);
                    uFirstName2.add(userNameContactMap.get(uUserName).FirstName);
                    uProfileList2.add(p.Id);
                    uUserNameList2.add(uUserName); 
                    uIsActiveList2.add(true);
                    uContactIdList2.add(userNameContactMap.get(uUserName).Id);
                }
                runUserCreation (uAliasList2, uEmailList2, uLastName2, uFirstName2, uProfileList2, uUserNameList2, uIsActiveList2, uContactIdList2);
                System.debug (logginglevel.INFO, '---------------------------create user size : ' + uUserNameList2.size());
            }
        }
    }

    private static void handlePermissionSetAssignment (Map<Id, Id> contactIdCACRIdMap, Boolean addAssignementFlag)
    {
        
        List<Contact> contactList = new List<Contact>();
        List<String> userNameList = new List<String>();
        List<Id> userIdList = new List<Id>();
        List<User> userList = new List<User>();
        List<PermissionSetAssignment> PSAList = new List<PermissionSetAssignment>();
        PermissionSet ps = new PermissionSet();
        List<Id> newPSAUserIdList = new List<Id>();
        List<Id> newPSAPermissionSetIdList = new List<Id>();
        List<Id> deletePSAIDList = new List<Id>();
        Set<String> PSASet = new Set<String>();
        List<CustomAccountContactRole__c> IdeaUserCACRList = new List<CustomAccountContactRole__c>();
        Map<Id, Id> IdeaUserCACRMap = new Map<Id, Id>();
        Set<Id> contactIdSet = new Set<Id>();

 
        

        if (addAssignementFlag == False) // Remove PSA 
        {
            for (Id CACRId:contactIdCACRIdMap.keySet())
            {
                if (!contactIdSet.contains(contactIdCACRIdMap.get(CACRId)))
                    contactIdSet.Add(contactIdCACRIdMap.get(CACRId));
            } 

            IdeaUserCACRList = [SELECT Id, Contact__c FROM CustomAccountContactRole__c
                    WHERE Contact__c IN :contactIdSet AND Role__c = 'Idea User'];
            for (CustomAccountContactRole__c cacr:IdeaUserCACRList)
            {
                if (contactIdCACRIdMap.get(cacr.Id) == null)
                {
                    contactIdSet.remove(cacr.Contact__c);
                }

            }
        }
        else
        {
            contactIdSet = contactIdCACRIdMap.keySet();
        }
        
        
        if (!contactIdSet.isEmpty())
        {
            contactList = [SELECT Id, Creation_Source_System__c, Email, Creation_Source_System_External_Id__c, LastName, FirstName 
                    FROM Contact WHERE Id IN :contactIdSet AND Creation_Source_System__c = 'AWO'];
            for (Contact c : ContactList)
            {
                userNameList.add(c.Creation_Source_System_External_Id__c.toLowerCase() + '@awo.com');
            }

            if (!userNameList.isEmpty())
            {
                userList = [SELECT Id FROM User WHERE UserName IN :userNameList]; 
                ps = [SELECT Id FROM PermissionSet WHERE Name = 'Idea_User' LIMIT 1];
            }

            for (User u : userList)
            {
                userIdList.add(u.Id);
            } 

            if (!userIdList.isEmpty())
            {
                PSAList = [SELECT Id, AssigneeId FROM PermissionSetAssignment WHERE AssigneeId IN :userIdList AND PermissionSetId = :ps.Id];
                for (PermissionSetAssignment PSA : PSAList)
                {
                    if (addAssignementFlag == False)  // Remove PSA
                        deletePSAIDList.add (PSA.Id); // Prepare delete PSA list
                    else                              // Add PSA
                        PSASet.add(PSA.AssigneeId);  
                }
                
                if (addAssignementFlag == True) // Add PSA
                {
                    for (User uu : userList)
                    {
                        if (!PSASet.contains(uu.Id))
                        {
                            newPSAUserIdList.add(uu.Id);
                            newPSAPermissionSetIdList.add(ps.Id);
                        }
                    } 
                }

                if (!deletePSAIDList.isEmpty())
                {
                    runPermissionSetAssignmentDeletion (deletePSAIDList);
                    System.debug (logginglevel.INFO, '---------------------------delete assignment size : ' + deletePSAIDList.size());
                }

                if(!newPSAUserIdList.isEmpty()) // assgin new permission set
                {
                    runPermissionSetAssignmentCreation(newPSAUserIdList, newPSAPermissionSetIdList);
                    System.debug (logginglevel.INFO, '---------------------------create assignment size : ' + newPSAUserIdList.size());
                }
            
            }
        }
        
    }

    @future
    private static void runUserUpdate (List<ID> uIDList, List<String> uAliasList, List<String> uEmailList, List<String> uLastName, List<String> uFirstName)
    {
        Integer i = 0;
        List<User> userList = new List<User>();
        User u = new User();
        String uNickName;
        while (i < uIDList.size())
        {
            uNickName = uFirstName.get(i) +  '.' + uLastName.get(i) + '.' + String.valueOf(Math.random());
            u = new User(Alias = uAliasList.get(i).length() > 8 ? uAliasList.get(i).substring(0,8) : uAliasList.get(i), Email=uEmailList.get(i)
                , EmailEncodingKey='UTF-8', LastName=uLastName.get(i), FirstName=uFirstName.get(i), LanguageLocaleKey='en_US', LocaleSidKey='en_US'
                , CommunityNickname = uNickName.length() > 40 ? uNickName.substring(0,40) : uNickName
                , TimeZoneSidKey='America/Los_Angeles', Id=uIDList.get(i));
            userList.add(u);
            i++;
        }
        try 
        {
            update userList;
        }
        catch (DMLException e)
        {
            System.debug(logginglevel.ERROR, 'There was a problem when updating the user. ' + e.getMessage());
        }
    }

    @future
    private static void runUserCreation (List<String> uAliasList, List<String> uEmailList, List<String> uLastName, List<String> uFirstName
        , List<ID> uProfileList, List<String> uUserNameList, List<Boolean> uIsActiveList, List<ID> uContactIdList)
    {
        Integer i = 0;
        List<User> userList = new List<User>();
        User u = new User();
        String uNickName;
        while (i < uUserNameList.size())
        {
            uNickName = uFirstName.get(i) +  '.' + uLastName.get(i) + '.' + String.valueOf(Math.random());
            u = new User(Alias = uAliasList.get(i).length() > 8 ? uAliasList.get(i).substring(0,8) : uAliasList.get(i), Email=uEmailList.get(i)
                , EmailEncodingKey='UTF-8', LastName=uLastName.get(i), FirstName=uFirstName.get(i), LanguageLocaleKey='en_US', LocaleSidKey='en_US'
                , ProfileId = uProfileList.get(i), TimeZoneSidKey='America/Los_Angeles' , IsActive=uIsActiveList.get(i)
                , CommunityNickname = uNickName.length() > 40 ? uNickName.substring(0,40) : uNickName
                , ContactId = uContactIdList.get(i), UserName = uUserNameList.get(i));
            userList.add(u);
            i++;
        }
        try
        {
            insert userList;
        }
        catch (DMLException e)
        {
            System.debug(logginglevel.ERROR, 'There was a problem when creating the user. ' + e.getMessage());
        }
    }


    @future
    @TestVisible private static void runPermissionSetAssignmentCreation (List<ID> assigneeIdList, List<ID> permissionSetIdList)
    {
        Integer i = 0;
        List<PermissionSetAssignment> PSAList = new List<PermissionSetAssignment>();
        PermissionSetAssignment PSA = new PermissionSetAssignment();
        while (i < assigneeIdList.size())
        {
            PSA = new PermissionSetAssignment(AssigneeId = assigneeIdList.get(i), PermissionSetId = permissionSetIdList.get(i));
            PSAList.add(PSA);
            i++;
        }
        try
        {
            insert PSAList;
        }
        catch (DMLException e)
        {
            System.debug(logginglevel.ERROR, 'There was a problem when creating the permissionsetassignment. ' + e.getMessage());
        }
    }


    @future
    @TestVisible private static void runPermissionSetAssignmentDeletion (List<ID> pIDList)
    {
        List<PermissionSetAssignment> PSAList = new List<PermissionSetAssignment>();
        PSAList = [SELECT Id FROM PermissionSetAssignment WHERE Id IN :pIDList];
        try 
        {    
            delete PSAList;
        }
        catch (DMLException e)
        {
            System.debug(logginglevel.ERROR, 'There was a problem when deleting the permissionsetassignment. ' + e.getMessage());
        }

    }
}