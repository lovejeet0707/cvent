/*
 * Class Name: CRM_EmailComponentController
 * Description: This class acts as the shared controller for VF Components "CRM_EmailComponent" and "CRM_EmailComponentRelease"
 * 
 * 
 *  History:
 *  Date            Version     Change/Description                          Author
 * -------------------------------------------------------------------------------------------
 *  May 3, 2016     1.0         Created                                     Praveen Kaushik
 * -------------------------------------------------------------------------------------------
*/
public without sharing class CRM_EmailComponentController {
    public String releaseIdCtrl;
    public String requestorIdCtrl;
    public Boolean readyForUATCtrl;
    public String projectStatusCtrl;
    
    public void setReleaseIdCtrl(string val){
        releaseIdCtrl = val;
    }
    public String getReleaseIdCtrl(){
        return releaseIdCtrl;
    }
    
    public void setRequestorIdCtrl(string val){
        requestorIdCtrl = val;
    }
    public String getRequestorIdCtrl(){
        return requestorIdCtrl;
    }

    public void setReadyForUATCtrl(boolean val){
        readyForUATCtrl = val;
    }
    public boolean getReadyForUATCtrl(){
        return readyForUATCtrl;
    }
    
    public void setProjectStatusCtrl(string val){
        projectStatusCtrl = val;
    }
    public String getProjectStatusCtrl(){
        return projectStatusCtrl;
    }
    
    public CRM_EmailComponentController() {
    }

    public List<CRM_Project__c> getProjects() {
        List<CRM_Project__c> projects = [select Id, Name, Project_Team__c, Status__c, CRM_Release__c, Case__c, Actual_Effort_Hours__c, Project_Name__c, Description__c, Estimated_Effort_Hours__c, Requestor__r.FirstName, Requestor__r.LastName  from CRM_Project__c where CRM_Release__c =: releaseIdCtrl];
        if(projectStatusCtrl != null){
            if(requestorIdCtrl != null) {
                projects = [select Id, Name, Project_Team__c, Status__c, CRM_Release__c, Case__c, Actual_Effort_Hours__c, Project_Name__c, Description__c, Estimated_Effort_Hours__c, Requestor__r.FirstName, Requestor__r.LastName  from CRM_Project__c where CRM_Release__c =: releaseIdCtrl and Status__c =: projectStatusCtrl and Requestor__c =: requestorIdCtrl];
            } else {
                projects = [select Id, Name, Project_Team__c, Status__c, CRM_Release__c,  Case__c, Actual_Effort_Hours__c, Project_Name__c, Description__c, Estimated_Effort_Hours__c, Requestor__r.FirstName, Requestor__r.LastName  from CRM_Project__c where CRM_Release__c =: releaseIdCtrl and Status__c =: projectStatusCtrl];                
            }
        } else {
            if(requestorIdCtrl != null) {
                projects = [select Id, Name, Project_Team__c, Status__c, CRM_Release__c, Case__c, Actual_Effort_Hours__c, Project_Name__c, Description__c, Estimated_Effort_Hours__c, Requestor__r.FirstName, Requestor__r.LastName  from CRM_Project__c where CRM_Release__c =: releaseIdCtrl and Requestor__c =: requestorIdCtrl];
            }
        }
        return projects;
    }

    
    public ResourceProject__c getCRMRelease(){
        List<ResourceProject__c> releases = [select Id, UAT_Sign_Off_Date__c, UAT_Start_Date__c, Deployment_Date__c, Release_Type__c, Estimated_Effort_Hours__c, of_projects_total__c, of_Projects_Sign_Off_Received__c from ResourceProject__c where id =:releaseIdCtrl];
        return releases.size() > 0 ? releases[0] : null;
    }
}