/**
 * @File Name          : TestSchedule_EBSBObject_SendWeeklyAlerts.cls
 * @Description        : 
 * @Author             : Nishant Goswami
 * @Group              : 
 * @Last Modified By   : Nishant Goswami
 * @Last Modified On   : 25/12/2019, 4:35:02 pm
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    25/12/2019   Nishant Goswami     Initial Version
**/
@isTest
private class TestSchedule_EBSBObject_SendWeeklyAlerts{

	public static testMethod void testschedule() {
		Test.StartTest();
		Schedule_EBSBObject_SendWeeklyAlerts testsche = new Schedule_EBSBObject_SendWeeklyAlerts();
		String sch = '0 0 23 * * ?';
		system.schedule('Test status Check', sch, testsche );
		Test.stopTest();
	}

}