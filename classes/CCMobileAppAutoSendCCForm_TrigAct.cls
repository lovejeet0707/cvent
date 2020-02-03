/**************************************************************************************
* Author: Sandeep Kumar
* Date: 06 November 2018
* Description: CC Mobile App Auto Send CC Form to Primary Contact, created as a part of CC ABP Automation  
* Class sends an email to the customer for filling out the survey
* Test Class : CCMobileAppAutoAssignment_TrigAct_Test
****************************************************************************************/
public class CCMobileAppAutoSendCCForm_TrigAct  extends TriggerAction{
    private set<Id> mobAppIdSet;
    private final String NormalABPTemplateID = Label.CC_Normal_ABP_Form_Template_ID;
    private final String RushABPTemplateID = Label.CC_Rush_Request_Form_Template_ID;
    private final String oweaForCrowdCompassSupportId = Label.CC_Automation_Org_Wide_Email_Address;    
    private final Id crowdCompassRecTypeId = Schema.SObjectType.Mobile_Card__c.getRecordTypeInfosByDeveloperName().get(Label.Mobile_App_RT_Label_Name).getRecordTypeId();
    
    public CCMobileAppAutoSendCCForm_TrigAct(){
        // call super to set batch variables & context
        super();
        mobAppIdSet = new set<Id>();
    }

    public override Boolean shouldRun(){
        if(this.isAfter() && this.isInsert() && !this.hasRun()){
            for(Mobile_Card__c newMobileApp: (List<Mobile_Card__c>)this.triggerMap.values()){
                // mobile app must have a valid record type for falling under CC Automation
                if(newMobileApp.RecordTypeId == crowdCompassRecTypeId)
                    mobAppIdSet.add(newMobileApp.Id);
            }
        }
        return !mobAppIdSet.isEmpty();
    }    
    
    public override void doAction(){
        // set trigger action variable to indicate that the doAction has been called and it will avoid recursion.        
        this.markRun();
        
        // iterate on valid mobile apps and create follow up cases where the CC Form Sent field is unchecked.
        for(Mobile_Card__c newMobileApp: (List<Mobile_Card__c>)this.triggerMap.values()){
            // mobile app must have a valid record type for falling under CC Automation
            if(mobAppIdSet.contains(newMobileApp.Id)){
                // sends an email to primary contact for asking him to fill out the survey form.
                if(newMobileApp.CC_Form_Sent__c){
                    // below code will be executed only if the email is not sent due to any email exception.
                    // error message will be displayed to the end user, so that business is aware about it and they should wait for 
                    // customer to fill out a survey which is not being sent to them originally.
                    if(!sendCCFormToPrimaryContact(newMobileApp)) newMobileApp.addError(Label.CC_Form_Exception_Error_Message);
                    else break;
                }
            }            
        }        
    } 
    
    private Boolean sendCCFormToPrimaryContact(Mobile_Card__c mobileApp){
        Boolean isSuccess = true;
        // Get an EmailTemplate that would be used for sending emails.
        Id normalABPTemplate = Id.valueOf(NormalABPTemplateID);
        Id rushABPTemplate = Id.valueOf(RushABPTemplateID);        
        // New instance of a single email message List
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();    
        // (Optional) Set list of people who should be CC'ed
        List<String> ccTo = new List<String>();        
        ccTo.add('ccleadership@cvent.com'); 
        ccTo.add('ersandeepkumar10@gmail.com');         
        if(mobileApp.Attributes__c != null && mobileApp.Attributes__c.contains('Rush Request')){
            // The email template ID used for Rush ABP Request.
            mail.setTemplateId(rushABPTemplate);            
        }else{
            // The email template ID used for Normal ABP Request.
            mail.setTemplateId(normalABPTemplate);
        }
        mail.setTargetObjectId(mobileApp.Primary_Contact__c);                           
        mail.setReplyTo('support@crowdcompass.com');
        //mail.setCcAddresses(ccTo);
        mail.setWhatId(mobileApp.Id);
        // Set the Org Wide Email Addresses
        mail.setOrgWideEmailAddressId(Id.valueOf(oweaForCrowdCompassSupportId));
        mail.setSaveAsActivity(false); 
        try{
            System.debug('mail'+mail);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
        }catch(Exception exp){
            isSuccess = false;
            System.debug('Failed to Send Mobile App Survey'+exp.getMessage()); 
        }       
        return isSuccess;
    }
}