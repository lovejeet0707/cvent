/* ===============================
AUTHOR     :     Udita Dwivedi
CREATED DATE   : 15 April 2018
PURPOSE     :    class called from lead/contact/account/user trigger to create GDPR Repository data when its marked GDPR True
TEST CLASS :     testGDPR 
============================= 
*/
public class trg_GDPRContactTrg{
   
   // Method to insert GDPR record when a contact is marked is GDPR True
  public static void insertGDPR_contact(Map<Id,Contact>newMapValues ,Map<Id,Contact> oldMapValues){
   list<GDPR_Central_Repository__c> insertGDPR = new list<GDPR_Central_Repository__c>();
   set<id> contactIds= new set<id>();
   set<string> contactEmailIds= new set<string>();   // to fetch converted leads with these email id's
   
   map<id,id> contactGDPR_Map = new map<id,id>();
    for(contact conObj :newMapValues.values()){
       contact conOld =  oldMapValues.get(conObj.id);  
       if(conObj.Is_GDPR__c != conOld.Is_GDPR__c && conObj.Is_GDPR__c == true){
            contactIds.add(conObj.id);
            if(!String.IsBlank(conOld.email)){
              contactEmailIds.add(conOld.email);
            }
            if(!String.IsBlank(conOld.Alternate_Email__c)){ 
              contactEmailIds.add(conOld.Alternate_Email__c);
            }
            GDPR_Central_Repository__c GDPRRec = new GDPR_Central_Repository__c();
            GDPRRec.Account_Name__c = conOld.SF_Account_Name__c;
            GDPRRec.Account_Id__c = conOld.AccountId;
            GDPRRec.Email__c = conOld.Email;
            GDPRRec.Firstname__c = conOld.FirstName;
            GDPRRec.Id__c = conObj.Id;
            GDPRRec.Is_GDPR__c = conObj.Is_GDPR__c;
            GDPRRec.LastName__c = conOld.LastName;
            GDPRRec.MobilePhone__c = conOld.MobilePhone;
            GDPRRec.Name__c = conOld.Name;
            GDPRRec.Phone__c = conOld.Phone;
            GDPRRec.RecordType_Id__c = conOld.RecordTypeId;
            GDPRRec.Alternate_Email__c  = conOld.Alternate_Email__c ;
            GDPRRec.sObject_type__c = 'Contact';
            GDPRRec.Source__c = 'Salesforce';
            GDPRRec.Fax__c = conOld.Fax ;
            GDPRRec.Asst_Phone__c =conOld.AssistantPhone ;
            GDPRRec.Home_Phone__c=conOld.HomePhone;
            GDPRRec.Salutation__c=conOld.Salutation;
            GDPRRec.Other_Phone__c=conOld.OtherPhone;
            GDPRRec.Title__c=conOld.Title;
            GDPRRec.Job_Function__c=conOld.Job_Function__c;
            GDPRRec.Department__c=conOld.Department;
            GDPRRec.Mailing_City__c=conOld.MailingCity;
            GDPRRec.Mailing_Country__c=conOld.MailingCountry;
            GDPRRec.Mailing_State__c=conOld.MailingState;
            GDPRRec.Mailing_Street__c=conOld.MailingStreet;
            GDPRRec.Mailing_Postal_Code__c=conOld.MailingPostalCode;
            GDPRRec.mkto2_Inferred_Company__c=conOld.mkto2__Inferred_Company__c;
            GDPRRec.Inferred_Country__c=conOld.mkto2__Inferred_Country__c;
            GDPRRec.mkto71_Inferred_Country__c=conOld.mkto71_Inferred_Country__c;
            GDPRRec.Inferred_Metropolitan_Area__c=conOld.mkto2__Inferred_Metropolitan_Area__c;
            GDPRRec.Inferred_Phone_Area_Code__c=conOld.mkto2__Inferred_Phone_Area_Code__c;
            GDPRRec.Inferred_Postal_Code__c=conOld.mkto2__Inferred_Postal_Code__c;
            GDPRRec.mkto71_Inferred_Postal_Code__c=conOld.mkto71_Inferred_Postal_Code__c;
            GDPRRec.Inferred_State_Region__c=conOld.mkto2__Inferred_State_Region__c;
            GDPRRec.mkto71_Inferred_State_Region__c=conOld.mkto71_Inferred_State_Region__c;
            GDPRRec.Inferred_City__c=conOld.mkto2__Inferred_City__c;
            GDPRRec.Job_Rank__c=conOld.Job_Rank__c;
            //GDPRRec.LinkedIn_ID__c=conOld.LinkedIn_ID__c;//UD:Commented for FP:4thApril
            GDPRRec.LinkedIn_Company_Id__c=conOld.LID__LinkedIn_Company_Id__c;
            GDPRRec.LinkedIn_Member_Token__c=conOld.LID__LinkedIn_Member_Token__c;
            GDPRRec.LinkedIn_URL__c=conOld.LinkedIn_URL__c;
            GDPRRec.Phone_Ext__c=conOld.Phone_Extension__c   ;
            GDPRRec.Preferred_Language__c=conOld.Preferred_Language__c;
            //GDPRRec.Preferred_Language_Verified__c=conOld.Preferred_Language_Verified__c;//UD:Commented for FP:4thApril
            GDPRRec.Twitter_URL__c=conOld.Twitter_URL__c;
            GDPRRec.Website__c=conOld.Website__c;
            insertGDPR.add(GDPRRec);
      } 
    }
    if(insertGDPR.size()>0){
      //Fetching the schema of the External Field to use it in the Upsert function......
        Schema.SObjectField externalId = GDPR_Central_Repository__c.Fields.Id__c;
        database.upsert(insertGDPR,externalId);
    } 
    // code to fetch user related to that contact and marking them as GDPR true
    list <user> userList = new list <user>();
    if(contactIds.size() >0){
       userList = [select id,FirstName,LastName,Username,MobilePhone,IsPortalSelfRegistered,IsActive,Email,ContactId,Is_GDPR__c,Phone,Title from user where ContactId in : contactIds and IsPortalEnabled = true];
    }
    set<id> userIds = new set<id>();
    if(userList.size() > 0){
     for(user u : userList){
       userIds.add(u.id);
     }
    }
    if(userList.size() > 0 && contactIds.size() > 0){
     //if(System.IsBatch() == false && System.isFuture() == false)
      insertGDPR_User(userIds,contactIds,userList);   
    }   
    
    //code to fetch the converted leads from contacts email ids and mark them GDPR true
    
    
    system.debug('----*****contactEmailIds////'+ contactEmailIds);
    if(contactEmailIds.size() > 0){
        list <lead> convertedLeadList = new list <lead>();
        convertedLeadList = [select id,email,Alternate_Email__c,IsConverted from lead where (email in : contactEmailIds or Alternate_Email__c in : contactEmailIds) and IsConverted = true];
        system.debug('----*****convertedLeadList////'+ convertedLeadList);
        for(lead instanceOfLead : convertedLeadList){
          instanceOfLead.Is_GDPR__c = true;
        }   
        if(convertedLeadList.size() > 0){
          update convertedLeadList;
        }   
    }
    
  }  
  
