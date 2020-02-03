//
trigger QuoteLineTrigger on SBQQ__QuoteLine__c (before update, before insert, after update, after insert) {

    System.debug('QuoteLineTrigger');
    
    if(Trigger.isBefore) {
        if(Trigger.isInsert) {
            QuoteLineTriggerHandler.calculateEffectiveAmounts(Trigger.new);
        }
        if(Trigger.isUpdate) {
            QuoteLineTriggerHandler.calculateEffectiveAmounts(Trigger.new);
        }
    }
}