/*
//////////////////////////////////////
//      @author Vaibhav Jain     //
/////////////////////////////////////
Version :   1.0
Restrict delete rights of Timings for all except System Administrators
Date : 18th Nov 2015
*/
trigger restrictDeleteTimings on WorkIt2__Timing__c (before delete) {
        String userProfileId = UserInfo.getProfileId();
        ID profileId =  [Select id from Profile where Name = 'System Administrator'].Id;
        for(WorkIt2__Timing__c  instOfTiming : trigger.old){
            if (userProfileId != profileId && userinfo.getUserName() != Label.bypassTimingDelete){
                instOfTiming.addError('You are not authorized to delete Timings');
            }
        }
}