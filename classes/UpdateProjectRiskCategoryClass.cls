/*HSR : P-004391 : Updating Project Rick Category on basis of below condition : - 
***************************************
1. Service Tier: 
This field will pick values from Service tier field at Account level. The field has below values 

* Bronze 
* Silver 
* Gold 
* Platinum 

1. Risk Factor: 

* Active ARA is checked at Account Level for the Account associated to EB/SB Project 
* ARA/Escalation object count >0 for the Account associated to EB/SB Project. 
* If any EB SB project on the account has a VDSAT or DSAT 
* External Escalation on EB SB project = True 
* Value in Project health field on EB SB Project = Red 


1. Final Calculation: 

* Value “High Dollar Value High Risk”: If 1 or more Risk Factors + Gold or Platinum Service Tier 
* Value “Low Dollar Value High Risk”: If 1 or more Risk Factor + Bronze or Silver Service Tier 
* Value “High Dollar Value Low Risk”: If No risk factor + Gold or Platinum Service Tier 
* Value “Low Dollar Value Low Risk: If No risk factor + Bronze of Silver Service Tier 
********************************
*/
public class UpdateProjectRiskCategoryClass{
    //This method is called from EBSB Trigger when "External Escalation"/"Project health" field is updated
    public static void UpdateProjectRiskCategory(List<EB_SB_Builder__c> EBSBRecList){
        //Variable initialization...........
        Map<Id,EB_SB_Builder__c> EBSBIdVsEBSBObjectMap = new Map<Id,EB_SB_Builder__c>();
        Map<Id,Integer> EBSBIdVsRiskFactorCountMap = new Map<Id,Integer>();
        Set<Id> accountIdSet = new Set<Id>();
        Map<Id,Set<Id>> AccountIdVsEBSBSetIdMap = new Map<Id,Set<Id>>();
        Set<Id> EBSBIdSet = new Set<Id>();
        
        Map<Id,Integer> accountIdVsVDSATCount = new Map<Id,Integer>();
        For(EB_SB_Builder__c EBSBRec : EBSBRecList)
        {
            if(EBSBRec.AccountCustom__c!=null){
                if(!AccountIdVsEBSBSetIdMap.containsKey(EBSBRec.AccountCustom__c)){
                    EBSBIdSet = new Set<Id>();
                    EBSBIdSet.add(EBSBRec.Id);
                    AccountIdVsEBSBSetIdMap.put(EBSBRec.AccountCustom__c,EBSBIdSet);
                }
                else{
                    AccountIdVsEBSBSetIdMap.get(EBSBRec.AccountCustom__c).add(EBSBRec.Id);
                }
                Integer riskFactorCount = 0;
                EBSBIdVSEBSBObjectMap.put(EBSBRec.Id,EBSBRec);
                accountIdSet.add(EBSBRec.AccountCustom__c);
                EBSBIdVsRiskFactorCountMap.put(EBSBRec.Id,riskFactorCount);
                //Account Active ARA check.............
                if(EBSBRec.Account_ARA_Active__c)
                {
                    riskFactorCount = riskFactorCount + 1;
                    EBSBIdVsRiskFactorCountMap.put(EBSBRec.Id,riskFactorCount);
                }
                //Account ARA/Escalation count check.............
                if(EBSBRec.Account_ARA_Escalation_Count__c>0)
                {
                    riskFactorCount = riskFactorCount + 1;
                    EBSBIdVsRiskFactorCountMap.put(EBSBRec.Id,riskFactorCount);
                }
                //EBSB External_Escalation__c check.............
                if(EBSBRec.External_Escalation__c)
                {
                    riskFactorCount = riskFactorCount + 1;
                    EBSBIdVsRiskFactorCountMap.put(EBSBRec.Id,riskFactorCount);
                }
                //EBSB Project_Health__c check.............
                if(EBSBRec.Project_Health__c=='Red')
                {
                    riskFactorCount = riskFactorCount + 1;
                    EBSBIdVsRiskFactorCountMap.put(EBSBRec.Id,riskFactorCount);
                }
            }
        }
        System.debug('accountIdSet****'+accountIdSet);
        //EBSBIdVsRiskFactorCountMap.containsKey(surveyInfoRec.EBSB__c) && 
        For(Survey_Q__c surveyInfoRec : [SELECT Id,Account_Id__c,EBSB__c,Answere__c FROM Survey_Q__c WHERE Account_Id__c IN : accountIdSet])
        {
            Integer count = 0;
            /*if(AccountIdVsEBSBSetIdMap.containsKey(surveyInfoRec.Account_Id__c) && 
                AccountIdVsEBSBSetIdMap.get(surveyInfoRec.Account_Id__c).contains(surveyInfoRec.EBSB__c)&&
                (surveyInfoRec.Answere__c=='Dissatisfied' || surveyInfoRec.Answere__c == 'Very Dissatisfied'))
            {
                EBSBIdVsRiskFactorCountMap.put(surveyInfoRec.EBSB__c,EBSBIdVsRiskFactorCountMap.get(surveyInfoRec.EBSB__c)+1);
            }*/
            if(!accountIdVsVDSATCount.containsKey(surveyInfoRec.Account_Id__c) && 
                (surveyInfoRec.Answere__c=='Dissatisfied' || surveyInfoRec.Answere__c == 'Very Dissatisfied'))
                accountIdVsVDSATCount.put(surveyInfoRec.Account_Id__c,count+1);
        }
        System.debug('accountIdVsVDSATCount*********'+accountIdVsVDSATCount);
        For(EB_SB_Builder__c EBSBRec : EBSBRecList)
        {
            if(EBSBIdVsRiskFactorCountMap.containsKey(EBSBRec.id))
            {
                //For service tier Gold/Platinum
                if(EBSBRec.Account_Service_Tier__c == 'Gold' || EBSBRec.Account_Service_Tier__c == 'Platinum')
                {
                    //If risk factor is greater than 1
                    if(EBSBIdVsRiskFactorCountMap.get(EBSBRec.id)>=1 || accountIdVsVDSATCount.containsKey(EBSBRec.AccountCustom__c)){
                        EBSBRec.Project_Risk_Category1__c = 'High Dollar Value High Risk';
                    }
                    //If risk factor is greater equals 0
                    else{
                        EBSBRec.Project_Risk_Category1__c = 'High Dollar Value Low Risk';
                    }
                }
                //For service tier Bronze/Silver
                else if(EBSBRec.Account_Service_Tier__c == 'Bronze' || EBSBRec.Account_Service_Tier__c == 'Silver')
                {
                    //If risk factor is greater than 1
                    System.debug('EBSBIdVsRiskFactorCountMap.get(EBSBRec.id)***'+EBSBIdVsRiskFactorCountMap.get(EBSBRec.id));
                    if(EBSBIdVsRiskFactorCountMap.get(EBSBRec.id)>=1 || accountIdVsVDSATCount.containsKey(EBSBRec.AccountCustom__c)){
                        EBSBRec.Project_Risk_Category1__c = 'Low Dollar Value High Risk';
                    }
                    //If risk factor is greater equals 0
                    else{
                        EBSBRec.Project_Risk_Category1__c = 'Low Dollar Value Low Risk';
                    }
                }
            }
        }
    }
}