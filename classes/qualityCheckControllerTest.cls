/**
//////////////////////////////////////
//    @author Vaibhav Jain    //
/////////////////////////////////////
Version :  1.0
Date : 29th Sept 2015
 */
@isTest
private class qualityCheckControllerTest {

    static testMethod void myUnitTest() {
          Quality_Checks__c qc = new Quality_Checks__c();
          qc.QC_Name__c = 'Spot Check for CC';
          insert qc;
          
          List<Quality_Check_Question__c> quesList = new List<Quality_Check_Question__c>();
          Quality_Check_Question__c instOfQues = new Quality_Check_Question__c();
          instOfQues.Answer_Choices__c = 'Yes';
          instOfQues.Criticality__c = 'Critical';
          instOfQues.Max_Score__c = 8;
          instOfQues.Question_Type_CC__c = 'Listing and Submission/Re-submission';
          instOfQues.Question__c = 'Are all the images uploaded to the stores  appropriate?';
          instOfQues.Quality_Checks__c = qc.id;
          quesList.add(instOfQues);
          
          Quality_Check_Question__c instOfQues2 = new Quality_Check_Question__c();
          instOfQues2.Answer_Choices__c = 'Yes';
          instOfQues2.Criticality__c = 'Critical';
          instOfQues2.Max_Score__c = 8;
          instOfQues2.Question_Type_CC__c = 'Listing and Submission/Re-submission';
          instOfQues2.Question__c = 'Are all the images uploaded to the stores  appropriate?';
          instOfQues2.Quality_Checks__c = qc.id;
          quesList.add(instOfQues2);
          insert quesList;
                    
          Quality_Check_Done__c instOfQCD = new Quality_Check_Done__c();
          instOfQCD.Quality_Checks__c = qc.id;
          insert instOfQCD;
          
          Quality_Check_Response__c instOFQCR = new Quality_Check_Response__c();
          instOFQCR.Quality_Check_Done__c = instOfQCD.id;
          instOFQCR.Quality_Check_Filled_Response__c = 'Yes';
          instOFQCR.Quality_Check_Question__c = instOfQues.id;
          instOFQCR.Score__c = 96;
          insert instOFQCR;
          instOFQCR.Quality_Check_Filled_Response__c = 'No';
          update instOFQCR;
          
          ApexPages.StandardController sc = new ApexPages.StandardController(qc);
          Apexpages.currentPage().getParameters().put('id', qc.id);
          qualityCheckController instofQuaChkCls = new qualityCheckController(sc);
          instofQuaChkCls.gettypes();
          instofQuaChkCls.submitValues();
    }
}