/**
//////////////////////////////////////
//      @author Abhishek Pandey     //
/////////////////////////////////////
Version :   1.0
Date : 6th Jan 2015
Description : To CurrencyIsoCode in on creation of record from parent opp. 
 */
public class InvoicingLIIrgHelperCls{
    
    public void OnBeforeInsert(List<Invoicing_Line_Items__c> newValues){
        Set<Id> setInvLI = new Set<Id>();
         
        for(Invoicing_Line_Items__c instOfFeature : newValues){
            if(instOfFeature.Invoicing_Details__c != null)
            setInvLI.add(instOfFeature.Invoicing_Details__c);
        }
        
        map<Id,Invoicing_Details__c> mapInvoicingDet = new map<Id,Invoicing_Details__c>();
        
        if(setInvLI.size() > 0)
        mapInvoicingDet = new map<Id,Invoicing_Details__c>([SELECT CreatedDate,Opportunity__r.CurrencyIsoCode,Opportunity__r.Exchange_Rate__c FROM Invoicing_Details__c WHERE Id=: setInvLI And Opportunity__r.CurrencyIsoCode != null]);
        
        for(Invoicing_Line_Items__c instInvLI : newValues){
            if(mapInvoicingDet.ContainsKey(instInvLI.Invoicing_Details__c)){
                if(mapInvoicingDet.get(instInvLI.Invoicing_Details__c).Opportunity__r.CurrencyIsoCode != null)
                instInvLI.CurrencyIsoCode = mapInvoicingDet.get(instInvLI.Invoicing_Details__c).Opportunity__r.CurrencyIsoCode;
                if(mapInvoicingDet.get(instInvLI.Invoicing_Details__c).Opportunity__r.Exchange_Rate__c != null)
                instInvLI.Exchange_Rate__c = mapInvoicingDet.get(instInvLI.Invoicing_Details__c).Opportunity__r.Exchange_Rate__c;
            }
        }
    }
    public void OnAfterInsert(Map<Id,Invoicing_Line_Items__c> newMapValues){
        
    }
    public void OnBeforeUpdate(Map<Id,Invoicing_Line_Items__c> oldMapValues,Map<Id,Invoicing_Line_Items__c> newMapValues){
        
    }
    public void OnAfterUpdate(Map<Id,Invoicing_Line_Items__c> oldMapValues,Map<Id,Invoicing_Line_Items__c> newMapValues){
        
    }
    public void OnBeforeDelete(List<Invoicing_Line_Items__c> oldValues,Map<Id,Invoicing_Line_Items__c> oldMapValues){        
        
    }
    public void OnAfterDelete(List<Invoicing_Line_Items__c> oldValues,Map<Id,Invoicing_Line_Items__c> oldMapValues){
        
    }
    public void OnUndelete(List<Invoicing_Line_Items__c> newValues){
        
    }
}