@isTest
public with sharing class Test_CustomRelatedListForOpenCasesCtrl 
{
    static testmethod void CustomRelatedListMethod()
    {
        Account instofAcc=TestUtil.createAccount('Test Account','Biz_Ac');
        instofAcc.BillingCountryCode = 'US';
        instOfAcc.BillingStateCode = 'TX';
        insert instofAcc;

        Contact instofCon=TestUtil.createContact(instofAcc.id);
        instOfCon.Email = 'Test987654321@test.com';
        instOfCon.Phone = '8877665544';
        insert instofCon;

        List <Contact> listOfContact = new List<Contact>();
        listOfContact.add(instofCon);

        Test.startTest();
        // Create a reference to the VF page
        PageReference pageRef = Page.CustomRelatedListForOpenCasesVF;
        // Add required parameters.
        pageRef.getParameters().put('Id', instofCon.Id);
        Test.setCurrentPageReference(pageRef);

        //Test.setCurrentPage(Page.CustomRelatedListForOpenCasesVF);
        ApexPages.StandardController conStandard = new ApexPages.StandardController(instofCon);
        CustomRelatedListForOpenCasesCtrl ext = new CustomRelatedListForOpenCasesCtrl(conStandard);
        
        //OpenCasesOnAccountCtrl
        // Create a reference to the VF page
        PageReference pageRef1 = Page.OpenCasesOnAccount;
        // Add required parameters.
        pageRef.getParameters().put('Id', instofAcc.Id);
        Test.setCurrentPageReference(pageRef);

        //Test.setCurrentPage(Page.CustomRelatedListForOpenCasesVF);
        ApexPages.StandardController accStandard = new ApexPages.StandardController(instofAcc);
        OpenCasesOnAccountCtrl ext1 = new OpenCasesOnAccountCtrl(accStandard);
        Test.stopTest();
    }
}