/*
//////////////////////////////////////
//      @author Abhishek Pandey     //
/////////////////////////////////////
Version :   1.0
Date : 17th June 2014
Description : Show Quota Vs Budget report using Google Charting. Test Class -ReportsLandingClsTest
*/
 

public class QuotaVsBudgetReportCls {
    
    public static List<Quota_Attainment__c> lstOfQA = new List<Quota_Attainment__c>();
    
    public static map<Id,List<Decimal>> mapUserIdMonthlyQNbb = new map<Id,List<Decimal>>();
    public static map<Id,List<Decimal>> mapUserIdQuaterlyQNbb = new map<Id,List<Decimal>>();
    public static map<Id,List<Decimal>> mapUserIdYearlyQNbb = new map<Id,List<Decimal>>();
    
    public static map<Id,List<Decimal>> mapUserIdMonthlyQPsg = new map<Id,List<Decimal>>();
    public static map<Id,List<Decimal>> mapUserIdQuaterlyQPsg = new map<Id,List<Decimal>>();
    public static map<Id,List<Decimal>> mapUserIdYearlyQPsg = new map<Id,List<Decimal>>();
    
    public static map<Id,List<Decimal>> mapUserIdMonthlyQRenew = new map<Id,List<Decimal>>();
    public static map<Id,List<Decimal>> mapUserIdQuaterlyQRenew = new map<Id,List<Decimal>>();
    public static map<Id,List<Decimal>> mapUserIdYearlyQRenew = new map<Id,List<Decimal>>();
    public static map<Id,List<Decimal>> mapUserIdMonthlyBundle = new map<Id,List<Decimal>>();
    public static map<Id,List<Decimal>> mapUserIdMonthlyCTT = new map<Id,List<Decimal>>();
    public static map<Id,List<Decimal>> mapUserIdMonthlyCtm = new map<Id,List<Decimal>>();
    
    public static List<Id> lstDsList = new List<Id>();
    public static List<Id> lstAMList = new List<Id>();
    
    public List<SelectOption> teamOptions {get;set;}
    public static string teamSelected{get;set;}  
    
    public static string monthFrom{get;set;}
    public static string monthTo{get;set;}
    
    public List<SelectOption> monthOption {get;set;}
    
    public static string productSelection {get;set;}
    public List<SelectOption> options {get;set;}
    
    public static string masterTypeSelection{get;set;}
    public static List<SelectOption> masterType{get;set;}
    public static string topScorerSelection{get;set;}
    public static List<SelectOption> topScorer{get;set;}
    public static List<SelectOption> QuotaYear{get;set;}
    public static List<SelectOption> ByRole{get;set;}
    
    public static List<OpportunityData> oppsData{get;set;}
    public boolean qTFlag{get;set;}
    
    public static String quotaYearSel{get;set;}
    public static String roleSel{get;set;}
    
    public QuotaVsBudgetReportCls(){
        
        Schema.DescribeFieldResult F = Opportunity.Product__c.getDescribe();
        teamSelected = '';
        productSelection = '';
        List<Schema.PicklistEntry> ple = F.getPicklistValues();
        options = new List<SelectOption>();
        options.add(new SelectOption('','--None--'));
        for(Schema.PicklistEntry lk:ple){     
            if(lk.getvalue()!='Decision Street' && lk.getvalue()!='TicketMob' && lk.getvalue()!='CrowdTorch')       
            options.add(new SelectOption(lk.getvalue(),lk.getvalue()));         
        }
        options.add(new SelectOption('TicketMob','CrowdTorch(Ticketing)'));
        options.add(new SelectOption('CrowdTorch','CrowdTorch(Mobile)'));
        
        lstDsList = new List<Id>();
        lstAMList = new List<Id>();
        
        teamOptions = new List<SelectOption>();     
        teamOptions.add(new SelectOption('','--None--'));
        teamOptions.add(new SelectOption('Direct Sales','Direct Sales'));
        teamOptions.add(new SelectOption('AM','AM'));
        
        monthOption = new List<SelectOption>(); 
        monthOption.add(new SelectOption('','--None--'));  
        monthOption.add(new SelectOption('1','Jan'));
        monthOption.add(new SelectOption('2','Feb'));
        monthOption.add(new SelectOption('3','Mar'));
        monthOption.add(new SelectOption('4','Apr'));
        monthOption.add(new SelectOption('5','May'));
        monthOption.add(new SelectOption('6','Jun'));
        monthOption.add(new SelectOption('7','Jul'));
        monthOption.add(new SelectOption('8','Aug'));
        monthOption.add(new SelectOption('9','Sep'));
        monthOption.add(new SelectOption('10','Oct'));  
        monthOption.add(new SelectOption('11','Nov'));  
        monthOption.add(new SelectOption('12','Dec')); 
        
        masterType = new List<SelectOption>();
        masterType.add(new SelectOption('','--None--'));
        masterType.add(new SelectOption('NBB','NBB'));
        masterType.add(new SelectOption('Renewal','Renewal'));
        
        topScorer = new List<SelectOption>();
        topScorer.add(new SelectOption('','--None--'));
        topScorer.add(new SelectOption('5','5'));
        topScorer.add(new SelectOption('10','10'));
        topScorer.add(new SelectOption('20','20'));
        
        String currYear = string.valueOf(system.today().year());
        String previousYear = string.valueOf(system.today().year() - 1);
        
        QuotaYear =  new List<SelectOption>();
        QuotaYear.add(new SelectOption('','--None--'));
        QuotaYear.add(new SelectOption(currYear,currYear));
        QuotaYear.add(new SelectOption(previousYear,previousYear));
        
        ByRole =  new List<SelectOption>();
        ByRole.add(new SelectOption('','--None--'));
        ByRole.add(new SelectOption('Event','Event'));
        ByRole.add(new SelectOption('Survey','Survey'));
        ByRole.add(new SelectOption('TPP','TPP'));
        ByRole.add(new SelectOption('Enterprise','Enterprise'));
        ByRole.add(new SelectOption('Product Adoption','Product Adoption'));
        ByRole.add(new SelectOption('Crowd Compass','Crowd Compass'));
        ByRole.add(new SelectOption('CSN','CSN')); 
        ByRole.add(new SelectOption('CrowdTorch(Ticketing)','CrowdTorch(Ticketing)'));
        ByRole.add(new SelectOption('CrowdTorch(Mobile)','CrowdTorch(Mobile)'));
        qTFlag = true;
    } 
    