   // Method to insert GDPR record when a Person Account is marked is GDPR True
   public static void insertGDPR_Account(Map<Id,Account> newMapValues,Map<Id,Account> oldMapValues){  
       list<GDPR_Central_Repository__c> insertGDPR = new list<GDPR_Central_Repository__c>();
       set<id> AccountIds= new set<id>();
       map<id,id> AccountGDPR_Map = new map<id,id>();
       for(Account accObj :newMapValues.values()){
           Account accOld =  oldMapValues.get(accObj.id);     
           if(accObj.id == accOld.id && accObj.Is_GDPR__pc  != accOld.Is_GDPR__pc  && accObj.Is_GDPR__pc  == true){
                AccountIds.add(accObj.id);
                GDPR_Central_Repository__c GDPRRec = new GDPR_Central_Repository__c();
                GDPRRec.Account_Name__c = accOld.Name;
                GDPRRec.Account_Id__c = accOld.Id;
                GDPRRec.Email__c = accOld.PersonEmail ;
                GDPRRec.Firstname__c = accOld.FirstName;
                GDPRRec.Id__c = accObj.Id;
                GDPRRec.Is_GDPR__c  = accObj.Is_GDPR__pc ;
                GDPRRec.LastName__c = accOld.LastName;
                GDPRRec.MobilePhone__c = accOld.PersonMobilePhone;
                GDPRRec.Name__c = accOld.Name;
                GDPRRec.Phone__c = accOld.Phone;
                GDPRRec.RecordType_Id__c = accOld.RecordTypeId;
                GDPRRec.Alternate_Email__c  = accOld.Alternate_Email__pc  ;
                GDPRRec.sObject_type__c = 'Person Account';
                GDPRRec.Source__c = 'Salesforce';
                insertGDPR.add(GDPRRec);
           }      
        }
        if(insertGDPR.size()>0){
          //Fetching the schema of the External Field to use it in the Upsert function......
            Schema.SObjectField externalId = GDPR_Central_Repository__c.Fields.Id__c;
            database.upsert(insertGDPR,externalId);
        } 
       
     }   
   // Method to insert GDPR record when a User is marked as GDPR True
  
