public class ContractTrgHelperCls {

    public static Map<Id,Opportunity> contractIdToAmendmentOpportunity = new Map<Id,Opportunity>();

    public static Map<Id,Id> contractIdToOriginalAmendmentOpportunityId = new Map<Id,Id>();

    public static Map<Id,List<SBQQ__Subscription__c>> legacyContractIdToSubscriptions = new Map<Id,List<SBQQ__Subscription__c>>();

    public static Map<Id,Date> accountIdToEndDate = new Map<Id,Date>();

    public static Set<Id> contractIdsBeingRenewed = new Set<Id>();

    public static Map<Id,Date> mydContractIdToEndDate = new Map<Id,Date>();

    public static Set<Id> opportunityIdsContracted = new Set<Id>();

    public static Set<Id> childContractIdsInserted = new Set<Id>();

    public static Boolean contractGenerationMonitorScheduled = false;

    public static Set<Id> parentContractIdsToCheck = new Set<Id>();

    public static Map<Id,Id> contractIdToLastAmendmentQuoteId = new Map<Id,Id>();

    public class OutyearLineWrapper {

        public SBQQ__QuoteLine__c currentQuoteLine;

        public SBQQ__QuoteLine__c previousQuoteLine;

        public SBQQ__Subscription__c subscription;

    }

    // call this method handleContractedOpportunities from opportunity trigger handler/dispatcher, before update

    public static void handleContractedOpportunities() {

        List<Opportunity> opportunities = (List<Opportunity>)Trigger.new;

        for(Opportunity opportunity : opportunities) {

            System.debug('opportunity id, in ContractTrgHelperCls: ' + opportunity.Id);

            Opportunity oldOpportunity = (Opportunity)Trigger.oldMap.get(opportunity.Id);

            Boolean wasContracted = oldOpportunity.SBQQ__Contracted__c;

            Boolean isContracted = opportunity.SBQQ__Contracted__c;

            if(!wasContracted && isContracted) {

                opportunity.contractedDateTime__c = DateTime.now();

                opportunityIdsContracted.add(opportunity.Id);

            }

        }

    }    

    public static void handleAfterInsert() {

        Map<Id,Date> accountIdToUpdateToEndDate = new Map<Id,Date>();

        for(Contract contract : (List<Contract>)Trigger.new) {

            Boolean updateAccount = ( accountIdToEndDate.get(contract.AccountId) == null || accountIdToEndDate.get(contract.AccountId) != contract.EndDate ) ;

            if(contract.RecordTypeId == CventMyd_Settings.parentContractRecordTypeId && updateAccount)  {

                accountIdToUpdateToEndDate.put(contract.AccountId,contract.EndDate);

            }

            if(accountIdToUpdateToEndDate.size() > 0) {

                updateEndDatesOnAccounts(accountIdToUpdateToEndDate);

            }

            if(contract.RecordTypeId == CventMyd_Settings.childContractRecordTypeId) {

                childContractIdsInserted.add(contract.Id);

            }

        }

    }

    public class RenewalException extends Exception {}

    public static void throwRenewalException(Id contractId, Boolean isLegacy) {

        String exceptionString = 'There are less than 1 renewable products on';

        exceptionString += (!isLegacy) ? ' non-legacy' : ' legacy';

        exceptionString += ' contract with Id';

        exceptionString += ' ' + '\'' + String.valueOf(contractId) + '\'';

        throw new RenewalException(exceptionString);

    }

