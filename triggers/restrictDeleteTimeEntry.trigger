/*
//////////////////////////////////////
//      @author Vaibhav Jain     //
/////////////////////////////////////
Version :   1.0
Restrict delete rights of Time Entries for all except System Administrators
Date : 18th Nov 2015
*/
trigger restrictDeleteTimeEntry on WorkIt2__Time_Entry__c (before delete) {
        String userProfileId = UserInfo.getProfileId();
        ID profileId =  [Select id from Profile where Name = 'System Administrator'].Id;
        for(WorkIt2__Time_Entry__c  instOfTimeEntry : trigger.old){
            if (userProfileId != profileId){
                instOfTimeEntry.addError('You are not authorized to delete Time Entries');
            }
        }
}