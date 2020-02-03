/**
** Author: Shanu Aggarwal
** Test class: TopAccountExtensionTest
**/
public with sharing class TopAccountExtension {
    Id accountId;
    private String accountProgress;
    public Boolean showSection{get;set;}
    Public Current_Status__c accountRec{get;set;}
    List<Current_Status__c> accountList;
    public TopAccountExtension(ApexPages.StandardController controller) {
        showSection=false;
        RecordType instRecTypeThir = [SELECT Id FROM RecordType WHERE SobjectType='Current_Status__c' And IsActive = true And DeveloperName = 'Top_Accounts' ];
        accountList=new List<Current_Status__c>();
        accountId=ApexPages.currentPage().getParameters().get('id');
        System.debug('accountId===>>>>'+accountId);
        if(accountId!=null){
            accountList = [Select c.Parent_Account__r.Name,CC_Acct_Status__c,CC_Assigned_User__c,CC_Progress_Details__c,Days_Since_CC_Acct_Status_Change__c,c.Days_Since_Status_Change__c,c.Parent_Account__c, c.BCP_Status__c, c.Account_Progress__c From Current_Status__c c where Parent_Account__c = :accountId and RecordTypeId=:instRecTypeThir.Id LIMIT 1];  
            System.debug('accountList******'+accountList);
            if(accountList.size()>0){
                showSection=true;
                accountRec = new Current_Status__c();
                //accountRec.RecordTypeId = instRecTypeThir.Id;
                accountRec=accountList[0];   
                accountProgress =  accountRec.Account_Progress__c ;
                System.debug('accountRec**********'+accountRec);
            }
        } 
    }
    public List<SelectOption> typeOptions {
        get {
            if (typeOptions == null) {
                typeOptions = new List<SelectOption>();
                //typeOptions.add(new SelectOption('', '--None--'));
                DescribeFieldResult d = Current_Status__c.Account_Progress__c.getDescribe();
                for(PicklistEntry e : d.getPicklistValues()) {
                    if (e.isActive()) {
                        typeOptions.add(new SelectOption(e.getValue(), e.getLabel()));
                    }
                }
            }
            return typeOptions;
        }
        set;
    }
    
    
    
    public List<SelectOption> getaccountProgressList() {
        List<SelectOption> options = new List<SelectOption>();
        Map<string,Account_Progress_Values__c> mapCodes = Account_Progress_Values__c.getAll();
        if(accountList.size()>0){
            if(accountRec.Account_Progress__c!=null)
                options.add(new SelectOption(accountRec.Account_Progress__c,accountRec.Account_Progress__c));
            else
                options.add(new SelectOption('--None--','--None--'));
            For(Integer i=1;i<=50;i++){
                if(mapCodes.containsKey(String.ValueOf(i)))
                {
                    String code = Account_Progress_Values__c.getInstance(String.ValueOf(i)).Value__c; 
                    if(code != accountRec.Account_Progress__c)
                        options.add(new SelectOption(code ,code ));
                    //listString.add(code);
                }
                else
                    break;
            }
        }
        return options;
    }
    public String getAccountProgress() {
        return accountProgress;
    }
    public void setAccountProgress(String accountProgress) {
        this.accountProgress = accountProgress;
    }
    
    public void Save(){
        
        accountRec.Account_Progress__c = accountProgress;
        update accountRec;
    }
}