    public static void handleBeforeUpdate() {

        Set<Id> contractIdsToQueryForAmendments = new Set<Id>();

        Boolean renewalQuotedChecked = false;

        Set<Id> legacyContractIdsToQuerySubscriptions = new Set<Id>();

        Id renewalMasterId = CventMyd_AutoRenewContractSchedulable.renewalChainMasterId;

        Boolean queryAmendmentOpportunities = ( System.isFuture() && !CventMyd_Settings.contractingInForeground ) || ( CventMyd_Settings.contractingInForeground && !opportunityIdsContracted.isEmpty()  );

        System.debug('ContractTrgHelperCls isFuture: ' + System.isFuture());

        for(Contract contract : (List<Contract>)Trigger.new) {

            Date endDate = contract.EndDate;

            contractIdToLastAmendmentQuoteId.put(contract.Id,contract.contractedAmendmentQuote__c);

            if(contract.RecordTypeId == CventMyd_Settings.childContractRecordTypeId) {

                Integer daysInAdvanced = (contract.Upcoming_Renewal_Type__c == 'MYD Renewal') ? 90 : 365;

                contract.Renewal_Opportunity_Creation__c = String.valueOf(daysInAdvanced) + ' days in advance';

                contract.Renewal_Creation_Date__c = (endDate != null) ? endDate.addDays((-1)*daysInAdvanced) : null ;

            }

            contract.renewalChainMaster__c = (renewalMasterId != null) ? renewalMasterId : contract.renewalChainMaster__c;

            System.debug('queryAmendmentOpportunities: ' + queryAmendmentOpportunities);

            if(queryAmendmentOpportunities && !contractIdToAmendmentOpportunity.containsKey(contract.Id) && !childContractIdsInserted.contains(contract.Id)) {

                contractIdsToQueryForAmendments.add(contract.Id);

            }

            Boolean oldRenewalQuoted = ((Contract)Trigger.oldMap.get(contract.Id)).SBQQ__RenewalQuoted__c;

            Boolean newRenewalQuoted = contract.SBQQ__RenewalQuoted__c;

            Boolean isLegacyRenewal = (contract.isLegacy__c && contract.contractedAmendmentOpportunity__c == null);

            if(!oldRenewalQuoted && newRenewalQuoted) {

                contractIdsBeingRenewed.add(contract.Id);

                if(contract.Upcoming_Renewal_Type__c == 'MYD Renewal') {
                    
                    mydContractIdToEndDate.put(contract.Id,endDate);

                }

                renewalQuotedChecked = true;

                Boolean isLegacy = contract.isLegacy__c;   

                if(!isLegacyRenewal && contract.renewableLineCount__c < 1 && !Test.isRunningTest()) {

                    throwRenewalException(contract.Id,false);

                }

            }        

            Boolean haventQueriedSubscriptions = !ContractTrgHelperCls.legacyContractIdToSubscriptions.containsKey(contract.Id);

            if(renewalQuotedChecked && isLegacyRenewal && haventQueriedSubscriptions) {

                legacyContractIdsToQuerySubscriptions.add(contract.Id);

            }

        }

        System.debug('legacyContractIdsToQuerySubscriptions: ' + legacyContractIdsToQuerySubscriptions);

        List<SBQQ__Subscription__c> legacySubscriptions = new List<SBQQ__Subscription__c>();

        Boolean querySubscriptions = (legacyContractIdsToQuerySubscriptions.size() > 0);

        if(querySubscriptions) {

            legacySubscriptions = CventMyd_LegacyContractHandler.getAndSetLegacySubscriptions(legacyContractIdsToQuerySubscriptions);

        }

        System.debug('legacySubscriptions keySet: ' + (new Map<Id,SBQQ__Subscription__c>(legacySubscriptions)).keySet() );

        if(legacySubscriptions.size() > 0) {

            System.debug('legacy subscriptions found....');

            for(Id contractId : ContractTrgHelperCls.legacyContractIdToSubscriptions.keySet()) {

                if(contractIdsBeingRenewed.contains(contractId)) {

                    List<SBQQ__Subscription__c> subscriptions = ContractTrgHelperCls.legacyContractIdToSubscriptions.get(contractId);

                    Decimal renewableLineCount = CventMyd_LegacyContractHandler.getRenewableLineCount(subscriptions);

                    if(renewableLineCount < 1) {

                        throwRenewalException(contractId,true);

                    }

                }

            }

            update legacySubscriptions;

        }

        else if(legacySubscriptions.size() == 0 && querySubscriptions) {

            for(Id contractId : legacyContractIdsToQuerySubscriptions) {

                Boolean isLegacy = ((Contract)Trigger.newMap.get(contractId)).isLegacy__c;

                if(isLegacy){throwRenewalException(contractId,true);}

            }

        }

        Map<Id,Id> amendmentQuoteIdToChildContractId = new Map<Id,Id>();

        Set<Id> parallelChildrenIds = new Set<Id>();

        System.debug('contractIdsToQueryForAmendments: ' + contractIdsToQueryForAmendments);

        if(contractIdsToQueryForAmendments.size() > 0) {

            DateTime twentyMinutesAgo = DateTime.now().addMinutes(-10);

            for(Contract contract : [SELECT Id,SBQQ__RenewalOpportunity__r.StageName,Multiple_Years_Commitment__c,

                (SELECT Id,SBQQ__PrimaryQuote__c,Master_Agreement__c,

                SBQQ__PrimaryQuote__r.Contract_Extension__c,SBQQ__Contracted__c,

                SBQQ__PrimaryQuote__r.Multiple_Years_Commitment__c,

                SBQQ__PrimaryQuote__r.jsonString__c,

                SBQQ__PrimaryQuote__r.Current_Year__c,

                SBQQ__PrimaryQuote__r.Contract_Term_Years__c,

                SBQQ__PrimaryQuote__r.Quote_Out_of_Date__c,

                SBQQ__PrimaryQuote__r.SBQQ__MasterContract__c

                FROM SBQQ__AmendmentOpportunities__r

                WHERE SBQQ__Contracted__c = TRUE

                AND contractedDateTime__c >: twentyMinutesAgo

                ORDER BY contractedDateTime__c DESC NULLS LAST, CreatedDate DESC

                LIMIT 30)         

                FROM Contract

                WHERE Id IN: contractIdsToQueryForAmendments

            ]) {

                for(Opportunity opportunity : contract.SBQQ__AmendmentOpportunities__r) {

                    if(opportunity.SBQQ__PrimaryQuote__r.jsonString__c != null) {

                        ((Contract)Trigger.newMap.get(contract.Id)).SBQQ__RenewalOpportunity__r = contract.SBQQ__RenewalOpportunity__r;

                        contractIdToAmendmentOpportunity.put(contract.Id,opportunity);

                        amendmentQuoteIdToChildContractId.put(opportunity.SBQQ__PrimaryQuote__c,contract.Id);

                        System.debug('amendmentQuoteIdToChildContractId: ' + amendmentQuoteIdToChildContractId);

                        if(opportunity.SBQQ__PrimaryQuote__r.Quote_Out_of_Date__c) {

                            parallelChildrenIds.add(contract.Id);

                        }

                        break;

                    }

                }

            }

        }

        for(Contract contract : (List<Contract>)Trigger.new) {

            if(contract.RecordTypeId == CventMyd_Settings.childContractRecordTypeId && contract.SBQQ__Quote__c != null) {

                contract.EndDate = contract.quoteEndDate__c;

            }
            
            Opportunity amendmentOpportunity = contractIdToAmendmentOpportunity.get(contract.Id);

            if(amendmentOpportunity != null && amendmentOpportunity.SBQQ__PrimaryQuote__c != null) {

                System.debug('amendmentOpportunity.Id: ' + amendmentOpportunity.Id);

                Opportunity renewalOpportunity = contract.SBQQ__RenewalOpportunity__r;

                if(renewalOpportunity != null && renewalOpportunity.StageName != 'Closed Won' && contract.SBQQ__RenewalQuoted__c) {

                    contract.SBQQ__RenewalQuoted__c = false;

                }

                contract.contractedAmendmentOpportunity__c = amendmentOpportunity.Id;

                contract.Last_Amended_Opportunity_Contracted__c = System.now();

                contract.contractedAmendmentQuote__c = amendmentOpportunity.SBQQ__PrimaryQuote__c;

                contract.Multiple_Years_Commitment__c = amendmentOpportunity.SBQQ__PrimaryQuote__r.Multiple_Years_Commitment__c;

                Boolean opportunityHasExtension = (amendmentOpportunity.SBQQ__PrimaryQuote__r.Contract_Extension__c != null && amendmentOpportunity.SBQQ__PrimaryQuote__r.Contract_Extension__c != '');

                contract.Parent_Contract__c = (opportunityHasExtension) ? amendmentOpportunity.Master_Agreement__c : contract.Parent_Contract__c;             

            }

            Boolean statusChange = (contract.Status != ((Contract)Trigger.oldMap.get(contract.Id)).Status);

            Boolean closedExecution = (contract.Status=='Closed/Executed' || contract.Status == 'Closed/Not Executed');

            if(statusChange && closedExecution) {

                contract.Status_Change_Date__c = System.today();

            }

        }

        System.debug('amendmentQuoteIdToChildContractId.keySet(): ' + amendmentQuoteIdToChildContractId.keySet());

        if(!amendmentQuoteIdToChildContractId.keySet().isEmpty()) {

            handleAmendmentChangesOnContract(amendmentQuoteIdToChildContractId,parallelChildrenIds);

        }

    }

