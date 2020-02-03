@isTest

private class CventMyd_RenewalChainMonitor_Test {

    public static testMethod void testRenewalChainMonitor0() {

        CpqAudit__c chainMaster = new CpqAudit__c(isChainMaster__c = true,jobsInChain__c = 0);

        insert chainMaster;

        String jobName = 'My nice job name';

        CventMyd_RenewalChainMonitor renewalChainMonitor = new CventMyd_RenewalChainMonitor(jobName,chainMaster.Id,true);

        String cronString = '0 0 23 * * ?';

        Test.startTest();

        System.schedule(jobName, cronString, renewalChainMonitor);

        Test.stopTest();

    }	

    public static testMethod void testRenewalChainMonitor1() {

        CpqAudit__c chainMaster = new CpqAudit__c(isChainMaster__c = true,jobsInChain__c = 1,chainFinished__c=true);

        insert chainMaster;

        String jobName = 'My nice job name';

        CventMyd_RenewalChainMonitor renewalChainMonitor = new CventMyd_RenewalChainMonitor(jobName,chainMaster.Id,false);

        String cronString = '0 0 23 * * ?';

        Test.startTest();

        System.schedule(jobName, cronString, renewalChainMonitor);

        Test.stopTest();

    }

}