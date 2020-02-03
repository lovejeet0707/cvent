/*
//////////////////////////////////////
//      @author Abhishek Pandey     //
/////////////////////////////////////
Version :   1.0
Date : 17th June 2014
Description : Show Quota Vs Budget report using Google Charting. Test Class -ReportsLandingClsTest
*/
public class QuotaAttainmentScreenCls {

    public PageReference test() {
        return null;
    }

    public static List<Id> lstDsList = new List<Id>();
    public static List<Id> lstAMList = new List<Id>();
    public static List<OpportunityData> oppsData{get;set;}
    public static map<Id,List<Decimal>> mapUserIdMonthlyQNbb = new map<Id,List<Decimal>>();
    public static map<Id,List<Decimal>> mapUserIdMonthlyQPsg = new map<Id,List<Decimal>>();
    public static map<Id,List<Decimal>> mapUserIdQuaterlyTppRoom = new map<Id,List<Decimal>>();
    public static map<Id,List<Decimal>> mapUserIdQuaterlyQRenew = new map<Id,List<Decimal>>();
    public static map<Id,List<Decimal>> mapUserIdMonthlyBundle = new map<Id,List<Decimal>>();
    public static map<Id,List<Decimal>> mapUserIdMonthlyCTT = new map<Id,List<Decimal>>();
    public static map<Id,List<Decimal>> mapUserIdMonthlyCtm = new map<Id,List<Decimal>>();
    public static Map<Id,Decimal> mapUserRoomNights = new Map<Id,Decimal>();
    
