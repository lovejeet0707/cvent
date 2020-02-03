global class IntegrationAccount
{
    public static void handleNewAccounts(Map<Id,Account> acMap)
    {
        System.Debug(Logginglevel.DEBUG,'INTEGRATIONACCOUNT.HANDLENEWACCOUNTS - Start.');
        List<Id> acList=new List<Id>();
        System.Debug(Logginglevel.FINE,'INTEGRATIONACCOUNT.HANDLENEWACCOUNTS - Checking for valid accounts for queue.');
        for(Account a:acMap.Values())
        {
            System.Debug(Logginglevel.DEBUG,'INTEGRATIONACCOUNT.HANDLENEWACCOUNTS - Checking on last modified by: '+a.lastModifiedById+'. truncated: '+String.ValueOf(a.lastModifiedById).left(15)+'...');
            
            //Prospects Sync disabled with this check. For new customers, EBS Order Sync process would trigger the Resync method directly.
            if(a.EBS_Account_Id__c != null) {
                System.Debug(Logginglevel.FINER,'INTEGRATIONACCOUNT.HANDLENEWACCOUNTS - Account('+a.Id+', '+a.Name+') is valid. Attempting to add to queue.');
                acList.Add(a.Id);
            }
        }
        if(!acList.isEmpty())
        {
            System.Debug(Logginglevel.FINER,'INTEGRATIONACCOUNT.HANDLENEWACCOUNTS - Adding '+acList.size()+' items to the queue.');
            addtoQueue(acList,'Create');
        }
    }
    
    public static void handleUpdatedAccounts(List<Account> acList,map<Id,Account> oldList)
    {
        System.Debug(Logginglevel.DEBUG,'INTEGRATIONACCOUNT.HANDLEUPDATEDACCOUNTS - Start');
        List<EBS_Integration__c> fieldList=[SELECT Name,Object__c,Field__c,Map_To__c,Map__c,Validate__c FROM EBS_Integration__c WHERE Object__c='Account' AND (Map__c=true OR Validate__c=true)];
        List<Id> updatedAcs=new List<Id>();
        List<Id> newAcs=new List<Id>();
        for(Account a:acList)
        {
            System.Debug(Logginglevel.FINER,'INTEGRATIONACCOUNT.HANDLEUPDATEDACCOUNTS - Testing '+a.Id+', '+a.Name);
            
            //Prospects Sync disabled with this check. For new customers, EBS Order Sync process would trigger the Resync method directly.
            if(a.EBS_Account_Id__c != null || a.EBS_Update__c == true) {
                Account old=oldList.get(a.Id);
                if(old!=null)
                {
                    Integer compare=IntegrationHelper.compare(a,old,fieldList);
                    if(compare==1)
                    {
                        System.Debug(Logginglevel.FINEST,'INTEGRATIONACCOUNT.HANDLEUPDATEDACCOUNTS - Changes detected. Adding '+a.Id+', '+a.Name+' to queue');
                        if(a.EBS_Account_Id__c==null)
                            newAcs.Add(a.Id);
                        else
                            updatedAcs.Add(a.Id);
                    }
                    else if(compare==0){
                        //Manually triggered Update: Could be used for One Time Sync 
                        if(a.EBS_Update__c == true && a.EBS_Update__c != old.EBS_Update__c){
                            System.Debug(Logginglevel.FINEST,'INTEGRATIONACCOUNT.HANDLEUPDATEDACCOUNTS - UPDATE FLAG SET MANUALLY');
                            updatedAcs.Add(a.Id);
                        } else {
                            System.Debug(Logginglevel.FINEST,'INTEGRATIONACCOUNT.HANDLEUPDATEDACCOUNTS - No changes detected for '+a.Id+', '+a.Name+'. skipping');
                        }
                    }
                    else
                        System.Debug(Logginglevel.FINEST,'INTEGRATIONACCOUNT.HANDLEUPDATEDACCOUNTS - Error detecting changes for '+a.Id+', '+a.Name);
                }
                else If(old==null)
                {
                        if(a.EBS_Account_Id__c==null)
                            newAcs.Add(a.Id);
                        else
                            updatedAcs.Add(a.Id);
                }
            }
        }
        if(!updatedAcs.isEmpty())
        {
            System.Debug(Logginglevel.FINE,'INTEGRATIONACCOUNT.HANDLEUPDATEDACCOUNTS - Adding '+updatedAcs.size()+' updated accounts to queue.');
            addToQueue(updatedAcs,'Update');
        }
        if(!newAcs.isEmpty())
        {
            System.Debug(Logginglevel.FINE,'INTEGRATIONACCOUNT.HANDLEUPDATEDACCOUNTS - Adding '+newAcs.size()+' new accounts to queue.');
            addToQueue(newAcs,'Create');
        }
    }
    
    public static void handleAddressUpdates(List<Account> aList,Map<Id,Account> oldMap)
    {
        System.Debug(Logginglevel.DEBUG,'INTEGRATIONCONTACT.HANDLECOUNTRYUPDATES - NO ACTION REQUIRED - Moved to Standard Country and State Picklists');
    }
    
    public static void handleDependentUpdates(List<Account> acList,map<Id,Account> oldList)
    {
        /* Trigger an update to related contacts and addresses only if the EBS Account Id is generated for the first time or if the EBS has changed (highly unlikely) */
        
        System.Debug(Logginglevel.DEBUG,'INTEGRATIONACCOUNT.HANDLECONTACTUPDATES - Start');
        List<Id> aList=new List<Id>();
        for(Account a:acList)
        {
            System.Debug('INTEST - a:'+a.EBS_Account_Id__c);
            Account old=oldList.get(a.Id);
            if(old!=null)
            {
                System.Debug('INTEST - old:'+old.EBS_Account_Id__c);
                if(a.EBS_Account_Id__c!=null&&a.EBS_Account_Id__c!=''&&a.EBS_Account_Id__c!=old.EBS_Account_Id__c)
                    aList.Add(a.Id);
            }
            else
                System.Debug(Logginglevel.FINEST,'INTEGRATIONACCOUNT.HANDLECONTACTUPDATES - No old values to compare for account'+a.Id+', '+a.Name);
        }
        if(!aList.isEmpty())
        {
            try
            {
                updateContactIds(aList);
                updateAddressIds(aList);
            }
            catch (Exception e)
            {
                System.Debug(Logginglevel.ERROR,'INTEGRATIONACCOUNT.HANDLECONTACTUPDATES - ERror occurred while attempting to update related contacts. '+e.getMessage());
            }
        }
    }
    
    private static void updateContactIds(List<Id> aList)
    {
        List<Contact> cUpdates=new List<Contact>();
        for(Contact c:[SELECT Id,Account.EBS_Account_Id__c,EBS_Account_Id__c FROM Contact WHERE AccountId IN :aList])
        {
            c.EBS_Account_Id__c=c.Account.EBS_Account_Id__c;
            c.EBS_Contact_Id__c=null;
            cUpdates.Add(c);
        }
        if(!cUpdates.isEmpty())
            update cUpdates;
    }
    
    private static void updateAddressIds(List<Id> aList)
    {
        List<Address__c> aUpdates=new List<Address__c>();
        for(Address__c a:[SELECT Id,Account__r.EBS_Account_Id__c,EBS_Account_Id__c FROM Address__c WHERE Account__c IN :aList])
        {
            a.EBS_Account_Id__c=a.Account__r.EBS_Account_Id__c;
            a.EBS_Site_Use_Id__c=null;
            a.EBS_Site_Number__c=null;
            aUpdates.Add(a);
        }
        if(!aUpdates.isEmpty())
            update aUpdates;
    }
     
//    @future
    private static void addToQueue(List<Id> acList,String updateType, String ebsOrderSyncId)
    {
        System.debug('UserInfo.getFirstName() *** '+UserInfo.getFirstName());
        if(UserInfo.getFirstName().equalsIgnoreCase('Cast Iron') && ebsOrderSyncId == null){
            return;
        }
        
        String qName='Account';
        System.Debug(Logginglevel.DEBUG,'INTEGRATIONACCOUNT.ADDTOQUEUE - Start');
        System.Debug(Logginglevel.FINE,'INTEGRATIONACCOUNT.ADDTOQUEUE - Building list of field mappings');
        List<EBS_Integration__c> fieldList=[SELECT Name,Object__c,Field__c,Map_To__c,Map__c,Validate__c FROM EBS_Integration__c WHERE Object__c='Account' AND Map__c=true];
        String queryString='SELECT ';
        for(EBS_Integration__c f:fieldList)
        {
            queryString+=f.Field__c+',';
        }
        if(queryString!='SELECT ')
        {
            Map<String,Integration_Queue__c> newList=new Map<String,Integration_Queue__c>();
            queryString+='id FROM Account WHERE Id IN :acList';
            System.Debug(Logginglevel.FINE,'INTEGRATIONACCOUNT.ADDTOQUEUE - Running query: '+queryString);
            try
            {
                for(Account a:Database.query(queryString))
                {
                    System.Debug(Logginglevel.FINER,'INTEGRATIONACCOUNT.ADDTOQUEUE - Adding account ('+a.Id+', '+a.Name+' to queue.');
                    Integration_Queue__c newItem=IntegrationHelper.mapToQueue(a,fieldList);
                    if(newItem!=null)
                    {
                        newItem.Queue__c=qName;
                        newItem.Status__c='Queued';
                        newItem.Object_ID__c=a.Id;
                        newItem.Type__c=updateType;
                        newList.Put(newItem.Object_Id__c,newItem);
                        if(ebsOrderSyncId != null){
                            System.Debug(Logginglevel.FINER,'INTEGRATIONADDRESS.ADDTOQUEUE - Related EBS Order Sync Process Id found '+ebsOrderSyncId);
                            newItem.EBS_Order_Sync_Process_Id__c = ebsOrderSyncId;    
                        }
                                                
                    }
                    else
                        System.Debug(Logginglevel.ERROR,'INTEGRATIONACCOUNT.ADDTOQUEUE - Unable to map to queue.');
                }
            }
            catch(Exception e)
            {
                System.Debug(Logginglevel.ERROR,'INTEGRATIONACCOUNT.ADDTOQUEUE - Error while attempting to run query! '+e.getMessage());
            }
            if(newList!=null)
            {
                IntegrationHelper.addToQueue(newList,fieldList,qName);
            }
        }
        else
            System.Debug(Logginglevel.ERROR,'INTEGRATIONACCOUNT.ADDTOQUEUE - No field mappings for account found!');
    }

    private static void addToQueue(List<Id> aList,String updateType)
    {
        addToQueue(aList, updateType, null);
    }
        
    webservice static void resyncAccountForOrderSync(String accId, String ebsOrderSyncId) {
        System.Debug(Logginglevel.DEBUG,'INTEGRATIONACCOUNT.resyncAccountForOrderSync - Start.');
        List<Id> acList=new List<Id>();
        acList.Add(accId);
        System.Debug(Logginglevel.FINER,'INTEGRATIONACCOUNT.resyncAccountForOrderSync - Adding '+acList.size()+' items to the queue.');
        addtoQueue(acList,'Create', ebsOrderSyncId);
    }  
    
    webservice static void resyncAccount(String accId) {
        System.Debug(Logginglevel.DEBUG,'INTEGRATIONACCOUNT.resyncAccount - Start.');
        List<Id> acList=new List<Id>();
        acList.Add(accId);
        System.Debug(Logginglevel.FINER,'INTEGRATIONACCOUNT.resyncAccount - Adding '+acList.size()+' items to the queue.');
        addtoQueue(acList,'Create');
    }
}