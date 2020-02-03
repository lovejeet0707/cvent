public class AppSupportQueriesClass{
    public Map<String,String> escalatedTopicVsGuildelines{get;set;}
    public String query{get;set;}
    Public string selectedname{get;set;}
    public String suggestedGuidelines{get;set;}
    public string queryTopic{get;set;}
    private Id caseId;
    private String caseRecordType;
    public Case caseObj{get;set;}
    public Map<String,App_Support_Custom_Setting__c> fetchCustomSetting;
    //public String productType{get;set;}
    public String appSupportRecordId{get;set;}
    public AppSupportQueriesClass(ApexPages.StandardController controller) {
        fetchCustomSetting = App_Support_Custom_Setting__c.getAll();
        
        case caseRec = (Case)controller.getRecord();
        caseId = caseRec.Id;
        suggestedGuidelines = '';
        selectedname = '- None -';
        escalatedTopicVsGuildelines = new Map<String,String>();
        caseObj = [SELECT Id,Event_Type_New__c,AccountId,RecordTypeId,RecordType.DeveloperName FROM Case WHERE Id = : caseId];
        //productType = fetchCustomSetting.get(caseObj.RecordType.DeveloperName).Product_Type__c;
        System.debug('caseObj.RecordType.DeveloperName***********'+caseObj.RecordType.DeveloperName);
        System.debug('fetchCustomSetting*********'+fetchCustomSetting);
        System.debug('fetchCustomSetting*********'+fetchCustomSetting.get(caseObj.RecordType.DeveloperName));
        appSupportRecordId = fetchCustomSetting.get(caseObj.RecordType.DeveloperName).App_Support_Case_Record_Type__c;

        query = 'SELECT Id,Case_Record_Type__c,Case_Submission_Guidelines__c,Escalated_Topic__c FROM App_Support_Question__c WHERE Case_Record_Type__c ='+'\''+caseObj.RecordType.DeveloperName+'\'';
        System.debug('*************'+query);
        escalatedTopicVsGuildelines.put('- None -','');
        For(App_Support_Question__c appSupRec : Database.query(query)){
            escalatedTopicVsGuildelines.put(appSupRec.Escalated_Topic__c,appSupRec.Case_Submission_Guidelines__c);    
        }
        
        System.debug('escalatedTopicVsGuildelines*************'+escalatedTopicVsGuildelines.keySet().size());

    }
    Public List<Selectoption> getSelectedEscalatedTopic(){
        
        List<Selectoption> lstnamesel = new List<selectoption>();
        //lstnamesel.add(new selectOption('', '- None -'));
        for(String escalatedTopic :escalatedTopicVsGuildelines.keySet()){
            lstnamesel.add(new selectoption(escalatedTopic,escalatedTopic));
        }
        System.debug('selectedname********'+selectedname);
        return lstnamesel; 
    }
    public void findSuggestions(){
        System.debug('queryTopic*****'+queryTopic);
        System.debug('escalatedTopicVsGuildelines*****'+escalatedTopicVsGuildelines);
        System.debug('suggestedGuidelines*****'+suggestedGuidelines);
        suggestedGuidelines = escalatedTopicVsGuildelines.get(selectedname);
    }
}