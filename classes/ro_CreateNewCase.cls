/*Modified By : HSR
Modified Date : 17th April 2017
Description : Adding a new record type for the case inserted through the community User
*/
public class ro_CreateNewCase{      

    public String newaccountID {get; set;}
    public String UserType {get; set;}
    public string Subject{get;set;}
    public string Description{get;set;}
    public string pageReload{get;set;}
    public String sFirstName {get;set;}
    public String sLastName {get;set;}
    public String sCompanyName {get;set;}
    public String sEmail {get;set;}
    
    public String sAccount{get;set;}
    public String sContact{get;set;}
        
    public Boolean error {get; set;}
    public boolean showPOPUP{get;set;}
    
    public User oUser{get;set;}
    public Case c { get; private set; }
    
    public PageReference pageRef = ApexPages.currentPage();
    
    public list<User_contact_Relation__c> UCRList{get;set;}
    public Boolean isSite {get;set;}
    
    private String sCaseNumber = '';
    
    private CategoryMapping__c oCategoryMapping;    
    public ro_CreateNewCase () {
        isSite = ro_ConfigHelper.self.isSite;
     oCategoryMapping = ro_ConfigHelper.self.oCategoryMapping;
        pageReload = 'true';
        system.debug('The pagereload'+pageReload);
        UCRList = new list<User_contact_Relation__c>();
        UCRList = [SELECT Id, Name, Related_Contact__c, Related_Contact__r.AccountId,Related_Contact__r.Account.Name, Account__c,Primary__c FROM User_Contact_Relation__c   
                    WHERE User__c =: Userinfo.getUserId()];
        /*HSR : 17th April : Adding a new record type for the case inserted through the community User*/        
        //Id lanyonCaseRecId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Lanyon Case').getRecordTypeId();
        /*...................ENDS HERE........................*/
        c = new Case();        
        Subject = ApexPages.currentPage().getParameters().get('Subject');
        Description = ApexPages.currentPage().getParameters().get('Desc');
        UserType= UserInfo.getUserType();
        /*HSR : 17th April : Adding a new record type for the case inserted through the community User*/        
        if(oCategoryMapping.RecordTypeId__c !=null && oCategoryMapping.RecordTypeId__c!='')
            c.RecordTypeId = oCategoryMapping.RecordTypeId__c;//lanyonCaseRecId;
        /*...................ENDS HERE........................*/
        c.Subject = Subject;
        c.Description = Description;
        c.Priority='P4 - Low/None';
        c.Origin = 'Web2Case';
         
        //c.Product_Family__c = 'RegOnline';
        //c.Product_Module__c = 'Portal';
        
        //loading from custom setting category mapping
        system.debug('@Developer -->oCategoryMapping:' +oCategoryMapping);
        c.OwnerId = oCategoryMapping.OwnerId__c;
        c.Product__c = oCategoryMapping.Product__c;
        c.Product_Family_Name__c = oCategoryMapping.Product_Family_Name__c;
        c.Group__c = oCategoryMapping.Group__c;
        c.Latest_Group__c = oCategoryMapping.Latest_Group__c; 
        
        newAccountId = ApexPages.currentPage().getParameters().get('AccountName');
        if(newAccountId != null){
             c.AccountId = newAccountId;
             sAccount = getAccountName(c.AccountId);
           }
           
           oUser = [SELECT Name,Email,AccountId,ContactId,Contact.Name,Contact.AccountId,Contact.Account.Name FROM User WHERE Id=:Userinfo.getUserId()];
           
           if(!isSite){
        if(c.AccountId == null){
       c.AccountId = oUser.Contact.AccountId;
       sAccount = oUser.Contact.Account.Name;
      }
        c.ContactId = oUser.ContactId;  
        sContact = oUser.Contact.Name;
     }
           
        if(UCRList != Null && UCRList.size() > 1){
          showPOPUP = true;
        }
        
        else if(UCRList == Null || UCRList.size() == 0){
          showPOPUP = false;
        }
        else if(UCRList != Null && UCRList.size() == 1){
         showPOPUP = false;
         c.AccountId = UCRList[0].Related_Contact__r.AccountId;
          sAccount = UCRList[0].Related_Contact__r.Account.Name;
        } 
        
        if(isSite){
            showPOPUP = false;
        }     
    }
    
    private String getAccountName(String sId){
        String sAcc='';
        for(Account oA:[Select Id,Name From Account Where Id =:sId limit 1]){
            sAcc = oA.Name;
        }
        return sAcc;
    }
    
    private String getContactName(String sId){
        String sCon='';
        for(Contact oC:[Select Id,Name From Contact Where Id =:sId limit 1]){
            sCon = oC.Name;
        }
        return sCon;
    }
    
    public pageReference PopulateAccountId(){
     c.AccountId = newAccountId;
     sAccount = getAccountName(c.AccountId);
     return null;
    }
    
    private void saveHandler(){
        error = false;
     list<Contact> lstContact;
     boolean bValidContatFound = false;
     String sDesc = c.Description;
     savepoint sp = Database.setSavepoint();                            
     try {
        
        if(isSite){
            lstContact = [Select Id,AccountId From Contact Where Email =:sEmail limit 2];
            if(lstContact.size() == 1){
                bValidContatFound = true;
            }
            
            if(bValidContatFound){
                c.ContactId = lstContact[0].Id;
                c.AccountId = lstContact[0].AccountId;
            }
            else{
                String sTmp = 'First Name: ' + sFirstName + '\n';
                sTmp += 'Last Name: ' + sLastName + '\n';
                sTmp += 'Company Name: ' + sCompanyName + '\n';
                sTmp += 'Work Email: ' +sEmail + '\n' + ro_ConfigHelper.self.sDescriptionSeparator + '\n';
                c.Description = sTmp + c.Description;
            }
        }
              
             /*  AssignmentRule AR = new AssignmentRule();
               AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];                
               Database.DMLOptions dmlOpts = new Database.DMLOptions();
               dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
               c.setOptions(dmlOpts);*/
               insert (c);
            
                        for(Case tmpCase : [select Id,CaseNumber From Case Where Id =:c.Id limit 1]){
                         sCaseNumber = tmpCase.CaseNumber;
                        }
      system.debug('@Developer -->sCaseNumber:' +sCaseNumber);
     }
     catch(System.DMLException e) {
         System.debug('e*************'+e);
        c.Description = sDesc;
         error = true;
         ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
         Database.rollback(sp);
     }
    }
     
    public PageReference saveAndAddAttachment() {     
        PageReference PR; 
     saveHandler();
     if (!error) {
        //PR = new PageReference('/p/attach/NoteAttach?pid='+c.Id+'&parentname='+sCaseNumber+'&retURL=/apex/ro_CaseDetail?id='+c.Id);
      PR = new pageReference((site.getPathPrefix()!= null?site.getPathPrefix():'') +'/apex/ro_CaseAddAttachment?caseid='+c.Id);
      return PR;
     }
     else{
        return null;
     }   
    }
    
    public PageReference save() {    
        PageReference PR; 
        saveHandler();
      if (!error) {
        //PR = new PageReference('/p/attach/NoteAttach?pid='+c.Id+'&parentname='+sCaseNumber+'&retURL=/apex/ro_CaseDetail?id='+c.Id);
       PR = new pageReference((site.getPathPrefix()!= null?site.getPathPrefix():'') +'/apex/ro_CaseDetail?Id='+c.Id);
       return PR; 
      }
      else{
        return null;
      }
    }

}