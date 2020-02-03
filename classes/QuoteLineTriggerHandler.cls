/*------------------------------------------------------------
Description: SBQQ__QuoteLine__c trigger handler
Test Class: QuoteLineTriggerHandlerTest
History:
04/16/2017 - Karl Andrzejewski (ATG) - Initial Creation
05/12/2017 - Karl Andrzejewski (ATG) - Added handling list price.


------------------------------------------------------------*/

public class QuoteLineTriggerHandler {
    
    
    public static void calculateEffectiveAmounts(List<SBQQ__QuoteLine__c> quoteLines) {
        
        Set<ID> quotes = new Set<ID>();
        for(SBQQ__QuoteLine__c quoteLine : quoteLines) {
            quotes.add(quoteLine.SBQQ__Quote__c);
        }
        
        Map<ID, SBQQ__Quote__c> quotesMap = new Map<ID, SBQQ__Quote__c>([select ID, Contract_Remaining_Term__c from SBQQ__Quote__c where ID in :quotes]);

        for(SBQQ__QuoteLine__c quoteLine : quoteLines) {
            //SBQQ__Quote__c q = quotesMap.get(quoteLine.SBQQ__Quote__c);
            Integer remainingTerm = Integer.valueOf(quotesMap.get(quoteLine.SBQQ__Quote__c).Contract_Remaining_Term__c);
            System.debug('Contract Term Years: ' + remainingTerm);
            quoteLine.Year_2_Effective_Amount__c = NULL;
            quoteLine.Year_3_Effective_Amount__c = NULL;
            quoteLine.Year_4_Effective_Amount__c = NULL;
            quoteLine.Year_5_Effective_Amount__c = NULL;

            if(remainingTerm >= 2) {
                if(quoteLine.Year_2_Net_Amount__c == NULL) {
                    quoteLine.Year_2_Effective_Amount__c = quoteLine.SBQQ__NetTotal__c;
                } else {
                    quoteLine.Year_2_Effective_Amount__c = quoteLine.Year_2_Net_Amount__c;
                }
            }
            if(remainingTerm >= 3) {
                if(quoteLine.Year_3_Net_Amount__c == NULL) {
                    quoteLine.Year_3_Effective_Amount__c = quoteLine.Year_2_Effective_Amount__c;
                } else {
                    quoteLine.Year_3_Effective_Amount__c = quoteLine.Year_3_Net_Amount__c;
                }
            }
            if(remainingTerm >= 4) {
                if(quoteLine.Year_4_Net_Amount__c == NULL) {
                    quoteLine.Year_4_Effective_Amount__c = quoteLine.Year_3_Effective_Amount__c;
                } else {
                    quoteLine.Year_4_Effective_Amount__c = quoteLine.Year_4_Net_Amount__c;
                }
            }
            if(remainingTerm >= 5) {
                if(quoteLine.Year_5_Net_Amount__c == NULL) {
                    quoteLine.Year_5_Effective_Amount__c = quoteLine.Year_4_Effective_Amount__c;
                } else {
                    quoteLine.Year_5_Effective_Amount__c = quoteLine.Year_5_Net_Amount__c;
                }
            }
        }
        System.debug('Effective amounts calculation.');
    }
}