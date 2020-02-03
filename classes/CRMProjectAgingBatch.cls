/** Author - Shanu Aggarwal
*** Added on - 03/01/2018
*** Batch process to update the aging of projects
***/

global class CRMProjectAgingBatch implements Database.Batchable<sObject>, Schedulable{


    global Database.querylocator start(Database.BatchableContext BC){
        
        
        //Get status fields from custom setting 
        String statusFields = ' ';
        for(CRMProjAgeSetting__c setting : CRMProjAgeSetting__c.getAll().values()){
            statusFields += setting.StatusField__c+',';
        }
        statusFields = statusFields.removeEnd(',');

        //Get Status filters
        Set<String> statusFilter = CRMProjAgeSetting__c.getAll().keySet();

        return Database.getQueryLocator('Select Status__c, ' + statusFields + ' From CRM_Project__c Where Status__c IN:statusFilter');
    }
    
    global void execute(Database.BatchableContext BC, List<CRM_Project__c> scope){
        
        List<CRM_Project__c> updateProjList = new List<CRM_Project__c> ();
        Map<String,CRMProjAgeSetting__c> statusVsField = CRMProjAgeSetting__c.getAll();
        String fieldApiName;

        for(CRM_Project__c currentProj : scope){
            //Current project status stored in custom setting 
            if(statusVsField.containsKey(currentProj.Status__c)){    
                CRM_Project__c project = new CRM_Project__c();
                project.Id = currentProj.Id;
                
                //Get the Field API based on Status
                fieldApiName = statusVsField.get(currentProj.Status__c).StatusField__c;

                //increment the existing count 
                if(currentProj.get(fieldApiName)!=null){
                    project.put(fieldApiName,Integer.valueOf(currentProj.get(fieldApiName))+1);
                }else{
                    project.put(fieldApiName,1);
                }


                updateProjList.add(project);
    
            }
        }
        if(updateProjList.size()>0)
            update updateProjList;

        
    }
    global void finish(Database.BatchableContext BC){
        
    }
    
    global void execute(SchedulableContext SC) {
        Database.executeBatch(new CRMProjectAgingBatch(),200);
    }
}