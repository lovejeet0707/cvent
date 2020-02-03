public class Am_Checklist_Class {
        //private final AM_Checklist__c account;
        public AM_Checklist__c account {get; private set;}
        Id id = ApexPages.currentPage().getParameters().get('id');
        Id id2 = ApexPages.currentPage().getParameters().get('acc_name');
        string tabname = ApexPages.currentPage().getParameters().get('tab_name');
               
        private String account_name, tab_name;
        public Am_Checklist_Class() {
        account = [Select a.Others__c, a.Reference__c, a.eMarketing_TBD_TB__c, a.eMarketing_TBD_CB__c, a.Webex_Training_TB__c, a.Webex_Training_CB__c, a.Webex_Integration_TB__c, a.Webex_Integration_CB__c, a.User_Logins_TB__c, a.User_Logins_CB__c, a.Task_List_TB__c, a.Task_List_CB__c, a.Table_Management_TB__c, a.Table_Management_CB__c, a.Survey_TB__c, a.Survey_CB__c, a.SurveyBuilder_TB__c, a.SurveyBuilder_CB__c, a.Salesforce_Integration_TB__c, a.Salesforce_Integration_CB__c, a.SMM_Meetings_Registration_TB__c, a.SMM_Meetings_Registration_CB__c, a.SMM_Meetings_Module_Ent_TB__c, a.SMM_Meetings_Module_Ent_CB__c, a.Registration_Rules_TB__c, a.Registration_Rules_CB__c, a.Passkey_TB__c, a.Passkey_CB__c, a.Parked_Reports_TB__c, a.Parked_Reports_CB__c, a.PSG_TB__c, a.PSG_CB__c, a.Onsite_Training_TB__c, a.Onsite_Training_CB__c, a.Name, a.ListBuilder_TB__c, a.ListBuilder_CB__c, a.LastModifiedDate, a.LastModifiedById, a.IsDeleted, a.Increased_Graphics_Storage_TB__c, a.Increased_Graphics_Storage_CB__c, a.Increased_Emails_Sent_TB__c, a.Increased_Emails_Sent_CB__c, a.Increased_Contacts_in_Address_Book_TB__c, a.Increased_Contacts_in_Address_Book_CB__c, a.Id, a.Housing_Travel_TB__c, a.Housing_Travel_CB__c, a.HTTP_Posting_TB__c, a.HTTP_Posting_CB__c, a.Group_Items_CB__c, a.Group_Item_TB__c, a.GetThere_TB__c, a.GetThere_CB__c, a.GL_Codes_TB__c, a.GL_Codes_CB__c, a.Events_Calendar_TB__c, a.Events_Calendar_CB__c, a.Event_Credits_Module_TB__c, a.Event_Credits_Module_CB__c, a.Event_Approval_Process_TB__c, a.Event_Approval_Process_CB__c, a.EventBuilder_TB__c, a.EventBuilder_CB__c, a.Dashboards_TB__c, a.Dashboards_CB__c, a.Custom_Reports_TB__c, a.Custom_Reports_CB__c, a.Custom_Graphics_TB__c, a.Custom_Graphics_CB__c, a.CreatedDate, a.CreatedById, a.Cliqbooks_TB__c, a.Cliqbooks_CB__c, a.Call_Center_TB__c, a.Call_Center_CB__c, a.CSN_TB__c, a.CSN_CB__c, a.Budget_TB__c, a.Budget_CB__c, a.Branding_Package_TB__c, a.Branding_Package_CB__c, a.Backend_Onsite_Srv_AMI_Partner_TB__c, a.Backend_Onsite_Srv_AMI_Partner_CB__c, a.Advanced_Web_Design_TB__c, a.Advanced_Web_Design_CB__c, a.Advanced_Registration_TB__c, a.Advanced_Registration_CB__c, a.Address_Book_Segmentation_TB__c, a.Address_Book_Segmentation_CB__c, a.Account__c, a.API_TB__c, a.API_CB__c From AM_Checklist__c a where id = 
        :id];
        account_name  = [select name from account where id = :id2 limit 1].name;
        tab_name = tabname;
        
        }
       
       public string getnameaccount() {
return this.account_name;
} 
public string getnametab() {
return this.tabname;
} 
 
public void setnametab(String s) {
this.tabname = s;
}    
        public PageReference save() {
        try {
update(account);
String xx;      
                        xx = id + '&acc_name=' + id2+'&tab_name=' + tabname  ;
String x1 = 'https://ssl.salesforce.com/apex/ViewAmFeatureSet?id=' + xx;
PageReference opptyPage = new PageReference(x1);
opptyPage.setRedirect(true);
return opptyPage;
} catch(System.DMLException e) {
ApexPages.addMessages(e);
return null;
}
        return null;
}
  
public PageReference edit() {
        
String xx;      
                        xx = id + '&acc_name=' + id2 + '&tab_name=' + tabname  ;
String x1 = 'https://ssl.salesforce.com/apex/EditAmFeatureSet?id=' + xx;
PageReference opptyPage = new PageReference(x1);
opptyPage.setRedirect(true);
return opptyPage;
}

public PageReference edit1() {
        
String xx;      
                      
                        xx = id + '&acc_name=' + id2 + '&tab_name=name1' ;
 String x1 = 'https://ssl.salesforce.com/apex/EditAmFeatureSet?id=' + xx;
PageReference opptyPage = new PageReference(x1);
opptyPage.setRedirect(true);
return opptyPage;
}
public PageReference edit3() {
        
String xx;      
                       
                        xx = id + '&acc_name=' + id2 + '&tab_name=name3' ;
 String x1 = 'https://ssl.salesforce.com/apex/EditAmFeatureSet?id=' + xx;
PageReference opptyPage = new PageReference(x1);
opptyPage.setRedirect(true);
return opptyPage;
}
 
public PageReference edit2() {
        
String xx;      
                       
                        xx = id + '&acc_name=' + id2 + '&tab_name=name2' ;
 String x1 = 'https://ssl.salesforce.com/apex/EditAmFeatureSet?id=' + xx;
PageReference opptyPage = new PageReference(x1);
opptyPage.setRedirect(true);
return opptyPage;
}

public PageReference cancel() {
        
String xx;      
                        xx = id + '&acc_name=' + id2+'&tab_name=' + tabname  ;
String x1 = 'https://ssl.salesforce.com/apex/ViewAmFeatureSet?id=' + xx;
PageReference opptyPage = new PageReference(x1);
opptyPage.setRedirect(true);
return opptyPage;
}
}