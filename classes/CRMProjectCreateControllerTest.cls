@istest
public class CRMProjectCreateControllerTest{

    static testmethod void  testProjects(){
    
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
        
        
        
        
        CRM_Project_Item__c pitem = new CRM_Project_Item__c();
        pitem.Subject__c = 'Test Item';
        pitem.CRM_Project__c = proj.Id ;
        pitem.Assigned_To__c = UserInfo.getUserId();
        pitem.Item_Type__c = 'Development';
        
        CRMProjectCreateController.ItemWrapper itemWrap = new CRMProjectCreateController.ItemWrapper(pitem);
        
        list<CRMProjectCreateController.ItemWrapper> itemWrapperList = new list<CRMProjectCreateController.ItemWrapper>();
        itemWrapperList.add(itemWrap);
    
        PageReference pgRef = Page.CRMProjectCreator;
        Test.setCurrentPage(pgRef);    
        
        CRM_Project_Queue__c q = new CRM_Project_Queue__c();
        q.Name = 'R&D';
        insert q;
        
        CRM_Project_Queue_Item__c item = new CRM_Project_Queue_Item__c();
        item.Name = 'Test Proj';
        item.CRM_Project_Queue__c = q.Id;
        item.Reason_for_moving_to_Dev__c = 'Need Apex Code';
        item.Description__c= 'Test';
        item.Category__c= 'Development';
        insert item;
        
        pgRef.getParameters().put('queuItemId',item.Id);
        pgRef.getParameters().put('index','1');
        
        ApexPages.StandardController controller = new ApexPages.StandardController(item);
        CRMProjectCreateController ct = new CRMProjectCreateController(controller);
        ct.addRow();
        ct.addRow();
        ct.removingRow();
        
        ct.proj = proj;
        ct.itemWrapperList = itemWrapperList;
        
        ct.save();
        
        
        
        ct.Cancel();
        
        
    
    }
    
   
        
}