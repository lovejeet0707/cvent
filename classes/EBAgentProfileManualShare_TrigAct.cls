/*Author: Sandeep Kumar
* Date: 25 April 2017
* Description: EB Agent Profile Manual Share. 
* Class is reponsible for sharing "EB Agent Profile" to Customer Care Rep.
* Test Class : EBAgentProfileManualShare_TrigAct_Test
*/
public class EBAgentProfileManualShare_TrigAct extends TriggerAction{  
    List<EB_Agent_Profile__Share> eBAgentProfileShareList;
    
    public EBAgentProfileManualShare_TrigAct(){
        // Call super to set batch variables & context
        super();        
    }
    
    public override Boolean shouldRun(){
        // Returns true if this class is call from a after insert trigger and has Run is false.
        return this.isInsert() && this.isAfter() && !this.hasRun();
    }  
    
    public override void doAction(){
        EB_Agent_Profile__Share eBAgentProfileShare;
        eBAgentProfileShareList = new List<EB_Agent_Profile__Share>();
        
        for(EB_Agent_Profile__c  EBAgentProfile: (List<EB_Agent_Profile__c >)this.triggerMap.values()){
            //Add new share if field has changed
            if(EBAgentProfile.Agent_Name__c != null){                
                eBAgentProfileShare = New EB_Agent_Profile__Share();
                // Set the ID of record being shared.
                eBAgentProfileShare.ParentId = EBAgentProfile.Id;
                // Set the ID of user or group being granted access.
                eBAgentProfileShare.UserOrGroupID = EBAgentProfile.Agent_Name__c;
                // Set the access level.
                eBAgentProfileShare.AccessLevel = 'Read';
                // Set rowCause to 'manual' for manual sharing.
                eBAgentProfileShare.rowCause = Schema.EB_Agent_Profile__Share.RowCause.Manual;
                // Add share object to list.
                eBAgentProfileShareList.add(eBAgentProfileShare);
            }
        }    
        try{
            if(!eBAgentProfileShareList.isEmpty()){
                insert eBAgentProfileShareList;
                this.markRun();
            }
        }catch(Exception exp){
            system.debug('Exception Occured ='+exp.getMessage());
        }
    }
}