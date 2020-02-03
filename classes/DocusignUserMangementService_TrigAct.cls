/*
* Author: Sandeep Kumar
* Date: 25-Dec-2017
* Class Name : DocusignUserMangementService_TrigAct 
* Description : Activates/ Deactivates Docusign user based on Salesforce User activation and deactivaton.
* 
* Test Class - DocusignUserMangmtService_TrigAct_Test,DocusignUserMangementServiceMock
*/
public class DocusignUserMangementService_TrigAct extends TriggerAction{
    private static string presentDocusignOrgCredential;
    private static Set<String> deactivationUserIdSet;
   // private static List<ActivateDocusignUserWrapper> activateDocusignUserWrapperList;
    private static List<DeactivateDocusignUserWrapper> deactivateDocusignUserWrapperList;
    private static Map<String,DocuSign_Credential__mdt> metaDataLabelToMetaDataTypeMap;   
    
    // Default Constructor
    public DocusignUserMangementService_TrigAct(){
        // Call super to set batch variables & context
        super();
        deactivationUserIdSet = new Set<String>();
     //   activateDocusignUserWrapperList = new List<ActivateDocusignUserWrapper>();
        deactivateDocusignUserWrapperList = new List<DeactivateDocusignUserWrapper>();
        // Get Survey Mappings from the Custom MetaData Type - "SyncSurveyFromInquisiumMapping__mdt"
        metaDataLabelToMetaDataTypeMap = new Map<String,DocuSign_Credential__mdt>();
        for(DocuSign_Credential__mdt rec : [Select Id,Label,Account_ID__c,Endpoint__c,IntegratorKey__c,Username__c,Password__c From DocuSign_Credential__mdt Where isActive__c = true LIMIT 1]){
            presentDocusignOrgCredential = rec.Label;
            metaDataLabelToMetaDataTypeMap.put(rec.Label,rec);
        }
    }
    
    public override Boolean shouldRun(){ 
        if(this.isUpdate() && this.isAfter() && !this.hasRun()){ 
            // Check Opportunities and execute the EBSB Automation process if below critrias are met.
            for (User newUsr : (List<User>) this.triggerMap.values()){ 
                User oldUsr = (User)this.triggerOldMap.get(newUsr.Id);
                if(newUsr.DocuSign_User_Id__c != null){
                    /*if(newUsr.isActive != oldUsr.isActive && newUsr.isActive){
                        // User is Activated in Salesforce, Activate Docusign user account as well.
                        // activateDocusignUserWrapperList.add(new ActivateDocusignUserWrapper(newUsr.DocuSign_User_Id__c,newUsr.Firstname+' '+newUsr.Lastname,'Active'));
                    }*/
                    if(newUsr.isActive != oldUsr.isActive && !newUsr.isActive){
                        // User is Deactivated in Salesforce, Deactivate Docusign user account as well.
                        deactivateDocusignUserWrapperList.add(new DeactivateDocusignUserWrapper(newUsr.DocuSign_User_Id__c));
                    }  
                }
            }             
        }
        return /*!activateDocusignUserWrapperList.isEmpty() ||*/ !deactivateDocusignUserWrapperList.isEmpty();
    }
    
