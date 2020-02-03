/*
//////////////////////////////////////
//      @author Abhishek Pandey     //
/////////////////////////////////////
Version :   1.0
Date : 18th March 2014
Description : To do ATI functionality Inserts Opportunities and feature sets, update Account with event date ,insets Task for reps,inserts AccountTeamMember .

Version 2.0
Date:7th Nov 2016
Description : Migrating FEATURESET to PRODUCT/PRICEBOOK. Below are the name of the field which needs to be replaced - 
OLD FIELD NAME       = NEW FIELD NAME
Feature_Sets__r      = OpportunityLineItems;
R00N00000008aGEXEA2  = OpportunityLineItems;
Feature_Set__c       = OpportunityLineItem;
Feature__c           = Product_Name__c;
Opportunity_N__c     = OpportunityId;
RecordType.DeveloperName = Product_Family__c; // Changed this from RecordType.DeveloperName to ProductFamily as now the concept of recordtype is finished
//Lines Commented as Can't update CurrencyISOCode of OpportunityLineItem
//Lines Commented as no need to update the PRODUCT NAME as it's a formula field in the OpportunityLineItem earlier was Picklist in FEATURESET
//Lines Commented as their is no concept left of recordtype....
*/
public class atiTRGHelperCls{
    public static List<DS_CS_Pairing__c> lstDSCSPar  = new List<DS_CS_Pairing__c>();
    public static map<Id,Id> mapDStoCS = new map<Id,Id>();
    public static List<RecordType> lstRecType = new List<RecordType>();
    public static map<string,Id> mapRecTyStr = new map<String,Id>(); 
    public static map<string,Id> mapRecTyStrFeat = new map<String,Id>();
    public static map<Id,String> mapUserRole = new map<Id,string>();
    public static map<String,Id> mapRecTypeATI = new map<String,Id>();
    public static Id masterRectypeId,AM_Record_TypeId;
    public static Id masterRectypeIdEvent;
    public static Id masterRectypeIdCC;
    public static Id masterRectypeIdInq;
    static{
        lstDSCSPar = [SELECT Id,CS_Rep__c,DS_Rep__c FROM DS_CS_Pairing__c];
        for(DS_CS_Pairing__c instDSCSPar : lstDSCSPar){
            mapDStoCS.put(instDSCSPar.DS_Rep__c,instDSCSPar.CS_Rep__c);
        }
        List<User> lstUsr = [ SELECT Id,UserRole.Name FROM User WHERE Id =: mapDStoCS.Keyset() And UserRole.Name != null];
        
        for(User usr : lstUsr){
            if(usr.UserRole.Name.contains('Event')){
                mapUserRole.put(usr.Id,'CS - Event');
            }else if(usr.UserRole.Name.contains('Survey')){
                mapUserRole.put(usr.Id,'CS - Survey');
            }else if(usr.UserRole.Name.contains('CrowdCompass')){
                mapUserRole.put(usr.Id,'CS - CrowdCompass');
            }else if(usr.UserRole.Name.contains('CrowdTorch')){
                mapUserRole.put(usr.Id,'CS - CrowdTorch Mobile');
            }else if(usr.UserRole.Name.contains('TicketMob')){
                mapUserRole.put(usr.Id,'CS - CrowdTorch Ticketing');
            }
        }
        
        lstRecType =  [SELECT Id,SobjectType, Name, IsActive, DeveloperName FROM RecordType WHERE SobjectType = 'Opportunity' And IsActive = true];
        
        for(RecordType instOfRec : lstRecType ){
            mapRecTyStr.put(instOfRec.Name.trim(),instOfRec.Id);
        }
        
        lstRecType = new List<RecordType>();
        
        lstRecType =  [SELECT Id,SobjectType, Name, IsActive, DeveloperName FROM RecordType WHERE SobjectType = 'OpportunityLineItem' And IsActive = true];
        for(RecordType instOfRec : lstRecType ){
            mapRecTyStrFeat.put(instOfRec.Name.trim(),instOfRec.Id);
        }
        lstRecType = new List<RecordType>();
        
        lstRecType =  [SELECT Id,SobjectType, Name, IsActive, DeveloperName FROM RecordType WHERE SobjectType = 'ATI_Info__c' And IsActive = true];
        for(RecordType instOfRec : lstRecType ){
            mapRecTypeATI.put(instOfRec.Name.trim(),instOfRec.Id);
        }
        
        masterRectypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'ATI_Info__c' AND DeveloperName='Master'].Id;
        AM_Record_TypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'ATI_Info__c' AND DeveloperName='AM_Record_Type'].Id;      
        masterRectypeIdCC = [SELECT Id FROM RecordType WHERE SobjectType = 'ATI_Info__c' AND DeveloperName='CrowdCompass'].Id;
        masterRectypeIdInq = [SELECT Id FROM RecordType WHERE SobjectType = 'ATI_Info__c' AND DeveloperName='Inquisium'].Id;
    }
    public void OnBeforeInsert(List<ATI_Info__c> newValues){  
    }
    public void OnAfterInsert(Map<Id,ATI_Info__c> newMapValues){
        List<Id> lstAccid = new List<Id>();
        map<Id,Date> mapIdATI = new map<Id,Date>();
        map<Id,Id> mapIdConId = new map<Id,Id>();
        map<Id,ATI_Info__c> mapIdATIOb = new map<ID,ATI_Info__c>();
        map<Id,string> mapRecType = new map<Id,String>();
        /*Commented as Future_Upsell_Opportunities__c is not on layout........
map<Id,String> mapOpp1 = new map<Id,String>();*/
        /*/*Commented as Future_Upsell_Opportunities__c is not on layout........
map<Id,String> mapOpp2 = new map<Id,String>();*/
        map<Id,String> mapOppFeat1 = new map<Id,String>();
        map<Id,String> mapOppFeat2 = new map<Id,String>();
        set<Id> setOppId = new set<Id>();
        map<Id,List<ATI_Info__c>> mapAccidLstAti = new map<Id,List<ATI_Info__c>>();
        for(ATI_Info__c instOfNew :  newMapValues.values()){
            if(instOfNew.RecordTypeId != masterRectypeId){
                lstAccid.add(instOfNew.Account__c);
                mapIdATI.put(instOfNew.Parent_Opportunity__c,instOfNew.First_Event_Launch_Date__c); 
                mapIdConId.put(instOfNew.Parent_Opportunity__c,instOfNew.Main_User1__c);
                mapIdATIOb.put(instOfNew.Parent_Opportunity__c,instOfNew);
                /*Commented as Future_Upsell_Opportunities__c is not on layout........
if(instOfNew.Future_Upsell_Opportunities__c != null)
mapOpp1.put(instOfNew.Parent_Opportunity__c,instOfNew.Future_Upsell_Opportunities__c);*/
                
                if(instOfNew.Features__c != null)
                    mapOppFeat1.put(instOfNew.Account__c,instOfNew.Features__c);
                /*Commented as Future_Upsell_Opportunities__c is not on layout........
if(instOfNew.Future_Upsell_Opportunities_2__c != null)
mapOpp2.put(instOfNew.Parent_Opportunity__c,instOfNew.Future_Upsell_Opportunities_2__c);*/
                
                if(instOfNew.Feature_2__c != null)
                    mapOppFeat2.put(instOfNew.Account__c,instOfNew.Feature_2__c);
                
                setOppId.add(instOfNew.Parent_Opportunity__c);
            }
        }
        List<Opportunity> lstOppSec =  [SELECT ID,Parent_Upsell__c,NBB_Renewal__c,MYD_Deal__c,RecordTypeId,product__c,accountId,(SELECT Id FROM OpportunityLineItems WHERE Product_Family__c ='CrowdCompass'),(SELECT Id,RecordTypeId FROM Account_Transition_Information__r) FROM Opportunity WHERE Id=:setOppId];// Changed this from RecordType.DeveloperName to ProductFamily as now the concept of recordtype is 
        system.debug('====lstOppSec===='+lstOppSec);        
        
        List<Account> updateAcc = new List<Account>();
        List<Task> lstTsk = new List<Task>();
        List<Opportunity> lstOpp = new List<Opportunity>();
        /*List<AccountTeamMember> lstATM = new List<AccountTeamMember>();*/
        
        List<Opportunity> lstOppThir = new List<Opportunity>();
        for(Opportunity instOfOpp : lstOppSec){
            instOfOpp.ATI_check__c = true;
            lstOppThir.add(instOfOpp);
        }
        
        if(lstOppThir.size()>0)
            update lstOppThir;
        
        Set<Id> accSet = new Set<Id>();
        for(Opportunity instOFAcc : lstOppSec){
            if(mapIdATI.containsKey(instOFAcc.Id)){                
                Account insOfAccSec = new Account();
                insOfAccSec.Id = instOFAcc.accountId;
                insOfAccSec.Event_Date__c = mapIdATI.get(instOFAcc.Id);
                if(instOFAcc.accountId != null && !accSet.contains(instOFAcc.accountId)){
                  updateAcc.add(insOfAccSec);
                   accSet.add(instOFAcc.accountId);
                }
                // Modified by : Sandeep Kumar. Please refer to project "P-000826" for detailed information.
                for(ATI_Info__c atiRec : instOFAcc.Account_Transition_Information__r){
                    if(mapIdATI.containsKey(instOFAcc.Id) && !(AM_Record_TypeId == atiRec.RecordTypeId) && newMapValues.containsKey(atiRec.Id)){ 
                        Task instOfTsk= new Task();
                        Task instOfTskEvent = new Task();
                        Task instOfTskCC = new Task();
                        
                        if(instOFAcc.Product__c == 'Event' || instOFAcc.Product__c =='CrowdCompass' || instOFAcc.Product__c == 'Survey' || instOFAcc.Product__c == 'Inquisium'){
                            instOfTsk.OwnerId = UserInfo.getUserId();
                            instOfTskEvent.OwnerId = UserInfo.getUserId();
                            instOfTskCC.OwnerId = UserInfo.getUserId();
                            instOfTsk.WhatId = instOFAcc.Id;
                            instOfTskEvent.WhatId = instOFAcc.Id;
                            instOfTskCC.WhatId = instOFAcc.Id;
                            instOfTskCC.Subject = 'Schedule Pre Event Call';
                            instOfTskEvent.Subject = 'Schedule Pre Event Call';
                            instOfTsk.Priority = 'Normal';
                            instOfTsk.Status = 'Not Started';                            
                            instOfTskEvent.Priority = 'Normal';
                            instOfTskEvent.Status = 'Not Started';
                        }
                        
                        if(instOFAcc.Product__c == 'Event' || instOFAcc.Product__c =='CrowdCompass')
                            instOfTsk.Subject = 'Schedule Pre Event Call';
                        
                        if(instOFAcc.Product__c == 'Survey' || instOFAcc.Product__c == 'Inquisium')
                            instOfTsk.Subject = 'Schedule Survey Launch Call';
                        
                        Date tempDate;
                        
                        if(instOFAcc.Product__c == 'Survey' || instOFAcc.Product__c == 'Inquisium'){                            
                            if(mapIdATIOb.get(instOFAcc.Id).First_Survey_Launch_Date__c != null){                                
                                if(mapIdATIOb.get(instOFAcc.Id).First_Survey_Launch_Date__c <= system.today())
                                    tempDate = system.today().addDays(1);
                                else
                                    tempDate = mapIdATIOb.get(instOFAcc.Id).First_Survey_Launch_Date__c;
                                
                                instOfTsk.ActivityDate = tempDate;
                            }                            
                        }                        
                        
                        if(instOFAcc.Product__c == 'Event' && instOFAcc.OpportunityLineItems.size()==0){                            
                            if(mapIdATIOb.get(instOFAcc.Id).First_Event_Launch_Date__c != null){
                                if(mapIdATIOb.get(instOFAcc.Id).First_Event_Launch_Date__c.adddays(-70)<= system.today())
                                    tempDate = system.today().addDays(1);
                                else
                                    tempDate = mapIdATIOb.get(instOFAcc.Id).First_Event_Launch_Date__c.adddays(-70);
                                instOfTsk.ActivityDate = tempDate;
                            }
                        }else if(instOFAcc.Product__c == 'Event' && instOFAcc.OpportunityLineItems.size()>0){                            
                            if(mapIdATIOb.get(instOFAcc.Id).First_Event_Launch_Date__c != null){
                                if(mapIdATIOb.get(instOFAcc.Id).First_Event_Launch_Date__c.adddays(-70)<= system.today())
                                    tempDate = system.today().addDays(1);
                                else
                                    tempDate = mapIdATIOb.get(instOFAcc.Id).First_Event_Launch_Date__c.adddays(-70);
                                instOfTskEvent.ActivityDate = tempDate;
                            }
                        }                        
                        
                        if(instOFAcc.Product__c == 'CrowdCompass'){
                            if(mapIdATIOb.get(instOFAcc.Id).First_App_Launch_Date__c != null){
                                if(mapIdATIOb.get(instOFAcc.Id).First_App_Launch_Date__c.adddays(-28)<= system.today())
                                    tempDate = system.today().addDays(1);
                                else
                                    tempDate = mapIdATIOb.get(instOFAcc.Id).First_App_Launch_Date__c.adddays(-28);
                                instOfTsk.ActivityDate = tempDate;
                            }
                        }                      
                        
                        if(instOFAcc.OpportunityLineItems.size()==0){
                            lstTsk.add(instOfTsk); 
                        }else{
                            lstTsk.add(instOfTskEvent); 
                        }
                    }
                }
                     /* Commented as Future_Upsell_Opportunities__c is not on layout........
if(mapOpp1.containsKey(instOFAcc.Id)){
Opportunity instOfOpp = new Opportunity();
if(mapIdATIOb.get(instOFAcc.Id).Future_Upsell_Opportunities__c.trim()=='PSG'){
instOfOpp.RecordTypeId = mapRecTyStr.get('Survey');
}else{
instOfOpp.RecordTypeId =  mapRecTyStr.get(mapIdATIOb.get(instOFAcc.Id).Future_Upsell_Opportunities__c.trim());
}
instOfOpp.AccountId = instOFAcc.accountId;
if(mapIdATIOb.get(instOFAcc.Id).Upsell_1_Notes__c!= '' && mapIdATIOb.get(instOFAcc.Id).Upsell_1_Notes__c!=null)
instOfOpp.Notes__c = mapIdATIOb.get(instOFAcc.Id).Upsell_1_Notes__c;
instOfOpp.ownerId = UserInfo.getUserId();
instOfOpp.Name = 'Account Transition Opportunity';
instOfOpp.Product__c = mapIdATIOb.get(instOFAcc.Id).Future_Upsell_Opportunities__c;
instOfOpp.StageName = 'Qualified';
instOfOpp.CloseDate = system.today().adddays(90);
instOfOpp.New_Amount__c = mapIdATIOb.get(instOFAcc.Id).Amount__c;
instOfOpp.Years__c= '1';
instOfOpp.LeadSource = 'ACD-PS';
instOfOpp.Contact_Associated__c = mapIdConId.get(instOFAcc.Id);
instOfOpp.Contact_Role__c = 'Primary User';
lstOpp.add(instOfOpp);
}*/
                    
                    /*Commented as Future_Upsell_Opportunities__c is not on layout........
if(mapOpp2.containsKey(instOFAcc.Id)){
Opportunity instOfOppSec = new Opportunity();
if(mapIdATIOb.get(instOFAcc.Id).Future_Upsell_Opportunities_2__c.trim()=='PSG'){
instOfOppSec.RecordTypeId = mapRecTyStr.get('Survey');
}else{
instOfOppSec.RecordTypeId =  mapRecTyStr.get(mapIdATIOb.get(instOFAcc.Id).Future_Upsell_Opportunities_2__c.trim());
}
instOfOppSec.AccountId = instOFAcc.accountId;

if(mapIdATIOb.get(instOFAcc.Id).Upsell_2_Notes__c!= '' && mapIdATIOb.get(instOFAcc.Id).Upsell_2_Notes__c!=null)
instOfOppSec.Notes__c = mapIdATIOb.get(instOFAcc.Id).Upsell_2_Notes__c;
instOfOppSec.ownerId = UserInfo.getUserId();
instOfOppSec.Name = 'Account Transition Opportunity';
instOfOppSec.Product__c = mapIdATIOb.get(instOFAcc.Id).Future_Upsell_Opportunities_2__c;
instOfOppSec.StageName = 'Qualified';
instOfOppSec.CloseDate = system.today().adddays(90);
instOfOppSec.New_Amount__c = mapIdATIOb.get(instOFAcc.Id).Amount_2nd_Opp__c;
instOfOppSec.Years__c= '1';
instOfOppSec.LeadSource = 'ACD-PS';
instOfOppSec.Contact_Associated__c = mapIdConId.get(instOFAcc.Id);
instOfOppSec.Contact_Role__c = 'Primary User';
lstOpp.add(instOfOppSec);
}
accId.add(instOFAcc.accountId);*/
                }
            }
      system.debug('====updateAcc Before Update====='+updateAcc);            
            if(lstTsk.size()>0)
                insert lstTsk;
        if(updateAcc.size()>0){
            system.debug('>>>>>>>>updateAcc>>>>>>'+updateAcc);
            update updateAcc;
        }
                
            
            /*
List<Account> lsAccSec = new List<Account>();
if(lstOpp.size() > 0)
lsAccSec = [SELECT Id,(SELECT Id,Product__c FROM Opportunities WHERE Name Like 'Account Transition Opportunity'),(SELECT Id,Feature_2__c,Features__c,Future_Upsell_Opportunities__c,
Future_Upsell_Opportunities_2__c FROM ATI_Info__r) FROM Account WHERE Id=:accId];

List<OpportunityLineItem> lstFeatureSet =  new List<OpportunityLineItem>();
for(Account instOfAcc : lsAccSec){
for(ATI_Info__c  instOfATI : instOfAcc.ATI_Info__r){
for(Opportunity instOpp : instOfAcc.Opportunities){
if(instOfATI.Future_Upsell_Opportunities__c == instOpp.Product__c){
if(instOfATI.Features__c != null){
List<String> lstOfM = new List<String>();
if(instOfATI.Features__c.contains(';'))
lstOfM  = instOfATI.Features__c.split(';', -2);
else
lstOfM.add(instOfATI.Features__c);
for(String instOfStr : lstOfM){
OpportunityLineItem instOfFeat = new OpportunityLineItem();
instOfFeat.OpportunityId = instOpp.ID;
lstFeatureSet.add(instOfFeat);
}
}
}
if(instOfATI.Future_Upsell_Opportunities_2__c == instOpp.Product__c){
if(instOfATI.Feature_2__c != null){
List<String> lstOfM = new List<String>();
if(instOfATI.Feature_2__c.contains(';'))
lstOfM  = instOfATI.Feature_2__c.split(';', -2);
else
lstOfM.add(instOfATI.Feature_2__c);
for(String instOfStr : lstOfM){
OpportunityLineItem instOfFeat = new OpportunityLineItem();
instOfFeat.OpportunityId = instOpp.ID;
lstFeatureSet.add(instOfFeat);
}
}
}
}
}
}

if(lstFeatureSet.size()>0)
insert lstFeatureSet;*/
        }
        public void OnBeforeUpdate(Map<Id,ATI_Info__c> oldMapValues,Map<Id,ATI_Info__c> newMapValues){ 
            set<Id> setOfOppId = new set<Id>();
            for(ATI_Info__c instOfATI : newMapValues.values()){
                if(instOfATI.RecordTypeId != masterRectypeId){
                    setOfOppId.add(instOfATI.Parent_Opportunity__c);
                }
            }
        }
    
      public void OnAfterUpdate(Map<Id,ATI_Info__c> oldMapValues,Map<Id,ATI_Info__c> newMapValues){}
        public void OnBeforeDelete(List<ATI_Info__c> oldValues,Map<Id,ATI_Info__c> oldMapValues){ }
        public void OnAfterDelete(List<ATI_Info__c> oldValues,Map<Id,ATI_Info__c> oldMapValues){}
        public void OnUndelete(List<ATI_Info__c> newValues){ }  
    }