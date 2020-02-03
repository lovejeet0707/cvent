/*
//////////////////////////////////////
//    @author Abhishek Pandey    //
/////////////////////////////////////
Version :  1.0
Date : 25th August 2014
Description : Merged trigger "AccountStatusCTupdate"
Merged trigger "AccountStatus"  
Merged trigger "AccountStatusTMupdate"
Version :  2.0
Date : 17th September 2014
Description : Merged trigger "updateAvgMoodOnAccount" on after update,after delete    
Version :  3.0
Date : 30th September 2014
Description : Functionality on insert event for sales department ,that associates contacts with campaigns on the basis of their "Lead Source" field value.     
Version :  3.0
Date : 25th March 2015
Description : To update ISO value with respecitve country.   
Date : 29/05/2016 
Description : DWF Contact Status should not go back when a advance stage is selected.
*/
/* *******************************************************
Last modified by: Kumud
Desc: Merge updateAvgMoodOnAccount trigger code in this class and deactivated the updateAvgMoodOnAccount trigger on contact
Date:28 may 2018

*/
public class ContactTrgHelperCls {
    
    //Merged trigger "AccountStatusCTupdate"
    public static Map<String, Integer> priorityMap = new Map<String, Integer>();
    public static Map<Integer,String> reversePriorMap = new Map<Integer,String>();
    //Functionality on insert event for sales department ,that associates contacts with campaigns
    public static map<String,Id> mapLeadSouCampId = new map<String,Id>();
    public static map<String,Campaign_Assignment__c> mapCampAssign = new map<String,Campaign_Assignment__c>();
    //Functionality on insert event for sales department ,that associates contacts with campaigns
    //To update ISO value with respecitve country. 
    public static List<ISOSetting__c> lstOFISO = new List<ISOSetting__c>();
    public static map<String,String> mapISO = new map<String,String>();
    //To update ISO value with respecitve country. 
    static{
        //Functionality on insert event for sales department ,that associates contacts with campaigns
        mapCampAssign = Campaign_Assignment__c.getall();
        for(Campaign_Assignment__c instOfCampAss : mapCampAssign.Values()){
            mapLeadSouCampId.put(instOfCampAss.Lead_Source__c,instOfCampAss.Campaign_Id__c);
        }
        //Functionality on insert event for sales department ,that associates contacts with campaigns
        
        //To update ISO value with respecitve country. 
        lstOFISO = ISOSetting__c.getall().values();
        for(ISOSetting__c instOf : lstOFISO){
            mapISO.put(instOf.Country_Name__c.trim(),instOf.ISO__c.trim());
        }
        //To update ISO value with respecitve country.
        
        //priorityMap.put('Test',1);
        priorityMap.put('H - Closed Won',10);
        priorityMap.put('G - Opportunity Created',9);
        priorityMap.put('F - Pricing',8);
        priorityMap.put('E - Attended',7);
        priorityMap.put('D - Set',6);
        priorityMap.put('C - Qualified',5);
        priorityMap.put('B - Working',4);
        priorityMap.put('A - New Contact',3);
        priorityMap.put('I - Recycle',2);
        priorityMap.put('J - Trash', 1);
        
        //reversePriorMap.put(1,'Test');
        reversePriorMap.put(10,'H - Closed Won');
        reversePriorMap.put(9,'G - Opportunity Created');
        reversePriorMap.put(8,'F - Pricing');
        reversePriorMap.put(7,'E - Attended');
        reversePriorMap.put(6,'D - Set');
        reversePriorMap.put(5,'C - Qualified');
        reversePriorMap.put(4,'B - Working');
        reversePriorMap.put(3,'A - New Contact');
        reversePriorMap.put(2,'I - Recycle');
        reversePriorMap.put(1,'J - Trash');
    }
    //Merged trigger "AccountStatusCTupdate"
    public void OnBeforeInsert(List<Contact> newValues){    
        
        //GDPR : Udita 
        //HSR: Validate before creating if the contact Email is not under GDPR request.....
        Set<String> emailSetToValidate = new Set<String>();
        Set<String> GDPREmailSet = new Set<String>();
        //Ends here.............
        
        //trigger.new for loop (before insert)
        For(Contact instOFContact : newValues){
            if(String.IsNotBlank(instOFContact.Email))
                emailSetToValidate.add(instOFContact.Email);
            if(String.IsNotBlank(instOFContact.Alternate_Email__c ))
                emailSetToValidate.add(instOFContact.Alternate_Email__c );
        }
        string nameuser = UserInfo.getUserName();                                
        if(emailSetToValidate.size()>0 && nameuser!='marketo@cvent.com')
            GDPREmailSet = trg_GDPRContactTrg.returnGDPREmail(emailSetToValidate,'Contact');
        //...................................................                        
        
        For(Contact conObj : newValues)
        {
            //HSR: Validate before creating if the contact Email is not under GDPR request.....
            if(GDPREmailSet.size()>0 && ((String.IsNotBlank(conObj.Email) && GDPREmailSet.contains(conObj.Email)) || (String.IsNotBlank(conObj.Alternate_Email__c ) && GDPREmailSet.contains(conObj.Alternate_Email__c ))))
            {
                conObj.addError('You cannot update Email on this contact as its email is GDPR processed.');
            }
            //Ends here.............
            
            // Udita : Create a validation on Contact using code so that it will run when creating Contact from Quick create a screen.
            if(conObj.AccountId == null){
                conObj.addError('First Create the Contact under relevant Account');
            }
        }
        //GDPR CODE ENDS: Udita  
        
        
        List<Id> lstAccId = new List<Id>();
        for(Contact instOFContact : newValues){
            //To update ISO value with respecitve country.
            system.debug(instOFContact.MailingCountryCode);
            
            //if(mapISO.containsKey(instOFContact.MailingCountryCode))
            //instOFContact.Iso_Tract__c = mapISO.get(instOFContact.MailingCountryCode);
            
            if(instOFContact.MailingCountryCode == null)
                lstAccId.add(instOFContact.AccountId);
            //To update ISO value with respecitve country.  
        }
        
        Map<Id,Account> mapAccId = new Map<Id,Account>();
        
        if(lstAccId.size()>0)
            mapAccId = new Map<Id,Account>([SELECT ID,BillingCountryCode,BillingStreet,BillingCity,BillingState,BillingPostalCode FROM Account WHERE Id=:lstAccId AND BillingCountryCode != null]);
        
        for(Contact instOFContact : newValues){
            if(instOFContact.MailingCountryCode!= null){
                if(mapISO.containsKey(instOFContact.MailingCountryCode))
                    instOFContact.Iso_Tract__c = mapISO.get(instOFContact.MailingCountryCode);
            }else{
                if(mapAccId.containsKey(instOFContact.AccountId)){
                    instOFContact.MailingCountryCode = mapAccId.get(instOFContact.AccountId).BillingCountryCode; 
                    instOFContact.Iso_Tract__c = mapISO.get(mapAccId.get(instOFContact.AccountId).BillingCountryCode);
                }
            }
            
            //Added By Mohsin on 11Dec2018
            if(instOFContact.MailingStreet == NULL && instOFContact.MailingCity == NULL && instOFContact.MailingStateCode == NULL && instOFContact.MailingPostalCode == NULL && mapAccId.containsKey(instOFContact.AccountId))
            {
                instOFContact.MailingStreet = mapAccId.get(instOFContact.AccountId).BillingStreet;
                instOFContact.MailingCity = mapAccId.get(instOFContact.AccountId).BillingCity;
                instOFContact.MailingState = mapAccId.get(instOFContact.AccountId).BillingState;
                instOFContact.MailingPostalCode = mapAccId.get(instOFContact.AccountId).BillingPostalCode ;
            }
        }
        if(CheckRecursive.runTwentyEight() &&  Label.PhoneNumberValidator == 'True'){
            PhoneNumberValidator_Clone.updateContactPhoneNumber(newValues,new Map<Id,Contact>());
            //AppendISDCodesOnPhone(newValues,new Map<Id,Contact>());
        }
    }
    public void OnAfterInsert(Map<Id,Contact> newMapValues){  
        set<id> advocateContactIds = new set<id>();
        map<id,Contact_Role__c> conRoleMap = new map<id,Contact_Role__c>(); // Added by udita for Customer Roles: Advocate 
        Id custRecTypeId = Schema.SObjectType.Contact_Role__c.getRecordTypeInfosByName().get('Customer Role').getRecordTypeId();
        //Map for AccountStatusCtUpdate
        Map<Id,Account> mapMasterupdate = new Map<Id,Account>();
        //Map for AccountStatusCtUpdate
        
        //Merged trigger "AccountStatusCTupdate"  
        Map<Id,String> mapAccIdStatus =  new Map<Id,String>();
        
        //Merged trigger "AccountStatus"
        Map<Id,String> mapAccIdStatusEvent =  new Map<Id,String>();
        //Merged trigger "AccountStatus"
        
        //Merged trigger "AccountStatusTMupdate"
        Map<Id,String> mapAccIdStatusTM =  new Map<Id,String>();
        //Merged trigger "AccountStatusTMupdate"
        
        //Functionality on insert event for sales department ,that associates contacts with campaigns
        List<Contact> lstOfContacts =  new List<Contact>();
        //Functionality on insert event for sales department ,that associates contacts with campaigns
        List<Contact_Role__c> crList = new List<Contact_Role__c>();
        
        for(Contact instOFContact : newMapValues.Values()){
            if(instOFContact.CT_Contact_Status__c != null && instOFContact.CT_Contact_Status__c !='' && instOFContact.AccountId != null){
                mapAccIdStatus.put(instOFContact.AccountId,instOFContact.CT_Contact_Status__c);
            }
            //Merged trigger "AccountStatus"
            if(instOFContact.Event_Contact_Status__c != null && instOFContact.Event_Contact_Status__c !='' && instOFContact.AccountId != null){
                mapAccIdStatusEvent.put(instOFContact.AccountId,instOFContact.Event_Contact_Status__c);
            }
            //Merged trigger "AccountStatus"
            
            //Merged trigger "AccountStatusTMupdate"
            if(instOFContact.TM_Contact_Status__c != null && instOFContact.TM_Contact_Status__c !='' && instOFContact.AccountId != null){
                mapAccIdStatusTM.put(instOFContact.AccountId,instOFContact.TM_Contact_Status__c);
            }
            //Merged trigger "AccountStatusTMupdate"
            
            //Functionality on insert event for sales department ,that associates contacts with campaigns
            if(instOFContact.LeadSource !=null && instOFContact.LeadSource !=''){
                if(mapLeadSouCampId.containsKey(instOFContact.LeadSource)){ 
                    lstOfContacts.add(instOFContact);
                }
            } 
            // Code for customer role enhancement : Udita
            if(instOFContact.AdvocateHub__Date_Joined_AdvocateHub__c != null){
                advocateContactIds.add(instOFContact.id);
            }
            //Functionality on insert event for sales department ,that associates contacts with campaigns
        }
        /*********Customer Role Advocate Checkbox code: Udita *****/       
        if(advocateContactIds.size() > 0){ 
            for(Contact c : newMapValues.values()){   
                if(c.AdvocateHub__Date_Joined_AdvocateHub__c != null){
                    Contact_Role__c cr = new Contact_Role__c();
                    cr.Advocate__c = True;
                    cr.Contact__c = c.id;
                    cr.Account_Customer_Role__c = c.AccountID;
                    cr.RecordtypeId = Schema.SObjectType.Contact_Role__c.getRecordTypeInfosByName().get('Customer Role').getRecordTypeId();  
                    cr.Contact_Validated_Date__c = System.today();
                    crList.add(cr);                    
                }          
            }       
        } 
        if(crList.size() > 0){
            insert crList;
        } 
       
        /****Ends ****/
        
        
        
        List<Account> lstAccount = new List<Account>();
        
        if(mapAccIdStatus.keyset().size()>0)
            lstAccount = [SELECT id, CT_Account_Status__c, (SELECT id, AccountId, CT_Contact_Status__c FROM Contacts WHERE CT_Contact_Status__c != null) FROM Account WHERE Id =: mapAccIdStatus.keyset() AND CT_Account_Status__c NOT IN ('I - Recycle', 'J - Trash')];
        
        List<Account> lstAccSec = new List<Account>();
        
        for(Account lstAcc : lstAccount){    
            String strTempStatus = mapAccIdStatus.get(lstAcc.Id);
            Integer intTempPrior = priorityMap.get(strTempStatus);
            system.debug('strTempStatus++'+strTempStatus);
            system.debug('intTempPrior++'+intTempPrior);
            if(lstAcc.CT_Account_Status__c != null && lstAcc.CT_Account_Status__c !=''){
                Integer intTemPriorAcc = priorityMap.get(lstAcc.CT_Account_Status__c);
                system.debug('intTemPriorAcc++'+intTemPriorAcc);
                if(intTempPrior >intTemPriorAcc){
                    lstAcc.CT_Account_Status__c = mapAccIdStatus.get(lstAcc.Id);
                    lstAccSec.add(lstAcc);
                }
            }else{  
                Integer tempVarSec = 0;
                for(Contact instOfCont : lstAcc.Contacts){
                    Integer tempVarPriorVal = priorityMap.get(instOfCont.CT_Contact_Status__c);
                    if(tempVarSec < tempVarPriorVal){
                        tempVarSec = tempVarPriorVal;
                    }
                }
                if(tempVarSec < intTempPrior){
                    lstAcc.CT_Account_Status__c = mapAccIdStatus.get(lstAcc.Id);
                    lstAccSec.add(lstAcc);
                }else{
                    lstAcc.CT_Account_Status__c = reversePriorMap.get(tempVarSec);
                    lstAccSec.add(lstAcc);
                }
            }
        }
        
        if(lstAccSec.size()>0){
            BoolContactHelperClass.boolVar = false;
            update lstAccSec;
        }
        
        //Merged trigger "AccountStatusCTupdate"
        
        //Merged trigger "AccountStatus"
        
        List<Account> lstAccountThir = new List<Account>();
        
        if(mapAccIdStatusEvent.keyset().size()>0)
            lstAccountThir = [SELECT id, Event_Account_Status__c, (SELECT id, AccountId, Event_Contact_Status__c FROM Contacts WHERE Event_Contact_Status__c != null) FROM Account WHERE Id =: mapAccIdStatusEvent.keyset()];
        
        List<Account> lstAccForth = new List<Account>();
        
        for(Account lstAcc : lstAccountThir){    
            String strTempStatus = mapAccIdStatusEvent.get(lstAcc.Id);
            Integer intTempPrior = priorityMap.get(strTempStatus);
            
            if(lstAcc.Event_Account_Status__c != null && lstAcc.Event_Account_Status__c !=''){
                Integer intTemPriorAcc = priorityMap.get(lstAcc.Event_Account_Status__c);
                system.debug('intTemPriorAcc++'+intTemPriorAcc);
                if(intTempPrior > intTemPriorAcc){
                    lstAcc.Event_Account_Status__c = mapAccIdStatusEvent.get(lstAcc.Id);
                    lstAccForth.add(lstAcc);
                }
            }else{  
                Integer tempVarSec = 0;
                for(Contact instOfCont : lstAcc.Contacts){
                    Integer tempVarPriorVal = priorityMap.get(instOfCont.Event_Contact_Status__c);
                    if(tempVarSec < tempVarPriorVal){
                        tempVarSec = tempVarPriorVal;
                    }
                }
                if(tempVarSec < intTempPrior){
                    lstAcc.Event_Account_Status__c = mapAccIdStatusEvent.get(lstAcc.Id);
                    lstAccForth.add(lstAcc);
                }else{
                    lstAcc.Event_Account_Status__c = reversePriorMap.get(tempVarSec);
                    lstAccForth.add(lstAcc);
                }
            }
        }
        
        if(lstAccForth.size()>0){
            BoolContactHelperClass.boolVar = false;
            update lstAccForth;
        }
        //Merged trigger "AccountStatus"
        
        //Merged trigger "AccountStatusTMupdate"
        List<Account> lstAccountFifth = new List<Account>();
        
        if(mapAccIdStatusTM.keyset().size()>0)
            lstAccountFifth = [SELECT Id, TM_Account_Status__c, (SELECT Id, AccountId, TM_Contact_Status__c FROM Contacts WHERE TM_Contact_Status__c != null) FROM Account WHERE Id =: mapAccIdStatusTM.keyset() AND TM_Account_Status__c NOT IN ('I - Recycle', 'J - Trash')];
        
        List<Account> lstAccSix = new List<Account>();
        
        for(Account lstAcc : lstAccountFifth){    
            String strTempStatus = mapAccIdStatusTM.get(lstAcc.Id);
            Integer intTempPrior = priorityMap.get(strTempStatus);
            
            if(lstAcc.TM_Account_Status__c != null && lstAcc.TM_Account_Status__c !=''){
                Integer intTemPriorAcc = priorityMap.get(lstAcc.TM_Account_Status__c);
                system.debug('intTemPriorAcc++'+intTemPriorAcc);
                if(intTempPrior > intTemPriorAcc){
                    lstAcc.TM_Account_Status__c = mapAccIdStatusTM.get(lstAcc.Id);
                    lstAccSix.add(lstAcc);
                }
            }else{  
                Integer tempVarSec = 0;
                for(Contact instOfCont : lstAcc.Contacts){
                    Integer tempVarPriorVal = priorityMap.get(instOfCont.TM_Contact_Status__c);
                    if(tempVarSec < tempVarPriorVal){
                        tempVarSec = tempVarPriorVal;
                    }
                }
                if(tempVarSec < intTempPrior){
                    lstAcc.TM_Account_Status__c = mapAccIdStatusTM.get(lstAcc.Id);
                    lstAccSix.add(lstAcc);
                }else{
                    lstAcc.TM_Account_Status__c = reversePriorMap.get(tempVarSec);
                    lstAccSix.add(lstAcc);
                }
            }
        }
        
        if(lstAccSix.size()>0){
            BoolContactHelperClass.boolVar = false;
            update lstAccSix;
        }
        //Merged trigger "AccountStatusTMupdate"
        
        //Functionality on insert event for sales department ,that associates contacts with campaigns
        
        List<CampaignMember> lstCampaignMem = new List<CampaignMember>();
        for(Contact instOfContact : lstOfContacts){
            CampaignMember instOfCampMem = new CampaignMember();
            instOfCampMem.CampaignId = mapLeadSouCampId.get(instOfContact.LeadSource);
            instOfCampMem.ContactId = instOfContact.Id;
            instOfCampMem.status = 'Responded';
            lstCampaignMem.add(instOfCampMem);
        }
        
        if(lstCampaignMem.size()>0)
            insert lstCampaignMem;
        //Functionality on insert event for sales department ,that associates contacts with campaigns
    }

