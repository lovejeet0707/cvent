/****************************************************************************************
Name            : PSA_TimecardSplitTriggerHandler
Author(s)       : TOP Step Consulting - Andy Heidrich (aheidrich@topstepconsulting.com)
				:
Created Date    : 
Description     : Contains methods called from Triggers on the Timecard Split object. All
				: Timecard Split trigger code should go in this class.  Each method
				: has its description listed at the beginning of the method.
Changelog		: 7-10-2017 Modified to also populate Quarter and Yearly Time Period fields - AH
******************************************************************************************/
public class PSA_timecardSplitTriggerHandler {
    
    //This method is called in a before insert/update context.  It populates
    //the Monthly Time Period related to a particular Timecard Split
    //in a lookup field on the Timecard Split record.  This method supports
    //the ability to calculate MBO Utilization because we need the relevant 
    //Time Periods on the Timecard Splits for our MBO batch job to work.
    public static void populateTimePeriod(list<pse__Timecard__c> tcList) {
        
        if(PSA_Utils.isTriggerDisabled('populateTimePeriod')) { return; }
        
        //Create a list of dates
        list<date> dateList = new list<date>();
        
        //Loop through Timecard Splits in this batch and add the 
        //start date of each Timecard Split to the date list if the Timecard
        //is on an Internal MBO or MBO Excluded Project
        for(pse__Timecard__c tc : tcList) {
            if(tc.MBO__c == TRUE) {
              dateList.add(tc.pse__Start_Date__c);  
            }   
        }
        
        //Proceed only if there are MBO Timecards
        if(!dateList.isEmpty()) {
            //Sort the date list
            datelist.sort();
            //Get the date of the first day of the month of the earliest TC split start date
            date minDate = date.newInstance(datelist.get(0).year(),1,1);
            //Get the date of the first day of the month of the latest TC split start date
            date maxDate = datelist.get(datelist.size()-1).toStartOfMonth();
            
            //Create maps to hold the Time Period records we need
            //Key will be Start Date
            map<date,pse__Time_Period__c>tpMonthMap = new map<date,pse__Time_Period__c>();
            map<date,pse__Time_Period__c>tpQtrMap = new map<date,pse__Time_Period__c>();
            map<date,pse__Time_Period__c>tpYrMap = new map<date,pse__Time_Period__c>();
            
            //Loop through Time Periods between minDate and maxDate
            for(pse__Time_Period__c tp : [SELECT Id, pse__Type__c, pse__Start_Date__c
                                          FROM pse__Time_Period__c
                                          WHERE pse__Start_Date__c >= : minDate
                                          AND pse__Start_Date__c <= : maxDate
                                          AND (pse__Type__c = 'Month' OR
                                               pse__Type__c = 'Quarter' OR
                                               pse__Type__c = 'Year')])
            {
                //Put Time Periods in the maps with start date as key
                //We'll use this to match Timecards with Time Periods
                if(tp.pse__Type__c == 'Month') {
                    tpMonthMap.put(tp.pse__Start_Date__c,tp);
                }
                if(tp.pse__Type__c == 'Quarter') {
                    tpQtrMap.put(tp.pse__Start_Date__c,tp);
                }
                if(tp.pse__Type__c == 'Year') {
                    tpYrMap.put(tp.pse__Start_Date__c,tp);
                }
            }
            
            
            //Loop through the Timecards to do the work
            for(pse__Timecard__c tc : tcList) {
                //Don't bother touching them if they're not MBO; save the CPU time
                if(tc.MBO__c == TRUE) {
                    //Declare variable for year start, get TPs from maps and populate.
                    date yrStart = date.newInstance(tc.pse__Start_Date__c.year(), 1, 1);
                    system.debug('Month: ' + tc.pse__Start_Date__c.toStartofMonth());
                    system.debug('Quarter: ' + tc.Current_Qtr_Start_Date__c);
                    system.debug('Year: ' + yrStart);
                    tc.Time_Period__c = tpMonthMap.get(tc.pse__Start_Date__c.toStartofMonth()).Id;
                    tc.Time_Period_Quarter__c = tpQtrMap.get(tc.Current_Qtr_Start_Date__c).Id;
                    tc.Time_Period_Year__c = tpYrMap.get(yrStart).Id;
                    system.debug('TPs successfully set');
                }
            }
        }   
    }
}