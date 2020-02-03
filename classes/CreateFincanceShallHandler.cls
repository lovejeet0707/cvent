public class CreateFincanceShallHandler {

    // for single record : change method name to createRelatedFincanceShallRecord from createRelatedFincanceShallRecords
    public static Database.UpsertResult[] createRelatedFincanceShallRecord(List<Opportunity> opportunityList) {
        List<Finance_Shell__c> financeShellList = new List<Finance_Shell__c>();
        Set<Id> expireContractID= new Set<Id>();
        Map<Id,String> renewalStage = new Map<Id,String>();
        System.debug(opportunityList);
        Map<Id,Finance_Shell__c> mapOppFinShells = new Map<Id,Finance_Shell__c>();
        mapOppFinShells = CreateFincanceShallHandler.existingFinancialRecords(opportunityList);

        for(Opportunity opportunity : opportunityList){
            Id opportunityId = null;
            System.debug('mapOppFinShells-->' + mapOppFinShells);
            if(mapOppFinShells.containsKey(opportunity.Id)){
                opportunityId = mapOppFinShells.get(opportunity.Id).Id;
                if(mapOppFinShells.get(opportunity.Id).Locked__c == false){
                    financeShellList.add(getFinanceShellInstance(opportunity,opportunityId));
                }
            }else{financeShellList.add(getFinanceShellInstance(opportunity,opportunityId));}//CJ Added this, your welcome Ash :)        
        }
        
        for (Finance_Shell__c fs : financeShellList) {
            if (fs.Previous_Contract__c != null && fs.Opportunity_type__c == 'Renewal') { 
                expireContractID.add(fs.Previous_Contract__c);
                renewalStage.put(fs.Previous_Contract__c,fs.Stage__c); 
                System.debug(fs.Stage__c +'-----27---- ' + fs);         
            } 
         /*  if(fs.Opportunity_ID__r.StageName == 'Closed Lost' || 
                fs.Opportunity_ID__r.StageName == 'Closed -- Never Qualified' ||
                fs.Opportunity_ID__r.StageName == 'Cancelled' ||
                fs.Opportunity_ID__r.StageName == 'Opted-Out' ||
                fs.Opportunity_ID__r.StageName == 'Closed Lost - Opted Out/Cancelled' ||
                fs.Opportunity_ID__r.StageName == 'Closed Reassigned'){
                     expireContractID.add(fs.Child_Contract__c);
                }*/
        }
        CreateFincanceShallHandler.expireParentContracts(expireContractID,renewalStage);
        financeShellList = CreateFincanceShallHandler.removeLostOpps(financeShellList); 
        Database.UpsertResult[] srList = Database.upsert(financeShellList, false);
        return srList;
    }
     
     
     // for bulk records 2 Aug cloned above method with return type void
     public static void createRelatedFincanceShallRecords(List<Opportunity> opportunityList) {
        List<Finance_Shell__c> financeShellList = new List<Finance_Shell__c>();
        Set<Id> expireContractID= new Set<Id>();
        Map<Id,String> renewalStage = new Map<Id,String>();
        Map<Id,Finance_Shell__c> mapOppFinShells = new Map<Id,Finance_Shell__c>();
        mapOppFinShells = CreateFincanceShallHandler.existingFinancialRecords(opportunityList);

        for(Opportunity opportunity : opportunityList){
            Id opportunityId = null; //Not a Opp Id it's a FInance Shell ID
            System.debug('mapOppFinShells-->' + mapOppFinShells);
            if(mapOppFinShells.containsKey(opportunity.Id)){
                opportunityId = mapOppFinShells.get(opportunity.Id).Id;
                if(mapOppFinShells.get(opportunity.Id).Locked__c == false){
                    financeShellList.add(getFinanceShellInstance(opportunity,opportunityId));}
            }
            else{
                financeShellList.add(getFinanceShellInstance(opportunity,opportunityId));
                System.debug('--63--' + financeShellList);
            }//CJ Added this, your welcome Ash :)

        }
        for (Finance_Shell__c fs : financeShellList) {
            System.debug('fs.Previous_Contract__c != null' + fs.Previous_Contract__c);
            System.debug('fs.Opportunity_type__c' + fs.Opportunity_type__c);
            if (fs.Previous_Contract__c != null && fs.Opportunity_type__c == 'Renewal')
            {
                  expireContractID.add(fs.Previous_Contract__c);
                  renewalStage.put(fs.Previous_Contract__c,fs.Stage__c);
                  System.debug(fs.Stage__c +'-----67---- ' + fs);
            }    
        }
        CreateFincanceShallHandler.expireParentContracts(expireContractID, renewalStage); 
        financeShellList = CreateFincanceShallHandler.removeLostOpps(financeShellList);
        try{
            upsert financeShellList;
        }
        catch(Exception ex){
            System.debug(ex);
        }        
    } 
        public static List<Finance_Shell__c> removeLostOpps(List<Finance_Shell__c> allFinanceShell) {
           List<Finance_Shell__c> finalFSList= new List<Finance_Shell__c>();
           for (Finance_Shell__c fs : allFinanceShell) {              
                 if(!(
                    fs.Stage__c == 'Closed -- Never Qualified' ||
                    fs.Stage__c == 'Cancelled' ||
                    fs.Stage__c== 'Opted-Out' ||                    
                    fs.Stage__c == 'Closed Reassigned' || 
                    fs.Stage__c== 'Closed Lost - Opted Out/Cancelled')) {
                        finalFSList.add(fs);
                }
                else {
                    System.debug('--92-->Not Created');
                }
           }
            return finalFSList;
       }
    
    public static Map<Id,Finance_Shell__c> existingFinancialRecords(List<Opportunity> opportunityList){
        List<Finance_Shell__c> lstExistingFinShell = new List<Finance_Shell__c>();
        Map<Id,Finance_Shell__c> mapOppFinShell = new Map<Id,Finance_Shell__c>();
        if(opportunityList.size() > 0 ) {  
            lstExistingFinShell = [SELECT Id,
                                          Opportunity_ID__c,
                                          Locked__c
                                     FROM Finance_Shell__c
                                    WHERE Opportunity_ID__c IN :opportunityList];
            if(lstExistingFinShell.size() > 0){
                for(Finance_Shell__c lstItr : lstExistingFinShell){
                    if(lstItr.Opportunity_ID__c != null){
                        mapOppFinShell.put(lstItr.Opportunity_ID__c,lstItr);
                    }
                }
            }
        }
        return mapOppFinShell;
    }

    public static Finance_Shell__c getFinanceShellInstance(Opportunity opportunity, Id finShellId) {
        if( null == opportunity ) {return new Finance_Shell__c();}
        String jsonString = '';
        Finance_Shell__c financeShell = new Finance_Shell__c();
        if(finShellId != null){
            financeShell.Id = finShellId;
        }
        financeShell.Account_ID__c = opportunity.AccountId;
        financeShell.Opportunity_ID__c = opportunity.Id;
        financeShell.CurrencyIsoCode = opportunity.CurrencyIsoCode;
        financeShell.Stage__c = opportunity.StageName;
        if(opportunity.SBQQ__PrimaryQuote__r.jsonString__c == null && opportunity.SBQQ__Quotes2__r.size() > 0){
            financeShell.Quote_ID__c = opportunity.SBQQ__Quotes2__r[0].Id;
            
            //financeShell.Quote_ID__c = opportunity.SBQQ__PrimaryQuote__c;
            financeShell.Opportunity_type__c = opportunity.SBQQ__Quotes2__r[0].SBQQ__Type__c; financeShell.Primary_Contact__c = opportunity.SBQQ__Quotes2__r[0].SBQQ__PrimaryContact__c;            financeShell.Contract_Year_1_start_date__c = opportunity.SBQQ__Quotes2__r[0].SBQQ__StartDate__c;            financeShell.Contract_Year_1_end_date__c = opportunity.SBQQ__Quotes2__r[0].SBQQ__EndDate__c;
            financeShell.Total_Duration__c = opportunity.SBQQ__Quotes2__r[0].Contract_Term_Years__c != null ? Decimal.valueOf(opportunity.SBQQ__Quotes2__r[0].Contract_Term_Years__c) : null;            financeShell.Current_term__c = opportunity.SBQQ__Quotes2__r[0].Current_Year__c;            financeShell.Year_Signed__c = opportunity.SBQQ__Quotes2__r[0].Contract_Executed_Date__c;
            financeShell.Variable_Options__c = opportunity.SBQQ__Quotes2__r[0].Multiple_Years_Commitment__c;            if( opportunity.SBQQ__Quotes2__r[0].jsonString__c != null){                jsonString = opportunity.SBQQ__Quotes2__r[0].jsonString__c;                financeShell = populateDataFromQuoteJSON(opportunity.SBQQ__Quotes2__r[0].jsonString__c, financeShell); 
            }
        }
        else {
            financeShell.Quote_ID__c = opportunity.SBQQ__PrimaryQuote__c;
            financeShell.Opportunity_type__c = opportunity.SBQQ__PrimaryQuote__r.SBQQ__Type__c;
            financeShell.Primary_Contact__c = opportunity.SBQQ__PrimaryQuote__r.SBQQ__PrimaryContact__c;
            financeShell.Contract_Year_1_start_date__c = opportunity.SBQQ__PrimaryQuote__r.SBQQ__StartDate__c;
            financeShell.Contract_Year_1_end_date__c = opportunity.SBQQ__PrimaryQuote__r.SBQQ__EndDate__c;
            financeShell.Total_Duration__c = opportunity.SBQQ__PrimaryQuote__r.Contract_Term_Years__c != null ? Decimal.valueOf(opportunity.SBQQ__PrimaryQuote__r.Contract_Term_Years__c) : null;
            financeShell.Current_term__c = opportunity.SBQQ__PrimaryQuote__r.Current_Year__c;
            jsonString = opportunity.SBQQ__PrimaryQuote__r.jsonString__c;
            financeShell.Year_Signed__c = opportunity.SBQQ__PrimaryQuote__r.Contract_Executed_Date__c;
            financeShell.Variable_Options__c = opportunity.SBQQ__PrimaryQuote__r.Multiple_Years_Commitment__c;
            financeShell = populateDataFromQuoteJSON(opportunity.SBQQ__PrimaryQuote__r.jsonString__c, financeShell);
        }
        
        financeShell.Parent_Contract__c = opportunity.Master_Agreement__c;
         if(opportunity.SBQQ__AmendedContract__c != null) {
            financeShell.Child_Contract__c  = opportunity.SBQQ__AmendedContract__c;
            financeShell.Child_Contract_Start_Date__c = opportunity.SBQQ__AmendedContract__r.StartDate;
            financeShell.Child_Contract_End_Date__c = opportunity.SBQQ__AmendedContract__r.EndDate;

        }
        else if(opportunity.SBQQ__Contracts__r.size()>0){financeShell.Child_Contract__c = opportunity.SBQQ__Contracts__r[0].Id;            financeShell.Child_Contract_Start_Date__c = opportunity.SBQQ__Contracts__r[0].StartDate;            financeShell.Child_Contract_End_Date__c = opportunity.SBQQ__Contracts__r[0].EndDate;}

        financeShell.Parent_Contract_Start_Date__c = opportunity.Master_Agreement__r.StartDate;
        financeShell.Parent_Contract_End_Date__c = opportunity.Master_Agreement__r.EndDate;
        financeShell.Opportunity_Amount__c = opportunity.Amount;
        financeShell.Primary_Contact__c = opportunity.SBQQ__PrimaryQuote__r.SBQQ__PrimaryContact__c;
        financeShell.Year_Signed__c = opportunity.ContractReceived__c; // .year()
        financeShell.Contract_implemented_Date__c = opportunity.Contract_Implemented_Date__c;
        financeShell.Contract_Received_Date__c = opportunity.ContractReceived__c;
        
        financeShell.Accountable_Quarter__c = populateQuarter(opportunity.ContractReceived__c);
        //CJ-- add fields
        financeShell.Closed_Date__c = opportunity.CloseDate;
        String str_Type = opportunity.Type;
        //financeShell.Contract_Expired__c = str_Type.contains('Renewal') ? :
        if(!String.isEmpty(jsonString))  {
            Map<Integer, SBQQ__QuoteLineGroup__c> map_quoteLineGroups = MapreturnDates(jsonString);
            System.debug('CJ__ :' +map_quoteLineGroups);
            financeShell.Contract_Year_2_start_date__c = map_quoteLineGroups.containsKey(2) ? map_quoteLineGroups.get(2).SBQQ__StartDate__c : null ;
            financeShell.Contract_Year_2_end_date__c = map_quoteLineGroups.containsKey(2) ? map_quoteLineGroups.get(2).SBQQ__EndDate__c: null ;
            financeShell.Contract_Year_3_start_date__c = map_quoteLineGroups.containsKey(3) ? map_quoteLineGroups.get(3).SBQQ__StartDate__c : null ;
            financeShell.Contract_Year_3_end_date__c = map_quoteLineGroups.containsKey(3) ? map_quoteLineGroups.get(3).SBQQ__EndDate__c: null ;
            financeShell.Contract_Year_4_start_date__c = map_quoteLineGroups.containsKey(4) ? map_quoteLineGroups.get(4).SBQQ__StartDate__c : null ;
            financeShell.Contract_Year_4_end_date__c = map_quoteLineGroups.containsKey(4) ? map_quoteLineGroups.get(4).SBQQ__EndDate__c: null ;
            financeShell.Contract_Year_5_start_date__c = map_quoteLineGroups.containsKey(5) ? map_quoteLineGroups.get(5).SBQQ__StartDate__c : null ;
            financeShell.Contract_Year_5_end_date__c = map_quoteLineGroups.containsKey(5) ? map_quoteLineGroups.get(5).SBQQ__EndDate__c: null ;
                        //}
    
            
            //?? financeShell.Year_Received_Quarter__c = Quarter + year of Contract received Date // Q2 2018
            financeShell = populateSalesRepDetails(opportunity, financeShell);
            financeShell = populatePreviousContractDetails(opportunity, financeShell);
            //financeShell = populateDataFromQuoteJSON(opportunity.SBQQ__PrimaryQuote__r.jsonString__c, financeShell);
             System.debug('...financeShell: '+ financeShell);
        }
        return financeShell;
    }

    //return map of years/dates
    public static Map<Integer, SBQQ__QuoteLineGroup__c> MapreturnDates(String jsonString)
    {
        CventMyd_QuoteObject quoteObj = new CventMyd_QuoteObject();

        List<Integer> yearsSorted = new List<Integer>();
        List<Integer> updatedyearsSorted = new List<Integer>();
        Map<Integer, Integer> map_year2RealYear = new Map<Integer, Integer>();
        Map<Integer, SBQQ__QuoteLineGroup__c> map_quoteLineGroups = new Map<Integer, SBQQ__QuoteLineGroup__c>();

        quoteObj = (CventMyd_QuoteObject)JSON.deserialize(jsonString,CventMyd_QuoteObject.class);

        for(Integer year : quoteObj.outyearMap.keySet()) {
            yearsSorted.add(year);
            }

        yearsSorted.sort();  
        Integer i = 2;  
        for(Integer year : yearsSorted) {
            updatedyearsSorted.add(i);
            map_year2RealYear.put(i, year);
            i++;
        }   
        System.debug('__ updatedyearsSorted:' +updatedyearsSorted);
        for(Integer year : updatedyearsSorted) {
            SBQQ__QuoteLineGroup__c yearGroup = new SBQQ__QuoteLineGroup__c();
            yearGroup.Name = 'Year ' + String.valueOf(year);
            yearGroup.term__c = year;
            yearGroup.SBQQ__StartDate__c = quoteObj.outyearMap.get(map_year2RealYear.get(year)).startDate;
            yearGroup.SBQQ__EndDate__c = quoteObj.outyearMap.get(map_year2RealYear.get(year)).endDate;
            map_quoteLineGroups.put(year, yearGroup);

        } 
        System.debug('__ map_quoteLineGroups:' +map_quoteLineGroups);
        return  map_quoteLineGroups;       
    }

    public static Finance_Shell__c populatePreviousContractDetails(Opportunity opportunity, Finance_Shell__c financeShell) {
        if( null == financeShell || null == opportunity ) {return financeShell;}
        financeShell.Opportunity_type__c = 'New';
        if(opportunity.SBQQ__AmendedContract__c != null) {
            //financeShell.Previous_Contract__c = opportunity.SBQQ__AmendedContract__c;
            financeShell.Parent_Opportunity__c = opportunity.SBQQ__AmendedContract__r.SBQQ__Opportunity__c;            financeShell.Opportunity_type__c = 'Amendment';
        } else if(opportunity.SBQQ__RenewedContract__c != null) {            financeShell.Previous_Contract__c = opportunity.SBQQ__RenewedContract__c;            financeShell.Parent_Opportunity__c = opportunity.SBQQ__RenewedContract__r.SBQQ__Opportunity__c;            financeShell.Opportunity_type__c = 'Renewal';

        }

        //#TODO can add the Parent_Shell__c population logic here
        if(financeShell.Previous_Contract__c != null)
        {
            //ID of finance shell where Contract ID matches for this shells Previous contract
            //Finance_Shell__r.Parent_Shell__c == financeShell.Parent_Opportunity__r.Finance_Shell__c;
        }
        return financeShell;
    }

    public static Finance_Shell__c populateSalesRepDetails(Opportunity opportunity, Finance_Shell__c financeShell) {
        if( null == financeShell || null == opportunity ) {return financeShell;}

        for( Integer index = 0; index < opportunity.OpportunitySplits.size(); index++ ) {
            switch on index {
                when 0 {
                    financeShell.Sales_rep_1__c = opportunity.OpportunitySplits[index].SplitOwnerId;
                    financeShell.Sales_rep_break_up_1__c = opportunity.OpportunitySplits[index].SplitPercentage;
                    financeShell.Opportunity_Split_Type_1__c = opportunity.OpportunitySplits[index].SplitType.MasterLabel;

                } when 1 { financeShell.Sales_rep_2__c = opportunity.OpportunitySplits[index].SplitOwnerId; financeShell.Sales_rep_break_up_2__c = opportunity.OpportunitySplits[index].SplitPercentage; financeShell.Opportunity_Split_Type_2__c = opportunity.OpportunitySplits[index].SplitType.MasterLabel;
                } when 2 {financeShell.Sales_rep_3__c = opportunity.OpportunitySplits[index].SplitOwnerId; financeShell.Sales_rep_break_up_3__c = opportunity.OpportunitySplits[index].SplitPercentage;      financeShell.Opportunity_Split_Type_3__c = opportunity.OpportunitySplits[index].SplitType.MasterLabel;
                } when 3 { financeShell.Sales_rep_4__c = opportunity.OpportunitySplits[index].SplitOwnerId;
                    financeShell.Sales_rep_break_up_4__c = opportunity.OpportunitySplits[index].SplitPercentage;
                    financeShell.Opportunity_Split_Type_4__c = opportunity.OpportunitySplits[index].SplitType.MasterLabel;

                 } when 4 {
                     financeShell.Sales_rep_5__c = opportunity.OpportunitySplits[index].SplitOwnerId;
                     financeShell.Sales_rep_break_up_5__c = opportunity.OpportunitySplits[index].SplitPercentage;
                     financeShell.Opportunity_Split_Type_5__c = opportunity.OpportunitySplits[index].SplitType.MasterLabel;

                } when 5 {
                     financeShell.Sales_rep_6__c = opportunity.OpportunitySplits[index].SplitOwnerId;
                     financeShell.Sales_rep_break_up_6__c = opportunity.OpportunitySplits[index].SplitPercentage;
                     financeShell.Opportunity_Split_Type_6__c = opportunity.OpportunitySplits[index].SplitType.MasterLabel;
                }
            }
        }
        return financeShell;
    }

    public static String populateQuarter(Date contractReceived) {
        if(null == contractReceived) {return null;}
        Integer month = contractReceived.month();
        switch on month {
            when 1, 2, 3 {
                return 'Q1';
            } when 4, 5, 6 {
                return 'Q2';
            } when 7, 8, 9 {
                return 'Q3';
            } when 10, 11, 12 {
                return 'Q4';
            }
        }

        return null;
    }

    public static Finance_Shell__c populateDataFromQuoteJSON(String quoteJSON, Finance_Shell__c financeShell) {
        if( true == String.isBlank(quoteJSON)
         || null == financeShell ) {
            return financeShell;
        }
        System.debug(quoteJSON);
        
        CventMyd_QuoteObject quoteObj = (CventMyd_QuoteObject)JSON.deserializeStrict(quoteJSON,CventMyd_QuoteObject.class);
        System.debug(quoteObj);
        if(null == quoteObj.outyearMap
        || true == quoteObj.outyearMap.isEmpty()) {return financeShell;}

        for( Integer key :  quoteObj.outyearMap.keySet() ) {
            CventMyd_Outyear outYear =quoteObj.outyearMap.get(key);
            switch on key {
              when 2 {
                    financeShell.Contract_Year_2_start_date__c = outYear.startDate;
                    financeShell.Contract_Year_2_end_date__c = outYear.endDate;

                } when 3 {
                    financeShell.Contract_Year_3_start_date__c = outYear.startDate;
                    financeShell.Contract_Year_3_end_date__c = outYear.endDate;

                 } when 4 {
                     financeShell.Contract_Year_4_start_date__c = outYear.startDate;
                     financeShell.Contract_Year_4_end_date__c = outYear.endDate;

                } when 5 {
                    financeShell.Contract_Year_5_start_date__c = outYear.startDate;
                    financeShell.Contract_Year_5_end_date__c = outYear.endDate;
                }
            }
        }
        return financeShell;

    }

    public static void expireParentContracts(set<Id> childContract, Map<Id,String> renewalStageUpdate) {
       List<Finance_Shell__c> expiredFinanceShell = new list<Finance_Shell__c>(); 
       expiredFinanceShell = [Select Id, Child_Contract__c from Finance_Shell__c where Child_Contract__c IN : childContract];

       for (Finance_Shell__c expiredShells : expiredFinanceShell )  {
           expiredShells.Contract_Expired__c = true ;
           expiredShells.Stage_of_Renewal_Opp__c = renewalStageUpdate.get(expiredShells.Child_Contract__c);
        }
       update expiredFinanceShell;
     }
}