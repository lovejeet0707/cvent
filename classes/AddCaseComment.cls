global with sharing class AddCaseComment {
    public String errMessage {get;set;}
    public CaseComment cc { get; private set; }
    
    public string CommentBody{get;set;}
    public string ccId{get;set;}
    public AddCaseComment(){
      errMessage = '';
      ccId=Apexpages.currentPage().getParameters().get('ccId');
      if(ccId !=null && String.isNotBlank(ccId)){
          Case caseRec = [SELECT Contact_Name_Text__c,Owner_Name__c,Owner.Name FROM Case WHERE Id =:ccId];
           if(ApexPages.currentPage().getParameters().containsKey('authorization') && Apexpages.currentPage().getParameters().get('authorization') == 'yes')
           {
               String commentValue = 'I, '+caseRec.Contact_Name_Text__c+', authorize '+caseRec.Owner.Name+' to make the changes outlined below.\n\n[HIGH-LEVEL DESCRIPTION OF CHANGE. INCLUDE THE EVENT, SURVEY, OR CAMPAIGN NAME] - \n\nThank you,\n'+caseRec.Contact_Name_Text__c;
               CommentBody = commentValue;
           }
           
       }
     if(ccId==null || ccId == ''){
      errMessage = 'Case reference missing.';
     }        
    }
    
    /*public PageReference Cancel() { 
      string caseId=ApexPages.currentPage().getParameters().get('ccid');
      PageReference pageRef = new PageReference('/apex/CaseDetail?id='+caseId);
      pageRef.setRedirect(true);
     return (pageRef);      
    }*/
    public PageReference submitComment(){
        cc=new CaseComment(ParentId=ccId,CommentBody=CommentBody,isPublished=true);
        upsert cc;
        
        PageReference pageRef;
        pageRef = new PageReference('/apex/CaseDetail?id='+ccId);
        return pageRef;
    }
    
    // Method to display case comments added by Harshit Johar for TICCM-1402
    public List<CaseComment> getCaseComments() {
        return ([SELECT CommentBody,CreatedById,CreatedBy.Name,CreatedDate,Id,IsDeleted,IsPublished,LastModifiedById,LastModifiedDate,ParentId,SystemModstamp FROM CaseComment WHERE IsPublished=true and ParentId=:ccId ORDER BY CreatedDate DESC]);
    }
    
    public PageReference SubmitComments(){
      PageReference pageRef;      
      errMessage = '';
      try{
        if(ccId != null){
          if(CommentBody == null || CommentBody == ''){
            errMessage = 'Please enter comments to submit.';
          }           
          else{
            cc=new CaseComment(ParentId=ccId,CommentBody=CommentBody,isPublished=true);
            upsert cc;
          }
        }
        else{
          errMessage = 'Case reference missing.';
        }
      }
      catch (Exception e){
      errMessage = e.getMessage();           
     }
     
     if(errMessage == ''){
      pageRef = new PageReference('/apex/CaseDetail?id='+ccId);
     }
     else{
       pageRef = null;
     }
     
     return pageRef;            
    }
    
    @RemoteAction
    global static void updaeComment(String CommentBody,String ccId) {
        CaseComment cc=new CaseComment(ParentId=ccId,CommentBody=CommentBody,isPublished=true);
        upsert cc;
    }
}