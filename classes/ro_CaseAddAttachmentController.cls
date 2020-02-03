public class ro_CaseAddAttachmentController {//with sharing 
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
    public ro_CaseAddAttachmentController(){
        System.debug('@Developer --> ro_CaseAddAttachmentController');
        errMessage = '';
        String caseId = '';
        caseId = System.currentPagereference().getParameters().get('caseid');
        System.debug('caseId********'+caseId);
        if(String.IsNotBlank(caseId)){
            System.debug('Inside If');
            System.debug('Query Result***'+[Select Id,CaseNumber From Case Where Id =:caseId limit 1]);
            System.debug('Query Result New***'+[Select Id,CaseNumber From Case limit 1]);
            for(Case c :[Select Id,CaseNumber From Case Where Id =:caseId limit 1]){
                System.debug('Inside query***'+c);
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
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ''));
            errMessage = ex.getMessage();
        }
        return null;
    }
    public PageReference done(){   
        PageReference pr = null;
        pr = new PageReference((site.getPathPrefix()!= null?site.getPathPrefix():'') + '/apex/ro_caseDetail?id='+ oCase.Id);
        return pr;
    }
}