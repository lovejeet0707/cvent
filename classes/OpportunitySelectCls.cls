/**
//////////////////////////////////////
//      @author Abhishek Pandey     //
/////////////////////////////////////
Version :   1.0
Date : 20th July 2015
Description : Supply data to OpportunitySelect , performs Send to Tract functionality. 
Test Class OpportunityTrgHelperClsTest

Modified BY : Kumud|Date 30 May 2018 | Desc: Remove unuseed fields from the code  
 */
public class OpportunitySelectCls {
    public Boolean flag {get;set;}
    public PageReference test() {
        return null;
    }

    public String strContractNum{get;set;}
    public List<Opportunity> lstOpp {get;set;}
    public List<Opportunity> lstOppSec {get;set;}
    public List<Id> lstIdTract {get;set;}
    public List<Id> lstIdTractSec {get;set;}
    public String SetCancellationStatusVal{get;set;}
    public list<SelectOption> StateList{get;set;}
    public list<String> StateListLabels{get;set;}
    public String JsonMap{get;set;}
    public Map<String,String> resultsMap{get;set;}
    public PageReference Search(){
        if(Apexpages.currentpage().getparameters().get('ContrNum')!= null && strContractNum==null)
        strContractNum = Apexpages.currentpage().getparameters().get('ContrNum');
        StateListLabels = new List<String>();
        StateList = new list<SelectOption>();
        
        resultsMap = new Map<String,String>();
        JsonMap = '';
        Schema.DescribeFieldResult fieldResult = Opportunity.Set_Cancellation_Status__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple){
            StateList.add(new SelectOption(f.getLabel(), f.getValue()));
            StateListLabels.add(f.getLabel());
            system.debug('StateList++'+StateList);
        }
        
