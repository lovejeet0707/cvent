/**********************************************************
* Class Name: CventSurveyWebservice_TestClass
* Author: Rishi Ojha
* Date: 11-05-2014 
* Description: Test Class for   Cevent_WebService_Utility,Cevent_WebService_Helper 
* Version : 2.0
* Description : Additional survey classes
***********************************************************/

@isTest 
private class CventSurveyWebservice_TestClass{    
    Static testMethod void ValidateCventSurveyWebservice() {
        Cevent_WebService_Helper testObject= new Cevent_WebService_Helper();
        /*Testing for  Login Call*/
        
        //Generating Request        
        Map<string,string>LoginRequestMap=new Map<string,string>();
        LoginRequestMap.put('Account','CSSATVA99');
        LoginRequestMap.put('UserName','CSSATVA99Api');
        LoginRequestMap.put('Password','9lTd55BM7YX');
        
        //Testing for Login Request Positive        
        StaticResourceCalloutMock loginPositive= new StaticResourceCalloutMock();
        loginPositive.setStaticResource('CventSurveyWebservice_Mock_Response_Login');
        loginPositive.setStatusCode(200);
        loginPositive.setHeader('Content-Type', 'text/XML'); 
        Test.setMock(HttpCalloutMock.class,loginPositive); 
        testobject.loginRequest(LoginRequestMap,40000);
        
        //Testing for Login Request Negative
        
        StaticResourceCalloutMock loginNegative= new StaticResourceCalloutMock();
        loginNegative.setStaticResource('CventSurveyWebservice_Mock_Response_NagativeTest');
        loginNegative.setStatusCode(500);
        loginNegative.setHeader('Content-Type', 'text/XML'); 
        Test.setMock(HttpCalloutMock.class, loginNegative);             
        testobject.loginRequest(LoginRequestMap,40000);
        
        /*Testing for  Search*/
        
        //Generating Request        
        Map<string,string>SearchRequestMap=new Map<string,string>();
        
        SearchRequestMap.put('SessionID','uuuuuuuuu');
        SearchRequestMap.put('SurveyID','0C999AD8-12DD-4212-ABBB-F79F4A2C742C');
       // SearchRequestMap.put('SurveyID','3ACC67F1-26F1-4B8C-AC39-77FCE78B12A2');
        Date DateToday = date.today()-1;
        string dateValue=String.valueOf(DateToday);
        System.debug('date===>'+dateValue);
        SearchRequestMap.put('Date',dateValue);
        
        //Testing for  Positive Test        
        StaticResourceCalloutMock SearchPositive= new StaticResourceCalloutMock();
        SearchPositive.setStaticResource('CventSurveyWebservice_Mock_Response_Search');
        SearchPositive.setStatusCode(200);
        SearchPositive.setHeader('Content-Type','text/XML'); 
        Test.setMock(HttpCalloutMock.class,SearchPositive); 
        testobject.Search(SearchRequestMap,40000);
        
        //Testing for  Negative        
        StaticResourceCalloutMock SearchNegative= new StaticResourceCalloutMock();
        SearchNegative.setStaticResource('CventSurveyWebservice_Mock_Response_NagativeTest');
        SearchNegative.setStatusCode(500);
        SearchNegative.setHeader('Content-Type', 'text/XML'); 
        Test.setMock(HttpCalloutMock.class, SearchNegative);             
        testobject.Search(SearchRequestMap,40000);
        
        /*Testing for  Retrieve*/    
        
        //Generating Request        
        Map<string,string>SurveyRequestMap=new Map<string,string>();
        Set<String>surveyIds=new Set<String>();     
        SurveyRequestMap.put('SessionID','uuuuuuuuu');
        SurveyRequestMap.put('SurveyID','0C999AD8-12DD-4212-ABBB-F79F4A2C742C');
        surveyIds.add('12347');
        
        //Testing for  Positive Test        
        StaticResourceCalloutMock retrievePositive= new StaticResourceCalloutMock();
        retrievePositive.setStaticResource('CventSurveyWebservice_Mock_Response_Search');
        retrievePositive.setStatusCode(200);
        retrievePositive.setHeader('Content-Type','text/XML'); 
        Test.setMock(HttpCalloutMock.class,retrievePositive); 
        testobject.retriveSurvey(SurveyRequestMap,surveyIds,40000);
        
        //Testing for  Negative        
        StaticResourceCalloutMock retrieveNegative= new StaticResourceCalloutMock();
        retrieveNegative.setStaticResource('CventSurveyWebservice_Mock_Response_NagativeTest');
        retrieveNegative.setStatusCode(500);
        retrieveNegative.setHeader('Content-Type', 'text/XML'); 
        Test.setMock(HttpCalloutMock.class, retrieveNegative);             
        testobject.retriveSurvey(SurveyRequestMap,surveyIds,40000);
        
        /**********************************************************************/    
        system.debug('SurveyRequestMapInquisiumToSalesforceEmailParser - START');
        Map<string,string> SurveyRequestMapInquisiumToSalesforceEmailParser = new Map<string,string>();
        Set<String> surveyIdsInquisiumToSalesforceEmailParser = new Set<String>();     
        SurveyRequestMapInquisiumToSalesforceEmailParser.put('SessionID','nF7LxZbXgLlinTq857qBFOQAcHLPtgOGDwRM+3sKCPBA/0rR3x68VBMClKtf/VO6L5iKoQfzMyfKTdATQeWQ7bbqebVLP9Es6hMYeWdxLk4b2vPi7jZx38zxV+91zlGNmT1sBA0poKDW/VgmV81k9kQILcPgOHBOxN6ULXL6maly2leiWVgmrTyUJhfLONUDMFClMuTh6j2OKuBHIAdn4zKqnfr5Vltasb8aSndU/iQrl0qYOKDtDySJ1DiOTrxjZomONl3Fu24ZThNVqAbkmx3bXrlm7Sg4gd1ZxnHzFjSjJXgLVWHcrLBR+gougrmnRhKDM4LRRYACRqLhX9+wn899obVcUWexf6lHG9/L6iY5RdEcTUGTSeIoruuUI96KR8jmkodwGGyaMfEbZG80YjLil7SB2WTv+PdQVChs+ZYgY0quyhrZWQEsR4gVaG0DhzsCeu+BdGfJeharPoI2JLF6k5/QGGoT/JMlTYYC7xesfqVoGBpQAS6K8OuE5jUEEKDfCK4osIKXPIuUBb8hRLMH3SBx7hwEN183mATRUYjIMdIWQ1wTwYbYJOPq0BIGruX+AL9ptNhRSok3fh8RA3DTnERKfRDCfSHjAs151wYci7jevGuVrDRdb5uCFfWhMvQ9ANh3uqFSfHLA9XfLXFb7wzqvsv5B3EVa+UDRSAMkeo0D7+TQ+hONWBtME9ehvSudoIIz0UfM18mSkX027ABbpTWejtZhvQaBC3hQiHLYAqrpXev2YeG/zkAAcZonujt5d0KfkEZ+hCVR9FPpnoHlmbpgbGvBKBt1ghWSthuP/DsQwd4U5eW4R5VyvNkkcPYADumB5Ph7gIKUVmJDRkEgoRVgnBZQcQeKV1/lkNJgyrXP2LrLpZpbb2cuJQ535iJdfyHyj0X7YmzeZf+LtM/q2DTsFjsYaKLSibN+1SyHLFNYNlXh/2JBsuwxo4AtqfiB+zyfDGs1qFCBbIGjWotRKIjJSsjqIeUkw0vA0ks4wgN8uwRxH+pKiKHDjYYXsFofR0OErMIGet2wMG4MhLJgw/7bTql4bj16Hny6eLUpYcPenNHWik2c3Lx3Y8tb8E4IPDf1M13jgmYQE/fyqxQo3xz7mqTE25KhfepWOAffpD816JK86btOWS4+pCw+w2MLz16KC8h409eDtYsUGcsbWqFhuskPsvIpbpO3ka0m9tcrFQ3DxySOYOFN87i/7jWI6SKBOrBpYRFaDiRlpBXsY9avwqeiNU1wVYApxMZadGQEE+hPkbJNJI0kJN7RmvkluNRrHqcvZJ78ofqm28z8ORMwr50h850gG3lhsb0=');
        SurveyRequestMapInquisiumToSalesforceEmailParser.put('SurveyID','111D1F9A-81B5-41E0-BA0E-C83734E9C8CB');
        surveyIdsInquisiumToSalesforceEmailParser.add('4B77A659-C820-4528-9F10-880D38A62B49');
        
        // Testing for  Positive Test for InquisiumToSalesforceEmailParser.       
        StaticResourceCalloutMock retrievePositiveInquisiumToSalesforceEmailParser = new StaticResourceCalloutMock();
        retrievePositiveInquisiumToSalesforceEmailParser.setStaticResource('Cevent_WebService_Helper_InquisiumToSalesforceEmailParser');
        retrievePositiveInquisiumToSalesforceEmailParser.setStatusCode(200);
        retrievePositiveInquisiumToSalesforceEmailParser.setHeader('Content-Type','text/XML'); 
        Test.setMock(HttpCalloutMock.class,retrievePositiveInquisiumToSalesforceEmailParser); 
        testobject.retriveSurvey(SurveyRequestMapInquisiumToSalesforceEmailParser,surveyIdsInquisiumToSalesforceEmailParser,40000);
        system.debug('SurveyRequestMapInquisiumToSalesforceEmailParser - STOP');

        String CRON_EXP = '0 0 0 1 1 ? 2025';  
        String jobId = System.schedule('CventSurveyWebservice_JobSchedularPSCS123', CRON_EXP, new CventSurveyWebservice_JobSchedularPSCS() );

        CronTrigger ct = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];

