/*
//////////////////////////////////////
//      @author Abhishek Pandey     //
/////////////////////////////////////
Version :   1.0
Date : 10th March 2015
Description : Update all opps historically

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
global class UpdateOppsTem implements Database.Batchable<sObject>{
  global String Query;
    global List<updateDate__c> lstOfDate = new List<updateDate__c>();
    global UpdateOppsTem(){
        query = '';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        lstOfDate = updateDate__c.getall().values();
      
        Date instDateTO =  Date.valueOf(lstOfDate[0].DateTimeTo__c);
    Date instDateFrom =  Date.valueOf(lstOfDate[0].DateTimeFrom__c);
    DateTime instDateTimeTo = lstOfDate[0].DateTimeTo__c;
    DateTime instDateTimeFrom = lstOfDate[0].DateTimeFrom__c;
    String curr = 'USD';
    query = 'SELECT Id,CurrencyIsoCode,Exchange_Rate__c,CloseDate,CreatedDate,(SELECT Id,CurrencyIsoCode,CreatedDate,Exchange_Rate__c FROM TM_Fee_Structure__r),(SELECT Id,CurrencyIsoCode,Exchange_Rate__c FROM OpportunityLineItems),(SELECT Id,CurrencyIsoCode FROM Invoicing_Details__r),(SELECT Id,CurrencyIsoCode,Exchange_Rate__c FROM CSN_Credits__r),(SELECT Id,CurrencyIsoCode,Exchange_Rate__c FROM CSN_Campaigns__r) FROM Opportunity WHERE ((CloseDate >=: instDateFrom AND CloseDate <=: instDateTO) OR (CreatedDate >=: instDateTimeFrom AND CreatedDate <=:instDateTimeTo)) AND CurrencyIsoCode !=:curr';
    system.debug('query++'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> scope){
    map<String,Decimal> mapConv = new map<String,Decimal>();
    //map<String,Decimal> mapConvFuture = new map<String,Decimal>();
        lstOfDate = updateDate__c.getall().values();
        system.debug('lstOfDate+++'+lstOfDate);
        Date instDateTO =  Date.valueOf(lstOfDate[0].DateTimeTo__c);
    Date instDateFrom =  Date.valueOf(lstOfDate[0].DateTimeFrom__c);
    DateTime instDateTimeTo = lstOfDate[0].DateTimeTo__c;
    DateTime instDateTimeFrom = lstOfDate[0].DateTimeFrom__c;
    system.debug('instDateFrom+++'+instDateFrom);
    system.debug('instDateTO+++'+instDateTO);
    system.debug('scope+++++++'+scope);
        List<DatedConversionRate> lstDateCR =  [SELECT StartDate, IsoCode, ConversionRate FROM DatedConversionRate WHERE StartDate >=:instDateFrom And StartDate <=:instDateTO];
        for(DatedConversionRate instOfDCR :lstDateCR){
            String instStr = instOfDCR.StartDate + instOfDCR.IsoCode;
            system.debug('instStr++'+instStr);
            system.debug('instOfDCR.ConversionRate+++'+instOfDCR.ConversionRate);
            mapConv.put(instStr,instOfDCR.ConversionRate);
            
            //if(instOfDCR.StartDate == system.today().adddays(-1))
            //mapConvFuture.put(instStr,instOfDCR.ConversionRate);
        }
        
        List<Opportunity> lstOpp = new List<Opportunity>();
        List<TM_Fee_Structure__c> lstofTMFS = new List<TM_Fee_Structure__c>();
        List<OpportunityLineItem> lstOfFeat = new List<OpportunityLineItem>();
        List<Multi_Property_Bundles__c> lstOfMPB = new List<Multi_Property_Bundles__c>();
        List<CSN_Credit__c> lstCSNCr = new List<CSN_Credit__c>();
        Set<Id> setInvoicingLI = new Set<Id>();
        
        for(Opportunity instOfOpp : scope){
            system.debug(instOfOpp.Id);
            String instStr = '';
            
            if(instOfOpp.CloseDate > system.today().adddays(-1)){
              instStr = Date.valueOf(instOfOpp.CreatedDate) + instOfOpp.CurrencyIsoCode;
            }else{
              instStr = instOfOpp.CloseDate + instOfOpp.CurrencyIsoCode;
            }
            //if(instOfOpp.CloseDate > system.today())
            
            system.debug('instStr++'+instStr);
            system.debug('mapConv++'+mapConv);
            if(instStr != ''){
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
        }
        
        system.debug('lstOpp++'+lstOpp);
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
    
    }
}