        system.debug('strContractNum++'+strContractNum);
        if(strContractNum != null && strContractNum != ''){
            strContractNum = strContractNum.trim();
            lstOpp = new List<Opportunity>();
            lstOppSec = new List<Opportunity>();
            lstIdTract = new List<Id>();
            lstIdTractSec = new List<Id>();
            lstOpp = [SELECT Set_Cancellation_Status__c,Id,Opportunity_Start_Date__c,Opp_End_Date__c,New_Contract_Total__c,Counted_sales_Cancellation_Value__c,Name,Deal_Year__c,StageName FROM Opportunity WHERE Contract_Number_New__c =: strContractNum AND (StageName='Closed Won' OR StageName ='TRACT Clone')  AND StageName!='Tract' Order By Deal_Year__c ASC];
            lstOppSec = [SELECT Year_1_End_Date__c, Year_1_Start_Date__c, Year_1_Value__c,                              // Year_1_Contract_Type__c comment by kd
                                Year_2_End_Date__c, Year_2_Start_Date__c, Year_2_Value__c,                              //Year_2_Contract_Type__c   comment by kd
                                Year_3_End_Date__c, Year_3_Start_Date__c, Year_3_Value__c,                              //Year_3_Contract_Type__c   comment by kd
                                Year_4_End_Date__c, Year_4_Start_Date__c, Year_4_Value__c,                              //Year_4_Contract_Type__c,
                                Year_5_Start_Date__c, Year_5_Value__c,                                                   //Year_5_Contract_Type__c
                                 
                                Contract_Total_Tract__c, 
                                Product_Category_Tract__c,Name,
                                            // Year_2_Opt_out_Date__c,Year_3_Opt_out_Date__c, Year_4_Opt_out_Date__c   //Year_1_Opt_out_Date__c     comment by kd
                                Deal_Booked_In__c,ContractStartDate__c,ContractEndDate__c    //,Year_5_Opt_out_Date__c,
        FROM Opportunity WHERE Contract_Number_New__c =: strContractNum AND StageName ='Tract'];  // Remove Tract_Implementation_Date__c,Year_5_End_Date__c,Year_1_Liquidation_fee__c,Year_2_Liquidation_fee__c,Year_3_Liquidation_fee__c,Year_4_Liquidation_fee__c,Year_5_Liquidation_fee__c [By Kumud :30 May 2018 ]
                                
            
            for(Opportunity instOfOpp : lstOpp){
                //system.debug(instOfOpp.Send_This_To_Tract__c);
              //  if(instOfOpp.Send_This_To_Tract__c == true)
               // lstIdTract.add(instOfOpp.Id);
                
                resultsMap.put(instOfOpp.id,instOfOpp.Set_Cancellation_Status__c);
                lstIdTractSec.add(instOfOpp.Id);
            }
            JsonMap=JSON.serialize(resultsMap);
        }
        return null;
    }

    public PageReference SubmitSec(){
        //List<Opportunity> lstOppUpdt = new List<Opportunity>();
        //for(Opportunity instOfOpp : lstOpp){
            //lstOppUpdt.add(instOfOpp);
            //system.debug(instOfOpp.Send_This_To_Tract__c);
        //}
        //update lstOppUpdt;
        return null;
    }
    
    @RemoteAction
    public static Boolean updateAnnualPickListsOnly(String strVal){
        Boolean updateCheck;
        List<Opportunity> lstOpp = [SELECT id FROM Opportunity WHERE Contract_Number_New__c =: strVal AND StageName!= 'Tract'];
        List<Opportunity> lstOppToUpd = new List<Opportunity>();
        for(Opportunity instOfOpp : lstOpp){
            instOfOpp.Set_Cancellation_Status__c = 'Do not open'; 
            lstOppToUpd.add(instOfOpp);
        }
        
        if(lstOppToUpd.size()>0){
            update lstOppToUpd;
            updateCheck = true;
        }    
        return updateCheck;
    }
    
    @RemoteAction
    public static Boolean updateAnnualOpps(String[] oppIdsCheck,String[] oppIdsUnCheck,String[] oppWithSelectVal){
        system.debug(oppIdsCheck);
        system.debug(oppIdsUnCheck);
        system.debug(oppWithSelectVal);
        map<String,String> mapIdValOfPicklist = new map<String,String>();
        for(String instOfStr : oppWithSelectVal){
            String[] tempStr = instOfStr.split(';');
            mapIdValOfPicklist.put(tempStr[0],tempStr[1]);
        }
        system.debug(mapIdValOfPicklist);
        Boolean updateCheck;
        List<Opportunity> lstOpp = new List<Opportunity>();
        lstOpp =[SELECT Id,Set_Cancellation_Status__c FROM Opportunity WHERE Id=: oppIdsUnCheck Or Id=: oppIdsCheck];
        map<String,Boolean> mapStrBol = new map<String,Boolean>();
        map<String,String> mapStrPickOld = new map<String,String>();
        for(Opportunity instOfOpp : lstOpp){
            //mapStrBol.put(String.valueOf(instOfOpp.Id),instOfOpp.Send_This_To_Tract__c); 
            mapStrPickOld.put(String.valueOf(instOfOpp.Id),instOfOpp.Set_Cancellation_Status__c);
        }
        List<Opportunity> lstOppUpdt = new List<Opportunity>();
        for(String instStr : oppIdsCheck){        
            Opportunity instOpp = new Opportunity();
            instOpp.id = instStr;
            system.debug(instStr);
            system.debug(mapIdValOfPicklist);
            system.debug(mapIdValOfPicklist.containskey(instStr));
            if(mapIdValOfPicklist.containskey(instStr)){
                if(mapIdValOfPicklist.get(instStr)!=mapStrPickOld.get(instStr)){
                    instOpp.Set_Cancellation_Status__c = mapIdValOfPicklist.get(instStr);
                    lstOppUpdt.add(instOpp);
                }
            }
            
            /*if(mapStrBol.get(instStr)!= true){
                //instOpp.Send_This_To_Tract__c = true;
                lstOppUpdt.add(instOpp);
            }*/
        }
        for(String instStr : oppIdsUnCheck){
        
            Opportunity instOpp = new Opportunity();
            instOpp.id = instStr;
            system.debug(instStr);
            system.debug(mapIdValOfPicklist);
            system.debug(mapIdValOfPicklist.containskey(instStr));
            if(mapIdValOfPicklist.containskey(instStr)){
                if(mapIdValOfPicklist.get(instStr) != mapStrPickOld.get(instStr)){
                    instOpp.Set_Cancellation_Status__c = mapIdValOfPicklist.get(instStr);
                    lstOppUpdt.add(instOpp);
                }
            }
            
            /*if(mapStrBol.get(instStr)!= false){
               // instOpp.Send_This_To_Tract__c = false;
                lstOppUpdt.add(instOpp);
            }*/
        }
        
        if(lstOppUpdt.size()>0){
            update lstOppUpdt;
            updateCheck = true;
        }
        
        return updateCheck;
    }

    public OpportunitySelectCls(){
        flag = false;
        Map<String, Superuser__c> mcs = Superuser__c.getAll();
        for(Superuser__c strVal : mcs.values()){
            if(UserInfo.getUserId() == strVal.Id__c)
            flag =  true;
        }
        lstOpp = new List<Opportunity>();
        lstOppSec = new List<Opportunity>();
        lstIdTract = new List<Id>();
    }
}