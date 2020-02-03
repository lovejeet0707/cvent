@istest
public class CRMProjectAgingBatchTest{

    static testmethod void runBatch(){
    
        CRMProjAgeSetting__c s = new CRMProjAgeSetting__c();
        s.Name = 'In Progress';
        s.StatusField__c = 'In_Progress__c';
        insert s;
        
        ResourceProject__c release = new ResourceProject__c();
        release.Name = 'CRM Major Release';
        release.Project_Name__c = 'CRM Major Release';
        release.Requirements_Cut_Off_Date__c = System.today();
        release.UAT_Start_Date__c = System.today()+3;
        release.UAT_Sign_Off_Date__c = System.today()+5;
        release.Deployment_Date__c = System.today()+7; 
        insert release;
                
        CRM_Project__c proj = new CRM_Project__c();
        proj.Project_Name__c = 'Test Proj';
        proj.CRM_Release__c = release.Id;
        proj.Project_Team__c = 'CRM Management';
        proj.Reporting_Process_Improvement_Automation__c = 'Development';
        proj.Status__c = 'In Progress';
        proj.Requestor__c = UserInfo.getUserId();
        //proj.Development_Team__c = 'CRM';
        //proj.Development_Owner__c = UserInfo.getUserId();
        proj.Description__c = 'Test Proj';
        insert proj;
        
        test.startTest();
        Database.ExecuteBatch(new CRMProjectAgingBatch());
        test.stopTest();
    
    }
    
    static testmethod void schdeuleBatch(){
    
        CRMProjAgeSetting__c s = new CRMProjAgeSetting__c();
        s.Name = 'In Progress';
        s.StatusField__c = 'In_Progress__c';
        insert s;
        
        ResourceProject__c release = new ResourceProject__c();
        release.Name = 'CRM Major Release';
        release.Project_Name__c = 'CRM Major Release';
        release.Requirements_Cut_Off_Date__c = System.today();
        release.UAT_Start_Date__c = System.today()+3;
        release.UAT_Sign_Off_Date__c = System.today()+5;
        release.Deployment_Date__c = System.today()+7; 
        insert release;
                
        CRM_Project__c proj = new CRM_Project__c();
        proj.Project_Name__c = 'Test Proj';
        proj.CRM_Release__c = release.Id;
        proj.Project_Team__c = 'CRM Management';
        proj.Reporting_Process_Improvement_Automation__c = 'Development';
        proj.Status__c = 'In Progress';
        proj.Requestor__c = UserInfo.getUserId();
        //proj.Development_Team__c = 'CRM';
        //proj.Development_Owner__c = UserInfo.getUserId();
        proj.Description__c = 'Test Proj';
        insert proj;
        
        test.startTest();
        CRMProjectAgingBatch btch = new CRMProjectAgingBatch();
        // Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
        String sch = '20 30 8 10 2 ?';
        String jobID = System.schedule('Aging batch', sch, btch);
        test.stopTest();
    
    }


}