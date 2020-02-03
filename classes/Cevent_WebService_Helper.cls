global class Cevent_WebService_Helper{
    public List<LoginResult>  LoginResult_Response_List;
    public List<searchWrapper>  search_Response_List;    
    public List<SurveyDetailWrapper>  SurveyDetailWrapper_Response_List;    
    
    /*
* @Description: Method to retrieve Session Result List.
*/     
    public List<LoginResult> loginRequest(Map<String,String>RequestParam,Integer Timelimit){
        String errorMessage;
        Set<String>DummySurveySet=new Set<String>();    
        map<string,string> response = Cevent_WebService_Utility.sendRequest(RequestParam,DummySurveySet,'loginRequest',Timelimit);
        String Responsecode=response.get('responseCode');
        String HttpResponse=response.get('response');
        LoginResult_Response_List=new list<LoginResult>();
        LoginResult ReslrObj=new LoginResult();
        
        if(Responsecode=='200'){
            
            try{
                Dom.Document doc = new Dom.Document();
                doc.load(HttpResponse);
                dom.XmlNode [] Body= doc.getRootElement().getChildElements();
                system.debug('Body==>'+Body.size());
                dom.XmlNode [] LoginResponse=Body[0].getChildElements();
                system.debug('LoginResponse==>'+LoginResponse.size());
                dom.XmlNode [] LoginResult=LoginResponse[0].getChildElements(); 
                
                if(LoginResult.size()>0){     
                    
                    for(Dom.XMLNode listvar:LoginResult){
                        ReslrObj=new LoginResult(); 
                        //This is the way to read element value
                        ReslrObj.sessionId=listvar.getAttributeValue('CventSessionHeader',null);    
                        //adding the record to list 
                        LoginResult_Response_List.add(ReslrObj);                      
                    }
                }
                
                //adding the response list size
                if(LoginResult_Response_List.size()!=0){
                    LoginResult_Response_List[0].error_Code=Responsecode;                  
                    LoginResult_Response_List[0].Records_Count=LoginResult_Response_List.size();                  
                }else{
                    //adding the response code to first record
                    //  ReslrObj.message=errorMessage;
                    LoginResult_Response_List.add(ReslrObj);
                    LoginResult_Response_List[0].error_Code=Responsecode;                      
                    LoginResult_Response_List[0].Records_Count=0;   
                }                  
            }catch(Exception ex){
                system.debug('exception occured'+ex.getMessage());               
                ReslrObj.error_Code='999';               
                LoginResult_Response_List.add(ReslrObj);
            } 
        }else{
            ReslrObj.error_Code=Responsecode;
            LoginResult_Response_List.add(ReslrObj);            
        }
        System.debug('response==>'+LoginResult_Response_List);
        return LoginResult_Response_List;        
    }
    
    
    /*
* @Description: Method to retrieve Search Result List.
*/     
    
    public List<searchWrapper> Search(Map<String,String>RequestParam,Integer Timelimit){
        String errorMessage;
        Set<String>DummySurveySet=new Set<String>();
        map<string,string> response=Cevent_WebService_Utility.sendRequest(RequestParam,DummySurveySet,'SearchSurvey',Timelimit);
        String Responsecode=response.get('responseCode');
        String HttpResponse=response.get('response');
        search_Response_List=new list<searchWrapper>();
        searchWrapper ReslrObj=new searchWrapper();
        
        if(Responsecode=='200'){
            try{
                Dom.Document doc = new Dom.Document();
                doc.load(HttpResponse);            
                dom.XmlNode [] Body= doc.getRootElement().getChildElements();
                dom.XmlNode [] SearchResponse=Body[1].getChildElements();
                dom.XmlNode [] Resultlist=SearchResponse[0].getChildElements(); 
                system.debug('Resultlist==>'+Resultlist.size());                 
                dom.XmlNode [] surveylist=Resultlist[0].getChildElements(); 
                system.debug('surveylist==>'+surveylist.size());                                                          
                
                if(surveylist.size()>0){
                    for(Dom.XMLNode records:surveylist){
                        ReslrObj=new searchWrapper();                    
                        if(records.getName()=='Id'){
                            ReslrObj.SurveyId=records.getText();
                        }
                        search_Response_List.add(ReslrObj);                      
                    }
                }
                //adding the response list size
                if(search_Response_List.size()!=0){
                    search_Response_List[0].error_Code=Responsecode;                  
                    search_Response_List[0].Records_Count=search_Response_List.size();                  
                }else{
                    //adding the response code to first record
                    //  ReslrObj.message=errorMessage;
                    search_Response_List.add(ReslrObj);
                    search_Response_List[0].error_Code=Responsecode;                      
                    search_Response_List[0].Records_Count=0;   
                }                  
            }catch(Exception ex){
                system.debug('exception occured'+ex.getMessage());               
                ReslrObj.error_Code='999';               
                search_Response_List.add(ReslrObj);
            } 
        }else{
            ReslrObj.error_Code=Responsecode;
            search_Response_List.add(ReslrObj);            
        }
        System.debug('response==>'+search_Response_List);
        return search_Response_List;        
    }
    
    /*
* @Description: Method to retrieve Survey details List.
*/ 
    
    public List<SurveyDetailWrapper> retriveSurvey(Map<String,String>RequestParam,Set<String>Survetset,Integer Timelimit){
        String errorMessage;
        map<string,string> response = Cevent_WebService_Utility.sendRequest(RequestParam,Survetset,'retriveSurvey',Timelimit);
        String Responsecode = response.get('responseCode');
        String HttpResponse = response.get('response');
        SurveyDetailWrapper_Response_List = new list<SurveyDetailWrapper>();
        SurveyDetailWrapper ReslrObj = new SurveyDetailWrapper();
        
        if(Responsecode=='200'){
            try{
                Dom.Document doc = new Dom.Document();
                doc.load(HttpResponse);
                dom.XmlNode [] Body= doc.getRootElement().getChildElements();
                dom.XmlNode [] RetrieveResult=Body[1].getChildElements();
                dom.XmlNode [] CvObject=RetrieveResult[0].getChildElements();
                dom.XmlNode [] SurveyDetailList=CvObject[0].getChildElements(); 
                System.debug('SurveyDetailList==>'+SurveyDetailList.size());  
                // Looping through all the Survey List
                //This is the level you get list of all the SurveyDetails               
                if(SurveyDetailList.size()>0){ 
                    for(Dom.XMLNode surveys : SurveyDetailList){
                        //REtrieving the values if Id,ResponseID,ReferenceId  
                        String ID,SourceId,ResponseID,ReferenceId,Email,FirstName,LastName,ResponseNumber,ReceivedDate;   
                        //This is the way to read element value from survey header
                        ID = surveys.getAttributeValue('Id',null); 
                        ResponseNumber = surveys.getAttributeValue('ResponseNumber',null);
                        ResponseID = surveys.getAttributeValue('ResponseID',null);   
                        ReferenceId = surveys.getAttributeValue('ReferenceId',null);
                        SourceId = surveys.getAttributeValue('SourceId',null);
                        Email = surveys.getAttributeValue('EmailAddress',null);  
                        FirstName = surveys.getAttributeValue('FirstName',null); 
                        LastName = surveys.getAttributeValue('LastName',null);                                                                            
                        ReceivedDate = surveys.getAttributeValue('ReceivedDate',null);
                        
                        dom.XmlNode [] result= surveys.getChildElements(); 
                        
                        //System.debug('ID,ResponseID,ReferenceId==>'+ID+'@@'+ResponseID+'@@'+ReferenceId); 
                        
                        for(Dom.XMLNode Objects : result){
                            dom.XmlNode [] fields=Objects.getChildElements();  
                            ReslrObj = new SurveyDetailWrapper();  
                            List<SurveyAnswereWrapper>SurveyAnswereWrapper_List=new List<SurveyAnswereWrapper>();                        
                            for(Dom.XMLNode field:fields) {
                                if(field.getName()=='QuestionText'){
                                    ReslrObj.questionText=field.getText();
                                }else if(field.getName()=='QuestionExportValue'){
                                    ReslrObj.questionExportValue=field.getText();                     
                                }else if(field.getName()=='QuestionType'){
                                    ReslrObj.QuestionType=field.getText();                     
                                }else if(field.getName()=='QuestionScore'){
                                    ReslrObj.QuestionScore=field.getText();                     
                                }else if(field.getName()=='QuestionCode'){
                                    ReslrObj.QuestionCode=field.getText();                     
                                }else if(field.getName()=='QuestionNumber'){
                                    ReslrObj.QuestionNumber=field.getText();                     
                                }else if(field.getName()=='Answer'){
                                    SurveyAnswereWrapper answersObj=new SurveyAnswereWrapper();                             
                                    dom.XmlNode [] answerefields=field.getChildElements();
                                    //Storing the answere list to current object  
                                    for(Dom.XMLNode value:answerefields) { 
                                        if(value.getName()=='AnswerPart'){
                                            answersObj.AnswerPart=value.getText(); 
                                        }else if(field.getName()=='AnswerColumn'){
                                            answersObj.AnswerColumn=value.getText();                   
                                        }else if(value.getName()=='AnswerText'){
                                            answersObj.AnswerText=value.getText();                    
                                        }else if(value.getName()=='AnswerOther'){
                                            answersObj.AnswerOther=value.getText();                   
                                        }else if(value.getName()=='AnswerExportValue'){
                                            answersObj.AnswerExportValue=value.getText();                 
                                        }else if(value.getName()=='AnswerComment'){
                                            answersObj.AnswerComment=value.getText();                      
                                        }
                                    }
                                    SurveyAnswereWrapper_List.add(answersObj);                     
                                }
                            } 
                            // adding ID,ResponseID,ReferenceId 
                            ReslrObj.Id = ID;
                            ReslrObj.ResponseID = ResponseID;
                            ReslrObj.ReferenceId = ReferenceId; 
                            ReslrObj.SourceId = SourceId; 
                            ReslrObj.ResponseNumber = ResponseNumber;
                            ReslrObj.Email = Email; 
                            ReslrObj.FirstName = FirstName; 
                            ReslrObj.LastName = LastName;   
                            ReslrObj.ReceivedDate = ReceivedDate;                             
                            
                            //adding the record to list 
                            ReslrObj.Answere=SurveyAnswereWrapper_List;
                            SurveyDetailWrapper_Response_List.add(ReslrObj);                             
                        }
                    }       
                }              
                //adding the response list size
                if(SurveyDetailWrapper_Response_List.size()!=0){
                    SurveyDetailWrapper_Response_List[0].error_Code=Responsecode;                  
                    SurveyDetailWrapper_Response_List[0].Records_Count=SurveyDetailWrapper_Response_List.size();                  
                }else{
                    //adding the response code to first record
                    SurveyDetailWrapper_Response_List.add(ReslrObj);
                    SurveyDetailWrapper_Response_List[0].error_Code=Responsecode;                      
                    SurveyDetailWrapper_Response_List[0].Records_Count=0;   
                }    
                
                
            }catch(Exception ex){
                system.debug('exception occured'+ex.getMessage());               
                ReslrObj.error_Code='999';               
                SurveyDetailWrapper_Response_List.add(ReslrObj);
            } 
         }else{
            ReslrObj.error_Code=Responsecode;
            SurveyDetailWrapper_Response_List.add(ReslrObj);            
        }
        System.debug('response==>'+SurveyDetailWrapper_Response_List);
        System.debug('response size==>'+SurveyDetailWrapper_Response_List.size());
        return SurveyDetailWrapper_Response_List;        
    }
    
    /*
* @Description: Wrapper Class to Store Parsed Response for Resellar Search.
*/  
    Global class LoginResult{
        public String sessionId{get;set;}
        public Integer Records_Count{get;set;}    
        public String Error_Code{get;set;}
    }
    /*
* @Description: Wrapper Class to Store Parsed Response for SurveyDetails.
*/  
    Global class SurveyDetailWrapper{        
        public String Id{get;set;}
        public String ResponseID{get;set;}
        public String ResponseNumber{get;set;}
        public String ReferenceId{get;set;}
        public String SourceId{get;set;}
        public String questionText{get;set;}
        public String questionExportValue{get;set;}
        public String QuestionType{get;set;}
        Public List<SurveyAnswereWrapper>Answere{get;set;}
        public String QuestionScore{get;set;}
        public String QuestionCode{get;set;}
        public String QuestionNumber{get;set;}  
        public String Email{get;set;}  
        public String FirstName{get;set;} 
        public String LastName{get;set;}           
        public Integer Records_Count{get;set;}    
        public String Error_Code{get;set;}
        public String ReceivedDate{get;set;} // TICCM-1042 : Udita
    }
    
    /*
* @Description: Wrapper Class to Store Parsed Response for AnswereWrapper.
*/  
    Global class SurveyAnswereWrapper{
        public String AnswerPart{get;set;}
        public String AnswerColumn{get;set;}
        public String AnswerText{get;set;}
        public String AnswerOther{get;set;}
        public String AnswerExportValue{get;set;}
        public String AnswerComment{get;set;}   
    }
    
    /*
* @Description: Wrapper Class to Store Parsed Response for Search.
*/  
    Global class searchWrapper{
        public String SurveyId{get;set;}
        public Integer Records_Count{get;set;}    
        public String Error_Code{get;set;}
    }
}