    /*
        ****Method Summary****
        ****Method Author: Mohsin Siddiqui****
        ****Date: 04th November, 2019****
        ****Description: Updating BatchUpdateContactFlag__c field if any of the fields in the BatchUpdateContactFields__c custom settings updates Using BatchUpdateContactFlag__c field in Batch Class****
    */
    public static void updateBatchFlag(Map<Id,Contact> oldMapValues,Map<Id,Contact> newMapValues)
    {
        Map<String,BatchUpdateContactFields__c> fieldNames = BatchUpdateContactFields__c.getAll();
        for(Contact newCon : newMapValues.values())
        {
            for(String fieldName : fieldNames.keySet())
            {
                if(newCon.get(fieldName) != oldMapValues.get(newCon.Id).get(fieldName) && newCon.BatchFlag__c == FALSE)
                {
                    newCon.BatchFlag__c = true;
                    break;
                }
            }
        }
    }
    
    public void OnBeforeUpdate(Map<Id,Contact> oldMapValues,Map<Id,Contact> newMapValues){
        if(CheckRecursive.runFifty())
        {
            updateBatchFlag(oldMapValues,newMapValues);
        }
        //GDPR code starts this overrides the fields of contacts when its marked gdpr : Udita - 5/17/2018
        Contact contactOld;
        For(Contact conObj : newMapValues.values())
        {   contactOld = oldMapValues.get(conObj.Id);
         if(conObj.Is_GDPR__c && contactOld.Is_GDPR__c != conObj.Is_GDPR__c)
         {
             conObj.FirstName = 'GDPR First Name';
             conObj.LastName = 'GDPR Last Name';
             conObj.Email = 'GDPR@GDPR.com';
             conObj.Phone = '';
             conObj.MobilePhone = '';
             conObj.Alternate_Email__c = 'GDPR@GDPR.com';
             conObj.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('GDPR').getRecordTypeId();
             conObj.Fax ='GDPR';
             conObj.AssistantPhone ='';
             conObj.HomePhone='';
             conObj.Salutation='';
             conObj.OtherPhone='';
             conObj.Title='GDPR';
             conObj.Job_Function__c='GDPR';
             conObj.Department='GDPR';
             conObj.MailingCity='';
             conObj.MailingCountry='';
             conObj.MailingState='';
             conObj.MailingStreet='';
             conObj.MailingPostalCode='';
             conObj.mkto2__Inferred_Company__c='GDPR';
             conObj.mkto2__Inferred_Country__c='GDPR';
             conObj.mkto71_Inferred_Country__c='GDPR';
             conObj.mkto2__Inferred_Metropolitan_Area__c='GDPR';
             conObj.mkto2__Inferred_Phone_Area_Code__c='GDPR';
             conObj.mkto2__Inferred_Postal_Code__c='GDPR';
             conObj.mkto71_Inferred_Postal_Code__c='GDPR';
             conObj.mkto2__Inferred_State_Region__c='GDPR';
             conObj.mkto71_Inferred_State_Region__c='GDPR';
             conObj.mkto2__Inferred_City__c='GDPR';
             conObj.Job_Rank__c='GDPR';
             //conObj.LinkedIn_ID__c='GDPR';//UD:Commented for FP:4thApril
             conObj.LID__LinkedIn_Company_Id__c=null;
             conObj.LID__LinkedIn_Member_Token__c='GDPR';
             conObj.LinkedIn_URL__c='GDPR';
             conObj.Phone_Extension__c   ='GDPR';
             conObj.Preferred_Language__c='GDPR';
             //conObj.Preferred_Language_Verified__c=false;//UD:Commented for FP:4thApril
             //conObj.Time_Zone__c='GDPR';
             conObj.Twitter_URL__c='GDPR';
             conObj.Website__c='GDPR';
         }
         if(!conObj.Is_GDPR__c && contactOld.Is_GDPR__c != conObj.Is_GDPR__c)
         {
             conObj.RecordTypeId = null;
         }
         if(conObj.Is_GDPR__c && (contactOld.FirstName != conObj.FirstName || contactOld.LastName != conObj.LastName || contactOld.Email != conObj.Email|| contactOld.Phone != conObj.Phone || contactOld.MobilePhone != conObj.MobilePhone || contactOld.Alternate_Email__c  != conObj.Alternate_Email__c))
         {
             conObj.FirstName = 'GDPR First Name';
             conObj.LastName = 'GDPR Last Name';
             conObj.Email = 'GDPR@GDPR.com';
             conObj.Phone = '';
             conObj.MobilePhone = '';
             conObj.Alternate_Email__c = 'GDPR@GDPR.com';
             conObj.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('GDPR').getRecordTypeId();
         }
         if(contactOld.Is_GDPR__c == true && conObj.Is_GDPR__c == true){
             conObj.addError('You cannot update a GDPR processed contact.');
         }
         
        }
        //GDPR code ends: Udita
        
        
        /* 29/05/2016 HSR : DWF Contact Status should not go back when a advance stage is selected....*/
        //Fetching Data from Custom Setting
        Map<String,DWFContactStatusOrder__c> DWFValMap = DWFContactStatusOrder__c.getAll();
        //Fetching User record to bypass form the custom label
        Set<Id> userIdSet = new Set<Id>();
        For(String userIdV : Label.DWFUserByPass.split(';'))
        {
            userIdSet.add(Id.valueOf(userIdV));
        }
        System.debug('******'+userIdSet);
        Id currentUserId = UserInfo.getUserId();
        /*....................ENDS HERE.............................*/
        //To update ISO value with respecitve country.
        for(Contact instOfCOntNew : newMapValues.values()){
            /* 29/05/2016 HSR : DWF Contact Status should not go back when a advance stage is selected....*/
            Contact oldContactValue = oldMapValues.get(instOfCOntNew.Id);//Fetching the Old Contact which is being modified
            if(!userIdSet.contains(currentUserId)){
                if(instOfCOntNew.SMM_Contact_Status__c != oldContactValue.SMM_Contact_Status__c)
                {
                    if((oldContactValue.SMM_Contact_Status__c == 'Closed Won' && instOfCOntNew.SMM_Contact_Status__c!='Trash')||
                       (DWFValMap.containsKey(oldContactValue.SMM_Contact_Status__c) && DWFValMap.containsKey(instOfCOntNew.SMM_Contact_Status__c)
                        && (DWFValMap.get(oldContactValue.SMM_Contact_Status__c).Order__c > DWFValMap.get(instOfCOntNew.SMM_Contact_Status__c).Order__c))
                      )
                    {
                        instOfCOntNew.addError('Enterprise Contact Status can not be moved back in Funnel');
                    }
                }
                if(instOfCOntNew.CC_Contact_Status__c != oldContactValue.CC_Contact_Status__c){
                    if((oldContactValue.CC_Contact_Status__c == 'Closed Won' && instOfCOntNew.CC_Contact_Status__c!='Trash')||
                       (DWFValMap.containsKey(oldContactValue.CC_Contact_Status__c) && DWFValMap.containsKey(instOfCOntNew.CC_Contact_Status__c)
                        && (DWFValMap.get(oldContactValue.CC_Contact_Status__c).Order__c > DWFValMap.get(instOfCOntNew.CC_Contact_Status__c).Order__c))
                      )
                        
                    {
                        instOfCOntNew.addError('CC Contact Status can not be moved back in Funnel');
                    }
                }
                if(instOfCOntNew.CSNS_Contact_Status__c != oldContactValue.CSNS_Contact_Status__c){
                    if((oldContactValue.CSNS_Contact_Status__c == 'Closed Won' && instOfCOntNew.CSNS_Contact_Status__c!='Trash')||
                       (DWFValMap.containsKey(oldContactValue.CSNS_Contact_Status__c) && DWFValMap.containsKey(instOfCOntNew.CSNS_Contact_Status__c)
                        && (DWFValMap.get(oldContactValue.CSNS_Contact_Status__c).Order__c > DWFValMap.get(instOfCOntNew.CSNS_Contact_Status__c).Order__c))
                      )
                    {
                        instOfCOntNew.addError('HC Contact Status can not be moved back in Funnel');
                    }
                }
                if(instOfCOntNew.Event_Contact_Status__c != oldContactValue.Event_Contact_Status__c){
                    
                    if((oldContactValue.Event_Contact_Status__c == 'Closed Won' && instOfCOntNew.Event_Contact_Status__c!='Trash')||
                       (DWFValMap.containsKey(oldContactValue.Event_Contact_Status__c) && DWFValMap.containsKey(instOfCOntNew.Event_Contact_Status__c)
                        && (DWFValMap.get(oldContactValue.Event_Contact_Status__c).Order__c > DWFValMap.get(instOfCOntNew.Event_Contact_Status__c).Order__c))
                      )
                    {
                        instOfCOntNew.addError('Event Contact Status can not be moved back in Funnel');
                    }
                }
                if(instOfCOntNew.Survey_Contact_Status__c != oldContactValue.Survey_Contact_Status__c)
                {
                    if((oldContactValue.Survey_Contact_Status__c == 'Closed Won' && instOfCOntNew.Survey_Contact_Status__c!='Trash')||
                       (DWFValMap.containsKey(oldContactValue.Survey_Contact_Status__c) && DWFValMap.containsKey(instOfCOntNew.Survey_Contact_Status__c)
                        && (DWFValMap.get(oldContactValue.Survey_Contact_Status__c).Order__c > DWFValMap.get(instOfCOntNew.Survey_Contact_Status__c).Order__c))
                      )
                    {
                        instOfCOntNew.addError('Inquisium Contact Status can not be moved back in Funnel');
                    }
                }
                if(instOfCOntNew.CSN_P_Contact_Status__c != oldContactValue.CSN_P_Contact_Status__c)
                {
                    if((oldContactValue.CSN_P_Contact_Status__c == 'Closed Won' && instOfCOntNew.CSN_P_Contact_Status__c!='Trash')||
                       (DWFValMap.containsKey(oldContactValue.CSN_P_Contact_Status__c) && DWFValMap.containsKey(instOfCOntNew.CSN_P_Contact_Status__c)
                        && (DWFValMap.get(oldContactValue.CSN_P_Contact_Status__c).Order__c > DWFValMap.get(instOfCOntNew.CSN_P_Contact_Status__c).Order__c))
                      )
                    {
                        instOfCOntNew.addError('CSN-P Contact Status can not be moved back in Funnel');
                    }
                }
            }
            /*....................ENDS HERE.............................*/
            /* 10/03/2016 Hemant: When the DWF contact status fields picklist are changed from "Recycle/Trash" to some other values then blank out the dependent "Recycle/Trash Reason" field */
            if(
                (instOfCOntNew.SMM_Contact_Status__c!='Trash' && instOfCOntNew.SMM_Contact_Status__c!='Recycle') &&
                (oldMapValues.get(instOfCOntNew.Id).SMM_Contact_Status__c=='Trash' || oldMapValues.get(instOfCOntNew.Id).SMM_Contact_Status__c=='Recycle') &&
                (instOfCOntNew.SMM_Contact_Status__c!=oldMapValues.get(instOfCOntNew.Id).SMM_Contact_Status__c)
            ){
                instOfCOntNew.SMM_Recycle_Trash_Reason__c='';
            }
            if(
                (instOfCOntNew.CSN_P_Contact_Status__c!='Trash' && instOfCOntNew.CSN_P_Contact_Status__c!='Recycle') &&
                (oldMapValues.get(instOfCOntNew.Id).CSN_P_Contact_Status__c=='Trash' || oldMapValues.get(instOfCOntNew.Id).CSN_P_Contact_Status__c=='Recycle') &&
                (instOfCOntNew.CSN_P_Contact_Status__c!=oldMapValues.get(instOfCOntNew.Id).CSN_P_Contact_Status__c)
            ){
                instOfCOntNew.CSN_P_Status_Details__c='';
            }
            if( 
                (instOfCOntNew.CC_Contact_Status__c!='Trash' && instOfCOntNew.CC_Contact_Status__c!='Recycle') &&
                (oldMapValues.get(instOfCOntNew.Id).CC_Contact_Status__c=='Trash' || oldMapValues.get(instOfCOntNew.Id).CC_Contact_Status__c=='Recycle') &&
                (instOfCOntNew.CC_Contact_Status__c!=oldMapValues.get(instOfCOntNew.Id).CC_Contact_Status__c)
            ){
                instOfCOntNew.CC_Recycle_Trash_Reason__c='';
            }
            if(
                (instOfCOntNew.CSNS_Contact_Status__c!='Trash' && instOfCOntNew.CSNS_Contact_Status__c!='Recycle') &&
                (oldMapValues.get(instOfCOntNew.Id).CSNS_Contact_Status__c=='Trash' || oldMapValues.get(instOfCOntNew.Id).CSNS_Contact_Status__c=='Recycle') &&
                (instOfCOntNew.CSNS_Contact_Status__c!=oldMapValues.get(instOfCOntNew.Id).CSNS_Contact_Status__c)
            ){
                instOfCOntNew.CSN_S_Recycle_Trash__c='';
            }
            if(
                (instOfCOntNew.Event_Contact_Status__c!='Trash' && instOfCOntNew.Event_Contact_Status__c!='Recycle') &&
                (oldMapValues.get(instOfCOntNew.Id).Event_Contact_Status__c=='Trash' || oldMapValues.get(instOfCOntNew.Id).Event_Contact_Status__c=='Recycle') &&
                (instOfCOntNew.Event_Contact_Status__c!=oldMapValues.get(instOfCOntNew.Id).Event_Contact_Status__c)
            ){
                instOfCOntNew.Event_Recycle_Reason__c='';
            }
            if(
                (instOfCOntNew.Survey_Contact_Status__c!='Trash' && instOfCOntNew.Survey_Contact_Status__c!='Recycle') &&
                (oldMapValues.get(instOfCOntNew.Id).Survey_Contact_Status__c=='Trash' || oldMapValues.get(instOfCOntNew.Id).Survey_Contact_Status__c=='Recycle') &&
                (instOfCOntNew.Survey_Contact_Status__c!=oldMapValues.get(instOfCOntNew.Id).Survey_Contact_Status__c)
            ){
                instOfCOntNew.Survey_Recycle_Reason__c='';
            }
            /*..................................ENDS HERE......................................................*/
            
            //if(newMapValues.get(instOfCOntNew.id).MailingCountryCode!= oldMapValues.get(instOfCOntNew.id).MailingCountryCode){
            if(mapISO.containsKey(instOfCOntNew.MailingCountryCode))
                instOfCOntNew.Iso_Tract__c = mapISO.get(instOfCOntNew.MailingCountryCode);  
            //}
        }
        //To update ISO value with respecitve country.
        
        if(CheckRecursive.runThirtyOne() && Label.PhoneNumberValidator == 'True'){
            //AppendISDCodesOnPhone(newMapValues.values(),oldMapValues);
            PhoneNumberValidator_Clone.updateContactPhoneNumber(newMapValues.values(),oldMapValues);
        }
    }
    
