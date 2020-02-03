public with sharing class AddressCustomStateCountryISO_Controller {
    public Account acc {get; set;}
    public Address__c address {get; set;}
    ApexPages.StandardController controller0 {get; set;}
    
    public AddressCustomStateCountryISO_Controller(ApexPages.StandardController controller) {
        acc= new Account();
        List<Address__c> addresList = [Select Id, Operating_unit_name__c, State__c, Country__c,CountryCode__c from Address__c where Id=: controller.getRecord().Id];
        if(addresList.size()>0){
            Address__c add0 = addresList[0];
            acc.BillingCountryCode = add0.CountryCode__c;        
            acc.BillingStateCode = add0.State__c;
        } else {
            //address = (Address__c) controller.getRecord();
        }
        address = (Address__c) controller.getRecord();
        controller0 = controller;
    }
    
    public PageReference saveAction(){
        try{
            address.CountryCode__c = acc.BillingCountryCode;
            address.Country__c = acc.BillingCountryCode;
            address.State__c = acc.BillingStateCode;
            //address.Operating_Unit_Name__c = address.Operating_Unit_Name__c;
            upsert address;
        } catch(Exception e){ 
            System.debug('Error Message: '+e);
            ApexPages.addMessages(e);
            return null;
        }
        return new PageReference('/'+address.id);
    }
    

}