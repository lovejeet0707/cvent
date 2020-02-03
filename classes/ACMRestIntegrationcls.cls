/*
//////////////////////////////////////
//      @author Abhishek Pandey     //
/////////////////////////////////////
Version :   1.0
Date : 23rd Feb 2014
Description : To dynamically update ACM object on regular basis from OANDA server using REST
*/
public class ACMRestIntegrationcls {
    @future(callout=true)
    public static void call(){
        Datetime myDatetime = Datetime.now();
        String myDatetimeStr = myDatetime.format('yyyy-MM-dd');
        
        
        Httprequest req =  new Httprequest();
        req.setEndpoint('https://www.oanda.com/rates/api/v1/rates/USD.json?decimal_places=4&date='+myDatetimeStr+'&fields=averages&quote=SGD&quote=AUD&quote=CAD&quote=INR&quote=EUR&quote=GBP&quote=CHF&quote=ZAR&quote=HKD&quote=NZD&quote=AED');
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + 'coneillcvent');
        ///req.setHeader('Authorization', 'Bearer ' + ' coneillcvent');
        
        //String body = '?api_key=coneillcvent&decimal_places=4&date='+myDatetimeStr+'&fields=averages"e=AUD"e=CAD"e=INR"e=EUR"e=GBP';
        //req.setBody(body);
        Http http = new Http();
        HTTPResponse res = new HTTPResponse();
        if (!Test.isRunningTest()){
            res = http.send(req);
        }
        
        system.debug(res.getBody());
        
        if(test.isRunningTest())
            res.setBody('{"base_currency":"USD","meta":{"effective_params":{"data_set":"oanda","date":"2015-02-23","decimal_places":"4","fields":["averages"],"quote_currencies":["SGD","AUD","CAD","EUR","GBP","INR","CHF","ZAR","HKD","NZD","AED"]},"request_time":"2015-02-23T13:54:55+0000","skipped_currencies":[]},"quotes":{"SGD":{"ask":"1.36081","bid":"1.35965","date":"2015-02-22T21:00:00+0000"},"AUD":{"ask":"1.2763","bid":"1.2739","date":"2015-02-22T21:00:00+0000"},"CAD":{"ask":"1.2538","bid":"1.2530","date":"2015-02-22T21:00:00+0000"},"EUR":{"ask":"0.8791","bid":"0.8786","date":"2015-02-22T21:00:00+0000"},"GBP":{"ask":"0.6498","bid":"0.6490","date":"2015-02-22T21:00:00+0000"},"CHF":{"ask":"0.93975","bid":"0.93687","date":"2015-02-22T21:00:00+0000"},"ZAR":{"ask":"11.6474","bid":"11.6037","date":"2015-02-22T21:00:00+0000"},"HKD":{"ask":"7.75971","bid":"7.75775","date":"2015-02-22T21:00:00+0000"},"NZD":{"ask":"1.33016","bid":"1.32799","date":"2015-02-22T21:00:00+0000"},"INR":{"ask":"62.2060","bid":"62.1010","date":"2015-02-22T21:00:00+0000"},"AED":{"ask":"12.2070","bid":"22.1080","date":"2015-02-22T21:00:00+0000"}}}');
        
        Jsonparser parser = JSON.createParser(res.getBody());
        
        Map<String,String> mapCurrEx = new Map<String,String>();
        
