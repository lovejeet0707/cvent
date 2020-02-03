/*
***
Author : Aparna Thapliyal
Created Date : 14th July 2017
Description : Update sthe value of Account,Contact and Opportunity
***
*/

public class ImplementationSurveyTriggerHandler{
    /*...Before Insert...*/
    public static void handleBeforeInsert(List<Implementation_Survey__c> impSurveyRecList){
        duplicacyCheck(impSurveyRecList);   //Added By Mohsin - 28th Feb 2019
        /*....Calling Method..*/
        updateAccountContact(impSurveyRecList);
        //Added on 05/25/2018 by Shanu Aggarwal - Project P-003576
        automateFieldsOnAccAndOpp(impSurveyRecList,null);
    }
    
    public static void handleAfterUpdate(List<Implementation_Survey__c> impSurveyRecList,Map<Id,Implementation_Survey__c> impSurveyRecListOld){
       
        //Added on 05/25/2018 by Shanu Aggarwal - Project P-003576
        automateFieldsOnAccAndOpp(impSurveyRecList,impSurveyRecListOld);
        
        //Added by Udita : 5/28/2019 : TICCM-279 : Changes to Implementation Survey for EDC
        populateDataCenterOnOpp(impSurveyRecList,impSurveyRecListOld);
    }

    //Added on 05/25/2018 by Shanu Aggarwal - Project P-003576
    public static void automateFieldsOnAccAndOpp(List<Implementation_Survey__c> impSurveyRecList,Map<Id,Implementation_Survey__c> impSurveyRecListOld){
        set<id> accIds = new set<id>();
        Map<Id,Opportunity> oppUpdateMap = new Map<Id,Opportunity>();
        Map<Id,Account> accUpdateMap = new Map<Id,Account>();
        List<Account> accList = new List<Account>();
      //  Map<Id,String> accSeedMap = new Map<Id,String>();
        map<id,map<id,string>> accImpSurveyMap = new map<id,map<id,string>>();
        
        List<Implementation_Survey__c> impSurveyList=new List<Implementation_Survey__c>();


        for(Implementation_Survey__c impSurveyRec : impSurveyRecList){
        if(impSurveyRec.Account__c!=null  && ( impSurveyRecListOld==null || impSurveyRecListOld.get(impSurveyRec.Id).Seed_Account__c!= impSurveyRec.Seed_Account__c)){
          accIds.add(impSurveyRec.Account__c);
        }
            
            //On Opportunity - VJ added additional condition for Specify_the_preferred_data_center__c
            if(impSurveyRec.Opportunity__c!=null && ( impSurveyRecListOld==null || impSurveyRecListOld.get(impSurveyRec.Id).Tax_Exempt__c!= impSurveyRec.Tax_Exempt__c 
            || impSurveyRecListOld.get(impSurveyRec.Id).PO_If_Applicable__c!= impSurveyRec.PO_If_Applicable__c || impSurveyRecListOld.get(impSurveyRec.Id).Specify_the_preferred_data_center__c!= impSurveyRec.Specify_the_preferred_data_center__c 
            || impSurveyRecListOld.get(impSurveyRec.Id).First_Presentation_Date__c!= impSurveyRec.First_Presentation_Date__c || impSurveyRecListOld.get(impSurveyRec.Id).Federal_Tax_ID_VAT_ID_GST_ID__c != impSurveyRec.Federal_Tax_ID_VAT_ID_GST_ID__c)){

                //Are you Sales Tax Exempt? to Opp
                oppUpdateMap.put(impSurveyRec.Opportunity__c,new Opportunity(Id=impSurveyRec.Opportunity__c,Are_you_Sales_Tax_Exempt__c=impSurveyRec.Tax_Exempt__c));
                //#PO Field to Opp
                if(ExecuteMethodHelper.isActive('OppFieldAutomation')){
                oppUpdateMap.get(impSurveyRec.Opportunity__c).put('PO__c',impSurveyRec.PO_If_Applicable__c); 
                oppUpdateMap.get(impSurveyRec.Opportunity__c).put('Federal_Tax_Id__c',impSurveyRec.Federal_Tax_ID_VAT_ID_GST_ID__c); }
                //Specify the preferred Data Center field to Opp - added by VJ
                oppUpdateMap.get(impSurveyRec.Opportunity__c).put('Specify_the_preferred_data_center__c',impSurveyRec.Specify_the_preferred_data_center__c);
                //Implementation Response #: Field To Opp
                oppUpdateMap.get(impSurveyRec.Opportunity__c).put('Implementation_Response__c',impSurveyRec.Name);
                //Implementation Survey Response No. Field To Opp
                oppUpdateMap.get(impSurveyRec.Opportunity__c).put('Implementation_Survey_Response_No__c',impSurveyRec.Id);
                //Implementation Survey First Presentation Date Field To Opp
                oppUpdateMap.get(impSurveyRec.Opportunity__c).put('FirstPresentation__c',impSurveyRec.First_Presentation_Date__c);
                
               
            }
            
           
            //On Account - Federal Tax ID/VAT ID/GST ID
            if(impSurveyRec.Account__c!=null  && ( impSurveyRecListOld==null || impSurveyRecListOld.get(impSurveyRec.Id).Federal_Tax_ID_VAT_ID_GST_ID__c!= impSurveyRec.Federal_Tax_ID_VAT_ID_GST_ID__c)){
                
                //Federal Tax ID/VAT ID/GST ID
                accUpdateMap.put(impSurveyRec.Account__c,new Account(Id=impSurveyRec.Account__c,Federal_Tax_ID_VAT_Number__c=impSurveyRec.Federal_Tax_ID_VAT_ID_GST_ID__c));
                 
            }
            
            //On Account - Seed Account
           /* if(impSurveyRec.Account__c!=null  && ( impSurveyRecListOld==null || impSurveyRecListOld.get(impSurveyRec.Id).Seed_Account__c!= impSurveyRec.Seed_Account__c)){
                
                //Collect Seed Account Multipicklist values
                if(accSeedMap.containsKey(impSurveyRec.Account__c)){
                    accSeedMap.put(impSurveyRec.Account__c,accSeedMap.get(impSurveyRec.Account__c)+';'+impSurveyRec.Seed_Account__c);
                }else{
                    accSeedMap.put(impSurveyRec.Account__c,impSurveyRec.Seed_Account__c);
                }
            }*/
            
            //On Account - Seed Account
           /* if(impSurveyRec.Account__c!=null  && ( impSurveyRecListOld==null || impSurveyRecListOld.get(impSurveyRec.Id).Seed_Account__c!= impSurveyRec.Seed_Account__c)){
                
                //Collect Seed Account Multipicklist values
                if(!accImpSurveyMap.containsKey(impSurveyRec.Account__c)){
                    accImpSurveyMap.put(impSurveyRec.Account__c,new map<id,string>());
                }
                accImpSurveyMap.get(impSurveyRec.Account__c).put(impSurveyRec.id,impSurveyRec.Seed_Account__c);
            }*/
            
            
        }
        //On Account - Seed Account
        if(accIds.size() > 0){
          accList = [select id,Seed_Type__c,(select id,Seed_Account__c,Account__c from Implementation_Surveys__r where Seed_Account__c!=null) from account where id in: accIds]; 
        }
        
        //remove opps which are contract implemented
        if(!oppUpdateMap.isEmpty()){
            for(Opportunity opp :  [Select Contract_Implemented__c from Opportunity Where ID IN:oppUpdateMap.keySet() and Contract_Implemented__c=true]){
                oppUpdateMap.remove(opp.Id);
            }
        }
        
        
        //Fill Seed Types on Account
      /*  if(!accImpSurveyMap.isEmpty()){
            
          for(Account acc : [Select Seed_Type__c From Account Where ID IN:accImpSurveyMap.keySet()]){
             for(id imp : accImpSurveyMap.get(acc.id).keyset()){ 
               system.debug('-=--accImpSurveyMap.get(acc.id).keyset() '+accImpSurveyMap.get(acc.id).keyset());
               string types = accImpSurveyMap.get(acc.Id).get(imp);
               system.debug('-=--'+types);
               if(acc.Seed_Type__c!=null){
                    //types+= ';'+ acc.Seed_Type__c;
               }
               if(accUpdateMap.containsKey(acc.Id) && accImpSurveyMap.get(acc.Id).get(imp) != null){
                   system.debug('-=--insideeee');
                   accUpdateMap.get(acc.Id).put('Seed_Type__c',types);
               }else if(!accUpdateMap.containsKey(acc.Id) && accImpSurveyMap.get(acc.Id).get(imp) != null){
                   system.debug('-=--insideeee1');
                   accUpdateMap.put(acc.Id,new Account(Id=acc.Id,Seed_Type__c=types));
               }
            }
          }
        }*/
        //Added by Udita - Project P-003956   
        //On Account - Seed Account
        if(accList.size() > 0){
          for(account acc : accList){    
             list<string> types = new list<string>();       
             if(acc.Seed_Type__c !=null){
                acc.Seed_Type__c =null;
             }            
            for(Implementation_Survey__c impSurvey : acc.Implementation_Surveys__r){
              if(impSurvey.Seed_Account__c != null)
               types.add(impSurvey.Seed_Account__c); 
            }
            if(types.size() > 0){
                acc.Seed_Type__c = string.join(types,';');
            }
              if(accUpdateMap.containsKey(acc.Id)){
                   accUpdateMap.get(acc.Id).put('Seed_Type__c',acc.Seed_Type__c);
             }else{
               accUpdateMap.put(acc.Id,new Account(Id=acc.Id,Seed_Type__c=acc.Seed_Type__c));
             }
           }
        }

        //Update Records
        if(!oppUpdateMap.isEmpty())
            update oppUpdateMap.values();
        
        if(!accUpdateMap.isEmpty()){
            update accUpdateMap.values();

        }
            

    }


