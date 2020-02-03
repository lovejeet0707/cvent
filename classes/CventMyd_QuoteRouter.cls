public without sharing class CventMyd_QuoteRouter {

    // all newly inserted amendment and renewal quotes will be passed to this method after they are updated (after their quote lines are inserted)

    public static void routeQuotes(Set<Id> quoteIds) {

        Map<Id,List<Integer>> quoteIdToOutyearsToCreateFromPreviousQuote = new Map<Id,List<Integer>>();

        Map<Id,List<Integer>> quoteIdToOutyearsToCreateFromLegacySubscriptions = new Map<Id,List<Integer>>();

        Integer quoteLineMaxCount = CventMyd_Settings.quoteLineMaxCount;

        for(Id quoteId : quoteIds) {

            SBQQ__Quote__c quote = (SBQQ__Quote__c)Trigger.newMap.get(quoteId);

            CventMyd_QuoteObject quoteObject = CventMyd_UtilityMethods.getQuoteObject(quote);

            Map<String,Boolean> quoteStatusMap = CventMyd_UtilityMethods.getQuoteStatusMap(quoteObject);

            Opportunity opportunity = CventMyd_QuoteTriggerHandler.quoteInsertionIdToOpportunity.get(quoteObject.insertionId);

            Id contractId = (quote.SBQQ__Type__c == 'Amendment') ? opportunity.SBQQ__AmendedContract__c : opportunity.SBQQ__RenewedContract__c;

            Integer outyearLineCount = (quote.Multiple_Years_Commitment__c) ? (Integer)(quote.previousQuoteLineCount__c - quote.previousQuoteNonOptionalLineCount__c) : 0;

            if(quote.SBQQ__LineItemCount__c > 0 && outyearLineCount > 0 && !quote.createdFromLegacyContract__c && quote.previousQuote__c != null) {

                // Boolean createAllYears = (outyearLineCount <= quoteLineMaxCount);

                Boolean createAllYears = true;

                List<Integer> outyearsToCreate = CventMyd_UtilityMethods.getQuoteOutyears(quote,createAllYears);

                quoteIdToOutyearsToCreateFromPreviousQuote.put(quoteId,outyearsToCreate);

            }

            else if(quote.SBQQ__LineItemCount__c > 0 && quote.createdFromLegacyContract__c && quote.previousQuote__c == null) {

                List<SBQQ__Subscription__c> subscriptions = ContractTrgHelperCls.legacyContractIdToSubscriptions.get(contractId);

                Integer expectedQuoteLineCount = CventMyd_LegacyContractHandler.getExpectedQuoteLineCount(subscriptions,quote.SBQQ__Type__c);

                System.debug('expectedQuoteLineCount: ' + expectedQuoteLineCount);

                System.debug('actualQuoteLineCount: ' + quote.SBQQ__LineItemCount__c);               

                if(quote.SBQQ__LineItemCount__c >= expectedQuoteLineCount && quote.Multiple_Years_Commitment__c) {

                    Integer expectedNumberOfQuoteLineGroups = CventMyd_UtilityMethods.getExpectedNumberOfQuoteLineGroups(quote);

                    // Boolean createAllYears = quote.nonOptionalLineCount__c * (expectedNumberOfQuoteLineGroups - 1) <= quoteLineMaxCount;

                    Boolean createAllYears = true;

                    List<Integer> outyearsToCreate = CventMyd_UtilityMethods.getQuoteOutyears(quote,createAllYears);

                    quoteIdToOutyearsToCreateFromLegacySubscriptions.put(quoteId,outyearsToCreate);

                }

            }

        }

        System.debug('quoteIdToOutyearsToCreateFromPreviousQuote: ' + quoteIdToOutyearsToCreateFromPreviousQuote);

        System.debug('quoteIdToOutyearsToCreateFromLegacySubscriptions: ' + quoteIdToOutyearsToCreateFromLegacySubscriptions);

        System.debug('Apex limits: ' + CventMyd_UtilityMethods.getApexLimitsString());

        if(quoteIdToOutyearsToCreateFromPreviousQuote.keySet().size() > 0) {

            CventMyd_LineAndGroupHandler.createOutyearsFromPreviousQuote(quoteIdToOutyearsToCreateFromPreviousQuote);

        }

        if(quoteIdToOutyearsToCreateFromLegacySubscriptions.keySet().size() > 0) {

            CventMyd_LegacyContractHandler.createOutyearsFromLegacySubscriptions(quoteIdToOutyearsToCreateFromLegacySubscriptions);         

        }

    }

}