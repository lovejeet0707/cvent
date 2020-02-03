@isTest
public class SettingUtilTest {
    
    @isTest
    public static void setUtilTest() {
        Trigger_Setting__c setting = new Trigger_Setting__c();
        setting.Name = 'ApprovalTrigger';
        setting.Is_On__c = true;
        
        insert setting;
        
        //SettingUtil settingClass = new SettingUtil();
        Boolean triggerFlag = SettingUtil.isTriggerOn('ApprovalTrigger');
        system.assertEquals(triggerFlag, true);
    }
    
}