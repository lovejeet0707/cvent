public class CRMProjectViewController {

    public string assigneeName {get;set;}
    public Id releaseId {get;set;}
    public Id projectId {get;set;}
    public boolean showProjects {get;set;}
    List<ResourceProject__c> releaseList;
    
    public  string statusSelected {get;set;}
    public List<CRM_Project__c> projectList {get;set;}
    public Map<Id,ResourceProject__c> releaseMap {get;set;}
    Map<Id,List<CRM_Project_Item__c>> mapOfProjects;
    List<CRM_Project_Item__c> dataList;     
    
    
    public CRMProjectViewController(){  
        showProjects=false;
        statusSelected = '---All---';
        //Default value to current user
        assigneeName = UserInfo.getName();  
        
             
        releaseMap = new Map<Id,ResourceProject__c>([Select Id ,UAT_Start_Date__c,UAT_Sign_Off_Date__c ,Name,Release_Type__c,Estimated_Effort_Hours__c,Actual_Effort_Hours__c,Deployment_Date__c From ResourceProject__c 
        where Name like '%CRM%' AND ( Deployment_Date__c = THIS_MONTH OR Deployment_Date__c = LAST_N_MONTHS:2 OR Deployment_Date__c =NEXT_N_MONTHS:1 ) 
        Order by Deployment_Date__c DESC LIMIT 10]);
        
        releaseList =  releaseMap.values();
        if(!releaseMap.isEmpty()){
            releaseId = releaseList.get(0).Id;
        }
        //Default Value to Current Release
        for(ResourceProject__c  rl : releaseList){
    
            if(rl.Deployment_Date__c<System.today()){
                break;
            }
            releaseId =rl.Id;
        }
        
        RefereshProjects();
                   
    }
    
    //Get All Releases 
    public List<SelectOption> getReleases(){
        
        List<SelectOption> options = new List<SelectOption>();
        
        for(ResourceProject__c release : releaseList ){
            options.add(new SelectOption(release.Id,release.Name));
        }
        
        return options;
    }
    
    //get status
    public List<SelectOption> getProjStatuses()
    {
       List<SelectOption> options = new List<SelectOption>();
            
       Schema.DescribeFieldResult fieldResult =
       CRM_Project__c.Status__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       options.add(new SelectOption('---All---','---All---'));     
       for( Schema.PicklistEntry f : ple)
       {
          options.add(new SelectOption(f.getLabel(), f.getValue()));
       }       
       
       return options;
    }
    
    //Get All Releases 
    public List<SelectOption> getProjects(){
        
        List<SelectOption> options = new List<SelectOption>();
       
            for(CRM_Project__c proj : projectList){
                options.add(new SelectOption(proj.Id,proj.Project_Name__c));
            }
        
        return options;
    }
    
     
    
    //Get WorkItems          
    public List<CRM_Project_Item__c> getWorkItemsList(){
           
           System.debug('*******projectId*** @@@ ' + projectId);
           dataList = new List<CRM_Project_Item__c>();

           if(projectId!=null){
               /*dataList =[ Select Id, Name, Subject__c,CreatedDate, Estimated_Effort_Hours__c,Actual_Effort_Hours__c, Description__c,Assigned_To__c,Project_Owner__c, Type__c, Available_Hours__c, Status__c
                            From CRM_Project_Item__c Where CRM_Project__c =:projectId ];  */
                            
            if(mapOfProjects.get(projectId)!=null){
                dataList = mapOfProjects.get(projectId);
            }
            
            System.debug('*******dataList *** @@@ ' + dataList );    
            
           
            return dataList;
        }
        
        return null;
    
    }
    
    //Get WorkItems          
    public List<Note> getNotesAttachments(){
           
           List<Note> noteList = new List<Note>();
           
           if(projectId!=null){
                noteList = [Select Id,Title,Body From Note Where ParentId=:projectId];
                return noteList;
            }
    
            return null;   
    }
   
    
    //Referesh Projects
    public void RefereshProjects(){
        
        mapOfProjects = new Map<Id,List<CRM_Project_Item__c>>();
        Set<CRM_Project__c> projectsSet = new Set<CRM_Project__c>();
        projectList = new List<CRM_Project__c>();
        dataList = new List<CRM_Project_Item__c>();
        system.debug('***statusSelected**'+ statusSelected);
        System.debug('releaseId'+ releaseId);
        System.debug('assigneeName'+ assigneeName);
        System.debug('projectId'+ projectId);
        
         String query = 'Select Id, Name, Subject__c,CreatedDate, Estimated_Effort_Hours__c,Actual_Effort_Hours__c, Description__c,Assigned_To__c,Project_Owner__c, Type__c, Available_Hours__c,'+
           'Status__c,CRM_Project__c,CRM_Project__r.Name,CRM_Project__r.Description__c,CRM_Project__r.CreatedDate ,CRM_Project__r.Project_Name__c,CRM_Project__r.Reporting_Process_Improvement_Automation__c,'+ 
           'CRM_Project__r.Requester_Department__c ,CRM_Project__r.Project_Team__c,CRM_Project__r.CRM_Release__c,CRM_Project__r.Status__c,CRM_Project__r.Requestor__c,'+
           'CRM_Project__r.Requestor__r.Name,CRM_Project__r.Estimated_Effort_Hours__c,CRM_Project__r.Actual_Effort_Hours__c From CRM_Project_Item__c Where CRM_Project__r.CRM_Release__c =:releaseID' ;
        
        if(assigneeName!='---All---'){
            query += ' And Assigned_To__r.Name =:assigneeName';
        }
        
        if(statusSelected!='---All---'){
            query += ' And CRM_Project__r.Status__c =:statusSelected';
        }
        
        if(releaseId!=null){
            
            for(CRM_Project_Item__c cItem : Database.Query(query)){
                 projectsSet.add(cItem.CRM_Project__r);
                 
                 if(mapOfProjects.containsKey(cItem.CRM_Project__c))
                     mapOfProjects.get(cItem.CRM_Project__c).add(cItem);
                 else
                     mapOfProjects.put(cItem.CRM_Project__c, new List<CRM_Project_Item__c>{cItem});
            }
        }  
       
            
        /*    
        if( releaseId!=null)
        projectList = [ Select Id,Name,CreatedDate ,Project_Name__c,Reporting_Process_Improvement_Automation__c,Requester_Department__c ,Project_Team__c,CRM_Release__c,Status__c,Requestor__c, Requestor__r.Name,
                        Estimated_Effort_Hours__c,Actual_Effort_Hours__c From CRM_Project__c Where CRM_Release__c =:releaseID];
        */
        projectList.addAll(projectsSet);
         
        if( projectList!=null && projectList.size() >0 )
           showProjects =true;
        else
           showProjects =false;
        
       
    }
   
}