        System.assertEquals(CRON_EXP, ct.CronExpression); 
        System.assertEquals(0, ct.TimesTriggered);
        System.assertEquals('2025-01-01 00:00:00', String.valueOf(ct.NextFireTime));

    }
    
    Static testMethod void ValidateCventSurveyWebserviceController() {
        
        CventSurveyWebserviceController.ProcessRequest();
        // Additional survey classes 
        CventSurveyWebserviceControllerCCGL.ProcessRequest();
        CventSurveyWebserviceControllerCCSS.ProcessRequest();
        CventSurveyWebserviceControllerCTGL.ProcessRequest();
        CventSurveyWebserviceControllerEBSB.ProcessRequest();
        CventSurveyWebserviceControllerIntC.ProcessRequest();
        CventSurveyWebserviceControllerMobApp.ProcessRequest();
        CventSurveyWebserviceControllerMobAppCT.ProcessRequest();
        CventSurveyWebserviceControllerONBO.ProcessRequest();
        CventSurveyWebserviceControllerTMCS.ProcessRequest();
        CventSurveyWebserviceControllerTMONBO.ProcessRequest();
        CventSurveyWebserviceControllerPSCS.ProcessRequest();
        CventSurveyWebserviceControllerFCS.ProcessRequest();
        CventSurveyWebserviceControllerNQM.ProcessRequest();


        // Additional survey classes 
    }
}