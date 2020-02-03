/**@author Hemant Rana
Version 1.0
Description : Class for Integrating two orgs and accessing their account data....
Test Class : AutoLoginTest
Date: 7th Feb 2017
*/
public class AutoLogin {
     private final Account acct;
     public string Id{get;set;}
     public String SESSION_ID{get;set;}
     private Map<String,LanyonCredentials__c> lanyonCredMap = new Map<String,LanyonCredentials__c>();
     private String userName;
     private String passSecurityToken;
     public String endPointURL{get;set;}
     public AutoLogin (ApexPages.StandardController stdController) {
        //Getting target Org credentials from Custom Setting.........
        lanyonCredMap = LanyonCredentials__c.getAll();
        For(String lanyonCred : lanyonCredMap.keySet())
        {
            userName = lanyonCred;
            passSecurityToken = lanyonCredMap.get(lanyonCred).LoginPassSecure__c;
            endPointURL = lanyonCredMap.get(lanyonCred).EndPointURL__c;
        }
        //..Getting Account Record Details..
        this.acct = (Account)stdController.getRecord();
        //Querying on the Account to get Lanyon Account Id.................
        Account inst = [SELECT ID,Lanyon_AccountId__c FROM Account WHERE Id=:ApexPages.currentPage().getParameters().get('Id')];
        //If Lanyon Account Id found then setting up the connection and getting Session Id..
        if(inst!=null && String.isNotBlank(inst.Lanyon_AccountId__c)){
            Id = inst.Lanyon_AccountId__c;
            // Invoke web service call
            String result = '';
            
                // Make a real callout since we are not running a test
                /*Login to Other Salesforce Org to grab session id - begin*/
                HTTP h1 = new HTTP();
                HttpRequest request = new HttpRequest();  
                request.setTimeout(2 * 60 * 1000);
                request.setEndpoint(endPointURL+'/services/Soap/u/30.0/services/Soap/u/30.0');
                request.setMethod('POST');
                request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
                request.setHeader('SOAPAction', '""');
                request.setBody('<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/"><Header/><Body><login xmlns="urn:partner.soap.sforce.com"><username>' +userName+ '</username><password>' +passSecurityToken + '</password></login></Body></Envelope>');
                String SERVER_URL;
            if (!Test.isRunningTest()){
                HTTPResponse loginResponse = h1.send(request);     
                Dom.Document doc = loginResponse.getBodyDocument();
                Dom.XMLNode receivedXml= doc.getRootElement();
                System.debug('receivedXml***********'+receivedXml);
                SESSION_ID = receivedXml.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/').getChildElement('loginResponse', 'urn:partner.soap.sforce.com').getChildElement('result','urn:partner.soap.sforce.com').getChildElement('sessionId','urn:partner.soap.sforce.com').getText();      
                System.debug('SESSION_ID********'+SESSION_ID);
            }
            else {
                // A test is running
                result = '<?xml version="1.0"?><ResultSet xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="urn:yahoo:maps" xsi:schemaLocation="urn:yahoo:maps http://api.local.yahoo.com/MapsService/V1/GeocodeResponse.xsd"><Result precision="address"><Latitude>37.416397</Latitude><Longitude>-122.025055</Longitude><Address>701 1st Ave</Address><City>Sunnyvale</City><State>CA</State><Zip>94089-1019</Zip><Country>US</Country></Result></ResultSet>';
            }
        }
    }
}