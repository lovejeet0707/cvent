@istest(SeeAllData=false)
// *********************************************************************************** 
//
//  AccountPartnerTest
//    
//  Desciption:
//  This class was created by InSitu Software for Cvent. The purpose of this class
//  is to test the processing of the Account Partner List Controller and Edit classes
//   
//  History:
//  InSitu  11/15/2013  Original version. 
//  InSitu  04/08/2014	Updated tests to remove calls to now removed Brand/Chain display functionality.
//						Added tests for new A/R checks.   
//
// ***********************************************************************************
class Account_Partner_ListControllerTest
{
	//--------------------------------------------------------------------------------
	//  testControllerAccount()
	// -------------------------------------------------------------------------------
	public static testMethod void testControllerAccount() 
	{
		// Create some test data to work with.
		
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
        Account acctChain = new Account(Name = 'AAA-Chain');
        insert acctChain;
        
        Account acctBrand = new Account(Name = 'BBB-Brand', ParentID = acctChain.Id);
        insert acctBrand;
        
        Account acctHotel = new Account(Name = 'CCC-Hotel', ParentID = acctBrand.Id);
        insert acctHotel;

        Account acctP1 = new Account(Name = 'DDD-Partner');
        insert acctP1;
        
        Account acctP2 = new Account(Name = 'EEE-Partner');
        insert acctP2;

        Account acctP3 = new Account(Name = 'FFF-Partner');
        insert acctP3;

        // ==============================================
        // Create account partner records.
        // ==============================================
		
		// Select all roles for A1-P1 and A1-P1 relationship.
		Account_Partner__c apA1P1 = new Account_Partner__c(Account__c = acctHotel.id, Partner__c = acctP1.id, Role_Select__c = listRoleNames[0]);
        insert apA1P1;
        
		Account_Partner__c apA1P2 = new Account_Partner__c(Account__c = acctHotel.id, Partner__c = acctP2.id, Role_Select__c = listRoleNames[1]);
        insert apA1P2;

		Account_Partner__c apA1P3 = new Account_Partner__c(Account__c = acctHotel.id, Partner__c = acctP3.id, Role_Select__c = listRoleNames[2]);
        insert apA1P3;

		// Create a reference to the VF page
	    PageReference pageRef = Page.Account_Partner_List;

		// Add required parameters.
		pageRef.getParameters().put('Id', acctHotel.Id);
	    Test.setCurrentPageReference(pageRef);
		    
        // Create instance of the standard page controller
        ApexPages.StandardController conStandard = new ApexPages.StandardController(acctHotel);
    
        // Create an instance of the controller to test
        Account_Partner_ListController controllerTest = new Account_Partner_ListController(conStandard);
		System.assertNotEquals(null, controllerTest);
		
		// Make sure attributes were properly initialized.
		System.assertEquals(acctHotel.id, controllerTest.getCurrentAccount());

		System.assertEquals(0, controllerTest.sortAccountColumn);
		System.assertEquals(0, controllerTest.previousAccountSortColumn);
		System.assertEquals('ASC', controllerTest.sortAccountDirection);
		System.assertEquals('0ASC', controllerTest.getCurrentAccountSort());
		
		System.assertEquals(0, controllerTest.sortPartnerColumn);
		System.assertEquals(0, controllerTest.previousPartnerSortColumn);
		System.assertEquals('ASC', controllerTest.sortPartnerDirection);
		System.assertEquals('0ASC', controllerTest.getCurrentPartnerSort());
		
		System.assertEquals(true, controllerTest.getShowPartnersTab());
		System.assertEquals(true, controllerTest.getShowAccountsTab());

/*
		System.assertEquals(true, controllerTest.getShowChain());
		System.assertEquals(true, controllerTest.getShowBrand());
		System.assertEquals('AAA-Chain', controllerTest.getChainName());
		System.assertNotEquals(null, controllerTest.getChainURL());
		System.assertEquals('BBB-Brand', controllerTest.getBrandName());
		System.assertNotEquals(null, controllerTest.getBrandURL());
*/
		System.assertEquals('Partners', controllerTest.TabInFocus);
		System.assertEquals(null, controllerTest.CurrAPId);

		List<Account_Partner_ListController.PartnerData> listPartnerData = controllerTest.getPartnerData();
		System.assertEquals(3, listPartnerData.size());
		
		List<Account_Partner_ListController.PartnerData> listAccountData = controllerTest.getAccountData();
		System.assertEquals(0, listAccountData.size());
		
		String strAddAccountURL = controllerTest.getAddAccountURL();
		System.assertEquals(True, strAddAccountURL.contains(acctHotel.ID));
		
		String strAddPartnerURL = controllerTest.getAddPartnerURL();
		System.assertEquals(True, strAddPartnerURL.contains(acctHotel.ID));
		
		controllerTest.doAccountSort();
		System.assertEquals(0, controllerTest.sortAccountColumn);
		System.assertEquals(null, controllerTest.previousAccountSortColumn);
		System.assertEquals('DESC', controllerTest.sortAccountDirection);
		System.assertEquals('0DESC', controllerTest.getCurrentAccountSort());
		
		controllerTest.sortAccountColumn = 1;
		controllerTest.doAccountSort();
		System.assertEquals(1, controllerTest.sortAccountColumn);
		System.assertEquals(1, controllerTest.previousAccountSortColumn);
		System.assertEquals('ASC', controllerTest.sortAccountDirection);
		System.assertEquals('1ASC', controllerTest.getCurrentAccountSort());
		
		controllerTest.CurrAPId = apA1P3.ID;        
		System.assertNotEquals(null, controllerTest.doAccountPartnerDelete());
		
		List<Account_Partner__c> listAPDeleted = [SELECT ID FROM Account_Partner__c WHERE ID = :apA1P3.ID];
		System.assertEquals(0, listAPDeleted.size());

	} // End testControllerAccount() 
	
