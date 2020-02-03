/**@author Hemant Rana
Batch Class for the Updation of Service_Tier__c field of the Account Object according to the Share of Wallet Field and the Mapping of Service_Tier_Mapping
Version 1.0
Date: 17th Feb 2016
*/
global class OpportunityAudit implements Database.Batchable<sObject>{
    Set<Id> opportunityIdSet = new Set<Id>();
    Map<Id,Decimal> oppIdVsBCTTotal_Map = new Map<Id,Decimal>();
    Map<Id,Decimal> oppIdVsSplitTotal_Map = new Map<Id,Decimal>();
    List<Booking_Audit__c> BAList = new List<Booking_Audit__c>();
    Decimal totalPrice = 0;
    Id OpportunitySplitTypeId;
    global OpportunityAudit(){
       OpportunitySplitTypeId = [SELECT Id FROM OpportunitySplitType WHERE MasterLabel = 'Revenue'].Id;
    }
    
    global Database.querylocator start(Database.BatchableContext BC){
        String Query = 'SELECT Id ,Parent_Upsell__c,SBQQ__PrimaryQuote__r.SBQQ__NetAmount__c,Opportunity_18_digit_id__c,Net_Amount_Opp__c,Opportunity_Product_Net_Amount__c FROM Opportunity WHERE CloseDate >= 2018-01-01 AND MSA_Code__c = null';
        System.debug('query===>'+query); 
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> scope){
        For(Opportunity oppRec : scope)
        {
            opportunityIdSet.add(oppRec.Id);
        }
        
        For(Booking_Classification__c BCT : [SELECT Total_Price__c,Opportunity__c FROM Booking_Classification__c WHERE Opportunity__c IN : opportunityIdSet])
        {
            if(!oppIdVsBCTTotal_Map.containsKey(BCT.Opportunity__c)){
                oppIdVsBCTTotal_Map.put(BCT.Opportunity__c,BCT.Total_Price__c!=null?BCT.Total_Price__c:0);
            }
            else{
                Decimal dd = 0;
                System.debug('qqqqqqqq******'+oppIdVsBCTTotal_Map.get(BCT.Opportunity__c));
                System.debug('BCT.Total_Price__c******'+BCT.Total_Price__c);
                dd = oppIdVsBCTTotal_Map.get(BCT.Opportunity__c) + (BCT.Total_Price__c!=null?BCT.Total_Price__c:0);
                System.debug('dd******'+dd);
                oppIdVsBCTTotal_Map.put(BCT.Opportunity__c,dd); 
                System.debug('oppIdVsBCTTotal_Map******'+oppIdVsBCTTotal_Map);
            }
        }
        
        For(OpportunitySplit oppSplit : [SELECT SplitAmount,OpportunityId FROM OpportunitySplit WHERE SplitTypeId =: OpportunitySplitTypeId AND OpportunityId IN : opportunityIdSet])
        {
            if(!oppIdVsSplitTotal_Map.containsKey(oppSplit.OpportunityId )){
                oppIdVsSplitTotal_Map.put(oppSplit.OpportunityId ,oppSplit.SplitAmount);
            }
            else{
                oppIdVsSplitTotal_Map.put(oppSplit.OpportunityId ,(oppIdVsSplitTotal_Map.get(oppSplit.OpportunityId ) + oppSplit.SplitAmount)); 
            }
        }
        
        For(Opportunity opportunityVal : scope)
        {
            Decimal BCTNetAmount = oppIdVsBCTTotal_Map.containsKey(opportunityVal.Id)?oppIdVsBCTTotal_Map.get(opportunityVal.Id):null;
            Decimal SplitNetAmount = oppIdVsSplitTotal_Map.containsKey(opportunityVal.Id)?oppIdVsSplitTotal_Map.get(opportunityVal.Id):null;
            //For Opportunity which are not One-Off..........
            if(opportunityVal.SBQQ__PrimaryQuote__c!=null){
                if(((BCTNetAmount!=null && BCTNetAmount>0) || (SplitNetAmount!=null && SplitNetAmount>0) || (opportunityVal.SBQQ__PrimaryQuote__r.SBQQ__NetAmount__c!=null && opportunityVal.SBQQ__PrimaryQuote__r.SBQQ__NetAmount__c>0) || (opportunityVal.Net_Amount_Opp__c!=null && opportunityVal.Net_Amount_Opp__c>0) || (opportunityVal.Opportunity_Product_Net_Amount__c!=null && opportunityVal.Opportunity_Product_Net_Amount__c>0)) && 
                        ((BCTNetAmount != SplitNetAmount) ||
                            (BCTNetAmount !=opportunityVal.SBQQ__PrimaryQuote__r.SBQQ__NetAmount__c) ||
                                (BCTNetAmount !=opportunityVal.Net_Amount_Opp__c) ||
                                    (BCTNetAmount !=opportunityVal.Opportunity_Product_Net_Amount__c) ||
                                        (SplitNetAmount != opportunityVal.SBQQ__PrimaryQuote__r.SBQQ__NetAmount__c) ||
                                            (SplitNetAmount != opportunityVal.Net_Amount_Opp__c) ||
                                                (SplitNetAmount != opportunityVal.Opportunity_Product_Net_Amount__c) ||
                                                    (opportunityVal.SBQQ__PrimaryQuote__r.SBQQ__NetAmount__c != opportunityVal.Net_Amount_Opp__c) ||
                                                        (opportunityVal.SBQQ__PrimaryQuote__r.SBQQ__NetAmount__c != opportunityVal.Opportunity_Product_Net_Amount__c)
                            )
                )
                {
                    Booking_Audit__c BA = new Booking_Audit__c();
                    BA.Opportunity__c = opportunityVal.Id;
                    BA.Opportunity_External_Id__c = opportunityVal.Opportunity_18_digit_id__c;
                    BA.BCT_NetAmount__c = oppIdVsBCTTotal_Map.containsKey(opportunityVal.Id)?oppIdVsBCTTotal_Map.get(opportunityVal.Id):null;
                    BA.Split_Net_Amount__c = oppIdVsSplitTotal_Map.containsKey(opportunityVal.Id)?oppIdVsSplitTotal_Map.get(opportunityVal.Id):null;
                    BA.Quote_Net_Amount__c = opportunityVal.SBQQ__PrimaryQuote__r.SBQQ__NetAmount__c;
                    BA.Opportunity_Net_Amount__c = opportunityVal.Net_Amount_Opp__c;
                    BA.Opportunity_Product_Net_Amount__c = opportunityVal.Opportunity_Product_Net_Amount__c;
                    BAList.add(BA);
                }
            }
            else{
                if(((BCTNetAmount!=null && BCTNetAmount>0) || (SplitNetAmount!=null && SplitNetAmount>0) || (opportunityVal.Net_Amount_Opp__c!=null && opportunityVal.Net_Amount_Opp__c>0) || (opportunityVal.Opportunity_Product_Net_Amount__c!=null && opportunityVal.Opportunity_Product_Net_Amount__c>0)) && 
                            ((BCTNetAmount != SplitNetAmount) ||
                                    (BCTNetAmount !=opportunityVal.Net_Amount_Opp__c) ||
                                        (BCTNetAmount !=opportunityVal.Opportunity_Product_Net_Amount__c) ||
                                                (SplitNetAmount != opportunityVal.Net_Amount_Opp__c) ||
                                                    (SplitNetAmount != opportunityVal.Opportunity_Product_Net_Amount__c)
                                )
                    )
                    {
                        Booking_Audit__c BA = new Booking_Audit__c();
                        BA.Opportunity__c = opportunityVal.Id;
                        BA.Opportunity_External_Id__c = opportunityVal.Opportunity_18_digit_id__c;
                        BA.BCT_NetAmount__c = oppIdVsBCTTotal_Map.containsKey(opportunityVal.Id)?oppIdVsBCTTotal_Map.get(opportunityVal.Id):null;
                        BA.Split_Net_Amount__c = oppIdVsSplitTotal_Map.containsKey(opportunityVal.Id)?oppIdVsSplitTotal_Map.get(opportunityVal.Id):null;
                        BA.Quote_Net_Amount__c = opportunityVal.SBQQ__PrimaryQuote__r.SBQQ__NetAmount__c;
                        BA.Opportunity_Net_Amount__c = opportunityVal.Net_Amount_Opp__c;
                        BA.Opportunity_Product_Net_Amount__c = opportunityVal.Opportunity_Product_Net_Amount__c;
                        BA.Opportunity_Type__c = 'No Quote';
                        BAList.add(BA);
                    }
            }
        }
        if(BAList.size()>0)
            Database.upsert(BAList,Booking_Audit__c.Opportunity_External_Id__c,false);
    }
    global void finish(Database.BatchableContext BC){
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email, CreatedBy.Name , ExtendedStatus  from AsyncApexJob where Id = :BC.getJobId()]; 
         
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
        String[] toAddresses = new String[] {a.CreatedBy.Email};  
        mail.setToAddresses(toAddresses);  
        mail.setSubject('Account ServiceTier BatchJob Status: ' + a.Status);  
        //mail.setPlainTextBody('The batch Apex job processed ' + a.JobItemsProcessed);
        String body='<span style='+'\''+'color:#1F497D; font-size:11.0pt;font-family:"Calibri",sans-serif;'+'\''+'><b>Hi '+a.CreatedBy.Name+',  </b></br></br>The request submitted by you to set the Account Service Tier is being completed.</br>You can now test on the account records.</br></br><b>Total Batch Processed:</b> '+a.JobItemsProcessed+'</span></br><span style='+'\''+'font-size:11.0pt;font-family:"Calibri",sans-serif;color:#000000'+'\''+'><b>Thanks,</br>'+'Salesforce'+'<o:p></o:p></b></span>';
        mail.setHtmlBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
        /*
        Send an email notification about Batch Completion.
        */
    }}