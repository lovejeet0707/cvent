public class ContactRoleTriggerHelper 
{
	public static void onAfterInsert(Map<Id,Contact_Role__c> newMap)
    {
        Map<Id,Contact_Role__c> contactsVSContactRole = new Map<Id,Contact_Role__c>();
        for(Contact_Role__c conRole : newMap.values())
        {
            if(conRole.Contact__c != NULL)
            {
                contactsVSContactRole.put(conRole.Contact__c,conRole);
            }
        }
        
        Map<Id,Higher_Logic__c> mapOfContactIdVSHigherLogic = new Map<Id,Higher_Logic__c>();
        List<Higher_Logic__c> listOfHigherLogic = new List<Higher_Logic__c>();
        Map<Id,Contact> mapOfContacts = new Map<Id,Contact>();
        for(Contact con : [select Higher_Logic__c,Higher_Logic__r.Customer_User_Sub_Role__c,Higher_Logic__r.Buyer_Decision_Maker__c,Higher_Logic__r.Buyer_Executive_Sponsor__c,Higher_Logic__r.Buyer_Influencer__c,Higher_Logic__r.Customer_Advocate__c,Higher_Logic__r.Customer_Billing__c,Higher_Logic__r.Customer_User__c,Higher_Logic__r.Customer_User_Status__c from Contact where ID IN :contactsVSContactRole.keySet()])
        {
            Id buyerRoleRecordTypeId = Schema.SObjectType.Contact_Role__c.getRecordTypeInfosByDeveloperName().get('Buyer_Role').getRecordTypeId();
            if(con.Higher_Logic__c != NULL)
            {
                Higher_Logic__c higherLogicRecord = new Higher_Logic__c(Id = con.Higher_Logic__c);
                System.debug('contactsVSContactRole.get(con.Id).RecordTypeId>>'+contactsVSContactRole.get(con.Id).RecordTypeId);
                if(contactsVSContactRole.get(con.Id).RecordTypeId == buyerRoleRecordTypeId)
                {
                    if(con.Higher_Logic__r.Buyer_Decision_Maker__c == FALSE)
                    {
                        higherLogicRecord.Buyer_Decision_Maker__c = contactsVSContactRole.get(con.Id).Decision_Maker__c;
                    }
                    if(con.Higher_Logic__r.Buyer_Executive_Sponsor__c == FALSE)
                    {
                        higherLogicRecord.Buyer_Executive_Sponsor__c = contactsVSContactRole.get(con.Id).Executive_Sponsor__c;
                    }
                    if(con.Higher_Logic__r.Buyer_Influencer__c == FALSE)
                    {
                        higherLogicRecord.Buyer_Influencer__c = contactsVSContactRole.get(con.Id).Influencer__c;
                    }
                }
                else
                {
                    if(con.Higher_Logic__r.Customer_Advocate__c == FALSE)
                    {
                        higherLogicRecord.Customer_Advocate__c = contactsVSContactRole.get(con.Id).Advocate__c;
                    }
                    if(con.Higher_Logic__r.Customer_Billing__c == FALSE)
                    {
                        higherLogicRecord.Customer_Billing__c = contactsVSContactRole.get(con.Id).Billing__c;
                    }
                    if(con.Higher_Logic__r.Customer_User__c == FALSE)
                    {
                        higherLogicRecord.Customer_User__c = contactsVSContactRole.get(con.Id).User__c;
                    }
                    if(String.isBlank(con.Higher_Logic__r.Customer_User_Status__c))
                    {
                        higherLogicRecord.Customer_User_Status__c = contactsVSContactRole.get(con.Id).User_Status__c;
                    }	
                    if(String.isBlank(con.Higher_Logic__r.Customer_User_Sub_Role__c))
                    {
                        higherLogicRecord.Customer_User_Sub_Role__c = contactsVSContactRole.get(con.Id).User_Sub_Role__c;
                    }
                }
                listOfHigherLogic.add(higherLogicRecord);
            }
            else
            {
                Higher_Logic__c higherLogicRec = new Higher_Logic__c();
                mapOfContacts.put(con.Id,con);
                if(contactsVSContactRole.get(con.Id).RecordTypeId == buyerRoleRecordTypeId)
                {
                    higherLogicRec.Buyer_Decision_Maker__c = contactsVSContactRole.get(con.Id).Decision_Maker__c;
                    higherLogicRec.Buyer_Executive_Sponsor__c = contactsVSContactRole.get(con.Id).Executive_Sponsor__c;
                    higherLogicRec.Buyer_Influencer__c = contactsVSContactRole.get(con.Id).Influencer__c;
                }
                else
                {
                    higherLogicRec.Customer_Advocate__c = contactsVSContactRole.get(con.Id).Advocate__c;
                    higherLogicRec.Customer_Billing__c = contactsVSContactRole.get(con.Id).Billing__c;
                    higherLogicRec.Customer_User__c = contactsVSContactRole.get(con.Id).User__c;
                    higherLogicRec.Customer_User_Status__c = contactsVSContactRole.get(con.Id).User_Status__c;
                    higherLogicRec.Customer_User_Sub_Role__c = contactsVSContactRole.get(con.Id).User_Sub_Role__c;
                }
                mapOfContactIdVSHigherLogic.put(con.Id,higherLogicRec);
            }
        }
        
        if(!mapOfContactIdVSHigherLogic.isEmpty())
        {
            insert mapOfContactIdVSHigherLogic.values();
        }
        
        if(!listOfHigherLogic.isEmpty())
        {
            update listOfHigherLogic;
        }
        
        for(Id conId : mapOfContactIdVSHigherLogic.keySet())
        {
            mapOfContacts.get(conId).Higher_Logic__c = mapOfContactIdVSHigherLogic.get(conId).Id;
        }
        
        if(!mapOfContacts.isEmpty())
        {
            update mapOfContacts.values();
        }
    }
    
    public static void onAfterUpdate(Map<Id,Contact_Role__c> oldMap, Map<Id,Contact_Role__c> newMap)
    {
        Map<Id,Contact_Role__c> contactsVSContactRole = new Map<Id,Contact_Role__c>();
        for(Contact_Role__c conRole : newMap.values())
        {
            if(conRole.Contact__c != NULL && (oldMap.get(conRole.Id).Decision_Maker__c != conRole.Decision_Maker__c || oldMap.get(conRole.Id).Executive_Sponsor__c != conRole.Executive_Sponsor__c || oldMap.get(conRole.Id).Influencer__c != conRole.Influencer__c || oldMap.get(conRole.Id).Advocate__c != conRole.Advocate__c || oldMap.get(conRole.Id).Billing__c != conRole.Billing__c || oldMap.get(conRole.Id).User__c != conRole.User__c || oldMap.get(conRole.Id).User_Status__c != conRole.User_Status__c || oldMap.get(conRole.Id).User_Sub_Role__c != conRole.User_Sub_Role__c))
            {
                contactsVSContactRole.put(conRole.Contact__c,conRole);
            }
        }
        List<Higher_Logic__c> listOfHigherLogic = new List<Higher_Logic__c>();
        Map<Id,Contact> mapOfContacts = new Map<Id,Contact>();
        Map<Id,Higher_Logic__c> mapOfContactIdVSHigherLogic = new Map<Id,Higher_Logic__c>();
        for(Contact con : [select Higher_Logic__c,Higher_Logic__r.Buyer_Decision_Maker__c,Higher_Logic__r.Buyer_Executive_Sponsor__c,Higher_Logic__r.Buyer_Influencer__c,Higher_Logic__r.Customer_Advocate__c,Higher_Logic__r.Customer_Billing__c,Higher_Logic__r.Customer_User__c,Higher_Logic__r.Customer_User_Status__c from Contact where ID IN :contactsVSContactRole.keySet()])
        {
            Id buyerRoleRecordTypeId = Schema.SObjectType.Contact_Role__c.getRecordTypeInfosByDeveloperName().get('Buyer_Role').getRecordTypeId();
            if(con.Higher_Logic__c != NULL)
            {
                Higher_Logic__c higherLogicRecord = new Higher_Logic__c(Id = con.Higher_Logic__c);
                
                if(contactsVSContactRole.get(con.Id).RecordTypeId == buyerRoleRecordTypeId)
                {
                    higherLogicRecord.Buyer_Decision_Maker__c = contactsVSContactRole.get(con.Id).Decision_Maker__c;
                    higherLogicRecord.Buyer_Executive_Sponsor__c = contactsVSContactRole.get(con.Id).Executive_Sponsor__c;
                    higherLogicRecord.Buyer_Influencer__c = contactsVSContactRole.get(con.Id).Influencer__c;
                }
                else
                {
                    higherLogicRecord.Customer_Advocate__c = contactsVSContactRole.get(con.Id).Advocate__c;
                    higherLogicRecord.Customer_Billing__c = contactsVSContactRole.get(con.Id).Billing__c;
                    higherLogicRecord.Customer_User__c = contactsVSContactRole.get(con.Id).User__c;
                    higherLogicRecord.Customer_User_Status__c = contactsVSContactRole.get(con.Id).User_Status__c;
                    higherLogicRecord.Customer_User_Sub_Role__c = contactsVSContactRole.get(con.Id).User_Sub_Role__c;
                 }
                listOfHigherLogic.add(higherLogicRecord);
            }
            else
            {
                Higher_Logic__c higherLogicRec = new Higher_Logic__c();
                mapOfContacts.put(con.Id,con);
                if(contactsVSContactRole.get(con.Id).RecordTypeId == buyerRoleRecordTypeId)
                {
                    higherLogicRec.Buyer_Decision_Maker__c = contactsVSContactRole.get(con.Id).Decision_Maker__c;
                    higherLogicRec.Buyer_Executive_Sponsor__c = contactsVSContactRole.get(con.Id).Executive_Sponsor__c;
                    higherLogicRec.Buyer_Influencer__c = contactsVSContactRole.get(con.Id).Influencer__c;
                }
                else
                {
                    higherLogicRec.Customer_Advocate__c = contactsVSContactRole.get(con.Id).Advocate__c;
                    higherLogicRec.Customer_Billing__c = contactsVSContactRole.get(con.Id).Billing__c;
                    higherLogicRec.Customer_User__c = contactsVSContactRole.get(con.Id).User__c;
                    higherLogicRec.Customer_User_Status__c = contactsVSContactRole.get(con.Id).User_Status__c;
                    higherLogicRec.Customer_User_Sub_Role__c = contactsVSContactRole.get(con.Id).User_Sub_Role__c;
                }
                mapOfContactIdVSHigherLogic.put(con.Id,higherLogicRec);
            }
        }
        
        if(!mapOfContactIdVSHigherLogic.isEmpty())
        {
            insert mapOfContactIdVSHigherLogic.values();
        }
        
        if(!listOfHigherLogic.isEmpty())
        {
            update listOfHigherLogic;
        }
        
        for(Id conId : mapOfContactIdVSHigherLogic.keySet())
        {
            mapOfContacts.get(conId).Higher_Logic__c = mapOfContactIdVSHigherLogic.get(conId).Id;
        }
        
        if(!mapOfContacts.isEmpty())
        {
            update mapOfContacts.values();
        }
    }
}