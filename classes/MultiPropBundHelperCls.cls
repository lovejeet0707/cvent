/**
//////////////////////////////////////
//      @author Abhishek Pandey     //
/////////////////////////////////////
Version :   1.0
Date : 6th Jan 2015
Description : To update field Milestone Check on feature creation and updation. 
 */
public class MultiPropBundHelperCls {
    
    public void OnBeforeInsert(List<Multi_Property_Bundles__c> newValues){
        Set<Id> setOppId = new Set<Id>();
         
        for(Multi_Property_Bundles__c instOfFeature : newValues){
            if(instOfFeature.Opportunity__c != null)
            setOppId.add(instOfFeature.Opportunity__c);
        }
        
        map<Id,Opportunity> maplstOpp = new map<Id,Opportunity>();
        
        if(setOppId.size()>0)
        maplstOpp = new map<Id,Opportunity>([SELECT ID,CurrencyIsoCode,Exchange_Rate__c FROM Opportunity WHERE Id =: setOppId]);
        for(Multi_Property_Bundles__c instOfFeature : newValues){
            if(maplstOpp.containsKey(instOfFeature.Opportunity__c)){
                instOfFeature.CurrencyIsoCode = maplstOpp.get(instOfFeature.Opportunity__c).CurrencyIsoCode;
                instOfFeature.Exchange_Rate__c = maplstOpp.get(instOfFeature.Opportunity__c).Exchange_Rate__c;
            }
        }
    }
    public void OnAfterInsert(Map<Id,Multi_Property_Bundles__c> newMapValues){
        
    }
    public void OnBeforeUpdate(Map<Id,Multi_Property_Bundles__c> oldMapValues,Map<Id,Multi_Property_Bundles__c> newMapValues){
        
    }
    public void OnAfterUpdate(Map<Id,Multi_Property_Bundles__c> oldMapValues,Map<Id,Multi_Property_Bundles__c> newMapValues){
        
    }
    public void OnBeforeDelete(List<Multi_Property_Bundles__c> oldValues,Map<Id,Multi_Property_Bundles__c> oldMapValues){        
        
    }
    public void OnAfterDelete(List<Multi_Property_Bundles__c> oldValues,Map<Id,Multi_Property_Bundles__c> oldMapValues){
        
    }
    public void OnUndelete(List<Multi_Property_Bundles__c> newValues){
        
    }
}