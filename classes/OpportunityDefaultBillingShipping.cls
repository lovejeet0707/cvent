public class OpportunityDefaultBillingShipping
{
    public static void UpdateOppBillingShipping(List<Opportunity> newOpp)
    {
        System.Debug(Logginglevel.DEBUG,'OPPORTUNITYDEEFAULTBILLINGSHIPPING.UpdateOppBillingShipping - START');
        Map<Id,Id> aList=new Map<Id,Id>();
        for(Opportunity o:newOpp)
        {
            if(!aList.containsKey(o.AccountId)&&o.AccountId<>null)
            {
                aList.Put(o.AccountId,o.AccountId);
            }
        }
        System.Debug(Logginglevel.DEBUG,'OPPORTUNITYDEFAULTBILLINGSHIPPING.UpdateOppBillingShipping - Account list:'+aList);
        System.Debug(logginglevel.DEBUG,'OPPORTUNITYDEFAULTBILLINGSHIPPING.UpdateOppBillingShipping - If(!aList.isEmpty()):'+!aList.isEmpty());
        if(!aList.isEmpty())
        {
        System.Debug(Logginglevel.DEBUG,'OPPORTUNITYDEFAULTBILLINGSHIPPING.UpdateOppBillingShipping - List of related account: '+aList);
        /*List<Contact> cList=[SELECT Id,AccountId,EBS_Contact_Id__c,EBS_Party_ID__c FROM Contact WHERE AccountId in :aList.keySet() AND EBS_Party_ID__c != NULL ORDER BY lastModifiedDate DESC];
        System.Debug(Logginglevel.DEBUG,'OPPORTUNITYDEFAULTBILLINGSHIPPING.UpdateOppBillingShipping - List of related contacts: '+cList); */
        List<Address__c> adList=[SELECT Id,Account__c,EBS_Site_Use_ID__c,Type__c,Operating_Unit_Name__c FROM Address__c WHERE Account__c in :aList.keySet() AND Primary_Sync__c = true];
        System.Debug(Logginglevel.DEBUG,'OPPORTUNITYDEFAULTBILLINGSHIPPING.UpdateOppBillingShipping - List of related addresses: '+adList);
        /*Map<Id,Contact> cMap=new Map<Id,Contact>();
        for(Contact c:cList)
        {
            if(!cMap.containsKey(c.AccountId))
            {
                cMap.Put(c.AccountId,c);
            }
        }*/
        Map<String,Address__c> adMap=new Map<String,Address__c>();
        for(Address__c ad:AdList)
        {
            if(!adMap.containsKey(ad.Account__c+ad.Type__c))
            {
                adMap.Put(ad.Account__c+ad.Type__c,ad);
            }
        }
        for(Opportunity o:newOpp)
        {
              //String opCode='86';
            /*
            if(o.CurrencyIsoCode=='CAD')
            {
                opCode='97';
            }
            */
            if(o.Bill_To_Address__c==null)
            {
                system.debug('obillAddress--'+o.Bill_To_Address__c);
                system.debug('accountID+billing '+o.AccountId+'Billing');
                Address__c billAd=adMap.Get(o.AccountId+'Billing');
                system.debug('billAd--'+billAd);
                if(billAd!=NULL)
                {
                    o.Bill_To_Address__c=billAd.Id;
                }
            }
            if(o.Bill_To_Contact__c==null)
            {
                o.Bill_To_Contact__c = o.Contact_Associated__c;
                /*Contact billCon=cMap.Get(o.AccountId);
                if(billCon!=NULL)
                {
                    o.Bill_To_Contact__c=billCon.Id;
                }*/
            }
            if(o.Ship_To_Address__c==null)
            {
                Address__c shipAd=adMap.Get(o.AccountId+'Shipping');
                if(shipAd!=NULL)
                {
                    o.Ship_To_Address__c=shipAd.Id;
                }
            }
            if(o.Ship_To_Contact__c==null)
            {
                o.Ship_To_Contact__c = o.Contact_Associated__c;
                /*Contact shipCon=cMap.Get(o.AccountId);
                if(shipCon!=NULL)
                {
                    o.Ship_To_Contact__c=shipCon.Id;
                }*/
            }
            
        }
        }
        System.Debug(Logginglevel.DEBUG,'OPPORTUNITYDEEFAULTBILLINGSHIPPING.UpdateOppBillingShipping - END');
    }
}