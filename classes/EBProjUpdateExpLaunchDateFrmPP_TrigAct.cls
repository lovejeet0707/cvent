/*Author: Sandeep Kumar
* Date: 23 May 2017
* Description: EBProjUpdateExpLaunchDateFrmPP_TrigAct. 
* Class is reponsible for updating "Expected launch Date" from "Project Plan" object to associated EBSB Object.
* Test Class : EBProjectUpdateExpLaunchDate_TrigAct_Test
*/
public class EBProjUpdateExpLaunchDateFrmPP_TrigAct extends TriggerAction{
    public Map<Id,Date> projIdToExpectedLaunchDateMap;
    public List<EB_SB_Builder__c> ebProjList;   
    public EBProjUpdateExpLaunchDateFrmPP_TrigAct(){
        // Call super to set batch variables & context
        super();
        projIdToExpectedLaunchDateMap = new Map<Id,Date>();
        ebProjList = new List<EB_SB_Builder__c>();
    }
    
    public override Boolean shouldRun(){
        if(this.isAfter() && !this.hasRun()){
            if(this.isUpdate()){
                for(Project_Plan_SOW_EB__c newProjPlanObj: (List<Project_Plan_SOW_EB__c>)this.triggerMap.values()){
                    Project_Plan_SOW_EB__c oldProjPlanObj = (Project_Plan_SOW_EB__c)this.triggerOldMap.get(newProjPlanObj.Id);
                    if(newProjPlanObj.EBSB_Builders_Name__c != null){
                        // Below condition is satisfied whenever the Expected Launch Date is changed.
                        if(oldProjPlanObj.Expected_Launch_Date__c != newProjPlanObj.Expected_Launch_Date__c){
                            projIdToExpectedLaunchDateMap.put(newProjPlanObj.EBSB_Builders_Name__c, newProjPlanObj.Expected_Launch_Date__c);
                            // Below condition is satisfied whenever the Event Launch Revised Date is changed.    
                        }else if(oldProjPlanObj.Event_Launch_Revised_Timeline__c != newProjPlanObj.Event_Launch_Revised_Timeline__c) {
                            projIdToExpectedLaunchDateMap.put(newProjPlanObj.EBSB_Builders_Name__c, newProjPlanObj.Event_Launch_Revised_Timeline__c);
                        }
                    }                    
                } 
            }else if(this.isInsert()){
                for(Project_Plan_SOW_EB__c newProjPlanObj: (List<Project_Plan_SOW_EB__c>)this.triggerMap.values()){
                    if(newProjPlanObj.EBSB_Builders_Name__c != null)
                        projIdToExpectedLaunchDateMap.put(newProjPlanObj.EBSB_Builders_Name__c, newProjPlanObj.Expected_Launch_Date__c);                    
                } 
            }            
        }        
        return !projIdToExpectedLaunchDateMap.isEmpty();
    }
    
    public override void doAction(){
        
        EB_SB_Builder__c ebProjObj;
        for(Id projId  :projIdToExpectedLaunchDateMap.keySet()){
            ebProjObj = new EB_SB_Builder__c();            
            ebProjObj.Id = projId;
            ebProjObj.Expected_Launch_Date__c = projIdToExpectedLaunchDateMap.get(projId);
            ebProjList.add(ebProjObj);
        }
        if(!ebProjList.isEmpty()){
            update ebProjList;
        } 
    }    
}