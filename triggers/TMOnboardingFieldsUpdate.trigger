trigger TMOnboardingFieldsUpdate on Task (after update)
{

    /* Skip execution if this user is setup to exempt triggers. This helps in one time data load as well */
    if(!BypassTriggerUtility.isTriggerEnabledForThisUserOrProfileId(UserInfo.getUserId())){
            return;
    } 
    
    list<TM_Buildout__c> TMUpdate = new List<TM_Buildout__c>(); 
    set<Id> TMIDs = new Set<Id>(); 
    Map<ID,TM_Buildout__c> TMUPdateMap=new Map<ID,TM_Buildout__c>();
    Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.TM_Buildout__c; 
    String KeyPrefix_TM_Buildout =cfrSchema.getkeyPrefix();   
    if(Trigger.isUpdate)
    { 
        for(Task t : Trigger.new) 
        {
            if(t.WhatId!=null) 
            {
                if(String.valueof(t.WhatId).startsWith(KeyPrefix_TM_Buildout)) 
                {
                    if(t.subject.equals('Client Launch Date') && t.Status.equals('Completed'))
                    {
                        if(TMUPdateMap.ContainsKey(t.WhatId))
                        {
                            TMUPdateMap.get(t.WhatId).Client_Launch_Date__c=system.today();
                            
                        }
                        else
                        {
                            TM_Buildout__c tmb=new TM_Buildout__c(id=t.WhatId,Client_Launch_Date__c=system.today());
                            TMUPdateMap.put(t.WhatId,tmb);
                        }
                    }
                    //For Checking Task Subject "Add Verify Service Fee"
                    if(t.subject.equals('Add Verify Service Fee') && t.Status.equals('Completed'))
                    {
                        if(TMUPdateMap.ContainsKey(t.WhatId))
                        {
                            TMUPdateMap.get(t.WhatId).Add_Verify_Service_Fee__c=system.today();
                            
                        }
                        else
                        {
                            TM_Buildout__c tmb=new TM_Buildout__c(id=t.WhatId,Add_Verify_Service_Fee__c=system.today());
                            TMUPdateMap.put(t.WhatId,tmb);
                        }
                        
                    }
                    
                    //For Checking Task Subject "Create Events"
                    
                    if(t.subject.equals('Create Events') && t.Status.equals('Completed'))
                    {
                        if(TMUPdateMap.ContainsKey(t.WhatId))
                        {
                            TMUPdateMap.get(t.WhatId).Create_Events__c=system.today();
                            
                        }
                        else
                        {
                            TM_Buildout__c tmb=new TM_Buildout__c(id=t.WhatId,Create_Events__c=system.today());
                            TMUPdateMap.put(t.WhatId,tmb);
                        }
                        
                    }
                    
                    //For Checking Task Subject "Designed Approved"
                    
                    if(t.subject.equals('Designed Approved') && t.Status.equals('Completed'))
                    {
                        if(TMUPdateMap.ContainsKey(t.WhatId))
                        {
                            TMUPdateMap.get(t.WhatId).a_Designed_Approved__c=system.today();
                            
                        }
                        else
                        {
                            TM_Buildout__c tmb=new TM_Buildout__c(id=t.WhatId,a_Designed_Approved__c=system.today());
                            TMUPdateMap.put(t.WhatId,tmb);
                        }
                        
                    }
                    
                    //For Checking Task Subject "Equipment Training"
                    
                    if(t.subject.equals('Equipment Training') && t.Status.equals('Completed'))
                    {
                        if(TMUPdateMap.ContainsKey(t.WhatId))
                        {
                            TMUPdateMap.get(t.WhatId).Equipment_Training__c=system.today();
                            
                        }
                        else
                        {
                            TM_Buildout__c tmb=new TM_Buildout__c(id=t.WhatId,Equipment_Training__c=system.today());
                            TMUPdateMap.put(t.WhatId,tmb);
                        }
                        
                    }
                    
                    //For Checking Task Subject "Import Previous TB Data"
                    
                    if(t.subject.equals('Import Previous TB Data') && t.Status.equals('Completed'))
                    {
                        if(TMUPdateMap.ContainsKey(t.WhatId))
                        {
                            TMUPdateMap.get(t.WhatId).a_Import_Previous_TB_Data__c=system.today();
                            
                        }
                        else
                        {
                            TM_Buildout__c tmb=new TM_Buildout__c(id=t.WhatId,a_Import_Previous_TB_Data__c=system.today());
                            TMUPdateMap.put(t.WhatId,tmb);
                        }
                        
                    }
                    
                    //For Checking Task Subject "Merchant A/C Setup Date"
                    
                    if(t.subject.equals('Merchant A/C Setup Date') && t.Status.equals('Completed'))
                    {
                        if(TMUPdateMap.ContainsKey(t.WhatId))
                        {
                            TMUPdateMap.get(t.WhatId).Merchant_A_C_Setup_Date__c=system.today();
                            
                        }
                        else
                        {
                            TM_Buildout__c tmb=new TM_Buildout__c(id=t.WhatId,Merchant_A_C_Setup_Date__c=system.today());
                            TMUPdateMap.put(t.WhatId,tmb);
                        }
                        
                    }
                    
                    //For Checking Task Subject "Collect W9"
                    
                    if(t.subject.equals('Collect W9') && t.Status.equals('Completed'))
                    {
                        if(TMUPdateMap.ContainsKey(t.WhatId))
                        {
                            TMUPdateMap.get(t.WhatId).a_Collect_W9__c=system.today();
                            
                        }
                        else
                        {
                            TM_Buildout__c tmb=new TM_Buildout__c(id=t.WhatId,a_Collect_W9__c=system.today());
                            TMUPdateMap.put(t.WhatId,tmb);
                        }
                        
                    }
                    
                    //For Checking Task Subject "Verify Gateway Info"
                    
                    if(t.subject.equals('Verify Gateway Info') && t.Status.equals('Completed'))
                    {
                        if(TMUPdateMap.ContainsKey(t.WhatId))
                        {
                            TMUPdateMap.get(t.WhatId).a_Verify_Gateway_Info__c=system.today();
                            
                        }
                        else
                        {
                            TM_Buildout__c tmb=new TM_Buildout__c(id=t.WhatId,a_Verify_Gateway_Info__c=system.today());
                            TMUPdateMap.put(t.WhatId,tmb);
                        }
                        
                    }
                    
                    //For Checking Task Subject "Q/A Testing"
                    
                    if(t.subject.equals('Q/A Testing') && t.Status.equals('Completed'))
                    {
                        if(TMUPdateMap.ContainsKey(t.WhatId))
                        {
                            TMUPdateMap.get(t.WhatId).Q_A_Testing__c=system.today();
                            
                        }
                        else
                        {
                            TM_Buildout__c tmb=new TM_Buildout__c(id=t.WhatId,Q_A_Testing__c=system.today());
                            TMUPdateMap.put(t.WhatId,tmb);
                        }
                        
                    }
                    
                    //For Checking Task Subject "Sent to Client for Approval"
                    
                    if(t.subject.equals('Sent to Client for Approval') && t.Status.equals('Completed'))
                    {
                        if(TMUPdateMap.ContainsKey(t.WhatId))
                        {
                            TMUPdateMap.get(t.WhatId).Sent_to_Client_for_Approval__c=system.today();
                            
                        }
                        else
                        {
                            TM_Buildout__c tmb=new TM_Buildout__c(id=t.WhatId,Sent_to_Client_for_Approval__c=system.today());
                            TMUPdateMap.put(t.WhatId,tmb);
                        }
                        
                    }
                    
                    //For Checking Task Subject "Site Design Completion"
                    
                    if(t.subject.equals('Site Design Completion') && t.Status.equals('Completed'))
                    {
                        if(TMUPdateMap.ContainsKey(t.WhatId))
                        {
                            TMUPdateMap.get(t.WhatId).Site_Design_Completion_Date__c=system.today();
                            
                        }
                        else
                        {
                            TM_Buildout__c tmb=new TM_Buildout__c(id=t.WhatId,Site_Design_Completion_Date__c=system.today());
                            TMUPdateMap.put(t.WhatId,tmb);
                        }
                        
                    }
                    
                    //For Checking Task Subject "Walkthrough & Training"
                    
                    if(t.subject.equals('Walkthrough & Training') && t.Status.equals('Completed'))
                    {
                        if(TMUPdateMap.ContainsKey(t.WhatId))
                        {
                            TMUPdateMap.get(t.WhatId).Walkthrough_Training__c=system.today();
                            
                        }
                        else
                        {
                            TM_Buildout__c tmb=new TM_Buildout__c(id=t.WhatId,Walkthrough_Training__c=system.today());
                            TMUPdateMap.put(t.WhatId,tmb);
                        }
                        
                    }
                    
                    
                    
                }
            } 
            
        } 
        
        if(TMUPdateMap.size()>0)
        {
            for(TM_Buildout__c tmb: TMUPdateMap.values())
            {
                TMUpdate.add(tmb);
            }
            if(TMUpdate.size()>0)
            {
                update TMUpdate;
            }
        }
    }
}