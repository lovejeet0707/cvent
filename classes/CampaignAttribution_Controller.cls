public with sharing class CampaignAttribution_Controller {
    public Campaign campaignObj{get;set;}
    public CampaignMember campMemObj{get;set;}
    CampaignROIBatchJobId__c customSettingValue;
    public String batchId{get;set;}
    public Boolean isBatchId{get;set;}
    List<Opportunity_Campaign_Attribution__c> oppCampAttribute_Obj;
    public Boolean closePopUp{get;set;}
    public list<wrapCampaign> wrapCampaignList { get; set; }
    
    List<String> campaignType_List;
    List<String> campaignProject_List;
    List<String> campaignTactic_List;
    List<String> campaignSource_List;
    List<String> campaignMemberStatus_List;
    public CampaignAttribution_Controller()
    {
        campaignType_List=new List<String>();
        campaignProject_List=new List<String>();
        campaignTactic_List=new List<String>();
        campaignSource_List=new List<String>();
        campaignMemberStatus_List=new List<String>();
/*        wrapCampaignList = new list<wrapCampaign>();
        wrapCampaignList.add(new wrapCampaign('Type'));
        wrapCampaignList.add(new wrapCampaign('Project'));
        wrapCampaignList.add(new wrapCampaign('Tactic'));
        wrapCampaignList.add(new wrapCampaign('Source'));
        wrapCampaignList.add(new wrapCampaign('Status'));
  */      
        closePopUp=false;
        oppCampAttribute_Obj=new List<Opportunity_Campaign_Attribution__c>();
        isBatchId=false;
        customSettingValue=CampaignROIBatchJobId__c.getInstance('BatchId');
        batchId=customSettingValue.BatchJobId__c;
        if(String.isNotBlank(batchId))
        {
            closePopUp=true;
            isBatchId=true;
        }
        
        campaignObj=new Campaign();
        campMemObj=new CampaignMember();
        
        
        lstSelectedAllValue=new List<String>(); 
        lstSelectedAllSavedValue=new List<String>(); 
        optionsAllValues=new List<SelectOption>();
        optionsAllSavedValue = new List<SelectOption>();
        
        lstSelectedAllProjectValue=new List<String>(); 
        lstSelectedAllSavedProjectValue=new List<String>(); 
        optionsAllProjectValues=new List<SelectOption>();
        optionsAllSavedProjectValue= new List<SelectOption>();
        
        lstSelectedAllTacticValue=new List<String>(); 
        lstSelectedAllSavedTacticValue=new List<String>(); 
        optionsAllTacticValues=new List<SelectOption>();
        optionsAllSavedTacticValue= new List<SelectOption>();
        
        lstSelectedAllSourceValue=new List<String>(); 
        lstSelectedAllSavedSourceValue=new List<String>(); 
        optionsAllSourceValues=new List<SelectOption>();
        optionsAllSavedSourceValue= new List<SelectOption>();   
        
        
        lstSelectedAllstatusValue=new List<String>(); 
        lstSelectedAllSavedstatusValue=new List<String>(); 
        optionsAllstatusValues=new List<SelectOption>();
        optionsAllSavedstatusValue= new List<SelectOption>(); 
  
        
    }
    public class wrapCampaign{
        public String accn{get;set;}
        public boolean isSelected{get;set;}
        public wrapCampaign(String a){
            accn=a;
            isselected=false;
        }
    }
    public PageReference CalculateAttribution()
    {
        campaignType_List.addAll(setSelectedValueName);
        campaignProject_List.addAll(setSelectedProjectValueName);
        campaignTactic_List.addAll(setSelectedTacticValueName);
        campaignSource_List.addAll(setSelectedSourceValueName);
        campaignMemberStatus_List.addAll(setSelectedstatusValueName);
        
        System.debug('campaignType_List===>'+campaignType_List);
        System.debug('campaignProject_List===>'+campaignProject_List);
        System.debug('campaignTactic_List==>'+campaignTactic_List);
        System.debug('campaignSource_List===>'+campaignSource_List);
        System.debug('campaignMemberStatus_List===>'+campaignMemberStatus_List);
        
        Opportunity_Campaign_Attribution__c [] oc = [Select BatchId__c From Opportunity_Campaign_Attribution__c ORDER BY CreatedDate ASC Limit 1];
        
        
        
            
        //Delete Batch
        if(oc.size()>0) 
        Id batchJobId = Database.executeBatch(new CampaignROIAttributionDeleteBatch(oc[0].BatchId__c),6000);
        
        //Insert Batch
        Id InsertbatchJobId = Database.executeBatch(new CampaignROIAttribution_Batch(campaignType_List,campaignProject_List,campaignTactic_List,campaignSource_List,campaignMemberStatus_List),800);
        
        User_Batch_History__c userHistory = new User_Batch_History__c();
            userHistory.Batch_Id__c=InsertbatchJobId;
            userHistory.User__c=UserInfo.getUserId();
            userHistory.Campaign_Type__c=String.Join(campaignType_List,';');
            userHistory.Campaign_Tactic__c=String.Join(campaignProject_List,';');
            userHistory.Campaign_Source__c=String.Join(campaignTactic_List,';');
            userHistory.Campaign_Project__c=String.Join(campaignSource_List,';');
            userHistory.Campaign_Member_Status__c=String.Join(campaignMemberStatus_List,';');
            userHistory.Status__c='In Progress';
            userHistory.Batch_Start_Date__c=system.now();
            insert userHistory;
        
        //Id batchJobId = Database.executeBatch(new CampaignROIAttribution_Batch(lstSelectedAllSavedValue,lstSelectedAllSavedProjectValue,lstSelectedAllSavedTacticValue,lstSelectedAllSavedSourceValue,lstSelectedAllSavedstatusValue));
        customSettingValue.BatchJobId__c = InsertbatchJobId;
        update customSettingValue;
        PageReference pg= new PageReference('/apex/CampaignAttribution?sfdc.tabName=01rR00000000iM2');
        pg.setRedirect(true);
        return pg;
    }
    
    public void closePopup()
    {
        closePopUp=false;
    }
    
    
    /*  **************************
       Code Add by kumud 
       Desc Make Multipicklist
    
    
     ******/
      Public  List<String>   lstSelectedAllValue {get;set;}
    Public  List<String>  lstSelectedAllSavedValue {get;set;}
     public List<SelectOption> optionsAllValues;// {get;set;}
     public List<SelectOption> optionsAllSavedValue{get;set;}
     
    
      
         
         
        // Code start for Value Visible on a page in multi Select form 
         Set<String>   setSelectedValueName=new Set<String>(); 
         Set<String>   setUnselectedValueName=new Set<String>();  
        
     
    
     Public void ValueMoveToSelected(){
      if(lstSelectedAllValue != null && lstSelectedAllValue.size() > 0)
        {
            setSelectedValueName.addAll(lstSelectedAllValue);
            //setUnselectedValueName.removeAll(lstSelectedAllValue);
        }
        drawSelectOptions();
    }
    Public void ValueMoveToUnselected(){
     if(lstSelectedAllSavedValue != null && lstSelectedAllSavedValue.size() > 0)
        {  
            setSelectedValueName.removeAll(lstSelectedAllSavedValue);
            setUnselectedValueName.addAll(lstSelectedAllSavedValue);
        }
       
        drawSelectOptions();
    
    }
        public List<SelectOption> getTypeOption(){
         
          
            lstSelectedAllSavedValue.clear();
           
            optionsAllValues.clear();
            
          
            List<SelectOption> options = new List<SelectOption>();
        
            Schema.DescribeFieldResult ValueResult = Campaign.Type.getDescribe();
       
            List<Schema.PicklistEntry> ple = ValueResult.getPicklistValues();
        
            for( Schema.PicklistEntry f : ple)
            {
               options.add(new SelectOption(f.getLabel(), f.getValue()));
            }       
              
            
            return options;
   
     
       
           
           
           
        }
    
     
   
    
    public void drawSelectOptions()
    {
        system.debug('*******in draw*********');
        lstSelectedAllSavedValue.clear();
        lstSelectedAllValue.clear();
        optionsAllSavedValue = new List<SelectOption>();
        if(setSelectedValueName != null && setSelectedValueName.size() > 0)
        { 
         for(String ValueName:setSelectedValueName)
            {   
                optionsAllSavedValue.add(new SelectOption(ValueName,ValueName));
                //optionsAllSavedValue.add(new SelectOption('ADMIN','Admin'));
            }
            
           
        }        
     
     
     
}
   /***   Code for Campign Project field */
    
    Public  List<String>   lstSelectedAllProjectValue {get;set;}
    Public  List<String>  lstSelectedAllSavedProjectValue {get;set;}
    public List<SelectOption> optionsAllProjectValues;// {get;set;}
    public List<SelectOption> optionsAllSavedProjectValue{get;set;}
     
    
      
         
         
        // Code start for ProjectValue Visible on a page in multi Select form 
         Set<String>   setSelectedProjectValueName=new Set<String>(); 
         Set<String>   setUnselectedProjectValueName=new Set<String>();  
        
     
    
     Public void projectValueMoveToSelected(){
      if(lstSelectedAllProjectValue != null && lstSelectedAllProjectValue.size() > 0)
        {
            setSelectedProjectValueName.addAll(lstSelectedAllProjectValue);
            //setUnselectedProjectValueName.removeAll(lstSelectedAllProjectValue);
        }
        drawSelectProjectOptions();
    }
    Public void projectValueMoveToUnselected(){
     if(lstSelectedAllSavedProjectValue != null && lstSelectedAllSavedProjectValue.size() > 0)
        {  
            setSelectedProjectValueName.removeAll(lstSelectedAllSavedProjectValue);
            setUnselectedProjectValueName.addAll(lstSelectedAllSavedProjectValue);
        }
       
        drawSelectProjectOptions();
    
    }
        public List<SelectOption> getTypeProjectOption(){
         
          
            lstSelectedAllSavedProjectValue.clear();
           
            optionsAllProjectValues.clear();
            
          
            List<SelectOption> options = new List<SelectOption>();
        
            Schema.DescribeFieldResult ProjectValueResult = Campaign.Project__c.getDescribe();
           
            List<Schema.PicklistEntry> ple = ProjectValueResult.getPicklistValues();
        
            for( Schema.PicklistEntry f : ple)
            {
               options.add(new SelectOption(f.getLabel(), f.getValue()));
            }       
              
            
            return options;
   
     
       
           
           
           
        }
    
     
   
    
    public void drawSelectProjectOptions()
    {
        system.debug('*******in draw*********');
        lstSelectedAllSavedProjectValue.clear();
        lstSelectedAllProjectValue.clear();
        optionsAllSavedProjectValue = new List<SelectOption>();
        if(setSelectedProjectValueName != null && setSelectedProjectValueName.size() > 0)
        { 
         for(String ProjectValueName:setSelectedProjectValueName)
            {   
                optionsAllSavedProjectValue.add(new SelectOption(ProjectValueName,ProjectValueName));
                //optionsAllSavedProjectValue.add(new SelectOption('ADMIN','Admin'));
            }
            
           
        }        
     
     
     
    }
     // End for Project PickList (Campaign)
     
         /** Code for tactic  **/
  
    Public  List<String>   lstSelectedAllTacticValue {get;set;}
    Public  List<String>  lstSelectedAllSavedTacticValue {get;set;}
    public List<SelectOption> optionsAllTacticValues;// {get;set;}
    public List<SelectOption> optionsAllSavedTacticValue{get;set;}
     
    
      
         
         
        // Code start for TacticValue Visible on a page in multi Select form 
         Set<String>   setSelectedTacticValueName=new Set<String>(); 
         Set<String>   setUnselectedTacticValueName=new Set<String>();  
        
     
    
     Public void TacticValueMoveToSelected(){
      if(lstSelectedAllTacticValue != null && lstSelectedAllTacticValue.size() > 0)
        {
            setSelectedTacticValueName.addAll(lstSelectedAllTacticValue);
            //setUnselectedTacticValueName.removeAll(lstSelectedAllTacticValue);
        }
        drawSelectTacticOptions();
    }
    Public void TacticValueMoveToUnselected(){
     if(lstSelectedAllSavedTacticValue != null && lstSelectedAllSavedTacticValue.size() > 0)
        {  
            setSelectedTacticValueName.removeAll(lstSelectedAllSavedTacticValue);
            setUnselectedTacticValueName.addAll(lstSelectedAllSavedTacticValue);
        }
       
        drawSelectTacticOptions();
    
    }
        public List<SelectOption> getTypeTacticOption(){
         
          
            lstSelectedAllSavedTacticValue.clear();
           
            optionsAllTacticValues.clear();
            
          
            List<SelectOption> options = new List<SelectOption>();
        
            Schema.DescribeFieldResult TacticValueResult = Campaign.Tactic__c.getDescribe();
           
            List<Schema.PicklistEntry> ple = TacticValueResult.getPicklistValues();
        
            for( Schema.PicklistEntry f : ple)
            {
               options.add(new SelectOption(f.getLabel(), f.getValue()));
            }       
              
            
            return options;
   
     
       
           
           
           
        }
    
     
   
    
    public void drawSelectTacticOptions()
    {
        system.debug('*******in draw*********');
        lstSelectedAllSavedTacticValue.clear();
        lstSelectedAllTacticValue.clear();
        optionsAllSavedTacticValue = new List<SelectOption>();
        if(setSelectedTacticValueName != null && setSelectedTacticValueName.size() > 0)
        { 
         for(String TacticValueName:setSelectedTacticValueName)
            {   
                optionsAllSavedTacticValue.add(new SelectOption(TacticValueName,TacticValueName));
                //optionsAllSavedTacticValue.add(new SelectOption('ADMIN','Admin'));
            }
            
           
        }        
     
     
     
    }
     // End for Tactic PickList (Campaign)
     
     
    /** Code for Source  **/
  
    Public  List<String>   lstSelectedAllSourceValue {get;set;}
    Public  List<String>  lstSelectedAllSavedSourceValue {get;set;}
    public List<SelectOption> optionsAllSourceValues;// {get;set;}
    public List<SelectOption> optionsAllSavedSourceValue{get;set;}
     
    
      
         
         
        // Code start for SourceValue Visible on a page in multi Select form 
         Set<String>   setSelectedSourceValueName=new Set<String>(); 
         Set<String>   setUnselectedSourceValueName=new Set<String>();  
        
     
    
     Public void SourceValueMoveToSelected(){
      if(lstSelectedAllSourceValue != null && lstSelectedAllSourceValue.size() > 0)
        {
            setSelectedSourceValueName.addAll(lstSelectedAllSourceValue);
            //setUnselectedSourceValueName.removeAll(lstSelectedAllSourceValue);
        }
        drawSelectSourceOptions();
    }
    Public void SourceValueMoveToUnselected(){
     if(lstSelectedAllSavedSourceValue != null && lstSelectedAllSavedSourceValue.size() > 0)
        {  
            setSelectedSourceValueName.removeAll(lstSelectedAllSavedSourceValue);
            setUnselectedSourceValueName.addAll(lstSelectedAllSavedSourceValue);
        }
       
        drawSelectSourceOptions();
    
    }
        public List<SelectOption> getTypeSourceOption(){
         
          
            lstSelectedAllSavedSourceValue.clear();
           
            optionsAllSourceValues.clear();
            
          
            List<SelectOption> options = new List<SelectOption>();
        
            Schema.DescribeFieldResult SourceValueResult = Campaign.Source__c.getDescribe();
           
            List<Schema.PicklistEntry> ple = SourceValueResult.getPicklistValues();
        
            for( Schema.PicklistEntry f : ple)
            {
               options.add(new SelectOption(f.getLabel(), f.getValue()));
            }       
              
            
            return options;
   
     
       
           
           
           
        }
    
     
   
    
    public void drawSelectSourceOptions()
    {
        system.debug('*******in draw*********');
        lstSelectedAllSavedSourceValue.clear();
        lstSelectedAllSourceValue.clear();
        optionsAllSavedSourceValue = new List<SelectOption>();
        if(setSelectedSourceValueName != null && setSelectedSourceValueName.size() > 0)
        { 
         for(String SourceValueName:setSelectedSourceValueName)
            {   
                optionsAllSavedSourceValue.add(new SelectOption(SourceValueName,SourceValueName));
                //optionsAllSavedSourceValue.add(new SelectOption('ADMIN','Admin'));
            }
            
           
        }        
     
     
     
    }
     // End for Source PickList (Campaign)
     /** Code for status Picklist **/
  
    Public  List<String>   lstSelectedAllstatusValue {get;set;}
    Public  List<String>  lstSelectedAllSavedstatusValue {get;set;}
    public List<SelectOption> optionsAllstatusValues;// {get;set;}
    public List<SelectOption> optionsAllSavedstatusValue{get;set;}
     
    
      
         
         
        // Code start for statusValue Visible on a page in multi Select form 
         Set<String>   setSelectedstatusValueName=new Set<String>(); 
         Set<String>   setUnselectedstatusValueName=new Set<String>();  
        
     
    
     Public void statusValueMoveToSelected(){
      if(lstSelectedAllstatusValue != null && lstSelectedAllstatusValue.size() > 0)
        {
            setSelectedstatusValueName.addAll(lstSelectedAllstatusValue);
            //setUnselectedstatusValueName.removeAll(lstSelectedAllstatusValue);
        }
        drawSelectstatusOptions();
    }
    Public void statusValueMoveToUnselected(){
     if(lstSelectedAllSavedstatusValue != null && lstSelectedAllSavedstatusValue.size() > 0)
        {  
            setSelectedstatusValueName.removeAll(lstSelectedAllSavedstatusValue);
            setUnselectedstatusValueName.addAll(lstSelectedAllSavedstatusValue);
        }
       
        drawSelectstatusOptions();
    
    }
        public List<SelectOption> getTypestatusOption(){
         
          
            lstSelectedAllSavedstatusValue.clear();
           
            optionsAllstatusValues.clear();
            
          
            List<SelectOption> options = new List<SelectOption>();
        
            Schema.DescribeFieldResult statusValueResult = CampaignMember.status.getDescribe();
           
            List<Schema.PicklistEntry> ple = statusValueResult.getPicklistValues();
        
            for( Schema.PicklistEntry f : ple)
            {
               options.add(new SelectOption(f.getLabel(), f.getValue()));
            }       
              
            
            return options;
   
     
       
           
           
           
        }
    
     
   
    
    public void drawSelectstatusOptions()
    {
        system.debug('*******in draw*********');
        lstSelectedAllSavedstatusValue.clear();
        lstSelectedAllstatusValue.clear();
        optionsAllSavedstatusValue = new List<SelectOption>();
        if(setSelectedstatusValueName != null && setSelectedstatusValueName.size() > 0)
        { 
         for(String statusValueName:setSelectedstatusValueName)
            {   
                optionsAllSavedstatusValue.add(new SelectOption(statusValueName,statusValueName));
                //optionsAllSavedstatusValue.add(new SelectOption('ADMIN','Admin'));
            }
            
           
        }        
     
     
     
    }
     // End for status PickList (Campaign)
     
     
     /****   
        User history data [call by pageblock table ]
        
     
     *****************/
     
    Public List<User_Batch_History__c> getUserHistories(){
        
        return [select Status__c,Batch_Start_Date__c,Batch_Completed_Date__c,User__r.name,Batch_Id__c,Campaign_Type__c,Campaign_Project__c,Campaign_Tactic__c,Campaign_Member_Status__c,Campaign_Source__c from User_Batch_History__c order by createdDate DESC];
        
    } 

}