   public static void insertGDPR_User(set<id> userIds,set<id> contactIds,list<user> newUserList){
   //  list<user> newUserList = new list<user>();
  //   newUserList=[select id,FirstName,LastName,Username,MobilePhone,IsPortalSelfRegistered,IsActive,Email,ContactId,Is_GDPR__c,Phone,Title from user where id in :userIds and  ContactId in : contactIds and IsPortalEnabled = true];
     list<GDPR_Central_Repository__c> insertGDPR = new list<GDPR_Central_Repository__c>();
   
     for(User UserObj :newUserList){
            GDPR_Central_Repository__c GDPRRec = new GDPR_Central_Repository__c();
            GDPRRec.Email__c = UserObj.Email;
            GDPRRec.Firstname__c = UserObj.FirstName;
            GDPRRec.Id__c = UserObj.Id;
            GDPRRec.Is_GDPR__c = true;//UserObj.Is_GDPR__c;
            GDPRRec.LastName__c = UserObj.LastName;
            GDPRRec.MobilePhone__c = UserObj.MobilePhone;
            GDPRRec.Name__c = UserObj.Username;
            GDPRRec.Phone__c = UserObj.Phone;           
            GDPRRec.sObject_type__c = 'User';
            GDPRRec.Source__c = 'Salesforce';
            GDPRRec.Title__c= UserObj.Title ;
            insertGDPR.add(GDPRRec);  
     }
     
     if(insertGDPR.size()>0){
     //Fetching the schema of the External Field to use it in the Upsert function......
        Schema.SObjectField externalId = GDPR_Central_Repository__c.Fields.Id__c;
        database.upsert(insertGDPR,externalId);

      //insert insertGDPR;
     }
    if(newUserList.size() > 0){
      GDPRCentralRepositoryHandler_User.updateGDPR_User( userIds,contactIds);
     } 
     
   }
   
// Method to insert GDPR record when a Lead is marked is GDPR True   
   public static void insertGDPR_Lead(Map<Id,Lead>oldMapValues ,Map<Id,Lead> newMapValues ){  
     list<GDPR_Central_Repository__c> insertGDPR = new list<GDPR_Central_Repository__c>();
     set<id> leadIds = new set<id>();
    for(Lead LeadObj :newMapValues.values()){
      Lead LeadOld=  oldMapValues.get(LeadObj.id);    
        if(LeadObj.Is_GDPR__c != LeadOld.Is_GDPR__c && LeadObj.Is_GDPR__c == true){
            leadIds.add(LeadObj.Id);
            GDPR_Central_Repository__c GDPRRec = new GDPR_Central_Repository__c();
            if(LeadObj.IsConverted == true){
              GDPRRec.Converted_Lead__c = true;  
            }
           // GDPRRec.Account_Name__c = LeadOld.DSE__DS_Account__r.name;
         //   GDPRRec.Account_Id__c = LeadOld.DSE__DS_Account__c;
            GDPRRec.Email__c = LeadOld.Email;
            GDPRRec.Alternate_Email__c = LeadOld.Alternate_Email__c ;
            GDPRRec.Firstname__c = LeadOld.FirstName;
            GDPRRec.Id__c = LeadObj.Id;
            GDPRRec.Is_GDPR__c = LeadObj.Is_GDPR__c;
            GDPRRec.LastName__c = LeadOld.LastName;
            GDPRRec.MobilePhone__c = LeadOld.MobilePhone;
            GDPRRec.Name__c = LeadOld.Name;
            GDPRRec.Phone__c = LeadOld.Phone;
            GDPRRec.RecordType_Id__c = LeadOld.RecordTypeId;
            GDPRRec.sObject_type__c = 'Lead';
            GDPRRec.Source__c = 'Salesforce';
             GDPRRec.Fax__c = LeadOld.Fax ;
           // GDPRRec.Asst_Phone__c =LeadOld.AssistantPhone ;
           // GDPRRec.Home_Phone__c=LeadOld.HomePhone;
            GDPRRec.Salutation__c=LeadOld.Salutation;
            GDPRRec.Other_Phone__c=LeadOld.Other_Phone__c;
            GDPRRec.Title__c=LeadOld.Title;
            GDPRRec.Job_Function__c=LeadOld.Job_Function__c;
            //GDPRRec.Department__c=LeadOld.Department;
            GDPRRec.Mailing_City__c=LeadOld.City;
            GDPRRec.Mailing_Country__c=LeadOld.Country;
            GDPRRec.Mailing_State__c=LeadOld.State;
            GDPRRec.Mailing_Street__c=LeadOld.Street;
            GDPRRec.Mailing_Postal_Code__c=LeadOld.PostalCode;
            GDPRRec.mkto2_Inferred_Company__c=LeadOld.mkto2__Inferred_Company__c;
            GDPRRec.Inferred_Country__c=LeadOld.mkto2__Inferred_Country__c;
            GDPRRec.mkto71_Inferred_Country__c=LeadOld.mkto71_Inferred_Country__c;
            GDPRRec.Inferred_Metropolitan_Area__c=LeadOld.mkto2__Inferred_Metropolitan_Area__c;
            GDPRRec.Inferred_Phone_Area_Code__c=LeadOld.mkto2__Inferred_Phone_Area_Code__c;
            GDPRRec.Inferred_Postal_Code__c=LeadOld.mkto2__Inferred_Postal_Code__c;
            GDPRRec.mkto71_Inferred_Postal_Code__c=LeadOld.mkto71_Inferred_Postal_Code__c;
            GDPRRec.Inferred_State_Region__c=LeadOld.mkto2__Inferred_State_Region__c;
            GDPRRec.mkto71_Inferred_State_Region__c=LeadOld.mkto71_Inferred_State_Region__c;
            GDPRRec.Inferred_City__c=LeadOld.mkto2__Inferred_City__c;
            GDPRRec.Job_Rank__c=LeadOld.Job_Rank__c;
           // GDPRRec.LinkedIn_ID__c=LeadOld.LinkedIn_ID__c;//HSR:Commented for FP:4thApril
            GDPRRec.LinkedIn_Company_Id__c=LeadOld.LID__LinkedIn_Company_Id__c;
            GDPRRec.LinkedIn_Member_Token__c=LeadOld.LID__LinkedIn_Member_Token__c;
            //GDPRRec.LinkedIn_URL__c=LeadOld.LinkedIn_URL__c;//HSR:Commented for FP:4thApril          
            //GDPRRec.Twitter_URL__c=LeadOld.Twitter_URL__c;//HSR:Commented for FP:4thApril
            GDPRRec.Website__c=LeadOld.Website;
            insertGDPR.add(GDPRRec);
       }      
    }
    if(insertGDPR.size()>0){
      //Fetching the schema of the External Field to use it in the Upsert function......
        Schema.SObjectField externalId = GDPR_Central_Repository__c.Fields.Id__c;
      database.upsert(insertGDPR,externalId);
      //insert insertGDPR;
    }     
   
   }
   