    //Added By Mohsin
    public void rollUpDedicatedEntMinutesPurchased(Map<Id,Contact> oldMapValues,Map<Id,Contact> newMapValues)
    {
        Map<Id,Contact> mapOfSelectedContacts = new Map<Id,Contact>();
        Map<Id,Id> mapOfSelectedAccountsVsContacts = new Map<Id,Id>();
        for(Contact con : newMapValues.values())
        {
            if(con.Dedicated_Ent_Support_Minutes_Purchased__c != oldMapValues.get(con.Id).Dedicated_Ent_Support_Minutes_Purchased__c)
            {
                mapOfSelectedContacts.put(con.Id,con);
                mapOfSelectedAccountsVsContacts.put(con.AccountId,con.Id);
            }
        }
        if(!mapOfSelectedAccountsVsContacts.isEmpty() && mapOfSelectedAccountsVsContacts.size() > 0)
        {
            List<Account> accToBeUpdated = new List<Account>();
            for(Account acc : [select id,Dedicated_Ent_Support_minutes_Purchased__c,(select Dedicated_Support_Minutes_Purchased__c from Contacts) from Account where id IN :mapOfSelectedAccountsVsContacts.keySet() AND isDeleted = false AND Id != '0011N000019CpY0'])
            {
                Decimal dedicatedEntMin = 0;
                for(Contact con : acc.Contacts)
                {
                    dedicatedEntMin = dedicatedEntMin + con.Dedicated_Support_Minutes_Purchased__c;
                }
                acc.Dedicated_Ent_Support_minutes_Purchased__c = dedicatedEntMin;
                accToBeUpdated.add(acc);
            }    
            
            if(accToBeUpdated.size() > 0 && !accToBeUpdated.isEmpty())
                update accToBeUpdated;
        }
    }
    