    public override void doAction(){
        
        string Docusign_Server_URL = metaDataLabelToMetaDataTypeMap.get(presentDocusignOrgCredential).Endpoint__c+metaDataLabelToMetaDataTypeMap.get(presentDocusignOrgCredential).Account_ID__c+'/users';
        string userName = metaDataLabelToMetaDataTypeMap.get(presentDocusignOrgCredential).Username__c;
        string password = metaDataLabelToMetaDataTypeMap.get(presentDocusignOrgCredential).Password__c;
        string integrationKey = metaDataLabelToMetaDataTypeMap.get(presentDocusignOrgCredential).IntegratorKey__c;        
        string authenticationHeader = '<DocuSignCredentials>' + '<Username>' + userName+ '</Username>' + '<Password>' + password + '</Password>' + 
            '<IntegratorKey>' + integrationKey  + '</IntegratorKey>' + '</DocuSignCredentials>';
        
        /*
        if(!activateDocusignUserWrapperList.isEmpty()){
            //instantiate the generator
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeFieldName('users');
            gen.writeStartArray();
            for(ActivateDocusignUserWrapper wrapObj :activateDocusignUserWrapperList){
                gen.writeStartObject();
                gen.writeStringField('userId',wrapObj.docusignUserId);      
                gen.writeStringField('userName',wrapObj.docusignUserName);        	
                gen.writeStringField('userStatus',wrapObj.docusignloginStatus);
                gen.writeEndObject();
            }
            gen.writeEndArray();
            //end of the parent JSON object
            gen.writeEndObject();
            
            String restReqBody = gen.getAsString();
            // Call Future method REST API callout
            restServiceCalloutForUserActivation(Docusign_Server_URL,authenticationHeader,'PUT',restReqBody);
        }
        */
            
        if(!deactivateDocusignUserWrapperList.isEmpty()){
            //instantiate the generator
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeFieldName('users');
            gen.writeStartArray();
            for(DeactivateDocusignUserWrapper wrapObj :deactivateDocusignUserWrapperList){
                gen.writeStartObject();
                gen.writeStringField('userId',wrapObj.docusignUserId);
                gen.writeEndObject();
            }
            gen.writeEndArray();
            //end of the parent JSON object
            gen.writeEndObject();
            
            String restReqBody = gen.getAsString();
            // Call Future method REST API callout
            restServiceCalloutForUserDeactivation(Docusign_Server_URL,authenticationHeader,'DELETE',restReqBody);
        }
    }
    /*
    @future(callout=true)
    public static void restServiceCalloutForUserActivation(String docusignServerUrl,String restReqHeader,String restReqType,String restReqBody){
        // Create http request class Instance
        HttpRequest req = new HttpRequest();
        // Create http response class Instance
        HttpResponse res = new HttpResponse();        
        // Create http class Instance
        Http http = new Http();       
        // Prepare Http Request for making a REST Callout to Docusign Interface
        req.setEndpoint(docusignServerUrl);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setHeader('X-DocuSign-Authentication',restReqHeader);
        req.setMethod(restReqType);
        req.setBody(restReqBody);
        System.debug('req Header====>>>'+docusignServerUrl);
        System.debug('req Header====>>>'+restReqHeader);
        System.debug('req Header====>>>'+req.getBody());
        System.debug('Http Req ====>>>'+req);
        // Sends REST Request
        res = http.send(req);
        // Get Response Body
        System.debug('res=====>>>>'+res.getBody());
    }
    */
    
    @future(callout=true)
    public static void restServiceCalloutForUserDeactivation(String docusignServerUrl,String restReqHeader,String restReqType,String restReqBody){
        // Create http request class Instance
        HttpRequest req = new HttpRequest();
        // Create http response class Instance
        HttpResponse res = new HttpResponse();        
        // Create http class Instance
        Http http = new Http();       
        // Prepare Http Request for making a REST Callout to Docusign Interface
        req.setEndpoint(docusignServerUrl);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setHeader('X-DocuSign-Authentication',restReqHeader);
        req.setMethod(restReqType);        
        req.setBody(restReqBody);
        // Sends REST Request
        res = http.send(req);
        // Get Response Body
        System.debug('res=====>>>>'+res.getBody());
    }
    
    /*
    // Wrapper Class Declaration for Activating User in Docusign
    public class ActivateDocusignUserWrapper{
        public string docusignUserId;
        public string docusignUserName;
        public string docusignloginStatus;
        // Wrapper class constructor
        public ActivateDocusignUserWrapper(String usrId,String usrName,String lgnStatus){
            this.docusignUserId = usrId;
            this.docusignUserName = usrName;
            this.docusignloginStatus = lgnStatus;
        }
    }
	*/
    
    // Wrapper Class Declaration for User Activation Request in Docusign
    public class ActivateDocusignUserRequestWrapper{
        public List<Users> users;
    }
    
    // Wrapper Class Declaration for Activating User in Docusign
    public class DeactivateDocusignUserWrapper{
        public string docusignUserId;
        // Wrapper class constructor
        public DeactivateDocusignUserWrapper(String usrId){
            this.docusignUserId = usrId;
        }
    }
    
    // Wrapper Class Declaration for User Deactivation Request in Docusign
    public class DeactivateDocusignUserRequestWrapper{
        public List<Users> users;
    }
    
    // Get User List from DocuSign 
    public class DocuSignUsersWrapper{
        public List<Users> users;
        public String resultSetSize;
        public String totalSetSize;
        public String startPosition;
        public String endPosition;
    }
    
    // Get User Object 
    public class Users{
        public String userName;
        public String userId;
        public String userType;
        public String isAdmin;
        public String userStatus;
        public String uri;
        public String email;
        public String createdDateTime;
        public String firstName;
        public String lastName;
        public String permissionProfileId;
        public String permissionProfileName;
        public String jobTitle;
    }
}