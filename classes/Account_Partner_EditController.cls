//*************************************************************************
//
//  Account_Partner_EditController
//    
//  This class is an Extension Controller for the
//  Account_Partner add/edit page.  A custom page is needed so we can
//  default field values properly and perform extra validation.
//
//  History:
//  InSitu  06/17/2013    Original version    
// *************************************************************************
public with sharing class Account_Partner_EditController 
{
    // -----------------------------------------------------
    //  Constants
    // -----------------------------------------------------
	
    // -----------------------------------------------------
    // Class Attributes
    // -----------------------------------------------------

    // -----------------------------------------------------
    //  Member variables
    // -----------------------------------------------------
	private ID						m_idAccountPartner;
	private ID						m_idAccount;
	private ID						m_idPartner;
	private String 					m_strMode;
	private String					m_strReturnURL;
	
	public Account_Partner__c 		AcctPartner	{get; set;} 

    // -----------------------------------------------------
    //  Methods
    // -----------------------------------------------------
    
    //-------------------------------------------------------------------
    // Getter methods for display components 
    //-------------------------------------------------------------------
    public String getPageTitle()				{return 'Account Partner';}		 
    public String getPageSubTitle()				{return getIsEdit() ? 'Edit Account Partner' : 'New Account Partner';}  
    public Boolean getIsAdd()					{return m_strMode == 'Add' ? true : false;}       
    public Boolean getIsEdit()					{return m_strMode == 'Edit' ? true : false;}

    // --------------------------------------------------------
    //  Constructor
    //
    //  Description: 
    //
    // 
    // --------------------------------------------------------
    public Account_Partner_EditController()
    {
    	system.debug(Logginglevel.WARN, 'in Account_Partner_EditController constructor.');

		// Get the mode parameter next - it will tell us if it is an Add or Edit operation.
		m_strMode = System.currentPageReference().getParameters().get('Mode');
		
		m_idAccount = System.currentPageReference().getParameters().get('AccountID');
		m_idPartner = System.currentPageReference().getParameters().get('PartnerID');
		
		// Get the ID of the Account Partner record, only if in edit mode.
		if (getIsEdit())
			m_idAccountPartner = System.currentPageReference().getParameters().get('ID');
		
		// Get the return URL, so we can redirect back to the calling page.
		m_strReturnURL = System.currentPageReference().getParameters().get('RetURL');
		
		// Retrieve associated records and initialize additional data members.
	    if (getIsEdit() == true)
	    {
			try
			{
		    	AcctPartner = [SELECT ID, Role__c, Role_Select__c, Partner__c, Partner__r.Name, Account__c, Account__r.Name 
					  			FROM Account_Partner__c
					  			WHERE ID = :m_idAccountPartner];
			}
			catch (Exception e) 
			{
		    	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error initializing the page. The Account Partner record is currently not available.'));
				return;
			} 
	    }
	    else
	    {
	    	if (m_idAccount != null)
	    		AcctPartner = new Account_Partner__c(Account__c = m_idAccount);
	    	else if (m_idPartner != null)
	    		AcctPartner = new Account_Partner__c(Partner__c = m_idPartner);
	    }
	}

    //---------------------------------------------------
    // doSave
    //--------------------------------------------------- 
	public PageReference doSave() 
	{
    	system.debug(Logginglevel.WARN, 'in Account_Partner_EditController::doSave()');

		Pagereference pageReturn;
		
		try 
		{
			if (getIsEdit() == true)
			{
				update AcctPartner;				
			}
			else
			{
				insert AcctPartner;
			}
		} 
		catch (DMLException e) 
		{
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'An error occurred while saving the Account Partner record. Error: ' + e.getMessage()));
			return null;
		} 

		return returnToPrevPage();
	}
	
	//---------------------------------------------------
    // doCancel
    //--------------------------------------------------- 
	public PageReference doCancel() 
	{
		return returnToPrevPage();
	}
	
	//---------------------------------------------------
    // returnToPrevPage
    //--------------------------------------------------- 
	public PageReference returnToPrevPage() 
	{
		Pagereference pageReturn;

		// Return to previous page (most likely the View Initial order page)
		if (m_strReturnURL != null)
		{
			pageReturn = new Pagereference (m_strReturnURL);
			pageReturn.setRedirect(true); 
		}
		
		return pageReturn;
	}
}