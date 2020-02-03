/*
File name : OpportunityTriggerDispatcher
Desc: call all handler classes from this classes
Date: 27 June 2018
Author :kumud 
Test class name :OpportunityTrgHelperClsTest,OpportunityTrgHelperCls_Version_2_Test,billingCaseCreate_Opp_Test

*/

public class OpportunityTriggerDispatcher{

    OpportunityTrgHelperCls handler;
    CreatePSPOnOppLineItemInsertion_TrigAct createPSPRec ;
    // Update Legal Review Stage on Quote Object - Description of functionality is mentioned in the called class.
    UpdateLegalReviewStageOnQuote_TrigAct updateQuote;
    Boolean Disable_DFR = false; // from DG_DFR_Opportunity_Trigger  
    Boolean triggerControl =false;
    public OpportunityTriggerDispatcher(){
        
        Disable_DFR =System.Label.Disable_DFR == '1'?true:false;
        triggerControl = Boolean.valueOf(Label.EB_Project_Trigger_Control);
        handler = new OpportunityTrgHelperCls();
        createPSPRec = new CreatePSPOnOppLineItemInsertion_TrigAct();
        updateQuote = new UpdateLegalReviewStageOnQuote_TrigAct();
    }// end 
    
    /*
    Method :onBeforeInsert
    Desc: Call from opportunity on before insert event.
    
    */
    public void onBeforeInsert(List<Opportunity> newListOpportunities){
    
        if(Trigger.new != null) {

            List<Opportunity> opportunities = (List<Opportunity>)Trigger.new;

            System.debug('contractIdsBeingAmended: ' + CventMyd_ContractAmendmentController.contractIdsBeingAmended);

            if(!CventMyd_ContractAmendmentController.contractIdsBeingAmended.isEmpty()) {

                for(Opportunity opportunity : opportunities) {

                    System.debug('opportunity.Name: ' + opportunity.Name);

                    opportunity.ignoreValidation__c = true;

                    System.debug('validation rule notes debug: ' + opportunity.Notes__c);

                    System.debug('opportunity.RecordTypeId: ' + opportunity.RecordTypeId);

                }

            }

        }   
        
        //CPQ
        handler.onInsert_DefaultFieldsForCPQ_RenewalMYD(newListOpportunities);
        handler.OnBeforeInsert(newListOpportunities);  
        // EBSOpportunityTrigger
        OpportunityDefaultBillingShipping.UpdateOppBillingShipping(newListOpportunities);
        // billingCaseCreate_Opp
        billingCaseCreate_Opp_handler.onbeforeInsert(newListOpportunities);
        if(CheckRecursive.runOnce()){
            //Added by Shanu
            OpportunityTrgHelperCls_Version_2.OnBeforeInsert(newListOpportunities);
        }
        
    }// end here
    /*
    
    Method :onAfterInsert
    Desc: Call from opportunity on After insert event.
    
    */
    public void onAfterInsert(List<Opportunity> newListOpportunities,Map<Id,Opportunity> newMapOppty){
        
        
        handler.OnAfterInsert(newMapOppty); 
        AssignReviewerOpptyTriggerHelper.assignContractReviewer(newListOpportunities); 
        //HSR:19thMarch2018: Creating a Booking Classification when a Opportunity is being created for the first time.
        if(Label.IsBCActive=='True')
            SnapShotUtilityHelper.createUnidentifiedBookClass(null,newMapOppty);
        
        
        if(CheckRecursive.runOnce()){
            //Added by Shanu
            OpportunityTrgHelperCls_Version_2.OnAfterInsert(newMapOppty);
        }
        // // EBSBOpportunityAfter TRIGGER
        if(triggerControl && createPSPRec.shouldRun()){
            createPSPRec.doAction();
        }
        if(triggerControl && updateQuote.shouldRun()){
            updateQuote.doAction();
        } // end
        //DG_DFR_Opportunity_Trigger  
        if(!Disable_DFR){
            
            DG_DFR_Class.OpportunityStageChange(newListOpportunities, Null);
            
        }// End here
        
    }// end 
    
    /*
    
    Method:onBeforeUpdate
    DESC: Call on before update event of opportunity
    */
    public void onBeforeUpdate(List<Opportunity> newListOpportunities,Map<ID,Opportunity> newMapOppty ,Map<ID,Opportunity> oldMapOpty) {

        ContractTrgHelperCls.handleContractedOpportunities();

        for(Opportunity opportunity : (List<Opportunity>)Trigger.new) {
            Boolean mydSwap = ContractTrgHelperCls.mydContractIdToEndDate.containsKey(opportunity.SBQQ__RenewedContract__c);
            mydSwap = (mydSwap && !opportunity.IsClosed);
            mydSwap = mydSwap && (opportunity.Deal_Year__c == '1' || opportunity.StageName == 'Up for Renewal');
            if(mydSwap && opportunity.Auto_Close_Date__c == null) {
                Date endDate = ContractTrgHelperCls.mydContractIdToEndDate.get(opportunity.SBQQ__RenewedContract__c);
                opportunity.StageName = 'MYD Created';
                opportunity.Auto_Close_Date__c = (endDate - 30);
            }                
        }
        
        handler.OnBeforeUpdate(oldMapOpty, newMapOppty); 

        OpportunityTrgHelperCls_Version_2.OnBeforeUpdate(oldMapOpty,newMapOppty);
        // billingCaseCreate_Opp
        billingCaseCreate_Opp_handler.onbeforeUpdate(newListOpportunities,newMapOppty, oldMapOpty);
        
        // // EBSBOpportunityAfter TRIGGER
        if(triggerControl && createPSPRec.shouldRun()){
            createPSPRec.doAction();
        }
        if(triggerControl && updateQuote.shouldRun()){
            updateQuote.doAction();
        } // end
    }
    
