/*   
  Author : Kumud thakur
  SOC :  21 December 2015
  DESC: Insert Contract Review on TCV Insertion 
  
  Version 24.0
Date:7th Nov 2016
Description : Migrating FEATURESET to PRODUCT/PRICEBOOK. Below are the name of the field which needs to be replaced - 
    OLD FIELD NAME       = NEW FIELD NAME
    Feature_Sets__r      = OpportunityLineItems;
    R00N00000008aGEXEA2  = OpportunityLineItems;
    Feature_Set__c       = OpportunityLineItem;
    Feature__c           = Product_Name__c;
    Opportunity_N__c     = OpportunityId;
*/

Public class AssignReviewerOpptyTriggerHelper{

/*  

Below method call by Opportunity after insert trigger 
 */
 Public Static void assignContractReviewer(List<Opportunity> listOpportunity){
  
  Set<ID> setOpporunityId=new Set<ID>();
  Set<ID> setOpptyRecordTypeId=new Set<Id>();
  List<Contract_Reviewing__c> listContractReview=new List<Contract_Reviewing__c>();
  Map<ID,String> mapIDVsProduct=new Map<Id,String>();
  Map<String,String> mapProductVsName=new Map<String,String>();
  Map<String,TrackUser__c> mapIDVsTrackUSer=TrackUser__c.getAll(); 
  Set<String> setContractNumber =new Set<String>();  // getAllcustom Setting data
  for(TrackUser__c trackUser:mapIDVsTrackUSer.values()){
        mapProductVsName.put(trackUser.product_name__C,trackUser.name__C);
      
  }//End of loop
  for(Opportunity objOppty:listOpportunity){
    
        setOpporunityId.add(objOppty.Id);
        setOpptyRecordTypeId.add(objOppty.RecordTypeId);
        mapIDVsProduct.put(objOppty.id,objOppty.Product__C);
        //if(objOppty.recordtype.developername=='Tract')
            
  
  }// End of Loop
   Map<Id,RecordType> mapIDVsRecordType=new Map<ID,RecordType>([select developerName from recordType where id in :setOpptyRecordTypeId OR developerName='Account_Team_Level_1' ]); // To get all current oppty RT
    for(Opportunity objOpp:listOpportunity){
     
        if(mapIDVsRecordType.get(objOpp.RecordTypeId).developerName=='Tract')
           setContractNumber.add(objOpp.Contract_Number_New__c);
    }
    List<Contract_Reviewing__c> objContract =new List<Contract_Reviewing__c>();  
    if(setContractNumber.size()>0)
        objContract=[Select Contract_Reviewer__c,Contract_Review_Ok__c,Is_Cancellation__c,Opportunity_Contract__c from Contract_Reviewing__c where Opportunity_Contract__c in :setContractNumber];
  //Map<Id,RecordType> mapIDVsRecordType=new Map<ID,RecordType>([select developerName from recordType where id in :setOpptyRecordTypeId OR developerName='Account_Team_Level_1' ]); // To get all current oppty RT
   // boolean isCancellation=false;
   Set<String> setCancellation =new Set<String>();
    for(Contract_Reviewing__c cRObj:objContract){
      
        if(cRObj.Is_Cancellation__c){
            setCancellation.add(cRObj.Opportunity_Contract__c);
            
        }
    }
  String recordTypeId;  // it is for contract Review 
  for(RecordType objRT:mapIDVsRecordType.values()){
      if(objRT.developerName=='Account_Team_Level_1'){
            recordTypeId=objRT.id;
            break;
      }     
      
  }// end of loop
  
  for(Opportunity objOpp:listOpportunity){
     
        if(mapIDVsRecordType.get(objOpp.RecordTypeId).developerName=='Tract' && !setCancellation.contains(objOpp.Contract_Number_New__c) ){
            
            
          Contract_Reviewing__c contractReview = new Contract_Reviewing__c();
          contractReview.RecordTypeID=recordTypeId;
          contractReview.Opportunity__c=objOpp.id;
          contractReview.Accounting_Team_Reviewer__c=mapProductVsName.keySet().contains(mapIDVsProduct.get(objOpp.id))?mapProductVsName.get(mapIDVsProduct.get(objOpp.id)):null;
          contractReview.CurrencyIsoCode=objOpp.CurrencyIsoCode;
          if(objContract.size()>0)
              contractReview.Contract_Reviewer__c=objContract[0].Contract_Reviewer__c;
          contractReview.Contract_Review_Ok__c='Yes';
          listContractReview.add(contractReview);
          
        } //End of IF 
      
      
  }// End of Loop
   
  if(listContractReview.size()>0)
  {
      
      insert listContractReview;
  }   
   
  
 
 
 }

 /*   
   Method to determine whether it is hybrid opportunity or not 
 
 */
 Public static Map<Id,Boolean> isHybridOppty(Set<ID> setOppids){
   
    Map<Id,Boolean>  mapOppIdIsHybrid=new Map<Id,Boolean>();
    Set<String> setAllHybridValue =new Set<String>();
    for(HybridPicklistValue__c hybridValue:HybridPicklistValue__c.getall().values())  {
        setAllHybridValue.add(hybridValue.HybridValue__c);
    }
    
    
     for(OpportunityLineItem fSet:[select OpportunityId,Product_Name__c from OpportunityLineItem where OpportunityId in :setOppids]){
         if(setAllHybridValue.contains(fSet.Product_Name__c)){
            mapOppIdIsHybrid.put(fSet.OpportunityId,true);
         }else {
            mapOppIdIsHybrid.put(fSet.OpportunityId,false);  
         }
     }
    return mapOppIdIsHybrid;
 
 }
 
/* 
  Call on before update of opportunity to lock or unlock validation check


 */
/* public static void beforeUpdateValidation(List<Opportunity> listOpportunity){
    system.debug('*********************listOpportunity'+listOpportunity);
    Set<String> setContractNumber =new Set<String>();
    //Map<Id,Opportunity> mapNonTCVOppty=new Map<Id,Opportunity>();
    //Map<String,Opportunity> mapTCVOppty=new Map<String,Opportunity>();
    Map<String,List<Contract_Reviewing__c>> mapNumberVsContracts =new Map<String,List<Contract_Reviewing__c>>();
    for(Opportunity opp:listOpportunity){
        
        setContractNumber.add(opp.Contract_Number_New__c);
        
    }
    List<Contract_Reviewing__c> listTCVContracts=new List<Contract_Reviewing__c>([Select Acc_Review_Post_Rev_Rec_OK__c,Contract_Value_50k_review_Ok__c,Contract_Value_50k__c,Acc_Review_Post_Rev_Rec__c,Accounting_Team_Reviewer__c, Contract_Value_100k_review_Ok__c,Contract_Value_100k__c,opportunity__r.Contract_Number_New__c from Contract_Reviewing__c where opportunity__r.recordtype.developername='Tract' and opportunity__r.Contract_Number_New__c in :setContractNumber]);
    List<Contract_Reviewing__c> templistContracts=new List<Contract_Reviewing__c>();
    system.debug('----------------------->listTCVContracts'+listTCVContracts);
    for(Contract_Reviewing__c objContract:listTCVContracts){
        if(mapNumberVsContracts.keySet().contains(objContract.opportunity__r.Contract_Number_New__c)){
            templistContracts.add(objContract);
            mapNumberVsContracts.put(objContract.opportunity__r.Contract_Number_New__c,templistContracts);
        }else {
            templistContracts=new List<Contract_Reviewing__c>();
            templistContracts.add(objContract);
            mapNumberVsContracts.put(objContract.opportunity__r.Contract_Number_New__c,templistContracts);
            
        }
        
    }
    system.debug('****-----------------'+mapNumberVsContracts);
    boolean flag=false;
    Set<String> setUser=new Set<String>();
    for(Opportunity objOpp:listOpportunity){
         
         if(mapNumberVsContracts.keyset().contains(objOpp.Contract_Number_New__c)){
             
             for(Contract_Reviewing__c objContract:mapNumberVsContracts.get(objOpp.Contract_Number_New__c)){
                 system.debug('objContract.Contract_Value_100k_review_Ok__c****'+objContract.Contract_Value_100k_review_Ok__c);
                 system.debug('objContract.Contract_Value_50k_review_Ok__c****'+objContract.Contract_Value_50k_review_Ok__c);
                 system.debug('objContract.Acc_Review_Post_Rev_Rec_OK__c****'+objContract.Acc_Review_Post_Rev_Rec_OK__c);
                 system.debug('**********Contract_Value_50k__c'+objContract.Contract_Value_50k__c);
                 system.debug('**********Acc_Review_Post_Rev_Rec__c'+objContract.Acc_Review_Post_Rev_Rec__c);
                 system.debug('**********Accounting_Team_Reviewer__c'+objContract.Accounting_Team_Reviewer__c);
                 System.debug('*****************************-----'+UserInfo.getName());
                 
                 
                   // Level 4 rejection then Level 3 will be editable
                   if(objContract.Contract_Value_100k_review_Ok__c=='No'){
                       setUser.add(objContract.Contract_Value_50k__c);
                      //objOpp.addError('You are not allow to edit.Only '+objContract.Contract_Value_50k__c    +' is allow'); 
                      
                   }
                   // Level 3 rejection then Level 2 will be editable
                   if( objContract.Contract_Value_50k_review_Ok__c=='No'){
                        setUser.add(objContract.Acc_Review_Post_Rev_Rec__c);
                      //objOpp.addError('You are not allow to edit.Only '+objContract.Acc_Review_Post_Rev_Rec__c +' is allow'); 
                      
                   }
                   // Level 2 rejection then Level 2 will be editable
                   if(objContract.Acc_Review_Post_Rev_Rec_OK__c=='No'){
                       setUser.add(objContract.Accounting_Team_Reviewer__c);
                      //objOpp.addError('You are not allow to edit.Only '+objContract.Accounting_Team_Reviewer__c +' is allow'); 
                      
                   }
                   
                 
             }
             
         }
       
    }
    
    
     for(Opportunity objOpp:listOpportunity){
            if(mapNumberVsContracts.keyset().contains(objOpp.Contract_Number_New__c)){
                    if(!setUser.contains(UserInfo.getName()))
                        objOpp.addError('You are not allow to edit');
            
            }
            
        }
    
    
    
    
    
    
}// End of method*/

}