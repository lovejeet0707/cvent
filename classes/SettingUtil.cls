/**
 * Name: SettingUtil
 * Author: Simplus
 * Created Date: 11 Dec 2019
 * Description: Utility class to retrieve Custom Setting values
 * History:[Author] [Modified Date] [Modification Reason]
**/
public Class SettingUtil {
    
    //Custom Setting API Name: Trigger_Setting__c
    //Custom Field: Is_On__c - Checkbox DataType - Default Value: Checked
    public static Boolean isTriggerOn(String triggerName) 
    {
        Boolean result = true; //If no setting, will return default value true;
        
        Trigger_Setting__c setting = Trigger_Setting__c.getInstance(triggerName);
        if(setting != null)
            result = setting.Is_On__c;
        
        return result;
    }
}