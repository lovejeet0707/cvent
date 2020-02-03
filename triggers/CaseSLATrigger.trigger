/**
* Case trigger for Case status update
* Requires an email was sent out or created a new Case Comment 
* for the case to save if the status is updated to:
* Open-Investigating, Waiting and Updated
* 
* 
* @author L. Lavapie
* @date 03.APR.2015
*/
trigger CaseSLATrigger on Case ( before update, before insert, after insert, after update) {

    CaseSLAComplianceClass triggerClass= new CaseSLAComplianceClass();

    //Added by JBarrameda - 04/29/2015
    BypassTriggerUtility u = new BypassTriggerUtility();  
    if (u.isTriggerBypassed()) {
         return;
    }   
    //End

   // Call on before update
    if(Trigger.isBefore && Trigger.isUpdate){
        triggerClass.checkStatus(Trigger.newMap, Trigger.oldMap);
    }
    
    if(Trigger.isBefore && Trigger.isInsert){
        triggerClass.initialResponseSLA(Trigger.new);
    }
}