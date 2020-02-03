/* ===============================
AUTHOR     :     Udita Dwivedi   
CREATED DATE   : 27 JAN 2020
PURPOSE     :    Custom Opportunity Splits - Record Team Designation
TEST CLASS :     CustomOppSplitTrgHandler_Test
SPECIAL NOTES:   Stamp a "Team" on the Custom Opportunity Split record, so that the split can be properly allocated to the team.
============================= 
*/

public class CustomOppSplitTrgHandler {

  public void OnBeforeInsert(List<Custom_Opportunity_Splits__c > newValues){    
     COSETeamAssignment(newValues,null,null);
  }
  
  public void OnBeforeUpdate(List<Custom_Opportunity_Splits__c > newValues,Map<Id,Custom_Opportunity_Splits__c > oldMapValues,Map<Id,Custom_Opportunity_Splits__c > newMapValues){ 
     system.debug('-----before update');
     COSETeamAssignment(newValues,oldMapValues,newMapValues);
  }
  
  public static void COSETeamAssignment(List<Custom_Opportunity_Splits__c > newValues,Map<Id,Custom_Opportunity_Splits__c > oldMapValues,Map<Id,Custom_Opportunity_Splits__c > newMapValues){ 
     Map<String, String> CustOppMap = new Map<String, String>();
     set<Id> oppSplitId = new set<Id>();
     for(CustomOppSplit__mdt oppSplit: [SELECT MasterLabel, Team__c FROM CustomOppSplit__mdt]){
        CustOppMap.put(oppSplit.MasterLabel, oppSplit.Team__c);}
        system.debug('----CustOppMap' + CustOppMap);
        
     for(Custom_Opportunity_Splits__c split : newValues){
       system.debug('----split.Team_Member__c' + split.Team_Member__c);
       if((oldMapValues==null && split.Team_Member__c != null ) || ((!oldMapValues.isEmpty() && split.Team_Member__c != oldMapValues.get(split.Id).Team_Member__c && split.Team_Member__c != null))){
           if(split.Team_Member__c != null && CustOppMap.containsKey(split.Team_Member_Name__c)){
             split.Team__c = CustOppMap.get(split.Team_Member_Name__c);
          }else if(split.Team_Member_Role__c != null && CustOppMap.containsKey(split.Team_Member_Role__c)){
             split.Team__c = CustOppMap.get(split.Team_Member_Role__c);
          }else if(split.Team_Member_Role__c != null && CustOppMap.containsKey(split.Team_Member_Role__c.substringBetween('(',')'))){
             split.Team__c = CustOppMap.get(split.Team_Member_Role__c.substringBetween('(',')'));
          }else if(split.Team_Member_Role__c == null && split.Team_Member_Manager_Role__c != null && CustOppMap.containsKey(split.Team_Member_Manager_Role__c)){
             split.Team__c = CustOppMap.get(split.Team_Member_Manager_Role__c);
          }else if(split.Team_Member_Role__c == null && split.Team_Member_Manager_Role__c != null && CustOppMap.containsKey(split.Team_Member_Manager_Role__c.substringBetween('(',')'))){
             split.Team__c = CustOppMap.get(split.Team_Member_Manager_Role__c.substringBetween('(',')'));
          }
       }       
     }

  }

}