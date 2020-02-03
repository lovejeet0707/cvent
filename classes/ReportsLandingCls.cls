public class ReportsLandingCls {
    public string text{get;set;}
    public ReportsLandingCls (){
        text = '';
    }
    public PageReference setRedirections() {
        system.debug('Tetxt+'+text);
        String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
        if(text == 'BudVsAc'){
            PageReference acctPage = new PageReference(sfdcBaseURL+'/apex/Report_Budget_Actual_page');
            acctPage.setRedirect(true);
            return acctPage;
        }
        if(text == 'QuotaA'){
            PageReference acctPage = new PageReference(sfdcBaseURL+'/apex/QuotaVsBudgetReportPage');
            acctPage.setRedirect(true);
            return acctPage;
        }
        if(text == 'LSCR'){
            PageReference acctPage = new PageReference(sfdcBaseURL+'/apex/QuotaAttainmentScreen');
            acctPage.setRedirect(true);
            return acctPage;
        }
        return null;
    }
}