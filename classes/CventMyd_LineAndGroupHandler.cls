public without sharing class CventMyd_LineAndGroupHandler {

    public static Map<Id,QuoteWrapper> quoteIdToQuoteWrapper = new Map<Id,QuoteWrapper>();

    public static Set<Id> quoteIdsQueriedForPreviousLines = new Set<Id>();

    public static Map<Id,Integer> groupIdToYear = new Map<Id,Integer>();

    public class QuoteWrapper {

        public SBQQ__Quote__c quote {get;set;}

        public SBQQ__Quote__c previousQuote {get;set;}

        public List<SBQQ__QuoteLine__c> previousQuoteLines {get;set;}

        public Map<Integer,GroupWrapper> yearToGroupWrapper {get;set;}

        public QuoteWrapper(SBQQ__Quote__c quote) {

            this.quote = quote;

            this.yearToGroupWrapper = new Map<Integer,GroupWrapper>();

            this.highestUnhiddenLineNumber = 0;

            this.highestHiddenLineNumber = 2999;            

        }

        public Integer highestHiddenLineNumber {get;set;}

        public Integer highestUnhiddenLineNumber {get;set;}

    }

    public class GroupWrapper {

        public SBQQ__QuoteLineGroup__c quoteLineGroup {get;set;}

        public Map<String,QuoteLineWrapper> qleIdToQuoteLineWrapper {get;set;}

        public GroupWrapper(SBQQ__QuoteLineGroup__c quoteLineGroup) {

            this.quoteLineGroup = quoteLineGroup;

            this.qleIdToQuoteLineWrapper = new Map<String,QuoteLineWrapper>();

        }

    }

    public class QuoteLineWrapper {

        public SBQQ__QuoteLine__c quoteLine {get;set;}

        public String requiredByQleId {get;set;}

        public Set<String> optionQleIds {get;set;}

        public Id newQuoteId {get;set;}

        public Boolean quoteFieldSet {get;set;}

        public QuoteLineWrapper(SBQQ__QuoteLine__c quoteLine, Id newQuoteId) {

            this.quoteLine = quoteLine;

            this.optionQleIds = new Set<String>();

            this.newQuoteId = newQuoteId;

            if(quoteLine.jsonString__c != null) {

                CventMyd_QuoteLineObject quoteLineObject = CventMyd_UtilityMethods.getQuoteLineObject(quoteLine);

                this.requiredByQleId = quoteLineObject.requiredByQleId;

            }          

        }

    }

    public static void groupCurrentYearQuoteLines(Set<Id> quoteIds) {

        Map<Id,List<Integer>> quoteIdToCurrentYear = new Map<Id,List<Integer>>();

        for(Id quoteId : quoteIds) {

            SBQQ__Quote__c quote = (SBQQ__Quote__c)Trigger.newMap.get(quoteId);

            if(!quoteIdToQuoteWrapper.containsKey(quoteId)) {quoteIdToQuoteWrapper.put(quoteId,new QuoteWrapper(quote));}

            quoteIdToQuoteWrapper.get(quoteId).quote = quote;

            if(quote.numberOfQuoteLineGroups__c == 0) {

                quoteIdToCurrentYear.put(quoteId,new List<Integer>{(Integer)quote.Current_Year__c});

            }

        }

        List<SBQQ__QuoteLineGroup__c> currentYearGroups = getMydQuoteLineGroups(quoteIdToCurrentYear,true);

        if(currentYearGroups.size() > 0) {

            insert currentYearGroups;

        }

        for(SBQQ__QuoteLineGroup__c qlg : currentYearGroups) {

            GroupWrapper groupWrapper = new GroupWrapper(qlg);

            quoteIdToQuoteWrapper.get(qlg.SBQQ__Quote__c).yearToGroupWrapper.put((Integer)qlg.term__c,groupWrapper);

        }

        Boolean needToGroupCurrentYearLines = false;

        for(Id quoteId : quoteIds) {

            QuoteWrapper quoteWrapper = quoteIdToQuoteWrapper.get(quoteId);

            SBQQ__Quote__c quote = (SBQQ__Quote__c)Trigger.newMap.get(quoteId);

            Integer handledCurrentYearLineCount = 0;

            Integer existingCurrentYearLineCount = (Integer)(quote.SBQQ__LineItemCount__c);

            for(GroupWrapper groupWrapper : quoteWrapper.yearToGroupWrapper.values()) {

                Integer year = (Integer)groupWrapper.quoteLineGroup.term__c;

                handledCurrentYearLineCount += (year == quote.Current_Year__c) ? groupWrapper.qleIdToQuoteLineWrapper.keySet().size() : 0;

                existingCurrentYearLineCount -= (year > quote.Current_Year__c) ? groupWrapper.qleIdToQuoteLineWrapper.keySet().size() : 0;

            }

            if(handledCurrentYearLineCount < existingCurrentYearLineCount) {

                needToGroupCurrentYearLines = true; break;

            }

        }

        if(needToGroupCurrentYearLines) {

            String queryString = 'SELECT Id,Name';

            queryString += ',' + CventMyd_Settings.fullQuoteLineFieldNamesString;

            queryString += ' FROM SBQQ__QuoteLine__c';

            queryString += ' WHERE SBQQ__Quote__c IN: quoteIds';

            queryString += ' AND SBQQ__Group__c = null';

            List<SBQQ__QuoteLine__c> ungroupedCurrentYearQuoteLines = Database.query(queryString);

            for(SBQQ__QuoteLine__c ql : ungroupedCurrentYearQuoteLines) {

                Integer currentYear = (Integer) ql.SBQQ__Quote__r.Current_Year__c;

                if(ql.jsonString__c != null) {

                    CventMyd_QuoteLineObject quoteLineObject = CventMyd_UtilityMethods.getQuoteLineObject(ql);

                    String qleId = quoteLineObject.qleId;

                    String nextYearQleId = quoteLineObject.nextYearQleId; 

                    if(nextYearQleId != null && !ql.SBQQ__Quote__r.createdFromLegacyContract__c && ql.SBQQ__Quote__r.SBQQ__Type__c == 'Renewal') {
                        
                        ql.jsonString__c = ql.jsonString__c.replace(qleId,nextYearQleId);
                        
                    }

                }

                ql.SBQQ__Group__c = quoteIdToQuoteWrapper.get(ql.SBQQ__Quote__c).yearToGroupWrapper.get(currentYear).quoteLineGroup.Id;

            }

            update ungroupedCurrentYearQuoteLines;

            List<SBQQ__QuoteLine__c> nowGroupedCurrentYearQuoteLines = ungroupedCurrentYearQuoteLines;

            for(SBQQ__QuoteLine__c ql : nowGroupedCurrentYearQuoteLines) {

                QuoteWrapper quoteWrapper = quoteIdToQuoteWrapper.get(ql.SBQQ__Quote__c);

                QuoteLineWrapper quoteLineWrapper = new QuoteLineWrapper(ql,ql.SBQQ__Quote__c);

                quoteLineWrapper.quoteFieldSet = true;

                String qleId;

                quoteWrapper.highestUnhiddenLineNumber = (ql.SBQQ__Number__c < 3000 && ql.SBQQ__Number__c > quoteWrapper.highestUnhiddenLineNumber) ? (Integer)ql.SBQQ__Number__c : quoteWrapper.highestUnhiddenLineNumber;

                quoteWrapper.highestHiddenLineNumber = (ql.SBQQ__Number__c >= 3000 && ql.SBQQ__Number__c > quoteWrapper.highestHiddenLineNumber) ? (Integer)ql.SBQQ__Number__c : quoteWrapper.highestHiddenLineNumber;            

                if(ql.jsonString__c != null) {

                    CventMyd_QuoteLineObject quoteLineObject = CventMyd_UtilityMethods.getQuoteLineObject(ql);

                    qleId = quoteLineObject.qleId;

                    String nextYearQleId = quoteLineObject.nextYearQleId;

                }

                GroupWrapper groupWrapper = quoteIdToQuoteWrapper.get(ql.SBQQ__Quote__c).yearToGroupWrapper.get((Integer)ql.term__c);

                quoteIdToQuoteWrapper.put(ql.SBQQ__Quote__c,quoteWrapper);

                quoteIdToQuoteWrapper.get(ql.SBQQ__Quote__c).yearToGroupWrapper.get((Integer)ql.term__c).qleIdToQuoteLineWrapper.put(qleId,quoteLineWrapper);

                groupWrapper = quoteIdToQuoteWrapper.get(ql.SBQQ__Quote__c).yearToGroupWrapper.get((Integer)ql.term__c);                

            }

        }

    }

    public static List<SBQQ__QuoteLineGroup__c> getMydQuoteLineGroups(Map<Id,List<Integer>> quoteIdToOutyears, Boolean getCurrentYearGroup) {

        List<SBQQ__QuoteLineGroup__c> quoteLineGroups = new List<SBQQ__QuoteLineGroup__c>();

        for(Id quoteId : quoteIdToOutyears.keySet()) {

            SBQQ__Quote__c quote = (Trigger.isExecuting && (SBQQ__Quote__c)Trigger.newMap.get(quoteId) != null) ? ((SBQQ__Quote__c)Trigger.newMap.get(quoteId)) : quoteIdToQuoteWrapper.get(quoteId).quote;

            CventMyd_QuoteObject quoteObject = CventMyd_UtilityMethods.getQuoteObject(quote);

            QuoteWrapper quoteWrapper = quoteIdToQuoteWrapper.get(quoteId);

            if(quoteWrapper != null) {

                for(Integer year : quoteIdToOutyears.get(quoteId)) {

                    Boolean groupAlreadyCreated = quoteWrapper.yearToGroupWrapper.containsKey(year);

                    Integer maxNumberOfQuoteLineGroups = (Integer.valueOf(quote.Contract_Term_Years__c) - (Integer)quote.Current_Year__c) + 1;

                    if(!groupAlreadyCreated && (quote.numberOfQuoteLineGroups__c < maxNumberOfQuoteLineGroups) && (year > quote.Current_Year__c || getCurrentYearGroup) ) {

                        CventMyd_QuoteLineGroupObject quoteLineGroupObject = new CventMyd_QuoteLineGroupObject();

                        quoteLineGroupObject.startDate = (year == quote.Current_Year__c) ? quote.SBQQ__StartDate__c : quoteObject.outyearMap.get(year).startDate;

                        quoteLineGroupObject.endDate = (year == quote.Current_Year__c) ? quote.SBQQ__EndDate__c : quoteObject.outyearMap.get(year).endDate;

                        quoteLineGroupObject.qleId = CventMyd_UtilityMethods.getQleId();

                        quoteLineGroupObject.clonedFromQleId = null;

                        quoteLineGroupObject.insertedWithApex = true;

                        String groupName = 'Year ' + String.valueOf(year) + ( (year==(Integer)quote.Current_Year__c) ? ' (Current Year)' : '');

                        SBQQ__QuoteLineGroup__c quoteLineGroup = new SBQQ__QuoteLineGroup__c(

                            Name = groupName,

                            SBQQ__Number__c = (year - (Integer)quote.Current_Year__c) + 1,

                            term__c = year,

                            SBQQ__Optional__c = (year > (Integer)quote.Current_Year__c) ? true : false,

                            groupType__c = 'Variable MYD Group',

                            SBQQ__Quote__c = quote.Id,

                            jsonString__c = JSON.serialize(quoteLineGroupObject)

                        );

                        quoteLineGroups.add(quoteLineGroup);                 

                        GroupWrapper groupWrapper = new GroupWrapper(quoteLineGroup);                    

                        quoteIdToQuoteWrapper.get(quoteLineGroup.SBQQ__Quote__c).yearToGroupWrapper.put((Integer)quoteLineGroup.term__c,groupWrapper);                

                    }

                }

            }

        }

        return quoteLineGroups;      

    }

    public static void createOutyearsFromPreviousQuote(Map<Id,List<Integer>> quoteIdToOutyears) {

        List<SBQQ__QuoteLineGroup__c> outyearGroups = getMydQuoteLineGroups(quoteIdToOutyears,false);

        if(outyearGroups.size() > 0) {

            insert outyearGroups;   

            for(SBQQ__QuoteLineGroup__c qlg : outyearGroups) {

                if(qlg.Id != null) {

                    GroupWrapper groupWrapper = new GroupWrapper(qlg);

                    quoteIdToQuoteWrapper.get(qlg.SBQQ__Quote__c).yearToGroupWrapper.put((Integer)qlg.term__c,groupWrapper);

                    Id quoteId = qlg.SBQQ__Quote__c;

                    groupIdToYear.put(qlg.Id,(Integer)qlg.term__c);

                }

            }

        }

        Map<Id,Id> quoteIdToPreviousQuoteId = new Map<Id,Id>();

        for(Id quoteId : quoteIdToQuoteWrapper.keySet()) {

            QuoteWrapper quoteWrapper = quoteIdToQuoteWrapper.get(quoteId);

            SBQQ__Quote__c quote = quoteWrapper.quote;

            if(quoteWrapper.previousQuote == null && quote.previousQuote__c != null && !quoteIdsQueriedForPreviousLines.contains(quote.Id)) {

                quoteIdToPreviousQuoteId.put(quote.Id,quoteWrapper.quote.previousQuote__c);

                quoteIdsQueriedForPreviousLines.add(quote.Id);

            }

        }

        if(!quoteIdToPreviousQuoteId.keySet().isEmpty()) {

            List<Id> previousQuoteIdsToQuery = quoteIdToPreviousQuoteId.values();

            Map<Id,Id> parallelLineIdToNewQuoteId = new Map<Id,Id>();

            if(Trigger.newMap != null) {

                System.debug('in quote trigger, checking for parallel line ids from previous quote');

                System.debug('quoteIdToPreviousQuoteId.keySet(): ' + quoteIdToPreviousQuoteId.keySet());

                for(Id quoteId : quoteIdToPreviousQuoteId.keySet()) {

                    System.debug('quote id: ' + quoteId);

                    System.debug('previous quote id: ' + quoteIdToPreviousQuoteId.get(quoteId));

                    SBQQ__Quote__c quote = (SBQQ__Quote__c)Trigger.newMap.get(quoteId);

                    System.debug('quote: ' + quote);

                    System.debug('CventMyd_QuoteTriggerHandler.quoteInsertionIdToParallelLineIds: ' + CventMyd_QuoteTriggerHandler.quoteInsertionIdToParallelLineIds);

                    if(quote != null) {

                        CventMyd_QuoteObject quoteObject = CventMyd_UtilityMethods.getQuoteObject(quote);

                        String insertionId = quoteObject.insertionId;

                        if(CventMyd_QuoteTriggerHandler.quoteInsertionIdToParallelLineIds.get(insertionId) != null) {

                            for(String idString : CventMyd_QuoteTriggerHandler.quoteInsertionIdToParallelLineIds.get(insertionId).split(';')) {

                                Id parallelLineId = Id.valueOf(idString);
                                
                                parallelLineIdToNewQuoteId.put(parallelLineId,quoteId);

                                System.debug('adding parallel line id: ' + parallelLineId);

                                System.debug('to new quote with id : ' + quoteId);

                            }

                        }   

                    }

                }

            }

            System.debug('parallelLineIdToNewQuoteId.keySet(): ' + parallelLineIdToNewQuoteId.keySet());

            String queryString = 'SELECT Id,Name,';

            queryString += CventMyd_Settings.fullQuoteLineFieldNamesString;

            Set<Id> lineIds = parallelLineIdToNewQuoteId.keySet();       

            Set<String> quoteFieldNames = new Set<String> {

                'SBQQ__Quote__r.Id',

                'SBQQ__Quote__r.nextQuote__c'

            };

            queryString += ',' + CventMyd_UtilityMethods.getFieldNamesStringFromStringSet(quoteFieldNames);

            queryString += ' FROM SBQQ__QuoteLine__c';

            queryString += ' WHERE SBQQ__Quote__c IN: previousQuoteIdsToQuery OR Id IN: lineIds';

            queryString += ' ORDER BY SBQQ__Number__c ASC';

            for(SBQQ__QuoteLine__c previousQuoteLine : Database.query(queryString)) {

                if(!parallelLineIdToNewQuoteId.containsKey(previousQuoteLine.Id)) {

                    SBQQ__Quote__c previousQuote = previousQuoteLine.SBQQ__Quote__r;

                    Id newQuoteId = previousQuote.nextQuote__c;

                    quoteIdToQuoteWrapper.get(newQuoteId).previousQuote = previousQuote;

                    if(quoteIdToQuoteWrapper.get(newQuoteId).previousQuoteLines == null) {

                        quoteIdToQuoteWrapper.get(newQuoteId).previousQuoteLines = new List<SBQQ__QuoteLine__c>();

                    }

                    quoteIdToQuoteWrapper.get(newQuoteId).previousQuoteLines.add(previousQuoteLine);

                }

                else if(parallelLineIdToNewQuoteId.containsKey(previousQuoteLine.Id)) {

                    Id newQuoteId = parallelLineIdToNewQuoteId.get(previousQuoteLine.Id);

                    if(quoteIdToQuoteWrapper.get(newQuoteId).previousQuoteLines == null) {

                        quoteIdToQuoteWrapper.get(newQuoteId).previousQuoteLines = new List<SBQQ__QuoteLine__c>();

                    }

                    System.debug('adding parallel outyear line: ' + previousQuoteLine.Id);

                    CventMyd_QuoteLineObject quoteLineObject = CventMyd_UtilityMethods.getQuoteLineObject(previousQuoteLine);

                    quoteLineObject.parallelLineAddition = true;

                    previousQuoteLine.jsonString__c = JSON.serialize(quoteLineObject);

                    System.debug('json string: ' + previousQuoteLine.jsonString__c);

                    quoteIdToQuoteWrapper.get(newQuoteId).previousQuoteLines.add(previousQuoteLine);

                }

            }

        }

        for(Id quoteId : quoteIdToOutyears.keySet()) {

            if(quoteIdToQuoteWrapper.get(quoteId) != null) {

                SBQQ__Quote__c quote = quoteIdToQuoteWrapper.get(quoteId).quote;

                SBQQ__Quote__c previousQuote = quoteIdToQuoteWrapper.get(quoteId).previousQuote;

                List<SBQQ__QuoteLine__c> previousQuoteLines = quoteIdToQuoteWrapper.get(quoteId).previousQuoteLines;

                for(SBQQ__QuoteLine__c ql : previousQuoteLines) {

                    CventMyd_QuoteLineObject quoteLineObject = (CventMyd_QuoteLineObject)JSON.deserialize(ql.jsonString__c,CventMyd_QuoteLineObject.class);

                    String qleId = quoteLineObject.qleId;

                    Boolean lineIsZeroedOnAmendment = (previousQuote.SBQQ__Type__c == 'Amendment' && ql.SBQQ__Quantity__c == 0);

                    Boolean lineIsWithinYearList = quoteIdToOutyears.get(quoteId).contains((Integer)ql.term__c);

                    Boolean lineIsOnNextCurrentYear = (ql.term__c == previousQuote.Current_Year__c + 1);

                    Boolean insertLineOnNextCurrentYear = quoteLineObject.insertOnNextCurrentYear && lineIsOnNextCurrentYear && quote.SBQQ__Type__c == 'Renewal';

                    QuoteWrapper quoteWrapper = quoteIdToQuoteWrapper.get(previousQuote.nextQuote__c);

                    GroupWrapper groupWrapper = quoteWrapper.yearToGroupWrapper.get((Integer)ql.term__c);

                    Boolean lineAlreadyHandled = (groupWrapper != null && groupWrapper.qleIdToQuoteLineWrapper.get(qleId) != null) ? true: false;

                    if(!lineAlreadyHandled && !lineIsZeroedOnAmendment && lineIsWithinYearList && (quote.SBQQ__Type__c == 'Amendment' || insertLineOnNextCurrentYear || !lineIsOnNextCurrentYear)) {

                        QuoteLineWrapper quoteLineWrapper = new QuoteLineWrapper(ql,previousQuote.nextQuote__c);

                        quoteLineWrapper.quoteFieldSet = false;

                        quoteIdToQuoteWrapper.get(quoteId).yearToGroupWrapper.get((Integer)ql.term__c).qleIdToQuoteLineWrapper.put(qleId,quoteLineWrapper);

                    }

                }

            }

        }

        insertClonedOutyearLines(quoteIdToQuoteWrapper);

    }

    public static void insertClonedOutyearLines(Map<Id,QuoteWrapper> quoteIdToQuoteWrapper) {

        List<SBQQ__QuoteLine__c> newOutyearQuoteLines = new List<SBQQ__QuoteLine__c>();

        for(QuoteWrapper quoteWrapper : quoteIdToQuoteWrapper.values()) {

            for(GroupWrapper groupWrapper : quoteWrapper.yearToGroupWrapper.values()) {

                for(String qleId : groupWrapper.qleIdToQuoteLineWrapper.keySet()) {

                    QuoteLineWrapper quoteLineWrapper = groupWrapper.qleIdToQuoteLineWrapper.get(qleId);

                    if(quoteLineWrapper.requiredByQleId != null) {

                        if(groupWrapper.qleIdToQuoteLineWrapper.get(quoteLineWrapper.requiredByQleId) != null) {

                            groupWrapper.qleIdToQuoteLineWrapper.get(quoteLineWrapper.requiredByQleId).optionQleIds.add(qleId);

                        }

                    }

                    if(groupWrapper.quoteLineGroup.Id != null && quoteLineWrapper.quoteLine.SBQQ__Quote__c != quoteLineWrapper.newQuoteId && !quoteLineWrapper.quoteFieldSet) {

                        SBQQ__QuoteLine__c quoteLineToClone = quoteLineWrapper.quoteLine;

                        SBQQ__QuoteLine__c newOutyearQuoteLine = quoteLineToClone.clone(false,true,false,false);

                        newOutyearQuoteLine.SBQQ__UpgradedSubscription__c = null;

                        newOutyearQuoteLine.SBQQ__RenewedSubscription__c = null;

                        CventMyd_QuoteLineObject lineObject = CventMyd_UtilityMethods.getQuoteLineObject(newOutyearQuoteLine);

                        System.debug('lineObject.parallelLineAddition: ' + lineObject.parallelLineAddition);

                        newOutyearQuoteLine.SBQQ__Quote__c = quoteWrapper.quote.Id;

                        Integer currentYear = (Integer)quoteWrapper.quote.Current_Year__c;

                        Integer groupYear = (Integer)groupWrapper.quoteLineGroup.term__c;

                        newOutyearQuoteLine.SBQQ__Optional__c = (groupYear > currentYear);

                        newOutyearQuoteLine.SBQQ__Group__c = groupWrapper.quoteLineGroup.Id;

                        newOutyearQuoteLine.SBQQ__Quantity__c = 0;

                        newOutyearQuoteLines.add(newOutyearQuoteLine);

                        groupIdToYear.put(groupWrapper.quoteLineGroup.Id,(Integer)groupWrapper.quoteLineGroup.term__c);

                        quoteLineWrapper.quoteFieldSet = true;

                        quoteIdToQuoteWrapper.get(newOutyearQuoteLine.SBQQ__Quote__c).yearToGroupWrapper.get((Integer)groupWrapper.quoteLineGroup.term__c).qleIdToQuoteLineWrapper.put(qleId,quoteLineWrapper);

                    } 

                }

            }

        }

        System.debug('in the insertClonedOutyearLines method...');

        if(newOutyearQuoteLines.size() > 0) {

            System.debug('inserting new out year lines... size: ' + newOutyearQuoteLines.size());  

            insert newOutyearQuoteLines;

            updateQuoteIdToQuoteWrapperMap(newOutyearQuoteLines);            

        }

        List<SBQQ__QuoteLine__c> quoteLinesToRebundle = new List<SBQQ__QuoteLine__c>();

        for(QuoteWrapper quoteWrapper : quoteIdToQuoteWrapper.values()) {

            Id quoteId = quoteWrapper.quote.Id;

            SBQQ__Quote__c quote = (Trigger.isExecuting && (SBQQ__Quote__c)Trigger.newMap.get(quoteId) != null) ? ((SBQQ__Quote__c)Trigger.newMap.get(quoteId)) : quoteIdToQuoteWrapper.get(quoteId).quote;

            if(quote != null && quote.numberOfQuoteLineGroups__c > 0) {

                for(GroupWrapper groupWrapper : quoteWrapper.yearToGroupWrapper.values()) {

                    for(String qleId : groupWrapper.qleIdToQuoteLineWrapper.keySet()) {

                        QuoteLineWrapper bundleLineWrapper = groupWrapper.qleIdToQuoteLineWrapper.get(qleId);

                        SBQQ__QuoteLine__c bundleLine = bundleLineWrapper.quoteLine;

                        for(String optionQleId : bundleLineWrapper.optionQleIds) {

                            if(groupWrapper.qleIdToQuoteLineWrapper.get(optionQleId) != null) {

                                QuoteLineWrapper optionLineWrapper = groupWrapper.qleIdToQuoteLineWrapper.get(optionQleId);

                                if(optionLineWrapper.quoteLine.SBQQ__Quote__c == quoteWrapper.quote.Id && optionLineWrapper.quoteLine.SBQQ__Group__c != null) {

                                    if(bundleLineWrapper.quoteLine.SBQQ__Group__c == optionLineWrapper.quoteLine.SBQQ__Group__c) {

                                        SBQQ__QuoteLine__c optionLine = optionLineWrapper.quoteLine;

                                        optionLine.SBQQ__RequiredBy__c = bundleLineWrapper.quoteLine.Id;

                                        Set<Id> quoteLinesToRebundleIds = (new Map<Id,SBQQ__QuoteLine__c>(quoteLinesToRebundle)).keySet();

                                        if(!quoteLinesToRebundleIds.contains(optionLine.Id)) {quoteLinesToRebundle.add(optionLine);}

                                    }

                                }

                            }

                        }

                    }

                }

            }

        }

        if(quoteLinesToRebundle.size() > 0) {

            update quoteLinesToRebundle;

            List<SBQQ__QuoteLine__c> rebundledQuoteLines = quoteLinesToRebundle;

            updateQuoteIdToQuoteWrapperMap(rebundledQuoteLines);

        }

    }
    
    public static Set<Id> getQuoteLineGroupIds(QuoteWrapper quoteWrapper) {

        Set<Id> quoteLineGroupIds = new Set<Id>();

        for(GroupWrapper groupWrapper : quoteWrapper.yearToGroupWrapper.values()) {

            quoteLineGroupIds.add(groupWrapper.quoteLineGroup.Id);

        }

        return quoteLineGroupIds;

    }

    public static void updateQuoteIdToQuoteWrapperMap(List<SBQQ__QuoteLine__c> quoteLines) {

        for(SBQQ__QuoteLine__c ql : quoteLines) {

            QuoteWrapper quoteWrapper = quoteIdToQuoteWrapper.get(ql.SBQQ__Quote__c);

            Integer year = (groupIdToYear.containsKey(ql.SBQQ__Group__c)) ? groupIdToYear.get(ql.SBQQ__Group__c) : (Integer)ql.term__c;

            GroupWrapper groupWrapper = quoteWrapper.yearToGroupWrapper.get(year);

            CventMyd_QuoteLineObject quoteLineObject = CventMyd_UtilityMethods.getQuoteLineObject(ql);

            String qleId = quoteLineObject.qleId;

            QuoteLineWrapper quoteLineWrapper = groupWrapper.qleIdToQuoteLineWrapper.get(quoteLineObject.qleId);

            quoteLineWrapper.quoteLine = ql;

            quoteIdToQuoteWrapper.get(ql.SBQQ__Quote__c).yearToGroupWrapper.get((Integer)ql.term__c).qleIdToQuoteLineWrapper.put(qleId,quoteLineWrapper);

        }        

    }

    public static List<SBQQ__QuoteLine__c> getRenumberedCurrentYearLinesToUpdate(List<SBQQ__QuoteLine__c> intratermCurrentYearLines, Map<Id,List<SBQQ__QuoteLine__c>> quoteIdToPreviousYearQuoteLines) {

        List<SBQQ__QuoteLine__c> quoteLinesToUpdate = new List<SBQQ__QuoteLine__c>();

        Map<Id,List<String>> quoteIdToOrderedQleIds = new Map<Id,List<String>>();

        for(Id quoteId : quoteIdToPreviousYearQuoteLines.keySet()) {

            quoteIdToOrderedQleIds.put(quoteId, new List<String>());

            for(SBQQ__QuoteLine__c ql : quoteIdToPreviousYearQuoteLines.get(quoteId)) {

                CventMyd_QuoteLineObject quoteLineObject = CventMyd_UtilityMethods.getQuoteLineObject(ql);

                String qleId = quoteLineObject.qleId;                

                quoteIdToOrderedQleIds.get(quoteId).add(qleId);

            }

        }

        Integer highestHiddenLineNumber = 2999;

        for(SBQQ__QuoteLine__C ql : intratermCurrentYearLines) {

            if(!ql.SBQQ__Quote__r.createdFromLegacyContract__c) {

                CventMyd_QuoteLineObject quoteLineObject = CventMyd_UtilityMethods.getQuoteLineObject(ql);

                String qleId = ( (CventMyd_UtilityMethods.getQuoteStatusMap(ql.SBQQ__Quote__r)).get('newlyInsertedVariable') && quoteLineObject.nextYearQleId != null) ? quoteLineObject.nextYearQleId : quoteLineObject.qleId;

                Integer previousQuoteLineIndex = quoteIdToOrderedQleIds.get(ql.SBQQ__Quote__c).indexOf(qleId);

                ql.SBQQ__Number__c = (ql.SBQQ__Number__c < 3000) ? previousQuoteLineIndex + 1 : highestHiddenLineNumber + 1;

                highestHiddenLineNumber += ((ql.SBQQ__Number__c >= 3000) ? 1 : 0);

                quoteLinesToUpdate.add(ql);

            }

        }

        return quoteLinesToUpdate;

    }


    public static List<SBQQ__QuoteLine__c> getQuoteLinesToDeleteOnIntratermRenewal(List<SBQQ__QuoteLine__c> intratermCurrentYearLines, Map<Id,List<SBQQ__QuoteLine__c>> quoteIdToPreviousYearQuoteLines) {

        List<SBQQ__QuoteLine__c> quoteLinesToDelete = new List<SBQQ__QuoteLine__c>();

        Map<Id,Set<String>> quoteIdToCurrentYearQleIds = new Map<Id,Set<String>>();

        for(Id quoteId : quoteIdToPreviousYearQuoteLines.keySet()) {

            quoteIdToCurrentYearQleIds.put(quoteId,new Set<String>());

            for(SBQQ__QuoteLine__c ql : quoteIdToPreviousYearQuoteLines.get(quoteId)) {

                CventMyd_QuoteLineObject quoteLineObject = (CventMyd_QuoteLineObject)JSON.deserialize(ql.jsonString__c,CventMyd_QuoteLineObject.class);

                quoteIdToCurrentYearQleIds.get(quoteId).add(quoteLineObject.qleId);

            }

        }

        for(SBQQ__QuoteLine__c ql : intratermCurrentYearLines) {

            CventMyd_QuoteLineObject quoteLineObject = CventMyd_UtilityMethods.getQuoteLineObject(ql);

            String nextYearQleId = (quoteLineObject.nextYearQleId != null) ? quoteLineObject.nextYearQleId : 'asdfsadf';

            String qleId = quoteLineObject.qleId;

            Set<String> previousQuoteQleIds = quoteIdToCurrentYearQleIds.get(ql.SBQQ__Quote__c);

            if(previousQuoteQleIds != null) {          

                if(!previousQuoteQleIds.contains(qleId) && !previousQuoteQleIds.contains(nextYearQleId)) {

                    quoteLinesToDelete.add(ql);

                }

                else if(quoteLineObject.deleteThisLine != null && quoteLineObject.deleteThisLine) {

                    quoteLinesToDelete.add(ql);

                }

            }

        }

        return quoteLinesToDelete;

    }    

    public static List<SBQQ__QuoteLine__c> getQuoteLinesToDeleteOnTermRenewal(List<SBQQ__Quote__c> quotes, Map<Id,List<SBQQ__QuoteLine__c>> quoteIdToQuoteLines) {

        List<SBQQ__QuoteLine__c> quoteLinesToDelete = new List<SBQQ__QuoteLine__c>();

        for(SBQQ__Quote__c quote : quotes) {

            List<SBQQ__QuoteLine__c> quoteLines = quoteIdToQuoteLines.get(quote.Id);

            for(SBQQ__QuoteLine__c ql : quoteLines) {

                if(ql.SBQQ__Product__r.Revenue_Type__c == 'Non-Recurring') {

                    quoteLinesToDelete.add(ql);

                }

            }

        }

        return quoteLinesToDelete;

    }

}