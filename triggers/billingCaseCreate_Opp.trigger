/* ***************************************************************************************************************
* Trigger Name:billingCaseCreate_Opp
* Author: Hemant Rana
* Date: 28-Nov-2015
* Requirement # Auto creation of Billing Cases and updating the
details of existing billing cases when the new deal is closed

*****************************************************************************************************************
*/
trigger billingCaseCreate_Opp on Opportunity (after insert,after update,before insert, before update) {

    /* Skip execution if this user is setup to exempt triggers. This helps in one time data load as well */
    if(!BypassTriggerUtility.isTriggerEnabledForThisUserOrProfileId(UserInfo.getUserId())){
            return;
    } 
    
    List<Opportunity> opportunityObject= new List<Opportunity>();//List used for passing list of Opportunity to a helperclass"billingCaseCreate_Opp_handler" on After Trigger Call
    List<Opportunity> opportunityObject_Update= new List<Opportunity>();//List used for passing list of Opportunity to a helperclass"billingCaseCreate_Opp_handler" on Before Trigger Call
    //Ends Here------------------------------------
    For(Opportunity oppObj : trigger.new)
    {
        if(trigger.isAfter){
            /*if(trigger.isInsert)
            {
            if(oppObj.Contract_Implemented__c==True){
            if(oppObj.StageName=='Closed Won')// && oppObj.CVII_ID__c!=null)
            {
            opportunityObject.add(oppObj);
            }
            }
            }
            else
            {*/
            if(trigger.isUpdate){
                Opportunity oldOpp = Trigger.oldMap.get(oppObj.Id);
                if((oppObj.Contract_Implemented__c !=trigger.oldMap.get(oppObj.id).Contract_Implemented__c) && (oppObj.stageName=='Closed Won' && oppObj.Contract_Implemented__c)) 
                //if(oppObj.StageName!=oldOpp.StageName || oppObj.Contract_Implemented__c!=oldOpp.Contract_Implemented__c){
                //if(oppObj.StageName=='Closed Won' && oppObj.Contract_Implemented__c==True)// && oppObj.CVII_ID__c!=null)
                {
                    opportunityObject.add(oppObj);
                }
                //}
            }
        }
        else
        {
            if(trigger.isInsert)
            {
                if(oppObj.Contract_Number_New__c!=null && (oppObj.Deal_Year__c!=null && oppObj.Deal_Year__c=='1'))//oppObj.Deal_Year__c=='1' && oppObj.Contract_Implemented__c==true  && oppObj.StageName=='Closed Won'
                {
                    opportunityObject_Update.add(oppObj);
                }
            }
            else
            {
                Opportunity oppObjUpdate= Trigger.OldMap.get(oppObj.Id);
                //More conditions need to be added for update condition
                if(oppObj.Contract_Number_New__c!=null && (oppObj.Contract_Number_New__c!=oppObjUpdate.Contract_Number_New__c) && (oppObj.Deal_Year__c!=null && oppObj.Deal_Year__c=='1'))//&& oppObj.StageName=='Closed Won' oppObj.Deal_Year__c=='1' && oppObj.Contract_Implemented__c==true || (oppObj.Contract_Implemented__c!=oppObjUpdate.Contract_Implemented__c && oppObj.Contract_Implemented__c==true))
                {
                    opportunityObject_Update.add(oppObj);
                }
            }
        }
    }
    if(opportunityObject.size()>0 && opportunityObject!=null && !billingCaseCreate_Opp_handler.isRunonce2)
    {
        billingCaseCreate_Opp_handler.isRunonce2=true;
        //billingCaseCreate_Opp_handler handlerClass=new billingCaseCreate_Opp_handler();
        billingCaseCreate_Opp_handler.billingCaseCreate_Method(opportunityObject);
    }
    if(opportunityObject_Update.size()>0 && opportunityObject_Update!=null && !billingCaseCreate_Opp_handler.isRunonce1)
    {
        billingCaseCreate_Opp_handler.isRunonce1=true;
        billingCaseCreate_Opp_handler.oppAutomationYear1_Method(opportunityObject_Update);
    }
}