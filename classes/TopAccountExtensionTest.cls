/**
**  Class: TopAccountExtension
**/
@istest
public class TopAccountExtensionTest {
    
    public static testmethod void testaccountProgress(){
        
        Account_Progress_Values__c setting = new Account_Progress_Values__c();
        setting.Name = '1';
        setting.Value__c = 'Closed Won';
        insert setting;
                
		Id recTypeId = Schema.SObjectType.Current_Status__c.getRecordTypeInfosByName().get('Top Accounts').getRecordTypeId();

        Account Acc = new account (name = 'testname' );
        insert Acc;
        
        Current_Status__c c = new Current_Status__c (Account_Progress__c = 'Closed Won',Parent_Account__c= Acc.Id,CC_Acct_Status__c='Closed Won',RecordTypeId=recTypeId);
        insert c;
                
        Pagereference pgRef = Page.TopAccount;
        pgRef.getParameters().put('id',Acc.Id);
        test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardController controller = new ApexPages.StandardController(c);
        TopAccountExtension ext = new TopAccountExtension(controller);
        List<SelectOption> opt = ext.typeOptions;
        ext.getaccountProgressList();
        ext.getAccountProgress();
        ext.setAccountProgress('Closed Won');
        ext.Save();
        
    } 

}