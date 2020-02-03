public with sharing class CRM_MyTimeCardController {

    public Id currentUserId {get; set;}
    public List<SelectOption> timecardsOptions {get; set;}
    public Map<Id, CRM_Timecard_Entry__c> timecardEntries {get; set;}

    Map<Id, CRM_Timecard__c> timecardMap;
    public CRM_Timecard__c selectedTimecard {get; set;}
    public String selectedTimecardId;
    public String selectedEntryId {get; set;}    
    public boolean managerView {get; set;}
        
    public List<SelectOption> projectWorkOptions {get; set;}

    public CRM_MyTimeCardController(){
    }
    
    public void initialize() { 
    }

    public CRM_MyTimeCardController(ApexPages.StandardController stdController) {
       this.selectedTimecard = (CRM_Timecard__c)stdController.getRecord();
       currentUserId = UserInfo.getUserId();
       timecardEntries = new Map<Id, CRM_Timecard_Entry__c>();
       timecardMap = new Map<Id, CRM_Timecard__c> ([select Id, Team_Member__c, Locked__c, Approver_Email__c, Status__c, Start_Date__c, End_Date__c, of_Closed_Cases_Week__c, Day_1__c, Day_2__c, Day_3__c, Day_4__c, Day_5__c, Day_6__c, Day_7__c, 
                                                        Description__c, Off_Hours_Week__c, Total_Hours_Week__c from CRM_Timecard__c where (Team_Member__c =: currentUserId and Start_Date__c >: System.Today() - 21 and Start_Date__c <: System.Today() + 21) or Id=:selectedTimecard.Id order by Start_Date__c desc]);

        timecardsOptions = new List<SelectOption>();
        timecardsOptions.add(new SelectOption('', '--select--'));
        for(CRM_Timecard__c timecard: timecardMap.values() ){
            timecardsOptions.add(new SelectOption(timecard.Id, timecard.Description__c));
        }

       if(selectedTimecard.Id != null){
           this.selectedTimecard = timecardMap.get(selectedTimecard.Id);
           refreshDropDowns();
           setSelectedTimecardId(selectedTimecard.Id);
           repopulateTimecardEntries();
           managerView = true;
       }
    }

    public void refreshDropDowns() {
        projectWorkOptions = new List<SelectOption>();
        for(CRM_Project_Item__c wItem: [select Id, Name,Subject__c, CRM_Project__r.Project_Name__c, Available_Hours__c, Estimated_Effort_Hours__c, CRM_Project__r.CRM_Release__r.Requirements_Cut_Off_Date__c, CRM_Project__r.CRM_Release__r.Deployment_Date__c  from CRM_Project_Item__c where Assigned_To__c=: currentUserId]){
            if(selectedTimecard != null){
                if(selectedTimecard.Start_Date__c > wItem.CRM_Project__r.CRM_Release__r.Requirements_Cut_Off_Date__c - 5 && selectedTimecard.End_Date__c <= wItem.CRM_Project__r.CRM_Release__r.Deployment_Date__c + 5){
                    projectWorkOptions.add(new SelectOption(wItem.Id, wItem.CRM_Project__r.Project_Name__c + '-' + wItem.Subject__c + ' [' + wItem.Available_Hours__c + ']'));
                }
            }
        } 
    }
    
    public String getSelectedTimecardId(){
        return selectedTimecardId;
    }
    
    public void setSelectedTimecardId(String idStr){
        selectedTimecardId  = idStr;
        selectedTimecard = timecardMap.get(selectedTimecardId);
    }

    public void reloadCurrentTimecard(){
        timecardMap.put(selectedTimecardId, [select Id, Team_Member__c, Locked__c, Approver_Email__c, Status__c, Start_Date__c, End_Date__c, of_Closed_Cases_Week__c, Day_1__c, Day_2__c, Day_3__c, Day_4__c, Day_5__c, Day_6__c, Day_7__c, 
                                                    Description__c, Off_Hours_Week__c, Total_Hours_Week__c from CRM_Timecard__c where Id =: selectedTimecardId][0]);
        selectedTimecard = timecardMap.get(selectedTimecardId);
        //System.debug('reloadCurrentTimecard called: total hours: '+selectedTimecard.Total_Hours_Week__c);
    }
        
    public PageReference selectTimecardAction() {
        autoGenerateEntriesAction();
        repopulateTimecardEntries();
        refreshDropDowns();
        return null;
    }

    public void repopulateTimecardEntries(){
        timecardEntries = new Map<Id, CRM_Timecard_Entry__c>([select Id, Comments__c, Name, of_Closed_Cases_Week__c,Auto__c,CRM_Project_Work_Item__c, CRM_Project_Work_Item__r.Subject__c , CRM_Project_Work_Item__r.CRM_Project__r.Project_Name__c ,CRM_Timecard__c, Day_1__c, Day_2__c, Day_3__c, Day_4__c, Day_5__c, Day_6__c, Day_7__c,Type__c from CRM_Timecard_Entry__c where CRM_Timecard__c =: selectedTimecardId order by Auto__c]);
    }
        
    public boolean getIsValidTimecard(){
        return (selectedTimecardId != null && selectedTimecardId != '');
    }
    
    public List<SelectOption> getEntryTypeOptions(){
        return getPicklistValues(new CRM_Timecard_Entry__c(), 'Type__c', 'Cases');
    }
    
    public PageReference saveAction() {
        if(timecardEntries != null && timecardEntries.size()>0) {
            upsert timecardEntries.values();
        }
        reloadCurrentTimecard();
        refreshAutoEntriesAction();
        return null;
    }

    public PageReference addEntryAction() {
        saveAction();
        CRM_Timecard_Entry__c entry = new CRM_Timecard_Entry__c(Name = selectedTimecard.Description__c, CRM_Timecard__c = selectedTimecardId, User__c = currentUserId, Day_1__c = 0, Day_2__c = 0, Day_3__c = 0, Day_4__c = 0, Day_5__c = 0, Day_6__c = 0, Day_7__c = 0);
        insert entry;
        timecardEntries.put(entry.Id, entry);
        reloadCurrentTimecard();
        return null;
    }


    public PageReference refreshAutoEntriesAction() {
        selectTimecardAction();
        reloadCurrentTimecard();

        return null;
    }


    public PageReference autoGenerateEntriesAction() {
        repopulateTimecardEntries();

        //Check if there is already auto generated timecard entry for cases.
        CRM_Timecard_Entry__c entry = new CRM_Timecard_Entry__c(CRM_Timecard__c = selectedTimecardId, Auto__c = true, Type__c = 'Cases');
        boolean existing = false;
        for(CRM_Timecard_Entry__c obj: timecardEntries.values()){
            if(obj.Auto__c && obj.Type__c == 'Cases'){
                entry = obj;
                existing = true;
                break;
            }
        }
         
        AggregateResult[] groupedResults = [SELECT count(id) RecordCount, Sum(Min_on_Case_Old__c) TotalMins, Date_Closed__c FROM Case Where 
                                                    OwnerId =:currentUserId and Date_Closed__c >=:selectedTimecard.Start_Date__c and Date_Closed__c <=:selectedTimecard.End_Date__c and IsClosed = true GROUP BY Date_Closed__c];
        integer totalCases = 0;
        for (AggregateResult ar : groupedResults)  {
            System.debug('Count: ' + ar.get('RecordCount'));
            System.debug('Total Mins: ' + ar.get('TotalMins'));
            System.debug('Date:' + ar.get('Date_Closed__c'));
            
            totalCases = totalCases + Integer.valueOf(ar.get('RecordCount'));
            if(ar.get('Date_Closed__c') == selectedTimecard.Start_Date__c)
                entry.Day_1__c = Double.valueOf(ar.get('TotalMins')) / 60;

            if(ar.get('Date_Closed__c') == selectedTimecard.Start_Date__c + 1)
                entry.Day_2__c = Double.valueOf(ar.get('TotalMins')) / 60;

            if(ar.get('Date_Closed__c') == selectedTimecard.Start_Date__c + 2)
                entry.Day_3__c = Double.valueOf(ar.get('TotalMins')) / 60;

            if(ar.get('Date_Closed__c') == selectedTimecard.Start_Date__c + 3)
                entry.Day_4__c = Double.valueOf(ar.get('TotalMins')) / 60;

            if(ar.get('Date_Closed__c') == selectedTimecard.Start_Date__c + 4)
                entry.Day_5__c = Double.valueOf(ar.get('TotalMins')) / 60;

            if(ar.get('Date_Closed__c') == selectedTimecard.Start_Date__c + 5)
                entry.Day_6__c = Double.valueOf(ar.get('TotalMins')) / 60;

            if(ar.get('Date_Closed__c') == selectedTimecard.Start_Date__c + 6)
                entry.Day_7__c = Double.valueOf(ar.get('TotalMins')) / 60;

        }
        entry.of_Closed_Cases_Week__c = totalCases;
        if(!existing){
            insert entry;
            timecardEntries.put(entry.Id, entry);
        } else {
            update timecardEntries.values();
        }

        return null;
    }
 
    public PageReference deleteAction() {
        saveAction();
        
        CRM_Timecard_Entry__c entry = [select Id from CRM_Timecard_Entry__c where Id=: selectedEntryId];
        delete entry;
 
        repopulateTimecardEntries();      
        reloadCurrentTimecard();
        return null;
    }

    public PageReference doNothing() {
        return null;
    }
    
    public PageReference submitApprovalAction() {
        selectedTimecard.Status__c = 'Pending Approval';
        selectedTimecard.Locked__c = true;
        update selectedTimecard;
        return null;
    }

    public PageReference approveAction() {
        selectedTimecard.Status__c = 'Approved';
        selectedTimecard.Locked__c = true;        
        update selectedTimecard;
        return null;
    }
    public PageReference rejectAction() {
        selectedTimecard.Status__c = 'Rejected';
        selectedTimecard.Locked__c = false;
        update selectedTimecard;
        return null;
    }
  

    public PageReference selectEntryTypeAction() {
        CRM_Timecard_Entry__c entry = timecardEntries.get(selectedEntryId);
        if(entry.Type__c != 'Project'){
            entry.CRM_Project_Work_Item__c = null;
        }
/*        projectWorkOptions = new List<SelectOption>();
        Set<Id> capturedProjectItems = new Set<Id>();
        for(CRM_Timecard_Entry__c e: timecardEntries.values()) {
            if(!capturedProjectItems.contains(e.CRM_Project_Work_Item__c)){
                capturedProjectItems.add(e.CRM_Project_Work_Item__c);
            }
        }
  */                  
        return null;
    }    
    
    public integer getRecordCount() {
        return timecardEntries.size();
    }

    //Utility Method to prepare a dropdown with picklist values
    public List<SelectOption> getPicklistValues(SObject obj, String fld, String valToExclude){
      list<SelectOption> options = new list<SelectOption>();
      // Get the object type of the SObject.
      Schema.sObjectType objType = obj.getSObjectType(); 
      // Describe the SObject using its object type.
      Schema.DescribeSObjectResult objDescribe = objType.getDescribe();       
      // Get a map of fields for the SObject
      map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap(); 
      // Get the list of picklist values for this field.
      list<Schema.PicklistEntry> values =
         fieldMap.get(fld).getDescribe().getPickListValues();
      // Add these values to the selectoption list. Exclude a value if required
      for (Schema.PicklistEntry a : values)
      { 
          if(valToExclude != null && valToExclude.equalsIgnoreCase(a.getLabel())){
              continue;
          }
          options.add(new SelectOption(a.getValue(), a.getLabel())); 
      }
      return options;
     }
    
}