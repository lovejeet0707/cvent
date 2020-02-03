public class CaseAddAttachmentController {//with sharing 
    private Transient Attachment oAttachment;
    public Attachment getAttachment() {
        if( oAttachment == null){
            oAttachment = new Attachment();
        }   
        return oAttachment;
    }
    public void setAttachment(Attachment att) {
        oAttachment = att; 
    }
    public list<Attachment> lstAttachment {get;set;}
    public Case oCase {get;set;}
    public String errMessage {get;set;}
    public CaseAddAttachmentController(){
        errMessage = '';
        String caseId = '';
        caseId = System.currentPagereference().getParameters().get('caseid');
        System.debug('caseId********'+caseId);
        if(String.IsNotBlank(caseId)){
            for(Case c :[Select Id,CaseNumber From Case Where Id =:caseId limit 1]){
                oCase = c;
            }
            System.debug('oCase********'+oCase);
            if(oCase == null){
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid case reference'));
                errMessage = 'Invalid case reference';
            }
            else{
                fetchAttachments();
            }
        }
        else{
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Case reference missing'));
            errMessage = 'Case reference missing';
        }
    }
    private void fetchAttachments(){
        lstAttachment = new list<Attachment>();
        for(Attachment a:[Select Id,Name From Attachment Where ParentId=:oCase.Id]){
            lstAttachment.add(a); 
        }
    }

    public Pagereference upload(){
        errMessage = '';
        try{
            System.debug('@Developer --> oAttachment' + oAttachment);
            System.debug('@Developer --> oAttachment' + oAttachment.Body);
            System.debug('@Developer --> oAttachment' + oAttachment.Name);
            System.debug('@Developer --> oCase.Id' + oCase.Id);
            oAttachment.ParentId = oCase.Id;
            insert oAttachment;
            fetchAttachments();
        }
        catch(Exception ex){
            System.debug('ex****'+ex);
            errMessage = ex.getMessage();
        }
        String url = '/apex/CaseAddAttachment?caseid='+oCase.Id;
        PageReference pageRef = new PageReference(url);
        pageRef.setRedirect(true);
        return pageRef;
    }
    public PageReference done(){   
        PageReference pr = null;
        pr = new PageReference((site.getPathPrefix()!= null?site.getPathPrefix():'') + '/apex/caseDetail?id='+ oCase.Id);
        return pr;
    }
}