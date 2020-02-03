/****************************************************************************************
Name            : PSA_MBOcalculationsSchedule
Author          : Andy Heidrich (aheidrich@topstepconsulting.com)
Created Date    : June 9, 2017
Description     : Schedule class for PSA_MBOcalculationsBatch

NOTE TO SCHEDULE THE MBO CALCULATION PROCESS RUN A SCRIPT LIKE THIS IN THE SYSTEM CONSOLE:

String seconds = '0'; //Execute at Zero Seconds
String minutes = '0'; //Execute at top of every hour (:00 minute)
String hours = '1'; // Execute at 1:00am
String month = '*'; //Execute every month
String dayOfWeek = '4'; //Execute every Wednesday (use ? for every day)
String year = '*'; //Execute every year
String sch = seconds + ' ' + minutes + ' ' + hours + ' * ' + month + ' ' + dayOfWeek + year;
PSA_MBOcalculationsSchedule mbo = new PSA_MBOcalculationsSchedule();
system.schedule('PSA MBO Calculations', sch, mbo);

******************************************************************************************/

global class PSA_MBOcalculationsSchedule implements schedulable {
    
    global void execute (SchedulableContext sc) {
        
        PSA_MBOcalculationsBatch mboc = new PSA_MBOcalculationsBatch();
        system.debug('**** PSA_MBOcalculationsBatch: starting batch exection*****************');
        Id batchId = database.executeBatch(mboc);    
        
        system.debug('**** PSA_MBOcalculationsBatch: Batch executed batchId: ' +batchId); 
        
    }
}