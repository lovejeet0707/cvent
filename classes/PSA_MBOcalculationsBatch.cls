/****************************************************************************************
Name            : PSA_MBOcalculationsBatch
Author          : TOP Step Consulting - Andy Heidrich (aheidrich@topstepconsulting.com)
Created Date    : 
Description     : This stateful batch method is run from PSA_MBOcalculationsSchedule class.
                : Should be scheduled to always execute following scheduled Utilization
                : Calculation. This batchable class finds timecards against projects that
                : are Internal MBO or MBO Excluded, and sums the respective hours into two
                : separate fields on the Monthly Utilization Detail records for each
                : resource.  This lets us have accurate utilization calculations in our
                : reports.
******************************************************************************************/

global class PSA_MBOcalculationsBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    //Create global map of Utilization Detail records
    //for stateful storage of totals across multiple batches.
    //String Key is Time Period + Resource
    global map<string,pse__Utilization_Detail__c> udMap;
    global PSA_MBOcalculationsBatch(){
        udMap = new Map<string,pse__Utilization_Detail__c> ();
    }
    
    //Batch start method, scope query is Timecard Splits on Projects that are
    //either Internal MBO or MBO Excluded.  We are going to sum these onto 
    //Monthly Resource Utilization Detail records for Utilization Calculations.
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, pse__Resource__c, pse__Project__r.Internal_MBO__c, pse__Total_Hours__c, ' +
                        'pse__Project__r.MBO_Time_Excluded__c, Time_Period__c, Time_Period_Quarter__c, Time_Period_Year__c,' +
                        'pse__Project__c FROM pse__Timecard__c WHERE ' +
                        '(pse__Project__r.Internal_MBO__c = TRUE OR pse__Project__r.MBO_Time_Excluded__c = TRUE) ' +
                        'AND pse__Total_Hours__c > 0 AND Time_Period__c != NULL AND pse__Submitted__c = TRUE ' +
                        'AND pse__Status__c <> \'Rejected\' ORDER BY Time_Period__c, pse__Resource__c';
        return Database.getQueryLocator(query);
    }
    
    //Batch execute method begin
    global void execute(Database.BatchableContext BC, List<pse__Timecard__c> scope) {
        
        //Declare a map of Timecard Splits with Time Period + Resource string as key
        //Declare sets to store Time Period and Resource Ids for querying
        map<string,pse__Timecard__c> tcMap = new map<string,pse__Timecard__c>();
        set<Id> tpIds = new set<Id>();
        set<Id> rIds = new set<Id>();
        
        //Loop through the Splits in this batch.  Add Time Period Id to set,
        //Resource Id to set, create key and add TC split to map
        for(pse__Timecard__c tc : scope) {
            tpIds.add(tc.Time_Period__c);
            tpIds.add(tc.Time_Period_Quarter__c);
            tpIds.add(tc.Time_Period_Year__c);
            rIds.add(tc.pse__Resource__c);
            string theKey1 = string.valueOf(tc.Time_Period__c) + string.valueOf(tc.pse__Resource__c);
            string theKey2 = string.valueOf(tc.Time_Period_Quarter__c) + string.valueOf(tc.pse__Resource__c);
            string theKey3 = string.valueOf(tc.Time_Period_Year__c) + string.valueOf(tc.pse__Resource__c);
            tcMap.put(theKey1,tc);
            tcMap.put(theKey2,tc);
            tcMap.put(theKey3,tc);
        }
        
        system.debug('tcMap size: ' + tcMap.size());
        
        //Declare local Utilization Detail map that will feed new Utilization Detail
        //records to the Global map if they've not been put there in a prior batch
        map<string,pse__Utilization_Detail__c> udLookup = new map<string,pse__Utilization_Detail__c>();
        //Populate local map with UD records related to Timecard Splits in this batch
        for(pse__Utilization_Detail__c ud : [SELECT Id, pse__Resource__c, pse__Time_Period__c,
                                             pse__Resource__r.LastName, pse__Resource__r.FirstName,
                                             Internal_MBO_Hours__c, Excluded_MBO_Hours__c
                                             FROM pse__Utilization_Detail__c
                                             WHERE pse__Time_Period__c IN : tpIds
                                             AND pse__Resource__c IN : rIds]) 
        {
            //Build our universal key
            string theKey = string.valueOf(ud.pse__Time_Period__c) + string.valueOf(ud.pse__Resource__c);
            //Put Utilization Detail record in the map
            udLookup.put(theKey, ud);
                                                
        }
        
        //Loop through the Timecards
        for(pse__Timecard__c tc :scope)
        {
            //Declare our key
            string theKey = string.valueOf(tc.Time_Period__c) + string.valueOf(tc.pse__Resource__c);
            string theKey2 = string.valueOf(tc.Time_Period_Quarter__c) + string.valueOf(tc.pse__Resource__c);
            string theKey3 = string.valueOf(tc.Time_Period_Year__c) + string.valueOf(tc.pse__Resource__c);
            //Execute Month if the global map already has running totals for this resource/month from
            //a previous batch - add values to what's in the global map
            if(udMap.containsKey(theKey)) {
                system.debug('----udMap1234'+udMap);
                //Get our record to work with
                pse__Utilization_Detail__c ud = udMap.get(theKey);
                //Logic if Project is Internal MBO
                system.debug('----ud.'+ud.id);
                if(tc.pse__Project__r.Internal_MBO__c == TRUE) {
                    //Add to what's in the map already
                    ud.Internal_MBO_Hours__c += tc.pse__Total_Hours__c;
                    //Keep Excluded the same (is this necessary?)
                    ud.Excluded_MBO_Hours__c = udMap.get(theKey).Excluded_MBO_Hours__c;
                    system.debug('----ud.Internal_MBO_Hours__c'+ud.Internal_MBO_Hours__c);
                    system.debug('----ud.Excluded_MBO_Hours__c'+ud.Excluded_MBO_Hours__c);
                }
                //Logic if Project is Excluded MBO
                if(tc.pse__Project__r.MBO_Time_Excluded__c == TRUE) {
                    //Add to what's in the map already
                    ud.Excluded_MBO_Hours__c += tc.pse__Total_Hours__c;
                    //Keep internal the same (is this necessary?)
                    ud.Internal_MBO_Hours__c = udMap.get(theKey).Internal_MBO_Hours__c;
                    system.debug('----ud.Internal_MBO_Hours__c123'+ud.Internal_MBO_Hours__c);
                    system.debug('----ud.Excluded_MBO_Hours__c123'+ud.Excluded_MBO_Hours__c);
                }
                //Update the global map
                udMap.put(theKey, ud);
            }


            else if(udLookup.get(theKey) != null) {
                    //Get the UD record to work with
                    pse__Utilization_Detail__c ud = udLookup.get(theKey);
                    system.debug('----ud123----'+ud.id);
                    //This if Internal MBO
                    if(tc.pse__Project__r.Internal_MBO__c == TRUE) {
                        //Start the total
                        ud.Internal_MBO_Hours__c = tc.pse__Total_Hours__c;
                        //Set excluded to zero
                        ud.Excluded_MBO_Hours__c = 0;

                    system.debug('----ud.Internal_MBO_Hours__c----'+ud.Internal_MBO_Hours__c);
                    system.debug('----ud.Excluded_MBO_Hours__c ----'+ud.Excluded_MBO_Hours__c );
                    }
                    //This if Excluded MBO
                    if(tc.pse__Project__r.MBO_Time_Excluded__c == TRUE) {
                        //Start the total
                        ud.Excluded_MBO_Hours__c = tc.pse__Total_Hours__c;
                        //Set internal to zero
                        ud.Internal_MBO_Hours__c = 0;

                        system.debug('----ud.Internal_MBO_Hours__c-123---'+ud.Internal_MBO_Hours__c);
                        system.debug('----ud.Excluded_MBO_Hours__c 123----'+ud.Excluded_MBO_Hours__c );
                    }
                    //And then we put it in the global map
                    udMap.put(theKey, ud); 
                 system.debug('----100000112222udMap'+udMap);
                }
            
            //Execute Quarter if the global map already has running totals for this resource/month from
            //a previous batch - add values to what's in the global map
            if(udMap.containsKey(theKey2)) {
                system.debug('----1udMap'+udMap); 
                //Get our record to work with
                pse__Utilization_Detail__c ud = udMap.get(theKey2);
                //Logic if Project is Internal MBO
                if(tc.pse__Project__r.Internal_MBO__c == TRUE) {
                    //Add to what's in the map already
                    ud.Internal_MBO_Hours__c += tc.pse__Total_Hours__c;
                    //Keep Excluded the same (is this necessary?)
                    ud.Excluded_MBO_Hours__c = udMap.get(theKey2).Excluded_MBO_Hours__c;
                }
                //Logic if Project is Excluded MBO
                if(tc.pse__Project__r.MBO_Time_Excluded__c == TRUE) {
                    //Add to what's in the map already
                    ud.Excluded_MBO_Hours__c += tc.pse__Total_Hours__c;
                    //Keep internal the same (is this necessary?)
                    ud.Internal_MBO_Hours__c = udMap.get(theKey2).Internal_MBO_Hours__c;
                }
                //Update the global map
                udMap.put(theKey2, ud);
                system.debug('----11udMap'+udMap);  
            }
             else if(udLookup.get(theKey2) != null) {
                    //Get the UD record to work with
                    pse__Utilization_Detail__c ud = udLookup.get(theKey2);
                    //This if Internal MBO
                    if(tc.pse__Project__r.Internal_MBO__c == TRUE) {
                        //Start the total
                        ud.Internal_MBO_Hours__c = tc.pse__Total_Hours__c;
                        //Set excluded to zero
                        ud.Excluded_MBO_Hours__c = 0;
                    }
                    //This if Excluded MBO
                    if(tc.pse__Project__r.MBO_Time_Excluded__c == TRUE) {
                        //Start the total
                        ud.Excluded_MBO_Hours__c = tc.pse__Total_Hours__c;
                        //Set internal to zero
                        ud.Internal_MBO_Hours__c = 0;
                    }
                    //And then we put it in the global map
                    udMap.put(theKey2, ud);
                     system.debug('----1112222udMap'+udMap);
                    
                }
            //Execute Year if the global map already has running totals for this resource/month from
            //a previous batch - add values to what's in the global map
            if(udMap.containsKey(theKey3)) {
                system.debug('----3311udMap'+udMap);
                //Get our record to work with
                pse__Utilization_Detail__c ud = udMap.get(theKey3);
                //Logic if Project is Internal MBO
                if(tc.pse__Project__r.Internal_MBO__c == TRUE) {
                    //Add to what's in the map already
                    ud.Internal_MBO_Hours__c += tc.pse__Total_Hours__c;
                    //Keep Excluded the same (is this necessary?)
                    ud.Excluded_MBO_Hours__c = udMap.get(theKey3).Excluded_MBO_Hours__c;
                }
                //Logic if Project is Excluded MBO
                if(tc.pse__Project__r.MBO_Time_Excluded__c == TRUE) {
                    //Add to what's in the map already
                    ud.Excluded_MBO_Hours__c += tc.pse__Total_Hours__c;
                    //Keep internal the same (is this necessary?)
                    ud.Internal_MBO_Hours__c = udMap.get(theKey3).Internal_MBO_Hours__c;
                }
                //Update the global map
                udMap.put(theKey3, ud);
                system.debug('----33udMap'+udMap);
            }
           
                else if(udLookup.get(theKey3) != null) {
                    //Get the UD record to work with
                    pse__Utilization_Detail__c ud = udLookup.get(theKey3);
                    //This if Internal MBO
                    if(tc.pse__Project__r.Internal_MBO__c == TRUE) {
                        //Start the total
                        ud.Internal_MBO_Hours__c = tc.pse__Total_Hours__c;
                        //Set excluded to zero
                        ud.Excluded_MBO_Hours__c = 0;
                    }
                    //This if Excluded MBO
                    if(tc.pse__Project__r.MBO_Time_Excluded__c == TRUE) {
                        //Start the total
                        ud.Excluded_MBO_Hours__c = tc.pse__Total_Hours__c;
                        //Set internal to zero
                        ud.Internal_MBO_Hours__c = 0;
                    }
                    //And then we put it in the global map
                    udMap.put(theKey3, ud);
                    system.debug('----111133udMap'+udMap);
                }   
            
        }            
    }
    
    
    //Finish method; this is where we actually update the UD records. 
    global void finish(Database.BatchableContext BC) {
        //Debugging the hours for all the resources in this job.
        //This debug doesn't need to go live, but it is good troubleshooting info
        for(pse__Utilization_Detail__c ud : udMap.values()) {
            system.debug('*************RESOURCE: ' + ud.pse__Resource__r.FirstName + ' ' + ud.pse__Resource__r.LastName + 
                         ' || ' + 'EXCLUDED HRS: ' + ud.Excluded_MBO_Hours__c + ' || ' + 'INTERNAL HRS: ' + ud.Internal_MBO_Hours__c);
        }
        //Let's update the Utilization Detail records now :-)
        update udMap.values();        
        AsyncApexJob job = [SELECT Status, NumberOfErrors, JobItemsProcessed FROM AsyncApexJob WHERE Id =:BC.getJobId()];
        //Send Developer an email if it broke (Cvent CRM Team - feel free to change email address to you once live)
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[]{'ff_admin@cvent.com'});
        email.setSubject('PSA_MBOcalculationsBatch ' + job.Status);
        email.setPlainTextBody(job.JobItemsProcessed + ' records were processed with ' + job.NumberOfErrors + ' failures.');
        if(job.NumberOfErrors > 0) Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
    }
    

}