    // this method takes in a set of amendment quote ids

    // this method runs in the future operation that occurs after checking SBQQ__Contracted__c on amendment opportunities 

    // subscription JSON needs to be updated according to changes made to quote lines

    // parallel amendment quotes need a list of outyear line additions to insert on next quote

    // outyear lines need JSON update in case parallel outyear changes are made

    public static void handleAmendmentChangesOnContract(Map<Id,Id> amendmentQuoteIdToChildContractId, Set<Id> parallelChildrenIds) {

        List<SBQQ__Subscription__c> subscriptionsToUpdate = new List<SBQQ__Subscription__c>();

        Set<Id> parallelAmendmentQuoteIdsToLock = new Set<Id>();

        Map<Id,Set<Id>> amendmentQuoteIdToAddedOutyearLineIds = new Map<Id,Set<Id>>();

        List<SBQQ__QuoteLine__c> outyearLinesToUpdateJson = new List<SBQQ__QuoteLine__c>();

        Map<Id,Id> recentParallelIdToJustExecutedId = new Map<Id,Id>();

        Set<Id> previousQuoteIds = new Set<Id>();

        // use the trigger-populated maps to collect ids of the previously contracted amendments (where the current amendment is not the first)

        for(Id quoteId : amendmentQuoteIdToChildContractId.keySet()) {

            Id childContractId = amendmentQuoteIdToChildContractId.get(quoteId);

            Id mostRecentAmendmentQuoteId = contractIdToLastAmendmentQuoteId.get(childContractId);

            previousQuoteIds.add(mostRecentAmendmentQuoteId);

        }

        System.debug('previousQuoteIds: ' + previousQuoteIds);

        // get all quote lines from the current amendment quote as well as the last contracted amendment quote

        List<SBQQ__QuoteLine__c> quoteLines = [SELECT

            Id,jsonString__c,SBQQ__UpgradedSubscription__c,Name,
            
            SBQQ__Quantity__c,SBQQ__PriorQuantity__c,SBQQ__Quote__c,
            
            SBQQ__EffectiveQuantity__c,SBQQ__Optional__c,SBQQ__NetPrice__c,

            SBQQ__Quote__r.SBQQ__MasterContract__c,SBQQ__ProductName__c,
            
            SBQQ__Quote__r.Current_Year__c,term__c,SBQQ__Product__c

            FROM SBQQ__QuoteLine__c

            WHERE SBQQ__Quote__c IN: amendmentQuoteIdToChildContractId.keySet()

            OR SBQQ__Quote__c IN: previousQuoteIds

        ];

        Map<Id,SBQQ__Subscription__c> subscriptionMap;

        // if parallel execution is occurring, get all the subscriptions as they currently exist on the contract
        
        if(!parallelChildrenIds.isEmpty()) {

            subscriptionMap = new Map<Id,SBQQ__Subscription__c>([SELECT Id,SBQQ__Quantity__c,Name,
        
                jsonString__c,SBQQ__RevisedSubscription__c,

                (SELECT Id,SBQQ__QuoteLine__c,SBQQ__Quantity__c FROM SBQQ__Revisions__r)

                FROM SBQQ__Subscription__c

                WHERE SBQQ__Contract__c IN: parallelChildrenIds

                AND SBQQ__RevisedSubscription__c = null
        
            ]);

        }    

        Map<Id,OutyearLineWrapper> quoteLineIdToOutyearLineWrapper = new Map<Id,OutyearLineWrapper>();

        // put all current quote outyear lines in a map

        for(SBQQ__QuoteLine__c quoteLine : quoteLines) {

            Boolean currentLine = (amendmentQuoteIdToChildContractId.containsKey(quoteLine.SBQQ__quote__c));

            Boolean outyearLine = (quoteLine.term__c > quoteLine.SBQQ__Quote__r.Current_Year__c);

            Boolean isParallel = (parallelChildrenIds.contains(quoteLine.SBQQ__Quote__r.SBQQ__MasterContract__c));

            if(currentLine && outyearLine && isParallel) {

                quoteLineIdToOutyearLineWrapper.put(quoteLine.Id,null);

                System.debug('adding outyear line to map for parallel execution, id: ' + quoteLine.Id);

            }

        }

        // populate the outyear line map so that each current quote line is mapped to its previous quote line

        // line0 is a quote line from the previous quote

        if(!parallelChildrenIds.isEmpty()) {

            for(SBQQ__QuoteLine__c line0 : quoteLines) {

                CventMyd_QuoteLineObject quoteLineObject0 = CventMyd_UtilityMethods.getQuoteLineObject(line0);

                Set<String> line0ClonedFromQleIds = new Set<String>(quoteLineObject0.clonedFromQleIds);

                if(!quoteLineIdToOutyearLineWrapper.containsKey(line0.Id)) {

                    // line1 is a quoteLine from the current quote

                    System.debug('line id from previous quote: ' + line0.Id);

                    for(SBQQ__QuoteLine__c line1 : quoteLines) {

                        OutyearLineWrapper outyearLineWrapper = new OutyearLineWrapper();

                        outyearLineWrapper.currentQuoteLine = line1;

                        outyearLineWrapper.previousQuoteLine = line0;

                        if(line1.Id != line0.Id && quoteLineIdToOutyearLineWrapper.containsKey(line1.Id) && quoteLineIdToOutyearLineWrapper.get(line1.Id) == null) {

                            CventMyd_QuoteLineObject quoteLineObject1 = CventMyd_UtilityMethods.getQuoteLineObject(line1);

                            Boolean sameContractedLine = false;

                            if(quoteLineObject0.qleId == quoteLineObject1.qleId) {

                                sameContractedLine = true;

                            }

                            else  {

                                Set<String> line1ClonedFromQleIds = new Set<String>(quoteLineObject1.clonedFromQleIds);

                                Boolean sameProduct = (line1.SBQQ__Product__c == line0.SBQQ__Product__c);
                                
                                Boolean samePrice =  (line1.SBQQ__NetPrice__c == line0.SBQQ__NetPrice__c);

                                Boolean sameYear = (line1.term__c == line0.term__c);

                                if(sameProduct && samePrice && sameYear) {

                                    if(line1ClonedFromQleIds.contains(quoteLineObject0.qleId) || line0ClonedFromQleIds.contains(quoteLineObject1.qleId)) {

                                        sameContractedLine = true;

                                    }

                                }

                            }

                            if(sameContractedLine) {

                                System.debug('found a match for line on current quote with Id: ' + line1.Id);

                                quoteLineIdToOutyearLineWrapper.put(line1.Id,outyearLineWrapper);

                                System.debug('its line from the previous quote has a record id of: ' + outyearLineWrapper.previousQuoteLine.Id);

                            }

                        }

                    }

                }

            }

        }

        for(SBQQ__QuoteLine__c quoteLine : quoteLines) {

            Boolean outyearLine = quoteLine.SBQQ__Optional__c;

            outyearLine = (outyearLine && quoteLine.term__c > quoteLine.SBQQ__Quote__r.Current_Year__c);

            Boolean existingLine = (quoteLine.SBQQ__PriorQuantity__c != null && quoteLine.SBQQ__PriorQuantity__c > 0);   

            // where there is no parallel execution occurring, simply update each subscription JSON to match its just-generated amendment quote line         

            if(!parallelChildrenIds.contains(quoteLine.SBQQ__Quote__r.SBQQ__MasterContract__c) && amendmentQuoteIdToChildContractId.containsKey(quoteLine.SBQQ__Quote__c) && !quoteLine.SBQQ__Optional__c && quoteLine.SBQQ__UpgradedSubscription__c != null) {

                SBQQ__Subscription__c subscription = new SBQQ__Subscription__c(
                    
                    Id = quoteLine.SBQQ__UpgradedSubscription__c,
                    
                    jsonString__c = quoteLine.jsonString__c
                    
                );

                System.debug('standard subscription to update: ' + subscription);

                System.debug('quoteLine.Id: ' + quoteLine.Id);

                subscriptionsToUpdate.add(subscription);

            }

            // for outyear lines that have been newly to the quote, map them to their quote

            // each quote needs a list of outyear line ids added newly in case parallel outyear execution occurs

            if(quoteLine.SBQQ__PriorQuantity__c == null && outyearLine && amendmentQuoteIdToChildContractId.containsKey(quoteLine.SBQQ__Quote__c)) {

                System.debug('adding new outyear line to map....');

                System.debug('product name: ' +  + quoteLine.SBQQ__ProductName__c);

                System.debug('quote line id: ' + quoteLine.Id);

                if(amendmentQuoteIdToAddedOutyearLineIds.get(quoteLine.SBQQ__Quote__c) == null) {

                    amendmentQuoteIdToAddedOutyearLineIds.put(quoteLine.SBQQ__Quote__c,new Set<Id>());

                }

                amendmentQuoteIdToAddedOutyearLineIds.get(quoteLine.SBQQ__Quote__c).add(quoteLine.Id);

            }              

        }

        System.debug('amendmentQuoteIdToAddedOutyearLineIds: ' + amendmentQuoteIdToAddedOutyearLineIds);

        if(!parallelChildrenIds.isEmpty()) {

            System.debug('checking parellel children ids: ' + parallelChildrenIds);

            // when parallel execution is occurring, an additional check needs to be made on the subscriptions

            // loop through the subscriptions and update the JSON quantities based on most recent amendment changes

            for(Id subscriptionId : subscriptionMap.keySet()) {

                SBQQ__Subscription__c subscription = subscriptionMap.get(subscriptionId);

                System.debug('*******subscription.Name: ' + subscription.Name);

                Decimal currentYearQuantity = CventMyd_LegacyContractHandler.getCurrentYearQuantity(subscription);

                Decimal nextYearQuantity;

                CventMyd_QuoteLineObject subscriptionLineObject = CventMyd_UtilityMethods.getQuoteLineObject(subscription.jsonString__c);

                String nextYearQleId = subscriptionLineObject.nextYearQleId;

                if(nextYearQleId != null) {

                    nextYearQuantity = Decimal.valueOf(subscriptionLineObject.preCalculationFieldValueMap.get('SBQQ__Quantity__c')[1]);

                }

                System.debug('nextYearQleId: ' + nextYearQleId);

                System.debug('nextYearQuantity: ' + nextYearQuantity);

                Boolean currentYearParallel = false;

                Boolean outyearParallel = false;

                Id nextYearLineId;

                String newNextYearQleId = null;

                // for each subscription, check the quote lines changed to see if a subscription update is required

                for(SBQQ__QuoteLine__c line : quoteLines) {

                    if(amendmentQuoteIdToChildContractId.containsKey(line.SBQQ__Quote__c)) {

                        System.debug('-----> quote line product: ' + line.SBQQ__ProductName__c);

                        System.debug('prior quantity: ' + line.SBQQ__PriorQuantity__c);

                        System.debug('quantity: ' + line.SBQQ__Quantity__c);

                        System.debug('effective quantity: ' + line.SBQQ__EffectiveQuantity__c);

                        CventMyd_QuoteLineObject quoteLineObject = CventMyd_UtilityMethods.getQuoteLineObject(line.jsonString__c);

                        String lineQleId = quoteLineObject.qleId;

                        System.debug('lineQleId: ' + lineQleId);

                        Decimal previousQuantity = (line.SBQQ__PriorQuantity__c != null) ? line.SBQQ__PriorQuantity__c : 0;

                        // if the line was generated from the sub, current year parallel change is occurring

                        if(line.SBQQ__UpgradedSubscription__c == subscription.Id) {

                            currentYearParallel = true;

                            currentYearQuantity += (line.SBQQ__Quantity__c - previousQuantity);

                            if(quoteLineObject.nextYearQleId != nextYearQleId  && nextYearQleId != null) {

                                newNextYearQleId = quoteLineObject.nextYearQleId;

                                System.debug('newNextYearQleId: ' + newNextYearQleId);

                            }                            

                        }

                        // if the line's qleId is the nextYearQleId of the sub, outyear parallel change is occurring

                        if(nextYearQleId == lineQleId) {

                            outyearParallel = true;

                            nextYearQuantity += (line.SBQQ__Quantity__c - previousQuantity);              

                            nextYearLineId = line.Id;
                            
                            System.debug('nextYearLineId: ' + nextYearLineId);
							System.debug('quoteLineIdToOutyearLineWrapper>>'+quoteLineIdToOutyearLineWrapper);
                            System.debug('subscription>>>>'+subscription);
                            System.debug('quoteLineIdToOutyearLineWrapper.containsKey(nextYearLineId)>>'+quoteLineIdToOutyearLineWrapper.containsKey(nextYearLineId));
                            if(quoteLineIdToOutyearLineWrapper.containsKey(nextYearLineId))
                            {
                                if(quoteLineIdToOutyearLineWrapper.get(nextYearLineId) != NULL)
                            		quoteLineIdToOutyearLineWrapper.get(nextYearLineId).subscription = subscription;
                            }

                        }

                    }           

                }

                System.debug('is outyear parallel execution occurring?: ' + outyearParallel);

                System.debug('is current year parallel execution occurring?: ' + currentYearParallel);

                System.debug('currentYearQuantity: ' + currentYearQuantity);

                System.debug('nextyearQuantity: ' + nextyearQuantity);

                String subscriptionJson = subscription.jsonString__c;

                if(currentYearParallel) {

                    subscriptionJson = CventMyd_UtilityMethods.replaceJsonStringKeyValue(subscriptionJson,'SBQQ__Quantity__c',String.valueOf(currentYearQuantity),0);

                }

                if(outyearParallel) {

                    subscriptionJson = CventMyd_UtilityMethods.replaceJsonStringKeyValue(subscriptionJson,'SBQQ__Quantity__c',String.valueOf(nextYearQuantity),1);

                }

                if(newNextYearQleId  != null) {
                
                    System.debug('this should be getting printed at least once...., newNextYearQleId= ' + newNextYearQleId);
                    String originalNextYearQleId = subscriptionJson.substringBetween('"nextYearQleId":"','"');
                    String nextYearQleIdSubString = '"nextYearQleId":"' + originalNextYearQleId + '"';
                    String replacementSubstring = nextYearQleIdSubString.replace(originalNextYearQleId,newNextYearQleId);
                    subscriptionJson = subscriptionJson.replace(nextYearQleIdSubString,replacementSubstring);

                }

                subscriptionsToUpdate.add(new SBQQ__Subscription__c(Id = subscriptionId,jsonString__c = subscriptionJson)); 

            }

            for(Id quoteLineId : quoteLineIdToOutyearLineWrapper.keySet()) {

                OutyearLineWrapper wrapper = quoteLineIdToOutyearLineWrapper.get(quoteLineId);

                if(wrapper != null) {

                    SBQQ__QuoteLine__c currentQuoteLine = wrapper.currentQuoteLine;

                    SBQQ__QuoteLine__c previousQuoteLine = wrapper.previousQuoteLine;

                    SBQQ__Subscription__c subscription = wrapper.subscription;

                    Decimal quantity;

                    if(subscription != null) {

                        CventMyd_QuoteLineObject lineObject = CventMyd_UtilityMethods.getQuoteLineObject(subscription.jsonString__c);

                        quantity = Decimal.valueOf(lineObject.preCalculationFieldValueMap.get('SBQQ__Quantity__c')[1]);

                    }

                    else {

                        quantity = previousQuoteLine.SBQQ__Quantity__c;

                    }

                    Decimal previousQuantity = (currentQuoteLine.SBQQ__PriorQuantity__c != null) ? currentQuoteLine.SBQQ__PriorQuantity__c : 0;

                    quantity += (currentQuoteLine.SBQQ__Quantity__c - previousQuantity);

                    System.debug('need to update JSON on changed outyearLine, the id is: ' + quoteLineId);

                    String outyearJsonString = currentQuoteLine.jsonString__c;

                    System.debug('json string before: ' + outyearJsonString);

                    parallelAmendmentQuoteIdsToLock.add(currentQuoteLine.SBQQ__Quote__c);

                    outyearJsonString = CventMyd_UtilityMethods.replaceJsonStringKeyValue(outyearJsonString, 'SBQQ__Quantity__c', String.valueOf(quantity), 0);

                    CventMyd_QuoteLineObject currentLineObject = CventMyd_UtilityMethods.getQuoteLineObject(currentQuoteLine);

                    System.debug('inserting on next current year (current line): ' + currentLineObject.insertOnNextCurrentYear);

                    if(quantity > 0) {

                        if(currentLineObject.insertOnNextCurrentYear != null && !currentLineObject.insertOnNextCurrentYear) {

                            CventMyd_QuoteLineObject previousLineObject = CventMyd_UtilityMethods.getQuoteLineObject(previousQuoteLine);

                            System.debug('inserting on next current year (previous line): ' + previousLineObject.insertOnNextCurrentYear);

                            if(previousLineObject.insertOnNextCurrentYear != null && previousLineObject.insertOnNextCurrentYear) {

                                outyearJsonString = outyearJsonString.replace('"insertOnNextCurrentYear":false','"insertOnNextCurrentYear":true');

                            }

                        }

                    }

                    System.debug('json string after: ' + outyearJsonString);

                    outyearLinesToUpdateJson.add(new SBQQ__QuoteLine__c(Id = quoteLineId,jsonString__c = outyearJsonString)); 

                }               

            }

            for(Id quoteId : amendmentQuoteIdToChildContractId.keySet()) {

                Id childContractId = amendmentQuoteIdToChildContractId.get(quoteId);

                Id mostRecentAmendmentQuoteId = contractIdToLastAmendmentQuoteId.get(childContractId);

                recentParallelIdToJustExecutedId.put(mostRecentAmendmentQuoteId,quoteId);

                System.debug('mostRecentAmendmentQuoteId: ' + mostRecentAmendmentQuoteId);

                System.debug('quoteId: ' + quoteId);

            }            

        }

        if(!recentParallelIdToJustExecutedId.keySet().isEmpty()) {

            for(SBQQ__Quote__c quote : [SELECT
            
                Id,SBQQ__MasterContract__c,parallelLineAdditionIds__c
                
                FROM SBQQ__Quote__c
                
                WHERE Id IN: recentParallelIdToJustExecutedId.keySet()
                
            ]) {

                Id justExecutedId = recentParallelIdToJustExecutedId.get(quote.Id);

                System.debug('justExecutedId: ' + justExecutedId);

                System.debug('recent parallel id: ' + quote.Id);

                Set<Id> recentParallelOutyearLineIds = new Set<Id>();

                Set<Id> justAddedOutyearLineIds = new Set<Id>();

                if(amendmentQuoteIdToAddedOutyearLineIds.get(quote.Id) != null) {

                    recentParallelOutyearLineIds = amendmentQuoteIdToAddedOutyearLineIds.get(quote.Id);

                }

                if(amendmentQuoteIdToAddedOutyearLineIds.get(justExecutedId) != null) {

                    justAddedOutyearLineIds = amendmentQuoteIdToAddedOutyearLineIds.get(justExecutedId);

                }

                Set<Id> outyearLineIds = justAddedOutyearLineIds;

                outyearLineIds.addAll(recentParallelOutyearLineIds);

                System.debug('recent parallel quote: ' + quote);

                if(quote.parallelLineAdditionIds__c != null) {

                    outyearLineIds = (outyearLineIds == null) ? new Set<Id>() : outyearLineIds ;

                    for(String additionalId : quote.parallelLineAdditionIds__c.split(';')) {

                        outyearLineIds.add(Id.valueOf(additionalId));

                    }

                    System.debug('adding outyear parallel line additions from last contracted quote: '  + outyearLineIds);

                    amendmentQuoteIdToAddedOutyearLineIds.put(justExecutedId,outyearLineIds);

                }

            }

        }

        if(!subscriptionsToUpdate.isEmpty()) {

            update subscriptionsToUpdate;

        }

        if(!parallelAmendmentQuoteIdsToLock.isEmpty()) {

            List<SBQQ__Quote__c> quotesToLock = new List<SBQQ__Quote__c>();

            System.debug('locking parallel amendment quote ids: ' + parallelAmendmentQuoteIdsToLock);

            for(Id quoteId : parallelAmendmentQuoteIdsToLock) {

                SBQQ__Quote__c quoteToLock = new SBQQ__Quote__c(Id = quoteId,parallelExecutionLock__c = true);

                System.debug('locking quote per outyear parallel execution, Id: ' + quoteToLock.Id);

                Set<Id> outyearLineIds = amendmentQuoteIdToAddedOutyearLineIds.get(quoteId);

                if(outyearLineIds != null) {

                    String parallelLineAdditionIds = CventMyd_UtilityMethods.getIdString(outyearLineIds,';');

                    quoteToLock.parallelLineAdditionIds__c = parallelLineAdditionIds;

                    System.debug('outyearLineIds: ' + outyearLineIds);

                }

                quotesToLock.add(quoteToLock);

                amendmentQuoteIdToAddedOutyearLineIds.remove(quoteId);

            }

            SBQQ.TriggerControl.disable();

            update quotesToLock;

            update outyearLinesToUpdateJson;

            SBQQ.TriggerControl.enable();

        }

        System.debug('amendmentQuoteIdToAddedOutyearLineIds.keySet(): ' + amendmentQuoteIdToAddedOutyearLineIds.keySet());

        if(!amendmentQuoteIdToAddedOutyearLineIds.isEmpty()) {

            List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();

            for(Id quoteId : amendmentQuoteIdToAddedOutyearLineIds.keySet()) {

                System.debug('preparing to update quote with outyear line ids....');

                SBQQ__Quote__c quote = new SBQQ__Quote__c(Id = quoteId);

                Set<Id> outyearLineIds = amendmentQuoteIdToAddedOutyearLineIds.get(quoteId);

                String lineAdditionIdString = CventMyd_UtilityMethods.getIdString(outyearLineIds,';');

                quote.parallelLineAdditionIds__c = lineAdditionIdString;

                System.debug('quote: ' + quote);

                quotes.add(quote);

            }

            SBQQ.TriggerControl.disable();

            update quotes;

            SBQQ.TriggerControl.enable();

        }

        //throw new CventMyd_UtilityMethods.TwinFieldException('throwing this exception to prevent the completion ot the asynchronous contracting operation...');

    }

