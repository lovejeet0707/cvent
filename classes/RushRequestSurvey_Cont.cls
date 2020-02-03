/**
* Author : Sandeep Kumar
* Date : 02 June, 2017
* Description : RushRequestSurvey_Cont class fullfills below functionalities,
* 1) This class is called from a custom button (Create EB Project) provided on the Opportunity standard page for EB Users. 
* 2) Show all the products asscoiated with opportunity and provides an option for user to easily create PSP ID, EB SB Projects etc with just one click.
* This functionality was provided to EB team so that they can still create eb projects on fly and this button is of no use for opportunities which are created after the automation went live.
* As the PSP Id and EB SB projects are automatically created on adding products.
* VF Page - RushRequestSurvey_StartPage,RushRequestSurvey_ResponsePage and RushRequestSurvey_FinishPage
* Test Class - ScopeRushRequestSurvey_Cont_Test
*/
public class RushRequestSurvey_Cont {  
    public Id accountId;
    public String surveyType;
    public string accountName; 
    public Id internalSurveyForEBObjId;
    public string respondentFirstName {get;set;}
    public string respondentLastName {get;set;}
    public string respondentName {get;set;}
    public string respondentEmailAddress {get;set;}
    public string selectedCountry {get;set;}
    public string selectedComplexity {get;set;}    
    public string selectedMultiSelect1Question {get;set;}
    public string selectedMultiSelect2Question {get;set;}
    public Boolean showMultiSelect1Question {get;set;}
    public Boolean showMultiSelect2Question {get;set;}
    public string selectedMultiSelectYesNoQuestion{get;set;}
    public Boolean showUploadMessagePanel{get;set;}
    public Boolean hideNoAttachmentPanel{get;set;}
    public Integer AttachmentCount {get;set;}
    public List<Event_Builder_Survey_Q_A__c> surQuestnAnsList{get;set;}
    public List<Event_Builder_Survey_Q_A__c> surveyResultList{get;set;}
    public Event_Builder_Survey_Q_A__c surveyResponseObj;
    public List<Event_Builder_Survey_Q_A__c> surveyResponseList;
    public List<Attachment> showSurveyAttachmentList{get;set;}
    public final static Id eventBuilderLeadersQueueId = Label.Event_Builder_Leaders_Queue_Id; 
    public final static Integer restrictRushRequestToDays = Integer.valueOf(Label.EB_Project_Restrict_Rush_Request_Days);
    
    public Attachment attachment1 {
        get {
            if (attachment1 == null)
                attachment1 = new Attachment();
            return attachment1;
        }
        set;
    }
    
    public Attachment attachment2 {
        get {
            if (attachment2 == null)
                attachment2 = new Attachment();
            return attachment2;
        }
        set;
    }
    
