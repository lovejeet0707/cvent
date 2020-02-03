/**=====================================================================
 * Cvent
 * Name: ContactDeletionBatch
 * Description: Batch Class for Inserting contactId's in "Contact_Id__c" Object on some conditions and after this batch will be completed another batch will run 
                 "ContactIdDeletionBatch" which will delete the respected CONTACT record and also the data in this Object.
 * Created Date: [10/05/2016]
 * Created By: Hemant Rana
 * 
 * Date Modified                Modified By                  Description of the update
 * [MON DD, YYYY]               [FirstName LastName]         [Short description for changes]
 
 * Rules used in this for deletion - 
   Contact that are not created in last 1 Year – can not be deleted
   Contacts not attached to Named Account – can be deleted
   Contact that does not have Cvent Titles updated – can be deleted
   Contacts that have no activities at all – can be deleted
   Contacts that have no activity in last 2 Years – can be deleted
   Contacts without cases – can be deleted
   Contact without any open activities – can be deleted
   Planner contacts that have sourced RFP but no activity – can be deleted
   Contacts not linked with an open opportunity – can be deleted
   Contacts not linked with any closed opportunity (opportunity that is closed in last one year) – can be deleted
   Contact not linked with closed won opportunity – can be deleted
   Contacts that are not CRM active – can be deleted
   Contacts that are not attached to a client account (Current/Former – Active/Inactive) – can be deleted
   Contacts that have no federation ID updated – Portal contacts should not be deleted – can be deleted
   Contacts without  “CSN Planner account #”  - can be deleted
   Contacts without Inquisium FT A/C # - can be deleted
   Contacts that have ‘Planner Account Self SignUp Date’ 2 years before – can be deleted
   Contacts that have ‘FT Sign Up Date (Inquisium)’ 2 years before – can be deleted
   Contacts that are not attached to an accounts where ‘Account supplier status’ is ‘approved’ or ‘reflagged’ – can be deleted
   Contacts that have no certification attached to it – This is specific to CSN and they are Cvent certified planner. Therefore has to be retained, if certification attached – can be deleted
   Contact Marketo Active = False – can be deleted

 =====================================================================*/ 