   //Description : To validate email from here before creating/updating Contact and Lead Email.....
   public static Set<String> returnGDPREmail(Set<String> emailSet,String sObjectName){
        Set<String> GDPREmailSet = new Set<String>();
        //Creating dynamic query on GDPR Central Repository........
        String query = 'SELECT Email__c,Alternate_Email__c FROM GDPR_Central_Repository__c WHERE ';
        //Creating dynamic query on GDPR Central Repository........ 
        query = query + ' (Email__c IN : emailSet or Alternate_Email__c  IN : emailSet)';

        query = query + ' AND Is_GDPR__c =TRUE';
        
        System.debug('query*********'+query);
        For(GDPR_Central_Repository__c GDPRData : Database.query(query))
        {
            GDPREmailSet.add(GDPRData.Email__c);
            GDPREmailSet.add(GDPRData.Alternate_Email__c);
        }
        
        return GDPREmailSet;
    
    }
    // Method called in Lead Trigger to update lead fields when Is GDPR is set to true 
    public static void OnBeforeUpdate(Map<Id,Lead> oldMapValues,Map<Id,Lead> newMapValues){ 
        
        //GDPR code starts: Udita
        Lead LeadOld;
        For(Lead LeadObj : newMapValues.values())
        {   LeadOld = oldMapValues.get(LeadObj.Id);
            if(LeadObj.Is_GDPR__c && LeadOld.Is_GDPR__c != LeadObj.Is_GDPR__c)
            {
                            LeadObj.FirstName = 'GDPR First Name';
                            LeadObj.LastName = 'GDPR Last Name';
                            LeadObj.Email = 'GDPR@GDPR.com';
                            LeadObj.Alternate_Email__c = 'GDPR123@GDPR.com';
                            LeadObj.Phone = '';
                            LeadObj.MobilePhone = '';
                            LeadObj.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('GDPR').getRecordTypeId();
                            LeadObj.Fax ='';
                            //LeadObj.HomePhone;
                            LeadObj.Salutation='';
                            LeadObj.Other_Phone__c='';
                            LeadObj.Title='';
                            LeadObj.Job_Function__c='';
                            LeadObj.City='';
                            LeadObj.Country='';
                            LeadObj.State='';
                            LeadObj.Street='';
                            LeadObj.PostalCode='';
                            LeadObj.mkto2__Inferred_Company__c='';
                            LeadObj.mkto2__Inferred_Country__c='';
                            LeadObj.mkto71_Inferred_Country__c='';
                            LeadObj.mkto2__Inferred_Metropolitan_Area__c='';
                            LeadObj.mkto2__Inferred_Phone_Area_Code__c='';
                            LeadObj.mkto2__Inferred_Postal_Code__c='';
                            LeadObj.mkto71_Inferred_Postal_Code__c='';
                            LeadObj.mkto2__Inferred_State_Region__c='';
                            LeadObj.mkto71_Inferred_State_Region__c='';
                            LeadObj.mkto2__Inferred_City__c='';
                            LeadObj.Job_Rank__c='';
                            //LeadObj.LinkedIn_ID__c;
                            LeadObj.LID__LinkedIn_Company_Id__c='';
                            LeadObj.LID__LinkedIn_Member_Token__c='';
                            //LeadObj.LinkedIn_URL__c='';//HSR:Commented for FP:4thApril
                            //LeadObj.Twitter_URL__c='';//HSR:Commented for FP:4thApril
                            LeadObj.Website='';
            }
             if(!LeadObj.Is_GDPR__c && LeadOld.Is_GDPR__c != LeadObj.Is_GDPR__c)
            {
                LeadObj.RecordTypeId = null;
            }
        }
       //GDPR code ends: Udita
     }
     
