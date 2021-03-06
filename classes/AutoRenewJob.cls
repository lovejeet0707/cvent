/**
 * Created by Ed Harrold on 8/19/2017.
 * Used by Apex Scheduled Job to launch AutoRenewContractSchedulable
 * (AutoRenewContractSchedulable has abort so it cannot be scheduled directly)
 */

global without sharing class AutoRenewJob implements Schedulable{
    global void execute(SchedulableContext sc) {
        DateTime future = System.now().addSeconds(5);
        Integer year = future.year();
        Integer month = future.month();
        Integer day = future.day();
        Integer hour = future.hour();
        Integer minute = future.minute();
        Integer second = future.second();
        String strJobName = 'AutoRenew-' + second + '_' + minute + '_' + hour + '_' + day + '_' + month + '_' + year;
        String strSchedule = second + ' ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
        System.schedule(strJobName, strSchedule, new AutoRenewContractSchedulable());
    }
}