	//--------------------------------------------------------------------------------
	//  testControllerPartner()
	// -------------------------------------------------------------------------------
	public static testMethod void testControllerPartner() 
	{
		// Create some test data to work with.
		
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
        Account acctChain = new Account(Name = 'AAA-Chain');
        insert acctChain;
        
        Account acctBrand = new Account(Name = 'BBB-Brand', ParentID = acctChain.Id);
        insert acctBrand;
        
        Account acctHotel = new Account(Name = 'CCC-Hotel', ParentID = acctBrand.Id);
        insert acctHotel;

        Account acctP1 = new Account(Name = 'DDD-Partner');
        insert acctP1;
        
        Account acctP2 = new Account(Name = 'EEE-Partner');
        insert acctP2;

        Account acctP3 = new Account(Name = 'FFF-Partner');
        insert acctP3;

        // ==============================================
        // Create account partner records.
        // ==============================================
		
		// Select all roles for A1-P1 and A1-P1 relationship.
		Account_Partner__c apA1P1 = new Account_Partner__c(Account__c = acctChain.id, Partner__c = acctP1.id, Role_Select__c = listRoleNames[0]);
        insert apA1P1;
        
		Account_Partner__c apA1P2 = new Account_Partner__c(Account__c = acctBrand.id, Partner__c = acctP1.id, Role_Select__c = listRoleNames[1]);
        insert apA1P2;

		Account_Partner__c apA1P3 = new Account_Partner__c(Account__c = acctHotel.id, Partner__c = acctP1.id, Role_Select__c = listRoleNames[2]);
        insert apA1P3;

		// Create a reference to the VF page
	    PageReference pageRef = Page.Account_Partner_List;

		// Add required parameters.
		pageRef.getParameters().put('Id', acctP1.Id);
	    Test.setCurrentPageReference(pageRef);
		    
        // Create instance of the standard page controller
        ApexPages.StandardController conStandard = new ApexPages.StandardController(acctP1);
    
        // Create an instance of the controller to test
        Account_Partner_ListController controllerTest = new Account_Partner_ListController(conStandard);
		System.assertNotEquals(null, controllerTest);
		
		// Make sure attributes were properly initialized.
		System.assertEquals(acctP1.id, controllerTest.getCurrentAccount());

		System.assertEquals(0, controllerTest.sortAccountColumn);
		System.assertEquals(0, controllerTest.previousAccountSortColumn);
		System.assertEquals('ASC', controllerTest.sortAccountDirection);
		System.assertEquals('0ASC', controllerTest.getCurrentAccountSort());
		
		System.assertEquals(0, controllerTest.sortPartnerColumn);
		System.assertEquals(0, controllerTest.previousPartnerSortColumn);
		System.assertEquals('ASC', controllerTest.sortPartnerDirection);
		System.assertEquals('0ASC', controllerTest.getCurrentPartnerSort());
		
		System.assertEquals(true, controllerTest.getShowPartnersTab());
		System.assertEquals(true, controllerTest.getShowAccountsTab());

/*
		System.assertEquals(false, controllerTest.getShowChain());
		System.assertEquals(false, controllerTest.getShowBrand());
		System.assertEquals('', controllerTest.getChainName());
		System.assertEquals(null, controllerTest.getChainURL());
		System.assertEquals('', controllerTest.getBrandName());
		System.assertEquals(null, controllerTest.getBrandURL());
*/

		System.assertEquals('Partners To', controllerTest.TabInFocus);
		System.assertEquals(null, controllerTest.CurrAPId);

		List<Account_Partner_ListController.PartnerData> listPartnerData = controllerTest.getPartnerData();
		System.assertEquals(0, listPartnerData.size());
		
		List<Account_Partner_ListController.PartnerData> listAccountData = controllerTest.getAccountData();
		System.assertEquals(3, listAccountData.size());
		
		String strAddAccountURL = controllerTest.getAddAccountURL();
		System.assertEquals(True, strAddAccountURL.contains(acctP1.ID));
		
		String strAddPartnerURL = controllerTest.getAddPartnerURL();
		System.assertEquals(True, strAddPartnerURL.contains(acctP1.ID));
		
		controllerTest.doPartnerSort();
		System.assertEquals(0, controllerTest.sortPartnerColumn);
		System.assertEquals(null, controllerTest.previousPartnerSortColumn);
		System.assertEquals('DESC', controllerTest.sortPartnerDirection);
		System.assertEquals('0DESC', controllerTest.getCurrentPartnerSort());
		
		controllerTest.sortPartnerColumn = 1;
		controllerTest.doPartnerSort();
		System.assertEquals(1, controllerTest.sortPartnerColumn);
		System.assertEquals(1, controllerTest.previousPartnerSortColumn);
		System.assertEquals('ASC', controllerTest.sortPartnerDirection);
		System.assertEquals('1ASC', controllerTest.getCurrentPartnerSort());
		
		controllerTest.CurrAPId = apA1P3.ID;        
		System.assertNotEquals(null, controllerTest.doAccountPartnerEdit());
		
	} // End testControllerPartner() 
	
