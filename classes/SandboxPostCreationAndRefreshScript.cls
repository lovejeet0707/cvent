/*    
* Author: Sandeep Kumar
* Date: 18-Oct-2017
* Class Name : SandboxPostCreationAndRefreshScript 
*
* Description : Class perform below updates on User Object.
*  - Mass update user email addresses for CRM Team.
*  - Update user profile to System Administrator for Developers.
*
* Last Modified By : Sandeep Kumar (01-Nov-2017)
* What was Added: Abort below Jobs to stop automated emails on sandbox refresh

- Data Export 
- Dashboard Refresh
- Reporting Snapshot
- Report Run

* Test Class - SandboxPostCreationAndRefreshScript_Test
*/
global class SandboxPostCreationAndRefreshScript implements SandboxPostCopy{
    public Set<Id> jobToAbortSet;
    public List<User> userToUpdateList;
    public final String crmTeamUserNames = Label.CRM_Team_User_Names;
    public final String profileIdToUpdate = [Select Id from Profile where Name = 'System Administrator' LIMIT 1].Id;
    public Set<String> postRefreshEmails;
    
    global void runApexClass(SandboxContext context){
        jobToAbortSet = new Set<Id>();
        userToUpdateList = new List<User>();
        postRefreshEmails = new Set<String>();
        postRefreshEmails.addAll(crmTeamUserNames.split(','));
        String newUserEmail = '';
        // Mass update Profile and Email Addresses.
        for(User usr: [Select Id,Name,Email,ProfileId From User Where Email IN :postRefreshEmails AND License__c != 'Guest User License' AND IsPortalEnabled = false AND isActive = True]){
            if(usr.Name.contains('(Sops)')){
                // Update ProfileId to System Administrator
                if(usr.ProfileId != profileIdToUpdate)
                    usr.ProfileId = profileIdToUpdate;
                // Update email address
                newUserEmail = usr.Email.subStringBefore('.invalid');
                if(newUserEmail.contains('@cvent.com'))
                    usr.Email = newUserEmail;
                userToUpdateList.add(usr);
            }
        }
        
        try{
            if(!userToUpdateList.isEmpty())
                update userToUpdateList;
        }Catch(Exception exp){
            System.debug('Do Nothing'+exp.getMessage());
        }
        
        // Deactivate Scheduled Jobs except Schduled Apex and Batch Job
        // Data Export (0)
        // Dashboard Refresh (3)
        // Reporting Snapshot (4)
        // Report Run (8)
        // Report Notification (A)
        for(CronTrigger ct : [SELECT Id FROM CronTrigger WHERE CronJobDetail.JobType in ('0','3','4','8','A') Limit 50000]){
            if(LIMITS.getDMLStatements() < 150){
                system.abortJob(ct.Id);
                System.debug('Job Aborted Successfully '+String.valueOf(ct.id));
            }else{
                if(test.isrunningTest()){
                    jobToAbortSet.add(ct.Id);
                    break;
                }
                else{
                    jobToAbortSet.add(ct.Id);
                }
            }
        }
        
        // Abort Job in Async mode.
        if(!jobToAbortSet.isEmpty()){
            // Future method called to bulk abort jobs.
            abortJobInASync(jobToAbortSet);
        }        
    }
    
    @future
    public static void abortJobInASync(Set<Id> jobToAbortSet){
              
        for(Id jobId : jobToAbortSet){
            system.abortJob(jobId);
            System.debug('Job Aborted Successfully '+String.valueOf(jobId));
        }
    }
}