/****************************************************************************************
Name            : PSA_updateProjectHealthBatch
Author          : TOP Step Consulting - Andy Heidrich (aheidrich@topstepconsulting.com)
Created Date    : 7-13-2017
Description     : This class queries records under Projects and rolls up aggregate scores 
				: for the Project Health calculation.  It includes Budget Score, 
				: Scope Score, Schedule Score, Escape Velocity Score, and Incident Severity Score. 
    			: Note that CSAT Score is calculated by After Insert/Update Trigger and related  
				: Handler Class on Survey_Q__c object (trigger PSA_SurveyInformation.apxt)
				: 
******************************************************************************************/

global class PSA_updateProjectHealthBatch implements Database.Batchable<sObject> {
    
    //Batch start method, define scope query
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id ' +
            		   'FROM pse__Proj__c ' +
            		   'WHERE pse__Is_Active__c = TRUE ' +
            		   'AND pse__Is_Billable__c = TRUE';
        return Database.getQueryLocator(query);
    }
    
    //Batch execute method begin
    global void execute(Database.BatchableContext BC, List<pse__Proj__c> scope) {
        
        //Declare set for Project Ids to perform queries
        set<Id>projIds = new set<Id>();
        
        //Declare maps for different Project Health calculation components
        
        //budgetMap = sum of billable Timecard hours through 
        //end of last Month (excluding any hours where
        //pse__Bill_Rate_is_Daily_Rate__c = TRUE)
        //populates Billable_Hours_Through_Last_Month__c on pse__Proj__c
        map<Id,double> budgetMap = new map<Id,double>();
        
        //scheduleMap = sum of Estimated Hours on Est vs Actual
        //records for current month and all months after where
        //Assignment is Billable - populates Future_Scheduled_Hours__c
        //on Project
        map<Id,double> scheduleMap = new map<Id,double>();
        
        //scopeMap = sum of Scope_Change_Number__c from 
        //all child Events_QA_Major_Deliverable__c records
        //populates Scope_Changes_Total__c on pse__Proj__c
        map<Id,double> scopeMap = new map<Id,double>();
       
        //escVelocityMap = sum of Power_Of_One__c from all 
        //child Events_QA_Major_Deliverable__c records where 
        //Remediation_Required__c = TRUE.  Populates
        //Escape_Velocity_Total__c on pse__Proj__c
        map<Id,double> escVelocityMap = new map<Id,double>();
        
        //incidentMap = sum of Project_Health_Points__c from all
        //child Events_Minor_Deliverable_Incident_Report__c records
        //Populates Incident_Severity_Points__c on pse__Proj__c
        map<Id,double> incidentMap = new map<Id,double>();
                
        //Put Project IDs in the set
        for(pse__Proj__c p : scope) {
            projIds.add(p.Id);
        }
        
        date firstOfMonth = date.today().toStartOfMonth();
        
        //Query Timecard Hours
        for(aggregateResult ar: [SELECT pse__Project__c, SUM(pse__Total_Hours__c) totHrs
                                 FROM pse__Timecard__c
                                 WHERE pse__Project__c IN : projIds
                                 AND pse__Billable__c = TRUE
                                 AND pse__Timecard_Header__r.pse__Daily_Bill_Rate__c = FALSE
                                 AND pse__End_Date__c < : firstOfMonth
                                 GROUP BY pse__Project__c]) 
        {
            //Store total hours in budgetMap
            budgetMap.put((Id)ar.get('pse__Project__c'),(double)ar.get('totHrs'));
        }
        
        //Query Scope Changes
        for(aggregateResult ar: [SELECT Project__c, SUM(Scope_Change_Number__c) totScope
                                 FROM Events_QA_Major_Deliverable__c 
                                 WHERE Project__c IN : projIds
                                 GROUP BY Project__c])
        {
            //Store total Scope Change Score in scopeMap
            scopeMap.put((Id)ar.get('Project__c'),(double)ar.get('totScope'));
        }
        
        //Query Schedule Changes
        for(aggregateResult ar: [SELECT pse__Project__c, SUM(pse__Estimated_Hours__c) totSched
                                 FROM pse__Est_vs_Actuals__c 
                                 WHERE pse__Project__c IN : projIds
                                 AND pse__Time_Period_Type__c = 'Month'
                                 AND pse__Start_Date__c >= : firstOfMonth
                                 AND pse__Assignment__r.pse__Is_Billable__c = TRUE
                                 GROUP BY pse__Project__c])
        {
            //Store total Scope Change Score in scopeMap
            scheduleMap.put((Id)ar.get('pse__Project__c'),(double)ar.get('totSched'));
        }
        
       //Query Escape Velocity (Remediation Required) Count
        for(aggregateResult ar: [SELECT Project__c, SUM(PowerOfOne__c) totEscVel
                                 FROM Events_QA_Major_Deliverable__c 
                                 WHERE Project__c IN : projIds
                                 AND Remediation_Required__c = TRUE
                                 GROUP BY Project__c])
        {
            //Store Escape Velocity count in escVelocityMap
            escVelocityMap.put((Id)ar.get('Project__c'),(double)ar.get('totEscVel'));
        }
        
        //Query Incident Severity Score
        for(aggregateResult ar: [SELECT Project__c, SUM(Project_Health_Points__c) totIncident
                                 FROM Events_Minor_Deliverable_Incident_Report__c
                                 GROUP BY Project__c])
        {
            incidentMap.put((Id)ar.get('Project__c'),(double)ar.get('totIncident'));
        }
        
        //Now update the Projects
        //Declare list for updating Projects
        list<pse__Proj__c> projUpdate = new list<pse__Proj__c>();
        
        //Loop through Projects and populate score values if they exist
        //in the maps, else initialize them to zero
        for(pse__Proj__c p : scope) {
            
            if(!budgetMap.isEmpty()) {
                if(budgetMap.containsKey(p.Id)) {
                    p.Billable_Hours_Through_Last_Month__c = budgetMap.get(p.Id);
                }
                else{ p.Billable_Hours_Through_Last_Month__c = 0; }
            }
            
            if(!scopeMap.isEmpty()) {
                if(scopeMap.containsKey(p.Id)) {
                    p.Scope_Changes_Total__c = scopeMap.get(p.Id);
                }
                else{ p.Scope_Changes_Total__c = 0; }
            }
            
            if(!scheduleMap.isEmpty()) {
                if(scheduleMap.containsKey(p.Id)) {
                    p.Future_Scheduled_Hours__c = scheduleMap.get(p.Id);
                }
                else{ p.Future_Scheduled_Hours__c = 0; }
            }
            
            if(!escVelocityMap.isEmpty()) {
                if(escVelocityMap.containsKey(p.Id)) {
                    p.Escape_Velocity_Total__c = escVelocityMap.get(p.Id);
                }
                else{ p.Escape_Velocity_Total__c = 0; }
            }
            
            if(!incidentMap.isEmpty()) {
                if(incidentMap.containsKey(p.Id)) {
                    p.Incident_Severity_Points__c = incidentMap.get(p.Id);
                }
                else{ p.Incident_Severity_Points__c = 0; }
            }
    		
            //Add updated Project to the list
            projUpdate.add(p);
            
        }
        
        //Update the Projects
        if(!projUpdate.isEmpty()) {
            update projUpdate;
        }
        
    }
    
    //Required finish method.
    global void finish(Database.BatchableContext BC) {
        AsyncApexJob job = [SELECT Status, NumberOfErrors, JobItemsProcessed FROM AsyncApexJob WHERE Id =:BC.getJobId()];
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[]{'aheidrich@topstepconsulting.com'});
        email.setSubject('PSA_updateProjectHealthBatch ' + job.Status);
        email.setPlainTextBody(job.JobItemsProcessed + ' records were processed with ' + job.NumberOfErrors + ' failures.');
        if(job.NumberOfErrors > 0) Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
    }

}