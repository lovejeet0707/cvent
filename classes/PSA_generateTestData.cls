@isTest
public class PSA_generateTestData {

    public static void customSettings() {
        PSA_Custom_Trigger_Settings__c cts = new PSA_Custom_Trigger_Settings__c(Name = 'Default');
        insert cts;
        
        PSA_Chatter_Settings__c cs = new PSA_Chatter_Settings__c(Name = 'Default', Pending_Completion_Message__c = 'Test Message');
        insert cs;        
    
    }
    
    public static Account getAccount(string AcctName) {
        Account a = new Account();
        a.Name = AcctName;
        a.CurrencyIsoCode = 'USD';
        a.BillingStateCode = 'PA';
        a.BillingState = 'PA';
        a.Phone = '555-123-4567';
        a.BillingPostalCode = '17011';
        a.BillingCountryCode = 'US';
        
        insert a;
        return a;
    }
    
    public static pse__Region__c getRegion(string regionName) {
        pse__Region__c r = new pse__Region__c();
        r.Name = regionName;
        
        insert r;
        return r;
    }
    
    public static pse__Practice__c getPractice(string practiceName) {
        pse__Practice__c p = new pse__Practice__c();
        p.name = practiceName;
        
        insert p;
        return p;
    }
    
    public static pse__Grp__c getGrp(string grpName) {
        pse__Grp__c g = new pse__Grp__c();
        g.Name = grpName;
        
        insert g;
        return g;
    }
    
    public static Contact getResource(string fName, string lName, string emailAddress, 
                                      Id accId, Id regionId, Id practiceId, Id grpId,
                                      Id sfUserId) {
        Contact c = new Contact();
        c.FirstName = fName;
        c.LastName = lName;
        c.Email = emailAddress;
        c.AccountId = accId;
        c.pse__Region__c = regionId;
        c.pse__Practice__c = practiceId;
        c.pse__Group__c = grpId;
        c.pse__Is_Resource__c = TRUE;
        c.pse__Is_Resource_Active__c = TRUE;
        c.pse__Start_Date__c = date.today().toStartOfMonth();
        c.pse__Utilization_Target__c = 75;
        c.pse__Salesforce_User__c = sfUserId;
        c.EBS_Vendor_Num__c = '12345';
        insert c;
        return c;
        
    }
    
    public static pse__Proj__c getProject(string projectName, Id regionId, Id practiceId, 
                                          Id groupId, Id projManId, string approveMethod, ID accid) {
        pse__Proj__c p = new pse__Proj__c();
        p.Name = projectName;
        p.pse__Is_Active__c = TRUE;
        p.pse__Region__c = regionId;
        p.pse__Practice__c = practiceId;
        p.pse__Group__c = groupId;
        p.pse__Stage__c = 'In Progress';
        p.pse__Project_Manager__c = projManId;
        p.Time_Approval_Method__c = approveMethod;
        p.Expense_Approval_Method__c = approveMethod;
        p.pse__Start_Date__c = date.today().toStartOfMonth();
        p.pse__End_Date__c = date.today().toStartOfMonth().addMonths(1).addDays(-1);
        p.pse__Account__c = accid;
        p.RecordTypeID = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Customer_Project').getRecordTypeId();
        
        insert p;
        return p;
    }
    
    public static void getPC(Id sfUserId, Id regionId) {
        pse__Permission_Control__c pc = new pse__Permission_Control__c();
        pc.pse__User__c = sfUserId;
        pc.pse__Region__c = regionId;
        pc.pse__Staffing__c = TRUE;
        pc.pse__Resource_Request_Entry__c = TRUE;
        pc.pse__Timecard_Ops_Edit__c = TRUE;
        
        insert pc;
    }
      
}