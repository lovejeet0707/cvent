public class Cevent_WebService_Utility{



/*
       * @Description: method to  Send Http Request
       * @Return:Http Response Body -  Http response body returned from Salesforce.
*/

public static Map<String,String> sendRequest(Map<String,String> RequestParams,Set<String>SurveySet,String method,Integer Timelimit){


    String responseXML;
    Integer responsecode;
    String requestBody;
    String requestAction;
    String requestEndPoint;
    Map<string,string> Response=new Map<string,string>(); 
   
    //Generate Request Body according to methods
     
    if(method=='LoginRequest'){

        
        requestBody=getmethodRequestbody(RequestParams,SurveySet,method);
        requestAction='http://api.cvent.com/2006-11/Login';
        requestEndPoint='https://api.cvent.com/soap/V200611.ASMX';             
     
        
    }else if(method=='RetriveSurvey'){
    
        requestBody=getmethodRequestbody(RequestParams,SurveySet,method);
        requestAction='http://api.cvent.com/2006-11/Retrieve';
        requestEndPoint='https://api.cvent.com/soap/V200611.ASMX';      
    
    }else if(method=='SearchSurvey'){
    
        requestBody=getmethodRequestbody(RequestParams,SurveySet,method);
        requestAction='http://api.cvent.com/2006-11/Search';
        requestEndPoint='https://api.cvent.com/soap/V200611.ASMX';      
    
    }
    
if(requestBody!=null){

   try{
   
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(requestEndPoint);
        req.setHeader('Content-Type','text/xml');
        req.setHeader('SOAPAction',requestAction);
        req.setTimeout(Timelimit);
        req.setBody(requestBody);
        Http http = new Http();
        HttpResponse res = null;
        DOM.Document document = new DOM.Document();
        res = http.send(req);  
        responsecode=res.getStatusCode(); 
        
        if(responsecode!=200){
            Response.put('responseCode',String.valueof(responsecode));
            Response.put('response','');
        }else{
            document = res.getBodyDocument();
            responseXML= document.toXmlString();
            Response.put('responseCode',String.valueof(responsecode));
            Response.put('response',responseXML);  
        } 
         
    }catch (Exception ex) {
    
        if(ex.getMessage().contains('Read timed out')){
            Response.put('responseCode','995'); 
            Response.put('response',ex.getMessage());  
        }else{
            Response.put('responseCode','999');
            Response.put('response',ex.getMessage());          
        }
  
    }
   
}else{

    Response.put('responseCode','000');
    Response.put('response','Invalid request'); 
}
system.debug('Response==>'+Response); 
return Response;
}



/*
       * @Description: method to generate the RequestBody based on method.
       * @Return:Http Request Body -  Http request body to be send to Cvent Service.
*/


public static String  getmethodRequestbody(Map<String,String> RequestParams,Set<String>SurveySet,string method){
String requestBody;
Boolean invalidRequest=false;

    if(method=='loginRequest'){
    
    
       //making request parameter to blank
     
         string reqAccount=(RequestParams.get('Account')!=null)?RequestParams.get('Account'):'';       
         string reqUserName=(RequestParams.get('UserName')!=null)?RequestParams.get('UserName'):'';
         string reqPassword=(RequestParams.get('Password')!=null)?RequestParams.get('Password'):'';
       
         
       //generating body components
              
        string startBody='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://api.cvent.com/2006-11">';
        string bodyHeader='<soapenv:Header/><soapenv:Body><ns:Login>';
        string account='<ns:AccountNumber>'+reqAccount+'</ns:AccountNumber>';
        string username='<ns:UserName>'+reqUserName+'</ns:UserName>';
        string password='<ns:Password>'+reqPassword+'</ns:Password>';
        string endBody='</ns:Login></soapenv:Body></soapenv:Envelope>';  
         
    
      
       //constructing body
       
         if(reqAccount==''||reqUserName==''||reqPassword==''){
             invalidRequest=true;
         }else{
             
             requestBody=startBody+bodyHeader+account+username+password+endBody;            
         }
    
    }else if(method=='retriveSurvey'){
        
        String SurveyIdsParam='';
       //making request parameter to blank
     
         string reqSessionID=(RequestParams.get('SessionID')!=null)?RequestParams.get('SessionID'):'';       
         
       //generating body components            
  
         String Startstring='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://api.cvent.com/2006-11" xmlns:ns1="http://schemas.cvent.com/api/2006-11">';
         String Header='<soapenv:Header><ns:CventSessionHeader><ns:CventSessionValue>';
         String Body1='</ns:CventSessionValue></ns:CventSessionHeader></soapenv:Header><soapenv:Body><ns:Retrieve><ns:ObjectType>Response</ns:ObjectType><ns1:Ids>';
         String BodyEnd='</ns1:Ids></ns:Retrieve></soapenv:Body></soapenv:Envelope>'; 
         
         if(SurveySet.size()>0){
             
             for(String val:SurveySet){
                 SurveyIdsParam=SurveyIdsParam+'<ns1:Id>'+val+'</ns1:Id>'; 
             }
             
          }        
         
       //constructing body
       
        if(reqSessionID==''){
             invalidRequest=true;
         }else{
             requestBody=Startstring+Header+reqSessionID+Body1+SurveyIdsParam+BodyEnd;            
         }            
  
  }else if(method=='SearchSurvey'){
    
       //making request parameter to blank
     
         string reqSessionID=(RequestParams.get('SessionID')!=null)?RequestParams.get('SessionID'):'';       
         string reqSurveyID=(RequestParams.get('SurveyID')!=null)?RequestParams.get('SurveyID'):''; 
         string reqDate=(RequestParams.get('Date')!=null)?RequestParams.get('Date'):'';          
         
       //generating body components            
  
         String Startstring='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://api.cvent.com/2006-11" xmlns:ns1="http://schemas.cvent.com/api/2006-11">';
         String Header='<soapenv:Header><ns:CventSessionHeader><ns:CventSessionValue>';
         String Body1='</ns:CventSessionValue></ns:CventSessionHeader></soapenv:Header><soapenv:Body><ns:Search><ns:ObjectType>Response</ns:ObjectType><ns1:CvSearchObject SearchType="AndSearch"><ns1:Filter><ns1:Field>SurveyId</ns1:Field><ns1:Operator>Equals</ns1:Operator><ns1:Value>';
         String Body2='</ns1:Value></ns1:Filter><ns1:Filter><ns1:Field>CompletionDate</ns1:Field><ns1:Operator>Greater than</ns1:Operator><ns1:Value>';
         String BodyEnd='</ns1:Value></ns1:Filter></ns1:CvSearchObject></ns:Search></soapenv:Body></soapenv:Envelope>'; 
         
       //constructing body
       
        if(reqSessionID==''||reqSurveyID==''||reqDate==''){
             invalidRequest=true;
         }else{
             requestBody=Startstring+Header+reqSessionID+Body1+reqSurveyID+Body2+reqDate+BodyEnd;            
         }            
  
    }  
 system.debug('requestBody==> '+method+' '+requestBody); 
       
    //confirming invalid request    
    if(!invalidRequest){
        requestBody=requestBody.replace('&','&amp;');     
        return requestBody;
    }else{
        return null;
    }


}
}