global class IntegrationContact
{   
    public static void handleNewContacts(Map<Id,Contact> cMap)
    {
        System.Debug(Logginglevel.DEBUG,'INTEGRATIONCONTACT.HANDLENEWCONTACTS - Start.');
        List<Id> cList=new List<Id>();
        System.Debug(Logginglevel.FINE,'INTEGRATIONCONTACT.HANDLENEWCONTACTS - Checking for valid accounts for queue.');
        for(Contact c:cMap.Values())
        {
            if(String.isNotBlank(c.EBS_AccountId__c)) //String.ValueOf(c.lastModifiedById).left(15)!='005K0000001A72T'&&String.ValueOf(c.lastModifiedById).left(15)!='00517000000hMo3'&&
            {
                System.Debug(Logginglevel.FINER,'INTEGRATIONCONTACT.HANDLENEWCONTACTS - Contact('+c.Id+', '+c.Name+') is valid. Attempting to add to queue.');
                cList.Add(c.Id);
            }
            else
                System.Debug(Logginglevel.FINER,'INTEGRATIONCONTACT.HANDLENEWCONTACTS - Contact('+c.Id+', '+c.Name+') is not valid. Skipping');
        }
        if(!cList.isEmpty())
        {
            System.Debug(Logginglevel.FINER,'INTEGRATIONCONTACT.HANDLENEWCONTACTS - Adding '+cList.size()+' items to the queue.');
            addtoQueue(cList,'Create');
        }
    }
    
    public static void handleUpdatedContacts(List<Contact> cList,map<Id,Contact> oldList)
    {
        System.Debug(Logginglevel.DEBUG,'INTEGRATIONCONTACT.HANDLEUPDATEDCONTACTS - Start');
        List<EBS_Integration__c> fieldList=[SELECT Name,Object__c,Field__c,Map_To__c,Map__c,Validate__c FROM EBS_Integration__c WHERE Object__c='Contact' AND (Map__c=true OR Validate__c=true)];
        List<Id> updatedC=new List<Id>();
        List<Id> newC=new List<Id>();
        for(Contact c:cList)
        {
            System.Debug(Logginglevel.FINER,'INTEGRATIONCONTACT.HANDLEUPDATEDCONTACTS - Testing '+c.Id+', '+c.Name);
            Contact old=oldList.get(c.Id);
            if(!test.isRunningTest()){
            if(UserInfo.getFirstName().equalsIgnoreCase('Cast Iron') && (c.Creation_Source_System__c == null || !c.Creation_Source_System__c.startsWith('ROL'))){
                return;
            }
            }
            //||(String.ValueOf(c.lastModifiedById).left(15)!='005K0000001A72T'&&String.ValueOf(c.lastModifiedById).left(15)!='00517000000hMo3'))
            //||(old.EBS_AccountId__c!=null)) //&& ((String.ValueOf(c.lastModifiedById).left(15) == '00517000000hMo3') || (String.ValueOf(c.lastModifiedById).left(15) == '00517000000GfDc'))))  
            //old!=null && c.EBS_Account_Id__c != old.EBS_Account_Id__c 
            //Allow for ROL contacts and/or all contacts with a change in EBS Account Ids
            if(String.isNotBlank(c.EBS_AccountId__c))// || (c.Creation_Source_System__c != null && c.Creation_Source_System__c == 'ROL'))
            {
                Integer compare=IntegrationHelper.compare(c,old,fieldList);
                 System.Debug(Logginglevel.FINEST,'INTEGRATIONCONTACT.HANDLEUPDATEDCONTACTS - Testing ROL '+c.Id+', '+c.Name+'. Just before compare');
                
                if(compare==1)
                {
                    System.Debug(Logginglevel.FINEST,'INTEGRATIONCONTACT.HANDLEUPDATEDCONTACTS - Changes detected. Adding '+c.Id+', '+c.Name+' to queue');
                    if(c.EBS_Party_Id__c==null)
                        newC.Add(c.Id);
                    else
                        updatedC.Add(c.Id);
                }
                else if(compare==0)
                    System.Debug(Logginglevel.FINEST,'INTEGRATIONCONTACT.HANDLEUPDATEDCONTACTS - No changes detected for '+c.Id+', '+c.Name+'. skipping');
                else
                    System.Debug(Logginglevel.FINEST,'INTEGRATIONCONTACT.HANDLEUPDATEDCONTACTS - Error detecting changes for '+c.Id+', '+c.Name);
            }
            else if(old==null)
                System.Debug(Logginglevel.ERROR,'INTEGRATIONCONTACT.HANDLEUPDATEDCONTACTS - Unable to find old values for '+c.Id+', '+c.Name);
        }
        if(!updatedC.isEmpty())
        {
            System.Debug(Logginglevel.FINE,'INTEGRATIONCONTACT.HANDLEUPDATEDCONTACTS - Adding '+updatedC.size()+' updated contacts to queue.');
            addToQueue(updatedC, 'Update');
        }
        if(!newC.isEmpty())
        {
            System.Debug(Logginglevel.FINE,'INTEGRATIONCONTACT.HANDLEUPDATEDCONTACTS - Adding '+newC.size()+' new contacts to queue.');
            addToQueue(newC,'Create');
        }
    }
    
    public static void handleAddressUpdates(List<Contact> cList,Map<Id,Contact> oldMap)
    {
        System.Debug(Logginglevel.DEBUG,'INTEGRATIONCONTACT.HANDLECOUNTRYUPDATES - NO ACTION REQUIRED - Moved to Standard Country and State Picklists');
    }
    
//    @future
    private static void addToQueue(List<Id> cList,String updateType, String ebsOrderSyncId)
    {
        System.debug('UserInfo.getFirstName() *** '+UserInfo.getFirstName());
        /*if(UserInfo.getFirstName().equalsIgnoreCase('Cast Iron') && ebsOrderSyncId == null){
            return;
        }*/
        
        String qName='Contact';
        System.Debug(Logginglevel.DEBUG,'INTEGRATIONCONTACT.ADDTOQUEUE - Start');
        System.Debug(Logginglevel.FINE,'INTEGRATIONCONTACT.ADDTOQUEUE - Building list of field mappings');
        List<EBS_Integration__c> fieldList=[SELECT Name,Object__c,Field__c,Map_To__c,Map__c,Validate__c FROM EBS_Integration__c WHERE Object__c='Contact' AND Map__c=true];
        String queryString='SELECT ';
        for(EBS_Integration__c f:fieldList)
        {
            queryString+=f.Field__c+',';
        }
        if(queryString!='SELECT ')
        {
            Map<String,Integration_Queue__c> newList=new Map<String,Integration_Queue__c>();
            queryString+='id FROM Contact WHERE Id IN :cList';
            System.Debug(Logginglevel.FINE,'INTEGRATIONCONTACT.ADDTOQUEUE - Running query: '+queryString);
            try
            {
                for(Contact c:Database.query(queryString))
                {
                    System.Debug(Logginglevel.FINER,'INTEGRATIONCONTACT.ADDTOQUEUE - Adding account ('+c.Id+', '+c.Name+' to queue.');
                    Integration_Queue__c newItem=IntegrationHelper.mapToQueue(c,fieldList);
                    if(newItem!=null)
                    {
                        newItem.Queue__c=qName;
                        newItem.Status__c='Queued';
                        newItem.Object_ID__c=c.Id;
                        newItem.Type__c=updateType;
                        if(ebsOrderSyncId != null){
                            System.Debug(Logginglevel.FINER,'INTEGRATIONADDRESS.ADDTOQUEUE - Related EBS Order Sync Process Id found '+ebsOrderSyncId);
                            newItem.EBS_Order_Sync_Process_Id__c = ebsOrderSyncId;    
                        }                        
                        newList.Put(newItem.Object_Id__c,newItem);
                    }
                    else
                        System.Debug(Logginglevel.ERROR,'INTEGRATIONCONTACT.ADDTOQUEUE - Unable to map to queue.');
                }
            }
            catch(Exception e)
            {
                System.Debug(Logginglevel.ERROR,'INTEGRATIONCONTACT.ADDTOQUEUE - Error while attempting to run query! '+e.getMessage());
            }
            if(newList!=null)
            {
                IntegrationHelper.addToQueue(newList,fieldList,qName);
            }
        }
        else
            System.Debug(Logginglevel.ERROR,'INTEGRATIONCONTACT.ADDTOQUEUE - No field mappings for account found!');
    }

    private static void addToQueue(List<Id> aList,String updateType)
    {
        addToQueue(aList, updateType, null);
    }
        
    webservice static void resyncContactForOrderSync(String conId, String ebsOrderSyncId) {
        System.Debug(Logginglevel.DEBUG,'INTEGRATIONCONTACT.resyncContactForOrderSync - Start.');
        List<Id> cList=new List<Id>();
        cList.Add(conId);
        System.Debug(Logginglevel.FINER,'INTEGRATIONCONTACT.resyncContactForOrderSync - Adding '+cList.size()+' items to the queue.');
        addtoQueue(cList,'Create', ebsOrderSyncId);
    }  
    
    webservice static void resyncContact(String conId) {
        System.Debug(Logginglevel.DEBUG,'INTEGRATIONCONTACT.resyncContact - Start.');
        List<Id> cList=new List<Id>();
        cList.Add(conId);
        System.Debug(Logginglevel.FINER,'INTEGRATIONCONTACT.resyncContact - Adding '+cList.size()+' items to the queue.');
        addtoQueue(cList,'Create');
    }
}