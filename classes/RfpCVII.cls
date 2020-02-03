public class RfpCVII {
    public string Url{get;set;}
    
    public RfpCVII(ApexPages.StandardController controller) {
        Rfp__c instofRfp  = [Select Id,Ofr_stub__c,RFP_Stub__c FROM RFP__C WHere Id=: ApexPages.currentPage().getParameters().get('id')];
        system.debug('+++++'+instofRfp);
        Url = 'https://cvii/Suppliers/ViewRFPDetails.aspx?rstub='+instofRfp.RFP_Stub__c+'&ostub='+instofRfp.Ofr_stub__c+'&searchstub=';
    }
}