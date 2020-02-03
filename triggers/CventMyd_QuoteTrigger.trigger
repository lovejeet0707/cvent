trigger CventMyd_QuoteTrigger on SBQQ__Quote__c (before insert, after insert, before update, after update) {

    if(!CventMyd_Settings.mydTriggersAreActive) {

        return;

    }
    
    else if(Trigger.isBefore && Trigger.isInsert) {
        
        CventMyd_QuoteTriggerHandler.handleBeforeInsert();

    }

    else if(Trigger.isAfter && Trigger.isInsert) {

        CventMyd_QuoteTriggerHandler.handleAfterInsert();

    }

    else if(Trigger.isBefore && Trigger.isUpdate) {

        CventMyd_QuoteTriggerHandler.handleBeforeUpdate();

    }    

    else if(Trigger.isAfter && Trigger.isUpdate) {

        CventMyd_QuoteTriggerHandler.handleAfterUpdate();

    }

}