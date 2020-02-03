/**
* Author : Sandeep Kumar
* Date : 02 June, 2017
* Description : ScopeRequestSurvey_Cont class fullfills below functionalities,
* 1) This class is called from a custom button (Create Scope Request) provided on the Account standard page for Account Managers. 
* 2) Survey form is filled by the account manager and it creates a case to handle further conversation for scope request.
* Cases are assigned to EB Agent Profiles who are eligible for working in the scope request. This eligibity is decided by the EB Leadership by selecting "Is also Handling Scope Request's".
* VF Page - ScopeRequestSurvey_StartPage,ScopeRequestSurvey_ResponsePage and ScopeRequestSurvey_FinishPage
* Scope Request Form - ScopeRequestPreview_Page
* Test Class - ScopeRushRequestSurvey_Cont_Test
*/
public class ScopeRequestSurvey_Cont{ 
    public Id accountId;
    public string surveyType;
    public string accountName;     
    public Id internalSurveyForEBObjId;    
    public string respondentName {get;set;}
    public string respondentFirstName {get;set;}
    public string respondentLastName {get;set;}
    public string respondentEmailAddress {get;set;}
    public string selectedCountry {get;set;}   
    public Boolean showMultiSelect1Question {get;set;}
    public string selectedMultiSelect1Question {get;set;}
    public string selectedMultiSelectYesNoQuestion{get;set;}    
    public List<Event_Builder_Survey_Q_A__c> surveyResultList{get;set;}
    public List<Event_Builder_Survey_Q_A__c> surQuestnAnsList{get;set;}
    public Event_Builder_Survey_Q_A__c surveyResponseObj;
    public List<Event_Builder_Survey_Q_A__c> surveyResponseList;
    public final static Id eventBuilderLeadersQueueId = Label.Event_Builder_Leaders_Queue_Id;       
    
    //Default Constructor
    public ScopeRequestSurvey_Cont(){  
        surveyResultList = new List<Event_Builder_Survey_Q_A__c>();
        surQuestnAnsList = new List<Event_Builder_Survey_Q_A__c>();                    
        if(apexpages.currentpage().getparameters().get('surveyType') == 'scopeRequest'){
            surveyType = 'Scope Request';
        }
        if(surveyType != null){
            accountId = apexpages.currentpage().getparameters().get('id');
            accountName = apexpages.currentpage().getparameters().get('accountName');
            for(Event_Builder_Survey_Q_A__c sqa :[select Id,Sequence__c,Question__c,Answer_Type__c,
                                                  Survey_Type__c,Sub_Question__c,Sub_Answer__c,Sub_Question_1__c,
                                                  Sub_Question_2__c,Answer__c,
                                                  Sub_Answer_1__c,Sub_Answer_2__c
                                                  from Event_Builder_Survey_Q_A__c 
                                                  where Survey_Type__c =:surveyType AND Is_Question__c = true ORDER BY Sequence__c ASC]){
                                                      if(sqa.Sequence__c == 1){
                                                          sqa.Answer__c = accountName;
                                                      }  
                                                      surQuestnAnsList.add(sqa);
                                                  }        
            this.surQuestnAnsList = surQuestnAnsList;
        }else{
            Id internalSurveyForEBId = apexpages.currentpage().getparameters().get('id');
            for(Event_Builder_Survey_Q_A__c sqa :[select Id,Answer__c,Internal_Survey_for_EB__r.Survey_Respondent__c,
                                                  Internal_Survey_for_EB__r.Respondent_Email__c,Sequence__c,
                                                  Question__c,Survey_Type__c,Answer_Type__c,Sub_Question__c,
                                                  Sub_Answer__c,Sub_Question_1__c,Sub_Question_2__c,
                                                  Sub_Answer_1__c,Sub_Answer_2__c
                                                  from Event_Builder_Survey_Q_A__c 
                                                  where Internal_Survey_for_EB__c =:internalSurveyForEBId ORDER BY Sequence__c ASC]){
                                                      system.debug('Answer==='+sqa.Answer__c);
                                                      surveyResultList.add(sqa);                                                            
                                                      respondentName = sqa.Internal_Survey_for_EB__r.Survey_Respondent__c;
                                                      respondentEmailAddress = sqa.Internal_Survey_for_EB__r.Respondent_Email__c;
                                                  } 
            this.surveyResultList = surveyResultList;
        }         
    }
    
    // Method responsible for showing countries on VF - Page
    public List<SelectOption> getCountries(){
        // Declare Selectoption List that will store all the available countires.
        List<SelectOption> countires = new List<SelectOption>();
        // Describe call to get all the countires with country code.
        Schema.DescribeFieldResult fieldResult = User.Countrycode.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();        
        // First option will be shown as blank
        countires.add(new SelectOption('--None--','--None--'));
        for( Schema.PicklistEntry f : ple){           
            countires.add(new SelectOption(f.getLabel(),f.getLabel()));
        }       
        return countires;
    }
    
