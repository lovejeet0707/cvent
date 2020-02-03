/*    
* Author: Sandeep Kumar
* Date: 13-June-2017
* Class Name : EBSBProjPullSurveyAttachment_WebService 
* Description # Retrieve Survey attachment from Survey tool and inserts the attachments with EBSB project.
* 
*/
global class EBSBProjPullSurveyAttachment_WebService{
    private static final string EBProjectFlexConversionSurveyStubID = Label.EB_Project_Flex_Conversion_Survey_Stub_ID;
    private static final string EBProjectSurveyIDOldEBForm = Label.EB_Project_Survey_ID_Old_EB_Form;
    private static final string EBProjectSurveyIDOldEBExpressForm = Label.EB_Project_Survey_ID_Old_EB_Express_Form;
    private static final string EBProjectSurveyIDNewEBExpressForm = Label.EB_Project_Survey_ID_New_EB_Express_Form;
    private static final string EBProjectSurveyIDNewEBForm = Label.EB_Project_Survey_ID_New_EB_Form;
    private static final string EBProjectCVIIAccountNumber = Label.EB_Project_CVII_Account_Number;
    private static final string EBProjectCVIIAccountUsername = Label.EB_Project_CVII_Account_Username;
    private static final string EBProjectCVIIAccountPassword = Label.EB_Project_CVII_Account_Password;
    private static final integer EBAttachmentPullDeadline = Integer.valueOf(Label.EB_Project_EB_Attachment_Pull_Deadline);    
    
    @future(callout=true)
    webservice static void ProcessRequest(String responseNumber,String ebProjectId,String projectType,Boolean useOldEBForm){ 
        system.debug('==Response Number=='+responseNumber+'====EB SB Project ID===='+ebProjectId+'===========Project Type======='+projectType+'=======useOldEBForm======'+useOldEBForm);
        String SessionID;
        Set<String>surveyIds=new Set<String>(); 
        
        // SOAP Request Type = Login
        Map<string,string>LoginRequestMap=new Map<string,string>();
        LoginRequestMap.put('Account',EBProjectCVIIAccountNumber.trim());
        LoginRequestMap.put('UserName',EBProjectCVIIAccountUsername.trim());
        LoginRequestMap.put('Password',EBProjectCVIIAccountPassword.trim());
        Cevent_WebService_Helper LoginStub =new Cevent_WebService_Helper();
        List<Cevent_WebService_Helper.LoginResult> result=new List<Cevent_WebService_Helper.LoginResult>();
        
        if(!Test.isRunningTest()){
            result=LoginStub.loginRequest(LoginRequestMap,40000);
        }else{
            Cevent_WebService_Helper.LoginResult testobj=new Cevent_WebService_Helper.LoginResult();
            testobj.sessionId='sssssss'; 
            testobj.Error_Code='200'; 
            result.add(testobj);         
        }
        system.debug('result for session===>'+result[0].sessionId);
        SessionID=result[0].sessionId;
        
        /*******************************************************************************************************************************************************/
        // SOAP Request Type = Search 
        // Pulls Surveys which are rcently created in Survey Tool.  
        
        Map<string,string>SearchRequestMap=new Map<string,string>();
        SearchRequestMap.put('SessionID',result[0].sessionId);
        
        if(useOldEBForm){
            // If part executes whenever the request comes from the Sync Attachment Button Provided on the EB SB Project Level.
            if(projectType != null && projectType.containsIgnoreCase('Event Builder - Express')){
                // Cvent Express Survey ID
                SearchRequestMap.put('SurveyID',EBProjectSurveyIDOldEBExpressForm.trim());            
            }else if(projectType != null && projectType.containsIgnoreCase(Label.EB_Project_Flex_Conversion_Project_Type)){
                // Cvent Flex Conversion Survey ID
                SearchRequestMap.put('SurveyID',EBProjectFlexConversionSurveyStubID.trim());
            }else{
                // Cvent Regular Survey ID
                SearchRequestMap.put('SurveyID',EBProjectSurveyIDOldEBForm.trim());
            }  
        }else{
            // Else part executes whenever the request comes from the automated workflow.
            if(projectType != null && projectType.containsIgnoreCase('Event Builder - Express')){
                // Cvent Express Survey ID
                SearchRequestMap.put('SurveyID',EBProjectSurveyIDNewEBExpressForm.trim());            
            }else if(projectType != null && projectType.containsIgnoreCase(Label.EB_Project_Flex_Conversion_Project_Type)){
                // Cvent Flex Conversion Survey ID
                SearchRequestMap.put('SurveyID',EBProjectFlexConversionSurveyStubID.trim());
            }else{
                // Cvent Regular Survey ID
                SearchRequestMap.put('SurveyID',EBProjectSurveyIDNewEBForm.trim());
            }  
        }
        Date DateToday = date.today().addDays(-EBAttachmentPullDeadline);
        string dateValue = String.valueOf(DateToday);
        SearchRequestMap.put('Date',dateValue);        
        
        Cevent_WebService_Helper SearchStub = new Cevent_WebService_Helper();
        List<Cevent_WebService_Helper.searchWrapper> SearchResult = new List<Cevent_WebService_Helper.searchWrapper>();
        if(!Test.isRunningTest()){
            SearchResult=SearchStub.Search(SearchRequestMap,40000);
        }else{
            Cevent_WebService_Helper.searchWrapper testobj=new Cevent_WebService_Helper.searchWrapper();
            testobj.SurveyId='testSurveyId'; 
            testobj.Error_Code='200'; 
            SearchResult.add(testobj);         
        }
        
        // Collecting survey IDS from Search API response.         
        for(Cevent_WebService_Helper.searchWrapper var : SearchResult){
            surveyIds.add(var.SurveyId);
        }
        system.debug('DailySurveyIds===>'+surveyIds);
        
        /*******************************************************************************************************************************************************/
        // SOAP Request Type = Retrieve 
        // Pulls the corresponding surveys for the corresponding surveyIDs created in Survey Tool. 
        
        Map<string,string> SurveyRequestMap = new Map<string,string>();
        SurveyRequestMap.put('SessionID',SessionID);
        Cevent_WebService_Helper SurveyStub= new Cevent_WebService_Helper();
        List<Cevent_WebService_Helper.SurveyDetailWrapper> SurveyResult=new List<Cevent_WebService_Helper.SurveyDetailWrapper>();    
        
        if(!Test.isRunningTest()){
            SurveyResult = SurveyStub.retriveSurvey(SurveyRequestMap,surveyIds,40000);
        }else{
            Cevent_WebService_Helper.SurveyDetailWrapper testobj = new Cevent_WebService_Helper.SurveyDetailWrapper();
            testobj.Id = 'sssssss'; 
            testobj.Error_Code = '200'; 
            testobj.QuestionType = '15';
            testobj.ResponseNumber = '55049764'; 
            testobj.QuestionNumber = '4';
            testobj.questionText = 'Test Question Text';
            testobj.ReferenceId = '50000000008d619'; 
            List<Cevent_WebService_Helper.SurveyAnswereWrapper> SurveyAnswereWrapper_TestList = new List<Cevent_WebService_Helper.SurveyAnswereWrapper>();  
            Cevent_WebService_Helper.SurveyAnswereWrapper testanswersObj = new Cevent_WebService_Helper.SurveyAnswereWrapper();
            testanswersObj.AnswerText = 'test answere';
            SurveyAnswereWrapper_TestList.add(testanswersObj);
            testobj.Answere = SurveyAnswereWrapper_TestList;                                   
            SurveyResult.add(testobj);         
        }
        Boolean isValidResponse = false;
        String surveyProjecId = '';
        // Inserts the survey attachments to the EB SB Project.
        if(SurveyResult.size()>0){
            List<Note> noteList = new List<Note>();
            Note noteObj;
            
            for(Cevent_WebService_Helper.SurveyDetailWrapper var: SurveyResult){
                if(var.QuestionNumber == '4' && !isValidResponse){
                    isValidResponse = true;
                    for(Cevent_WebService_Helper.SurveyAnswereWrapper val: var.Answere){                        
                        surveyProjecId = val.AnswerText;  
                    }
                }
            }   
            
            for(Cevent_WebService_Helper.SurveyDetailWrapper var: SurveyResult){
                if(var != null && var.QuestionType != null){
                    system.debug(Integer.valueOf(var.QuestionType)+'====='+var.ResponseNumber+'==========='+responseNumber+'======'+surveyProjecId+'====='+ebProjectId);
                    if(Integer.valueOf(var.QuestionType) == 15 && isValidResponse && (var.ResponseNumber == responseNumber || surveyProjecId.trim() == ebProjectId.trim())){
                        noteObj = new Note();
                        noteObj.ParentId = ebProjectId;
                        noteObj.Title = var.questionText;
                        for(Cevent_WebService_Helper.SurveyAnswereWrapper val: var.Answere){
                            system.debug('====AnswerText===='+val.AnswerText);
                            noteObj.Body = val.AnswerText; 
                        }
                        if(noteObj.Body != null){
                            noteList.add(noteObj);
                        }
                    }   
                }else{
                    System.Debug('Soap Request didn\'t return any survey attachments.'); 
                }                 
            }
            try{
                if(!noteList.isEmpty()){
                    insert noteList;
                    EB_SB_Builder__c ebProjObj = new EB_SB_Builder__c();
                    ebProjObj.Id = ebProjectId;
                    ebProjObj.Is_Attachment_Sync_Successful__c = true;
                    update ebProjObj;
                }                
            }Catch(Exception exp){
                System.debug ('Error Message===> '+  exp.getmessage());
                // Create new record in Logs WareHouse.
                LogsWarehouse__c newRec = new LogsWarehouse__c();
                newRec.Service_Name__c = 'Survey Tool - Attachment Integration';
                newRec.Status__c = 'Failed';
                newRec.Error_description__c = exp.getMessage();
                insert newRec; 
            }
        }
    }       
}