     // Method called in Lead Trigger to Validate before creating if the Lead Email is not under GDPR request.....
     public static void OnBeforeInsert(List<Lead> newValues){   
   //GDPR : Udita 
   // Validate before creating if the Lead Email is not under GDPR request.....
        Set<String> emailSetToValidate = new Set<String>();
        Set<String> GDPREmailSet = new Set<String>();
        //Ends here.............
                                
                //trigger.new for loop (before insert)
                For(Lead instOFLead : newValues){
                if(String.IsNotBlank(instOFLead.Email))
                    emailSetToValidate.add(instOFLead.Email);
                if(String.IsNotBlank(instOFLead.Alternate_Email__c ))
                    emailSetToValidate.add(instOFLead.Alternate_Email__c );
                }
                string nameuser = UserInfo.getUserName();                                
                if(emailSetToValidate.size()>0 && nameuser!='marketo@cvent.com')
                    GDPREmailSet = returnGDPREmail(emailSetToValidate,'Lead');
                                //...................................................                        
                                
        For(Lead leadObj : newValues)
        {
            //HSR: Validate before creating if the Lead Email is not under GDPR request.....
            if(GDPREmailSet.size()>0 && ((String.IsNotBlank(leadObj.Email) && GDPREmailSet.contains(leadObj.Email)) || (String.IsNotBlank(leadObj.Alternate_Email__c ) && GDPREmailSet.contains(leadObj.Alternate_Email__c ))))
            {
                leadObj.addError('You cannot update Email on this Lead as its email is GDPR processed.');
            }
            //Ends here.............
        }
        //GDPR CODE ENDS: Udita  
        
    }
    // method to insert gdpr rep record when case is marked is gdpr true
    public static void insertGDPR_case(Map<Id,case>newMapValues ,Map<Id,case> oldMapValues ){  
     list<GDPR_Central_Repository__c> insertGDPR = new list<GDPR_Central_Repository__c>();
    for(case caseObj :newMapValues.values()){
      case caseOld=  oldMapValues.get(caseObj.id);    
        if(caseObj.Is_GDPR__c != caseOld.Is_GDPR__c && caseObj.Is_GDPR__c == true){
            GDPR_Central_Repository__c GDPRRec = new GDPR_Central_Repository__c();
            GDPRRec.Firstname__c= caseOld.SuppliedName;
            GDPRRec.Email__c = caseOld.SuppliedEmail;
            GDPRRec.Account_Name__c = caseOld.SuppliedCompany;
            GDPRRec.Are_you_a_Cvent_Customer__c   = caseOld.Are_you_a_Cvent_Customer__c ;
            GDPRRec.I_agree_to_term_and_condition__c  = caseOld.Agrrement__c;
            GDPRRec.Id__c = caseObj.Id;
            GDPRRec.Is_GDPR__c = caseObj.Is_GDPR__c;
            GDPRRec.RecordType_Id__c  = caseOld.RecordTypeId;
            GDPRRec.sObject_type__c = 'Case';
            GDPRRec.Source__c = 'Salesforce'; 
            GDPRRec.Case_Number__c = caseObj.CaseNumber;          
            insertGDPR.add(GDPRRec);
       }      
    }
    if(insertGDPR.size()>0){
      //Fetching the schema of the External Field to use it in the Upsert function......
      Schema.SObjectField externalId = GDPR_Central_Repository__c.Fields.Id__c;
      database.upsert(insertGDPR,externalId);
      //insert insertGDPR;
    }  
    
}

}