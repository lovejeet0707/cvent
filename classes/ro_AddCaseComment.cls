public with sharing class ro_AddCaseComment {
    public String errMessage {get;set;}
    public CaseComment cc { get; private set; }
    
    public string CommentBody{get;set;}
    public ro_AddCaseComment(){
    	errMessage = '';
     string ccId=Apexpages.currentPage().getParameters().get('ccId');
            
     if(ccId==null || ccId == ''){
      errMessage = 'Case reference missing.';
     }        
    }
    
    public PageReference Cancel() { 
	    string caseId=ApexPages.currentPage().getParameters().get('ccid');
	    PageReference pageRef = new PageReference('/apex/ro_CaseDetail?id='+caseId);
     return (pageRef);      
    }
    
    public PageReference SubmitComment(){
    	string ccId=ApexPages.currentPage().getParameters().get('ccId');        
     System.debug('@Developer -->ccId:' + ccId);
    	System.debug('@Developer -->CommentBody:' + CommentBody);
    	
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
      pageRef = new PageReference('/apex/ro_CaseDetail?id='+ccId);
     }
     else{
     	pageRef = null;
     }
     
     return pageRef;            
    }
}