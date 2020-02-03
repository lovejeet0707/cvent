trigger PSA_ExpenseReport on pse__Expense_Report__c (before insert, before update, after insert, after update) {
    if(PSA_Utils.IsDataLoadMode && !test.IsRunningTest()) return;
    if(trigger.isBefore){
        PSA_ExpenseReportTriggerHandler.populateApprover(trigger.new);
    }
    
    if(trigger.isAfter) {
        PSA_ExpenseReportTriggerHandler.handleNewExpenseReport(trigger.new);
        PSA_ExpenseReportTriggerHandler.createExpenseReportShare(trigger.newMap);
    }
}