    //Added By Mohsin
    public void rollUpDedicatedEntMinutesUsed(Map<Id,Contact> oldMapValues,Map<Id,Contact> newMapValues)
    {
        Map<Id,Id> mapOfSelectedAccountsVsContacts = new Map<Id,Id>();
        for(Contact con : newMapValues.values())
        {
            if(con.Dedicated_Ent_Support_Minutes_Used__c != oldMapValues.get(con.Id).Dedicated_Ent_Support_Minutes_Used__c)
            {
                mapOfSelectedAccountsVsContacts.put(con.AccountId,con.Id);
            }
        }
        if(!mapOfSelectedAccountsVsContacts.isEmpty() && mapOfSelectedAccountsVsContacts.size() > 0)
        {
            List<Account> accToBeUpdated = new List<Account>();
            for(Account acc : [select id,Dedicated_Ent_Support_Minutes_Used__c,(select Dedicated_Ent_Support_Minutes_Used__c,Dedicated_Support_Minutes_Purchased__c from Contacts) from Account where id IN :mapOfSelectedAccountsVsContacts.keySet() AND isDeleted = false AND Id != '0011N000019CpY0' AND Id != '0011N000017qesE'])
            {
                Decimal dedicatedEntMin = 0;
                for(Contact con : acc.Contacts)
                {
                    dedicatedEntMin = dedicatedEntMin + con.Dedicated_Ent_Support_Minutes_Used__c;
                }
                acc.Dedicated_Ent_Support_Minutes_Used__c = dedicatedEntMin;
                accToBeUpdated.add(acc);
            }    
            
            if(accToBeUpdated.size() > 0 && !accToBeUpdated.isEmpty())
                update accToBeUpdated;
        }
    }
    