        while(parser.nextToken() != null) {
            system.debug('parser.getCurrentToken()+++'+parser.getCurrentToken());
            system.debug('JSONToken.FIELD_NAME++'+JSONToken.FIELD_NAME);
            system.debug('parser.getText()++'+parser.getText());
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'AED' || parser.getText() == 'INR' || parser.getText() == 'SGD' || parser.getText() == 'AUD' || parser.getText() == 'CAD' || parser.getText() == 'EUR' || 
            parser.getText() == 'CHF' ||
            parser.getText() == 'ZAR' ||
            parser.getText() == 'HKD' ||
            parser.getText() == 'NZD' ||
            parser.getText() == 'GBP')) {
                // Get the value.
                String strCurrency = '';
                strCurrency = parser.getText();
                while(parser.nextToken()!= JSONToken.END_OBJECT){
                    if((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'Bid')){
                        parser.nextToken(); 
                        if(parser.getCurrentToken() == JSONToken.VALUE_STRING){
                            mapCurrEx.put(strCurrency,parser.getText());
                        }
                    }   
                } 
            }
        }
        List<CurrencyPassAuth__c> mcs = CurrencyPassAuth__c.getall().values();
        system.debug('mapCurrEx+++'+mapCurrEx);
        system.debug('mcs[0].Security_Token__c.trim()+++'+mcs[0].Security_Token__c.trim());
        system.debug('mcs[0].Password__c.trim()+++'+mcs[0].Password__c.trim());
        system.debug('mcs[0].Username_del__c.trim()+++'+mcs[0].Username_del__c.trim());
        
        String xmlReq =
            '<?xml version="1.0" encoding="utf-8" ?>'+
            '<env:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">'+
            '<env:Body>'+
            '<n1:login xmlns:n1="urn:partner.soap.sforce.com">'+
            '<n1:username>'+mcs[0].Username_del__c.trim()+'</n1:username>'+
            '<n1:password>'+mcs[0].Password__c.trim()+mcs[0].Security_Token__c.trim()+'</n1:password>'+
            '</n1:login>'+
            '</env:Body>'+
            '</env:Envelope>';
        DOM.Document doc = new DOM.Document();
        doc.load(xmlReq);
        
        http = new Http();
        req = new HttpRequest();
        req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm()+'/services/Soap/u/28.0');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'text/xml; charset=UTF-8');
        req.setHeader('SOAPAction', 'login');       
        req.setBodyDocument(doc);
        
        res = new HTTPResponse(); 
        String xmlRes;
        if (!Test.isRunningTest()){
            res = http.send(req);
        }
        xmlRes = res.getBody(); 
        String sessionId;
        if (Test.isRunningTest()){
            sessionId = 'Wwersddsfsnze1123' ;
        }
        if (!Test.isRunningTest()){
            sessionId = xmlRes.split('<sessionId>',2)[1].split('</sessionId>',2)[0];
        }
        system.debug(sessionId);
        String csvContent; 
        csvContent = 'INR,'+mapCurrEx.get('INR')+','+system.today()+'\n'+
            'AUD,'+mapCurrEx.get('AUD')+','+system.today()+'\n'+
            'SGD,'+mapCurrEx.get('SGD')+','+system.today()+'\n'+
            'CHF,'+mapCurrEx.get('CHF')+','+system.today()+'\n'+
            'ZAR,'+mapCurrEx.get('ZAR')+','+system.today()+'\n'+
            'HKD,'+mapCurrEx.get('HKD')+','+system.today()+'\n'+
            'NZD,'+mapCurrEx.get('NZD')+','+system.today()+'\n'+
            'CAD,'+mapCurrEx.get('CAD')+','+system.today()+'\n'+
            'EUR,'+mapCurrEx.get('EUR')+','+system.today()+'\n'+
            'GBP,'+mapCurrEx.get('GBP')+','+system.today()+'\n'+
			'AED,'+mapCurrEx.get('AED')+','+system.today()+'\n';
        csvContent = 'IsoCode,ConversionRate,StartDate'+'\n'+csvContent;
        Blob csvBlob = Blob.valueOf(csvContent);
        String loadDef =
            '<?xml version="1.0" encoding="UTF-8"?>'+
            '<jobInfo xmlns="http://www.force.com/2009/06/asyncapi/dataload">'+
            '<operation>insert</operation>'+
            '<object>DatedConversionRate</object>'+
            '<contentType>CSV</contentType>'+
            '</jobInfo>';
        DOM.Document docsec = new DOM.Document();
        docsec.load(loadDef);      
        
        http = new Http();
        req = new HttpRequest();
        req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm()+'/services/async/27.0/job');
        req.setMethod('GET');
        req.setHeader('X-SFDC-Session', sessionId); 
        req.setHeader('Content-Type', 'application/xml; charset=UTF-8');
        req.setBodyDocument(docsec);
        if (!Test.isRunningTest()){
            res = http.send(req);
        }
        xmlRes = res.getBody();
        if (Test.isRunningTest()){
            xmlRes ='<?xml version="1.0" encoding="UTF-8"?>'+
                '<jobInfo xmlns="http://www.force.com/2009/06/asyncapi/dataload">'+
                '<operation>insert</operation>'+
                '<object>DatedConversionRate</object>'+
                '<contentType>CSV</contentType>'+
                '</jobInfo>' ;
        }
        
        String jobId; //get the Bulk Load Job's Job ID
        doc = new DOM.Document();       
        doc.load(xmlRes);
        for(Dom.XMLNode childNode: doc.getRootElement().getChildren()) {
            if (childNode.getName() == 'id') {
                //if (!Test.isRunningTest()){
                jobId = childNode.getText();
                //}
                break;  
            }
        }
        http = new Http();
        req = new HttpRequest();
        req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm()+'/services/async/27.0/job/'+jobId+'/batch');
        req.setMethod('GET');
        req.setHeader('X-SFDC-Session', sessionId);      
        req.setHeader('Content-Type', 'text/csv; charset=UTF-8');                       
        req.setBodyAsBlob(csvBlob);
        if (!Test.isRunningTest()){
            res = http.send(req);
        }
        xmlRes = res.getBody();
        
        if (Test.isRunningTest()){
            xmlRes ='<?xml version="1.0" encoding="UTF-8"?>'+
                '<jobInfo xmlns="http://www.force.com/2009/06/asyncapi/dataload">'+
                '<operation>insert</operation>'+
                '<object>DatedConversionRate</object>'+
                '<contentType>CSV</contentType>'+
                '</jobInfo>' ;
        }    
        
        String batchId; //get the Bulk Load Batch Id
        doc = new DOM.Document();       
        doc.load(xmlRes);
        for(Dom.XMLNode childNode: doc.getRootElement().getChildren()) {
            if (childNode.getName() == 'id') {
                //if (!Test.isRunningTest()){
                batchId = childNode.getText();
                //}
                break;  
            }
        }
        
        //=================================================================
        String closeDef =
            '<?xml version="1.0" encoding="UTF-8"?>'+
            '<jobInfo xmlns="http://www.force.com/2009/06/asyncapi/dataload">'+
            '<state>Closed</state>'+
            '</jobInfo>';
        doc = new DOM.Document();
        doc.load(closeDef);
        
        http = new Http();
        req = new HttpRequest();
        req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm()+'/services/async/27.0/job/'+jobId);
        req.setMethod('GET');
        req.setHeader('X-SFDC-Session', sessionId);
        req.setHeader('Content-Type', 'application/xml; charset=UTF-8');
        req.setBodyDocument(doc);
        
        if (!Test.isRunningTest()) {
            res = http.send(req);
            xmlRes = res.getBody();
        }
    }
 }