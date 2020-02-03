global class IntegrationAddress
{
    public static void handleNewAddresses(List<Address__c> aList)
    {
        System.Debug(Logginglevel.DEBUG,'INTEGRATIONADDRESS.HANDLENEWADDRESSES - Start.');
        List<Id> newA=new List<Id>();
        System.Debug(Logginglevel.FINE,'INTEGRATIONADDRESS.HANDLENEWADDRESSES - Checking for valid accounts for queue.');
        for(Address__c a:aList)
        {
            //if((a.Type__c=='Billing'||a.Type__c=='Shipping'||a.Type__c=='Remittance')&&String.ValueOf(a.lastModifiedById).left(15)!='005K0000001A72T'&&String.ValueOf(a.lastModifiedById).left(15)!='005d0000001atqI'&&String.isNotBlank(a.EBS_Account_Id__c))
            
            //Stop syncing Shipping Addresses - Added on 10/04/2018
            //if((a.Type__c=='Billing'||a.Type__c=='Shipping'||a.Type__c=='Remittance') && String.isNotBlank(a.EBS_Account_Id__c) && String.ValueOf(a.lastModifiedById).left(15)!='005K0000001A72T')
           //shipping check added by Udita : P-004959
            if((a.Type__c=='Billing' ||a.Type__c=='Shipping' || a.Address_Validation__c=='VALID' || a.Type__c=='Remittance') && String.isNotBlank(a.EBS_Account_Id__c) && String.ValueOf(a.lastModifiedById).left(15)!='005K0000001A72T')
            {
                System.Debug(Logginglevel.FINER,'INTEGRATIONADDRESS.HANDLENEWADDRESSES - Address('+a.Id+', '+a.Name+') is valid. Attempting to add to queue.');
                newA.Add(a.Id);
            }
            else
                System.Debug(Logginglevel.FINER,'INTEGRATIONADDRESS.HANDLENEWADDRESSES - Address('+a.Id+', '+a.Name+') is not valid. Skipping');
        }
        if(!newA.isEmpty())
        {
            System.Debug(Logginglevel.FINER,'INTEGRATIONADDRESS.HANDLENEWADDRESSES - Adding '+newA.size()+' items to the queue.');
            addtoQueue(newA,'Create');
        }
    }
    
    public static void handleUpdatedAddresses(List<Address__c> aList,map<Id,Address__c> oldList)
    {
        System.Debug(Logginglevel.DEBUG,'INTEGRATIONADDRESS.HANDLEUPDATEDADDRESSES - Start');
        List<EBS_Integration__c> fieldList=[SELECT Name,Object__c,Field__c,Map_To__c,Map__c,Validate__c FROM EBS_Integration__c WHERE Object__c='Address__c' AND (Map__c=true OR Validate__c=true)];
        List<Id> updatedA=new List<Id>();
        List<Id> newA=new List<Id>();
        for(Address__c a:aList)
        {
            System.Debug(Logginglevel.FINER,'INTEGRATIONADDRESS.HANDLEUPDATEDADDRESSES - Testing '+a.Id+', '+a.Name);
            Address__c old=oldList.get(a.Id);
            
            //Stop syncing Shipping Addresses - Added on 10/04/2018
            //if(old!=null&&(a.Type__c=='Billing'||a.Type__c=='Shipping'||a.Type__c=='Remittance')&&(String.isNotBlank(a.EBS_Account_Id__c))) //a.EBS_Account_Id__c!=old.EBS_Account_Id__c &&||(String.ValueOf(a.lastModifiedById).left(15)!='005K0000001A72T'&&String.ValueOf(a.lastModifiedById).left(15)!='00517000000hMo3'))
           //shipping check added by Udita : P-004959
            if(old!=null && (a.Type__c=='Billing' ||a.Type__c=='Shipping' || (a.Is_EBS_Synced__c==true && a.Is_EBS_Synced__c!=old.Is_EBS_Synced__c) || a.Type__c=='Remittance') && (String.isNotBlank(a.EBS_Account_Id__c))) //a.EBS_Account_Id__c!=old.EBS_Account_Id__c &&||(String.ValueOf(a.lastModifiedById).left(15)!='005K0000001A72T'&&String.ValueOf(a.lastModifiedById).left(15)!='00517000000hMo3'))
            {
                Integer compare=IntegrationHelper.compare(a,old,fieldList);
                if(compare==1 || a.Type__c=='Shipping')
                {
                    System.Debug(Logginglevel.FINEST,'INTEGRATIONADDRESS.HANDLEUPDATEDADDRESSES - Changes detected. Adding '+a.Id+', '+a.Name+' to queue');
                    if(a.EBS_Site_Use_Id__c==null)
                        newA.Add(a.Id);
                    else
                        updatedA.Add(a.Id);
                }
                else if(compare==0)
                    System.Debug(Logginglevel.FINEST,'INTEGRATIONADDRESS.HANDLEUPDATEDADDRESSES - No changes detected for '+a.Id+', '+a.Name+'. skipping');
                else
                    System.Debug(Logginglevel.FINEST,'INTEGRATIONADDRESS.HANDLEUPDATEDADDRESSES - Error detecting changes for '+a.Id+', '+a.Name);
            }
            else if(old==null)
                System.Debug(Logginglevel.ERROR,'INTEGRATIONADDRESS.HANDLEUPDATEDADDRESSES - Unable to find old values for '+a.Id+', '+a.Name);
        }
        if(!updatedA.isEmpty())
        {
            System.Debug(Logginglevel.FINE,'INTEGRATIONADDRESS.HANDLEUPDATEDADDRESSES - Adding '+updatedA.size()+' updated addresses to queue.');
            addToQueue(updatedA, 'Update');
        }
        if(!newA.isEmpty())
        {
            System.Debug(Logginglevel.FINE,'INTEGRATIONADDRESS.HANDLEUPDATEDADDRESSES - Adding '+newA.size()+' new addresses to queue.');
            addToQueue(newA,'Create');
        }
    }

    public static void handleAddressUpdates(List<Address__c> aList,Map<Id,Address__c> oldMap)
    {
        /* NOT REQUIRED as with Address Edit override there always will be a valid country and state code. Same applies for autogenerated addresses which takes values from Account.
          
        System.Debug(Logginglevel.DEBUG,'INTEGRATIONADDRESS.HANDLECOUNTRYUPDATES - Start');
        for(Address__c a:aList)
        {
            Address__c old=oldMap.get(a.Id);
            if(a.Country__c!=null&&(old==null||a.Country__c!=old.Country__c))
            {
                CountryCodes__c tCode=IntegrationHelper.findCountry(a.Country__c);
                if(tCode!=null)
                    a.CountryCode__c=tCode.CountryCode__c;
            } 
            if(a.CountryCode__c=='CA'&&a.Province__c!=null&&(old==null||a.Province__c!=old.Province__c))
            {
                CAProvinceLookup__c tProvince=IntegrationHelper.findProvince(a.Province__c);
                if(tProvince!=null)
                {
                    a.ProvinceCode__c=tProvince.Code__c;
                    a.Province__c=tProvince.Name;
                }
            }
        }*/
    }

    public static void validationRestrictingPrimarySync(List<Address__c> newList,Map<Id,Address__c> oldMap)
    {
        Map<Id,Address__c> selectedAddresses = new Map<Id,Address__c>();
        Map<Id,Id> mapOfAccountIdsVsAddressIds = new Map<Id,Id>();
        for(Address__c addressInstance : newList)
        {
            if((oldMap == NULL || addressInstance.Primary_Sync__c != oldMap.get(addressInstance.Id).Primary_Sync__c) && addressInstance.Primary_Sync__c == TRUE)
            {
                selectedAddresses.put(addressInstance.Id,addressInstance);
                mapOfAccountIdsVsAddressIds.put(addressInstance.Account__c,addressInstance.Id);
            }
        }

        if(!mapOfAccountIdsVsAddressIds.isEmpty())
        {
            System.debug('Testing');
            for(Account acc : [select Id,(select Id,Name,Type__c,Primary_Sync__c from Additional_Addresses__r) from Account where Id IN :mapOfAccountIdsVsAddressIds.keySet()])
            {
                for(Address__c childAddress : acc.Additional_Addresses__r)
                {
                    if(selectedAddresses.get(mapOfAccountIdsVsAddressIds.get(acc.Id)).Type__c == childAddress.Type__c)
                    {
                        if(childAddress.Primary_Sync__c == TRUE)
                        {
                            selectedAddresses.get(mapOfAccountIdsVsAddressIds.get(acc.Id)).addError('There is already an address '+childAddress.Name+' of type '+childAddress.Type__c+' which is marked as Primary. Please mark that address as non-primary before marking any new address as Primary');
                            break;
                        }
                    }
                }
            }
        }

    }
    private static void addToQueue(List<Id> aList,String updateType)
    {
        addToQueue(aList, updateType, null);
    }
//    @future
    private static void addToQueue(List<Id> aList,String updateType, String ebsOrderSyncId)
    {
        System.debug('UserInfo.getFirstName() *** '+UserInfo.getFirstName() + '   ebsOrderSyncId: '+ebsOrderSyncId);
        if(UserInfo.getFirstName().equalsIgnoreCase('Cast Iron') && ebsOrderSyncId == null && updateType != null && !updateType.equalsIgnoreCase('Create')){
            /* Any time an account is synced; it is updated for an EBS ID using cast Iron integration user. At that time, Account Trigger would try to update 
             * Addresses and Contacts with the parent Account EBS Id. This check would effectively stop any sync on Addresses when they are updated for parent EBS Account Id.
             * If part of the Order Sync Framework, there will be a ebsOrderSyncId and it will sync.
             */
            return;
        }

        String qName='Address__c';
        System.Debug(Logginglevel.DEBUG,'INTEGRATIONADDRESS.ADDTOQUEUE - Start');
        System.Debug(Logginglevel.FINE,'INTEGRATIONADDRESS.ADDTOQUEUE - Building list of field mappings');
        List<EBS_Integration__c> fieldList=[SELECT Name,Object__c,Field__c,Map_To__c,Map__c,Validate__c FROM EBS_Integration__c WHERE Object__c='Address__c' AND Map__c=true];
        String queryString='SELECT ';
        for(EBS_Integration__c f:fieldList)
        {
            queryString+=f.Field__c+',';
        }
        if(queryString!='SELECT ')
        {
            Map<String,Integration_Queue__c> newList=new Map<String,Integration_Queue__c>();
            if(!queryString.contains(',name,'))
                queryString+='name,';
            queryString+='id FROM Address__c WHERE Id IN :aList';
            System.Debug(Logginglevel.FINE,'INTEGRATIONADDRESS.ADDTOQUEUE - Running query: '+queryString);
            for(Address__c a:Database.query(queryString)){
            }
            try
            {
                for(Address__c a:Database.query(queryString))
                {
                    System.Debug(Logginglevel.FINER,'INTEGRATIONADDRESS.ADDTOQUEUE - Adding address ('+a.Id+', '+a.Name+' to queue.');
                    Integration_Queue__c newItem=IntegrationHelper.mapToQueue(a,fieldList);
                    if(newItem!=null)
                    {
                        newItem.Queue__c=qName;
                        newItem.Status__c='Queued';
                        newItem.Object_ID__c=a.Id;
                        newItem.Type__c=updateType;
                        
                        if(ebsOrderSyncId != null){
                            System.Debug(Logginglevel.FINER,'INTEGRATIONADDRESS.ADDTOQUEUE - Related EBS Order Sync Process Id found '+ebsOrderSyncId);
                            newItem.EBS_Order_Sync_Process_Id__c = ebsOrderSyncId;    
                        }
                        
                        newList.Put(newItem.Object_Id__c,newItem);
                    }
                    else
                        System.Debug(Logginglevel.ERROR,'INTEGRATIONADDRESS.ADDTOQUEUE - Unable to map to queue.');
                }
            }
            catch(Exception e)
            {
                System.Debug(Logginglevel.ERROR,'INTEGRATIONADDRESS.ADDTOQUEUE - Error while attempting to run query! '+e.getMessage());
            }
            if(newList!=null)
            {
                IntegrationHelper.addToQueue(newList,fieldList,qName);
            }
        }
        else
            System.Debug(Logginglevel.ERROR,'INTEGRATIONADDRESS.ADDTOQUEUE - No field mappings for account found!');
    }
    
    webservice static void resyncAddress(String addressId) {
        System.Debug(Logginglevel.DEBUG,'INTEGRATIONADDRESS.resyncAddress - Start.');
        List<Id> newA=new List<Id>();
        newA.Add(addressId);
        System.Debug(Logginglevel.FINER,'INTEGRATIONADDRESS.resyncAddress - Adding '+newA.size()+' items to the queue.');
        addtoQueue(newA,'Create');
    }
    
    webservice static void resyncAddressForOrderSync(String addressId, String ebsOrderSyncId) {
        System.Debug(Logginglevel.DEBUG,'INTEGRATIONADDRESS.resyncAddressForOrderSync - Start.');
        List<Id> newA=new List<Id>();
        newA.Add(addressId);
        System.Debug(Logginglevel.FINER,'INTEGRATIONADDRESS.resyncAddressForOrderSync - Adding '+newA.size()+' items to the queue.');
        addtoQueue(newA,'Create', ebsOrderSyncId);
    }    
}