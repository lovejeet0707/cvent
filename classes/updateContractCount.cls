global class updateContractCount implements Database.Batchable<sObject>{
    global static Map<String,String> mapStatusSett = new Map<String,String>(); 
    global static Set<String> tempSet = new Set<String>();
    static{
        List<Contract_Status_Values__c> lstContrStatusVal = [SELECT Id,Custom_Field_Api__c,Picklist_Values_del__c FROM Contract_Status_Values__c];
        
        for(Contract_Status_Values__c instOfContrVal :lstContrStatusVal ){
            mapStatusSett.put(instOfContrVal.Picklist_Values_del__c.trim(),instOfContrVal.Custom_Field_Api__c.trim());
        }
        tempSet.addAll(mapStatusSett.Keyset());
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Status,Id,Creation_to_Execution__c';
        for(String strVal : mapStatusSett.values()){
            query = query +','+strVal;
        }
        query = query + ' FROM Contract WHERE Status != null AND Status IN:tempSet ';
        system.debug(query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        Map<Id,Contract> mapIdContract = new Map<Id,Contract>();
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        SObjectType sObj;
        sObj = gd.get('Contract');
        List<SObject> lstSObj = new List<SObject>();
        for(SObject instOfCont : scope){
            SObject sobjectInstance = sObj.newSObject();
            sobjectInstance.Id = instOfCont.Id;
            system.debug(instOfCont.get('Status'));
            system.debug(String.valueOf(instOfCont.get('Status')));
            system.debug(mapStatusSett);
            system.debug(mapStatusSett.get(String.valueOf(instOfCont.get('Status'))));
            system.debug(String.valueOf(mapStatusSett.get(String.valueOf(instOfCont.get('Status')))));
            system.debug(instOfCont.get(String.valueOf(mapStatusSett.get(String.valueOf(instOfCont.get('Status'))))));
            Integer intTemp=0;
            if(instOfCont.get(String.valueOf(mapStatusSett.get(String.valueOf(instOfCont.get('Status')))))==null)
            intTemp = 0;
            else
            intTemp = Integer.valueOf(instOfCont.get(String.valueOf(mapStatusSett.get(String.valueOf(instOfCont.get('Status'))))));
            system.debug(intTemp);
            sobjectInstance.put(mapStatusSett.get(String.valueOf(instOfCont.get('Status'))),intTemp+1);
            system.debug('Test++++'+instOfCont.get('Creation_to_Execution__c'));
            intTemp  = 0;
            for(String instMapStr : mapStatusSett.values()){
                if(instOfCont.get(instMapStr) == null)
                intTemp = 0 + intTemp;
                else
                intTemp = intTemp + integer.valueof(instOfCont.get(instMapStr));
            }
            sobjectInstance.put('Creation_to_Execution__c',intTemp +1);
            lstSObj.add(sobjectInstance);
        }
        
        if(lstSObj.size()>0)
        Database.update(lstSObj, false);
        //update lstSObj;   
    }
    
    global void finish(Database.BatchableContext BC){
    }
}