public with sharing class UpdateContactStatus_Event_Controller {
    String accountId;  // added by udita for P-003643  Providing Access to “Back-Office Systems” Field
    String recordTypeId;
    String recordId;
    String whatId;
    String whoId;
    String contactId;
    String evt5;
    String recordPrefix;
    String WhoIdprefix;
    String newId;
    String logACall;
    String param;
    Set<String> userNameSet;
    public String recordTypeName{get;set;}//Recordtype name is stored in this and used for rendering the pageblock section accordingly
    public Contact contactRec {get; set;}//used in the vf page to show contact status field
    List<Event> eventRecord;
    public Lead leadRec {get; set;}//used in the vf page to show lead status field
    public boolean showContactStatus{get;set;}
    public boolean showLeadStatus{get;set;}
    public UpdateContactStatus_Event_Controller(ApexPages.StandardController controller) {
        userNameSet = new Set<String>();
        contactRec = new Contact();
        eventRecord=new List<Event>();
        leadRec=new Lead();
    }
    public PageReference DetailPageReference()
    {
        For(UserExcludedFromDWF__c ft : UserExcludedFromDWF__c.getall().values())
        {
            userNameSet.add(ft.name);
        }
        //if(!userNameSet.contains(UserInfo.getUserName())){
            System.debug('TestCheck===>'+ApexPages.currentPage().getParameters().containsKey('newid'));
            System.debug('newId============>'+ApexPages.currentPage().getParameters().get('newid'));
            //System.debug('newId============>'+ApexPages.currentPage().getParameters().get(newid));
            if(ApexPages.currentPage().getParameters().containsKey('RecordType')){
                recordTypeId=ApexPages.currentPage().getParameters().get('RecordType');
            }
            if(ApexPages.currentPage().getParameters().containsKey('What_Id')){
                whatId=ApexPages.currentPage().getParameters().get('What_Id');
            }
            if(ApexPages.currentPage().getParameters().containsKey('Who_Id')){
                whoId=ApexPages.currentPage().getParameters().get('Who_Id');
            }
            if(ApexPages.currentPage().getParameters().containsKey('retURL')){
                recordId=ApexPages.currentPage().getParameters().get('retURL');
            }
            if(ApexPages.currentPage().getParameters().containsKey('newid')){
                newId=ApexPages.currentPage().getParameters().get('newid');
            }
            if(ApexPages.currentPage().getParameters().containsKey('evt5'))
            {
                evt5=ApexPages.currentPage().getParameters().get('evt5');
                evt5=EncodingUtil.urlEncode(evt5,'UTF-8');
            }
            if(ApexPages.currentPage().getParameters().containsKey('followup'))
            {
                logACall = ApexPages.currentPage().getParameters().get('followup');
            }
            if(ApexPages.currentPage().getParameters().containsKey('recTypId'))
            {
                System.debug('asfsafdsad===>'+ApexPages.currentPage().getParameters().get('recTypId'));
                param=ApexPages.currentPage().getParameters().get('recTypId');
                recordId=param.substringAfterLast('retURL=/');
                recordTypeId=param.substringBefore('retURL=');
            }
            System.debug('recordIdStart====>'+recordId);
            if(recordTypeId==null){
                Schema.DescribeSObjectResult describeOpp = Schema.SObjectType.Event;    
                List<Schema.RecordTypeInfo> rtInfos = describeOpp.getRecordTypeInfos();
                for(Schema.RecordTypeInfo rtInfo : rtInfos) {
                    if(rtInfo.isDefaultRecordTypeMapping()) {               
                        recordTypeId=rtInfo.getRecordTypeId();
                        break;
                    }
                }
            }
            System.debug('recordTypeId===>'+recordTypeId);
            if(recordTypeId!=null)
            taskRecordTypeName();
            if(!userNameSet.contains(UserInfo.getUserName()) && (recordTypeName=='CrowdCompass_Presentations'||recordTypeName=='Event_Presentations1'||recordTypeName=='BD_Presentations'||recordTypeName=='Survey_Presentations'||recordTypeName=='SMM_BD_Presentations' ||recordTypeName=='TPP_Intl' ||recordTypeName=='PA_Presentations'))
            {
                System.debug('Inside If===>'+recordTypeName);
                System.debug('newId==>'+newId);
                if(newId==null){
                    System.debug('inside check'+recordId);
                    String taskEditUrl='/00U/e?'+'&retURL='+recordId+'&saveURL=/apex/UpdateContactStatus_Event?recTypId='+recordTypeId+'retURL='+recordId+'&RecordType='+recordTypeId+'&ent=Event&nooverride=1';
                    /*3/23/2016: PK: Carry forward the subject for "Save & New button"*/
                    if(evt5 != null){
                        taskEditUrl = taskEditUrl + '&evt5='+evt5;
                    }
                    if(whatId != null){
                        taskEditUrl = taskEditUrl + '&what_id='+whatId;
                    }   
                    if(whoId!=null)
                    {
                        taskEditUrl = taskEditUrl + '&who_id='+whoId;
                    }
                    if(logACall != null){
                        taskEditUrl = taskEditUrl + '&followup='+logACall;
                    }
                    PageReference taskDetailPage=new PageReference(taskEditUrl);
                    taskDetailPage.setRedirect(true);
                    return taskDetailPage;
                }
                else if(newId!=null)
                {
                    System.debug('inside else if'+newId);
                    Event EventObj=[SELECT Id,WhoId,WhatId,RecordTypeId FROM Event WHERE Id=:newId];
                    System.debug('EventObj===>'+EventObj);
                    if(EventObj!=null && EventObj.WhoId!=null)//&& (WhoIdprefix=='003' || WhoIdPrefix=='00Q')
                    {
                        contactId=EventObj.WhoId;
                        System.debug('This Level #2nd Check');
                        recordPrefix = String.valueOf(EventObj.WhoId).substring(0,3);
                        System.debug('recordPrefix===>'+recordPrefix);
                        if(recordPrefix=='003')
                        {
                            showContactStatus=true;
                            showLeadStatus=false;
                            /*For(Event taskObj :[SELECT Redirected_Dev__c,WHOId FROM Event WHERE WhoId=:contactId AND Redirected_Dev__c=true])
                            {
                            taskObj.Redirected_Dev__c=False;
                            update taskObj;
                            }*/
                            contactRec=[SELECT AccountId,Account.Back_Office_System__c,of_Offsite_Events__c,Id,Name,Types_of_Surveys_Eloqua__c,of_Employees_in_Organisation_del__c,of_Events_CC__c,of_Exhibitors_CC__c,of_Attendees_Eloqua__c,Type_of_Events__c,ChargeFeeforEvents__c,Ever_Used_Mobile_App_CC__c,Have_Breakouts_CC__c,Why_are_you_looking_for_a_survey_tool__c FROM Contact WHERE Id=:contactId];
                            accountId = contactRec.AccountId;  // added by udita for P-003643  Providing Access to “Back-Office Systems” Field
                            contactRec.Account.Back_Office_System__c = contactRec.Account.Back_Office_System__c;   // added by udita for P-003643  Providing Access to “Back-Office Systems” Field
                            /*contactRec.Types_of_Surveys_Eloqua__c ='';
                            contactRec.of_Employees_in_Organisation_del__c ='';
                            contactRec.of_Events_CC__c ='';
                            contactRec.of_Exhibitors_CC__c ='';
                            contactRec.of_Attendees_Eloqua__c ='';
                            contactRec.Type_of_Events__c ='';
                            contactRec.ChargeFeeforEvents__c ='';
                            contactRec.Ever_Used_Mobile_App_CC__c ='';
                            contactRec.Have_Breakouts_CC__c ='';
                            contactRec.Why_are_you_looking_for_a_survey_tool__c ='';
                            contactRec.of_Offsite_Events__c='';*/
                            return null;
                        }
                        else if(recordPrefix=='00Q')
                        {
                            showContactStatus=false;
                            showLeadStatus=true;
                            /*For(Event taskObj :[SELECT Redirected_Dev__c,WHOId FROM Event WHERE WhoId=:contactId AND Redirected_Dev__c=true])
                            {
                            taskObj.Redirected_Dev__c=False;
                            update taskObj;
                            }*/
                            leadRec=[SELECT Id,Name,Types_of_Surveys_Eloqua__c,of_Employees_in_Organisation__c,of_Events_CC__c,of_Exhibitors_CC__c,of_Attendees_Eloqua__c,Type_of_Events__c,Charge_Fee_for_Events__c,Ever_Used_Mobile_App_CC__c,Have_Breakouts_CC__c,Why_are_you_looking_for_a_survey_tool__c FROM Lead WHERE Id=:contactId];
                            /*leadRec.Types_of_Surveys_Eloqua__c ='';
                            leadRec.of_Employees_in_Organisation__c ='';
                            leadRec.of_Events_CC__c ='';
                            leadRec.of_Exhibitors_CC__c ='';
                            leadRec.of_Attendees_Eloqua__c ='';
                            leadRec.Type_of_Events__c ='';
                            leadRec.Charge_Fee_for_Events__c ='';
                            leadRec.Ever_Used_Mobile_App_CC__c ='';
                            leadRec.Have_Breakouts_CC__c ='';
                            leadRec.Why_are_you_looking_for_a_survey_tool__c ='';*/
                            //This method is called to verify that the contact status is "Closed Won" or not
                            //createLeadUpdate(recordTypeName);
                            return null;
                        }
                        return null;
                    }
                    else
                    {
                        System.debug('recordIdElse====>'+recordId);
                        PageReference taskDetailPage=new PageReference('/'+recordId);
                        taskDetailPage.setRedirect(true);
                        return taskDetailPage;
                    }
                    return null;
                }
                return null;
            }
            else
            {
                System.debug('inside final else');
                String taskEditUrl='/00U/e?'+'&retURL='+recordId+'&RecordType='+recordTypeId+'&ent=Event&nooverride=1';
                if(evt5 != null){
                    taskEditUrl = taskEditUrl + '&evt5='+evt5;
                }
                if(whatId != null){
                    taskEditUrl = taskEditUrl + '&what_id='+whatId;
                }   
                if(whoId!=null)
                {
                    taskEditUrl = taskEditUrl + '&who_id='+whoId;
                }
                if(logACall != null){
                    taskEditUrl = taskEditUrl + '&followup='+logACall;
                }
                PageReference taskDetailPage=new PageReference(taskEditUrl);
                taskDetailPage.setRedirect(true);
                return taskDetailPage;
            }
        //}
        /*else if(newId!=null)
        {
            Event EventObj=[SELECT Id,WhoId,WhatId,RecordTypeId FROM Event WHERE Id=:newId];
            recordTypeId=EventObj.RecordTypeId;
        }*/
    }

    //Get current Event RecordType Name
    private string taskRecordTypeName()
    {
        String recordTypeQuery='SELECT Name,DeveloperName FROM RecordType WHERE Id ='+'\''+recordTypeId+'\'';
        sObject sRecordType=Database.query(recordTypeQuery);
        RecordType rt=(RecordType)sRecordType;
        recordTypeName=rt.DeveloperName;
        return recordTypeName;
    }
    public PageReference SaveContact()
    {
        PageReference contactDetailPage;
        System.debug('contactRec===>'+contactRec);
        System.debug('leadRec===>'+leadRec);
        if(recordPrefix=='003'){
            Contact conObj = new Contact(Id=contactRec.Id);
            if(contactRec.of_Events_CC__c!=null)
                conObj.of_Events_CC__c=contactRec.of_Events_CC__c;
            if(contactRec.of_Attendees_Eloqua__c!=null)
                conObj.of_Attendees_Eloqua__c=contactRec.of_Attendees_Eloqua__c;
            if(contactRec.Type_of_Events__c!=null)
                conObj.Type_of_Events__c=contactRec.Type_of_Events__c;
            if(contactRec.Ever_Used_Mobile_App_CC__c!=null)
                conObj.Ever_Used_Mobile_App_CC__c=contactRec.Ever_Used_Mobile_App_CC__c;
            if(contactRec.ChargeFeeforEvents__c!=null)
                conObj.ChargeFeeforEvents__c=contactRec.ChargeFeeforEvents__c;
            if(contactRec.of_Exhibitors_CC__c!=null)
                conObj.of_Exhibitors_CC__c=contactRec.of_Exhibitors_CC__c;
            if(contactRec.Have_Breakouts_CC__c!=null)
                conObj.Have_Breakouts_CC__c=contactRec.Have_Breakouts_CC__c;
            if(contactRec.Why_are_you_looking_for_a_survey_tool__c!=null)
                conObj.Why_are_you_looking_for_a_survey_tool__c=contactRec.Why_are_you_looking_for_a_survey_tool__c;
            if(contactRec.Types_of_Surveys_Eloqua__c!=null)
                conObj.Types_of_Surveys_Eloqua__c=contactRec.Types_of_Surveys_Eloqua__c;
            if(contactRec.of_Employees_in_Organisation_del__c!=null)
                conObj.of_Employees_in_Organisation_del__c=contactRec.of_Employees_in_Organisation_del__c;
            if(contactRec.of_Offsite_Events__c!=null)
                conObj.of_Offsite_Events__c=contactRec.of_Offsite_Events__c;

            update conObj;
            
            // added by udita for P-003643  Providing Access to “Back-Office Systems” Field
            Account accObj = new Account(Id=contactRec.AccountId);
            if(contactRec.Account.Back_Office_System__c !=null)
                accObj.Back_Office_System__c  =contactRec.Account.Back_Office_System__c;
            update accObj;
        }
        else if(recordPrefix=='00Q'){
            Lead leadObj = new Lead(Id=leadRec.Id);
            if(leadRec.of_Events_CC__c!=null)
                leadObj.of_Events_CC__c=leadRec.of_Events_CC__c;
            if(leadRec.of_Attendees_Eloqua__c!=null)
                leadObj.of_Attendees_Eloqua__c=leadRec.of_Attendees_Eloqua__c;
            if(leadRec.Type_of_Events__c!=null)
                leadObj.Type_of_Events__c=leadRec.Type_of_Events__c;
            if(leadRec.Ever_Used_Mobile_App_CC__c!=null)
                leadObj.Ever_Used_Mobile_App_CC__c=leadRec.Ever_Used_Mobile_App_CC__c;
            if(leadRec.Charge_Fee_for_Events__c!=null)
                leadObj.Charge_Fee_for_Events__c=leadRec.Charge_Fee_for_Events__c;
            if(leadRec.of_Exhibitors_CC__c!=null)
                leadObj.of_Exhibitors_CC__c=leadRec.of_Exhibitors_CC__c;
            if(leadRec.Have_Breakouts_CC__c!=null)
                leadObj.Have_Breakouts_CC__c=leadRec.Have_Breakouts_CC__c;
            if(leadRec.Why_are_you_looking_for_a_survey_tool__c!=null)
                leadObj.Why_are_you_looking_for_a_survey_tool__c=leadRec.Why_are_you_looking_for_a_survey_tool__c;
            if(leadRec.Types_of_Surveys_Eloqua__c!=null)
                leadObj.Types_of_Surveys_Eloqua__c=leadRec.Types_of_Surveys_Eloqua__c;
            if(leadRec.of_Employees_in_Organisation__c!=null)
                leadObj.of_Employees_in_Organisation__c=leadRec.of_Employees_in_Organisation__c;
            update leadObj;
        }
        contactDetailPage=new PageReference('/'+recordId);
        contactDetailPage.setRedirect(true);
        return contactDetailPage;
    }
    public PageReference cancel(){
        String cancelUrl = '/';
        if(recordId!=null)
            cancelUrl=cancelUrl+recordId;
        PageReference pg = new PageReference(cancelUrl);
        pg.setRedirect(true);
        return pg;
    }
}