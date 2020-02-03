/*** Test Class : GDPRCaseFollowUpTest ***/
public class GDPRCaseFollowUpClass{
    
    private final Case CaseFollowUp;
    private final Id CaseFollowUpId;
    public List<GDPR_Case_Follow_Up__c> gdprFollowUpList{get;set;}
    public Boolean isEdit{get;set;}
    public GDPRCaseFollowUpClass(ApexPages.StandardController controller) {
        isEdit = False;
        gdprFollowUpList = new List<GDPR_Case_Follow_Up__c>();
        //Fetching Coaching Form Parent Record.........
        CaseFollowUp = (Case)controller.getRecord();
        //Fetching Coaching Form Parent Id.........
        CaseFollowUpId = CaseFollowUp.Id;
        
        gdprFollowUpList = [SELECT Id,Action__c,Case__c,Email_Sent__c,
                                            Response_Received__c,Vendor__c FROM GDPR_Case_Follow_Up__c
                                                    WHERE Case__c =:CaseFollowUpId];
    }
    public void editGDPRRecords(){
        isEdit = TRUE;
    }
    public PageReference saveGDPRRecords(){
        update gdprFollowUpList;
        isEdit = FALSE;
        PageReference nextPage = new PageReference('/' + CaseFollowUpId);
        return nextPage;
    }
    public PageReference Cancel(){
      isEdit = FALSE;
      PageReference nextPage = new PageReference('/' + CaseFollowUpId);
      return nextPage;
    }
}