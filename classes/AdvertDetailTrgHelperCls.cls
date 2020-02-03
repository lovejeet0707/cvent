/*
//////////////////////////////////////
//      @author Abhishek Pandey     //
/////////////////////////////////////
Version :   1.0
Date : 20th Nov 2014
Description : To update the parent account field Adv_w_Competitor__c by collating all child of Advertiser_Detail__c with fields Competitor_Name__c and  Advertised_in_Year__c
*/
public class AdvertDetailTrgHelperCls{
    public void OnBeforeInsert(List<Advertiser_Detail__c> newValues){
        
    }
    public void OnAfterInsert(Map<Id,Advertiser_Detail__c> newMapValues){
        RecordType instRecType = [SELECT ID FROM RecordType WHERE SobjectType= 'Advertiser_Detail__c' AND DeveloperName = 'Advertised_with_Competitor' AND IsActive= true LIMIT 1];
        map<Id,String> mapAccIdStr = new map<Id,String>();
        for(Advertiser_Detail__c instOfAdtDet : newMapValues.values()){
            if(instOfAdtDet.RecordTypeId == instRecType.Id){
                if(instOfAdtDet.Advertised_in_Year__c !=null && instOfAdtDet.Competitor_Name__c != null){
                    if(mapAccIdStr.containsKey(instOfAdtDet.Supplier_Account__c)){
                        String str = '' ; 
                        str = mapAccIdStr.get(instOfAdtDet.Supplier_Account__c);
                        str = str + instOfAdtDet.Competitor_Name__c + '(' + instOfAdtDet.Advertised_in_Year__c + ');';
                        mapAccIdStr.put(instOfAdtDet.Supplier_Account__c,str);
                    }else{
                        String str = '';
                        str = instOfAdtDet.Competitor_Name__c + '(' + instOfAdtDet.Advertised_in_Year__c + ');';
                        mapAccIdStr.put(instOfAdtDet.Supplier_Account__c,str);
                    }
                }
            }
        }
        
        List<Account> lstAccount = new List<Account>();
        if(mapAccIdStr.size()>0)
        lstAccount = [SELECT Id,Adv_w_Competitor__c FROM Account WHERE Id =: mapAccIdStr.KeySet()];
        
        List<Account> lstAccountSec = new List<Account>();
        
        for(Account instOfAcc : lstAccount){
            String str ='';
            str = mapAccIdStr.get(instOfAcc.Id);
            if(instOfAcc.Adv_w_Competitor__c == null){
                instOfAcc.Adv_w_Competitor__c =  str;
            }else{
                instOfAcc.Adv_w_Competitor__c = instOfAcc.Adv_w_Competitor__c + str;
            }
            lstAccountSec.add(instOfAcc);
        }
        
        if(lstAccountSec.size()>0)
        update lstAccountSec;
    }
    public void OnBeforeUpdate(Map<Id,Advertiser_Detail__c> oldMapValues,Map<Id,Advertiser_Detail__c> newMapValues){
        
    }
    public void OnAfterUpdate(Map<Id,Advertiser_Detail__c> oldMapValues,Map<Id,Advertiser_Detail__c> newMapValues){
        map<Id,Advertiser_Detail__c> mapAccIdStr = new map<Id,Advertiser_Detail__c>();
        RecordType instRecType = [SELECT ID FROM RecordType WHERE SobjectType= 'Advertiser_Detail__c' AND DeveloperName = 'Advertised_with_Competitor' AND IsActive= true LIMIT 1];
        
        for(Advertiser_Detail__c instOfAdvetDet : newMapValues.values()){
            if(instRecType.Id == instOfAdvetDet.RecordTypeId){
                //if(instOfAdvetDet.Competitor_Name__c != oldMapValues.get(instOfAdvetDet.id).Competitor_Name__c || instOfAdvetDet.Advertised_in_Year__c != oldMapValues.get(instOfAdvetDet.id).Advertised_in_Year__c){
                    mapAccIdStr.put(instOfAdvetDet.Supplier_Account__c,instOfAdvetDet);
                //}
            }
        }
        List<Account> lstAccount = new List<Account>();
        if(mapAccIdStr.KeySet().size()>0)
        lstAccount = [SELECT Id,Adv_w_Competitor__c,(SELECT Id,Competitor_Name__c,Advertised_in_Year__c FROM Advertiser_Details__r WHERE Competitor_Name__c != null AND Advertised_in_Year__c != null) FROM Account WHERE Id =: mapAccIdStr.Keyset()];
        
        
        List<Account> lstAccountSec = new List<Account>();
        for(Account instOfAcc : lstAccount){
            String str = '';
            for(Advertiser_Detail__c instOfAdvetDet : instOfAcc.Advertiser_Details__r){
                str = str + instOfAdvetDet.Competitor_Name__c + '(' + instOfAdvetDet.Advertised_in_Year__c + ');';
            }
            instOfAcc.Adv_w_Competitor__c = str; 
            
            lstAccountSec.add(instOfAcc);
        }
        
        if(lstAccountSec.size()>0)
        update lstAccountSec;
    }
    public void OnBeforeDelete(List<Advertiser_Detail__c> oldValues,Map<Id,Advertiser_Detail__c> oldMapValues){        
        
    }
    public void OnAfterDelete(List<Advertiser_Detail__c> oldValues,Map<Id,Advertiser_Detail__c> oldMapValues){
        map<Id,Advertiser_Detail__c> mapAccIdStr = new map<Id,Advertiser_Detail__c>();
        RecordType instRecType = [SELECT ID FROM RecordType WHERE SobjectType= 'Advertiser_Detail__c' AND DeveloperName = 'Advertised_with_Competitor' AND IsActive= true LIMIT 1];
        
        for(Advertiser_Detail__c instOfAdvetDet : oldMapValues.values()){
            if(instRecType.Id == instOfAdvetDet.RecordTypeId){
                mapAccIdStr.put(instOfAdvetDet.Supplier_Account__c,instOfAdvetDet);
            }
        }
        
        List<Account> lstAccount = new List<Account>();
        if(mapAccIdStr.KeySet().size()>0)
        lstAccount = [SELECT Id,Adv_w_Competitor__c,(SELECT Id,Competitor_Name__c,Advertised_in_Year__c FROM Advertiser_Details__r WHERE Competitor_Name__c != null AND Advertised_in_Year__c != null) FROM Account WHERE Id =: mapAccIdStr.Keyset()];
        
        
        List<Account> lstAccountSec = new List<Account>();
        for(Account instOfAcc : lstAccount){
            String str = '';
            for(Advertiser_Detail__c instOfAdvetDet : instOfAcc.Advertiser_Details__r){
                str = str + instOfAdvetDet.Competitor_Name__c + '(' + instOfAdvetDet.Advertised_in_Year__c + ');';
            }
            instOfAcc.Adv_w_Competitor__c = str; 
            
            lstAccountSec.add(instOfAcc);
        }
        
        if(lstAccountSec.size()>0)
        update lstAccountSec;
    }
    public void OnUndelete(List<Advertiser_Detail__c> newValues){
        
    }
}