/*
//////////////////////////////////////
//      @author Kumud thakur   //
/////////////////////////////////////
Version :   1.0
Date : 18th april 2016
Description : Used to update status of case 
*/

public class CaseStatusExtension{
    
  
    private String caseId,contactID;
    public Case CaseObj{get;private set;}
    public boolean flag{get;private set;}
    public boolean isShow{get;private set;}
    public boolean isclosePopUp{get;private set;}
   
   
    /*  
      Parametrized Constructor

    */
    
    public CaseStatusExtension(ApexPages.StandardController controller){
        
      caseId=ApexPages.currentPage().getParameters().get('id');
      contactID=ApexPages.currentPage().getParameters().get('contactId');
      isShow=false;
      isclosePopUp=true;
      CaseObj=[select caseNumber,Ownerid,status,contactID,contact.name from case where id =:caseId.trim()];
      if(CaseObj.status=='Closed'){
         flag=true;
      }
       else if(CaseObj.contactID==contactID.trim()){
                   isclosePopUp=false;
        }
    }
    
    public void updateCase(){
        caseObj.status='Closed';
        caseObj.Case_Status_L2__c='Resolved';
        //caseObj.Case_Close_ContactBy__c=caseObj.contact.name;
        caseObj.Case_Closed_By_One_Click__c=true;
        
         try{
             update CaseObj;
             isShow=true;
             isclosePopUp=true;
           
             }catch(Exception e){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
                ApexPages.addMessage(myMsg);
             }
             
        
    }
    
  
    Public void cancel(){
      isclosePopUp=true;
    }
    
   
   
  
   
}