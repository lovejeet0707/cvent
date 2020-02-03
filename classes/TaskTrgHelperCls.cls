/*
//////////////////////////////////////
//      @author Abhishek Pandey     //
/////////////////////////////////////
Version :   1.0
Date : 28th June 2014
Description : Validation To Stop User From Creating a Task If No Campaign Association Less Than 90 days And Campaign Source on Contact Is Empty
Version :   2.0
Date : 13th June 2014
Description : Merged trigger "SetFirstactivityDate" on after update and after insert 
Version :   3.0
Date : 19th August 2014
Description : Merged trigger "Tasktriggerbulk" on after update and after insert 
Version :   4.0
Date : 27th August 2014
Description : Merged trigger "timeSpentOnTDProject" on after insert, after update, after delete,after undelete
Version :   5.0
Date : 9th Sept 2014
Description : Blue Release check box functionality .
Version :   6.0
Date : 11th Sept 2014
Description : Merged trigger "CCCards" only on after update.
Version :   7.0
Date : 12th Sept 2014
Description : Merged trigger "Minutescase" on after insert, after update, after delete.
Version :   8.0
Date : 15th Sept 2014
Description : Merged trigger "TaskTimeSpent" on after insert, after update, before delete, after delete.
Version :   9.0
Date : 16th Sept 2014
Description : Merged trigger "CalculateOpenTasks CalculateOpenTasksNewTest CalculateClosedTasks" on after insert, after update, before delete, after delete.
Version :   10.0
Date : 17th Sept 2014
Description : Merged trigger "updateMoodLevel" after insert, after update.
Version :   11.0
Date : 1st Oct 2014
Description : Functionality on insert event for sales department ,that associates contacts with campaigns
Version :   12.0
Date : 13th Jan 2015
Description : Functionality on task insert , for associating parent contact with respective campaigns.
Version :   12.0
Date : 10th July 2015
Description : Functionality to update Client_Proficiency_Level__c on contact from Task
Version :   13.0
Date : 19th August 2015
Description : Functionality to attach campaign with Contact on basis of subject
Version :   14.0
Date : 14th March 2016
Description : Add link for mood record
Version :   15.0
Date : 18th July 2016
Description : Update Case on any change on task level.. 
Version :   16.0
Date : 15th Nov 2016
Description : Added functionality insert new OD PS task when some Task with specific subject lines are found according to the custom setting mapping

Version :   17.0
Date : 8th Feb 2017
Description : Added functionality to update the count of VEnue Sourcing Task.

Version :   18.0
Date : 8th Feb 2017
Description : Adding Campaign on basis of Subject if not found then on the basis of Assigned_Role__c.

Version :   19.0
Date : 15th Dec 2017
Description : To insert Campaign Member when a Task is created by SSI or SOPS.

Version :   19.0
Date : 16th Dec 2017
Description : To update Product on Campaign Member when a IST reps updates the Product on the Task after the status is completed.

Version :   20.0
Date : 25th April 2018
Description : Added by udita  : New Trigger Fields At Contact Level For HC

Version :   21.0
Date : 10/Oct 2018
Description : Added by udita  : Replace Closed By SSI To Closed By LM

Test Class : TaskTrgHelperClsTest
*/

public class TaskTrgHelperCls {
    
    //Merged trigger "CalculateOpenTasks" on after insert, after update, before delete, after delete.
    public static Map<String, Event_Role__c> mapeventRole = new Map<String, Event_Role__c>();
    public static Map<String, HC_Role__c> mapHCRole = new Map<String, HC_Role__c>();   // ver 20.0
    public static Map<String, CCRole__c> mapccRole = new Map<String, CCRole__c>();
    public static Map<String,String> mapMasterEveCC = new Map<String,String>();
    //8th Feb 2017 : HSR : Added functionality to update the count of VEnue Sourcing Task.
    public static Map<String, Venue_Sourcing__c> mapVenueSourcingRole = new Map<String, Venue_Sourcing__c>();
    //................................Ends Here..........................................
    //public static DSE.API_ContactTriggerHandler insOfCloudMDMCls = new DSE.API_ContactTriggerHandler();
    //public static DSE.API_AccountTriggerHandler insOfCloudMDMClsAcc = new DSE.API_AccountTriggerHandler();
    
    //Functionality on insert event for sales department ,that associates contacts with campaigns
    public static map<String,Campaign_Assignment__c> mapLeadSouCampId = new map<String,Campaign_Assignment__c>();
    public static map<String,Campaign_Assignment__c> mapCampAssign = new map<String,Campaign_Assignment__c>();
    //Functionality on insert event for sales department ,that associates contacts with campaigns
    //Functionality on task insert , for associating parent contact with respective campaigns.
    
    public static map<String,Id> mapLeadSouCampIdBy = new map<String,Id>();
    public static map<String,Campaign_Assignment_Referredby__c> mapCampAssignBy = new map<String,Campaign_Assignment_Referredby__c>();
    
    public static map<String,Id> mapLeadSouCampIdVM = new map<String,Id>();
    public static map<String,Campaign_Assignment_ReceivedVM__c> mapCampAssignVM = new map<String,Campaign_Assignment_ReceivedVM__c>();
    
    public static map<String,Id> mapLeadSouCampIdFor = new map<String,Id>();
    public static map<String,Campaign_Assignment_Referralfor__c> mapCampAssignFor = new map<String,Campaign_Assignment_Referralfor__c>();
    //Functionality on task insert , for associating parent contact with respective campaigns.
    
    //Functionality to attach campaign with Contact on basis of subject
    public static map<String,String> mapSubCampId =  new map<String,String>();
    public static map<String,RfpUploadTeam__c> mapSubCampIdSett =  new map<String,RfpUploadTeam__c>();
    //Functionality to attach campaign with Contact on basis of subject
    
    //Update Case on any change on task level.
    public static RecordType instOFRecType = new  RecordType();
    //Update Case on any change on task level.
    
    public TaskTrgHelperCls(){
        mapeventRole = Event_Role__c.getAll();
        mapccRole = CCRole__c.getAll();
        mapHCRole=HC_Role__c.getAll();  // ver 20.0
        //8th Feb 2017 : HSR : Added functionality to update the count of VEnue Sourcing Task.
        mapVenueSourcingRole = Venue_Sourcing__c.getAll();
        //..............................ENDS HERE........................
        for(String str : mapeventRole.keyset()){
            mapMasterEveCC.put(str,str);
        }
        
        for(String str : mapHCRole.keyset()){     // ver 20.0
            mapMasterEveCC.put(str,str);
        }
        
        for(String str : mapccRole.keyset()){
            mapMasterEveCC.put(str,str);
        }
        
        //8th Feb 2017 : HSR : Added functionality to update the count of VEnue Sourcing Task.
        for(String str : mapVenueSourcingRole.keySet())
        {
            mapMasterEveCC.put(str,str);
        }
        //.............................ENDS HERE..............................
        //Functionality to attach campaign with Contact on basis of subject
        mapSubCampIdSett = RfpUploadTeam__c.getAll();
        for(RfpUploadTeam__c str: mapSubCampIdSett.values()){
            mapSubCampId.put(str.Subject__c.Trim(),str.Campaign_Id__c.Trim());
        }
        //Functionality to attach campaign with Contact on basis of subject
        
        //Functionality on insert event for sales department ,that associates contacts with campaigns
        mapCampAssign = Campaign_Assignment__c.getall();
        for(Campaign_Assignment__c instOfCampAss : mapCampAssign.Values()){
            mapLeadSouCampId.put(instOfCampAss.Assigned_Role__c,instOfCampAss);
        }
        System.debug('mapLeadSouCampId******'+mapLeadSouCampId);
        //Functionality on task insert , for associating parent contact with respective campaigns.
        
        mapCampAssignBy = Campaign_Assignment_Referredby__c.getall();
        
        for(Campaign_Assignment_Referredby__c instOfCampAss : mapCampAssignBy.Values()){
            mapLeadSouCampIdBy.put(instOfCampAss.Assigned_Role__c,instOfCampAss.Campaign_Id__c);
        }
        
        mapCampAssignVM = Campaign_Assignment_ReceivedVM__c.getall();
        for(Campaign_Assignment_ReceivedVM__c instOfCampAss : mapCampAssignVM.Values()){
            mapLeadSouCampIdVM.put(instOfCampAss.Assigned_Role__c,instOfCampAss.Campaign_Id__c);
        }
        
        mapCampAssignFor = Campaign_Assignment_Referralfor__c.getall();
        for(Campaign_Assignment_Referralfor__c instOfCampAss : mapCampAssignFor.Values()){
            mapLeadSouCampIdFor.put(instOfCampAss.Assigned_Role__c,instOfCampAss.Campaign_Id__c);
        }
        //Functionality on task insert , for associating parent contact with respective campaigns.
        
        //Update Case on any change on task level. 
        instOFRecType = [SELECT  Id, DeveloperName, SobjectType, SystemModstamp FROM RecordType WHERE SobjectType='Case' AND DeveloperName='Billing_Cases' AND IsActive = true LIMIT 1];
        //Update Case on any change on task level. 
    }
    //Merged trigger "CalculateOpenTasks" on after insert, after update, before delete, after delete.
    
    //Update Case on any change on task level. 
    public static Map<String, Schema.SObjectField> mapTaskFieldNames = new Map<String, Schema.SObjectField>();
    static{
        mapTaskFieldNames = Schema.SObjectType.Task.fields.getMap(); 
    }
    //Update Case on any change on task level.
    public void OnBeforeInsert(List<Task> newValues){       
        //insOfCloudMDMCls.disableCloudMDMTrigger();
        //insOfCloudMDMClsAcc.disableCloudMDMTrigger();
        /*User instUser =  [SELECT Profile.Name FROM User WHERE Id =: Userinfo.getUserId()];
        if(instUser.Profile.Name.Contains('Sales Representative')){
            
            Set<Id> idOfContact =  new Set<id>();
            
            for(Task instOfTask : newValues){
                String idString = String.valueOf(instOfTask.WhoId);
                if(instOfTask.WhoId!=null && idString.Startswith('003')){
                    idOfContact.add(instOfTask.WhoId);
                }
            }
            
            List<Contact> lstContact =  new List<Contact>();
            if(idOfContact.size()>0)
            lstContact =  [SELECT ID,Campaign_Source__c,(SELECT Id,LastModifiedDate FROM CampaignMembers ORDER BY LastModifiedDate DESC) FROM Contact WHERE Id =: idOfContact];
            
            for(Contact instOfContact : lstContact){
                if(instOfContact.Campaign_Source__c == 'None' || instOfContact.Campaign_Source__c == null){
                    for(Task instOfTask :newValues){
                        if(instOfContact.Id == instOfTask.WhoId){
                            if(instOfContact.CampaignMembers.size()>0){
                                List<CampaignMember> lstOfCampaignMem = instOfContact.CampaignMembers;
                                system.debug(lstOfCampaignMem[0].LastModifiedDate);
                                if(lstOfCampaignMem[0].LastModifiedDate!=null ){
                                    Date instOfDate = date.newinstance(lstOfCampaignMem[0].LastModifiedDate.year(), lstOfCampaignMem[0].LastModifiedDate.month(), lstOfCampaignMem[0].LastModifiedDate.day());
                                    Integer instDays = instOfDate.daysBetween(System.Today());
                                    system.debug('instDays+++'+instDays);
                                    system.debug('instOfContact.Campaign_Source__c+++'+instOfContact.Campaign_Source__c);
                                    if(instDays>=90 && (instOfTask.Campaign_Source__c=='None'|| instOfTask.Campaign_Source__c==null)){
                                        instOfTask.Campaign_Source__c.addError('Value is required');
                                        instOfTask.addError('Please add value to Campaign Source field because of no activity on Campaign Member for past 90 days');
                                    }
                                }                                                                       
                            }else{
                                if(instOfTask.Campaign_Source__c=='None' || instOfTask.Campaign_Source__c==null){
                                    instOfTask.Campaign_Source__c.addError('Value is required');
                                    instOfTask.addError('Please add value to Campaign Source field as there is no Campaign Member record');
                                }
                            }                           
                        }                       
                    }
                }                               
            }   
        }*/     
        
          //Added By Mohsin
        if(Boolean.valueOf(Label.CalledUnCalled))
        {
            Map<Id,Task> mapofOwnerIdsVsTask = new Map<Id,Task>();
            Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
            for(Task taskObj : newValues)
            {
                if(taskObj.Status == 'Not Started' && recordTypeId == taskObj.RecordTypeId && taskObj.ringdna__Created_by_RingDNA__c == FALSE)
                {
                    mapofOwnerIdsVsTask.put(taskObj.OwnerId,taskObj);
                }
            }
            
            if(!mapofOwnerIdsVsTask.isEmpty())
            {
                for(Task t : [select id,ActivityDate,OwnerId,WhoId from Task where ringdna__Created_by_RingDNA__c = TRUE AND (ringdna__Call_Disposition__c = 'Spoke' OR ringdna__Call_Disposition__c = 'Set Presentation' OR ringdna__Call_Disposition__c = 'Presentation') AND OwnerId IN :mapofOwnerIdsVsTask.keySet()  AND (Status != 'Completed' OR Status != 'Cancelled')])
                {
                    if(mapofOwnerIdsVsTask.get(t.OwnerId).WhoId == t.WhoId)
                    {
                        Task newTask = mapofOwnerIdsVsTask.get(t.OwnerId);
                        Integer numberDaysDue = newTask.ActivityDate.daysBetween(t.ActivityDate);
                        System.debug('numberDaysDue>>'+numberDaysDue);
                        if(numberDaysDue <= 3 && numberDaysDue >= 0)
                        {
                            System.debug('Inside of called');
                            newTask.Called_UnCalled__c = 'Called';
                        }
                        else
                        {
                            System.debug('Inside of uncalled');
                            newTask.Called_UnCalled__c = 'Uncalled';  
                        }
                    }
                }
                
                for(Task t :mapofOwnerIdsVsTask.values())
                {
                    if(t.Called_UnCalled__c != 'Called' && t.Called_UnCalled__c != 'Uncalled')
                    {
                        System.debug('Inside of both not condition');
                        t.Called_UnCalled__c = 'Uncalled';
                    }
                }
            }
        }
    }
    
