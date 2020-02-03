trigger MobileAppBefore on Mobile_Card__c (before insert,before update,before delete){
    String runCCAutomationProcess = Label.Run_CC_Automation_Process;
    
     // CC Automation - Mobile App Pre-Populate Data Handler executes in Before Insert Context
    CCMobileAppPrePopulateDataTrig_Act updateMobileApp = new CCMobileAppPrePopulateDataTrig_Act();
    if(Boolean.valueOf(runCCAutomationProcess) && updateMobileApp.shouldRun()) updateMobileApp.doAction();
    
    // CC Automation - Mobile App Auto-Assignment Handler executes in Before Insert/ UpdateContext
    CCMobileAppAutoAssignment_TrigAct mobileAppAutomation = new CCMobileAppAutoAssignment_TrigAct();
    if(Boolean.valueOf(runCCAutomationProcess) && mobileAppAutomation.shouldRun()) mobileAppAutomation.doAction();
}