    //Default Constructor
    public RushRequestSurvey_Cont(){
        showUploadMessagePanel = false;
        surQuestnAnsList = new List<Event_Builder_Survey_Q_A__c>();
        surveyResultList = new List<Event_Builder_Survey_Q_A__c>();
        showSurveyAttachmentList = new List<Attachment>();
        if(apexpages.currentpage().getparameters().get('surveyType') == 'rushRequest'){
            surveyType = 'Rush Request';
        }
        if(surveyType != null){
            accountId = apexpages.currentpage().getparameters().get('id');
            accountName = apexpages.currentpage().getparameters().get('accountName');
            for(Event_Builder_Survey_Q_A__c sqa :[select Id,Answer__c,
                                                  Sequence__c,Question__c,Survey_Type__c,Answer_Type__c,
                                                  Sub_Question__c,Sub_Answer__c,Sub_Question_1__c,
                                                  Sub_Question_2__c,Sub_Answer_1__c,
                                                  Sub_Answer_2__c
                                                  from Event_Builder_Survey_Q_A__c 
                                                  where Is_Question__c = true AND Survey_Type__c =:surveyType ORDER BY Sequence__c ASC]){
                                                      if(sqa.Sequence__c == 1){
                                                          sqa.Answer__c = accountName;
                                                      }  
                                                      surQuestnAnsList.add(sqa);
                                                  } 
            showMultiSelect1Question = false;
            showMultiSelect2Question = false;
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
                                                      surveyResultList.add(sqa);                                                            
                                                      respondentName = sqa.Internal_Survey_for_EB__r.Survey_Respondent__c;
                                                      respondentEmailAddress = sqa.Internal_Survey_for_EB__r.Respondent_Email__c;
                                                  } 
            this.surveyResultList = surveyResultList;
            this.showSurveyAttachmentList = [Select Id,Name from Attachment where ParentId =:internalSurveyForEBId];
            if(showSurveyAttachmentList.isEmpty()){
                hideNoAttachmentPanel = true;
            }
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
    
    // Method responsible for showing MultiSelect2 Answer Type options on VF - Page
    public List<SelectOption> getMultiSelect2Answers(){
        // Declare Selectoption List that will store all the available countires.
        List<SelectOption> multiSelect2Answers = new List<SelectOption>();
        multiSelect2Answers.add(new SelectOption('--None--','--None--'));
        multiSelect2Answers.add(new SelectOption('Paid','Paid'));
        multiSelect2Answers.add(new SelectOption('Complimentary','Complimentary'));
        return multiSelect2Answers;
    }
    
    // Method responsible for showing Complexities on VF - Page
    public List<SelectOption> getComplexities(){
        // Declare Selectoption List that will store all the available countires.
        List<SelectOption> complexities = new List<SelectOption>();
        complexities.add(new SelectOption('--None--','--None--'));
        complexities.add(new SelectOption('Simple','Simple'));
        complexities.add(new SelectOption('Medium','Medium'));
        complexities.add(new SelectOption('Advanced','Advanced'));
        complexities.add(new SelectOption('Complex','Complex'));
        return complexities;
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
    
    // Method called from the MultiSelect2Question onChange event.
    public void MultiSelect2QuestionVisibility(){   
        if(selectedMultiSelect2Question == 'Paid'){
            showMultiSelect2Question = true;
        }else{
            showMultiSelect2Question = false;
        }
        return; 
    }
    
    // Button called from Rush Request Start Page
    public PageReference rushRequestStartPage(){
        Internal_Survey_for_EB__c evntBuilderSurveyObj = new Internal_Survey_for_EB__c();
        if(accountId!= null){
            evntBuilderSurveyObj.Account__c = accountId;
        }
        evntBuilderSurveyObj.Survey_Respondent__c = respondentFirstName+' '+respondentLastName;
        evntBuilderSurveyObj.Respondent_Email__c = respondentEmailAddress;
        evntBuilderSurveyObj.Survey_Type__c = surveyType;
        
        try{
            insert evntBuilderSurveyObj;
            internalSurveyForEBObjId = evntBuilderSurveyObj.Id;
        }Catch(Exception exp){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading file'));
            return null;
        }
        return Page.RushRequestSurvey_ResponsePage;        
    }
    
    // Button called from Rush Request Finish Page
    public PageReference rushRequestSubmit(){
        Boolean showExpectedLaunchDateError;
        surveyResponseList = new List<Event_Builder_Survey_Q_A__c>();      
        for(Event_Builder_Survey_Q_A__c sqa :surQuestnAnsList){
            // Instatiate Event Builder Survey Q A Object
            surveyResponseObj = new Event_Builder_Survey_Q_A__c();
            surveyResponseObj.Internal_Survey_for_EB__c = internalSurveyForEBObjId; 
            surveyResponseObj.Question__c = sqa.Question__c;
            if(sqa.Answer_Type__c == 'Country Name' && selectedCountry != null){
                surveyResponseObj.Answer__c = selectedCountry;
            }else if(sqa.Answer_Type__c == 'MultiSelect1' && selectedMultiSelect1Question != null){
                surveyResponseObj.Answer__c = selectedMultiSelect1Question;
            }else if(sqa.Answer_Type__c == 'MultiSelect2' && selectedMultiSelect2Question != null){
                surveyResponseObj.Answer__c = selectedMultiSelect2Question;
            }else if(sqa.Answer_Type__c == 'Picklist - Yes/No' && selectedMultiSelectYesNoQuestion != null){
                surveyResponseObj.Answer__c = selectedMultiSelectYesNoQuestion;
            }else if(sqa.Answer_Type__c == 'Picklist - Complexity' && selectedComplexity != null){
                surveyResponseObj.Answer__c = selectedComplexity;
            } 
            if(surveyResponseObj.Answer__c == null){
                surveyResponseObj.Answer__c = sqa.Answer__c;
            }
            if(sqa.Sequence__c == 9){
                String launchDateString = sqa.Answer__c;
                if(!Test.isRunningTest()){
                    Date launchDate = Date.parse(launchDateString.substringBefore(' '));
                    Integer numberOfDays = Date.today().daysBetween(launchDate);
                    if(numberOfDays < restrictRushRequestToDays){
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error : Rush Request can not be placed. Expected Launch Date should be more than 15 working days from the today. Please contact EB Team for more information.'));
                        return null;
                    }
                }
            }
            surveyResponseObj.Answer_Type__c = sqa.Answer_Type__c;
            surveyResponseObj.Sequence__c = sqa.Sequence__c;
            surveyResponseObj.Sub_Question__c = sqa.Sub_Question__c;            
            surveyResponseObj.Sub_Question_1__c = sqa.Sub_Question_1__c;
            surveyResponseObj.Sub_Question_2__c = sqa.Sub_Question_2__c;
            surveyResponseObj.Sub_Answer__c = sqa.Sub_Answer__c;            
            surveyResponseObj.Sub_Answer_1__c = sqa.Sub_Answer_1__c;
            surveyResponseObj.Sub_Answer_2__c = sqa.Sub_Answer_2__c;
            surveyResponseObj.Survey_Type__c = sqa.Survey_Type__c;
            surveyResponseList.add(surveyResponseObj);
        }        
        try{            
            if(!surveyResponseList.isEmpty()){
                insert surveyResponseList;
                createCaseForRushRequest(accountId,internalSurveyForEBObjId);
                // Redirect User to Survey Submitted Page.
                return Page.RushRequestSurveyAttachmentUpload_Page;                
            }else{
                return null;
            }           
        }Catch(Exception exp){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error occured while submitting survey. Please contact System Administrator.'));
            return null;
        }  
    }
    
    public PageReference submitSurvey(){     
        return Page.RushRequestSurvey_FinishPage;
    }
    
    public PageReference uploadAttachments(){     
        List<Attachment> attachmentList = new List<Attachment>();
        // Handles Attachment 1 
        if(attachment1.Name != null){
            attachment1.OwnerId = UserInfo.getUserId();
            attachment1.ParentId = internalSurveyForEBObjId;
            attachmentList.add(attachment1);     
            attachment1 = new Attachment();
        }       
        // Handles Attachment 2 
        if(attachment2.Name != null){
            attachment2.OwnerId = UserInfo.getUserId();
            attachment2.ParentId = internalSurveyForEBObjId;
            attachmentList.add(attachment2);      
            attachment2 = new Attachment();
        }
        try{
            insert attachmentList; 
            showUploadMessagePanel = true;
            AttachmentCount = attachmentList.size();
            return null;   
        }Catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage())); 
            return null;
        }
    }
    
    public static void createCaseForRushRequest(Id accountId, Id evntBuilderSurveyId){        
        // Create new Case for rush survey request        
        Case newCase = new Case();
        newCase.AccountId = accountId;
        //newCase.ContactId = UserInfo.getUserId();
        newCase.RecordTypeId = RecordTypeUtil.getRecordTypeIDByDevName('Case','Eventbuilder');
        newCase.Product_Type__c = 'Event Blue';
        newCase.Status = 'Open';
        newCase.Priority = 'Medium';
        newCase.Origin = 'Admin';
        newCase.Subject = 'A new Rush Request has been created.';
        newCase.Description = 'Please refer the email for more information.';
        insert newCase;        
        
        // Updates the case Id on the Survey Record.
        Internal_Survey_for_EB__c intSurveyForEBObj = new Internal_Survey_for_EB__c();
        intSurveyForEBObj.Id = evntBuilderSurveyId;
        intSurveyForEBObj.Case__c = newCase.Id;
        update intSurveyForEBObj;
        
        // Send email to newly assigned owner's. 
        EBSurveyNotificationEmail sendAssignementEmail = new EBSurveyNotificationEmail();
        sendAssignementEmail.sendEmailToNewCaseOwner(evntBuilderSurveyId);
        
        // Assign to Queue if their is no available user found. 
        Case updateCaseOwner = new Case();    
        updateCaseOwner.Id = newCase.Id;
        updateCaseOwner.OwnerId = eventBuilderLeadersQueueId;
        update updateCaseOwner;
    }
}