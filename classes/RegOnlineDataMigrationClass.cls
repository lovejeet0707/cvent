/*Modified By : HSR
Modified Date : 17th April 2017
Description : Adding a new record type for the case inserted through the community User
*/
public class RegOnlineDataMigrationClass{      
    public String selectedProduct {get;set;}
    public String newaccountID {get; set;}
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
    
    public User oUser{get;set;}
    public Case c { get; private set; }
    
    public PageReference pageRef = ApexPages.currentPage();
    
    public Boolean isSite {get;set;}
    
    public RegOnlineDataMigrationClass() {
        isSite = false;
        pageReload = 'true';
        
        c = new Case();        
        c.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Case' AND DeveloperName ='New_Support_SignUp4'].id;
        c.OwnerId = [select Id from Group where Type = 'Queue' AND DeveloperNAME = 'Data_Migration'].Id;
        c.Subject = 'Data Migration Request';
        c.SU4_Parent_Case_Number__c = 'RegOnline';
        c.Priority='Medium';
        c.Origin = 'Web2Case';
        c.Status= 'New';
        oUser = [SELECT Name,Email,AccountId,ContactId,Contact.Name,Contact.AccountId,Contact.Account.Name FROM User WHERE Id=:Userinfo.getUserId()];
        c.AccountId = oUser.Contact.AccountId;
        c.ContactId = oUser.ContactId;  
        sContact = oUser.Contact.Name;
        sAccount = oUser.Contact.Account.Name;
        
    }
    public void saveHandler(){
        error = false;
        savepoint sp = Database.setSavepoint();                            
        insert (c);
    }
    public PageReference save() {  
        PageReference PR; 
        saveHandler();
        if (!error) {
            PR = new pageReference((site.getPathPrefix()!= null?site.getPathPrefix():'') +'/apex/CaseDataMigrationDetail?Id='+c.Id);
            return PR; 
       }
        else{
            return null;
        }
    }
}