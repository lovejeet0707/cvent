/**=====================================================================
 * Cvent
 * Name: EmailMessageTriggerHandler
 * Description: Trigger Handler for EmailMessageTrigger
 * Created Date: [27/04/2016]
 * Created By: Hemant Rana
 * 
 * Date Modified                Modified By                  Description of the update
 * [MON DD, YYYY]               [FirstName LastName]         [Short description for changes]
 =====================================================================*/ 

public class EmailMessageTriggerHandler{
//public static boolean isCurrentlyInExecution = false;
    public void processAllTriggerEvents(List<EmailMessage> triggerNew, Map<Id, EmailMessage> triggerNewMap,  List<EmailMessage> triggerOld, Map<Id, EmailMessage> triggerOldMap, Boolean isInsert, Boolean isUpdate, Boolean isDelete, Boolean isBefore, Boolean isAfter, Boolean isUnDelete){
        //if(isCurrentlyInExecution){
            //Dont do anything. Simply return as this is a recursion. This will break the flow.
         //   return;
        //} else {
            //Set the flag for the first time this trigger is called in a transaction.
         //   isCurrentlyInExecution = true;
       // }

        /* A custom setting flag could be used to bypass all EmailMessage Triggers. This is very handy when you load data in SFDC and dont want to run Triggers on a given object */
        /*if(TriggerExemptSettings__c.getValues('Global') != null){
            if(TriggerExemptSettings__c.getValues('Global').Exempt_Account_Triggers__c){
                //Exempt Flag Set
                System.debug('*** EmailMessage TRIGGERS ARE SET TO BE EXEMPTED FOR EXECUTION. Please check TriggerExemptSettings__c Custom Setting **** ');
                return;
            }
        }*/
        
        /* Execute any Common SOQL that would get all the data you need for all the triggers being consolidated. You can pass on the 
        results of these SOQL as a parameter to the various event handler methods for further processing */
    
        /*  BEFORE INSERT. You can also join multiple BEFORE Events like Before Update/Before Insert if you like. */
        if(isInsert && isBefore){
           
        }
        
        /* BEFORE UPDATE Event */
        if(isUpdate && isBefore){
            //OnBeforeUpdate(triggerOld, triggerOldMap, TriggerNew, triggerNewMap);
        }

        /* AFTER UPDATE Event */
        if(isUpdate && isAfter){
            //OnAfterUpdate(triggerOld, triggerOldMap, TriggerNew, triggerNewMap);
        }
        System.debug('isBefore===>'+isBefore);
        System.debug('isDelete===>'+isDelete);
        /* BEFORE DELETE Event */
        if(isBefore && isDelete){
            System.debug('Inside This');
            OnBeforeDelete(triggerOld, triggerOldMap);
        }

    }

/* Event Handlers */
    //public void OnBeforeUpdate(List<EmailMessage>  triggerOld, Map<ID, EmailMessage> triggerOldMap, List<EmailMessage>  triggerNew, Map<ID, EmailMessage> triggerNewMap){
        //Do all your before update logic here. 
    //}
    /** 27/04/2016 Added By Hemant: Restriction of email deletion of below cases by users having profile other than SystemAdmin and having record type="Billing Cases" and Parent Id having Case id**/
    public void OnBeforeDelete( List<EmailMessage> triggerOld, Map<Id, EmailMessage> triggerOldMap){
        //Getting users of a Public Group to by pass this validation "Collection_Mgmt_Group"
        Set<Id> groupUserIds = new Set<Id>();
        for (GroupMember gm : [select 
                                     UserOrGroupId
                                  from GroupMember 
                                  where group.DeveloperName = 'Collection_Mgmt_Group']) {
               groupUserIds.add(gm.UserOrGroupId);
           }
        System.debug('=====>groupUserIds'+groupUserIds);
        System.debug('inside this method');
        Profile p = [SELECT Id,Name FROM Profile WHERE Name = 'System Administrator'];
        if(p.Id != UserInfo.getProfileId() && !groupUserIds.contains(userinfo.getuserid())){
            Map<Id,Id> emailIdVSCaseIdMap=new Map<Id,Id>();
            Map<Id,Id> caseIdVsRecordTypeIdMap=new Map<Id,Id>(); 
            For(EmailMessage emailMessageRec : triggerOld)
            {
                if(emailMessageRec.ParentId!=null && String.valueOf(emailMessageRec.ParentId).substring(0,3)=='500')
                    emailIdVSCaseIdMap.put(emailMessageRec.Id,emailMessageRec.ParentId);
            }
            if(emailIdVSCaseIdMap.size()>0){
                Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Billing Cases').getRecordTypeId();//Billing_Cases
                For(Case caseObj : [SELECT RecordTypeId,Id FROM Case WHERE Id IN : emailIdVSCaseIdMap.values()])
                {
                    if(caseObj.RecordTypeId!=null && caseObj.RecordTypeId==devRecordTypeId)
                        caseIdVsRecordTypeIdMap.put(caseObj.Id,caseObj.RecordTypeId);
                }
                For(EmailMessage emailMessageRec : triggerOld)
                {
                    if(caseIdVsRecordTypeIdMap.containsKey(emailMessageRec.ParentId))//==devRecordTypeId)//emailMessageRec.ParentId!=null && String.valueOf(emailMessageRec.ParentId).substring(0,3)=='500' && 
                    {
                        emailMessageRec.ParentId.addError('You are not authorized to delete the email message');
                    }
                }
            }
        }
    }

    
   // public void OnAfterUpdate(List<EmailMessage> triggerNew, Map<Id, EmailMessage> triggerNewMap,  List<EmailMessage> triggerOld, Map<Id, EmailMessage> triggerOldMap){
        
   // }
  
}