    // Method responsible for showing Yes/ No options on VF - Page
    public List<SelectOption> getAnswers(){
        // Declare Selectoption List that will store all the available countires.
        List<SelectOption> answers = new List<SelectOption>();
        answers.add(new SelectOption('--None--','--None--'));
        answers.add(new SelectOption('Yes','Yes'));
        answers.add(new SelectOption('No','No'));
        return answers;
    }
    // Method called from the MultiSelect1Question onChange event.
    public void MultiSelect1QuestionVisibility(){   
        if(selectedMultiSelect1Question == 'Yes'){
            showMultiSelect1Question = true;
        }else{
            showMultiSelect1Question = false;
        }
        return; 
    }
    
    // Button called from Scope Request Start Page
    public PageReference scopeRequestStartPage(){ 
        Internal_Survey_for_EB__c evntBuilderSurveyObj = new Internal_Survey_for_EB__c();
        if(accountId!= null){
            evntBuilderSurveyObj.Account__c = accountId;
        }
        evntBuilderSurveyObj.Survey_Respondent__c = respondentFirstName+' '+respondentLastName;
        evntBuilderSurveyObj.Respondent_Email__c = respondentEmailAddress;
        evntBuilderSurveyObj.Survey_Type__c = surveyType;
        
        try{
            insert evntBuilderSurveyObj;
            system.debug('evntBuilderSurveyObj=='+evntBuilderSurveyObj);
            internalSurveyForEBObjId = evntBuilderSurveyObj.Id;
            return Page.ScopeRequestSurvey_ResponsePage;       
        }Catch(Exception exp){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading file'));
            system.debug('Exception==1='+exp.getMessage());            
            return null;
        }
    }
    
    // Button called from Scope Request Finish Page
    public PageReference scopeRequestFinish(){       
        surveyResponseList = new List<Event_Builder_Survey_Q_A__c>();      
        for(Event_Builder_Survey_Q_A__c sqa :surQuestnAnsList){
            // Instatiate Event Builder Survey Q A Object
            surveyResponseObj = new Event_Builder_Survey_Q_A__c();
            surveyResponseObj.Internal_Survey_for_EB__c = internalSurveyForEBObjId; 
            surveyResponseObj.Question__c = sqa.Question__c;
            surveyResponseObj.Sub_Question__c = sqa.Sub_Question__c;  
            surveyResponseObj.Sub_Answer__c = sqa.Sub_Answer__c;  
            surveyResponseObj.Answer_Type__c = sqa.Answer_Type__c;
            surveyResponseObj.Sequence__c = sqa.Sequence__c;
            surveyResponseObj.Survey_Type__c = sqa.Survey_Type__c;
            if(sqa.Answer_Type__c == 'Country Name'){
                surveyResponseObj.Answer__c = selectedCountry;
                surveyResponseList.add(surveyResponseObj);
            }else if(sqa.Answer_Type__c == 'MultiSelect1' && selectedMultiSelect1Question != null){
                surveyResponseObj.Answer__c = selectedMultiSelect1Question;
                surveyResponseList.add(surveyResponseObj);
            }else if(sqa.Answer_Type__c == 'Picklist - Yes/No' && selectedMultiSelectYesNoQuestion != null){
                surveyResponseObj.Answer__c = selectedMultiSelectYesNoQuestion;
                surveyResponseList.add(surveyResponseObj);
            }else{
                surveyResponseObj.Answer__c = sqa.Answer__c;
                surveyResponseList.add(surveyResponseObj);
            }
        }         
        try{
            if(!surveyResponseList.isEmpty()){                
                insert surveyResponseList;
                // Call the method to create Case and Assign Case to Agent.
                createCaseAndRunAssignmentRules(accountId,internalSurveyForEBObjId,respondentEmailAddress);
                // Redirect User to Survey Submitted Page.
                return Page.ScopeRequestSurvey_FinishPage;
            }else{
                return null;
            }
        }Catch(Exception exp){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading file'));
            system.debug('Exception==2='+exp.getMessage());
            return null;
        }       
    }
    
    // Button called from Scope Request Response Page
    public PageReference scopeRequestCancel(){        
        return Page.ScopeRequestSurvey_StartPage; 
    } 
    
