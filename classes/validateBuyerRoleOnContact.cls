//Written by udita to validate the contact role if not validated for the contact... This is a vf page on contact layout named "validateBuyerRole"
//Test Class : AMValidationControllerTest

public class validateBuyerRoleOnContact{
  public id accountId; 
  public id AccId{get;set;}
  public id contactId{get;set;}
  public string accountName{get;set;}
  public List<contact> conList{get;set;}
  public list<Contact_Role__c> conRoleList{get;set;}
  public list<Contact_Role__c >currentRecordConRole{get; set;}  
  List<Contact_Role__c> crUpdateList;
  public Map <Id,Contact_Role__c> selectedcontactRoleMap{get; set;}
  public boolean hideConValidateSection{get; set;}
  public List<WrapperContactRoleWrapper> wrapperlist;    
  public Decimal noOfRecords{get; set;}  
  String userFullName = UserInfo.getName();
  public string dt{get; set;}
  public boolean ShowConList{get; set;}
  
    public validateBuyerRoleOnContact(ApexPages.StandardController controller) {
        integer numberDaysDue = 0;
        selectedcontactRoleMap = new Map <Id,Contact_Role__c>();
        crUpdateList = new List<Contact_Role__c>();
        hideConValidateSection = false;
        this.contactId = ApexPages.currentPage().getParameters().get('ID');
        conList = new List<contact>();
        conList = [select id,name,DateTime_TeamMember__c, AccountId,Account.name,Account.Account_Status__c from contact where id =:this.contactId and Account.Account_Status__c like  'Active%'];  
        if(conList.size()>0){
            AccId = conList[0].AccountId;
            accountName = conList[0].Account.Name;
            date startDate = System.Today();
            date dueDate = conList[0].DateTime_TeamMember__c;
            if(dueDate != null){         
               numberDaysDue = startDate.daysBetween(dueDate);
            }
        }
        IF(conList.size()>0 && (conList[0].DateTime_TeamMember__c == null || (numberDaysDue > 180))){
           ShowConList =  True;
        }
        currentRecordConRole = [select id,Contact_Validated__c,Account_Buyer_Role__c,Account_Buyer_Role__r.Account_Status__c from Contact_Role__c where Contact__c = :ApexPages.currentPage().getParameters().get('id') and Contact_Validated__c =false and RecordType.Name='Buyer Role' and Account_Buyer_Role__r.Account_Status__c like  'Active%' /*and Account_Buyer_Role__c = :AccId*/];
        conRoleList = new list<Contact_Role__c>();
        conRoleList =[select id,name,Account_Buyer_Role__c from Contact_Role__c where /*Account_Buyer_Role__c =: AccId  and*/ Contact__c =: this.contactId and RecordType.Name='Buyer Role'];
        dt = DateTime.now().format().escapeHtml4();
    }
 public PageReference validateContact() {
   try{
        if(currentRecordConRole.size() > 0){
            for(Contact_Role__c cr : currentRecordConRole){
               cr.Contact_Validated_Date__c = system.now();
            }
            update currentRecordConRole;
          }
        PageReference contactPage = ApexPages.currentPage();            
        contactPage.setRedirect(true);
        return contactPage;
    }
    catch(Exception e){
    
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
        ApexPages.addMessage(myMsg);
        return null;
    }
   }
   public PageReference callNo() {
     if(conList!= NULL){
       conList[0].DateTime_TeamMember__c = system.today();
       update conList;
     }
     PageReference pageRef = new PageReference(ApexPages.currentPage().getUrl());
     pageRef.setRedirect(true);
     return pageRef;
   }
   public PageReference editBuyerRole() {
     PageReference pageRef = new PageReference('/apex/contactRolesOfContact?id='+this.contactId);
     pageRef.setRedirect(true);
     return pageRef;
   }
   
   //////*********** Validate Buyer Role Starts**************////
   
   
    // instantiate the StandardSetController from a query locator
    public ApexPages.StandardSetController Setcon{
        get{            
            if(Setcon == Null){
                Setcon = new ApexPages.StandardSetController(Database.getQueryLocator([Select Id,Name,Account_Buyer_Role__c, Account_Name__c, Contact__c,Contact__r.Name, Contact__r.Email,Contact__r.Phone,
                                                                                       Contact__r.MailingCity,Contact__r.Account.Name,
                                                                                       Contact__r.MailingState,
                                                                                       Contact__r.MailingPostalCode,Primary_POC__c,Advocate__c,Billing__c,
                                                                                       Contact__r.MailingCountry,Executive_Sponsor__c,Decision_Maker__c,Influencer__c,
                                                                                       Opportunity__c,Opportunity__r.Name,Contact_Role__c,RecordType.Name, 
                                                                                       Contact_Validated_Date__c , Contract_Validated_By__c,Contact_Validated__c  From 
                                                                                       Contact_Role__c Where RecordType.Name='Buyer Role' and Contact__c =: this.contactId 
                                                                                       and Contact_Validated__c= false
                                                                                       Order BY Contact__r.Account.Name]));
                // Sets the number of records in each page set
                setCon.setpagesize(20);
                noOfRecords = setCon.getResultSize();
            }
            return Setcon; 
        }
        set;
    }
    
