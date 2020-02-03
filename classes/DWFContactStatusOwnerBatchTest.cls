/**=====================================================================
 * Cvent
 * Name: TestDataFactory 
 * Description: Test class for "DWFContactStatusOwnerBatch" && "ScheduledDWFContactStatusOwnerBatch" Class.
 * Created Date: [22/07/2016]
 * Created By: Hemant Rana
 * 
 * Date Modified                Modified By                  Description of the update
 * [MON DD, YYYY]               [FirstName LastName]         [Short description for changes]
 =====================================================================*/ 
 @isTest
 private class DWFContactStatusOwnerBatchTest{
     @TestSetup static void insertCustomSetting(){
         //Inserting records in "DWF_Batch_Execution__c" NOT NEEDED IN THE FUTURE
        /*List<DWF_Batch_Execution__c> DWFBatchExecutionStatusObj= new List<DWF_Batch_Execution__c>();
        for(Integer i=0;i<2;i++) {
            DWFBatchExecutionStatusObj.add(new DWF_Batch_Execution__c(Batch_Status__c='New'));
        }
        insert DWFBatchExecutionStatusObj; */
         
         //Inserting records in "DWR_Role_ContactStatus__c" Custom Setting
         List<DWF_Product_Vs_Status_Vs_Owner_Field__c> productContactStatusList=new List<DWF_Product_Vs_Status_Vs_Owner_Field__c>();
         
         DWF_Product_Vs_Status_Vs_Owner_Field__c productContactStatus=new DWF_Product_Vs_Status_Vs_Owner_Field__c();
         productContactStatus.Contact_Owner_Field__c='Contact_Owner_for_Event__c';
         productContactStatus.Contact_Status_Field__c='Event_Contact_Status__c';
         productContactStatus.Name='Cvent Connect';
         productContactStatusList.add(productContactStatus);
         
         productContactStatus=new DWF_Product_Vs_Status_Vs_Owner_Field__c();
         productContactStatus.Contact_Owner_Field__c='Contact_Owner_for_CSN_S__c';
         productContactStatus.Contact_Status_Field__c='CSNS_Contact_Status__c';
         productContactStatus.Name='Diamonds';
         productContactStatusList.add(productContactStatus);
         
         insert productContactStatusList;
         
         //Inserting records in "DWR_Role_ContactStatus__c" Custom Setting
         List<DWR_Role_ContactStatus__c> roleContactStatusList=new List<DWR_Role_ContactStatus__c>();
         
         DWR_Role_ContactStatus__c roleContactStatus=new DWR_Role_ContactStatus__c();
         roleContactStatus.Contact_Owner_Field__c='Contact_Owner_for_Event__c';
         roleContactStatus.Contact_Status_Field__c='Event_Contact_Status__c';
         roleContactStatus.Name='AM (Event)';
         roleContactStatusList.add(roleContactStatus);
         
         roleContactStatus=new DWR_Role_ContactStatus__c();
         roleContactStatus.Contact_Owner_Field__c='Contact_Owner_for_Survey__c';
         roleContactStatus.Contact_Status_Field__c='Survey_Contact_Status__c';
         roleContactStatus.Name='AM (Survey)';
         roleContactStatusList.add(roleContactStatus);
         
         insert roleContactStatusList;
         
         //Inserting records in "DWF_SubjectLine_Vs_DWStatus__c" Custom Setting
         List<DWF_SubjectLine_Vs_DWStatus__c> subjectStatusList=new List<DWF_SubjectLine_Vs_DWStatus__c>();
         
         DWF_SubjectLine_Vs_DWStatus__c subjectStatus=new DWF_SubjectLine_Vs_DWStatus__c();
         subjectStatus.DW_Status__c='Marketing Qualified';
         subjectStatus.Name='Marketing Qualified';
         subjectStatusList.add(subjectStatus);
         
         subjectStatus=new DWF_SubjectLine_Vs_DWStatus__c();
         subjectStatus.DW_Status__c='Marketing Researched';
         subjectStatus.Name='Attending TS';
         subjectStatusList.add(subjectStatus);
         
         insert subjectStatusList;
         
         //Inserting records in "DWF_SubjectLine_Vs_DWStatus__c" Custom Setting
         List<DWF_Contact_Status_Order__c> contactStatusOrderList=new List<DWF_Contact_Status_Order__c>();
         
         DWF_Contact_Status_Order__c contactStatusOrder=new DWF_Contact_Status_Order__c();
         contactStatusOrder.Name='Marketing Qualified';
         contactStatusOrder.Order__c=3;
         contactStatusOrderList.add(contactStatusOrder);
         
         contactStatusOrder=new DWF_Contact_Status_Order__c();
         contactStatusOrder.Name='Marketing Researched';
         contactStatusOrder.Order__c=2;
         contactStatusOrderList.add(contactStatusOrder);
         
         insert contactStatusOrderList;
         
     }
     /*@isTest static void testMethod1()
     {
         
         TestDataFactory.createTestRecord();
         User UserRec = [SELECT Id FROM User WHERE LastName='Sops'];
         system.runAs(UserRec){
            Test.startTest();
            
            DWFContactStatusOwnerBatch batchClass= new DWFContactStatusOwnerBatch();
            Id BatchId = Database.executeBatch(batchClass);
            
            // Get the first test DWF_Batch_Execution__c by using a SOQL query
            DWF_Batch_Execution__c DWFBatchRec= [SELECT Id,Batch_Id__c FROM DWF_Batch_Execution__c WHERE Batch_Status__c='New'];
            // Modify first DWF_Batch_Execution__c 
            DWFBatchRec.Batch_Id__c = BatchId ;
            // This update is local to this test method only.
            update DWFBatchRec;
            Test.stopTest();
         }
     }*/
      //test Method for the "ScheduledDWFContactStatusOwnerBatch" class
      @isTest static void testScheduledDWFContactStatusOwnerBatch()
       {
           Test.startTest();
           TestDataFactory.createTestRecord();
           ScheduledDWFContactStatusOwnerBatch schedulerVar=new ScheduledDWFContactStatusOwnerBatch();
           String sch = '0 0 23 * * ?'; 
           system.schedule('Test DWFContactStatusOwnerBatch', sch, schedulerVar); 
           Test.stopTest();
       }
 }