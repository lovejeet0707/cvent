@IsTest
public class PreChatFormControllerTest
{
    static testMethod void myUnitTestFirst()
    {
        Account instofAcc = TestUtil.createAccount('Test Account','Biz_Ac');
        instofAcc.Cvent_Account_ID__c = 'NBAK12';
        insert instofAcc;
        Contact instOfCon = TestUtil.createContact(String.valueOf(instofAcc.Id));
        instOfCon.Phone = '1241142534';
        insert instOfCon;
        
        User instUsr = TestUtil.CreateDeploymentUser();
        instUsr.Account_ID__c = instofAcc.Id;
        instUsr.Contact_ID__c = instOfCon.Id;
        insert instUsr;
        
        system.runAs(instUsr)
        {
            PreChatFormController pre = new PreChatFormController();
        }
    }

}