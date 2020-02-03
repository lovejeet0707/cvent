public class IntegrationAddressContact
{
    private static String qName='Address_Contact__c';

    public static void handleNewAddressContacts(List<Address_Contact__c> acList)
    {
        System.Debug(Logginglevel.DEBUG,'INTEGRATIONADDRESSCONTACTS.HANDLENEWADDRESSCONTACTS - Start.');
        List<Id> newAC=new List<Id>();
        System.Debug(Logginglevel.FINE,'INTEGRATIONADDRESSCONTACTS.HANDLENEWADDRESSCONTACTS - Checking for valid address contacts for queue.');
        for(Address_Contact__c ac:acList)
        {
            if(String.ValueOf(ac.lastModifiedById).left(15)!='005K0000001A72T' || String.ValueOf(ac.lastModifiedById).left(15)=='00517000000hMo3' || String.ValueOf(ac.lastModifiedById).left(15)=='005o0000001zMAm')
            {
                System.Debug(Logginglevel.FINER,'INTEGRATIONADDRESSCONTACTS.HANDLENEWADDRESSCONTACTS - Address Contact ('+ac+') is valid. Attempting to add to queue.');
                newAC.Add(ac.Id);
            }
            else
                System.Debug(Logginglevel.FINER,'INTEGRATIONADDRESSCONTACTS.HANDLENEWADDRESSCONTACTS - Address Contact ('+ac+') is not valid. Skipping');
        }
        if(!newAC.isEmpty())
        {
            System.Debug(Logginglevel.FINER,'INTEGRATIONADDRESSCONTACTS.HANDLENEWADDRESSCONTACTS - Adding '+newAC.size()+' items to the queue.');
            addtoQueue(newAC,'Create');
        }
    }

    public static void handleUpdatedAddressContactss(List<Address_Contact__c> acList,map<Id,Address_Contact__c> oldList)
    {
        System.Debug(Logginglevel.DEBUG,'INTEGRATIONADDRESSCONTACT.HANDLEUPDATEDADDRESSCONTACTS - Start');
        List<EBS_Integration__c> fieldList=[SELECT Name,Object__c,Field__c,Map_To__c,Map__c,Validate__c FROM EBS_Integration__c WHERE Object__c=:qName AND (Map__c=true OR Validate__c=true)];
        List<Id> updatedAC=new List<Id>();
        List<Id> newAC=new List<Id>();
        for(Address_Contact__c ac:acList)
        {
            System.Debug(Logginglevel.FINER,'INTEGRATIONADDRESSCONTACT.HANDLEUPDATEDADDRESSCONTACTS - Testing '+ac);
            Address_Contact__c old=oldList.get(ac.Id);
            if(old!=null&&String.ValueOf(ac.lastModifiedById).left(15)!='005K0000001A72T'&&String.ValueOf(ac.lastModifiedById).left(15)!='00517000000hMo3' && String.ValueOf(ac.lastModifiedById).left(15)!='005o0000001zMAm')
            {
                Integer compare=IntegrationHelper.compare(ac,old,fieldList);
                if(compare==1)
                {
                    System.Debug(Logginglevel.FINEST,'INTEGRATIONADDRESSCONTACT.HANDLEUPDATEDADDRESSCONTACTS - Changes detected. Adding '+ac+' to queue');
                    if(ac.EBS_Address_Contact_Id__c ==null)
                        newAC.Add(ac.Id);
                    else
                        updatedAC.Add(ac.Id);
                }
                else if(compare==0)
                    System.Debug(Logginglevel.FINEST,'INTEGRATIONADDRESSCONTACT.HANDLEUPDATEDADDRESSCONTACTS - No changes detected for '+ac+'. skipping');
                else
                    System.Debug(Logginglevel.FINEST,'INTEGRATIONADDRESSCONTACT.HANDLEUPDATEDADDRESSCONTACTS - Error detecting changes for '+ac);
            }
            else if(old==null)
                System.Debug(Logginglevel.ERROR,'INTEGRATIONADDRESSCONTACT.HANDLEUPDATEDADDRESSCONTACTS - Unable to find old values for '+ac);
        }
        if(!updatedAC.isEmpty())
        {
            System.Debug(Logginglevel.FINE,'INTEGRATIONADDRESSCONTACT.HANDLEUPDATEDADDRESSCONTACTS - Adding '+updatedAC.size()+' updated addresses to queue.');
            addToQueue(updatedAC, 'Update');
        }
        if(!newAC.isEmpty())
        {
            System.Debug(Logginglevel.FINE,'INTEGRATIONADDRESSCONTACT.HANDLEUPDATEDADDRESSCONTACTS - Adding '+newAC.size()+' new address contacts to queue.');
            addToQueue(newAC,'Create');
        }
    }

    public static void handleUpdatedContact(List<Id> cList)
    {
        System.Debug(Logginglevel.DEBUG,'INTEGRATIONADDRESSCONTACT>HANDLEUPDATEDCONTACT - Start');
        Map<Id,Address_Contact__c> acMap=new Map<Id,Address_Contact__c>([SELECT Id FROM Address_Contact__c WHERE Contact__c in :cList AND EBS_Address_Contact_Id__c <> NULL]);
        List<Id> acUpdateList=new List<Id>();
        acUPdateList.addAll(acMap.keySet());
        acMap=new Map<Id,Address_Contact__c>([SELECT Id FROM Address_Contact__c WHERE Contact__c in :cList AND EBS_Address_Contact_Id__c = NULL]);
        List<Id> acNewList=new List<Id>();
        acNewList.addAll(acMap.keySet());
        if(!acUpdateList.isEmpty())
        {
            addToQueue(acUpdateList,'Update');
        }
        if(!acNewList.isEmpty())
        {
            addToQueue(acNewList,'Create');
        }
        System.Debug(Logginglevel.DEBUG,'INTEGRATIONADDRESSCONTACT>HANDLEUPDATEDCONTACT - Finish');
    }
    
    private static void addToQueue(List<Id> acList,String updateType)
    {
        System.Debug(Logginglevel.DEBUG,'INTEGRATIONADDRESSCONTACT.ADDTOQUEUE - Start');
        System.Debug(Logginglevel.FINE,'INTEGRATIONADDRESSCONTACT.ADDTOQUEUE - Building list of field mappings');
        List<EBS_Integration__c> fieldList=[SELECT Name,Object__c,Field__c,Map_To__c,Map__c,Validate__c FROM EBS_Integration__c WHERE Object__c=:qName AND Map__c=true];
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
            queryString+='id FROM Address_Contact__c WHERE Id IN :acList';
            System.Debug(Logginglevel.FINE,'INTEGRATIONADDRESSCONTACT.ADDTOQUEUE - Running query: '+queryString);
            try
            {
                for(Address_Contact__c ac:Database.query(queryString))
                {
                    System.Debug(Logginglevel.FINER,'INTEGRATIONADDRESSCONTACT.ADDTOQUEUE - Adding address contact ('+ac+' to queue.');
                    Integration_Queue__c newItem=IntegrationHelper.mapToQueue(ac,fieldList);
                    if(newItem!=null)
                    {
                        newItem.Queue__c=qName;
                        newItem.Status__c='Queued';
                        newItem.Object_ID__c=ac.Id;
                        newItem.Type__c=updateType;
                        newList.Put(newItem.Object_Id__c,newItem);
                    }
                    else
                        System.Debug(Logginglevel.ERROR,'INTEGRATIONADDRESSCONTACT.ADDTOQUEUE - Unable to map to queue.');
                }
            }
            catch(Exception e)
            {
                System.Debug(Logginglevel.ERROR,'INTEGRATIONADDRESSCONTACT.ADDTOQUEUE - Error while attempting to run query! '+e.getMessage());
            }
            if(newList!=null)
            {
                IntegrationHelper.addToQueue(newList,fieldList,qName);
            }
        }
        else
            System.Debug(Logginglevel.ERROR,'INTEGRATIONADDRESSCONTACT.ADDTOQUEUE - No field mappings for address contact found!');
    }
}