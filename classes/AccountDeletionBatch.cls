/**=====================================================================
 * Cvent
 * Name: AccountDeletionBatch
 * Description: Batch Class for Deleting Account on below conditions
 * Created Date: [12/20/2016]
 * Created By: Hemant Rana
 * 
 * Date Modified                Modified By                  Description of the update
 * [MON DD, YYYY]               [FirstName LastName]         [Short description for changes]
 
 * Rules used in this for deletion - 

Should not be a client account (Current/Former) - Account Status should be blank
Should not have an open activity attached (NOPE)
Should not have a closed activity assigned in last 2 years (NOPE)
Should not have any opportunity attached (NOPE)
Should not have  Cvent Account ID updated- Cvent Account ID equals Blank 
Should not have  Cvent Account ID updated- Crowdcompass  Account ID equals Blank
Should not have CSN ID Updated - CSN ID should be Blank
Should not be created in last 1 year 
Should not starts with 'CSN' in “Type” field (NOPE)
Should not have a valid contact attached - Should not have any contact attached (NOPE)
Should not have Named Account Field Updated - Named Acct field should be blank
Should not be a top account - Top Account field should be blank
Should not be a Seed Account - Seed Account Field Should be blank or False
Should not have Account Trial Status field updated - Should be blank


 =====================================================================*/ 

global class AccountDeletionBatch implements Database.Batchable<sObject>{//,Database.stateful{
    Date oneYearBackDate;
    Set<Id> accountIdSet;
    DateTime todayDateTime;
    List<Account> accDeleteList;
    DeletedAccountId__c accDel;
    List<DeletedAccountId__c> accDelList;
    Date twoYearBackDate;
    DateTime twoYearBackDateTime;

    global AccountDeletionBatch()
    {
        twoYearBackDate=Date.Today().addYears(-2);

        oneYearBackDate=Date.Today().addYears(-1);
        todayDateTime=System.now();
        twoYearBackDateTime=datetime.newInstance(twoYearBackDate.year(), twoYearBackDate.month(),twoYearBackDate.day()); 

    }
    global Database.querylocator start(Database.BatchableContext BC){

        //String query='SELECT Id,Title FROM Contact WHERE  (Planner_Account_Self_SignUp_Date__c=null OR Planner_Account_Self_SignUp_Date__c<:twoYearBackDate) AND (FT_Sign_Up__c=null OR FT_Sign_Up__c<:twoYearBackDate) AND Contact.Account.Supplier_Status__c!='+'\''+'Approved'+'\''+' AND Contact.Account.Supplier_Status__c!='+'\''+'Reflagged'+'\''+' AND ((NOT Contact.Account_Status__c LIKE '+'\''+ 'Active%'+'\''+') OR (Contact.Account_Status__c=null)) AND Marketo_Active__c=False AND (of_RFPs_Sent__c=null OR of_RFPs_Sent__c=0) AND CreatedDate < : oneYearBackDate AND CRMList__c=null AND CSN_Planner_A_C__c ='+'\''+'\'' + ' AND Survey_FT_A_C__c ='+'\''+'\'' +' AND Contact.Account.Named_Acct__c=null ' + ' AND Federation_ID__c ='+'\''+'\'' ;
        
        String query ='SELECT Id,Cvent_Account_ID__c,Type,CrowdCompass_Account_ID__c,CSN_ID__c,Account_Trial_Status__c FROM Account WHERE Account_Status__c = null AND CreatedDate < : oneYearBackDate AND Named_Acct__c=null AND Top_Accounts__c = null AND Seed_Account__c = null';
        
        System.debug('query------>>>>'+query);
        
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Account> scope){
        accDeleteList = new List<Account>();
        accDelList = new List<DeletedAccountId__c>();
        accountIdSet = new Set<Id>();
        For(Account accObj : scope)
        {
            if(String.isBlank(accObj.Cvent_Account_ID__c) && String.isBlank(accObj.CrowdCompass_Account_ID__c) && String.isBlank(accObj.CSN_ID__c) && String.isBlank(accObj.Account_Trial_Status__c) && (accObj.Type==null || (accObj.Type!=null && !accObj.Type.StartsWith('CSN'))))
            {
                accountIdSet.add(accObj.Id);
            }
        }
        //,(SELECT Id FROM Tasks WHERE Status!='Completed')
        For(Account accRec : [SELECT Id,Name, (SELECT Id FROM Contacts LIMIT 1),(SELECT Id FROM Opportunities LIMIT 1)
,(SELECT Id FROM Tasks WHERE (Status='Completed' AND (CreatedDate<:todayDateTime AND CreatedDate>:twoYearBackDateTime)) OR (Status!='Completed') LIMIT 1)
            FROM Account WHERE Id IN : accountIdSet])
        {
            if(accRec.contacts.size()==0 && accRec.Opportunities.size()==0 && accRec.Tasks.size()==0)
            {
                accDeleteList.add(accRec);
            }
    }
        For(Account accVal : accDeleteList)
        {
            accDel = new DeletedAccountId__c();
            accDel.Account_Id__c =accVal.Id;
            accDel.Account_Name__c = accVal.Name ;
            accDelList.add(accDel);
        }
        //insert accDelList;
        Database.SaveResult[] drList = Database.insert(accDelList, false);
        //Database.DeleteResult[] drList = Database.delete(accDeleteList, false);
    }
    global void finish(Database.BatchableContext BC){
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email, CreatedBy.Name , ExtendedStatus  from AsyncApexJob where Id = :BC.getJobId()]; 
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
        String[] toAddresses = new String[] {a.CreatedBy.Email,'SBhalla@cvent.com','hrana@cvent.com'};  
        mail.setToAddresses(toAddresses);  
        mail.setSubject('Account deletion BatchJob Status: ' + a.Status);
        String body='<span style='+'\''+'color:#1F497D; font-size:11.0pt;font-family:"Calibri",sans-serif;'+'\''+'><b>Hi '+a.CreatedBy.Name+',  </b></br></br>Account Id has been inserted into "DeletedAccountId" Object API Name - "DeletedAccountId__c".</br></br>Please take the back up.</br></br><b>Total Batch Processed:</b> '+a.JobItemsProcessed+'</span></br><span style='+'\''+'font-size:11.0pt;font-family:"Calibri",sans-serif;color:#000000'+'\''+'><b>Thanks,</br>'+'Salesforce'+'<o:p></o:p></b></span>';
        mail.setHtmlBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}