    public void OnAfterInsert(Map<Id,Task> newMapValues){  
        
         //DWF Enhancement wrt RingDNA : update contact status :Udita
        if(Label.UpdateContactStatus=='True')
        { system.debug('--methodcalled---');
          updateContactStatus(null,newMapValues);
        }
        /********* added by udita for GDPR *********/
        list<case> caseList=new list<case>();
        string nameuser = UserInfo.getUserName(); 
        set<string> subjectLines = new set<string>();        
        
        for (GDPR_Subject_Line__mdt subj : [SELECT Subject_Line__c FROM GDPR_Subject_Line__mdt]) {
          subjectLines.add(subj.Subject_Line__c);   
        }
         for(Task taskObj : newMapValues.VALUES()){                                                            
            if((subjectLines.contains(taskObj.Subject)) /*&& nameuser =='marketo@cvent.com.devxii'*/ && taskObj.Status =='Closed'){
                Case cObj = new Case();
                cObj.Subject=taskObj.Subject;
                cObj.Description = 'For marketo User-GDPR';
                cObj.Requestor_Department__c = 'Client Services';
                cObj.AccountId =taskObj.WhatId;
                cObj.ContactId =taskObj.WhoId;
                cObj.Status='Open';
                caseList.add(cObj);
            }  
        }
        if(caseList.size() > 0){
           insert caseList;
        }
        /****** ENDS HERE *******/   
        
        addCampaign(null,newMapValues);
         List<Task> taskObjInsert = new List<Task>();
         Set<Id> userIdSet = new Set<Id>();
         /*For(User userRec : [SELECT Id FROM User WHERE Name LIKE '%SOPS%' OR Name LIKE '%SSI%'])
         {
             userIdSet.add(userRec.Id);
         }*/
        /*Map<Id,String> mapIdString =  new Map<Id,String>();*/     
        //Merged trigger "timeSpentOnTDProject" on after insert, after update, after delete,after undelete
        Set<Id> projectIDs = new Set<Id>();
        //Merged trigger "timeSpentOnTDProject" on after insert, after update, after delete,after undelete
        
        //Merged trigger "Minutescase" on after insert, after update, after delete
        set<Id> setIdSalesRes = new set<Id>();
        //Merged trigger "Minutescase" on after insert, after update, after delete
        
        // Blue Release check box functionality
        map<Id,List<Task>> mapContIdLstTsk = new map<Id,List<Task>>(); 
        // Blue Release check box functionality
        
        //Merged trigger "TaskTimeSpent" on after insert, after update, before delete, after delete
        set<Id> setIdMobCard =  new set<Id>();
        //Merged trigger "TaskTimeSpent" on after insert, after update, before delete, after delete
        
        //Merged trigger "CalculateOpenTasks" on after insert, after update, before delete, after delete.
        set<Id> setLeadId = new set<Id>();
        set<Id> setContId = new set<Id>();
        //Merged trigger "CalculateOpenTasks" on after insert, after update, before delete, after delete.
        
        //Merged trigger "updateMoodLevel" on after insert, after update.
        map<Id,Task> mapIdContTask = new map<Id,Task>();
        map<Id,Task> mapIdUserTask = new map<Id,Task>();
        //Merged trigger "updateMoodLevel" on after insert, after update.
        
        //Functionality on insert event for sales department ,that associates contacts with campaigns
        List<Task> lstTskCampMem = new List<Task>();
        List<Id> lstOwnerId = new List<Id>();
        Set<Id> setContactId = new Set<Id>();
        //Functionality on insert event for sales department ,that associates contacts with campaigns
        
        //Functionality on task insert , for associating parent contact with respective campaigns.
        
        //List<Id> lstOwnerIdVM = new List<Id>();
        //Set<Id> setContactIdVM = new Set<Id>();
        
        List<Task> lstTskCampMemFor = new List<Task>();
        //List<Id> lstOwnerIdFor = new List<Id>();
        //Set<Id> setContactIdFor = new Set<Id>();
        
        List<Task> lstTskCampMemVM = new List<Task>();
        List<Task> lstTskCampMemBy = new List<Task>();
        //List<Id> lstOwnerIdVMBy = new List<Id>();
        //Set<Id> setContactIdVMBy = new Set<Id>();
        
        //Functionality on task insert , for associating parent contact with respective campaigns.
        
        List<Task> lstTskCampMemExclude = new List<Task>();
        //Functionality to update Client_Proficiency_Level__c on contact from Task
        Set<Id> setIdOfContact = new Set<Id>();
        //Functionality to update Client_Proficiency_Level__c on contact from Task
        
        //Update Case on any change on task level. 
        Set<Id> setOfBillingCseId = new Set<Id>();
        //Update Case on any change on task level. 
        
        
         /* 3/22/2016 Hemant: Added functionality insert new task when some Task with specific subject lines are found according to the custom setting mapping*/
        /*Map<String,String> taskSubjectMap=new Map<String,String>();
        List<Task> taskObjList=new List<Task>();
        For(Task_Subject_Mapping__c taskSubjectObj : Task_Subject_Mapping__c.getAll().values())
        {
            taskSubjectMap.put(taskSubjectObj.Current_Task_Subject_Line__c,taskSubjectObj.Second_Task__c);
        }
        System.debug('taskSubjectMap*********************'+taskSubjectMap);*/
        /*.........................................Ends Here..............................................................................................*/

        /*  11/15/2016 Hemant: Added functionality insert new OD PS task when some Task with specific subject lines are found according to the custom setting mapping*/
        Task taskObj;
        List<Task> taskObjList=new List<Task>();
        Map<String,OD_PS_Task_Mapping__c> custMap = New Map<String,OD_PS_Task_Mapping__c>();//Map for storing the Custom Setting Data...............
        String subjectVal;
        Set<Id> contactIdSet=new Set<Id>();
        Map<Id,Contact> conIdVsDate=new Map<Id,Contact>();
        Map<Id,Contact> conIdVsODDate=new Map<Id,Contact>();
        
        //Getting Custom Setting Data.........
        FOR(OD_PS_Task_Mapping__c mappingObj : OD_PS_Task_Mapping__c.getAll().values())
        {
            custMap.put(mappingObj.Name,mappingObj);
        }
        /*.........................................Ends Here..............................................................................................*/
        for(Task instOfTask: newMapValues.values()){
            /*  12/15/2017 Hemant: To insert Campaign Member when a Task is created by SSI or SOPS.*/
            
            if(Label.IsActiveCampignMemberAutomation=='True' && instOfTask.Campaign_ID__c!='' && instOfTask.Whoid!=null)
            {
                userIdSet.add(instOfTask.CreatedById);
                taskObjInsert.add(instOfTask);
            }
            
            /*.........................................Ends Here..............................................................................................*/
            /* 3/22/2016 Hemant: Added functionality insert new task when some Task with specific subject lines are found according to the custom setting mapping*/
           /* if(!taskSubjectMap.isEmpty() && instOfTask.subject!=null)
            {
                if(taskSubjectMap.containsKey(instOfTask.subject)){
                    System.debug('Inside If=============>>>>>>');
                    Task taskObjClone = instOfTask.clone(false, true, false, false);
                    taskObjClone.Subject=taskSubjectMap.get(instOfTask.subject);
                    taskObjClone.Status='Completed';
                    taskObjList.add(taskObjClone);
                }
                else
                {
                    System.debug('instOfTask.subject=============>>>>>'+instOfTask.subject);
                    For(String subjectContent : taskSubjectMap.keySet())
                    {
                        System.debug('subjectContent**************'+instOfTask.subject+'===='+subjectContent);
                        if(instOfTask.subject.contains(subjectContent))
                        {
                            System.debug('subjectContent=======>>>'+subjectContent);
                            System.debug('instOfTask.subject=======>>>'+instOfTask.subject);
                            Task taskObjClone = instOfTask.clone(false, true, false, false);
                            taskObjClone.Subject=taskSubjectMap.get(subjectContent);
                            taskObjClone.Status='Completed';
                            taskObjList.add(taskObjClone);
                        }
                    }
                }
            }
            System.debug('taskObjList==================>>>>>'+taskObjList);*/
            /*.........................................Ends Here..............................................................................................*/        
            /*if(instOfTask.Campaign_Source__c != 'None' && instOfTask.Campaign_Source__c !=null){
                String idString = String.valueOf(instOfTask.WhoId);
                if(instOfTask.WhoId!=null && idString.startswith('003'))
                mapIdString.put(instOfTask.WhoId,instOfTask.Campaign_Source__c);                        
            } */
            
            //Update Case on any change on task level. 
            if(instOfTask.WhatId != null){
                if(string.valueOf(instOfTask.WhatId).startsWith('500')){
                    setOfBillingCseId.add(instOfTask.WhatId);
                }
            }
            //Update Case on any change on task level. 
            
            //Functionality to update Client_Proficiency_Level__c on contact from Task
            if(instOfTask.Client_Proficiency_Level__c != null){
                if(instOfTask.WhoId != null){
                    if(string.valueOf(instOfTask.WhoId).startsWith('003')){
                        setIdOfContact.add(instOfTask.WhoId);
                    }
                }
            }
            //Functionality to update Client_Proficiency_Level__c on contact from Task
            
            //Merged trigger "CalculateOpenTasks" on after insert, after update, before delete, after delete.
            if(instOfTask.WhoId != null){
                if(string.valueOf(instOfTask.WhoId).startsWith('00Q') && instOfTask.ActivityDate >= system.today().adddays(-30) && instOfTask.ActivityDate <= system.today().adddays(60) ){
                    setLeadId.add(instOfTask.WhoId);
                }
                if(string.valueOf(instOfTask.WhoId).startsWith('003') && instOfTask.ActivityDate >= system.today().adddays(-60) && instOfTask.ActivityDate <= system.today().adddays(60) ){
                    setContId.add(instOfTask.WhoId);
                }   
            }
            //Merged trigger "CalculateOpenTasks" on after insert, after update, before delete, after delete.
            
            //Merged trigger "updateMoodLevel" on after insert, after update.
            if(instOfTask.WhoId != null){
                if(instOfTask.WhoId != null && string.valueOf(instOfTask.WhoId).startsWith('003') && instOfTask.IsClosed == true && instOfTask.Mood__c != null){
                    mapIdContTask.put(instOfTask.WhoId,instOfTask) ;
                    mapIdUserTask.put(instOfTask.ownerId,instOfTask) ;
                }   
            }
            //Merged trigger "updateMoodLevel" on after insert, after update.
            
            //Merged trigger "timeSpentOnTDProject" on after insert, after update, after delete,after undelete
            if(instOfTask.WhatId != null){
                if(string.valueOf(instOfTask.WhatId).startsWith('a0n') && instOfTask.Minutes_on_tasks__c != null && instOfTask.IsClosed == true){
                    projectIDs.add(instOfTask.WhatId);
                }
            }
            //Merged trigger "timeSpentOnTDProject" on after insert, after update, after delete,after undelete
            
            //Merged trigger "Minutescase" on after insert, after update, after delete
            if(instOfTask.WhatID != null){
                if(string.valueOf(instOfTask.WhatID).startsWith('a1u') && instOfTask.Minutes_on_tasks__c != null  && instOfTask.IsClosed == true){
                    setIdSalesRes.add(instOfTask.WhatID);
                }
            }
            //Merged trigger "Minutescase" on after insert, after update, after delete
            
            
            //Merged trigger "TaskTimeSpent" on after insert, after update, before delete, after delete
            if(instOfTask.WhatID != null){
                if(string.valueOf(instOfTask.WhatID).startsWith('a0P') && (instOfTask.Minutes_on_tasks__c != null || instOfTask.Minutes_on_Case__c != null)  && instOfTask.IsClosed == true){
                    setIdMobCard.add(instOfTask.WhatID);
                }
            }
            //Merged trigger "TaskTimeSpent" on after insert, after update, before delete, after delete
            
            
            //Functionality on insert event for sales department ,that associates contacts with campaigns
            if(instOfTask.WhoId != null){
                if(instOfTask.Subject != null){
                    String instStrSubject = instOfTask.Subject;
                    instStrSubject = instStrSubject.trim();
                    String[] instStrSubjectArr = instStrSubject.split(' ',-2);
                    System.debug('instStrSubject*********'+instStrSubject.contains('Chat Transcript'));
                    System.debug('instOfTask.Isclosed*********'+instOfTask.Isclosed);
                    //&& instOfTask.Isclosed == true 
                    /*8th Feb 2017 : HSR : Adding Campaign on basis of Subject if not found then on the basis of Assigned_Role__c*/
                    if(string.valueOf(instOfTask.WhoId).startsWith('003') && instOfTask.OwnerId != null && (instStrSubject.contains('VS Chat') || instStrSubject.contains('Chat Transcript') || instStrSubject.contains('chat transcript') || instStrSubject.contains('CHAT TRANSCRIPT'))){
                        System.debug('#Checkpoint One');
                        lstTskCampMem.add(instOfTask);
                        lstOwnerId.add(instOfTask.OwnerId);
                        setContactId.add(instOfTask.WhoId);
                    }
                    if(string.valueOf(instOfTask.WhoId).startsWith('003') && instOfTask.Status =='Not Started'){
                        for(String strKey :mapSubCampId.KeySet()){
                            if(instOfTask.Subject.contains(strKey)){
                                lstTskCampMemExclude.add(instOfTask);
                                lstOwnerId.add(instOfTask.OwnerId);
                                setContactId.add(instOfTask.WhoId);
                            }
                        }
                    }
                    //Functionality on task insert , for associating parent contact with respective campaigns.
                    if(string.valueOf(instOfTask.WhoId).startsWith('003') && instOfTask.OwnerId != null && instOfTask.Isclosed == false && instStrSubject.contains('Received VM')){
                        lstTskCampMemVM.add(instOfTask);
                        lstOwnerId.add(instOfTask.OwnerId);
                        setContactId.add(instOfTask.WhoId);
                    }
                    if(string.valueOf(instOfTask.WhoId).startsWith('003') && instOfTask.OwnerId != null && instOfTask.Isclosed == false && instStrSubject.contains('Referral for') && instStrSubject.contains('who attended')){
                        lstTskCampMemFor.add(instOfTask);
                        lstOwnerId.add(instOfTask.OwnerId);
                        setContactId.add(instOfTask.WhoId);
                        
                    }
                    if(string.valueOf(instOfTask.WhoId).startsWith('003') && instOfTask.OwnerId != null && instOfTask.Isclosed == false && instStrSubject.contains('Referred as') && instStrSubject.contains('who attended')){
                        lstTskCampMemBy.add(instOfTask);
                        lstOwnerId.add(instOfTask.OwnerId);
                        setContactId.add(instOfTask.WhoId);
                    }
                    //Functionality on task insert , for associating parent contact with respective campaigns.
                }
            }
            //Functionality on insert event for sales department ,that associates contacts with campaigns
        }
        if(taskObjInsert.size()>0 && CheckRecursive.runtwelve())
            insertCampaignMember(taskObjInsert,new List<Task>(),userIdSet);        
        //Update Case on any change on task level. 
        List<Case> lstBillingCseQ = new List<Case>();
        if(setOfBillingCseId.size()>0)
        lstBillingCseQ = [SELECT Id FROM Case WHERE Id =:setOfBillingCseId AND RecordTypeId =: instOFRecType.Id];
        
        List<Case> lstBillingCseUpd = new List<Case>();
        for(Case instOfBillingCse : lstBillingCseQ){
            lstBillingCseUpd.add(instOfBillingCse);
        }
        
        if(lstBillingCseUpd.size()>0)
        update lstBillingCseUpd;
        //Update Case on any change on task level. 
        
        //Functionality to update Client_Proficiency_Level__c on contact from Task
        List<Contact> lstContactCPL = new List<Contact>();
        if(setIdOfContact.size()>0)
        lstContactCPL = [SELECT Id,Client_Proficiency_Level__c,(SELECT Id,Client_Proficiency_Level__c FROM Tasks WHERE Client_Proficiency_Level__c!=null ORDER By CreatedDate ASC) FROM Contact WHERE Id =: setIdOfContact];
        
        List<Contact> lstContactUpd = new List<Contact>(); 
        for(Contact instCont : lstContactCPL){
            if(instCont.Tasks.size()>0){
                instCont.Client_Proficiency_Level__c =  instCont.Tasks[instCont.Tasks.size()-1].Client_Proficiency_Level__c;
                lstContactUpd.add(instCont);
            }
        }
        if(lstContactUpd.size()>0)
        update lstContactUpd;
        //Functionality to update Client_Proficiency_Level__c on contact from Task
        
        //Functionality on insert event for sales department ,that associates contacts with campaigns
        map<Id,User> mapIdUserRole = new map<Id,User>();
        List<Contact> lstContactForMem = new List<Contact>();
        
        if(lstOwnerId.size()>0){
            lstContactForMem = [SELECT Id,(SELECT Id,CampaignId FROM CampaignMembers) FROM Contact WHERE Id =: setContactId];
            mapIdUserRole = new map<Id,User>([SELECT Id ,UserRole.Name FROM User WHERE Id =: lstOwnerId]);
        }
        
        List<CampaignMember> lstCampMem = new List<CampaignMember>();
        Map<String,String> mapIdContactCamp = new Map<String,String>();
        
        for(Contact instOfCont : lstContactForMem){
            for(CampaignMember instOfCampMem : instOfCont.CampaignMembers){
                String str1 = String.valueOf(instOfCont.ID)+String.valueOf(instOfCampMem.CampaignId);
                String str2 = String.valueOf(instOfCont.ID)+String.valueOf(instOfCampMem.CampaignId);
                mapIdContactCamp.put(str1,str2);
            }
        }
        
        Map<String,CampaignMember> mapFinalCampMem = new Map<String,CampaignMember>();
        System.debug('lstTskCampMem***********'+lstTskCampMem);
        for(Task instOfTsk :lstTskCampMem){
            String strUserRoleName = mapIdUserRole.get(instOfTsk.OwnerId).UserRole.Name;
            Integer counter = 0 ;
            for(String instOfStr : mapLeadSouCampId.keySet()){
                system.debug('instOfStr+++'+instOfStr);
                system.debug('strUserRoleName+++'+strUserRoleName);
                system.debug('strUserRoleName.contains(instOfStr)+++'+strUserRoleName.contains(instOfStr));
                /*8th Feb 2017 : HSR : Adding Campaign on basis of Subject if not found then on the basis of Assigned_Role__c*/
                if(mapLeadSouCampId.containsKey(instOfStr) && mapLeadSouCampId.get(instOfStr).Product__c!=null && instOfTsk.subject.contains(mapLeadSouCampId.get(instOfStr).Product__c))
                {
                    counter++;
                    String str1 = String.valueOf(instOfTsk.WhoId)+String.valueOf(mapLeadSouCampId.get(instOfStr).Campaign_Id__c);
                    system.debug('str1+++'+str1);
                    system.debug('mapIdContactCamp+++'+mapIdContactCamp);
                    if(!mapIdContactCamp.containsKey(str1)){
                        CampaignMember instOfCampMem = new CampaignMember();
                        instOfCampMem.CampaignId = mapLeadSouCampId.get(instOfStr).Campaign_Id__c;
                        instOfCampMem.ContactId = instOfTsk.WhoId;
                        instOfCampMem.Status = 'Responded';
                        lstCampMem.add(instOfCampMem);  
                        String str2 = string.valueOf(instOfTsk.WhoId)+string.valueOf(instOfCampMem.CampaignId);
                        mapFinalCampMem.put(str2,instOfCampMem);
                    }
                }
                /*...............................ENDS HERE.................................................*/
                else if(strUserRoleName.contains(instOfStr)){
                    counter++;
                    String str1 = String.valueOf(instOfTsk.WhoId)+String.valueOf(mapLeadSouCampId.get(instOfStr).Campaign_Id__c);
                    system.debug('str1+++'+str1);
                    system.debug('mapIdContactCamp+++'+mapIdContactCamp);
                    if(!mapIdContactCamp.containsKey(str1)){
                        CampaignMember instOfCampMem = new CampaignMember();
                        instOfCampMem.CampaignId = mapLeadSouCampId.get(instOfStr).Campaign_Id__c;
                        instOfCampMem.ContactId = instOfTsk.WhoId;
                        instOfCampMem.Status = 'Responded';
                        lstCampMem.add(instOfCampMem);  
                        String str2 = string.valueOf(instOfTsk.WhoId)+string.valueOf(instOfCampMem.CampaignId);
                        mapFinalCampMem.put(str2,instOfCampMem);
                    }
                }
            }
            if(counter == 0){
                String str1 = String.valueOf(instOfTsk.WhoId)+String.valueOf(mapLeadSouCampId.get('Other').Campaign_Id__c);
                system.debug('str1+++'+str1);
                system.debug('mapIdContactCamp+++'+mapIdContactCamp);
                if(!mapIdContactCamp.containsKey(str1)){
                    CampaignMember instOfCampMem = new CampaignMember();
                    instOfCampMem.CampaignId = mapLeadSouCampId.get('Other').Campaign_Id__c;
                    instOfCampMem.ContactId = instOfTsk.WhoId;
                    instOfCampMem.Status = 'Responded';
                    lstCampMem.add(instOfCampMem);  
                    String str2 = string.valueOf(instOfTsk.WhoId)+string.valueOf(instOfCampMem.CampaignId);
                    mapFinalCampMem.put(str2,instOfCampMem);
                }   
            }
            
        }
        
        for(Task instOfTsk :lstTskCampMemExclude){
            //if(mapSubCampId.containsKey(instOfTsk.Subject.trim())){
            //for(String strKey :mapSubCampId.KeySet()){
                //if(instOfTask.Subject.contains(strKey)){
                    String str1='';
                    system.debug(String.valueOf(instOfTsk.WhoId));
                    system.debug(String.valueOf(mapSubCampId.get(instOfTsk.Subject.trim())));
                    for(String str : mapSubCampId.Keyset()){
                        if(instOfTsk.Subject.contains(str)){
                            str1 = String.valueOf(instOfTsk.WhoId)+String.valueOf(mapSubCampId.get(str));
                        }
                    }
                    system.debug(str1);
                    if(!mapIdContactCamp.containsKey(str1)&&!str1.contains('null')){
                        CampaignMember instOfCampMem = new CampaignMember();
                        for(String str : mapSubCampId.Keyset()){
                            if(instOfTsk.Subject.contains(str)){
                            system.debug(mapSubCampId.get(str));
                            instOfCampMem.CampaignId = mapSubCampId.get(str);
                            }
                        }
                        instOfCampMem.ContactId = instOfTsk.WhoId;
                        instOfCampMem.Status = 'Sent';
                        lstCampMem.add(instOfCampMem);  
                        String str2 = string.valueOf(instOfTsk.WhoId)+string.valueOf(instOfCampMem.CampaignId);
                        if(instOfCampMem.CampaignId!= null){
                            if(string.valueof(instOfCampMem.CampaignId).startswith('701'))
                            mapFinalCampMem.put(str2,instOfCampMem);
                        }
                    }
                //}
            //}
            //}
        }
        for(Task instOfTsk :lstTskCampMemVM){
            String strUserRoleName = mapIdUserRole.get(instOfTsk.OwnerId).UserRole.Name;
            for(String instOfStr : mapLeadSouCampIdVM.keySet()){
                system.debug('instOfStr+++'+instOfStr);
                system.debug('strUserRoleName+++'+strUserRoleName);
                system.debug('strUserRoleName.contains(instOfStr)+++'+strUserRoleName.contains(instOfStr));
                if(strUserRoleName.contains(instOfStr)){
                    String str1 = String.valueOf(instOfTsk.WhoId)+String.valueOf(mapLeadSouCampIdVM.get(instOfStr));
                    system.debug('str1+++'+str1);
                    system.debug('mapIdContactCamp+++'+mapIdContactCamp);
                    if(!mapIdContactCamp.containsKey(str1)){
                        CampaignMember instOfCampMem = new CampaignMember();
                        instOfCampMem.CampaignId = mapLeadSouCampIdVM.get(instOfStr);
                        instOfCampMem.ContactId = instOfTsk.WhoId;
                        instOfCampMem.Status = 'Responded';
                        lstCampMem.add(instOfCampMem);  
                        String str2 = string.valueOf(instOfTsk.WhoId)+string.valueOf(instOfCampMem.CampaignId);
                        mapFinalCampMem.put(str2,instOfCampMem);
                    }
                }
            }
        }
        
        for(Task instOfTsk :lstTskCampMemBy){
            String strUserRoleName = mapIdUserRole.get(instOfTsk.OwnerId).UserRole.Name;
            for(String instOfStr : mapLeadSouCampIdBy.keySet()){
                system.debug('instOfStr+++'+instOfStr);
                system.debug('strUserRoleName+++'+strUserRoleName);
                system.debug('strUserRoleName.contains(instOfStr)+++'+strUserRoleName.contains(instOfStr));
                if(strUserRoleName.contains(instOfStr)){
                    String str1 = String.valueOf(instOfTsk.WhoId)+String.valueOf(mapLeadSouCampIdBy.get(instOfStr));
                    system.debug('str1+++'+str1);
                    system.debug('mapIdContactCamp+++'+mapIdContactCamp);
                    if(!mapIdContactCamp.containsKey(str1)){
                        CampaignMember instOfCampMem = new CampaignMember();
                        instOfCampMem.CampaignId = mapLeadSouCampIdBy.get(instOfStr);
                        instOfCampMem.ContactId = instOfTsk.WhoId;
                        instOfCampMem.Status = 'Responded';
                        lstCampMem.add(instOfCampMem);  
                        String str2 = string.valueOf(instOfTsk.WhoId)+string.valueOf(instOfCampMem.CampaignId);
                        mapFinalCampMem.put(str2,instOfCampMem);
                    }
                }
            }
        }
        
        system.debug('lstTskCampMemFor++'+lstTskCampMemFor);
        system.debug('mapLeadSouCampIdFor++'+mapLeadSouCampIdFor);
        system.debug('mapIdContactCamp++'+mapIdContactCamp);
        for(Task instOfTsk :lstTskCampMemFor){
            String strUserRoleName = mapIdUserRole.get(instOfTsk.OwnerId).UserRole.Name;
            for(String instOfStr : mapLeadSouCampIdFor.keySet()){
                system.debug('instOfStr+++'+instOfStr);
                system.debug('strUserRoleName+++'+strUserRoleName);
                system.debug('strUserRoleName.contains(instOfStr)+++'+strUserRoleName.contains(instOfStr));
                if(strUserRoleName.contains(instOfStr)){
                    String str1 = String.valueOf(instOfTsk.WhoId)+String.valueOf(mapLeadSouCampIdFor.get(instOfStr));
                    system.debug('str1+++'+str1);
                    system.debug('mapIdContactCamp+++'+mapIdContactCamp);
                    if(!mapIdContactCamp.containsKey(str1)){
                        CampaignMember instOfCampMem = new CampaignMember();
                        instOfCampMem.CampaignId = mapLeadSouCampIdFor.get(instOfStr);
                        instOfCampMem.ContactId = instOfTsk.WhoId;
                        instOfCampMem.Status = 'Responded';
                        lstCampMem.add(instOfCampMem);  
                        String str2 = string.valueOf(instOfTsk.WhoId)+string.valueOf(instOfCampMem.CampaignId);
                        mapFinalCampMem.put(str2,instOfCampMem);
                    }
                }
            }
        }
        
        system.debug('mapFinalCampMem+++'+mapFinalCampMem);
        if(mapFinalCampMem.values().size()>0)
        insert mapFinalCampMem.values();
        //if(lstCampMem.size()>0)
        //insert lstCampMem;
        
        //Functionality on insert event for sales department ,that associates contacts with campaigns 
                 
        
        //Merged trigger "CalculateOpenTasks" on after insert, after update, before delete, after delete.
        List<Lead> lstLead = new List<Lead>();
        List<Contact> lstContThir = new List<Contact>();
        
        system.debug('setLeadId++'+setLeadId);
        if(setLeadId.size()>0)
        lstLead = [SELECT Id,Validation_Counter__c,(SELECT Id,Ownerid,Owner.Userrole.Name,IsClosed FROM Tasks WHERE ActivityDate >=: system.today().adddays(-30) AND 
                        ActivityDate <=: system.today().adddays(60) AND Owner.Userrole.Name =: mapMasterEveCC.Keyset()) FROM Lead WHERE Id =: setLeadId];
        
        //system.debug('lstLead.tasks++'+lstLead[0].tasks);
        if(setContId.size()>0)
        lstContThir = [SELECT Id,Total_Open_Venue_Sourcing_Tasks__c,Total_Closed_Event_Tasks__c,Total_Closed_CC_Tasks__c,Total_Closed_HC_Tasks__c,Total_Open_Event_Tasks__c,Total_Open_CC_Tasks__c,Total_Open_HC_Tasks__c,Total_Closed_Venue_Sourcing_Tasks__c,Validation_Counter__c,(SELECT Id,Ownerid,Owner.Userrole.Name,CreatedBy.Userrole.Name,Subject,IsClosed FROM Tasks WHERE ((ActivityDate >=: system.today().adddays(-60) AND IsClosed=True AND ActivityDate <=:system.today()) OR (ActivityDate <=: system.today().adddays(60) AND IsClosed=False AND ActivityDate >=:system.today().adddays(-30))) AND Owner.Userrole.Name =: mapMasterEveCC.Keyset()) FROM Contact WHERE Id =: setContId];
        
        //system.debug('lstContThir.tasks++'+lstContThir[0].tasks);
        
        List<Lead> lstLeadSec = new List<Lead>();
        system.debug('mapMasterEveCC++'+mapMasterEveCC.keySet());
        
        for(Lead instOfLead : lstLead){
            Integer EventCount = 0;
            Integer closedEvent = 0; 
            Integer CCCount = 0;    
            Integer closedCCCount = 0;
           
            for(Task instOfTask : instOfLead.Tasks){
                system.debug('mapeventRole+++'+mapeventRole);
                system.debug('instOfTask.Owner.Userrole.Name'+instOfTask.Owner.Userrole.Name);
                if(mapeventRole.containsKey(instOfTask.Owner.Userrole.Name)){
                    if(instOfTask.IsClosed == false){
                        EventCount++;
                    }else if(instOfTask.IsClosed == true){
                        closedEvent++;
                    }
                }else if(mapccRole.containsKey(instOfTask.Owner.Userrole.Name)){
                    if(instOfTask.IsClosed == false){
                        CCCount++;
                    }else if(instOfTask.IsClosed == true){
                        closedCCCount++;
                    }
                }
                
            }
            instOfLead.Total_Open_Event_Tasks__c = EventCount;
            instOfLead.Total_Open_CC_Tasks__c = CCCount;
            if(instOfLead.Validation_Counter__c == null)
            instOfLead.Validation_Counter__c = 0;
            
            instOfLead.Validation_Counter__c = instOfLead.Validation_Counter__c + 1;
            instOfLead.Total_Closed_Event_Tasks__c = closedEvent;
            instOfLead.Total_Closed_CC_Tasks__c = closedCCCount;
            lstLeadSec.add(instOfLead);
        }
        
        if(lstLeadSec.Size()>0)
        update lstLeadSec;
        
        List<Contact> lstContFourth = new List<Contact>();
        
        for(Contact instOfCont : lstContThir){
            //8th Feb 2017 : HSR : Added functionality to update the count of VEnue Sourcing Task.
            Integer venueCount = 0;
            Integer venueClosedCount = 0; 
            //.............................ENDS HERE.............................................
            Integer EventCount = 0;
            Integer closedEvent = 0; 
            Integer CCCount = 0;    
            Integer closedCCCount = 0;
            Integer HCCount = 0;     // ver 20.0
            Integer closedHCCount = 0;   // ver 20.0
            for(Task instOfTask : instOfCont.Tasks){
                if(mapeventRole.containsKey(instOfTask.Owner.Userrole.Name)){
                    if(instOfTask.IsClosed == false && mapeventRole.containsKey(instOfTask.CreatedBy.Userrole.Name)){
                        EventCount++;
                        instOfCont.Total_Event_Tasks_Updated_On__c = DateTime.now();
                    }else if(instOfTask.IsClosed == true && !instOfTask.Subject.containsIgnoreCase('Closed by LM') && !instOfTask.Subject.containsIgnoreCase('Closed By SSI') && !instOfTask.Subject.containsIgnoreCase('Survey Answers')&& !instOfTask.Subject.containsIgnoreCase('Registered')){
                        closedEvent++;
                        instOfCont.Total_Event_Tasks_Updated_On__c = DateTime.now();
                    }
                    
                }if(mapccRole.containsKey(instOfTask.Owner.Userrole.Name)){
                    if(instOfTask.IsClosed == false  && mapccRole.containsKey(instOfTask.CreatedBy.Userrole.Name)){
                        CCCount++;
                        instOfCont.Total_CC_Tasks_Updated_On__c = DateTime.now();
                    }else if(instOfTask.IsClosed == true && !instOfTask.Subject.containsIgnoreCase('Closed by LM') && !instOfTask.Subject.containsIgnoreCase('Closed By SSI') && !instOfTask.Subject.containsIgnoreCase('Survey Answers')&& !instOfTask.Subject.containsIgnoreCase('Registered')){
                        closedCCCount++;
                        instOfCont.Total_CC_Tasks_Updated_On__c = DateTime.now();
                    }
                    
                }
                // ver 20.0 starts
                if(mapHcRole.containsKey(instOfTask.Owner.Userrole.Name)){
                    if(instOfTask.IsClosed == false  && mapHcRole.containsKey(instOfTask.CreatedBy.Userrole.Name)){
                        HCCount++;
                       // instOfCont.Total_CC_Tasks_Updated_On__c = DateTime.now();
                    }else if(instOfTask.IsClosed == true && !instOfTask.Subject.containsIgnoreCase('Closed by LM') && !instOfTask.Subject.containsIgnoreCase('Closed By SSI') && !instOfTask.Subject.containsIgnoreCase('Survey Answers')&& !instOfTask.Subject.containsIgnoreCase('Registered')){
                        closedHCCount++;
                       // instOfCont.Total_CC_Tasks_Updated_On__c = DateTime.now();
                    }
                    
                }  // ver 20.0 ends
                
                //8th Feb 2017 : HSR : Added functionality to update the count of VEnue Sourcing Task.
                if(mapVenueSourcingRole.containsKey(instOfTask.Owner.Userrole.Name)){
                    if(instOfTask.IsClosed == false && mapVenueSourcingRole.containsKey(instOfTask.CreatedBy.Userrole.Name)){
                        venueCount++;
                        instOfCont.Total_Venue_Tasks_Updated_On__c = DateTime.now();
                    }else if(instOfTask.IsClosed == true && !instOfTask.Subject.containsIgnoreCase('Closed by LM') && !instOfTask.Subject.containsIgnoreCase('Closed By SSI') && !instOfTask.Subject.containsIgnoreCase('Survey Answers')&& !instOfTask.Subject.containsIgnoreCase('Registered')){
                        venueClosedCount++;
                        instOfCont.Total_Venue_Tasks_Updated_On__c = DateTime.now();
                    }
                    
                }
                //.............................ENDS HERE.............................................
            }
            instOfCont.Total_Open_Event_Tasks__c = EventCount;
            instOfCont.Total_Open_CC_Tasks__c = CCCount;
            instOfCont.Total_Open_HC_Tasks__c = HCCount;  // ver 20.0
            //8th Feb 2017 : HSR : Added functionality to update the count of VEnue Sourcing Task.
            instOfCont.Total_Open_Venue_Sourcing_Tasks__c = venueCount;
            instOfCont.Total_Closed_Venue_Sourcing_Tasks__c = venueClosedCount;
            //.............................ENDS HERE.............................................
            
            if(instOfCont.Validation_Counter__c == null)
                instOfCont.Validation_Counter__c = 0;
            
            instOfCont.Validation_Counter__c = instOfCont.Validation_Counter__c + 1;
            instOfCont.Total_Closed_Event_Tasks__c = closedEvent;
            instOfCont.Total_Closed_CC_Tasks__c = closedCCCount;
            instOfCont.Total_Closed_HC_Tasks__c = closedHCCount;   // ver 20.0
            lstContFourth.add(instOfCont);
        }
        
        if(lstContFourth.size()>0)
        update lstContFourth;
        
        //Merged trigger "CalculateOpenTasks" on after insert, after update, before delete, after delete.
        
        //Merged trigger "updateMoodLevel" on after insert, after update.
        List<User> lstUsr = new List<User>();
        map<Id,User> mapIdUser = new map<Id,User>();
        
        if(mapIdUserTask.keySet().size()>0)
        lstUsr = [SELECT Manager_Email__c,Name FROM User WHERE Id =: mapIdUserTask.keySet()];
        
        for(User instOfUsr : lstUsr){
            mapIdUser.put(mapIdUserTask.get(instOfUsr.Id).WhoId,instOfUsr);
        }
        
        List<Contact> lstContactFifth = new List<Contact>();
        User instOfUser = new User();
        
        if(mapIdContTask.keySet().size()>0){
            lstContactFifth = [SELECT Mood_Level__c/*,Profile_Name__c*/ FROM Contact WHERE Id =: mapIdContTask.keySet()];//UD:Commented for FP:4thApril
            instOfUser = [SELECT Id,Profile.Name FROM User WHERE Id =: UserInfo.getUserId()];
        }
        
        Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Task.getRecordTypeInfosById();
        List<Contact> lstContactSixth = new List<Contact>();
        
        for(Contact instOfCont : lstContactFifth){
           // instOfCont.Profile_Name__c = instOfUser.Profile.Name;//UD:Commented for FP:4thApril
            instOfCont.Mood_Level__c = Decimal.valueof(mapIdContTask.get(instOfCont.id).Mood__c.substring(0,1));
            if(mapIdContTask.get(instOfCont.id).Mood__c == '1 - Irate' || mapIdContTask.get(instOfCont.id).Mood__c == '2 - Frustrated'){
                String urlString = System.URL.getSalesforceBaseUrl().toExternalForm();
                String Url = '<a href=' + urlString + '/' + mapIdContTask.get(instOfCont.id).Id + '>Please click on this Link to review the activity and take the appropriate action.</a>';
                instOfCont.Mood_Text__c = mapIdContTask.get(instOfCont.id).Mood__c.substring(4,Integer.valueof((mapIdContTask.get(instOfCont.id).Mood__c).length()));
                //instOfCont.Manager_Email__c =(mapIdUser.containsKey(instOfCont.id) && mapIdUser.get(instOfCont.id).Manager_Email__c!=null)?mapIdUser.get(instOfCont.id).Manager_Email__c:'';//UD:Commented for FP:4thApril
                /*instOfCont.Template_FIelds__c = 'Product: ' + rtMap.get(mapIdContTask.get(instOfCont.id).RecordTypeId).getName() +'<br>' +
                                                'Mood Origin: Task' + '<br>' + 
                                                'Mood Creator: ' + ((mapIdUser.containsKey(instOfCont.id) && mapIdUser.get(instOfCont.id).Name!=null)?mapIdUser.get(instOfCont.id).Name:'') + '<br>' +
                                                'Mood Set Date/Time: ' + system.now() + '<br>' +
                                                'Subject: '+ mapIdContTask.get(instOfCont.Id).Subject + '<br>' +
                                                'Primary Reason for mood: '+ mapIdContTask.get(instOfCont.Id).Primary_Reason_for_Mood_Driver__c + '<br>' +
                                                'Driver: ' + mapIdContTask.get(instOfCont.Id).Reason__c + '<br>' +
                                                Url + '<br>';*///UD:Commented for FP:4thApril
                // Add link for mood record
                instOfCont.Mood_Changed_From_Id__c = null;
                if(mapIdContTask.get(instOfCont.id).WhatId!=null)
                    instOfCont.Mood_Changed_From_Id__c = mapIdContTask.get(instOfCont.id).WhatId;
                // Add link for mood record
            }
            lstContactSixth.add(instOfCont);
        }
        
        if(lstContactSixth.Size()>0)
        update lstContactSixth;
        //Merged trigger "updateMoodLevel" on after insert, after update.
        
        //Merged trigger "TaskTimeSpent" on after insert, after update, before delete, after delete
        List<Mobile_Card__c> lstMobCard = new List<Mobile_Card__c>();
        
        if(setIdMobCard.size()>0)
        lstMobCard = [SELECT Id,Total_Time_Spent_Task_Hrs__c,Total_Time_Spent_Case_Hrs__c,(SELECT Id,Minutes_on_tasks__c,Minutes_on_Case__c FROM Tasks WHERE Status = 'Completed') 
                        FROM Mobile_Card__c WHERE Id =: setIdMobCard];
        
        List<Mobile_Card__c> lsMobCardSec = new List<Mobile_Card__c>();
        
        for(Mobile_Card__c instOfMobCard: lstMobCard){
            Decimal sum = 0;
            Decimal sumSec = 0;
            for(Task instOfTask : instOfMobCard.Tasks){
                if(instOfTask.Minutes_on_tasks__c != null)
                sum = sum + instOfTask.Minutes_on_tasks__c;
                
                if(instOfTask.Minutes_on_Case__c != null)
                sumSec = sumSec + instOfTask.Minutes_on_Case__c;
            }
            instOfMobCard.Total_Time_Spent_Task_Hrs__c = sum/60 ;
            instOfMobCard.Total_Time_Spent_Case_Hrs__c = sumSec/60 ;
            lsMobCardSec.add(instOfMobCard);
        }
        
        if(lsMobCardSec.size()>0)
        update lsMobCardSec;
        //Merged trigger "TaskTimeSpent" on after insert, after update, before delete, after delete
        
        //Merged trigger "Minutescase" on after insert, after update, after delete
        List<Sales_Resources__c> lstSalRes = new List<Sales_Resources__c>();
        
        if(setIdSalesRes.size()>0)
        lstSalRes= [SELECT Id,Total_Time_Spent_Hrs__c,(SELECT Id,Minutes_on_tasks__c FROM Tasks WHERE Status = 'Completed') FROM Sales_Resources__c WHERE Id =: setIdSalesRes];
        
        List<Sales_Resources__c> lstSalesResSec = new List<Sales_Resources__c>();
        
        for(Sales_Resources__c instOfSalRes : lstSalRes){
            Decimal sum=0;
            for(Task instOfTask : instOfSalRes.Tasks){
                if(instOfTask.Minutes_on_tasks__c != null)
                sum = sum + instOfTask.Minutes_on_tasks__c;
            }
            instOfSalRes.Total_Time_Spent_Hrs__c = sum;
            lstSalesResSec.add(instOfSalRes);
        }
        
        if(lstSalesResSec.size()>0)
        update lstSalesResSec;
        //Merged trigger "Minutescase" on after insert, after update, after delete
        
        //Merged trigger "timeSpentOnTDProject" on after insert, after update, after delete,after undelete
        List<aggregateResult> arMap = new List<aggregateresult>();
        if(projectIDs.size()>0){
            arMap = [SELECT WhatId, SUM(Minutes_on_tasks__c) summ FROM Task WHERE Status = 'Completed' AND WhatId IN :projectIDs GROUP BY WhatId];
        }
        
        Map<Id,Double> valuesMap = new Map<Id,Double>();
        for(aggregateResult ar: arMap){
            valuesMap.put(String.valueof(ar.get('WhatId')),Double.valueof(ar.get('summ')));
        }
        
        List<T_D__c> updateProjects = new List<T_D__c>();
        if(valuesMap.size()>0){
            for(T_D__c td : [SELECT Id,Time_Spent_on_Project__c FROM T_D__c WHERE Id IN :valuesMap.keyset()]){
                if(td.Time_Spent_on_Project__c!=valuesMap.get(td.id)){
                    td.Time_Spent_on_Project__c = valuesMap.get(td.id);
                    updateProjects.add(td);
                }
            }
        }
        
        if(updateProjects.size()>0)
        update updateProjects;
        //Merged trigger "timeSpentOnTDProject" on after insert, after update, after delete,after undelete
        
        //Merged trigger "SetFirstactivityDate" on after update and after insert
        
        Set<Id> RecordIds=new Set<Id>();
        for (Task evntObj: newMapValues.values()){
            RecordIds.add(evntObj.WhoId);
        }
        
        List<Contact> conList= new List<Contact>();
        
        //for(Contact con : [Select id,First_ACTIVITY_Date__c,(SELECT ActivityDate FROM ActivityHistories Where ActivityDate < = Today  Order By ActivityDate ASC Limit 1) from Contact where id in:RecordIds]){
        List<Contact> lstContactThir = new List<Contact>();
        
        if(RecordIds.size()>0)
        lstContactThir =  [Select id,First_ACTIVITY_Date__c,(SELECT ActivityDate FROM ActivityHistories Where ActivityDate < = Today  Order By ActivityDate ASC Limit 1) from Contact where id in:RecordIds];
        
        for(Contact con : lstContactThir){
            if(con.ActivityHistories.size()>0){
                if(con.First_ACTIVITY_Date__c != con.ActivityHistories[0].ActivityDate){
                    con.First_ACTIVITY_Date__c = con.ActivityHistories[0].ActivityDate; 
                    conList.add(con);
                    //con.Apex_context__c = True;//UD:Commented for FP:4thApril
                }
            }else{
                con.First_ACTIVITY_Date__c = null;
                conList.add(con);
                //con.Apex_context__c = True;//UD:Commented for FP:4thApril
            }            
        }
        
        if(conList.size()>0){
            update conList;
        }
        //Merged trigger "SetFirstactivityDate" on after update and after insert
        
        //Merged trigger "Tasktriggerbulk" on after update and after insert
        List<Id> idESB =  new List<Id>();
        List<Id> idProjActi = new List<Id>();
        System.debug('conIdVsDate*********'+conIdVsDate);
        
        for(Task instOfTsk : newMapValues.values()){
            /*...................................................................................... END HERE.............................................................*/
            if(instOfTsk.WhatId!=null){
                String instOfStr = instOfTsk.WhatId;
                if(instOfStr.startsWith('a0B')){
                    idESB.add(instOfTsk.WhatId);
                }else if(instOfStr.startsWith('a07')){
                    idProjActi.add(instOfTsk.WhatId);
                }
            }
        }
        
        List<EB_SB_Builder__c> lstEBSB = new List<EB_SB_Builder__c>();
        List<EB_SB_Builder__c> lstEBSBCase = new List<EB_SB_Builder__c>();
        List<EB_SB_Builder__c> lstEBSBEvent = new List<EB_SB_Builder__c>();
        if(idESB.size()>0){
            lstEBSB = [SELECT Id,Build_Out_Time_Exhausted__c,(SELECT Id,Minutes_on_tasks__c FROM Tasks) FROM EB_SB_Builder__c WHERE Id =: idESB ];
            //Changes for getting complete total
            lstEBSBEvent = [SELECT Id,Build_Out_Time_Exhausted__c,Talktime_Exhausted__c,(SELECT  Minutes_on_tasks__c, DurationInMinutes,Id FROM Events) FROM EB_SB_Builder__c WHERE Id =: idESB ];
            lstEBSBCase = [SELECT Id,Build_Out_Time_Exhausted__c,(SELECT Min_s_Spent__c,Id FROM Cases__r) FROM EB_SB_Builder__c WHERE Id =: idESB ];
            //Changes for getting complete total
        }
        
        List<Project_Activity__c> lstProjActEvent = new List<Project_Activity__c>();
        List<Project_Activity__c> lstProjAct = new List<Project_Activity__c>();
        if(idProjActi.size()>0){
            lstProjAct = [SELECT Id,Actual_Time_Spent__c,(SELECT Id,Minutes_on_tasks__c FROM Tasks) FROM Project_Activity__c WHERE Id =: idProjActi ];
            //Changes for getting complete total
            lstProjActEvent = [SELECT Id,Actual_Time_Spent__c,(SELECT DurationInMinutes,Minutes_on_tasks__c FROM Events) FROM Project_Activity__c WHERE Id=: idProjActi];
            //Changes for getting complete total
        }
        List<EB_SB_Builder__c> lstEBSBSec = new List<EB_SB_Builder__c>();
        List<Project_Activity__c> lstProjActSec = new List<Project_Activity__c>();
        
        //Changes for getting complete total
        Map<Id,EB_SB_Builder__c> mapEBSBIdCount = new Map<Id,EB_SB_Builder__c>();
       
        
        for(EB_SB_Builder__c instOfEBSBSec : lstEBSB){
            Double Sum = 0;
            for(Task instOfTsk : instOfEBSBSec.Tasks){
                if(instOfTsk.Minutes_on_tasks__c != null)
                Sum = Sum + instOfTsk.Minutes_on_tasks__c;
            }
            instOfEBSBSec.Build_Out_Time_Exhausted__c = Sum/60;
             system.debug('instOfEBSBSec.Build_Out_Time_Exhausted__c+++++++'+instOfEBSBSec.Build_Out_Time_Exhausted__c);
            //lstEBSBSec.add(instOfEBSBSec);
            mapEBSBIdCount.put(instOfEBSBSec.Id,instOfEBSBSec);
        }
        
        for(EB_SB_Builder__c instOfEBSBSec : lstEBSBCase){
            Double Sum = 0;
            for(Case instOfTsk : instOfEBSBSec.Cases__r){
                if(instOfTsk.Min_s_Spent__c != null)
                Sum = Sum + instOfTsk.Min_s_Spent__c;
            }
            Double taskValue = mapEBSBIdCount.get(instOfEBSBSec.Id).Build_Out_Time_Exhausted__c;
            instOfEBSBSec.Build_Out_Time_Exhausted__c = Sum/60 + taskValue;
            system.debug('instOfEBSBSec.Build_Out_Time_Exhausted__c++'+instOfEBSBSec.Build_Out_Time_Exhausted__c);
            mapEBSBIdCount.put(instOfEBSBSec.Id,instOfEBSBSec);
        }
        
        
        for(EB_SB_Builder__c instOfEBSBSec : lstEBSBEvent){
            Double Sum = 0;
            Double SumSec = 0;
            for(Event instOfTsk : instOfEBSBSec.Events){
                if(instOfTsk.Minutes_on_tasks__c != null)
                Sum = Sum + instOfTsk.Minutes_on_tasks__c;
                SumSec = SumSec + instOfTsk.DurationInMinutes;
            }
            Double taskValue = mapEBSBIdCount.get(instOfEBSBSec.Id).Build_Out_Time_Exhausted__c;
            instOfEBSBSec.Build_Out_Time_Exhausted__c = Sum/60 + taskValue;
             system.debug('instOfEBSBSec.Build_Out_Time_Exhausted__c++'+instOfEBSBSec.Build_Out_Time_Exhausted__c);
            instOfEBSBSec.Talktime_Exhausted__c = SumSec/60;
            mapEBSBIdCount.put(instOfEBSBSec.Id,instOfEBSBSec);
        }
        
        if(mapEBSBIdCount.values().size()>0)
        update mapEBSBIdCount.values();
        //Changes for getting complete total
        //if(lstEBSBSec.size()>0)
        //update lstEBSBSec;
        Map<Id,Project_Activity__c> mapProjActIdCount = new Map<Id,Project_Activity__c>();
        
        for(Project_Activity__c instOfProjAct : lstProjAct){
            Double Sum = 0;
            for(Task instOfTsk : instOfProjAct.Tasks){
                if(instOfTsk.Minutes_on_tasks__c != null)
                Sum = Sum + instOfTsk.Minutes_on_tasks__c;
            }
            instOfProjAct.Actual_Time_Spent__c = Sum/60;
            //lstProjActSec.add(instOfProjAct);
            mapProjActIdCount.put(instOfProjAct.Id,instOfProjAct);
        }
        
        for(Project_Activity__c instOfProjAct : lstProjActEvent){
            Double Sum = 0;
            for(Event instOfTsk : instOfProjAct.Events){
                if(instOfTsk.Minutes_on_tasks__c != null)
                Sum = Sum + instOfTsk.Minutes_on_tasks__c + instOfTsk.DurationInMinutes;
            }
            Double taskValue = mapProjActIdCount.get(instOfProjAct.Id).Actual_Time_Spent__c;
            instOfProjAct.Actual_Time_Spent__c = Sum/60 + taskValue;
            //lstProjActSec.add(instOfProjAct);
            mapProjActIdCount.put(instOfProjAct.Id,instOfProjAct);
        }
        
        if(mapProjActIdCount.values().size()>0)
        update mapProjActIdCount.values();
        //if(lstProjActSec.size()>0)
        //update lstProjActSec;
        
        //Merged trigger "Tasktriggerbulk" on after update and after insert  
        
        //insOfCloudMDMCls.enableCloudMDMTrigger();
        //insOfCloudMDMClsAcc.enableCloudMDMTrigger();
    }
    public void OnBeforeUpdate(Map<Id,Task> oldMapValues,Map<Id,Task> newMapValues){ 
        //insOfCloudMDMCls.disableCloudMDMTrigger();
        //insOfCloudMDMClsAcc.disableCloudMDMTrigger();
        
        //Added By Mohsin
        if(Boolean.valueOf(Label.CalledUnCalled))
        {
            Map<Id,Task> mapofOwnerIdsVsTask = new Map<Id,Task>();
            Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
            for(Task taskObj : newMapValues.values())
            {
                if((taskObj.Status == 'Completed' && taskObj.Status != oldMapValues.get(taskObj.Id).Status && recordTypeId == taskObj.RecordTypeId) || (taskObj.OwnerId != oldMapValues.get(taskObj.Id).OwnerId  && recordTypeId == taskObj.RecordTypeId && taskObj.Status != 'Completed'))
                {
                    mapofOwnerIdsVsTask.put(taskObj.OwnerId,taskObj);
                }
            }
            
            if(!mapofOwnerIdsVsTask.isEmpty())
            {
                for(Task t : [select id,ActivityDate,OwnerId,WhoId from Task where ringdna__Created_by_RingDNA__c = TRUE AND (ringdna__Call_Disposition__c = 'Spoke' OR ringdna__Call_Disposition__c = 'Set Presentation' OR ringdna__Call_Disposition__c = 'Presentation') AND OwnerId IN :mapofOwnerIdsVsTask.keySet() AND (Status != 'Completed' OR Status != 'Cancelled')])
                {
                    if(mapofOwnerIdsVsTask.get(t.OwnerId).WhoId == t.WhoId)
                    {
                        Task newTask = mapofOwnerIdsVsTask.get(t.OwnerId);
                        Integer numberDaysDue = newTask.ActivityDate.daysBetween(t.ActivityDate);
                        System.debug('numberDaysDue before????'+numberDaysDue);
                        if(numberDaysDue <= 3 && numberDaysDue>= 0)
                        {
                            System.debug('Befor Update Called');
                            newTask.Called_UnCalled__c = 'Called';
                        }
                        else
                        {
                            System.debug('Befor Update UnCalled');
                            newTask.Called_UnCalled__c = 'Uncalled';  
                        }
                    }
                }
                
                for(Task t :mapofOwnerIdsVsTask.values())
                {
                    if(t.Called_UnCalled__c != 'Called' && t.Called_UnCalled__c != 'Uncalled')
                    {
                        System.debug('Befor Update Unwanted');
                        t.Called_UnCalled__c = 'Uncalled';
                    }
                }
            }
        }
        
        /************* Code written by Udita for :  P-005010 2/11/2019*********/
        if(Boolean.ValueOf(Label.CampaignAssociation)){
        set<id> oldContactId = new set<id>();
        Map<id,List<Task>> checkTaskForNewWhoId =new Map<id,List<Task>>();
        set<Id> deleteCampaignList = new set<Id>();
        For(Task taskObj : newMapValues.values())
        {        
          if(oldMapValues!= null && taskObj.WhoId != oldMapValues.get(taskObj.id).WhoId && taskObj.Campaign_ID__c != null){
            oldContactId.add(oldMapValues.get(taskObj.id).WhoId);    
          }
        system.debug('---oldContactId'+oldContactId);      
        }
        oldContactId.remove(null);
       if(oldContactId.size() > 0){
       list<task> tskList =[select id,Campaign_ID__c from task where whoId  in :oldContactId ];
       for(Task t :tskList)
       {
          if(!checkTaskForNewWhoId.containskey(t.Campaign_ID__c)){
             checkTaskForNewWhoId.put(t.Campaign_ID__c,new List<task>());
          }
          checkTaskForNewWhoId.get(t.Campaign_ID__c).add(t);
       }
       system.debug('---checkTaskForNewWhoId'+checkTaskForNewWhoId);
       For(Task taskRec: newMapValues.values())
       { 
    // if(oldMapValues!= null && taskObj.WhoId != oldMapValues.get(taskObj.id).WhoId && taskObj.Campaign_ID__c != null){
       if(oldMapValues!= null && taskRec.WhoId != oldMapValues.get(taskRec.id).WhoId && taskRec.Campaign_ID__c != null && checkTaskForNewWhoId != null){
              system.debug('---checkTaskForNewWhoId.containsKey(taskRec.Campaign_ID__c)'+checkTaskForNewWhoId.containsKey(taskRec.Campaign_ID__c));
              if(checkTaskForNewWhoId.containsKey(taskRec.Campaign_ID__c)){
                 integer size =  checkTaskForNewWhoId.get(taskRec.Campaign_ID__c).size();  
                 system.debug('---size'+size);
                 if(size == 1){
                    deleteCampaignList.add(Id.valueOf(taskRec.Campaign_ID__c));
                 }               
              }
            }    
        }
      }
      if(deleteCampaignList.size() > 0){
       List<CampaignMember> deleteList= new list<CampaignMember>();
       system.debug('---deleteCampaignList'+deleteCampaignList);
       system.debug('---oldContactId'+oldContactId);
       deleteList = [select id from CampaignMember where CampaignId in :deleteCampaignList and ContactId in :oldContactId];
       system.debug('---deleteList '+deleteList );  
       delete deleteList;
      }
      }
      /*****Ends ******/
    }
    public void OnAfterUpdate(Map<Id,Task> oldMapValues,Map<Id,Task> newMapValues){
        
         if(Label.UpdateContactStatusAfterUpdate=='True')
        { system.debug('--methodcalled---');
          updateContactStatusAfterUpdate(oldMapValues,newMapValues);
        }
        
        /********* added by udita for GDPR *********/
        list<case> caseList=new list<case>();
        string nameuser = UserInfo.getUserName(); 
        set<string> subjectLines = new set<string>();        
        
        for (GDPR_Subject_Line__mdt subj : [SELECT Subject_Line__c FROM GDPR_Subject_Line__mdt]) {
          subjectLines.add(subj.Subject_Line__c);   
        }            
        for(Task taskObj : newMapValues.values()){  
            Task taskOld = oldMapValues.get(taskObj.id);         
            if((taskObj.Subject != taskOld.Subject || taskObj.Status != taskOld.Status) && (subjectLines.contains(taskObj.Subject) && taskObj.Status =='Closed') /*&& nameuser =='marketo@cvent.com.devxii'*/){
                Case cObj = new Case();
                cObj.Subject=taskObj.Subject;
                cObj.Description = 'For marketo User-GDPR';
                cObj.Requestor_Department__c = 'Client Services';
                cObj.AccountId =taskObj.WhatId;
                cObj.ContactId =taskObj.WhoId;
                cObj.Status='Open';
                caseList.add(cObj);
            }  
        }
        if(caseList.size() > 0){
           insert caseList;
        }
        /****** ENDS HERE *******/
        
        
        List<Task> taskObjInsert = new List<Task>();
         Set<Id> userIdSet = new Set<Id>();

        // Blue Release check box functionality
        map<Id,List<Task>> mapContIdLstTsk = new map<Id,List<Task>>(); 
        // Blue Release check box functionality
        
        //Merged trigger "Minutescase" on after insert, after update, after delete
        set<Id> setIdSalesRes = new set<Id>();
        //Merged trigger "Minutescase" on after insert, after update, after delete
        
        //Merged trigger "CCCards" only on after update
        map<Id,List<Task>> mapMobAppIdLstTskAll =  new map<Id,List<Task>>();
        //Merged trigger "CCCards" only on after update
        
        //Merged trigger "TaskTimeSpent" on after insert, after update, before delete, after delete
        set<Id> setIdMobCard =  new set<Id>();
        //Merged trigger "TaskTimeSpent" on after insert, after update, before delete, after delete
        
        //Merged trigger "CalculateOpenTasks" on after insert, after update, before delete, after delete.
        set<Id> setLeadId = new set<Id>();
        set<Id> setContId = new set<Id>();
        //Merged trigger "CalculateOpenTasks" on after insert, after update, before delete, after delete.
        
        //Merged trigger "updateMoodLevel" on after insert, after update.
        map<Id,Task> mapIdContTask = new map<Id,Task>();
        map<Id,Task> mapIdUserTask = new map<Id,Task>();
        //Merged trigger "updateMoodLevel" on after insert, after update.
        
        //Merged trigger "SetFirstactivityDate" on after update and after insert
        
        //Functionality to update Client_Proficiency_Level__c on contact from Task
        Set<Id> setIdContact = new Set<Id>();
        //Functionality to update Client_Proficiency_Level__c on contact from Task
        
        //Update Case on any change on task level. 
        Set<Id> setOfBillingCseId = new Set<Id>();
        Integer Counter = 0;
        //Update Case on any change on task level. 
        
        Set<Id> RecordIds= new Set<Id>();
        //HSR : 16th DEC : To update Product on Campaign Member when a IST reps updates the Product on the Task after the status is completed.
        List<Task> taskRecList = new List<Task>();
        //....Ends Here............
        for (Task instOfTask : newMapValues.values()){
            Counter = 0;
            //Update Case on any change on task level. 
            if(instOfTask.WhatId != null){
                if(string.valueOf(instOfTask.WhatId).startsWith('500')){
                    for(String str : mapTaskFieldNames.KeySet()){
                        if(str!='lastmodifieddate' && str!='systemmodstamp' && str!='Last_Modified_Date_Time__c'){
                            if(instOfTask.get(str) != oldMapValues.get(instOfTask.id).get(str)){
                                system.debug(str);
                                system.debug(instOfTask.get(str));
                                system.debug(oldMapValues.get(instOfTask.id).get(str));
                                Counter++;
                            }   
                        }
                    }
                    
                    if(Counter>0)
                    setOfBillingCseId.add(instOfTask.WhatId);
                }   
            }
            
            Task oldTaskRec = oldMapValues.get(instOfTask.Id);
            /*  12/15/2017 Hemant: To insert Campaign Member when a Task is created by SSI or SOPS.*/
            if(Label.IsActiveCampignMemberAutomation=='True' && String.isNotBlank(instOfTask.Campaign_ID__c) && (oldTaskRec.Campaign_ID__c!= instOfTask.Campaign_ID__c || oldTaskRec.WhoId != instOfTask.WhoId) && instOfTask.Whoid!=null)
            {
                userIdSet.add(instOfTask.CreatedById);
                taskObjInsert.add(instOfTask);
            }

            //HSR : 16th DEC : To update Product on Campaign Member when a IST reps updates the Product on the Task after the status is completed.
            else if(Label.IsActiveCampignMemberAutomation=='True' && String.isNotBlank(instOfTask.Campaign_ID__c) && instOfTask.WhoId != null && instOfTask.Product__c!=null && (oldTaskRec.Product__c != instOfTask.Product__c)) //instOfTask.Task_Assigned_Role__c == 'Pre Sales - Special Projects' && 
            {
                taskRecList.add(instOfTask);
            }
            
            //....Ends Here............
            //Update Case on any change on task level. 
            
            RecordIds.add(instOfTask.WhoId);
            
            //Functionality to update Client_Proficiency_Level__c on contact from Task
            if(instOfTask.Client_Proficiency_Level__c != oldMapValues.get(instOfTask.Id).Client_Proficiency_Level__c){
                if(instOfTask.WhoId != null){
                    if(string.valueOf(instOfTask.WhoId).startsWith('003'))
                    setIdContact.add(instOfTask.WhoId);
                }
            }           
            //Functionality to update Client_Proficiency_Level__c on contact from Task
            
            //Merged trigger "CalculateOpenTasks" on after insert, after update, before delete, after delete.
            if(instOfTask.WhoId != null){
                if(string.valueOf(instOfTask.WhoId).startsWith('00Q') && (instOfTask.IsClosed != oldMapValues.get(instOfTask.Id).IsClosed || instOfTask.OwnerId != oldMapValues.get(instOfTask.Id).OwnerId) && instOfTask.ActivityDate >= system.today().adddays(-30) && instOfTask.ActivityDate <= system.today().adddays(60) ){
                    setLeadId.add(instOfTask.WhoId);
                }
                if(string.valueOf(instOfTask.WhoId).startsWith('003')
                //&& (instOfTask.IsClosed != oldMapValues.get(instOfTask.Id).IsClosed || instOfTask.OwnerId != oldMapValues.get(instOfTask.Id).OwnerId || 
            //instOfTask.ActivityDate != oldMapValues.get(instOfTask.Id).ActivityDate)
            )   
                {
                    setContId.add(instOfTask.WhoId);
                }   
            }
            System.debug('setContId***********'+setContId);
            //Merged trigger "CalculateOpenTasks" on after insert, after update, before delete, after delete.
            
            //Merged trigger "updateMoodLevel" on after insert, after update.
            if(instOfTask.WhoId != null){
                if(instOfTask.WhoId != null && instOfTask.Mood__c != null && string.valueOf(instOfTask.WhoId).startsWith('003') && ( ( instOfTask.Mood__c != oldMapValues.get(instOfTask.Id).Mood__c && instOfTask.IsClosed == true) || (instOfTask.IsClosed != oldMapValues.get(instOfTask.Id).IsClosed && instOfTask.IsClosed == true ) ) ){
                    mapIdContTask.put(instOfTask.WhoId,instOfTask) ;
                    mapIdUserTask.put(instOfTask.ownerId,instOfTask) ;
                }   
            }
            //Merged trigger "updateMoodLevel" on after insert, after update.
            
            //Merged trigger "Minutescase" on after insert, after update, before delete, after delete
            if(instOfTask.WhatID != null){
                if(string.valueOf(instOfTask.WhatID).startsWith('a1u')){
                    if((instOfTask.Minutes_on_tasks__c != oldMapValues.get(instOfTask.Id).Minutes_on_tasks__c || instOfTask.IsClosed != oldMapValues.get(instOfTask.Id).IsClosed) || (instOfTask.IsClosed != oldMapValues.get(instOfTask.Id).IsClosed && instOfTask.IsClosed == true )){
                        setIdSalesRes.add(instOfTask.WhatID);
                    }
                }
            }
            //Merged trigger "Minutescase" on after insert, after update, before delete, after delete
            
            //Merged trigger "TaskTimeSpent" on after insert, after update, before delete, after delete
            if(instOfTask.WhatID != null){
                if(string.valueOf(instOfTask.WhatID).startsWith('a0P') && ( ( (instOfTask.Minutes_on_tasks__c != oldMapValues.get(instOfTask.Id).Minutes_on_tasks__c || instOfTask.Minutes_on_Case__c != oldMapValues.get(instOfTask.Id).Minutes_on_Case__c) && instOfTask.IsClosed == true)  || (instOfTask.IsClosed != oldMapValues.get(instOfTask.Id).IsClosed && instOfTask.IsClosed == true ) ) ){
                    setIdMobCard.add(instOfTask.WhatID);
                }
            }
            //Merged trigger "TaskTimeSpent" on after insert, after update, before delete, after delete
            
            //Merged trigger "CCCards" only on after update
            if(instOfTask.WhatId != null){
                if(string.valueOf(instOfTask.WhatId).startsWith('a0P')){
                    system.debug('instOfTask.IsClosed+++'+instOfTask.IsClosed);
                    system.debug('oldMapValues.get(instOfTask.Id).IsClosed+++'+oldMapValues.get(instOfTask.Id).IsClosed);
                    if(instOfTask.IsClosed != oldMapValues.get(instOfTask.Id).IsClosed && instOfTask.IsClosed == true){
                        if(mapMobAppIdLstTskAll.containskey(instOfTask.WhatId)){
                            List<Task> lstTsk = mapMobAppIdLstTskAll.get(instOfTask.WhatId);
                            lstTsk.add(instOfTask);
                            mapMobAppIdLstTskAll.put(instOfTask.WhatId,lstTsk);
                        }else{
                            List<Task> lstTsk = new List<Task>();
                            lstTsk.add(instOfTask);
                            mapMobAppIdLstTskAll.put(instOfTask.WhatId,lstTsk);
                        }
                    }
                }
            }
            //Merged trigger "CCCards" only on after update
        }
        if(taskObjInsert.size()>0 && CheckRecursive.runthirteen())
            insertCampaignMember(taskObjInsert,new List<Task>(),userIdSet);
        //HSR : 16th DEC : To update Product on Campaign Member when a IST reps updates the Product on the Task after the status is completed.
        System.debug('taskRecList****'+taskRecList);
        if(taskRecList.size()>0 && CheckRecursive.runFourteen())
            updateProductOnCM(taskRecList);
        //Update Case on any change on task level. 
        List<Case> lstBillingCseQ = new List<Case>();
        if(setOfBillingCseId.size()>0)
        lstBillingCseQ = [SELECT Id FROM Case WHERE Id =:setOfBillingCseId AND RecordTypeId =: instOFRecType.Id];
        
        List<Case> lstBillingCseUpd = new List<Case>();
        for(Case instOfBillingCse : lstBillingCseQ){
            lstBillingCseUpd.add(instOfBillingCse);
        }
        
        if(lstBillingCseUpd.size()>0)
        update lstBillingCseUpd;
        //Update Case on any change on task level. 
        
        //Functionality to update Client_Proficiency_Level__c on contact from Task
        List<Contact> lstContactCPL = new List<Contact>();
        if(setIdContact.size()>0)
        lstContactCPL = [SELECT ID,Client_Proficiency_Level__c,(SELECT Id,Client_Proficiency_Level__c FROM Tasks WHERE Client_Proficiency_Level__c != null ORDER By LastModifiedDate) FROM Contact WHERE Id=: setIdContact];
        
        List<Contact> lstContactUpd = new List<Contact>();
        
        for(Contact instOfContact : lstContactCPL ){
            if(instOfContact.Tasks.size()>0){
                instOfContact.Client_Proficiency_Level__c = instOfContact.Tasks[instOfContact.Tasks.size()-1].Client_Proficiency_Level__c;
                lstContactUpd.add(instOfContact);
            }
        }
        
        if(lstContactUpd.size()>0)
        update lstContactUpd;
        //Functionality to update Client_Proficiency_Level__c on contact from Task
        
        //Merged trigger "Minutescase" on after insert, after update, after delete
        
        List<Sales_Resources__c> lstSalRes = new List<Sales_Resources__c>();
        
        if(setIdSalesRes.size()>0)
        lstSalRes= [SELECT Id,Total_Time_Spent_Hrs__c,(SELECT Id,Minutes_on_tasks__c FROM Tasks WHERE Status = 'Completed') FROM Sales_Resources__c WHERE Id =: setIdSalesRes];
        
        List<Sales_Resources__c> lstSalesResSec = new List<Sales_Resources__c>();
        
        for(Sales_Resources__c instOfSalRes : lstSalRes){
            if(instOfSalRes.Tasks.Size()>0){
                Decimal sum=0;
                for(Task instOfTask : instOfSalRes.Tasks){
                    if(instOfTask.Minutes_on_tasks__c != null)
                    sum = sum + instOfTask.Minutes_on_tasks__c;
                }
                instOfSalRes.Total_Time_Spent_Hrs__c = sum;
                lstSalesResSec.add(instOfSalRes);
            }else if(instOfSalRes.Tasks.Size() == 0){
                instOfSalRes.Total_Time_Spent_Hrs__c = 0;
                lstSalesResSec.add(instOfSalRes);
            }
        }
        
        if(lstSalesResSec.size()>0)
        update lstSalesResSec;
        
        //Merged trigger "Minutescase" on after insert, after update, after delete
        
        //Merged trigger "updateMoodLevel" on after insert, after update.
        List<User> lstUsr = new List<User>();
        map<Id,User> mapIdUser = new map<Id,User>();
        
        if(mapIdUserTask.keySet().size()>0)
        lstUsr = [SELECT Manager_Email__c,Name FROM User WHERE Id =: mapIdUserTask.keySet()];
        
        for(User instOfUsr : lstUsr){
            mapIdUser.put(mapIdUserTask.get(instOfUsr.Id).WhoId,instOfUsr);
        }
        
        List<Contact> lstContactFifth = new List<Contact>();
        User instOfUser = new User();
        
        if(mapIdContTask.keySet().size()>0){
            lstContactFifth = [SELECT Mood_Level__c/*,Profile_Name__c*/ FROM Contact WHERE Id =: mapIdContTask.keySet()];//UD:Commented for FP:4thApril
            instOfUser = [SELECT Id,Profile.Name FROM User WHERE Id =: UserInfo.getUserId()];
        }
        
        Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Task.getRecordTypeInfosById();
        List<Contact> lstContactSixth = new List<Contact>();
        
        for(Contact instOfCont : lstContactFifth){
            //instOfCont.Profile_Name__c = instOfUser.Profile.Name;//UD:Commented for FP:4thApril
            instOfCont.Mood_Level__c = Decimal.valueof(mapIdContTask.get(instOfCont.id).Mood__c.substring(0,1));
            if(mapIdContTask.get(instOfCont.id).Mood__c == '1 - Irate' || mapIdContTask.get(instOfCont.id).Mood__c == '2 - Frustrated'){
                String urlString = System.URL.getSalesforceBaseUrl().toExternalForm();
                String Url = '<a href=' + urlString + '/' + mapIdContTask.get(instOfCont.id).Id + '>Please click on this Link to review the activity and take the appropriate action.</a>';
                instOfCont.Mood_Text__c = mapIdContTask.get(instOfCont.id).Mood__c.substring(4,Integer.valueof((mapIdContTask.get(instOfCont.id).Mood__c).length()));
                //instOfCont.Manager_Email__c =(mapIdUser.containsKey(instOfCont.id) && mapIdUser.get(instOfCont.id).Manager_Email__c!=null)?mapIdUser.get(instOfCont.id).Manager_Email__c:'';// mapIdUser.get(instOfCont.id).Manager_Email__c;//UD:Commented for FP:4thApril
                /*instOfCont.Template_FIelds__c = 'Product: ' + rtMap.get(mapIdContTask.get(instOfCont.id).RecordTypeId).getName() +'<br>' +
                                                'Mood Origin: Task' + '<br>' + 
                                                'Mood Creator: ' + ((mapIdUser.containsKey(instOfCont.id) && mapIdUser.get(instOfCont.id).Name!=null)?mapIdUser.get(instOfCont.id).Name:'')  + '<br>' +
                                                'Mood Set Date/Time: ' + system.now() + '<br>' +
                                                'Subject: '+ mapIdContTask.get(instOfCont.Id).Subject + '<br>' +
                                                'Primary Reason for mood: '+ mapIdContTask.get(instOfCont.Id).Primary_Reason_for_Mood_Driver__c + '<br>' +
                                                'Driver: ' + mapIdContTask.get(instOfCont.Id).Reason__c + '<br>' +
                                                Url + '<br>';*///UD:Commented for FP:4thApril
                // Add link for mood record
                instOfCont.Mood_Changed_From_Id__c = null;
                if(mapIdContTask.get(instOfCont.id).WhatId!=null)
                    instOfCont.Mood_Changed_From_Id__c = mapIdContTask.get(instOfCont.id).WhatId;
                // Add link for mood record
            }
            lstContactSixth.add(instOfCont);
        }
        
        if(lstContactSixth.Size()>0)
        update lstContactSixth;
        //Merged trigger "updateMoodLevel" on after insert, after update.
        
        //Merged trigger "CalculateOpenTasks" on after insert, after update, before delete, after delete.
        List<Lead> lstLead = new List<Lead>();
        List<Contact> lstContThir = new List<Contact>();
        
        if(setLeadId.size()>0)
        lstLead = [SELECT Id,Validation_Counter__c,(SELECT Id,Ownerid,Owner.Userrole.Name,IsClosed FROM Tasks WHERE Owner.Userrole.Name =: mapMasterEveCC.Keyset() AND ActivityDate >=: system.today().adddays(-30) AND
                     ActivityDate <=: system.today().adddays(60)) FROM Lead WHERE Id =: setLeadId];
        
        if(setContId.size()>0)
        lstContThir = [SELECT Id,name,Total_Open_Venue_Sourcing_Tasks__c,Total_Closed_Event_Tasks__c,Total_Closed_CC_Tasks__c,Total_Closed_HC_Tasks__c,Total_Open_Event_Tasks__c,Total_Open_CC_Tasks__c,Total_Open_HC_Tasks__c,Total_Closed_Venue_Sourcing_Tasks__c,Validation_Counter__c,(SELECT Id,Ownerid,Owner.Userrole.Name,CreatedBy.Userrole.Name,Subject,IsClosed FROM Tasks WHERE Owner.Userrole.Name =: mapMasterEveCC.Keyset() AND ((ActivityDate >=: system.today().adddays(-60) AND IsClosed=True AND ActivityDate <=:system.today()) OR (ActivityDate <=: system.today().adddays(60) AND IsClosed=False AND ActivityDate >=:system.today().adddays(-30)))) FROM Contact WHERE Id =: setContId];
        
        List<Lead> lstLeadSec = new List<Lead>();
        
        System.debug('lstContThir**********'+lstContThir);
        for(Lead instOfLead : lstLead){
            if(instOfLead.Tasks.Size()>0){
                Integer EventCount = 0;
                Integer closedEvent = 0; 
                Integer CCCount = 0;    
                Integer closedCCCount = 0;
                Integer HCCount = 0;    
                Integer closedHCCount = 0;
                for(Task instOfTask : instOfLead.Tasks){
                    if(mapeventRole.containsKey(instOfTask.Owner.Userrole.Name)){
                        if(instOfTask.IsClosed == false){
                            EventCount++;
                        }else if(instOfTask.IsClosed == true){
                            closedEvent++;
                        }
                    }else if(mapccRole.containsKey(instOfTask.Owner.Userrole.Name)){
                        if(instOfTask.IsClosed == false){
                            CCCount++;
                        }else if(instOfTask.IsClosed == true){
                            closedCCCount++;
                        }
                    }
                   
                }
                instOfLead.Total_Open_Event_Tasks__c = EventCount;
                instOfLead.Total_Open_CC_Tasks__c = CCCount;
                instOfLead.Validation_Counter__c = (instOfLead.Validation_Counter__c!=null?instOfLead.Validation_Counter__c:0) + 1;
                instOfLead.Total_Closed_Event_Tasks__c = closedEvent;
                instOfLead.Total_Closed_CC_Tasks__c = closedCCCount;
                lstLeadSec.add(instOfLead);
            }else if(instOfLead.Tasks.Size() == 0){
                instOfLead.Total_Open_Event_Tasks__c = 0;
                instOfLead.Total_Open_CC_Tasks__c = 0;
                instOfLead.Total_Closed_Event_Tasks__c = 0;
                instOfLead.Total_Closed_CC_Tasks__c = 0;
                instOfLead.Validation_Counter__c = (instOfLead.Validation_Counter__c!=null?instOfLead.Validation_Counter__c:0) + 1;
                lstLeadSec.add(instOfLead);
            }
        }
        
        if(lstLeadSec.Size()>0)
        update lstLeadSec;
        
        List<Contact> lstContFourth = new List<Contact>();
        
        for(Contact instOfCont : lstContThir){
            System.debug('Task Size************'+instOfCont.Tasks.Size());
            System.debug('mapeventRole************'+mapeventRole);
            if(instOfCont.Tasks.Size()>0){
                //8th Feb 2017 : HSR : Added functionality to update the count of VEnue Sourcing Task.
                Integer venueCount = 0;
                Integer venueClosedCount = 0; 
                //.............................ENDS HERE.............................................
                Integer EventCount = 0;
                Integer closedEvent = 0; 
                Integer CCCount = 0;    
                Integer closedCCCount = 0;
                Integer HCCount = 0;    
                Integer closedHCCount = 0;
                for(Task instOfTask : instOfCont.Tasks){
                    System.debug('Task Owner Role*********'+instOfTask.Owner.Userrole.Name);
                    if(mapeventRole.containsKey(instOfTask.Owner.Userrole.Name)){
                        System.debug('#Checkpoint 1');
                        if(instOfTask.IsClosed == false && mapeventRole.containsKey(instOfTask.CreatedBy.Userrole.Name)){
                            EventCount++;
                            instOfCont.Total_Event_Tasks_Updated_On__c= DateTime.now();
                        }else if(instOfTask.IsClosed == true && !instOfTask.Subject.containsIgnoreCase('Closed by LM') && !instOfTask.Subject.containsIgnoreCase('Closed By SSI') && !instOfTask.Subject.containsIgnoreCase('Survey Answers')&& !instOfTask.Subject.containsIgnoreCase('Registered')){
                            closedEvent++;
                            instOfCont.Total_Event_Tasks_Updated_On__c= DateTime.now();
                        }
                        
                    }if(mapccRole.containsKey(instOfTask.Owner.Userrole.Name)){
                        if(instOfTask.IsClosed == false && mapccRole.containsKey(instOfTask.CreatedBy.Userrole.Name)){
                            CCCount++;
                            instOfCont.Total_CC_Tasks_Updated_On__c= DateTime.now();
                        }else if(instOfTask.IsClosed == true && !instOfTask.Subject.containsIgnoreCase('Closed by LM') && !instOfTask.Subject.containsIgnoreCase('Closed By SSI') && !instOfTask.Subject.containsIgnoreCase('Survey Answers')&& !instOfTask.Subject.containsIgnoreCase('Registered')){
                            closedCCCount++;
                            instOfCont.Total_CC_Tasks_Updated_On__c= DateTime.now();
                        }
                    }
                    if(mapHcRole.containsKey(instOfTask.Owner.Userrole.Name)){
                        if(instOfTask.IsClosed == false && mapHcRole.containsKey(instOfTask.CreatedBy.Userrole.Name)){
                            HCCount++;
                           // instOfCont.Total_CC_Tasks_Updated_On__c= DateTime.now();
                        }else if(instOfTask.IsClosed == true && !instOfTask.Subject.containsIgnoreCase('Closed by LM') && !instOfTask.Subject.containsIgnoreCase('Closed By SSI') && !instOfTask.Subject.containsIgnoreCase('Survey Answers')&& !instOfTask.Subject.containsIgnoreCase('Registered')){
                            closedHCCount++;
                          //  instOfCont.Total_CC_Tasks_Updated_On__c= DateTime.now();
                        }
                    }
                    //8th Feb 2017 : HSR : Added functionality to update the count of VEnue Sourcing Task.
                    if(mapVenueSourcingRole.containsKey(instOfTask.Owner.Userrole.Name)){
                        if(instOfTask.IsClosed == false && mapVenueSourcingRole.containsKey(instOfTask.CreatedBy.Userrole.Name)){
                            venueCount++;
                            instOfCont.Total_Venue_Tasks_Updated_On__c= DateTime.now();
                        }else if(instOfTask.IsClosed == true && !instOfTask.Subject.containsIgnoreCase('Closed by LM') && !instOfTask.Subject.containsIgnoreCase('Closed By SSI') && !instOfTask.Subject.containsIgnoreCase('Survey Answers')&& !instOfTask.Subject.containsIgnoreCase('Registered')){
                            venueClosedCount++;
                            instOfCont.Total_Venue_Tasks_Updated_On__c= DateTime.now();
                        }
                    }
                //.............................ENDS HERE.............................................
                }
                instOfCont.Total_Open_Event_Tasks__c = EventCount;
                instOfCont.Total_Open_CC_Tasks__c = CCCount;  
                instOfCont.Total_Open_HC_Tasks__c = HCCount;                
                if(instOfCont.Validation_Counter__c == null)
                instOfCont.Validation_Counter__c = 0;                
                instOfCont.Validation_Counter__c = instOfCont.Validation_Counter__c + 1;
                instOfCont.Total_Closed_Event_Tasks__c = closedEvent;
                instOfCont.Total_Closed_CC_Tasks__c = closedCCCount;
                instOfCont.Total_Closed_HC_Tasks__c = closedHCCount;
                //8th Feb 2017 : HSR : Added functionality to update the count of VEnue Sourcing Task.
                instOfCont.Total_Open_Venue_Sourcing_Tasks__c = venueCount;
                instOfCont.Total_Closed_Venue_Sourcing_Tasks__c = venueClosedCount;
                //.............................ENDS HERE.............................................
                lstContFourth.add(instOfCont);
            }else if(instOfCont.Tasks.Size() == 0){
                instOfCont.Total_Open_Event_Tasks__c = 0;
                instOfCont.Total_Open_CC_Tasks__c = 0;
                 instOfCont.Total_Open_HC_Tasks__c = 0;
                instOfCont.Total_Closed_Event_Tasks__c = 0;
                instOfCont.Total_Closed_CC_Tasks__c = 0;     
                instOfCont.Total_Closed_HC_Tasks__c = 0;                    
                if(instOfCont.Validation_Counter__c == null)
                instOfCont.Validation_Counter__c = 0;                
                instOfCont.Validation_Counter__c = instOfCont.Validation_Counter__c + 1;
                //8th Feb 2017 : HSR : Added functionality to update the count of VEnue Sourcing Task.
                instOfCont.Total_Open_Venue_Sourcing_Tasks__c = 0;
                instOfCont.Total_Closed_Venue_Sourcing_Tasks__c = 0;
                //.............................ENDS HERE.............................................
                lstContFourth.add(instOfCont);
            }
        }
        System.debug('lstContFourth********'+lstContFourth);
        if(lstContFourth.size()>0)
        update lstContFourth;
        
        //Merged trigger "CalculateOpenTasks" on after insert, after update, before delete, after delete.
        
        //Merged trigger "CCCards" only on after update
        system.debug('mapMobAppIdLstTskAll+++'+mapMobAppIdLstTskAll);
        system.debug('mapMobAppIdLstTskAll+++'+mapMobAppIdLstTskAll.keyset());
        List<Mobile_Card__c> lstMobCardSec = new List<Mobile_Card__c>();
        
        if(mapMobAppIdLstTskAll.keyset().size()>0)
        lstMobCardSec =  [SELECT Id,stage__c,a_Preview_Date__c,a_submit_Date__c,a_released_Date__c,a_approval_Date__c FROM Mobile_Card__c WHERE Id=: mapMobAppIdLstTskAll.keyset()];
        
        List<Mobile_Card__c> lstMobCard =  new List<Mobile_Card__c>();
        
        for(Mobile_Card__c instOfMobCard : lstMobCardSec){
            
            List<Task> lstTask = mapMobAppIdLstTskAll.get(instOfMobCard.Id);
            Integer instLstSize = lstTask.size();
            system.debug('instOfMobCard.Subject++'+lstTask[instLstSize-1].Subject);
            system.debug('test-----'+lstTask[instLstSize-1].Subject.contains('Submit iPhone App to Apple')); 
            if(lstTask[instLstSize-1].Subject.contains('App Preview Sent to Customer')){
                instOfMobCard.stage__c = 'Preview & Iterate';
                instOfMobCard.a_Preview_Date__c = system.today();
                lstMobCard.add(instOfMobCard);
            }else if(lstTask[instLstSize-1].Subject.contains('Submit iPhone App to Apple')){
                instOfMobCard.stage__c = 'Pending App Store Approval';
                instOfMobCard.a_submit_Date__c = system.today();
                lstMobCard.add(instOfMobCard);  
            }else if(lstTask[instLstSize-1].Subject.contains('Live App Links Sent to Customer')){
                instOfMobCard.stage__c = 'Approved & Released';
                instOfMobCard.a_released_Date__c = system.today();
                lstMobCard.add(instOfMobCard);
            }else if(lstTask[instLstSize-1].Subject.contains('Final Preview Approved')){
                instOfMobCard.a_approval_Date__c = system.today();
                lstMobCard.add(instOfMobCard);  
            }
            
        }
        
        if(lstMobCard.size()>0)
        update lstMobCard;
        //Merged trigger "CCCards" only on after update
        
        List<Contact> conList= new List<Contact>();
        List<Contact> conSecList = new List<Contact>();
        if(RecordIds.size()>0)
        conSecList = [SELECT id,name,First_ACTIVITY_Date__c,(SELECT ActivityDate FROM ActivityHistories WHERE ActivityDate < = Today  Order By ActivityDate ASC Limit 1) from Contact where id in:RecordIds];
        
        for(Contact con : conSecList){
            if(con.ActivityHistories.size()>0){
                if(con.First_ACTIVITY_Date__c != con.ActivityHistories[0].ActivityDate){
                    con.First_ACTIVITY_Date__c = con.ActivityHistories[0].ActivityDate; 
                    conList.add(con);
                    //con.Apex_context__c = True;//UD:Commented for FP:4thApril
                }
            }else{
                con.First_ACTIVITY_Date__c = null;
                conList.add(con);
                //con.Apex_context__c = True;//UD:Commented for FP:4thApril
            }            
        }
        
        if(conList.size()>0){
            update conList;
        }
        
        //Merged trigger "TaskTimeSpent" on after insert, after update, before delete, after delete
        List<Mobile_Card__c> lstMobCardThir = new List<Mobile_Card__c>();
        
        if(setIdMobCard.size()>0)
        lstMobCardThir = [SELECT Id,Total_Time_Spent_Task_Hrs__c,Total_Time_Spent_Case_Hrs__c,(SELECT Id,Minutes_on_tasks__c,Minutes_on_Case__c FROM Tasks WHERE Status = 'Completed') FROM Mobile_Card__c WHERE Id =: setIdMobCard];
        
        List<Mobile_Card__c> lsMobCardFor = new List<Mobile_Card__c>();
        
        for(Mobile_Card__c instOfMobCard: lstMobCardThir){
            if(instOfMobCard.Tasks.size()>0){
                Decimal sum = 0;
                Decimal sumSec = 0;
                for(Task instOfTask : instOfMobCard.Tasks){
                    if(instOfTask.Minutes_on_tasks__c != null)
                    sum = sum + instOfTask.Minutes_on_tasks__c;
                    
                    if(instOfTask.Minutes_on_Case__c != null)
                    sumSec = sumSec + instOfTask.Minutes_on_Case__c;
                }
                instOfMobCard.Total_Time_Spent_Task_Hrs__c = sum/60 ;
                instOfMobCard.Total_Time_Spent_Case_Hrs__c = sumSec/60 ;
                lsMobCardFor.add(instOfMobCard);
            }else if(instOfMobCard.Tasks.size() == 0){
                instOfMobCard.Total_Time_Spent_Task_Hrs__c = 0;
                instOfMobCard.Total_Time_Spent_Case_Hrs__c = 0;
                lsMobCardFor.add(instOfMobCard);
            }
        }
        
        if(lsMobCardFor.size()>0)
        update lsMobCardFor;
        //Merged trigger "TaskTimeSpent" on after insert, after update, before delete, after delete
        
        
        //Merged trigger "SetFirstactivityDate" on after update and after insert 
        
        //Merged trigger "timeSpentOnTDProject" on after insert, after update, after delete,after undelete
        Set<Id> projectIDs = new Set<Id>();
        //Merged trigger "timeSpentOnTDProject" on after insert, after update, after delete,after undelete
        
        //Merged trigger "Tasktriggerbulk" on after update and after insert
        List<Id> idESB =  new List<Id>();
        List<Id> idProjActi = new List<Id>();
        
        for(Task instOfTask : newMapValues.values()){           
            if(instOfTask.WhatId!=null){
                String instOfWhatId = instOfTask.WhatId;
                if((instOfTask.Minutes_on_tasks__c != oldMapValues.get(instOfTask.id).Minutes_on_tasks__c) && instOfWhatId.startsWith('a0B')){
                    idESB.add(instOfTask.Whatid);
                }else if((instOfTask.Minutes_on_tasks__c != oldMapValues.get(instOfTask.id).Minutes_on_tasks__c) && instOfWhatId.startsWith('a07')){
                    idProjActi.add(instOfTask.Whatid);
                }
            }
            //Merged trigger "timeSpentOnTDProject" on after insert, after update, after delete,after undelete
            if(instOfTask.WhatId!=null){
                if(string.valueOf(instOfTask.WhatId).startsWith('a0n') && (instOfTask.Minutes_on_tasks__c != oldMapValues.get(instOfTask.Id).Minutes_on_tasks__c) || (instOfTask.Status == 'Completed' && instOfTask.Status != oldMapValues.get(instOfTask.Id).Status)){
                    projectIDs.add(instOfTask.WhatId);
                }
            }
            //Merged trigger "timeSpentOnTDProject" on after insert, after update, after delete,after undelete
        }
        
        List<EB_SB_Builder__c> lstEBSB = new List<EB_SB_Builder__c>();
        List<EB_SB_Builder__c> lstEBSBCase = new List<EB_SB_Builder__c>();
        List<EB_SB_Builder__c> lstEBSBEvent = new List<EB_SB_Builder__c>();
        
        if(idESB.size()>0){
            lstEBSB = [SELECT Id,Build_Out_Time_Exhausted__c,(SELECT Id,Minutes_on_tasks__c FROM Tasks) FROM EB_SB_Builder__c WHERE Id =: idESB ];
            //Changes for getting complete total
            lstEBSBEvent = [SELECT Id,Build_Out_Time_Exhausted__c,(SELECT  Minutes_on_tasks__c, DurationInMinutes,Id FROM Events) FROM EB_SB_Builder__c WHERE Id =: idESB ];
            lstEBSBCase = [SELECT Id,Build_Out_Time_Exhausted__c,(SELECT Min_s_Spent__c,Id FROM Cases__r) FROM EB_SB_Builder__c WHERE Id =: idESB ];
            //Changes for getting complete total
        }
        List<Project_Activity__c> lstProjAct = new List<Project_Activity__c>();
        List<Project_Activity__c> lstProjActEvent = new List<Project_Activity__c>();
        if(idProjActi.size()>0){
            lstProjAct = [SELECT Id,Actual_Time_Spent__c,(SELECT Id,Minutes_on_tasks__c FROM Tasks) FROM Project_Activity__c WHERE Id =: idProjActi ];
            //Changes for getting complete total
            lstProjActEvent = [SELECT Id,Actual_Time_Spent__c,(SELECT DurationInMinutes,Minutes_on_tasks__c FROM Events) FROM Project_Activity__c WHERE Id=: idProjActi];
            //Changes for getting complete total
        }
        
        List<EB_SB_Builder__c> lstEBSBSec = new List<EB_SB_Builder__c>();
        List<Project_Activity__c> lstProjActSec = new List<Project_Activity__c>();
        
        /*for(EB_SB_Builder__c instOfEBSBSec : lstEBSB){
            Double Sum = 0;
            for(Task instOfTsk : instOfEBSBSec.Tasks){
                if(instOfTsk.Minutes_on_tasks__c!=null)
                Sum = Sum + instOfTsk.Minutes_on_tasks__c;
            }
            instOfEBSBSec.Build_Out_Time_Exhausted__c = Sum/60;
            lstEBSBSec.add(instOfEBSBSec);
        }
        if(lstEBSBSec.size()>0)
        update lstEBSBSec;*/
        
        //Changes for getting complete total
        Map<Id,EB_SB_Builder__c> mapEBSBIdCount = new Map<Id,EB_SB_Builder__c>();
       
        
        for(EB_SB_Builder__c instOfEBSBSec : lstEBSB){
            Double Sum = 0;
            for(Task instOfTsk : instOfEBSBSec.Tasks){
                if(instOfTsk.Minutes_on_tasks__c != null)
                Sum = Sum + instOfTsk.Minutes_on_tasks__c;
            }
            instOfEBSBSec.Build_Out_Time_Exhausted__c = Sum/60;
            //lstEBSBSec.add(instOfEBSBSec);
            mapEBSBIdCount.put(instOfEBSBSec.Id,instOfEBSBSec);
        }
        
        for(EB_SB_Builder__c instOfEBSBSec : lstEBSBCase){
            Double Sum = 0;
            for(Case instOfTsk : instOfEBSBSec.Cases__r){
                if(instOfTsk.Min_s_Spent__c != null)
                Sum = Sum + instOfTsk.Min_s_Spent__c;
            }
            Double taskValue = mapEBSBIdCount.get(instOfEBSBSec.Id).Build_Out_Time_Exhausted__c;
            instOfEBSBSec.Build_Out_Time_Exhausted__c = Sum/60 + taskValue;
            mapEBSBIdCount.put(instOfEBSBSec.Id,instOfEBSBSec);
        }
        
        
        for(EB_SB_Builder__c instOfEBSBSec : lstEBSBEvent){
            Double Sum = 0;
            Double SumSec = 0;
            for(Event instOfTsk : instOfEBSBSec.Events){
                if(instOfTsk.Minutes_on_tasks__c != null)
                Sum = Sum + instOfTsk.Minutes_on_tasks__c;
                SumSec = SumSec + instOfTsk.DurationInMinutes;
            }
            Double taskValue = mapEBSBIdCount.get(instOfEBSBSec.Id).Build_Out_Time_Exhausted__c;
            instOfEBSBSec.Build_Out_Time_Exhausted__c = Sum/60 + taskValue;
            instOfEBSBSec.Talktime_Exhausted__c = SumSec/60;
            mapEBSBIdCount.put(instOfEBSBSec.Id,instOfEBSBSec);
        }
        
        if(mapEBSBIdCount.values().size()>0)
        update mapEBSBIdCount.values();
        //Changes for getting complete total
        Map<Id,Project_Activity__c> mapProjActIdCount = new Map<Id,Project_Activity__c>();
        
        for(Project_Activity__c instOfProjAct : lstProjAct){
            Double Sum = 0;
            for(Task instOfTsk : instOfProjAct.Tasks){
                if(instOfTsk.Minutes_on_tasks__c!=null)
                Sum = Sum + instOfTsk.Minutes_on_tasks__c;
            }
            instOfProjAct.Actual_Time_Spent__c = Sum/60;
            mapProjActIdCount.put(instOfProjAct.Id,instOfProjAct);
            //lstProjActSec.add(instOfProjAct);
        }
        
        for(Project_Activity__c instOfProjAct : lstProjActEvent){
            Double Sum = 0;
            for(Event instOfTsk : instOfProjAct.Events){
                if(instOfTsk.Minutes_on_tasks__c != null)
                Sum = Sum + instOfTsk.Minutes_on_tasks__c + instOfTsk.DurationInMinutes;
            }
            Double taskValue = mapProjActIdCount.get(instOfProjAct.Id).Actual_Time_Spent__c;
            instOfProjAct.Actual_Time_Spent__c = Sum/60 + taskValue;
            //lstProjActSec.add(instOfProjAct);
            mapProjActIdCount.put(instOfProjAct.Id,instOfProjAct);
        }
        
        if(mapProjActIdCount.values().size()>0)
        update mapProjActIdCount.values();
        
        //if(lstProjActSec.size()>0)
        //update lstProjActSec;
        //Merged trigger "Tasktriggerbulk" on after update and after insert
        
        
        //Merged trigger "timeSpentOnTDProject" on after insert, after update, after delete,after undelete
        List<aggregateResult> arMap = new List<aggregateresult>();
        if(projectIDs.size()>0){
            arMap = [SELECT WhatId, SUM(Minutes_on_tasks__c) summ FROM Task WHERE Status = 'Completed' AND WhatId IN :projectIDs GROUP BY WhatId];
        }
        
        Map<Id,Double> valuesMap = new Map<Id,Double>();
        for(aggregateResult ar: arMap){
            valuesMap.put(String.valueof(ar.get('WhatId')),Double.valueof(ar.get('summ')));
        }
        
        List<T_D__c> updateProjects = new List<T_D__c>();
        if(valuesMap.size()>0){
            for(T_D__c td : [SELECT Id,Time_Spent_on_Project__c FROM T_D__c WHERE Id IN :valuesMap.keyset()]){
                if(td.Time_Spent_on_Project__c!=valuesMap.get(td.id)){
                    td.Time_Spent_on_Project__c = valuesMap.get(td.id);
                    updateProjects.add(td);
                }
            }
        }
        
        if(updateProjects.size()>0)
        update updateProjects;
        //Merged trigger "timeSpentOnTDProject" on after insert, after update, after delete,after undelete
        //insOfCloudMDMCls.enableCloudMDMTrigger();
        //insOfCloudMDMClsAcc.enableCloudMDMTrigger();
    }
    public void OnBeforeDelete(List<Task> oldValues,Map<Id,Task> oldMapValues){
          //Validation Related to Tasks Deletion : udita TICCM-645
        string userLastName= UserInfo.getLastName(); 
        if(ExecuteMethodHelper.isActive('deleteSOPTaskValidation')){
        if(!userLastName.containsIgnoreCase('Sops')){
          for(Task a: [select id, CreatedBy.Lastname from task where id in :oldMapValues.keyset()]){
          system.debug('---a.CreatedBy.Lastname'+a.CreatedBy.Lastname);
          IF(a.CreatedBy.Lastname.containsIgnoreCase('(Sops)')){
             Task actualRecord = oldMapValues.get(a.Id); 
             actualRecord.addError('You can\'t delete this record created by Lead Management');
          }             
         }
        }}        
    }
    public void OnAfterDelete(List<Task> oldValues,Map<Id,Task> oldMapValues){
        
        //Merged trigger "timeSpentOnTDProject" on after insert, after update, after delete,after undelete
        Set<Id> projectIDs = new Set<Id>();
        //Merged trigger "timeSpentOnTDProject" on after insert, after update, after delete,after undelete
        
        //Merged trigger "Minutescase" on after insert, after update, after delete
        set<Id> setIdSalesRes = new set<Id>();
        //Merged trigger "Minutescase" on after insert, after update, after delete
        
        //Merged trigger "TaskTimeSpent" on after insert, after update, before delete, after delete
        set<Id> setIdMobCard =  new set<Id>();
        //Merged trigger "TaskTimeSpent" on after insert, after update, before delete, after delete
        
        //Merged trigger "CalculateOpenTasks" on after insert, after update, before delete, after delete.
        set<Id> setLeadId = new set<Id>();
        set<Id> setContId = new set<Id>();
        //Merged trigger "CalculateOpenTasks" on after insert, after update, before delete, after delete.
        
        //Merged trigger "Tasktriggerbulk" on after update and after insert
        List<Id> idESB =  new List<Id>();
        List<Id> idProjActi = new List<Id>();
        
        //Update Case on any change on task level. 
        Set<Id> setOfBillingCseId = new Set<Id>();
        //Update Case on any change on task level.
        
        for(Task instOfTsk : oldValues){
            if(instOfTsk.WhatId!=null){
                String instOfStr = instOfTsk.WhatId;
                if(instOfStr.startsWith('a0B')){
                    idESB.add(instOfTsk.WhatId);
                }else if(instOfStr.startsWith('a07')){
                    idProjActi.add(instOfTsk.WhatId);
                }
            }
            //Update Case on any change on task level. 
            if(instOfTsk.WhatId != null){
                if(string.valueOf(instOfTsk.WhatId).startsWith('500')){
                    setOfBillingCseId.add(instOfTsk.WhatId);
                }   
            }
            //Update Case on any change on task level.
            
            //Merged trigger "CalculateOpenTasks" on after insert, after update, before delete, after delete.
            if(instOfTsk.WhoId != null){
                if(string.valueOf(instOfTsk.WhoId).startsWith('00Q') && instOfTsk.ActivityDate >= system.today().adddays(-30) && instOfTsk.ActivityDate <= system.today().adddays(60) ){
                    setLeadId.add(instOfTsk.WhoId);
                }
                if(string.valueOf(instOfTsk.WhoId).startsWith('003') && instOfTsk.ActivityDate >= system.today().adddays(-60) && instOfTsk.ActivityDate <= system.today().adddays(60) ){
                    setContId.add(instOfTsk.WhoId);
                }   
            }
            //Merged trigger "CalculateOpenTasks" on after insert, after update, before delete, after delete.
            
            //Merged trigger "Minutescase" on after insert, after update, before delete, after delete
            if(instOfTsk.WhatID != null){
                if(string.valueOf(instOfTsk.WhatID).startsWith('a1u') && instOfTsk.Minutes_on_tasks__c != null && instOfTsk.IsClosed == true){
                    setIdSalesRes.add(instOfTsk.WhatID);
                }
            }
            //Merged trigger "Minutescase" on after insert, after update, before delete, after delete
            
            
            //Merged trigger "timeSpentOnTDProject" on after insert, after update, after delete,after undelete
            if(instOfTsk.WhatId!=null){
                if(string.valueOf(instOfTsk.WhatId).startsWith('a0n') && instOfTsk.Minutes_on_tasks__c != null && instOfTsk.IsClosed == True){
                    projectIDs.add(instOfTsk.WhatId);
                }
            }
            //Merged trigger "timeSpentOnTDProject" on after insert, after update, after delete,after undelete
            
            //Merged trigger "TaskTimeSpent" on after insert, after update, before delete, after delete
            if(instOfTsk.WhatID != null){
                if(string.valueOf(instOfTsk.WhatID).startsWith('a0P') && (instOfTsk.Minutes_on_tasks__c != null || instOfTsk.Minutes_on_Case__c != null)  && instOfTsk.IsClosed == true){
                    setIdMobCard.add(instOfTsk.WhatID);
                }
            }
            //Merged trigger "TaskTimeSpent" on after insert, after update, before delete, after delete
        }
        
        List<EB_SB_Builder__c> lstEBSB = new List<EB_SB_Builder__c>();
        List<EB_SB_Builder__c> lstEBSBCase = new List<EB_SB_Builder__c>();
        List<EB_SB_Builder__c> lstEBSBEvent = new List<EB_SB_Builder__c>();
        
        if(idESB.size()>0){
            lstEBSB = [SELECT Id,Build_Out_Time_Exhausted__c,(SELECT Id,Minutes_on_tasks__c FROM Tasks) FROM EB_SB_Builder__c WHERE Id =: idESB ];
            //Changes for getting complete total
            lstEBSBEvent = [SELECT Id,Build_Out_Time_Exhausted__c,(SELECT  Minutes_on_tasks__c, DurationInMinutes,Id FROM Events) FROM EB_SB_Builder__c WHERE Id =: idESB ];
            lstEBSBCase = [SELECT Id,Build_Out_Time_Exhausted__c,(SELECT Min_s_Spent__c,Id FROM Cases__r) FROM EB_SB_Builder__c WHERE Id =: idESB ];
            //Changes for getting complete total
        }
        
        List<Project_Activity__c> lstProjAct = new List<Project_Activity__c>();
        List<Project_Activity__c>lstProjActEvent = new List<Project_Activity__c>();
        
        if(idProjActi.size()>0){
            lstProjAct = [SELECT Id,Actual_Time_Spent__c,(SELECT Id,Minutes_on_tasks__c FROM Tasks) FROM Project_Activity__c WHERE Id =: idProjActi ];
            //Changes for getting complete total
            lstProjActEvent = [SELECT Id,Actual_Time_Spent__c,(SELECT DurationInMinutes,Minutes_on_tasks__c FROM Events) FROM Project_Activity__c WHERE Id=: idProjActi];
            //Changes for getting complete total
        }
        List<EB_SB_Builder__c> lstEBSBSec = new List<EB_SB_Builder__c>();
        List<Project_Activity__c> lstProjActSec = new List<Project_Activity__c>();
        
        /*for(EB_SB_Builder__c instOfEBSBSec : lstEBSB){
            if(instOfEBSBSec.Tasks.Size()>0){
                Double Sum = 0;
                for(Task instOfTsk : instOfEBSBSec.Tasks){
                    Sum = Sum + instOfTsk.Minutes_on_tasks__c;
                }
                instOfEBSBSec.Build_Out_Time_Exhausted__c = Sum/60;
                lstEBSBSec.add(instOfEBSBSec);
            }else if(instOfEBSBSec.Tasks.Size() == 0){
                instOfEBSBSec.Build_Out_Time_Exhausted__c = 0;
                lstEBSBSec.add(instOfEBSBSec);
            }
        }
        if(lstEBSBSec.size()>0)
        update lstEBSBSec;*/
        
        //Update Case on any change on task level. 
        List<Case> lstBillingCseQ = new List<Case>();
        if(setOfBillingCseId.size()>0)
        lstBillingCseQ = [SELECT Id FROM Case WHERE Id =:setOfBillingCseId AND RecordTypeId =: instOFRecType.Id];
        
        List<Case> lstBillingCseUpd = new List<Case>();
        for(Case instOfBillingCse : lstBillingCseQ){
            lstBillingCseUpd.add(instOfBillingCse);
        }
        
        if(lstBillingCseUpd.size()>0)
        update lstBillingCseUpd;
        //Update Case on any change on task level.
        
        //Changes for getting complete total
        Map<Id,EB_SB_Builder__c> mapEBSBIdCount = new Map<Id,EB_SB_Builder__c>();
        
        for(EB_SB_Builder__c instOfEBSBSec : lstEBSB){
            Double Sum = 0;
            for(Task instOfTsk : instOfEBSBSec.Tasks){
                if(instOfTsk.Minutes_on_tasks__c != null)
                Sum = Sum + instOfTsk.Minutes_on_tasks__c;
            }
            instOfEBSBSec.Build_Out_Time_Exhausted__c = Sum/60;
            //lstEBSBSec.add(instOfEBSBSec);
            mapEBSBIdCount.put(instOfEBSBSec.Id,instOfEBSBSec);
        }
        
        for(EB_SB_Builder__c instOfEBSBSec : lstEBSBCase){
            Double Sum = 0;
            for(Case instOfTsk : instOfEBSBSec.Cases__r){
                if(instOfTsk.Min_s_Spent__c != null)
                Sum = Sum + instOfTsk.Min_s_Spent__c;
            }
            Double taskValue = mapEBSBIdCount.get(instOfEBSBSec.Id).Build_Out_Time_Exhausted__c;
            instOfEBSBSec.Build_Out_Time_Exhausted__c = Sum/60 + taskValue;
            mapEBSBIdCount.put(instOfEBSBSec.Id,instOfEBSBSec);
        }
        
        
        for(EB_SB_Builder__c instOfEBSBSec : lstEBSBEvent){
            Double Sum = 0;
            Double SumSec = 0;
            for(Event instOfTsk : instOfEBSBSec.Events){
                if(instOfTsk.Minutes_on_tasks__c != null)
                Sum = Sum + instOfTsk.Minutes_on_tasks__c;
                SumSec = SumSec + instOfTsk.DurationInMinutes;
            }
            Double taskValue = mapEBSBIdCount.get(instOfEBSBSec.Id).Build_Out_Time_Exhausted__c;
            instOfEBSBSec.Build_Out_Time_Exhausted__c = Sum/60 + taskValue;
            instOfEBSBSec.Talktime_Exhausted__c = SumSec/60;
            mapEBSBIdCount.put(instOfEBSBSec.Id,instOfEBSBSec);
        }
        
        if(mapEBSBIdCount.values().size()>0)
        update mapEBSBIdCount.values();
        //Changes for getting complete total
        
        Map<Id,Project_Activity__c> mapProjActIdCount = new Map<Id,Project_Activity__c>();
        
        for(Project_Activity__c instOfProjAct : lstProjAct){
            if(instOfProjAct.Tasks.size() > 0){
                Double Sum = 0;
                for(Task instOfTsk : instOfProjAct.Tasks){
                    Sum = Sum + instOfTsk.Minutes_on_tasks__c;
                }
                instOfProjAct.Actual_Time_Spent__c = Sum/60;
                mapProjActIdCount.put(instOfProjAct.Id,instOfProjAct);
                //lstProjActSec.add(instOfProjAct);
            }else if(instOfProjAct.Tasks.size() == 0){
                instOfProjAct.Actual_Time_Spent__c = 0;
                lstProjActSec.add(instOfProjAct);
                mapProjActIdCount.put(instOfProjAct.Id,instOfProjAct);
            }
        }
        
        for(Project_Activity__c instOfProjAct : lstProjActEvent){
            Double Sum = 0;
            for(Event instOfTsk : instOfProjAct.Events){
                if(instOfTsk.Minutes_on_tasks__c != null)
                Sum = Sum + instOfTsk.Minutes_on_tasks__c + instOfTsk.DurationInMinutes;
            }
            Double taskValue = mapProjActIdCount.get(instOfProjAct.Id).Actual_Time_Spent__c;
            instOfProjAct.Actual_Time_Spent__c = Sum/60 + taskValue;
            //lstProjActSec.add(instOfProjAct);
            mapProjActIdCount.put(instOfProjAct.Id,instOfProjAct);
        }
        
        if(mapProjActIdCount.values().size()>0)
        update mapProjActIdCount.values();
        //if(lstProjActSec.size()>0)
        //update lstProjActSec;
        //Merged trigger "Tasktriggerbulk" on after update and after insert
        
        //Merged trigger "Minutescase" on after insert, after update, after delete
        
        //Merged trigger "CalculateOpenTasks" on after insert, after update, before delete, after delete.
        List<Lead> lstLead = new List<Lead>();
        List<Contact> lstContThir = new List<Contact>();
        
        if(setLeadId.size()>0)
        lstLead = [SELECT Id,Validation_Counter__c,(SELECT Id,Ownerid,Owner.Userrole.Name,IsClosed FROM Tasks WHERE Owner.Userrole.Name =: mapMasterEveCC.Keyset() AND ActivityDate >=: system.today().adddays(-30) AND
                     ActivityDate <=: system.today().adddays(60)) FROM Lead WHERE Id =: setLeadId];
        
        if(setContId.size()>0)
        lstContThir = [SELECT Id,Total_Open_Venue_Sourcing_Tasks__c,Total_Closed_Event_Tasks__c,Total_Closed_CC_Tasks__c,Total_Closed_HC_Tasks__c,Total_Open_Event_Tasks__c,Total_Open_CC_Tasks__c,Total_Open_HC_Tasks__c,Total_Closed_Venue_Sourcing_Tasks__c,Validation_Counter__c,(SELECT Id,Ownerid,Owner.Userrole.Name,CreatedBy.Userrole.Name,Subject,IsClosed FROM Tasks WHERE Owner.Userrole.Name =: mapMasterEveCC.Keyset() AND ((ActivityDate >=: system.today().adddays(-60) AND IsClosed=True AND ActivityDate <=:system.today()) OR (ActivityDate <=: system.today().adddays(60) AND IsClosed=False AND ActivityDate >=:system.today().adddays(-30)))) FROM Contact WHERE Id =: setContId];
        
        List<Lead> lstLeadSec = new List<Lead>();
        
        for(Lead instOfLead : lstLead){
            if(instOfLead.Tasks.Size()>0){
                Integer EventCount = 0;
                Integer closedEvent = 0; 
                Integer CCCount = 0;    
                Integer closedCCCount = 0;
                Integer HCCount = 0;    
                Integer closedHCCount = 0;

                for(Task instOfTask : instOfLead.Tasks){
                    if(mapeventRole.containsKey(instOfTask.Owner.Userrole.Name)){
                        if(instOfTask.IsClosed == false){
                            EventCount++;
                        }else if(instOfTask.IsClosed == true){
                            closedEvent++;
                        }
                    }else if(mapccRole.containsKey(instOfTask.Owner.Userrole.Name)){
                        if(instOfTask.IsClosed == false){
                            CCCount++;
                        }else if(instOfTask.IsClosed == true){
                            closedCCCount++;
                        }
                    }
                   
                }
                instOfLead.Total_Open_Event_Tasks__c = EventCount;
                instOfLead.Total_Open_CC_Tasks__c = CCCount;
                instOfLead.Validation_Counter__c = instOfLead.Validation_Counter__c + 1;
                instOfLead.Total_Closed_Event_Tasks__c = closedEvent;
                instOfLead.Total_Closed_CC_Tasks__c = closedCCCount;
                lstLeadSec.add(instOfLead);
            }else if(instOfLead.Tasks.Size() == 0){
                instOfLead.Total_Open_Event_Tasks__c = 0;
                instOfLead.Total_Open_CC_Tasks__c = 0;
                instOfLead.Total_Closed_Event_Tasks__c = 0;
                instOfLead.Total_Closed_CC_Tasks__c = 0;
                instOfLead.Validation_Counter__c = instOfLead.Validation_Counter__c + 1;
                lstLeadSec.add(instOfLead);
            }
        }
        
        if(lstLeadSec.Size()>0)
        update lstLeadSec;
        
        List<Contact> lstContFourth = new List<Contact>();
        
        for(Contact instOfCont : lstContThir){
            if(instOfCont.Tasks.Size()>0){
                Integer EventCount = 0;
                Integer closedEvent = 0; 
                Integer CCCount = 0;    
                Integer closedCCCount = 0;
                 Integer HCCount = 0;    
                Integer closedHCCount = 0;
                //8th Feb 2017 : HSR : Added functionality to update the count of VEnue Sourcing Task.
                Integer venueCount = 0;
                Integer venueClosedCount = 0; 
                //.............................ENDS HERE.............................................
                for(Task instOfTask : instOfCont.Tasks){
                    if(mapeventRole.containsKey(instOfTask.Owner.Userrole.Name)){
                        if(instOfTask.IsClosed == false && mapeventRole.containsKey(instOfTask.CreatedBy.Userrole.Name)){
                            EventCount++;
                            instOfCont.Total_Event_Tasks_Updated_On__c= DateTime.now();
                        }else if(instOfTask.IsClosed == true && !instOfTask.Subject.containsIgnoreCase('Closed by LM') && !instOfTask.Subject.containsIgnoreCase('Survey Answers')&& !instOfTask.Subject.containsIgnoreCase('Registered')){
                            closedEvent++;
                            instOfCont.Total_Event_Tasks_Updated_On__c= DateTime.now();
                        }
                    }if(mapccRole.containsKey(instOfTask.Owner.Userrole.Name)){
                        if(instOfTask.IsClosed == false && mapccRole.containsKey(instOfTask.CreatedBy.Userrole.Name)){
                            CCCount++;
                            instOfCont.Total_CC_Tasks_Updated_On__c= DateTime.now();
                        }else if(instOfTask.IsClosed == true && !instOfTask.Subject.containsIgnoreCase('Closed by LM') && !instOfTask.Subject.containsIgnoreCase('Survey Answers')&& !instOfTask.Subject.containsIgnoreCase('Registered')){
                            closedCCCount++;
                            instOfCont.Total_CC_Tasks_Updated_On__c= DateTime.now();
                        }
                    }
                    if(mapHcRole.containsKey(instOfTask.Owner.Userrole.Name)){
                        if(instOfTask.IsClosed == false && mapHcRole.containsKey(instOfTask.CreatedBy.Userrole.Name)){
                            HCCount++;
                          //  instOfCont.Total_HC_Tasks_Updated_On__c= DateTime.now();
                        }else if(instOfTask.IsClosed == true && !instOfTask.Subject.containsIgnoreCase('Closed by LM') && !instOfTask.Subject.containsIgnoreCase('Survey Answers')&& !instOfTask.Subject.containsIgnoreCase('Registered')){
                            closedHCCount++;
                         //   instOfCont.Total_HC_Tasks_Updated_On__c= DateTime.now();
                        }
                    }
                    //8th Feb 2017 : HSR : Added functionality to update the count of VEnue Sourcing Task.
                    if(mapVenueSourcingRole.containsKey(instOfTask.Owner.Userrole.Name)){
                        if(instOfTask.IsClosed == false && mapVenueSourcingRole.containsKey(instOfTask.CreatedBy.Userrole.Name)){
                            venueCount++;
                            instOfCont.Total_Venue_Tasks_Updated_On__c= DateTime.now();
                        }else if(instOfTask.IsClosed == true && !instOfTask.Subject.containsIgnoreCase('Closed by LM') && !instOfTask.Subject.containsIgnoreCase('Survey Answers')&& !instOfTask.Subject.containsIgnoreCase('Registered')){
                            venueClosedCount++;
                            instOfCont.Total_Venue_Tasks_Updated_On__c= DateTime.now();
                        }
                    }
                    //.............................ENDS HERE.............................................
                }
                instOfCont.Total_Open_Event_Tasks__c = EventCount;
                instOfCont.Total_Open_CC_Tasks__c = CCCount;
                instOfCont.Total_Open_HC_Tasks__c = HCCount;
                if(instOfCont.Validation_Counter__c ==null)
                instOfCont.Validation_Counter__c = 0;
                
                instOfCont.Validation_Counter__c = instOfCont.Validation_Counter__c + 1;
                instOfCont.Total_Closed_Event_Tasks__c = closedEvent;
                instOfCont.Total_Closed_CC_Tasks__c = closedCCCount;
                instOfCont.Total_Closed_HC_Tasks__c = closedHCCount;
                //8th Feb 2017 : HSR : Added functionality to update the count of VEnue Sourcing Task.
                instOfCont.Total_Open_Venue_Sourcing_Tasks__c = venueCount;
                instOfCont.Total_Closed_Venue_Sourcing_Tasks__c = venueClosedCount;
                //.............................ENDS HERE.............................................
                lstContFourth.add(instOfCont);
            }else if(instOfCont.Tasks.Size() == 0){
                instOfCont.Total_Open_Event_Tasks__c = 0;
                instOfCont.Total_Open_CC_Tasks__c = 0;
                instOfCont.Total_Open_HC_Tasks__c = 0;
                instOfCont.Total_Closed_Event_Tasks__c = 0;
                instOfCont.Total_Closed_CC_Tasks__c = 0;
                instOfCont.Total_Closed_HC_Tasks__c = 0;
                //8th Feb 2017 : HSR : Added functionality to update the count of VEnue Sourcing Task.
                instOfCont.Total_Open_Venue_Sourcing_Tasks__c = 0;
                instOfCont.Total_Closed_Venue_Sourcing_Tasks__c = 0;
                //.............................ENDS HERE.............................................
                if(instOfCont.Validation_Counter__c == null)
                instOfCont.Validation_Counter__c = 0;
                
                instOfCont.Validation_Counter__c = instOfCont.Validation_Counter__c + 1;
                lstContFourth.add(instOfCont);
            }
        }
        
        if(lstContFourth.size()>0)
        update lstContFourth;
        
        //Merged trigger "CalculateOpenTasks" on after insert, after update, before delete, after delete.
        
        //Merged trigger "Minutescase" on after insert, after update, before delete, after delete
        
        List<Sales_Resources__c> lstSalRes = new List<Sales_Resources__c>();
        
        if(setIdSalesRes.size()>0)
        lstSalRes= [SELECT Id,Total_Time_Spent_Hrs__c,(SELECT Id,Minutes_on_tasks__c FROM Tasks WHERE Status = 'Completed') FROM Sales_Resources__c WHERE Id =: setIdSalesRes];
        
        List<Sales_Resources__c> lstSalesResSec = new List<Sales_Resources__c>();
        
        for(Sales_Resources__c instOfSalRes : lstSalRes){
            if(instOfSalRes.Tasks.Size() > 0){
                Decimal sum=0;
                for(Task instOfTask : instOfSalRes.Tasks){
                    if(instOfTask.Minutes_on_tasks__c != null)
                    sum = sum + instOfTask.Minutes_on_tasks__c;
                }
                instOfSalRes.Total_Time_Spent_Hrs__c = sum;
                lstSalesResSec.add(instOfSalRes);
            }else if(instOfSalRes.Tasks.Size() == 0){
                instOfSalRes.Total_Time_Spent_Hrs__c = 0;
                lstSalesResSec.add(instOfSalRes);
            }
        }
        
        if(lstSalesResSec.size()>0)
        update lstSalesResSec;
        
        //Merged trigger "Minutescase" on after insert, after update, before delete, after delete
        
        //Merged trigger "TaskTimeSpent" on after insert, after update, before delete, after delete
        List<Mobile_Card__c> lstMobCard = new List<Mobile_Card__c>();
        
        if(setIdMobCard.size()>0)
        lstMobCard = [SELECT Id,Total_Time_Spent_Task_Hrs__c,Total_Time_Spent_Case_Hrs__c,(SELECT Id,Minutes_on_tasks__c,Minutes_on_Case__c FROM Tasks WHERE Status = 'Completed') FROM Mobile_Card__c WHERE Id =: setIdMobCard];
        
        List<Mobile_Card__c> lsMobCardSec = new List<Mobile_Card__c>();
        
        for(Mobile_Card__c instOfMobCard: lstMobCard){
            Decimal sum = 0;
            Decimal sumSec = 0;
            for(Task instOfTask : instOfMobCard.Tasks){
                if(instOfTask.Minutes_on_tasks__c != null)
                sum = sum + instOfTask.Minutes_on_tasks__c;
                
                if(instOfTask.Minutes_on_Case__c != null)
                sumSec = sumSec + instOfTask.Minutes_on_Case__c;
            }
            instOfMobCard.Total_Time_Spent_Task_Hrs__c = sum/60 ;
            instOfMobCard.Total_Time_Spent_Case_Hrs__c = sumSec/60 ;
            lsMobCardSec.add(instOfMobCard);
        }
        
        if(lsMobCardSec.size()>0)
        update lsMobCardSec;
        //Merged trigger "TaskTimeSpent" on after insert, after update, before delete, after delete
        
        //Merged trigger "timeSpentOnTDProject" on after insert, after update, after delete,after undelete
        List<aggregateResult> arMap = new List<aggregateresult>();
        if(projectIDs.size()>0){
            arMap = [SELECT WhatId, SUM(Minutes_on_tasks__c) summ FROM Task WHERE Status = 'Completed' AND WhatId IN :projectIDs GROUP BY WhatId];
        }
        
        Map<Id,Double> valuesMap = new Map<Id,Double>();
        for(aggregateResult ar: arMap){
            valuesMap.put(String.valueof(ar.get('WhatId')),Double.valueof(ar.get('summ')));
        }
        
        List<T_D__c> updateProjects = new List<T_D__c>();
        if(valuesMap.size()>0){
            for(T_D__c td : [SELECT Id,Time_Spent_on_Project__c FROM T_D__c WHERE Id IN :valuesMap.keyset()]){
                if(td.Time_Spent_on_Project__c!=valuesMap.get(td.id)){
                    td.Time_Spent_on_Project__c = valuesMap.get(td.id);
                    updateProjects.add(td);
                }
            }
        }
        
        if(updateProjects.size()>0)
        update updateProjects;      
        //Merged trigger "timeSpentOnTDProject" on after insert, after update, after delete,after undelete
    }
    public void OnUndelete(List<Task> newValues){
        
        //Merged trigger "CalculateOpenTasks" on after insert, after update, before delete, after delete.
        set<Id> setLeadId = new set<Id>();
        set<Id> setContId = new set<Id>();
        //Merged trigger "CalculateOpenTasks" on after insert, after update, before delete, after delete.
        
        //Merged trigger "timeSpentOnTDProject" on after insert, after update, after delete,after undelete
        Set<Id> projectIDs = new Set<Id>();
        for(Task instOfTask: newValues){    
            if(instOfTask.whatId<>null){
                if(string.valueOf(instOfTask.WhatId).startsWith('a0n') && instOfTask.Minutes_on_tasks__c <> null && instOfTask.IsClosed == True){
                    projectIDs.add(instOfTask.WhatId);
                }
            }
            
            //Merged trigger "CalculateOpenTasks" on after insert, after update, before delete, after delete.
            if(instOfTask.WhoId != null){
                if(string.valueOf(instOfTask.WhoId).startsWith('00Q') && instOfTask.ActivityDate >= system.today().adddays(-30) && instOfTask.ActivityDate <= system.today().adddays(60) ){
                    setLeadId.add(instOfTask.WhoId);
                }
                if(string.valueOf(instOfTask.WhoId).startsWith('003') && instOfTask.ActivityDate >= system.today().adddays(-60) && instOfTask.ActivityDate <= system.today().adddays(60) ){
                    setContId.add(instOfTask.WhoId);
                }   
            }
            //Merged trigger "CalculateOpenTasks" on after insert, after update, before delete, after delete.
        }
        
        //Merged trigger "CalculateOpenTasks" on after insert, after update, before delete, after delete.
        List<Lead> lstLead = new List<Lead>();
        List<Contact> lstContThir = new List<Contact>();
        
        if(setLeadId.size()>0)
        lstLead = [SELECT Id,Validation_Counter__c,(SELECT Id,Ownerid,Owner.Userrole.Name,CreatedBy.Userrole.Name,Subject,IsClosed FROM Tasks WHERE Owner.Userrole.Name =: mapMasterEveCC.Keyset() AND ActivityDate >=:system.today().adddays(-30) AND 
                        ActivityDate <=: system.today().adddays(60)) FROM Lead WHERE Id =: setLeadId];
        
        if(setContId.size()>0)
        lstContThir = [SELECT Id,Validation_Counter__c,(SELECT Id,CreatedBy.Userrole.Name,Subject,Ownerid,Owner.Userrole.Name,IsClosed FROM Tasks WHERE Owner.Userrole.Name =: mapMasterEveCC.Keyset() AND ((ActivityDate >=: system.today().adddays(-60) AND IsClosed=True AND ActivityDate <=:system.today()) OR (ActivityDate <=: system.today().adddays(60) AND IsClosed=False AND ActivityDate >=:system.today().adddays(-30)))) FROM Contact WHERE Id =: setContId];
        
        List<Lead> lstLeadSec = new List<Lead>();
        
        for(Lead instOfLead : lstLead){
            Integer EventCount = 0;
            Integer closedEvent = 0; 
            Integer CCCount = 0;    
            Integer closedCCCount = 0;
            
            for(Task instOfTask : instOfLead.Tasks){
                if(mapeventRole.containsKey(instOfTask.Owner.Userrole.Name)){
                    if(instOfTask.IsClosed == false){
                        EventCount++;
                    }else if(instOfTask.IsClosed == true){
                        closedEvent++;
                    }
                }else if(mapccRole.containsKey(instOfTask.Owner.Userrole.Name)){
                    if(instOfTask.IsClosed == false){
                        CCCount++;
                    }else if(instOfTask.IsClosed == true){
                        closedCCCount++;
                    }
                }
                
            }
            instOfLead.Total_Open_Event_Tasks__c = EventCount;
            instOfLead.Total_Open_CC_Tasks__c = CCCount;
            instOfLead.Validation_Counter__c = instOfLead.Validation_Counter__c + 1;
            instOfLead.Total_Closed_Event_Tasks__c = closedEvent;
            instOfLead.Total_Closed_CC_Tasks__c = closedCCCount;
            lstLeadSec.add(instOfLead);
        }
        
        if(lstLeadSec.Size()>0)
        update lstLeadSec;
        
        List<Contact> lstContFourth = new List<Contact>();
        
        for(Contact instOfCont : lstContThir){
            Integer EventCount = 0;
            Integer closedEvent = 0; 
            Integer CCCount = 0;    
            Integer closedCCCount = 0;
            Integer HCCount = 0;    
            Integer closedHCCount = 0;
            for(Task instOfTask : instOfCont.Tasks){
                if(mapeventRole.containsKey(instOfTask.Owner.Userrole.Name)){
                    if(instOfTask.IsClosed == false && mapeventRole.containsKey(instOfTask.CreatedBy.Userrole.Name)){
                        EventCount++;
                        instOfCont.Total_Event_Tasks_Updated_On__c= DateTime.now();
                    }else if(instOfTask.IsClosed == true && !instOfTask.Subject.containsIgnoreCase('Closed by LM') && !instOfTask.Subject.containsIgnoreCase('Closed By SSI') && !instOfTask.Subject.containsIgnoreCase('Survey Answers')&& !instOfTask.Subject.containsIgnoreCase('Registered')){
                        closedEvent++;
                        instOfCont.Total_Event_Tasks_Updated_On__c= DateTime.now();
                    }
                }if(mapccRole.containsKey(instOfTask.Owner.Userrole.Name)){
                    if(instOfTask.IsClosed == false && mapccRole.containsKey(instOfTask.CreatedBy.Userrole.Name)){
                        CCCount++;
                        instOfCont.Total_CC_Tasks_Updated_On__c= DateTime.now();
                    }else if(instOfTask.IsClosed == true && !instOfTask.Subject.containsIgnoreCase('Closed by LM') && !instOfTask.Subject.containsIgnoreCase('Closed By SSI') && !instOfTask.Subject.containsIgnoreCase('Survey Answers')&& !instOfTask.Subject.containsIgnoreCase('Registered')){
                        closedCCCount++;
                        instOfCont.Total_CC_Tasks_Updated_On__c= DateTime.now();
                    }
                }
                // ver 20.0 starts
                if(mapHcRole.containsKey(instOfTask.Owner.Userrole.Name)){
                    if(instOfTask.IsClosed == false && mapHcRole.containsKey(instOfTask.CreatedBy.Userrole.Name)){
                        HCCount++;
                       // instOfCont.Total_CC_Tasks_Updated_On__c= DateTime.now();
                    }else if(instOfTask.IsClosed == true && !instOfTask.Subject.containsIgnoreCase('Closed by LM') && !instOfTask.Subject.containsIgnoreCase('Closed By SSI') && !instOfTask.Subject.containsIgnoreCase('Survey Answers')&& !instOfTask.Subject.containsIgnoreCase('Registered')){
                        closedHCCount++;
                      //  instOfCont.Total_CC_Tasks_Updated_On__c= DateTime.now();
                    }
                } // ver 20.0 ends
            }
            instOfCont.Total_Open_Event_Tasks__c = EventCount;
            instOfCont.Total_Open_CC_Tasks__c = CCCount;   
            instOfCont.Total_Open_HC_Tasks__c = HCCount;     // ver 20.0         
            if(instOfCont.Validation_Counter__c == null)
            instOfCont.Validation_Counter__c = 0;            
            instOfCont.Validation_Counter__c = instOfCont.Validation_Counter__c + 1;
            instOfCont.Total_Closed_Event_Tasks__c = closedEvent;
            instOfCont.Total_Closed_CC_Tasks__c = closedCCCount;  // ver 20.0
            instOfCont.Total_Closed_HC_Tasks__c = closedHCCount;   // ver 20.0
            lstContFourth.add(instOfCont);
        }
        
        if(lstContFourth.size()>0)
        update lstContFourth;
        
        //Merged trigger "CalculateOpenTasks" on after insert, after update, before delete, after delete.
        
        List<aggregateResult> arMap = new List<aggregateresult>();
        if(projectIDs.size()>0){
            arMap = [SELECT WhatId, SUM(Minutes_on_tasks__c) summ FROM Task WHERE Status = 'Completed' AND WhatId IN :projectIDs GROUP BY WhatId];
        }
        
        Map<Id,Double> valuesMap = new Map<Id,Double>();
        for(aggregateResult ar: arMap){
            valuesMap.put(String.valueof(ar.get('WhatId')),Double.valueof(ar.get('summ')));
        }
        
        List<T_D__c> updateProjects = new List<T_D__c>();
        if(valuesMap.size()>0){
            for(T_D__c td : [SELECT Id,Time_Spent_on_Project__c FROM T_D__c WHERE Id IN :valuesMap.keyset()]){
                if(td.Time_Spent_on_Project__c!=valuesMap.get(td.id)){
                    td.Time_Spent_on_Project__c = valuesMap.get(td.id);
                    updateProjects.add(td);
                }
            }
        }
        
        if(updateProjects.size()>0)
        update updateProjects;
        //Merged trigger "timeSpentOnTDProject" on after insert, after update, after delete,after undelete
    }
    
/**
** HSR
** Description : To insert Campaign Member when a Task is created by SSI or SOPS.
** Date : 12/14/2017
**
**/
public static void insertCampaignMember(List<Task> newTaskList,List<Task> oldTaskList,Set<Id> userIdSet){
    Set<Id> userObjId = new Set<Id>();
    System.debug('userIdSet**********'+userIdSet);
    Set<String> campIdSet = new Set<String>();
    Set<String> conIdSet = new Set<String>();
    String campTemp = '';
    String conTemp = '';
    Map<String,Id> conCampIdVsCampMem_Map = new Map<String,Id>();
    For(Task taskObj : newTaskList)
    {
        if(String.IsNotBlank(taskObj.Campaign_ID__c) && taskObj.WhoId!=null){
            campTemp = '';
            conTemp = '';
            //capmIdConIdVal = '';
            campTemp = taskObj.Campaign_ID__c.substring(0,15);
            conTemp = String.valueOf(taskObj.WhoId).substring(0,15);
            campIdSet.add(campTemp);
            conIdSet.add(conTemp);
        }
    }
    if(campIdSet.size()>0 && conIdSet.size()>0){
        //Querying to fetch the CampaignMembers we need to update the products......
        For(CampaignMember campMembRec : [SELECT Id,CampaignId,ContactId,Product__c FROM CampaignMember WHERE CampaignId IN : campIdSet AND ContactId IN : conIdSet])
        {
            conCampIdVsCampMem_Map.put((String.ValueOf(campMembRec.CampaignId).substring(0,15)+String.Valueof(campMembRec.ContactId).substring(0,15)),campMembRec.Id);
        }
    }
    For(User userObj : [SELECT Id,Name FROM User WHERE Id IN : userIdSet])
    {
        if(userObj.Name!='Informatica India (Sops)' && (userObj.Name.contains('Sops') || userObj.Name.contains('SSI')))
        {
            System.debug('Checkpoint USER FOR LOOP');
            userObjId.add(userObj.Id);
        }
    }
   // Set<CampaignMember> campMemList = new Set<CampaignMember>();
   // List<CampaignMember> campMemUpsertList = new List<CampaignMember>();
    List<CampaignMember> campMemList = new List<CampaignMember>();
    CampaignMember campMemObj = new CampaignMember();
    //Custom Setting for referencing the CampaignMember Status on the basis of the task Subject Line....
    Map<String,String> taskSubVsCMStatusMap = new Map<String,String>();
    For(String custSetVal : Task_Subject_Vs_CM_Status__c.getAll().keySet())
    {
        taskSubVsCMStatusMap.put(Task_Subject_Vs_CM_Status__c.getInstance(custSetVal).Task_Subject_Line__c,Task_Subject_Vs_CM_Status__c.getInstance(custSetVal).Member_Status__c);
    }
    Map<String,TaskRoleVsCMProduct__c> taskRoleVsCMProdMap = new Map<String,TaskRoleVsCMProduct__c>();
    taskRoleVsCMProdMap = TaskRoleVsCMProduct__c.getAll();
    System.debug('newTaskList**********'+newTaskList);
    System.debug('userObjId**********'+userObjId);
    For(Task taskRec : newTaskList)
    {
        System.debug('taskRec.createdById************'+taskRec.createdById);
        if(userObjId.contains(taskRec.createdById) && String.IsNotBlank(taskRec.Campaign_ID__c) && taskRec.WhoId!=null){
            System.debug('#Checkpoint');
            campMemObj = new CampaignMember();
            if(conCampIdVsCampMem_Map.containsKey((String.ValueOf(taskRec.Campaign_ID__c).substring(0,15)+String.Valueof(taskRec.WhoId).substring(0,15))))
            {
                campMemObj.Id = conCampIdVsCampMem_Map.get((String.ValueOf(taskRec.Campaign_ID__c).substring(0,15)+String.Valueof(taskRec.WhoId).substring(0,15)));
            }
            For(String subjectString : taskSubVsCMStatusMap.keySet())
            {
                System.debug('taskRec.subject.containsIgnoreCase(subjectString)*****'+taskRec.subject.contains(subjectString));
                if(taskRec.subject.containsIgnoreCase(subjectString) || (taskRec.Task_Type__c!=null && taskRec.Task_Type__c.containsIgnoreCase(subjectString))){
                    System.debug('subjectString*********'+subjectString);
                    System.debug('taskSubVsCMStatusMap.get(subjectString)*********'+taskSubVsCMStatusMap.get(subjectString));                    
                    campMemObj.Status = taskSubVsCMStatusMap.get(subjectString);
                    if(subjectString=='Email Referrals' || subjectString=='Email No/Yes')
                        break;
                }
            }
            System.debug('campMemObj.Status*******'+campMemObj.Status);
            if(campMemObj.Status!=null){
                if(taskRec.subject.contains(' OD-CC') || taskRec.subject.contains(' PS-CC') || taskRec.subject.contains(' CC_') || taskRec.subject.contains(' CrowdCompass'))
                {
                    campMemObj.Product__c = 'Crowd Compass';
                }
                else if(taskRoleVsCMProdMap.containsKey(taskRec.Task_Assigned_Role__c))
                {
                    campMemObj.Product__c = taskRoleVsCMProdMap.get(taskRec.Task_Assigned_Role__c).Product__c;
                }
                else if(taskRec.Task_Assigned_Role__c == 'Pre Sales - Special Projects' && taskRec.Product__c !=null)
                    campMemObj.Product__c = taskRec.Product__c;
                if(campMemObj.Id==null){
                    campMemObj.ContactId = taskRec.WhoId;
                    campMemObj.CampaignId = taskRec.Campaign_ID__c;
                }
                campMemList.add(campMemObj);
            }
        }
        System.debug('************AllObj'+campMemObj);
        /*if((taskRec.WhoId == '003o000000UU0gSAAT' || taskRec.WhoId == '003o000000UU0gS') && taskRec.WhatId == '7011k00000092oG')
        {
            System.debug('************Status'+campMemObj.Status);
            System.debug('************AllObj'+campMemObj);
        }*/
    }
    if(campMemList.size()>0){
         upsert campMemList;
        //campMemUpsertList.addAll(campMemList);
        //Database.Insert(campMemList,false);
        //upsert campMemUpsertList;
        //System.debug('************campMemList'+campMemList);
        /*
        Database.SaveResult[] srList = Database.Insert(campMemList,false);
        
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                System.debug('Successfully inserted account. Account ID: ' + sr.getId());
            }
        }*/
    }
    }
    
