// ===============================
// AUTHOR           : Shanu Aggarwal    
// CREATED DATE     : 06 June 2017
// PURPOSE          : Test Class for Onsite Troubleshooting Hardware Page
// TEST CLASS       :   
// SPECIAL NOTES    :
// ===============================
@isTest
public class OnsiteTroubleShootingControllerTest{
    
    
    static testmethod void test1(){
        
        List<Onsite_Troubleshooting__c> trList = new List<Onsite_Troubleshooting__c>();

        Onsite_Troubleshooting__c ot1 = new Onsite_Troubleshooting__c();
        ot1.Name = '1';
        ot1.Question__c = 'What is the issue?';
        ot1.Answer_1__c = 'The printer is not printing.';
        ot1.Answer_2__c = 'The iPads wont connect to the printer.';


        Onsite_Troubleshooting__c ot2 = new Onsite_Troubleshooting__c();
        ot2.Name = '2';
        ot2.Question__c = 'Is the power cord plugged in properly? Make sure it has not come apart. Like most laptop power cables, it contains 2 halves that need to be joined together.';
        ot2.Answer_1__c = '3';
        ot2.Answer_2__c = '6';
        
        trList.add(ot1);
        trList.add(ot2);
        insert trList;
        
        ApexPages.StandardController std = new ApexPages.StandardController(trList[0]);
        OnsiteTroubleShootingController oController = new OnsiteTroubleShootingController(std);
        oController.getOptions();
        oController.doNext();
        oController.doPrevious();
        
    }

    static testmethod void test17(){
        
        List<Onsite_Troubleshooting__c> trList = new List<Onsite_Troubleshooting__c>();

        Onsite_Troubleshooting__c ot1 = new Onsite_Troubleshooting__c();
        ot1.Name = '17';
        ot1.Question__c = 'What is the issue?';
        ot1.Answer_1__c = 'The printer is not printing.';
        ot1.Answer_2__c = 'The iPads wont connect to the printer.';

        trList.add(ot1);
        insert trList;
        
        ApexPages.StandardController std = new ApexPages.StandardController(trList[0]);
        OnsiteTroubleShootingController oController = new OnsiteTroubleShootingController(std);
        
        oController.currentQues=trList.get(0);
        oController.getOptions();
        oController.doNext();
        oController.doPrevious();
        
    }
    
    static testmethod void test16(){
        
        List<Onsite_Troubleshooting__c> trList = new List<Onsite_Troubleshooting__c>();

        Onsite_Troubleshooting__c ot1 = new Onsite_Troubleshooting__c();
        ot1.Name = '16';
        ot1.Question__c = 'What is the issue?';
        ot1.Answer_1__c = 'The printer is not printing.';
        ot1.Answer_2__c = 'The iPads wont connect to the printer.';

        trList.add(ot1);
        insert trList;
        
        ApexPages.StandardController std = new ApexPages.StandardController(trList[0]);
        OnsiteTroubleShootingController oController = new OnsiteTroubleShootingController(std);
        
        oController.currentQues=trList.get(0);
        oController.answer='2';
        oController.getOptions();
        oController.doNext();
        oController.doPrevious();
        
        oController.currentQues=null;
        oController.getOptions();
        
    }




}