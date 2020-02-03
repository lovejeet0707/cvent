trigger MobileAppAfter on Mobile_Card__c (after insert,after update,after delete,after undelete){
    String runCCAutomationProcess = Label.Run_CC_Automation_Process;
    
    // CC Automation - Mobile App Rollup Handler
    CCMobileAppAssignmentRollup_TrigAct mobileAppRollup = new CCMobileAppAssignmentRollup_TrigAct();
    if(Boolean.valueOf(runCCAutomationProcess) && mobileAppRollup.shouldRun()) mobileAppRollup.doAction();
    
    // CC Automation - Mobile App Auto Send CC Form Handler and Responsible for Sending Normal ABP Form to Customer
    CCMobileAppAutoSendCCForm_TrigAct runAutoEmailHandler = new CCMobileAppAutoSendCCForm_TrigAct();
    if(Boolean.valueOf(runCCAutomationProcess) && runAutoEmailHandler.shouldRun()) runAutoEmailHandler.doAction();
}