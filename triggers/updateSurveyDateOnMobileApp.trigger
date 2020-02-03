//Test Class - updateSurveyDateTest,doceboUserTrgHandlerTest,ChatterPostNotificationTest
trigger updateSurveyDateOnMobileApp on Mobile_Card__c (after update, after Insert) {
    MobileAppTrgHandler handler = new MobileAppTrgHandler();
    if(Trigger.isAfter && Trigger.isUpdate)
    {
        MobileAppTriggerHelper.updateSurveyDateOnMobileApp(Trigger.new, Trigger.oldMap);
        MobileAppTriggerHelper.mobileAppChatterFieldNotificationforUpdate(Trigger.new,Trigger.oldMap);
        MobileAppTriggerHelper.crowdCompassChatterAlert(Trigger.newMap,Trigger.oldMap);
    }
    if(Trigger.isAfter && Trigger.isInsert)
    {
        MobileAppTriggerHelper.crowdCompassChatterAlert(Trigger.newMap,null);
        if(CheckRecursive.runForty())
        {
            MobileAppTriggerHelper.mobileAppChatterFieldNotificationforInsert(Trigger.new);
        }
    }
   if(Trigger.IsAfter && Trigger.IsInsert && Boolean.ValueOf(Label.IsDoceboCodeActive)){
     handler.onAfterInsert(Trigger.new);
   }
}