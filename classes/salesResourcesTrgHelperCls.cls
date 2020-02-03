/**
///////////////////////////////
//    @author Rohit Saxena    //
///////////////////////////////

Version 1.0
Date: 10th July 2015
Description: Update/Insert 2 fields at Account with the same value Sales Resource Object have for same fields.
*/

public class salesResourcesTrgHelperCls {
    public void OnBeforeInsert(List<Sales_Resources__c> newValues){    
        RecordType instRecType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Sales_Engineering' And SobjectType = 'Sales_Resources__c' And IsActive = true];
        Set<Id> setAccId = new Set<Id>();
        
        for(Sales_Resources__c instOfSalRes : newValues){
            if(instOfSalRes.Account__c != null && instRecType.Id == instOfSalRes.RecordTypeId)
            setAccId.add(instOfSalRes.Account__c);
        }
        
        Map<Id,Account> mapAcc = new Map<Id,Account>();
        
        if(setAccId.size()>0)
        mapAcc = new map<Id,Account>([SELECT Id,API_connected_with__c,Back_Office_System__c,(SELECT Id FROM Sales_RFP__r WHERE RecordTypeId =: instRecType.Id) FROM Account WHERE Id=: setAccId]);
        
        for(Sales_Resources__c instOfSalRes : newValues){
            if(mapAcc.containsKey(instOfSalRes.Account__c)){
                if(mapAcc.get(instOfSalRes.Account__c).Sales_RFP__r.size()>0){
               /*     instOfSalRes.addError('Account already containse Sales Resource record with record type Sales Engineering');*/
                }else{
                    instOfSalRes.Back_Office_System_New__c = mapAcc.get(instOfSalRes.Account__c).Back_Office_System__c + ';' + instOfSalRes.Back_Office_System_New__c;
                    instOfSalRes.API_connected_with__c = mapAcc.get(instOfSalRes.Account__c).API_connected_with__c + ';' + instOfSalRes.API_connected_with__c;
                }
            }
        }
    }
    
    public void OnAfterInsert(Map<Id,Sales_Resources__c> newMapValues){  
        RecordType instRecType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Sales_Engineering' And SobjectType = 'Sales_Resources__c' And IsActive = true];
        Set<Id> setAccId = new Set<Id>();
        
        for(Sales_Resources__c instOfSalRes : newMapValues.values()){
            if(instOfSalRes.Account__c != null && instRecType.Id == instOfSalRes.RecordTypeId)
            setAccId.add(instOfSalRes.Account__c);
        }
        
        Map<Id,Account> mapAcc = new Map<Id,Account>();
        
        if(setAccId.size()>0)
        mapAcc = new map<Id,Account>([SELECT Id,API_connected_with__c,Back_Office_System__c,(SELECT Id FROM Sales_RFP__r WHERE RecordTypeId =: instRecType.Id) FROM Account WHERE Id=: setAccId]);
        
        List<Account> lstAccountUpd = new List<Account>();

        for(Sales_Resources__c instOfSalRes : newMapValues.values()){
            if(mapAcc.containsKey(instOfSalRes.Account__c)){
                Account instOfAcc = new Account();
                instOfAcc.Id = instOfSalRes.Account__c;
                instOfAcc.Back_Office_System__c = mapAcc.get(instOfSalRes.Account__c).Back_Office_System__c + ';' + instOfSalRes.Back_Office_System_New__c;
                instOfAcc.API_connected_with__c = mapAcc.get(instOfSalRes.Account__c).API_connected_with__c + ';' + instOfSalRes.API_connected_with__c;
                lstAccountUpd.add(instOfAcc);
            }
        }
        
        if(lstAccountUpd.size()>0)
        update lstAccountUpd;
    }
    
    public void OnBeforeUpdate(Map<Id,Sales_Resources__c> oldMapValues,Map<Id,Sales_Resources__c> newMapValues){ 
        
    }
    public void OnAfterUpdate(Map<Id,Sales_Resources__c> oldMapValues,Map<Id,Sales_Resources__c> newMapValues){ 
        RecordType instRecType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Sales_Engineering' And SobjectType = 'Sales_Resources__c' And IsActive = true];
        Set<Id> setAccId = new Set<Id>();
        Map<Id,String> mapOfBackOffice = new Map<Id,String>();
        Map<Id,String> mapOfApiCon = new Map<Id,String>();
        for(Sales_Resources__c instOfSalRes :  newMapValues.values()){
            
                if((instOfSalRes.Back_Office_System_New__c != oldMapValues.get(instOfSalRes.Id).Back_Office_System_New__c || instOfSalRes.API_connected_with__c != oldMapValues.get(instOfSalRes.Id).API_connected_with__c) && instOfSalRes.RecordTypeId == instRecType.Id){
                    if(instOfSalRes.Account__c != null){
                        
                        setAccId.add(instOfSalRes.Account__c);
                        
                        if(instOfSalRes.Back_Office_System_New__c != null && instOfSalRes.Back_Office_System_New__c !='')
                        mapOfBackOffice.put(instOfSalRes.Account__c,instOfSalRes.Back_Office_System_New__c);
                        else
                        mapOfBackOffice.put(instOfSalRes.Account__c,'');
                        
                        if(instOfSalRes.API_connected_with__c != null && instOfSalRes.API_connected_with__c !='')
                        mapOfApiCon.put(instOfSalRes.Account__c,instOfSalRes.API_connected_with__c);
                        else
                        mapOfApiCon.put(instOfSalRes.Account__c,'');
                    }
                }
            
        }
        
        List<Account> lstAccount = new List<Account>();
        
        if(setAccId.size()>0)
        lstAccount = [SELECT Id,API_connected_with__c,Back_Office_System__c FROM Account WHERE Id=: setAccId];
        
        List<Account> lstAccToBeUpdated = new List<Account>();
        
        for(Account instOfAcc : lstAccount){
            if(mapOfBackOffice.containsKey(instOfAcc.Id)){
                instOfAcc.Back_Office_System__c =  mapOfBackOffice.get(instOfAcc.Id);
            }
            if(mapOfApiCon.containsKey(instOfAcc.Id)){
                instOfAcc.API_connected_with__c =  mapOfApiCon.get(instOfAcc.Id);
            }
            lstAccToBeUpdated.add(instOfAcc);
        }
        
        if(lstAccToBeUpdated.size()> 0){
            update lstAccToBeUpdated;
            
        }
    }
    public void OnBeforeDelete(List<Sales_Resources__c> oldValues,Map<Id,Sales_Resources__c> oldMapValues){
        
    }
    
    public void OnAfterDelete(List<Sales_Resources__c> oldValues,Map<Id,Sales_Resources__c> oldMapValues){
    }
    
    public void OnUndelete(List<Sales_Resources__c> newValues){
        
    }
}