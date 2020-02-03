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
private class EB_Case_Owner_Trigger_Test_Class {

   // static testMethod void myUnitTest() {
       // TO DO: implement unit test
      // EB_SB_Builder__c ebsb = new  EB_SB_Builder__c ();
      //  Case accs1 = new Case();
     //  insert ebsb;
     //  Datetime dt = Datetime.now();
     //   Case accs = new Case(RecordTypeId='0120000000098Po',Event_Survey_Builder__c = ebsb.Id, Origin= 'Email', Subject='Testing Task', Minutesoncase__c =10, Reason='508 compliance', Product_Type__c = 'Event Tool');
     //   Case accs = new Case(ContactId = '003P000000Cu7pU',RecordTypeId='0120000000095Nn',Event_Survey_Builder__c = ebsb.Id, Origin= 'Email', Subject='Testing Task', Minutesoncase__c =10, Reason='508 compliance', Product_Type__c = 'Event Tool' , AccountId='001P000000GF1fq');
    //   insert accs;
  }