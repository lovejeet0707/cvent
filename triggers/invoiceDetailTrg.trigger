/**
///////////////////////////////
//    @author Hemant Singh Rana    //
///////////////////////////////
Test Class in InvoiceDetailTrgHelperTest
Version 1.0
Date: 29th May 2016
Description: Removing TAB character from some of the custom fields for TRACT.
Version 2.0
Date:
Description:
*/
trigger invoiceDetailTrg on Invoicing_Details__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    
    InvoiceDetailTrgHelper handler = new InvoiceDetailTrgHelper();
     
    if(Trigger.isInsert && Trigger.isBefore){
        handler.OnBeforeInsert(Trigger.new);          
    }
    else if(Trigger.isInsert && Trigger.isAfter){
        handler.OnAfterInsert(Trigger.newMap);        
    }
    else if(Trigger.isUpdate && Trigger.isBefore){
        handler.OnBeforeUpdate(Trigger.oldMap, Trigger.newMap);        
    }
    else if(Trigger.isUpdate && Trigger.isAfter){
        handler.OnAfterUpdate(Trigger.oldMap, Trigger.newMap);        
    }    
    else if(Trigger.isDelete && Trigger.isBefore){
        handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);        
    }
    else if(Trigger.isDelete && Trigger.isAfter){
        handler.OnAfterDelete(Trigger.old, Trigger.oldMap);        
    }    
    else if(Trigger.isUnDelete){
        handler.OnUndelete(Trigger.new);          
    }
}