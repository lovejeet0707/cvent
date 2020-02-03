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
private class New_Task_test {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        //Task accs = [Select id,subject, WhatId from Task where WhatId = 'a0700000000a6Ez' limit 1];
        //accs.subject = 'test sunbject';
        //update accs;
        
        EB_SB_Builder__c ebsb = new  EB_SB_Builder__c ();
        insert ebsb;
        Datetime dt = Datetime.now();
        Task accs = new Task(Subject='Testing Task',Minutes_on_tasks__c =10, Task_Reason__c='Introduction', WhatId=ebsb.Id);
        insert accs;
        Task accs1 = [Select Id, Subject from Task where Id = :accs.Id];
        accs1.subject = 'test subject';
        update accs1;
        delete accs1;
        
        
    }
}