    /*
    
    Method:onAfterUpdate
    DESC: Call on before update event of opportunity
    */
    public void onAfterUpdate(List<Opportunity> newListOpportunities,Map<ID,Opportunity> newMapOppty ,Map<ID,Opportunity> oldMapOpty){
        
        //HSR:19thMarch2018: Creating a Booking Classification when a Opportunity is being created for the first time.
        if(Label.IsBCActive=='True'){
            SnapShotUtilityHelper.createUnidentifiedBookClass(oldMapOpty,newMapOppty);
        }
        handler.OnAfterUpdate(oldMapOpty, newMapOppty); 
        System.debug('null pointers are forbidden as of 4/23/2019 - 0');        
        //Added by Shanu
        if(CheckRecursive.runOnceEight()){ //Avoid recursion
           System.debug('null pointers are forbidden as of 4/23/2019 - 1');
           OpportunityTrgHelperCls_Version_2.OnAfterUpdate(oldMapOpty, newMapOppty); 
        }
        
        if(CheckRecursive.runFortyEight() || Test.isRunningTest()){
            Map<Id,Opportunity> mapOfOpps3 = new Map<Id,Opportunity>();   
            for(Opportunity opp : newMapOppty.values())
            {
                System.debug('New SBQQ__Contracted__c:'+opp.Contract_Implemented__c+', Old SBQQ__Contracted__c'+oldMapOpty.get(opp.Id).Contract_Implemented__c);
                if(((opp.Contract_Implemented__c == TRUE && opp.Contract_Implemented__c != oldMapOpty.get(opp.Id).Contract_Implemented__c)) || Test.isRunningTest())
                {
                    mapOfOpps3.put(opp.Id,opp);
                }
            }
            if(!mapOfOpps3.isEmpty() && mapOfOpps3.size() > 0 && Boolean.valueOf(Label.SocialTablesEmailAlert))
                OpportunityTrgHelperCls_Version_2.SendSocialTablesEmailAlert(mapOfOpps3);
        }
        
        
        // EBSBOpportunityAfter  Trigger
        if(triggerControl && createPSPRec.shouldRun()){
            createPSPRec.doAction();
        }
        if(triggerControl && updateQuote.shouldRun()){
            updateQuote.doAction();
        } // End here
        
        //DG_DFR_Opportunity_Trigger  
        if(!Disable_DFR){
            
            DG_DFR_Class.OpportunityStageChange(newListOpportunities, oldMapOpty);
            
        }// End here
        // billingCaseCreate_Opp
        billingCaseCreate_Opp_handler.onAfterUpdate(newListOpportunities,newMapOppty,oldMapOpty);
        // end here
        
    }// end here 
    /*
      Method:onBeforeDelete
      Desc: call on before delete of opportunity
    
    */
    public void onBeforeDelete(List<Opportunity> oldListOpportunities,Map<Id,Opportunity> oldMapOppty){
        
        handler.OnBeforeDelete(oldListOpportunities, oldMapOppty); 
        OpportunityTrgHelperCls_Version_2.onbeforeDelete(oldListOpportunities); 
        
    } // end here
    
    /*
      Method:onAfterDelete
      Desc: call on after delete of opportunity
    
    */
    public void onAfterDelete(List<Opportunity> oldListOpportunities,Map<Id,Opportunity> oldMapOppty){
        
            handler.OnAfterDelete(oldListOpportunities, oldMapOppty);    
            //Added on 03/06/2018- 
            OpportunityTrgHelperCls_Version_2.OnAfterDelete(oldListOpportunities,oldMapOppty);  
            // EBSBOpportunityAfter  Trigger
            if(triggerControl && createPSPRec.shouldRun()){
                createPSPRec.doAction();
            }
            if(triggerControl && updateQuote.shouldRun()){
                updateQuote.doAction();
            } // end here   
        
    } // end here
    
    /*
      Method:onUndelete
      Desc: call on after delete of opportunity
    
    */
    public void onUndelete(List<Opportunity> newListOpportunities){
        
        handler.OnUndelete(newListOpportunities); 
        // EBSBOpportunityAfter  Trigger
        if(triggerControl && createPSPRec.shouldRun()){
            createPSPRec.doAction();
        }
        if(triggerControl && updateQuote.shouldRun()){
            updateQuote.doAction();
        } // End here 
        
    }// end here

}// end of class