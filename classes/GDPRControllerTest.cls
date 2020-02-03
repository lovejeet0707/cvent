@istest
public class GDPRControllerTest{

    static testmethod void runtest(){
        
        /***** For GDPR SubProcessors Task *****/
        
        Account acc = new Account();
        acc.name = 'Test GDPR';
        acc.BillingCountry='MX';
        insert acc;
        
        Contact con = new Contact();
        con.AccountId = acc.id;
        con.LastName = 'GDPR Testing';
        insert con; 
        
        GDPRTaskSubProcessor__c setGDPR = new GDPRTaskSubProcessor__c();
        setGDPR.Assigned_To__c= String.ValueOf(con.id);
        setGDPR.Product__c= 'Business Transient';
        setGDPR.Subject__c= 'Send Amadeus sub-processor notification - hospitality.notification@amadeus.com (client using BT, CSB and/or Group)';
        setGDPR.name = 'Business Transient';
        insert setGDPR;
        
        GDPRTaskSubProcessor__c setGDPR1 = new GDPRTaskSubProcessor__c();
        setGDPR1.Assigned_To__c= String.ValueOf(con.id);
        setGDPR1.Product__c= 'Abstract Management';
        setGDPR1.Subject__c= 'Send Amadeus sub-processor notification - hospitality.notification@amadeus.com (client using BT, CSB and/or Group)';
        setGDPR1.name = 'Abstract Management';
        insert setGDPR1;
        
    
        
        GDPRProductSetting__c setting = new GDPRProductSetting__c();
        setting.Name = 'Abstract Management';
        setting.Product__c = 'Abstract Management';
        setting.GDPR_Form_Field_Label__c  = 'Account Number';
        insert setting;
                       
        GDPRController controller = new GDPRController();

        //get initialized case from controller
        Case cs = controller.c;
        
        cs.Submitter_Name__c = 'Test User';
        cs.Submitter_Email__c = 'user@user.com';
        controller.fName = 'Test2';
        controller.lName = 'User';
        cs.Requester_s_Email__c = 'user@user.com';
        cs.Data_Subject__c = 'Attendee';
        cs.GDPR_Type__c = 'Right of Access (Data Retrieval)';
        cs.GDPR_Submitted_Date__c = system.today();
        cs.Products_Affected_Dev__c = 'Abstract Management;Business Transient';
        controller.showDescription = 'Yes';
        cs.Description = 'Yes';
        controller.agree = true;
        
        
        
        
        //put case information back to the c instance of controller
        controller.c = cs;
        controller.GetProducts();
        
        //put account number
        controller.selectedProdMap.put('Abstract Management',new GDPRController.ProductBoxWrapper('Abstract Management Account Number','464465464',true));
        controller.submitRequest();
        
        //throw exception 1 (agree checkbox false)
        controller.agree = false;
        controller.submitRequest();
        
        //throw exception 2 ( account number missing)
        controller.selectedProdMap.put('Abstract Management',new GDPRController.ProductBoxWrapper('Abstract Management Account Number',null,true));
        controller.fName = null;
        cs.Submitter_Email__c = 'xyz';
        controller.submitRequest();
     
        
        
        
    }

}