/****************************************************************************************
Name            : PSA_resourceRequestTriggerHandler
Author(s)       : TOP Step Consulting - Andy Heidrich (aheidrich@topstepconsulting.com)
				:
Created Date    : 
Description     : Contains methods called from Triggers on the Resource Request object. All
				: Resource Request trigger code should go in this class.  Each method
				: has its description listed at the beginning of the method.
******************************************************************************************/

public class PSA_resourceRequestTriggerHandler {
    
    //Method to populate a group's Resource Manager on a new Resource Request
    //Called from before insert and update
    public static void setResourceManager(list<pse__Resource_Request__c> rrList) {
        
        if(PSA_Utils.isTriggerDisabled('setResourceManager')) { return; }
        
        //Get Ids of RR's pse__Grp__c records in this batch -
        //declare set, loop through records and add Group Ids
        set<Id> groupIds = new set<Id>();
        for(pse__Resource_Request__c rr : rrList) {
            groupIds.add(rr.pse__Group__c);
        }
        
        //Declare and populate map of Groups and Resource Manager field on Groups
        map<Id,pse__Grp__c> groupMap = new map<Id,pse__Grp__c>([SELECT Id,Resource_Manager__c
                                                                FROM pse__Grp__c
                                                                WHERE Id IN : groupIds]);
        
        //Loop through the Resource Requests
        for(pse__Resource_Request__c rr : rrList) {
            
            //If Group is populated on RR
            if(rr.pse__Group__c != null) {
                //If Resource Manager is populated on Group
                if(groupMap.get(rr.pse__Group__c).Resource_Manager__c != null) {
                    //Set RR Resource Manager to Group Resource Manager
                    rr.Resource_Manager__c = groupMap.get(rr.pse__Group__c).Resource_Manager__c;
                }
            }
        }
    }
}