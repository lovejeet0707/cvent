public without sharing class CventMyd_QuoteTriggerHandler {

    public static Map<String,Opportunity> quoteInsertionIdToOpportunity = new Map<String,Opportunity>();

    public static List<List<String>> fieldValueMapFieldNameLists = new List<List<String>>();

    public static Map<Id,Id> amendedContractIdToAmendmentOpportunityId = new Map<Id,Id>();

    public static Map<Id,CpqAudit__c> quoteIdToInsertionAuditRecord = new Map<Id,CpqAudit__c>();

    public static Map<Id,Id> quoteIdToNextQuote = new Map<Id,Id>();

    public static Set<Id> newQuoteIds = new Set<Id>();

    public static Id contractIdInRenewalJob;

    public static Id amendmentChainMasterId;

    public static Id renewalChainMasterId;

    public static String sessionIdString;

    public static Boolean disabledCpqTriggers = false;

    public static Set<Id> msaQuoteIdsForRecalculation = new Set<Id>();

    public static Integer runningCalculationJobs = null;

    public static Boolean calculationIsRunning;

    public static Boolean qleIsOpen;

    public static Integer triggerFireCount = 0;

    public static String currentRequestUrl;

    public static String currentApexContext;

    public static Map<String,String> quoteInsertionIdToParallelLineIds = new Map<String,String>();

    public static Map<String,Opportunity> getUpdatedQuoteToOpportunityMap(Map<String,Opportunity> quoteInsertionIdToOpportunity) {

        Map<Id,List<String>> opportunityIdToInsertionIds = new Map<Id,List<String>>();

        for(SBQQ__Quote__c quote : (List<SBQQ__Quote__c>)Trigger.new) {

            CventMyd_QuoteObject quoteObject = CventMyd_UtilityMethods.getQuoteObject(quote);
            
            if(quoteObject != null && quote.nextQuote__c == null) {

                String insertionId = quoteObject.insertionId;

                if(!quoteInsertionIdToOpportunity.containsKey(insertionId)) {

                    if(!opportunityIdToInsertionIds.containsKey(quote.SBQQ__Opportunity2__c)) {

                        opportunityIdToInsertionIds.put(quote.SBQQ__Opportunity2__c,new List<String>());

                    }

                    opportunityIdToInsertionIds.get(quote.SBQQ__Opportunity2__c).add(insertionId);

                }

            }

        }

        Set<Id> opportunityIdsToQuery = opportunityIdToInsertionIds.keySet();

        if(opportunityIdsToQuery.size() > 0) {

            String queryString = 'SELECT Id,Name';

            queryString += ',' + CventMyd_Settings.opportunityFieldNamesString;

            queryString += ', (SELECT Id,Name,SBQQ__Primary__c,Cloned_From_Quote__c FROM SBQQ__Quotes2__r ORDER BY CreatedDate DESC)';

            queryString += ' FROM Opportunity';

            queryString += ' WHERE Id IN: opportunityIdsToQuery';

            for(Opportunity opportunity : Database.query(queryString)) {

                for(String insertionId : opportunityIdToInsertionIds.get(opportunity.Id)) {

                    quoteInsertionIdToOpportunity.put(insertionId,opportunity);

                }

            }

        }

        return quoteInsertionIdToOpportunity;

    }

    /*
       #Added By Mohsin

       Whenever a new quote is being created, this method will check for the 'amended contract’ field on opportunity.

       If 'amended contract’ is not blank and this quote is not the first quote for the parent opportunity then it will not allow user to create the Quote.
       
    */
    
    public static void checkForAmendedContract() {

        Map<Id,List<SBQQ__Quote__c>> opportunityIdToQuotes = new Map<Id,List<SBQQ__Quote__c>>();

        System.debug('trigger new size: ' + Trigger.new.size());
        
        for(SBQQ__Quote__c quote : (List<SBQQ__Quote__c>)Trigger.new) {

            if(quote.SBQQ__Opportunity2__c != null) {

                System.debug('opportunityId 0: ' + quote.SBQQ__Opportunity2__c);

                if(opportunityIdToQuotes.get(quote.SBQQ__Opportunity2__c) == null) {

                    opportunityIdToQuotes.put(quote.SBQQ__Opportunity2__c, new List<SBQQ__Quote__c>());

                }

                opportunityIdToQuotes.get(quote.SBQQ__Opportunity2__c).add(quote);

            }

        }

        if(Trigger.isInsert) {

            System.debug('in the checkForAmendedContract method: ');
        
            for(Opportunity opp : quoteInsertionIdToOpportunity.values()) {

                System.debug('debug 000 ');

                if(opportunityIdToQuotes.containsKey(opp.Id) && opp.SBQQ__AmendedContract__c != null) {

                    System.debug('debug 001 ');

                    List<SBQQ__Quote__c> quotes = opp.SBQQ__Quotes2__r;

                    System.debug('quotes.size(): ' + quotes.size());

                    if(quotes.size() > 0 || CventMyd_ContractAmendmentController.contractIdsBeingAmended.isEmpty()) {

                        System.debug('opportunityId 1: ' + opp.Id);

                        for(SBQQ__Quote__c quote : opportunityIdToQuotes.get(opp.Id)) {

                            if(!Test.isRunningTest()) {

                                quote.addError('You’ve already started an amendment; in order to change create a new quote, create a new opportunity.');

                            }

                        }
                    
                    }

                }

            }

        }

    }
    /* test for MSA renewal
    public static void updateMsaOnRenewal(){
        
        for(SBQQ__Quote__c q:(List<SBQQ__Quote__c>)Trigger.new){
            
            if(q.SBQQ__Opportunity2__r.MSA_Code__c != null)
                q.msaUpload__c = true;
        }*/
    
    public static void handleBeforeInsert() {

        System.debug('#####CventMyd_QuoteTriggerHandler.handleBeforeInsert()#####');

        System.debug('$$$$ Queueable Jobs added: ' + Limits.getQueueableJobs());

        List<Opportunity> opportunitiesToDelete = new List<Opportunity>();

        System.debug('sessionIdString (in quote trigger handler): ' + sessionIdString);

        renewalChainMasterId = CventMyd_AutoRenewContractSchedulable.renewalChainMasterId;

        for(SBQQ__Quote__c quote : (List<SBQQ__Quote__c>)Trigger.new) {

            if(quote.Cloned_From_Quote__c == null) {
            
                //if(quote.previousquote__r.MSAUpload__c)
                  //  quote.MSAUpload__c = true;
                
                quote.renewalChainMaster__c = renewalChainMasterId;

                quote.amendmentChainMaster__c = amendmentChainMasterId;

                CventMyd_QuoteObject quoteObject = new CventMyd_QuoteObject();

                quoteObject.insertionId = CventMyd_UtilityMethods.getQleId();

                System.debug('quoteObject.insertionId: ' + quoteObject.insertionId);

                quoteObject.settings = new CventMyd_QuoteObject.Settings();

                quoteObject.settings.preCalculationFieldNames = CventMyd_Settings.fieldValueMapFieldNameLists[0];

                quoteObject.settings.calculatedFieldNames = CventMyd_Settings.fieldValueMapFieldNameLists[1];

                quoteObject.settings.msAtLastUpdate = null;

                quoteObject.automationStage = new CventMyd_QuoteAutomationStage();

                quoteObject.automationStage.codeStatus = CventMyd_QuoteAutomationStage.CodeStatus.LAST_UPDATED_BY_TRIGGER;

                quoteObject.outyearMap = new Map<Integer,CventMyd_Outyear>();

                quote.jsonString__c = JSON.serialize(quoteObject);

            }
                
        }        

        quoteInsertionIdToOpportunity = getUpdatedQuoteToOpportunityMap(quoteInsertionIdToOpportunity);

        checkForAmendedContract();  //#Added By Mohsin
        
        for(SBQQ__Quote__c quote : (List<SBQQ__Quote__c>)Trigger.new) {         
            
            if(quote.SBQQ__Type__c != null && quote.Cloned_From_Quote__c == null) {

                quote.sessionIdString__c = sessionIdString;

                CventMyd_QuoteObject quoteObject = CventMyd_UtilityMethods.getQuoteObject(quote);

                Opportunity opportunity = quoteInsertionIdToOpportunity.get(quoteObject.insertionId);

                quote.CurrencyIsoCode = (opportunity != null) ? opportunity.CurrencyIsoCode : quote.CurrencyIsoCode;

                SBQQ__Quote__c previousQuote;

                if(quote.SBQQ__Type__c == 'Renewal' && opportunity.SBQQ__RenewedContract__r != null) {

                    quote.SBQQ__SubscriptionTerm__c = 12;

                }

                if(quote.SBQQ__Type__c == 'Renewal' && opportunity.SBQQ__RenewedContract__r != null && !quote.msaUpload__c) {

                    Contract childContract = opportunity.SBQQ__RenewedContract__r;

                    quote.Contract_Term_Years__c = childContract.Parent_Contract_Term_Years__c;

                    System.debug('Child Contract End Date before'+childContract.EndDate);

                    quote.SBQQ__StartDate__c = childContract.EndDate.addDays(1);

                     System.debug('Child Contract End Date after'+childContract.EndDate);

                    if(childContract.Upcoming_Renewal_Type__c == 'Contract Renewal') {

                       quote.Current_Year__c = 1;

                       quote.SBQQ__EndDate__c = quote.SBQQ__StartDate__c.addYears(1);

                       quote.SBQQ__EndDate__c = quote.SBQQ__EndDate__c.addDays(-1);

                       quote.Multiple_Years_Commitment__c = false;

                       quoteObject.automationStage.outyearProcessingStage = null;

                    }

                    else if(childContract.Upcoming_Renewal_Type__c == 'MYD Renewal') {

                        quote.isLockedIntratermRenewal__c = true;

                        quote.Current_Year__c = childContract.Current_Year__c + 1;

                        quote.Multiple_Years_Commitment__c = childContract.Multiple_Years_Commitment__c;

                    }

                    previousQuote = (childContract.contractedAmendmentQuote__c != null) ? childContract.contractedAmendmentQuote__r : childContract.SBQQ__Quote__r;

                    if(previousQuote != null && CventMyd_UtilityMethods.getQuoteObject(previousQuote) != null) {

                        quote.previousQuote__c = previousQuote.Id;

                        System.debug('previous quote id: ' + quote.previousQuote__c);

                        //System.debug('previous quote parallel line addition ids: ' + previousQuote.parallelLineAdditionIds__c);

                        if(childContract.contractedAmendmentQuote__c != null) {

                            quoteInsertionIdToParallelLineIds.put(quoteObject.insertionId,previousQuote.parallelLineAdditionIds__c);

                        }

                        if(quote.Current_Year__c > 1) {

                            CventMyd_QuoteObject previousQuoteObject = CventMyd_UtilityMethods.getQuoteObject(previousQuote);

                            quote.SBQQ__EndDate__c = previousQuoteObject.outyearMap.get((Integer)quote.Current_Year__c).endDate;

                            for(Integer i = (Integer)quote.Current_Year__c + 1; i <= Integer.valueOf(quote.Contract_Term_Years__c); i++) {

                                quoteObject.outyearMap.put(i,previousQuoteObject.outyearMap.get(i));

                            }

                        }

                    }

                    else if(previousQuote == null || CventMyd_UtilityMethods.getQuoteObject(previousQuote) == null) {

                        quote.previousQuote__c = null;

                        quote.createdFromLegacyContract__c = true;

                        quote.SBQQ__EndDate__c = CventMyd_LegacyContractHandler.getEndDateForQuoteCreatedFromLegacyContract(quote,childContract);

                        quoteObject.outyearMap = CventMyd_UtilityMethods.getOutyearMap((SObject)childContract);

                        quoteObject.outyearMap.remove((Integer)quote.Current_Year__c);

                        quoteObject.currentYearSynced = true;

                    }

                }

                else if(quote.SBQQ__Type__c == 'Amendment' && opportunity.SBQQ__AmendedContract__r != null && !quote.msaUpload__c) {

                    Contract childContract = opportunity.SBQQ__AmendedContract__r;

                    quote.Multiple_Years_Commitment__c = childContract.Multiple_Years_Commitment__c;

                    quote.Current_Year__c = childContract.Current_Year__c;

                    quote.Contract_Term_Years__c = childContract.Parent_Contract_Term_Years__c;

                    quote.SBQQ__EndDate__c = childContract.EndDate;

                    Boolean amendmentOpportunityWasCreatedByUser = amendedContractIdToAmendmentOpportunityId.values().contains(opportunity.Id);

                    if(amendedContractIdToAmendmentOpportunityId.keySet().contains(opportunity.SBQQ__AmendedContract__c) && !amendmentOpportunityWasCreatedByUser) {

                        opportunitiesToDelete.add(opportunity);

                        quote.SBQQ__Opportunity2__c = amendedContractIdToAmendmentOpportunityId.get(opportunity.SBQQ__AmendedContract__c);

                    }                    

                    previousQuote = (childContract.contractedAmendmentQuote__c != null) ? childContract.contractedAmendmentQuote__r : childContract.SBQQ__Quote__r;

                    if(previousQuote != null && CventMyd_UtilityMethods.getQuoteObject(previousQuote) != null) {

                        if(childContract.contractedAmendmentQuote__c != null) {

                            quoteInsertionIdToParallelLineIds.put(quoteObject.insertionId,previousQuote.parallelLineAdditionIds__c);

                        }

                        quote.previousQuote__c = previousQuote.Id;

                        String insertionId = quoteObject.insertionId;

                        quoteObject = CventMyd_UtilityMethods.getQuoteObject(previousQuote);

                        quoteObject.insertionId = insertionId;

                        quoteObject.automationStage.codeStatus = CventMyd_QuoteAutomationStage.CodeStatus.LAST_UPDATED_BY_TRIGGER;

                    }

                    else if(previousQuote == null || CventMyd_UtilityMethods.getQuoteObject(previousQuote) == null) {

                        quote.previousQuote__c = null;

                        quote.createdFromLegacyContract__c = true;

                        quoteObject.outyearMap = CventMyd_UtilityMethods.getOutyearMap((SObject)childContract);

                        quote.SBQQ__EndDate__c = childContract.EndDate;

                    }

                }

                if(previousQuote != null) {quoteObject.previousQuoteType = previousQuote.SBQQ__Type__c;}

                quoteObject.automationStage.outyearProcessingStage = (quote.Multiple_Years_Commitment__c) ? CventMyd_QuoteAutomationStage.OutyearProcessingStage.NEWLY_INSERTED_VARIABLE : CventMyd_QuoteAutomationStage.OutyearProcessingStage.NEWLY_INSERTED_NON_VARIABLE;

                quote.SBQQ__LineItemsGrouped__c = (quote.SBQQ__Type__c == 'Renewal' || quote.SBQQ__Type__c == 'Amendment') ? quote.Multiple_Years_Commitment__c : false;

                Integer finalYear = (quote.Contract_Term_Years__c != null) ? Integer.valueOf(quote.Contract_Term_Years__c) : null;

                Boolean newQuote = (quote.SBQQ__Type__c == 'Quote');

                Boolean termRenewal = (quote.SBQQ__Type__c == 'Renewal' && quote.Current_Year__c == 1);
                
                quoteObject.outyearMap = (newQuote || termRenewal || quote.msaUpload__c) ? CventMyd_UtilityMethods.getOutyearMap((SObject)quote) : quoteObject.outyearMap;

                quote.Contract_End_Date__c = (finalYear != null && quoteObject.outyearMap.get(finalYear) != null) ? Date.valueOf(quoteObject.outyearMap.get(finalYear).endDate) : quote.SBQQ__EndDate__c;

                quote.jsonString__c = JSON.serialize(quoteObject);

                quote.SBQQ__Primary__c = true;

                quote.RecordTypeId = CventMyd_Settings.quoteUnlockedRecordTypeId;

            }

        }

        if(opportunitiesToDelete.size() > 0) {

            delete opportunitiesToDelete;

        }

        if(cloneRelated.pass != true) {

            Set<Id> quoteIdsToUncheckPrimary = new Set<Id>();

            for(Opportunity o : quoteInsertionIdToOpportunity.values()) {

                if(o.SBQQ__Quotes2__r.size() > 0) {

                    for(Integer i = 0; i < o.SBQQ__Quotes2__r.size(); i++) {

                        SBQQ__Quote__c quote = o.SBQQ__Quotes2__r[i];

                        if(quote.Id != null && quote.SBQQ__Primary__c) {

                            quoteIdsToUncheckPrimary.add(quote.Id);

                        }

                    }

                }

            }

            if(quoteIdsToUncheckPrimary.size() > 0 && !System.isFuture() && !System.isBatch()) {

                CventMyd_UtilityMethods.uncheckPrimaryOnQuotes(quoteIdsToUncheckPrimary);

            }

        }

    }

    public static void handleAfterInsert() {

        System.debug('#####CventMyd_QuoteTriggerHandler.handleAfterInsert()#####');

        List<CpqAudit__c> auditRecords = new List<CpqAudit__c>();

        String apexLimitsString = CventMyd_UtilityMethods.getApexLimitsString();

        Set<Id> quoteIdsToDelete = new Set<Id>();

        Map<Id,List<Integer>> quoteIdToYearsToCreateGroups = new Map<Id,List<Integer>>();

        for(SBQQ__Quote__c quote : (List<SBQQ__Quote__c>)Trigger.new) {

            if(quote.msaUpload__c && quote.Multiple_Years_Commitment__c) {

                CventMyd_LineAndGroupHandler.quoteIdToQuoteWrapper.put(quote.Id,new CventMyd_LineAndGroupHandler.QuoteWrapper(quote));

                quoteIdToYearsToCreateGroups.put(quote.Id,CventMyd_UtilityMethods.getYearsSorted(quote));

            }            

            else if( quote.SBQQ__Type__c == 'Renewal' && !quote.msaUpload__c && ContractTrgHelperCls.contractIdsBeingRenewed.isEmpty() && System.isFuture() ) {

                System.debug('DISABLING CPQ TRIGGERS');

                SBQQ.TriggerControl.disable();

                disabledCpqTriggers = true;

                quoteIdsToDelete.add(quote.Id);

            }

            else if(quote.Cloned_From_Quote__c == null && !quote.msaUpload__c) {

                CventMyd_QuoteObject quoteObject = CventMyd_UtilityMethods.getQuoteObject(quote);        

                CpqAudit__c auditRecord = CventMyd_UtilityMethods.getAuditRecord(quote,true,apexLimitsString);

                if(quote.SBQQ__Type__c == 'Amendment' || quote.SBQQ__Type__c == 'Renewal' && quote.SBQQ__Opportunity2__c != null) {

                    Opportunity opportunity = quoteInsertionIdToOpportunity.get(quoteObject.insertionId);

                    auditRecord.contract__c = (quote.SBQQ__Type__c == 'Amendment') ? opportunity.SBQQ__AmendedContract__c : opportunity.SBQQ__RenewedContract__c;

                    auditRecord.chainMaster__c = (renewalChainMasterId != null) ? renewalChainMasterId : amendmentChainMasterId ;

                }

                auditRecords.add(auditRecord);

                newQuoteIds.add(quote.Id);

            }

        }

        List<SBQQ__QuoteLineGroup__c> quoteLineGroups = CventMyd_LineAndGroupHandler.getMydQuoteLineGroups(quoteIdToYearsToCreateGroups,true);

        System.debug('quoteLineGroups: ' + quoteLineGroups);

        if(quoteLineGroups.size() > 0) {

            for(SBQQ__QuoteLineGroup__c qlg : quoteLineGroups) {

                Id quoteId = qlg.SBQQ__Quote__c;

                SBQQ__Quote__c quote = (SBQQ__Quote__c)Trigger.newMap.get(quoteId);

                Map<Integer,CventMyd_Outyear> yearToDates = CventMyd_UtilityMethods.getFullYearToDatesMap(quote);

                Integer year = (Integer)qlg.term__c;

                qlg.SBQQ__StartDate__c = yearToDates.get(year).startDate;

                qlg.SBQQ__EndDate__c = yearToDates.get(year).endDate;

                qlg.termLength__c = quote.Contract_Term_Years__c;

            }

            insert quoteLineGroups;

        }
        
        if(auditRecords.size() > 0) {
            
            insert auditRecords;
            
            for(CpqAudit__c auditRecord : auditRecords) {quoteIdToInsertionAuditRecord.put(auditRecord.quote__c,auditRecord);}
            
        }

        if(quoteIdsToDelete.size() > 0) {

            System.debug('SCHEDULING JOB TO DELETE GHOST QUOTES');

            String jobName = 'GHOST QUOTE DELETION: ' + CventMyd_UtilityMethods.getFormattedDateTimeString(DateTime.now(),true,false);

            CventMyd_DeleteGhostQuotes deleteGhostQuotes = new CventMyd_DeleteGhostQuotes(quoteIdsToDelete,jobName);

            String cronString = CventMyd_UtilityMethods.getCronString(20);

            String jobIdString = System.schedule(jobName,cronString,deleteGhostQuotes);

            System.debug('jobIdString: ' + jobIdString);
            
        }

    }


    public static void handleBeforeUpdate() {

        System.debug('#####CventMyd_QuoteTriggerHandler.handleBeforeUpdate()#####');

        checkForAmendedContract();

        determineUpdateContext();

        Map<Id,Integer> quoteIdToRecalculationAttempts = new Map<Id,Integer>();

        for(SBQQ__Quote__c quote : (List<SBQQ__Quote__c>)Trigger.new) {
            
            // set outyear dates for certification SKU quotes: P-004417
            if(quote.Certification_SKU__c > 0 && quote.SBQQ__Type__c == 'Renewal' && quote.Current_Year__c == 1 && quote.CreatedDate > Date.newInstance(2019, 2, 17)){
                quote.SBQQ__EndDate__c = quote.SBQQ__StartDate__c!=null?quote.SBQQ__StartDate__c.addYears(2):quote.SBQQ__EndDate__c;
                quote.SBQQ__EndDate__c = quote.SBQQ__EndDate__c!=null?quote.SBQQ__EndDate__c.addDays(-1):quote.SBQQ__EndDate__c;
                Date previousYearEndDate = quote.SBQQ__EndDate__c;
                Map<Integer,CventMyd_Outyear> outyearMap = new Map<Integer,CventMyd_Outyear>();
                for(Integer i = 2; i<= Integer.valueOf(quote.Contract_Term_Years__c); i++ ) {
                    CventMYd_Outyear outyear = new CventMyd_Outyear();
                    outyear.startDate = previousYearEndDate.addDays(+1);
                    outyear.endDate =outyear.startDate.addYears(2);
                    outyear.endDate =outyear.endDate.addDays(-1);
                    previousYearEndDate = outyear.endDate;
                    outyearMap.put(i,outyear);
                }
                CventMyd_QuoteObject quoteObject = CventMyd_UtilityMethods.getQuoteObject(quote.jsonString__C);
                quoteObject.outyearMap = outyearMap;
                quote.jsonString__c = JSON.serialize(quoteObject);
                System.debug('certification SKU outyearMap: ' + outyearMap);
                if(outyearMap.containsKey(Integer.valueOf(quote.Contract_Term_Years__c))){
                    quote.Contract_End_Date__c = outyearMap.get(Integer.valueOf(quote.Contract_Term_Years__c)).endDate;
                }
                else{
                    quote.Contract_End_Date__c = quote.SBQQ__EndDate__c;
                } 
            }

            Boolean notNull = (quote.SBQQ__Account__c != null && quote.SBQQ__Opportunity2__c != null && quote.SBQQ__Type__c != null);
            String errorString;
            if(notNull) {
                errorString = CventMyd_ValidationHandler.getBeforeUpdateErrors(quote);
            }
            Boolean legacyNonPrimary = (quote.jsonString__c == null && !quote.SBQQ__Primary__c);
            if(!String.isBlank(errorString) && !legacyNonPrimary && notNull) {
                quote.addError(errorString);
            }

            Boolean lineCountHasChanged = CventMyd_UtilityMethods.didFieldChange(quote,'SBQQ__LineItemCount__c');

            quote.calculationCycleFinished__c = (lineCountHasChanged && !calculationIsRunning) ? false : quote.calculationCyclefinished__c;

            
            if(quote.msaUpload__c) {

                quote.SBQQ__LineItemsGrouped__c = (quote.Multiple_Years_Commitment__c) ? true : quote.SBQQ__LineItemsGrouped__c ;

                if(lineCountHasChanged && !calculationIsRunning && !msaQuoteIdsForRecalculation.contains(quote.Id) && CventMyd_Settings.recalculationSettings.recalculateMsaQuotes) {

                    quoteIdToRecalculationAttempts.put(quote.Id,0);

                    msaQuoteIdsForRecalculation.add(quote.Id);                           

                }

            }
            

            try {

                Integer finalYear = Integer.valueOf(quote.Contract_Term_Years__c);

                String outyearDatesVerbiage = '';

                Boolean nonStandardYears = false;

                Boolean populateDatesVerbiage = false;

                if(finalYear > quote.Current_Year__c && quote.jsonString__c != null) {

                    CventMyd_QuoteObject quoteObject = CventMyd_UtilityMethods.getQuoteObject(quote);

                    Map<Integer,CventMyd_Outyear> yearToDates = quoteObject.outyearMap.clone();

                    CventMyd_Outyear currentYear = new CventMyd_Outyear();

                    currentYear.startDate = quote.SBQQ__StartDate__c;

                    currentYear.endDate = quote.SBQQ__EndDate__c;

                    yearToDates.put((Integer)quote.Current_Year__c,currentYear);

                    List<Integer> yearsSorted = new List<Integer>(yearToDates.keySet());

                    yearsSorted.sort();

                    for(Integer year : yearsSorted) {

                        System.debug('year: ' + year);

                        Date startDate = yearToDates.get(year).startDate;

                        Date endDate = yearToDates.get(year).endDate;

                        Integer daysBetween = CventMyd_UtilityMethods.getDaysBetween(startDate,endDate);

                        System.debug('daysBetween: ' + daysBetween);

                        outyearDatesVerbiage += '• YEAR ' + String.valueOf(year) + ': ';

                        outyearDatesVerbiage += startDate.format();

                        outyearDatesVerbiage += ' to ' + endDate.format();

                        outyearDatesVerbiage += '\r\n';

                        if(daysBetween != 365) {populateDatesVerbiage = true;}

                    }

                }

                quote.outyearDatesVerbiage__c = (populateDatesVerbiage) ? outyearDatesVerbiage : '';

            }

            catch(Exception e) {

                System.debug('In general it is bad practice to just catch and debug exceptions... here it should be ok: ' + CventMyd_UtilityMethods.getExceptionString(e));

            }
            

        }

        handleQuoteRecalculation(quoteIdToRecalculationAttempts);

    }

    public static void determineUpdateContext() {

        triggerFireCount++;

        currentApexContext = (currentApexContext == null) ? CventMyd_UtilityMethods.getApexContext() : currentApexContext;

        if(currentRequestUrl == null) {

            try {

                Url currentUrl = Url.getCurrentRequestUrl();

                System.debug('currentUrl: ' + currentUrl);

                currentRequestUrl = String.valueOf(currentUrl);                

            }

            catch (Exception e) {

                currentRequestUrl = '';

                System.debug('whoa there, whoa there...');

                String exceptionMessage = e.getMessage();

                System.debug('exceptionMessage: ' + exceptionMessage);

                if(exceptionMessage.contains('Illegal character in path at index ')) {

                    exceptionMessage = exceptionMessage.replaceAll(' ','%20');

                    currentRequestUrl = exceptionMessage.substringAfter('https://');

                    currentRequestUrl = 'https://' + currentRequestUrl;

                }

            }

        }

        System.debug('currentRequestUrl: ' + currentRequestUrl);

        for(SBQQ__Quote__c quote : (List<SBQQ__Quote__c>)Trigger.new)  {

            CventMyd_QuoteObject quoteObject = CventMyd_UtilityMethods.getQuoteObject(quote);

            if(quoteObject != null) {
                
                String oldJsonString = ((SBQQ__Quote__c)Trigger.oldMap.get(quote.Id)).jsonString__c;
                
                String newJsonString = ((SBQQ__Quote__c)Trigger.newMap.get(quote.Id)).jsonString__c;
                
                String oldCalculationId = (CventMyd_UtilityMethods.getQuoteObject(oldJsonString)).calculationIdString;
                
                String newCalculationId = (CventMyd_UtilityMethods.getQuoteObject(newJsonString)).calculationIdString;
                
                if(oldCalculationId != newCalculationId && newCalculationId != null && newCalculationId != 'NOT_IN_CALCULATION_CONTEXT') {
                    
                    calculationIsRunning = true;
                    
                    qleIsOpen = (newCalculationId.contains('QLE__'));
                    
                    break;
                    
                }
                
                else if(currentRequestUrl.containsIgnoreCase('sbqq') && currentRequestUrl.containsIgnoreCase('apexremote')) {
                    
                    calculationIsRunning = true;
                    
                    qleIsOpen = true;
                    
                    break;
                    
                }
                
                else if(oldCalculationId == newCalculationId && (calculationIsRunning == null || !calculationIsRunning)) {
                    
                    quoteObject.calculationIdString = 'NOT_IN_CALCULATION_CONTEXT_';
                    
                    quoteObject.calculationIdString += currentApexContext;
                    
                    quote.jsonString__c = JSON.serialize(quoteObject);
                    
                    calculationIsRunning = false;
                    
                    qleIsOpen = false;
                    
                }
                
            }
            
        }

    }

    public static void handleQuoteRecalculation(Map<Id,Integer> quoteIdToRecalculationAttempts) {

        System.debug('handling quote recalculation with quote count: ' + quoteIdToRecalculationAttempts.keySet().size());

        if(runningCalculationJobs == null && !quoteIdToRecalculationAttempts.keySet().isEmpty()) {

            List<CpqAudit__c> records = [SELECT

                Id,LastModifiedDate FROM CpqAudit__c

                WHERE Name LIKE 'Quote Recalculate - forceRecalculation%'

                AND chainFinished__c = false

            ];

            runningCalculationJobs = records.size();

            System.debug('runningCalculationJobs: ' + runningCalculationJobs);

            if(runningCalculationJobs == 1) {

                DateTime lastModified = records[0].LastModifiedDate;

                Decimal hoursSinceModification = CventMyd_UtilityMethods.getHoursBetweenDateTimes(lastModified,DateTime.now());

                if(hoursSinceModification > .5) {

                    records[0].chainFinished__c = true;

                    update records;

                    runningCalculationJobs = 0;

                }
                
            }            

            if(runningCalculationJobs == 0) {

                System.debug('scheduling a job to recalculate MSA quotes: ');

                CventMyd_RecalculateQuotes recalculateQuotes = new CventMyd_RecalculateQuotes(quoteIdToRecalculationAttempts,0);

                System.debug('recalculateQuotes.settings.forceRecalculation: ' + recalculateQuotes.settings.forceRecalculation);

                recalculateQuotes.upsertAuditRecord(null);

                String jobName = recalculateQuotes.getJobName();

                Integer secondsUntilJobStart = Math.round(CventMyd_Settings.recalculationSettings.minutesBeforeFirstJob * 60);

                String cronString = CventMyd_UtilityMethods.getCronString(secondsUntilJobStart);

                System.schedule(jobName,cronString,recalculateQuotes);

            }

            else if(runningCalculationJobs != 1) {

                throw new CventMyd_RecalculateQuotes.RecalculationException('There can only be 1 or 0 recalculation jobs running at once.');

            }

        }

    }

    public static void handleAfterUpdate() {

        System.debug('#####CventMyd_QuoteTriggerHandler.handleAfterUpdate()#####');

        System.debug('$$$$ Queueable Jobs added: ' + Limits.getQueueableJobs());        

        if(quoteInsertionIdToOpportunity.keySet().size() > 0) {

           quoteInsertionIdToOpportunity = getUpdatedQuoteToOpportunityMap(quoteInsertionIdToOpportunity);

        }

        Set<Id> quoteIdsToGroupByCurrentYear = new Set<Id>();

        Set<Id> quoteIdsToRoute = new Set<Id>();

        List<CpqAudit__c> insertionAuditRecordsToUpdate = new List<CpqAudit__c>();

        String apexLimitsString = CventMyd_UtilityMethods.getApexLimitsString();    

        Boolean updatePreviousQuotes = false;

        for(SBQQ__Quote__c quote : (List<SBQQ__Quote__c>)Trigger.new) {

            if(quote.jsonString__c == null) {

                Boolean oldPrimaryBoolean = ((SBQQ__Quote__c)Trigger.oldMap.get(quote.Id)).SBQQ__Primary__c;

                if(oldPrimaryBoolean != true && quote.SBQQ__Primary__c) {

                    String errorMessage = ' You cannot mark this quote as primary.';

                    errorMessage += ' Please use the quote on the opportunity that was migrated for you in the new format, or create a new quote.';

                    quote.addError(errorMessage);

                }

            }            

            else if(quote.previousQuote__c != null && !quoteIdToNextQuote.values().contains(quote.Id) && newQuoteIds.contains(quote.Id)) {

                updatePreviousQuotes = true;

                quoteIdToNextQuote.put(quote.previousQuote__c,quote.Id);

            }

        }

        if(updatePreviousQuotes && !(System.isFuture() && CventMyd_ContractAmendmentController.contractIdsBeingAmended.isEmpty())) {

            CventMyd_UtilityMethods.updatePreviousQuotes(quoteIdToNextQuote);

        }            

        for(SBQQ__Quote__c quote : (List<SBQQ__Quote__c>)Trigger.new) {

            if(quote.Cloned_From_Quote__c == null && !quote.msaUpload__c && quote.jsonString__c != null && (quote.SBQQ__Type__c == 'Renewal' || quote.SBQQ__Type__c == 'Amendment')) {
                
                CventMyd_QuoteObject quoteObject = CventMyd_UtilityMethods.getQuoteObject(quote);
                
                Opportunity opportunity = quoteInsertionIdToOpportunity.get(quoteObject.insertionId);
                
                Boolean renewalQuoted = (opportunity != null && opportunity.SBQQ__RenewedContract__r != null) ? opportunity.SBQQ__RenewedContract__r.SBQQ__RenewalQuoted__c : false;

                Boolean renewalForecast = (opportunity != null && opportunity.SBQQ__RenewedContract__r != null) ? opportunity.SBQQ__RenewedContract__r.SBQQ__RenewalForecast__c : false;

                Boolean isRenewal = (renewalQuoted && !renewalForecast || renewalQuoted && renewalForecast);

                Boolean isAmendment = (quote.SBQQ__Type__c == 'Amendment');

                Boolean outyearProcessingComplete = quote.jsonString__c.contains('OUTYEAR_PROCESSING_COMPLETE');

                Boolean lastUpdatedByTrigger = quote.jsonString__c.contains('LAST_UPDATED_BY_TRIGGER');

                Boolean newAmendmentOrRenewal = ( (isRenewal || isAmendment) && lastUpdatedByTrigger);

                if(newAmendmentOrRenewal && quote.Multiple_Years_Commitment__c) {

                    quoteIdsToGroupByCurrentYear.add(quote.Id);

                }

                if(!outyearProcessingComplete && newQuoteIds.contains(quote.Id)) {

                    quoteIdsToRoute.add(quote.Id);

                }

            }
            
            CpqAudit__c insertionAuditRecord = quoteIdToInsertionAuditRecord.get(quote.Id);

            if(insertionAuditRecord != null) {

                insertionAuditRecord.processingInformation__c += '\r\n' + '==================================================';

                insertionAuditRecord.processingInformation__c += '\r\n' + 'After update trigger fire limits: ' + '\r\n' + apexLimitsString;

                insertionAuditRecordsToUpdate.add(insertionAuditRecord);

            }
            
        }

        if(insertionAuditRecordsToUpdate.size() > 0) {

          update insertionAuditRecordsToUpdate;

        }

        System.debug('quoteIdsToGroupByCurrentYear: ' + quoteIdsToGroupByCurrentYear);

        if(quoteIdsToGroupByCurrentYear.size() > 0) {

            CventMyd_LineAndGroupHandler.groupCurrentYearQuoteLines(quoteIdsToGroupByCurrentYear);

        }

        if(quoteIdsToRoute.size() > 0) {

            CventMyd_QuoteRouter.routeQuotes(quoteIdsToRoute);

        }

    }

}