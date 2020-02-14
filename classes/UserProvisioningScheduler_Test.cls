@isTest(seeAllData = false)
public class UserProvisioningScheduler_Test {
    @isTest
    public static void schedulerTest(){
        UserProvisioningScheduler schInstance = new UserProvisioningScheduler();
        schInstance.execute(null);
    }
}