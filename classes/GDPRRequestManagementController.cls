//@author : udita
//created for GDPR case to either approve or reject it.....
// Test class : ScrubGDPRRepositoryClassTest
public class GDPRRequestManagementController{
    public case cs;
    public id caseID{get;set;}
    public boolean showButton{get;set;}
    public boolean showThanku{get;set;}
    public boolean showApproved{get;set;}
    public boolean showIgnored{get;set;}
    
    public GDPRRequestManagementController(){
        showButton = true;
        showApproved = false ;
        showIgnored = false;  
        caseID =  ApexPages.Currentpage().getparameters().get('caseId');   
    }
    public PageReference  approveRequest(){
        cs =[select id,Status,CreatedDate from case where id =:ApexPages.Currentpage().getparameters().get('caseId')];
        cs.Status = 'Open – Approved';
        update cs;
        showButton = false;
        showApproved = true;
        showIgnored = false;
        
        return new PageReference(Label.GDPRApprveThankYou);
    }
    public PageReference  ignoreRequest(){
        cs =[select id,Status,CreatedDate from case where id =:ApexPages.Currentpage().getparameters().get('caseId')];
        cs.Status = 'Closed  - Rejected';
        update cs;
        showButton = false;
        showApproved = false;
        showIgnored = true;
        
        return new PageReference(Label.GDPRRejectThankYou);
    }
    public void checkExpiration() {
        IF(ApexPages.Currentpage().getparameters().get('caseId') == null){
            showButton = false;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'The link you are using is either expired or invalid. Please submit a new GDPR request.')); 
        }
        IF(ApexPages.Currentpage().getparameters().get('caseId') !=NULL){
            caseID =  ApexPages.Currentpage().getparameters().get('caseId');
            cs =[select id,Status,CreatedDate from case where id =:caseID ]; 
            integer intDays =  cs.CreatedDate.Date().daysBetween(system.now().Date());

            if(cs.Status=='Closed  - Completed' || cs.Status=='Open – Approved')
            {
                showButton = false;
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'You have already used the link. For any changes please fill the GDPR form again.')); 
            }
            else if(intDays > 1){
                cs.Status = 'Closed – No Approval';
                update cs;
                showButton = false;
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'The link you are using is either expired or invalid. Please submit a new GDPR request.')); 
            }
        }
    }
}