	//--------------------------------------------------------------------------------
	//  testControllerAccountChain()
	// -------------------------------------------------------------------------------
	public static testMethod void testControllerAccountChain() 
	{
		// Create some test data to work with.
		
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
        Account acctChain = new Account(Name = 'AAA-Chain');
        insert acctChain;
        
        Account acctBrand = new Account(Name = 'BBB-Brand', ParentID = acctChain.Id);
        insert acctBrand;
        
        Account acctHotel = new Account(Name = 'CCC-Hotel', ParentID = acctBrand.Id);
        insert acctHotel;

        Account acctP1 = new Account(Name = 'DDD-Partner');
        insert acctP1;
        
        Account acctP2 = new Account(Name = 'EEE-Partner');
        insert acctP2;

        Account acctP3 = new Account(Name = 'FFF-Partner');
        insert acctP3;

        // ==============================================
        // Create account partner records.
        // ==============================================
		
		// Select all roles for A1-P1 and A1-P1 relationship.
		Account_Partner__c apA1P1 = new Account_Partner__c(Account__c = acctBrand.id, Partner__c = acctP1.id, Role_Select__c = listRoleNames[0]);
        insert apA1P1;
        
		Account_Partner__c apA1P2 = new Account_Partner__c(Account__c = acctBrand.id, Partner__c = acctP2.id, Role_Select__c = listRoleNames[1]);
        insert apA1P2;

		Account_Partner__c apA1P3 = new Account_Partner__c(Account__c = acctBrand.id, Partner__c = acctP3.id, Role_Select__c = listRoleNames[2]);
        insert apA1P3;

		// Create a reference to the VF page
	    PageReference pageRef = Page.Account_Partner_List;

		// Add required parameters.
		pageRef.getParameters().put('Id', acctBrand.Id);
	    Test.setCurrentPageReference(pageRef);
		    
        // Create instance of the standard page controller
        ApexPages.StandardController conStandard = new ApexPages.StandardController(acctBrand);
    
        // Create an instance of the controller to test
        Account_Partner_ListController controllerTest = new Account_Partner_ListController(conStandard);
		System.assertNotEquals(null, controllerTest);
		
		// Make sure attributes were properly initialized.
		System.assertEquals(acctBrand.id, controllerTest.getCurrentAccount());

/*
		System.assertEquals(true, controllerTest.getShowChain());
		System.assertEquals(true, controllerTest.getShowBrand());
		System.assertEquals('AAA-Chain', controllerTest.getChainName());
		System.assertNotEquals(null, controllerTest.getChainURL());
		System.assertEquals('BBB-Brand', controllerTest.getBrandName());
		System.assertNotEquals(null, controllerTest.getBrandURL());
*/

		System.assertEquals('Partners', controllerTest.TabInFocus);
		System.assertEquals(null, controllerTest.CurrAPId);

		List<Account_Partner_ListController.PartnerData> listPartnerData = controllerTest.getPartnerData();
		System.assertEquals(3, listPartnerData.size());
		
		List<Account_Partner_ListController.PartnerData> listAccountData = controllerTest.getAccountData();
		System.assertEquals(0, listAccountData.size());
		
		String strAddAccountURL = controllerTest.getAddAccountURL();
		System.assertEquals(True, strAddAccountURL.contains(acctBrand.ID));
		
		String strAddPartnerURL = controllerTest.getAddPartnerURL();
		System.assertEquals(True, strAddPartnerURL.contains(acctBrand.ID));
		

	} // End testControllerGeneral() 


