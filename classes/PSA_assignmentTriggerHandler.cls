/****************************************************************************************
Name            : PSA_assignmentTriggerHandler
Author(s)       : TOP Step Consulting - Andy Heidrich (aheidrich@topstepconsulting.com)
				:
Created Date    : 
Description     : Contains methods called from Triggers on the Assignment object. All
				: Assignment trigger code should go in this class.  Each method
				: has its description listed at the beginning of the method.
Changelog		: 
******************************************************************************************/

public class PSA_assignmentTriggerHandler {
    
    //This method causes resources to follow Projects in Chatter when they are assigned to them.
    //Runs in after insert context
    public static void followProject(set<Id> aIds) {
        
        if(PSA_Utils.isTriggerDisabled('followProject')) { return; }
        
        //Get a map of Assignments and related User Ids for Assignments in this batch
        map<Id,pse__Assignment__c> aMap = new map<Id,pse__Assignment__c>([SELECT Id, pse__Resource__r.pse__Salesforce_User__c,
                                                                         pse__Resource__r.pse__Salesforce_User__r.IsActive,
                                                                         pse__Project__c FROM pse__Assignment__c
                                                                         WHERE Id IN : aIds]);
        
        //Declare set of Project Ids for querying, and a string set for Project + User Id key
        //(we will use this to avoid dupe insert errors)
        set<Id> projIds = new set<Id>();
        set<string> theKeys = new set<string>();
        
        //Loop through Assignments and add project Id
        for(pse__Assignment__c a : aMap.values()) {
            projIds.add(a.pse__Project__c);
        }
        
        //Loop through existing EntitySubscription records for Projects related to Assignments
        //in this batch.  Create unique key of Project + User Id and add to theKey set
        //for duplicate comparison
        for(EntitySubscription es : [SELECT SubscriberId, ParentId
                                    FROM EntitySubscription
                                     WHERE ParentId IN : projIds]) {
            string theKey = string.valueOf(es.ParentId) + string.valueOf(es.SubscriberId);
            theKeys.add(theKey);
		}
        
        //Declare list of new Follows to create
        list<EntitySubscription> followList = new list<EntitySubscription>();
         
        //Loop through the Assignments in this batch
        for(pse__Assignment__c a : aMap.values()) {
            //Only run if Resource has an active Salesforce user
            if(a.pse__Resource__r.pse__Salesforce_User__c != null && a.pse__Resource__r.pse__Salesforce_User__r.IsActive == TRUE) {
                //Declare a matching key for dupe checking
                string theKey = string.valueOf(a.pse__Project__c) + string.valueOf(a.pse__Resource__r.pse__Salesforce_User__c);
            	//Only proceed if the resource is not following the Assignment's Project already
            	if(!theKeys.contains(theKey)) {
               		//Create new subscription record and it to the list for insertion
                    EntitySubscription es = new EntitySubscription();
                	es.SubscriberId = a.pse__Resource__r.pse__Salesforce_User__c;
                	es.ParentId = a.pse__Project__c;
                	followList.add(es);
            	}
            }  
        }
        
        //Create the subscription records
        if(!followList.isEmpty()) {
        	insert followList;
        }    
    }
}