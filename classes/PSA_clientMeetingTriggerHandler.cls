/****************************************************************************************
Name            : PSA_clientMeetingTriggerHandler
Author(s)       : TOP Step Consulting - Andy Heidrich (aheidrich@topstepconsulting.com)
				:
Created Date    : July 19, 2017
Description     : Contains methods called from PSA_ClientMeeting.apxt:
				: deactivateMeeting: fills a gap in the time-based Workflow functionality
				: where a meeting is not deactivated (Active = FALSE) if the Meeting Date
				: is changed to a date more than 45 days in the past from an edit operation, 
				: and not by the passage of time
******************************************************************************************/

public class PSA_clientMeetingTriggerHandler {
    
    //Method to deactivate Meetings where the Meeting Date is changed
    //such that it should be deactivated, but the time-based Workflow
    //does not fire because it's more than X days in the past
    //(where X = 80 for Apple and 45 for all others)
    public static void deactivateMeeting(list<Client_Meeting__c> cmList) {
        
        if(PSA_Utils.isTriggerDisabled('deactivateMeeting')) { return; }
        
        //Declare set for the Account Ids
        set<Id> aIds = new set<Id>();
        //Loop through CMs and populate aIds
        for(Client_Meeting__c cm : cmList) {
            if(cm.Client_Account__c != null) {
                aIds.add(cm.Client_Account__c);
            }
        }
        //Query the Account Names
        map<Id,Account> aMap = new map<Id,Account>([SELECT Id, Name
                                                    FROM Account
                                                    WHERE Id IN : aIds]);
        
        //Continue if we have Accounts
        if(!aMap.isEmpty()) {
            //Loop through the Meetings and execute the logic
            for(Client_Meeting__c cm : cmList) {
                //Continue if Meeting is Active
                if(cm.Active__c = TRUE) {
                    //Continue if Account is in the Map
                    if(aMap.containsKey(cm.Client_Account__c)) {
                        //Put Account Name in a string for Contains checking
                        string aName = aMap.get(cm.Client_Account__c).Name;
                        //Get days between today and Meeting Date
                        integer daysBetween = cm.Meeting_Date__c.daysBetween(date.today());
                        //Deactivate if not Apple and Meeting more than 45 days ago
                        if(daysBetween > 45) {
                            cm.Active__c = FALSE;
                        }
                    }    
                }  
            }     
        }       
    }
}