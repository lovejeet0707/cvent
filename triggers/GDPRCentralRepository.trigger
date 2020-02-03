/* ===============================
AUTHOR     :     Udita Dwivedi
CREATED DATE   : 17 April 2018
PURPOSE     :    It reverts the GDPR Record of contact/lead/account/user when isGDPR field in GDPR Rep is marked false..
TEST CLASS :    testGDPR  
============================= 
*/
trigger GDPRCentralRepository on GDPR_Central_Repository__c (after update) {
    List<Contact> conObjList = new List<Contact>();
    List<Case> caseObjList = new List<Case>();
    List<Lead> LeadObjList = new List<Lead>();
    List<User> UserObjList = new List<User>();
    Map<Id,GDPR_Central_Repository__c> contactIdMap = new Map<Id,GDPR_Central_Repository__c>();
    Map<Id,GDPR_Central_Repository__c> caseIdMap = new Map<Id,GDPR_Central_Repository__c>();
    Map<Id,GDPR_Central_Repository__c> LeadIdMap = new Map<Id,GDPR_Central_Repository__c>();
    Map<Id,GDPR_Central_Repository__c> UserIdMap = new Map<Id,GDPR_Central_Repository__c>();
    Set<Id> GDPRIdSet = new Set<Id>();
    Map<Id,GDPR_Central_Repository__c> accountIdMap = new Map<Id,GDPR_Central_Repository__c>();
    List<account> accObjList = new List<account>();
    
    Contact conObj = new Contact();
    For(GDPR_Central_Repository__c GDPRRec : trigger.new)
    {
        GDPR_Central_Repository__c GDPROld = trigger.oldMap.get(GDPRRec.Id);
        if(GDPROld.Is_GDPR__c != GDPRRec.Is_GDPR__c && !GDPRRec.Is_GDPR__c && GDPRRec.sObject_type__c =='Contact')
        {
            contactIdMap.put(GDPRRec.Id__c,GDPRRec);
        }
        else if(GDPROld.Is_GDPR__c != GDPRRec.Is_GDPR__c && !GDPRRec.Is_GDPR__c && GDPRRec.sObject_type__c =='Lead'){
            LeadIdMap.put(GDPRRec.Id__c,GDPRRec);
        }
         else if(GDPROld.Is_GDPR__c != GDPRRec.Is_GDPR__c && !GDPRRec.Is_GDPR__c && GDPRRec.sObject_type__c =='User'){
            GDPRIdSet.add(GDPRRec.Id);
        }
        else if(GDPROld.Is_GDPR__c != GDPRRec.Is_GDPR__c && !GDPRRec.Is_GDPR__c && GDPRRec.sObject_type__c =='Person Account'){
            accountIdMap.put(GDPRRec.Id__c,GDPRRec);
        }
        else if(GDPROld.Is_GDPR__c != GDPRRec.Is_GDPR__c && !GDPRRec.Is_GDPR__c && GDPRRec.sObject_type__c =='Case'){
            caseIdMap.put(GDPRRec.Id__c,GDPRRec);
        }
    }
 
     if(contactIdMap.size() > 0){
        For(GDPR_Central_Repository__c gdpr: contactIdMap.values()){
            contact conObj = new contact(id = gdpr.id__C);
            conObj.Email = contactIdMap.get(conObj.Id).Email__c;
            conObj.FirstName = contactIdMap.get(conObj.Id).Firstname__c;
            conObj.Is_GDPR__c = false;//contactIdMap.get(conObj.Id).Is_GDPR__c;
            conObj.LastName = contactIdMap.get(conObj.Id).LastName__c;
            conObj.MobilePhone = contactIdMap.get(conObj.Id).MobilePhone__c;
            conObj.Phone = contactIdMap.get(conObj.Id).Phone__c;
            conObj.Alternate_Email__c = contactIdMap.get(conObj.Id).Alternate_Email__c;
            conObj.Fax = contactIdMap.get(conObj.Id).Fax__c;
            conObj.AssistantPhone =contactIdMap.get(conObj.Id).Asst_Phone__c;
            conObj.HomePhone=contactIdMap.get(conObj.Id).Home_Phone__c;
            conObj.Salutation=contactIdMap.get(conObj.Id).Salutation__c;
            conObj.OtherPhone=contactIdMap.get(conObj.Id).Other_Phone__c;
            conObj.Title=contactIdMap.get(conObj.Id).Title__c;
            conObj.Job_Function__c=contactIdMap.get(conObj.Id).Job_Function__c;
            conObj.Department=contactIdMap.get(conObj.Id).Department__c;
            conObj.MailingCity=contactIdMap.get(conObj.Id).Mailing_City__c;
            conObj.MailingCountry=contactIdMap.get(conObj.Id).Mailing_Country__c;
            conObj.MailingState=contactIdMap.get(conObj.Id).Mailing_State__c;
            conObj.MailingStreet=contactIdMap.get(conObj.Id).Mailing_Street__c;
            conObj.MailingPostalCode=contactIdMap.get(conObj.Id).Mailing_Postal_Code__c;
            conObj.mkto2__Inferred_Company__c=contactIdMap.get(conObj.Id).mkto2_Inferred_Company__c;
            conObj.mkto2__Inferred_Country__c=contactIdMap.get(conObj.Id).Inferred_Country__c;
            conObj.mkto71_Inferred_Country__c=contactIdMap.get(conObj.Id).mkto71_Inferred_Country__c;
            conObj.mkto2__Inferred_Metropolitan_Area__c=contactIdMap.get(conObj.Id).Inferred_Metropolitan_Area__c;
            conObj.mkto2__Inferred_Phone_Area_Code__c=contactIdMap.get(conObj.Id).Inferred_Phone_Area_Code__c;
            conObj.mkto2__Inferred_Postal_Code__c=contactIdMap.get(conObj.Id).Inferred_Phone_Area_Code__c;
            conObj.mkto71_Inferred_Postal_Code__c=contactIdMap.get(conObj.Id).mkto71_Inferred_Postal_Code__c;
            conObj.mkto2__Inferred_State_Region__c=contactIdMap.get(conObj.Id).Inferred_State_Region__c;
            conObj.mkto71_Inferred_State_Region__c=contactIdMap.get(conObj.Id).mkto71_Inferred_State_Region__c;
            conObj.mkto2__Inferred_City__c=contactIdMap.get(conObj.Id).Inferred_City__c;
            conObj.Job_Rank__c=contactIdMap.get(conObj.Id).Job_Rank__c;
           // conObj.LinkedIn_ID__c=contactIdMap.get(conObj.Id).LinkedIn_ID__c;//UD:Commented for FP:4thApril
            conObj.LID__LinkedIn_Company_Id__c= contactIdMap.get(conObj.Id).LinkedIn_Company_Id__c;
            conObj.LID__LinkedIn_Member_Token__c=contactIdMap.get(conObj.Id).LinkedIn_Member_Token__c;
            conObj.LinkedIn_URL__c=contactIdMap.get(conObj.Id).LinkedIn_URL__c;
            conObj.Phone_Extension__c   =contactIdMap.get(conObj.Id).Phone_Ext__c;
            conObj.Preferred_Language__c=contactIdMap.get(conObj.Id).Preferred_Language__c;
            //conObj.Preferred_Language_Verified__c=  contactIdMap.get(conObj.Id).Preferred_Language_Verified__c;//UD:Commented for FP:4thApril
            //conObj.Time_Zone__c=contactIdMap.get(conObj.Id).Alternate_Email__c;
            conObj.Twitter_URL__c=contactIdMap.get(conObj.Id).Twitter_URL__c;
            conObj.Website__c=contactIdMap.get(conObj.Id).Website__c;
            conObj.RecordTypeId=null;
            conObjList.add(conObj);
        }
      }
   
    If(conObjList.size()>0){
        update conObjList;
    }
    
     if(LeadIdMap.size() > 0){
       For(GDPR_Central_Repository__c gdpr : LeadIdMap.values()){
            Lead LeadObj= new Lead(id = gdpr.id__C);
            LeadObj.Email = LeadIdMap.get(LeadObj.Id).Email__c;
            LeadObj.FirstName = LeadIdMap.get(LeadObj.Id).Firstname__c;
            LeadObj.Is_GDPR__c = false;//LeadtactIdMap.get(LeadObj.Id).Is_GDPR__c;
            LeadObj.LastName = LeadIdMap.get(LeadObj.Id).LastName__c;
            LeadObj.MobilePhone = LeadIdMap.get(LeadObj.Id).MobilePhone__c;
            LeadObj.Phone= LeadIdMap.get(LeadObj.Id).Phone__c;
            LeadObj.Fax = LeadIdMap.get(LeadObj.Id).Fax__c;           
            LeadObj.Salutation=LeadIdMap.get(LeadObj.Id).Salutation__c;
            LeadObj.Other_Phone__c=LeadIdMap.get(LeadObj.Id).Other_Phone__c;
            LeadObj.Title=LeadIdMap.get(LeadObj.Id).Title__c;
            LeadObj.Job_Function__c=LeadIdMap.get(LeadObj.Id).Job_Function__c;
            LeadObj.City=LeadIdMap.get(LeadObj.Id).Mailing_City__c;
            LeadObj.Country=LeadIdMap.get(LeadObj.Id).Mailing_Country__c;
            LeadObj.State=LeadIdMap.get(LeadObj.Id).Mailing_State__c;
            LeadObj.Street=LeadIdMap.get(LeadObj.Id).Mailing_Street__c;
            LeadObj.PostalCode=LeadIdMap.get(LeadObj.Id).Mailing_Postal_Code__c;
            LeadObj.mkto2__Inferred_Company__c=LeadIdMap.get(LeadObj.Id).mkto2_Inferred_Company__c;
            LeadObj.mkto2__Inferred_Country__c=LeadIdMap.get(LeadObj.Id).Inferred_Country__c;
            LeadObj.mkto71_Inferred_Country__c=LeadIdMap.get(LeadObj.Id).mkto71_Inferred_Country__c;
            LeadObj.mkto2__Inferred_Metropolitan_Area__c=LeadIdMap.get(LeadObj.Id).Inferred_Metropolitan_Area__c;
            LeadObj.mkto2__Inferred_Phone_Area_Code__c=LeadIdMap.get(LeadObj.Id).Inferred_Phone_Area_Code__c;
            LeadObj.mkto2__Inferred_Postal_Code__c=LeadIdMap.get(LeadObj.Id).Inferred_Phone_Area_Code__c;
            LeadObj.mkto71_Inferred_Postal_Code__c=LeadIdMap.get(LeadObj.Id).mkto71_Inferred_Postal_Code__c;
            LeadObj.mkto2__Inferred_State_Region__c=LeadIdMap.get(LeadObj.Id).Inferred_State_Region__c;
            LeadObj.mkto71_Inferred_State_Region__c=LeadIdMap.get(LeadObj.Id).mkto71_Inferred_State_Region__c;
            LeadObj.mkto2__Inferred_City__c=LeadIdMap.get(LeadObj.Id).Inferred_City__c;
            LeadObj.Job_Rank__c=LeadIdMap.get(LeadObj.Id).Job_Rank__c;
          //  LeadObj.LinkedIn_ID__c=LeadIdMap.get(LeadObj.Id).LinkedIn_ID__c;
            LeadObj.LID__LinkedIn_Company_Id__c= LeadIdMap.get(LeadObj.Id).LinkedIn_Company_Id__c;
            LeadObj.LID__LinkedIn_Member_Token__c=LeadIdMap.get(LeadObj.Id).LinkedIn_Member_Token__c;
            //LeadObj.LinkedIn_URL__c=LeadIdMap.get(LeadObj.Id).LinkedIn_URL__c;//HSR:Commented for FP:4thApril           
            //LeadObj.Time_Zone__c=LeadIdMap.get(LeadObj.Id).Alternate_Email__c;
            //LeadObj.Twitter_URL__c=LeadIdMap.get(LeadObj.Id).Twitter_URL__c;//HSR:Commented for FP:4thApril
            LeadObj.Website=LeadIdMap.get(LeadObj.Id).Website__c;
            LeadObjList.add(LeadObj);
        }
     } 
    If(LeadObjList.size()>0){
        update LeadObjList;
    }
    
    if(accountIdMap.size() > 0){
       For(account accObj : [SELECT PersonEmail,Id,Firstname,/*Is_GDPR__pc,*/Is_GDPR__c,LastName,PersonMobilePhone,Phone FROM account WHERE ID IN : accountIdMap.keySet()]){
            accObj.PersonEmail = accountIdMap.get(accObj.Id).Email__c;
            //accObj.FirstName = accountIdMap.get(accObj.Id).Firstname__c;
            accObj.Is_GDPR__c= false;//UsertactIdMap.get(UserObj.Id).Is_GDPR__c;
            accObj.Name = accountIdMap.get(accObj.Id).Firstname__c + '' + accountIdMap.get(accObj.Id).LastName__c;
            //accObj.LastName = accountIdMap.get(accObj.Id).LastName__c;
            accObj.PersonMobilePhone = accountIdMap.get(accObj.Id).MobilePhone__c;
            accObj.Phone= accountIdMap.get(accObj.Id).Phone__c;
           // accObj.UserName= accountIdMap.get(accObj.Id).Name__c ;
            accObj.RecordtypeId= accountIdMap.get(accObj.Id).RecordType_Id__c;       
            accObjList.add(accObj);
        }
     } 
    If(accObjList.size()>0){
        update accObjList;
    }
        
    if(caseIdMap.size() > 0){
       For(GDPR_Central_Repository__c gdpr: caseIdMap.values()){
            case caseObj = new case(id = gdpr.id__C);
            caseObj.SuppliedEmail = caseIdMap.get(caseObj.Id).Email__c;
            caseObj.SuppliedName = caseIdMap.get(caseObj.Id).Firstname__c;
            caseObj.Is_GDPR__c = false;
            caseObj.SuppliedCompany = caseIdMap.get(caseObj.Id).Account_Name__c ;   
            caseObj.RecordtypeId= caseIdMap.get(caseObj.Id).RecordType_Id__c;         
            caseObjList.add(caseObj);
        }
    } 
     If(caseObjList.size()>0){
        update caseObjList;
     }
    
    if(GDPRIdSet.size()>0){
    if(System.IsBatch() == false && System.isFuture() == false){ 
        GDPRCentralRepositoryHandler.GDPRUser(GDPRIdSet);
    }
    }   
}