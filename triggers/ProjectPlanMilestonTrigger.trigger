trigger ProjectPlanMilestonTrigger on Project_Plan_SOW_EB__c (Before Insert,Before Update) {

// ===============================
// AUTHOR     :  SHANU AGGARWAL
// CREATE DATE     :  5 FEB 2016
// PURPOSE     :  PROJECT PLAN TRIGGER 
// TRIGGER HELPER CLASS: ProjectPlanTrgHelper
// TEST CLASS: ProjectPlanTrgHelperTest
// SPECIAL NOTES:
// ===============================
// Change History:
//
//==================================
  
    ProjectPlanTrgHelper handler = new ProjectPlanTrgHelper();
    
    if(Trigger.isInsert && Trigger.isBefore){
        handler.OnBeforeInsert(Trigger.new);          
    }
       
    else if(Trigger.isUpdate && Trigger.isBefore){
        handler.OnBeforeUpdate( Trigger.new, Trigger.oldMap );        
    }
   

}