    //Returns a list of wrapper objects for the sObjects in the current page set
    public List<WrapperContactRoleWrapper> getContactRoles(){   
        system.debug('-----Setcon.getRecords()' +Setcon.getRecords());     
        getSelectedContactRoles();        
        // Initilaize the list to add the selected contact roles
        wrapperlist = new List <WrapperContactRoleWrapper>();
        System.debug('****Setcon.getRecords()***'+ Setcon.getRecords());
        for(Contact_Role__c cr : (List<Contact_Role__c>)Setcon.getRecords()){            
            if( selectedcontactRoleMap.ContainsKey(cr.id)){                
                wrapperlist.add (new WrapperContactRoleWrapper(cr,true));
            }else{                
                wrapperlist.add(new WrapperContactRoleWrapper(cr,false));
            }
        }
        
        if(wrapperlist.size()==0){
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO,'No Contact Roles to Validate'));
        }       
        return wrapperlist;
    }
    
    
    //Set the selected Contact Roles
    public void getSelectedContactRoles(){      
        if(wrapperlist!=null){
            for(WrapperContactRoleWrapper wr:wrapperlist){
                if(wr.isSelected == true){
                    selectedcontactRoleMap.put(wr.conRole.id,wr.conRole); // Add the selected contact id in to the selectedcontactRoleMap.
                }else{
                    selectedcontactRoleMap.remove(wr.conRole.id); // If you uncheck the contact, remove it from the selectedcontactRoleMap
                }
            }
        }
    }
    
    
    //Validate Selected Contact Roles 
    public PageReference ValidateSelected(){      
        crUpdateList.clear();
        getSelectedContactRoles(); 
        
        for(Contact_Role__c cr: selectedcontactRoleMap.values()){
            Contact_Role__c crUpdate = new Contact_Role__c(Id = cr.Id);
            crUpdate.Contact_Validated_Date__c = DateTime.now();
            crUpdate.Contract_Validated_By__c = userFullName;          
            crUpdateList.add(crUpdate);
            
        }
        
        if(crUpdateList.size()>0){
            update crUpdateList;
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.CONFIRM,'Selected Contact Roles Validated Successfully'));
        }
        
        selectedcontactRoleMap = new Map <Id,Contact_Role__c>();
        wrapperlist =  new List <WrapperContactRoleWrapper>();
        //setCon.setpageNumber(1);
        setCon=null;
        
        return null;
    }
    
    //Validate all Contact Roles 
    public pageReference ValidateAll(){
        crUpdateList.clear();
        Decimal totalpages;
        
        setCon.setpageNumber(1);
        //All Contact Roles
        List<Contact_Role__c> allConRolesList = new List<Contact_Role__c>();
        
        Decimal pages = noOfRecords.divide(Decimal.valueOf(setCon.getPageSize()), 2);
        totalPages = (Integer)pages.round(System.RoundingMode.CEILING);
        
        system.debug('====totalPages===='+totalPages);
        system.debug('====Setcon.getRecords()===='+Setcon.getRecords());
        //Collecting all records from StandardSetController 
        for(integer i=0;  i< totalPages; i++){
            
            allConRolesList.addAll((List<Contact_Role__c>)Setcon.getRecords());
            
            setCon.next();  
        }
        
        System.debug('***allConRolesList**'+ allConRolesList);
        //Updating all Contact Roles
        for(Contact_Role__c cr : allConRolesList){            
            Contact_Role__c crUpdate = new Contact_Role__c(Id = cr.Id);
            crUpdate.Contact_Validated_Date__c = DateTime.now();
            crUpdate.Contract_Validated_By__c = userFullName;
            crUpdateList.add(crUpdate);
        }
        
        if(crUpdateList.size()>0){
            update crUpdateList;        
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.CONFIRM,'All Contact Roles Validated Successfully'));    
        }
        
     
        setCon=null;
        
        return null;
    }
    

    //Return the pageNumber 
    public integer pageNumber{
        get{
            return Setcon.getPageNumber();
        }
        set;
    }    
    
    //Wrapper of Contact Roles
    public class WrapperContactRoleWrapper{        
        public Contact_Role__c conRole  {get;set;}
        public boolean isSelected {get;set;}
        
        public WrapperContactRoleWrapper(Contact_Role__c conRole,boolean isSelected){
            this.conRole = conRole;
            this.isSelected = isSelected;
        }
    }
}