global without sharing class CventMyd_QuoteSchedulable implements Schedulable {

    global static Id renewalChainMasterId;

    global static Boolean chainFinished;    

    global Set<Id> quoteIds {get;set;}

    global String jobName {get;set;}

    global Id auditRecordId {get;set;}

    global CventMyd_QuoteSchedulable(Set<Id> quoteIds, String jobName, Id auditRecordId) {
        
        this.quoteIds = quoteIds;

        this.jobName = jobName;

        this.auditRecordId = auditRecordId;

    }

    global class QuoteStatusException extends Exception {}

    global void execute(SchedulableContext sc) {

        CpqAudit__c quoteMasterAuditRecord = [SELECT

            Id,quote__c,contract__c,Name,

            chainMaster__c,previousJob__r.Name,

            chainMaster__r.chainFinished__c

            FROM CpqAudit__c

            WHERE Id =: auditRecordId

        ];  

        chainFinished = quoteMasterAuditRecord.chainMaster__r.chainFinished__c;

        if(Test.isRunningTest()) {

            renewalChainMasterId = quoteMasterAuditRecord.chainMaster__c;

        }

        try {

            Map<Id,Id> quoteIdToContractId = new Map<Id,Id>();

            renewalChainMasterId = quoteMasterAuditRecord.chainMaster__c;

            Boolean poolQuotes = (renewalChainMasterId != null);

            Set<String> quoteFieldNames = new Set<String> {

                'jsonString__c','Current_Year__c','previousQuote__c',

                'numberOfQuoteLineGroups__c','SBQQ__Type__c',

                'SBQQ__LineItemCount__c','statusCheckCount__c','calculationCycleFinished__c',

                'Multiple_Years_Commitment__c','recalculationToggler__c',

                'Contract_Term_Years__c','createdFromLegacyContract__c',

                'opportunityLineItemCount__c','nonOptionalLineCount__c','CreatedDate',

                'previousQuote__r.parallelLineAdditionIds__c'

            };

            String queryString = 'SELECT Id,Name';

            queryString += ',' + CventMyd_UtilityMethods.getFieldNamesStringFromStringSet(quoteFieldNames);

            queryString += ',(SELECT Id,term__c,jsonString__c,SBQQ__Optional__c';

            queryString += ' FROM SBQQ__LineItemGroups__r';

            queryString += ' ORDER BY term__c ASC)';

            queryString += ' FROM SBQQ__Quote__c';

            if(!poolQuotes) {

                queryString += ' WHERE Id IN: quoteIds';

            }

            else if(poolQuotes) {

                Integer statusCheckMax = CventMyd_Settings.renewalGenerationSettings.statusChecksPerQuote;

                queryString += ' WHERE renewalChainMaster__c =: renewalChainMasterId';

                queryString += ' AND (schedulableExceptionCount__c <= 4 OR schedulableExceptionCount__c = null)';

                queryString += ' ORDER BY statusCheckCount__c ASC';

                queryString += ', schedulableExceptionCount__c ASC NULLS FIRST';

                queryString += ', CreatedDate ASC';

                queryString += ' LIMIT 3';

            }

            List<SBQQ__Quote__c> quotes =  Database.query(queryString);

            Set<Id> oldParallelLineIds = new Set<Id>();

            for(SBQQ__Quote__c quote : quotes) {

                if(quote.previousQuote__r.parallelLineAdditionIds__c != null) {

                    oldParallelLineIds.addAll(CventMyd_UtilityMethods.getIdSet(quote.previousQuote__r.parallelLineAdditionIds__c,';'));

                }

            }

            if(quoteMasterAuditRecord.chainMaster__c != null && quoteMasterAuditRecord.chainMaster__r.chainFinished__c) {

                Boolean moreQuotesToProcess = false;

                for(SBQQ__Quote__c quote : quotes) {

                    System.debug('quote in quote schedulable: ' + quote);

                    if(quote.statusCheckCount__c < CventMyd_Settings.renewalGenerationSettings.statusChecksPerQuote) {

                        moreQuotesToProcess = true;

                    }

                }

                if(!moreQuotesToProcess) {

                    throw new QuoteStatusException('there are no more quotes to process in chain');

                }

            }

            Map<Id,SBQQ__Quote__c> quoteIdToQuote = new Map<Id,SBQQ__Quote__c>(quotes);

            quoteIds = quoteIdToQuote.keySet();

            Map<Id,List<SBQQ__QuoteLine__c>> quoteIdToQuoteLines = new Map<Id,List<SBQQ__QuoteLine__c>>();

            queryString = 'SELECT Id,Name,SBQQ__RequiredBy__r.SBQQ__RequiredBy__c';

            queryString += ',' + CventMyd_Settings.fullQuoteLineFieldNamesString;

            queryString += ' FROM SBQQ__QuoteLine__c';

            queryString += ' WHERE SBQQ__Quote__c IN: quoteIds';

            queryString += ' ORDER BY SBQQ__Number__c ASC';

            System.debug('oldParallelLineIds: ' + oldParallelLineIds);

            List<SBQQ__QuoteLine__c> parallelLineAdditions = [SELECT Id,jsonString__c FROM SBQQ__QuoteLine__c WHERE Id IN: oldParallelLineIds];

            Map<Id,Set<Id>> quoteIdToNewParallelLineIds = new Map<Id,Set<Id>>();

            for(SBQQ__QuoteLine__c quoteLine : Database.query(queryString)) {

                CventMyd_QuoteLineObject lineObject = CventMyd_UtilityMethods.getQuoteLineObject(quoteLine);

                if(quoteIdToQuoteLines.get(quoteLine.SBQQ__Quote__c) == null) {

                    quoteIdToQuoteLines.put(quoteLine.SBQQ__Quote__c, new List<SBQQ__QuoteLine__c>());

                }

                quoteIdToQuoteLines.get(quoteLine.SBQQ__Quote__c).add(quoteLine);

                for(SBQQ__QuoteLine__c oldParallelLine : parallelLineAdditions) {

                    CventMyd_QuoteLineObject lineObject1 = CventMyd_UtilityMethods.getQuoteLineObject(oldParallelLine);

                    if(lineObject1.qleId == lineObject.qleId) {

                        System.debug('matching qleId found: ' + lineObject.qleId);

                        System.debug('new quote line id: ' + quoteLine.Id);

                        if(quoteIdToNewParallelLineIds.get(quoteLine.SBQQ__Quote__c) == null) {

                            quoteIdToNewParallelLineIds.put(quoteLine.SBQQ__Quote__c,new Set<Id>());

                        }

                        quoteIdToNewParallelLineIds.get(quoteLine.SBQQ__Quote__c).add(quoteLine.Id);

                    }

                }

            }

            List<SBQQ__QuoteLine__c> intratermCurrentYearLines = new List<SBQQ__QuoteLine__c>();

            List<SBQQ__Quote__c> termRenewalQuotes = new List<SBQQ__Quote__c>();

            Set<Id> previousQuoteIds = new Set<Id>();

            List<SBQQ__Quote__c> quotesToCreateOutyears = new List<SBQQ__Quote__c>();

            Set<Id> quoteIdsToRenumberAllLines = new Set<Id>();

            for(SBQQ__Quote__c quote : quotes) {
                
                CventMyd_LineAndGroupHandler.QuoteWrapper quoteWrapper = new CventMyd_LineAndGroupHandler.QuoteWrapper(quote);

                CventMyd_LineAndGroupHandler.quoteIdToQuoteWrapper.put(quote.Id,quoteWrapper);

                CventMyd_QuoteObject quoteObject = CventMyd_UtilityMethods.getQuoteObject(quote);

                Map<String,Boolean> quoteStatusMap = CventMyd_UtilityMethods.getQuoteStatusMap(quoteObject);

                Boolean outyearProcessingComplete = quoteStatusMap.get('outyearProcessingComplete');

                quote.jsonString__c = JSON.serialize(quoteObject);

                quote.statusCheckCount__c = quote.statusCheckCount__c + 1;

                previousQuoteIds.add(quote.previousQuote__c);

                List<SBQQ__QuoteLine__c> quoteLines = (quoteIdToQuoteLines.get(quote.Id) != null) ? quoteIdToQuoteLines.get(quote.Id) : new List<SBQQ__QuoteLine__c>();

                if((quote.createdFromLegacyContract__c || quote.SBQQ__LineItemCount__c == 0) && quote.SBQQ__LineItemGroups__r.size() > 0) {

                    CventMyd_LineAndGroupHandler.GroupWrapper groupWrapper = new CventMyd_LineAndGroupHandler.GroupWrapper(quote.SBQQ__LineItemGroups__r[0]);

                    SBQQ__QuoteLine__c previousQuoteLine;

                    for(SBQQ__QuoteLine__c ql : quoteLines) {

                        if(quote.createdFromLegacyContract__c ) {

                            if(ql.SBQQ__Number__c < 3000 && ql.SBQQ__RequiredBy__c != null) {

                                Boolean bundleLineIsAbove = (ql.SBQQ__Number__c == (ql.SBQQ__RequiredBy__r.SBQQ__Number__c + 1));

                                Boolean aboveLineIsInSameBundle = (previousQuoteLine.SBQQ__RequiredBy__c == ql.SBQQ__RequiredBy__c);

                                aboveLineIsInSameBundle = (previousQuoteLine.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c == ql.SBQQ__RequiredBy__c) ? true : aboveLineIsInSameBundle;

                                if(!bundleLineIsAbove && !aboveLineIsInSameBundle) {

                                    quoteIdsToRenumberAllLines.add(ql.SBQQ__Quote__c);

                                }                           

                            }

                            previousQuoteLine = ql;

                        }

                        quoteWrapper.highestUnhiddenLineNumber = (ql.SBQQ__Number__c < 3000 && ql.SBQQ__Number__c > quoteWrapper.highestUnhiddenLineNumber) ? (Integer)ql.SBQQ__Number__c : quoteWrapper.highestUnhiddenLineNumber;

                        quoteWrapper.highestHiddenLineNumber = (ql.SBQQ__Number__c >= 3000 && ql.SBQQ__Number__c > quoteWrapper.highestHiddenLineNumber) ? (Integer)ql.SBQQ__Number__c : quoteWrapper.highestHiddenLineNumber;                  

                        if(ql.SBQQ__Group__c == groupWrapper.quoteLineGroup.Id) {

                            CventMyd_LineAndGroupHandler.QuoteLineWrapper quoteLineWrapper = new CventMyd_LineAndGroupHandler.QuoteLineWrapper(ql,quote.Id);

                            quoteLineWrapper.quoteFieldSet = true;

                            CventMyd_QuoteLineObject quoteLineObject = CventMyd_UtilityMethods.getQuoteLineObject(ql);

                            groupWrapper.qleIdToQuoteLineWrapper.put(quoteLineObject.qleId,quoteLineWrapper);

                            Id contractId = (ql.SBQQ__UpgradedSubscription__c != null) ? ql.SBQQ__UpgradedSubscription__r.SBQQ__Contract__c : ql.SBQQ__RenewedSubscription__r.SBQQ__Contract__c;

                            if(contractId != null) {quoteIdToContractId.put(ql.SBQQ__Quote__c,contractId);}

                        }

                    }

                    quoteWrapper.yearToGroupWrapper.put((Integer)quote.Current_Year__c,groupWrapper);

                    CventMyd_LineAndGroupHandler.quoteIdToQuoteWrapper.put(quote.Id,quoteWrapper);

                }

                System.debug('quoteIdToNewParallelLineIds: ' + quoteIdToNewParallelLineIds);

                if((quote.Current_Year__c > 1 && quote.SBQQ__Type__c == 'Renewal' || quote.SBQQ__Type__c == 'Amendment') && quote.Multiple_Years_Commitment__c) {

                    for(SBQQ__QuoteLine__c ql : quoteLines) {

                        CventMyd_QuoteLineObject quoteLineObject = CventMyd_UtilityMethods.getQuoteLineObject(ql);

                        Boolean deleteThisLine = quoteLineObject.deleteThisLine != null && quoteLineObject.deleteThisLine;

                        if(ql.term__c == quote.Current_Year__c && (!outyearProcessingComplete || deleteThisLine)  && quote.SBQQ__Type__c == 'Renewal') {

                            Set<Id> newParallelLineIds = quoteIdToNewParallelLineIds.get(ql.SBQQ__Quote__c);

                            System.debug('newParallelLineIds: ' + newParallelLineIds);

                            Boolean sameQleIdAsParallelLine = (newParallelLineIds != null && newParallelLineIds.contains(ql.Id));

                            Boolean parallelLineAddition = (quoteLineObject.parallelLineAddition != null && quoteLineObject.parallelLineAddition);

                            if(!sameQleIdAsParallelLine && !parallelLineAddition) {

                                intratermCurrentYearLines.add(ql);
                                
                            }

                        }

                    }

                    Integer expectedNumberOfQuoteLineGroups = (Integer) (Integer.valueOf(quote.Contract_Term_Years__c) - quote.Current_Year__c + 1);

                    System.debug('expectedNumberOfQuoteLineGroups: ' + expectedNumberOfQuoteLineGroups);

                    System.debug('quote.numberOfQuoteLineGroups__c: ' + quote.numberOfQuoteLineGroups__c);

                    if(quote.numberOfQuoteLineGroups__c < expectedNumberOfQuoteLineGroups || quote.SBQQ__LineItemCount__c == 0) {

                        quotesToCreateOutyears.add(quote);

                    }

                }

                else if(quote.Current_Year__c == 1) {

                    termRenewalQuotes.add(quote);

                }

            }

            // form map of new quote to previous year contracted quote lines

            // this values of the map are all quote lines that are on the next year of the previous quote (which is now the current year of its renewal)

            Map<Id,List<SBQQ__QuoteLine__c>> quoteIdToPreviousYearQuoteLines = new Map<Id,List<SBQQ__QuoteLine__c>>();
            
            for(SBQQ__QuoteLine__c ql : [SELECT

                Id,term__c, jsonString__c,SBQQ__Quote__c,SBQQ__Group__c,

                SBQQ__Quote__r.nextQuote__c,SBQQ__Quote__r.Current_Year__c,

                SBQQ__Quote__r.createdFromLegacyContract__c

                FROM SBQQ__QuoteLine__c

                WHERE SBQQ__Quote__c IN: previousQuoteIds

                ORDER BY SBQQ__Number__c ASC

            ]) {

                if(ql.term__c == ql.SBQQ__Quote__r.Current_Year__c + 1) {

                    if(quoteIdToPreviousYearQuoteLines.get(ql.SBQQ__Quote__r.nextQuote__c) == null) {

                        quoteIdToPreviousYearQuoteLines.put(ql.SBQQ__Quote__r.nextQuote__c,new List<SBQQ__QuoteLine__c>());

                    }

                    quoteIdToPreviousYearQuoteLines.get(ql.SBQQ__Quote__r.nextQuote__c).add(ql);

                }

            }

            System.debug('quoteIdToPreviousYearQuoteLines: ' + quoteIdToPreviousYearQuoteLines);

            System.debug('intratermCurrentYearLines: ' + intratermCurrentYearLines.size());

            List<SBQQ__QuoteLine__c> quoteLinesToDelete = new List<SBQQ__QuoteLine__c>();

            quoteLinesToDelete.addAll(CventMyd_LineAndGroupHandler.getQuoteLinesToDeleteOnIntratermRenewal(intratermCurrentYearLines,quoteIdToPreviousYearQuoteLines));

            quoteLinesToDelete.addAll(CventMyd_LineAndGroupHandler.getQuoteLinesToDeleteOnTermRenewal(termRenewalQuotes,quoteIdToQuoteLines));

            quoteLinesToDelete.addAll(CventMyd_LegacyContractHandler.getQuoteLinesToDeleteOnIntratermRenewal(intratermCurrentYearLines));

            Map<Id,Set<String>> quoteIdToQuoteLinesDeleted = new Map<Id,Set<String>>();

            // remove the deleted quote lines from the intraterm current year line list

            // remove them so that the current year lines can be correctly updated with numbering from original quote

            if(quoteLinesToDelete.size() > 0) {

                Set<Id> quoteLineIdsToDelete = (new Map<Id,SBQQ__QuoteLine__c>(quoteLinesToDelete)).keySet();

                List<SBQQ__QuoteLine__c> quoteLinesToRemove = new List<SBQQ__QuoteLine__c>();

                for(SBQQ__QuoteLine__c ql :  intratermCurrentYearLines) {

                    if(quoteLineIdsToDelete.contains(ql.Id)) {

                        quoteLinesToRemove.add(ql);

                    }

                }

                for(SBQQ__QuoteLine__c ql : quoteLinesToRemove) {

                    Integer indexToRemove = intratermCurrentYearLines.indexOf(ql);

                    intratermCurrentYearLines.remove(indexToRemove);

                }

                for(SBQQ__QuoteLine__c ql : quoteLinesToDelete) {

                    if(quoteIdToQuoteLinesDeleted.get(ql.SBQQ__Quote__c) == null) {

                        quoteIdToQuoteLinesDeleted.put(ql.SBQQ__Quote__c, new Set<String>());

                    }

                    String quoteLineString = 'Product Name: ' + ql.SBQQ__ProductName__c + ', Product Code: ' + ql.SBQQ__ProductCode__c + ', Revenue Type: ' + ql.SBQQ__Product__r.Revenue_Type__c +', Year: ' + ql.term__c;

                    quoteIdToQuoteLinesDeleted.get(ql.SBQQ__Quote__c).add(quoteLineString);

                }

                System.debug('quoteIdToQuoteLinesDeleted: ' + quoteIdToQuoteLinesDeleted);

                delete quoteLinesToDelete;

            }

            Map<Id,List<SBQQ__QuoteLine__c>> quoteIdToQuoteLinesRenumbered = new Map<Id,List<SBQQ__QuoteLine__c>>();

            if(intratermCurrentYearLines.size() > 0 || quoteIdsToRenumberAllLines.size() > 0) {

                List<SBQQ__QuoteLine__c> quoteLinesToRenumber = new List<SBQQ__QuoteLine__c>();

                if(intratermCurrentYearLines.size() > 0) {

                    quoteLinesToRenumber = CventMyd_LineAndGroupHandler.getRenumberedCurrentYearLinesToUpdate(intratermCurrentYearLines,quoteIdToPreviousYearQuoteLines);

                }

                else if(quoteIdsToRenumberAllLines.size() > 0) {

                    for(SBQQ__Quote__c quote : quotes) {

                        List<SBQQ__QuoteLine__c> quoteLines = (quoteIdToQuoteLines.get(quote.Id) != null) ? quoteIdToQuoteLines.get(quote.Id) : new List<SBQQ__QuoteLine__c>();

                        quoteLinesToRenumber.addAll(quoteLines);

                    }

                    quoteLinesToRenumber = CventMyd_LegacyContractHandler.getQuoteLinesToRenumber(quoteLinesToRenumber);

                }

                update quoteLinesToRenumber;

                for(SBQQ__QuoteLine__c ql : quoteLinesToRenumber) {

                    if(quoteIdToQuoteLinesRenumbered.get(ql.SBQQ__Quote__c) == null) {

                        quoteIdToQuoteLinesRenumbered.put(ql.SBQQ__Quote__c,new List<SBQQ__QuoteLine__c>());

                    }

                    SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(Id=ql.Id,SBQQ__Product__c=ql.SBQQ__Product__c,SBQQ__Number__c=ql.SBQQ__Number__c);

                    quoteIdToQuoteLinesRenumbered.get(ql.SBQQ__Quote__c).add(quoteLine);

                }

            }

            System.debug('quotesToCreateOutyears: ' + quotesToCreateOutyears);

            Map<Id,List<Integer>> quoteIdToAllOutyears = new Map<Id,List<Integer>>();

            for(SBQQ__Quote__c q : quotesToCreateOutyears) {

                quoteIdToAllOutyears.put(q.Id,CventMyd_UtilityMethods.getQuoteOutyears(q,true));

            }

            Map<Id,List<Integer>> quoteIdToOutyearsToCreateFromPreviousQuote = new Map<Id,List<Integer>>();

            Map<Id,List<Integer>> quoteIdToOutyearsToCreateFromLegacySubscriptions = new Map<Id,List<Integer>>();           

            System.debug('quoteIdToAllOutyears: ' + quoteIdToAllOutyears);

            // form a map of quote id to outyear to create

            // in this scheduled job only one outyear would be created at a time, per quote

            for(Id quoteId : quoteIdToAllOutyears.keySet()) {

                SBQQ__Quote__c quote = quoteIdToQuote.get(quoteId);

                if(quote.Multiple_Years_Commitment__c) {

                    Integer numberOfGroups = (Integer)quote.numberOfQuoteLineGroups__c;

                    Integer nextOutyearIndex = (quote.SBQQ__Type__c == 'Renewal' && quote.SBQQ__LineItemCount__c > 0) ? numberOfGroups : numberOfGroups - 1 ;

                    Integer nextOutyear = quoteIdToAllOutyears.get(quoteId)[nextOutyearIndex];

                    if(!quote.createdFromLegacyContract__c) {

                        quoteIdToOutyearsToCreateFromPreviousQuote.put(quoteId,new List<Integer>());

                        quoteIdToOutyearsToCreateFromPreviousQuote.get(quoteId).add(nextOutyear);

                    }

                    else if(quote.createdFromLegacyContract__c) {

                        quoteIdToOutyearsToCreateFromLegacySubscriptions.put(quoteId,new List<Integer>());

                        quoteIdToOutyearsToCreateFromLegacySubscriptions.get(quoteId).add(nextOutyear);                     

                    }

                }

            }

            System.debug('quoteIdToOutyearsToCreateFromPreviousQuote0: ' + quoteIdToOutyearsToCreateFromPreviousQuote);

            System.debug('quoteIdToOutyearsToCreateFromLegacySubscriptions: ' + quoteIdToOutyearsToCreateFromLegacySubscriptions);

            if(quoteIdToOutyearsToCreateFromPreviousQuote.keySet().size() > 0) {

                System.debug('quoteIdToOutyears1: ' + quoteIdToOutyearsToCreateFromPreviousQuote);

                CventMyd_LineAndGroupHandler.createOutyearsFromPreviousQuote(quoteIdToOutyearsToCreateFromPreviousQuote);

            }

            if(quoteIdToOutyearsToCreateFromLegacySubscriptions.keySet().size() > 0) {

                System.debug('quoteIdToOutyears1: ' + quoteIdToOutyearsToCreateFromLegacySubscriptions);

                CventMyd_LegacyContractHandler.getAndSetLegacySubscriptions(new Set<Id>(quoteIdToContractId.values()));

                CventMyd_LegacyContractHandler.createOutyearsFromLegacySubscriptions(quoteIdToOutyearsToCreateFromLegacySubscriptions);

            }           

            String apexLimitsString = CventMyd_UtilityMethods.getApexLimitsString();

            List<CpqAudit__c> auditRecords = new List<CpqAudit__c>();

            for(SBQQ__Quote__c quote : quotes) {

                CpqAudit__c auditRecord = CventMyd_UtilityMethods.getAuditRecord(quote,false,apexLimitsString);

                auditRecord.chainMaster__c = renewalChainMasterId;

                System.debug('auditRecord.statusCheckCount__c: ' + auditRecord.statusCheckCount__c);

                System.debug('quote.statusCheckCount__c: ' + quote.statusCheckCount__c);

                auditRecord.contract__c = quoteIdToContractId.get(quote.Id);

                auditRecord.statusCheckCount__c = quote.statusCheckCount__c;

                auditRecord.previousJob__c = quoteMasterAuditRecord.Id;

                auditRecord.processingInformation__c = 'scheduled quoteIds:' + JSON.serialize(quoteIds) + '\r\n' + auditRecord.processingInformation__c;

                Set<String> quoteLinesDeleted = quoteIdToQuoteLinesDeleted.get(quote.Id);

                auditRecord.processingInformation__c += '\r\n' + '==================================================';

                auditRecord.processingInformation__c += '\r\n' + 'quoteLinesDeleted: '; 

                auditRecord.processingInformation__c += (quoteLinesDeleted != null) ? 'Count: ' + String.valueOf(quoteLinesDeleted.size()) + JSON.serialize(quoteLinesDeleted) : null;

                List<SBQQ__QuoteLine__c> quoteLinesRenumbered = quoteIdToQuoteLinesRenumbered.get(quote.Id);

                auditRecord.processingInformation__c += '\r\n' + '==================================================';

                auditRecord.processingInformation__c += '\r\n' + 'quoteLinesRenumbered: ';

                auditRecord.processingInformation__c += ((quoteLinesRenumbered != null) ? String.valueOf(quoteLinesRenumbered) : null);

                auditRecord.processingInformation__c += '\r\n' + '==================================================';

                List<Integer> outyearsCreatedFromPreviousQuoteInThisJob = quoteIdToOutyearsToCreateFromPreviousQuote.get(quote.Id);

                auditRecord.processingInformation__c += '\r\n' + 'outyearsCreatedFromPreviousQuote: ';

                auditRecord.processingInformation__c += (outyearsCreatedFromPreviousQuoteInThisJob != null) ? JSON.serialize(outyearsCreatedFromPreviousQuoteInThisJob) : null;

                auditRecord.processingInformation__c += '\r\n' + '==================================================';

                List<Integer> outyearsCreatedFromLegacySubscriptions = quoteIdToOutyearsToCreateFromLegacySubscriptions.get(quote.Id);

                auditRecord.processingInformation__c += '\r\n' + 'outyearsCreatedFromLegacySubscriptions: ';     

                auditRecord.processingInformation__c += (quoteIdToOutyearsToCreateFromLegacySubscriptions != null) ? JSON.serialize(quoteIdToOutyearsToCreateFromLegacySubscriptions) : null;     

                CventMyd_QuoteObject quoteObject = CventMyd_UtilityMethods.getQuoteObject(quote);

                Map<String,Boolean> quoteStatusMap = CventMyd_UtilityMethods.getQuoteStatusMap(quoteObject);

                Boolean outyearsWereCreated = (outyearsCreatedFromPreviousQuoteInThisJob != null || outyearsCreatedFromLegacySubscriptions != null);



                if(outyearsWereCreated && quoteStatusMap.get('calculationCycleFinished')) {

                    quoteObject.automationStage.outyearProcessingStage = CventMyd_QuoteAutomationStage.OutyearProcessingStage.OUTYEAR_PROCESSING_IN_PROGRESS;

                }

                quoteObject.currentYearSynced = true;
                
                Boolean recalculateQuote = false;

                if(quote.SBQQ__Type__c == 'Renewal') {

                    if((Integer)quote.statusCheckCount__c == 1) {

                        recalculateQuote = false;

                    }

                    else if((Integer)quote.statusCheckCount__c == CventMyd_Settings.renewalGenerationSettings.statusChecksPerQuote) {

                        recalculateQuote = (quote.opportunityLineItemCount__c > quote.nonOptionalLineCount__c);

                    }

                    else if(quote.Multiple_Years_Commitment__c) {

                        recalculateQuote = !quoteStatusMap.get('outyearProcessingComplete');

                    }

                    else if(!quote.Multiple_Years_Commitment__c) {

                        recalculateQuote = !quoteStatusMap.get('calculationCycleFinished');

                    }               

                }

                else if(quote.SBQQ__Type__c == 'Amendment') {

                    DateTime twoMinutesAgoDateTime = DateTime.now().addMinutes(-2);

                    if(quote.CreatedDate.getTime() < twoMinutesAgoDateTime.getTime() && !quote.calculationCycleFinished__c) {

                        recalculateQuote = true;

                    }

                }

                quoteObject.automationStage.codeStatus = (quote.Multiple_Years_Commitment__c) ? CventMyd_QuoteAutomationStage.CodeStatus.LAST_UPDATED_BY_SCHEDULABLE_JOB : quoteObject.automationStage.codeStatus;

                quote.jsonString__c = JSON.serialize(quoteObject);

                quote.recalculationToggler__c = (recalculateQuote) ? !quote.recalculationToggler__c : quote.recalculationToggler__c;

                auditRecord.processingInformation__c += '\r\n' + '==================================================';

                auditRecord.processingInformation__c += '\r\n' + 'quoteRecalculated: ';      
                
                auditRecord.processingInformation__c += String.valueOf(recalculateQuote);          

                auditRecord.processingInformation__c += '\r\n' + '==================================================';

                auditRecord.processingInformation__c += '\r\n' + 'non-optional line count: ';   

                auditRecord.processingInformation__c += String.valueOf(quote.nonOptionalLineCount__c);

                auditRecord.processingInformation__c += '\r\n' + '==================================================';

                auditRecord.processingInformation__c += '\r\n' + 'opportunity line count: '; 

                auditRecord.processingInformation__c += String.valueOf(quote.opportunityLineItemCount__c);                  
                
                auditRecords.add(auditRecord);

            }

            update quotes;

            insert auditRecords;

            CventMyd_RecalculationWrapper recalculationWrapper = CventMyd_UtilityMethods.getRecalculationWrapper(this.quoteIds,false);

            System.debug('recalculationWrapper.opportunityIdToPrimaryQuoteId : ' + recalculationWrapper.opportunityIdToPrimaryQuoteId);

            if(recalculationWrapper.opportunityIdToPrimaryQuoteId.keySet().size() > 0) {

                CventMyd_UtilityMethods.updatePrimaryQuoteFieldOnOpportunities(this.quoteIds,false);

            }

            System.debug('aborting schedulable job 2...');

            String previousJobName = quoteMasterAuditRecord.previousJob__r.Name;

            CventMyd_UtilityMethods.abortSchedulableJobs(true,previousJobName,this.jobName,false);

        }

        catch (Exception e0) {

            CpqAudit__c jobAuditRecord = new CpqAudit__c(Id = this.auditRecordId);

            jobAuditRecord.exceptionOccurred__c = true;

            String exceptionString = CventMyd_UtilityMethods.getExceptionString(e0);

            jobAuditRecord.processingInformation__c = exceptionString;

            update jobAuditRecord;

            List<CpqAudit__c> auditRecords = new List<CpqAudit__c>();

            String apexLimitsString = CventMyd_UtilityMethods.getApexLimitsString();

            List<SBQQ__Quote__c> quotes =  [SELECT

                Id,Name,jsonString__c,Current_Year__c,previousQuote__c,numberOfQuoteLineGroups__c,

                SBQQ__Type__c,SBQQ__LineItemCount__c,Multiple_Years_Commitment__c,

                statusCheckCount__c,SBQQ__Source__c,schedulableExceptionCount__c,

                Contract_Term_Years__c,recalculationToggler__c,createdFromLegacyContract__c

                FROM SBQQ__Quote__c WHERE Id IN: quoteIds

            ];            

            for(SBQQ__Quote__c quote : quotes) {

                CpqAudit__c auditRecord = CventMyd_UtilityMethods.getAuditRecord(quote,false,apexLimitsString);

                auditRecord.exceptionOccurred__c = true;

                auditRecord.quoteJobMaster__c = jobAuditRecord.Id;

                auditRecord.processingInformation__c += exceptionString;

                auditRecord.processingInformation__c += '\r\n' + '==================================================';

                auditRecord.processingInformation__c += '\r\n' + 'quoteIds: ' + JSON.serialize(this.quoteIds);

                quote.schedulableExceptionCount__c = (quote.schedulableExceptionCount__c == null) ? 1 : quote.schedulableExceptionCount__c + 1;

                auditRecords.add(auditRecord);

            }

            insert auditRecords;

            try {update quotes;}

            catch(Exception e1) {}

            CventMyd_UtilityMethods.abortSchedulableJobs(true,quoteMasterAuditRecord.previousJob__r.Name,this.jobName,false);
            
        }

    }

}