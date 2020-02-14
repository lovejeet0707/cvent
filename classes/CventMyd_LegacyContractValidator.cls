global without sharing class CventMyd_LegacyContractValidator {

    public static Map<Id,List<SBQQ__Subscription__c>> contractIdToSubscriptions = new Map<Id,List<SBQQ__Subscription__c>>();

    public static Map<Id,Contract> contractIdToContract = new Map<Id,Contract>();

    public static Map<Id,SBQQ__Quote__c> quoteIdToQuote = new Map<Id,SBQQ__Quote__c>();

    public static Map<Id,List<SBQQ__QuoteLine__c>> quoteIdToQuoteLines = new Map<Id,List<SBQQ__QuoteLine__c>>();

    public static Id masterReportId;

    public static Map<String,List<String>> quoteLineFieldNameTosubscriptionFieldNames;

    static {

        quoteLineFieldNameTosubscriptionFieldNames = getQuoteLineFieldNameToSubscriptionFieldNames();

    }

    public enum ComparisonType {

        VARIABLE_OPTIONS_CHECKBOX,

        CURRENT_YEAR,

        FINAL_YEAR,

        DATES,

        QUOTE_LINE_GROUP_COUNT,

        QUOTE_LINE_COUNTS,     

        OPPORTUNITY_LINE_CHECK,

        TOTALS,

        SUBSCRIPTION_VALUE_CHECK,

        AMENDMENT_ZEROED_CHECK

    }

    public class LegacyContractWrapper {

        public Contract contract;

        public SBQQ__Quote__c quote;

        public Boolean isAmendment;

        public Id contractReportId;

    }     

    public class LegacyValidationException extends Exception {}

    public static Id createOrGetMasterReport() {

        String dateString = CventMyd_UtilityMethods.getFormattedDateTimeString(DateTime.now(),false,false);

        Id masterReportId;

        List<LegacyMasterReport__c> masterReports = [

            SELECT Id

            FROM LegacyMasterReport__c

            WHERE isMainMaster__c = TRUE

        ];

        if(masterReports.size() > 0) {

            masterReportId = masterReports[0].Id;

        }

        else {

            String reportName = 'Master Report @ ' + dateString;

            LegacyMasterReport__c masterReport = new LegacyMasterReport__c();

            masterReport.isMainMaster__c = true;

            masterReport.Name = reportName;

            insert masterReport;

            masterReportId = masterReport.Id;

        }

        return masterReportId;

    }

    public static void createGenerationFailureReport(Contract contract, String exceptionString, Boolean isAmendment) {

        Id masterReportId = createOrGetMasterReport();

        String dateString = CventMyd_UtilityMethods.getFormattedDateTimeString(DateTime.now(),false,true);

        LegacyContractReport__c legacyContractReport = new LegacyContractReport__c();

        String reportName = 'Contract with Id \'';

        reportName += (contract != null) ? String.valueOf(contract.Id) : 'null';

        reportName += '\' failed to';

        reportName += (isAmendment) ? ' amend' : ' renew' ;

        reportName += ' @ ' + dateString;

        legacyContractReport.Name = reportName;

        legacyContractReport.contract__c = (contract != null) ? contract.Id : null ;

        legacyContractReport.generationFailure__c = true;

        legacyContractReport.masterReport__c = masterReportId;

        legacyContractReport.processingInformation__c = exceptionString;

        insert legacyContractReport;

    }

    webservice static String validateAgainstLegacyContract(Id quoteId, Boolean deleteOldReports) {

        validateAgainstLegacyContracts(null, new Set<Id>{quoteId}, deleteOldReports);

        Id myId = UserInfo.getUserId();

        LegacyContractReport__c legacyContractReport = [

            SELECT Id

            FROM LegacyContractReport__c

            WHERE CreatedBy.Id =: myId

            ORDER BY CreatedDate

            DESC LIMIT 1

        ];

        return String.valueOf(legacyContractReport.Id);        

    }       

    webservice static String validateAgainstAllLegacyContracts(Boolean deleteOldReports) {

        Integer quotesPerJob = CventMyd_Settings.quotesPerLegacyValidationJob;

        DateTime createdDateTimeLow = DateTime.newInstance(2018,7,15);

        List<SBQQ__Quote__c> quotes = [

            SELECT Id,(SELECT Id FROM legacyContractReports__r)

            FROM SBQQ__Quote__c

            WHERE (SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.isLegacy__c = true OR

            SBQQ__Opportunity2__r.SBQQ__AmendedContract__r.isLegacy__c = true)

            AND SBQQ__Primary__c = true

            AND (renewalChainMaster__c != null OR

            amendmentChainMaster__c != null)

            AND previousQuote__c = null

            AND Cloned_From_Quote__c = null

            AND CreatedDate >=: createdDateTimeLow

        ];

        Set<Id> quoteIds = (new Map<Id,SBQQ__Quote__c>(quotes)).keySet();

        CventMyd_LegacyValidationQueueable validationQueueable = new CventMyd_LegacyValidationQueueable(new List<Id>(quoteIds), deleteOldReports);

        System.enqueueJob(validationQueueable);

        String resultMessage = String.valueOf(quoteIds.size());

        resultMessage += ' quotes have been sent to a self-chaining queueable job';

        resultMessage += ', ' + String.valueOf(quotesPerJob) + ' quotes per job.';

        return resultMessage;

    }    

    public static void validateAgainstLegacyContracts(Set<Id> chainMasterRecordIds, Set<Id> quoteIds, Boolean deleteOldReports) {

        if(chainMasterRecordIds != null && quoteIds != null) {

            throw new LegacyValidationException('Specificy chain master ids or quote Ids, not both');

        }

        masterReportId = createOrGetMasterReport();

        quoteIds = (quoteIds != null) ? quoteIds : new Set<Id>() ;

        List<SBQQ__Quote__c> quotes = getQuotes(chainMasterRecordIds,quoteIds);

        List<LegacyContractWrapper> legacyContractWrappers = getLegacyContractWrappersAndCreateReports(quotes,deleteOldReports);

        List<LegacyDataComparison__c> comparisonRecords = getDataComparisons(legacyContractWrappers);

        for(LegacyDataComparison__c comparison : comparisonRecords) {

            Boolean isAmendment = quoteIdToQuote.get(comparison.quote__c).SBQQ__Type__c == 'Amendment';

            Contract contract = contractIdtoContract.get(comparison.legacyContract__c);

            Boolean termRenewal = (!isAmendment && contract.Upcoming_Renewal_Type__c == 'Contract Renewal');

            String result;

            Boolean isAmountCheck = (

                comparison.comparisonType__c.contains('TOTAL') ||

                (comparison.parameterValue__c != null && 

                (comparison.parameterValue__c.contains('SBQQ__NetPrice__c') ||

                comparison.parameterValue__c.contains('SBQQ__NetTotal__c')) ||

                comparison.quoteLineField__c == 'Custom_Discount__c')

            );

            Boolean isDiscount = (comparison.quoteLineField__c == 'Custom_Discount__c');

            System.debug('comparison.comparisonType__c: ' + comparison.comparisonType__c);

            System.debug('comparison.parameterName__c: ' + comparison.parameterName__c);

            System.debug('comparison.parameterValue__c: ' + comparison.parameterValue__c);

            System.debug('comparison.isAmountCheck: ' + isAmountCheck);

            String expectedValue = comparison.expectedValue__c;

            String actualValue = comparison.actualValue__c;

            // if expected quantity is 0, then the actual quantity will be no because there will be no mapped quote line

            if(comparison.parameterValue__c != null && comparison.parameterValue__c.contains('SBQQ__Quantity__c')) {

                comparison.isMatch__c = (Decimal.valueOf(expectedValue) == 0 && actualValue == 'N/A') ? true : null;

            }

            if(!isAmountCheck) {

                System.debug('comparison.isMatch__c0: ' + comparison.isMatch__c);

                comparison.isMatch__c = (comparison.isMatch__c != true) ? (expectedValue == actualValue) : comparison.isMatch__c;

                System.debug('comparison.isMatch__c1: ' + comparison.isMatch__c);

                result = (comparison.isMatch__c) ? 'SUCCESS' : 'FAILURE';

                System.debug('result: ' + result);

            }

            else if(isAmountCheck) {

                Boolean bothNull = (expectedValue == null && actualValue == null);

                Boolean bothDontExist = (expectedValue == 'N/A' && actualValue == 'N/A');

                Boolean bothNotNull = (expectedValue != null && actualValue != null);

                Boolean bothExist = (expectedValue != 'N/A' && actualValue != 'N/A');

                if(bothNotNull && bothExist) {

                    Decimal actualValueDec = Decimal.valueOf(comparison.actualValue__c);

                    Decimal expectedValueDec = Decimal.valueOf(comparison.expectedValue__c);                    

                    Decimal difference = actualValueDec - expectedValueDec;

                    difference = Math.abs(difference);

                    comparison.isMatch__c = (difference <= .0049);

                }

                else if(bothNull || bothDontExist) {

                    comparison.isMatch__c = true;

                }                

                else {

                    comparison.isMatch__c = false;

                }

                result = (comparison.isMatch__c) ? 'SUCCESS' : ( (termRenewal && bothNotNull && bothExist && !isDiscount) ? 'NEEDS VALIDATION' : 'FAILURE' );

            }

            comparison.result__c = result;

        }

        insert comparisonRecords;

    }   

    public static List<LegacyContractWrapper> getLegacyContractWrappersAndCreateReports(List<SBQQ__Quote__c> quotes, Boolean deleteOldReports) {

        Map<Id,Id> quoteIdToContractId = new Map<Id,Id>();

        List<LegacyContractReport__c> reportsToDelete = new List<LegacyContractReport__c>();

        for(SBQQ__Quote__c quote : quotes) {

            Boolean legacyRenewal = (quote.SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.isLegacy__c && quote.previousQuote__c == null);

            Boolean legacyAmendment = (quote.SBQQ__Opportunity2__r.SBQQ__AmendedContract__r.isLegacy__c && quote.previousQuote__c == null);

            if(legacyRenewal || legacyAmendment) {

                Id contractId = (legacyRenewal) ? quote.SBQQ__Opportunity2__r.SBQQ__RenewedContract__c : quote.SBQQ__Opportunity2__r.SBQQ__AmendedContract__c ;

                quoteIdToContractId.put(quote.Id,contractId);

            }

            else {

                String exceptionString = 'Quote with Id \'';

                exceptionString += String.valueOf(quote.Id);

                exceptionString += '\' was not generated from a legacy contract';

                throw new LegacyValidationException(exceptionString);

            }

            reportsToDelete.addAll(quote.legacyContractReports__r);

        }

        if(reportsToDelete.size() > 0 && deleteOldReports) {

            delete reportsToDelete;

        }

        Map<Id,SBQQ__Quote__c> quoteIdToQuote = new Map<Id,SBQQ__Quote__c>(quotes);

        Set<Id> contractIds = new Set<Id>(quoteIdToContractId.values());

        System.debug('contractIds: ' + contractIds);

        contractIdToContract = new Map<Id,Contract>([SELECT Id,Multiple_Years_Commitment__c,

            Upcoming_Renewal_Type__c,SBQQ__Quote__c,ContractNumber,

            Current_Year__c,Parent_Contract_Term_Years__c,

            StartDate,EndDate,recordTypeName__c,

            Year_2_End_Date__c,Year_3_End_Date__c,Year_4_End_Date__c,

            Year_5_End_Date__c,Parent_Contract__r.recordTypeName__c,

            Parent_Contract__r.StartDate,Parent_Contract__r.EndDate,

            Parent_Contract__r.Year_2_End_Date__c,Parent_Contract__r.Year_3_End_Date__c,

            Parent_Contract__r.Year_4_End_Date__c,Parent_Contract__r.Year_5_End_Date__c,

            SBQQ__Quote__r.Current_Year__c,SBQQ__Quote__r.Contract_Term_Years__c,

            SBQQ__Quote__r.Effective_Year_2_End_Date__c,SBQQ__Quote__r.Effective_Year_3_End_Date__c,

            SBQQ__Quote__r.Effective_Year_4_End_Date__c,SBQQ__Quote__r.Effective_Year_5_End_Date__c,
            
            SBQQ__Quote__r.SBQQ__EndDate__c,

            SBQQ__Quote__r.SBQQ__StartDate__c,renewalChainMaster__c,

            (SELECT

                Id,SBQQ__PrimaryQuote__c,

                SBQQ__PrimaryQuote__r.Current_Year__c,

                SBQQ__PrimaryQuote__r.Id,

                SBQQ__PrimaryQuote__r.Contract_Term_Years__c,

                SBQQ__PrimaryQuote__r.SBQQ__StartDate__c,

                SBQQ__PrimaryQuote__r.SBQQ__EndDate__c,

                SBQQ__PrimaryQuote__r.Effective_Year_2_End_Date__c,

                SBQQ__PrimaryQuote__r.Effective_Year_3_End_Date__c,

                SBQQ__PrimaryQuote__r.Effective_Year_4_End_Date__c,

                SBQQ__PrimaryQuote__r.Effective_Year_5_End_Date__c

                FROM SBQQ__AmendmentOpportunities__r

                WHERE SBQQ__Contracted__c = true

                LIMIT 2

            )

            FROM Contract

            WHERE Id IN: contractIds

        ]);

        List<LegacyContractReport__c> legacyContractReports = new List<LegacyContractReport__c>();

        for(SBQQ__Quote__c quote : quotes) {

            Id contractId = quoteIdToContractId.get(quote.Id);

            Contract contract = contractIdToContract.get(contractId);

            LegacyContractReport__c legacyContractReport = new LegacyContractReport__c();

            legacyContractReport.masterReport__c = masterReportId;

            legacyContractReport.Name = quote.Name + ' ' + quote.SBQQ__Type__c + ' Validation w.r.t. Legacy Contract ' + contract.ContractNumber;

            legacyContractReport.chainMasterRecord__c = contract.renewalChainMaster__c;

            legacyContractReport.contract__c = contractId;

            legacyContractReport.quote__c = quote.Id;

            legacyContractReport.quoteType__c = quote.SBQQ__Type__c;

            legacyContractReports.add(legacyContractReport);

        }

        insert legacyContractReports;

        List<LegacyContractWrapper> legacyContractWrappers = new List<LegacyContractWrapper>();

        for(LegacyContractReport__c legacyContractReport : legacyContractReports) {

            System.debug('legacyContractReport Id: ' + legacyContractReport.Id);

            LegacyContractWrapper legacyContractWrapper = new LegacyContractWrapper();

            legacyContractWrapper.contractReportId = legacyContractReport.Id;

            legacyContractWrapper.contract = contractIdToContract.get(legacyContractReport.contract__c);

            SBQQ__Quote__c quote = quoteIdToQuote.get(legacyContractReport.quote__c);

            legacyContractWrapper.quote = quote;

            legacyContractWrapper.isAmendment = (quote.SBQQ__Type__c == 'Amendment');

            legacyContractWrappers.add(legacyContractWrapper);

        }

        return legacyContractWrappers;

    }

    public static LegacyDataComparison__c initializeDataCheck(LegacyContractWrapper legacyContractWrapper, ComparisonType comparisonTypeEnum) {

        LegacyDataComparison__c dataCheck = new LegacyDataComparison__c();

        dataCheck.legacyContract__c = legacyContractWrapper.contract.Id;

        dataCheck.quote__c = legacyContractWrapper.quote.Id;

        dataCheck.legacyContractReport__c = legacyContractWrapper.contractReportId;

        dataCheck.comparisonType__c = String.valueOf(comparisonTypeEnum);

        return dataCheck;

    }    

    public static List<LegacyDataComparison__c> getDataComparisons(List<LegacyContractWrapper> legacyContractWrappers) {

        Set<Id> contractIds = new Set<Id>();

        Set<Id> quoteIds = new Set<Id>();

        for(LegacyContractWrapper legacyContractWrapper : legacyContractWrappers) {

            contractIds.add(legacyContractWrapper.contract.Id);

            quoteIds.add(legacyContractWrapper.quote.Id);

        }

        setQuoteIdToQuoteLines(quoteIds);

        String queryString = 'SELECT Id,Name,SBQQ__Product__r.SBQQ__PricingMethod__c,SBQQ__Product__r.Disable_Proration__c';

        queryString += ',' + CventMyd_Settings.legacySubscriptionFieldNamesString;

        queryString += ', (SELECT Id,Name,SBQQ__Quantity__c FROM SBQQ__Revisions__r ORDER BY CreatedDate DESC)';

        queryString += ', (SELECT Id,Name,term__c,SBQQ__Quote__c,SBQQ__Quantity__c,Custom_Discount__c,SBQQ__NetPrice__c,SBQQ__NetTotal__c FROM generatedLines__r)';

        queryString += ', (SELECT Id,Name,term__c,SBQQ__Quote__c,SBQQ__Quantity__c,Custom_Discount__c,SBQQ__NetPrice__c,SBQQ__NetTotal__c FROM SBQQ__RenewalQuoteLines__r)';

        queryString += ', (SELECT Id,Name,term__c,SBQQ__Quote__c,SBQQ__Quantity__c,Custom_Discount__c,SBQQ__NetPrice__c,SBQQ__NetTotal__c FROM SBQQ__UpgradeLines__r)';

        queryString += ' FROM SBQQ__Subscription__c';

        queryString += ' WHERE SBQQ__RevisedSubscription__c = null';

        queryString += ' AND SBQQ__Contract__c IN: contractIds';

        for(SBQQ__Subscription__c subscription : Database.query(queryString)) {

            if(contractIdToSubscriptions.get(subscription.SBQQ__Contract__c) == null) {

                contractIdToSubscriptions.put(subscription.SBQQ__Contract__c, new List<SBQQ__Subscription__c>());

            }

            contractIdToSubscriptions.get(subscription.SBQQ__Contract__c).add(subscription);

        }

        List<LegacyDataComparison__c> dataChecks = new List<LegacyDataComparison__c>();

        for(LegacyContractWrapper legacyContractWrapper : LegacyContractWrappers) {

            Contract contract = legacyContractWrapper.contract;

            SBQQ__Quote__c quote = legacyContractWrapper.quote;

            List<SBQQ__QuoteLine__c> quoteLines = quoteIdToQuoteLines.get(quote.Id);

            ComparisonType comparisonTypeEnum;

            // check variable options checkbox value

            comparisonTypeEnum = ComparisonType.VARIABLE_OPTIONS_CHECKBOX;

            LegacyDataComparison__c variableOptionsCheck = initializeDataCheck(legacyContractWrapper,comparisonTypeEnum);

            variableOptionsCheck.expectedValue__c = String.valueOf(getExpectedVariableOptionsBoolean(legacyContractWrapper));

            variableOptionsCheck.actualValue__c = String.valueOf(quote.Multiple_Years_Commitment__c);

            dataChecks.add(variableOptionsCheck);

            // check current year value

            comparisonTypeEnum = ComparisonType.CURRENT_YEAR;

            LegacyDataComparison__c currentYearCheck = initializeDataCheck(legacyContractWrapper,comparisonTypeEnum);

            currentYearCheck.expectedValue__c = String.valueOf((Integer)quote.Current_Year__c);

            currentYearCheck.actualValue__c = String.valueOf(getExpectedCurrentYear(legacyContractWrapper));

            dataChecks.add(currentYearCheck);

            // check final year value

            comparisonTypeEnum = ComparisonType.FINAL_YEAR;

            LegacyDataComparison__c finalYearCheck = initializeDataCheck(legacyContractWrapper,comparisonTypeEnum);

            finalYearCheck.expectedValue__c = String.valueOf(getExpectedFinalYear(contract));

            finalYearCheck.actualValue__c = quote.Contract_Term_Years__c;

            dataChecks.add(finalYearCheck);

            // check quote line group count

            comparisonTypeEnum = ComparisonType.QUOTE_LINE_GROUP_COUNT;

            LegacyDataComparison__c groupCountCheck = initializeDataCheck(legacyContractWrapper,comparisonTypeEnum);

            groupCountCheck.expectedValue__c = String.valueOf(getExpectedNumberOfQuoteLineGroups(legacyContractWrapper));

            groupCountCheck.actualValue__c = String.valueOf(quote.numberOfQuoteLineGroups__c);

            dataChecks.add(groupCountCheck);

            // check dates

            comparisonTypeEnum = ComparisonType.DATES;

            dataChecks.addAll(getDatesComparisons(legacyContractWrapper,comparisonTypeEnum));

            // check opportunity product count

            if(!legacyContractWrapper.isAmendment) { 

                comparisonTypeEnum = ComparisonType.OPPORTUNITY_LINE_CHECK;

                dataChecks.add(getOpportunityLineCheck(legacyContractWrapper,comparisonTypeEnum));

            }     

            // check number of lines per year

            comparisonTypeEnum = ComparisonType.QUOTE_LINE_COUNTS;

            dataChecks.addAll(getQuoteLineCountComparisons(legacyContractWrapper,comparisonTypeEnum));

            // check period totals (yearly and for entire deal)

            comparisonTypeEnum = ComparisonType.TOTALS;

            dataChecks.addAll(getPeriodTotalsComparisons(legacyContractWrapper,comparisonTypeEnum));

            // for amendments check all net totals are zeroed

            if(legacyContractWrapper.isAmendment) {

                comparisonTypeEnum = ComparisonType.AMENDMENT_ZEROED_CHECK;

                dataChecks.add(getAmendmentZeroedCheck(legacyContractWrapper,comparisonTypeEnum));

            }            

            // check subscription values (quantity, discount, net total, and net price)

            comparisonTypeEnum = ComparisonType.SUBSCRIPTION_VALUE_CHECK;

            dataChecks.addAll(getSubscriptionValueComparisons(legacyContractWrapper,comparisonTypeEnum));

        }

        return dataChecks;

    }

    public static Boolean getExpectedVariableOptionsBoolean(LegacyContractWrapper legacyContractWrapper) {

        Contract contract = legacyContractWrapper.contract;

        SBQQ__Quote__c quote = legacyContractWrapper.quote;

        Boolean isTermRenewal = (contract.Upcoming_Renewal_Type__c == 'Contract Renewal');

        Boolean isAmendment = (quote.SBQQ__Type__c == 'Amendment');

        Boolean expectedVariablOptionsBoolean = contract.Multiple_Years_Commitment__c;

        expectedVariablOptionsBoolean = (isTermRenewal && !isAmendment) ? false : expectedVariablOptionsBoolean;

        return expectedVariablOptionsBoolean;

    }    

    public static Integer getExpectedCurrentYear(LegacyContractWrapper legacyContractWrapper) {

        Contract contract = legacyContractWrapper.contract;

        Boolean isAmendment = legacyContractWrapper.isAmendment;

        Boolean isTermRenewal = (!isAmendment && (contract.Upcoming_Renewal_Type__c == 'Contract Renewal'));

        Integer expectedCurrentYear = Integer.valueOf(contract.Current_Year__c);

        if(isTermRenewal) {expectedCurrentYear = 1;}

        else if(!isAmendment) {expectedCurrentYear++;}

        return expectedCurrentYear;

    }

    public static Integer getExpectedFinalYear(Contract legacyContract) {

        return Integer.valueOf(legacyContract.Parent_Contract_Term_Years__c);

    }

    public static List<Integer> getExpectedOutyears(LegacyContractWrapper legacyContractWrapper) {

        Contract contract = legacyContractWrapper.contract;

        Boolean isAmendment = legacyContractWrapper.isAmendment;

        Boolean isTermRenewal = (!isAmendment && (contract.Upcoming_Renewal_Type__c == 'Contract Renewal'));

        Integer currentYear = getExpectedCurrentYear(legacyContractWrapper);

        Integer finalYear = getExpectedFinalYear(contract);

        List<Integer> outyears = new List<Integer>();

        for(Integer year = currentYear + 1; year <= finalYear; year++) {

            outyears.add(year);

        }

        System.debug('contractId: ' + contract.Id);

        System.debug('expected out years: ' + outyears);

        return outyears;

    }

    public static List<Integer> getExpectedQuoteYears(LegacyContractWrapper legacyContractWrapper) {

        List<Integer> expectedQuoteYears = new List<Integer>();

        expectedQuoteYears.add(getExpectedCurrentYear(legacyContractWrapper));

        expectedQuoteYears.addAll(getExpectedOutyears(legacyContractWrapper));

        return expectedQuoteYears;

    }

    public static Date getExpectedStartDate(LegacyContractWrapper legacyContractWrapper) {

        SBQQ__Quote__c quote = legacyContractWrapper.quote;

        if(legacyContractWrapper.isAmendment) {

            DateTime createdDateTime = quote.CreatedDate;

            Date createdDate = createdDateTime.dateGMT();

            Date actualStartDate = quote.SBQQ__StartDate__c;

            Boolean sameYear = actualStartDate.year() == createdDate.year();

            Boolean sameMonth = actualStartDate.month() == createdDate.month();

            if(sameYear && sameMonth && Math.abs(createdDate.day() - quote.SBQQ__StartDate__c.day()) == 1) {

                return quote.SBQQ__StartDate__c;

            }

            else {

                return createdDate;

            } 

        }

        else {

            return legacyContractWrapper.contract.EndDate.addDays(1);

        }

    }    

    public static Date getExpectedEndDate(LegacyContractWrapper legacyContractWrapper) {

        Date expectedEndDate;

        Integer expectedCurrentYear = getExpectedCurrentYear(legacyContractWrapper);

        Date expectedStartDate = getExpectedStartDate(legacyContractWrapper);

        Contract contract = legacyContractWrapper.contract;

        SBQQ__Quote__c quote = getQuoteToUseForEndDate(contract,expectedCurrentYear,expectedStartDate);

        Map<Integer,String> yearToEndDateFieldName;

        String endDateFieldName;

        if(legacyContractWrapper.isAmendment) {

            System.debug('this happened XYZ0');

            expectedEndDate = contract.EndDate;

        }

        else if(contract.Upcoming_Renewal_Type__c == 'Contract Renewal') {

            System.debug('this happened XYZ1');

            expectedEndDate = contract.EndDate.addDays(1);

            expectedEndDate = expectedEndDate.addMonths(12);

            expectedEndDate = expectedEndDate.addDays(-1);

            expectedEndDate = expectedEndDate;

        }

        else if(quote != null && quote.Id == null) {

            System.debug('this happened XYZ2');

            expectedEndDate = CventMyd_LegacyContractHandler.getEndDateForQuoteCreatedFromLegacyContract(quote,contract);

        }

        else if(quote != null) {

            System.debug('this happened XYZ3');

            yearToEndDateFieldName = CventMyd_UtilityMethods.getYearToEndDateFieldName(quote);

            yearToEndDateFieldName = replaceYearWithEffectiveYear(yearToEndDateFieldName);

            System.debug('yearToEndDateFieldName: ' + yearToEndDateFieldName);

            endDateFieldName = yearToEndDateFieldName.get(expectedCurrentYear);

            System.debug('endDateFieldName: ' + endDateFieldName);

            System.debug('expectedCurrentYear: ' + expectedCurrentYear);

            expectedEndDate = (endDateFieldName != null && quote.get(endDateFieldName) != null) ? (Date)quote.get(endDateFieldName) : Date.newInstance(1901,1,1);

        }

        else if (quote == null) {

            System.debug('this happened XYZ4');

            yearToEndDateFieldName = CventMyd_UtilityMethods.getYearToEndDateFieldName(contract);

            endDateFieldName = yearToEndDateFieldName.get(expectedCurrentYear);

            expectedEndDate = (Date)contract.get(endDateFieldName);

        }

        System.debug('expectedEndDate: ' + expectedEndDate);

        return expectedEndDate;   
  
    }

    public static SBQQ__Quote__c getQuoteToUseForEndDate(Contract contract, Integer expectedCurrentYear, Date expectedStartDate) {

        SBQQ__Quote__c quote;

        List<Opportunity> amendmentOpportunities = contract.SBQQ__AmendmentOpportunities__r;

        if(amendmentOpportunities.isEmpty() || amendmentOpportunities.size() == 2) {

            if(contract.SBQQ__Quote__r == null && amendmentOpportunities.isEmpty()) {

                quote = new SBQQ__Quote__c(Current_Year__c = expectedCurrentYear, SBQQ__StartDate__c = expectedStartDate) ;

            }

            else if (contract.SBQQ__Quote__r != null && amendmentOpportunities.isEmpty()) {

                quote = contract.SBQQ__Quote__r;

            }

            else if(amendmentOpportunities.size() == 2) {

                quote = null;

            }

        }

        else if (amendmentOpportunities.size() == 1) {

            quote = amendmentOpportunities[0].SBQQ__PrimaryQuote__r;

        }

        return quote;

    }    

    public static Map<Integer,CventMyd_Outyear> getExpectedOutyearMap(LegacyContractWrapper legacyContractWrapper) {

        Map<Integer,CventMyd_Outyear> outyearMap = new Map<Integer,CventMyd_Outyear>();

        List<Integer> outyears = getExpectedOutyears(legacyContractWrapper);

        Contract contract = legacyContractWrapper.contract;

        Boolean isAmendment = legacyContractWrapper.isAmendment;

        Boolean isTermRenewal = (!isAmendment && contract.Upcoming_Renewal_Type__c == 'Contract Renewal');

        if(isAmendment || !isTermRenewal) {

            Sobject record = (contract.SBQQ__Quote__c != null) ? (SObject)contract.SBQQ__Quote__r : (SObject)contract;

            List<Opportunity> amendmentOpportunities = contract.SBQQ__AmendmentOpportunities__r;

            record = (amendmentOpportunities.size() == 1) ? (SObject)amendmentOpportunities[0].SBQQ__PrimaryQuote__r : record;

            record = (amendmentOpportunities.size() == 2) ? (SObject)contract : record;

            Map<Integer,String> yearToEndDateFieldName = CventMyd_UtilityMethods.getYearToEndDateFieldName(record);

            Date previousYearEndDate = getExpectedEndDate(legacyContractWrapper);

            System.debug('contract.Id: ' + contract.Id);

            System.debug('previousYearEndDate: ' + previousYearEndDate);

            previousYearEndDate = (previousYearEndDate == null) ? Date.newInstance(1901,1,1) : previousYearEndDate;

            for(Integer year : outyears) {

                CventMyd_Outyear outyear = new CventMyd_Outyear();

                String objectName = String.valueOf(record.getSObjectType());

                if(previousYearEndDate == null && outyears.indexOf(year) != 0 && objectName == 'Child Contract') {

                    record = (SObject)contract.Parent_Contract__r;

                    yearToEndDateFieldName = CventMyd_UtilityMethods.getYearToEndDateFieldName(record);

                    String endDateFieldName = yearToEndDateFieldName.get(year - 1);

                    previousYearEndDate = (Date)record.get(endDateFieldName);

                }

                yearToEndDateFieldName = (objectName == 'SBQQ__Quote__c') ? replaceYearWithEffectiveYear(yearToEndDateFieldName) : yearToEndDateFieldName;

                outyear.startDate = previousYearEndDate.addDays(1);

                System.debug('outyear.startDate: ' + outyear.startDate);

                String endDateFieldName = yearToEndDateFieldName.get(year);

                System.debug('year: ' + year);

                System.debug('endDateFieldName: ' + endDateFieldName);

                System.debug('yearToEndDateFieldName: ' + yearToEndDateFieldName);

                System.debug('record: ' + record);

                outyear.endDate = (endDateFieldName != null) ? (Date)record.get(endDateFieldName) : null;

                if(outyear.endDate == null) {

                    outyear.endDate = outyear.startDate.addMonths(12);

                    outyear.endDate = outyear.endDate.addDays(-1);

                }

                System.debug('outyear.endDate: ' + outyear.endDate);

                outyearMap.put(year,outyear);

                previousYearEndDate = outyear.endDate;

            }

        }

        else if(isTermRenewal) {

            Date previousYearEndDate = contract.EndDate.addDays(1);

            previousYearEndDate = previousYearEndDate.addMonths(12);

            previousYearEndDate = previousYearEndDate.addDays(-1);

            for(Integer year : outyears) {

                CventMyd_Outyear outyear = new CventMyd_Outyear();

                outyear.startDate = previousYearEndDate.addDays(1);

                outyear.endDate = outyear.startDate.addMonths(12);

                outyear.endDate = outyear.endDate.addDays(-1);

                outyearMap.put(year,outyear);

                previousYearEndDate = outyear.endDate;

            }

        }

        return outyearMap;

    }     

    public static Integer getExpectedNumberOfQuoteLineGroups(LegacyContractWrapper legacyContractWrapper) {

        Contract contract = legacyContractWrapper.contract;

        Integer expectedNumberOfQuoteLineGroups = 0;

        Boolean isAmendment = legacyContractWrapper.isAmendment;

        Boolean termRenewal = (!isAmendment && legacyContractWrapper.contract.Upcoming_Renewal_Type__c == 'Contract Renewal');

        if(contract.Multiple_Years_Commitment__c && !termRenewal) {

            expectedNumberOfQuoteLineGroups = getExpectedQuoteYears(legacyContractWrapper).size();

        }

        return expectedNumberOfQuoteLineGroups;     

    }

    public static Map<Integer,Integer> getExpectedGroupYearToQuoteLineCount(LegacyContractWrapper legacyContractWrapper) {

        Contract contract = legacyContractWrapper.contract;

        Boolean isAmendment = legacyContractWrapper.isAmendment;

        List<SBQQ__Subscription__c> subscriptions = contractIdToSubscriptions.get(contract.Id);

        Boolean shouldBeVariableOptions = getExpectedVariableOptionsBoolean(legacyContractWrapper);

        Map<Integer,Integer> groupYearToQuoteLineCount = new Map<Integer,Integer>();

        List<Integer> expectedQuoteYears = getExpectedQuoteYears(legacyContractWrapper);

        System.debug('expectedQuoteYears: ' + expectedQuoteYears);

        System.debug('contract.Id: ' + contract.Id);

        if(!shouldBeVariableOptions) {

            System.debug('this happened 0');

            Integer expectedQuoteLineCount = 0;

            if(subscriptions != null) {

                for(SBQQ__Subscription__c subscription : subscriptions) {

                    Boolean isNonRecurring = (subscription.SBQQ__Product__r.Revenue_Type__c == 'Non-Recurring');

                    Boolean isTermRenewal = (!isAmendment && contract.Upcoming_Renewal_Type__c == 'Contract Renewal');

                    if(!(isNonRecurring && isTermRenewal)) {                

                        Decimal currentYearQuantity = CventMyd_LegacyContractHandler.getCurrentYearQuantity(subscription);

                        expectedQuoteLineCount += (currentYearQuantity != 0) ? 1 : 0 ;

                    }

                }

            }

            groupYearToQuoteLineCount.put(-1,expectedQuoteLineCount);

        }

        else if(shouldBeVariableOptions) {

            List<String> quantityFieldNames = quoteLineFieldNameToSubscriptionFieldNames.get('SBQQ__Quantity__c');

            System.debug('quantityFieldNames: ' + quantityFieldNames);

            if(subscriptions != null) {

                for(SBQQ__Subscription__c subscription : subscriptions) {

                    for(Integer year : expectedQuoteYears) {

                        System.debug('year: ' + year);

                        if(groupYearToQuoteLineCount.get(year) == null) {groupYearToQuoteLineCount.put(year,0);}

                        Integer expectedQuoteLineCount = groupYearToQuoteLineCount.get(year);

                        Integer yearIndex = expectedQuoteYears.indexOf(year);

                        Boolean isCurrentYear = (yearIndex == 0);

                        yearIndex = (!isAmendment) ? yearIndex + 1 : yearIndex;

                        String yearQuantityFieldName = quantityFieldNames[yearIndex];

                        Decimal yearQuantity = (Decimal)subscription.get(yearQuantityFieldName);

                        yearQuantity = (yearQuantity == null || isAmendment && isCurrentYear) ? CventMyd_LegacyContractHandler.getCurrentYearQuantity(subscription) : yearQuantity ;

                        expectedQuoteLineCount += (yearQuantity != 0 && yearQuantity != null) ? 1 : 0 ;

                        groupYearToQuoteLineCount.put(year,expectedQuoteLineCount);

                    }

                }

            }      

        }

        return groupYearToQuoteLineCount;

    }

    public static Map<Integer,List<Date>> getExpectedYearToDates(LegacyContractWrapper legacyContractWrapper) {

        Map<Integer,List<Date>> expectedYearToDates = new Map<Integer,List<Date>>();

        Integer expectedCurrentYear = getExpectedCurrentYear(legacyContractWrapper);

        expectedYearToDates.put(expectedCurrentYear,new List<Date>());

        expectedYearToDates.get(expectedCurrentYear).add(getExpectedStartDate(legacyContractWrapper));

        expectedYearToDates.get(expectedCurrentYear).add(getExpectedEndDate(legacyContractWrapper));

        Map<Integer,CventMyd_Outyear> expectedYearToOutyear = getExpectedOutyearMap(legacyContractWrapper);

        for(Integer year : expectedYearToOutyear.keySet()) {

            expectedYearToDates.put(year,new List<Date>());

            expectedYearToDates.get(year).add(expectedYearToOutyear.get(year).startDate);

            expectedYearToDates.get(year).add(expectedYearToOutyear.get(year).endDate);

        }

        return expectedYearToDates;

    }

    public static List<LegacyDataComparison__c> getDatesComparisons(LegacyContractWrapper legacyContractWrapper, ComparisonType comparisonTypeEnum) {

        Contract contract = legacyContractWrapper.contract;

        SBQQ__Quote__c quote = legacyContractWrapper.quote;

        Map<Integer,List<Date>> expectedYearToDates = getExpectedYearToDates(legacyContractWrapper);

        List<SBQQ__QuoteLine__c> quoteLines = quoteIdToQuoteLines.get(quote.Id);

        Id contractReportId = legacyContractWrapper.contractReportId;        

        Map<Integer,List<Date>> actualYearToDates = new Map<Integer,List<Date>>();

        Integer actualCurrentYear = (Integer)quote.Current_Year__c;

        actualYearToDates.put(actualCurrentYear,new List<Date>());

        actualYearToDates.get(actualCurrentYear).add(quote.SBQQ__StartDate__c);

        actualYearToDates.get(actualCurrentYear).add(quote.SBQQ__EndDate__c);

        CventMyd_QuoteObject quoteObject = CventMyd_UtilityMethods.getQuoteObject(quote);

        Map<Integer,CventMyd_Outyear> actualOutyearMap = quoteObject.outyearMap;             

        for(Integer year : actualOutyearMap.keySet()) {

            actualYearToDates.put(year,new List<Date>());

            actualYearToDates.get(year).add(actualOutyearMap.get(year).startDate);

            actualYearToDates.get(year).add(actualOutyearMap.get(year).endDate);

        }

        List<LegacyDataComparison__c> datesComparisons = new List<LegacyDataComparison__c>();

        System.debug('quote.Id: ' + quote.Id);

        System.debug('actualYearToDates: ' + actualYearToDates);

        System.debug('expectedYearToDates: ' + expectedYearToDates);

        for(Integer year : expectedYearToDates.keySet()) {

            LegacyDataComparison__c startDateComparison = initializeDataCheck(legacyContractWrapper,comparisonTypeEnum);

            startDateComparison.parameterName__c = 'Year Start Date';

            startDateComparison.parameterValue__c = 'Year ' + String.valueOf(year);

            startDateComparison.expectedValue__c = String.valueOf(expectedYearToDates.get(year)[0]);

            startDateComparison.actualValue__c =  (actualYearToDates.containsKey(year)) ? String.valueOf(actualYearToDates.get(year)[0]) : null;

            LegacyDataComparison__c endDateComparison = initializeDataCheck(legacyContractWrapper,comparisonTypeEnum);

            endDateComparison.parameterName__c = 'Year End Date';

            endDateComparison.parameterValue__c = 'Year ' + String.valueOf(year);

            endDateComparison.expectedValue__c = String.valueOf(expectedYearToDates.get(year)[1]);

            endDateComparison.actualValue__c =  (actualYearToDates.containsKey(year)) ? String.valueOf(actualYearToDates.get(year)[1]) : null;

            datesComparisons.add(startDateComparison);

            datesComparisons.add(endDateComparison);

        }

        return datesComparisons;

    }

    public static List<LegacyDataComparison__c> getSubscriptionValueComparisons(LegacyContractWrapper legacyContractWrapper, ComparisonType comparisonTypeEnum) {

        Id quoteId = legacyContractWrapper.quote.Id;

        Boolean isAmendment = legacyContractWrapper.isAmendment;

        List<LegacyDataComparison__c> subscriptionValueComparisons = new List<LegacyDataComparison__c>();

        ExpectedValuesWrapper expectedValuesWrapper = getExpectedValuesWrapper(legacyContractWrapper);

        Map<Id,ExpectedValues> subscriptionIdToExpectedValues = expectedValuesWrapper.subscriptionIdToExpectedValues;

        Map<Integer,List<LegacyDataComparison__c>> yearToComparisons = new Map<Integer,List<LegacyDataComparison__c>>();

        List<Integer> expectedQuoteYears = getExpectedQuoteYears(legacyContractWrapper);

        expectedQuoteYears = (!getExpectedVariableOptionsBoolean(legacyContractWrapper)) ? new List<Integer>{getExpectedCurrentYear(legacyContractWrapper)} : expectedQuoteYears;

        Map<Id,SBQQ__Subscription__c> subscriptionIdToSubscription = new Map<Id,SBQQ__Subscription__c>();

        if(contractIdToSubscriptions.get(legacyContractWrapper.contract.Id) != null) {

            subscriptionIdToSubscription = new Map<Id,SBQQ__Subscription__c>(contractIdToSubscriptions.get(legacyContractWrapper.contract.Id));

        }

        for(Id subscriptionId : subscriptionIdToExpectedValues.keySet()) {

            SBQQ__Subscription__c subscription = subscriptionIdToSubscription.get(subscriptionId);

            ExpectedValues expectedValues = subscriptionIdToExpectedValues.get(subscriptionId);

            Map<Integer,Values> yearToValues = expectedValues.yearToValues;

            for(Integer year : expectedQuoteYears) {

                Values values = yearToValues.get(year);

                Map<String,Decimal> fieldNameToFieldvalue = values.fieldNameToFieldvalue;

                for(String fieldName : fieldNameToFieldvalue.keySet()) {

                    LegacyDataComparison__c valueComparison = initializeDataCheck(legacyContractWrapper,comparisonTypeEnum);

                    valueComparison.parameterName__c = 'Year; Field Name';

                    valueComparison.parameterValue__c = 'Year ' + String.valueOf(year) + '; ' + fieldName;

                    valueComparison.year__c = year;

                    valueComparison.quoteLineField__c = fieldName;

                    System.debug('zeroDebug1:' + subscription.Name + ':' + fieldName);

                    System.debug('fieldNameToFieldValue0: ' + JSON.serialize(fieldNameToFieldValue));

                    System.debug('fieldNameToFieldvalue.get(fieldName): ' + fieldNameToFieldvalue.get(fieldName));

                    valueComparison.expectedValue__c = (fieldNameToFieldValue.get(fieldName) == -69696.6969696969) ? 'N/A' : String.valueOf(fieldNameToFieldValue.get(fieldName)) ;

                    System.debug('valueComparison.expectedValue__c: ' + valueComparison.expectedValue__c);

                    valueComparison.subscription__c = subscriptionId;

                    List<String> results = getActualSubscriptionValueFromQuoteLine(subscription,quoteId,year,fieldName);

                    valueComparison.actualValue__c = results[0]; valueComparison.quoteLine__c = results[1];

                    if(yearToComparisons.get(year) == null) {

                        yearToComparisons.put(year, new List<LegacyDataComparison__c>());

                    }

                    if(!(isAmendment && fieldName == 'SBQQ__NetTotal__c')) {

                        yearToComparisons.get(year).add(valueComparison);

                    }

                }

            }

        }

        for(Integer year : yearToComparisons.keySet()) {

            subscriptionValueComparisons.addAll(yearToComparisons.get(year));

        }

        return subscriptionValueComparisons;

    }

    public static List<String> getActualSubscriptionValueFromQuoteLine(SBQQ__Subscription__c subscription, Id quoteId, Integer year, String fieldName) {

        String actualValue;

        String quoteLineIdString;

        List<SBQQ__QuoteLine__c> generatedLines = subscription.SBQQ__RenewalQuoteLines__r;

        generatedLines.addAll(subscription.generatedLines__r);

        generatedLines.addAll(subscription.SBQQ__UpgradeLines__r);

        Boolean matchFound = false;

        for(SBQQ__QuoteLine__c quoteLine : generatedLines) {

            if((Integer)quoteLine.term__c == year && quoteLine.SBQQ__Quote__c == quoteId) {

                actualValue = String.valueOf(quoteLine.get(fieldName));

                if(!matchFound) {

                    matchFound = true;

                    quoteLineIdString = String.valueOf(quoteLine.Id);

                }

                else if(matchFound) {

                    String exceptionString = 'Multiple quote lines were generated for subscription with Id \'';

                    exceptionString += String.valueOf(subscription.Id);

                    exceptionString += '\' for Year ';

                    exceptionString += String.valueOf(year);

                    throw new LegacyValidationException(exceptionString);

                }

            }

        }

        return (matchFound) ? new List<String>{actualValue,quoteLineIdString} : new List<String>{'N/A',null} ;     

    }

    public static List<LegacyDataComparison__c> getPeriodTotalsComparisons(LegacyContractWrapper legacyContractWrapper, ComparisonType comparisonTypeEnum) {

        List<LegacyDataComparison__c> totalsComparisons = new List<LegacyDataComparison__c>();

        ExpectedValuesWrapper expectedValuesWrapper = getExpectedValuesWrapper(legacyContractWrapper);

        Map<Integer,Decimal> expectedYearToTotal = expectedValuesWrapper.expectedYearToTotal;

        Map<Integer,Decimal> actualYearToTotal = getActualYearToTotal(legacyContractWrapper.quote);

        Decimal expectedOverallTotal = 0.00000;

        Decimal actualOverallTotal = 0.00000;

        List<Integer> expectedQuoteYears = getExpectedQuoteYears(legacyContractWrapper);

        for(Integer year : expectedQuoteYears) {

            LegacyDataComparison__c yearTotalComparison = initializeDataCheck(legacyContractWrapper,comparisonTypeEnum);

            Decimal expectedYearTotal = expectedYearToTotal.get(year);

            Decimal acutalYearTotal = actualYearToTotal.get(year);

            expectedYearTotal = (expectedYearTotal != null) ? expectedYearTotal : 0;

            System.debug('expectedYearTotal: ' + expectedYearTotal);

            expectedOverallTotal += expectedYearTotal;

            actualOverallTotal += (acutalYearTotal != null) ? acutalYearTotal : 0;

            yearTotalComparison.parameterName__c = 'Period Total';

            yearTotalComparison.parameterValue__c = 'Year ' + String.valueOf(year);

            yearTotalComparison.year__c = year;

            yearTotalComparison.expectedValue__c = String.valueOf(expectedYearTotal);

            yearTotalComparison.actualValue__c = String.valueOf(acutalYearTotal);

            totalsComparisons.add(yearTotalComparison);

        }

        Integer expectedCurrentYear = getExpectedCurrentYear(legacyContractWrapper);

        Integer expectedFinalYear = getExpectedFinalYear(legacyContractWrapper.contract);

        if(expectedFinalYear > expectedCurrentYear) {

            LegacyDataComparison__c overallTotalComparison = initializeDataCheck(legacyContractWrapper,comparisonTypeEnum);

            overallTotalComparison.parameterName__c = 'Period Total';

            overallTotalComparison.parameterValue__c = 'Year ' + expectedCurrentYear;

            overallTotalComparison.parameterValue__c += ' - ' + expectedFinalYear;

            overallTotalComparison.expectedValue__c = String.valueOf(expectedOverallTotal);

            overallTotalComparison.actualValue__c = String.valueOf(actualOverallTotal);

            totalsComparisons.add(overallTotalComparison);

        }

        return totalsComparisons;

    }

    public static Map<Integer,Decimal> getActualYearToTotal(SBQQ__Quote__c quote) {

        List<SBQQ__QuoteLine__c> quoteLines = quoteIdToQuoteLines.get(quote.Id);

        Map<Integer,Decimal> yearToTotal = new Map<Integer,Decimal>();

        Integer currentYear = (Integer)quote.Current_Year__c;

        Integer finalYear = Integer.valueOf(quote.Contract_Term_Years__c);

        if(quoteLines != null) {

            for(SBQQ__QuoteLine__c quoteLine : quoteLines) {

                Integer year = (Integer)quoteLine.term__c;

                Decimal total = (yearToTotal.get(year) != null) ? yearToTotal.get(year) : 0.0000;

                total += (quoteLine.SBQQ__NetTotal__c != null) ? quoteLine.SBQQ__NetTotal__c : 0 ;

                System.debug('quoteLine.SBQQ__NetTotal__c: ' + quoteLine.SBQQ__NetTotal__c);

                yearToTotal.put(year,total);

            }

        }

        else {

            yearToTotal = (Map<Integer,Decimal>)getYearToZeroMap(quote);

        }

        System.debug('yearToTotal: ' + yearToTotal);

        ComparisonType comparisonTypeEnum = ComparisonType.DATES;

        if(!quote.Multiple_Years_Commitment__c && finalYear > currentYear) {

            Decimal currentYearTotal = yearToTotal.get(currentYear);

            for(Integer year = currentYear + 1; year <= finalYear; year++) {

                yearToTotal.put(year,currentYearTotal);

            }

        }

        return yearToTotal;

    }

    public static final List<String> quoteLineFieldNamesToCompare = new List<String>{

        'SBQQ__Quantity__c',

        'Custom_Discount__c',

        'SBQQ__NetTotal__c',

        'SBQQ__NetPrice__c'

    };

    public class ExpectedValuesWrapper {

        public Map<Id,ExpectedValues> subscriptionIdToExpectedValues;

        public Map<Integer,Decimal> expectedYearToTotal;

    }

    public class ExpectedValues {

        Map<Integer,Values> yearToValues;

        public ExpectedValues() {

            this.yearToValues = new Map<Integer,Values>();

        }

    }

    public class Values {

        Map<String,Decimal> fieldNameToFieldValue;

        public Values() {

            this.fieldNameToFieldValue = new Map<String,Decimal>();

        }

    }   

    public static ExpectedValuesWrapper getExpectedValuesWrapper(LegacyContractWrapper legacyContractWrapper) {

        ExpectedValuesWrapper expectedValuesWrapper = new ExpectedValuesWrapper();

        Map<Id,ExpectedValues> subscriptionIdToExpectedValues = getSubscriptionIdToExpectedValues(legacyContractWrapper);

        expectedValuesWrapper.subscriptionIdToExpectedValues = subscriptionIdToExpectedValues;

        Map<Integer,Decimal> expectedYearToTotal = new Map<Integer,Decimal>();

        for(ExpectedValues expectedValues : subscriptionIdToExpectedValues.values()) {

            Map<Integer,Values> yearToValues = expectedValues.yearToValues;

            for(Integer year : yearToValues.keySet()) {

                System.debug('year: (totals debugging): ' + year);

                Decimal summedTotal = (expectedYearToTotal.get(year) != null) ? expectedYearToTotal.get(year) : 0.00000;

                Values values = yearToValues.get(year);

                Decimal thisTotal = values.fieldNameToFieldValue.get('SBQQ__NetTotal__c');

                System.debug('thisTotal: ' + thisTotal);

                summedTotal += (thisTotal != null && thisTotal != -69696.6969696969) ? thisTotal : 0;

                System.debug('summedTotal: ' + summedTotal);

                expectedYearToTotal.put(year,summedTotal);

            }

        }

        expectedValuesWrapper.expectedYearToTotal = expectedYearToTotal;

        return expectedValuesWrapper;

    }

    public static Map<Id,ExpectedValues> getSubscriptionIdToExpectedValues(LegacyContractWrapper legacyContractWrapper) {

        Contract contract = legacyContractWrapper.contract;

        SBQQ__Quote__c quote = legacyContractWrapper.quote;

        Boolean isAmendment = legacyContractWrapper.isAmendment;

        List<SBQQ__Subscription__c> subscriptions = (contractIdToSubscriptions.get(contract.Id) != null) ? contractIdToSubscriptions.get(contract.Id) : new List<SBQQ__Subscription__c>();

        List<Integer> expectedQuoteYears = getExpectedQuoteYears(legacyContractWrapper);

        Boolean isTermRenewal = (!isAmendment && contract.Upcoming_Renewal_Type__c == 'Contract Renewal');

        System.debug('isTermRenewal?? : ' + isTermRenewal);

        System.debug('expectedQuoteYears: ' + expectedQuoteYears);

        Map<Id,ExpectedValues> subscriptionIdToExpectedValues = new Map<Id,ExpectedValues>();

        System.debug('quoteLineFieldNameToSubscriptionFieldNames (initial): ' + quoteLineFieldNameToSubscriptionFieldNames.get('SBQQ__NetTotal__c'));

        Map<String,List<String>> fieldNameToFieldNames = quoteLineFieldNameToSubscriptionFieldNames;

        Map<Integer,List<Date>> yearToExpectedDates = getExpectedYearToDates(legacyContractWrapper);

        List<String> fieldNames;

        if(getExpectedVariableOptionsBoolean(legacyContractWrapper)) {

            fieldNames = getNetAmountFieldNames(legacyContractWrapper);

        }

        else {

            fieldNames = new List<String>{'SBQQ__NetPrice__c','SBQQ__NetPrice__c','SBQQ__NetPrice__c','SBQQ__NetPrice__c','SBQQ__NetPrice__c'};

        }

        fieldNameToFieldNames.put('SBQQ__NetTotal__c', fieldNames);

        System.debug('quoteLineFieldNameToSubscriptionFieldNames (after): ' + quoteLineFieldNameToSubscriptionFieldNames.get('SBQQ__NetTotal__c'));

        for(Integer year : expectedQuoteYears) {

            System.debug('year: ' + year);

            Integer yearIndex = expectedQuoteYears.indexOf(year);

            yearIndex = (!isAmendment && !isTermRenewal) ? yearIndex + 1 : yearIndex ;

            Boolean isCurrentYear = (year == getExpectedCurrentYear(legacyContractWrapper));

            for(SBQQ__Subscription__c subscription : subscriptions) {

                System.debug('subscription.Id: (expectedValues debug): ' + subscription.Id );

                if(subscriptionIdToExpectedValues.get(subscription.Id) == null) {

                    subscriptionIdToExpectedValues.put(subscription.Id, new ExpectedValues());

                }

                ExpectedValues expectedValues = subscriptionIdToExpectedValues.get(subscription.Id);

                Map<Integer,Values> yearToValues = expectedValues.yearToValues;

                Values values = new Values();

                Map<String,Decimal> fieldNameToFieldValue = new Map<String,Decimal>();

                for(String quoteLineFieldName : quoteLineFieldNamesToCompare) {

                    System.debug('quoteLineFieldName0: ' + quoteLineFieldName);

                    List<String> subscriptionFieldNames = quoteLineFieldNameToSubscriptionFieldNames.get(quoteLineFieldName);

                    System.debug('subscriptionFieldNames: ' + subscriptionFieldNames);

                    System.debug('yearIndex: ' + yearIndex);

                    String subscriptionFieldName = subscriptionFieldNames[yearIndex];

                    System.debug('subscriptionFieldName: ' + subscriptionFieldName);

                    Decimal expectedValue = (Decimal)subscription.get(subscriptionFieldName);

                    Boolean checkCurrentYearPrice = false;

                    if(expectedValue == null) {

                        if(subscriptionFieldName.contains('_Net_Amount')) {

                            subscriptionFieldName = subscriptionFieldName.replace('_Net_','_Effective_');

                            expectedValue = (Decimal)subscription.get(subscriptionFieldName);

                            checkCurrentYearPrice = (expectedValue == null) ? true : false ;

                        }

                        else if(subscriptionFieldName.contains('Quantity_X')) {

                            expectedValue = CventMyd_LegacyContractHandler.getCurrentYearQuantity(subscription);

                        }

                        if(expectedValue == null) {

                            subscriptionFieldName = (checkCurrentYearPrice) ? 'SBQQ__NetPrice__c' : subscriptionFieldName;

                            expectedValue = (Decimal)subscription.get(subscriptionFieldNames[0]);

                        }

                    }

                    expectedValue = (quoteLineFieldName == 'SBQQ__Quantity__c') ? expectedValue.setScale(2) : expectedValue;

                    // if subscription field name is SBQQ__Quantity__c, use calculate quantity based on revisions

                    if(subscriptionFieldName == 'SBQQ__Quantity__c') {

                        Boolean isNonRecurring = (subscription.SBQQ__Product__r.Revenue_Type__c == 'Non-Recurring');  

                        System.debug('isNonRecurring??: ' + isNonRecurring);

                        if(!(isNonRecurring && isTermRenewal)) {    

                            expectedValue = CventMyd_LegacyContractHandler.getCurrentYearQuantity(subscription);

                        }

                        else {

                            expectedValue = 0;

                        }

                        System.debug('expected current year quantity: ' + expectedValue);

                    }
                    
                    Decimal expectedQuantity = fieldNameToFieldValue.get('SBQQ__Quantity__c');

                    System.debug('expectedQuantity: ' + expectedQuantity);

                    if(expectedQuantity != 0) {

                        // below is for current year net total - it should be SBQQ__NetPrice__c * effective quantity

                        if(quoteLineFieldName == 'SBQQ__NetTotal__c' && subscriptionFieldName == 'SBQQ__NetPrice__c') {

                            Decimal expectedNetPrice = expectedValue;

                            System.debug('expectedNetPrice: ' + expectedNetPrice);

                            Decimal multiplier = (subscription.SBQQ__Product__r.SBQQ__PricingMethod__c == 'Block') ? 1 : expectedQuantity;

                            System.debug('multiplier: ' + multiplier);

                            expectedValue = expectedNetPrice * multiplier;

                        }

                        // below is for net price. divide net total calculated in previous iteration by the expected effective quantity

                        else if(quoteLineFieldName == 'SBQQ__NetPrice__c') {

                            Decimal expectedNetTotal = fieldNameToFieldValue.get('SBQQ__NetTotal__c');

                            Decimal denominator = (subscription.SBQQ__Product__r.SBQQ__PricingMethod__c == 'Block') ? 1 : expectedQuantity;

                            expectedValue = (expectedNetTotal != null && expectedQuantity != 0) ? expectedNetTotal.divide(denominator,6) : -69696.6969696969;

                            if(expectedValue != -69696.6969696969 && isAmendment && !subscription.SBQQ__Product__r.Disable_Proration__c && isCurrentYear) {

                                Date originalStartDate = subscription.SBQQ__StartDate__c;

                                Date originalEndDate = subscription.SBQQ__EndDate__c;

                                Decimal originalProrateMultiplier = getProrateMultiplier(originalStartDate,originalEndDate);

                                Date expectedStartDate = getExpectedStartDate(legacyContractWrapper);

                                Date expectedEndDate = originalEndDate;

                                Decimal expectedProrateMultiplier = getProrateMultiplier(expectedStartDate,expectedEndDate);

                                System.debug('expectedStartDate: ' + expectedStartDate);

                                System.debug('expectedEndDate: ' + expectedEndDate);

                                System.debug('expectedProrateMultiplier: ' + expectedProrateMultiplier);

                                expectedValue = (expectedProrateMultiplier / originalProrateMultiplier) * expectedValue;

                            }

                        }

                    }

                    else {

                        // this decimal represents that there should not exist an expected value

                        // this is different from expected value of null - null means that a mapped quote line should exist with null value

                        // whereas the below decimal means that NO quote line should be mapped to the subscription

                        expectedValue = -69696.6969696969;

                    }

                    System.debug('zeroDebug0:' + subscription.Name + ':' + quoteLineFieldName);

                    System.debug('expectedValue: ' + expectedValue);

                    fieldNameToFieldValue.put(quoteLineFieldName,expectedValue);

                }

                System.debug('fieldNameToFieldValue1: ' + JSON.serialize(fieldNameToFieldValue));

                values.fieldNameToFieldValue = fieldNameToFieldvalue;

                yearToValues.put(year,values);

                expectedValues.yearToValues = yearToValues;

                subscriptionIdToExpectedValues.put(subscription.Id,expectedValues);

            }

        }

        for(ExpectedValues expectedValues : subscriptionIdToExpectedValues.values()) {

            for(Values values : expectedValues.yearToValues.values()) {

                for(String fieldName : values.fieldNameToFieldValue.keySet()) {

                    Decimal fieldValue = values.fieldNameToFieldValue.get(fieldName);

                    if(fieldName == 'SBQQ__NetTotal__c' && legacyContractWrapper.isAmendment && fieldValue != -69696.6969696969) {

                        values.fieldNameToFieldValue.put(fieldName,0.00);

                    }

                }

            }

        }

        return subscriptionIdToExpectedValues;

    }

    public static List<String> getNetAmountFieldNames(LegacyContractWrapper legacyContractWrapper) {

        Boolean isAmendment = legacyContractWrapper.isAmendment;

        List<String> netAmountFieldNames = new List<String>{'SBQQ__NetPrice__c'};

        Boolean shouldBeVariableOptions = getExpectedVariableOptionsBoolean(legacyContractWrapper);

        List<Integer> expectedQuoteYears = getExpectedQuoteYears(legacyContractWrapper);

        if(!shouldBeVariableOptions) {

            for(Integer year : expectedQuoteYears) {

                netAmountFieldNames.add('SBQQ__NetPrice__c');

            }

        }

        else if(shouldBeVariableOptions) {

            netAmountFieldNames.add('Year_2_Net_Amount_X__c');

            netAmountFieldNames.add('Year_3_Net_Amount_X__c');

            netAmountFieldNames.add('Year_4_Net_Amount_X__c');

            netAmountFieldNames.add('Year_5_Net_Amount_X__c');

        }

        return netAmountFieldNames;

    }

    public static Map<String,List<String>> getQuoteLineFieldNameToSubscriptionFieldNames() {

        Map<String,List<String>> quoteLineFieldNameToSubscriptionFieldNames = new Map<String,List<String>>();

        for(Map<String,List<String>> fieldNameMap : CventMyd_Settings.quoteLineToSubscriptionFieldMaps) {

            quoteLineFieldNameTosubscriptionFieldNames.putAll(fieldNameMap);

        }

        return quoteLineFieldNameToSubscriptionFieldNames;

    }

    public static List<LegacyDataComparison__c> getQuoteLineCountComparisons(LegacyContractWrapper legacyContractWrapper, ComparisonType comparisonTypeEnum) {

        SBQQ__Quote__c quote = legacyContractWrapper.quote;

        List<SBQQ__QuoteLine__c> quoteLines = quoteIdToQuoteLines.get(quote.Id);

        Contract contract = legacyContractWrapper.contract;

        Map<Integer,Integer> renewalGroupYearToQuoteLineCount = getGroupYearToQuoteLineCount(quote);

        Map<Integer,Integer> expectedGroupYearToQuoteLineCount = getExpectedGroupYearToQuoteLineCount(legacyContractWrapper);

        List<LegacyDataComparison__c> quoteLineCountComparisons = new List<LegacyDataComparison__c>();

        for(Integer year : expectedGroupYearToQuoteLineCount.keySet()) {

            LegacyDataComparison__c lineCountComparison = initializeDataCheck(legacyContractWrapper,comparisonTypeEnum);

            lineCountComparison.parameterName__c = 'Year';

            lineCountComparison.parameterValue__c = (year != -1) ? String.valueOf(year) : 'All Years';

            lineCountComparison.expectedValue__c = String.valueOf(expectedGroupYearToQuoteLineCount.get(year));

            lineCountComparison.actualValue__c = String.valueOf(renewalGroupYearToQuoteLineCount.get(year));

            quoteLineCountComparisons.add(lineCountComparison);

        }

        return quoteLineCountComparisons;

    }

    public static LegacyDataComparison__c getOpportunityLineCheck(LegacyContractWrapper legacyContractWrapper, ComparisonType comparisonTypeEnum) {

        SBQQ__Quote__c quote = legacyContractWrapper.quote;

        LegacyDataComparison__c lineCheck = initializeDataCheck(legacyContractWrapper,comparisonTypeEnum);

        lineCheck.expectedValue__c = String.valueOf(quote.nonOptionalLineCount__c);

        lineCheck.actualValue__c = String.valueOf(quote.opportunityLineItemCount__c);

        return lineCheck;

    }

    public static Map<Integer,Integer> getGroupYearToQuoteLineCount(SBQQ__Quote__c quote) {

        List<SBQQ__QuoteLine__c> quoteLines = quoteIdToQuoteLines.get(quote.Id);

        Map<Integer,Integer> groupYearToQuoteLineCount = new Map<Integer,Integer>();

        if(quote.numberOfQuoteLineGroups__c == 0) {

            groupYearToQuoteLineCount.put(-1,(Integer)quote.SBQQ__LineItemCount__c);

        }

        else {

            if(quoteLines != null) {
            
                for(SBQQ__QuoteLine__c quoteLine : quoteLines) {

                    Integer year = (Integer)quoteLine.term__c;

                    if(groupYearToQuoteLineCount.get(year) == null) {

                        groupYearToQuoteLineCount.put(year,0);

                    }

                    Integer yearcount = groupYearToQuoteLineCount.get(year);

                    yearCount++;

                    groupYearToQuoteLineCount.put(year,yearCount);

                }

            }

            else {

                groupYearToQuoteLineCount = getYearToZeroMap(quote);

            }

        }

        return groupYearToQuoteLineCount;

    }

    public static Map<Integer,Integer> getYearToZeroMap(SBQQ__Quote__c quote) {

        Map<Integer,Integer> yearToZeroMap = new Map<Integer,Integer>();

        Integer actualCurrentYear = (Integer)quote.Current_Year__c;

        Integer actualFinalYear = Integer.valueOf(quote.Contract_Term_Years__c);

        for(Integer year = actualCurrentYear; year <= actualFinalYear; year++) {

            yearToZeroMap.put(year,0);

        }

        return yearToZeroMap;

    }

    public static List<SBQQ__Quote__c> getQuotes(Set<Id> chainMasterRecordIds, Set<Id> quoteIds) {

        Set<String> quoteQueryFields = new Set<String> {

            'jsonString__c','Current_Year__c','previousQuote__c','numberOfQuoteLineGroups__c',

            'SBQQ__Type__c','SBQQ__LineItemCount__c','Multiple_Years_Commitment__c','statusCheckCount__c',

            'Contract_Term_Years__c','recalculationToggler__c','createdFromLegacyContract__c',

            'SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.isLegacy__c',

            'SBQQ__Opportunity2__r.SBQQ__AmendedContract__r.isLegacy__c',

            'SBQQ__Opportunity2__r.SBQQ__RenewedContract__c','SBQQ__StartDate__c','SBQQ__EndDate__c',

            'nonOptionalLineCount__c','opportunityLineItemCount__c','CreatedDate'
            
        };  

        String queryString = 'SELECT Id,Name';

        queryString += ',' + CventMyd_UtilityMethods.getFieldNamesStringFromStringSet(quoteQueryFields);

        queryString += ',' + '(SELECT Id,term__c,jsonString__c,SBQQ__Optional__c FROM SBQQ__LineItemGroups__r ORDER BY term__c ASC)';

        queryString += ',' + '(SELECT Id FROM legacyContractReports__r)';

        queryString += ' FROM SBQQ__Quote__c';

        queryString += (chainMasterRecordIds != null) ? ' WHERE renewalChainMaster__c IN: chainMasterRecordIds' : ' WHERE Id IN: quoteIds';

        List<SBQQ__Quote__c> quotes = Database.query(queryString);

        quoteIdToQuote = new Map<Id,SBQQ__Quote__c>(quotes);

        return quotes;

    }

    public static void setQuoteIdToQuoteLines(Set<Id> quoteIds) {

        String queryString = 'SELECT Id,Name,legacySubscription__c';

        queryString += ',' + CventMyd_Settings.fullQuoteLineFieldNamesString;

        queryString += ' FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN: quoteIds';

        for(SBQQ__QuoteLine__c quoteLine : Database.query(queryString)) {

            if(quoteIdToQuoteLines.get(quoteLine.SBQQ__Quote__c) == null) {

                quoteIdToQuoteLines.put(quoteLine.SBQQ__Quote__c,new List<SBQQ__QuoteLine__c>());

            }

            quoteIdToQuoteLines.get(quoteLine.SBQQ__Quote__c).add(quoteLine);

        }

    }

    public static Map<Integer,String> replaceYearWithEffectiveYear(Map<Integer,String> quoteYearToEndDateFieldName ) {

        for(Integer year : quoteYearToEndDateFieldName.keySet()) {

            String fieldName = quoteYearToEndDateFieldName.get(year);

            if(!fieldName.containsIgnoreCase('Effective_Year_')) {

                fieldName = fieldName.replace('Year_','Effective_Year_');

            }

            quoteYearToEndDateFieldName.put(year,fieldName);

        }

        return quoteYearToEndDateFieldName;

    }

    public static LegacyDataComparison__c getAmendmentZeroedCheck(LegacyContractWrapper legacyContractWrapper, ComparisonType comparisonTypeEnum) {

        LegacyDataComparison__c amendmentZeroedCheck = initializeDataCheck(legacyContractWrapper,comparisonTypeEnum);

        amendmentZeroedCheck.expectedValue__c = null;

        String actualValue;

        amendmentZeroedCheck.parameterName__c = 'Value Meaning';

        amendmentZeroedCheck.parameterValue__c = 'Non-zeroed Quote Line Ids';

        List<SBQQ__QuoteLine__c> quoteLines = quoteIdToQuoteLines.get(legacyContractWrapper.quote.Id);

        if(quoteLines != null) {

            for(SBQQ__QuoteLine__c quoteLine : quoteLines) {

                if(quoteLine.SBQQ__NetTotal__c != 0) {

                    actualValue = ( actualValue == null ) ? '' : actualValue + String.valueOf(quoteLine.Id) ;

                }

            }

        }

        else {

            actualValue = 'NO_QUOTE_LINES_FOUND';

        }

        amendmentZeroedCheck.actualValue__c = actualValue;

        return amendmentZeroedCheck;

    }

    public static Decimal getProrateMultiplier(Date startDate, Date endDate) {

        Decimal multiplier = 1;

        if(startDate != null && endDate != null && startDate.year() > 2000 && endDate.year() > 2000) {

            Decimal daysDifference = Decimal.valueOf(startDate.daysBetween(endDate));

            daysDifference++;

            daysDifference = ( Date.isLeapYear(endDate.year()) && (endDate.month() > 2 || endDate.month() == 2 && endDate.day() == 29)) ? daysDifference - 1 : daysDifference;

            multiplier = daysDifference.divide(365,8);

        }

        return multiplier;

    }

}