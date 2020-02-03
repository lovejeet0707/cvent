@istest(SeeAllData=false)
// *********************************************************************************** 
//
//  AccountPartnerTest
//    
//  Desciption:
//  This class was created by InSitu Software for Cvent. The purpose of this class
//  is to test the processing of the Account Paretner Rollup Batch Apex Calculation
//  and other associated processing, including the scheduled execution.
//   
//  History:
//  InSitu  11/13/2013  Original version. 
//
// ***********************************************************************************

class AccountPartnerTest 
{
    //--------------------------------------------------------------------------------
    //  testAccountPartner_Rollup_Sched()
    // -------------------------------------------------------------------------------
    public static testMethod void testAccountPartner_Rollup_Sched() 
    {
        Test.startTest();

        // Run the scheduled job at midnight Sept. 3rd. 2022  
        String CRON_EXP = '0 0 0 3 9 ? 2022';
        String jobId = System.schedule('testScheduledRollupCalc', CRON_EXP, new Account_Partner_RollupSched());
        
        // Get the information from the CronTrigger API object  
        CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

        // Verify the expressions are the same  
        System.assertEquals(CRON_EXP, ct.CronExpression);

        // Verify the job has not run  
        System.assertEquals(0, ct.TimesTriggered);

        // Verify the next time the job will run  
        System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));
        Test.stopTest();
    }
    
    //--------------------------------------------------------------------------------
    //  testAccountPartner_Rollup_Calc()
    // -------------------------------------------------------------------------------
    public static testMethod void testAccountPartner_Rollup_Calc() 
    {
		// If role and field names change - just update the values in these 2 lists.
		List<String> listRoleNames = new List<String>{'Advertising Agency', 'Chain Affiliation', 'Management Company', 'Other Chain Name', 'Ownership Group'};
		List<String> listFieldNames = new List<String>{'Partner_Advertising_Agency__c', 'Partner_Chain_Affiliation__c', 'Partner_Management_Company__c', 'Partner_Other_Chain_Name__c', 'Partner_Ownership_Group__c'};
		
		// Create the custom settings records for the 5 fields we know exist.
		List<Account_Partner_Roles__c> listAPRSettings = new List<Account_Partner_Roles__c>();
		for (integer iIdx = 0; iIdx < listRoleNames.size(); iIdx++)
		{ 
			listAPRSettings.add(new Account_Partner_Roles__c(Name = listRoleNames[iIdx], Account_Role_Field_API_Name__c = listFieldNames[iIdx]));
		}
		insert listAPRSettings;
		
        // ==============================================
        // Create test data - a couple accounts representing accounts and partner accounts
        // ==============================================
        Account acctA1 = new Account(Name = 'AAA-Account');
        insert acctA1;
        
        Account acctP1 = new Account(Name = 'CCC-Partner');
        insert acctP1;

    	Test.startTest();

        // ==============================================
        // Create account partner records.
        // ==============================================
		
		// Select all roles for A1-P1 relationship.
		String strRoleValues = String.join(listRoleNames, ';');
		Account_Partner__c apA1P1 = new Account_Partner__c(Account__c = acctA1.id, Partner__c = acctP1.id, Role_Select__c = strRoleValues);
        insert apA1P1;

    	// Call the static method to execute the queuing of the batch job.
        ID idJob = Account_Partner_RollupBatch.runAccount_Partner_RollupBatch(0, 300);

    	Test.stopTest();
    	
    	// Verify results.
		
		// Format query string and execute.
		String strFieldNames = String.join(listFieldNames, ', ');
		String strQuery = 'SELECT Id, Name, ' + strFieldNames + ' FROM Account ORDER BY Name ASC ';
	    List<Account> listAccts = database.query(strQuery); 
	    
		// Validate results - all fields should have partner name in it.
    	System.assertEquals('AAA-Account', listAccts[0].Name);
	    for (String strFieldName : listFieldNames)
	    {
	    	System.assertEquals('CCC-Partner', String.valueOf(listAccts[0].get(strFieldName)));
	    }

    }

    //--------------------------------------------------------------------------------
    //  testAccountPartner_Rollup_Calc2()
    // -------------------------------------------------------------------------------
    public static testMethod void testAccountPartner_Rollup_Calc2() 
    {
		// If role and field names change - just update the values in these 2 lists.
		List<String> listRoleNames = new List<String>{'Advertising Agency', 'Chain Affiliation', 'Management Company', 'Other Chain Name', 'Ownership Group'};
		List<String> listFieldNames = new List<String>{'Partner_Advertising_Agency__c', 'Partner_Chain_Affiliation__c', 'Partner_Management_Company__c', 'Partner_Other_Chain_Name__c', 'Partner_Ownership_Group__c'};
		
		// Create the custom settings records for the 5 fields we know exist.
		List<Account_Partner_Roles__c> listAPRSettings = new List<Account_Partner_Roles__c>();
		for (integer iIdx = 0; iIdx < listRoleNames.size(); iIdx++)
		{ 
			listAPRSettings.add(new Account_Partner_Roles__c(Name = listRoleNames[iIdx], Account_Role_Field_API_Name__c = listFieldNames[iIdx]));
		}
		insert listAPRSettings;
		
        // ==============================================
        // Create test data - a couple accounts representing accounts and partner accounts
        // ==============================================
        Account acctA1 = new Account(Name = 'AAA-Account');
        insert acctA1;
        
        Account acctA2 = new Account(Name = 'BBB-Account');
        insert acctA2;
        
        Account acctP1 = new Account(Name = 'CCC-Partner');
        insert acctP1;
        
        Account acctP2 = new Account(Name = 'DDD-Partner');
        insert acctP2;

    	Test.startTest();

        // ==============================================
        // Create account partner records.
        // ==============================================
		
		// Select all roles for A1-P1 and A1-P1 relationship.
		String strRoleValues = String.join(listRoleNames, ';');
		Account_Partner__c apA1P1 = new Account_Partner__c(Account__c = acctA1.id, Partner__c = acctP1.id, Role_Select__c = strRoleValues);
        insert apA1P1;
        
		Account_Partner__c apA1P2 = new Account_Partner__c(Account__c = acctA1.id, Partner__c = acctP2.id, Role_Select__c = strRoleValues);
        insert apA1P2;

    	// Call the static method to execute the queuing of the batch job.
        ID idJob = Account_Partner_RollupBatch.runAccount_Partner_RollupBatch(20, null);

    	Test.stopTest();
    	
    	// Verify results.
		
		// Format query string and execute.
		String strFieldNames = String.join(listFieldNames, ', ');
		String strQuery = 'SELECT Id, Name, ' + strFieldNames + ' FROM Account ORDER BY Name ASC ';
	    List<Account> listAccts = database.query(strQuery); 
	    
		// Validate results - all fields should have partner name in it.
    	System.assertEquals('AAA-Account', listAccts[0].Name);
	    for (String strFieldName : listFieldNames)
	    {
	    	System.assertEquals('CCC-Partner, DDD-Partner', String.valueOf(listAccts[0].get(strFieldName)));
	    }
	    
        // Verify that the 'Role__c' value was properly formatted on the Account_Partner record.
        apA1P1 = [SELECT id, Role__c FROM Account_Partner__c WHERE ID = :apA1P1.id];
        
	    // Sort values.
	    listRoleNames.sort();
	    String sFormattedValue = String.join(listRoleNames, '; ');
	    sFormattedValue = sFormattedValue.abbreviate(255);
        System.assertEquals(sFormattedValue, apA1P1.Role__c);
     }
     
    //--------------------------------------------------------------------------------
    //  testSetValuesOnAccountPartner()
    // -------------------------------------------------------------------------------
    public static testMethod void testSetValuesOnAccountPartner() 
    {
		// If role and field names change - just update the values in these 2 lists.
		List<String> listRoleNames = new List<String>{'Advertising Agency', 'Chain Affiliation', 'Management Company', 'Other Chain Name', 'Ownership Group'};
		List<String> listFieldNames = new List<String>{'Partner_Advertising_Agency__c', 'Partner_Chain_Affiliation__c', 'Partner_Management_Company__c', 'Partner_Other_Chain_Name__c', 'Partner_Ownership_Group__c'};
		
		// Create the custom settings records for the 5 fields we know exist.
		List<Account_Partner_Roles__c> listAPRSettings = new List<Account_Partner_Roles__c>();
		for (integer iIdx = 0; iIdx < listRoleNames.size(); iIdx++)
		{ 
			listAPRSettings.add(new Account_Partner_Roles__c(Name = listRoleNames[iIdx], Account_Role_Field_API_Name__c = listFieldNames[iIdx]));
		}
		insert listAPRSettings;
		
        // ==============================================
        // Create test data - a couple accounts representing accounts and partner accounts
        // ==============================================
        Account acctA1 = new Account(Name = 'AAA-Account');
        insert acctA1;
        
        Account acctP1 = new Account(Name = 'CCC-Partner');
        insert acctP1;
        
        Account acctP2 = new Account(Name = 'DDD-Partner');
        insert acctP2;

        // ==============================================
        // Create account partner records.
        // ==============================================
		
		// Select a single role roles for A1-P1 and A1-P1 relationship.
		String strRoleValues = String.join(listRoleNames, ';');
		Account_Partner__c apA1P1 = new Account_Partner__c(Account__c = acctA1.id, Partner__c = acctP1.id, Role_Select__c = listRoleNames[0]);
        insert apA1P1;

		Account_Partner__c apA1P2 = new Account_Partner__c(Account__c = acctA1.id, Partner__c = acctP2.id, Role_Select__c = listRoleNames[1]);
        insert apA1P2;

        // Verify that the 'Role__c' value was properly formatted on the Account_Partner record.
        apA1P1 = [SELECT id, Role__c FROM Account_Partner__c WHERE ID = :apA1P1.id];
        System.assertEquals(listRoleNames[0], apA1P1.Role__c);
        apA1P2 = [SELECT id, Role__c FROM Account_Partner__c WHERE ID = :apA1P2.id];
        System.assertEquals(listRoleNames[1], apA1P2.Role__c);
        
        // Clear out value in Role_Select field.
        apA1P1.Role_Select__c = null;
        update apA1P1;

        apA1P1 = [SELECT id, Role__c FROM Account_Partner__c WHERE ID = :apA1P1.id];
        System.assertEquals(null, apA1P1.Role__c);
        
        // Change value in Role_Select field.
        apA1P2.Role_Select__c = listRoleNames[0];
        update apA1P2;

        apA1P2 = [SELECT id, Role__c FROM Account_Partner__c WHERE ID = :apA1P2.id];
        System.assertEquals(listRoleNames[0], apA1P2.Role__c);
        
     }
     
}