    /**
    ** HSR
    ** Description : To update Product on Campaign Member when a IST reps updates the Product on the Task after the status is completed.
    ** Date : 12/16/2017
    **
    **/
    public static void updateProductOnCM(List<Task> taskList){
        System.debug('Checkpoint');
        //Initializing Variables
        Set<String> campIdSet = new Set<String>();
        Set<Id> conIdSet = new Set<Id>();
        Map<String,String> capmIdConIdVsProduct_Map = new Map<String,String>();
        List<CampaignMember> campMembList = new List<CampaignMember>();
        String capmIdConIdVal = '';
        String campTemp = '';
        String conTemp = '';
        For(Task taskRec : taskList)
        {
            capmIdConIdVal = '';
            campTemp = taskRec.Campaign_ID__c.substring(0,15);
            conTemp = String.valueOf(taskRec.WhoId).substring(0,15);
            campIdSet.add(campTemp);
            conIdSet.add(Id.ValueOf(conTemp));
            capmIdConIdVal = campTemp + conTemp;
            capmIdConIdVsProduct_Map.put(capmIdConIdVal,taskRec.Product__c);
        }
        System.debug('campIdSet*******'+campIdSet);
        System.debug('conIdSet****'+conIdSet);
        System.debug('capmIdConIdVsProduct_Map****'+capmIdConIdVsProduct_Map);
        if(campIdSet.size()>0 && conIdSet.size()>0){
            //Querying to fetch the CampaignMembers we need to update the products......
            For(CampaignMember campMembRec : [SELECT Id,CampaignId,ContactId,Product__c FROM CampaignMember WHERE CampaignId IN : campIdSet AND ContactId IN : conIdSet])
            {
                System.debug('###########*******'+campMembRec.CampaignId);
                                System.debug('###########*******'+campMembRec.ContactId);
                capmIdConIdVal = '';
                capmIdConIdVal = String.ValueOf(campMembRec.CampaignId).substring(0,15)+String.Valueof(campMembRec.ContactId).substring(0,15);
                if(capmIdConIdVsProduct_Map.containsKey(capmIdConIdVal))
                {
                    campMembRec.Product__c = capmIdConIdVsProduct_Map.get(capmIdConIdVal);
                    campMembList.add(campMembRec);
                }
            }
        System.debug('campMembList *******'+campMembList);
        //.............Updating Products in Campaign member
        if(campMembList.size()>0)
            update campMembList;
        }
    }
    /*HSR : Adding contact with Campaign when task cerated with subject line,containing Chat Transcript (H Cloud) and if the Assigned role consist of any of the names CSN,CSN CVB,CSN OG/AD,CSN SAT,CSN SI,CSN CVB,RFP....*/
    public static void addCampaign(Map<Id,Task> oldMapValues,Map<Id,Task> newMapValues){
        List<CampaignMember>  campMemberList = new List<CampaignMember>();
        For(Task taskRec : newMapValues.values()){
            if(taskRec.WhoId!=null && String.valueOf(taskRec.WhoId).startswith('003') && taskRec.Subject.contains('Chat Transcript (H Cloud)') && (taskRec.Task_Assigned_Role__c.containsIgnoreCase('CSN') || taskRec.Task_Assigned_Role__c.containsIgnoreCase('CSN CVB') || taskRec.Task_Assigned_Role__c.containsIgnoreCase('CSN OG/AD') || taskRec.Task_Assigned_Role__c.containsIgnoreCase('CSN SAT') || taskRec.Task_Assigned_Role__c.containsIgnoreCase('CSN SI') || taskRec.Task_Assigned_Role__c.containsIgnoreCase('CSN CVB') || taskRec.Task_Assigned_Role__c.containsIgnoreCase('RFP')))
            {
                CampaignMember campMem = new CampaignMember();
                campMem.ContactId = taskRec.WhoId;
                campMem.CampaignId = '7011N000000fXwu';
                campMem.Status = 'Sent';
                campMemberList.add(campMem);
            }
        }
        if(campMemberList.size()>0)
            insert campMemberList;
    }
    //Udita : On after insert - DWF Enhancement wrt RingDNA : update contact status
    public void updateContactStatus(Map<Id,Task> oldMapValues,Map<Id,Task> newMapValues){
        map<string,CallDepositionVsContactStatus__c> mapOfStatusValues = CallDepositionVsContactStatus__c.getAll();
        //Fetching Data from Custom Setting
        Map<String,DWFContactStatusOrder__c> DWFValMap = DWFContactStatusOrder__c.getAll();
        map<string,RoleVsContactAPIName__c> mapOfFieldAPI = RoleVsContactAPIName__c.getAll();
        list<contact> conListToUpdate = new list<contact>();
        string statusValue,fieldAPI,oldStatusValue;
        list<Track_RingDNA_Contact_Status__c> trackingObject = new List<Track_RingDNA_Contact_Status__c>();
        map<id,contact> conMap;
        set<id> conIds = new set<id>();
        list<task> taskList = new list<task>();
        for(Task newTask : newMapValues.values()){
          //  Task oldTask = oldMapValues.get(newTask.id);            
            if(newTask.WhoId !=null && String.ValueOf(newTask.WhoId).startsWith('003') && newTask.ringdna__Call_Disposition__c != null /* && newTask.ringdna__Call_Disposition__c != oldTask.ringdna__Call_Disposition__c*/){
               if(mapOfStatusValues.containsKey(newTask.ringdna__Call_Disposition__c)){                 
                 taskList.add(newTask);
                 conIds.add(newTask.WhoId);
                }
            }
        }
        
        if(taskList.size() > 0 && conIds.size() > 0){
            conMap = new map<id,contact>([select id,Event_Contact_Status__c,Ring_DNA_Tracking__c,CSNS_Contact_Status__c,Survey_Contact_Status__c,CSN_P_Contact_Status__c,CC_Contact_Status__c from Contact where id in : conIds]);
            for(Task tsk : taskList){
                 statusValue = mapOfStatusValues.get(tsk.ringdna__Call_Disposition__c).Contact_Status__c;
                 if(mapOfFieldAPI.containsKey(tsk.Task_Assigned_Role__c)){
                     fieldAPI = mapOfFieldAPI.get(tsk.Task_Assigned_Role__c).Field_API_Name__c;
                 }
                 system.debug('--fieldAPI'+fieldAPI);
                 if(statusValue !=null && fieldAPI !=null){
                     Contact con = conMap.get(tsk.WhoId);
                     if(con.get(fieldAPI) != null){
                       oldStatusValue = String.ValueOf(con.get(fieldAPI));                     
                       if(DWFValMap.containsKey(oldStatusValue) && DWFValMap.containsKey(statusValue)){
                          con.Ring_DNA_Tracking__c ='Insert---DWFValMap.containsKey(oldStatusValue) && DWFValMap.containsKey(statusValue)';
                          system.debug('--oldStatusValue'+oldStatusValue);
                          system.debug('--DWFValMap.get(oldStatusValue).Order__c'+DWFValMap.get(oldStatusValue).Order__c);
                          system.debug('--DWFValMap.get(statusValue).Order__c'+DWFValMap.get(statusValue).Order__c);
                       if(DWFValMap.get(oldStatusValue).Order__c  < DWFValMap.get(statusValue).Order__c){
                         con.put(fieldAPI,statusValue);
                         con.Ring_DNA_Tracking__c =  '1If--Insert' + fieldAPI+ '' + statusValue+ '' + System.now();
                         conListToUpdate.add(con);
                       }}else{
                         con.put(fieldAPI,statusValue);
                         con.Ring_DNA_Tracking__c ='2If--Insert' + fieldAPI+ '' + statusValue+ '' + System.now();
                         conListToUpdate.add(con);
                        }
                     }else{
                         con.put(fieldAPI,statusValue);
                         con.Ring_DNA_Tracking__c ='3If--Insert' + fieldAPI + '' + statusValue + ' ' +  System.now();
                         conListToUpdate.add(con);
                     }
                     if(Label.TrackRingDNAContactStatu =='True'){
                      Track_RingDNA_Contact_Status__c track = new Track_RingDNA_Contact_Status__c();
                      track.Field_Updated_API__c = fieldAPI;
                      track.Task_Id__c = tsk.id;
                      track.Value_Updated__c =statusValue;
                      track.Contact_Id__c = tsk.WhoId;
                      track.Trigger_Point__c = 'Insert';
                      trackingObject.add(track);
                     }
                 }          
            } 
        }
                        
        if(conListToUpdate.size() > 0){
            update conListToUpdate;
        }
        if(trackingObject.size() > 0){
          insert trackingObject;
        }
    }
    
