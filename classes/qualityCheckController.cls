public with sharing class qualityCheckController {
    
    public String quesType {get;set;}
    public String caseId {get; set;}
    public String userForId {get;set;}
    public String qcId {get;set;}
    public List<question> allQuestions {get;set;}
    public String selectedType {get;set;}
    public List<SelectOption> types;
    public String qcDoneId {get;set;}
    public Quality_Check_Done__c qcDone {get;set;}
    /*public String[] getquesType() {
        return quesType;
    }
    
    public void setquesType(String[] quesType) {
        this.quesType = quesType;
    }*/
    public qualityCheckController(ApexPages.StandardController stdController) {
        // Get url parameters
        qcId = Apexpages.currentPage().getParameters().get('id');
        qcDone = new Quality_Check_Done__c();
        system.debug('@@@@qcId: '+qcId);
        
        getallQuestions();
    }
     
    public void checkSelectedValue(){        
        system.debug('Selected value is: ' + quesType);
    } 
    
    public List<SelectOption> gettypes(){
        Schema.sObjectType sobject_type = Quality_Check_Question__c.getSObjectType();
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
        List<Schema.PicklistEntry> pick_list_values = field_map.get('Question_Type_CC__c').getDescribe().getPickListValues();
        List<selectOption> options = new List<selectOption>();
        for (Schema.PicklistEntry a : pick_list_values) {
            options.add(new selectOption(a.getLabel(), a.getValue()));
        }
        return options;  
    }
    
    public PageReference submitValues(){
        system.debug('@@@@@allQuestions : '+allQuestions);
        system.debug('@@@@@quesType: '+quesType);
        caseId = qcDone.Mobile_App__c;
        userForId = qcDone.QC_Done_For__c;
        system.debug('@@@@caseId : '+caseId);
        system.debug('@@@@userForId : '+userForId);
        List <Quality_Check_Response__c> qcrList = new List<Quality_Check_Response__c>();
        Integer counter = 0;
        String lstQues='';
        for (question q : allQuestions){
            system.debug('@@@@@@Inside the for loop');
            Quality_Check_Response__c qcr = new Quality_Check_Response__c();
            system.debug('++++++222'+q.selectedOption);
            system.debug('++++++q.questionType'+q.questionType);
            if((q.selectedOption == null || q.selectedOption == '') && quesType== q.questionType){
                system.debug('++++++'+q.selectedOption);
                lstQues = lstQues + q.question +'\n\n\n\n\n\n';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'**********Kindly complete the below questions**********'));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,q.question));
                qcr.Quality_Check_Filled_Response__c = '';
                counter++; 
            }  
        }
        //if(counter>0)
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,lstQues));
        if(counter==0){
            for (question q : allQuestions){
                if(quesType== q.questionType){
                    Quality_Check_Response__c qcr = new Quality_Check_Response__c();
                    qcr.Quality_Check_Filled_Response__c = q.singleOptions.get(Integer.valueOf(q.selectedOption)).getLabel();
                    qcr.Quality_Check_Question__c = q.Id;
                    qcr.Comments__c =  q.Comments;
                    qcrList.add(qcr);
                }
            }
        
            system.debug('@@@@@@Inside the submit method');
            if(addQCDone()){
                for(Quality_Check_Response__c qcr : qcrList){
                    qcr.Quality_Check_Done__c = qcDoneId;
                }
                if(qcrList.size()>0)
                    insert qcrList;
            }
            //PageReference pageRef = new PageReference('/apex/qcforCCDetailPage?id='+qcDoneId);
            PageReference pageRef = new PageReference('/'+qcDoneId);
            return pageRef;
        }else{
            return null;
        }
    }
    private Boolean addQCDone(){
        String userId;
        system.debug('@@@@qcId: '+qcId);
        if (qcId == null)
            return false;
        
        userId = UserInfo.getUserId();
        system.debug('@@@@userId: '+userId);
        //system.debug('@@@@qcDone.QC_Done_For__c: '+qcDone.QC_Done_For__c);
        //system.debug('@@@@qcDone.Mobile_App__c: '+qcDone.Mobile_App__c);
        List<Quality_Check_Done__c> check = [Select Mobile_App__c, QC_Done_By__c, QC_Done_For__c, Quality_Checks__c From Quality_Check_Done__c Where QC_Done_For__c=:userForId and Quality_Checks__c=:qcId and Mobile_App__c = :caseId];
           /* if(check != null && check.size()>0){
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This has already been done!!!'));
                return false;       
            }*/
        
        Quality_Check_Done__c qc = new Quality_Check_Done__c();
        qc.Mobile_App__c = qcDone.Mobile_App__c;
        qc.QC_Done_By__c = userId;
        qc.QC_Done_For__c = qcDone.QC_Done_For__c;
        qc.Quality_Checks__c = qcId;
        system.debug('@@@@qc: '+qc);
        insert qc;  
        qcDoneId = qc.Id;
        return true;    
    }
    
    @TestVisible public class question{
        public String name {get; set;}
        public String answerChoices {get; set;}
        public String question {get; set;}
        public String questionType {get; set;}
        public String id {get; set;}
        public List<SelectOption> singleOptions {get; set;}
        public List<String> strList {get; set;}
        public String singleOptionsForChart  {get; set;}
        public String selectedOption {get;set;}
        public String comments{get;set;}

        public question(Quality_Check_Question__c qc){
            name = qc.Name;
            answerChoices = qc.Answer_Choices__c;
            question = qc.Question__c;
            questionType = qc.Question_Type_CC__c;
            id = qc.id;
            this.comments = comments;
            singleOptions = stringToSelectOptions(answerChoices);
        }
        
        
        private List<SelectOption> stringToSelectOptions(String str){
            if (str == ''){
                return new List<SelectOption>();
            }
            strList = str.split('\n');
            List<SelectOption> returnVal = new List<SelectOption>();
            Integer i = 0;
            for(String s: strList){
                if (s!='') {    
                    if (s != 'null' && s!= null) {
                        String sBis = s.replace(' ', '%20');
                        singleOptionsForChart += s.trim()+'|';
                        returnVal.add(new SelectOption(String.valueOf(i),s));
                        System.debug('*****VALUES: ' + s);
                        i++;
                    }
                }
            }
            singleOptionsForChart = singleOptionsForChart.substring(0, singleOptionsForChart.length()-1);
            return returnVal;
        }
    }
    
    public List<question> getallQuestions() {
        List<Quality_Check_Question__c> allQuestionsObject = [Select id,Name,Question_Type_CC__c,Question__c,Answer_Choices__c From Quality_Check_Question__c s 
                                                              WHERE s.Quality_Checks__c =: qcId];
        allQuestions = new List<question>();
        for (Quality_Check_Question__c q : allQuestionsObject){ 
            question theQ = new question(q);
            allQuestions.add(theQ);
        }
        system.debug('allQuestions size'+allQuestions.size());
        return allQuestions;
    }
}