/*Author: Sandeep Kumar
* Date: 02 April 2017
* Description: Update Pending Hrs for Project Completion. 
* Class is reponsible for updating "EB_SB_Builder__c" field based on the project stage change.It is updating # of Pending Hrs for Completion.
* Test Class : EBProjectAssignmentRollup_TrigAct_Test
*/
public class EBProjectUpdatePendingHrsForCompletion extends TriggerAction{
    
    public List<EB_SB_Builder__c> EbProjList;  
    public Map<String,EBProjectStageToPendingHrsSetting__c> NameToHrsPendingMap;    
    
    public EBProjectUpdatePendingHrsForCompletion(){
        // Call super to set batch variables & context
        super();
        EbProjList = new List<EB_SB_Builder__c>();
        NameToHrsPendingMap = new Map<String,EBProjectStageToPendingHrsSetting__c>();        
    }
    
    public override Boolean shouldRun(){
        if(this.isUpdate() && this.isBefore() && !this.hasRun()){
            for(EB_SB_Builder__c newEBProj: (List<EB_SB_Builder__c>)this.triggerMap.values()){
                EB_SB_Builder__c oldEBProj = (EB_SB_Builder__c)this.triggerOldMap.get(newEBProj.Id);
                if(oldEBProj.Project_Stage__c != newEBProj.Project_Stage__c){
                    EbProjList.add(newEBProj);
                }
            }
        }        
        return !EbProjList.isEmpty();
    }
    
    public override void doAction(){
        
        for(EBProjectStageToPendingHrsSetting__c rec :EBProjectStageToPendingHrsSetting__c.getAll().Values()){
            NameToHrsPendingMap.put(rec.Name, rec);
        }
        
        for(EB_SB_Builder__c EBProj: EbProjList){
            if(EBProj.Project_Complexity__c == '1-Simple'){
                EBProj.Hrs_Pending_for_Completion__c = NameToHrsPendingMap.get(EBProj.Project_Stage__c).SimplePendingHrs__c;
            }else if(EBProj.Project_Complexity__c == '2-Medium'){
                EBProj.Hrs_Pending_for_Completion__c = NameToHrsPendingMap.get(EBProj.Project_Stage__c).MediumPendingHrs__c;
            }else if(EBProj.Project_Complexity__c == '3-Advanced'){
                EBProj.Hrs_Pending_for_Completion__c = NameToHrsPendingMap.get(EBProj.Project_Stage__c).AdvancedPendingHrs__c;
            }else if(EBProj.Project_Complexity__c == '4-Complex'){
                EBProj.Hrs_Pending_for_Completion__c = NameToHrsPendingMap.get(EBProj.Project_Stage__c).ComplexPendingHrs__c;
            }           
        }           
    }
}