/*******************************************************************************************************************   
* Author: Sandeep Kumar
* Date: 04-Sep-2017
* Class Name : InquisiumToSalesforceSurveySync 
* Description : Retrieves Survey responses from Inquisium tool and updates it to several objects based on the Survey Type.
* Calling Class - InquisiumToSalesforceEmailParser
* Test Class - InquisiumToSalesforceEmailParser_Test
*
* Version 2: Revamped the class to handle Multiple Survey responses in the Salesforce Organsation.
* Last Modified By : Sandeep Kumar (Dated: 20 June, 2018) 
*
* Version 2.1: Revamped the class to handle Multiple Surveys per object in the Salesforce Organsation.
* Last Modified By : Sandeep Kumar (Dated: 30 Jan, 2019) 
**********************************************************************************************************************/
global class InquisiumToSalesforceSurveySync{
    private static string surveyFinalKey;
    private static Map<String,Survey_Q__c> surveyInfokeyToSurveyInfoObjMap;
    private static Map<String,SyncSurveyFromInquisiumMapping__mdt> metaDataLabelToMetaDataTypeMap;
    
    @future(callout=true)
    webservice static void makeInquisiumCallout(String surveyResponseNumber,String surveyRefId,String recordType,String surveyType,String surveySubType){ 
        system.debug('==Response Number======>>'+surveyResponseNumber+'====SFDC Ref ID====>>>>'+surveyRefId+'===========Survey Type=======>>>>>'+surveyType+'===========Survey Sub Type=======>>>>>'+surveySubType);
        
        String surveyKey = '';
        // prepare surveyFinalKey to be used later to fetch the survey
        if(recordType != null)
            surveyFinalKey = recordType.trim();
        if(surveyType != null)
            surveyFinalKey += ':'+surveyType.trim();
        if(surveySubType != null)
            surveyFinalKey += ':'+surveySubType.trim();
        
        // Get Survey Mappings from the Custom MetaData Type - "SyncSurveyFromInquisiumMapping__mdt"
        metaDataLabelToMetaDataTypeMap = new Map<String,SyncSurveyFromInquisiumMapping__mdt>();
        
        for(SyncSurveyFromInquisiumMapping__mdt rec : [Select Id,Label,
                                                       Survey_Type__c,
                                                       Survey_Sub_Type__c,
                                                       Survey_Account_ID__c,
                                                       Survey_Account_Password__c,
                                                       Survey_Account_Username__c,
                                                       Survey_Link__c,
                                                       Survey_Stub_ID__c,
                                                       Survey_Sync_Deadline_In_Days__c,
                                                       Target_Object__c,
                                                       Target_Object_API__c,
                                                       Record_Type_DevName__c,
                                                       Allow_Multiple_Responses__c  From SyncSurveyFromInquisiumMapping__mdt Where Active__c = true])
        {
            // prepare survey key
            if(rec.Record_Type_DevName__c != null)
                surveyKey = rec.Record_Type_DevName__c.trim();
            if(rec.Survey_Type__c != null)
                surveyKey += ':'+rec.Survey_Type__c.trim();
            if(rec.Survey_Sub_Type__c != null)
                surveyKey += ':'+rec.Survey_Sub_Type__c.trim();
            
            // prepare map to be used later to call Inquisium Survey API
            metaDataLabelToMetaDataTypeMap.put(surveyKey,rec);
        } 
        
        System.debug('surveyFinalKey ==>>'+surveyFinalKey);
        System.debug('Survey Metadata Found ==>>'+metaDataLabelToMetaDataTypeMap.containsKey(surveyFinalKey));
        
        String SessionID = '';
        Set<String> surveyIds = new Set<String>(); 
        
        // SOAP Request Type = Login
        Map<string,string> loginRequestMap = new Map<string,string>();
        LoginRequestMap.put('Account',metaDataLabelToMetaDataTypeMap.get(surveyFinalKey).Survey_Account_ID__c.trim());
        LoginRequestMap.put('UserName',metaDataLabelToMetaDataTypeMap.get(surveyFinalKey).Survey_Account_Username__c.trim());
        LoginRequestMap.put('Password',metaDataLabelToMetaDataTypeMap.get(surveyFinalKey).Survey_Account_Password__c.trim());
        Cevent_WebService_Helper loginStub = new Cevent_WebService_Helper();
        List<Cevent_WebService_Helper.LoginResult> result = new List<Cevent_WebService_Helper.LoginResult>();
        
        if(!Test.isRunningTest()){
            result = loginStub.loginRequest(loginRequestMap,40000);
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
        
        Map<string,string> searchRequestMap = new Map<string,string>();
        searchRequestMap.put('SessionID',result[0].sessionId);
        
        // Else part executes whenever the request comes from the automated workflow.
        if(surveyFinalKey != null){
            // Update the Cvent Survey ID
            searchRequestMap.put('SurveyID',metaDataLabelToMetaDataTypeMap.get(surveyFinalKey).Survey_Stub_ID__c.trim());            
        } 
        
        Date DateToday = date.today().addDays(-Integer.valueOf(metaDataLabelToMetaDataTypeMap.get(surveyFinalKey).Survey_Sync_Deadline_In_Days__c));
        string dateValue = String.valueOf(DateToday);
        searchRequestMap.put('Date',dateValue);        
        
        Cevent_WebService_Helper searchStub = new Cevent_WebService_Helper();
        List<Cevent_WebService_Helper.searchWrapper> searchResult = new List<Cevent_WebService_Helper.searchWrapper>();
        if(!Test.isRunningTest()){
            searchResult = searchStub.Search(searchRequestMap,40000);
        }else{
            Cevent_WebService_Helper.searchWrapper testobj = new Cevent_WebService_Helper.searchWrapper();
            testobj.SurveyId = 'testSurveyId'; 
            testobj.Error_Code = '200'; 
            searchResult.add(testobj);         
        }
        
        // Collecting survey IDS from Search API response.         
        for(Cevent_WebService_Helper.searchWrapper var : searchResult){
            surveyIds.add(var.SurveyId);
        }
        system.debug('DailySurveyIds===>'+surveyIds);
        
        /*******************************************************************************************************************************************************/
        // SOAP Request Type = Retrieve 
        // Pulls the corresponding surveys for the corresponding surveyIDs created in Survey Tool. 
        
        Map<string,string> surveyRequestMap = new Map<string,string>();
        surveyRequestMap.put('SessionID',SessionID);
        Cevent_WebService_Helper surveyStub = new Cevent_WebService_Helper();
        List<Cevent_WebService_Helper.SurveyDetailWrapper> surveyResult = new List<Cevent_WebService_Helper.SurveyDetailWrapper>();    
        
        if(!Test.isRunningTest()){
            surveyResult = surveyStub.retriveSurvey(surveyRequestMap,surveyIds,40000);
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
            String surveyInfoKey = '';
            
            // get survey information
            if(metaDataLabelToMetaDataTypeMap.get(surveyFinalKey).Allow_Multiple_Responses__c){
                for(Survey_Q__c surveyInfo  : getSurveyInfo(metaDataLabelToMetaDataTypeMap.get(surveyFinalKey),surveyRefId)){
                    surveyInfoKey = '';
                    
                    if(surveyInfo.Name != null)
                        surveyInfoKey = surveyInfo.Name.trim();
                    if(surveyInfo.Email_Address__c != null)
                        surveyInfoKey += ':'+surveyInfo.Email_Address__c.trim();
                    if(surveyInfo.Question_Text__c != null)
                        surveyInfoKey += ':'+surveyInfo.Question_Text__c.trim();
                    if(surveyInfo.AnswerPart__c != null)
                        surveyInfoKey += ':'+surveyInfo.AnswerPart__c.trim();
                    if(surveyInfo.Answere__c != null)
                        surveyInfoKey += ':'+surveyInfo.Answere__c.trim();
                    // create unique record in the map
                    surveyInfokeyToSurveyInfoObjMap.put(surveyInfoKey, surveyInfo);
                }
            }
            
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
                if(!metaDataLabelToMetaDataTypeMap.get(surveyFinalKey).Allow_Multiple_Responses__c && surveyResponseNumber == responseNumber && surveyRefId == surveyResponseSourceId){
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
                        surveyInfoObj.put(metaDataLabelToMetaDataTypeMap.get(surveyFinalKey).Target_Object_API__c,surveyResponseSourceId);
                        surveyInfoObj.Answere__c = val.AnswerText;
                        
                        //surveyInfoObj.Survey_Completed_Date__c = DateTime.valueOf(val.AnswerText);
                        if(IsvalidSurveyRecordId){
                            surveyInformationList.add(surveyInfoObj);  
                        }                         
                    }
                    // Handles multiple responses per object
                    // Creates a Survey Information Object only if the Salesforce Record ID and Survey Source ID are matched.                    
                }else if(metaDataLabelToMetaDataTypeMap.get(surveyFinalKey).Allow_Multiple_Responses__c && surveyRefId == surveyResponseSourceId){
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
                        surveyInfoObj.put(metaDataLabelToMetaDataTypeMap.get(surveyFinalKey).Target_Object_API__c,surveyResponseSourceId);
                        surveyInfoObj.Answere__c = val.AnswerText;
                        
                        surveyInfoKey = '';
                        // prepare unique key for map
                        if(surveyInfoObj.Name != null)
                            surveyInfoKey = surveyInfoObj.Name.trim();
                        if(surveyInfoObj.Email_Address__c != null)
                            surveyInfoKey += ':'+surveyInfoObj.Email_Address__c.trim();
                        if(surveyInfoObj.Question_Text__c != null)
                            surveyInfoKey += ':'+surveyInfoObj.Question_Text__c.trim();
                        if(surveyInfoObj.AnswerPart__c != null)
                            surveyInfoKey += ':'+surveyInfoObj.AnswerPart__c.trim();
                        if(surveyInfoObj.Answere__c != null)
                            surveyInfoKey += ':'+surveyInfoObj.Answere__c.trim();
                        
                        //
                        if(surveyInfokeyToSurveyInfoObjMap != NULL) 
                        if(IsvalidSurveyRecordId && (!surveyInfokeyToSurveyInfoObjMap.containsKey(surveyInfoKey))){
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
                // create a LogsWarehouse object for the exception.
                if(surveyRefId != null) InquisiumToSalesforceEmailParser.StoreStatusInLogsWarehouse(surveyRefId,'Failed',exp.getMessage()+'\n\n\n Response Number'+responseNumber);
            }
        }else{
            System.debug('<==No Records retrieved==>');
        }    
    } 
    
    private static List<Survey_Q__c> getSurveyInfo(SyncSurveyFromInquisiumMapping__mdt metaDataType,String salesforceRecordId){
        String surveyInfoQuery = 'SELECT Id';
        // make describe call for Survey Information
        Schema.DescribeSObjectResult surveyInfo_desc = Survey_Q__c.sObjectType.getDescribe(); 
        // get all fields from the Survey Information object, 
        Map<String, Schema.SObjectField> surveyInfo_fields = surveyInfo_desc.fields.getMap();
        // prepare dynamic query
        for(Schema.sObjectField fld : surveyInfo_fields.values()){ 
            if(String.valueOf(fld) != 'Id') surveyInfoQuery +=','+String.valueOf(fld);
        }
        // add filter 
        surveyInfoQuery += ' From Survey_Q__c Where '+metaDataType.Target_Object_API__c+'=\''+salesforceRecordId+'\'';       
        System.debug('surveyInfoQuery <==>'+surveyInfoQuery);
        
        // return survye information records
        return Database.query(surveyInfoQuery);
    }
}