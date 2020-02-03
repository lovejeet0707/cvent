/*
//////////////////////////////////////
//      @author Abhishek Pandey     //
/////////////////////////////////////
Version :   1.0
Date : 1st Oct 2014
Description : Tests federationIdPageCls 
*/
@isTest
private class FederationIdPageClsTest {

    static testMethod void myUnitTest() {
        federationIdPageCls instOfFed = new federationIdPageCls();
        federationIdPageCls.fedIdStr ='Test';
        instOfFed.search(); 
    }
}