Public Class Quota_Approval_VF_Component_Controller{
// ===============================
// AUTHOR     : Shanu Aggarwal    
// CREATED DATE     : 25/02/2016
// PURPOSE     :  To Genereate Approval URL For Quota Changes Request
// SPECIAL NOTES:
// TEST CLASS: Quota_Approval_VF_Component_Ctr_Test
// ===============================
// Change History:
//
//==================================


      public String recID {get; set;}  
      public String quotaApprovalStatus{get; set;}  
     
      public String geturlStr(){  
         return generateApprovalURL(recID);  
      }
   
   
      public String generateApprovalURL(String recordID){  
          String url='';  
            
          List<ProcessInstanceWorkitem> workItemLst =   
            [SELECT id  
          FROM ProcessInstanceWorkitem  
          WHERE processInstance.TargetObjectId=:recordID];   
            
          if(workItemLst.size() > 0)  
          {  
             
            url='https://'+ System.URL.getSalesforceBaseUrl().getHost() +   
             '/p/process/ProcessInstanceWorkitemWizardStageManager?id=' + workItemLst[0].id;      
         }  
         return url;  
       }  
       
       //Get Approval Comments 
       public String getApprovalComment() {
          
          if (recID!= null) {
            Quota_Allocation__c qAllocation = [Select Id, 
                                (Select TargetObjectId, Comments, ActorId From ProcessSteps order by CreatedDate desc Limit 1) 
                                from Quota_Allocation__c where Id = :recID];
            return qAllocation.ProcessSteps[0].Comments;
          }
          
          return '';
        }

}