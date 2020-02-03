/*==========================================================================================================
//Created by Rishi Ojha 
//Trigger is used to update RFP records on certain conditions
//Test class for the trigger is : TestUniqueRFPTrigger
============================================================================================================*/


trigger UpdateChildRFPs on Unique_RFPs__c (after insert,after update) 
{
    Set<Id> UrfIdSet=new Set<ID>();
    Set<String> StatusSet=new Set<String>{'Awaiting Proposal'};
    List<RFP__c> RFPListforUpdate=new List<RFP__c>();
    List<RFP__c> RFPUncheckListforUpdate=new List<RFP__c>();
    for(Unique_RFPs__c urfp:trigger.new)
    {
    UrfIdSet.add(urfp.id);
    
    }
    if(UrfIdSet.size()>0)
    {
           for(Unique_RFPs__c urfp_iterator:[SELECT Name,ID,Status__c,Escalated_RFP__c,(Select id,Name,Status__c,Escalated_RFP__c from RFPs__r) FROM Unique_RFPs__c where id in:UrfIdSet])
           {
              if(urfp_iterator.Escalated_RFP__c==true)
              {
                 for(RFP__c rfp_iterator:urfp_iterator.RFPs__r)
                 
                 {
                 if(StatusSet.contains(rfp_iterator.Status__c)) 
                 
                 {
                 rfp_iterator.Escalated_RFP__c=true; 
                 RFPListforUpdate.add(rfp_iterator);
                   }
                 }
             }
            /* else
             {
               for(RFP__c rfp_iterator:urfp_iterator.RFPs__r)
                { 
                rfp_iterator.Escalated_RFP__c=false;
                RFPUncheckListforUpdate.add(rfp_iterator);
                   }
              
             } */
           
           }
      }
   
   if(RFPListforUpdate.size()>0) 
   { 
   
   update RFPListforUpdate; 
   
   }
  /* if(RFPUncheckListforUpdate.size()>0)
   
    { 
    update RFPUncheckListforUpdate;
   } */
}