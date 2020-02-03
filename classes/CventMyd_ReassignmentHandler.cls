public class CventMyd_ReassignmentHandler {

    public static Settings settings = CventMyd_Settings.reassignmentSettings;
    public static Set<Id> reassignedOpportunityIds = new Set<Id>();
    
    public class Reassignment {
        public Opportunity sourceOpportunity;
        public Opportunity targetOpportunity;
        public Map<Integer,LineGroup> sourceYearToLineGroup;
        public Map<Integer,LineGroup> targetYearToLineGroup;
        public SBQQ__Quote__c sourceQuote;
        public SBQQ__Quote__c targetQuote;
        Map<Id,Integer> lineIdToTimesAdded;
        public Set<Integer> groupYearsCreated;
        Map<Integer,Integer> sourceYearToTargetYear;
        public Reassignment() {
            this.sourceYearToLineGroup = new Map<Integer,LineGroup>();
            this.targetYearToLineGroup = new Map<Integer,LineGroup>();
            this.lineIdToTimesAdded = new Map<Id,Integer>();
            this.groupYearsCreated = new Set<Integer>();
        }
    }

    public class Settings {
        public Boolean isActive;
        public Boolean recalculateTargetQuote;
        public Boolean throwDebuggingException;
        public Set<String> invalidTargetStages;
        public Set<String> invalidTargetApprovalStatuses;
        public String errorMessage;
    }

    public class QuoteLineWrapper {
        public SBQQ__QuoteLine__c quoteLine;
        public Set<Id> oldOptionLineIds;
        public String tempId;
        public QuoteLineWrapper() {
            oldOptionLineIds = new Set<Id>();
            tempId = CventMyd_UtilityMethods.getQleId();
        }
    }

    public class LineGroup {
        public SBQQ__QuoteLineGroup__c quoteLineGroup;
        public List<SBQQ__QuoteLine__c> quoteLineRecords;
        public Integer highestLineNumber;
        public LineGroup () {
            this.quoteLineRecords = new List<SBQQ__QuoteLine__c>();
        }
        public void addLineToGroup(SBQQ__QuoteLine__c quoteLine) {
            System.debug('adding line to group....');
            if(quoteLineGroup != null) {
                System.debug('group year : ' + quoteLineGroup.term__c);
            }
            System.debug('line product: ' + quoteLine.SBQQ__ProductName__c);
            System.debug('highestLineNumber (before): ' + this.highestLineNumber);
            if(this.highestLineNumber == null) {
                Set<Integer> lineNumbers = new Set<Integer>();
                for(SBQQ__QuoteLine__c groupLine : this.quoteLineRecords) {
                    lineNumbers.add((Integer)groupLine.SBQQ__Number__c);
                }
                List<Integer> numberList = new List<Integer>(lineNumbers);
                numberList.sort();
                this.highestLineNumber = (numberList.isEmpty()) ? ((Integer)quoteLine.SBQQ__Number__c - 1) : numberList[numberList.size() - 1] ;
            }
            this.highestLineNumber++;
            System.debug('highestLineNumber (after): ' + this.highestLineNumber);
            quoteLine.SBQQ__Number__c = this.highestLineNumber;
            this.quoteLineRecords.add(quoteLine);
        }
    }

    public static void handleReassignment() {
        System.debug('$$$$$ Checking for Opportunity Reassignment $$$$$ ');
        Map<Id,Id> sourceIdToTargetId = new Map<Id,Id>();
        Map<Id,Id> opportunityIdToOldReassignedId = new Map<Id,Id>();
        Map<Id,Reassignment> sourceIdToReassignment = new Map<Id,Reassignment>();
        Set<Id> sourceQuoteIds = new Set<Id>();
        Set<Id> quoteIdsToQuery = new Set<Id>();
        Map<Id,Boolean> quoteIdToRecalculationBoolean = new Map<Id,Boolean>();
        Map<Id,Id> quoteIdToOpportunityId = new Map<Id,Id>();
        if(settings.isActive) {
            for(Opportunity opportunity : (List<Opportunity>)Trigger.new) {
                if(!reassignedOpportunityIds.contains(opportunity.Id)) {
                    Id oldReassignedToId = (Id)Trigger.oldMap.get(opportunity.Id).get('Reassigned_To__c');
                    Boolean fieldChanged = CventMyd_UtilityMethods.didFieldChange(opportunity,'Reassigned_To__c');
                    if(fieldChanged && opportunity.Reassigned_To__c != null) {
                        sourceIdToTargetId.put(opportunity.Id,opportunity.Reassigned_To__c);
                    }
                    if(fieldChanged && oldReassignedToId != null) {
                        opportunityIdToOldReassignedId.put(opportunity.Id,oldReassignedToId);
                    }
                }
            }
            if(!opportunityIdToOldReassignedId.keySet().isEmpty()) {
                deleteReassignedQuoteLines(opportunityIdToOldReassignedId);
            }
        }
        if(!sourceIdToTargetId.keySet().isEmpty()) {
            System.debug('****** Performing reassignment for following opportunity source ids ******');
            System.debug(CventMyd_UtilityMethods.getIdString(sourceIdToTargetId.keySet(),';'));
            Set<Id> quoteIdsToConvertToVariable = new Set<Id>();
            List<SBQQ__QuoteLineGroup__c> newVariableGroups = new List<SBQQ__QuoteLineGroup__c>();            
            Map<Id,Opportunity> opportunityMap = new Map<Id,Opportunity>([SELECT Id,
                SBQQ__PrimaryQuote__c,
                SBQQ__PrimaryQuote__r.Current_Year__c,
                SBQQ__PrimaryQuote__r.Contract_Term_Years__c,
                SBQQ__PrimaryQuote__r.Multiple_Years_Commitment__c,
                SBQQ__PrimaryQuote__r.numberOfQuoteLineGroups__c,
                SBQQ__PrimaryQuote__r.SBQQ__LineItemCount__c,
                SBQQ__PrimaryQuote__r.SBQQ__Opportunity2__c,
                Reassigned_To__r.CurrencyIsoCode,
                Reassigned_To__r.SBQQ__PrimaryQuote__r.numberOfQuoteLineGroups__c,
                Reassigned_To__r.SBQQ__PrimaryQuote__c,
                Reassigned_To__r.SBQQ__PrimaryQuote__r.Current_Year__c,
                Reassigned_To__r.SBQQ__PrimaryQuote__r.Contract_Term_Years__c,
                Reassigned_To__r.SBQQ__PrimaryQuote__r.Multiple_Years_Commitment__c,
                Reassigned_To__r.SBQQ__PrimaryQuote__r.ApprovalStatus__c,
                Reassigned_To__r.SBQQ__PrimaryQuote__r.SBQQ__LineItemCount__c,
                Reassigned_To__r.SBQQ__PrimaryQuote__r.SBQQ__Opportunity2__c,
                Reassigned_To__r.StageName,
                SBQQ__PrimaryQuote__r.recalculationToggler__c,
                Reassigned_To__r.SBQQ__PrimaryQuote__r.recalculationToggler__c
                FROM Opportunity
                WHERE Id IN: sourceIdToTargetId.keySet()
            ]);
            System.debug('sourceIds: ' + CventMyd_UtilityMethods.getIdString(sourceIdToTargetId.keySet(),';'));
            System.debug('targetIds: ' + CventMyd_UtilityMethods.getIdString(new Set<Id>(sourceIdToTargetId.values()),';'));
            for(Opportunity opportunity : opportunityMap.values()) {
                Set<Id> targetIds = new Set<Id>(sourceIdToTargetId.values());
                Boolean sourceOpportunity = sourceIdToTargetId.containsKey(opportunity.Id);
                Boolean targetOpportunity = targetIds.contains(opportunity.Id);
                reassignedOpportunityIds.add(opportunity.Id);
                SBQQ__Quote__c sourceQuote = opportunity.SBQQ__PrimaryQuote__r;
                SBQQ__Quote__c targetQuote = opportunity.Reassigned_To__r.SBQQ__PrimaryQuote__r;
                String targetApprovalStatus = (targetQuote == null ) ? null : targetQuote.ApprovalStatus__c;
                Boolean unapplicableSource = (sourceQuote == null || sourceQuote.SBQQ__LineItemCount__c == 0);
                Boolean invalidTargetStage = settings.invalidTargetStages.contains(opportunity.Reassigned_To__r.StageName);
                Boolean invalidTargetApproval = settings.invalidTargetApprovalStatuses.contains(targetApprovalStatus);
                Boolean unapplicableTarget = (invalidTargetStage || invalidTargetApproval || (targetQuote == null));
                if(unapplicableSource || unapplicableTarget) {
                    if(invalidTargetStage || invalidTargetApproval) {
                        Trigger.newMap.get(opportunity.Id).addError(settings.errorMessage);
                    }
                }
                // should only go into below else block when both source and target have a quote
                else {
                    Reassignment reassignment = new Reassignment();
                    System.debug('applicable reassignment detected for source id: ' + opportunity.Id);
                    sourceIdToReassignment.put(opportunity.Id,reassignment);
                    quoteIdToOpportunityId.put(targetQuote.Id,targetQuote.SBQQ__Opportunity2__c);
                    quoteIdToOpportunityId.put(sourceQuote.Id,sourceQuote.SBQQ__Opportunity2__c);
                    quoteIdsToQuery.add(opportunity.SBQQ__PrimaryQuote__c);
                    quoteIdsToQuery.add(opportunity.Reassigned_To__r.SBQQ__PrimaryQuote__c);
                    sourceQuoteIds.add(opportunity.SBQQ__PrimaryQuote__c);
                    Id targetQuoteId = opportunity.Reassigned_To__r.SBQQ__PrimaryQuote__c;
                    reassignment.targetQuote = targetQuote;
                    reassignment.targetOpportunity = opportunity.Reassigned_To__r;
                    Boolean targetQuoteBoolean = targetQuote.recalculationToggler__c;
                    quoteIdToRecalculationBoolean.put(targetQuoteId,targetQuoteBoolean);
                    Boolean sourceIsVariable = (sourceQuote.Multiple_Years_Commitment__c && sourceQuote.numberOfQuoteLineGroups__c > 1);
                    Boolean targetIsVariable = targetQuote.Multiple_Years_Commitment__c;
                    Map<Integer,Integer> sourceYearToTargetYear = new Map<Integer,Integer>();
                    if(!sourceIsVariable && !targetIsVariable) {
                        sourceYearToTargetYear.put(null,null);
                    }
                    else {
                        Integer sourceCurrentYear = (Integer)sourceQuote.Current_Year__c;
                        Integer sourceFinalYear = Integer.valueOf(sourceQuote.Contract_Term_Years__c);
                        Integer targetCurrentYear = (Integer)targetQuote.Current_Year__c;
                        Integer targetFinalYear = Integer.valueOf(targetQuote.Contract_Term_Years__c);
                        List<Integer> sourceYears = CventMyd_UtilityMethods.getIntegerListBetween(sourceCurrentYear,sourceFinalYear);
                        List<Integer> targetYears = CventMyd_UtilityMethods.getIntegerListBetween(targetCurrentYear,targetFinalYear);
                        System.debug('source years: ' + sourceYears);
                        System.debug('target years: ' + targetYears);
                        if(sourceIsVariable) {
                            for(Integer i = 0; i < sourceYears.size(); i++) {
                                Integer sourceYear = sourceYears[i];
                                Integer targetYear = null;
                                if(i < targetYears.size()) {
                                    targetYear = targetYears[i];
                                }
                                sourceYearToTargetYear.put(sourceYear,targetYear);
                            }
                        }
                        else if(!sourceIsVariable) {
                            for(Integer year : targetYears) {
                                sourceYearToTargetYear.put(year,year);
                            }                           
                        }
                        reassignment.sourceYearToTargetYear = sourceYearToTargetYear;
                    }
                    System.debug('sourceYearToTargetYear map: ' + sourceYearToTargetYear);
                    reassignment.sourceYearToTargetYear = sourceYearToTargetYear;
                    if(targetQuote.SBQQ__LineItemCount__c == 0 && targetQuote.Multiple_Years_Commitment__c){
                        System.debug('target quote is lineless');
                        Integer currentYear = (Integer)targetQuote.Current_Year__c;
                        Integer finalYear = Integer.valueOf(targetQuote.Contract_Term_Years__c);
                        quoteIdsToConvertToVariable.add(targetQuote.Id);
                        for(Integer year = currentYear; year <= finalYear; year++) {
                            System.debug('lineless year: ' + year);
                            SBQQ__QuoteLineGroup__c newGroup = getNewQuoteLineGroup(year,targetQuote);
                            newVariableGroups.add(newGroup);
                        }
                    }
                }                
            }
            System.debug('the following quote ids need to be queried for reassignment...');
            System.debug(CventMyd_UtilityMethods.getIdString(quoteIdsToQuery,';'));
            Map<Id,Id> targetQuoteIdToSourceOpportunityId = new Map<Id,Id>();
            if(!quoteIdsToQuery.isEmpty()) {
                String queryString = 'SELECT Id,Name,SBQQ__OriginalPrice__c';
                queryString += ',' + CventMyd_Settings.fullQuoteLineFieldNamesString;
                queryString += ',SBQQ__RequiredBy__r.SBQQ__Product__c';
                queryString += ',SBQQ__Quote__r.SBQQ__Opportunity2__c,SBQQ__Group__r.term__c';
                queryString += ',SBQQ__Quote__r.SBQQ__Opportunity2__r.SBQQ__RenewedContract__c';
                queryString += ' FROM SBQQ__QuoteLine__c';
                queryString += ' WHERE SBQQ__Quote__c IN: quoteIdsToQuery';
                queryString += ' ORDER BY SBQQ__Number__c ASC';
                List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
                List<SBQQ__QuoteLine__c> quoteLineTmp = Database.query(queryString);
                Map<Id,Integer> lineIdToCheckedCount = new Map<Id,Integer>();
                Integer index = 0;
                Integer loopCount = 0;
                System.debug('QUOTE LINE SORTING');
                Set<Id> targetProductIds = new Set<Id>();
                while(!quoteLineTmp.isEmpty()) {
                    loopCount++;
                    SBQQ__QuoteLine__c line = quoteLineTmp[index];
                    Integer checkedCount = lineIdToCheckedCount.get(line.Id);
                    checkedCount = (checkedCount == null) ? 0 : checkedCount ;
                    Boolean isSource = sourceQuoteIds.contains(line.SBQQ__Quote__c);
                    System.debug('line product: ' + line.SBQQ__ProductName__c);
                    System.debug('line number: ' + line.SBQQ__Number__c);
                    System.debug('isSource: ' + isSource);
                    System.debug('checkedCount: ' + checkedCount);
                    System.debug('index before: ' + index);
                    if(!isSource || checkedCount == 1) {
                        quoteLines.add(quotelineTmp.remove(index));
                        if(index == quoteLineTmp.size()) {
                            index = 0;
                        }
                    }
                    else if(quoteLineTmp.size() > index + 1){
                        index++;
                    }
                    else if(quoteLineTmp.size() == index + 1){
                        index = 0;
                    }
                    if(!isSource) {
                        targetProductIds.add(line.SBQQ__Product__c);
                    }
                    System.debug('index after: ' + index);
                    checkedCount++;
                    lineIdToCheckedCount.put(line.Id,checkedCount);
                }
                Integer i = 0;
                while(i < quoteLines.size()) {
                    SBQQ__QuoteLine__c line = quoteLines[i];
                    Boolean isSource = sourceQuoteIds.contains(line.SBQQ__Quote__c);
                    Id productId = line.SBQQ__Product__c;
                    if(isSource && targetProductIds.contains(productId)) {
                        quoteLines.remove(i);
                        i--;
                    }
                    else if(line.SBQQ__RequiredBy__c != null) {
                        Id requiredByProductId = line.SBQQ__RequiredBy__r.SBQQ__Product__c;
                        if(targetProductIds.contains(requiredByProductId)) {
                            line.SBQQ__RequiredBy__c = null;
                            line.SBQQ__ProductOption__c = null;
                        }
                    }
                    i++;
                }
                for(SBQQ__QuoteLine__c quoteLine : quoteLines) {
                    System.debug('=======> quote line for reassignment, Id: ' + quoteLine.Id);
                    System.debug('... quote line name: ' + quoteLine.Name);
                    System.debug('... number: ' + quoteLine.SBQQ__Number__c);
                    System.debug('... product code: ' + quoteLine.SBQQ__ProductName__c);
                    Id opportunityId = quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__c;
                    Id quoteId = quoteLine.SBQQ__Quote__c;
                    Boolean isSource = sourceIdToTargetId.containsKey(opportunityId);
                    Boolean isTarget = sourceIdToTargetId.values().contains(opportunityId);
                    System.debug('... isSource: ' + isSource);
                    System.debug('... isTarget: ' + isTarget);
                    Set<Id> sourceIds = (isTarget) ? CventMyd_UtilityMethods.getKeyIdsToValueId(sourceIdToTargetId,opportunityId,false) : new Set<Id>{opportunityId} ;
                    Id targetId = (isSource) ? sourceIdToTargetId.get(opportunityId) : opportunityId;
                    System.debug('...targetId: ' + targetId);
                    System.debug('...sourceIds: ' + CventMyd_UtilityMethods.getIdString(sourceIds,';'));
                    for(Id sourceId : sourceIds) {
                        System.debug('********** sourceId: ' + sourceId);
                        Opportunity opportunity = opportunityMap.get(sourceId);
                        Reassignment reassignment = sourceIdToReassignment.get(sourceId);
                        SBQQ__Quote__c sourceQuote = opportunity.SBQQ__PrimaryQuote__r;
                        SBQQ__Quote__c targetQuote = opportunity.Reassigned_To__r.SBQQ__PrimaryQuote__r;
                        Boolean sourceIsVariable = (sourceQuote.Multiple_Years_Commitment__c && sourceQuote.numberOfQuoteLineGroups__c > 1);
                        Boolean targetIsVariable = targetQuote.Multiple_Years_Commitment__c;
                        Map<Integer,Integer> sourceYearToTargetYear = reassignment.sourceYearToTargetYear;
                        System.debug('... targetIsVariable: ' + targetIsVariable);
                        System.debug('... sourceIsVariable: ' + sourceIsVariable);
                        if(isSource) {
                            reassignment.sourceQuote = quoteLine.SBQQ__Quote__r;
                        }
                        else if(isTarget) {
                            reassignment.targetQuote = quoteLine.SBQQ__Quote__r;
                        }  
                        Set<Integer> targetYears = new Set<Integer>(sourceYearToTargetYear.values());
                        targetYears.remove(null);
                        System.debug('... sourceYears: ' + sourceYearToTargetYear.keySet());
                        System.debug('... targetYears: ' + targetYears);
                        for(Integer year : sourceYearToTargetYear.keySet()) {
                            Integer sourceYear = year;
                            Integer targetYear = sourceYearToTargetYear.get(sourceYear);
                            System.debug('>> sourceYear: ' + sourceYear);
                            System.debug('>> targetYear: ' + targetYear);
                            LineGroup sourceLineGroup = (reassignment.sourceYearToLineGroup.get(sourceYear) != null) ? reassignment.sourceYearToLineGroup.get(sourceYear) : new LineGroup();
                            //System.debug('sourceLineGroup (top of year loop): ' + sourceLineGroup);
                            LineGroup targetLineGroup = (reassignment.targetYearToLineGroup.get(targetYear) != null) ? reassignment.targetYearToLineGroup.get(targetYear) : new LineGroup();
                            Boolean sameTermValue;
                            if(isSource) {
                                sameTermValue = (sourceYear == quoteLine.SBQQ__Group__r.term__c);
                                if(sourceLineGroup.quoteLineGroup == null && sameTermValue) {
                                    sourceLineGroup.quoteLineGroup = quoteLine.SBQQ__Group__r;
                                }
                                Set<Id> addedSourceLineIds = CventMyd_UtilityMethods.getIdSet(sourceLineGroup.quoteLineRecords);
                                if(!addedSourceLineIds.contains(quoteLine.Id) && (sameTermValue || !sourceIsVariable)) {
                                    System.debug('... adding source line with Id : ' + quoteLine.Id);
                                    System.debug('... to line group with sourceYear: ' + sourceYear);
                                    //System.debug('sourceLineGroup: ' + sourceLineGroup);
                                    sourceLineGroup.addLineToGroup(quoteLine);
                                    targetLineGroup.highestLineNumber = sourceLineGroup.highestLineNumber;
                                }
                                //System.debug('... quoteLine.SBQQ__Group__r (source line): ' + quoteLine.SBQQ__Group__r);
                            }
                            else if(isTarget) {
                                sameTermValue = (targetYear == quoteLine.SBQQ__Group__r.term__c);
                                if(targetLineGroup.quoteLineGroup == null && sameTermValue) {
                                    targetLineGroup.quoteLineGroup = quoteLine.SBQQ__Group__r;
                                }
                                //System.debug('... quoteLine.SBQQ__Group__r (target line): ' + quoteLine.SBQQ__Group__r);
                                if(sameTermValue || (!targetIsVariable && !sourceIsVariable)) {
                                    System.debug('... adding target line with Id : ' + quoteLine.Id);
                                    System.debug('... to line group with year: ' + targetYear);
                                    //System.debug('sourceLineGroup: ' + sourceLineGroup);
                                    targetLineGroup.addLineToGroup(quoteLine);
                                    sourceLineGroup.highestLineNumber = targetLineGroup.highestLineNumber;
                                }
                                else if(!targetIsVariable && sourceIsVariable || targetIsVariable && quoteLine.SBQQ__Group__r == null) {
                                    System.debug('debug XYZU');
                                    System.debug('line id is: ' + quoteLine.Id);
                                    Integer timesAdded = reassignment.lineIdToTimesAdded.get(quoteLine.Id);
                                    System.debug('times Added before: ' + timesAdded);
                                    if(timesAdded == null) {
                                        System.debug('debugAAA');
                                        targetLineGroup.addLineToGroup(quoteLine);
                                        sourceLineGroup.highestLineNumber = targetLineGroup.highestLineNumber;
                                        timesAdded = 1;
                                        reassignment.lineIdToTimesAdded.put(quoteLine.Id,timesAdded);
                                    }
                                    else {
                                        System.debug('debugBBB');
                                        if(timesAdded < targetYears.size()) {
                                            System.debug('debugBBC');
                                            SBQQ__QuoteLine__c clonedTargetLine = quoteLine.clone();
                                            clonedTargetLine.Cloned_From_Quote_Line__c = quoteLine.Id;
                                            clonedTargetLine.Id = null;
                                            clonedTargetLine.SBQQ__UpgradedSubscription__c = null;
                                            clonedTargetLine.SBQQ__RenewedSubscription__c = null;
                                            targetLineGroup.addLineToGroup(clonedTargetLine);
                                            //System.debug('sourceLineGroup: ' + sourceLineGroup);
                                            //System.debug('sourceLineGroup.highestLineNumber (before): ' + sourceLineGroup.highestLineNumber);
                                            sourceLineGroup.highestLineNumber = targetLineGroup.highestLineNumber;
                                            //System.debug('sourceLineGroup.highestLineNumber (after): ' + sourceLineGroup.highestLineNumber);
                                            timesAdded++;
                                        }
                                    }
                                    System.debug('times Added after: ' + timesAdded);
                                }
                                if(targetYear != null && quoteLine.SBQQ__Group__r == null && !reassignment.groupYearsCreated.contains(targetYear)) {
                                    quoteIdsToConvertToVariable.add(quoteLine.SBQQ__Quote__c);
                                    SBQQ__QuoteLineGroup__c quoteLineGroup = getNewQuoteLineGroup(targetYear,quoteLine.SBQQ__Quote__r);
                                    newVariableGroups.add(quoteLineGroup);
                                    reassignment.groupYearsCreated.add(targetYear);
                                }
                            }
                            reassignment.sourceYearToLineGroup.put(sourceYear,sourceLineGroup);
                            reassignment.targetYearToLineGroup.put(targetYear,targetLineGroup);
                        }
                        sourceIdToReassignment.put(sourceId,reassignment);
                    }              
                }
            }
            if(!quoteIdsToConvertToVariable.isEmpty()) {
                List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
                for(Id quoteID : quoteIdsToConvertToVariable) {
                    SBQQ__Quote__c quote = new SBQQ__Quote__c(Id = quoteId);
                    quote.Multiple_Years_Commitment__c = true;
                    quote.SBQQ__LineItemsGrouped__c = true;
                    quotes.add(quote);
                }
                System.debug('updating quote with following id to variable: ' + quote.Id);
                SBQQ.TriggerControl.disable();
                update quotes;
                SBQQ.TriggerControl.enable();
            }
            if(!newVariableGroups.isEmpty()) {
                insert newVariableGroups;
            }
            for(SBQQ__QuoteLineGroup__c quoteLineGroup : newVariableGroups) {
                Id targetId = quoteIdToOpportunityId.get(quoteLineGroup.SBQQ__Quote__c);
                Set<Id> sourceIds = CventMyd_UtilityMethods.getKeyIdsToValueId(sourceIdToTargetId,targetId,false);
                System.debug('just inserted quote line group id: ' + quoteLineGroup.Id);
                System.debug('just inserted quote line group year: ' + quoteLineGroup.term__c);
                for(Id sourceId : sourceIds) {
                    Reassignment reassignment = sourceIdToReassignment.get(sourceId);
                    LineGroup targetLineGroup = reassignment.targetYearToLineGroup.get((Integer)quoteLineGroup.term__c);
                    targetLineGroup.quoteLineGroup = quoteLineGroup;
                    System.debug('setting the quote line group on targetLineGroup....');
                    reassignment.targetQuote.Multiple_Years_Commitment__c = true;
                    reassignment.targetQuote.SBQQ__LineItemsGrouped__c = true;
                }       
            }
            Map<Id,List<QuoteLineWrapper>> oldLineIdToNewLineWrappers = new Map<Id,List<QuoteLineWrapper>>();
            List<SBQQ__QuoteLine__c> linesToUpdate = new List<SBQQ__QuoteLine__c>();
            System.debug('!!!!!!!!!!!!!! forming list of quote lines to insert !!!!!!!!!!!!!!');
            for(Id sourceId : sourceIdToReassignment.keySet()) {
                Reassignment reassignment = sourceIdToReassignment.get(sourceId);
                String targetCurrency = reassignment.targetOpportunity.CurrencyIsoCode;
                System.debug('...sourceId: ' + sourceId);
                for(Integer sourceYear : reassignment.sourceYearToLineGroup.keySet()) {
                    Integer targetYear = reassignment.sourceYearToTargetYear.get(sourceYear);
                    System.debug('SOURCE YEAR::::: ' + sourceYear);
                    System.debug('TARGET YEAR::::: ' + targetYear);
                    LineGroup sourceLineGroup = reassignment.sourceYearToLineGroup.get(sourceYear);
                    LineGroup targetLineGroup = reassignment.targetYearToLineGroup.get(targetYear);
                    //System.debug('target group Id::::: ' + targetLineGroup.quoteLineGroup);
                    System.debug('source line group record count: ' + sourceLineGroup.quoteLineRecords.size());
                    if(!(sourceYear != null && targetYear == null)) {
                        for(SBQQ__QuoteLine__c sourceQuoteLine : sourceLineGroup.quoteLineRecords) {
                            QuoteLineWrapper quoteLineWrapper = new QuoteLineWrapper();
                            SBQQ__QuoteLine__c newReassignedLine = sourceQuoteLine.clone(false,true,false,false);
                            newReassignedLine.Id = null;
                            newReassignedLine.CurrencyIsoCode = targetCurrency;
                            newReassignedLine.SBQQ__UpgradedSubscription__c = null;
                            newReassignedLine.SBQQ__RenewedSubscription__c = null;
                            newReassignedLine.SBQQ__Group__c = (targetYear != null) ? targetLineGroup.quoteLineGroup.Id : null;
                            newReassignedLine.SBQQ__Quote__c = reassignment.targetQuote.Id;
                            newReassignedLine.ReassignedFromOpportunityId__c = String.valueOf(sourceId);
                            newReassignedLine.ReassignedFromRenewedContract__c = sourceQuoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.SBQQ__RenewedContract__c;
                            newReassignedLine.Cloned_from_Quote_Line__c = sourceQuoteLine.Id;
                            newReassignedLine.priceRuleDebug__c = quoteLineWrapper.tempId;
                            System.debug('--------> preparing to insert new reassigned quote line: ');
                            System.debug('... source line id: ' + sourceQuoteLine.Id);
                            System.debug('... product name: ' + newReassignedLine.SBQQ__ProductName__c);
                            System.debug('... product id: ' + newReassignedLine.SBQQ__Product__c);
                            System.debug('... line number: ' + newReassignedLine.SBQQ__Number__c);
                            System.debug('... group source year: ' + sourceYear);
                            System.debug('... group target year: ' + targetYear);
                            System.debug('... target group Id: ' + newReassignedLine.SBQQ__Group__c);
                            System.debug('... target quote id: ' + newReassignedLine.SBQQ__Quote__c);
                            System.debug('... source quote id: ' + sourceQuoteLine.SBQQ__Quote__c);
                            quoteLineWrapper.quoteLine = newReassignedLine;
                            if(!oldLineIdToNewLineWrappers.containsKey(sourceQuoteLine.Id)) {
                                oldLineIdToNewLineWrappers.put(sourceQuoteLine.Id, new List<QuoteLineWrapper>());
                            }
                            oldLineIdToNewLineWrappers.get(sourceQuoteLine.Id).add(quoteLineWrapper);
                        }
                        if(targetLineGroup.quoteLineGroup != null) {
                            System.debug('target quote line record list size: ' + targetLineGroup.quoteLineRecords.size());
                            for(SBQQ__QuoteLine__c targetQuoteLine : targetLineGroup.quoteLineRecords) {
                                if(targetQuoteLine.Id != null) {
                                    System.debug('--------> preparing to group target quote line: ');
                                    System.debug('... line id: ' + targetQuoteLine.Id);
                                    System.debug('... product name: ' + targetQuoteLine.SBQQ__ProductName__c);
                                    System.debug('... product id: ' + targetQuoteLine.SBQQ__Product__c);
                                    System.debug('... line number: ' + targetQuoteLine.SBQQ__Number__c); 
                                    System.debug('... group year: ' + targetYear); 
                                    if(targetLineGroup.quoteLineGroup != null) {
                                        System.debug('target quote line group id: ' + targetLineGroup.quoteLineGroup.Id);
                                        targetQuoteLine.SBQQ__Group__c = targetLineGroup.quoteLineGroup.Id;
                                    }                     
                                    SBQQ__QuoteLine__c targetLineToUpdate = new SBQQ__QuoteLine__c();
                                    targetLineToUpdate.Id = targetQuoteLine.Id;
                                    targetLineToUpdate.SBQQ__Group__c = targetQuoteLine.SBQQ__Group__c;
                                    targetLineToUpdate.SBQQ__Number__c = targetQuoteLine.SBQQ__Number__c;
                                    linesToUpdate.add(targetLineToUpdate);
                                }
                                else if(targetQuoteLine.Id == null) {
                                    QuoteLineWrapper quoteLineWrapper = new QuoteLineWrapper();
                                    targetQuoteLine.SBQQ__Group__c = targetLineGroup.quoteLineGroup.Id;
                                    //targetQuoteLine.ReassignedFromOpportunityId__c = String.valueOf(sourceId);
                                    System.debug('--------> preparing to insert new cloned target quote line: ');
                                    System.debug('... source line id: ' + targetQuoteLine.Id);
                                    System.debug('... product name: ' + targetQuoteLine.SBQQ__ProductName__c);
                                    System.debug('... product id: ' + targetQuoteLine.SBQQ__Product__c);
                                    System.debug('... line number: ' + targetQuoteLine.SBQQ__Number__c);
                                    System.debug('... group year: ' + targetYear);
                                    System.debug('... target group Id: ' + targetQuoteLine.SBQQ__Group__c);
                                    System.debug('... target quote id: ' + targetQuoteLine.SBQQ__Quote__c);
                                    targetQuoteLine.priceRuleDebug__c = quoteLineWrapper.tempId;
                                    quoteLineWrapper.quoteLine = targetQuoteLine;
                                    if(!oldLineIdToNewLineWrappers.containsKey(targetQuoteLine.Cloned_From_Quote_Line__c)) {
                                        oldLineIdToNewLineWrappers.put(targetQuoteLine.Cloned_From_Quote_Line__c,new List<QuoteLineWrapper>());
                                    }
                                    oldLineIdToNewLineWrappers.get(targetQuoteLine.Cloned_From_Quote_Line__c).add(quoteLineWrapper);                                
                                }
                            }                        
                        }
                    }
                }
            }
            if(!oldLineIdToNewLineWrappers.keySet().isEmpty()) {
                SBQQ.TriggerControl.disable();
                List<SBQQ__QuoteLine__c> newTargetLines = new List<SBQQ__QuoteLine__c>();
                for(Id oldLineId : oldLineIdToNewLineWrappers.keySet()) {
                    for(QuoteLineWrapper quoteLineWrapper : oldLineIdToNewLineWrappers.get(oldLineId)) {
                        SBQQ__QuoteLine__c newTargetLine = quoteLineWrapper.quoteLine;
                        newTargetLines.add(quoteLineWrapper.quoteLine);
                        Id oldRequiredById = newTargetLine.SBQQ__RequiredBy__c;
                        if(oldRequiredById != null) {
                            System.debug('oldRequiredById: ' + oldRequiredById);
                            for(QuoteLineWrapper requiredByWrapper : oldLineIdToNewLineWrappers.get(oldRequiredById)) {
                                System.debug('requiredByWrapper.tempId: ' + requiredByWrapper.tempId);
                                requiredByWrapper.oldOptionLineIds.add(oldLineId);
                            }
                        }
                    }
                }
                insert newTargetLines;
                SBQQ.TriggerControl.enable();
                for(SBQQ__QuoteLine__c insertedTargetLine : newTargetLines) {
                    Id oldLineId = insertedTargetLine.Cloned_From_Quote_Line__c;
                    for(QuoteLineWrapper quoteLineWrapper : oldLineIdToNewLineWrappers.get(oldLineId)) {
                        if(quoteLineWrapper.tempId == insertedTargetLine.priceRuleDebug__c){
                            quoteLineWrapper.quoteLine.Id = insertedTargetLine.Id;
                        }
                    }
                }
                System.debug('NOW LOOPING THROUGH THE oldLineId MAP');
                Set<Id> handledNewLineIds = new Set<Id>();
                for(Id oldLineId : oldLineIdToNewLineWrappers.keySet()) {
                    System.debug('old line id: ' + oldLineId);
                    for(QuoteLineWrapper bundleLineWrapper : oldLineIdToNewLineWrappers.get(oldLineId)) {
                        System.debug('quote line wrapper temp id: ' + bundleLineWrapper.tempId);
                        System.debug('quote line wrapper new record id: ' + bundleLineWrapper.quoteLine.Id);
                        System.debug('oldOptionLineIds: ' + bundleLineWrapper.oldOptionLineIds);
                        if(!bundleLineWrapper.oldOptionLineIds.isEmpty()) {
                            for(Id oldOptionId : bundleLineWrapper.oldOptionLineIds) {
                                //System.debug('option wrappers: ' + oldLineIdToNewLineWrappers.get(oldOptionId));
                                for(QuoteLineWrapper optionLineWrapper : oldLineIdToNewLineWrappers.get(oldOptionId)){
                                    // System.debug('old option id: ' + oldOptionId);
                                    Id optionGroupId = optionLineWrapper.quoteLine.SBQQ__Group__c;
                                    Id bundleGroupId = bundleLineWrapper.quoteLine.SBQQ__Group__c;
                                    Boolean sameGroup = (optionGroupId == bundleGroupId);
                                    if(!handledNewLineIds.contains(optionLineWrapper.quoteLine.Id) && sameGroup) {
                                        SBQQ__QuoteLine__c lineToRebundle = new SBQQ__QuoteLine__c();
                                        lineToRebundle.Id = optionLineWrapper.quoteLine.Id;
                                        System.debug('old option id: ' + lineToRebundle.SBQQ__RequiredBy__c);
                                        lineToRebundle.SBQQ__RequiredBy__c = bundleLineWrapper.quoteLine.Id;
                                        System.debug('new option id: ' + lineToRebundle.SBQQ__RequiredBy__c);
                                        handledNewLineIds.add(optionLineWrapper.quoteLine.Id);
                                        linesToUpdate.add(lineToRebundle);
                                    }
                                }
                            }
                        }
                    }
                }
                SBQQ.TriggerControl.enable();
            }
            if(!linesToUpdate.isEmpty()){
                SBQQ.TriggerControl.disable();
                update linesToUpdate;
                SBQQ.TriggerControl.enable();
            }
            if(settings.recalculateTargetQuote && !quoteIdToRecalculationBoolean.keySet().isEmpty()) {
                List<SBQQ__Quote__c> quotesToRecalculate = new List<SBQQ__Quote__c>();
                for(Id quoteId : quoteIdToRecalculationBoolean.keySet()) {
                    Boolean newToggleValue = !quoteIdToRecalculationBoolean.get(quoteId);
                    SBQQ__Quote__c quoteToRecalculate = new SBQQ__Quote__c(Id = quoteId,recalculationToggler__c = newToggleValue);
                    quotesToRecalculate.add(quoteToRecalculate);
                }
                update quotesToRecalculate;
            }
            if(settings.throwDebuggingException) {
                String exceptionString = 'throwing this exception to verify debugged results before completing the operation';
                throw new CventMyd_UtilityMethods.Cvent_Exception(exceptionString);
            }
        }
    }

    public static SBQQ__QuoteLineGroup__c getNewQuoteLineGroup(Integer year, SBQQ__Quote__c quote) {
        SBQQ__QuoteLineGroup__c quoteLineGroup = new SBQQ__QuoteLineGroup__c(term__c = year,SBQQ__Quote__c = quote.Id);
        Integer currentYear = (Integer)quote.Current_Year__c;
        String groupName = 'Year ' + String.valueOf(year);
        groupName += (year == currentYear) ? ' (Current Year)' : '';
        quoteLineGroup.groupType__c = 'Variable MYD Group';
        quoteLineGroup.Name = groupName;
        quoteLineGroup.SBQQ__Number__c = year;
        System.debug('preparing for creation of quote line group with year : ' + year);
        System.debug('on quote with id : ' + quote.Id); 
        System.debug('what is the quote id on the group i am about to insert?: ' + quoteLineGroup.SBQQ__Quote__c);
        return quoteLineGroup;   
    }
    
    public static void deleteReassignedQuoteLines(Map<Id,Id> opportunityIdToOldReassignedId){
        List<SBQQ__QuoteLine__c> quoteLinesToDelete = new List<SBQQ__QuoteLine__c>();
        List<Booking_Classification__c> bookingClassificationsToDelete = new List<Booking_Classification__c>();
        Set<String> reassignedFromIdStrings = new Set<String>();
        for(Id opportunityId : opportunityIdToOldReassignedId.keySet()) {
            reassignedFromIdStrings.add(String.valueOf(opportunityId));
            reassignedOpportunityIds.add(opportunityId);
        }
        bookingClassificationsToDelete = [SELECT Id
            FROM Booking_Classification__c
            WHERE Opportunity__c IN : opportunityIdToOldReassignedId.values()
            AND Opportunity__r.StageName != 'Closed Won'
        ];
        quoteLinesToDelete = [SELECT
            Id FROM SBQQ__QuoteLine__c
            WHERE ReassignedFromOpportunityId__c IN : reassignedFromIdStrings
            AND SBQQ__Quote__r.SBQQ__Opportunity2__c IN : opportunityIdToOldReassignedId.values()
            AND SBQQ__Quote__r.SBQQ__Opportunity2__r.StageName != 'Closed Won'
        ];
        if(quoteLinesToDelete.size() > 0) {
            if(!settings.recalculateTargetQuote) {
                SBQQ.TriggerControl.disable();
            }
            delete quoteLinesToDelete;
            SBQQ.TriggerControl.enable();
        }
        if(bookingClassificationsToDelete.size() > 0) {
            delete bookingClassificationsToDelete;
        }
    }
    
}