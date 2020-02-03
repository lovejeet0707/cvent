//*********************************************************************************** 
//
//  Account_Partner_RollupBatch
//
//  Desciption:
//  This class was created by InSitu Software for cVent. The purpose of the class is to provide a schedulable
//  Apex Job routine to provide a 'Rollup' of account partner information to the associated account.
//
//  History:
//  InSitu  10/20/2013  Original version.
//  InSitu  11/14/2013  Updated to support configurable/dynamic role values and account fields.
//
// ***********************************************************************************

global with sharing class Account_Partner_RollupBatch implements Database.Batchable<sObject>, Database.Stateful
{
    ///////////////////////////////////////////////////
    //  Constants
    ///////////////////////////////////////////////////

    
    ///////////////////////////////////////////////////
    //  Member variables
    ///////////////////////////////////////////////////
   
    global integer m_iLimit;        // Need this to limit the amount of processing for unit test purposes.
    Map<String, Account_Partner_Roles__c>   m_mapAcctPartnerRoles;
    List<String>                            m_listRoles = new List<String>();
    List<String>                            m_listFieldNames = new List<String>();
    String                                  m_strQuery;
    Integer                                 m_iRecordsUpdated = 0;
 
    // Constructor
    global Account_Partner_RollupBatch (integer iLimit)
    {
        m_iLimit = iLimit; 
        
        // Load up the custom setting containing the Partner Role to Account Field mapping.
        m_mapAcctPartnerRoles = Account_Partner_Roles__c.getAll();
        
        // Get the list of Role values.
        Set<String>setRoles = m_mapAcctPartnerRoles.keySet();
        m_listRoles.addAll(setRoles);
        system.debug(Logginglevel.WARN, 'InSitu Debug: m_listRoles = ' + m_listRoles);
        
        // Get list of field names.
        List<Account_Partner_Roles__c> listAPR = m_mapAcctPartnerRoles.values();
        for (Account_Partner_Roles__c APR : listAPR)
        {
            m_listFieldNames.add(APR.Account_Role_Field_API_Name__c);
        }
        system.debug(Logginglevel.WARN, 'InSitu Debug: m_listFieldNames = ' + m_listFieldNames);
        
        // Format query string.
        m_strQuery = 'SELECT Id, ';
        m_strQuery += String.join(m_listFieldNames, ', ');
        m_strQuery += ', (SELECT Role__c, Role_Select__c, Partner__c, Partner__r.Name, Account__c FROM Account_Partners__r) ';
        m_strQuery += 'FROM Account WHERE Id IN :setAcctIDs';
        system.debug(Logginglevel.WARN, 'InSitu Debug: m_strQuery = ' + m_strQuery);
    }
    
    //----------------------------------------------------------------------- 
    //  runAccount_Partner_RollupBatch
    //
    //  This method is provided in order to initiate the batch job from 
    //  any Apex code.
    //
    //  iLimit - determines the number of records to be processed.
    //  iBatchSize - determines the number of records in each batch size. Minimum is 1, Maximum is 200, Default is 10.
    //----------------------------------------------------------------------- 

    global static ID runAccount_Partner_RollupBatch(integer iLimit, integer iBatchSize)
    {
        Id idJob = null;
        
        // Make sure the batch size is greater than 0, but less than 201.
        if (iBatchSize == null || iBatchSize < 1)
            iBatchSize = 10;
        else if (iBatchSize > 200)
            iBatchSize = 200;

        // Check governor limits first - Determine if there are already more than 5 jobs in the queue before adding another one.
        Set<String> setStatus = new Set<String>{'Queued', 'Processing', 'Preparing'};
        Set<String> setJobType = new Set<String>{'BatchApex'};
        integer iCnt = [SELECT count() FROM AsyncApexJob WHERE Status in :setStatus AND JobType in :setJobType];
        if (iCnt < 5)
        {
            // The calculation is going to be done in batch. Create an instance of the Apex Batch class and
            // initiate the batch processing.
            Account_Partner_RollupBatch batchARCalc = new Account_Partner_RollupBatch(iLimit);
            idJob = database.executeBatch(batchARCalc, iBatchSize);
            system.debug(Logginglevel.WARN, 'InSitu Debug: Batch job successfully queued.');
        }
        else
        {
            system.debug(Logginglevel.WARN, 'InSitu Debug: Cannot queue batch job since there are already 5 in the queue.');
        }
            
        return idJob;
    }

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        // Query String that drives the batch process - Process all accounts
        String sQuery = 'SELECT id FROM Account';
            
        if (m_iLimit > 0)
            sQuery += ' LIMIT ' + m_iLimit;
        
        return Database.getQueryLocator(sQuery );
    }

    global void execute(Database.BatchableContext BC, sObject[] listObjects)
    {
        // Build set of Account UP Ids for records that will be aggregated.
        List<Account> listAcctObjs = (List<Account>)listObjects;
        Set<ID> setAcctIDs = new Set<ID>();
        for (Account acctObj : listAcctObjs)
            setAcctIDs.add(acctObj.ID);
            
        // Query for all the associated Partner Account Records.
        List<Account> listAccts = database.query(m_strQuery); 
                                          
        // For each Account, iterate through the related Account Partner records.
        List<Account> listAcctsToUpdate = new List<Account>();
        for (Account acct : listAccts)
        {
            // Use map of lists to store Partner Account name.
            Map<String, List<String>> mapRoleToListPartnerNames = new Map<String, List<String>>();
            for (String strRole : m_listRoles)
                mapRoleToListPartnerNames.put(strRole, new List<String>());
            
            for (Account_Partner__c  acctPartner : acct.Account_Partners__r)
            {
                if (acctPartner.Role_Select__c != null)
                {
                    // Split the list of Role Values
                    List<String> listRoleValues = acctPartner.Role_Select__c.split(';', 0);
                    for (String strRole : listRoleValues)
                    {
                        // Add the partner name to the list based on the role value.
                        if (mapRoleToListPartnerNames.get(strRole) != null)
                            mapRoleToListPartnerNames.get(strRole).add(acctPartner.Partner__r.Name);
                    }
                }
            }
            
            // Analyze results of Partner Account mapping and determine what fields need to be updated.
            Boolean bUpdate = false;
            for (String strRole : m_listRoles)
            {
                // Get the setting record for the given role (in order to get the associated account field)
                Account_Partner_Roles__c apr = m_mapAcctPartnerRoles.get(strRole);
                String strFieldName = apr.Account_Role_Field_API_Name__c;
                
                // Get the partner account names for the role (if any)
                List<String> listPartnerNames = mapRoleToListPartnerNames.get(strRole);
                String strNewFieldValue = formatPartnerList(listPartnerNames);
                
                // Get the current value for the account field.
                String strOldFieldValue = String.valueOf(acct.get(strFieldName));
                
                // Only update if the field value has changed.
                if (strNewFieldValue != strOldFieldValue)
                {
                    system.debug(Logginglevel.WARN, 'strNewFieldValue = ' + strNewFieldValue + ', strOldFieldValue = ' + strOldFieldValue);
                    acct.put(strFieldName, strNewFieldValue);
                    bUpdate = true;
                }
            }
            
            // Determine if Account record needs to be updated.
            if (bUpdate)
            {
                listAcctsToUpdate.add(acct);
            }
        }

        // Update applicable accounts.
        if (listAcctsToUpdate.size() > 0)
        {
            update listAcctsToUpdate;
            m_iRecordsUpdated += listAcctsToUpdate.size();
        }
    }

    private String formatPartnerList (List<String> listValues)
    {
        String strRetVal = null;
        if (listValues.size() > 1)
        {
            // Sort values.
            listValues.sort();
            
            // Format values.
            String sFormattedValue = String.join(listValues, ', ');
                
            // Set formatted value - Field value cannot be more than 255.
            strRetVal = sFormattedValue.abbreviate(255);
        }
        else if (listValues.size() == 1)
        {
            // Only one value, so the display name is the same as the multi-select field value.
            strRetVal = listValues[0];
        }
        
        return strRetVal;
    }
    
    
    global void finish(Database.BatchableContext BC)
    {
        system.debug(Logginglevel.WARN, 'InSitu Debug: m_iRecordsUpdated = ' + m_iRecordsUpdated);


        // Get the ID of the AsyncApexJob representing this batch job from Database.BatchableContext.
        // Query the AsyncApexJob object to retrieve the current job's information.
        ID idJob = BC.getJobId();
        AsyncApexJob apexjobUP =  [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
                                    FROM AsyncApexJob WHERE Id = :idJob];

        // Because of test coverage issues in this class, need to create the 'failure' email message and only
        // send if there is truly a failure.
        // I can't seem to find a way to fail the job from a test.
        Messaging.SingleEmailMessage emailNotify = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {apexjobUP.CreatedBy.Email};
        emailNotify.setToAddresses(toAddresses);
        emailNotify.setSubject('Partner Account Rollup Calculation - Completed with Errors');
        emailNotify.setPlainTextBody(
            'Your Partner Account Rollup Calculation request completed, however the job reported ' + apexjobUP.NumberOfErrors + 
            ' errors. The accounts processed as part of the batch(es) in which errors occurred were not updated. If your Partner Account ' +
            'Rollup Calculation requests continue to fail, contact your system administrator.');
            
        // if the job did not complete successfully, then send an email to the job's submitter letting them know that there was a problem.
        if (apexjobUP.Status == 'Failed')
        {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { emailNotify });
        }
    }  
}