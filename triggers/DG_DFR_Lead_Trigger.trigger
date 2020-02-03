trigger DG_DFR_Lead_Trigger on Lead (after insert, after update, before insert, before update,before delete) {
       
       Boolean Disable_DFR = false;
       
       try{
          if(System.Label.Disable_DFR == '1'){
                 Disable_DFR = true;
          }
       }catch(exception e){}
       
       if(!Disable_DFR){
              
              if(trigger.isInsert && trigger.isAfter){
             DG_DFR_Class.CreateLeadDFR(Trigger.new);      
           }        
              
              
           if(Trigger.isUpdate && trigger.isAfter){
                     if(DG_DFR_Class.LeadAfterUpdate_FirstRun || test.isRunningTest()){                    
                           DG_DFR_Class.DFR_LeadStatusChange(trigger.new,trigger.oldMap);    
                     DG_DFR_Class.LeadAfterUpdate_FirstRun=false;
                     }      
                     
                     
                     if(DG_DFR_Class.LeadConversion_FirstRun || test.isRunningTest()){                     
                           DG_DFR_Class.DFR_LeadConversion(trigger.new,trigger.oldMap);                                  
                     DG_DFR_Class.LeadConversion_FirstRun=false;
                     }
                     
              }
              
       }
       
       if(trigger.isBefore){
       
           if(trigger.isInsert){
               if(CheckRecursive.runTwentyNine() && Label.PhoneNumberValidator == 'True')
               PhoneNumberValidator_Clone.updateLeadPhoneNumber(trigger.new,new Map<Id,Lead>());
               trg_GDPRContactTrg.OnBeforeInsert(Trigger.new);   // Added by udita : 05/17/2018 [When a lead is marked GDPR this method is called]
               
           }else if(trigger.isUpdate){
               LeadTriggerHelper.onBeforeUpdate(Trigger.oldMap, Trigger.newMap); 
               /******Preventing PayGo lead from conversion. Only informatica user can do it****/
                Set<String> authorizedUserSet = new Set<String>();
                //Accessing custom setting.....................
                For(PayGo_Records_Delete_Prevention__c PG : PayGo_Records_Delete_Prevention__c.getall().values()){
                    authorizedUserSet.add(PG.Name);
                }
        
                For(Lead leadRec : trigger.new){
                    if(authorizedUserSet.size()>0 && String.IsNotBlank(leadRec.GUI_ID__c) && leadRec.IsConverted && !authorizedUserSet.contains(UserInfo.getUserId()) && leadRec.IsConverted != trigger.oldMap.get(leadRec.id).IsConverted){
                        leadRec.addError('This is a paygo Lead and should be converted via automated process upon account activation. Please create a new lead/contact record and move tasks.');
                    }
                }
                /****************Ends Here***********************/
               if(CheckRecursive.runThirtyThree() && Label.PhoneNumberValidator == 'True')
               PhoneNumberValidator_Clone.updateLeadPhoneNumber(trigger.new, Trigger.newMap);
               trg_GDPRContactTrg.OnBeforeUpdate(Trigger.oldMap, Trigger.newMap);  // Added by udita : 05/17/2018 [When a lead is marked GDPR this method is called]     
           }
       
       }
       
        if(Trigger.isUpdate && trigger.isAfter){
            trg_GDPRContactTrg.insertGDPR_Lead(Trigger.oldMap, Trigger.newMap);  // Added by udita : 05/17/2018 [When a lead is marked GDPR this method is called to insert its record in GDPR Repository]
        }
        if(Trigger.isDelete && trigger.isBefore){
            /******Preventing PayGo lead from deletion. Only informatica user can do it****/
            Set<String> authorizedUserSet = new Set<String>();
            //Accessing custom setting.....................
            For(PayGo_Records_Delete_Prevention__c PG : PayGo_Records_Delete_Prevention__c.getall().values()){
                authorizedUserSet.add(PG.Name);
            }

            For(Lead leadRec : trigger.old){
                if(((authorizedUserSet.size()==0)|| (authorizedUserSet.size()>0 && !authorizedUserSet.contains(UserInfo.getUserId()))) && String.IsNotBlank(leadRec.GUI_ID__c)){
                    leadRec.addError('PayGo Lead can not be deleted');
                }
            }
            /****************Ends Here***********************/
        }
}