trigger Product2After on Product2 (after insert, after update, after delete) {
    
    Boolean Product2TriggerControl = Boolean.valueOf(Label.Product2_Trigger_Control);
    
    // Below class is reponsible for creating new EB Product Mappings.
    CreateEBProductMapping_TrigAct createNewMapping = new CreateEBProductMapping_TrigAct();
    if(Product2TriggerControl && createNewMapping.shouldRun()){
        createNewMapping.doAction();
    }    
}