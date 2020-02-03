trigger CustomerAssetBefore on Customer_Asset__c (before insert,before update,before delete) {
    
    Boolean triggerControl = Boolean.valueOf(Label.Customer_Asset_Trigger_Control);
    
    PopulateFieldsOnCustomerAsset_TrigAct populateCustomerAssetFields = new PopulateFieldsOnCustomerAsset_TrigAct();
    if(populateCustomerAssetFields.shouldRun() && triggerControl){
        populateCustomerAssetFields.doAction();
    }
}