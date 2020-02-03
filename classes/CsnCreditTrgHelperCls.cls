/**
//////////////////////////////////////
//      @author Abhishek Pandey     //
/////////////////////////////////////
Version :   1.0
Date : 6th Jan 2015
Description : To update CurrencyIso Code on creation
 */
public class CsnCreditTrgHelperCls{
    
    public void OnBeforeInsert(List<CSN_Credit__c> newValues){
        Set<Id> setOppId = new Set<Id>();
        for(CSN_Credit__c instOfFeature : newValues){
            if(instOfFeature.Opportunity__c != null)
            setOppId.add(instOfFeature.Opportunity__c);
        }
        
        map<Id,Opportunity> maplstOpp = new map<Id,Opportunity>();
        
        if(setOppId.size()>0)
        maplstOpp = new map<Id,Opportunity>([SELECT ID,CurrencyIsoCode,Exchange_Rate__c FROM Opportunity WHERE Id =: setOppId]);
        for(CSN_Credit__c instOfFeature : newValues){
            if(maplstOpp.containsKey(instOfFeature.Opportunity__c)){
                instOfFeature.CurrencyIsoCode = maplstOpp.get(instOfFeature.Opportunity__c).CurrencyIsoCode;
                instOfFeature.Exchange_Rate__c = maplstOpp.get(instOfFeature.Opportunity__c).Exchange_Rate__c;
            }
        }
    }
    public void OnAfterInsert(Map<Id,CSN_Credit__c> newMapValues){
        
    }
    public void OnBeforeUpdate(Map<Id,CSN_Credit__c> oldMapValues,Map<Id,CSN_Credit__c> newMapValues){
        
    }
    public void OnAfterUpdate(Map<Id,CSN_Credit__c> oldMapValues,Map<Id,CSN_Credit__c> newMapValues){
        
    }
    public void OnBeforeDelete(List<CSN_Credit__c> oldValues,Map<Id,CSN_Credit__c> oldMapValues){        
        
    }
    public void OnAfterDelete(List<CSN_Credit__c> oldValues,Map<Id,CSN_Credit__c> oldMapValues){
        
    }
    public void OnUndelete(List<CSN_Credit__c> newValues){
        
    }
}