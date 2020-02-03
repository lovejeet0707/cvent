public class SupportPage_Controller {
    public List<Case> caseList;
    public String caseJSONString{get;set;}
    public String searchText{get;set;}
    public String selectedProduct{get;set;}
    Id loggedInUserId;
    public Boolean isInternalUser{get;set;}
    public SupportPage_Controller(){
        caseList = new List<Case>(); 
        loggedInUserId = UserInfo.getUserId();
        User communityUserRec = [SELECT Id,ContactId,Name,Email,account.Name,account.AccountNumber FROM User WHERE Id = : loggedInUserId];
        //Validate if the user is Internal or External....
        String userEmailDomain = communityUserRec.Email.substringAfterLast('@');
        if(userEmailDomain.containsIgnoreCase('Cvent') || userEmailDomain.containsIgnoreCase('Inquisium') || userEmailDomain.containsIgnoreCase('CC') || userEmailDomain.containsIgnoreCase('Lanyon') || (String.isNotBlank(communityUserRec.account.Name) && communityUserRec.account.Name.containsIgnoreCase('CVENT') )|| (String.isNotBlank(communityUserRec.account.Name) && communityUserRec.account.Name.containsIgnoreCase('TEST')) || (String.isNotBlank(communityUserRec.account.AccountNumber) && communityUserRec.account.AccountNumber.containsIgnoreCase('CVT')))
        {
            isInternalUser = true;
        }
        //Ends Here...

        Id contactId = communityUserRec.ContactId;
        Set<Id> recordTypeId = new Set<Id>();        
        For(String recordTypeName : Cvent_Community_Record_Types__c.getAll().keySet())
        {
            recordTypeId.add(Schema.SObjectType.Case.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId());    
        }
        System.debug('*******'+recordTypeId);
        /*recordTypeId.add(Schema.SObjectType.Case.getRecordTypeInfosByName().get('New Event').getRecordTypeId());
        recordTypeId.add(Schema.SObjectType.Case.getRecordTypeInfosByName().get('New CrowdCompass').getRecordTypeId());
        recordTypeId.add(Schema.SObjectType.Case.getRecordTypeInfosByName().get('New CSN-Planner').getRecordTypeId());
        recordTypeId.add(Schema.SObjectType.Case.getRecordTypeInfosByName().get('New CSN-Supplier').getRecordTypeId());
        recordTypeId.add(Schema.SObjectType.Case.getRecordTypeInfosByName().get('New eMarketing').getRecordTypeId());
        recordTypeId.add(Schema.SObjectType.Case.getRecordTypeInfosByName().get('New Inquisium').getRecordTypeId());
        recordTypeId.add(Schema.SObjectType.Case.getRecordTypeInfosByName().get('Closed').getRecordTypeId());
        */
        
        
        String caseQuery ;//CreatedById =:loggedInUserId OR 
        Id CSCaseQueueDeleteId;
        For(Group groupRec : [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Client_Services_Case_Queue_for_Delete']){
            CSCaseQueueDeleteId = groupRec.Id;
        }
        
        if(contactId!=null){
            caseQuery = 'SELECT Id,CaseNumber,RecordType.DeveloperName,Subject,Status,CreatedDate FROM Case WHERE Client_Services_Category__c != \'Web Design Support\' AND Case_Status_L2__c != \'Forwarded to Sales\' AND RecordTypeId IN:recordTypeId AND ContactId =:contactId ';
            System.debug('Inside This out');
            if(CSCaseQueueDeleteId!=null){
                System.debug('Inside This');
                caseQuery = caseQuery + ' AND OwnerId != :CSCaseQueueDeleteId';
            }
            caseQuery = caseQuery +  ' ORDER BY CreatedDate DESC';
        }
        else{ 
            caseQuery = 'SELECT Id,CaseNumber,RecordType.DeveloperName,Subject,Status,CreatedDate FROM Case WHERE Client_Services_Category__c != \'Web Design Support\' AND Case_Status_L2__c != \'Forwarded to Sales\' AND RecordTypeId IN:recordTypeId AND CreatedById =:loggedInUserId ';
            if(CSCaseQueueDeleteId!=null)
                caseQuery = caseQuery + ' AND OwnerId != :CSCaseQueueDeleteId';
            caseQuery = caseQuery +  ' ORDER BY CreatedDate DESC';
        }
        System.debug('*************8'+caseQuery);
        For(Case caseRec : Database.query(caseQuery))
        {
            if(caseList.size()<=1000)
                caseList.add(caseRec);
            else
                break;
        }
        
        caseJSONString = JSON.serialize(caseList);
    }
    public PageReference createTracker(){
        Case_Deflection_Track__c caseDeflectTrack = new Case_Deflection_Track__c();
        caseDeflectTrack.User_Id__c = UserInfo.getUserId();
        caseDeflectTrack.User_Name__c = UserInfo.getUserName();
        caseDeflectTrack.New_Case_Click__c = 1;
        insert caseDeflectTrack;
        
        String urlRedirect = '/apex/FindHelp?id='+caseDeflectTrack.Id;
        PageReference pr = new PageReference(urlRedirect);
        pr.setRedirect(true);
        return pr;

        //caseList = [SELECT Id,CaseNumber,Subject,Status,CreatedDate FROM Case WHERE CreatedById =:loggedInUserId LIMIT 10000];
        //caseJSONString = JSON.serialize(caseList);
    }
}