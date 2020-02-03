/**********************************************************************************************************
* Author : Sandeep Kumar
* Date : 15 Feb, 2018
* Description : JobAbortController class acts as controller to provide data on JobAbort VF page,
* It aborts the scheduled Jobs based on the Job ID entered by the User.
* Mode - Runs in System Context.
* VF Page - JobAbort_Page
* Test Class - JobAbortController_Test
************************************************************************************************************/
public without sharing class JobAbortController {
    public string scheduledJobId{get;set;}
    public List<CronTrigger> cronTriggerList{get;set;}
    public List<AsyncApexJob> asyncApexJobList{get;set;}
    public Boolean showCron{get;set;}
    public Boolean showAsync{get;set;}
    public JobAbortController(){
        cronTriggerList = new List<CronTrigger>();
        asyncApexJobList = new List<AsyncApexJob>();
        showCron = false;
        showAsync = false;
    }
    
    public pageReference getJobDetail(){
        system.debug('scheduledJobId in getJobDetail = '+scheduledJobId);
        if(scheduledJobId.length() != 15 && scheduledJobId.length() != 18){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter a valid Job Id.'));
        }else{
            cronTriggerList =  [SELECT Id,CronJobDetailId,CronJobDetail.Name,EndTime,NextFireTime,OwnerId,PreviousFireTime,State,TimesTriggered FROM CronTrigger WHERE Id = :scheduledJobId];
            showCron = true;
            if(cronTriggerList.size()==0){
                asyncApexJobList = [SELECT Id,ApexClass.name,Status FROM AsyncApexJob WHERE Id = :scheduledJobId];
                showCron = false;
                showAsync = true;
            }
            if(cronTriggerList.size() == 0 && asyncApexJobList.size()>0){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'There is no Job exist with entered Job Id, Please try again.'));
            }
        }
        return null;
    }
    
    public void abortJob(){
        try{
            system.debug('scheduledJobId in abortJob = '+scheduledJobId);
            // This section can't be covered as we don't want to turn off Job in Production.
            if(scheduledJobId != null){
                system.abortJob(scheduledJobId);
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Job has been successfully aborted.'));
            }
        }Catch(Exception exp){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,exp.getMessage()));
        }         
    }
}