    public static void createCaseAndRunAssignmentRules(Id accountId, Id evntBuilderSurveyId,String contactEmail){
        Professional_Services_Project__c PSPObj;
        String currentYear = String.valueOf(System.today().Year());
        Integer currentYearPSPCount = 0;
        List<Professional_Services_Project__c> PSPObjList = [Select Id,Account__c From Professional_Services_Project__c where Account__c =:accountId and PSP_Year__c =:currentYear];
        
        // Create PSP if there is no record exists for the current year.
        if(PSPObjList.Size() == 0){
            PSPObj = new Professional_Services_Project__c();
            PSPObj.Account__c = accountId;
            PSPObj.Event_Builder__c = true;
            insert PSPObj;
        }
        
        // Create new Case for fullfilling survey request and this case shall be assigned Event Builder Rep based on rules.                  
        Case newCase = new Case();
        newCase.AccountId = accountId;
        newCase.SuppliedEmail = contactEmail;
        newCase.RecordTypeId = RecordTypeUtil.getRecordTypeIDByDevName('Case','Eventbuilder');
        newCase.Status = 'Open';
        newCase.Priority = 'Medium';
        newCase.Origin = 'Admin';
        newCase.Client_Services_Category__c = 'Scope Call';
        newCase.Subject = 'A new Scope Request has been created.';
        newCase.Description = 'Please refer the attached email for more information.'; 
        if(PSPObjList.Size() == 1){
            newCase.PSP__c = PSPObjList[0].Id;
        }else{
            newCase.PSP__c = PSPObj.Id;
        }
        insert newCase; 
        
        // Updates the case Id on the Survey Record.
        Internal_Survey_for_EB__c intSurveyForEBObj = new Internal_Survey_for_EB__c();
        intSurveyForEBObj.Id = evntBuilderSurveyId;
        intSurveyForEBObj.Case__c = newCase.Id;
        update intSurveyForEBObj;
        
        // Prepare Agent score to EB Project Assignment Map
        List<Id> agentIdList = new List<Id>(); 
        Map<Integer,List<Id>> agentScoreToAgentIdsMap = new Map<Integer,List<Id>>();
        Map<Id,EB_Agent_Profile__c> agentIdEBAgentProfileObjMap = new Map<Id,EB_Agent_Profile__c>(); 
        
        for(EB_Agent_Profile__c AssignRec : [Select Id,Agent_Name__c,Agent_Score__c,Last_Project_Assignment__c,of_Projects__c,of_Projects_Agent__c,Max_Workload_Agent_Hrs__c,Max_of_Projects_Per_Week__c,Current_Assignment__c,Current_Work_Load_hrs__c,of_Simple_Projects__c,of_Medium_Projects__c,Millisecond__c,of_Advanced_Projects__c,of_Complex_Projects__c from EB_Agent_Profile__c where Is_also_Handling_Scope_Request__c = true AND User_Active__c = true Order By Agent_Score__c,Last_Project_Assignment__c]){
            // Prepare a with User Id to EbAgent Profile Id.
            agentIdEBAgentProfileObjMap.put(AssignRec.Agent_Name__c, AssignRec);            
            // Add agent Id in the list. It will be used later for the auto assignment.         
            agentIdList.add(AssignRec.Agent_Name__c);
        }
        
        String newAssigneeId = '';
        
        system.debug('agentIdList'+agentIdList);
        // Assign the case to EB Agent Profile.
        for(Id agentId :agentIdList){
            if(agentIdEBAgentProfileObjMap.containsKey(agentId)){
                if(agentIdEBAgentProfileObjMap.get(agentId).Current_Assignment__c == 'Available'){
                    if(agentIdEBAgentProfileObjMap.get(agentId).of_Projects__c < agentIdEBAgentProfileObjMap.get(agentId).of_Projects_Agent__c && agentIdEBAgentProfileObjMap.get(agentId).Current_Work_Load_hrs__c < agentIdEBAgentProfileObjMap.get(agentId).Max_Workload_Agent_Hrs__c){
                        newAssigneeId = agentId;
                        break;
                    }
                }                               
            }                    
        }
        // Declare Eb Agent Profile Object.
        EB_Agent_Profile__c eBAgentProfile;
        Set<Id> eBAgentProfileIds = new Set<Id>();
        Boolean sendEmail = false;
        // Instantiate List
        List<EB_Agent_Profile__c> eBAgentProfilesToUpdateList = new List<EB_Agent_Profile__c>();
        // Assign the case to EB Agent Profile.
        if(newAssigneeId != null && newAssigneeId != ''){
            // Assign new Agent Id
            newCase.OwnerId =Id.valueOf(newAssigneeId);   
            if(agentIdEBAgentProfileObjMap.containsKey(newAssigneeId) && !eBAgentProfileIds.contains(agentIdEBAgentProfileObjMap.get(newAssigneeId).Id)){
                // Update the Last Project Assignment Details on EB Agent Profile.
                eBAgentProfile  = new EB_Agent_Profile__c();
                eBAgentProfile.Id = agentIdEBAgentProfileObjMap.get(newAssigneeId).Id;
                eBAgentProfile.Last_Project_Assignment__c = System.Datetime.now();
                eBAgentProfilesToUpdateList.add(eBAgentProfile);
                // Add Agent Profile Id to avoid duplicate Ids.
                eBAgentProfileIds.add(eBAgentProfile.Id);                    
            }
        }else{
            // Assign to Queue if their is no available user found.                
            Database.DMLOptions dmo = new Database.DMLOptions(); 
            dmo.EmailHeader.triggerUserEmail = true; 
            newCase.OwnerId = eventBuilderLeadersQueueId;
            newCase.setOptions(dmo);  
            sendEmail = true;
        }  
        // Update new Case owner
        update newCase;
        // Updates EB Agent Profiles.
        if(!eBAgentProfilesToUpdateList.isEmpty())
            update eBAgentProfilesToUpdateList;
        // Send email to newly assigned owner's.
        if(!sendEmail){
            EBSurveyNotificationEmail sendAssignementEmail = new EBSurveyNotificationEmail();
            sendAssignementEmail.sendEmailToNewCaseOwner(evntBuilderSurveyId);
        }
    }     
}