@isTest
public class TestAddressCustomStateCountryISO {

    public static testMethod void testMyController() {
        
        
        Address__c obj = new Address__c();
        obj.Operating_unit_name__c = 'CVINC';
        obj.State__c = 'NE';
        obj.Country__c = 'US';
        obj.CountryCode__c = 'US';
        insert obj;

        ApexPages.StandardController sc = new ApexPages.StandardController(obj);
        
        AddressCustomStateCountryISO_Controller thecontroller = new AddressCustomStateCountryISO_Controller(sc);
        
        PageReference pageRef = Page.helphome;
        pageRef.getParameters().put('id', String.valueOf(obj.Id));
        Test.setCurrentPage(pageRef);
        
        
        thecontroller.saveAction();
    }
}