/*
//////////////////////////////////////
//      @author Abhishek Pandey     //
/////////////////////////////////////
Version :   1.0
Date : 10th March 2015
Description : Update all opps falling on same day with correct exchange rate.
Tested in OpportunityTrgHelperClsTest


    Version 2.0
    Date:7th Nov 2016
    Description : Migrating FEATURESET to PRODUCT/PRICEBOOK. Below are the name of the field which needs to be replaced - 
    OLD FIELD NAME       = NEW FIELD NAME
    Feature_Sets__r      = OpportunityLineItems;
    R00N00000008aGEXEA2  = OpportunityLineItems;
    Feature_Set__c       = OpportunityLineItem;
    Feature__c           = Product_Name__c;
    Opportunity_N__c     = OpportunityId;
    //Lines Commented as Can't update CurrencyISOCode of OpportunityLineItem
*/
global class UpdateCurrencyBatchOppCls implements Database.Batchable<sObject>{
    
    global String Query;
    
    global UpdateCurrencyBatchOppCls(){
        query = '';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        Date dateInst = system.today();
        query = 'SELECT Id,CurrencyIsoCode,Exchange_Rate__c,CloseDate,(SELECT Id,CurrencyIsoCode,Exchange_Rate__c FROM TM_Fee_Structure__r),(SELECT Id,CurrencyIsoCode,Exchange_Rate__c FROM OpportunityLineItems),(SELECT Id,CurrencyIsoCode FROM Invoicing_Details__r),(SELECT Id,CurrencyIsoCode,Exchange_Rate__c FROM CSN_Credits__r),(SELECT Id,CurrencyIsoCode,Exchange_Rate__c FROM CSN_Campaigns__r) FROM Opportunity WHERE CloseDate =: dateInst';
        system.debug('query++'+query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Opportunity> scope){
        map<String,Decimal> mapConv = new map<String,Decimal>();
        
        List<DatedConversionRate> lstDateCR =  [SELECT StartDate, IsoCode, ConversionRate FROM DatedConversionRate WHERE StartDate =: System.Today()];
        for(DatedConversionRate instOfDCR :lstDateCR){
            String instStr = instOfDCR.StartDate + instOfDCR.IsoCode;
            system.debug('instStr++'+instStr);
            system.debug('instOfDCR.ConversionRate+++'+instOfDCR.ConversionRate);
            mapConv.put(instStr,instOfDCR.ConversionRate);
        }
        
        List<Opportunity> lstOpp = new List<Opportunity>();
        List<TM_Fee_Structure__c> lstofTMFS = new List<TM_Fee_Structure__c>();
        List<OpportunityLineItem> lstOfFeat = new List<OpportunityLineItem>();
        List<Multi_Property_Bundles__c> lstOfMPB = new List<Multi_Property_Bundles__c>();
        List<CSN_Credit__c> lstCSNCr = new List<CSN_Credit__c>();
        Set<Id> setInvoicingLI = new Set<Id>();
        
        for(Opportunity instOfOpp : scope){
            system.debug(instOfOpp.Id);
            
            String instStr = instOfOpp.CloseDate + instOfOpp.CurrencyIsoCode;
            system.debug('instStr++'+instStr);
            system.debug('mapConv++'+mapConv);
            if(mapConv.ContainsKey(instStr)){
                instOfOpp.Exchange_Rate__c = mapConv.get(instStr);
                lstOpp.add(instOfOpp);
            }else if(instOfOpp.CurrencyIsoCode == 'USD'){
                instOfOpp.Exchange_Rate__c = 1;
                lstOpp.add(instOfOpp);
            }
            
            for(TM_Fee_Structure__c instofTMFS : instOfOpp.TM_Fee_Structure__r){
                instofTMFS.Exchange_Rate__c = instOfOpp.Exchange_Rate__c;
                lstofTMFS.add(instofTMFS);
            }
            for(OpportunityLineItem instOfFeat : instOfOpp.OpportunityLineItems){
                instOfFeat.Exchange_Rate__c = instOfOpp.Exchange_Rate__c;
                lstOfFeat.add(instOfFeat);
            }
            for(Invoicing_Details__c instOfDet : instOfOpp.Invoicing_Details__r){
                setInvoicingLI.add(instOfDet.Id);
            }
            for(Multi_Property_Bundles__c instOfMPB : instOfOpp.CSN_Campaigns__r){
                instOfMPB.Exchange_Rate__c = instOfOpp.Exchange_Rate__c;
                lstOfMPB.add(instOfMPB);
            }
            for(CSN_Credit__c instCSNCr : instOfOpp.CSN_Credits__r){
                instCSNCr.Exchange_Rate__c = instOfOpp.Exchange_Rate__c;
                lstCSNCr.add(instCSNCr);
            }
        }
        
        if(lstOpp.size()>0)
        Database.SaveResult[] sr = Database.update(lstOpp , false);
        //update lstOpp;
        
        List<Invoicing_Details__c> lstInvDetLI = new List<Invoicing_Details__c>();
        
        lstInvDetLI = [SELECT Id,Opportunity__r.CurrencyIsoCode,Opportunity__r.Exchange_Rate__c,(SELECT Id,Exchange_Rate__c,CurrencyIsoCode FROM Invoicing_Line_Items__r) FROM Invoicing_Details__c WHERE Id =: setInvoicingLI];
        
        List<Invoicing_Line_Items__c> lstILI = new List<Invoicing_Line_Items__c>();
        
        for(Invoicing_Details__c incvoicingDet : lstInvDetLI){
            for(Invoicing_Line_Items__c instOfInvLI : incvoicingDet.Invoicing_Line_Items__r){
                instOfInvLI.CurrencyIsoCode = incvoicingDet.Opportunity__r.CurrencyIsoCode;
                instOfInvLI.Exchange_Rate__c = incvoicingDet.Opportunity__r.Exchange_Rate__c;
                lstILI.add(instOfInvLI);
            }
        }
        
        if(lstILI.size()>0)
        Database.SaveResult[] sr = Database.update(lstILI , false);
        //update lstILI;  
        
        if(lstofTMFS.size()>0)
        Database.SaveResult[] sr = Database.update(lstofTMFS , false);
        //update lstofTMFS;
        
        if(lstOfFeat.size()>0)
        Database.SaveResult[] sr = Database.update(lstOfFeat , false);
        //update lstOfFeat;
        
        if(lstOfMPB.size()>0)
        Database.SaveResult[] sr = Database.update(lstOfMPB , false);
        //update lstOfMPB;
        
        if(lstCSNCr.size()>0)
        Database.SaveResult[] sr = Database.update(lstCSNCr , false);
        //update lstCSNCr;
        
        
    }

    global void finish(Database.BatchableContext BC){
        Integer currencyRecCount = 0;
        //String recipientsEmail = System.Label.Admin_Team_Emails;
        String[] toAddresses = new String[]{};
        currencyRecCount = [SELECT count() FROM DatedConversionRate WHERE StartDate = today];
        
        // Send an email alert if their is an failure.
        if(currencyRecCount <6){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
            toAddresses = System.Label.Admin_Team_Emails.split(',');
            //String[] toAddresses = new String[] {recipientsEmail};  
            mail.setToAddresses(toAddresses);  
            mail.setSubject('Failed to update some currencies information from Oanda servers');
            String body='<span style='+'\''+'color:#1F497D; font-size:11.0pt;font-family:"Calibri",sans-serif;'+'\''+'><b>Hi '+', </b></br></br>You have been identified as a Designated Contact for this Integration.</br></br> Scheduled Batch Job (ACMRestIntegrationcls) has been failed to update some currencies information from Oanda servers.</br>'+'</span></br><span style='+'\''+'font-size:11.0pt;font-family:"Calibri",sans-serif;color:#000000'+'\''+'><b>Thanks,</br>'+'Salesforce'+'<o:p></o:p></b></span>';//mail.setHtmlBody(body);
            mail.setHtmlBody(body);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        //=============================================================
    }
}