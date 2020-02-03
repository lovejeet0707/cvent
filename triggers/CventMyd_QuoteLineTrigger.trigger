trigger CventMyd_QuoteLineTrigger on SBQQ__QuoteLine__c (before insert,before update) {
    CventMyd_QuoteLineTriggerHandler.setNetAmountCrm();
}