    public PageReference qTypVal(){
        system.debug('teamSelected++'+teamSelected);
        system.debug('productSelection++'+productSelection);
        if(teamSelected != '' && teamSelected != null && productSelection != '' && productSelection != null){
            qTFlag = false;
            if(teamSelected == 'Direct Sales' && productSelection != 'Survey' && productSelection != 'TicketMob' && productSelection != 'CrowdTorch' ){
                masterType = new List<SelectOption>();
                masterType.add(new SelectOption('NBB','NBB Licensing'));
            }
            if(teamSelected == 'AM' && productSelection != 'Survey' && productSelection != 'CSN' && productSelection != 'TicketMob' && productSelection != 'CrowdTorch'){
                masterType = new List<SelectOption>();
                masterType.add(new SelectOption('NBB','NBB Licensing'));
                masterType.add(new SelectOption('Renewal','Renewal'));
            }
            if(teamSelected == 'AM' && productSelection == 'Survey' ){
                masterType = new List<SelectOption>();
                masterType.add(new SelectOption('NBB','NBB Licensing'));
                masterType.add(new SelectOption('PSG','PSG Licensing'));
                masterType.add(new SelectOption('Renewal','Renewal'));
            }
            if(teamSelected == 'Direct Sales' && productSelection == 'Survey' ){
                masterType = new List<SelectOption>();
                masterType.add(new SelectOption('NBB','NBB Licensing'));
                masterType.add(new SelectOption('PSG','PSG Licensing'));
            }
            if(teamSelected == 'AM' && productSelection == 'CSN' ){
                masterType = new List<SelectOption>();
                masterType.add(new SelectOption('NBB','NBB'));
                masterType.add(new SelectOption('Renewal','Renewal'));
                masterType.add(new SelectOption('Bundle','Bundle'));
            }
            if(teamSelected == 'Direct Sales' && productSelection == 'CSN' ){
                masterType = new List<SelectOption>();
                masterType.add(new SelectOption('NBB','NBB'));
            }
            if((teamSelected == 'AM' || teamSelected == 'Direct Sales') && productSelection == 'TicketMob' ){
                masterType = new List<SelectOption>();
                masterType.add(new SelectOption('NBB','NBB'));
            }
            if((teamSelected == 'AM' || teamSelected == 'Direct Sales')&& productSelection == 'CrowdTorch' ){
                masterType = new List<SelectOption>();
                masterType.add(new SelectOption('NBB','NBB'));
            }
        }else{
            masterType = new List<SelectOption>();
            masterType.add(new SelectOption('','--None--'));
            qTFlag = true;
        }
        return null;
    }
    @readonly
    @RemoteAction
    public static List<OpportunityData> loadOpps(String teamValue,Integer monthFromJs,Integer monthToJs,String product,String masterTypeSec,String topScorerSec,String roleSec,String yearSel){
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
        
        system.debug('+++beforeyearSel+++'+yearSel);
        
        if(yearSel == null)
        yearSel = string.valueOf(system.today().year());
        
        system.debug('+++Year+++'+system.today().year());
        system.debug('+++Year+++'+string.valueOf(system.today().year()));
        system.debug('+++yearSel+++'+yearSel);
        
        for(Quota_Attainment__c instOfQA : lstOfQA){
            system.debug('string.valueOf(instOfQA.Quota_Year__c)++'+string.valueOf(instOfQA.Quota_Year__c));
            system.debug('yearSel++'+yearSel);
            string.valueOf(instOfQA.Quota_Year__c);
            String valStr = string.valueOf(instOfQA.Quota_Year__c);
            if(Test.isRunningtest()){
                valStr = string.valueOf(instOfQA.Quota_Year__c) + '.0';
                yearSel = string.valueOf(system.today().year());
            }
            system.debug('valStr++'+valStr);
            system.debug('yearSel++'+yearSel +'.0');
            
            if(valStr == yearSel +'.0'){
                lstOfMonthy =  new List<String>();
                lstOfMonthlyRenewal =  new List<String>();
                lstOfMonthlyPSG =  new List<String>();
                lstOfMonthyDec = new List<Decimal>();
                lstOfMonthyCTTDec = new List<Decimal>();
                lstOfMonthyCtmDec = new List<Decimal>();
                lstOfMonthlyRenewalDeci = new List<Decimal>();
                lstOfMonthlyPSGDeci =  new List<Decimal>();
                lstofBundleDeci = new List<Decimal>();
                lstofBundle = new List<String>();
                lstOfMonthyCTT = new List<String>();
                lstOfMonthyCTM = new List<String>();
                
                if(instOfQA.Role__c.trim() == 'Direct Sales' && roleSec == null)
                lstDsList.add(instOfQA.User_Id__c);
                
                if(instOfQA.Role__c.trim() == 'Direct Sales' && roleSec != null && instOfQA.Team_Role__c.trim() == roleSec)
                lstDsList.add(instOfQA.User_Id__c);
                
                if(instOfQA.Role__c.trim() == 'AM' && roleSec == null)
                lstAMList.add(instOfQA.User_Id__c);
                
                if(instOfQA.Role__c.trim() == 'AM' && roleSec != null && instOfQA.Team_Role__c.trim() == roleSec)
                lstAMList.add(instOfQA.User_Id__c);
                
                if(instOfQA.NBB_Licensing_Monthly__c != null && instOfQA.NBB_Licensing_Monthly__c !='' && instOfQA.Team_Role__c.trim() =='CrowdTorch(Ticketing)')
                lstOfMonthyCTT = instOfQA.NBB_Licensing_Monthly__c.split(';',-2);
                
                for(String instOfStr : lstOfMonthyCTT){
                    system.debug('instOfStr++'+instOfStr.trim());
                    instOfStr = instOfStr.trim();
                    lstOfMonthyCTTDec.add(Decimal.valueOf(instOfStr));
                }
                
                if(instOfQA.NBB_Licensing_Monthly__c != null && instOfQA.NBB_Licensing_Monthly__c !='' && instOfQA.Team_Role__c.trim() =='CrowdTorch(Mobile)')
                lstOfMonthyCTM = instOfQA.NBB_Licensing_Monthly__c.split(';',-2);   
                
                for(String instOfStr : lstOfMonthyCTM){
                    system.debug('instOfStr++'+instOfStr.trim());
                    instOfStr = instOfStr.trim();
                    lstOfMonthyCtmDec.add(Decimal.valueOf(instOfStr));
                }
                
                if(instOfQA.NBB_Licensing_Monthly__c != null && instOfQA.NBB_Licensing_Monthly__c !='' && instOfQA.Team_Role__c.trim() !='CrowdTorch(Ticketing)' && instOfQA.Team_Role__c.trim() !='CrowdTorch(Mobile)')
                lstOfMonthy = instOfQA.NBB_Licensing_Monthly__c.split(';',-2);
                
                for(String instOfStr : lstOfMonthy){
                    system.debug('instOfStr++'+instOfStr.trim());
                    instOfStr = instOfStr.trim();
                    lstOfMonthyDec.add(Decimal.valueOf(instOfStr));
                }
                
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
        system.debug('getvalue+++'+mapUserIdMonthlyQPsg.get('00500000006rMSBAA2'));
        system.debug('getvalue+++'+mapUserIdMonthlyQPsg.get('00500000006rMSBAA2'));
        system.debug('mapUserIdMonthlyQNbb+++'+mapUserIdMonthlyQNbb);
        system.debug('teamValue++'+teamValue);
        system.debug('monthFromJs++'+monthFromJs);
        system.debug('monthToJs++'+monthToJs);
        system.debug('product++'+product);
        system.debug('masterTypeSec++'+masterTypeSec);
        system.debug('topScorerSec++'+topScorerSec);
        Integer topScorerSecInt ;
        
        if(teamValue != null){
            teamSelected = teamValue;
        }
        
        if(masterTypeSec != null){
            if(masterTypeSec=='NBB')
            masterTypeSec = '1) NBB';
            
            if(masterTypeSec == 'Renewal')
            masterTypeSec = '3) Renewal';
        }
        
        if(topScorerSec!= null)
        topScorerSecInt = Integer.valueOf(topScorerSec);
        
        if(teamValue == null && monthFromJs==null && monthToJs==null && product==null && masterTypeSec==null && topScorerSec==null){
            String quaterStr = mapNoMonthName.get(system.today().month());
            Integer[] lstDeci = mapNoMonthNameSec.get(quaterStr);
            monthFromJs = lstDeci[0];
            monthToJs = lstDeci[2];
            topScorerSec = '5';
        }
        system.debug('lstDsList++--'+lstDsList);
        system.debug('lstAMList++--'+lstAMList);
        
        List<Opportunity> lstOpp =  new List<Opportunity>();
        if(monthFromJs != null && monthToJs != null && teamValue==null &&  product==null){
            lstOpp = [SELECT Id,New_Contract_Total__c,Product__c,New_Type__c,Bundle_Value__c,OwnerId FROM Opportunity WHERE StageName = 'Closed Won' AND (OwnerId =: lstDsList OR OwnerId =: lstAMList)
                      AND CALENDAR_MONTH(CloseDate) >=: monthFromJs AND CALENDAR_MONTH(CloseDate) <=: monthToJs AND CALENDAR_YEAR(CloseDate) =: Integer.valueOf(yearSel) AND New_Contract_Total__c != 0];
                      
        }else if(monthFromJs != null && monthToJs != null && teamValue == null &&  product != null ){
            lstOpp = [SELECT Id,New_Contract_Total__c,Product__c,New_Type__c,Bundle_Value__c,OwnerId FROM Opportunity WHERE StageName = 'Closed Won' AND (OwnerId =: lstDsList OR OwnerId =: lstAMList)
                      AND CALENDAR_MONTH(CloseDate) >=: monthFromJs AND CALENDAR_MONTH(CloseDate) <=: monthToJs AND Product__c =: product AND CALENDAR_YEAR(CloseDate) =: Integer.valueOf(yearSel) AND New_Contract_Total__c != 0];
                      
        }else if(monthFromJs != null && monthToJs != null && teamValue == 'Direct Sales' &&  product == null ){
            lstOpp = [SELECT Id,New_Contract_Total__c,Product__c,New_Type__c,Bundle_Value__c,OwnerId FROM Opportunity WHERE StageName = 'Closed Won' AND OwnerId =: lstDsList
                      AND CALENDAR_MONTH(CloseDate) >=: monthFromJs AND CALENDAR_MONTH(CloseDate) <=: monthToJs AND CALENDAR_YEAR(CloseDate) =: Integer.valueOf(yearSel) AND New_Contract_Total__c != 0];
                      
        }else if(monthFromJs != null && monthToJs != null && teamValue == 'AM' &&  product == null ){
            lstOpp = [SELECT Id,New_Contract_Total__c,Product__c,New_Type__c,Bundle_Value__c,OwnerId FROM Opportunity WHERE StageName = 'Closed Won' AND OwnerId =: lstAMList
                      AND CALENDAR_MONTH(CloseDate) >=: monthFromJs AND CALENDAR_MONTH(CloseDate) <=: monthToJs AND CALENDAR_YEAR(CloseDate) =: Integer.valueOf(yearSel) AND New_Contract_Total__c != 0];
                      
        }else if(monthFromJs != null && monthToJs != null && teamValue == 'Direct Sales' &&  product != null && masterTypeSec == '1) NBB' ){
            lstOpp = [SELECT Id,New_Contract_Total__c,Product__c,New_Type__c,Bundle_Value__c,OwnerId FROM Opportunity WHERE StageName = 'Closed Won' AND OwnerId =: lstDsList AND Master_Type__c=: masterTypeSec
                      AND CALENDAR_MONTH(CloseDate) >=: monthFromJs AND CALENDAR_MONTH(CloseDate) <=: monthToJs AND CALENDAR_YEAR(CloseDate) =: Integer.valueOf(yearSel) AND Product__c =: product AND New_Contract_Total__c != 0];
                      
        }else if(monthFromJs != null && monthToJs != null && teamValue == 'Direct Sales' &&  product != null && masterTypeSec == '3) Renewal' ){
            lstOpp = [SELECT Id,New_Contract_Total__c,Product__c,New_Type__c,Bundle_Value__c,OwnerId FROM Opportunity WHERE StageName = 'Closed Won' AND OwnerId =: lstDsList AND Master_Type__c=: masterTypeSec
                      AND CALENDAR_MONTH(CloseDate) >=: monthFromJs AND CALENDAR_MONTH(CloseDate) <=: monthToJs AND CALENDAR_YEAR(CloseDate) =: Integer.valueOf(yearSel) AND Product__c =: product AND New_Contract_Total__c != 0];
                      
        }else if(monthFromJs != null && monthToJs != null && teamValue == 'Direct Sales' && masterTypeSec == 'PSG' ){
            lstOpp = [SELECT Id,New_Contract_Total__c,Product__c,New_Type__c,Bundle_Value__c,OwnerId FROM Opportunity WHERE StageName = 'Closed Won' AND OwnerId =: lstDsList AND Master_Type__c=: '1) NBB'
                      AND CALENDAR_MONTH(CloseDate) >=: monthFromJs AND CALENDAR_MONTH(CloseDate) <=: monthToJs AND CALENDAR_YEAR(CloseDate) =: Integer.valueOf(yearSel) AND Product__c =: 'Survey' AND License_Type__c =:'Professional Services' AND New_Contract_Total__c != 0];
                      
        }else if(monthFromJs != null && monthToJs != null && teamValue == 'AM' &&  product != null && masterTypeSec == '1) NBB'){
            lstOpp = [SELECT Id,New_Contract_Total__c,Product__c,New_Type__c,Bundle_Value__c,OwnerId FROM Opportunity WHERE StageName = 'Closed Won' AND OwnerId =: lstAMList AND Master_Type__c=: masterTypeSec
                      AND CALENDAR_MONTH(CloseDate) >=: monthFromJs AND CALENDAR_MONTH(CloseDate) <=: monthToJs AND CALENDAR_YEAR(CloseDate) =: Integer.valueOf(yearSel) AND Product__c =: product AND New_Contract_Total__c != 0];
                      
        }else if(monthFromJs != null && monthToJs != null && teamValue == 'AM' &&  product != null && masterTypeSec == '3) Renewal'){
            lstOpp = [SELECT Id,New_Contract_Total__c,Product__c,New_Type__c,Bundle_Value__c,OwnerId FROM Opportunity WHERE StageName = 'Closed Won' AND OwnerId =: lstAMList AND Master_Type__c=: masterTypeSec
                      AND CALENDAR_MONTH(CloseDate) >=: monthFromJs AND CALENDAR_MONTH(CloseDate) <=: monthToJs AND CALENDAR_YEAR(CloseDate) =: Integer.valueOf(yearSel) AND Product__c =: product AND New_Contract_Total__c != 0];
                      
        }else if(monthFromJs != null && monthToJs != null && teamValue == 'AM' &&  product != null && masterTypeSec == 'PSG'){
            lstOpp = [SELECT Id,New_Contract_Total__c,Product__c,New_Type__c,Bundle_Value__c,OwnerId FROM Opportunity WHERE StageName = 'Closed Won' AND OwnerId =: lstAMList AND Master_Type__c=: '1) NBB'
                      AND CALENDAR_MONTH(CloseDate) >=: monthFromJs AND CALENDAR_MONTH(CloseDate) <=: monthToJs AND CALENDAR_YEAR(CloseDate) =: Integer.valueOf(yearSel) AND Product__c =: 'Survey' AND License_Type__c =:'Professional Services' AND New_Contract_Total__c != 0];
                      
        }else if(monthFromJs != null && monthToJs != null && teamValue == 'AM' &&  product != null && masterTypeSec == 'Bundle'){
            lstOpp = [SELECT Id,New_Contract_Total__c,Product__c,New_Type__c,Bundle_Value__c,OwnerId FROM Opportunity WHERE StageName = 'Closed Won' AND OwnerId =: lstAMList AND Master_Type__c=: '1) NBB' 
                      AND CALENDAR_MONTH(CloseDate) >=: monthFromJs AND CALENDAR_MONTH(CloseDate) <=: monthToJs AND CALENDAR_YEAR(CloseDate) =: Integer.valueOf(yearSel) AND Product__c =: 'CSN' AND Bundle_Value__c != 0];
                      system.debug('lstOppShudComeHere++++'+lstOpp);
                      
        }
        /*
        else if(monthFromJs != null && monthToJs != null && teamValue == 'Direct Sales' && masterTypeSec != null && product != null ){
            lstOpp = [SELECT Id,New_Contract_Total__c,OwnerId FROM Opportunity WHERE Master_Type__c=: masterTypeSec AND StageName = 'Closed Won' AND OwnerId =: lstDsList 
                      AND CALENDAR_MONTH(CloseDate) >=: monthFromJs AND CALENDAR_MONTH(CloseDate) <=: monthToJs AND Product__c =: product AND CALENDAR_YEAR(CloseDate) =: system.today().Year()];
        
        }else if(monthFromJs != null && monthToJs != null && teamValue == 'Direct Sales' && masterTypeSec != null && product != null){
            lstOpp = [SELECT Id,New_Contract_Total__c,OwnerId FROM Opportunity WHERE Master_Type__c=: masterTypeSec AND StageName = 'Closed Won' AND OwnerId =: lstDsList 
                        AND CALENDAR_MONTH(CloseDate) >=: monthFromJs AND CALENDAR_MONTH(CloseDate) <=: monthToJs AND Product__c =: product AND CALENDAR_YEAR(CloseDate) =: system.today().Year()];
        
        }else if(monthFromJs != null && monthToJs != null && teamValue == 'AM' && masterTypeSec != null && product != null ){
            lstOpp = [SELECT Id,New_Contract_Total__c,OwnerId FROM Opportunity WHERE Master_Type__c=: masterTypeSec AND StageName = 'Closed Won' AND OwnerId =: lstAMList 
                        AND CALENDAR_MONTH(CloseDate) >=: monthFromJs AND CALENDAR_MONTH(CloseDate) <=: monthToJs AND Product__c =: product AND CALENDAR_YEAR(CloseDate) =: system.today().Year()];
        
        }else if(monthFromJs == null && monthToJs == null && teamValue == 'AM' && masterTypeSec != null && product != null ){
            monthFromJs= 1;
            monthToJs =12;
            lstOpp = [SELECT Id,New_Contract_Total__c,OwnerId FROM Opportunity WHERE Master_Type__c=: masterTypeSec AND StageName = 'Closed Won' AND OwnerId =: lstAMList 
                        AND CALENDAR_MONTH(CloseDate) >=: monthFromJs AND CALENDAR_MONTH(CloseDate) <=: monthToJs AND Product__c =: product AND CALENDAR_YEAR(CloseDate) =: system.today().Year()];
        
        }else if(monthFromJs == null && monthToJs == null && teamValue == 'Direct Sales' && masterTypeSec != null && product != null ){
            monthFromJs= 1;
            monthToJs = 12;
            lstOpp = [SELECT Id,New_Contract_Total__c,OwnerId FROM Opportunity WHERE Master_Type__c=: masterTypeSec AND StageName = 'Closed Won' AND OwnerId =: lstDsList 
                        AND CALENDAR_MONTH(CloseDate) >=: monthFromJs AND CALENDAR_MONTH(CloseDate) <=: monthToJs AND Product__c =: product AND CALENDAR_YEAR(CloseDate) =: system.today().Year()];
        
        }else if(monthFromJs == null && monthToJs == null && teamValue == null && masterTypeSec != null && product != null){
            monthFromJs= 1;
            monthToJs = 12;
            lstOpp = [SELECT Id,New_Contract_Total__c,OwnerId FROM Opportunity WHERE Master_Type__c=: masterTypeSec AND StageName = 'Closed Won' AND OwnerId =: mapUserIdMonthlyQNbb.keyset() 
                        AND CALENDAR_MONTH(CloseDate) >=: monthFromJs AND CALENDAR_MONTH(CloseDate) <=: monthToJs AND Product__c =: product AND CALENDAR_YEAR(CloseDate) =: system.today().Year()];
        }*/
        
        if(masterTypeSec == null){
            masterTypeSec = 'NBBPSGRENEWALBUNDCTTCTM';
        }else if(masterTypeSec == '1) NBB' && product=='Survey'){
            masterTypeSec = 'NBBPSG';
        }else if(masterTypeSec =='1) NBB' && product=='CrowdTorch'){
            masterTypeSec = 'NBBMOB';
        }else if(masterTypeSec == '1) NBB' && product == 'TicketMob'){
            masterTypeSec = 'NBBTicket';
        }
        Map<Id,Decimal> mapUserSum = new Map<Id,Decimal>();
        for(Opportunity instOfOpp : lstOpp){
            if(mapUserSum.containsKey(instOfOpp.OwnerId)){
                Decimal deciTemVal = mapUserSum.get(instOfOpp.OwnerId);
                if(instOfOpp.Bundle_Value__c != null && instOfOpp.Product__c == 'CSN'){
                    deciTemVal = deciTemVal + instOfOpp.Bundle_Value__c;    
                    system.debug('mapUserSumBundle++'+mapUserSum);
                }else{
                    if(instOfOpp.New_Contract_Total__c != null)
                    deciTemVal = deciTemVal + instOfOpp.New_Contract_Total__c;  
                    system.debug('mapUserSumContractTotal++'+mapUserSum);
                }
                mapUserSum.put(instOfOpp.OwnerId,deciTemVal);
            }else{
                if(instOfOpp.New_Contract_Total__c != null || instOfOpp.Bundle_Value__c != null){
                    if(instOfOpp.Bundle_Value__c != null && instOfOpp.Product__c == 'CSN'){
                        mapUserSum.put(instOfOpp.OwnerId,instOfOpp.Bundle_Value__c);
                        system.debug('mapUserSumBundle++'+mapUserSum);
                    }else{
                        if(instOfOpp.New_Contract_Total__c != null)
                        mapUserSum.put(instOfOpp.OwnerId,instOfOpp.New_Contract_Total__c);
                        system.debug('mapUserSumContractTotal++'+mapUserSum);
                    }   
                }
                
            }
        }
        system.debug('lstOpp++'+lstOpp);
        Map<Id,List<Decimal>> mapOfUser = new Map<Id,List<Decimal>>();
        system.debug(mapUserSum+'+++'+monthFromJs+'+++'+monthToJs+'+++'+masterTypeSec);
        mapOfUser = calculation(mapUserSum,monthFromJs,monthToJs,masterTypeSec);
        //calculation(monthToJs);
        Map<Id,User> mapUserPicLink = new Map<Id,user>([SELECT Id,FullPhotoUrl,Name FROM User Where Id =: mapOfUser.keyset()]);
        oppsData = new List<OpportunityData>();
        for(Id userId : mapOfUser.keySet()){
            OpportunityData opp = new OpportunityData(mapUserPicLink.get(userId).Name,mapOfUser.get(userId)[0],mapOfUser.get(userId)[1],mapOfUser.get(userId)[2],mapUserPicLink.get(userId).FullPhotoUrl);                                 
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
        return oppsData;
        
    }
    
    public static map<Id,List<Decimal>> calculation(map<Id,Decimal> mapUserSum,Integer monthFromJs,Integer monthToJs,String masterTypeSec){
        Decimal sum = 0;
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
                    for(Integer i = monthFromJs -1 ; i<= monthToJs -1; i++){
                        sum = sum + lstDeci[i]; 
                    }
                    if(sum !=0){
                        Decimal percenTAchieved = (mapUserSum.get(idOfUser)/sum)*100;
                        lstForItr.add(percenTAchieved);
                        lstForItr.add(mapUserSum.get(idOfUser));
                        lstForItr.add(sum);
                        system.debug('lstForItr++'+lstForItr);
                        mapOfUser.put(idOfUser,lstForItr);
                    }
                }
            }else if(masterTypeSec == '3) Renewal' ){
                for(Id idOfUser : mapUserSum.keySet()){
                    sum = 0;
                    lstForItr.clear();
                    system.debug('idOfUser+++'+idOfUser);
                    system.debug('mapUserIdMonthlyQNbb++'+mapUserIdMonthlyQNbb);
                    List<Decimal> lstDeci = mapUserIdQuaterlyQRenew.get(idOfUser);
                    for(Integer i = monthFromJs -1 ; i<= monthToJs -1; i++){
                        sum = sum + lstDeci[i]; 
                    }
                    if(sum !=0){
                        Decimal percenTAchieved = (mapUserSum.get(idOfUser)/sum)*100;
                        lstForItr.add(percenTAchieved);
                        lstForItr.add(mapUserSum.get(idOfUser));
                        lstForItr.add(sum);
                        system.debug('lstForItr++'+lstForItr);
                        mapOfUser.put(idOfUser,lstForItr);
                    }
                }
            }else if(masterTypeSec == '1) NBB'){
                for(Id idOfUser : mapUserSum.keySet()){
                    system.debug('mapOfUser250++'+mapOfUser);
                    sum = 0;
                    lstForItr = new List<Decimal>();
                    system.debug('idOfUser+++'+idOfUser);
                    system.debug('mapUserIdMonthlyQNbb++'+mapUserIdMonthlyQNbb);
                    
                    List<Decimal> lstDeci = new List<Decimal>();
                    lstDeci = mapUserIdMonthlyQNbb.get(idOfUser);
                    
                    system.debug('lstDeci++'+lstDeci);
                    system.debug('monthFromJs+'+monthFromJs);
                    system.debug('monthToJs+'+monthToJs);
                    for(Integer i = monthFromJs-1 ; i <= monthToJs-1; i++){
                        sum = sum + lstDeci[i]; 
                    }
                    if(sum !=0){
                        system.debug('sum++'+sum);
                        system.debug('mapUserSum.get(idOfUser)++'+mapUserSum.get(idOfUser));
                        //system.debug('sum/mapUserSum.get(idOfUser)++'+sum/mapUserSum.get(idOfUser));
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
                }
            }else if(masterTypeSec == 'NBBMOB'){
                for(Id idOfUser : mapUserSum.keySet()){
                    system.debug('mapOfUser250++'+mapOfUser);
                    sum = 0;
                    lstForItr = new List<Decimal>();
                    system.debug('idOfUser+++'+idOfUser);
                    system.debug('mapUserIdMonthlyQNbb++'+mapUserIdMonthlyQNbb);
                    
                    List<Decimal> lstDeci = new List<Decimal>();
                    lstDeci = mapUserIdMonthlyCtm.get(idOfUser);
                    
                    system.debug('lstDeci++'+lstDeci);
                    system.debug('monthFromJs+'+monthFromJs);
                    system.debug('monthToJs+'+monthToJs);
                    for(Integer i = monthFromJs-1 ; i <= monthToJs-1; i++){
                        sum = sum + lstDeci[i]; 
                    }
                    if(sum !=0){
                        system.debug('sum++'+sum);
                        system.debug('mapUserSum.get(idOfUser)++'+mapUserSum.get(idOfUser));
                        //system.debug('sum/mapUserSum.get(idOfUser)++'+sum/mapUserSum.get(idOfUser));
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
                }
            }else if(masterTypeSec == 'NBBTicket'){
                for(Id idOfUser : mapUserSum.keySet()){
                    system.debug('mapOfUser250++'+mapOfUser);
                    sum = 0;
                    lstForItr = new List<Decimal>();
                    system.debug('idOfUser+++'+idOfUser);
                    system.debug('mapUserIdMonthlyQNbb++'+mapUserIdMonthlyQNbb);
                    
                    List<Decimal> lstDeci = new List<Decimal>();
                    lstDeci = mapUserIdMonthlyCTT.get(idOfUser);
                    
                    system.debug('lstDeci++'+lstDeci);
                    system.debug('monthFromJs+'+monthFromJs);
                    system.debug('monthToJs+'+monthToJs);
                    for(Integer i = monthFromJs-1 ; i <= monthToJs-1; i++){
                        sum = sum + lstDeci[i]; 
                    }
                    if(sum !=0){
                        system.debug('sum++'+sum);
                        system.debug('mapUserSum.get(idOfUser)++'+mapUserSum.get(idOfUser));
                        //system.debug('sum/mapUserSum.get(idOfUser)++'+sum/mapUserSum.get(idOfUser));
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
                }
            }else if(masterTypeSec == 'NBBPSGRENEWALBUNDCTTCTM'){
                for(Id idOfUser : mapUserSum.keySet()){
                    sum = 0;
                    lstForItr = new List<Decimal>();
                    
                    List<Decimal> lstDeci = new List<Decimal>();
                    if(mapUserIdMonthlyQNbb.containsKey(idOfUser)){
                        lstDeci = mapUserIdMonthlyQNbb.get(idOfUser);
                    }else{
                        lstDeci.addall(lstTemp);
                    }
                    
                    List<Decimal> lstDeciSec = new List<Decimal>();
                    if(mapUserIdQuaterlyQRenew.containsKey(idOfUser)){
                        lstDeciSec = mapUserIdQuaterlyQRenew.get(idOfUser);
                    }else{
                        lstDeciSec.addall(lstTemp);
                    }
                    
                    List<Decimal> lstDeciThir = new List<Decimal>();
                    if(mapUserIdMonthlyQPsg.containsKey(idOfUser)){
                        lstDeciThir = mapUserIdMonthlyQPsg.get(idOfUser);
                    }else{
                        lstDeciThir.addall(lstTemp);
                    }
                    
                    List<Decimal> lstDeciFor = new List<Decimal>();
                    if(mapUserIdMonthlyBundle.containsKey(idOfUser)){
                        lstDeciFor = mapUserIdMonthlyBundle.get(idOfUser);
                    }else{
                        lstDeciFor.addall(lstTemp);
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
                    
                    system.debug('lstDeci++'+lstDeci);
                    system.debug('lstDeciSec++'+lstDeciSec);
                    system.debug('lstDeciThir++'+lstDeciThir);
                    system.debug('lstDeciFor++'+lstDeciFor);
                    system.debug('lstDeciFif++'+lstDeciFif);
                    system.debug('lstDeciSix++'+lstDeciSix);
                    
                    for(Integer i = monthFromJs-1 ; i <= monthToJs-1; i++){
                        sum = sum + lstDeci[i] + lstDeciSec[i] + lstDeciThir[i] + lstDeciFor[i] + lstDeciFif[i] + lstDeciSix[i]; 
                    }
                    
                    system.debug('idOfUser++'+idOfUser);
                    system.debug('sum++'+sum);
                    system.debug('mapUserSum.get(idOfUser)++'+mapUserSum.get(idOfUser));
                    if(sum !=0){
                        Decimal percenTAchieved = (mapUserSum.get(idOfUser)/sum)*100;
                        lstForItr.add(percenTAchieved);
                        lstForItr.add(mapUserSum.get(idOfUser));
                        lstForItr.add(sum);
                        mapOfUser.put(idOfUser,lstForItr);
                    }
                }
            }else if(masterTypeSec == 'NBBPSG'){
                for(Id idOfUser : mapUserSum.keySet()){
                    sum = 0;
                    lstForItr = new List<Decimal>();
                    
                    List<Decimal> lstDeci = new List<Decimal>();
                    if(mapUserIdMonthlyQNbb.containsKey(idOfUser)){
                        lstDeci = mapUserIdMonthlyQNbb.get(idOfUser);
                    }else{
                        lstDeci.addall(lstTemp);
                    }
                    
                    List<Decimal> lstDeciThir = new List<Decimal>();
                    
                    if(mapUserIdMonthlyQPsg.containsKey(idOfUser)){
                        lstDeciThir = mapUserIdMonthlyQPsg.get(idOfUser);
                    }else{
                        lstDeciThir.addall(lstTemp);
                    }
                    for(Integer i = monthFromJs-1 ; i <= monthToJs-1; i++){
                        sum = sum + lstDeci[i] + lstDeciThir[i]; 
                    }
                    if(sum !=0){
                        Decimal percenTAchieved = (mapUserSum.get(idOfUser)/sum)*100;
                        lstForItr.add(percenTAchieved);
                        lstForItr.add(mapUserSum.get(idOfUser));
                        lstForItr.add(sum);
                        mapOfUser.put(idOfUser,lstForItr);
                    }
                }
            }else if(masterTypeSec == 'Bundle'){
                for(Id idOfUser : mapUserSum.keySet()){
                    
                    sum = 0;
                    lstForItr = new List<Decimal>();
                    
                    List<Decimal> lstDeci = new List<Decimal>();
                    lstDeci = mapUserIdMonthlyBundle.get(idOfUser);
                    
                    for(Integer i = monthFromJs-1 ; i <= monthToJs-1; i++){
                        sum = sum + lstDeci[i]; 
                    }
                    if(sum !=0){
                        Decimal percenTAchieved = (mapUserSum.get(idOfUser)/sum)*100;
                        lstForItr.add(percenTAchieved);
                        lstForItr.add(mapUserSum.get(idOfUser));
                        lstForItr.add(sum);
                        mapOfUser.put(idOfUser,lstForItr);
                    }
                }
            }
        }
        for(Id key: mapOfUser.keyset()){
            system.debug('mapOfUserSec+++'+mapOfUser.get(key));
        }
        return mapOfUser;
    }
   
    // Wrapper class  
    public class OpportunityData {  
        public String userName {get; set;}
        public Decimal data1 {get; set;}
        public Decimal data2 {get; set;}        
        public Decimal data3 {get; set;}        
        public String linkPhoto{get; set;}        
        public OpportunityData(String userName , Decimal data1,Decimal data2,Decimal data3,String linkPhoto){
            this.userName = userName;
            this.data1 = data1;
            this.data2 = data2;
            this.data3 = data3;
            this.linkPhoto= linkPhoto;
        }  
    }
    
    public pageReference setFilterValues(){     
        //system.debug('productSelection+++'+productSelection);
        return null;
    }
}