@isTest
public class CRMProjectViewControllerTest {

    
    static testmethod void test1(){
        ResourceProject__c rp = new ResourceProject__c();
        rp.Name = 'CRM Release 1';
        rp.Project_Name__c = 'CRM Release 1';
        rp.Requirements_Cut_Off_Date__c = System.today() + 15 ;
        rp.UAT_Start_Date__c = System.today() + 30 ;
        rp.UAT_Sign_Off_Date__c   = System.today() + 35 ;
        rp.Deployment_Date__c  = date.newInstance(System.today().Year(), System.today().Month(), 31);

        
        insert rp ;
        
        CRM_Project__c proj = new CRM_Project__c();
        proj.Project_Name__c = 'CRM Project 1';
        proj.CRM_Release__c = rp.Id;
        proj.Description__c = 'Test';
        proj.Project_Team__c = 'SOPS';
        //proj.Reporting_Process_Improvement_Automation__c = 'Development';
        proj.Status__c = 'In Progress';
        proj.Requestor__c = UserInfo.getUserId();
        
        insert proj;
        
        
        CRM_Project_Item__c item = new CRM_Project_Item__c();
        item.Subject__c = 'Test Item';
        item.CRM_Project__c = proj.Id ;
        item.Assigned_To__c = UserInfo.getUserId();
        item.Item_Type__c = 'Development';
        insert item;
            
        
        CRMProjectViewController ctr = new CRMProjectViewController();
        
        ctr.getReleases();
        ctr.getProjects();
        ctr.projectId = proj.Id;
        ctr.getWorkItemsList();
        ctr.RefereshProjects();
        ctr.getNotesAttachments();
        ctr.getProjStatuses();
        
    }
    
}