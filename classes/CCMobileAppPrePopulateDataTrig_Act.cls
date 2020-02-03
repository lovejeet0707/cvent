/**************************************************************************************
* Author: Sandeep Kumar
* Date: 18 October 2018
* Description: CC Mobile App pre-Populate Data, created as a part of CC ABP Automation  
* Class updates Mobile App fields from the Opportunties Implementation Survey in the Before Context to avoid DML
* Test Class : CCMobileAppAutoAssignment_TrigAct_Test
****************************************************************************************/
public class CCMobileAppPrePopulateDataTrig_Act extends TriggerAction{
    private Set<Id> mobileAppOppIdSet;
    private Map<Id,Implementation_Survey__c> oppIdToImpSurveyMap;
    
    public CCMobileAppPrePopulateDataTrig_Act(){
        // Call super to set batch variables & context
        super();
        mobileAppOppIdSet = new Set<Id>();
        oppIdToImpSurveyMap = new Map<Id,Implementation_Survey__c>();
    }
    
    public override Boolean shouldRun(){
        if(this.isBefore() && !this.hasRun()){
            if(this.isInsert()){
                for(Mobile_Card__c newMobileApp: (List<Mobile_Card__c>)this.triggerList){
                    // mobile app must have a valid opportunity to pre-populate the data from implementation survey
                    if(newMobileApp.Opportunity__c != null)
                        mobileAppOppIdSet.add(newMobileApp.Opportunity__c);
                }
                // get the Implementation survey response for the associated opportunity
                if(!mobileAppOppIdSet.isEmpty()){
                    for(Implementation_Survey__c 
                        impSurvey : [Select Id,Opportunity__c,
                                     First_Mobile_Event_Date__c,Contact__c,Primary_User__c,
                                     First_Mobile_Event_Launch_Date__c,Mobile_Delivery_Date__c,
                                     Rush_Request__c,How_Many_Mobile_Apps_Purchased_in_Year_1__c,
                                     Additional_Comments__c
                                     From Implementation_Survey__c 
                                     Where Opportunity__c IN :mobileAppOppIdSet
                                    ]
                       ){
                           // prepare map of OppId to Implementation Survey considering the fact that only one survey will be associated
                           // per Opportunity in Salesforce.
                           oppIdToImpSurveyMap.put(impSurvey.Opportunity__c, impSurvey);                    
                       } 
                }
            }
            if(this.isUpdate()){
                for(Mobile_Card__c newMobileApp: (List<Mobile_Card__c>)this.triggerMap.values()){
                    if(newMobileApp.Agent_Profile__c != null){
                        Mobile_Card__c oldMobileApp = (Mobile_Card__c)this.triggerOldMap.get(newMobileApp.Id);
                        // mobile App Ownership is Changed or existing App Builder is modified by the new App Builder
                        if((oldMobileApp.Agent_Profile__c != null && oldMobileApp.Agent_Profile__c != newMobileApp.Agent_Profile__c)
                           // ideal App Launch Date Entered by the App Builder after Assignment
                           || (oldMobileApp.Ideal_App_Launch_Date__c == null && oldMobileApp.Ideal_App_Launch_Date__c != newMobileApp.Ideal_App_Launch_Date__c)
                           // event Start Date Entered by the App Builder after Assignment
                           || (oldMobileApp.Event_Start_Date__c == null && oldMobileApp.Event_Start_Date__c != newMobileApp.Event_Start_Date__c))
                        {
                            // update today's date as Auto-Assignment Date
                            newMobileApp.Auto_Assignment_Date__c = Date.today();
                        }                        
                    }                             
                }
            }           
        }
        // call doaction only if the set is not empty.
        return !oppIdToImpSurveyMap.isEmpty();
    }
    
    public override void doAction(){
        // variable declaration
        Boolean setEventStartAndLaunchDate = true;
        // set trigger action variable to indicate that the doAction has been called and it will avoid recursion.
        this.markRun();
        
        // process only newly inserted mobile apps, therefore doesn't work in update operation.
        for(Mobile_Card__c newMobileApp: (List<Mobile_Card__c>)this.triggerList){
            // proceed only if the values are contained in the previously created map.
            if(oppIdToImpSurveyMap.containsKey(newMobileApp.Opportunity__c)){
                // CC Form will be sent to the Primary Contact on a Mobile App and some fields should prepopulated with the data from Imp Survey.
                if(setEventStartAndLaunchDate){
                    // IMPSurvey (First Mobile Event Date) => Mobile App (Event Start Date)
                    newMobileApp.Event_Date__c = oppIdToImpSurveyMap.get(newMobileApp.Opportunity__c).First_Mobile_Event_Date__c;
                    // IMPSurvey (First Mobile Event Date) => Mobile App (Event Start Date)
                    newMobileApp.Event_Start_Date__c = oppIdToImpSurveyMap.get(newMobileApp.Opportunity__c).First_Mobile_Event_Date__c;
                    // IMPSurvey (First Mobile Event Date) => Mobile App (Event End Date)
                    newMobileApp.Event_End_Date__c = oppIdToImpSurveyMap.get(newMobileApp.Opportunity__c).First_Mobile_Event_Date__c;
                    // IMPSurvey (First Mobile Event Date) => Mobile App (Ideal App Launch Date)
                    newMobileApp.Ideal_App_Launch_Date__c = oppIdToImpSurveyMap.get(newMobileApp.Opportunity__c).First_Mobile_Event_Launch_Date__c;
                    // populate survey related fields on Mobile App 
                    // Survey field be sent by CCMobileAppAutoCaseCreation_TrigAct once the mobile apps are created
                    // using the CC Foem Sent field. With this we can also avoid the DML operation on the same object post email delivery.
                    newMobileApp.CC_Form_Sent__c = true;          
                    newMobileApp.Survey_Sent_By__c = 'Email has been already sent by '+userInfo.getName()+' on '+System.Today().Format()+'.';     
                    setEventStartAndLaunchDate = false; 
                }
                // IMPSurvey (Record ID) => Mobile App (Implementation Survey)
                newMobileApp.Implementation_Survey__c = oppIdToImpSurveyMap.get(newMobileApp.Opportunity__c).Id;
                // IMPSurvey (Additional Comments) => Mobile App (Notes)
                newMobileApp.Notes__c = oppIdToImpSurveyMap.get(newMobileApp.Opportunity__c).Additional_Comments__c;
                // IMPSurvey (Primary User) => Mobile App (Primary Contact)
                if(oppIdToImpSurveyMap.get(newMobileApp.Opportunity__c).Primary_User__c != null){
                    newMobileApp.Primary_Contact__c = oppIdToImpSurveyMap.get(newMobileApp.Opportunity__c).Primary_User__c;
                }                	
                // IMPSurvey (Mobile Delivery Date) => Mobile App (Attributes)
                newMobileApp.Attributes__c = oppIdToImpSurveyMap.get(newMobileApp.Opportunity__c).Mobile_Delivery_Date__c;
                if(oppIdToImpSurveyMap.get(newMobileApp.Opportunity__c).Rush_Request__c != null && oppIdToImpSurveyMap.get(newMobileApp.Opportunity__c).Rush_Request__c == 'Yes'){
                    newMobileApp.Attributes__c += ';Rush Request';
                    newMobileApp.Request_Type__c = 'Rush Request';   
                }
            }
        }        
    }    
}