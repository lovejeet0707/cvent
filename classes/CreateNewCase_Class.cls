/*Modified By : HSR
Modified Date : 17th April 2017
Description : Adding a new record type for the case inserted through the community User
*/
public class CreateNewCase_Class{      
    public String selectedProduct {get;set;}
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
    private Cvent_Category_Mapping__c categoryMapping;
    private String productName;
    public CreateNewCase_Class() {
        isSite = false;
        productName = ApexPages.currentPage().getParameters().get('prod');
        categoryMapping = Cvent_Category_Mapping__c.getValues(productName);
        
        pageReload = 'true';
        UserType= UserInfo.getUserType();
        UCRList = new list<User_contact_Relation__c>();
        UCRList = [SELECT Id, Name, Related_Contact__c, Related_Contact__r.AccountId,Related_Contact__r.Account.Name, Account__c,Primary__c FROM User_Contact_Relation__c   
                   WHERE User__c =: Userinfo.getUserId()];
        
        Subject = ApexPages.currentPage().getParameters().get('Subject');
        Description = ApexPages.currentPage().getParameters().get('Desc');
        newAccountId = ApexPages.currentPage().getParameters().get('AccountName');
        
        c = new Case();        
        
        if(categoryMapping!=null){
            c.RecordTypeId = categoryMapping.RecordType_Id__c;
            c.OwnerId = categoryMapping.OwnerId__c;
            c.Product__c = categoryMapping.Product__c;
        }
        c.Subject = Subject;
        c.Description = Description;
        c.Priority='P4 - Low/None';
        c.Origin = 'Customer Portal';
        
        
        if(newAccountId != null){
            c.AccountId = newAccountId;
            sAccount = getAccountName(c.AccountId);
        }
        
        oUser = [SELECT Name,Email,AccountId,ContactId,Contact.Name,Contact.AccountId,Contact.Account.Name FROM User WHERE Id=:Userinfo.getUserId()];
        
        //if(!isSite){
            if(c.AccountId == null){
                c.AccountId = oUser.Contact.AccountId;
                sAccount = oUser.Contact.Account.Name;
            }
            c.ContactId = oUser.ContactId;  
            sContact = oUser.Contact.Name;
        //}
        
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
        
        /*if(isSite){
            showPOPUP = false;
        } */    
    }
    
    public String getAccountName(String sId){
        String sAcc='';
        for(Account oA:[Select Id,Name From Account Where Id =:sId limit 1]){
            sAcc = oA.Name;
        }
        return sAcc;
    }
    
    public String getContactName(String sId){
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
    
    public void saveHandler(){
        error = false;
        list<Contact> lstContact;
        boolean bValidContatFound = false;
        String sDesc = c.Description;
        savepoint sp = Database.setSavepoint();                            
        //try {
        System.debug('saveHandler method ********');
        /*if(isSite){
            System.debug('saveHandler method Inside If********');
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
        }*/
        
        /*  AssignmentRule AR = new AssignmentRule();
AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];                
Database.DMLOptions dmlOpts = new Database.DMLOptions();
dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
c.setOptions(dmlOpts);*/
        c.product__c = apexpages.currentPage().getParameters().get('productValue');
        if(Label.CaseClassMethodActive=='True'){
            String productAPI = apexpages.currentPage().getParameters().get('productAPI');
            System.debug('productAPI************'+productAPI);
            System.debug('c.product__c************'+c.product__c);
            if(String.isNOtBlank(productAPI)){
                categoryMapping = Cvent_Category_Mapping__c.getValues(productAPI);
                System.debug('categoryMapping************'+categoryMapping);
                if(categoryMapping!=null){
                    c.RecordTypeId = categoryMapping.RecordType_Id__c;
                    c.OwnerId = categoryMapping.OwnerId__c;
                    c.Product__c = categoryMapping.Product__c;
                }
                System.debug('Case Product Details****'+c.Product__c);
            }
        }
        System.debug('c*********'+c);
        insert (c);
        
        for(Case tmpCase : [select Id,CaseNumber From Case Where Id =:c.Id limit 1]){
            sCaseNumber = tmpCase.CaseNumber;
        }
        system.debug('@Developer -->sCaseNumber:' +sCaseNumber);
        //}
        /*catch(System.DMLException e) {
System.debug('e*************'+e);
c.Description = sDesc;
error = true;
ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
Database.rollback(sp);
}*/
    }
    
    public PageReference saveAndAddAttachment() {     
        PageReference PR; 
        saveHandler();
        Id trackerId = apexpages.currentpage().getparameters().get('id');
        if(trackerId!=null){
            Case_Deflection_Track__c caseDeflect = new Case_Deflection_Track__c(id=trackerId);
            caseDeflect.Case_Created_Count__c = 1;
            update caseDeflect;
        }
        System.debug('Attachement Called');
        if (!error) {
            //PR = new PageReference('/p/attach/NoteAttach?pid='+c.Id+'&parentname='+sCaseNumber+'&retURL=/apex/ro_CaseDetail?id='+c.Id);
            PR = new pageReference((site.getPathPrefix()!= null?site.getPathPrefix():'') +'/apex/CaseAddAttachment?caseid='+c.Id);
            System.debug('inside if');
            return PR;
        }
        else{
            System.debug('inside else');
            return null;
        }   
    }
    
    public PageReference save() {  
        PageReference PR; 
        saveHandler();
        System.debug('Save Called');
        Id trackerId = apexpages.currentpage().getparameters().get('id');
        if(trackerId!=null){
            Case_Deflection_Track__c caseDeflect = new Case_Deflection_Track__c(id=trackerId);
            caseDeflect.Case_Created_Count__c = 1;
            update caseDeflect;
        }
        if (!error) {
            //PR = new PageReference('/p/attach/NoteAttach?pid='+c.Id+'&parentname='+sCaseNumber+'&retURL=/apex/ro_CaseDetail?id='+c.Id);
            PR = new pageReference((site.getPathPrefix()!= null?site.getPathPrefix():'') +'/apex/CaseDetail?Id='+c.Id);
            return PR; 
           
       }
        else{
            return null;
        }
        
    }
}