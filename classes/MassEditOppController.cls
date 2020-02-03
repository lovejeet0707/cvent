/**
//////////////////////////////////////
//      @author Abhishek Pandey     //
/////////////////////////////////////
Version :   1.0
Date : 27th October 2014
 */
public class MassEditOppController {
    ApexPages.StandardSetController setCon;
    public List<Opportunity> selected{get;set;}
    public Set<Id> setId = new Set<Id>(); 
    public boolean boolForEvent{get;set;}
    public MassEditOppController(ApexPages.StandardSetController controller) {
        selected = new List<Opportunity>();
        setCon = controller;
        system.debug(setCon.getSelected());
        for(Sobject instOfOpp : setCon.getSelected()){
            setId.add(instOfOpp.Id);
        }
        boolForEvent = false;
        User instOFUser = [SELECT ID,Profile.Name,UserRole.Name FROM User WHERE Id =: UserInfo.getUserId()];
        if(instOFUser.UserRole.Name.Contains('Event')){
            boolForEvent = true;
        }
        List<Opportunity> lstOpp = [SELECT Id,Feature_Total_Roll_up_MCValue__c,Years__c ,MaintenanceFee__c,RegsEvents__c,Name,RegTransFee__c,New_Contract_Total__c,Account.Name,New_Type__c,StageName,CloseDate,NextStep FROM Opportunity WHERE Id =: setId ORDER BY StageName DESC, CloseDate DESC];
        for(Opportunity instOfOpp : lstOpp){
            selected.add(instOfOpp);
        }
    }
    
    public pageReference save(){
        try{
            update selected;
        }catch(DmlException e){
            //Integer noOfRec = e.getNumDml();
            //+ e.getDmlMessage()
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,e.getNumDml()+'record(s) have error'+'\n\n\n');
            ApexPages.addMessage(message);
            String messages;
            for(integer i = 0 ; i < e.getNumDml(); i++){
                system.debug(e.getDmlId(i));
                system.debug(e.getDmlMessage(i));
                //messages = 'Record Id:'+ e.getDmlId(i)+'-' + 'Error:'+e.getDmlMessage(i)+'\n\n\n';
                message = new ApexPages.message(ApexPages.severity.ERROR,'Record Id:'+ e.getDmlId(i)+'-' + 'Error:'+e.getDmlMessage(i));
                ApexPages.addMessage(message);
            }
            
            
            
            return null;
        }
        String listViewId = apexpages.currentpage().getparameters().get('retURL');
        system.debug('listViewId+++'+listViewId);
        PageReference pageRef = new PageReference(listViewId);
        pageRef.setRedirect(true);
        return pageRef;
    }
}