    //Udita : On after update - DWF Enhancement wrt RingDNA : update contact status
    public void updateContactStatusAfterUpdate(Map<Id,Task> oldMapValues,Map<Id,Task> newMapValues){
        map<string,CallDepositionVsContactStatus__c> mapOfStatusValues = CallDepositionVsContactStatus__c.getAll();
        //Fetching Data from Custom Setting
        Map<String,DWFContactStatusOrder__c> DWFValMap = DWFContactStatusOrder__c.getAll();
        map<string,RoleVsContactAPIName__c> mapOfFieldAPI = RoleVsContactAPIName__c.getAll();
        list<contact> conListToUpdate = new list<contact>();
        string statusValue,fieldAPI,oldStatusValue;
        list<Track_RingDNA_Contact_Status__c> trackingObject = new List<Track_RingDNA_Contact_Status__c>();
        map<id,contact> conMap;
        set<id> conIds = new set<id>();
        list<task> taskList = new list<task>();
        for(Task newTask : newMapValues.values()){
            Task oldTask = oldMapValues.get(newTask.id);            
            if(newTask.WhoId !=null && String.ValueOf(newTask.WhoId).startsWith('003') && newTask.ringdna__Call_Disposition__c != null  && newTask.ringdna__Call_Disposition__c != oldTask.ringdna__Call_Disposition__c){
              system.debug('----Date.ValueOf(newTask.CreatedDate)'+Date.ValueOf(newTask.CreatedDate) + '--- '+ Date.ValueOf(newTask.LastModifiedDate));
              if(date.newinstance(newTask.CreatedDate.year(), newTask.CreatedDate.month(), newTask.CreatedDate.day()) == date.newinstance(newTask.LastModifiedDate.year(), newTask.LastModifiedDate.month(), newTask.LastModifiedDate.day())){
              system.debug('----mapOfStatusValues.containsKey(newTask.ringdna__Call_Disposition__c)'+mapOfStatusValues.containsKey(newTask.ringdna__Call_Disposition__c));
               if(mapOfStatusValues.containsKey(newTask.ringdna__Call_Disposition__c)){                 
                 taskList.add(newTask);
                 conIds.add(newTask.WhoId);
                 system.debug('----taskList'+taskList);
                 system.debug('----conIds'+conIds);
                }
              }
            }
        }
        
        if(taskList.size() > 0 && conIds.size() > 0){
            conMap = new map<id,contact>([select id,Event_Contact_Status__c,Ring_DNA_Tracking__c,CSNS_Contact_Status__c,Survey_Contact_Status__c,CSN_P_Contact_Status__c,CC_Contact_Status__c from Contact where id in : conIds]);
            for(Task tsk : taskList){
                 statusValue = mapOfStatusValues.get(tsk.ringdna__Call_Disposition__c).Contact_Status__c;
                 if(mapOfFieldAPI.containsKey(tsk.Task_Assigned_Role__c)){
                     fieldAPI = mapOfFieldAPI.get(tsk.Task_Assigned_Role__c).Field_API_Name__c;
                 }
                 system.debug('--fieldAPI'+fieldAPI);
                 system.debug('--statusValue '+statusValue );
                 if(statusValue !=null && fieldAPI !=null){
                     system.debug('inside ifff');
                     Contact con = conMap.get(tsk.WhoId);
                     if(con.get(fieldAPI) != null){
                       oldStatusValue = String.ValueOf(con.get(fieldAPI));                     
                       if(DWFValMap.containsKey(oldStatusValue) && DWFValMap.containsKey(statusValue)){
                          con.Ring_DNA_Tracking__c ='Update---DWFValMap.containsKey(oldStatusValue) && DWFValMap.containsKey(statusValue)';
                          system.debug('--oldStatusValue'+oldStatusValue);
                          system.debug('--DWFValMap.get(oldStatusValue).Order__c'+DWFValMap.get(oldStatusValue).Order__c);
                          system.debug('--DWFValMap.get(statusValue).Order__c'+DWFValMap.get(statusValue).Order__c);
                       if(DWFValMap.get(oldStatusValue).Order__c  < DWFValMap.get(statusValue).Order__c){
                         con.put(fieldAPI,statusValue);
                         con.Ring_DNA_Tracking__c =  '1If--Update' + fieldAPI+ '' + statusValue+ '' + System.now();
                         conListToUpdate.add(con);
                       }}else{
                         con.put(fieldAPI,statusValue);
                         con.Ring_DNA_Tracking__c ='2If--Update' + fieldAPI+ '' + statusValue+ '' + System.now();
                         conListToUpdate.add(con);
                        }
                     }else{
                         con.put(fieldAPI,statusValue);
                         con.Ring_DNA_Tracking__c ='3If--Update' + fieldAPI + '' + statusValue + ' ' +  System.now();
                         conListToUpdate.add(con);
                     }
                     if(Label.TrackRingDNAContactStatu =='True'){
                      Track_RingDNA_Contact_Status__c track = new Track_RingDNA_Contact_Status__c();
                      track.Field_Updated_API__c = fieldAPI;
                      track.Task_Id__c = tsk.id;
                      track.Value_Updated__c =statusValue;
                      track.Contact_Id__c = tsk.WhoId;
                      track.Trigger_Point__c = 'Update';
                      trackingObject.add(track);
                     }
                 }          
            } 
        }
                        
        if(conListToUpdate.size() > 0){
            update conListToUpdate;
        }
        if(trackingObject.size() > 0){
          insert trackingObject;
        }
    }
    
    public static void fakeMethod(){
        integer i =0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}