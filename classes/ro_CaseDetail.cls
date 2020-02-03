public without sharing class ro_CaseDetail {      
    //public String rType {get; set;}
    //public Id id{get; set;}
    //public String cancelURL {get; set;}
    //public String accountID {get; set;}
    //public String contactID {get; set;}
    //public String UserType {get; set;}    
    //public Boolean error {get; set;}
    public boolean showCloseCase{get;set;}
    public boolean showAddButton{get;set;}   
    public Case c { get; private set; }
    
    //public CaseComment cc { get; private set; }
    public PageReference pageRef = ApexPages.currentPage();
    //public List<Attachment> CaseAttachments{get;set;}        
    //public String Priority {get;set;}
    //public String aId{get;set;}
    //public String Status {get;set;}
    //public String Origin {get;set;} 
    //public String Family {get;set;}
    //public String Module {get;set;}
    //public List<CaseComment> lstCaseComments{get;set;}      
    public List<EmailMessage> getEmails{get;set;}                             
    public List<KnowledgeArticleVersion> kav {get;set;}
    public transient List<CaseArticle> carList {get;set;}
    //public Contact contact {get;set;}
    
    public map<String,String> mapEmailMessageStatus {get;set;}
    
    public Boolean isSite {get;set;}
        
    private String caseId;
    
    public ro_CaseDetail(){
        System.debug('@Developer --> ro_CaseDetail');
        isSite = ro_ConfigHelper.self.isSite;

        mapEmailMessageStatus = new map<String,String>();
        mapEmailMessageStatus.put('0','New');
        mapEmailMessageStatus.put('1','Read');
        mapEmailMessageStatus.put('2','Replied');
        mapEmailMessageStatus.put('3','Sent');
        mapEmailMessageStatus.put('4','Forwarded');
        mapEmailMessageStatus.put('5','Draft');
        
        caseId = ApexPages.currentPage().getParameters().get('id');
        System.debug('CaseId************************'+caseId);
        c = [SELECT 
             CaseNumber,Account__c,ContactId,Priority,Origin,Product_Family__c,Product_Family_Name__c,Reason,CreatedDate,
             Status,ownerid,Customer_Impact__c,Product_Module__c,Subject,Description,Contact.Name,
             Contact.Email,Contact.Phone,Contact_Phone_Extension__c,AccountId,Account.Name, ClosedDate
             FROM Case 
             WHERE Id = :caseId];
        System.debug('Case ************************'+c);
        if(c != Null && (c.Status != 'Closed' && c.Status != 'Re-Close')){
            showCloseCase = true;
        }else{
            showCloseCase = false;
        }
        
        showAddButton = false;
        
        if(c != Null){
            System.debug('#Checkpoint');
            if(c.Status != 'Closed' && c.Status != 'Re-Close'){
                showAddButton = true;
            System.debug('#Checkpoint 1');
            }
            else{ // status is either closed or re-close
                System.debug('#Checkpoint else');
                if(System.today() <= c.ClosedDate.addDays(2)){
                    System.debug('#Checkpoint else 1');
                    showAddButton = true;
                }
            } 
        }
        
        string soql='';
        
        //Display Case Articles Attached.  || November Release Item ||        
        Map<Id,String> csArtIdMap = new Map<Id,String>();
        carList = new List<CaseArticle>([SELECT KnowledgeArticleId FROM CaseArticle WHERE CaseId=:caseId ]);      
        for(CaseArticle car : carList) {
            if(!csArtIdMap.containsKey(car.KnowledgeArticleId))
                csArtIdMap.put(car.KnowledgeArticleId,'Name');
        }
        try {
            kav= new List<KnowledgeArticleVersion>([SELECT KnowledgeArticleId,Title FROM KnowledgeArticleVersion WHERE KnowledgeArticleId IN :csArtIdMap.Keyset() AND PublishStatus = 'Online']); 
            //kav=Database.query(soql);
        } catch (Exception e) 
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Sorry! Error in querying Attachments.'));              
        }
    }
    
    // Get Methods for displaying Case Related Lists.
    public List<CaseComment> getCaseComments() {
           
        return ([SELECT CommentBody,CreatedById,CreatedBy.Name,CreatedDate,Id,IsDeleted,IsPublished,LastModifiedById,LastModifiedDate,ParentId,SystemModstamp FROM CaseComment WHERE IsPublished=true and ParentId=:caseId ORDER BY CreatedDate DESC]);
    }
    
    public List<Attachment> getAttachments() {
        System.debug('@Developer --> getAttachments');
           
        return ([SELECT CreatedById,CreatedBy.Name,CreatedDate,Id,Name FROM Attachment WHERE ParentId =: caseId ORDER BY CreatedDate DESC]);
    }
    
    public List<KnowledgeArticleVersion> getKav() {
           
        Map<Id,String> csArtIdMap = new Map<Id,String>();
        carList = new List<CaseArticle>([SELECT KnowledgeArticleId FROM CaseArticle WHERE CaseId=:caseId ]);      
        for(CaseArticle car : carList) {
            if(!csArtIdMap.containsKey(car.KnowledgeArticleId))
                csArtIdMap.put(car.KnowledgeArticleId,'Name');
        } 
        return ([SELECT KnowledgeArticleId,Title FROM KnowledgeArticleVersion WHERE KnowledgeArticleId IN :csArtIdMap.Keyset() AND PublishStatus = 'Online']);
    }
    
    public List<EmailMessage> getEmails() {
        
        return ([SELECT Id,ToAddress,Subject,Status,MessageDate,FromName,FromAddress,ParentId FROM EmailMessage WHERE ParentId=:caseId ORDER BY CreatedDate DESC]);
    }
    
    
    //Command Button to Add Case Comments
    public PageReference AddCaseComments() {
        PageReference pageRef = new PageReference((site.getPathPrefix()!= null?site.getPathPrefix():'') + '/apex/ro_AddCaseComments?ccId='+caseId);
        return (pageRef);             
    }                
    
    public PageReference closeCase()   {
        case c = [SELECT Id, Status, CaseNumber, CreatedDate, Product_Family__c,Product_Family_Name__c FROM Case WHERE Id=:caseId AND Id!=null];
        c.Status= 'Closed';
        c.Reason='Closed by Customer';
        Update c;        
        PageReference pageRef = new PageReference((site.getPathPrefix()!= null?site.getPathPrefix():'') +'/apex/ro_CaseDetail?id='+caseId);
        pageref.setredirect(true);
        return (pageRef);       
    }
    
    public PageReference done()   {
        PageReference pageRef = new PageReference((site.getPathPrefix()!= null?site.getPathPrefix():'') +'/apex/cpCaseListView?sfdc.tabName=01rJ00000000Oez');
        pageref.setredirect(true);
        return (pageRef);       
    } 
    
    public pageReference AddAttachments(){
        //https://cs22.salesforce.com/p/attach/NoteAttach?pid=50017000001esYa&parentname=00675693&retURL=%2F50017000001esYaAAI%3Fnooverride%3D1
        //pageReference PR = new PageReference('/p/attach/NoteAttach?pid='+c.Id+'&parentname='+c.CaseNumber+'&retURL=' + (site.getPathPrefix()!= null?site.getPathPrefix():'') + '/apex/ro_CaseDetail?id='+c.Id);
        pageReference PR = new pageReference((site.getPathPrefix()!= null?site.getPathPrefix():'') +'/apex/ro_CaseAddAttachment?caseid='+c.Id);
        return PR;
    }   

}