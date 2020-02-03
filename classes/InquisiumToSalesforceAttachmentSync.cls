/*    
* Author: Sandeep Kumar
* Date: 20-Jan-2019
* Class Name : InquisiumToSalesforceAttachmentSync 
* Description : Retrieves Survey attachments from Survye/ Inquisium Tool and updates it to several objects based on the Attachment Type/ Sub Type.
* Class uses Custom Metadata Type - SyncSurveyFromInquisiumMappings
* Stores the complete configuration of below class.
* Class is called from InquisiumToSalesforceEmailParser - Inbound Email Handler
* Global email address used within Cvent for Survey Integration- InquisiumToSalesforceSync@cvent.com
* Test Class - InquisiumToSalesforceEmailParser_Test 
*/
global class InquisiumToSalesforceAttachmentSync{    
    private static string attachmentFinalKey;
    private static Map<String,SyncSurveyFromInquisiumMapping__mdt> metaDataLabelToMetaDataTypeMap;
    
    @future(callout=true)
    webservice static void processRequest(String surveyResponseNumber,String salesforceRecordId,String attachmentType,String attachmentSubType){ 
        system.debug('==Response Number=='+surveyResponseNumber+'====SFDC Record ID===='+salesforceRecordId+'===========Attachment Type======='+attachmentType+'===========Attachment Sub Type======='+attachmentSubType);
        String attachmentKey = '';
        // prepare attachmentFinalKey to be used later to fetch the survey
        if(attachmentType != null)
            attachmentFinalKey = attachmentType.trim();
        if(attachmentSubType != null)
            attachmentFinalKey += ':'+attachmentSubType;
        
        // Get Survey Mappings from the Custom MetaData Type - "SyncSurveyFromInquisiumMapping__mdt"
        metaDataLabelToMetaDataTypeMap = new Map<String,SyncSurveyFromInquisiumMapping__mdt>();
        for(SyncSurveyFromInquisiumMapping__mdt rec : [Select Id,Label,
                                                       Survey_Account_ID__c,
                                                       Attachment_Sync__c,
                                                       Attachment_Sync_Deadline__c,
                                                       Attachment_Type__c,
                                                       Attachment_Sub_Type__c,
                                                       Survey_Sub_Type__c,
                                                       Survey_Type__c,
                                                       Survey_Account_Password__c,
                                                       Survey_Account_Username__c,
                                                       Survey_Link__c,Survey_Stub_ID__c,
                                                       Survey_Sync_Deadline_In_Days__c,
                                                       Target_Object__c,
                                                       Target_Object_API__c,
                                                       Allow_Multiple_Responses__c From SyncSurveyFromInquisiumMapping__mdt Where Active__c = true AND Attachment_Sync__c = true])
        {
            
            if(rec.Attachment_Type__c != null)
                attachmentKey = rec.Attachment_Type__c.trim();
            if(rec.Attachment_Sub_Type__c != null)
                attachmentKey += ':'+rec.Attachment_Sub_Type__c.trim();
            // prepare map to be used later to call Inquisium Survey Attachment API
            metaDataLabelToMetaDataTypeMap.put(attachmentKey,rec);
        }
        
        System.debug('attachmentFinalKey ==>>'+attachmentFinalKey);
        System.debug('Attachment Metadata Found ==>>'+metaDataLabelToMetaDataTypeMap.containsKey(attachmentFinalKey));
        
        String SessionID;
        Set<String>surveyIds=new Set<String>(); 
        
        // SOAP Request Type = Login
        Map<string,string> loginRequestMap = new Map<string,string>();
        loginRequestMap.put('Account',metaDataLabelToMetaDataTypeMap.get(attachmentFinalKey).Survey_Account_ID__c.trim());
        loginRequestMap.put('UserName',metaDataLabelToMetaDataTypeMap.get(attachmentFinalKey).Survey_Account_Username__c.trim());
        loginRequestMap.put('Password',metaDataLabelToMetaDataTypeMap.get(attachmentFinalKey).Survey_Account_Password__c.trim());
        
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
        system.debug('result for session===>'+result[0].sessionId);
        SessionID=result[0].sessionId;
        
        /*******************************************************************************************************************************************************/
        // SOAP Request Type = Search 
        // pulls Attachments which are recently created in Survey Tool.  
        
        Map<string,string> searchRequestMap = new Map<string,string>();
        searchRequestMap.put('SessionID',result[0].sessionId);
        
        // else part executes whenever the request comes from the automated workflow.
        if(attachmentFinalKey != null){
            // update the Cvent Survey ID
            searchRequestMap.put('SurveyID',metaDataLabelToMetaDataTypeMap.get(attachmentFinalKey).Survey_Stub_ID__c.trim());            
        }         
        
        Date dateToday = date.today().addDays(-Integer.valueOf(metaDataLabelToMetaDataTypeMap.get(attachmentFinalKey).Attachment_Sync_Deadline__c));
        
        String dateValue = String.valueOf(dateToday);
        searchRequestMap.put('Date',dateValue);        
        
        Cevent_WebService_Helper searchStub = new Cevent_WebService_Helper();
        List<Cevent_WebService_Helper.searchWrapper> searchResult = new List<Cevent_WebService_Helper.searchWrapper>();
        
        if(!Test.isRunningTest()){
            searchResult = searchStub.Search(searchRequestMap,40000);
        }else{
            Cevent_WebService_Helper.searchWrapper testobj = new Cevent_WebService_Helper.searchWrapper();
            testobj.SurveyId='testSurveyId'; 
            testobj.Error_Code='200'; 
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
            testobj.ResponseNumber = '55049764'; 
            testobj.QuestionNumber = '4';
            testobj.questionText = 'Test Question Text';
            testobj.ReferenceId = '50000000008d619'; 
            testobj.SourceId = '50000000008d619'; 
            List<Cevent_WebService_Helper.SurveyAnswereWrapper> SurveyAnswereWrapper_TestList = new List<Cevent_WebService_Helper.SurveyAnswereWrapper>();  
            Cevent_WebService_Helper.SurveyAnswereWrapper testanswersObj = new Cevent_WebService_Helper.SurveyAnswereWrapper();
            testanswersObj.AnswerText = 'test answere';
            SurveyAnswereWrapper_TestList.add(testanswersObj);
            testobj.Answere = SurveyAnswereWrapper_TestList;                                   
            surveyResult.add(testobj);         
        }
        
        Boolean isValidResponse = false;
        String surveyResponseRefId = '';  
        String surveyResponseSourceId = '';
        String responseNumber = '';
        
        // inserts the survey attachments to the EB SB Project.
        if(surveyResult.size()>0){
            List<Note> noteList = new List<Note>();
            Note noteObj;
            
            for(Cevent_WebService_Helper.SurveyDetailWrapper surveyResponseObj : surveyResult){
                // get the Source ID from the survey response
                if(surveyResponseObj.SourceId != null && surveyResponseObj.SourceId != ''){
                    isValidResponse = true;
                    surveyResponseSourceId = surveyResponseObj.SourceId; 
                }
                // get the Reference ID from the survey response
                if(surveyResponseObj.ReferenceId != null && surveyResponseObj.ReferenceId != ''){
                    isValidResponse = true;
                    surveyResponseRefId = surveyResponseObj.ReferenceId; 
                }
                // get the Response Number from the survey response
                responseNumber = surveyResponseObj.ResponseNumber;
                
                if(surveyResponseObj != null && surveyResponseObj.QuestionType != null){
                    system.debug(Integer.valueOf(surveyResponseObj.QuestionType)+'====='+surveyResponseNumber+'======'+surveyResponseNumber+'======'+surveyResponseRefId+'====='+salesforceRecordId);
                    if(Integer.valueOf(surveyResponseObj.QuestionType) == 15 && isValidResponse && surveyResponseNumber == responseNumber && (surveyResponseRefId.trim() == salesforceRecordId.trim() || surveyResponseSourceId == salesforceRecordId.trim())){
                        // create new note record
                        noteObj = new Note(ParentId = salesforceRecordId,Title  = surveyResponseObj.questionText);
                        // get the attachment url from the survey response
                        for(Cevent_WebService_Helper.SurveyAnswereWrapper surveyResponse : surveyResponseObj.Answere){
                            system.debug('====Attachment URL===='+surveyResponse.AnswerText);
                            noteObj.Body = surveyResponse.AnswerText; 
                        }
                        if(noteObj.Body != null) noteList.add(noteObj);
                    }   
                }else{
                    System.Debug('Soap Request didn\'t return any survey attachments.'); 
                }       
            }            
            try{
                if(!noteList.isEmpty()){
                    insert noteList;
                    // creating a new sObject instance
                    sObject sObj = Schema.getGlobalDescribe().get(metaDataLabelToMetaDataTypeMap.get(attachmentFinalKey).Target_Object_API__c).newSObject() ;
                    sObj.put('Id',salesforceRecordId) ;
                    sObj.put('Is_Attachment_Sync_Successful__c',true);
                    update sObj ;
                }                
            }Catch(Exception exp){
                // create a new record in Logs WareHouse.
                insert new LogsWarehouse__c(Service_Name__c = 'Survey Tool - Attachment Integration',Status__c = 'Failed',Error_description__c = 'Salesforce Record ID = '+salesforceRecordId+'\n\n Exception Message = '+exp.getMessage()); 
            }
        }
    }
}