	//--------------------------------------------------------------------------------
	//  testControllerEdit()
	// -------------------------------------------------------------------------------
	public static testMethod void testControllerEdit() 
	{
		// Create some test data to work with.
		
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
        Account acctChain = new Account(Name = 'AAA-Chain');
        insert acctChain;
        
        Account acctP1 = new Account(Name = 'DDD-Partner');
        insert acctP1;

        Account acctP2 = new Account(Name = 'EEE-Partner');
        insert acctP2;
        
		// Select all roles for A1-P1 and A1-P1 relationship.
		Account_Partner__c apA1P1 = new Account_Partner__c(Account__c = acctChain.id, Partner__c = acctP1.id, Role_Select__c = listRoleNames[0]);
        insert apA1P1;
        
		// Create a reference to the VF page
	    PageReference pageRef = Page.Account_Partner_Edit;

		// Add required parameters.
		pageRef.getParameters().put('Mode', 'Edit');
		pageRef.getParameters().put('ID', apA1P1.ID);
		pageRef.getParameters().put('RetURL', '/' + acctChain.ID);
	    Test.setCurrentPageReference(pageRef);
		    
        // Create an instance of the controller to test
        Account_Partner_EditController controllerTest = new Account_Partner_EditController();
		System.assertNotEquals(null, controllerTest);
		
		// Make sure attributes were properly initialized.
		System.assertEquals('Account Partner', controllerTest.getPageTitle());
		System.assertEquals('Edit Account Partner', controllerTest.getPageSubTitle());
		System.assertEquals(false, controllerTest.getIsAdd());
		System.assertEquals(true, controllerTest.getIsEdit());
		
		// Update the partner field.
		controllerTest.AcctPartner.Partner__c = acctP2.ID;
		System.assertNotEquals(null, controllerTest.doSave());
		
		// Verify the save
		apA1P1 = [SELECT ID, Partner__c FROM Account_Partner__c WHERE ID =:apA1P1.Id];
		System.assertEquals(acctP2.ID, apA1P1.Partner__c); 
		
		// Cancel
		System.assertNotEquals(null, controllerTest.doCancel());
	} // End testControllerEdit() 

	//--------------------------------------------------------------------------------
	//  testControllerAdd()
	// -------------------------------------------------------------------------------
	public static testMethod void testControllerAdd() 
	{
		// Create some test data to work with.
		
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
        Account acctChain = new Account(Name = 'AAA-Chain');
        insert acctChain;
        
        Account acctP1 = new Account(Name = 'DDD-Partner');
        insert acctP1;

        Account acctP2 = new Account(Name = 'EEE-Partner');
        insert acctP2;
        
		// Create a reference to the VF page
	    PageReference pageRef = Page.Account_Partner_Edit;

		// Add required parameters.
		pageRef.getParameters().put('Mode', 'Add');
		pageRef.getParameters().put('AccountID', acctChain.ID);
		pageRef.getParameters().put('RetURL', '/' + acctChain.ID);
	    Test.setCurrentPageReference(pageRef);
		    
        // Create an instance of the controller to test
        Account_Partner_EditController controllerTest = new Account_Partner_EditController();
		System.assertNotEquals(null, controllerTest);
		
		// Make sure attributes were properly initialized.
		System.assertEquals('Account Partner', controllerTest.getPageTitle());
		System.assertEquals('New Account Partner', controllerTest.getPageSubTitle());
		System.assertEquals(true, controllerTest.getIsAdd());
		System.assertEquals(false, controllerTest.getIsEdit());
		
		// Update the partner field.
		controllerTest.AcctPartner.Partner__c = acctP2.ID;
		controllerTest.AcctPartner.Role_Select__c = listRoleNames[0];
		System.assertNotEquals(null, controllerTest.doSave());
		
		// Verify the save
		Account_Partner__c apA1P1 = [SELECT ID, Partner__c, Role_Select__c, Role__c FROM Account_Partner__c WHERE Partner__c =:acctP2.ID];
		System.assertEquals(listRoleNames[0], apA1P1.Role_Select__c); 
		System.assertEquals(listRoleNames[0], apA1P1.Role__c); 
		
		// Delete the record and attempt to save. Error should be generated.
		delete apA1P1;
		System.assertEquals(null, controllerTest.doSave());
	

	} // End testControllerAdd() 

