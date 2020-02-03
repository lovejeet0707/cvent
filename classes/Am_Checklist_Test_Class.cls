/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class Am_Checklist_Test_Class {
    static testMethod void myUnitTest() {
        //Test.setCurrentPage(pageRef);
        //String nextPage = controller.edit().getUrl();
        //System.assertEquals('/apex/failure?error=noParam', nextPage);
        ID idtest = 'a0300000000UHsT';
        ApexPages.currentPage().getParameters().put('id', 'a0300000000y2yF');
        ApexPages.currentPage().getParameters().put('acc_name', '00100000005S6GC');
        ApexPages.currentPage().getParameters().put('tab_name', 'name1');
       
       String id = 'a0300000000y2yF';
       String acc_name = '00100000005S6GC';
       String account_name, tab_name  ;
       account_name = [select name from account where id = :acc_name limit 1].name; 
       tab_name = 'name1';

       Am_Checklist_Class controller = new Am_Checklist_Class (); 
       String nextPage = controller.edit().getUrl();
       
       String nextPage2 = controller.save().getUrl();
       String nextPage3 = controller.edit1().getUrl();
       String nextPage6 = controller.edit3().getUrl();
       String nextPage5 = controller.edit2().getUrl();
       String nextPage4 = controller.cancel().getUrl();
       controller.setnametab('sam bhat');
    }
    }