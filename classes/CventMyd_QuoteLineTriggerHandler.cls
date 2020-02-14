public without sharing class CventMyd_QuoteLineTriggerHandler {
    public static void setNetAmountCrm() {
        for(SBQQ__QuoteLine__c quoteLine : (List<SBQQ__QuoteLine__c>)Trigger.New) {
            quoteLine.Net_Amount_CRM__c = quoteLine.SBQQ__NetTotal__c;
        }
    }
}