    public void OnAfterUpdate(Map<Id,Contact> oldMapValues,Map<Id,Contact> newMapValues){
        
        //Added By Mohsin
        rollUpDedicatedEntMinutesPurchased(oldMapValues,newMapValues);
        rollUpDedicatedEntMinutesUsed(oldMapValues,newMapValues);
        /*********GDPR Class called to create its related record in GDPR Repository if its marked GDPR****/
        trg_GDPRContactTrg.insertGDPR_contact(newMapValues,oldMapValues);
        /*** ENDS *****/ 
        
        //Merged trigger "AccountStatusCTupdate"  
        Map<Id,String> mapAccIdStatus =  new Map<Id,String>();
        
        //Merged trigger "AccountStatus"
        Map<Id,String> mapAccIdStatusEvent =  new Map<Id,String>();
        //Merged trigger "AccountStatus"
        
        //Merged trigger "AccountStatusTMupdate"
        Map<Id,String> mapAccIdStatusTM =  new Map<Id,String>();
        //Merged trigger "AccountStatusTMupdate"
        
        //Merged trigger "updateAvgMoodOnAccount" on after update,after delete    
        Map<Id,Contact> mapContIdAccount =  new Map<Id,Contact>();
        //Merged trigger "updateAvgMoodOnAccount" on after update,after delete
        
        /*Added By : AT : 21 Nov 2017 : */
        List<Contact> contactCSNPassList = new List<Contact>();
        List<Contact> contactCSNList = new List<Contact>();
        List<Contact> contactPassKeyList = new List<Contact>();
        List<Contact> contactIQList = new List<Contact>();
        String passkeyVal;
        String CSNVal;
        String IQVal;
        set<id> FormerContactIds = new set<id>();
        map<id,id> AccountContactIds = new map<id,id>();
        /*................Ends Here...................*/
        for(Contact instOFContact : newMapValues.Values()){
            if(instOFContact.Purchasing_Interest_PK__c!=null)
                passkeyVal = instOFContact.Purchasing_Interest_PK__c.substring(0,1);
            if(instOFContact.Purchasing_Interest_CSNP__c!=null)
                CSNVal= instOFContact.Purchasing_Interest_CSNP__c.substring(0,1);
            if(instOFContact.Purchasing_Interest_Inquisium__c!=null)
                IQVal = instOFContact.Purchasing_Interest_Inquisium__c.substring(0,1);
            /*Added By : AT : 21 Nov 2017 : */
            Contact oldCon = oldMapValues.get(instOFContact.id);            
            
            if((instOFContact.Purchasing_Interest_CSNP__c!=null && instOFContact.Purchasing_Interest_PK__c!=null) && (Integer.Valueof(CSNVal)>=3 && Integer.Valueof(CSNVal)<=5) && (Integer.Valueof(passkeyVal) >=3 && Integer.Valueof(passkeyVal) <=5) &&  (instOFContact.Purchasing_Interest_CSNP__c != oldCon.Purchasing_Interest_CSNP__c && instOFContact.Purchasing_Interest_PK__c  != oldCon.Purchasing_Interest_PK__c) && (instOFContact.Attended__c == 'CSG' || instOFContact.Attended__c == 'Training Workshop') && instOFContact.Last_Attended_Event__c != oldCon.Last_Attended_Event__c)
            {
                contactCSNPassList.add(instOFContact);
            }
            else if(instOFContact.Last_Attended_Event__c != oldCon.Last_Attended_Event__c && instOFContact.Purchasing_Interest_CSNP__c!=null && (Integer.Valueof(CSNVal) >=3 && Integer.Valueof(CSNVal) <=5) && (instOFContact.Purchasing_Interest_CSNP__c != oldCon.Purchasing_Interest_CSNP__c) && (instOFContact.Attended__c == 'OD/PS' || instOFContact.Attended__c == 'CSG' || instOFContact.Attended__c == 'Training Workshop')){
                contactCSNList.add(instOFContact);
            }
            else if(instOFContact.Last_Attended_Event__c != oldCon.Last_Attended_Event__c && instOFContact.Purchasing_Interest_PK__c!=null && (instOFContact.Attended__c == 'CSG' || instOFContact.Attended__c == 'Training Workshop') && (Integer.Valueof(passkeyVal) >=3 && Integer.Valueof(passkeyVal) <=5)&&  (instOFContact.Purchasing_Interest_PK__c != oldCon.Purchasing_Interest_PK__c)){
                contactPassKeyList.add(instOFContact);
            }
            if(instOFContact.Last_Attended_Event__c != oldCon.Last_Attended_Event__c && instOFContact.Purchasing_Interest_Inquisium__c!=null &&(instOFContact.Attended__c == 'CSG' || instOFContact.Attended__c == 'Training Workshop') && (Integer.Valueof(IQVal)>=3 && Integer.Valueof(IQVal)<=5) && instOFContact.Purchasing_Interest_Inquisium__c != oldCon.Purchasing_Interest_Inquisium__c){
                contactIQList.add(instOFContact);
            }
            system.debug('---contactIQList'+contactIQList);
            
            
            /*................Ends Here...................*/
            if(instOFContact.CT_Contact_Status__c != oldMapValues.get(instOFContact.id).CT_Contact_Status__c && instOFContact.AccountId != null){
                mapAccIdStatus.put(instOFContact.AccountId,instOFContact.CT_Contact_Status__c);
            }
            //Merged trigger "AccountStatus"
            if(instOFContact.Event_Contact_Status__c != oldMapValues.get(instOFContact.id).Event_Contact_Status__c && instOFContact.AccountId != null){
                mapAccIdStatusEvent.put(instOFContact.AccountId,instOFContact.Event_Contact_Status__c);
            }
            //Merged trigger "AccountStatus"
            
            //Merged trigger "AccountStatusTMupdate"
            if(instOFContact.TM_Contact_Status__c != oldMapValues.get(instOFContact.id).TM_Contact_Status__c && instOFContact.AccountId != null){
                mapAccIdStatusTM.put(instOFContact.AccountId,instOFContact.TM_Contact_Status__c);
            }
            //Merged trigger "AccountStatusTMupdate"
            
            //Merged trigger "updateAvgMoodOnAccount" on after update,after delete
            if(instOFContact.AccountId != null && (oldMapValues.get(instOFContact.id).Mood_Level__c != instOFContact.Mood_Level__c)){
                mapContIdAccount.put(instOFContact.AccountId,instOFContact);
            }
            //Merged trigger "updateAvgMoodOnAccount" on after update,after delete  
            
            //Former Position : Udita
            if(instOFContact.AccountId != null && (oldMapValues.get(instOFContact.id).AccountId != instOFContact.AccountId)){
                FormerContactIds.add(instOFContact.id);
                AccountContactIds.put(instOFContact.id,instOFContact.AccountId);
            }          
        }
        
        
        /*--------- added by udita for Additional IQ Tasks in CSG Process -------------*/
        
        if(contactIQList.size()>0)
        { 
            set<id> contactIds = new set<id>();
            for(contact con: contactIQList){
                contactIds.add(con.id);
            }
            map<id,Contact> contactAccountMap = new map<id,Contact>([select id,account.Purchased_License__c,account.Named_Acct__c,account.Account_Status__c from contact where id in:contactIds]);
            
            for(Integer index = 0; index < contactIQList.size(); index++) {
                Contact  conObj = contactIQList[index];
                list<string> nameAccountValues = new list<string>();
                list<string> purchaseLicenseValues = new list<string>();
                if(contactAccountMap.get(conObj.id).account.Named_Acct__c != null){
                    nameAccountValues = contactAccountMap.get(conObj.id).account.Named_Acct__c.split(';');
                }
                if(contactAccountMap.get(conObj.id).account.Purchased_License__c != null){
                    purchaseLicenseValues = contactAccountMap.get(conObj.id).account.Purchased_License__c.split(';');
                }             
                if((conObj.Attended__c == 'CSG' || conObj.Attended__c == 'Training Workshop' || conObj.Attended__c == 'OD/PS') && 
                   ((nameAccountValues.size() > 0 && !JSON.serialize(nameAccountValues).contains('Event Enterprise')) || (nameAccountValues.size() == 0) ) &&
                   ((contactAccountMap.get(conObj.id).account.Account_Status__c !=null  && contactAccountMap.get(conObj.id).account.Account_Status__c.startsWithIgnoreCase('Active') &&  
                   purchaseLicenseValues.size() > 0 && (!JSON.serialize(purchaseLicenseValues).contains('Inquisium') &&
                   !JSON.serialize(purchaseLicenseValues).contains('Survey'))) || 
                   (contactAccountMap.get(conObj.id).account.Account_Status__c!=null && contactAccountMap.get(conObj.id).account.Account_Status__c.startsWithIgnoreCase('Inactive')) || 
                   (contactAccountMap.get(conObj.id).account.Account_Status__c == null))){
                       System.debug('index******'+index);
                       contactIQList.remove(index);
                       System.debug('contactIQList******'+contactIQList);
                   }
            }
        } 
        /*................Ends Here...................*/
        
        
        /*Added By : AT : 21 Nov 2017 : */
        if(contactCSNPassList.size()>0 || contactCSNList.size()>0 ||contactPassKeyList.size()>0 ||contactIQList.size()>0)
        {
            System.debug('contactIQList*****'+contactIQList);
            if(CheckRecursive.runOnceNine()){
                createCSNPasskeyIQTask(contactCSNPassList,contactCSNList,contactPassKeyList,contactIQList);
            }
        }
        /*................Ends Here...................*/
        List<Account> lstAccount = new List<Account>();
        
        if(mapAccIdStatus.keyset().size()>0)
            lstAccount = [SELECT id, CT_Account_Status__c, (SELECT id, AccountId, CT_Contact_Status__c FROM Contacts WHERE CT_Contact_Status__c != null) FROM Account WHERE Id =: mapAccIdStatus.keyset() AND CT_Account_Status__c NOT IN ('I - Recycle', 'J - Trash')];
        
        List<Account> lstAccSec = new List<Account>();
        
        for(Account lstAcc : lstAccount){    
            /*
String strTempStatus = mapAccIdStatus.get(lstAcc.Id);
Integer intTempPrior = priorityMap.get(strTempStatus);
system.debug('strTempStatus++'+strTempStatus);
system.debug('intTempPrior++'+intTempPrior);
if(lstAcc.CT_Account_Status__c != null && lstAcc.CT_Account_Status__c !=''){
Integer intTemPriorAcc = priorityMap.get(lstAcc.CT_Account_Status__c);
system.debug('intTemPriorAcc++'+intTemPriorAcc);
if(intTempPrior >intTemPriorAcc){
lstAcc.CT_Account_Status__c = mapAccIdStatus.get(lstAcc.Id);
lstAccSec.add(lstAcc);
}
}else{  
Integer tempVarSec = 0;
for(Contact instOfCont : lstAcc.Contacts){
Integer tempVarPriorVal = priorityMap.get(instOfCont.CT_Contact_Status__c);
if(tempVarSec < tempVarPriorVal){
tempVarSec = tempVarPriorVal;
}
}
if(tempVarSec < intTempPrior){
lstAcc.CT_Account_Status__c = mapAccIdStatus.get(lstAcc.Id);
lstAccSec.add(lstAcc);
}else{
lstAcc.CT_Account_Status__c = reversePriorMap.get(tempVarSec);
lstAccSec.add(lstAcc);
}
}
*/
            if(lstAcc.Contacts.size()>0){
                Integer tempVarSec = 0;
                for(Contact instOfCont : lstAcc.Contacts){
                    Integer tempVarPriorVal = priorityMap.get(instOfCont.CT_Contact_Status__c);
                    if(tempVarSec < tempVarPriorVal){
                        tempVarSec = tempVarPriorVal;
                    }
                }
                lstAcc.CT_Account_Status__c = reversePriorMap.get(tempVarSec);
                lstAccSec.add(lstAcc);
            }
        }
        
        if(lstAccSec.size()>0){
            BoolContactHelperClass.boolVar = false;
            update lstAccSec;
        }
        //Merged trigger "AccountStatusCTupdate"
        
        //Merged trigger "updateAvgMoodOnAccount" on after update,after delete
        /*
// Commented by kumud updateAvgMoodOnAccount is doing below in separte method 
List<Account> lstAccountSix = new List<Account>();

if(mapContIdAccount.keySet().size()>0)
lstAccountSix = [SELECT Id,Client_Mood_Rating__c,(SELECT Id,Mood_Level__c FROM Contacts WHERE Mood_Level__c != null) FROM Account WHERE Id =: mapContIdAccount.keySet()];

List<Account> lstAccountEight = new List<Account>();

for(Account instAcc : lstAccountSix){
Integer intContNo = instAcc.Contacts.Size();
Decimal intMoodTotal = 0;
for(Contact instContact : instAcc.Contacts){
intMoodTotal = intMoodTotal + instContact.Mood_Level__c; 
}
instAcc.Client_Mood_Rating__c = intMoodTotal/intContNo;
lstAccountEight.add(instAcc);
}

if(lstAccountEight.Size()>0)
update lstAccountEight;
End here: Part of Code clean up activity */
        //Merged trigger "updateAvgMoodOnAccount" on after update,after delete
        
        //Merged trigger "AccountStatus"
        
        List<Account> lstAccountThir = new List<Account>();
        
        if(mapAccIdStatusEvent.keyset().size()>0)
            lstAccountThir = [SELECT id, Event_Account_Status__c, (SELECT id, AccountId, Event_Contact_Status__c FROM Contacts WHERE Event_Contact_Status__c != null) FROM Account WHERE Id =: mapAccIdStatusEvent.keyset()];
        
        List<Account> lstAccForth = new List<Account>();
        
        for(Account lstAcc : lstAccountThir){    
            if(lstAcc.Contacts.size()>0){
                Integer tempVarSec = 0;
                for(Contact instOfCont : lstAcc.Contacts){
                    Integer tempVarPriorVal = priorityMap.get(instOfCont.Event_Contact_Status__c);
                    if(tempVarSec < tempVarPriorVal){
                        tempVarSec = tempVarPriorVal;
                    }
                }
                lstAcc.Event_Account_Status__c = reversePriorMap.get(tempVarSec);
                lstAccForth.add(lstAcc);
            }
        }
        
        if(lstAccForth.size()>0)
            update lstAccForth;
        //Merged trigger "AccountStatus"
        
        //Merged trigger "AccountStatusTMupdate"
        List<Account> lstAccountFifth = new List<Account>();
        
        if(mapAccIdStatusTM.keyset().size()>0)
            lstAccountFifth = [SELECT Id, TM_Account_Status__c, (SELECT Id, AccountId, TM_Contact_Status__c FROM Contacts WHERE TM_Contact_Status__c != null) FROM Account WHERE Id =: mapAccIdStatusTM.keyset() AND TM_Account_Status__c NOT IN ('I - Recycle', 'J - Trash')];
        
        List<Account> lstAccSix = new List<Account>();
        
        for(Account lstAcc : lstAccountFifth){    
            /*String strTempStatus = mapAccIdStatusTM.get(lstAcc.Id);
Integer intTempPrior = priorityMap.get(strTempStatus);

if(lstAcc.TM_Account_Status__c != null && lstAcc.TM_Account_Status__c !=''){
Integer intTemPriorAcc = priorityMap.get(lstAcc.TM_Account_Status__c);
system.debug('intTemPriorAcc++'+intTemPriorAcc);
if(intTempPrior > intTemPriorAcc){
lstAcc.TM_Account_Status__c = mapAccIdStatusTM.get(lstAcc.Id);
lstAccSix.add(lstAcc);
}
}else{  
Integer tempVarSec = 0;
for(Contact instOfCont : lstAcc.Contacts){
Integer tempVarPriorVal = priorityMap.get(instOfCont.TM_Contact_Status__c);
if(tempVarSec < tempVarPriorVal){
tempVarSec = tempVarPriorVal;
}
}
if(tempVarSec < intTempPrior){
lstAcc.TM_Account_Status__c = mapAccIdStatusTM.get(lstAcc.Id);
lstAccSix.add(lstAcc);
}else{
lstAcc.TM_Account_Status__c = reversePriorMap.get(tempVarSec);
lstAccSix.add(lstAcc);
}
}*/
            if(lstAcc.Contacts.size()>0){
                Integer tempVarSec = 0;
                for(Contact instOfCont : lstAcc.Contacts){
                    Integer tempVarPriorVal = priorityMap.get(instOfCont.TM_Contact_Status__c);
                    if(tempVarSec < tempVarPriorVal){
                        tempVarSec = tempVarPriorVal;
                    }
                }
                lstAcc.TM_Account_Status__c = reversePriorMap.get(tempVarSec);
                lstAccSix.add(lstAcc);
            }
        }
        
        if(lstAccSix.size()>0){
            BoolContactHelperClass.boolVar = false;
            update lstAccSix;
        }
        
        /******************************/
        // Contact Role Deletion, Author: Sandeep Kumar
        
        List<Contact_Role__c> conRoleDelList;     
        String conStatusMatch = 'Trash';
        String conStatusReasonMatch = 'No longer there';
        Id custRecTypeId = Schema.SObjectType.Contact_Role__c.getRecordTypeInfosByName().get('Customer Role').getRecordTypeId();
        Id buyerRecTypeId = Schema.SObjectType.Contact_Role__c.getRecordTypeInfosByName().get('Buyer Role').getRecordTypeId();
        Set<ID> recTypeIdSet = new Set<ID>{custRecTypeId,buyerRecTypeId};
            map<id,Contact_Role__c> conRoleMap = new map<id,Contact_Role__c>(); // Added by udita for Customer Roles: Advocate    
        List<Contact_Role__c> crListing = new List<Contact_Role__c>();    
        Map<Id,List<Contact_Role__c>> conIdToConRoleMap = new Map<Id,List<Contact_Role__c>>();
        List<Contact_Role__c> conRolesList;
        
        for(Contact_Role__c conRoleObj : [Select Id,Contact__c,User__c,Advocate__c,RecordTypeId From Contact_Role__c where Contact__c IN :newMapValues.keySet()  AND RecordTypeId IN :recTypeIdSet]){
            // Instantiate contact role List.
            conRolesList = new List<Contact_Role__c>();                
            if(conIdToConRoleMap.containsKey(conRoleObj.Contact__c)){
                conRolesList = conIdToConRoleMap.get(conRoleObj.Contact__c);
                conRolesList.add(conRoleObj);
                conIdToConRoleMap.put(conRoleObj.Contact__c, conRolesList);
            }else{
                conRolesList.add(conRoleObj);
                conIdToConRoleMap.put(conRoleObj.Contact__c, conRolesList);
            }
            
            //Advocate Customer Role : Udita 
            if(conRoleObj.RecordTypeId == custRecTypeId){
                conRoleMap.put(conRoleObj.Contact__c,conRoleObj);  
            }                    
        }
        system.debug('*******conRoleMap'+conRoleMap);
        // Instantiate List.
        conRoleDelList = new List<Contact_Role__c>(); 
        List<Contact_Role__c> crList = new List<Contact_Role__c>();
        Boolean recDelFlag;
        for(Contact c : newMapValues.values()){
            // Null Check for conIdToConRoleMap
            if(conIdToConRoleMap != null && conIdToConRoleMap.containsKey(c.Id)){
                for(Contact_Role__c conRole : conIdToConRoleMap.get(c.Id)){
                    // Null Check
                    system.debug('****** conRole ******' + conRole);
                    if(conRole.RecordTypeId.equals(custRecTypeId) && !Boolean.valueOf(conRole.User__c) || conRole.RecordTypeId.equals(buyerRecTypeId)){
                        recDelFlag = false;
                        if(c.Event_Contact_Status__c != null && conStatusMatch.containsIgnoreCase(c.Event_Contact_Status__c) && c.Event_Recycle_Reason__c != null && conStatusReasonMatch.containsIgnoreCase(c.Event_Recycle_Reason__c)){
                            // Set the flag for deletion.
                            recDelFlag = true;
                        }
                        if(c.Survey_Contact_Status__c != null && conStatusMatch.containsIgnoreCase(c.Survey_Contact_Status__c) && c.Survey_Recycle_Reason__c != null &&conStatusReasonMatch.containsIgnoreCase(c.Survey_Recycle_Reason__c)){
                            recDelFlag = true;
                        }
                        if(c.CSN_P_Contact_Status__c != null && conStatusMatch.containsIgnoreCase(c.CSN_P_Contact_Status__c) && c.CSN_P_Status_Details__c != null  && conStatusReasonMatch.containsIgnoreCase(c.CSN_P_Status_Details__c)){
                            recDelFlag = true;
                        }
                        if(c.SMM_Contact_Status__c != null && conStatusMatch.containsIgnoreCase(c.SMM_Contact_Status__c) && c.SMM_Recycle_Trash_Reason__c != null && conStatusReasonMatch.containsIgnoreCase(c.SMM_Recycle_Trash_Reason__c)){
                            recDelFlag = true;
                        }
                        if(c.CT_Contact_Status__c != null && c.CT_Contact_Status__c == 'J - Trash' /*&& c.CT_Recycle_Trash_Reason__c != null && conStatusReasonMatch.containsIgnoreCase(c.CT_Recycle_Trash_Reason__c)*/){//UD:Commented for FP:4thApril
                            recDelFlag = true;
                        }
                        if(c.CC_Contact_Status__c != null && conStatusMatch.containsIgnoreCase(c.CC_Contact_Status__c) && c.CC_Recycle_Trash_Reason__c != null && conStatusReasonMatch.containsIgnoreCase(c.CC_Recycle_Trash_Reason__c)){
                            recDelFlag = true;
                        }                                              
                        if(c.CSNS_Contact_Status__c != null && conStatusMatch.containsIgnoreCase(c.CSNS_Contact_Status__c) && c.CSN_S_Recycle_Trash__c != null && conStatusReasonMatch.containsIgnoreCase(c.CSN_S_Recycle_Trash__c)){
                            recDelFlag = true;
                        }
                        if(c.TM_Contact_Status__c != null && conStatusMatch.containsIgnoreCase(c.TM_Contact_Status__c) /*&& c.TM_Recycle_Trash_Reason__c != null && conStatusReasonMatch.containsIgnoreCase(c.TM_Recycle_Trash_Reason__c)*/){//UD:Commented for FP:4thApril
                            recDelFlag = true;
                        }  
                        if(recDelFlag){
                            conRoleDelList.add(conRole); 
                        }
                    }
                }
            }
            /*********Customer Role Advocate Checkbox code: Udita *****/
            
            if(c.AdvocateHub__Date_Joined_AdvocateHub__c != null && (c.AdvocateHub__Date_Joined_AdvocateHub__c != oldMapValues.get(c.id).AdvocateHub__Date_Joined_AdvocateHub__c)){   
                if(conRoleMap.isEmpty() || !conRoleMap.containsKey(c.id)){
                    Contact_Role__c cr = new Contact_Role__c();
                    cr.Advocate__c = True;
                    cr.Contact__c = c.id;
                    cr.Account_Customer_Role__c = c.AccountID;
                    cr.RecordtypeId = Schema.SObjectType.Contact_Role__c.getRecordTypeInfosByName().get('Customer Role').getRecordTypeId();  
                    cr.Contact_Validated_Date__c= System.today();
                    crList.add(cr);
                }
                else if(!conRoleMap.isEmpty() && conRoleMap.containsKey(c.id) && conRoleMap.get(c.id).Advocate__c == False){
                    conRoleMap.get(c.id).Advocate__c = True;
                    crListing.add(conRoleMap.values());
                } 
            }    
            /****Ends ****/
        }
        if(!conRoleDelList.isEmpty()){
            delete conRoleDelList;
        } 
        
        if(crList.size() > 0){
            insert crList;
        } 
        /*if(!conRoleMap.isEmpty()){
// update conRoleMap.values();
}   
*/  
        
        if(crListing.size() > 0){
            update crListing;
        } 
        
        /******************************/ 
        
        //Merged trigger "AccountStatusTMupdate"
        /*Call updateAvgMoodOnAccount method [Code clean up] 
Make  updateAvgMoodOnAccount trigger on contact inactive

*/
        updateMoodOnAccount(newMapValues.values(),oldMapValues,newMapValues);
        
         // Code starts for deleting buyer roles and removing HC Products : Former Position : Udita
        Boolean MethodIsActive = ExecuteMethodHelper.isActive('FormerContact');
     If(MethodIsActive || Test.isRunningTest()){
        if(FormerContactIds.size() > 0){
           Boolean isThisHC1;
           Boolean isThisHC2;
           Boolean isThisHC3;
           List<Contact_Role__c> deleteBuyerRoles = new List<Contact_Role__c>();
           List<Contact_Role__c> updateBuyerRoles = new List<Contact_Role__c>();
           Set<String> picklistHC = new Set<String>( Label.HC_Products.split(','));
           Set<String> picklistEC = new Set<String>( Label.EC_Products.split(','));
           String fieldValueUpdated1;
           String fieldValueUpdated2;
           String fieldValueUpdated3;
           Map<id,string> DecisionMap = new Map<id,String>();
           
           for(Contact_Role__c cr : [select id,Decision_Maker_Products__c,Executive_Sponsor_Products__c,Influencer_Products__c,Contact__c from Contact_Role__c where Contact__c in : FormerContactIds AND Recordtype.DeveloperName = 'Buyer_Role']){
                 isThisHC1 = False;
                 isThisHC2 = False;
                 isThisHC3 = False;
                 fieldValueUpdated1 = '';
                 fieldValueUpdated2 = '';
                 fieldValueUpdated3 = '';
                 if(cr.Decision_Maker_Products__c != null){
                   For(string sValue1: cr.Decision_Maker_Products__c.split(';')){
                     if(picklistEC.contains(sValue1)){
                        fieldValueUpdated1 = sValue1 +';'+fieldValueUpdated1;
                     }if(picklistHC.contains(sValue1)){
                         isThisHC1 = True;
                     }
                   }
                 }
                 if(cr.Executive_Sponsor_Products__c != null){
                   For(string sValue2: cr.Executive_Sponsor_Products__c.split(';')){
                     if(picklistEC.contains(sValue2)){
                        fieldValueUpdated2 = sValue2 +';'+fieldValueUpdated2;
                     }if(picklistHC.contains(sValue2)){
                         isThisHC1 = True;
                     }
                   }
                 }
                 if(cr.Influencer_Products__c != null){
                   For(string sValue3: cr.Influencer_Products__c.split(';')){
                     if(picklistEC.contains(sValue3)){
                        fieldValueUpdated3 = sValue3 +';'+fieldValueUpdated3;
                     }if(picklistHC.contains(sValue3)){
                         isThisHC1 = True;
                     }
                   }
                 }
                 if(isThisHC1 && String.isBlank(fieldValueUpdated1) && String.isBlank(fieldValueUpdated2) && String.isBlank(fieldValueUpdated3)){
                      deleteBuyerRoles.add(cr);
                 }
                 else{
                      cr.Decision_Maker_Products__c = fieldValueUpdated1;
                      cr.Executive_Sponsor_Products__c = fieldValueUpdated2;
                      cr.Influencer_Products__c= fieldValueUpdated3;
                      system.debug('-----cr.Decision_Maker_Products__c'+cr.Decision_Maker_Products__c);
                      system.debug('-----cr.Executive_Sponsor_Products__c'+cr.Executive_Sponsor_Products__c);
                      system.debug('-----cr.Influencer_Products__c'+cr.Influencer_Products__c);
                      if(String.IsBlank(cr.Decision_Maker_Products__c))
                         cr.Decision_Maker__c=False;
                      else
                         cr.Decision_Maker__c=True;   
                      if(String.IsBlank(cr.Executive_Sponsor_Products__c))
                         cr.Executive_Sponsor__c=False;
                      else
                         cr.Executive_Sponsor__c=True;   
                      if(String.IsBlank(cr.Influencer_Products__c))
                         cr.Influencer__c=False;
                      else
                         cr.Influencer__c=True;   
                      cr.Account_Buyer_Role__c = AccountContactIds.get(cr.Contact__c);  
                      updateBuyerRoles.add(cr);
                 }
           }// Loop Closed
           
           if(deleteBuyerRoles.size() > 0){
               delete deleteBuyerRoles;
           }
           if(updateBuyerRoles.size() > 0){
               update updateBuyerRoles;
           }
        }// Code ends for delete buyer roles : Former position
      }  
    }
    public void OnBeforeDelete(List<Contact> oldValues,Map<Id,Contact> oldMapValues){
        /******Preventing Contact Records from deletion.****/
        Set<String> authorizedUserSet = new Set<String>();
        //Accessing custom setting.....................
        For(ContactPayGo_Records_Delete_Prevention__c PG : ContactPayGo_Records_Delete_Prevention__c.getall().values()){
            authorizedUserSet.add(PG.Name);
        }
        set<id> contactIds = new set<id>();
        map<id,id> userMap = new map<id,id>();
        
        /*for(Contact instOfCon : oldValues){             
//Prevent deletion of Contacts having "Lanyon Migrated Id" in it.       
if(String.IsNotBlank(instOfCon.Lanyon_Migrated_ID__c))        
{       
instOfCon.addError('Error: You cannot Delete/Merge this Contact.');     
}       
}*/
        //HSR : 16Feb2018: Stop Contact Merge if Slave Contact has value in either "EBS Account ID"/"EBS Account Number"/"Creation Source System External ID".............
        String errorROLMessage = 'You can'+'\'t merge an ROL Contact.';
        String errorEBSMessage = 'You can'+'\'t merge a Contact with EBS Id.';
        Boolean MethodIsActive = ExecuteMethodHelper.isActive('PreventSTDeletion');
        For(Contact conObj : oldValues)
        {
            
            /******TICCM-200 - Preventing PayGo Contacts from deletion.****/
            if(((authorizedUserSet.size()>0 && !authorizedUserSet.contains(UserInfo.getUserId())) || authorizedUserSet.size()==0) && String.IsNotBlank(conObj.GUI_ID__c))
            {
                conObj.addError('PayGo Contact can not be deleted or merged');
            }
            /****************Ends Here***********************/   
        contactIds.add(conObj.id);
         // Added by Dishank Jain on Sunny's request 10537022
         if(String.IsNotBlank(conObj.QM_Migrated_Contact_ID__c))
             conObj.addError('QM Migrated/Mapped Account Cannot be Deleted');
         else if(String.IsNotBlank(conObj.EBS_Contact_ID__c)/* || String.IsNotBlank(conObj.EBS_Contact_Number__c)*/)//HJ: Commented for TICCM-1077
             conObj.addError(errorEBSMessage);
         else if(String.IsNotBlank(conObj.Creation_Source_System_External_ID__c))
             conObj.addError(errorROLMessage);
          
         if(conObj.ST_Migrated_ID__c != null && MethodIsActive == True){
            conObj.addError('ST Migrated Contact Cannot be Deleted');
         }    
        }
        //............ENDS HERE.............................
        
        //Code Starts ---- Udita :   Validation check on merging of Portal Enabled Contacts
        for(User u : [select id,ContactId from user where ContactId != null AND ContactId in :contactIds AND  IsPortalEnabled =true AND IsActive =true AND (Profile_Name__c = 'RegOnline:High Volume Community Portal User' OR Profile_Name__c = 'Business Operations' OR Profile_Name__c = 'Cvent Customer Community User')]){
            userMap.put(u.ContactId,u.id);
        }
        for(Contact conObj : oldValues){
            if(userMap.containsKey(conObj.id)){
                conObj.addError('Error: You cannot Delete/Merge this Contact.'); 
            }          
        }
     
        // -----ENDS HERE----------------------------------
    }
    public void OnAfterDelete(List<Contact> oldValues,Map<Id,Contact> oldMapValues){
        //Merged trigger "AccountStatusCTupdate"  
        Map<Id,String> mapAccIdStatus =  new Map<Id,String>();
        
        //Merged trigger "AccountStatus"
        Map<Id,String> mapAccIdStatusEvent =  new Map<Id,String>();
        //Merged trigger "AccountStatus"
        
        //Merged trigger "AccountStatusTMupdate"
        Map<Id,String> mapAccIdStatusTM =  new Map<Id,String>();
        //Merged trigger "AccountStatusTMupdate"
        
        //Merged trigger "updateAvgMoodOnAccount" on after update,after delete    
        Map<Id,Contact> mapContIdAccount =  new Map<Id,Contact>();
        //Merged trigger "updateAvgMoodOnAccount" on after update,after delete
        
        //HSR : 16Feb2018: Stop Contact Merge if the Master Contact has value in "Creation Source System External ID" field.............  
        Set<Id> masterContactIdSet = new Set<Id>();
        String errorMessage = 'You can'+'\'t merge an ROL Contact.';
        set<id> updateMergeChckboxId = new set<id>();
        for(Contact instOFContact : oldMapValues.Values()){
            if(instOFContact.MasterRecordId!=null){
                masterContactIdSet.add(instOFContact.MasterRecordId);
            }
            if(instOFContact.CT_Contact_Status__c != null && instOFContact.CT_Contact_Status__c !='' && instOFContact.AccountId != null){
                mapAccIdStatus.put(instOFContact.AccountId,instOFContact.CT_Contact_Status__c);
            }
            //Merged trigger "AccountStatus"
            if(instOFContact.Event_Contact_Status__c != null && instOFContact.Event_Contact_Status__c !='' && instOFContact.AccountId != null){
                mapAccIdStatusEvent.put(instOFContact.AccountId,instOFContact.Event_Contact_Status__c);
            }
            //Merged trigger "AccountStatus"
            
            //Merged trigger "AccountStatusTMupdate"
            if(instOFContact.TM_Contact_Status__c != null && instOFContact.TM_Contact_Status__c !='' && instOFContact.AccountId != null){
                mapAccIdStatusTM.put(instOFContact.AccountId,instOFContact.TM_Contact_Status__c);
            }
            //Merged trigger "AccountStatusTMupdate"
            
            //Merged trigger "updateAvgMoodOnAccount" on after update,after delete
            if(instOFContact.AccountId != null && instOFContact.Mood_Level__c != null && instOFContact.Mood_Level__c != 0){
                mapContIdAccount.put(instOFContact.AccountId,instOFContact);
            }
            //Merged trigger "updateAvgMoodOnAccount" on after update,after delete
            if(instOFContact.MasterRecordId != NULL){
               updateMergeChckboxId.add(instOFContact.MasterRecordId);
            }
        }
         //udita : TICS-409
         if(updateMergeChckboxId.size() > 0 && Boolean.valueOf(Label.updateMergeChckboxOnParentContact)){
            updateMergeChckboxOnParentContact(updateMergeChckboxId);
        }
            
        //}
        //HSR : 16Feb2018: Stop Contact Merge if the Master Contact has value in "Creation Source System External ID" field.............  
        if(masterContactIdSet.size()>0){
            For(Contact masterContact : [SELECT Id,Creation_Source_System_External_ID__c FROM Contact WHERE Id IN : masterContactIdSet])
            {
                if(String.IsNotBlank(masterContact.Creation_Source_System_External_ID__c))
                    masterContact.addError(errorMessage);
            }
        }
        //............ENDS HERE.............................
        //HSR : 11th June2018 : Contact Merging Calls from SF to CVII
        Boolean MethodIsActive = ExecuteMethodHelper.isActive('SFCVIIMerge');
        if(MethodIsActive || Test.isRunningTest())
        {
            Map<Id,Id> deletedIdVsMasterId = new Map<Id,Id>();
            for(Contact instOFContact : oldMapValues.Values()){
                if(instOFContact.MasterRecordId!=null){
                    deletedIdVsMasterId.put(instOFContact.Id,instOFContact.MasterRecordId);
                }
            }
            if(!deletedIdVsMasterId.isEmpty()){
                MergingCallsFromSFtoCVII.sendIdToCVII(deletedIdVsMasterId,'Contact');
            }
        }
        //..................ENDS HERE..............
        List<Account> lstAccount = new List<Account>();
        
        if(mapAccIdStatus.keyset().size()>0)
            lstAccount = [SELECT id, CT_Account_Status__c, (SELECT id, AccountId, CT_Contact_Status__c FROM Contacts WHERE CT_Contact_Status__c != null) FROM Account WHERE Id =: mapAccIdStatus.keyset() AND CT_Account_Status__c NOT IN ('I - Recycle', 'J - Trash')];
        
        List<Account> lstAccSec = new List<Account>();
        
        for(Account lstAcc : lstAccount){    
            Integer tempVarSec = 0;
            if(lstAcc.Contacts.size()>0){
                for(Contact instOfCont : lstAcc.Contacts){
                    
                    Integer tempVarPriorVal;
                    if(instOfCont.CT_Contact_Status__c != null || instOfCont.CT_Contact_Status__c != ' ')
                        tempVarPriorVal = priorityMap.get(instOfCont.CT_Contact_Status__c);
                    
                    if(tempVarSec < tempVarPriorVal){
                        tempVarSec = tempVarPriorVal;
                    }
                    
                }
                lstAcc.CT_Account_Status__c = reversePriorMap.get(tempVarSec);
                lstAccSec.add(lstAcc);
            }else if(lstAcc.Contacts.size() == 0){
                lstAcc.CT_Account_Status__c = '';
                lstAccSec.add(lstAcc);
            }
        }
        
        if(lstAccSec.size()>0){
            BoolContactHelperClass.boolVar = false;
            update lstAccSec;
        }
        //Merged trigger "AccountStatusCTupdate"
        
        //Merged trigger "updateAvgMoodOnAccount" on after update,after delete
        List<Account> lstAccountSix = new List<Account>();
        
        if(mapContIdAccount.keySet().size()>0)
            lstAccountSix = [SELECT Id,Client_Mood_Rating__c,(SELECT Id,Mood_Level__c FROM Contacts WHERE Mood_Level__c != null) FROM Account WHERE Id =: mapContIdAccount.keySet()];
        
        List<Account> lstAccountEight = new List<Account>();
        
        for(Account instAcc : lstAccountSix){
            if(instAcc.Contacts.Size() > 0){
                Integer intContNo = instAcc.Contacts.Size();
                Decimal intMoodTotal = 0;
                for(Contact instContact : instAcc.Contacts){
                    intMoodTotal = intMoodTotal + instContact.Mood_Level__c; 
                }
                instAcc.Client_Mood_Rating__c = intMoodTotal/intContNo;
                lstAccountEight.add(instAcc);
            }else if(instAcc.Contacts.Size() == 0){
                instAcc.Client_Mood_Rating__c = 0;
                lstAccountEight.add(instAcc);
            }
        }
        
        if(lstAccountEight.Size()>0)
            update lstAccountEight;
        //Merged trigger "updateAvgMoodOnAccount" on after update,after delete
        
        //Merged trigger "AccountStatus"
        
        List<Account> lstAccountThir = new List<Account>();
        
        if(mapAccIdStatusEvent.keyset().size()>0)
            lstAccountThir = [SELECT id, Event_Account_Status__c, (SELECT id, AccountId, Event_Contact_Status__c FROM Contacts WHERE Event_Contact_Status__c != null) FROM Account WHERE Id =: mapAccIdStatusEvent.keyset()];
        
        List<Account> lstAccForth = new List<Account>();
        
        for(Account lstAcc : lstAccountThir){    
            Integer tempVarSec = 0;
            if(lstAcc.Contacts.size()>0){
                for(Contact instOfCont : lstAcc.Contacts){
                    
                    Integer tempVarPriorVal;
                    if(instOfCont.Event_Contact_Status__c != null || instOfCont.Event_Contact_Status__c != ' ')
                        tempVarPriorVal = priorityMap.get(instOfCont.Event_Contact_Status__c);
                    
                    if(tempVarSec < tempVarPriorVal){
                        tempVarSec = tempVarPriorVal;
                    }
                    
                }
                lstAcc.Event_Account_Status__c = reversePriorMap.get(tempVarSec);
                lstAccForth.add(lstAcc);
            }else if(lstAcc.Contacts.size() == 0){
                lstAcc.Event_Account_Status__c = '';
                lstAccForth.add(lstAcc);
            }
        }
        
        if(lstAccForth.size()>0)
            update lstAccForth;
        //Merged trigger "AccountStatus"
        
        //Merged trigger "AccountStatusTMupdate"
        List<Account> lstAccountFifth = new List<Account>();
        
        if(mapAccIdStatusTM.keyset().size()>0)
            lstAccountFifth = [SELECT Id, TM_Account_Status__c, (SELECT Id, AccountId, TM_Contact_Status__c FROM Contacts WHERE TM_Contact_Status__c != null) FROM Account WHERE Id =: mapAccIdStatusTM.keyset() AND TM_Account_Status__c NOT IN ('I - Recycle', 'J - Trash')];
        
        List<Account> lstAccSix = new List<Account>();
        
        for(Account lstAcc : lstAccountFifth){    
            Integer tempVarSec = 0;
            if(lstAcc.Contacts.size()>0){
                for(Contact instOfCont : lstAcc.Contacts){
                    
                    Integer tempVarPriorVal = priorityMap.get(instOfCont.TM_Contact_Status__c);
                    
                    if(tempVarSec < tempVarPriorVal){
                        tempVarSec = tempVarPriorVal;
                    }
                    
                }
                lstAcc.TM_Account_Status__c = reversePriorMap.get(tempVarSec);
                lstAccSix.add(lstAcc);
            }else if(lstAcc.Contacts.size() == 0){
                lstAcc.TM_Account_Status__c = '';
                lstAccSix.add(lstAcc);
            }
        }
        
        if(lstAccSix.size()>0){
            BoolContactHelperClass.boolVar = false;  
            update lstAccSix;
        }
        //Merged trigger "AccountStatusTMupdate"
    }
    public void OnUndelete(List<Contact> newValues){
        
    }
    //udita : TICS-409
    @future
    public static void updateMergeChckboxOnParentContact(set<id> conIds){
    List<contact> conList = new List<Contact>();
      for(Contact c : [select id,Contact_Merged__c from contact where id in : conIds]){
          c.Contact_Merged__c  = TRUE;
          conList.add(c);
          
      }              
      if(conList.size() > 0){
          update conList;
      }
    }
    /*Added By : AT : 21 Nov 2017 : */
    public static void createCSNPasskeyIQTask(List<Contact> contactCSNPassList,List<Contact> contactCSNList,List<Contact> contactPassKeyList,List<Contact> contactIQList){
        System.debug('Test'+contactCSNList);
        User userObj = [SELECT Id FROM User WHERE Name = 'Lead Management (SOPs)' LIMIT 1];
        Task taskObj = new Task();
        List<Task> taskObjInsertList = new List<Task>();
        if(contactCSNPassList.size()>0)
        {
            String CSNPVal;
            String PIVal;
            For(Contact conObj : contactCSNPassList)
            {
                if(conObj.Purchasing_Interest_CSNP__c != null)
                    CSNPVal = conObj.Purchasing_Interest_CSNP__c.SubString(0,1);
                if(conObj.Purchasing_Interest_PK__c != null)
                    PIVal = conObj.Purchasing_Interest_PK__c.SubString(0,1);
                taskObj = new Task();
                
                String subjectVar = '';
                if(conObj.Attended__c == 'CSG')
                {
                    subjectVar = 'Attended CSG VS & Passkey Interest ('+CSNPVal+','+PIVal+')';
                }
                else if(conObj.Attended__c == 'Training Workshop')
                {
                    subjectVar = 'Attended Training Workshop VS & Passkey Interest ('+CSNPVal+','+PIVal+')';
                }
                taskObj.Subject = subjectVar;
                
                //taskObj.Subject = 'Attended CSG VS & Passkey Interest ('+CSNPVal+','+PIVal+')';
                taskObj.ActivityDate = System.today().addDays(15);
                taskObj.Status = 'Not Started';
                taskObj.Priority = 'High';
                taskObj.OwnerId = userObj.Id;
                taskObj.WhoId=conObj.Id;
                taskObjInsertList.add(taskObj);
            }
        }
        if(contactCSNList.size()>0)
        {
            String CSNVal;
            String PIVal;
            For(Contact conObj : contactCSNList)
            {
                if(conObj.Purchasing_Interest_CSNP__c != null)
                    CSNVal = conObj.Purchasing_Interest_CSNP__c.SubString(0,1);
                If((Integer.ValueOf(CSNVal) >=3 && Integer.ValueOf(CSNVal) <=5) && conObj.Attended__c == 'OD/PS')
                {
                    taskObj = new Task();
                    taskObj.Subject = 'Attended Event OD/PS ('+CSNVal+' CSNPI)';
                    taskObj.ActivityDate = System.today().addDays(15);
                    taskObj.Status = 'Not Started';
                    taskObj.Priority = 'High';
                    taskObj.OwnerId = userObj.Id;
                    taskObj.WhoId=conObj.Id;
                    taskObjInsertList.add(taskObj);
                }
                Else If((Integer.ValueOf(CSNVal) >=3 && Integer.ValueOf(CSNVal) <=5) && (conObj.Attended__c == 'CSG' || conObj.Attended__c == 'Training Workshop'))
                {
                    taskObj = new Task();
                    String subjectVar = '';
                    if(conObj.Attended__c == 'CSG')
                    {
                        subjectVar = 'Attended CSG VS Interest ('+CSNVal+')';
                    }
                    else if(conObj.Attended__c == 'Training Workshop')
                    {
                        subjectVar = 'Attended Training Workshop VS Interest ('+CSNVal+')';
                    }
                    taskObj.Subject = subjectVar;
                    taskObj.ActivityDate = System.today().addDays(15);
                    taskObj.Status = 'Not Started';
                    taskObj.Priority = 'High';
                    taskObj.OwnerId = userObj.Id;
                    taskObj.WhoId=conObj.Id;
                    taskObjInsertList.add(taskObj);
                }
            }
        }
        if(contactPassKeyList.size()>0)
        {
            String PIVal;
            For(Contact conObj : contactPassKeyList){
                if(conObj.Purchasing_Interest_PK__c != null)
                    PIVal = conObj.Purchasing_Interest_PK__c.SubString(0,1);
                taskObj = new Task();
                
                String subjectVar = '';
                if(conObj.Attended__c == 'CSG')
                {
                    subjectVar = 'Attended CSG Passkey Interest ('+PIVal+')';
                }
                else if(conObj.Attended__c == 'Training Workshop')
                {
                    subjectVar = 'Attended Training Workshop Passkey Interest ('+PIVal+')';
                }
                taskObj.Subject = subjectVar;
                
                //taskObj.Subject = 'Attended CSG Passkey Interest ('+PIVal+')';
                taskObj.ActivityDate = System.today().addDays(15);
                taskObj.Status = 'Not Started';
                taskObj.Priority = 'High';
                taskObj.OwnerId = userObj.Id;
                taskObj.WhoId=conObj.Id;
                taskObjInsertList.add(taskObj);
            }
        }
        if(contactIQList.size()>0){
            String IQVal;
            For(Contact conObj : contactIQList){
                if(conObj.Purchasing_Interest_Inquisium__c != null)
                    IQVal = conObj.Purchasing_Interest_Inquisium__c.SubString(0,1);
                taskObj = new Task();
                String subjectVar = '';
                if(conObj.Attended__c == 'CSG')
                {
                    subjectVar = 'Attended CSG IQ Interest ('+IQVal+')';
                }
                else if(conObj.Attended__c == 'Training Workshop')
                {
                    subjectVar = 'Attended Training Workshop IQ Interest ('+IQVal+')';
                }
                taskObj.Subject = subjectVar;
                
                //taskObj.Subject = 'Attended CSG IQ Interest ('+IQVal+')';
                taskObj.ActivityDate = System.today().addDays(15);
                taskObj.Status = 'Not Started';
                taskObj.Priority = 'High';
                taskObj.OwnerId = userObj.Id;
                taskObj.WhoId=conObj.Id;
                taskObjInsertList.add(taskObj);
            }
        }
        System.debug('taskObjInsertList'+taskObjInsertList);
        insert taskObjInsertList;
        if(taskObjInsertList.size()>0)
            Database.Insert(taskObjInsertList,false);
    }
    /*
Desc: Move the updateAvgMoodOnAccount trigger code to below method and deactivate the trigger
Author :kumud 
Project :Code Cleanup
*/
    
