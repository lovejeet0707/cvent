/**
* Author : Sandeep Kumar
* Date : 20 April, 2017
* Description : It tests below mentioned class
* 1) CreateEBProductMapping_TrigAct
*/
@isTest(seeAllData= false)
public class CreateEBProductMapping_TrigAct_Test {
    private static User depUser = [Select Id, ProfileId from User where Name = 'CRM Deployment User'];
    
    static testMethod void createProduct(){        
        System.runAs(depUser){
            Test.startTest();
            // Create Product Record.
            List<Product2> products =  TestUtil.createProducts(new List<String>{'EOY Cvent Event Builder Promotion- Advanced','EOY Cvent Event Builder Promotion- Advanced with Mobile','EOY Cvent Event Builder Promotion- Complex','EOY Cvent Event Builder Promotion- Complex with Mobile','EOY Cvent Event Builder Promotion- Medium','EOY Cvent Event Builder Promotion- Medium with Mobile','EOY Cvent Event Builder Promotion- Simple','EOY Cvent Event Builder Promotion- Simple with Mobile','Event Builder - Additional Round of Changes','Event Builder - Complex','Event Builder-Enterprise-Complex','Event Builder-Enterprise-Medium','Event Builder Premium Services - Advanced','Event Builder Premium Services - Advanced + Event Quarterback','Event Builder Premium Services - Complex','Event Builder Premium Services - Complex + Event Quarterback','Event Builder Premium Services - Complex (with Mobile)','Event Builder Premium Services - Medium','Event Builder Premium Services - Medium + Event Quarterback','Event Builder Premium Services - Simple','Event Builder Premium Services - Simple + Event Quarterback','Event Builder(s)','Event Builder(s) - Advanced','Event Builder(s) - Advanced + Event Quarterback','Event Builder(s) - Advanced with Mobile','Event Builder(s) - Advanced with Mobile + Event Quarterback','Event Builder(s) - Complex','Event Builder(s) - Complex + Event Quarterback','Event Builder(s) - Complex with Mobile','Event Builder(s) - Complex with Mobile + Event Quarterback','Event Builder(s) - Express','Event Builder(s) - Medium','Event Builder(s) - Medium + Event Quarterback','Event Builder(s) - Medium with Mobile','Event Builder(s) - Medium with Mobile + Event Quarterback','Event Builder(s) - Simple','Event Builder(s) - Simple + Event Quarterback','Event Builder(s) - Simple with Mobile','Event Builder(s) - Simple with Mobile + Event Quarterback','Event Builder(s) â€“ Express'});
            insert products;
            Test.stopTest();
        }        
    }
}