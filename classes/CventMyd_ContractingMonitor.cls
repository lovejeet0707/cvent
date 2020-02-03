global without sharing class CventMyd_ContractingMonitor implements Schedulable {

    global Set<Id> opportunityIds;

    global class Settings {

        global Time timeToRunContractedMonitoring;

        global Decimal hoursToCheckContractedMonitoring;

        global Boolean createRecordsForSuccesses;

        global List<String> additionalEmails;

    }

    global static Settings settings = CventMyd_Settings.contractingMonitorSettings;

    global CventMyd_ContractingMonitor(Set<Id> opportunityIds) {

        this.opportunityIds = opportunityIds;

    }

    global void execute(SchedulableContext sc) {

        CventMyd_ContractingMonitorHandler.generateReport(this.opportunityIds);

        if(!Test.isRunningTest()) {

            CventMyd_ContractingMonitorHandler.scheduleNextContractingMonitor(false, null);

        }

        System.abortJob(sc.getTriggerId());

    }

}