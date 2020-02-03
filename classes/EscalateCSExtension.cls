public with sharing class EscalateCSExtension {
    string CaseNrt;
    public Final Case caseObj{get;set;}
    public EscalateCSExtension(ApexPages.StandardController controller) {
        Case temp = (Case)controller.getRecord();
        CaseNrt = temp.id;
        if(String.isNotBlank(CaseNrt))
        caseObj=[SELECT CaseNumber,AccountId,ContactId,CC_Email_To__c,Escalation_Reason__c,External_Escalation__c,Esclated_Date__c,Escalation_Comments__c FROM Case WHERE Id =:CaseNrt];
    }
    public pageReference save()
    {
        //caseObj.Esclated_Date__c=system.today();
        caseObj.External_Escalation__c=true;
        update caseObj;
        PageReference pageRef = new PageReference('/'+CaseNrt);
        return pageRef;
    }
    public pageReference cancel()
    {
        PageReference pageRef = new PageReference('/'+CaseNrt);
        return pageRef;
    }
}