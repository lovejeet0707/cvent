trigger CventMyd_CpqAuditTrigger on CpqAudit__c (before insert) {

    if(Trigger.isInsert && CventMyd_Settings.mydTriggersAreActive) {

        CventMyd_CpqAuditTriggerHandler.handleBeforeInsert();

    }   

}