global class ContactDeletionBatch implements Database.Batchable<sObject>{//,Database.stateful{
    Date twoYearBackDate;
    Date oneYearBackDate;
    Date todayDate;
    DateTime twoYearBackDateTime;
    DateTime todayDateTime;
    Set<Id> contactIdSet;
    Set<String> cventTitleSet;
    public datetime m=system.now();
    //Integer deletedContactCount;
    Contact_Id__c conDel;//Object in which contactId will be stored which are going to be deleted
    List<Contact_Id__c> conDelList;
    Map<Id,Contact> contactIdVsContact;
    global ContactDeletionBatch()
    {
        cventTitleSet=new Set<String> ((Label.Contact_Titles+','+Label.Contact_Titles1+','+Label.Contact_Titles2).split(','));
        todayDateTime=System.now();
        todayDate=system.today();
        twoYearBackDate=Date.Today().addYears(-2);
        twoYearBackDateTime=datetime.newInstance(twoYearBackDate.year(), twoYearBackDate.month(),twoYearBackDate.day()); 
        oneYearBackDate=Date.Today().addYears(-1);
        //deletedContactCount=0;
    }
    global Database.querylocator start(Database.BatchableContext BC){
        //Latest Also have to remove LASTMODIFIEDDATE-- Remove Opportunity Where Clause> String query='SELECT Id,CRMList__c,Title,CSN_Planner_A_C__c,Survey_FT_A_C__c,Named_Acct__c,Account.Named_Acct__c,Federation_ID__c,(SELECT Id FROM Tasks WHERE Status!='+'\''+'Not Started'+'\''+' AND (CreatedDate<:todayDateTime AND CreatedDate>:twoYearBackDateTime) LIMIT 1),(SELECT Id FROM Events WHERE (CreatedDate<:todayDateTime AND CreatedDate>:twoYearBackDateTime) LIMIT 1),(SELECT Id FROM Cases  LIMIT 1),(SELECT Id FROM Opportunities_Cust__r WHERE   (IsClosed = FALSE AND IsWon=FALSE) OR (IsClosed = TRUE AND IsWon=TRUE) OR (IsClosed = TRUE AND (CloseDate>:oneYearBackDate AND CloseDate< :todayDate)) LIMIT 1),(SELECT Id FROM Client_Certifications__r  LIMIT 1) FROM Contact WHERE  (Planner_Account_Self_SignUp_Date__c=null OR Planner_Account_Self_SignUp_Date__c<:twoYearBackDate) AND (FT_Sign_Up__c=null OR FT_Sign_Up__c<:twoYearBackDate) AND Contact.Account.Supplier_Status__c!='+'\''+'Approved'+'\''+' AND Contact.Account.Supplier_Status__c!='+'\''+'Reflagged'+'\''+' AND ((NOT Contact.Account_Status__c LIKE '+'\''+ 'Active%'+'\''+') OR (Contact.Account_Status__c=null)) AND Marketo_Active__c=False AND (of_RFPs_Sent__c=null OR of_RFPs_Sent__c=0) AND CreatedDate < : oneYearBackDate AND LastModiFiedDate > : tempDate' ;
        
        //String query='SELECT Id,CRMList__c,Title,CSN_Planner_A_C__c,Survey_FT_A_C__c,Named_Acct__c,Account.Named_Acct__c,Federation_ID__c,(SELECT Id FROM Tasks WHERE Status!='+'\''+'Not Started'+'\''+' AND (CreatedDate<:todayDateTime AND CreatedDate>:twoYearBackDateTime) LIMIT 1),(SELECT Id FROM Events WHERE (CreatedDate<:todayDateTime AND CreatedDate>:twoYearBackDateTime) LIMIT 1),(SELECT Id FROM Cases  LIMIT 1),(SELECT Id FROM Opportunities_Cust__r LIMIT 1),(SELECT Id FROM Client_Certifications__r  LIMIT 1) FROM Contact WHERE  (Planner_Account_Self_SignUp_Date__c=null OR Planner_Account_Self_SignUp_Date__c<:twoYearBackDate) AND (FT_Sign_Up__c=null OR FT_Sign_Up__c<:twoYearBackDate) AND Contact.Account.Supplier_Status__c!='+'\''+'Approved'+'\''+' AND Contact.Account.Supplier_Status__c!='+'\''+'Reflagged'+'\''+' AND Contact.Account_Status__c=null AND Marketo_Active__c=False AND (of_RFPs_Sent__c=null OR of_RFPs_Sent__c=0) AND CreatedDate < : oneYearBackDate AND LastModiFiedDate > : tempDate' ;
        
        //15Dec Query String query='SELECT Id,CRMList__c,Title,CSN_Planner_A_C__c,Survey_FT_A_C__c,Named_Acct__c,Account.Named_Acct__c,Federation_ID__c,(SELECT Id FROM Tasks WHERE Status!='+'\''+'Not Started'+'\''+' AND (CreatedDate<:todayDateTime AND CreatedDate>:twoYearBackDateTime) LIMIT 1),(SELECT Id FROM Events WHERE (CreatedDate<:todayDateTime AND CreatedDate>:twoYearBackDateTime) LIMIT 1),(SELECT Id FROM Cases  LIMIT 1),(SELECT Id FROM Opportunities_Cust__r LIMIT 1),(SELECT Id FROM Client_Certifications__r  LIMIT 1) FROM Contact WHERE  (Planner_Account_Self_SignUp_Date__c=null OR Planner_Account_Self_SignUp_Date__c<:twoYearBackDate) AND (FT_Sign_Up__c=null OR FT_Sign_Up__c<:twoYearBackDate) AND Contact.Account.Supplier_Status__c!='+'\''+'Approved'+'\''+' AND Contact.Account.Supplier_Status__c!='+'\''+'Reflagged'+'\''+' AND ((NOT Contact.Account_Status__c LIKE '+'\''+ 'Active%'+'\''+') OR (Contact.Account_Status__c=null)) AND Marketo_Active__c=False AND (of_RFPs_Sent__c=null OR of_RFPs_Sent__c=0) AND CreatedDate < : oneYearBackDate' ;
        
        String query='SELECT Id,Name,Federation_ID__c,CSN_Planner_A_C__c,Contact.Account.Named_Acct__c,of_RFPs_Sent__c,CRMList__c,Title,Contact.Account.Supplier_Status__c FROM Contact WHERE (Planner_Account_Self_SignUp_Date__c=null OR Planner_Account_Self_SignUp_Date__c<:twoYearBackDate) AND (FT_Sign_Up__c=null OR FT_Sign_Up__c<:twoYearBackDate) AND (((NOT Contact.Account_Status__c LIKE '+'\''+ 'Active%'+'\''+') AND (NOT Contact.Account_Status__c LIKE '+'\''+ 'InActive%'+'\''+')) OR (Contact.Account_Status__c=null)) AND Marketo_Active__c=False AND CreatedDate < : oneYearBackDate';
        System.debug('query************'+query);
        return Database.getQueryLocator(query);
    }
    Set<Id> conIdSet;
    global void execute(Database.BatchableContext BC, List<Contact> scope){
        conDelList = new List<Contact_Id__c>();
        contactIdVsContact=new Map<Id,Contact>();
        conIdSet = new Set<Id>();
        For(Contact conObj : scope)
        {
            if((conObj.Federation_ID__c=='' || String.isBlank(conObj.Federation_ID__c)) /*&& (conObj.Survey_FT_A_C__c=='' || String.isBlank(conObj.Survey_FT_A_C__c))*/&& (conObj.CSN_Planner_A_C__c =='' ||String.isBlank(conObj.CSN_Planner_A_C__c)) && conObj.Account.Named_Acct__c==null && conObj.CRMList__c==null && 
            conObj.Account.Supplier_Status__c!='Approved' && conObj.Account.Supplier_Status__c!='Reflagged' && (conObj.of_RFPs_Sent__c==null || conObj.of_RFPs_Sent__c==0))//UD:Commented for FP:4thApril

                {
                    conIdSet.add(conObj.Id);
                }
        }
        
        For(Contact conRec : [SELECT Id,Title,Name,(SELECT Id FROM Cards_CC__r LIMIT 1),(SELECT Id FROM Tasks WHERE Status!='Not Started' AND (CreatedDate<:todayDateTime AND CreatedDate>:twoYearBackDateTime) LIMIT 1),(SELECT Id FROM Events WHERE (CreatedDate<:todayDateTime AND CreatedDate>:twoYearBackDateTime) LIMIT 1),(SELECT Id FROM Cases  LIMIT 1),(SELECT Id FROM Opportunities_Cust__r LIMIT 1),(SELECT Id FROM Client_Certifications__r  LIMIT 1) FROM Contact WHERE Id IN : conIdSet])
        {
            if(conRec.Cards_CC__r.size()==0  && conRec.Tasks.size()==0 && conRec.Events.size()==0 && conRec.Cases.size()==0 && conRec.Client_Certifications__r.size()==0 && conRec.Opportunities_Cust__r.size()==0)
            {
                if(conRec.Title!=null)
                {
                    if(conRec.Title.contains(',')){
                        For(String cventTitle : conRec.Title.split(','))
                        {
                            if(!cventTitleSet.contains(cventTitle))
                            {
                                contactIdVsContact.put(conRec.Id,conRec);
                            }
                        }
                    }
                    else if(!cventTitleSet.contains(conRec.Title))
                    {
                        contactIdVsContact.put(conRec.Id,conRec);
                    }
                }
                else
                contactIdVsContact.put(conRec.Id,conRec);
            }
        }

        For(Id conIdV : contactIdVsContact.keySet())
        {
            conDel = new Contact_Id__c();
            conDel.ContactId__c=conIdV;
            conDel.Contact_Name__c = contactIdVsContact.get(conIdV).Name ;
            conDelList.add(conDel);
        }
        //insert conDelList;
        Database.SaveResult[] drList = Database.Insert(conDelList, false);
        //Database.DeleteResult[] drList = Database.delete(contactIdVsContact.values(), false);
        //delete contactIdVsContact.values();
    }
    global void finish(Database.BatchableContext BC){
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email, CreatedBy.Name , ExtendedStatus  from AsyncApexJob where Id = :BC.getJobId()]; 
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
        String[] toAddresses = new String[] {a.CreatedBy.Email,'SBhalla@cvent.com','hrana@cvent.com'};  
        mail.setToAddresses(toAddresses);  
        mail.setSubject('Contact deletion BatchJob Status: ' + a.Status);
        String body='<span style='+'\''+'color:#1F497D; font-size:11.0pt;font-family:"Calibri",sans-serif;'+'\''+'><b>Hi '+a.CreatedBy.Name+',  </b></br></br>Contact Id has been inserted into "Contact Id" Object API Name - "Contact_Id__c".</br></br>Please take the back up.</br></br><b>Total Batch Processed:</b> '+a.JobItemsProcessed+'</span></br><span style='+'\''+'font-size:11.0pt;font-family:"Calibri",sans-serif;color:#000000'+'\''+'><b>Thanks,</br>'+'Salesforce'+'<o:p></o:p></b></span>';
        mail.setHtmlBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}