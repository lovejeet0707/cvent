/*
* Update by Tim 06.08.17
*
* Note: AutoRenewContracts batchable removed
*
* 06.08.17 : Ed Harrold : Deploy updated schedulable code removing batch method
* 07.14.17 : Ed Harrold : Debugging due to huge number of scheduled jobs - found over 9,0000
*                         in the system
* 07.15.17 : Ed Harrold : Update to handle apparent overrun of scheduled tasks and failed renewals
*                         extending to 60 seconds or longer
* 08.18.17 : Ed Harrold : Added abort job and debug output for troubleshooting contracts that don't renew
* 08.19.17 : Ed Harrold : Add code coverage of exception path
* 
*/
global without sharing class AutoRenewContractSchedulable implements Schedulable {

    static Final Integer SECONDSTONEXTSCHEDULE = 60;

    global void execute(SchedulableContext sc) {
        /*AutoRenewContracts b = new AutoRenewContracts();
        database.executeBatch(b, 1);*/
        Date dt = System.Today();
        System.debug('AutoRenewContractSchedulable: '+dt);

        List<Database.SaveResult> updateResult;
        String query = 'SELECT Id FROM Contract WHERE SBQQ__RenewalQuoted__c = false AND Renewal_Creation_Date__c <=: dt AND RecordType.DeveloperName = \'Subscription_Agreement\' AND Failed_Auto_Renew__c = false LIMIT 1';
        List<Contract> scope = database.query(query);
        System.debug('AutoRenewContractSchedulable: Items to schedule count: '+scope.size());
        for(Integer i=0; i<scope.size(); i++) {
            scope[i].SBQQ__RenewalQuoted__c = true;
            System.debug('AutoRenewContractSchedulable: set SBQQ__RenewalQuoted__c true');
        }
        try {
            if (scope.size() > 0) {
                System.debug('AutoRenewContractSchedulable: updating: '+scope);
                update scope;
            }
            //added for code coverage of exception path
            if (Test.isRunningTest()){
                throw new autorenewException();
            }
        } catch (exception e) {
            System.debug('AutoRenewContractSchedulable: 1st Exception on update scope: line: '+e.getLineNumber()+' message:'+e.getMessage());
            try{
                scope[0].SBQQ__RenewalQuoted__c = false;
                scope[0].Failed_Auto_Renew__c = true;
                scope[0].Failed_Auto_Renew_Message__c = 'AutoRenewContractSchedulable: 1st Exception on update scope: line: '+e.getLineNumber()+' message:'+e.getMessage();
                update scope;

            }catch(exception e1){
                System.debug('AutoRenewContractSchedulable: 2nd Exception on update scope: line: '+e1.getLineNumber()+' message:'+e1.getMessage());

            }
        }

        //any remaining items?
        List<Contract> cList = database.query(query);
        // move items out for unit testing
        DateTime future = system.now().addSeconds(SECONDSTONEXTSCHEDULE);
        Integer year = future.year();
        Integer month = future.month();
        Integer day = future.day();
        Integer hour = future.hour();
        Integer minute = future.minute();
        Integer second = future.second();
        String strJobName = 'AutoRenew-' + second + '_' + minute + '_' + hour + '_' + day + '_' + month + '_' + year;
        String strSchedule = second + ' ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
        if(!cList.isEmpty()) {
            System.debug('AutoRenewContractSchedulable: Items to schedule count: '+cList.size());
            System.schedule(strJobName, strSchedule, new AutoRenewContractSchedulable());
        }
        System.abortJob(sc.getTriggerId());
    }
    //added for code coverage of exception path
    public class autorenewException extends Exception {}
}