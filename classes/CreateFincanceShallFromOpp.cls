/*------------------------------------------------------------------------------------------------------------------------------+
Simplus(info@Simplus.com)
Purpose: Nightly Batch for creating Fincance Shall Records

Details: Batch Class

History:
07/1/2018 CJ Abreu
    -- Created

-------------------------------------------------------------------------------------------------------------------------------+*/
global class CreateFincanceShallFromOpp implements Database.Batchable<sObject>, Database.Stateful {

    global Set<Id> oppProcessed;

    Public ID oppRecordId {get; set;}
    Public String oppRecordStartDate {get; set;}
    Public String oppRecordEndDate {get; set;}
    Public String queryString {get;set;}

    Public Set<Id> oppList {get;set;}
    Public Set<Id> setOpp {get;set;}

    Public CreateFincanceShallFromOpp(String oppId){
        oppProcessed = new Set<Id>();
        if(oppId != 'QUERY1'){
            oppRecordId = oppId;
            queryString = ' WHERE ID =  :oppRecordId ';
        }
        else {
            setOpp = new Set<Id>();
            Date finalReviewDate = Date.newInstance(2018,08,05);
            for(Contract_Reviewing__c lstItr  :[SELECT Opportunity__c
                                                  FROM Contract_Reviewing__c 
                                                 WHERE Contract_Review_Ok__c = 'Yes' 
                                                 AND Final_Review_Date__c >= :finalReviewDate ]){
                setOpp.add(lstItr.Opportunity__c);
            }
            if(setOpp.size() > 0){           
                queryString = ' WHERE ID IN :setOpp ';
            }
        }
    }
    Public CreateFincanceShallFromOpp(String oppStartDate, String oppEndDate){
        oppProcessed = new Set<Id>();
        oppRecordStartDate = oppStartDate;
        oppRecordEndDate = oppEndDate;
        queryString = ' WHERE Contract_Implemented_Date__c >=  '+oppRecordStartDate +' AND Contract_Implemented_Date__c <= '+oppRecordEndDate+ '  AND  DELETE_Primary_Quote_is_Variable_Options__c = false AND  SBQQ__PrimaryQuote__c != null ';
    }
    Public CreateFincanceShallFromOpp(Set<ID> setOpportunities){
        oppProcessed = new Set<Id>();
        setOpp = setOpportunities;
        queryString = '';       
        if(setOpportunities.size() > 0){           
           queryString = ' WHERE ID IN :setOpp ';
        }
        System.debug('queryString-->' + queryString);
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
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
                       ', ' + Schema.Opportunity.StageName +', ' + 'CloseDate' +
                    //  ', ' + 'CurrencyIsoCode' +
                      ', ' + 'SBQQ__PrimaryQuote__r.Multiple_Years_Commitment__c'+
                      ', ' + 'Type' +
                     ', ( Select Id ' +
                      ', ' + ' StartDate' + 
                      ', ' + ' EndDate from SBQQ__Contracts__r where Contract_Type__c=\'Child Contract\' Limit 1)' + 
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
                      ' ' + ' FROM SBQQ__Quotes2__r WHERE Cloned_from_Quote__c != null) '+
                      ', ( SELECT Id ' +
                      ', ' + Schema.OpportunitySplit.OpportunityId +
                      ', ' + Schema.OpportunitySplit.SplitOwnerId +
                      ', ' + Schema.OpportunitySplit.SplitPercentage +
                      ', ' + 'SplitType.MasterLabel ' +
                  ' FROM OpportunitySplits' +
                 ' WHERE SplitType.isActive = true' +
                 ' )' +
                 ' FROM Opportunity' + queryString +
                 ' AND SBQQ__PrimaryQuote__c != null ';
                  System.debug(query);
                List<Opportunity> lst = Database.query(query);
               System.debug(lst.size());
                System.debug('QueryData1');
                return Database.getQueryLocator(query);
            //return null;
                
            }
            else {
                queryString += 'select id from Opportunity LIMIT 0';
                return Database.getQueryLocator(queryString);
                //return null;
            }
    }

   global void execute(Database.BatchableContext BC, List<Opportunity> opportunityList) {
       for(Opportunity lstItr : opportunityList){
            oppProcessed.add(lstItr.Id);
        }
        CreateFincanceShallHandler.createRelatedFincanceShallRecords(opportunityList);        
    }

    global void finish(Database.BatchableContext BC) {      
        Set<Id> setOpp = new Set<Id>();
        List<Opportunity> lstOppProcessed = [SELECT Id, 
                                            (SELECT Id 
                                               FROM Finance_Shell__r) 
                                               FROM Opportunity 
                                              WHERE Id IN :oppProcessed 
                                              AND StageName  NOT IN ('Closed Lost',
                                                                  'Closed -- Never Qualified',
                                                                  'Cancelled', 
                                                                  'Opted-Out', 
                                                                  'Closed Lost - Opted Out/Cancelled', 
                                                                  'Closed Reassigned')] ;
        for(Opportunity lstItr : lstOppProcessed){
            if(lstItr.Finance_Shell__r.size() <= 0){
                setOpp.add(lstItr.Id);
            }
        }

        
         if(setOpp.size()>0){
            String mailSubject = 'Finance Shell is NOT CREATED in Current Batch Execution';
            String body = '';
             body = '<b> Finance Shell for following opportunities are NOT created.</b><br>Opportunity List :';
                for(Id setItr : setOpp){
                    body += setItr + '<br>';
                } 
            String emailRecevierList = Label.Opportunity_Email_Receivers;
            String[] sendingTo= emailRecevierList.split(',');
            ScheduledFinanceShellBatch financeObj = new ScheduledFinanceShellBatch();
            financeObj.sendEmail(setOpp,mailSubject,body,sendingTo);         
        } 
    }
}