    public static void updateAccountContact(List<Implementation_Survey__c> impSurveyRecList){
        Map<Id,Id> quoteIdVsOppIdMap = new Map<Id,id>();
        Map<Id,SBQQ__Quote__c> quoteIdVsQuoteMap = new Map<Id,SBQQ__Quote__c>();
        For(Implementation_Survey__c impSurveyRec : impSurveyRecList)
        {
            System.debug('impSurveyRec.Quote__c********'+impSurveyRec.Quote__c);            
            QuoteIdVsOppIdMap.put(impSurveyRec.id,impSurveyRec.Quote__c);
        }
        For(SBQQ__Quote__c quoteObj : [SELECT Id,SBQQ__Opportunity2__c,SBQQ__Opportunity2__r.AccountId,SBQQ__Opportunity2__r.Contact_Associated__c,SBQQ__Opportunity2__r.Bundle_Campaigns__c FROM SBQQ__Quote__c WHERE Id IN : QuoteIdVsOppIdMap.values()])
        {
            quoteIdVsQuoteMap.put(quoteObj.Id,quoteObj);
        }
        System.debug('quoteIdVsQuoteMap********'+quoteIdVsQuoteMap);
        
        For(Implementation_Survey__c qouteId : impSurveyRecList)  
        {   if(quoteIdVsQuoteMap.get(qouteId.Quote__c).SBQQ__Opportunity2__r.AccountId != null) // UDITA : /TICCM-1430
               qouteId.Account__c = quoteIdVsQuoteMap.get(qouteId.Quote__c).SBQQ__Opportunity2__r.AccountId;
            qouteId.Contact__c = quoteIdVsQuoteMap.get(qouteId.Quote__c).SBQQ__Opportunity2__r.Contact_Associated__c;
            qouteId.Opportunity__c = quoteIdVsQuoteMap.get(qouteId.Quote__c).SBQQ__Opportunity2__c;
            qouteId.MSA_Bundle_Campaigns__c = quoteIdVsQuoteMap.get(qouteId.Quote__c).SBQQ__Opportunity2__r.Bundle_Campaigns__c;
        }
    }

