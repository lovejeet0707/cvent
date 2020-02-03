/*
//////////////////////////////////////
//      @author Abhishek Pandey     //
/////////////////////////////////////
Version :   1.0
Date : 17th June 2013
Description : Supplies Data to page Report_Budget_Actual_page for showing opportunity data on the basis of filters given on page binded with this controller
*/
global class ReportBudgetActualCls{
    
    global Opportunity opp {get;set;}
    global static string productSelection {get;set;}
    public List<SelectOption> options {get;set;}
    public List<SelectOption> monthOption {get;set;}
    public List<SelectOption> teamOptions {get;set;}
    global static string monthFrom{get;set;}
    global static string monthTo{get;set;}
    global static string teamSelected{get;set;}
    global static Map<Integer,String> mapNoMonthName = new Map<Integer,String>();
    global ReportBudgetActualCls(){
        Schema.DescribeFieldResult F = Opportunity.Product__c.getDescribe();
        teamSelected = '';
        productSelection = '';
        List<Schema.PicklistEntry> ple = F.getPicklistValues();
        options = new List<SelectOption>();
        options.add(new SelectOption('','--None--'));
        for(Schema.PicklistEntry lk:ple){           
            options.add(new SelectOption(lk.getvalue(),lk.getvalue()));         
        }
        
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
        
        teamOptions = new List<SelectOption>();     
        teamOptions.add(new SelectOption('','--None--'));
        teamOptions.add(new SelectOption('AM','AM'));
        teamOptions.add(new SelectOption('PA','PA'));
        teamOptions.add(new SelectOption('DS','DS'));   
                
        mapNoMonthName.put(1,'Jan');
        mapNoMonthName.put(2,'Feb');
        mapNoMonthName.put(3,'Mar');
        mapNoMonthName.put(4,'Apr');
        mapNoMonthName.put(5,'May');
        mapNoMonthName.put(6,'Jun');
        mapNoMonthName.put(7,'Jul');
        mapNoMonthName.put(8,'Aug');
        mapNoMonthName.put(9,'Sep');
        mapNoMonthName.put(10,'Oct');
        mapNoMonthName.put(11,'Nov');
        mapNoMonthName.put(12,'Dec');   
    }
    @readonly
    @RemoteAction   
    global static List<OpportunityData> loadOpps(String product,String teamValue,Integer monthFromJs,Integer monthToJs) {
        if(product!=null){
            productSelection = product;
        }  
        if(teamValue!=null){
            teamSelected = teamValue;
        }   
        system.debug('monthFromJs+++'+monthFromJs);
        system.debug('monthToJs+++'+monthToJs);
        Map<Integer,String> tempMapNoMonthName = new Map<Integer,String>();
        Integer monthFromJsInt;
        Integer monthToJsInt;
        if(monthFromJs!=null && monthToJs!=null){
            monthFromJsInt = Integer.valueOf(monthFromJs);
            monthToJsInt = Integer.valueOf(monthToJs);
            List<Integer> tempList = new List<Integer>();
            for(Integer i=monthFromJsInt;i<=monthToJsInt;i++){
                String strMonth = tempMapNoMonthName.get(i);
                tempMapNoMonthName.put(i,strMonth);
            }           
        }else if(monthFromJs == null && monthToJs == null){
            monthFromJsInt =1;
            monthToJsInt = 12;
            for(Integer i=monthFromJsInt;i<=monthToJsInt;i++){
                String strMonth = tempMapNoMonthName.get(i);
                tempMapNoMonthName.put(i,strMonth);
            }
        }
        system.debug('productSelection+++'+productSelection);
        system.debug('teamSelected+++'+teamSelected);
        /*AggregateResult[] result ;
        if((productSelection == null || productSelection == '') && (teamSelected == '' || teamSelected == null)){
            result = [SELECT SUM(New_Contract_Total__c)monthlyRev,Sum(Budget_Total__c)xprvn,CALENDAR_MONTH(CloseDate) month,CALENDAR_YEAR(CloseDate) year FROM Opportunity WHERE (stageName='Closed Won' or stageName='Closed Won - AR Settlement' or stageName='Budget') 
                        AND CALENDAR_YEAR(CloseDate) =: system.today().Year() GROUP BY CALENDAR_YEAR(closeDate),CALENDAR_MONTH(CloseDate)  Order BY CALENDAR_YEAR(closeDate),CALENDAR_MONTH(CloseDate)];
        }else if(productSelection != null && productSelection != '' && (teamSelected == '' || teamSelected == null)){
            result = [SELECT SUM(New_Contract_Total__c)monthlyRev,Sum(Budget_Total__c)xprvn,CALENDAR_MONTH(CloseDate) month,CALENDAR_YEAR(CloseDate) year FROM Opportunity WHERE (stageName='Closed Won' or stageName='Closed Won - AR Settlement' or stageName='Budget') 
                        AND CALENDAR_YEAR(CloseDate) =: system.today().Year() AND Product__c =: productSelection GROUP BY CALENDAR_YEAR(closeDate),CALENDAR_MONTH(CloseDate)  Order BY CALENDAR_YEAR(closeDate),CALENDAR_MONTH(CloseDate)];
            system.debug('CameInCorrectW+++'+result);       
        }else if(productSelection!='' && productSelection!=null && teamSelected !=null && teamSelected != ''){
            result = [SELECT SUM(New_Contract_Total__c)monthlyRev,Sum(Budget_Total__c)xprvn,CALENDAR_MONTH(CloseDate) month,CALENDAR_YEAR(CloseDate) year FROM Opportunity WHERE (stageName='Closed Won' or stageName='Closed Won - AR Settlement' or stageName='Budget') 
                        AND CALENDAR_YEAR(CloseDate) =: system.today().Year() AND Product__c =: productSelection AND Owner_s_Role__c =: teamSelected GROUP BY CALENDAR_YEAR(closeDate),CALENDAR_MONTH(CloseDate)  Order BY CALENDAR_YEAR(closeDate),CALENDAR_MONTH(CloseDate)];
            system.debug('CameInCorrect+++'+result);            
        }else if((productSelection=='' || productSelection==null) && teamSelected !=null && teamSelected != ''){
            result = [SELECT SUM(New_Contract_Total__c)monthlyRev,Sum(Budget_Total__c)xprvn,CALENDAR_MONTH(CloseDate) month,CALENDAR_YEAR(CloseDate) year FROM Opportunity WHERE (stageName='Closed Won' or stageName='Closed Won - AR Settlement' or stageName='Budget') 
                        AND CALENDAR_YEAR(CloseDate) =: system.today().Year() AND Owner_s_Role__c =: teamSelected GROUP BY CALENDAR_YEAR(closeDate),CALENDAR_MONTH(CloseDate)  Order BY CALENDAR_YEAR(closeDate),CALENDAR_MONTH(CloseDate)];
            system.debug('CameInCorrect+++'+result);            
        }
        
        List<OpportunityData> oppsData = new List<OpportunityData>();
        Integer tempNum = 1;
        for (AggregateResult a : result){
            
            Datetime d=Datetime.newInstance((Integer)a.get('year'),(Integer)a.get('month'), 1);
            Integer monInteger = (Integer)a.get('month');             
            if(tempMapNoMonthName.containskey(monInteger)){  
                OpportunityData opp = new OpportunityData(d.format('MMM-YY'),(Decimal)a.get('monthlyRev'),(Decimal)a.get('xprvn'));                                 
                oppsData.add(opp);
            }
        }*/
        List<OpportunityData> oppsData = new List<OpportunityData>();
        system.debug(oppsData);
        return oppsData; 
    }   
    // Wrapper class  
    global class OpportunityData {  
        public String month {get; set;}
        public Decimal data1 {get; set;}
        public Decimal data2 {get; set;}        
        public OpportunityData(String month, Decimal data1,Decimal data2){
            this.month = month;
            this.data1 = data1;
            this.data2 = data2;
        }  
    }
    
    global pageReference setFilterValues(){     
        system.debug('productSelection+++'+productSelection);
        return null;
    }
 
}