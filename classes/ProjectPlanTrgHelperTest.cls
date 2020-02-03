@isTest
Public Class ProjectPlanTrgHelperTest{

  @testsetup
  static void createTetsDataProjectPlan(){
      
      //Creating custom setting data (Project Plan Revised)
      Project_Plan_Revised__c pPlanRevised= new Project_Plan_Revised__c();
      pPlanRevised.Name = 'S1';
      pPlanRevised.Field_Sequence__c = 1 ;
      pPlanRevised.Expected_Timeline_API_Name__c = 'Event_Setup_Call_Expected_Timeline__c' ; 
      pPlanRevised.Revised_Timeline_API_Name__c = 'Event_Setup_Call_Revised_Timeline__c' ;
      pPlanRevised.Timeline_Reason_API_Name__c = 'Event_Setup_Call_Revised_Timeline_Reason__c' ;
      pPlanRevised.Actual_Timeline_API_Name__c =  'Event_Setup_Call_Actual_Timeline__c';
      insert pPlanRevised;
      
      
      //Creating custom setting data (Project Plan Revised)
      Project_Plan_Revised__c pPlanRevised2 = new Project_Plan_Revised__c();
      pPlanRevised2.Name = 'S2';
      pPlanRevised2.Field_Sequence__c = 2 ;
      pPlanRevised2.Expected_Timeline_API_Name__c = 'Addnl_Info_Received_Expected_Timeline__c' ; 
      pPlanRevised2.Revised_Timeline_API_Name__c = 'Addnl_Info_Received_Revised_Timeline__c' ;
      pPlanRevised.Timeline_Reason_API_Name__c = 'Addnl_Info_Recvd_Revised_Timeline_Reason__c' ;
      pPlanRevised2.Actual_Timeline_API_Name__c =  'Addnl_Info_Received_Actual_Timeline__c';
      insert pPlanRevised2;
      
      
      
      //Creating custom setting data (Project Plan Milestone)
      Decimal d = 3;
      Project_Plan_Milestone__c pPlanCustSetting = new Project_Plan_Milestone__c();
      pPlanCustSetting.Name = 'Regular Simple';
      pPlanCustSetting.Event_Launch_Expected_Date__c = d;
      pPlanCustSetting.Event_Setup_Call_Expected_Date__c = d;
      pPlanCustSetting.Event_Testing_Expected_Date__c = d;
      pPlanCustSetting.FD_Completed_Expected_Date__c = d;
      pPlanCustSetting.X1st_ROC_Completed_Expected_Date__c = d;
      pPlanCustSetting.X1st_ROC_Received_Expected_Date__c = d;
      pPlanCustSetting.X2nd_ROC_Received_Expected_Date__c = d;
      pPlanCustSetting.X2nd_ROC_Completed_Expected_Date__c = d;
      pPlanCustSetting.X3rd_ROC_Completed_Expected_Date__c = d;
      pPlanCustSetting.X3rd_ROC_Received_Expected_Date__c = d;     
      pPlanCustSetting.Addnl_Info_Received_Expected_Date__c = d;
      Insert pPlanCustSetting;
      
      
       //Creating Project Plan EB
      Project_Plan_SOW_EB__c pPlan = new Project_Plan_SOW_EB__c();
      pPlan.Information_Received__c = System.Today();
      pPlan.Project_Received_Date__c = System.Today();
      pPlan.Expected_Launch_Date__c = System.Today();
      pPlan.Request_Type__c = 'Regular' ;
      pPlan.Project_Complexity__c = '1-Simple';
      pPlan.Project_Plan_Status__c = 'Generate Project Plan';
      insert pPlan;   
  }
  
  @isTest Public static void beforeInsertTest(){
  
        Project_Plan_SOW_EB__c  pp = [Select Id,Event_Setup_Call_Expected_Timeline__c,Event_Setup_Call_Revised_Timeline__c,Event_Setup_Call_Revised_Timeline_Reason__c From Project_Plan_SOW_EB__c Limit 1];
        pp.Event_Setup_Call_Revised_Timeline__c =  pp.Event_Setup_Call_Expected_Timeline__c + 4;
        pp.Event_Setup_Call_Revised_Timeline_Reason__c = 'Test Reason';
        pp.Is_Launch_Date_Revised__c = 'No';
        Update pp;
  
  }
  
  

}