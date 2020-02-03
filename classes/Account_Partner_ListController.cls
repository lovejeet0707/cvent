//*************************************************************************
//
//  Account_Partner_ListController
//    
//  This class is an Extension Controller for the
//  Account_Partner custom list page.  The page's 
//  controller is the standard controller for the Account object.
//
//  History:
//  InSitu  06/17/2013    Original version 
//  InSitu  04/08/2014  Added check for Edit/Delete rights to determine when action column and links should be displayed.
//                      Removed the inclusion of the Brand/Chain entries, since cVent has created Account Partner records to represent that relationship.   
// *************************************************************************
public with sharing class Account_Partner_ListController 
{
    public class APLException extends Exception {}
    
    // -----------------------------------------------------
    // Constants
    // -----------------------------------------------------
     
    // -----------------------------------------------------
    // Data members
    // -----------------------------------------------------
    private final Account                   m_Account;
/*
    private final Account                   m_AccountChain;
    private final Account                   m_AccountBrand;
    private final String                    m_strChainURL;
    private final String                    m_strBrandURL;
*/
    private final ID                        m_idAccount;
    private final String                    m_strUPAccountName;
    private List<PartnerData>               m_listPartnerData = new List<PartnerData>();
    private List<PartnerData>               m_listAccountData = new List<PartnerData>();
    private Boolean                         m_bCanEdit;
    private Boolean                         m_bCanDelete;
    
    //-------------------------------------------------------------------
    // Getter methods for action components
    //-------------------------------------------------------------------
    public  ID  getCurrentAccount()         {return m_idAccount;}

    //-------------------------------------------------------------------
    // Getter methods for sorting components
    //-------------------------------------------------------------------
    private String m_sPartnerSortFieldName;
    public Integer sortPartnerColumn            {get; set;}
    public Integer previousPartnerSortColumn    {get; set;}
    public String sortPartnerDirection          {get; set;}
    public String getCurrentPartnerSort()       {return sortPartnerColumn.format() + sortPartnerDirection;}

    private String m_sAccountSortFieldName;
    public Integer sortAccountColumn            {get; set;}
    public Integer previousAccountSortColumn    {get; set;}
    public String sortAccountDirection          {get; set;}
    public String getCurrentAccountSort()       {return sortAccountColumn.format() + sortAccountDirection;}

    // -----------------------------------------------------
    // Class Attributes
    // -----------------------------------------------------
    public Boolean getShowPartnersTab()         {return true;}
    public Boolean getShowAccountsTab()         {return true;}
    public Boolean getShowActionCol()           {return m_bCanEdit || m_bCanDelete;}
    public Boolean getShowEditLink()            {return m_bCanEdit;}
    public Boolean getShowDeleteLink()          {return m_bCanDelete;}
    public List<PartnerData> getPartnerData()   {return m_listPartnerData;} 
    public List<PartnerData> getAccountData()   {return m_listAccountData;}
    
/*    
    public Boolean getShowChain()               {return m_AccountChain == null ? false : true;}
    public Boolean getShowBrand()               {return m_AccountBrand == null ? false : true;}
    public String getChainName()                {return m_AccountChain == null ? '' : m_AccountChain.Name;}
    public String getChainURL()                 {return m_strChainURL;}
    public String getBrandName()                {return m_AccountBrand == null ? '' : m_AccountBrand.Name;}
    public String getBrandURL()                 {return m_strBrandURL;}
*/

    public String TabInFocus                    {get; set;}
    public ID CurrAPId                          {get; set;}

    //-------------------------------------------------------------------
    // Constructor
    //-------------------------------------------------------------------
    public Account_Partner_ListController(ApexPages.StandardController controller) 
    {
        // Initialize the sort control mechanisms
        sortPartnerColumn = 0;
        previousPartnerSortColumn = 0;
        sortPartnerDirection = 'ASC';
        m_sPartnerSortFieldName = 'Partner__r.Name';

        sortAccountColumn = 0;
        previousAccountSortColumn = 0;
        sortAccountDirection = 'ASC';
        m_sAccountSortFieldName = 'Account__r.Name';
        
        m_bCanEdit = false;
        m_bCanDelete = false;

        Schema.SObjectType sobjAcctPartner = Schema.getGlobalDescribe().get('Account_Partner__c');
        if (sobjAcctPartner != null)
        {
            Schema.DescribeSObjectResult rAcctPartner = sobjAcctPartner.getDescribe();
            if (rAcctPartner != null && rAcctPartner.isAccessible())
            {
                m_bCanDelete = rAcctPartner.isDeletable();
                m_bCanEdit= rAcctPartner.isUpdateable();
            }
        }


        try
        {
            // Get the Account record
            m_idAccount = System.currentPageReference().getParameters().get('Id');
            m_Account = [SELECT ID, Name, ParentId, InSituCah__Ultimate_Parent__c, InSituCah__Ultimate_Parent__r.InSituCah__Account__c  ,CSN_ID__c 
                         FROM Account 
                         WHERE Id=:m_idAccount];
                         
/*
            try
            {
                // Get the Ultimate Parent Account - if it exists.
                if (m_Account.InSituCah__Ultimate_Parent__c != null && 
                    m_Account.InSituCah__Ultimate_Parent__r.InSituCah__Account__c != null)
                {
                    m_AccountChain = [SELECT ID, Name  
                                      FROM Account 
                                      WHERE Id=:m_Account.InSituCah__Ultimate_Parent__r.InSituCah__Account__c];
                    system.debug(Logginglevel.WARN, 'Account Chain = ' + m_AccountChain.Name);
                    m_strChainURL = getAHURL(m_AccountChain.ID, false);
                
                    // Get the Parent Account - if it exists and the parent is not the ultimate parent account.
                    if (m_Account.ParentID != null)
                    {
                        // Check to see if the current Account is the Chain.
                        if (m_Account.ParentID == m_AccountChain.ID)
                        {
                            m_AccountBrand = m_Account; 
                        }
                        else
                        {
                            for (ID idParent = m_Account.ParentId; idParent != null && idParent != m_AccountChain.ID; idParent = m_AccountBrand.ParentId)
                            {
                                m_AccountBrand = [SELECT ID, Name, ParentID  
                                                  FROM Account 
                                                  WHERE Id=:idParent];
                                system.debug(Logginglevel.WARN, 'Account Brand = ' + m_AccountBrand.Name);
                            }
                        }
                        if (m_AccountBrand != null)
                            m_strBrandURL = getAHURL(m_AccountBrand.ID, false);
                    }
                }
            }
            catch (Exception e)
            {
                // An error occurred trying to retrieve the Chain or Brand account records. 
                // No need to throw an exception at the moment, just write out a debug statement.
                system.debug(Logginglevel.WARN, 'Error getting the Account Chain and Brand account records.  Error: ' + e.getMessage());   
                //throw new APLException('Error getting the Account Chain and Brand account records.  Error: ' + e.getMessage());       
            }
*/
                             
            // Get the list of all related Partners for the Account.
            refreshPartnerList();

            // Get the list of all related Accounts for the Partner Account.
            refreshAccountList();

            TabInFocus = m_listAccountData.size() > 0 ? 'Partners To' : 'Partners';

        }
        catch (Exception e)
        {
            // Something happened with the query or processing the query results.   
            throw new APLException('Error getting Account Partner related records.  Error: ' + e.getMessage());       
        }
     
    }

    public void refreshPartnerList()
    {
        // Get the list of all related Account Partners for the Account.
        m_listPartnerData = queryPartnerData();
    }
    
    public void refreshAccountList()
    {
        // Get the list of all related Account Partners for the Account.
        m_listAccountData = queryAccountData();
    }

    private List<PartnerData> queryPartnerData()
    {
        List<PartnerData> listPartnerData = new List<PartnerData>();

/*
        // Add the Brand and Chain records, as appropriate.
        if (m_AccountChain != null)
        {
            listPartnerData.add(new PartnerData(m_AccountChain, m_AccountChain, 'Chain', false));
        }
        if (m_AccountBrand != null)
        {
            listPartnerData.add(new PartnerData(m_AccountBrand, m_AccountBrand, 'Brand', false));
        }
*/

        // Build the query string.
        String strQuery = 'SELECT ID, Role__c, Partner__c, Partner__r.Name, Partner__r.CSN_ID__c,Account__c, Account__r.Name,Account__r.CSN_ID__c FROM Account_Partner__c ';
        strQuery += 'WHERE Account__c = \'' + m_idAccount + '\'';
        
        // Sort Nulls based on direction
        if (m_sPartnerSortFieldName != null)
        {
            // Format the Order By clause
            String strOrderBy = ' Order By ' + m_sPartnerSortFieldName + ' ' + sortPartnerDirection;
            
            // Sort Nulls based on direction
            if (sortPartnerDirection == 'ASC')
                strOrderBy += ' NULLS FIRST';   
            else
                strOrderBy += ' NULLS LAST';        
            
            // Finalize the query string.
            strQuery += strOrderBy;
        }
        System.debug('strQuery===>>>>'+strQuery);
        // Execute the query.
        for (List<Account_Partner__c> listAP : database.query(strQuery))
        {
            // Build list of data for use by visualforce page.
            for (Account_Partner__c acctPartner : listAP)   
            {
                // Build a list of associated PartnerData items.
                listPartnerData.add(new PartnerData(acctPartner, true));
            }
        }
        System.debug('listPartnerData===>>>>'+listPartnerData);
        return listPartnerData;
    }

    private List<PartnerData> queryAccountData()
    {
        List<PartnerData> listAccountData = new List<PartnerData>();

        // Build the query string.
        String strQuery = 'SELECT ID, Role__c, Account__c, Account__r.Name,Account__r.CSN_ID__c, Partner__c,Partner__r.Name,Partner__r.CSN_ID__c FROM Account_Partner__c ';
        strQuery += 'WHERE Partner__c = \'' + m_idAccount + '\'';
        
        // Sort Nulls based on direction
        if (m_sAccountSortFieldName != null)
        {
            // Format the Order By clause
            String strOrderBy = ' Order By ' + m_sAccountSortFieldName + ' ' + sortAccountDirection;
            
            // Sort Nulls based on direction
            if (sortAccountDirection == 'ASC')
                strOrderBy += ' NULLS FIRST';   
            else
                strOrderBy += ' NULLS LAST';        
            
            // Finalize the query string.
            strQuery += strOrderBy;
        }
        
        // Execute the query.
        for (List<Account_Partner__c> listAP : database.query(strQuery))
        {
                
            // Build list of data for use by visualforce page.
            for (Account_Partner__c acctAccount : listAP)   
            {
                // Build a list of associated AccountData items.
                listAccountData.add(new PartnerData(acctAccount, false));
            }
        }
        System.debug('listAccountData==>>>'+listAccountData);
        return listAccountData;
    }

        
    // --------------------------------------------------------
    //  buildAHURL
    //
    //  Description: 
    //
    // --------------------------------------------------------
    static public String getAHURL(ID idAcct, Boolean bPartner)
    {
        String urlAH;
        PageReference prReturn = Page.InsituCAH__InSitu_Account_Hierarchy;
        if (prReturn != null)
        {   
            prReturn.getParameters().put('ID', idAcct);
            if (bPartner)
            {
                // Set focust to Custom1 tab and how hierarchical view.
                prReturn.getParameters().put('TabInFocus', 'Custom1');
                prReturn.getParameters().put('ShowHier', '1');
            }
            urlAH = prReturn.getUrl();
        }
        return urlAH;
    }
    
    // --------------------------------------------------------
    //  getAddAccountURL
    //
    //  Description: 
    //
    // --------------------------------------------------------
    public String getAddAccountURL()
    {
        PageReference prAPEdit = Page.Account_Partner_Edit; 
        prAPEdit.getParameters().put('PartnerID', m_idAccount);
        prAPEdit.getParameters().put('Mode', 'Add');
        prAPEdit.getParameters().put('RetURL', '/' + m_idAccount);

        return prAPEdit.getUrl();
    }

    // --------------------------------------------------------
    //  getAddPartnerURL
    //
    //  Description: 
    //
    // --------------------------------------------------------
    public String getAddPartnerURL()
    {
        PageReference prAPEdit = Page.Account_Partner_Edit; 
        prAPEdit.getParameters().put('AccountID', m_idAccount);
        prAPEdit.getParameters().put('Mode', 'Add');
        prAPEdit.getParameters().put('RetURL', '/' + m_idAccount);

        return prAPEdit.getUrl();
    }

    //-------------------------------------------------------------------
    //  doAccountPartnerDelete()
    //    
    //------------------------------------------------------------------- 
    public PageReference doAccountPartnerDelete()
    {
        system.debug(Logginglevel.WARN, 'In doAccountDelete. CurrAPId = ' + CurrAPId);
 
        if (CurrAPId != null)
        {
            try
            {
                Account_Partner__c ap = [SELECT ID,Partner__r.CSN_ID__c,Account__r.CSN_ID__c FROM Account_Partner__c WHERE ID =: CurrAPId];
                try
                {
                    delete ap;                  
                }
                catch (Exception e)
                {
                    // Something happened with the query or processing the query results.   
                    throw new APLException('Error deleting Account Partner record.  Error: ' + e.getMessage());       
                }
            }
            catch (Exception e)
            {
                // Something happened with the query or processing the query results.   
                throw new APLException('Error getting Account Partner record.  Error: ' + e.getMessage());       
            }
        
        }
        system.debug(Logginglevel.WARN, 'Exiting doAccountDelete');
        
        PageReference prReturn = Page.Account_Partner_List; 
        prReturn.getParameters().put('ID', m_idAccount);
        prReturn.setRedirect(true);
 
        return prReturn;
    }

    //-------------------------------------------------------------------
    //  doAccountPartnerEdit()
    //    
    //------------------------------------------------------------------- 
    public pageReference doAccountPartnerEdit()
    {
        system.debug(Logginglevel.WARN, 'In doAccountPartnerEdit. CurrAPId = ' + CurrAPId);
        
        if (CurrAPId != null)
        {
            PageReference prAPEdit = Page.Account_Partner_Edit; 
            prAPEdit.getParameters().put('Id', CurrAPId);
            prAPEdit.getParameters().put('Mode', 'Edit');
            prAPEdit.getParameters().put('RetURL', '/' + m_idAccount);
            return prAPEdit;
        }
        else
            return null;
 
    }

    //-------------------------------------------------------------------
    //  doAccountSort()
    //    
    //------------------------------------------------------------------- 
    public void doAccountSort()
    {
        system.debug(Logginglevel.WARN, 'In doSort');
 
        // Assume ascending direction
        sortAccountDirection = 'ASC';

        // This checks to see if the same header was clicked two times in a row,  
        // if so it switches the direction.
        if (previousAccountSortColumn == sortAccountColumn)
        {
            sortAccountDirection = 'DESC';
            previousAccountSortColumn = null;
        }
        else
        {
            previousAccountSortColumn = sortAccountColumn;
        } 

        m_sAccountSortFieldName = (sortAccountColumn == 0) ? 'Account__r.Name' : 'Role__c';
        
        // Get the list of all related Account Accounts for the Account.
        refreshAccountList();

        //system.debug(Logginglevel.WARN, 'Exiting doSort');
    }
    

    //-------------------------------------------------------------------
    //  doPartnerSort()
    //    
    //------------------------------------------------------------------- 
    public void doPartnerSort()
    {
        system.debug(Logginglevel.WARN, 'In doSort');
 
        // Assume ascending direction
        sortPartnerDirection = 'ASC';

        // This checks to see if the same header was clicked two times in a row,  
        // if so it switches the direction.
        if (previousPartnerSortColumn == sortPartnerColumn)
        {
            sortPartnerDirection = 'DESC';
            previousPartnerSortColumn = null;
        }
        else
        {
            previousPartnerSortColumn = sortPartnerColumn;
        } 

        m_sPartnerSortFieldName = (sortPartnerColumn == 0) ? 'Partner__r.Name' : 'Role__c';
        
        // Get the list of all related Account Partners for the Account.
        refreshPartnerList();

        //system.debug(Logginglevel.WARN, 'Exiting doSort');
    }

    // +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    // + D A T A   T A B L E   I T E M   C L A S S                                       
    // +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    public with sharing class PartnerData
    {
        public Account_Partner__c   AcctPartner     {get; private set;}
        public Account              Acct            {get; private set;}
        public Account              Partner         {get; private set;}
        public String               Role            {get; private set;}
        public String               urlAH           {get; private set;}
        public String               urlEdit         {get; private set;}
        //public String               CSNID         {get; private set;}
        public Boolean              CanEdit         {get; private set;}

    
        // --------------------------------------
        // Constructor
        // --------------------------------------
        public PartnerData(Account objAcct, Account objPartner, String strRole, Boolean bPartner)
        {
            Acct = objAcct;
            Partner = objPartner;
            Role = strRole;
            CanEdit = true; // (Role == 'Chain' || Role == 'Brand') ? false : true;
            System.debug('objAcct==>>>>>>>'+objAcct);
            if (bPartner)
                urlAH = Account_Partner_ListController.getAHURL(objPartner.ID, true);
            else
                urlAH = Account_Partner_ListController.getAHURL(objAcct.ID, false);
        }
        
        public PartnerData(Account_Partner__c AccountPartner, Boolean bPartner)
        {
            AcctPartner = AccountPartner.clone(true, true);
            system.debug(Logginglevel.WARN, 'In PartnerData constructor: AcctPartner.ID = ' + AcctPartner.ID);
            Acct = new Account(ID = AccountPartner.Account__c, Name = AccountPartner.Account__r.Name,CSN_ID__c=AccountPartner.Account__r.CSN_ID__c);
            Partner = new Account(ID = AccountPartner.Partner__c, Name = AccountPartner.Partner__r.Name,CSN_ID__c=AccountPartner.Partner__r.CSN_ID__c);
            Role = AccountPartner.Role__c;
            //CSNID = AccountPartner.Partner__r
            CanEdit = true; // (Role == 'Chain' || Role == 'Brand') ? false : true;
            
            if (bPartner)
            {
                urlAH = Account_Partner_ListController.getAHURL(AccountPartner.Partner__r.ID, true);
                urlEdit = buildEditURL(AccountPartner.ID, AccountPartner.Account__r.ID);
            }
            else
            {
                urlAH = Account_Partner_ListController.getAHURL(AccountPartner.Account__r.ID, false);
                urlEdit = buildEditURL(AccountPartner.ID, AccountPartner.Partner__r.ID);
            }
        }
        
        // --------------------------------------------------------
        //  buildEditURL
        //
        //  Description: 
        //
        // --------------------------------------------------------
        public String buildEditURL(ID idAP, ID idAccount)
        {
            PageReference prAPEdit = Page.Account_Partner_Edit; 
            prAPEdit.getParameters().put('Id', idAP);
            prAPEdit.getParameters().put('AccountID', idAccount);
            prAPEdit.getParameters().put('Mode', 'Edit');
            prAPEdit.getParameters().put('RetURL', '/' + idAccount);

            return prAPEdit.getUrl();
        }
    
        
    }
}