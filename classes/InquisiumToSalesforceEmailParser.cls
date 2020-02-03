/********************************************************************************************************************************
* Author: Sandeep Kumar
* Date: 07-Sep-2017
* Class Name : InquisiumToSalesforceEmailParser 
* Description : Retrieves Survey responses from Survye/ Inquisium Tool and updates it to several objects based on the Survey Type.
* Class uses Custom Metadata Type - SyncSurveyFromInquisiumMappings
* Stores the complete configuration of below class.
* Class is called from InquisiumToSalesforceEmailParser - Inbound Email Handler
* Global email address used within Cvent for Survey Integration- InquisiumToSalesforceSync@cvent.com
* Test Class - InquisiumToSalesforceEmailParser_Test
*
* Version 2: Revamped the class to handle Multiple Survey responses in the Salesforce Organsation.
* Last Modified By : Sandeep Kumar (Dated: 18 June, 2018) 
*********************************************************************************************************************************/
global class InquisiumToSalesforceEmailParser implements Messaging.InboundEmailHandler{
    private static Messaging.SingleEmailMessage mail;
    private boolean surveyFilled,responseGenerated,SFDCRefIdGenerated;
    private String htmlBody,responseNumber,SFDCRefId,recordTypeDevName,inquisiumSurveyType,inquisiumSurveySubType;
    private final String caseObjPrefix = Label.Inquisium_To_Salesforce_Case_Prefix;    
    private Map<String,SyncSurveyFromInquisiumMapping__mdt> metaDataRecordTypeToMetaDataTypeMap;
    private final String surveyHeaderObjPrefix = Label.Inquisium_To_Salesforce_Survey_Header_Prefix;
    private final String bundleCardItemObjPrefix = Label.Inquisium_To_Salesforce_Bundle_Card_Item_Prefix;    
    private final String onsiteSolutionProjectObjPrefix = Label.Inquisium_To_Salesforce_Onsite_Solution_Project_Prefix;
    private final String onboardingObjPrefix = Label.Inquisium_To_Salesforce_Onboarding_Prefix;
    private final String mobileAppObjPrefix = Label.Inquisium_To_Salesforce_Mobile_App_Prefix;
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env){
        // Create an InboundEmailResult object for returning the result of the Apex Email Service
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        // Initilize the Objects.
        htmlBody = '';
        SFDCRefId = '';
        responseNumber = '';
        recordTypeDevName = '';
        inquisiumSurveyType = '';
        inquisiumSurveySubType = '';
        SFDCRefIdGenerated = false;
        surveyFilled = false;
        responseGenerated = false;
        // String representing the body of the incoming e-mail message
        htmlBody = email.htmlBody;
        system.debug('Entry Point ====>> htmlBody==='+htmlBody);
        
        // Get Survey Mappings from the Custom MetaData Type - "SyncSurveyFromInquisiumMapping__mdt"
        metaDataRecordTypeToMetaDataTypeMap = new Map<String,SyncSurveyFromInquisiumMapping__mdt>();
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
                                                       Record_Type_DevName__c,
                                                       Target_Object__c,
                                                       Target_Object_API__c,
                                                       Allow_Multiple_Responses__c From SyncSurveyFromInquisiumMapping__mdt Where Active__c = true])
        {
            // Mapping Key is RecordTypeName and Value is complete Object.
            metaDataRecordTypeToMetaDataTypeMap.put(rec.Record_Type_DevName__c,rec);
        }        
        
        if(htmlBody.contains('<table border="0" cellspacing="0" cellpadding="3" style="font-size:10pt; font-family: Arial, Helvetica, sans-serif; border-collapse: collapse;" width="590">')){
            String htmlTable1 = htmlBody.substringBetween('<table border="0" cellspacing="0" cellpadding="3" style="font-size:10pt; font-family: Arial, Helvetica, sans-serif; border-collapse: collapse;" width="590">','</table>');
            String htmlTable2 = htmlBody.substringBetween('<table border="0" cellspacing="0" cellpadding="3" style="font-size:10pt; font-family: Arial, Helvetica, sans-serif; border-collapse: collapse;" width="600">','</table>');
            
            /**************************************Fetch the Source ID from the Survey Alert Email*************************************************/
            if(htmlTable1 != null){
                for(String st : htmlTable1.split('<tr style="font-size:10pt;font-family: Arial, Helvetica, sans-serif; background-color: #fff;">')){
                    if(st.contains('width="180"') && st.contains('Source ID')){
                        SFDCRefIdGenerated = true;
                    }
                    if(st.contains('width="410"')){
                        if(SFDCRefId == '' && SFDCRefIdGenerated){
                            SFDCRefId = st.substringBetween('<td width="410" align="left" valign="top" style="background-color: #fff; border: 1px solid #cccccc;">','</td>');
                            SFDCRefIdGenerated = false;
                        }
                    }                    
                }
            }
            
            /**************************************Fetch the Response Number from the Survey Alert Email*************************************************/
            if(htmlTable2 != null){
                for(String st : htmlTable2.split('<tr style="font-size:10pt;font-family: Arial, Helvetica, sans-serif; background-color: #fff;">')){
                    if(st.contains('width="180"') && st.contains('Response Number')){
                        responseGenerated = true;
                    }
                    if(st.contains('width="410"')){
                        if(responseNumber == '' && responseGenerated){
                            responseNumber = st.substringBetween('<td width="410" align="left" valign="top" style="background-color: #fff; border: 1px solid #cccccc;">','</td>');
                            responseGenerated = false;
                        }
                    }                                       
                }
            }
            
            system.debug('Source Id = '+SFDCRefId);
            system.debug('Response Number = '+responseNumber);
            
            try{                
                if(SFDCRefId != null && SFDCRefId.startsWithIgnoreCase(surveyHeaderObjPrefix)){
                    /**************************************Financial Force Survey Block*************************************************/
                    Survey_Header__c surveyHeaderobjSurvey = [Select Id,Survey_Type__c,Inquisium_Response_Number__c From Survey_Header__c Where Id =:SFDCRefId LIMIT 1];
                    // Updates Survey Response Number at Survey Header Object level.
                    if(responseNumber != null && responseNumber != ''){
                        if(surveyHeaderobjSurvey.Inquisium_Response_Number__c == null){
                            surveyHeaderobjSurvey.Inquisium_Response_Number__c = responseNumber;
                            update surveyHeaderobjSurvey;
                            
                        } 
                        // Get the mapping form the Meta-Data Type and calls a webservice class for pulling survey response.
                        if(surveyHeaderobjSurvey.Survey_Type__c != null && metaDataRecordTypeToMetaDataTypeMap.containsKey(surveyHeaderobjSurvey.Survey_Type__c)){
                            inquisiumSurveyType = metaDataRecordTypeToMetaDataTypeMap.get(surveyHeaderobjSurvey.Survey_Type__c).Label;
                            inquisiumSurveySubType = null;
                            // Web-Service Callout To Inquisium.
                            SyncSurveyFromInquisium_WebService.getSurveyResponseFromInquisium(responseNumber,SFDCRefId,inquisiumSurveyType);
                        }                           
                    }                    
                    // Set the result to true. No need to send an email back to the user with an error message.
                    result.success = true;
                }else if(SFDCRefId != null && SFDCRefId.startsWithIgnoreCase(caseObjPrefix)){
                    /**************************************Case Survey Block*************************************************/
                    Case caseObjSurvey = [Select Id,RecordType.DeveloperName,Inquisium_Response_Number__c From Case Where Id =:SFDCRefId LIMIT 1];
                    // Updates Survey Response Number at Case Object level.
                    if(responseNumber != null && responseNumber != ''){
                        if(caseObjSurvey.Inquisium_Response_Number__c == null){
                            caseObjSurvey.Inquisium_Response_Number__c = responseNumber;
                            update caseObjSurvey;
                        }
                        // Get the mapping form the Meta-Data Type and calls a webservice class for pulling survey response.
                        if(caseObjSurvey.RecordType.DeveloperName != null && metaDataRecordTypeToMetaDataTypeMap.containsKey(caseObjSurvey.RecordType.DeveloperName)){
                            inquisiumSurveyType = metaDataRecordTypeToMetaDataTypeMap.get(caseObjSurvey.RecordType.DeveloperName).Label;
                            inquisiumSurveySubType = null;
                            // Web-Service Callout To Inquisium.
                            SyncSurveyFromInquisium_WebService.getSurveyResponseFromInquisium(responseNumber,SFDCRefId,inquisiumSurveyType);
                        }else{
                            inquisiumSurveyType = metaDataRecordTypeToMetaDataTypeMap.get('caseSurvey').Label;
                            inquisiumSurveySubType = null;
                            // Web-Service Callout To Inquisium.
                            SyncSurveyFromInquisium_WebService.getSurveyResponseFromInquisium(responseNumber,SFDCRefId,inquisiumSurveyType);
                        }
                    } 
                    // Set the result to true. No need to send an email back to the user with an error message.
                    result.success = true;
                }else if(SFDCRefId != null && SFDCRefId.startsWithIgnoreCase(onsiteSolutionProjectObjPrefix)){
                    /**************************************Onsite Solution Survey Block*************************************************/
                    Alliance_OA_Projects__c onsiteSolutionObjSurvey = [Select Id,RecordType.DeveloperName,Inquisium_Response_Number__c From Alliance_OA_Projects__c Where Id =:SFDCRefId LIMIT 1];
                    // Updates Survey Response Number at Onsite Solution Object level.
                    if(responseNumber != null && responseNumber != ''){
                        if(onsiteSolutionObjSurvey.Inquisium_Response_Number__c == null){
                            onsiteSolutionObjSurvey.Inquisium_Response_Number__c = responseNumber;
                            update onsiteSolutionObjSurvey;
                            
                        }    
                        // Get the mapping form the Meta-Data Type and calls a webservice class for pulling survey response.
                        if(onsiteSolutionObjSurvey.RecordType.DeveloperName != null && metaDataRecordTypeToMetaDataTypeMap.containsKey(onsiteSolutionObjSurvey.RecordType.DeveloperName)){
                            inquisiumSurveyType = metaDataRecordTypeToMetaDataTypeMap.get(onsiteSolutionObjSurvey.RecordType.DeveloperName).Label;
                            inquisiumSurveySubType = null;
                            // Web-Service Callout To Inquisium.
                            SyncSurveyFromInquisium_WebService.getSurveyResponseFromInquisium(responseNumber,SFDCRefId,inquisiumSurveyType);
                        }else{
                            inquisiumSurveyType = metaDataRecordTypeToMetaDataTypeMap.get('onsiteSolutionSurvey').Label;
                            inquisiumSurveySubType = null;
                            // Web-Service Callout To Inquisium.
                            SyncSurveyFromInquisium_WebService.getSurveyResponseFromInquisium(responseNumber,SFDCRefId,inquisiumSurveyType);
                        }
                    } 
                    // Set the result to true. No need to send an email back to the user with an error message.
                    result.success = true;
                }else if(SFDCRefId != null && SFDCRefId.startsWithIgnoreCase(bundleCardItemObjPrefix)){
                    /**************************************Bundle Card Item Survey Block*************************************************/
                    Bundle_Card_Item__c bundleCardItemSurvey = [Select Id,/*RecordType.DeveloperName,*/Inquisium_Response_Number__c From Bundle_Card_Item__c Where Id =:SFDCRefId LIMIT 1];
                    // Updates Survey Response Number at Bundle Card Item Object level.
                    if(responseNumber != null && responseNumber != ''){
                        if(bundleCardItemSurvey.Inquisium_Response_Number__c == null){
                            bundleCardItemSurvey.Inquisium_Response_Number__c = responseNumber;
                            update bundleCardItemSurvey;
                         }   
                        inquisiumSurveyType = metaDataRecordTypeToMetaDataTypeMap.get('bundleCardItemSurvey').Label;
                        inquisiumSurveySubType = null;
                        // Web-Service Callout To Inquisium.
                        SyncSurveyFromInquisium_WebService.getSurveyResponseFromInquisium(responseNumber,SFDCRefId,inquisiumSurveyType);
                    } 
                    // Set the result to true. No need to send an email back to the user with an error message.
                    result.success = true;
                }else if(SFDCRefId != null && SFDCRefId.startsWithIgnoreCase(onboardingObjPrefix)){
                    /**************************************Bundle Card Item Survey Block*************************************************/
                    Onboarding__c onboardingSurvey = [Select Id,RecordTypeId,RecordType.DeveloperName,Inquisium_Response_Number__c From Onboarding__c Where Id =:SFDCRefId LIMIT 1];
                    // Updates Survey Response Number at Bundle Card Item Object level.
                    if(responseNumber != null && responseNumber != ''){
                        if(onboardingSurvey.Inquisium_Response_Number__c == null){
                            onboardingSurvey.Inquisium_Response_Number__c = responseNumber; 
                            update onboardingSurvey;                            
                        } 
                        recordTypeDevName = onboardingSurvey.RecordTypeId != null ? onboardingSurvey.RecordType.DeveloperName : null;
                        inquisiumSurveyType = null;
                        inquisiumSurveySubType = null;
                        
                        // web-service callout to Inquisium.
                        InquisiumToSalesforceSurveySync.makeInquisiumCallout(responseNumber,SFDCRefId,recordTypeDevName,inquisiumSurveyType,inquisiumSurveySubType);                        
                    } 
                    // Set the result to true. No need to send an email back to the user with an error message.
                    result.success = true;
                }else if(SFDCRefId != null && SFDCRefId.startsWithIgnoreCase(mobileAppObjPrefix)){
                    /**************************************Mobile App Survey Block*************************************************/
                    Mobile_Card__c mobileAppSurvey = [Select Id,RecordTypeId,RecordType.DeveloperName,Request_Type__c,Inquisium_Response_Number__c From Mobile_Card__c Where Id =:SFDCRefId LIMIT 1];
                    // updates Survey Response Number at Mobile App Object level.
                    if(responseNumber != null && responseNumber != ''){
                        if(mobileAppSurvey.Inquisium_Response_Number__c == null){
                            mobileAppSurvey.Inquisium_Response_Number__c = responseNumber;
                            update mobileAppSurvey;
                        }                        
                        recordTypeDevName = mobileAppSurvey.RecordTypeId != null ? mobileAppSurvey.RecordType.DeveloperName : null;
                        inquisiumSurveyType = mobileAppSurvey.Request_Type__c;
                        inquisiumSurveySubType = null;
                        
                        // web-service callout to Inquisium.
                        InquisiumToSalesforceSurveySync.makeInquisiumCallout(responseNumber,SFDCRefId,recordTypeDevName,inquisiumSurveyType,inquisiumSurveySubType);
                    } 
                    // Set the result to true. No need to send an email back to the user with an error message.
                    result.success = true;
                }              
                // Return the result for the Apex Email Service
                return result; 
            }catch(Exception exp){ 
                String exceptionBody = exp.getMessage()+'\n\n\n Response Number'+responseNumber;
                // Create a LogsWarehouse Object for the exception.
                if(SFDCRefId != null)
                    StoreStatusInLogsWarehouse(SFDCRefId,'Failed',exceptionBody);
                result.success = false;
            } 
        }
        // Return the result for the Apex Email Service
        return result;  
    }
    
    // creating a logs warehouse object for storing email service logs.
    public static void StoreStatusInLogsWarehouse(Id ebProjectId,String reqStatus,String reqBody){        
        // create new record in Logs WareHouse.
        insert new LogsWarehouse__c(Service_Name__c = 'Email Service - Inquisium-To-Salesforce Sync',Record_Id__c = ebProjectId,Status__c = reqStatus,Error_description__c = reqBody);
    }
}