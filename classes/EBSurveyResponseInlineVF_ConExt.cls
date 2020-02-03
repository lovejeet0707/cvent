/*Author: Sandeep Kumar
* Date: 12 April 2017
* Description: Update Pending Hrs for Project Completion. 
* Test Class : EBSurveyResponseInlineVF_ConExt_Test
* VF - EBSurveyResponseInlineVF_Page
*/
public class EBSurveyResponseInlineVF_ConExt {
    public List<WrapperSurvey> WrapperSurveyList {get;set;}
    public List<Note> showSurveyAttachmentList{get;set;}
    public EB_SB_Builder__c eBProjectObj{get;set;}
    public Id eBProjectId {get;set;}
    public Boolean showSurveyResponse {get;set;}
    public Boolean hideButtonFlag {get;set;}
    public Boolean showAttachmentSection {get;set;}
    private Boolean getAnswer;
    private String surveyQuestion;
    private String surveyAnswer;
    public string eBProjId;    
    
    public class WrapperSurvey{
        public String surveyQuestion {get;set;}
        public String surveyAnswer {get;set;}    
        public WrapperSurvey(String surveyQuestion, String surveyAnswer){
            this.surveyQuestion = surveyQuestion;
            this.surveyAnswer = surveyAnswer;
        }
    }
    
    public EBSurveyResponseInlineVF_ConExt(ApexPages.StandardController controller){
        eBProjId = apexpages.currentpage().getparameters().get('id');        
        String hideButton = apexpages.currentpage().getparameters().get('hideButton');
        showSurveyAttachmentList = new List<Note>();
        showAttachmentSection = false;
        if(hideButton == null){
            hideButtonFlag = true;
        }else{
            hideButtonFlag = Boolean.valueOf(apexpages.currentpage().getparameters().get('hideButton'));
            hideButtonFlag = false;
        }
        if(eBProjId != null){
            eBProjectObj = [Select Id,Survey_Feedback__c,Name From EB_SB_Builder__c Where Id =:eBProjId];
            showSurveyAttachmentList = [Select Id,Title,Body from Note where ParentId =:eBProjId];
            if(showSurveyAttachmentList.size() > 0){
                this.showAttachmentSection = true;
            }
            eBProjectId = eBProjectObj.Id;
            // Instantiate Wrapper class before filling it.
            WrapperSurveyList = new List<WrapperSurvey>();
            if(eBProjectObj.Survey_Feedback__c != null){
                if(eBProjectObj.Survey_Feedback__c.contains('Question:') && eBProjectObj.Survey_Feedback__c.contains('Your Answer:')){
                    // Parse the response and add them as question and answer in the wrapper class.
                    for(String surveyRec : eBProjectObj.Survey_Feedback__c.split('Question: ')){
                        surveyQuestion = surveyRec.substringBefore('Your Answer:');
                        surveyAnswer = surveyRec.substringAfter('Your Answer:');
                        if(surveyAnswer.contains('please respond to this email or give us a call on the numbers below')){
                            surveyAnswer = surveyAnswer.substringBefore('If you have questions before your Kick-Off call');
                        }
                        system.debug(surveyQuestion.trim()+'======='+surveyAnswer.trim()+'================'+surveyAnswer.length());
                        if(!surveyQuestion.contains('Your Answers') && surveyAnswer.length() != 5){
                            WrapperSurveyList.add(new WrapperSurvey(surveyQuestion.trim(),surveyAnswer.trim()));                    
                        }
                    }
                    showSurveyResponse = true;
                }else{
                    // Parse the response and add them as question and answer in the wrapper class.
                    for(String surveyRec : eBProjectObj.Survey_Feedback__c.split('\n\n')){
                        showSurveyResponse = true;
                        getAnswer = false;
                        surveyQuestion = '';
                        surveyAnswer = '';
                        for(String res : surveyRec.split('#')){
                            if(!getAnswer){
                                surveyQuestion = res.trim();
                                getAnswer = true;
                            }else{
                                surveyAnswer = res.trim();                                
                            }                
                        }
                        system.debug(surveyQuestion+'========================'+surveyAnswer);
                        WrapperSurveyList.add(new WrapperSurvey(surveyQuestion,surveyAnswer));
                    }
                    showSurveyResponse = true;
                }                
            }            
        }        
    }
    
    public PageReference SaveAsAttachment(){        
        try{
            Blob docItem;
            String attachmentName = eBProjectObj.Name+' EB Form';
            Integer eBForm = [SELECT Count() FROM Attachment Where Name =:attachmentName];
            system.debug('SaveAsAttachment'+eBForm);
            if(eBForm == 0){
                PageReference Pg = Page.EBSurveyResponseDownload_Page;
                if(!Test.isRunningTest()){
                    docItem = pg.getcontent();
                }else{
                    docItem = Blob.valueOf('Some Text'); 
                }                
                system.debug('SaveAsAttachment = docItem'+docItem);
                Attachment attach = new Attachment();
                attach.Body = docItem;
                // add the user entered name
                attach.Name = eBProjectObj.Name+' EB Form';
                // attach the pdf to the account
                attach.ParentId = Id.valueOf(eBProjId);
                attach.ContentType = 'application/vnd.msword';
                insert attach;
            }                
            return null; 
        }Catch(Exception exp){
            system.debug('Exception = '+exp.getMessage());
        } 
        return null; 
    }    
}