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
public class InvoiceDetailTrgHelper{
    static{
    }
    public void OnBeforeInsert(List<Invoicing_Details__c> newValues){    
        for(Invoicing_Details__c instOfInvoice : newValues){
            /* HSR : 29th May : removal of TAB character from som fields*/
            /*if(instOfInvoice.Billing_POC__c!=null){
                System.debug('Before Removal====>'+instOfInvoice.Billing_POC__c.length());
                instOfInvoice.Billing_POC__c=instOfInvoice.Billing_POC__c.replaceAll('[\\n\\t]', '');
                System.debug('After Removal====>'+instOfInvoice.Billing_POC__c.length());
            }*/
            if(instOfInvoice.Payment_Mode__c!=null){
            System.debug('Before Removal====>'+instOfInvoice.Payment_Mode__c.length());
            instOfInvoice.Payment_Mode__c=instOfInvoice.Payment_Mode__c.replaceAll('[\\n\\t]', '');
            System.debug('After Removal====>'+instOfInvoice.Payment_Mode__c.length());
            }
            if(instOfInvoice.Invoice_Note_1__c!=null){
            System.debug('Before Removal====>'+instOfInvoice.Invoice_Note_1__c.length());
            instOfInvoice.Invoice_Note_1__c=instOfInvoice.Invoice_Note_1__c.replaceAll('[\\n\\t]', '');
            System.debug('After Removal====>'+instOfInvoice.Invoice_Note_1__c.length());
            }
            if(instOfInvoice.Billed_to_Company_Name__c!=null){
            System.debug('Before Removal====>'+instOfInvoice.Billed_to_Company_Name__c.length());
            instOfInvoice.Billed_to_Company_Name__c=instOfInvoice.Billed_to_Company_Name__c.replaceAll('[\\n\\t]', '');
            System.debug('After Removal====>'+instOfInvoice.Billed_to_Company_Name__c.length());
            }
            if(instOfInvoice.Invoice_Note_2__c!=null){
            System.debug('Before Removal====>'+instOfInvoice.Invoice_Note_2__c.length());
            instOfInvoice.Invoice_Note_2__c=instOfInvoice.Invoice_Note_2__c.replaceAll('[\\n\\t]', '');
            System.debug('After Removal====>'+instOfInvoice.Invoice_Note_2__c.length());
            }
            if(instOfInvoice.Subject_Note__c!=null){
            System.debug('Before Removal====>'+instOfInvoice.Subject_Note__c.length());
            instOfInvoice.Subject_Note__c=instOfInvoice.Subject_Note__c.replaceAll('[\\n\\t]', '');
            System.debug('After Removal====>'+instOfInvoice.Subject_Note__c.length());
            }
            if(instOfInvoice.Email_Note__c!=null){
            System.debug('Before Removal====>'+instOfInvoice.Email_Note__c.length());
            instOfInvoice.Email_Note__c=instOfInvoice.Email_Note__c.replaceAll('[\\n\\t]', '');
            System.debug('After Removal====>'+instOfInvoice.Email_Note__c.length());
            }
            if(instOfInvoice.PO__c!=null){
            System.debug('Before Removal====>'+instOfInvoice.PO__c.length());
            instOfInvoice.PO__c=instOfInvoice.PO__c.replaceAll('[\\n\\t]', '');
            System.debug('After Removal====>'+instOfInvoice.PO__c.length());
            }
            if(instOfInvoice.Notes__c!=null){
            System.debug('Before Removal====>'+instOfInvoice.Notes__c.length());
            instOfInvoice.Notes__c=instOfInvoice.Notes__c.replaceAll('[\\n\\t]', '');
            System.debug('After Removal====>'+instOfInvoice.Notes__c.length());
            }
            /* -------------------Ends Here-----------------------------*/
        }
    }
    public void OnAfterInsert(Map<Id,Invoicing_Details__c> newMapValues){ 
    }
    public void OnBeforeUpdate(Map<Id,Invoicing_Details__c> oldMapValues,Map<Id,Invoicing_Details__c> newMapValues){ 
        for(Invoicing_Details__c instOfInvoice : newMapValues.values()){
            /* HSR : 29th May : removal of TAB character from som fields*/
            /*if(instOfInvoice.Billing_POC__c!=null){
                //System.debug('Before Removal====>'+instOfInvoice.Billing_POC__c.length());
                instOfInvoice.Billing_POC__c=instOfInvoice.Billing_POC__c.replaceAll('[\\n\\t]', '');
                //System.debug('After Removal====>'+instOfInvoice.Billing_POC__c.length());
            }*/
            if(instOfInvoice.Payment_Mode__c!=null){
            System.debug('Before Removal====>'+instOfInvoice.Payment_Mode__c.length());
            instOfInvoice.Payment_Mode__c=instOfInvoice.Payment_Mode__c.replaceAll('[\\n\\t]', '');
            System.debug('After Removal====>'+instOfInvoice.Payment_Mode__c.length());
            }
            if(instOfInvoice.Invoice_Note_1__c!=null){
            System.debug('Before Removal====>'+instOfInvoice.Invoice_Note_1__c.length());
            instOfInvoice.Invoice_Note_1__c=instOfInvoice.Invoice_Note_1__c.replaceAll('[\\n\\t]', '');
            System.debug('After Removal====>'+instOfInvoice.Invoice_Note_1__c.length());
            }
            if(instOfInvoice.Billed_to_Company_Name__c!=null){
            System.debug('Before Removal====>'+instOfInvoice.Billed_to_Company_Name__c.length());
            instOfInvoice.Billed_to_Company_Name__c=instOfInvoice.Billed_to_Company_Name__c.replaceAll('[\\n\\t]', '');
            System.debug('After Removal====>'+instOfInvoice.Billed_to_Company_Name__c.length());
            }
            if(instOfInvoice.Invoice_Note_2__c!=null){
            System.debug('Before Removal====>'+instOfInvoice.Invoice_Note_2__c.length());
            instOfInvoice.Invoice_Note_2__c=instOfInvoice.Invoice_Note_2__c.replaceAll('[\\n\\t]', '');
            System.debug('After Removal====>'+instOfInvoice.Invoice_Note_2__c.length());
            }
            if(instOfInvoice.Subject_Note__c!=null){
            System.debug('Before Removal====>'+instOfInvoice.Subject_Note__c.length());
            instOfInvoice.Subject_Note__c=instOfInvoice.Subject_Note__c.replaceAll('[\\n\\t]', '');
            System.debug('After Removal====>'+instOfInvoice.Subject_Note__c.length());
            }
            if(instOfInvoice.Email_Note__c!=null){
            System.debug('Before Removal====>'+instOfInvoice.Email_Note__c.length());
            instOfInvoice.Email_Note__c=instOfInvoice.Email_Note__c.replaceAll('[\\n\\t]', '');
            System.debug('After Removal====>'+instOfInvoice.Email_Note__c.length());
            }
            if(instOfInvoice.PO__c!=null){
            System.debug('Before Removal====>'+instOfInvoice.PO__c.length());
            instOfInvoice.PO__c=instOfInvoice.PO__c.replaceAll('[\\n\\t]', '');
            System.debug('After Removal====>'+instOfInvoice.PO__c.length());
            }
            if(instOfInvoice.Notes__c!=null){
            System.debug('Before Removal====>'+instOfInvoice.Notes__c.length());
            instOfInvoice.Notes__c=instOfInvoice.Notes__c.replaceAll('[\\n\\t]', '');
            System.debug('After Removal====>'+instOfInvoice.Notes__c.length());
            }
            /* -------------------Ends Here-----------------------------*/
        }
    }
    public void OnAfterUpdate(Map<Id,Invoicing_Details__c> oldMapValues,Map<Id,Invoicing_Details__c> newMapValues){ 
    }
    public void OnBeforeDelete(List<Invoicing_Details__c> oldValues,Map<Id,Invoicing_Details__c> oldMapValues){
    }
    public void OnAfterDelete(List<Invoicing_Details__c> oldValues,Map<Id,Invoicing_Details__c> oldMapValues){
    }
    public void OnUndelete(List<Invoicing_Details__c> newValues){
    }
}