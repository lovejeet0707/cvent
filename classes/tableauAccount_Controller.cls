public with sharing class tableauAccount_Controller {
    @TestVisible String AccountId;
    public PageReference DataFromTableau()
    {
        AccountId = ApexPages.currentPage().getParameters().get('AccountID');
        if(String.IsNotBlank(AccountId)){
            Account[] accountObj=[SELECT Cvent_Account_ID__c FROM Account WHERE Id=:AccountId];
            if(accountObj.size()>0 && accountObj[0].Cvent_Account_ID__c!=null){
                PageReference pageRef= new PageReference('https://tableau/views/GainSightReports/GainSight-UpcomingEvents?Account%20Number='+accountObj[0].Cvent_Account_ID__c+'&:isGuestRedirectFromVizportal=y&:embed=y');
                pageRef.setRedirect(false);
                return pageRef;
            }
            else{
                return null;
            }
        }
        else{
            return null;
        }
    }
}