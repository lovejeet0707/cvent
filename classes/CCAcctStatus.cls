public class CCAcctStatus  {

    public Current_Status__c accdetails {get; private set;}
    String id = ApexPages.currentPage().getParameters().get('id');
    String id2 = ApexPages.currentPage().getParameters().get('PID');
    @TestVisible private String Parent_account_name;
    
    public CCAcctStatus(){
        RecordType instRecTypeThir = [SELECT Id FROM RecordType WHERE SobjectType='Current_Status__c' And IsActive = true And DeveloperName = 'Top_Accounts' ];
        accdetails = [Select c.CC_Acct_Status__c,c.Parent_Account__c, c.CC_Progress_Details__c,c.CC_Assigned_User__c From Current_Status__c c where Parent_Account__c = :id2 AND RecordTypeId !=:instRecTypeThir.Id];
        Parent_account_name = [select name from account where id = :id2 limit 1].name;
    }
   
    public PageReference edit() {
        String xx;      
        xx = id + '&PID=' + id2;
        String x1 = '/apex/CCStatusEdit?id=' + xx;
        PageReference opptyPage = new PageReference(x1);
        opptyPage.setRedirect(true);
        return opptyPage;
    }
        
    public PageReference cancel(){
        String xx;      
        xx = id + '&PID=' + id2;
        //ccstatustext = accdetails.Account_Progress__c;
        String x1 = '/apex/CCStatus?id=' + xx;
        PageReference opptyPage = new PageReference(x1);
        opptyPage.setRedirect(true);
        return opptyPage;
    }

    public PageReference save(){
        try{
            update(accdetails);
            String xx;      
            xx = id + '&PID=' + id2;
            String x1 = '/apex/CCStatus?id=' + xx;
            PageReference opptyPage = new PageReference(x1);
            opptyPage.setRedirect(true);
            return opptyPage;
        }
        catch(System.DMLException e){ ApexPages.addMessages(e); return null; }
        //return null;
    }
       
    public string getparentaccount(){
        return this.Parent_account_name ;
    }

    //class
}