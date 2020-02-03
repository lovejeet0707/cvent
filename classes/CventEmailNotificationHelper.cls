/*
 * Class Name: CventEmailNotificationHelper
 * Description: This class is at the core of the Custom Email Notification framework. It run in admin context and provides for the helper methods to create and insert record(s)
 *              in the Email Notification object.
 *              Cvent Email Notification framework is developed to support email notifications (can also configure field updates, task creation using the same native rules) for 
 *              1) Objects like Account Team that doesn't provide for native workflow email alerts
 *              2) Custom/Special use cases where a personalized email is to be sent out based on derived values. Example: Release Management 
 *              
 *              The framework comprises of  
 *              - Custom Object "Cvent Email Notification": Any record created in this object should trigger an email alert (using native workflow on this object) using 
 *                the Recipient and Subject information. It also supports Time Based notification based on the date field "Trigger_Time__c"
 *              - Class "CventEmailNotificationHelper": Provides helper methods to support DML on custom object
 *              - Class "Batch_PurgeCventEmailNotification": Batch job to purge all expired notification records (records created as of yesterday and (Trigger_Time__c is null or elapsed))
 *              - Class "Scheduler_Batch_PurgeCventEmailNotification": Scheduler class to schedule the purge batch job
 *              - Class "Test_CventEmailNotificationFramework": Testcases and related coverage for all components in this framework
 *              
 *              Sample snippet to create a notification record using this helper class:
 *              CventEmailNotificationHelper.insertEmailNotification('005o0000002QrNR','Praveen Kaushik', 'Test 1', 'pkaushik@cvent.com', CventEmailNotificationHelper.SourceProcessName.ReleaseManagement, null, 'CRM_Project__c', 'aAE7A0000008OLT', null, null);
 * 
 *  History:
 *  Date            Version     Change/Description                          Author
 * -------------------------------------------------------------------------------------------
 *  April 27, 2016  1.0         Created                                     Praveen Kaushik
 * -------------------------------------------------------------------------------------------
*/
public without sharing class CventEmailNotificationHelper {
    /* Custom Exception Class for this Framework */
    public class NotificationFrameworkException extends Exception {}
    
    public static boolean isEmailSent = false;
    
    /* Enum to enforce valid values for Source Process Name */
    public enum SourceProcessName {ReleaseManagement, AccountTeamAssignment, Other}

    /* Initializes and Returns a new Cvent_Email_Notification__c record */
    public static Cvent_Email_Notification__c createEmailNotification() {
        Cvent_Email_Notification__c notification = new Cvent_Email_Notification__c();
        return notification;
    }
    
    /* Initializes and Returns a new Cvent_Email_Notification__c record. The caller has the responsibility to insert the newly initialized record */
    public static Cvent_Email_Notification__c createEmailNotification(String recipeintId, String recipientName, String emailSubject, String emailAddress, SourceProcessName processName, 
                                                                            Datetime triggerTime, String sourceRecordId, String objectAPIName,  String attribute1, String attribute2, String releaseName) {
        if(isBlank(emailAddress)){
            throw new NotificationFrameworkException('A valid email address is required.');
        }
        Cvent_Email_Notification__c notification = createEmailNotification();
        notification.Recipient_User_Id__c = recipeintId;
        notification.Recipient_Name__c = recipientName;
        notification.Email_Subject__c = emailSubject;
        notification.Recipient_Email__c = emailAddress;
        notification.Source_Process__c = processName.name();
        notification.Source_Object_API_Name__c = objectAPIName;
        notification.Source_Record_Id__c = sourceRecordId;
        notification.Placeholder_Attribute_1__c = attribute1 != null ? attribute1 : '';
        notification.Placeholder_Attribute_2__c = attribute2 != null ? attribute2 : '';
        notification.Trigger_Time__c = triggerTime != null ? triggerTime : null;
        notification.Release__c = releaseName;
        return notification;
    }

    /* Inserts a new Cvent_Email_Notification__c record. This is different from createEmailNotification which only initializes the record */
    public static Cvent_Email_Notification__c insertEmailNotification(String recipeintId, String recipientName, String emailSubject, String emailAddress, SourceProcessName processName, 
                                                                            Datetime triggerTime, String sourceRecordId, String objectAPIName,  String attribute1, String attribute2, String releaseName) {
        Cvent_Email_Notification__c notification = createEmailNotification(recipeintId, recipientName, emailSubject, emailAddress, processName, triggerTime, sourceRecordId, objectAPIName, attribute1, attribute2,releaseName);
        insert notification;
        return notification;
    }
    
    /* Returns true if the string passed as parameter is either NULL or BLANK */
    private static boolean isBlank(String strValue){
        return (strValue == null || String.isBlank(strValue));
    }
    
    
}