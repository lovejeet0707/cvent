/****************************************************************************************
Name            : PSA_timecardHeaderTriggerHandler
Author          : TOP Step Consulting - Andy Heidrich (aheidrich@topstepconsulting.com)
Created Date    : 
Description     : Contains methods called from Triggers on the Timecard Header object. All
				: Timecard Header trigger code should go in this class.  Each method
				: has its description listed at the beginning of the method.
Changelog		: 
******************************************************************************************/

public class PSA_timecardHeaderTriggerHandler {
    
    //Method to unset billable flag on timecards where Milestone is set to "Non-billable Milestone"
    //Sets Billable to FALSE, Credited to TRUE, and Bill Rate to zero when time is logged to
    //non-billable Milestones.
    public static void nonBillableMilestone(list<pse__Timecard_Header__c> tcList) {
        
        if(PSA_Utils.isTriggerDisabled('nonBillableMilestone')) { return; }
        
        //Loop through the Timecards
        for(pse__Timecard_Header__c tc : tcList) {
            //Execute if it's a nonbillable Milestone against a billable Project
            if(tc.Non_billable_Milestone__c == TRUE && tc.Billable_Project__c == TRUE) {
                tc.pse__Billable__c = FALSE;
                tc.pse__Time_Credited__c = TRUE;
                tc.pse__Bill_Rate__c = 0;
            }
        }  
    }
    
    //Method to populate the Approver field on Timecard Header
    //Populates with Resource's Manager if Time Approval Method is Resource Manager
    //(or if PM is submitting against his or her own Project)
    //Populates with Project Manager if Time Approval Method is Project Manager
    //Runs in before insert/update context
    public static void populateApprover(list<pse__Timecard_Header__c> tcList) {
        
        if(PSA_Utils.isTriggerDisabled('TCpopulateApprover')) { return; }
        
        //Declare sets to hold Ids for SOQL
        set<Id> projIds = new set<Id>();
    	set<Id> resIds = new set<Id>();
    
    	//Loop through TCs in this batch and add Ids to sets
        for(pse__Timecard_Header__c tc : tcList) {
        
        	projIds.add(tc.pse__Project__c);
        	resIds.add(tc.pse__Resource__c);
    	}
    
    	//Create map of TC Projects and required fields
        map<Id,pse__Proj__c> projMap = new map<Id,pse__Proj__c>
        	([SELECT Id, Time_Approval_Method__c,
              pse__Project_Manager__c,
              pse__Project_Manager__r.pse__Salesforce_User__c
         	  FROM pse__Proj__c WHERE Id IN : projIds]);
    
    	//Create map of TC Resources and required fields
        map<Id,Contact> resMap = new map<Id,Contact>
        	([SELECT Id, pse__Salesforce_User__c, pse__Salesforce_User__r.ManagerId
		 	  FROM Contact WHERE Id IN : resIds]);
    
    	//Loop through the TCs
        for(pse__Timecard_Header__c tc : tcList) {
        
        	//Only run if Submitted
            if(tc.pse__Status__c == 'Submitted') {
            
            	//Assign Ids of Resource, PM, and RM Users and contacts, 
            	//assign Time Approval Method to string
                Id res = tc.pse__Resource__r.pse__Salesforce_User__c;
            	Id rm = resMap.get(tc.pse__Resource__c).pse__Salesforce_User__r.ManagerId;
            	Id pm = projMap.get(tc.pse__Project__c).pse__Project_Manager__r.pse__Salesforce_User__c;
                Id pmCon = projMap.get(tc.pse__Project__c).pse__Project_Manager__c;
                Id resCon = tc.pse__Resource__c;
                string approvalMethod = projMap.get(tc.pse__Project__c).Time_Approval_Method__c;
            
            	//Perform validation that PM Salesforce User is in place if Approval route is PM
                if(approvalMethod == 'Project Manager' && pmCon != resCon) {
                
                	//Error if no PM
                    if(pm == null) {
                    	tc.addError('Either this Project has no Project Manager defined, or the PM does not have a ' +
                                    'Salesforce User populated on his or her Contact record. You must have a Project ' +
                                    'Manager to submit Timecards against projects where the Time Approval ' +
                                    'Method is \'Project Manager\' (you can still save your Timecard).');
                	}
                
                	//If it's all good, populate the Approver field
                    else {
                    	tc.pse__Approver__c = pm;
                	}
            	}
            
            	//Perform validation that Resource has Manager if Approval route 
            	//is Resource Manager or PM is submitting against own Project.
                else if(approvalMethod == 'Resource Manager' || resCon == pmCon) {
                
                	//Error if Resource has no Manager
                    if(rm == null) {
                    	tc.addError('You do not have a Manager populated on your User record.  This is required to submit ' +
                                    'Timecards against Projects where the Time Approval Method is \'Resource ' +
                                    'Manager\' (or when you are the PM submitting against your own Project).  Please contact ' +
                                    'the Help Desk to correct this issue (you can still save your Timecard).');
                	}
                
                	//If it's all good, populate the Approver field
                    else {
                    	tc.pse__Approver__c = rm;
                	}
            	}        
        	}
    	}
    }
}