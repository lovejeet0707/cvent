trigger ContractTrg on Contract (after insert, before update, after update) {

    if(CventMyd_Settings.mydTriggersAreActive) {

        if(Trigger.isInsert && Trigger.isAfter){

            ContractTrgHelperCls.handleAfterInsert();

        }

        else if(Trigger.isUpdate && Trigger.isBefore){

            ContractTrgHelperCls.handleBeforeUpdate();    

        }

        else if(Trigger.isUpdate && Trigger.isAfter){

            ContractTrgHelperCls.handleAfterUpdate();       

        }

    }

}