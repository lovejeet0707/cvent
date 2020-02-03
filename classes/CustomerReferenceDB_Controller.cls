public without sharing class CustomerReferenceDB_Controller{ 

    public ApexPages.StandardSetController con {get; set;} 
    public List<CustomerWrapper> lstDataDump;
    public List<CustomerWrapper> getLstDataDump ()  
    {  
        lstDataDump = new List<CustomerWrapper>();
        if(con != null) {  
            List<Account> accountsList = (List<Account>)con.getRecords();  
            lstDataDump = prepareWrapperData(accountsList);
        }
        return lstDataDump;
    }

    public List<CustomerWrapper> prepareWrapperData(List<Account> accountsList){
        List<CustomerWrapper> lstDataDump0 = new List<CustomerWrapper>();
        Map<Id,List<Contact>> mapAdvocates = new Map<Id,List<Contact>>();
        List<Contact> contactList = [select Id, AccountId, of_Active_Advocate_with_Contact__c, FirstName, LastName, Title, Email, Phone, Job_Function__c, Mood__c,/* Manager_Email__c,*/ RoleinDecision__c, MailingCity, MailingState, MailingCountry, AdvocateHub__Date_Joined_AdvocateHub__c from Contact where accountid in:accountsList and AdvocateHub__Date_Joined_AdvocateHub__c != null];//UD:Commented manager_email__c for FP:4thApril
        for(Account acc : accountsList){
            //for(Contact cnt: acc.Contacts) {
            for(Contact cnt: contactList) {
                if(cnt.accountId == acc.Id && cnt.AdvocateHub__Date_Joined_AdvocateHub__c != null){ //cnt.of_Active_Advocate_with_Contact__c > 0) {
                    List<Contact> advList = (List<Contact>) mapAdvocates.get(acc.Id);
                    if(advList == null){
                        advList = new List<Contact>();
                    }
                    advList.add(cnt);
                    mapAdvocates.put(acc.Id,advList);
                } 
            }
        }
        for(Account acc : accountsList){
            boolean isAdvocate = (mapAdvocates.get(acc.Id) != null && mapAdvocates.get(acc.Id).size() > 0? true: false);
            if(advocateOnly){
                if(isAdvocate){
                    lstDataDump0.add(new CustomerWrapper(acc.Name,acc.BillingCountryCode,acc.BillingCity,acc.BillingStateCode,acc.Purchased_License__c, 'Yes',acc.Id,acc.Sic,acc.SicDesc,acc.Account_Management_Tier__c,acc.Back_Office_System__c,acc.AM_Event__c, acc.AnnualRevenue,acc.of_Employees_New__c,acc.Segment__c,acc.Industry_for_Hospitality__c,acc.Industry_Sub_Segment_for_Hospitality__c,mapAdvocates.get(acc.Id)));
                }
             } else {
                lstDataDump0.add(new CustomerWrapper(acc.Name,acc.BillingCountryCode,acc.BillingCity,acc.BillingStateCode,acc.Purchased_License__c, (isAdvocate ? 'Yes' : 'No') ,acc.Id,acc.Sic,acc.SicDesc,acc.Account_Management_Tier__c,acc.Back_Office_System__c,acc.AM_Event__c, acc.AnnualRevenue,acc.of_Employees_New__c,acc.Segment__c,acc.Industry_for_Hospitality__c,acc.Industry_Sub_Segment_for_Hospitality__c,mapAdvocates.get(acc.Id)));
            }
        }         
        return lstDataDump0;
    }
    
    public List<CustomerWrapper> getLstDataDumpDownload ()  
    {  
        List<CustomerWrapper> lstDataDumpDownload = new List<CustomerWrapper>();
        List<Account> accountsList = Database.query(soqlStr);
        lstDataDumpDownload = prepareWrapperData(accountsList);
        return lstDataDumpDownload;
    }
    
    String soqlStr;
    final integer SOQLLIMIT = 100;
    public integer getSOQLLIMIT(){
        return SOQLLIMIT;
    }
    
    public boolean searchInitiated {get; set;}
    
    public PageReference searchAction()
    {
        searchInitiated = true;
        soqlStr = 'SELECT of_Employees_New__c,Share_of_Wallet_Client__c, AnnualRevenue, Purchased_License__c,Account_Status__c,BillingCountryCode,BillingCity,BillingStateCode,Name, AM_Event__c, Back_Office_System__c,Account_Management_Tier__c,Sic,SicDesc,Segment__c,Industry_Sub_Segment_for_Hospitality__c,Industry_for_Hospitality__c FROM Account WHERE Account_Status__c =\'Active\' ';
        if(selectedProduct != null){
            List<String> likeOptions = new List<String>();
            if(selectedProduct.equalsIgnoreCase('Event'))
                soqlStr = soqlStr + ' AND ' + ' CRDB_Products__c LIKE \'Products:%Event%\'';
            else if(selectedProduct.equalsIgnoreCase('CrowdCompass'))
                soqlStr = soqlStr + ' AND ' + ' CRDB_Products__c LIKE \'Products:%CrowdCompass%\'';
            else if(selectedProduct.equalsIgnoreCase('Event & CC'))
                soqlStr = soqlStr + ' AND ' + 'CRDB_Products__c LIKE \'%Event%\' AND CRDB_Products__c  LIKE \'%CrowdCompass%\'';      
            else if(selectedProduct.equalsIgnoreCase('Inquisium'))
                soqlStr = soqlStr + ' AND ' + ' CRDB_Products__c LIKE \'Products:%Survey%\'';
            else if(selectedProduct.equalsIgnoreCase('SMM'))
                soqlStr = soqlStr + ' AND ' + ' CRDB_Products__c LIKE \'Products:%SMM%\'';
             else if(selectedProduct.equalsIgnoreCase('CSN Planner'))
                soqlStr = soqlStr + ' AND ' + ' CRDB_Products__c LIKE \'Products:%CSN%\'';
            else if(selectedProduct.equalsIgnoreCase('Hospitality Cloud'))
                soqlStr = soqlStr + ' AND ' + ' CRDB_Products__c LIKE \'Products:%RFP%\'';       
        }
        
        if(acc.BillingCountryCode != null){
            soqlStr = soqlStr + ' AND ' + ' BillingCountryCode = \''+acc.BillingCountryCode + '\'';
        }    
        if(acc.BillingStateCode != null){
            soqlStr = soqlStr + ' AND ' + ' BillingStateCode = \''+acc.BillingStateCode + '\'';
        }    
        if(acc.Segment__c != null){
            soqlStr = soqlStr + ' AND ' + ' Segment__c = \''+acc.Segment__c + '\'';
        }  
        if(acc.Industry_for_Hospitality__c != null){
            soqlStr = soqlStr + ' AND ' + ' Industry_for_Hospitality__c = \''+acc.Industry_for_Hospitality__c + '\'';
        }  
        if(acc.Industry_Sub_Segment_for_Hospitality__c != null){
            soqlStr = soqlStr + ' AND ' + ' Industry_Sub_Segment_for_Hospitality__c = \''+acc.Industry_Sub_Segment_for_Hospitality__c + '\'';
        }  
        
        if(String.IsNotBlank(selectedSIC)){   // Added by Udita & commented (if(selectedSIC != null){)  : P-004644
            soqlStr = soqlStr + ' AND ' + ' SicDesc like \''+selectedSIC + '%\'';
        }   

        if(advocateOnly){
            soqlStr = soqlStr + ' AND ' + ' Customer_Advocate_Count_CRDB__c > 0 ';
        }  
        
        if(selectedRevenue != null && selectedRevenue != '--None--'){
            if(selectedRevenue.equalsIgnoreCase('Under $10,000'))
                soqlStr = soqlStr + ' AND ' + ' Share_of_Wallet_Client__c < 10000';
            else if(selectedRevenue.equalsIgnoreCase('$10,000-24,999'))
                soqlStr = soqlStr + ' AND ' + ' (Share_of_Wallet_Client__c > 10000 AND Share_of_Wallet_Client__c < 24999)';
            else if(selectedRevenue.equalsIgnoreCase('$25,000-$99,999'))
                soqlStr = soqlStr + ' AND ' + ' (Share_of_Wallet_Client__c > 25000 AND Share_of_Wallet_Client__c < 99999)';      
            else if(selectedRevenue.equalsIgnoreCase('$100,000+'))
                soqlStr = soqlStr + ' AND ' + ' Share_of_Wallet_Client__c > 100000';     
        }

        
        soqlStr = soqlStr + 'ORDER by Name';// LIMIT '+ SOQLLIMIT; //(advocateOnly ? SOQLLIMIT * 3 : SOQLLIMIT);
        //con = new ApexPages.StandardSetController([SELECT (select Id, of_Active_Advocate_with_Contact__c, FirstName, LastName, Title, Email, Phone, Job_Function__c, Mood__c, Manager_Email__c, RoleinDecision__c, MailingCity, MailingState, MailingCountry, AdvocateHub__Date_Joined_AdvocateHub__c from Contacts where AdvocateHub__Date_Joined_AdvocateHub__c != null),  of_Employees_New__c, AnnualRevenue, Purchased_License__c,Account_Status__c,BillingCountryCode,BillingCity,BillingStateCode,Name, AM_Event__c, Back_Office_System__c,Account_Management_Tier__c,Sic,SicDesc,Segment__c,Industry_Sub_Segment_for_Hospitality__c,Industry_for_Hospitality__c FROM Account WHERE Account_Status__c ='Active' and Event_Customer_CRDB__c = true limit 200]) ; 
        con = new ApexPages.StandardSetController(database.getQueryLocator(soqlStr));
        con.setPageSize(100);
        return null;
    }
    public Boolean hasNext  
    {  
        get  
        {  
            return con.getHasNext();  
        }  
        set;  
    }  
    public Boolean hasPrevious  
    {  
        get  
        {  
            return con.getHasPrevious();  
        }  
        set;  
    }  
    public Integer pageNumber  
    {  
        get  
        {  
            return con.getPageNumber();  
        }  
        set;  
    }  
    public void previous()  
    {  
        con.previous();  
    }  
    public void next()  
    {  
        con.next();  
    }  
    
    
    public Account acc {get; set;}
    public String selectedSIC {get; set;} 
    public String selectedProduct {get; set;}
    public String selectedRevenue {get; set;}
    public boolean advocateOnly {get; set;}
    public List<CustomerWrapper> exportData {get; set;}
    
    public PageReference initializeAction(){
        acc = new Account();
        acc.BillingCountryCode = 'US';
        lstDataDump = new List<CustomerWrapper>();
        searchInitiated = false;
        advocateOnly = false;
        return null;
    }
    
    public CustomerReferenceDB_Controller(){
        initializeAction();
    }
    
 
    @InvocableMethod
    public static void UpdateAdvocateStatusForAccount(List<Id> contactAccountIds) 
    {
        List<AggregateResult> contactAdvocates = 
            [select count(id), sum(of_Active_Advocate_with_Contact__c) from Contact  
               where accountId =:contactAccountIds[0] and AdvocateHub__Date_Joined_AdvocateHub__c != null];
        
        integer advSum = Integer.valueOf(contactAdvocates[0].get('expr0'));
        if(advSum>0){
            Account acc = new Account(id=contactAccountIds[0]);
            acc.Customer_Advocate_Count_CRDB__c = advSum;
            update acc;
        }
    }
    public PageReference saveExportCirteriaAction(){
        PageReference pg = new PageReference('/apex/CustomerReferenceDB_Download');
        //pg.setRedirect(true);
        return pg;
    }
    
    public PageReference generateExportDataAction(){
        return null;
    }
    
    public class CustomerWrapper{
        public String Name {get; set;}
        public String City {get; set;}
        public String State {get; set;}
        public String Country {get; set;}
        public String Product {get; set;}
        public String IsAdvocate {get; set;}
        public String Id {get; set;}
        public String Sic {get; set;}
        public String SicDesc{get; set;}
        public String Tier{get; set;}
        public String BackOfficeSystem{get;set;}
        public String AmEvent{get;set;}
        public Decimal Rev{get;set;}
        public String Employees{get;set;}
        public String Segment{get;set;}
        public String Industry{get;set;}
        public String SubSegment{get;set;}
        public Integer advCount{get;set;}
        public List<Contact> advocateList {get; set;}
        
        public CustomerWrapper(String Name,String Country,String City,String State,String Product,String IsAdvocate,String Id,String Sic,String SicDesc,String Tier,String BackOfficeSystem, String  AmEvent, Decimal Rev,String Employees,String Segment,String Industry,String SubSegment, List<Contact> advocateList0) {
            this.Name = Name;
            this.Country =Country;
            this.State =State ;
            this.City=City;
            this.Product = Product;
            this.IsAdvocate=IsAdvocate;
            this.Id = Id;
            this.Sic = Sic;
            this.SicDesc = SicDesc;
            this.Tier = Tier;
            this.BackOfficeSystem = BackOfficeSystem;
            this.AmEvent = AmEvent;
            this.Rev = Rev;
            this.Employees = Employees;
            this.Segment= Segment;
            this.Industry = Industry;
            this.SubSegment = SubSegment;
            
            this.advocateList = advocateList0;
            this.advCount = advocateList != null ? advocateList.size() : 0;
/*          if(advocateList != null){
                for(Contact cnt: advocateList){
                    if(cnt.of_Active_Advocate_with_Contact__c>0)
                        this.advCount++; 
                }                
            } */
        }
    }
}