    public static void handleAfterUpdate() {

        Map<Id,Date> accountIdToUpdateToEndDate = new Map<Id,Date>();

        for(Contract contract : (List<Contract>)Trigger.new) {

            Boolean updateAccount = ( accountIdToEndDate.get(contract.AccountId) != null && accountIdToEndDate.get(contract.AccountId) != contract.EndDate );

            Boolean endDateChanged = (Date)Trigger.oldMap.get(contract.Id).get('EndDate') != contract.EndDate;

            Boolean accountIdChanged = (Id)Trigger.oldMap.get(contract.Id).get('AccountId') != contract.AccountId;

            if(contract.RecordTypeId == CventMyd_Settings.parentContractRecordTypeId && (updateAccount || endDateChanged)) {

                accountIdToUpdateToEndDate.put(contract.AccountId,contract.EndDate);

            }

            if(accountIdToUpdateToEndDate.size() > 0) {

                updateEndDatesOnAccounts(accountIdToUpdateToEndDate);

            }

            if(contract.RecordTypeId == CventMyd_Settings.parentContractRecordTypeId) {

                Boolean termChanged = CventMyd_UtilityMethods.didFieldChange(contract,'Contract_Term_Years__c');

                if(termChanged && !parentContractIdsToCheck.contains(contract.Id)) {

                    parentContractIdsToCheck.add(contract.Id);

                }

            }

        }

        if(!parentContractIdsToCheck.isEmpty() && parentContractIdsToCheck.size() < 5) {

            String errorString = CventMyd_ValidationHandler.getNegativeTermErrors(parentContractIdsToCheck);

            if(!String.isBlank(errorString)) {
                
                for(Sobject contract : Trigger.new) {

                    contract.addError(errorString);

                }

            }

        }        

    }

    public static void updateEndDatesOnAccounts(Map<Id,Date> accountIdToUpdateToEndDate) {

        List<Account> accountsToUpdate = new List<Account>();

        for(Id accountId : accountIdToUpdateToEndDate.keySet()) {

            Account account = new Account(Id = accountId, Contract_End_Date_Dev__c = accountIdToUpdateToEndDate.get(accountId));

            accountsToUpdate.add(account);

            accountIdToEndDate.put(accountId,accountIdToUpdateToEndDate.get(accountId));

        }

        update accountsToUpdate;
                       
    }
    
}