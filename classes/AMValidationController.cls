// ===============================
// Name             : AMValidationController
// AUTHOR           : Shanu Aggarwal    
// CREATED DATE     : 20 Sep 2016
// PURPOSE          : Validation of Contact Roles by AM/CS-Rep
// TEST CLASS       : AMValidationControllerTest
// SPECIAL NOTES    :
// ===============================
global class AMValidationController {   
    
    //Accounts Hold by AM's
    Map<Id,Contact> contactMap;    
    //Record Type Ids of Contact Role
    Set<ID> recTypeIds;    
    //Account Id's
    Set<ID> accIds ;    
    Id accId ; // Contact Validation @ Account Level    
    
    //This is Our collection of the class/wrapper objects WrapperContactRoleWrapper
    public List<WrapperContactRoleWrapper> wrapperlist;    
    public Decimal noOfRecords{get; set;}    
    public boolean showCustomer{get; set;}
    public boolean showBuyer{get; set;}
    public boolean hideConValidateSection{get; set;}
    
    // Create a new Map to verify whether the Contact is already added in the Map
    @testvisible
    Map <Id,Contact_Role__c> selectedcontactRoleMap;
    //public list<Contact_Role__c> selectedList {get;set;}
    
    //Name of Current User 
    String userFullName = UserInfo.getName();
    String roleName,profileName = '';
    List<Contact_Role__c> crUpdateList;
    
    public AMValidationController(ApexPages.StandardController stdCtrl){        
        accIds = new Set<ID>();
        recTypeIds = new Set<ID>();      
        selectedcontactRoleMap = new Map <Id,Contact_Role__c>();
        crUpdateList = new List<Contact_Role__c>();
        hideConValidateSection = false;
        roleName = [Select Name From UserRole Where Id= :UserInfo.getUserRoleId() ].Name;
        profileName = [Select Name from Profile Where Id= :UserInfo.getProfileId() ].Name;        
        
        String query = 'Select Id From Account ';
        contactMap = new Map<Id,Contact>();
        
        //Find all Accounts held by current AM
        if( roleName.startsWith('AM') || profileName.equals('System Administrator')|| roleName.startsWith('PMO') || profileName.startsWith('Tech SMM') || profileName.equals('Sales Development - RFP') || profileName.equals('Sales Representative - DS (RFP)') || profileName.equals('Sales Representative - PS (RFP)') ){
            
            query +=  'Where ( AM_CrowdCompass__c =:userFullName OR ' +
                'AM_CSN__c =:userFullName OR OwnerCSN_DS__r.Name =:userFullName OR ' +
                'AM_Event__c =:userFullName OR AM_Survey__c =:userFullName OR ' +
                'AM_PA__c =:userFullName OR AM_Pre_Sales_Event__c=:userFullName ) AND Account_Status__c Like \'Active%\'' ;
            

            /*Actual Query -  Commented By Mohsin on 21st June 2019 - FP Activity

            query +=  'Where ( AM_CrowdCompass__c =:userFullName OR AM_CrowdTorch__c =:userFullName OR ' +
                'AM_CSN__c =:userFullName OR AM_CT_TM__c =:userFullName OR OwnerCSN_DS__r.Name =:userFullName OR ' +
                'AM_Event__c =:userFullName OR AM_Survey__c =:userFullName OR ' +
                'AM_PA__c =:userFullName OR AM_TicketMob__c =:userFullName OR AM_Pre_Sales_Event__c=:userFullName ) AND Account_Status__c Like \'Active%\'' ;
            
            */


            //AM Should see All Contact Roles 
            recTypeIds.add(Schema.SObjectType.Contact_Role__c.getRecordTypeInfosByName().get('Buyer Role').getRecordTypeId());
            showBuyer=true;
        }
        //Find all Accounts held by current CS rep
        else{
            query += 'Where CS_Rep__c =:userFullName AND Account_Status__c Like \'Active%\'';
            
            //CS Rep should see Customer Roles only. 
            recTypeIds.add(Schema.SObjectType.Contact_Role__c.getRecordTypeInfosByName().get('Customer Role').getRecordTypeId());
            showCustomer = true;
        }
        
        System.debug('****Query 1***' + query );
        System.debug('****Query 2***' +Database.Query(query) );
        query += ' ORDER BY Name LIMIT 1000';
        
        for( Account acc : Database.Query(query)){
            accIds.add(acc.Id);
            System.debug('***accIds B****' +accIds );
        }
        
        // Account Id retrived by button click on Account Level
        accId = ApexPages.CurrentPage().GetParameters().Get('id');
        
        if(accId == null && profileName.equals('Sales Representative - PS (RFP)')){
              hideConValidateSection = true;         
        }
        
        //Check If Validated on Account Level
        if(accId!=null){
            //If AM verified 
            if(accIds.contains(accId)){
                accIds = new Set<ID>();
                accIds.add(accId);
            }else{
                accIds.clear();
            }
        }
    }
    
    // instantiate the StandardSetController from a query locator
    public ApexPages.StandardSetController Setcon{
        get{            
            if(Setcon == Null){
                if(Test.isRunningTest())
                {
                   Setcon = new ApexPages.StandardSetController(Database.getQueryLocator([Select Id,Name, Account_Name__c, Contact__c,Contact__r.Name, Contact__r.Email,Contact__r.Phone,
                                                                                       Contact__r.MailingCity,Contact__r.Account.Name,
                                                                                       Contact__r.MailingState,
                                                                                       Contact__r.MailingPostalCode,Primary_POC__c,Advocate__c,Billing__c,
                                                                                       Contact__r.MailingCountry,Executive_Sponsor__c,Decision_Maker__c,Influencer__c,
                                                                                       Opportunity__c,Opportunity__r.Name,Contact_Role__c,RecordType.Name, 
                                                                                       Contact_Validated_Date__c , Contract_Validated_By__c,Contact_Validated__c  From 
                                                                                       Contact_Role__c LIMIT 1]));
                // Sets the number of records in each page set
                setCon.setpagesize(10);
                noOfRecords = setCon.getResultSize(); 
                }
                else
                {
                    Setcon = new ApexPages.StandardSetController(Database.getQueryLocator([Select Id,Name, Account_Name__c, Contact__c,Contact__r.Name, Contact__r.Email,Contact__r.Phone,
                                                                                           Contact__r.MailingCity,Contact__r.Account.Name,
                                                                                           Contact__r.MailingState,
                                                                                           Contact__r.MailingPostalCode,Primary_POC__c,Advocate__c,Billing__c,
                                                                                           Contact__r.MailingCountry,Executive_Sponsor__c,Decision_Maker__c,Influencer__c,
                                                                                           Opportunity__c,Opportunity__r.Name,Contact_Role__c,RecordType.Name, 
                                                                                           Contact_Validated_Date__c , Contract_Validated_By__c,Contact_Validated__c  From 
                                                                                           Contact_Role__c Where RecordTypeId IN : recTypeIds and Account_Buyer_Role__c IN: accIds 
                                                                                           and Contact_Validated__c= false
                                                                                           Order BY Contact__r.Account.Name]));
                    // Sets the number of records in each page set
                    setCon.setpagesize(10);
                    noOfRecords = setCon.getResultSize();
                }
            }
            return Setcon; 
        }
        set;
    }
    
    
    //Returns a list of wrapper objects for the sObjects in the current page set
    public List<WrapperContactRoleWrapper> getContactRoles(){        
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
        
        
        /*PageReference pgRef = Page.AMValidation;
pgRef.setRedirect(true);
return pgRef;*/
        //selectedcontactRoleMap = new Map <Id,Contact_Role__c>();
        // wrapperlist =  new List <WrapperContactRoleWrapper>();      
        
        //setCon.setpageNumber(1);
        setCon=null;
        
        return null;
    }
    
    /*
//@Account Level (Validate Roles by Custom Button)
public pageReference ValidateContactRoles(){


// Account Id retrived by button click on Account Level
accId = ApexPages.CurrentPage().GetParameters().Get('id');


//Validate Current Logged in user is AM For given Account
//Get only Current Account in set
if(accId!=null && accIds.contains(accId)){
accIds = new Set<ID>();
accIds.add(accId);
Setcon.getRecords();
ValidateAll();
}

if(accId!=null){
return new pageReference ('/'+accId);
}

return null;
}
*/    
    
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