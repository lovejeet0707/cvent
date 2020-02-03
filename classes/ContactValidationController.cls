public class ContactValidationController{

    Id conId;
    public ContactValidationController(ApexPages.StandardController ctr){
        conId= ctr.getId();
    }
    
    public PageReference validate(){
        
        Contact con = new Contact();
        con.Id = conId;
        con.Contact_Validated_Date__c = System.now();
        con.Contact_Validated_By__c= UserInfo.getName();
        update con;            
     

        return new PageReference ('/'+ conId) ;
    }
    
}