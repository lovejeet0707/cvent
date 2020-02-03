/****************************************************************************************
Name            : PSA_utils
Author(s)       : TOP Step Consulting - Andy Heidrich (aheidrich@topstepconsulting.com)
				:
Created Date    : 
Description     : Contains utility methods implemented for custom PSA code developed by
				: TOP Step Consulting.
				:
******************************************************************************************/

public without sharing class PSA_Utils {
    
    //This method checks to see if the currently logged in user has 'Validation Bypass' checked
    //on the User record.  This is used to bypass Apex code when loading data.
    public static Map<Id,User> DataLoadModeUsers
	{
		get
		{
			if(DataLoadModeUsers==null)
			{
				DataLoadModeUsers = new Map<Id,User>([SELECT Id FROM User WHERE UserType = 'Standard' AND IsActive = TRUE AND Validation_Bypass__c = TRUE]);				
			}
			return DataLoadModeUsers;
		}
	}
	public static boolean IsDataLoadMode
	{
		get
		{
			return DataLoadModeUsers.containsKey(UserInfo.getUserId());
		}
	}
    
    public static set<string> disabledTriggers
    {
        get{
            if(disabledTriggers == null) {
                disabledTriggers = new set<string>();
                PSA_Custom_Trigger_Settings__c pcts = 
                    [SELECT Disable_Assignment_followProject__c, Disable_Client_Meeting_deactivateMeeting__c,
                     Disable_ER_handleNewExpenseReport__c, Disable_ER_populateApprover__c, Disable_Expense_setExpenseType__c,
                     Disable_Milestone_sumMilestoneWeight__c, Disable_Project_pendingCompletionPost__c, Disable_Project_populatePMsMgr__c,
                     Disable_RR_setResourceManager__c, Disable_Survey_Info_answerToNumber__c, Disable_Survey_Info_sumTotalScore__c,
                     Disable_TCHeader_nonBillableMilestone__c, Disable_TCHeader_populateApprover__c, Disable_TC_Split_populateTimePeriod__c
                     FROM PSA_Custom_Trigger_Settings__c WHERE Name = 'Default'];
                
                if(pcts.Disable_Assignment_followProject__c) { disabledTriggers.add('followProject'); }
                if(pcts.Disable_Client_Meeting_deactivateMeeting__c) { disabledTriggers.add('deactivateMeeting'); }
                if(pcts.Disable_ER_handleNewExpenseReport__c) { disabledTriggers.add('handleNewExpenseReport'); }
                if(pcts.Disable_ER_populateApprover__c) { disabledTriggers.add('ERpopulateApprover'); }
                if(pcts.Disable_Expense_setExpenseType__c) { disabledTriggers.add('setExpenseType'); }
                if(pcts.Disable_Milestone_sumMilestoneWeight__c) { disabledTriggers.add('sumMilestoneWeight'); }
                if(pcts.Disable_Project_pendingCompletionPost__c) { disabledTriggers.add('pendingCompletionPost'); }
                if(pcts.Disable_Project_populatePMsMgr__c) { disabledTriggers.add('populatePMsMgr'); }
                if(pcts.Disable_RR_setResourceManager__c) { disabledTriggers.add('setResourceManager'); }
                if(pcts.Disable_Survey_Info_answerToNumber__c) { disabledTriggers.add('answerToNumber'); }
                if(pcts.Disable_Survey_Info_sumTotalScore__c) { disabledTriggers.add('sumTotalScore'); }
                if(pcts.Disable_TCHeader_nonBillableMilestone__c) { disabledTriggers.add('nonBillableMilestone'); }
                if(pcts.Disable_TCHeader_populateApprover__c) { disabledTriggers.add('TCpopulateApprover'); }
                if(pcts.Disable_TC_Split_populateTimePeriod__c) { disabledTriggers.add('populateTimePeriod'); }
            }
            return disabledTriggers;
        }
    }
    
    public static boolean isTriggerDisabled(string methodName)
	{
		return disabledTriggers.contains(methodName);	
	}
}