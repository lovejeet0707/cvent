/****************************************************************************************
Name            : PSA_updateProjectHealthSchedule
Author          : Andy Heidrich (aheidrich@topstepconsulting.com)
Created Date    : July 13, 2017
Description     : Schedule class for PSA_createCreditedTCsBatch

NOTE TO SCHEDULE THE PROJECT HEALTH PROCESS RUN A SCRIPT LIKE THIS IN THE SYSTEM CONSOLE:

String seconds = '0'; //Execute at Zero Seconds
String minutes = '0'; //Execute at top of every hour (:00 minute)
String hours = '1'; // Execute at 1:00am
String month = '*'; //Execute every month
String dayOfWeek = '?'; //Execute every day (use ? for every day)
String year = '*'; //Execute every year
String sch = seconds + ' ' + minutes + ' ' + hours + ' * ' + month + ' ' + dayOfWeek + year;
PSA_updateProjectHealthSchedule phs = new PSA_createCreditedTCsSchedule();
system.schedule('PSA Update Project Health', sch, phs);

******************************************************************************************/

global class PSA_updateProjectHealthSchedule implements schedulable {
    
    global void execute (SchedulableContext sc) {
        
        integer BATCH_SIZE = 100;
        PSA_updateProjectHealthBatch phb = new PSA_updateProjectHealthBatch();
        system.debug('**** PSA_updateProjectHealthBatch: starting batch exection*****************');
        Id batchId = database.executeBatch(phb, BATCH_SIZE);    
        
        system.debug('**** PSA_updateProjectHealthBatch: Batch executed batchId: ' +batchId);                 
    }
}