    public QuotaAttainmentScreenCls(){
        lstDsList = new List<Id>();
        lstAMList = new List<Id>();
    } 
    public static List<Quota_Attainment__c> lstOfQA = new List<Quota_Attainment__c>();
    @readonly
    @RemoteAction
    public static List<OpportunityData> loadOpps(){
        
        
        Integer monthFromJs;
        Integer monthToJs;
        String masterTypeSec ;
        String topScorerSec ='20';
        lstOfQA = Quota_Attainment__c.getall().values();
        List<String> lstOfMonthy = new List<String>();
        List<Decimal> lstOfMonthyDec = new List<Decimal>();
        
        List<String> lstOfMonthlyRenewal = new List<String>();
        List<Decimal> lstOfMonthlyRenewalDeci = new List<Decimal>();
        
        List<String> lstOfMonthlyPSG = new List<String>();
        List<Decimal> lstOfMonthlyPSGDeci = new List<Decimal>();
        
        List<Decimal> lstofBundleDeci = new List<Decimal>();
        List<String> lstofBundle = new List<String>();
        
        List<String> lstOfMonthyCTT = new List<String>();
        List<String> lstOfMonthyCTM = new List<String>();
        
        List<Decimal> lstOfMonthyCTTDec = new List<Decimal>();
        List<Decimal> lstOfMonthyCtmDec = new List<Decimal>();
        
        List<String> lstOfMonthlyTPPRoomN = new List<String>();
        List<Decimal> lstOfMonthlyTPPRoomNDeci = new List<Decimal>();
        
        Map<Integer,String> mapNoMonthName = new Map<Integer,String>();
        Map<String,Integer[]> mapNoMonthNameSec = new Map<String,Integer[]>();
        
        mapNoMonthName.put(1,'Q1');
        mapNoMonthName.put(2,'Q1');
        mapNoMonthName.put(3,'Q1');
        mapNoMonthName.put(4,'Q2');
        mapNoMonthName.put(5,'Q2');
        mapNoMonthName.put(6,'Q2');
        mapNoMonthName.put(7,'Q3');
        mapNoMonthName.put(8,'Q3');
        mapNoMonthName.put(9,'Q3');
        mapNoMonthName.put(10,'Q4');
        mapNoMonthName.put(11,'Q4');
        mapNoMonthName.put(12,'Q4');
        
        mapNoMonthNameSec.put('Q1',new Integer[]{1,2,3});
        mapNoMonthNameSec.put('Q2',new Integer[]{4,5,6});
        mapNoMonthNameSec.put('Q3',new Integer[]{7,8,9});
        mapNoMonthNameSec.put('Q4',new Integer[]{10,11,12});
        
        for(Quota_Attainment__c instOfQA : lstOfQA){
            system.debug('instOfQA.Quota_Year__c++'+instOfQA.Quota_Year__c);
            system.debug('system.now().year()++'+system.now().year()+'.0');
            String valStr = string.valueOf(instOfQA.Quota_Year__c);
            if(Test.isRunningtest()){
                valStr = string.valueOf(instOfQA.Quota_Year__c) + '.0';
            }
            if(valStr == system.now().year()+'.0'){
                lstOfMonthy =  new List<String>();
                lstOfMonthlyRenewal =  new List<String>();
                lstOfMonthlyPSG =  new List<String>();
                lstOfMonthyCTM = new List<String>();
                lstOfMonthyDec = new List<Decimal>();
                lstOfMonthlyRenewalDeci = new List<Decimal>();
                lstOfMonthlyPSGDeci =  new List<Decimal>();
                lstOfMonthyCtmDec = new List<Decimal>();
                lstOfMonthlyTPPRoomN = new List<String>();
                lstOfMonthlyTPPRoomNDeci = new List<Decimal>();
                lstofBundleDeci = new List<Decimal>();
                lstofBundle = new List<String>();
                
                
                if(instOfQA.Role__c.trim() == 'Direct Sales')
                lstDsList.add(instOfQA.User_Id__c);
                
                if(instOfQA.Role__c.trim() == 'AM')
                lstAMList.add(instOfQA.User_Id__c);
                
                if(instOfQA.Room_Nights_Monthly__c != null && instOfQA.Room_Nights_Monthly__c != '' && (instOfQA.Team_Role__c.trim() == 'TPP'  || instOfQA.Team_Role__c.trim() =='Product Adoption'))
                lstOfMonthlyTPPRoomN = instOfQA.Room_Nights_Monthly__c.split(';',-2);
                
                for(String instOfStr : lstOfMonthlyTPPRoomN){
 
                    instOfStr = instOfStr.trim();
                    lstOfMonthlyTPPRoomNDeci.add(Decimal.valueOf(instOfStr));
                }
                
                if(instOfQA.NBB_Licensing_Monthly__c != null && instOfQA.NBB_Licensing_Monthly__c !='' && instOfQA.Team_Role__c =='CrowdTorch(Ticketing)')
                lstOfMonthyCTT = instOfQA.NBB_Licensing_Monthly__c.split(';',-2);
                
                for(String instOfStr : lstOfMonthyCTT){
                    system.debug('instOfStr++'+instOfStr.trim());
                    instOfStr = instOfStr.trim();
                    lstOfMonthyCTTDec.add(Decimal.valueOf(instOfStr));
                }
                
                if(instOfQA.NBB_Licensing_Monthly__c != null && instOfQA.NBB_Licensing_Monthly__c !='' && instOfQA.Team_Role__c =='CrowdTorch(Mobile)')
                lstOfMonthyCTM = instOfQA.NBB_Licensing_Monthly__c.split(';',-2);   
                
                for(String instOfStr : lstOfMonthyCTM){
                    system.debug('instOfStr++'+instOfStr.trim());
                    instOfStr = instOfStr.trim();
                    lstOfMonthyCtmDec.add(Decimal.valueOf(instOfStr));
                }
                
                if(instOfQA.NBB_Licensing_Monthly__c != null && instOfQA.NBB_Licensing_Monthly__c !='' && instOfQA.Team_Role__c !='CrowdTorch(Ticketing)' && instOfQA.Team_Role__c !='CrowdTorch(Mobile)')
                lstOfMonthy = instOfQA.NBB_Licensing_Monthly__c.split(';',-2);
                
                for(String instOfStr : lstOfMonthy){
                    system.debug('instOfStr++'+instOfStr.trim());
                    instOfStr = instOfStr.trim();
                    lstOfMonthyDec.add(Decimal.valueOf(instOfStr));
                }
                /*if(instOfQA.NBB_Licensing_Monthly__c != null && instOfQA.NBB_Licensing_Monthly__c !='')
                lstOfMonthy = instOfQA.NBB_Licensing_Monthly__c.split(';',-2);
                
                for(String instOfStr : lstOfMonthy){
                    system.debug('instOfStr++'+instOfStr.trim());
                    instOfStr = instOfStr.trim();
                    lstOfMonthyDec.add(Decimal.valueOf(instOfStr));
                }*/
                
                if(instOfQA.Renewal_Monthly__c != null && instOfQA.Renewal_Monthly__c !='')
                lstOfMonthlyRenewal = instOfQA.Renewal_Monthly__c.split(';',-2);
                
                for(String instOfMonRen : lstOfMonthlyRenewal){
                    system.debug('instOfStr++'+instOfMonRen.trim());
                    instOfMonRen = instOfMonRen.trim();
                    lstOfMonthlyRenewalDeci.add(Decimal.valueOf(instOfMonRen));
                }
                
                if(instOfQA.NBB_PSG_Monthly__c != null && instOfQA.NBB_PSG_Monthly__c !='')
                lstOfMonthlyPSG = instOfQA.NBB_PSG_Monthly__c.split(';',-2);
                
                for(String instOfMonthlyPSG : lstOfMonthlyPSG){
                    system.debug('instOfStr++'+instOfMonthlyPSG.trim());
                    instOfMonthlyPSG = instOfMonthlyPSG.trim();
                    lstOfMonthlyPSGDeci.add(Decimal.valueOf(instOfMonthlyPSG));
                }
                
                if(instOfQA.Bundle_Monthly__c != null && instOfQA.Bundle_Monthly__c !='')
                lstofBundle = instOfQA.Bundle_Monthly__c.split(';',-2);
                
                for(String instOfMonthlyBun : lstofBundle){
                    instOfMonthlyBun = instOfMonthlyBun.trim();
                    lstofBundleDeci.add(Decimal.valueOf(instOfMonthlyBun));
                }
                
                if(lstOfMonthlyTPPRoomNDeci.size()>0)
                mapUserIdQuaterlyTppRoom.put(instOfQA.User_Id__c,lstOfMonthlyTPPRoomNDeci);
                
                if(lstofBundleDeci.size()>0)
                mapUserIdMonthlyBundle.put(instOfQA.User_Id__c,lstofBundleDeci);
                
                if(lstOfMonthlyRenewalDeci.size()>0)
                mapUserIdQuaterlyQRenew.put(instOfQA.User_Id__c,lstOfMonthlyRenewalDeci);
                
                if(lstOfMonthlyPSGDeci.size()>0)
                mapUserIdMonthlyQPsg.put(instOfQA.User_Id__c,lstOfMonthlyPSGDeci);
                
                if(lstOfMonthyDec.size()>0)
                mapUserIdMonthlyQNbb.put(instOfQA.User_Id__c,lstOfMonthyDec);
                
                if(lstOfMonthyCTTDec.size()>0)
                mapUserIdMonthlyCTT.put(instOfQA.User_Id__c,lstOfMonthyCTTDec); 
                
                if(lstOfMonthyCtmDec.size()>0)
                mapUserIdMonthlyCtm.put(instOfQA.User_Id__c,lstOfMonthyCtmDec);
            }
        }
        
        String quaterStr = mapNoMonthName.get(system.today().month());
        Integer[] lstDeci = mapNoMonthNameSec.get(quaterStr);
        monthFromJs = lstDeci[0];
        monthToJs = lstDeci[2];
        topScorerSec = '20';
        masterTypeSec = 'NBBPSGRENEWAL';
        List<Opportunity> lstOpp =  new List<Opportunity>();
        system.debug('monthFromJs++'+monthFromJs);
        system.debug('monthToJs++'+monthToJs );
        system.debug('lstDsList++'+lstDsList);
        system.debug('monthToJs++'+monthToJs );
        system.debug('system.today.Year()-1'+system.today().Year());
        lstOpp = [SELECT Id,New_Contract_Total__c,OwnerId,Bundle_Value__c,Exchange_Rate__c,CurrencyISoCode,of_Total_Room_Nights_Committed__c,Product__c FROM Opportunity WHERE StageName = 'Closed Won' AND OwnerId =: lstDsList AND (Master_Type__c =: '1) NBB' OR (Product__c =: 'Survey' AND License_Type__c =:'Professional Services'))
                      AND CALENDAR_MONTH(CloseDate) >=: monthFromJs AND CALENDAR_MONTH(CloseDate) <=: monthToJs AND CALENDAR_YEAR(CloseDate) =: system.today().Year() AND Product__c != 'CSN'];
        system.debug('lstOpp+++'+lstOpp);
        Map<Id,Decimal> mapUserSum = new Map<Id,Decimal>();
        mapUserRoomNights = new Map<Id,Decimal>();
        for(Opportunity instOfOpp : lstOpp){
            system.debug(instOfOpp.CurrencyISoCode);
            if(mapUserSum.containsKey(instOfOpp.OwnerId)){
                system.debug(instOfOpp.Bundle_Value__c);
                system.debug(mapUserSum.get(instOfOpp.OwnerId));
                Decimal deciTemVal = mapUserSum.get(instOfOpp.OwnerId);
                system.debug(deciTemVal);
                //if(instOfOpp.Bundle_Value__c != null && instOfOpp.Bundle_Value__c!=0){
                    //deciTemVal = deciTemVal + instOfOpp.Bundle_Value__c;   
                    //system.debug(deciTemVal);
                    //system.debug(instOfOpp.Bundle_Value__c); 
                //}else{
                    if(instOfOpp.New_Contract_Total__c != null){
                        if(instOfOpp.Exchange_Rate__c!= null && instOfOpp.Exchange_Rate__c!= 0)
                        deciTemVal = deciTemVal + instOfOpp.New_Contract_Total__c/instOfOpp.Exchange_Rate__c;  
                        else
                        deciTemVal = deciTemVal + instOfOpp.New_Contract_Total__c; 
                    }
                    system.debug(deciTemVal);
                    system.debug(instOfOpp.New_Contract_Total__c);
                //}
                system.debug(instOfOpp.OwnerId);
                system.debug(instOfOpp.Exchange_Rate__c);
                system.debug(instOfOpp.CurrencyISoCode);
                system.debug(instOfOpp.New_Contract_Total__c);
                system.debug(deciTemVal);
                mapUserSum.put(instOfOpp.OwnerId,deciTemVal);
            }else{
                //if(instOfOpp.Bundle_Value__c != null && instOfOpp.Bundle_Value__c!=0){
                    //mapUserSum.put(instOfOpp.OwnerId,instOfOpp.Bundle_Value__c);
                    //system.debug(instOfOpp.Bundle_Value__c);
                    //system.debug(mapUserSum.get(instOfOpp.OwnerId));
                //}else{
                    system.debug(instOfOpp.Exchange_Rate__c);
                    system.debug(instOfOpp.CurrencyISoCode);
                    system.debug(instOfOpp.New_Contract_Total__c);
                    if(instOfOpp.New_Contract_Total__c != null){
                        if(instOfOpp.Exchange_Rate__c!= null && instOfOpp.Exchange_Rate__c!= 0)
                        mapUserSum.put(instOfOpp.OwnerId,instOfOpp.New_Contract_Total__c/instOfOpp.Exchange_Rate__c); 
                        else
                        mapUserSum.put(instOfOpp.OwnerId,instOfOpp.New_Contract_Total__c);
                    }
                    system.debug(instOfOpp.OwnerId);
                    system.debug(instOfOpp.New_Contract_Total__c);
                //}
            }
            if(mapUserRoomNights.containsKey(instOfOpp.OwnerId)){
                Decimal deciTemVal = mapUserRoomNights.get(instOfOpp.OwnerId);
                if(instOfOpp.of_Total_Room_Nights_Committed__c != null){
                    deciTemVal = deciTemVal + instOfOpp.of_Total_Room_Nights_Committed__c;
                    mapUserRoomNights.put(instOfOpp.OwnerId,deciTemVal);
                }
            }else{
                if(instOfOpp.of_Total_Room_Nights_Committed__c != null && (instOfOpp.Product__c == 'Event' || instOfOpp.Product__c == 'CSN'))
                mapUserRoomNights.put(instOfOpp.OwnerId,instOfOpp.of_Total_Room_Nights_Committed__c);
            }
        }
        
        Map<Id,List<Decimal>> mapOfUser = new Map<Id,List<Decimal>>();
        mapOfUser = calculation(mapUserSum,monthFromJs,monthToJs,masterTypeSec);
        
        List<OpportunityData> lstOppsData = new List<OpportunityData>();
        Map<Id,User> mapUserPicLink = new Map<Id,user>([SELECT Id,FullPhotoUrl,Name FROM User Where Id =: mapOfUser.keyset()]);
        oppsData = new List<OpportunityData>();
        for(Id userId : mapOfUser.keySet()){
            OpportunityData opp = new OpportunityData(mapUserPicLink.get(userId).Name,mapOfUser.get(userId)[0],mapOfUser.get(userId)[1],mapOfUser.get(userId)[2],mapUserPicLink.get(userId).FullPhotoUrl);                                 
            system.debug(opp);
            oppsData.add(opp);
        }
        system.debug('oppsData++'+oppsData);
        Integer flag = 1;
        Integer j=0,swap=0;
        OpportunityData instOfOppData;
        for(Integer i=0 ; i < oppsData.Size(); i++){
            oppsData[i].data1 = oppsData[i].data1.setScale(2);
        } 
        for(Integer i=0 ; i < oppsData.Size(); i++){
            for(j=0,swap=0;j < oppsData.Size()-1;j++){
                system.debug('oppsData[j].data1++'+oppsData[j].data1);
                system.debug('oppsData[j+1].data1++'+oppsData[j+1].data1);
                if(oppsData[j].data1 < oppsData[j+1].data1){
                    instOfOppData = oppsData[j];
                    oppsData[j] = oppsData[j+1];
                    oppsData[j+1] = instOfOppData; 
                    swap++;
                }
            }
            if(swap==0)
            break;
        }
        system.debug('oppsData+++'+oppsData);
        system.debug('topScorerSec+++'+topScorerSec);
        system.debug('oppsData.size+++'+oppsData.size());
        Integer oppsDataSize = oppsData.size();
        if(topScorerSec!=null){
            if(oppsData.size() > Integer.valueOf(topScorerSec)){
                for(Integer i = oppsDataSize-1 ; i >=  Integer.valueOf(topScorerSec); i--){
                    system.debug('i+++'+i);
                    oppsData.remove(i);
                }
            }
        }
        system.debug('oppsData+++'+oppsData);
        return oppsData; 
    }
    @readonly
    @RemoteAction
    public static List<OpportunityDataSec> loadOppsSec(){
        lstOfQA = Quota_Attainment__c.getall().values();
        map<Id,String> mapUsrId = new map<Id,String>();
        for(Quota_Attainment__c instOfQA : lstOfQA){
            
            if(instOfQA.Role__c.trim() == 'Direct Sales')
            lstDsList.add(instOfQA.User_Id__c);
            
            if(instOfQA.Role__c.trim() == 'AM')
            lstAMList.add(instOfQA.User_Id__c);
            
            mapUsrId.put(instOfQA.User_Id__c,instOfQA.Team_Role__c);
        }
        
        String masterTypeSec = '1) NBB';
        
        List<Opportunity> lstOpp =  new List<Opportunity>();
        lstOpp = [SELECT Id,New_Contract_Total__c,OwnerId,Account.Name,AccountId,Exchange_Rate__c,CurrencyISoCode FROM Opportunity WHERE StageName = 'Closed Won' AND (OwnerId =: lstDsList OR OwnerId =: lstAMList) AND Master_Type__c =: '1) NBB'
                      AND CloseDate >=: system.today().adddays(-7) AND CloseDate <=: system.today() AND CALENDAR_YEAR(CloseDate) =: system.today().Year() AND AccountId != null AND New_Contract_Total__c !=0 AND New_Contract_Total__c > 5000 AND OwnerId != null];
        
        Set<Id> setId = new Set<Id>();
        map<String,Decimal> mapAccId = new map<String,Decimal>();
        map<String,String> mapAccIdOwnerIdAccName = new map<String,String>();
        map<String,Id> mapStrOwnerId = new map<String,Id>();
        
        for(Opportunity instOfOpp : lstOpp ){
            
            setId.add(instOfOpp.OwnerId);
            String strIdAccOwner =  string.valueOf(instOfOpp.AccountId) + string.valueOf(instOfOpp.OwnerId);
            if(mapAccId.ContainsKey(strIdAccOwner)){
                Decimal intContractSum = mapAccId.get(strIdAccOwner);
                if(instOfOpp.Exchange_Rate__c!= null && instOfOpp.Exchange_Rate__c!= 0){
                    intContractSum = intContractSum + instOfOpp.New_Contract_Total__c/instOfOpp.Exchange_Rate__c;
                }else{
                    intContractSum = intContractSum + instOfOpp.New_Contract_Total__c;
                }
                mapAccId.put(strIdAccOwner,intContractSum);
            }else{
                if(instOfOpp.Exchange_Rate__c!= null && instOfOpp.Exchange_Rate__c!= 0){
                    mapAccId.put(strIdAccOwner,instOfOpp.New_Contract_Total__c/instOfOpp.Exchange_Rate__c);
                    mapAccIdOwnerIdAccName.put(strIdAccOwner,instOfOpp.Account.Name);
                    mapStrOwnerId.put(strIdAccOwner,instOfOpp.OwnerId);
                }else{
                    mapAccId.put(strIdAccOwner,instOfOpp.New_Contract_Total__c);
                    mapAccIdOwnerIdAccName.put(strIdAccOwner,instOfOpp.Account.Name);
                    mapStrOwnerId.put(strIdAccOwner,instOfOpp.OwnerId);
                }
            }

        }
        
        List<OpportunityDataSec> oppsDataSec = new List<OpportunityDataSec>();
        Map<Id,User> mapUserPicLink = new Map<Id,user>([SELECT Id,FullPhotoUrl,Name FROM User Where Id =: setId]);
        Integer counter = 0;
        
        for(String instStr : mapAccId.KeySet()){
            OpportunityDataSec opp = new OpportunityDataSec(mapUserPicLink.get(mapStrOwnerId.get(instStr)).Name,mapAccId.get(instStr),mapAccIdOwnerIdAccName.get(instStr),mapUserPicLink.get(mapStrOwnerId.get(instStr)).FullPhotoUrl,mapUsrId.get(mapStrOwnerId.get(instStr)));                                 
            system.debug('oppopp++'+opp);
            oppsDataSec.add(opp);
            //counter++;
        }
        
        OpportunityDataSec instOfOpp;
        Integer flag = 1;
        Integer j=0,swap=0;
        for(Integer i=0 ; i < oppsDataSec.Size(); i++){
            for(j=0,swap=0;j < oppsDataSec.Size()-1;j++){
                //system.debug('lstOpp[j].data1++'+lstOpp[j].data1);
                //system.debug('lstOpp[j+1].data1++'+lstOpp[j+1].data1);
                if(oppsDataSec[j].data1 < oppsDataSec[j+1].data1){
                    instOfOpp = oppsDataSec[j];
                    oppsDataSec[j] = oppsDataSec[j+1];
                    oppsDataSec[j+1] = instOfOpp; 
                    swap++;
                }
            }
            if(swap==0)
            break;
        }
        
        Integer oppsDataSize = oppsDataSec.size();
        Integer topScorerSec = 20;
        if(oppsDataSec.size() > Integer.valueOf(topScorerSec)){
            for(Integer i = oppsDataSize-1 ; i >=  Integer.valueOf(topScorerSec); i--){
                system.debug('i+++'+i);
                oppsDataSec.remove(i);
            }
        }
        
        return oppsDataSec;
    }
    
