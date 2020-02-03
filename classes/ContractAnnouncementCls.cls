public class ContractAnnouncementCls {
    public Contract instContr;
    public Boolean warning{get;set;}
    public Boolean success{get;set;}
    public Boolean notNeeded{get;set;}
    public String errorMSG{get;set;}
    public String errorMSGSec{get;set;}
    public String errorMSGThir{get;set;}
    public String errorMSGFor{get;set;}
    public String errorMSGFif{get;set;}
    public ContractAnnouncementCls(ApexPages.StandardController controller) {
        warning = false;
        success = false;
        notNeeded = false;
        this.instContr = (Contract)controller.getRecord();
        system.debug(instContr.Id);
        system.debug(instContr.Id);
        instContr = [SELECT ID,Security_Review_Required__c,Document_Type__c,status,Product_Enhancement__c,Legal_Review_Required__c,SLA_Type__c,Finance_Review_Required__c,SLA_Tech_Review_Required__c,Is_there_an_information_security_review__c  FROM Contract WHERE Id=:instContr.Id];
        //if((instContr.Security_Review_Required__c=='Yes' || instContr.Legal_Review_Required__c == 'Yes' || instContr.Finance_Review_Required__c=='Yes' || instContr.SLA_Tech_Review_Required__c=='Yes') && instContr.status=='Waiting for Documents'){
        if(instContr.status=='Waiting for Documents'){
            if(instContr.status=='Waiting for Documents' && (instContr.Document_Type__c == 'Cvent Modified Terms' || instContr.Document_Type__c == 'Customer Terms' || instContr.Document_Type__c == 'Upsell – Review Required'||  instContr.Document_Type__c == 'Amendment for Existing Agreement')){
                errorMSG = '* Contract indicates document type of “Cvent Modified Terms” or “Customer Terms” or "Upsell – Review Required" or "Amendment for Existing Agreement" – please attach these terms under Notes & Attachments below.';
                warning = true;
            }
            if(instContr.status=='Waiting for Documents' && (instContr.Is_there_an_information_security_review__c == 'Yes')){
                errorMSGSec = '* Please attach security questionnaire (filled out if Cvent information security team already submitted it, otherwise the blank form) and any security attachment or equivalent contract document, if any, to the Contract under Notes & Attachments.';
                warning = true;
            }
            if(instContr.status =='Waiting for Documents' && (instContr.SLA_Type__c == 'Nonstandard SLA')){
                errorMSGThir = '* Contract indicates SLA type is “nonstandard” – please attach the nonstandard SLA under Notes & Attachments below (and/or describe any nonstandard provisions in the SLA/Tech Review comments.';
                warning = true;
            }
            if(instContr.status =='Waiting for Documents' && (instContr.Finance_Review_Required__c == 'Yes')){
                errorMSGFor = '* You must insert or describe the special payment terms in the Finance Review Comments, and attach the Order Form containing the special payment terms to the Contract under Notes & Attachments (so that the Finance team can review and approve).';
                warning = true;
            }
            if(instContr.status =='Waiting for Documents' && (instContr.Product_Enhancement__c == 'Yes')){
                errorMSGFif = '* Contract indicates that a product enhancement is required – please attach a description of the product enhancement under Notes & Attachments below (and/or describe the product enhancement in the Product Enhancement comments.';
                warning = true;
            }
        }else if(instContr.status!='Waiting for Documents' && (instContr.Security_Review_Required__c=='Yes' || instContr.Legal_Review_Required__c == 'Yes' || instContr.Finance_Review_Required__c=='Yes' || instContr.SLA_Tech_Review_Required__c=='Yes')){
            //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Confirm,'Thanks for attaching the document');
            //ApexPages.addMessage(myMsg);
            success = true;
        }else if(instContr.Security_Review_Required__c!='Yes' && instContr.Legal_Review_Required__c != 'Yes' || instContr.Finance_Review_Required__c!='Yes' || instContr.SLA_Tech_Review_Required__c!='Yes'){
            //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'No Document Needed');
            //ApexPages.addMessage(myMsg);
            notNeeded = true;
        }
    }

}