    public static void duplicacyCheck(List<Implementation_Survey__c> impSurveyRecList)
    {
        Map<Id,Implementation_Survey__c> opportunityIdsVsIsurvey = new Map<Id,Implementation_Survey__c>();
        for(Implementation_Survey__c iSurvey : impSurveyRecList)
        {
            if(iSurvey.Opportunity__c != NULL)
            {
                opportunityIdsVsIsurvey.put(iSurvey.Opportunity__c,iSurvey);
            }
        }

        for(Opportunity opp : [select Id,(select Id from Implementation_Surveys__r) from Opportunity where Id IN :opportunityIdsVsIsurvey.keySet()])
        {
            if(opp.Implementation_Surveys__r.size() > 0)
            {
                opportunityIdsVsIsurvey.get(opp.Id).addError('You can\'t create more than one Implementation Survey');
            }
        }
    }
    //Added by Udita : 5/28/2019 : TICCM-279 : Changes to Implementation Survey for EDC
    public static void populateDataCenterOnOpp(List<Implementation_Survey__c> impSurveyRecList,Map<Id,Implementation_Survey__c> impSurveyRecListOld){
       List<Opportunity> oppListToUpdate = new List<Opportunity>();  
       set<id> oppIds = new set<id>();     
       for(Implementation_Survey__c  imp : impSurveyRecList){
       if(imp.Specify_data_center_for_implementation__c != null && (impSurveyRecListOld== Null || impSurveyRecListOld.get(imp.id).Specify_data_center_for_implementation__c != imp.Specify_data_center_for_implementation__c)){
          switch on imp.Specify_data_center_for_implementation__c{
            when 'Default based on Customer\'s Bill To'{
               //Opportunity opp = new Opportunity(id = imp.Opportunity__c);
               //opp.Specify_the_preferred_data_center__c = 'US Data Center';
               //oppListToUpdate.add(opp);
               oppIds.add(imp.Opportunity__c);
            }
            when 'Override Default Location'{
              Opportunity opp = new Opportunity(id = imp.Opportunity__c);
              opp.Specify_the_preferred_data_center__c = Null;
              oppListToUpdate.add(opp); 
            }
          }                 
       }
       }
       
       if(oppIds.size() > 0){
           for(Opportunity opp : [select id,Bill_To_Address__c,Bill_To_Address__r.CountryCode__c from opportunity where id in : oppIds ]){
               if(opp.Bill_To_Address__r.CountryCode__c== 'US' || opp.Bill_To_Address__r.CountryCode__c== 'CA' ||opp.Bill_To_Address__r.CountryCode__c== 'MX'){
                      opp.Specify_the_preferred_data_center__c = 'US Data Center';
               }else{
                      opp.Specify_the_preferred_data_center__c = 'European Data Center';
               }
               oppListToUpdate.add(opp); 
           }
           
       }
       if(oppListToUpdate.size() > 0){
         update oppListToUpdate;
       }
    }
}