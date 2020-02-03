/**
//////////////////////////////////////
//      @author Abhishek Pandey     //
/////////////////////////////////////
Version :   1.0
Date : 27th June 2014
Description: Testing for FeedbackCls
 */

@isTest

private class FeedbackClsTest {
    public static CLS_Assignment_Id__c instOfCLSAssgn = new CLS_Assignment_Id__c();
    static{
        instOfCLSAssgn.X18_Digit_Client_Serv_VP_Id__c  = UserInfo.getUserId();
        instOfCLSAssgn.Name  = UserInfo.getUserId();
        insert instOfCLSAssgn;
    }
    static testMethod void test(){
        RecordType instOfRecType = [SELECT Id FROM RecordType WHERE DeveloperName='Customer_Listening_System'];
        Case instCase = new Case(RecordTypeId = instOfRecType.Id);
        FeedbackCls instOfFeedBC = new FeedbackCls(new ApexPages.StandardController(instCase));
        instOfFeedBC.instOfCase.Feedback_Driver__c ='Product';
        instOfFeedBC.save();
        instOfFeedBC.cancel();
    }
    static testMethod void testSec(){
        RecordType instOfRecType = [SELECT Id FROM RecordType WHERE DeveloperName='Customer_Listening_System'];
        Case instCase = new Case(RecordTypeId = instOfRecType.Id);
        FeedbackCls instOfFeedBC = new FeedbackCls(new ApexPages.StandardController(instCase));
        instOfFeedBC.instOfCase.Description = '';
        instOfFeedBC.instOfCase.Feedback_Driver__c ='Sales';
        instOfFeedBC.save();
    }
    static testMethod void testThir(){
        RecordType instOfRecType = [SELECT Id FROM RecordType WHERE DeveloperName='Customer_Listening_System'];
        Case instCase = new Case(RecordTypeId = instOfRecType.Id);
        FeedbackCls instOfFeedBC = new FeedbackCls(new ApexPages.StandardController(instCase));
        instOfFeedBC.instOfCase.Description = 'test';
        instOfFeedBC.instOfCase.Feedback_Driver__c ='Sales';
        instOfFeedBC.instOfCase.Product_Type__c = 'CrowdCompass';
        instOfFeedBC.save();
    }
}