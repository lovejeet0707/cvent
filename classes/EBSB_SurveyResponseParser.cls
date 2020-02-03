/* Author : Sandeep Kumar
* Description : EB SB Survey Parser
* It is beiing used to parse the survey reponse email and updates the feedback in salesforce.
* Date: 25 March 2017
*/
global class EBSB_SurveyResponseParser implements Messaging.InboundEmailHandler {      
    // Setup local variables to be used across all methods
    private String htmlBody,surveyQuestion,surveyAnswer,eventLaunchDate,responseNumber,ebProjId;
    private Boolean responseGenerated,SFDCRefId,eventLaunch;
    private String surveyInformation;
    Private static Messaging.SingleEmailMessage mail;
    Private Map<String,String> MonthNameToMonthNumberMap = new Map<String,String>{'Jan'=>'01','Feb'=>'02','Mar'=>'03','Apr'=>'04','May'=>'05','Jun'=>'06',
        'Jul'=>'07','Aug'=>'08','Sep'=>'09','Oct'=>'10','Nov'=>'11','Dec'=>'12'};
            
            global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env){
                // Create an InboundEmailResult object for returning the result of the Apex Email Service
                Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
                // Initilize the Objects.
                // String representing the body of the incoming e-mail message
                htmlBody = '';
                responseNumber ='';
                Boolean surveyFilled = false;
                responseGenerated = false;
                htmlBody = email.htmlBody;
                system.debug('====htmlBody==='+htmlBody);
                system.debug('====htmlBody Stripped==='+htmlBody.stripHtmlTags()); 
                
                // Below section handles the scope / rush requests replies to parent cases.
                if(email.Subject.contains('A new Rush Request is received for') || email.Subject.contains('A new Scope Request is received for')){
                    // Get the Case Id from the incoming email message.
                    String caseId = htmlBody.subStringBetween('ref:',':ref').trim();
                    // Create email message object and associate it with the parent case.
                    if(caseId != null){
                        // Prepare a EMail Message and attach it to Case.
                        EmailMessage emailMesgObj = new EmailMessage();                        
                        emailMesgObj.ParentId = caseId;                    
                        emailMesgObj.Subject = email.Subject;
                        emailMesgObj.TextBody = email.plainTextBody;
                        emailMesgObj.ToAddress = String.valueOf(email.toAddresses);
                        emailMesgObj.FromAddress = String.valueOf(email.fromAddress);
                        emailMesgObj.CcAddress = String.valueOf(email.ccAddresses);
                        emailMesgObj.FromName = email.fromName;
                        emailMesgObj.HtmlBody = email.htmlBody;
                        emailMesgObj.Incoming = true;
                        system.debug(emailMesgObj);
                        insert emailMesgObj;
                    }
                }       
                
                // Below section handles get the Response number from the incoming EB Form.
                if(htmlBody.contains('<table border="0" cellspacing="0" cellpadding="3" style="font-size:10pt; font-family: Arial, Helvetica, sans-serif; border-collapse: collapse;" width="590">')){
                    String htmlTable1 = htmlBody.substringBetween('<table border="0" cellspacing="0" cellpadding="3" style="font-size:10pt; font-family: Arial, Helvetica, sans-serif; border-collapse: collapse;" width="600">','</table>');
                    String htmlTable2 = htmlBody.subStringBetween('<td colspan="2" style="background-color:gray;color:white; border: 1px solid #cccccc;"><b>Response Information</b></td>','</table>');
                    if(htmlTable1 != null){
                        for(String st : htmlTable1.split('<tr style="font-size:10pt;font-family: Arial, Helvetica, sans-serif; background-color: #fff;">')){
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
                    
                    ebProjId = '';
                    if(htmlTable2 != null){
                        Boolean SFDCRefId = false;
                        for(String st : htmlTable2.split('<tr style="font-size:10pt;font-family: Arial, Helvetica, sans-serif; background-color: #fff;">')){
                            if(st.contains('width="295"')){
                                Integer i=0;
                                for(String tt : st.split('</td>')){
                                    if(i==0){
                                        if(tt.contains('Ref Id')){
                                            SFDCRefId = true;
                                        }                                        
                                    }else{
                                        if(SFDCRefId){
                                            ebProjId = tt.subStringAfter('<td width="295" align="left" valign="top" style="background-color: #fff; border: 1px solid #cccccc;">').trim();
                                            SFDCRefId = false;
                                        }                                        
                                    }                   
                                    i++;                                    
                                }  
                            }                            
                        }                        
                    }
                    try{
                        Boolean responseNumberFilled = false;
                        if(ebProjId != null && ebProjId.startsWithIgnoreCase('a0B')){
                            EB_SB_Builder__c eBProObj1 = [Select Id,PSP_ID__c,Event_Title__c,Response_Number__c,Project_Received_Date__c,Project__c,Project_Type_del__c,Project_Status_del__c,Opportunity__c,Survey_Feedback__c,AccountCustom__c From EB_SB_Builder__c Where Id =:ebProjId];
                            // Updates Survey Response Number at EBSB Project level.
                            if(responseNumber != null && responseNumber != ''){
                                if(eBProObj1.Response_Number__c == null){
                                    eBProObj1.Response_Number__c = responseNumber;
                                    update eBProObj1;
                                    // Calls a web-service interface to pull survey attachments whenever the Response number is updated on EB Project.
                                    InquisiumToSalesforceAttachmentSync.processRequest(responseNumber,String.valueOf(eBProObj1.Id),eBProObj1.Project__c,eBProObj1.Project_Type_del__c);
                                }else{
                                    system.debug('Inside Response Number else Part'+eBProObj1.Response_Number__c);
                                    Id eBProObjectId1 = eBProObj1.Id;
                                    for(EB_SB_Builder__c eBProObj2 : [Select Id,PSP_ID__c,Opportunity__c,Response_Number__c,Survey_Feedback__c From EB_SB_Builder__c Where Id !=:eBProObjectId1 AND Opportunity__c =:eBProObj1.Opportunity__c AND PSP_ID__c =:eBProObj1.PSP_ID__c]){
                                        if(eBProObj2.Response_Number__c == null && !responseNumberFilled){
                                            eBProObj2.Response_Number__c = responseNumber;
                                            eBProObj2.Project_Status_del__c= 'On Hold - Leadership';
                                            update eBProObj2;
                                            responseNumberFilled = true;
                                            // Send an email to Leadership informing about the duplicate links.
                                            EBSurveyNotificationEmail sendEmailToLeadership = new EBSurveyNotificationEmail();
                                            sendEmailToLeadership.sendEbProjectDuplicateLinkUsageInfo(eBProObj2);
                                            break;
                                        }                                    
                                    }                                    
                                }    
                            }                                                        
                            // Set the result to true. No need to send an email back to the user with an error message.
                            result.success = true;
                        }else{
                            result.success = false;
                        }
                        // Return the result for the Apex Email Service
                        return result;            
                    }catch(Exception exp){ 
                        String exceptionBody = exp.getMessage()+'\n\n\n'+responseNumber;
                        // Create a LogsWarehouse Object for the exception.
                        if(ebProjId != null)
                            StoreStatusInLogsWarehouse(ebProjId,'Failed',exceptionBody);
                        result.success = false;
                        // Return the result for the Apex Email Service
                        return result;
                    }                    
                }else if(htmlBody.contains('<td colspan="2" style="border:none;background:#333333;padding:.75pt .75pt .75pt .75pt">')){
                    Id ebProjectId;
                    String surveyQuestion = '';
                    String surveyAnswer = '';                    
                    try{
                        // Parse the response and add them as question and answer in the wrapper class.
                        for(String surveyRec : htmlBody.stripHtmlTags().split('Question: ')){
                            surveyQuestion = surveyRec.substringBefore('Your Answer:');
                            surveyAnswer = surveyRec.substringAfter('Your Answer: '); 
                            if(!surveyQuestion.contains('Your Answers') && surveyAnswer.trim().startsWithIgnoreCase('a0B')){
                                system.debug(surveyAnswer.deleteWhitespace().trim()+'===Ref Id===='+surveyAnswer.substring(0, 15).length());
                                ebProjectId = Id.valueOf(surveyAnswer.substring(0, 15));  
                                break;    
                            }
                        }
                        if(ebProjectId != null){
                            EB_SB_Builder__c eBProObj1 = [Select Id,PSP_ID__c,Event_Title__c,Project_Received_Date__c,Project_Status_del__c,Opportunity__c,Survey_Feedback__c,AccountCustom__c From EB_SB_Builder__c Where Id =:ebProjectId];
                            if(eBProObj1.Survey_Feedback__c == null){
                                eBProObj1.Survey_Feedback__c = htmlBody.stripHtmlTags();
                                eBProObj1.Project_Received_Date__c = Date.today();
                                update eBProObj1; 
                                UpdatePSPs(eBProObj1.Id); 
                                StoreStatusInLogsWarehouse(eBProObj1.Id,'Success',htmlBody.stripHtmlTags());
                            }else{
                                Id eBProObjectId1 = eBProObj1.Id;
                                Id eBProObjectId2;
                                for(EB_SB_Builder__c eBProObj2 : [Select Id,PSP_ID__c,Opportunity__c,Survey_Feedback__c From EB_SB_Builder__c Where Id !=:eBProObjectId1 AND Opportunity__c =:eBProObj1.Opportunity__c AND PSP_ID__c =:eBProObj1.PSP_ID__c]){
                                    if(eBProObj2.Survey_Feedback__c == null && !surveyFilled){
                                        eBProObj2.Survey_Feedback__c = htmlBody.stripHtmlTags();
                                        eBProObj2.Project_Status_del__c= 'On Hold - Leadership';
                                        update eBProObj2;
                                        UpdatePSPs(eBProObj2.Id); 
                                        StoreStatusInLogsWarehouse(eBProObj2.Id,'Success',htmlBody.stripHtmlTags());
                                        surveyFilled = true;
                                        eBProObjectId2 = eBProObj2.id;
                                        // Send an email to Leadership informing about the duplicate links.
                                        EBSurveyNotificationEmail sendEmailToLeadership = new EBSurveyNotificationEmail();
                                        sendEmailToLeadership.sendEbProjectDuplicateLinkUsageInfo(eBProObj2);
                                        break;
                                    }                                    
                                }
                                if(!surveyFilled){
                                    for(EB_SB_Builder__c eBProObj3 : [Select Id,PSP_ID__c,Opportunity__c,Survey_Feedback__c From EB_SB_Builder__c Where Id NOT IN (:eBProObjectId1,:eBProObjectId2) AND AccountCustom__c =:eBProObj1.AccountCustom__c AND PSP_ID__c =:eBProObj1.PSP_ID__c]){
                                        if(eBProObj3.Survey_Feedback__c == null && !surveyFilled){
                                            eBProObj3.Survey_Feedback__c = htmlBody.stripHtmlTags();
                                            eBProObj3.Project_Status_del__c= 'On Hold - Leadership';
                                            update eBProObj3;
                                            UpdatePSPs(eBProObj3.Id); 
                                            StoreStatusInLogsWarehouse(eBProObj3.Id,'Success',htmlBody.stripHtmlTags());
                                            surveyFilled = true;
                                            // Send an email to Leadership informing about the duplicate links.
                                            EBSurveyNotificationEmail sendEmailToLeadership = new EBSurveyNotificationEmail();
                                            sendEmailToLeadership.sendEbProjectDuplicateLinkUsageInfo(eBProObj3);
                                            break;
                                        }                                    
                                    }
                                }                                  
                            }                            
                            // Set the result to true. No need to send an email back to the user with an error message.
                            result.success = true;
                        }else{
                            result.success = false;                            
                        }
                        // Return the result for the Apex Email Service
                        return result;            
                    }catch(Exception exp){ 
                        String exceptionBody = exp.getMessage()+'\n\n\n'+htmlBody.stripHtmlTags();
                        // Create a LogsWarehouse Object for the exception.
                        if(ebProjectId != null)
                            StoreStatusInLogsWarehouse(ebProjectId,'Failed',exceptionBody);
                        result.success = false;
                        // Return the result for the Apex Email Service
                        return result;
                    }        
                }else{
                    if(htmlBody.stripHtmlTags().contains('Question: ')){
                        ebProjId = '';
                        try{
                            // Parse the response and add them as question and answer in the wrapper class.
                            for(String surveyRec : htmlBody.stripHtmlTags().split('Question: ')){
                                surveyQuestion = surveyRec.substringBefore('Your Answer:');
                                surveyAnswer = surveyRec.substringAfter('Your Answer: '); 
                                if(!surveyQuestion.contains('Your Answers') && surveyAnswer.trim().startsWithIgnoreCase('a0B')){
                                    system.debug(surveyAnswer.deleteWhitespace().trim()+'===Ref Id===='+surveyAnswer.substring(0, 15).length());
                                    ebProjId = Id.valueOf(surveyAnswer.substring(0, 15));  
                                    break;    
                                }
                            }
                            if(ebProjId != null && ebProjId.startsWithIgnoreCase('a0B')){
                                EB_SB_Builder__c eBProObj1 = [Select Id,PSP_ID__c,Event_Title__c,Project_Received_Date__c,Project_Status_del__c,Opportunity__c,Survey_Feedback__c,AccountCustom__c From EB_SB_Builder__c Where Id =:ebProjId];
                                // Updates Survey Feedback at EBSB Project level.
                                if(htmlBody != null && htmlBody.stripHtmlTags() != null){
                                    if(eBProObj1.Survey_Feedback__c == null){
                                        eBProObj1.Survey_Feedback__c = htmlBody.stripHtmlTags();
                                        eBProObj1.Project_Received_Date__c = Date.today();                                
                                        update eBProObj1;                                 
                                        UpdatePSPs(eBProObj1.Id);                            
                                        StoreStatusInLogsWarehouse(eBProObj1.Id,'Success',htmlBody.stripHtmlTags());
                                    }else{
                                        Id eBProObjectId1 = eBProObj1.Id;
                                        Id eBProObjectId2;
                                        for(EB_SB_Builder__c eBProObj2 : [Select Id,PSP_ID__c,Opportunity__c,Survey_Feedback__c From EB_SB_Builder__c Where Id !=:eBProObjectId1 AND Opportunity__c =:eBProObj1.Opportunity__c AND PSP_ID__c =:eBProObj1.PSP_ID__c]){
                                            if(eBProObj2.Survey_Feedback__c == null && !surveyFilled){
                                                eBProObj2.Survey_Feedback__c = htmlBody.stripHtmlTags();
                                                eBProObj2.Project_Status_del__c= 'On Hold - Leadership';
                                                update eBProObj2;
                                                UpdatePSPs(eBProObj2.Id); 
                                                StoreStatusInLogsWarehouse(eBProObj2.Id,'Success',htmlBody.stripHtmlTags());
                                                surveyFilled = true;
                                                eBProObjectId2 = eBProObj2.Id;
                                                // Send an email to Leadership informing about the duplicate links.
                                                EBSurveyNotificationEmail sendEmailToLeadership = new EBSurveyNotificationEmail();
                                                sendEmailToLeadership.sendEbProjectDuplicateLinkUsageInfo(eBProObj2);
                                                break;
                                            }                                    
                                        }
                                        if(!surveyFilled){
                                            for(EB_SB_Builder__c eBProObj3 : [Select Id,PSP_ID__c,Opportunity__c,Survey_Feedback__c From EB_SB_Builder__c Where Id NOT IN (:eBProObjectId1,:eBProObjectId2) AND AccountCustom__c =:eBProObj1.AccountCustom__c AND PSP_ID__c =:eBProObj1.PSP_ID__c]){
                                                if(eBProObj3.Survey_Feedback__c == null && !surveyFilled){
                                                    eBProObj3.Survey_Feedback__c = htmlBody.stripHtmlTags();
                                                    eBProObj3.Project_Status_del__c= 'On Hold - Leadership';
                                                    update eBProObj3;
                                                    UpdatePSPs(eBProObj3.Id); 
                                                    StoreStatusInLogsWarehouse(eBProObj3.Id,'Success',htmlBody.stripHtmlTags());
                                                    // Send an email to Leadership informing about the duplicate links.
                                                    EBSurveyNotificationEmail sendEmailToLeadership = new EBSurveyNotificationEmail();
                                                    sendEmailToLeadership.sendEbProjectDuplicateLinkUsageInfo(eBProObj3);
                                                    break;
                                                }                                    
                                            }
                                        } 
                                    }
                                }                        
                            }
                        }catch(Exception exp){
                            String exceptionBody = exp.getMessage()+'\n\n\n'+surveyInformation;
                            // Create a LogsWarehouse Object for the exception.
                            if(ebProjId != null)
                                StoreStatusInLogsWarehouse(ebProjId,'Failed',exceptionBody);
                            result.success = false;
                            // Return the result for the Apex Email Service
                            return result;    
                        }
                    }                   
                }
                result.success = true; 
                return result;
            }
    
    // Creating a logs warehouse object for storing email service logs.
    public static void StoreStatusInLogsWarehouse(Id ebProjectId,String reqStatus,String reqBody){        
        // Create new record in Logs WareHouse.
        LogsWarehouse__c newRec = new LogsWarehouse__c();
        newRec.Service_Name__c = 'Event Builder - Email Service';
        newRec.Record_Id__c = ebProjectId;
        newRec.Status__c = reqStatus;
        newRec.Error_description__c = reqBody;
        insert newRec;            
    }
    
    public static void UpdatePSPs(Id ebProjectId){        
        // Query used to fetch the PSP Id.
        EB_SB_Builder__c eBProObj = [Select Id,Response_Number__c,Project_Type_del__c,PSP_ID__c From EB_SB_Builder__c Where Id =:ebProjectId];        
        // Query used to fetch the PSP record which will be updated by the new Count.
        Professional_Services_Project__c currentYearPSP = [Select Id,of_EB_Used__c From Professional_Services_Project__c where Id =:eBProObj.PSP_ID__c];
        if(currentYearPSP.of_EB_Used__c != null){
            currentYearPSP.of_EB_Used__c += 1;
        }else{
            currentYearPSP.of_EB_Used__c = 1;
        }         
        try{
            // Update existing PSP record.
            update currentYearPSP;            
        }catch(Exception exp){
            system.debug('Exception in Update Future Method'+exp.getMessage());
        }
    }
}