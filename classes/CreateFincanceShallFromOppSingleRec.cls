Public class CreateFincanceShallFromOppSingleRec{

    Public ID oppRecordId {get; set;}   
    Public String finShellId {get;set;} 
    Public String queryString {get;set;} 
    Public CreateFincanceShallFromOppSingleRec(String oppId){
        oppRecordId = oppId;
        queryString = ' WHERE ID =  :oppRecordId';
    }

    Public String createFinanceShellRecord() {
        if(!String.isEmpty(queryString)){
            String query =
            'SELECT Id' +
                  ', ' + Schema.Opportunity.AccountId +
                  ', ' + Schema.Opportunity.SBQQ__PrimaryQuote__c +
                  ', ' + Schema.Opportunity.Master_Agreement__c +
                  ', ' + Schema.Opportunity.ContractId +
                  ', ' + Schema.Opportunity.Amount +
                  ', ' + Schema.Opportunity.SBQQ__AmendedContract__c +
                  ', ' + Schema.Opportunity.SBQQ__RenewedContract__c +
                  ', ' + Schema.Opportunity.Contract_Implemented_Date__c  +
                  ', ' + Schema.Opportunity.ContractReceived__c +
                    ', ' + Schema.Opportunity.CurrencyIsoCode +
                     ', ' + Schema.Opportunity.StageName +
                  ', ' + 'CloseDate' +
                  ', ' + 'SBQQ__PrimaryQuote__r.Multiple_Years_Commitment__c'+
                  ', ' + 'Type' +
                 ', ( Select Id ' +
                  ', ' + ' StartDate' + 
                  ', ' + ' EndDate from SBQQ__Contracts__r where Contract_Type__c =\'Child Contract\' Limit 1)' + 
//                  ', ' + 'Contract.StartDate' +
//                  ', ' + 'Contract.EndDate' +
                  ', ' + 'SBQQ__AmendedContract__r.SBQQ__Opportunity__c' +
                  ', ' + 'SBQQ__AmendedContract__r.StartDate' +
                  ', ' + 'SBQQ__AmendedContract__r.EndDate' +
                  ', ' + 'SBQQ__RenewedContract__r.SBQQ__Opportunity__c' +
                  ', ' + 'Master_Agreement__r.StartDate'+
                  ', ' + 'Master_Agreement__r.EndDate' +
                  ', ' + 'SBQQ__PrimaryQuote__r.Contract_Term_Years__c' +
                  ', ' + 'SBQQ__PrimaryQuote__r.Current_Year__c' +
                  ', ' + 'SBQQ__PrimaryQuote__r.SBQQ__Type__c' +
                  ', ' + 'SBQQ__PrimaryQuote__r.SBQQ__PrimaryContact__c' +
                  ', ' + 'SBQQ__PrimaryQuote__r.jsonString__c' +
                  ', ' + 'SBQQ__PrimaryQuote__r.SBQQ__StartDate__c' +
                  ', ' + 'SBQQ__PrimaryQuote__r.SBQQ__EndDate__c' +
                  ', ' + 'SBQQ__PrimaryQuote__r.Contract_Executed_Date__c ' +
                  ', ' + '(SELECT ID,SBQQ__Type__c,SBQQ__PrimaryContact__c,SBQQ__StartDate__c,Contract_Executed_Date__c,Multiple_Years_Commitment__c,SBQQ__EndDate__c,Contract_Term_Years__c,Current_Year__c,jsonString__c'+
                  ' ' + ' FROM SBQQ__Quotes2__r WHERE Cloned_from_Quote__c != null ) '+
                  ', ( SELECT Id ' +
                  ', ' + Schema.OpportunitySplit.OpportunityId +
                  ', ' + Schema.OpportunitySplit.SplitOwnerId +
                  ', ' + Schema.OpportunitySplit.SplitPercentage +
                  ', ' + 'SplitType.MasterLabel ' +
              ' FROM OpportunitySplits' +
             ' WHERE SplitType.isActive = true' +
             ' )' +
             ' FROM Opportunity' + queryString;
            
            List<Opportunity> lstOpportunities = Database.query(query);
            System.debug(lstOpportunities.size());
            Database.UpsertResult[] srList = CreateFincanceShallHandler.createRelatedFincanceShallRecord(lstOpportunities);
            if(srList.size() > 0){
                Database.UpsertResult sr = srList[0];
                if(sr.isSuccess()){
                    finShellId = sr.getId();
                }
            }
        }  
        return finShellId;
    }
}