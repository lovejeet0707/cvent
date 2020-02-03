/****************************************************************************************
Name            : PSA_createCreditedTCsSchedule
Author          : Andy Heidrich (aheidrich@topstepconsulting.com)
Created Date    : June 9, 2017
Description     : Schedule class for PSA_createCreditedTCsBatch

NOTE TO SCHEDULE THE CREDITED TIMECARD PROCESS RUN A SCRIPT LIKE THIS IN THE SYSTEM CONSOLE:

String seconds = '0'; //Execute at Zero Seconds
String minutes = '0'; //Execute at top of every hour (:00 minute)
String hours = '1'; // Execute at 1:00am
String month = '*'; //Execute every month
String dayOfWeek = '?'; //Execute every day (use ? for every day)
String year = '*'; //Execute every year
String sch = seconds + ' ' + minutes + ' ' + hours + ' * ' + month + ' ' + dayOfWeek + year;
PSA_createCreditedTCsSchedule ctc = new PSA_createCreditedTCsSchedule();
system.schedule('PSA Credit Onsite Hrs Over 8', sch, ctc);

******************************************************************************************/

global class PSA_createCreditedTCsSchedule implements schedulable {
    
    global void execute (SchedulableContext sc) {
        
        integer BATCH_SIZE = 40;
        PSA_createCreditedTCsBatch tcb = new PSA_createCreditedTCsBatch();
        system.debug('**** PSA_createCreditedTCsBatch: starting batch exection*****************');
        Id batchId = database.executeBatch(tcb, BATCH_SIZE);    
        
        system.debug('**** PSA_createCreditedTCsBatch: Batch executed batchId: ' +batchId);                 
    }
}