	//--------------------------------------------------------------------------------
	//  testControllerAdd2()
	// -------------------------------------------------------------------------------
	public static testMethod void testControllerAdd2() 
	{
		// Create some test data to work with.
		
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
        Account acctChain = new Account(Name = 'AAA-Chain');
        insert acctChain;
        
        Account acctP1 = new Account(Name = 'DDD-Partner');
        insert acctP1;

        Account acctP2 = new Account(Name = 'EEE-Partner');
        insert acctP2;
        
		// Create a reference to the VF page
	    PageReference pageRef = Page.Account_Partner_Edit;

		// Add required parameters.
		pageRef.getParameters().put('Mode', 'Add');
		pageRef.getParameters().put('PartnerID', acctP1.ID);
		pageRef.getParameters().put('RetURL', '/' + acctP1.ID);
	    Test.setCurrentPageReference(pageRef);
		    
        // Create an instance of the controller to test
        Account_Partner_EditController controllerTest = new Account_Partner_EditController();
		System.assertNotEquals(null, controllerTest);
		
		// Make sure attributes were properly initialized.
		System.assertEquals('Account Partner', controllerTest.getPageTitle());
		System.assertEquals('New Account Partner', controllerTest.getPageSubTitle());
		System.assertEquals(true, controllerTest.getIsAdd());
		System.assertEquals(false, controllerTest.getIsEdit());
		
		// Update the partner field.
		controllerTest.AcctPartner.Account__c = acctChain.ID;
		controllerTest.AcctPartner.Role_Select__c = listRoleNames[0];
		System.assertNotEquals(null, controllerTest.doSave());
		
		// Verify the save
		Account_Partner__c apA1P1 = [SELECT ID, Partner__c, Role_Select__c, Role__c FROM Account_Partner__c WHERE Partner__c =:acctP1.ID];
		System.assertEquals(listRoleNames[0], apA1P1.Role_Select__c); 
		System.assertEquals(listRoleNames[0], apA1P1.Role__c); 
		
	} // End testControllerGeneral() 

	//--------------------------------------------------------------------------------
	//  testControllerEditException()
	// -------------------------------------------------------------------------------
	public static testMethod void testControllerEditException() 
	{
		// Create some test data to work with.
		
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
        Account acctChain = new Account(Name = 'AAA-Chain');
        insert acctChain;
        
        Account acctP1 = new Account(Name = 'DDD-Partner');
        insert acctP1;

        Account acctP2 = new Account(Name = 'EEE-Partner');
        insert acctP2;
        
		// Select all roles for A1-P1 and A1-P1 relationship.
		Account_Partner__c apA1P1 = new Account_Partner__c(Account__c = acctChain.id, Partner__c = acctP1.id, Role_Select__c = listRoleNames[0]);
        insert apA1P1;
        ID idA1P1 = apA1P1.id;
        
		// Create a reference to the VF page
	    PageReference pageRef = Page.Account_Partner_Edit;

		// Add required parameters.
		pageRef.getParameters().put('Mode', 'Edit');
		pageRef.getParameters().put('ID', apA1P1.ID);
		pageRef.getParameters().put('RetURL', '/' + acctChain.ID);
	    Test.setCurrentPageReference(pageRef);
	    
	    // Delete the record - should generate error on controller constructor.
	    delete apA1P1;
		    
        // Create an instance of the controller to test
        Account_Partner_EditController controllerTest = new Account_Partner_EditController();
		System.assertEquals(true, ApexPages.hasMessages());
		

	} // End testControllerEdit() 

	
} // End class