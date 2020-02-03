/*******************************************************************************************************************   
* Author: Sandeep Kumar
* Date: 04-Sep-2017
* Class Name : SyncSurveyFromInquisium_WebService 
* Description : Retrieves Survey responses from Inquisium tool and updates it to several objects based on the Survey Type.
* Calling Class - InquisiumToSalesforceEmailParser
* Test Class - InquisiumToSalesforceEmailParser_Test
*
* Version 2: Revamped the class to handle Multiple Survey responses in the Salesforce Organsation.
* Last Modified By : Sandeep Kumar (Dated: 20 June, 2018) 
**********************************************************************************************************************/
global class SyncSurveyFromInquisium_WebService {
    private static Map<String,SyncSurveyFromInquisiumMapping__mdt> metaDataLabelToMetaDataTypeMap;
    
    @future(callout=true)
    webservice static void getSurveyResponseFromInquisium(String surveyResponseNumber,String surveyRefId,String surveyType){ 
        system.debug('==Response Number======>>'+surveyResponseNumber+'====SFDC Ref ID====>>>>'+surveyRefId+'===========Survey Type=======>>>>>'+surveyType);
        String SessionID = '';
        Set<String> surveyIds = new Set<String>(); 
        
        // Get Survey Mappings from the Custom MetaData Type - "SyncSurveyFromInquisiumMapping__mdt"
        metaDataLabelToMetaDataTypeMap = new Map<String,SyncSurveyFromInquisiumMapping__mdt>();
        for(SyncSurveyFromInquisiumMapping__mdt rec : [Select Id,Label,
                                                       Survey_Account_ID__c,
                                                       Survey_Type__c,
                                                       Survey_Sub_Type__c,
                                                       Survey_Account_Password__c,
                                                       Survey_Account_Username__c,
                                                       Survey_Link__c,Survey_Stub_ID__c,
                                                       Survey_Sync_Deadline_In_Days__c,
                                                       Target_Object__c,
                                                       Target_Object_API__c,
                                                       Record_Type_DevName__c,
                                                       Allow_Multiple_Responses__c  From SyncSurveyFromInquisiumMapping__mdt Where Active__c = true]){
            metaDataLabelToMetaDataTypeMap.put(rec.Label, rec);
        } 
        
        // SOAP Request Type = Login
        Map<string,string> LoginRequestMap = new Map<string,string>();
        LoginRequestMap.put('Account',metaDataLabelToMetaDataTypeMap.get(surveyType).Survey_Account_ID__c.trim());
        LoginRequestMap.put('UserName',metaDataLabelToMetaDataTypeMap.get(surveyType).Survey_Account_Username__c.trim());
        LoginRequestMap.put('Password',metaDataLabelToMetaDataTypeMap.get(surveyType).Survey_Account_Password__c.trim());
        Cevent_WebService_Helper LoginStub = new Cevent_WebService_Helper();
        List<Cevent_WebService_Helper.LoginResult> result = new List<Cevent_WebService_Helper.LoginResult>();
        
        if(!Test.isRunningTest()){
            result = LoginStub.loginRequest(LoginRequestMap,40000);
        }else{
            Cevent_WebService_Helper.LoginResult testobj = new Cevent_WebService_Helper.LoginResult();
            testobj.sessionId='sssssss'; 
            testobj.Error_Code='200'; 
            result.add(testobj);         
        }
        system.debug('Session Id === '+result[0].sessionId);
        SessionID = result[0].sessionId;
        
        /*******************************************************************************************************************************************************/
        // SOAP Request Type = Search 
        // Pulls Surveys which are rcently created in Survey Tool.  
        
        Map<string,string> SearchRequestMap = new Map<string,string>();
        SearchRequestMap.put('SessionID',result[0].sessionId);
        
        // Else part executes whenever the request comes from the automated workflow.
        if(surveyType != null){
            // Update the Cvent Survey ID
            SearchRequestMap.put('SurveyID',metaDataLabelToMetaDataTypeMap.get(surveyType).Survey_Stub_ID__c.trim());            
        } 
        
        Date DateToday = date.today().addDays(-Integer.valueOf(metaDataLabelToMetaDataTypeMap.get(surveyType).Survey_Sync_Deadline_In_Days__c));
        string dateValue = String.valueOf(DateToday);
        SearchRequestMap.put('Date',dateValue);        
        
        Cevent_WebService_Helper SearchStub = new Cevent_WebService_Helper();
        List<Cevent_WebService_Helper.searchWrapper> SearchResult = new List<Cevent_WebService_Helper.searchWrapper>();
        if(!Test.isRunningTest()){
            SearchResult = SearchStub.Search(SearchRequestMap,40000);
        }else{
            Cevent_WebService_Helper.searchWrapper testobj = new Cevent_WebService_Helper.searchWrapper();
            testobj.SurveyId = 'testSurveyId'; 
            testobj.Error_Code = '200'; 
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
        Cevent_WebService_Helper SurveyStub = new Cevent_WebService_Helper();
        List<Cevent_WebService_Helper.SurveyDetailWrapper> SurveyResult = new List<Cevent_WebService_Helper.SurveyDetailWrapper>();    
        
        if(!Test.isRunningTest()){
            SurveyResult = SurveyStub.retriveSurvey(SurveyRequestMap,surveyIds,40000);
        }else{
            Cevent_WebService_Helper.SurveyDetailWrapper testobj = new Cevent_WebService_Helper.SurveyDetailWrapper();
            testobj.Id = 'sssssss'; 
            testobj.Error_Code = '200'; 
            testobj.QuestionType = '15';
            testobj.ResponseNumber = surveyResponseNumber; 
            testobj.QuestionNumber = '4';
            testobj.questionText = 'Test Question Text';
            testobj.ReferenceId = surveyRefId; 
            testobj.SourceId = surveyRefId; 
            List<Cevent_WebService_Helper.SurveyAnswereWrapper> SurveyAnswereWrapper_TestList = new List<Cevent_WebService_Helper.SurveyAnswereWrapper>();  
            Cevent_WebService_Helper.SurveyAnswereWrapper testanswersObj = new Cevent_WebService_Helper.SurveyAnswereWrapper();
            testanswersObj.AnswerText = 'test answere';
            SurveyAnswereWrapper_TestList.add(testanswersObj);
            testobj.Answere = SurveyAnswereWrapper_TestList;                                   
            SurveyResult.add(testobj);         
        }
        // If the Survey Result Size is > 0. It means some surveys are reteived.
        if(SurveyResult.size() > 0){
            // Variable and Object declaration
            Integer i = 0;
            String lastValue = '';
            Survey_Q__c surveyInfoObj;  
            Boolean IsvalidSurveyRecordId;            
            String surveyResponseRefId = '';  
            String surveyResponseSourceId = '';  
            Boolean isValidResponse = false;
            String respondentName,respondentEmailAddress,questionText,questionType,questionNumber,responseNumber,surveyCompletionDate;       
            List<Survey_Q__c> surveyInformationList = new List<Survey_Q__c>();
            System.debug('Survey Response Received');
            for(Cevent_WebService_Helper.SurveyDetailWrapper surveyResponseObj : SurveyResult){
                surveyResponseSourceId = '';  
                IsvalidSurveyRecordId = true;
                // Get the survey Respondent Name
                respondentName = surveyResponseObj.FirstName+' '+surveyResponseObj.LastName;
                // Get the survey Respondent Email
                respondentEmailAddress = surveyResponseObj.Email;  
                // Get the Source ID from the survey response
                if(surveyResponseObj.SourceId != null && surveyResponseObj.SourceId != ''){
                    try{
                        surveyResponseSourceId = surveyResponseObj.SourceId; 
                    }catch(exception e){
                        system.debug('surveyResponseSourceId = '+surveyResponseSourceId);
                        IsvalidSurveyRecordId = false;
                    }
                }
                // Get the attributes from the parent header.
                questionText = surveyResponseObj.QuestionText;
                questionType = surveyResponseObj.QuestionType; 
                questionNumber = surveyResponseObj.QuestionNumber;   
                responseNumber = surveyResponseObj.ResponseNumber;
                
                system.debug(responseNumber+'===========Response Number received from Integration===============Source Id'+surveyResponseSourceId);
                system.debug(surveyResponseNumber+'===========Response Number received from Email======Source ID'+surveyRefId);
                
                // Handles only one response per object
                // Creates a Survey Information Object only if the Salesforce Record ID and Survey Source ID are matched.
                // AND Inquisium Response Number and Survey Response Number are matched.
                if(!metaDataLabelToMetaDataTypeMap.get(surveyType).Allow_Multiple_Responses__c && surveyResponseNumber == responseNumber && surveyRefId == surveyResponseSourceId){
                    // Fetch individual responses and create a Survey Information Object.
                    for(Cevent_WebService_Helper.SurveyAnswereWrapper val: surveyResponseObj.Answere){
                        surveyInfoObj = new Survey_Q__c();
                        surveyInfoObj.Name = respondentName;
                        surveyInfoObj.Email_Address__c = respondentEmailAddress;
                        surveyInfoObj.Question_Text__c = questionText;
                        // Adding Sub Question to the Answerpart field.
                        surveyInfoObj.AnswerPart__c = val.AnswerPart;
                        surveyInfoObj.Question_Type__c = questionType;
                        surveyInfoObj.Question__c = questionNumber;
                        // Dynamically updates the parent Object Id for which the survey is being filled out.
                        surveyInfoObj.put(metaDataLabelToMetaDataTypeMap.get(surveyType).Target_Object_API__c,surveyResponseSourceId);
                        surveyInfoObj.Answere__c = val.AnswerText;
                        
                        //surveyInfoObj.Survey_Completed_Date__c = DateTime.valueOf(val.AnswerText);
                        if(IsvalidSurveyRecordId){
                            surveyInformationList.add(surveyInfoObj);  
                        }                         
                    }
                    // Handles multiple responses per object
                    // Creates a Survey Information Object only if the Salesforce Record ID and Survey Source ID are matched.                    
                }else if(metaDataLabelToMetaDataTypeMap.get(surveyType).Allow_Multiple_Responses__c && surveyRefId == surveyResponseSourceId){
                    // Fetch individual responses and create a Survey Information Object.
                    for(Cevent_WebService_Helper.SurveyAnswereWrapper val: surveyResponseObj.Answere){
                        surveyInfoObj = new Survey_Q__c();
                        surveyInfoObj.Name = respondentName;
                        surveyInfoObj.Email_Address__c = respondentEmailAddress;
                        surveyInfoObj.Question_Text__c = questionText;
                        // Adding Sub Question to the Answerpart field.
                        surveyInfoObj.AnswerPart__c = val.AnswerPart;
                        surveyInfoObj.Question_Type__c = questionType;
                        surveyInfoObj.Question__c = questionNumber;
                        // Dynamically updates the parent Object Id for which the survey is being filled out.
                        surveyInfoObj.put(metaDataLabelToMetaDataTypeMap.get(surveyType).Target_Object_API__c,surveyResponseSourceId);
                        surveyInfoObj.Answere__c = val.AnswerText;
                        
                        //surveyInfoObj.Survey_Completed_Date__c = DateTime.valueOf(val.AnswerText);
                        if(IsvalidSurveyRecordId){
                            surveyInformationList.add(surveyInfoObj);  
                        }                         
                    } 
                }
            }
            try{
                if(!surveyInformationList.isEmpty()){
                    insert surveyInformationList;
                    InquisiumToSalesforceEmailParser.StoreStatusInLogsWarehouse(surveyRefId,'Success','');
                }                
            }Catch(Exception exp){
                System.debug ('Error Message===> '+  exp.getmessage());
                // Create a LogsWarehouse Object for the exception.
                if(surveyRefId != null) InquisiumToSalesforceEmailParser.StoreStatusInLogsWarehouse(surveyRefId,'Failed',exp.getMessage()+'\n\n\n Response Number'+responseNumber);
            }
        }else{
            System.debug('<==No Records retrieved==>');
        }    
    }    
}