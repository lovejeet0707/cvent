public class FeedbackCls{
    public static List<CLS_Assignment_Id__c> lstCLSAssgn = new List<CLS_Assignment_Id__c>();
    private Map<String, FeedBackOwnerList__c> FeedBackOwnerListMap;
    static{
        lstCLSAssgn = CLS_Assignment_Id__c.getall().values();
    }
    public Case instOfCase{get;set;}
    public FeedbackCls(ApexPages.StandardController controller) {
        //Case instOfCase =(Case)controller.getRecord();
        FeedBackOwnerListMap = new Map<String, FeedBackOwnerList__c>();  
        FeedBackOwnerListMap = FeedBackOwnerList__c.getAll();
        instOfCase = new Case();
        RecordType instOfRecType = [SELECT Id FROM RecordType WHERE DeveloperName='Customer_Listening_System'];
        instOfCase.RecordTypeId = instOfRecType.Id;
    }
    public pagereference save(){
        try{
            User instOfUser = [SELECT Id,ContactId FROM User WHERE Id =: UserInfo.getUserId()];
            
            instOfCase.ContactId = instOfUser.ContactId;
            
            //if(instOfUser.ContactId == null)
            instOfCase.ownerId = FeedBackOwnerListMap!=null?(FeedBackOwnerListMap.containsKey(instOfCase.Feedback_Driver__c)?FeedBackOwnerListMap.get(instOfCase.Feedback_Driver__c).Queue_Id__c:lstCLSAssgn[0].X18_Digit_Client_Serv_VP_Id__c):lstCLSAssgn[0].X18_Digit_Client_Serv_VP_Id__c;//lstCLSAssgn[0].X18_Digit_Client_Serv_VP_Id__c;
            
            system.debug('Test++'+instOfCase.Feedback_Type__c);
            system.debug('Test++'+instOfCase.Feedback_Driver__c);
            system.debug('Test++'+instOfCase.Product_Type__c);
            instOfCase.origin = 'Customer Portal'; 
            if(instOfCase.Feedback_Driver__c == 'Product'&& instOfCase.Product_Type__c ==null){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Which Product?: You must enter a value');
                ApexPages.addMessage(myMsg);
                return null;
            }
            if(instOfCase.Description == null || instOfCase.Description == ''){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Feedback: You must enter a value');
                ApexPages.addMessage(myMsg);
                return null;
            }
            insert instOfCase;
            
            
            
            //update instOfCase;
        }
        catch(DmlException ex){
            ApexPages.addMessages(ex);
            return null;
        }
        if(instOfCase.Id != null){
            PageReference pageRef = new PageReference('/apex/FeedbackMessage');
            pageRef.setredirect(true);
            return pageRef; 
        }
        return null;
    }
    
    public pagereference  cancel(){
        PageReference pageRef = new PageReference('/apex/SupportPage');
        pageRef.setredirect(true);
        return pageRef; 
    }
}