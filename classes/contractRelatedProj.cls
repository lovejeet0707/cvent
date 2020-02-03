public class contractRelatedProj {
       
    public Project__c relatedProj{get;set;}
    public String ContractId{get;set;}
    public boolean checklist{get;set;}
    
    public contractRelatedProj(ApexPages.StandardController controller) {
        ContractId = ApexPages.currentPage().getParameters().get('id');
        relatedProj = new Project__c();
        checklist=false;
        relatedProj();
    }
    public Project__c relatedProj(){
       ID proId = [Select Project_Name__c from Contract where id =: ContractId].Project_Name__c;
       system.debug('@@@@@Opp Id: '+proId);
       relatedProj = [Select Vendor_Name__c,Product_Name__c,Product_Type__c,Vendor_Website__c,Vendor_Contact_Name__c,Vendor_Contact_Phone__c,Vendor_Contact_Email__c
                      FROM Project__c where id =: proId];
       checklist = true;
       return relatedProj;
    }   
}