    public void updateMoodOnAccount(List<Contact> listContact,Map<Id,Contact> oldMap,Map<Id,Contact> newMap){
        
        Map<Id,Contact> contactMap = new Map<Id,Contact>();
        Map<Id,Double> MapAvgMoodValues = new Map<Id,Double>();
        List<Account> listAccount = new List<Account>();
        AggregateResult[] groupedResults = new AggregateResult[]{};
            
            for(Contact instCon : listContact){
                Contact beforeUpdateMood = OldMap.get(instCon.id);
                if(instCon.AccountId!=null && (beforeUpdateMood.Mood_Level__c !=instCon.Mood_Level__c))
                    contactMap.put(instCon.AccountId,instCon);
            }// end of loop
        if(!contactMap.isEmpty()){
            
            groupedResults = [SELECT AccountId accId, AVG(Mood_Level__c) FROM Contact where AccountID in : contactMap.keySet() GROUP BY AccountId];
            
        }
        
        for (AggregateResult ar : groupedResults)  {
            
            MapAvgMoodValues.put(String.valueof(ar.get('accId')),Double.valueof(ar.get('expr0')));
        }
        
        for(Id accId:MapAvgMoodValues.keySet()){
            
            Account instAcc=new Account();
            instAcc.id=accId;
            instAcc.Client_Mood_Rating__c=MapAvgMoodValues.get(accId);
            listAccount.add(instAcc);
            
        }
        
        if(!listAccount.isEmpty()){
            
            update listAccount;
            
        }// end of if 
    }// end of method  
}