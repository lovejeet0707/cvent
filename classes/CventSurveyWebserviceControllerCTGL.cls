/**********************************
 Class Name:CventSurveyWebserviceControllerCTGL 
 * Author: Rishi Ojha
 * Date: 24-Sep-2015
 * Requirement # Retrieve Survey responses from Cvent System then to insert data in Salesforce
 * Description: # Controller is used for Client Management(Global) , CT ticketing for Cases
 * Product Type:Client Management(Global) (CrowdTorch Ticketing Client Feedback Survey)  
                
***********************************/
Public class CventSurveyWebserviceControllerCTGL {


@Future(callout=true)
Public static void ProcessRequest(){

    String SessionID;
    Set<String>surveyIds=new Set<String>(); 

  //Login Call
    Map<string,string>LoginRequestMap=new Map<string,string>();
    LoginRequestMap.put('Account','CSSATVA99');
    LoginRequestMap.put('UserName','CSSATVA99Api');
    LoginRequestMap.put('Password','9lTd55BM7YX');
    Cevent_WebService_Helper LoginStub =new Cevent_WebService_Helper();
    List<Cevent_WebService_Helper.LoginResult> result=new List<Cevent_WebService_Helper.LoginResult>();
    
    if(!Test.isRunningTest()){
        result=LoginStub.loginRequest(LoginRequestMap,40000);
    }else{
        Cevent_WebService_Helper.LoginResult testobj=new Cevent_WebService_Helper.LoginResult();
        testobj.sessionId='sssssss'; 
        testobj.Error_Code='200'; 
        result.add(testobj);         
     }
    system.debug('result for session===>'+result[0].sessionId);
    SessionID=result[0].sessionId;
  //Making the Search Call
  
    Map<string,string>SearchRequestMap=new Map<string,string>();
    SearchRequestMap.put('SessionID',result[0].sessionId);
    SearchRequestMap.put('SurveyID','217C9891-9D41-4A61-90BF-A7480E939BFC');
    Date DateToday = date.today()-1;
    string dateValue=String.valueOf(DateToday);
 //   string dateValue='2014-05-10';  
    System.debug('date===>'+dateValue);
    SearchRequestMap.put('Date',dateValue);
    //Cevent_WebService_Utility.sendRequest(Request,'SearchSurvey',40000);
    Cevent_WebService_Helper SearchStub=new Cevent_WebService_Helper();
    List<Cevent_WebService_Helper.searchWrapper> SearchResult=new List<Cevent_WebService_Helper.searchWrapper>();
    if(!Test.isRunningTest()){
        SearchResult=SearchStub.Search(SearchRequestMap,40000);
    }else{
        Cevent_WebService_Helper.searchWrapper testobj=new Cevent_WebService_Helper.searchWrapper();
        testobj.SurveyId='sssssss'; 
        testobj.Error_Code='200'; 
        SearchResult.add(testobj);         
     }
//   system.debug('SearchResult==>'+SearchResult);  
    
  //Collecting survey IDS  from Search  

    for(Cevent_WebService_Helper.searchWrapper var:SearchResult){
      surveyIds.add(var.SurveyId);
    }
//    system.debug('DailySurveyIds===>'+surveyIds);
    
  //Retrieving the corresponding surveys for the corresponding surveyIDs
   
    Map<string,string>SurveyRequestMap=new Map<string,string>();
    SurveyRequestMap.put('SessionID',SessionID);
    Cevent_WebService_Helper SurveyStub= new Cevent_WebService_Helper();
    List<Cevent_WebService_Helper.SurveyDetailWrapper> SurveyResult=new List<Cevent_WebService_Helper.SurveyDetailWrapper>();    
    
    if(!Test.isRunningTest()){
        SurveyResult=SurveyStub.retriveSurvey(SurveyRequestMap,surveyIds,40000);
    }else{
        Cevent_WebService_Helper.SurveyDetailWrapper testobj=new Cevent_WebService_Helper.SurveyDetailWrapper();
        testobj.Id='sssssss'; 
        testobj.Error_Code='200'; 
      //for production using below
        testobj.ReferenceId='50000000008d619'; 
      //for sandbox use below  
      //testobj.ReferenceId='ssssss';
        List<Cevent_WebService_Helper.SurveyAnswereWrapper>SurveyAnswereWrapper_TestList=new List<Cevent_WebService_Helper.SurveyAnswereWrapper>();  
        Cevent_WebService_Helper.SurveyAnswereWrapper testanswersObj=new Cevent_WebService_Helper.SurveyAnswereWrapper();
        testanswersObj.AnswerText='test answere';   
        testobj.Answere=SurveyAnswereWrapper_TestList;                                   
        SurveyResult.add(testobj);         
     }
//    System.debug('SurveyResult==>'+SurveyResult);

   //preparing to insert into CSAT Survey object
   List<Survey_Q__c>SurveyQList=new List<Survey_Q__c>();
   List<Survey_R__c>SurveyRList=new List<Survey_R__c>();   
   if(SurveyResult.size()>0){
       Integer i=0;
       String lastValue='';
       for(Cevent_WebService_Helper.SurveyDetailWrapper var:SurveyResult){
        String Name, EmailAddress, CaseId, CaseExternalId, QuestionText, QuestionType, QuestionNumber ;
        Boolean IsvalidCaseId=true;
        ///logic to cast webservice response to salesforce oject and make Database.insertor update.
        Survey_Q__c sq=new Survey_Q__c();
      //  Survey_R__c sr=new Survey_R__c();        
         Name=var.FirstName+' '+var.LastName;
         EmailAddress=var.Email;  
          


      
     //   System.debug ('lastvalue==>>>' +var.);
       
        if(var.ReferenceId!=null||var.ReferenceId!=''){
            try{
                sq.Case__c=var.ReferenceId;
                CaseId = var.ReferenceId;
               // sq.CaseID__c=var.ReferenceId+string.valueof(i);
            }catch(exception e){
                IsvalidCaseId=false;
            }
        //for Sandbox, using text field (also updating CaseId in Production for external id)
      //  sq.CaseID__c=var.ReferenceId; 
      
        }
        QuestionText=var.questionText;
        QuestionType=var.QuestionType; 
        QuestionNumber=var.QuestionNumber;   
             
        for(Cevent_WebService_Helper.SurveyAnswereWrapper val:var.Answere){
         Survey_Q__c SS =new Survey_Q__c();
         if(lastValue==var.ReferenceId){
             i++;
         }else{
             i=0;
             lastValue=var.ReferenceId; 
         }
            SS.Name=Name;
            SS.Email_Address__c=EmailAddress;
            SS.Question_Text__c=QuestionText;
            SS.Question_Type__c=QuestionType;
            SS.Question__c=QuestionNumber ;
           /* hardcoding sandbox caseid as response brings prod case ids*/            
             SS.Case__c=CaseId;
          // SS.Case__c='500P0000003d55F';
            SS.Answere__c=val.AnswerText;
            SS.AnswerPart__c=val.AnswerPart;
            SS.CaseID__c=var.ReferenceId+string.valueof(i);
            if(IsvalidCaseId){
                SurveyQList.add(SS);  
            }                         
        }
 

       }
     //system.debug('SurveyQList==>'+SurveyQList);
     System.debug ('SurveyQList===> '+  SurveyQList );
       try {
           database.upsert(SurveyQList,false);
          // upsert(SurveyQList);
       } catch (DmlException e) {
       
        System.debug ('Error Message===> '+  e.getmessage() );
   
       }
       
   }else{
   System.debug('No records retrieved==>');
   }

  
}

}