    // Wrapper class  
    public class OpportunityData {  
        public String userName {get; set;}
        public Decimal data1 {get; set;}
        public Decimal data2 {get; set;}        
        public Decimal data3 {get; set;}        
        public String linkPhoto{get; set;}        
        public OpportunityData(String userName ,Decimal data1,Decimal data2,Decimal data3,String linkPhoto){
            this.userName = userName;
            this.data1 = data1;
            this.data2 = data2;
            this.data3 = data3;
            this.linkPhoto= linkPhoto;
        }  
    }
    public class OpportunityDataSec{  
        public String userName {get; set;}
        public Decimal data1 {get; set;}
        public String data2 {get; set;}               
        public String linkPhoto{get; set;} 
        public String userTeam{get;set;}       
        public OpportunityDataSec(String userName,Decimal data1,String accName,String linkPhoto,String userTeam){
            this.userName = userName;
            this.data1 = data1;
            this.data2 = accName;
            this.linkPhoto = linkPhoto;
            this.userTeam = userTeam;
        }  
    }
    public static map<Id,List<Decimal>> calculation(map<Id,Decimal> mapUserSum,Integer monthFromJs,Integer monthToJs,String masterTypeSec){
        Decimal sum = 0;
        Decimal sumRoom = 0;
        system.debug('mapUserIdMonthlyQNbb++'+mapUserIdMonthlyQNbb);
        map<Id,List<Decimal>> mapOfUser = new map<Id,List<Decimal>>();
        List<Decimal> lstTemp = new List<Decimal>();
        for(Integer i=0 ;i < 12;i++){
            lstTemp.add(0);
        }
        List<Decimal> lstForItr = new List<Decimal>();
        if(masterTypeSec != null){
            if(masterTypeSec == 'PSG'){
                for(Id idOfUser : mapUserSum.keySet()){
                    sum = 0;
                    lstForItr.clear();
                    system.debug('idOfUser+++'+idOfUser);
                    system.debug('mapUserIdMonthlyQPsg++'+mapUserIdMonthlyQPsg);
                    List<Decimal> lstDeci = mapUserIdMonthlyQPsg.get(idOfUser);
                    for(Integer i = monthFromJs ; i<= monthToJs; i++){
                        sum = sum + lstDeci[i]; 
                    }
                    Decimal percenTAchieved = (sum/mapUserSum.get(idOfUser))*100;
                    lstForItr.add(percenTAchieved);
                    lstForItr.add(mapUserSum.get(idOfUser));
                    lstForItr.add(sum);
                    system.debug('lstForItr++'+lstForItr);
                    mapOfUser.put(idOfUser,lstForItr);
                }
            }else if(masterTypeSec == '3) Renewal' ){
                for(Id idOfUser : mapUserSum.keySet()){
                    sum = 0;
                    lstForItr.clear();
                    system.debug('idOfUser+++'+idOfUser);
                    system.debug('mapUserIdMonthlyQNbb++'+mapUserIdMonthlyQNbb);
                    List<Decimal> lstDeci = mapUserIdQuaterlyQRenew.get(idOfUser);
                    for(Integer i = monthFromJs ; i<= monthToJs; i++){
                        sum = sum + lstDeci[i]; 
                    }
                    Decimal percenTAchieved = (sum/mapUserSum.get(idOfUser))*100;
                    lstForItr.add(percenTAchieved);
                    lstForItr.add(mapUserSum.get(idOfUser));
                    lstForItr.add(sum);
                    system.debug('lstForItr++'+lstForItr);
                    mapOfUser.put(idOfUser,lstForItr);
                }
            }else if(masterTypeSec == '1) NBB'){
                for(Id idOfUser : mapUserSum.keySet()){
                    system.debug('mapOfUser250++'+mapOfUser);
                    sum = 0;
                    lstForItr = new List<Decimal>();
                    system.debug('idOfUser+++'+idOfUser);
                    system.debug('mapUserIdMonthlyQNbb++'+mapUserIdMonthlyQNbb);
                    List<Decimal> lstDeci = mapUserIdMonthlyQNbb.get(idOfUser);
                    system.debug('lstDeci++'+lstDeci);
                    system.debug('monthFromJs+'+monthFromJs);
                    system.debug('monthToJs+'+monthToJs);
                    for(Integer i = monthFromJs-1 ; i <= monthToJs-1; i++){
                        sum = sum + lstDeci[i]; 
                    }
                    system.debug('sum++'+sum);
                    system.debug('mapUserSum.get(idOfUser)++'+mapUserSum.get(idOfUser));
                    system.debug('sum/mapUserSum.get(idOfUser)++'+sum/mapUserSum.get(idOfUser));
                    Decimal percenTAchieved = (mapUserSum.get(idOfUser)/sum)*100;
                    system.debug('percenTAchieved+++'+percenTAchieved);
                    system.debug('mapOfUser267++'+mapOfUser);
                    lstForItr.add(percenTAchieved);
                    lstForItr.add(mapUserSum.get(idOfUser));
                    lstForItr.add(sum);
                    system.debug('lstForItr++'+lstForItr);
                    system.debug('idOfUser++'+idOfUser);
                    system.debug('mapOfUserBefore++'+mapOfUser);
                    mapOfUser.put(idOfUser,lstForItr);
                    system.debug('mapOfUser++'+mapOfUser);
                }
            }else if(masterTypeSec == 'NBBPSGRENEWAL'){
                for(Id idOfUser : mapUserSum.keySet()){
                    sum = 0;
                    sumRoom = 0;
                    lstForItr = new List<Decimal>();
                    
                    List<Decimal> lstDeci = new List<Decimal>();
                    if(mapUserIdMonthlyQNbb.containsKey(idOfUser)){
                        lstDeci = mapUserIdMonthlyQNbb.get(idOfUser);
                    }else{
                        lstDeci.addall(lstTemp);
                    }
                    
                    /*List<Decimal> lstDeciSec = new List<Decimal>();
                    if(mapUserIdQuaterlyQRenew.containsKey(idOfUser)){
                        lstDeciSec = mapUserIdQuaterlyQRenew.get(idOfUser);
                    }else{
                        lstDeciSec.addall(lstTemp);
                    }*/
                    
                    List<Decimal> lstDeciThir = new List<Decimal>();
                    
                    if(mapUserIdMonthlyQPsg.containsKey(idOfUser)){
                        lstDeciThir = mapUserIdMonthlyQPsg.get(idOfUser);
                    }else{
                        lstDeciThir.addall(lstTemp);
                    }
                    
                    List<Decimal> lstDeciFif = new List<Decimal>();
                    if(mapUserIdMonthlyCTT.containsKey(idOfUser)){
                        lstDeciFif = mapUserIdMonthlyCTT.get(idOfUser);
                    }else{
                        lstDeciFif.addall(lstTemp);
                    }
                    
                    List<Decimal> lstDeciSix = new List<Decimal>();
                    if(mapUserIdMonthlyCtm.containsKey(idOfUser)){
                        lstDeciSix = mapUserIdMonthlyCtm.get(idOfUser);
                    }else{
                        lstDeciSix.addall(lstTemp);
                    }
                    
                    List<Decimal> lstDeciSev =  new List<Decimal>();
 
                    if(mapUserIdQuaterlyTppRoom.containsKey(idOfUser)){
                        lstDeciSev = mapUserIdQuaterlyTppRoom.get(idOfUser);
                    }else{
                        lstDeciSev.addall(lstTemp);
                    }
                    List<Decimal> lstDeciFor = new List<Decimal>();
                    if(mapUserIdMonthlyBundle.containsKey(idOfUser)){
                        lstDeciFor = mapUserIdMonthlyBundle.get(idOfUser);
                    }else{
                        lstDeciFor.addall(lstTemp);
                    }
                    
                    for(Integer i = monthFromJs-1 ; i <= monthToJs-1; i++){
                        sum = sum + lstDeci[i] + lstDeciThir[i] + lstDeciFif[i] + lstDeciSix[i] + lstDeciFor[i]; 
                    }
                    for(Integer i = monthFromJs-1 ; i <= monthToJs-1; i++){
                        sumRoom =  sumRoom + lstDeciSev[i]; 
                    }
                    /*
                    if(sum !=0){
                        Decimal percenTAchieved = (mapUserSum.get(idOfUser)/sum)*100;
                        lstForItr.add(percenTAchieved);
                        lstForItr.add(mapUserSum.get(idOfUser));
                        lstForItr.add(sum);
                        mapOfUser.put(idOfUser,lstForItr);
                    }*/
                    //if(sum !=0 && sumRoom == 0){
                    system.debug('(mapUserSum.get(idOfUser)++'+mapUserSum.containsKey(idOfUser));
                    system.debug('(mapUserSum.get(idOfUser)++'+mapUserSum.get(idOfUser));
                    system.debug('percenTAchievedRoom++'+mapUserRoomNights.containsKey(idOfUser));
                    system.debug('idOfUser++'+idOfUser);
                    system.debug('sum++'+sum);
                    system.debug('sumRoom++'+sumRoom);
                    if(mapUserSum.containsKey(idOfUser) && !mapUserRoomNights.containsKey(idOfUser)){
                        if(sum !=0){
                        Decimal percenTAchieved = (mapUserSum.get(idOfUser)/sum)*100;
                        lstForItr.add(percenTAchieved);
                        lstForItr.add(mapUserSum.get(idOfUser));
                        lstForItr.add(sum);
                        lstForItr.add(0);
                        lstForItr.add(0);
                        system.debug(idOfUser);
                        system.debug(mapUserSum.get(idOfUser));
                        system.debug(percenTAchieved);
                        mapOfUser.put(idOfUser,lstForItr);
                        }
                    //}else if(sum !=0 && sumRoom != 0){
                    }else if(mapUserSum.containsKey(idOfUser) && mapUserRoomNights.containsKey(idOfUser)){
                        if(sum !=0 && sumRoom != 0){
                        Decimal percenTAchieved = (mapUserSum.get(idOfUser)/sum)*100;
                        Decimal percenTAchievedRoom = (mapUserRoomNights.get(idOfUser)/sumRoom)*100;
                        percenTAchieved = ((percenTAchieved + percenTAchievedRoom)/200)*100;
                        lstForItr.add(percenTAchieved);
                        lstForItr.add(mapUserSum.get(idOfUser));
                        lstForItr.add(sum);
                        //lstForItr.add(mapUserRoomNights.get(idOfUser));
                        //lstForItr.add(sumRoom);
                        mapOfUser.put(idOfUser,lstForItr);
                        }
                    }
                }
            }
        }
        for(Id key: mapOfUser.keyset()){
            system.debug('mapOfUserSec+++'+mapOfUser.get(key));
        }
        return mapOfUser;
    }
}