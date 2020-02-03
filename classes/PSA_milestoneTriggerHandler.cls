/****************************************************************************************
Name            : PSA_milestoneTriggerHandler
Author          : TOP Step Consulting - Andy Heidrich (aheidrich@topstepconsulting.com)
Created Date    : 
Description     : Contains methods called from Triggers on the Milestone object. All
				: Milestone trigger code should go in this class.  Each method
				: has its description listed at the beginning of the method.
Changelog		: 
******************************************************************************************/

public class PSA_milestoneTriggerHandler {
    
    //This method handles Milestone Weighting Calculations on the Project.
    //It sums the necessary values from the child Milestones and 
    //updates the Project if different from the current values.
    //Runs in After Insert and After Update context.
    public static void sumMilestoneWeight(list<pse__Milestone__c> mList) {
        
        if(PSA_Utils.isTriggerDisabled('sumMilestoneWeight')) { return; }
        
        //Declare needed Project collections
        set<Id> projIds = new set<Id>();
        list<pse__Proj__c> projUpdate = new list<pse__Proj__c>();
        map<Id,pse__Proj__c> projMap = new map<Id,pse__Proj__c>();
        
        //Declare maps to hold totals
        map<Id,Double>totalWeightMap = new map<Id,Double>();
		map<Id,Double>completeWeightMap = new map<Id,Double>();        
        
        //Loop through Milestones and add to projIds set
        //if Milestones have a Weight > 0
        for(pse__Milestone__c m : mList) {
            
            if(m.Milestone_Weight_for_Project__c > 0) {
            	projIds.add(m.pse__Project__c);
            }
        }
        
        //Proceed if we have Weighted Milestones
        if(!projIds.isEmpty()) {    
        	
            //Query the Projects and put them in a Map
            for(pse__Proj__c p : [SELECT Id, Total_Milestone_Weight__c, Completed_Milestone_Weight__c
                                  FROM pse__Proj__c
                                  WHERE Id IN : projIds]) 
            {
                projMap.put(p.Id,p);
            }
            
            //Aggregate Query for Total Milestone Weight; store results in totalWeightMap by Project
            for(aggregateResult t : [SELECT pse__Project__c,SUM(Milestone_Weight_for_Project__c) totWeight
                                     FROM pse__Milestone__c WHERE pse__Project__c IN : projIds
                                     GROUP BY pse__Project__c]) 
            {
                 totalWeightMap.put((Id)t.get('pse__Project__c'), (Double)t.get('totWeight'));                        
            }
            
            //Aggregate Query for Completed Milestone Weight; store results in completeWeightMap by Project
            for(aggregateResult t : [SELECT pse__Project__c,SUM(Milestone_Weight_for_Project__c) compWeight
                                     FROM pse__Milestone__c WHERE pse__Project__c IN : projIds
                                     AND (pse__Status__c = 'Approved' OR pse__Status__c = 'Complete' OR pse__Status__c = 'Completed')
                                     GROUP BY pse__Project__c]) 
            {
                 completeWeightMap.put((Id)t.get('pse__Project__c'), (Double)t.get('compWeight'));                        
            }
            
            //Loop through the Projects to update values
            for(pse__Proj__c p : projMap.values()) {
                
                //Declare necessary variables
                double totalWeight;
                double completeWeight;
                double weightPercentComplete;
                boolean doUpdate = FALSE;
                
                //Initialize totalWeight with sum of this Project's Milestones from Map
                if(totalWeightMap.containsKey(p.Id)) {
                    
                    totalWeight = totalWeightMap.get(p.Id); 
                }
                
                //Initialize completeWeight with sum of this Project's Milestones value from Map (else zero)
                if(completeWeightMap.containsKey(p.Id)) {
                    
                    completeWeight = completeWeightMap.get(p.Id);
                }
                else(completeWeight = 0);
                
                //Calculate the total Weighted Percent Complete
                weightPercentComplete = completeWeight/TotalWeight * 100;
                
                //Update Complete Weight on Project if different
                if(completeWeight != p.Completed_Milestone_Weight__c) {
                    p.Completed_Milestone_Weight__c = completeWeight;
                    doUpdate = TRUE;  
                }
                //Update Total Weight on Project if different
                if(totalWeight != p.Total_Milestone_Weight__c) {
                    p.Total_Milestone_Weight__c = totalWeight;
                    doUpdate = TRUE;
                }
                
                //If either Total or Complete Weight are different, update
                //Weighted Percent Complete on Project (add to list)
                if(doUpdate == TRUE) {
                    p.Project_Compl_Milestone_Weighted__c = weightPercentComplete;
                	projUpdate.add(p);
                }
            }
            //Update if we have any projects
            if(!projUpdate.isEmpty()) {
            	update projUpdate;
            }
        }
    }
}