// ===============================
// Name             : ReflagController
// AUTHOR           : Hemant Rana   
// CREATED DATE     : 3 Nov 2016
// PURPOSE          : Reflag
// TEST CLASS       : ReflagControllerTest
// SPECIAL NOTES    :
// ===============================
global class ReflagController {
    public Integer size {get; set;}
    public Integer NumberOfPages {get; set;}
    //Initializing the private variable for storing the Rebrand_Reflag__c record
    private final Rebrand_Reflag__c rebrandReflagObj;
    //Initializing the variable for storing the Opportunity List record
    //public List<Opportunity> oppList{get;set;}

    //This is Our collection of the class/wrapper objects WrapperOpportunityWrapper
    public List<WrapperOpportunityWrapper> wrapperlist;
    
    public Decimal noOfRecords{get; set;}
    
    // Create a new Map to verify whether the Contact is already added in the Map
    @testvisible
    Map <Id,Opportunity> selectedoppMap;
    
    //Name of Current User 
    List<Opportunity> oppUpdateList;
    
    //Id oldAccId;
    Id newAccIdReplace;
    
    Map<Id,String> userIdVsCountryName= new Map<Id,String>(); // User Id vs Country Map...........
    List<Account> accountListUpdate = new List<Account>();// Old and New Account List which needs to be updated.........
    public ReflagController(ApexPages.StandardController stdCtrl){
        oppUpdateList = new List<Opportunity> ();
        selectedoppMap= new Map <Id,Opportunity> ();
        //Current Rebrand_Reflag__c Object Record......................
        Rebrand_Reflag__c reReflagObj = (Rebrand_Reflag__c)stdCtrl.getRecord();
        System.debug('*************Id'+reReflagObj.RecordTypeId);
        rebrandReflagObj = [SELECT Reflagged_on_Date__c,Reflag_Processed_Date__c,New_Supplier_Account__c,New_Supplier_Account__r.Name
                                ,Old_Supp_Ac__c,Old_Supp_Ac__r.Name,Old_Supp_Ac__r.OwnerId,Old_Supp_Ac__r.CVII_ID__c,New_Supplier_Account__r.Purchased_License__c,
                                Old_Supp_Ac__r.Management_Company__c,Old_Supp_Ac__r.Brand__c,Old_Supp_Ac__r.Chain_Affiliation__c,/*Old_Supp_Ac__r.EM_Purchased_License_For__c,*/    //Commented By Mohsin on 30th Sept 2019 - FP Activity
                                /*Old_Supp_Ac__r.SRFP_Purchased_License_For__c,*/   //Commented By Mohsin on 30th Sept 2019 - FP Activity
                                Old_Supp_Ac__r.SRFP_White_Label__c,
                                Old_Supp_Ac__r.EMA_Purchased_License_For__c,
                                Old_Supp_Ac__r.EMA_Year__c,
                                Old_Supp_Ac__r.EM_Certification_Level__c,
                                Old_Supp_Ac__r.Account_Management_Tier__c,
                                Old_Supp_Ac__r.CSN_Contract_Type__c,
                                Old_Supp_Ac__r.Purchased_License__c,
                                Old_Supp_Ac__r.Original_A_C_Owner__c,
                                Old_Supp_Ac__r.Original_A_c_Owner_CSN__c,
                                /*Old_Supp_Ac__r.Original_A_c_Owner_CT__c,*/  //Commented By Mohsin on 21st June 2019 - FP Activity
                                Old_Supp_Ac__r.Original_A_c_Owner_Event__c,
                                Old_Supp_Ac__r.Original_A_c_Owner_Survey__c,
                                Old_Supp_Ac__r.Consent_for_logo__c,
                                Old_Supp_Ac__r.Supplier_Status__c,
                                Old_Supp_Ac__r.Standard_Non_Standard_Contract__c FROM Rebrand_Reflag__c WHERE Id = : reReflagObj.Id];
        System.debug('rebrandReflagObj***********'+rebrandReflagObj);
        
        For(User userObj : [SELECT Id,Country FROM User WHERE Id = :rebrandReflagObj.Old_Supp_Ac__r.OwnerId  AND Country !=null])
        {
            userIdVsCountryName.put(userObj.Id,userObj.Country);
        }
        newAccIdReplace=rebrandReflagObj.New_Supplier_Account__c;
        //oldAccId=rebrandReflagObj.Old_Supp_Ac__c;
        //Initializing the Opportunity List and getting Opportunity record related to the "Old_Supp_Ac__c" Account Id.................
        //oppList = new List<Opportunity>([SELECT Id FROM Opportunity WHERE AccountId = : rebrandReflagObj.Old_Supp_Ac__c]);
        //System.debug('oppList*******************'+oppList);
    }
    
    public pageReference ReflagOpportunity(){
        Id CSNRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CSN-Supplier').getRecordTypeId();

        oppUpdateList.clear();
        getSelectedOpportunities();

        for(Opportunity cr: selectedoppMap.values()){
            //Updating Opportunity with new Account Id....
            Opportunity crUpdate = new Opportunity(Id = cr.Id,AccountId = newAccIdReplace,Reflag_Opp_BYPass__c=true);
            oppUpdateList.add(crUpdate);
        }

        if(oppUpdateList.size()>0){
            update oppUpdateList;
            //Inserting new 0$ Reflag Opportunity 
            Opportunity oppReflag= new Opportunity();
            
            oppReflag.Reflag_Opp_BYPass__c=True;
            oppReflag.StageName='Closed Won';
            oppReflag.Product__c='CSN';
            oppReflag.CloseDate=System.today();
            oppReflag.Probabilities__c=100;
            oppReflag.Contract_Implemented__c=True;
            oppReflag.Contract_Implemented_Date__c=System.today();
            oppReflag.CVII_Contract_Number__c='0';
            oppReflag.Contract_Number_New__c='0';
            oppReflag.Set_Cancellation_Status__c='Do Not Open';
            oppReflag.Case_Received_Date__c=system.today();
            oppReflag.Contact_Associated__c='003o000000PK7ca';
            oppReflag.Contact_Role__c='Signer';
            oppReflag.Parent_Upsell__c='Reflag';
            oppReflag.License_Type__c='1/2 Diamond';
            oppReflag.Early_Contract__c='Not Early';
            oppReflag.NBB_Renewal__c='Renewal';
            oppReflag.MYD_Deal__c='First Year';
            oppReflag.New_Amount__c=0;
            oppReflag.PaymentTerms__c='Annual Upfront Invoice';
            oppReflag.Deal_Booked_In__c='US Books';
            oppReflag.Years__c='1';
            oppReflag.Deal_Year__c='1';
            oppReflag.Non_Standard_Terms__c='Not Appicable';
            oppReflag.ContractReceived__c=System.today();
            oppReflag.Chain_Deal__c='Venue/Service';
            oppReflag.Bundled_Package_Type__c='Not Applicable';
            oppReflag.Name=system.now().format('MMMMM')+' '+system.now().Year()+' '+'REFLAG';
            oppReflag.AccountId=rebrandReflagObj.Old_Supp_Ac__c;
            oppReflag.RecordTypeId = CSNRecordTypeId; 
            oppReflag.OwnerId=rebrandReflagObj.Old_Supp_Ac__r.OwnerId;
            oppReflag.Deal_Closed_by__c=rebrandReflagObj.Old_Supp_Ac__r.OwnerId;
            oppReflag.Management_Company_Name__c=rebrandReflagObj.Old_Supp_Ac__r.Management_Company__c;
            oppReflag.Brand_Name__c=rebrandReflagObj.Old_Supp_Ac__r.Brand__c;
            oppReflag.Chain_Name__c=rebrandReflagObj.Old_Supp_Ac__r.Chain_Affiliation__c;
            oppReflag.ContractStartDate__c=rebrandReflagObj.Reflagged_on_Date__c.addDays(-2);
            oppReflag.ContractEndDate__c=rebrandReflagObj.Reflagged_on_Date__c.addDays(-1);
            //oppReflag.Opportunity_Start_Date__c=rebrandReflagObj.Reflagged_on_Date__c.addDays(-2); Forumla Field
            oppReflag.Opp_End_Date__c=rebrandReflagObj.Reflagged_on_Date__c.addDays(-1);
            oppReflag.Original_Contract_End_Date__c=rebrandReflagObj.Reflagged_on_Date__c.addDays(-1);
            
            String location=userIdVsCountryName.containsKey(oppReflag.Deal_Closed_by__c)?userIdVsCountryName.get(oppReflag.Deal_Closed_by__c):userIdVsCountryName.values()[0];
            
            System.debug('location===>>>'+location);
            
            if(location!=null){
                //oppReflag.Sold_By__c=(location=='IN'?'India':((location=='United Kingdom'||location=='GB')?'Europe':(location=='AU'?'Australia':(location=='US'?'USA':location))));
                oppReflag.Sold_By__c=(location=='IN'?'India':((location=='United Kingdom'||location=='GB')?'Europe':(location=='AU'?'Australia':(location=='CA'?'Canada':(location=='SG'?'Singapore':(location=='US'?'USA':location))))));
            }
            
            insert oppReflag;//Inserting $0 Reflag Opportunity............
            
            
            Account old_New_AccObj;
            
            //New Account field update.............
            old_New_AccObj = new Account();
            old_New_AccObj.Id=rebrandReflagObj.New_Supplier_Account__c;
            old_New_AccObj.Reflag_Opp_Acc_BYPass__c=True;
            old_New_AccObj.CVII_ID__c = rebrandReflagObj.Old_Supp_Ac__r.CVII_ID__c;
            old_New_AccObj.Purchased_License__c= rebrandReflagObj.New_Supplier_Account__r.Purchased_License__c==null?rebrandReflagObj.Old_Supp_Ac__r.Purchased_License__c:rebrandReflagObj.New_Supplier_Account__r.Purchased_License__c;
            old_New_AccObj.Account_Status__c='Active';
            //old_New_AccObj.EM_Purchased_License_For__c=rebrandReflagObj.Old_Supp_Ac__r.EM_Purchased_License_For__c;   //Commented By Mohsin on 30th Sept 2019 - FP Activity
            //old_New_AccObj.SRFP_Purchased_License_For__c=rebrandReflagObj.Old_Supp_Ac__r.SRFP_Purchased_License_For__c; //Commented By Mohsin on 30th Sept 2019 - FP Activity
            old_New_AccObj.SRFP_White_Label__c=rebrandReflagObj.Old_Supp_Ac__r.SRFP_White_Label__c;
            old_New_AccObj.EMA_Purchased_License_For__c=rebrandReflagObj.Old_Supp_Ac__r.EMA_Purchased_License_For__c;
            old_New_AccObj.EMA_Year__c=rebrandReflagObj.Old_Supp_Ac__r.EMA_Year__c;
            old_New_AccObj.EM_Certification_Level__c=rebrandReflagObj.Old_Supp_Ac__r.EM_Certification_Level__c;
            old_New_AccObj.Account_Management_Tier__c=rebrandReflagObj.Old_Supp_Ac__r.Account_Management_Tier__c;
            old_New_AccObj.CSN_Contract_Type__c=rebrandReflagObj.Old_Supp_Ac__r.CSN_Contract_Type__c;
            old_New_AccObj.Original_A_C_Owner__c=rebrandReflagObj.Old_Supp_Ac__r.Original_A_C_Owner__c;
            old_New_AccObj.Original_A_c_Owner_CSN__c=rebrandReflagObj.Old_Supp_Ac__r.Original_A_c_Owner_CSN__c;
            /*old_New_AccObj.Original_A_c_Owner_CT__c=rebrandReflagObj.Old_Supp_Ac__r.Original_A_c_Owner_CT__c;*/  //Commented By Mohsin on 21st June 2019 - FP Activity
            old_New_AccObj.Original_A_c_Owner_Event__c=rebrandReflagObj.Old_Supp_Ac__r.Original_A_c_Owner_Event__c;
            old_New_AccObj.Original_A_c_Owner_Survey__c=rebrandReflagObj.Old_Supp_Ac__r.Original_A_c_Owner_Survey__c;
            old_New_AccObj.Consent_for_logo__c=rebrandReflagObj.Old_Supp_Ac__r.Consent_for_logo__c;
            old_New_AccObj.Standard_Non_Standard_Contract__c=rebrandReflagObj.Old_Supp_Ac__r.Standard_Non_Standard_Contract__c;
            
            accountListUpdate.add(old_New_AccObj);
            
            
            
            //Old Account field update.............
            old_New_AccObj = new Account();
            old_New_AccObj.Id=rebrandReflagObj.Old_Supp_Ac__c;
            old_New_AccObj.Reflag_Opp_Acc_BYPass__c=True;
            old_New_AccObj.Name = 'REFLAGGED - '+ rebrandReflagObj.Old_Supp_Ac__r.Name ;
            old_New_AccObj.Purchased_License__c=null;
            old_New_AccObj.Account_Status__c='Inactive Customer - Reflag';
            //old_New_AccObj.EM_Purchased_License_For__c=null;  //Commented By Mohsin on 30th Sept 2019 - FP Activity
            //old_New_AccObj.SRFP_Purchased_License_For__c=null;    //Commented By Mohsin on 30th Sept 2019 - FP Activity
            old_New_AccObj.SRFP_White_Label__c=null;
            old_New_AccObj.EMA_Purchased_License_For__c=null;
            old_New_AccObj.EMA_Year__c=null;
            old_New_AccObj.EM_Certification_Level__c=null;
            old_New_AccObj.Account_Management_Tier__c=null;
            old_New_AccObj.CSN_Contract_Type__c=null;
            old_New_AccObj.Original_A_C_Owner__c=null;
            old_New_AccObj.Original_A_c_Owner_CSN__c=null;
            /*old_New_AccObj.Original_A_c_Owner_CT__c=null; */  //Commented By Mohsin on 21st June 2019 - FP Activity
            old_New_AccObj.Original_A_c_Owner_Event__c=null;
            old_New_AccObj.Original_A_c_Owner_Survey__c=null;
            old_New_AccObj.Consent_for_logo__c=null;
            old_New_AccObj.Standard_Non_Standard_Contract__c=null;
            old_New_AccObj.Supplier_Status__c='Reflagged';
            
            accountListUpdate.add(old_New_AccObj);
            //updating Account List............
            if(accountListUpdate.size()>0)
                update accountListUpdate;
            
            
            
            
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.CONFIRM,'Selected Opportunity updated Successfully'));
        }

        selectedoppMap = new Map <Id,Opportunity>();
        wrapperlist =  new List <WrapperOpportunityWrapper>();
        //setCon.setpageNumber(1);
        setCon=null;
        
        return null;
    }
    //Validate all Opportunities
    /*public pageReference ReflagAllOpportunity(){
        
        oppUpdateList.clear();
        Decimal totalpages;
        
        setCon.setpageNumber(1);
        //All Contact Roles
        List<Opportunity> allConRolesList = new List<Opportunity>();
        
        Decimal pages = noOfRecords.divide(Decimal.valueOf(setCon.getPageSize()), 2);
        totalPages = (Integer)pages.round(System.RoundingMode.CEILING);

        //Collecting all records from StandardSetController 
        for(integer i=0; i<totalPages; i++){
            
            allConRolesList.addAll((List<Opportunity>)Setcon.getRecords());
            
            setCon.next();  
        }
        
        System.debug('***allConRolesList**'+ allConRolesList);
        //Updating all Contact Roles
        for(Opportunity cr: selectedoppMap.values()){
            Opportunity crUpdate = new Opportunity(Id = cr.Id,AccountId = newAccIdReplace);
            oppUpdateList.add(crUpdate);
        }
        
        if(oppUpdateList.size()>0){
            update oppUpdateList;
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.CONFIRM,'Selected Opportunity updated Successfully'));
        }
        
        
        /*PageReference pgRef = Page.AMValidation;
        pgRef.setRedirect(true);
        return pgRef;
        //selectedcontactRoleMap = new Map <Id,Contact_Role__c>();
       // wrapperlist =  new List <WrapperContactRoleWrapper>();      
        
        //setCon.setpageNumber(1);
        setCon=null;
        
        return null;
    }*/

    
    // instantiate the StandardSetController from a query locator
    public ApexPages.StandardSetController Setcon{
        get{
            size = 190;
            if(Setcon == Null){
                Setcon = new ApexPages.StandardSetController(Database.getQueryLocator([SELECT Id,Name,StageName,Contribution_Type__c,Owner.Name,Product__c,New_Type__c FROM Opportunity WHERE AccountId = : rebrandReflagObj.Old_Supp_Ac__c]));
                // sets the number of records in each page set
                setCon.setpagesize(size);
                noOfRecords = setCon.getResultSize();
                NumberOfPages = Integer.ValueOf((noOfRecords/(Decimal)size).round(System.RoundingMode.CEILING));
            }
            return Setcon; 
        }
        set;
    }
    
    
    //Returns a list of wrapper objects for the sObjects in the current page set
    public List<WrapperOpportunityWrapper> getOpportunities(){    
        getSelectedOpportunities();
        
        // Initilaize the list to add the selected contact roles
        wrapperlist = new List <WrapperOpportunityWrapper>();
        System.debug('****Setcon.getRecords()***'+ Setcon.getRecords());
        for(Opportunity cr : (List<Opportunity>)Setcon.getRecords()){

            if( selectedoppMap!=null && selectedoppMap.ContainsKey(cr.id)){

                wrapperlist.add (new WrapperOpportunityWrapper(cr,true));
            }else{

                wrapperlist.add(new WrapperOpportunityWrapper(cr,false));
            }
        }
        
        if(wrapperlist.size()==0){
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO,'No Opportunity to Reflag.....'));
        }
        
        
        return wrapperlist;
    }
    
    //Set the selected Contact Roles
    public void getSelectedOpportunities(){
      
        if(wrapperlist!=null){
            System.debug('wrapperlist************************'+wrapperlist);
            for(WrapperOpportunityWrapper wr:wrapperlist){
                if(wr.isSelected == true){
                    System.debug('wr.oppRec.id*****************'+wr.oppRec.id);
                    System.debug('wr.oppRec*****************'+wr.oppRec);
                    selectedoppMap.put(wr.oppRec.id,wr.oppRec); // Add the selected contact id in to the selectedoppMap.
                }else if(selectedoppMap!=null){
                    selectedoppMap.remove(wr.oppRec.id); // If you uncheck the contact, remove it from the selectedoppMap
                }
            }
        }
    }
    
    //Return the pageNumber 
    public integer pageNumber{
    get{
        return Setcon.getPageNumber();
    }
    set;
    }
    

    //Wrapper of Contact Roles
    public class WrapperOpportunityWrapper{

        public Opportunity oppRec  {get;set;}
        public boolean isSelected {get;set;}

        public WrapperOpportunityWrapper(Opportunity oppRec,boolean isSelected){
            this.oppRec = oppRec;
            this.isSelected = isSelected;
        }
    }

        
    


}