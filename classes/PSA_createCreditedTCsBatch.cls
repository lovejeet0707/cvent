/****************************************************************************************
Name            : PSA_createCreditedTCsBatch
Author          : TOP Step Consulting - Andy Heidrich (aheidrich@topstepconsulting.com)
Created Date    : 
Description     : Here we are getting Timecards that are billed at a Daily Rate and Approved, 
                : but have not yet been processed by this code.  We are going to take any 
                : time over X* hours in any individual day from a Timecard Row and shave it 
                : off into a new Credited Timecard that is related to the Billable Timecard.  
                : We are going to move the notes for those days as well.  This lets us
                : track billable vs. productive utilization for Events onsites.
                : *X = the number of hours set in a custom setting
******************************************************************************************/

global class PSA_createCreditedTCsBatch implements Database.Batchable<sObject> {
    
    //Batch start method, define scope query
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, pse__Resource__c, pse__Assignment__c, CurrencyIsoCode, ' +
                        'pse__Project__c, pse__Milestone__c, pse__Total_Hours__c, ' +
                        'pse__Monday_Hours__c, pse__Tuesday_Hours__c, pse__Wednesday_Hours__c, ' +
                        'pse__Thursday_Hours__c, pse__Friday_Hours__c, pse__Saturday_Hours__c, ' +
                        'pse__Sunday_Hours__c, pse__Monday_Notes__c, pse__Tuesday_Notes__c, ' +
                        'pse__Wednesday_Notes__c, pse__Thursday_Notes__c, pse__Friday_Notes__c, ' +
                        'pse__Saturday_Notes__c, pse__Sunday_Notes__c, pse__Bill_Rate__c, pse__Daily_Bill_Rate__c, ' +
                        'pse__Start_Date__c, pse__Billable__c,' +
                        'pse__Project__r.pse__Group__c, pse__End_Date__c, pse__Status__c, pse__Cost_Rate_Amount__c ' +
                        'FROM pse__Timecard_Header__c ' +
                        'WHERE pse__Billable__c = TRUE AND pse__Daily_Bill_Rate__c = TRUE ' +
                        'AND pse__Approved__c = TRUE AND Time_Credit_Applied__c = FALSE ' +
                        'ORDER BY pse__Assignment__c';
        return Database.getQueryLocator(query);
    }
    
    //Batch execute method begin
    global void execute(Database.BatchableContext BC, List<pse__Timecard_Header__c> scope) {
        
             
        //Get the values of our Custom Setting. The default hours level for the org,
        //and any override levels for specific groups.  The Ids of those groups as well.
        //To do: These should all be made global as they won't change between batches
        PSA_Daily_Rate_Utilization_Settings__c groups = PSA_Daily_Rate_Utilization_Settings__c.getValues('Default');
        double owd = groups.Org_Default__c;
        double g1hrs = groups.Group_1_Override__c;
        double g2hrs = groups.Group_2_Override__c;
        id g1Id;
        id g2Id;
        if(groups.Group_1_ID__c != null) {
              g1Id = id.valueOf(groups.Group_1_ID__c);
        }
        if(groups.Group_2_ID__c != null) {
              g2Id = id.valueOf(groups.Group_2_ID__c);
        }
        
        //Declare lists - Insert for Credited Timecards, Update for Billable Timecards
        list<pse__Timecard_Header__c> tcInsert = new list<pse__Timecard_Header__c>();
        list<pse__Timecard_Header__c> tcUpdate = new list<pse__Timecard_Header__c>();
        
        //Loop through the Timecards in this batch
        for(pse__Timecard_Header__c tc : scope) {
            //Redundancy from scope query
            if(tc.pse__Billable__c == TRUE && tc.pse__Daily_Bill_Rate__c == TRUE) {
                
                //initialize variables:
                //the # of hrs to credit once over for a single day
                double hrsAmt = owd;
                //The number of hours for each day
                double sat = 0;
                double sun = 0;
                double mon = 0;
                double tue = 0;
                double wed = 0;
                double thu = 0;
                double fri = 0;
                //Flag for whether or not to do updates
                boolean doUpdate = FALSE;
                //The notes for each day
                string satNotes = null;
                string sunNotes = null;
                string monNotes = null;
                string tueNotes = null;
                string wedNotes = null;
                string thuNotes = null;
                string friNotes = null;
                
                //If this Timecard Project is in a group with an override
                //to the default # of hours over which to credit (via Custom
                //Setting), set that amount accordingly (applies to both ifs below)
                if(tc.pse__Project__r.pse__Group__c == g1Id) {
                    hrsAmt = g1hrs;
                }
                if(tc.pse__Project__r.pse__Group__c == g2Id) {
                    hrsAmt = g2hrs;
                }
              
                
                //In this section we go through the days, and if any individual day breaks the cap, we set
                //the source TC hours to the max for a day, and store the extra hours in a variable
                //for Credited TC creation. Then we set update flag and move on to the next day and repeat.
                
                //Saturday
                if(tc.pse__Saturday_Hours__c > hrsAmt) {
                    doUpdate = TRUE;
                    sat = tc.pse__Saturday_Hours__c - hrsAmt;
                    tc.pse__Saturday_Hours__c = hrsAmt;
                    satNotes = 'Credited overage hours - see related billable timecard';
                }
                //Sunday
                if(tc.pse__Sunday_Hours__c > hrsAmt) {
                    doUpdate = TRUE;
                    sun = tc.pse__Sunday_Hours__c - hrsAmt;
                    tc.pse__Sunday_Hours__c = hrsAmt;
                    sunNotes = 'Credited overage hours - see related billable timecard';
                }
                //Monday
                if(tc.pse__Monday_Hours__c > hrsAmt) {
                    doUpdate = TRUE;
                    mon = tc.pse__Monday_Hours__c - hrsAmt;
                    tc.pse__Monday_Hours__c = hrsAmt;
                    monNotes = 'Credited overage hours - see related billable timecard';
                }
                //Tuesday
                if(tc.pse__Tuesday_Hours__c > hrsAmt) {
                    doUpdate = TRUE;
                    tue = tc.pse__Tuesday_Hours__c - hrsAmt;
                    tc.pse__Tuesday_Hours__c = hrsAmt;
                    tueNotes = 'Credited overage hours - see related billable timecard';
                }
                //Wednesday
                if(tc.pse__Wednesday_Hours__c > hrsAmt) {
                    doUpdate = TRUE;
                    wed = tc.pse__Wednesday_Hours__c - hrsAmt;
                    tc.pse__Wednesday_Hours__c = hrsAmt;
                    wedNotes = 'Credited overage hours - see related billable timecard';
                }
                //Thursday
                if(tc.pse__Thursday_Hours__c > hrsAmt) {
                    doUpdate = TRUE;
                    thu = tc.pse__Thursday_Hours__c - hrsAmt;
                    tc.pse__Thursday_Hours__c = hrsAmt;
                    thuNotes = 'Credited overage hours - see related billable timecard';
                }
                //Friday
                if(tc.pse__Friday_Hours__c > hrsAmt) {
                    doUpdate = TRUE;
                    fri = tc.pse__Friday_Hours__c - hrsAmt;
                    tc.pse__Friday_Hours__c = hrsAmt;
                    friNotes = 'Credited overage hours - see related billable timecard';
                }
                
                //Now if any of the days were over (update flag is TRUE), let's make it happen:
                //Set remaining fields on billable TC and add it to update list.  Set necessary
                //fields on Credited TC and add it to Insert list.
                if(doUpdate == TRUE) {
                    //Source TC stuff
                    tc.Time_Credit_Applied__c = TRUE;
                    tc.pse__Admin_Global_Edit__c = TRUE;
                    tc.pse__Audit_Notes__c = 'Time moved to credited timecard.';
                    tcUpdate.add(tc);
                    
                    //And here's our credited TC
                    pse__Timecard_Header__c tcIns = new pse__Timecard_Header__c
                    (pse__Project__c = tc.pse__Project__c, pse__Resource__c = tc.pse__Resource__c, pse__Assignment__c = tc.pse__Assignment__c,
                     pse__Start_Date__c = tc.pse__Start_Date__c, pse__End_Date__c = tc.pse__End_Date__c, pse__Milestone__c = tc.pse__Milestone__c,
                     pse__Status__c = tc.pse__Status__c, pse__Approved__c = TRUE, pse__Submitted__c = TRUE, pse__Include_in_Financials__c = TRUE,
                     Related_Billable_Timecard__c = tc.Id, pse__Monday_Hours__c = mon, pse__Monday_Notes__c = monNotes,
                     pse__Tuesday_Hours__c = tue, pse__Tuesday_Notes__c = tueNotes, pse__Wednesday_Hours__c = wed,
                     pse__Wednesday_Notes__c = wedNotes, pse__Thursday_Hours__c = thu,
                     pse__Thursday_Notes__c = thuNotes, pse__Friday_Hours__c = fri, pse__Friday_Notes__c = friNotes,
                     pse__Saturday_Hours__c = sat, pse__Saturday_Notes__c = satNotes, pse__Sunday_Hours__c = sun, pse__Sunday_Notes__c = sunNotes,
                     pse__Time_Credited__c = TRUE, pse__Billable__c = FALSE, pse__Bill_Rate__c = 0);
                
                    tcInsert.add(tcIns);   
                } 
            }
        }
        
        //Insert if we have TCs to insert
        if(!tcInsert.isEmpty()) {
            insert tcInsert;
            //This part is due to an annoying FF behavior, but Time Credited
            //WILL NOT SAVE on these TCs after the initial insert - FF unsets it.
            //We have to do a second loop through the inserted list and re-set Time Credited...
            for (pse__Timecard_Header__c tc : tcInsert) {
                
                tc.pse__Time_Credited__c = TRUE;
                tc.pse__Bill_Rate__c = 0;
            }
            //...and then update the insert to fix Time Credited
            update tcInsert;
            
            //Now update the source TCs
            update tcUpdate;
        }
    }
    
    //Required finish method.
    global void finish(Database.BatchableContext BC) {
        AsyncApexJob job = [SELECT Status, NumberOfErrors, JobItemsProcessed FROM AsyncApexJob WHERE Id =:BC.getJobId()];
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[]{'ff_admin@cvent.com'});
        email.setSubject('PSA_CreditedBatch ' + job.Status);
        email.setPlainTextBody(job.JobItemsProcessed + ' records were processed with ' + job.NumberOfErrors + ' failures.');
        if(job.NumberOfErrors > 0) Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
    }

}