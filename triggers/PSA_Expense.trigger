trigger PSA_Expense on pse__Expense__c (before insert, before update, after insert, after update) {
    if(PSA_Utils.IsDataLoadMode && !test.IsRunningTest()) return;
    if(trigger.isBefore) {
        PSA_expenseTriggerHandler.setExpenseType(trigger.new);
    }
    if(trigger.isAfter) {
        PSA_expenseTriggerHandler.createExpenseShare(trigger.newMap);
    }
}