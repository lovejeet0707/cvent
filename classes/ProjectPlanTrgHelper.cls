Public Class ProjectPlanTrgHelper {

// ===============================
// AUTHOR     :  SHANU AGGARWAL
// CREATE DATE     :  5 FEB 2016
// PURPOSE     :  PROJECT PLAN TRIGGER HELPER
// TEST CLASS: ProjectPlanTrgHelperTest
// SPECIAL NOTES:
// ===============================
// Change History:
// Ver 2.0 : Project Estimated/Revised Timeline Auto Update
//==================================

    Map<String, Schema.SobjectField> fields  = Project_Plan_SOW_EB__c.getSObjectType().getDescribe().fields.getMap();
    
    Public void OnBeforeInsert(List<Project_Plan_SOW_EB__c> newValues){ 
        
        //Validation for EB SB
        For( Project_Plan_SOW_EB__c pPlan : newValues ){
            If( pPlan.Project_Plan_Status__c == 'Generate Project Plan' )
            PopulateMilestoneBasedonComplexity(newValues,null);
            else{            
            pPlan.Project_Plan_Status__c.addError('Please Generate New Project Plan');
            }
        
        }
    }   
  
    Public void OnBeforeUpdate( List<Project_Plan_SOW_EB__c> newValues, Map<Id,Project_Plan_SOW_EB__c> oldValues){
        PopulateMilestoneBasedonComplexity(newValues,oldValues);
        AutoUpdateRevisedTimeline(newValues,oldValues);
    }
    
    

    
    //Auto-Update the Revised Timelines on EB SB object once any of the Revised timeline changed,
    //Only Subsequent Revised Timeline should be updated with the difference of Expected and Revised timeline. 
    public void AutoUpdateRevisedTimeline( List<Project_Plan_SOW_EB__c> newValues , Map<Id,Project_Plan_SOW_EB__c> oldValues ){
        
        //Custom Setting Data in ascending field sequqnece (This is the reason to make SOQL)
        Map<Integer,Project_Plan_Revised__c> revisedSettingsMap  = new Map<Integer,Project_Plan_Revised__c>();
        for( Project_Plan_Revised__c pPlanobj : [ Select Name,Field_Sequence__c,Revised_Timeline_API_Name__c,Expected_Timeline_API_Name__c,Timeline_Reason_API_Name__c,Actual_Timeline_API_Name__c 
                                                  From Project_Plan_Revised__c ORDER BY Field_Sequence__c ASC ]){
            
            revisedSettingsMap.put( Integer.ValueOf(pPlanobj.Field_Sequence__c), pPlanobj);
            
        }
        
        //Converting Map values into List 
        List<Project_Plan_Revised__c>  settingsList = revisedSettingsMap.Values();
        
        List<Project_Plan_SOW_EB__c>  listToUpdate = new List<Project_Plan_SOW_EB__c>();
        
        
        //Iterating over new records 
        for( Project_Plan_SOW_EB__c  projPlanRec :  newValues ){
 
            
            //For each Record checking Revised timeline Values  
            for( Project_Plan_Revised__c  pRevisedSetting : settingsList ){
                
                System.debug('@@ Sequence @@@' + pRevisedSetting.Field_Sequence__c);
                //API Names for current set in Revised Timeline
                Integer fieldSequence = Integer.valueOf(pRevisedSetting.Field_Sequence__c);
                String  revisedFieldApiName  = pRevisedSetting.Revised_Timeline_API_Name__c;
                String  expectedFieldApiName =  pRevisedSetting.Expected_Timeline_API_Name__c;
                String  timelineReasonFieldApiNAme = pRevisedSetting.Timeline_Reason_API_Name__c;
                
                //Actual timeline fields
                String  actualFieldApiName = pRevisedSetting.Actual_Timeline_API_Name__c;
                Date actualDate = (Date)projPlanRec.get(actualFieldApiName);
                
                
                //Date Values of Expected and Revised Timeline fields
                Date expectedDate = (Date)projPlanRec.get(expectedFieldApiName);
                Date revisedDateNew =   (Date)projPlanRec.get(revisedFieldApiName);
                
                //Debug Statements
                System.Debug(' **** actualFieldApiName **  ' + actualFieldApiName); 
                System.Debug(' **** revisedFieldApiName **  ' + revisedFieldApiName);
                System.Debug(' **** revisedDateNew **  ' + revisedDateNew);
                System.Debug(' **** revisedDateOld **  ' + trigger.oldMap.get(projPlanRec.Id).get(revisedFieldApiName));
                System.Debug(' **** expectedFieldApiName **  ' + expectedFieldApiName);
                System.Debug(' **** expectedDate **  ' + expectedDate);                 
                System.Debug(' **** timelineReasonFieldApiNAme**  ' + timelineReasonFieldApiNAme);             
                System.Debug(' **** Current fieldSequence **  ' + fieldSequence);
                System.Debug(' **** Last fieldSequence **  ' + settingsList.get(settingsList.size()-1).Field_Sequence__c);
                //System.Debug(' **** Days Differecnce **  ' + CalculateWorkingDays.ReturnDiffBtwDates((Date)projPlanRec.get(expectedFieldApiName), (Date)projPlanRec.get(revisedFieldApiName)));
               
                
                /***    ******START******** 
                ****
                ****  WHEN REVISED TIMELINE CHANGED
                ****  UPDATING REST OF THE REVISED TIMELINES IN THE SEQUENCE FROM UP TO DOWN
                ****
                ***/
                if( trigger.oldMap!=null && revisedDateNew != trigger.oldMap.get(projPlanRec.Id).get(revisedFieldApiName) && expectedDate!=null ){

                    /******
                        All Validation Checks
                        1) Expected Date is required if timleline is revisedDateNew
                        2) New Launch date needed 
                        3) If New Launch date 
                        4) Timeline reason is required. 
                    *******/
                    
                    //Must have expected date 
                    if( expectedDate==null ){
               
                        projPlanRec.addError( 'You can not change revised timeline without expected timeline');
                        break;
                    }
                    //Must have Is Launch Date Selected
                    else if( projPlanRec.Is_Launch_Date_Revised__c == null || projPlanRec.Is_Launch_Date_Revised__c == ''){
                        projPlanRec.Is_Launch_Date_Revised__c.addError(  'Please select this field ');
                        break;
                    }
                    //Must have Reason field selected 
                    else if( projPlanRec.get(timelineReasonFieldApiNAme)=='' || projPlanRec.get(timelineReasonFieldApiNAme) == trigger.oldMap.get(projPlanRec.Id).get(timelineReasonFieldApiNAme)  ){
                            
                          string fieldLabel = Schema.SobjectType.Project_Plan_SOW_EB__c.fields.getMap().get(timelineReasonFieldApiNAme).getDescribe().getLabel();   
                          projPlanRec.addError(    fieldLabel + ' Required '   );
                          break; 
                    }
                    
                    
                    
                    //Difference between Expected and Revised dates
                    Integer diff =  CalculateWorkingDays.ReturnDiffBtwDates(expectedDate,revisedDateNew);
                    
                    
                    //Last Sequence of Revised Timeline in the list
                    Integer lastIndex =  Integer.ValueOf(settingsList.get(settingsList.size()-1).Field_Sequence__c);
                    
                    if( projPlanRec.Is_Launch_Date_Revised__c == 'Yes'){
                        
                        projPlanRec.put( 'Event_Launch_Revised_Timeline__c', CalculateWorkingDays.AddBusinessDays(projPlanRec.Event_Launch_Expected_Timeline__c, diff));
                    }
                    
                    
                    //Iterating remaining revised timeline fields to update 
                    for(integer i=fieldSequence ; i<=lastIndex ; i++){
                        
                        
                        //Current Timeline Fields API Name 
                        Project_Plan_Revised__c setting = revisedSettingsMap.get(i);
                        Date currnetExpectedDate =  (Date)projPlanRec.get(setting.Expected_Timeline_API_Name__c);
                        
                        
                        
                        System.debug('#### currnetExpectedDate ### ' + currnetExpectedDate); 
                        
                        if( currnetExpectedDate !=null ){
                            
                            System.debug('#### Exepcted Field ### ' + setting.Expected_Timeline_API_Name__c); 
                            System.debug('#### Field Name ### ' + setting.Revised_Timeline_API_Name__c);
                            System.debug('#### Value ### ' + CalculateWorkingDays.AddBusinessDays(currnetExpectedDate,diff));

                            
                            Date revisedDateAfterAdd = CalculateWorkingDays.AddBusinessDays(currnetExpectedDate, diff);
                            
                            //Whichvever launch date is greater between revised and expected
                            Date launchDateToCompare= projPlanRec.Event_Launch_Revised_Timeline__c > projPlanRec.Event_Launch_Expected_Timeline__c ?  projPlanRec.Event_Launch_Revised_Timeline__c : projPlanRec.Event_Launch_Expected_Timeline__c ;
                            
                            
                            System.debug('#### revisedDateAfterAdd ### ' + revisedDateAfterAdd); 
                            System.debug('#### Is_Launch_Date_Revised__c ### ' +  projPlanRec.Is_Launch_Date_Revised__c); 
                            
                            //If Launch Date is not Revised , skip the ROC if required 
                            if( projPlanRec.Is_Launch_Date_Revised__c == 'No' && revisedDateAfterAdd >  launchDateToCompare ){
                                
                                projPlanRec.put( setting.Revised_Timeline_API_Name__c, null);
                                projPlanRec.put( setting.Expected_Timeline_API_Name__c, null);
                                projPlanRec.put( setting.Timeline_Reason_API_Name__c, null);
                                
                                System.debug('@@@ Related Field Seq @@ ' + setting.Field_Sequence__c);
                                //System.debug('@@@ Field to Remove @@ ' + revisedSettingsMap.get((Integer)setting.Field_Sequence__c-1).Revised_Timeline_API_Name__c);
                                System.debug('@@@ Contains Completed @@ ' +  setting.Expected_Timeline_API_Name__c.contains('Completed'));
                                System.debug('@@@ Expected_Timeline_API_Name__c @@ ' +  setting.Expected_Timeline_API_Name__c);
                                
                                
                                //IF Completed timlines becoms null then Related timelines will also become null 
                                if( setting.Expected_Timeline_API_Name__c.contains('Completed') ){
                                    System.debug('ENTER*******');
                                    projPlanRec.put( revisedSettingsMap.get((Integer)setting.Field_Sequence__c-1).Revised_Timeline_API_Name__c, null);
                                    projPlanRec.put( revisedSettingsMap.get((Integer)setting.Field_Sequence__c-1).Expected_Timeline_API_Name__c, null);
                                    projPlanRec.put( revisedSettingsMap.get((Integer)setting.Field_Sequence__c-1).Timeline_Reason_API_Name__c, null);
                                    
                                }
                               
                                
                                
                            }
                            else{
                                //Updating remaining revised fields with the difference of Expected and Revised for changed field 
                                projPlanRec.put( setting.Revised_Timeline_API_Name__c, revisedDateAfterAdd);
                            }
                        }
                    }
                    
                   break;                                      
                }  
                
                /**
                **  END REVISED TIMELINE 
                **/
                
                
                 
                /***    ******START******** 
                ****
                ****  WHEN ACTUAL TIMELINE CHANGED
                ****  UPDATING REVISED TIMELINES ONLY LESS THAN ACTUAL TIMELINE
                ****
                ***/
                else if( trigger.oldMap!=null && actualDate != trigger.oldMap.get(projPlanRec.Id).get(actualFieldApiName)){
                    
                    //Get assoicated Revised Timeline (Preferred) / Expected Timeline
                    Date dateToCompare =  revisedDateNew!=null ? revisedDateNew : expectedDate;
                    
                    //Actual Timeline should be less than Expected OR Revised Timeline
                    if(dateToCompare!=null && actualDate < dateToCompare){
                            
                        //Difference between Actual Date and Expected/Revised Date
                        Integer diff =  CalculateWorkingDays.ReturnDiffBtwDates(actualDate,dateToCompare);
                        
                        
                        //Last Sequence of Revised Timeline in the list
                        Integer lastIndex =  Integer.ValueOf(settingsList.get(settingsList.size()-1).Field_Sequence__c);
                        
                        
                        //Iterating remaining revised timeline fields to update 
                        for(integer i=fieldSequence+1; i<=lastIndex; i++){
                                         
                            //Current Timeline Fields API Name 
                            Project_Plan_Revised__c setting = revisedSettingsMap.get(i);
                        
                            Date nextExpectedDate =  (Date)projPlanRec.get(setting.Expected_Timeline_API_Name__c);
                            Date nextRevisedDate =  (Date)projPlanRec.get(setting.Revised_Timeline_API_Name__c);
                            
                            
                            Date expectedORRevised = nextRevisedDate!=null ? nextRevisedDate : nextExpectedDate;
                            System.Debug('***expectedORRevised***'+ expectedORRevised);
                            System.Debug('***diff***'+ diff);
                            
                            //Populate Revised Timleine
                            if(expectedORRevised!=null){
                                //Removing working days difference calculated
                                Date revisedDate = CalculateWorkingDays.AddBusinessDays(expectedORRevised, -diff);
                                projPlanRec.put(setting.Revised_Timeline_API_Name__c, revisedDate);
                            }

                        }
                        Date launchDate =  projPlanRec.Event_Launch_Revised_Timeline__c!=null ? projPlanRec.Event_Launch_Revised_Timeline__c: projPlanRec.Event_Launch_Expected_Timeline__c ;
                        projPlanRec.put('Event_Launch_Revised_Timeline__c', CalculateWorkingDays.AddBusinessDays(launchDate, -diff));
                        
                    }
                    
                    break;
                    
                }   
                /**
                **  END ACTUAL TIMELINE 
                **/
    
            }  
            //Blank out the below field for next milestone change 
             //projPlanRec.Is_Launch_Date_Revised__c = ''; 
        }
         
    }

    

  
    //EB-SB Milestone Project
    //This method is used to populate milestone date on Project Plan based on RequestType and Complexity
    //Only Working days allowed to calculate
    Public void PopulateMilestoneBasedonComplexity(List<Project_Plan_SOW_EB__c> newValues , Map<Id,Project_Plan_SOW_EB__c> oldValues){
  
      For ( Project_Plan_SOW_EB__c pPlan : newValues )
        {

                
               // If( oldValues!=null && pPlan.Project_Plan_Status__c == 'Freeze project Plan' && oldValues.get(pPlan.Id).Information_Received__c != pPlan.Information_Received__c  ){
                    //pPlan.addError('You can not generate new timelines');
               // }
               //If Project Plan is new (Only 'Generate Project Plan' can be selected )
               If( Trigger.isInsert && pPlan.Project_Plan_Status__c != 'Generate Project Plan' ){
                   pPlan.Project_Plan_Status__c.addError('Please Generate New Project Plan');
               }
            
               else { 
                            
                String dataSetName = pPlan.Request_Type__c  + ' ' + pPlan.Project_Complexity__c.substringAfter('-');
                Project_Plan_Milestone__c projectPlanSettings =  Project_Plan_Milestone__c.getValues(dataSetName);
                
                //Updating Project Plan No of Working Days based on Request Type, Milestone and Complexity
                pPlan.Event_Setup_Call_Expected_Timeline__c= CalculateWorkingDays.AddBusinessDays(pPlan.Information_Received__c, Integer.valueOf(projectPlanSettings.Event_Setup_Call_Expected_Date__c));
                pPlan.FD_Completed_Expected_Date__c = CalculateWorkingDays.AddBusinessDays(pPlan.Information_Received__c, Integer.valueOf(projectPlanSettings.FD_Completed_Expected_Date__c));
                pPlan.X1st_ROC_Completed_Expected_Date__c = CalculateWorkingDays.AddBusinessDays(pPlan.Information_Received__c, Integer.valueOf(projectPlanSettings.X1st_ROC_Completed_Expected_Date__c));
                pPlan.X1st_ROC_Received_Expected_Date__c = CalculateWorkingDays.AddBusinessDays(pPlan.Information_Received__c, Integer.valueOf(projectPlanSettings.X1st_ROC_Received_Expected_Date__c));
                pPlan.X2nd_ROC_Received_Expected_Date__c = CalculateWorkingDays.AddBusinessDays(pPlan.Information_Received__c, Integer.valueOf(projectPlanSettings.X2nd_ROC_Received_Expected_Date__c));
                pPlan.X2nd_ROC_Completed_Expected_Date__c = CalculateWorkingDays.AddBusinessDays(pPlan.Information_Received__c, Integer.valueOf(projectPlanSettings.X2nd_ROC_Completed_Expected_Date__c));
                pPlan.X3rd_ROC_Completed_Expected_Date__c = CalculateWorkingDays.AddBusinessDays(pPlan.Information_Received__c, Integer.valueOf(projectPlanSettings.X3rd_ROC_Completed_Expected_Date__c));
                pPlan.X3rd_ROC_Received_Expected_Date__c = CalculateWorkingDays.AddBusinessDays(pPlan.Information_Received__c, Integer.valueOf(projectPlanSettings.X3rd_ROC_Received_Expected_Date__c));
                pPlan.Event_Testing_Expected_Date__c = CalculateWorkingDays.AddBusinessDays(pPlan.Information_Received__c, Integer.valueOf(projectPlanSettings.Event_Testing_Expected_Date__c));
                pPlan.Event_Launch_Expected_Date__c = CalculateWorkingDays.AddBusinessDays(pPlan.Information_Received__c, Integer.valueOf(projectPlanSettings.Event_Launch_Expected_Date__c));
                pPlan.Addnl_Info_Received_Expected_Date__c = CalculateWorkingDays.AddBusinessDays(pPlan.Information_Received__c, Integer.valueOf(projectPlanSettings.Addnl_Info_Received_Expected_Date__c));
                
            }
        }
  
    }
  
    

}