public without sharing class CventMyd_LegacyContractHandler {

    public static Map<Id,Map<Integer,CventMyd_QuoteLineObject>> subscriptionIdToYearToQuoteLineObject = new Map<Id,Map<Integer,CventMyd_QuoteLineObject>>();

    public static Map<Id,Contract> subscriptionIdToContract = new Map<Id,Contract>();

    public static List<SBQQ__Subscription__c> getAndSetLegacySubscriptions(Set<Id> contractIds) {

        String queryString = 'SELECT Id,Name';

        queryString += ',' + CventMyd_Settings.legacySubscriptionFieldNamesString;

        queryString += ', (SELECT Id,Name,SBQQ__Quantity__c FROM SBQQ__Revisions__r)';

        queryString += ' FROM SBQQ__Subscription__c';

        queryString += ' WHERE SBQQ__RevisedSubscription__c = null';

        queryString += ' AND SBQQ__Contract__c IN: contractIds';

        List<SBQQ__Subscription__c> legacySubscriptions = Database.query(queryString);
                                                                                    
        if(legacySubscriptions.size() > 0) {

            for(SBQQ__Subscription__c subscription : legacySubscriptions) {

                if(ContractTrgHelperCls.legacyContractIdToSubscriptions.get(subscription.SBQQ__Contract__c) == null) {

                    ContractTrgHelperCls.legacyContractIdToSubscriptions.put(subscription.SBQQ__Contract__c, new List<SBQQ__Subscription__c>());

                }

                ContractTrgHelperCls.legacyContractIdToSubscriptions.get(subscription.SBQQ__Contract__c).add(subscription);

            }

            subscriptionIdToYearToQuoteLineObject = getSubscriptionIdToYearToQuoteLineObject(legacySubscriptions);

            legacySubscriptions = getExistingLegacySubscriptionsToUpdateJsonStrings(subscriptionIdToYearToQuoteLineObject);

        }

        return legacySubscriptions;

    }

    public static List<SBQQ__Subscription__c> getExistingLegacySubscriptionsToUpdateJsonStrings(Map<Id,Map<Integer,CventMyd_QuoteLineObject>> subscriptionIdToYearToQuoteLineObject) {

        List<SBQQ__Subscription__c> subscriptionsToUpdate = new List<SBQQ__Subscription__c>();

        for(Id subscriptionId : subscriptionIdToYearToQuoteLineObject.keySet()) {

            SBQQ__Subscription__c subscription = new SBQQ__Subscription__c(Id = subscriptionId);

            Contract contract = subscriptionIdToContract.get(subscription.Id);

            Map<Integer,CventMyd_QuoteLineObject> yearToQuoteLineObject = subscriptionIdToYearToQuoteLineObject.get(subscriptionId);

            List<Integer> years = new List<Integer>(yearToQuoteLineObject.keySet()); years.sort();

            if(years.size() > 0) {

                Integer currentYear = years[0];

                CventMyd_QuoteLineObject currentYearQuoteLineObject = yearToQuoteLineObject.get(currentYear);

                Boolean renewalOccurring = ContractTrgHelperCls.contractIdsBeingRenewed.contains(contract.Id);

                Boolean amendmentOccurring = CventMyd_ContractAmendmentController.contractIdsBeingAmended.contains(contract.Id);

                Boolean usingLegacyData = (contract.contractedAmendmentQuote__c == null);

                if(usingLegacyData && (renewalOccurring || amendmentOccurring)) {

                    subscription.jsonString__c = JSON.serialize(currentYearQuoteLineObject);

                    subscriptionsToUpdate.add(subscription);

                }

            }

        }

        return subscriptionsToUpdate;
    }

    public static Map<Id,Map<Integer,CventMyd_QuoteLineObject>> getSubscriptionIdToYearToQuoteLineObject(List<SBQQ__Subscription__c> legacySubscriptions) {

        Map<Id,Map<Integer,CventMyd_QuoteLineObject>> subscriptionIdToYearToQuoteLineObject = new Map<Id,Map<Integer,CventMyd_QuoteLineObject>>();

        for(SBQQ__Subscription__c subscription : legacySubscriptions) {

            Contract contract = subscription.SBQQ__Contract__r;

            subscriptionIdToContract.put(subscription.Id,contract);

            Map<Integer,CventMyd_QuoteLineObject> yearToQuoteLineObject = getYearToQuoteLineObject(subscription,contract);

            subscriptionIdToYearToQuoteLineObject.put(subscription.Id,yearToQuoteLineObject);

        }

        for(Id subscriptionId : subscriptionIdToYearToQuoteLineObject.keySet()) {

            Map<Integer,CventMyd_QuoteLineObject> yearToQuoteLineObject = subscriptionIdToYearToQuoteLineObject.get(subscriptionId);

            List<Integer> years = new List<Integer>(yearToQuoteLineObject.keySet()); years.sort();

            Boolean isAmendment = CventMyd_ContractAmendmentController.amendedContractId != null;

            System.debug('isAmendment? deleteThisLine debug: ' + isAmendment);

            Contract contract = subscriptionIdToContract.get(subscriptionId);

            Integer currentYear = (Integer)contract.Current_Year__c;
            
            Integer finalYear = Integer.valueOf(contract.Parent_Contract_Term_Years__c);

            Integer startingYearIndex = (isAmendment || ( !isAmendment && years.size() < (finalYear-currentYear+1) ) ) ? 1 : 2 ;

            if(years.size() > startingYearIndex) {

                for(Integer i = startingYearIndex; i < years.size(); i++) {

                    Integer outyear = years[i];

                    CventMyd_QuoteLineObject quoteLineObject = yearToQuoteLineObject.get(outyear);

                    if(quoteLineObject.requiredBySubscriptionIdString != null) {

                        Id requiredBySubscriptionId = Id.valueOf(quoteLineObject.requiredBySubscriptionIdString);

                        Map<Integer,CventMyd_QuoteLineObject> requiredByYearToQuoteLineObject = subscriptionIdToYearToQuoteLineObject.get(requiredBySubscriptionId);

                        CventMyd_QuoteLineObject requiredByQuoteLineObject = requiredByYearToQuoteLineObject.get(outyear);

                        if(requiredByQuoteLineObject != null) {

                            String requiredByQleId = requiredByQuoteLineObject.qleId;

                            quoteLineObject.requiredByQleId = requiredByQuoteLineObject.qleId;

                            yearToQuoteLineObject.put(outyear,quoteLineObject);

                            subscriptionIdToYearToQuoteLineObject.put(subscriptionId,yearToQuoteLineObject);

                        }

                    }

                }

            }

        }

        return subscriptionIdToYearToQuoteLineObject;

    }

    public static Map<Integer,CventMyd_QuoteLineObject> getYearToQuoteLineObject(SBQQ__Subscription__c subscription, Contract contract) {

        List<List<String>> fieldValueMapFieldNameLists = CventMyd_Settings.fieldValueMapFieldNameLists;

        Map<Integer,CventMyd_Outyear> outyearMap = CventMyd_UtilityMethods.getOutYearMap((SObject)contract);

        List<Map<String,List<String>>> quoteLineToSubscriptionFieldMaps = CventMyd_Settings.quoteLineToSubscriptionFieldMaps;

        Map<Id,List<CventMyd_QuoteLineObject>> subcriptionIdToQuoteLineObjects = new Map<Id,List<CventMyd_QuoteLineObject>>();

        String nextYearQleId;

        Boolean isAmendment = (CventMyd_ContractAmendmentController.contractIdsBeingAmended != null && CventMyd_ContractAmendmentController.contractIdsBeingAmended.contains(contract.Id));

        List<String> allQleIds = new List<String>();

        Map<Integer,CventMyd_QuoteLineObject> yearToQuoteLineObject = new Map<Integer,CventMyd_QuoteLineObject>();
                                                                                                          
        for(Integer year = (Integer)contract.Current_Year__c; year <= Integer.valueOf(contract.Parent_Contract_Term_Years__c); year++) {

            Boolean inCurrentYear = (year == (Integer)contract.Current_Year__c);

            Boolean inFinalYear = (year == Integer.valueOf(contract.Parent_Contract_Term_Years__c));

            Integer yearIndex = (Integer)(year - contract.Current_Year__c);

            CventMyd_QuoteLineObject quoteLineObject = new CventMyd_QuoteLineObject();

            quoteLineObject.legacySubscriptionUpdated = (subscription.jsonString__c != null);

            quoteLineObject.qleId = (nextYearQleId != null) ? nextYearQleId : CventMyd_UtilityMethods.getQleId();

            quoteLineObject.requiredBySubscriptionIdString = subscription.SBQQ__RequiredById__c;

            List<Map<String,List<String>>> fieldValueMaps = new List<Map<String,List<String>>>();

            for(List<String> fieldValueMapFieldNameList : fieldValueMapFieldNameLists) {

                Map<String,List<String>> fieldValueMap = new Map<String,List<String>>();

                Integer fieldMapIndex = fieldValueMapFieldNameLists.indexOf(fieldValueMapFieldNameList);

                Map<String,List<String>> jsonFieldNameToSubscriptionFieldNames = quoteLineToSubscriptionFieldMaps[fieldMapIndex];

                for(String jsonFieldName : fieldValueMapFieldNameList) {

                    fieldValueMap.put(jsonFieldName,new List<String>());

                    if(jsonFieldName == 'SBQQ__ProrateMultiplier__c') {

                        Date startDate = Date.valueOf(fieldValueMaps[0].get('SBQQ__StartDate__c')[0]);

                        Date endDate = Date.valueOf(fieldValueMaps[0].get('SBQQ__EndDate__c')[0]);

                        Decimal prorateMultiplierFromDates = getProrateMultiplier(startDate,endDate);                        

                        if(!inCurrentYear) {

                            fieldValueMap.get('SBQQ__ProrateMultiplier__c').add(String.valueOf(prorateMultiplierFromDates));

                        }

                        else if(inCurrentYear) {

                            if(subscription.SBQQ__ProrateMultiplier__c != null) {

                                fieldValueMap.get('SBQQ__ProrateMultiplier__c').add(String.valueOf(subscription.SBQQ__ProrateMultiplier__c));

                            }

                            else {

                                fieldValueMap.get('SBQQ__ProrateMultiplier__c').add(String.valueOf(prorateMultiplierFromDates));

                            }

                            if(!inFinalYear) {

                                startDate = Date.valueOf(fieldValueMaps[0].get('SBQQ__StartDate__c')[1]);

                                endDate = Date.valueOf(fieldValueMaps[0].get('SBQQ__EndDate__c')[1]);

                                Decimal prorateMultiplier = getProrateMultiplier(startDate,endDate);  

                                fieldValueMap.get('SBQQ__ProrateMultiplier__c').add(String.valueOf(prorateMultiplier));

                            }

                        }

                    }

                    else if(jsonFieldNameToSubscriptionFieldNames.containsKey(jsonFieldName)) {

                        String currentYearFieldName = jsonFieldNameToSubscriptionFieldNames.get(jsonFieldName)[0];

                        String currentYearFieldValue = (subscription.get(currentYearFieldName) != null) ? String.valueOf(subscription.get(currentYearFieldName)).substringBefore(' 00:00:00') : null;

                        currentYearFieldValue = (jsonFieldName == 'SBQQ__Quantity__c') ? String.valueOf(getCurrentYearQuantity(subscription)) : currentYearFieldValue ;

                        String thisYearFieldName = jsonFieldNameToSubscriptionFieldNames.get(jsonFieldName)[yearIndex];

                        String thisYearFieldValue = (subscription.get(thisYearFieldName) != null) ? String.valueOf(subscription.get(thisYearFieldName)).substringBefore(' 00:00:00') : null;

                        thisYearFieldValue = (thisYearFieldValue != null) ? thisYearFieldValue : searchForFieldValue(year,currentYearFieldValue,jsonFieldName,thisYearFieldValue,outyearMap);

                        fieldValueMap.get(jsonFieldName).add(thisYearFieldValue);                       

                        if(inCurrentYear && !inFinalYear) {

                            String nextYearFieldName = jsonFieldNameToSubscriptionFieldNames.get(jsonFieldName)[yearIndex + 1];

                            String nextYearFieldValue = (subscription.get(nextYearFieldName) != null) ? String.valueOf(subscription.get(nextYearFieldName)).substringBefore(' 00:00:00') : null;

                            nextYearFieldValue = searchForFieldValue(year + 1,currentYearFieldValue,jsonFieldName,nextYearFieldValue,outyearMap);

                            fieldValueMap.get(jsonFieldName).add(nextYearFieldValue);                        

                        }

                    }

                    else if(!jsonFieldNameToSubscriptionFieldNames.containsKey(jsonFieldName)) {

                        fieldValueMap.get(jsonFieldName).add(null);

                        if(inCurrentYear && !inFinalYear) {fieldValueMap.get(jsonFieldName).add(null);}                        

                    }

                }

                fieldValueMaps.add(fieldValueMap);

            }

            quoteLineObject.preCalculationFieldValueMap = fieldValueMaps[0];

            quoteLineObject.calculatedFieldValueMap = fieldValueMaps[1];  

            quoteLineObject.insertOnNextCurrentYear = false;

            quoteLineObject.contractedFieldValueMap = new Map<String,String>();

            Decimal thisYearQuantity = Decimal.valueOf(quoteLineObject.preCalculationFieldValueMap.get('SBQQ__Quantity__c')[0]);

            Decimal nextYearQuantity = (inCurrentYear && !inFinalYear) ? Decimal.valueOf(quoteLineObject.preCalculationFieldValueMap.get('SBQQ__Quantity__c')[1]) : 0 ;

            Boolean isOnNextYear = (nextYearQuantity != 0);

            if(thisYearQuantity != 0 || inCurrentYear) {

                quoteLineObject.nextYearQleId = (inCurrentYear && isOnNextYear) ? CventMyd_UtilityMethods.getQleId() : null ;

                quoteLineObject.deleteThisLine = (inCurrentYear && quoteLineObject.nextYearQleId == null && !isAmendment);

                nextYearQleId = quoteLineObject.nextYearQleId;            

                yearToQuoteLineObject.put(year,quoteLineObject);

                allQleIds.add(quoteLineObject.qleId);

            }

        }

        for(Integer year : yearToQuoteLineObject.keySet()) {

            CventMyd_QuoteLineObject quoteLineObject = yearToQuoteLineObject.get(year);

            quoteLineObject.clonedFromQleIds = allQleIds;

            Integer thisQleIndex = quoteLineObject.clonedFromQleIds.indexOf(quoteLineObject.qleId);

            yearToQuoteLineObject.put(year,quoteLineObject);

        }

        return yearToQuoteLineObject;        

    }

    public static void createOutyearsFromLegacySubscriptions(Map<Id,List<Integer>> quoteIdToOutyears) {

        List<SBQQ__QuoteLineGroup__c> outyearGroups = CventMyd_LineAndGroupHandler.getMydQuoteLineGroups(quoteIdToOutyears,false);

        if(outyearGroups.size() > 0) {

            insert outyearGroups; 

            for(SBQQ__QuoteLineGroup__c qlg : outyearGroups) {

                if(qlg.Id != null) {

                    CventMyd_LineAndGroupHandler.GroupWrapper groupWrapper = new CventMyd_LineAndGroupHandler.GroupWrapper(qlg);

                    CventMyd_LineAndGroupHandler.quoteIdToQuoteWrapper.get(qlg.SBQQ__Quote__c).yearToGroupWrapper.put((Integer)qlg.term__c,groupWrapper);

                    Id quoteId = qlg.SBQQ__Quote__c;

                }

            }

            for(Id quoteId : quoteIdToOutyears.keySet()) {

                List<Integer> outyears = quoteIdToOutyears.get(quoteId);

                if(CventMyd_LineAndGroupHandler.quoteIdToQuoteWrapper.get(quoteId) != null) {

                    CventMyd_LineAndGroupHandler.QuoteWrapper quoteWrapper = CventMyd_LineAndGroupHandler.quoteIdToQuoteWrapper.get(quoteId);

                    SBQQ__Quote__c quote = quoteWrapper.quote;

                    CventMyd_LineAndGroupHandler.GroupWrapper currentYearGroupWrapper = quoteWrapper.yearToGroupWrapper.get((Integer)quote.Current_Year__c);

                    List<CventMyd_LineAndGroupHandler.QuoteLineWrapper> quoteLineWrappers = getOrderedQuoteLineWrappers(currentYearGroupWrapper.qleIdToQuoteLineWrapper.values());

                    for(Integer year : outyears) {

                        CventMyd_LineAndGroupHandler.GroupWrapper outyearGroupWrapper = quoteWrapper.yearToGroupWrapper.get(year);

                        for(CventMyd_LineAndGroupHandler.QuoteLineWrapper qlw : quoteLineWrappers) {

                            SBQQ__QuoteLine__c currentYearQuoteLine = qlw.quoteLine;

                            Id subscriptionId = (quote.SBQQ__Type__c == 'Amendment') ? currentYearQuoteLine.SBQQ__UpgradedSubscription__c : currentYearQuoteLine.SBQQ__RenewedSubscription__c;

                            Map<Integer,CventMyd_QuoteLineObject> yearToQuoteLineObject = subscriptionIdToYearToQuoteLineObject.get(subscriptionId);

                            if(yearToQuoteLineObject.containsKey(year) && year != quote.Current_Year__c) {

                                CventMyd_QuoteLineObject quoteLineObject = yearToQuoteLineObject.get(year);

                                String qleId = quoteLineObject.qleId;

                                if(!outyearGroupWrapper.qleIdToQuoteLineWrapper.containsKey(quoteLineObject.qleId)) {

                                    SBQQ__QuoteLine__c outyearLine = currentYearQuoteLine.clone(false,true,false,false);

                                    System.debug('outyearLine: ' + outyearLine);

                                    outyearLine.legacySubscription__c = subscriptionId;

                                    outyearLine.SBQQ__UpgradedSubscription__c = null;

                                    outyearLine.SBQQ__RenewedSubscription__c = null;                                   

                                    quoteWrapper.highestUnhiddenLineNumber = (outyearLine.SBQQ__Number__c < 3000) ? quoteWrapper.highestUnhiddenLineNumber + 1 : quoteWrapper.highestUnhiddenLineNumber;

                                    quoteWrapper.highestHiddenLineNumber = (outyearLine.SBQQ__Number__c >= 3000) ? quoteWrapper.highestHiddenLineNumber + 1 : quoteWrapper.highestHiddenLineNumber;                 

                                    outyearLine.SBQQ__Number__c = (outyearLine.SBQQ__Number__c < 3000) ? quoteWrapper.highestUnhiddenLineNumber : quoteWrapper.highestHiddenLineNumber;

                                    outyearLine.jsonString__c = JSON.serialize(quoteLineObject);

                                    outyearLine.SBQQ__Quote__c = null;

                                    CventMyd_LineAndGroupHandler.QuoteLineWrapper quoteLineWrapper = new CventMyd_LineAndGroupHandler.QuoteLineWrapper(outyearLine,quoteId);

                                    quoteLineWrapper.quoteFieldSet = false;

                                    CventMyd_LineAndGroupHandler.quoteIdToQuoteWrapper.put(quote.Id,quoteWrapper);

                                    CventMyd_LineAndGroupHandler.quoteIdToQuoteWrapper.get(quoteId).yearToGroupWrapper.get(year).qleIdToQuoteLineWrapper.put(qleId,quoteLineWrapper);                        

                                }

                            }

                        }

                    }

                }

            }

            CventMyd_LineAndGroupHandler.insertClonedOutyearLines(CventMyd_LineAndGroupHandler.quoteIdToQuoteWrapper);

        }

    }

    public static List<SBQQ__QuoteLine__c> getQuoteLinesToDeleteOnIntratermRenewal(List<SBQQ__QuoteLine__c> quoteLines) {

        List<SBQQ__QuoteLine__c> quoteLinesToDelete = new List<SBQQ__QuoteLine__c>();

        for(SBQQ__QuoteLine__c quoteLine : quoteLines) {

            CventMyd_QuoteLineObject quoteLineObject = CventMyd_UtilityMethods.getQuoteLineObject(quoteLine);

            SBQQ__Quote__c quote = quoteLine.SBQQ__Quote__r;

            if(quote.createdFromLegacyContract__c && quoteLineObject.deleteThisLine) {

                Integer expectedNumberOfQuoteLineGroups = CventMyd_UtilityMethods.getExpectedNumberOfQuoteLineGroups(quote);

                if(expectedNumberOfQuoteLineGroups == quote.numberOfQuoteLineGroups__c) {

                    quoteLinesToDelete.add(quoteLine);

                }

            }

        }

        return quoteLinesToDelete;

    }

    public static String searchForFieldValue(Integer year, String currentYearFieldValue, String jsonFieldName, String thisFieldValue, Map<Integer,CventMyd_Outyear> outyearMap) {      

        thisFieldValue = (jsonFieldName == 'SBQQ__StartDate__c' && thisFieldValue == null) ? String.valueOf(outyearMap.get(year).startDate) : thisFieldValue;

        thisFieldValue = (jsonFieldName == 'SBQQ__EndDate__c' && thisFieldValue == null) ? String.valueOf(outyearMap.get(year).endDate) : thisFieldValue;

        thisFieldValue = (thisFieldValue == null) ? currentYearFieldValue : thisFieldValue;

        thisFieldValue = (thisFieldValue == null && currentYearFieldValue != null) ? String.valueOf(currentYearFieldValue).substringBefore(' 00:00:00') : thisFieldValue;

        return thisFieldValue; 

    }

    public static Decimal getProrateMultiplier(Date startDate, Date endDate) {

        Decimal daysDifference = Decimal.valueOf(startDate.daysBetween(endDate));

        daysDifference++;

        daysDifference = ( Date.isLeapYear(endDate.year()) && (endDate.month() > 2 || endDate.month() == 2 && endDate.day() == 29)) ? daysDifference - 1 : daysDifference;

        Decimal multiplier = daysDifference.divide(365,8);

        return multiplier;

    }    

    public class QuoteLineWrapperReorderingException extends Exception {}

    public static List<CventMyd_LineAndGroupHandler.QuoteLineWrapper> getOrderedQuoteLineWrappers (List<CventMyd_LineAndGroupHandler.QuoteLineWrapper> quoteLineWrappers) {

        List<CventMyd_LineAndGroupHandler.QuoteLineWrapper> reorderedQuoteLineWrappers = new List<CventMyd_LineAndGroupHandler.QuoteLineWrapper>();

        Set<Integer> lineNumbers = new Set<Integer>();

        for(CventMyd_LineAndGroupHandler.QuoteLineWrapper qlw : quoteLineWrappers) {

            Integer lineNumber = (Integer)qlw.quoteLine.SBQQ__Number__c;

            if(lineNumbers.contains(lineNumber)) {

                while(lineNumbers.contains(lineNumber)){

                    lineNumber++;

                }

            }

            qlw.quoteLine.SBQQ__Number__c = lineNumber;

            lineNumbers.add(lineNumber);

        }

        Map<Integer,Integer> lineNumberToIndex = new Map<Integer,Integer>();

        for(CventMyd_LineAndGroupHandler.QuoteLineWrapper qlw : quoteLineWrappers) {

            Integer lineNumber = (Integer)qlw.quoteLine.SBQQ__Number__c;

            Integer index = quoteLineWrappers.indexOf(qlw);

            lineNumberToIndex.put(lineNumber,index);

        }

        List<Integer> sortedNumbers = new List<Integer>(lineNumberToIndex.keySet());

        sortedNumbers.sort();

        for(Integer lineNumber : sortedNumbers) {

            Integer index = lineNumberToIndex.get(lineNumber);

            CventMyd_LineAndGroupHandler.QuoteLineWrapper qlw = quoteLineWrappers[index];

            reorderedQuoteLineWrappers.add(qlw);

        }

        if(reorderedQuoteLineWrappers.size() == quoteLineWrappers.size()) {

            for(CventMyd_LineAndGroupHandler.QuoteLineWrapper qlw : reorderedQuoteLineWrappers) {

            }

            return reorderedQuoteLineWrappers;

        }

        else if(reorderedQuoteLineWrappers.size() != quoteLineWrappers.size()) {

            throw new QuoteLineWrapperReorderingException('1 or more quote line wrapper(s) were lost when reordering');

        }

        return null;

    }

    public static Date getEndDateForQuoteCreatedFromLegacyContract(SBQQ__Quote__c quote, Contract childContract) {

        Contract parentContract = childContract.Parent_Contract__r;

        String childContractEndDateName = CventMyd_UtilityMethods.getYearToEndDateFieldName((SObject)childContract).get((Integer)quote.Current_Year__c);

        String parentContractEndDateFieldName = CventMyd_UtilityMethods.getYearToEndDateFieldName((SObject)parentContract).get((Integer)quote.Current_Year__c);

        Date endDate = (childContract.Upcoming_Renewal_Type__c == 'MYD Renewal') ? Date.valueOf(childContract.get(childContractEndDateName)) : null;

        endDate = (endDate == null && childContract.Upcoming_Renewal_Type__c == 'MYD Renewal') ? Date.valueOf(childContract.get(parentContractEndDateFieldName)) : endDate;

        if(endDate == null) {

            endDate = quote.SBQQ__StartDate__c.addMonths(12);

            endDate = endDate.addDays(-1);

        }

        return endDate;

    }

    public static Decimal getCurrentYearQuantity(SBQQ__Subscription__c subscription) {

        Decimal currentYearQuantity = 0.00;

        if(subscription.SBQQ__RevisedSubscription__c == null) {

            currentYearQuantity = subscription.SBQQ__Quantity__c;

            for(SBQQ__Subscription__c revisedSubscription : subscription.SBQQ__Revisions__r) {

                currentYearQuantity += revisedSubscription.SBQQ__Quantity__c;

            }

        }

        return currentYearQuantity;

    }

    public static Integer getExpectedQuoteLineCount(List<SBQQ__Subscription__c> subscriptions, String quoteType) {

        Integer expectedQuoteLineCount = 0;

        if(subscriptions != null) {

            Map<Id,SBQQ__Subscription__c> subscriptionIdToSubscription = new Map<Id,SBQQ__Subscription__c>(subscriptions);

            expectedQuoteLineCount = subscriptions.size();

            for(SBQQ__Subscription__c subscription : subscriptions) {

                SBQQ__Subscription__c bundleSubscription;

                if(subscription.SBQQ__RequiredById__c != null) {

                    Id requiredById = Id.valueOf(subscription.SBQQ__RequiredById__c);

                    bundleSubscription = subscriptionIdToSubscription.get(requiredById);

                }

                if(!willSubscriptionCreateQuoteLine(subscription,bundleSubscription,quoteType)) {

                    expectedQuoteLineCount--;

                }

            }

        }

        return expectedQuoteLineCount;

    }

    public static Boolean willSubscriptionCreateQuoteLine(SBQQ__Subscription__c subscription, SBQQ__Subscription__c requiredBySubscription, String quoteType) {

        Boolean terminatedOrZeroed = isTerminatedOrZeroed(subscription,quoteType);

        Boolean decomissioned = isSubscriptionDecomissioned(subscription);

        Boolean bundleTerminatedOrZeroed = isTerminatedOrZeroed(requiredBySubscription,quoteType);

        Boolean bundleDecomissioned = isSubscriptionDecomissioned(requiredBySubscription);

        Boolean returnResult = !(terminatedOrZeroed || decomissioned || bundleTerminatedOrZeroed || bundleDecomissioned);

        return returnResult;

    }

    public static Boolean isTerminatedOrZeroed(SBQQ__Subscription__c subscription, String quoteType) {

        if(subscription != null) {

            Boolean isTerminated = (subscription.SBQQ__TerminatedDate__c != null);

            Boolean isZeroed = (quoteType == 'Amendment') ? (subscription.SBQQ__Quantity__c == 0) : (subscription.SBQQ__RenewalQuantity__c == 0);

            return (isTerminated || isZeroed);

        }

        else {return false;}

    }

    public static Boolean isSubscriptionDecomissioned(SBQQ__Subscription__c subscription) {

        if(subscription != null) {

            Decimal currentYearQuantity = getCurrentYearQuantity(subscription);

            Boolean isDecomissioned = (currentYearQuantity == 0 && subscription.SBQQ__Revisions__r.size() > 0);

            return isDecomissioned;

        }

        else {return false;}

    }

    public static Decimal getRenewableLineCount(List<SBQQ__Subscription__c> subscriptions) {

        Decimal renewableProductCount = 0.00;

        if(subscriptions != null && subscriptions.size() > 0) {

            for(SBQQ__Subscription__c subscription  : subscriptions) {

                Contract contract = subscription.SBQQ__Contract__r;

                Boolean intratermRenewal = (contract.Upcoming_Renewal_Type__c == 'MYD Renewal');

                Boolean variableOptionsRenewal = (!intratermRenewal) ? false : contract.Multiple_Years_Commitment__c;

                Boolean productIsRenewable = (intratermRenewal) ? true : (subscription.SBQQ__Product__r.Revenue_Type__c != 'Non-Recurring');

                productIsRenewable = (subscription.SBQQ__Number__c >= 3000) ? false : productIsRenewable;

                Decimal nextYearQuantityToAdd;

                if(!variableOptionsRenewal) {

                    nextYearQuantityToAdd = getCurrentYearQuantity(subscription);

                    renewableProductCount += (productIsRenewable) ? nextYearQuantityToAdd : 0 ;

                }

                else {

                    Map<Integer,CventMyd_QuoteLineObject> yearToQuoteLineObject = subscriptionIdToYearToQuoteLineObject.get(subscription.Id);

                    Integer currentYear = (Integer)contract.Current_Year__c;

                    CventMyd_QuoteLineObject currentYearQuoteLineObject = yearToQuoteLineObject.get(currentYear);

                    if(currentYearQuoteLineObject != null) {

                        String nextYearQuantityString = currentYearQuoteLineObject.preCalculationFieldValueMap.get('SBQQ__Quantity__c')[1];

                        nextYearQuantityToAdd = Decimal.valueOf(nextYearQuantityString);

                        renewableProductCount += (productIsRenewable) ? nextYearQuantityToAdd : 0 ;

                    }

                }

            }

        }

        return renewableProductCount;

    }

    public static List<SBQQ__QuoteLine__c> getQuoteLinesToRenumber(List<SBQQ__QuoteLine__c> quoteLines) {

        Map<Id,SBQQ__QuoteLine__c> quoteLineIdToQuoteLine = new Map<Id,SBQQ__QuoteLine__c>(quoteLines);

        Map<Id,List<Id>> bundleIdToOptionIds = new Map<Id,List<Id>>();

        for(SBQQ__QuoteLine__c quoteLine : quoteLines) {

            if(quoteLine.SBQQ__RequiredBy__c != null && quoteLine.SBQQ__Number__c < 3000) {
            
                if(bundleIdToOptionIds.get(quoteLine.SBQQ__RequiredBy__c) == null) {
                
                    bundleIdToOptionIds.put(quoteLine.SBQQ__RequiredBy__c,new List<Id>());
                    
                }
                
                bundleIdToOptionIds.get(quoteLine.SBQQ__RequiredBy__c).add(quoteLine.Id);
                
            }
            
        }

        List<SBQQ__QuoteLine__c> renumberedLinesToUpdate = new List<SBQQ__QuoteLine__c>();

        Integer highestLineNumber = 0;

        for(SBQQ__QuoteLine__c quoteLine: quoteLines) {

            Set<Id> handledIds = (new Map<Id,SBQQ__QuoteLine__c>(renumberedLinesToUpdate)).keySet();

            Id quoteLineId = quoteLine.Id;
            
            if(quoteLine.SBQQ__Number__c < 3000 && !handledIds.contains(quoteLineId)) {

                highestLineNumber++;

                quoteLine.SBQQ__Number__c = highestLineNumber;

                renumberedLinesToUpdate.add(quoteLine);

                while(bundleIdToOptionIds.get(quoteLineId) != null) {

                    List<Id> optionIds = bundleIdToOptionIds.get(quoteLineId);

                    for(Id optionId : optionIds) {

                        SBQQ__QuoteLine__c optionLine = quoteLineIdToQuoteLine.get(optionId);

                        highestLineNumber++;

                        optionLine.SBQQ__Number__c = highestLineNumber;

                        renumberedLinesToUpdate.add(optionLine);

                        quoteLineId = optionLine.Id;

                        if(bundleIdToOptionIds.get(quoteLineId) != null) {

                            break;

                        }                        

                    }

                }
                
            }
            
        }

        return renumberedLinesToUpdate;

    }

}