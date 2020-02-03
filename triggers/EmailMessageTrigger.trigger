/**=====================================================================
 * Cvent
 * Name: EmailMessageTrigger
 * Description: Trigger on Email Message
 * Created Date: [27/04/2016]
 * Created By: Hemant Rana
 * 
 * Date Modified                Modified By                  Description of the update
 * [MON DD, YYYY]               [FirstName LastName]         [Short description for changes]
 =====================================================================*/ 
 
trigger EmailMessageTrigger on EmailMessage (before insert, before update, before delete, after insert, after delete, after update, after undelete) {//EmailDeletionRestriction 
    EmailMessageTriggerHandler handlerObj = new EmailMessageTriggerHandler();
    handlerObj.processAllTriggerEvents(trigger.new, trigger.newMap,  trigger.Old, trigger.oldMap, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete, Trigger.isBefore, Trigger.isAfter, Trigger.isUnDelete);
}