/**********************************************************************************************************
* Author : Sandeep Kumar
* Date : 11 Dec, 2017
* Description : CoachingFormSelection_Controller class acts as controller to provide data on account planning VF page,
* Page is called from the custom list view button and provides option to select both old and new coaching forma from the same page.
* User is rediredcted to standard edit page for creating a new coaching form.
* VF Page - CoachingFormSelection_Page and CoachingFormSelection_Page2
* Test Class - CoachingFormSelection_Controller_Test 
************************************************************************************************************/
public class CoachingFormSelection_Controller {
    public Id sourceObjId;
    public String sourceObjType;
    public String sourceObjName;
    public String appendObjUrl;
    public string selectedRecordType{get;set;}
    public Map<String,Id> oldCoachingFormRecTypeNameToIdMap;
    public Map<String,Id> newCoachingFormRecTypeNameToIdMap;
    public List<RecordType> oldCoachingFormRecTypeIdToRecTypeDevNameList;
    public List<RecordType> newCoachingFormRecTypeIdToRecTypeDevNameList;
    public string sfBaseURL = Label.Salesforce_Base_URL;
    public List<RecordType> coachingFormRecTypeList{get;set;}
    
    public CoachingFormSelection_Controller(ApexPages.StandardSetController stdController){
        sourceObjId = ApexPages.Currentpage().getparameters().get('id');
        sourceObjType = String.valueOf(sourceObjId.getSobjectType());        
        system.debug(sourceObjType+'sourceObjId.getSobjectType() = '+sourceObjId.getSobjectType());
        
        if(sourceObjId != null && sourceObjType == 'Case'){
            sourceObjName = [Select Id,CaseNumber From Case Where Id =:sourceObjId].CaseNumber;
            // Coaching Form URL
            appendObjUrl += '&CF00No000000CAwEq_lkid='+sourceObjId+'&CF00No000000CAwEq='+sourceObjName;
            // Coaching Form 2.0 URL
            appendObjUrl += '&CF00N1N00000EuWZH_lkid='+sourceObjId+'&CF00N1N00000EuWZH='+sourceObjName;
        }else if(sourceObjId != null && sourceObjType == 'Bundle_Card_Item__c'){
            sourceObjName = [Select Id,Name From Bundle_Card_Item__c Where Id =:sourceObjId].Name;
            // Coaching Form URL
            appendObjUrl += '&CF00No000000DVtSb_lkid='+sourceObjId+'&CF00No000000DVtSb='+sourceObjName;
        }else if(sourceObjId != null && sourceObjType == 'EB_SB_Builder__c'){
            sourceObjName = [Select Id,Name From EB_SB_Builder__c Where Id =:sourceObjId].Name;
            // Coaching Form URL
            appendObjUrl += '&CF00No000000CCSi8_lkid='+sourceObjId+'&CF00No000000CCSi8='+sourceObjName;
            // Coaching Form 2.0 URL
            appendObjUrl += '&CF00N1N00000EuWZW_lkid='+sourceObjId+'&CF00N1N00000EuWZW='+sourceObjName;
        }else if(sourceObjId != null && sourceObjType == 'Mobile_Card__c'){
            sourceObjName = [Select Id,Name From Mobile_Card__c Where Id =:sourceObjId].Name;
            // Coaching Form URL
            appendObjUrl += '&CF00No000000CmmGZ_lkid='+sourceObjId+'&CF00No000000CmmGZ='+sourceObjName;
            // Coaching Form 2.0 URL
            appendObjUrl += '&CF00N1N00000EuWZM_lkid='+sourceObjId+'&CF00N1N00000EuWZM='+sourceObjName;
        }else if(sourceObjId != null && sourceObjType == 'Onboarding__c'){
            sourceObjName = [Select Id,Name From Onboarding__c Where Id =:sourceObjId].Name;
            // Coaching Form URL
            appendObjUrl += '&CF00No000000CmmGe_lkid='+sourceObjId+'&CF00No000000CmmGe='+sourceObjName;
            // Coaching Form 2.0 URL
            appendObjUrl += '&CF00N1N00000EuWZR_lkid='+sourceObjId+'&CF00N1N00000EuWZR='+sourceObjName;
        }else if(sourceObjId != null && sourceObjType == 'Alliance_OA_Projects__c'){
            sourceObjName = [Select Id,Name From Alliance_OA_Projects__c Where Id =:sourceObjId].Name;
            // Coaching Form URL
            appendObjUrl += '&CF00No000000DmwCD_lkid='+sourceObjId+'&CF00No000000DmwCD='+sourceObjName;
            // Coaching Form 2.0 URL
            appendObjUrl += '&CF00N1N00000EuWTD_lkid='+sourceObjId+'&CF00N1N00000EuWTD='+sourceObjName;
        }else if(sourceObjId != null && sourceObjType == 'TM_Buildout__c'){
            sourceObjName = [Select Id,Name From TM_Buildout__c Where Id =:sourceObjId].Name;
            // Coaching Form URL
            appendObjUrl += '&CF00No000000CmmIa_lkid='+sourceObjId+'&CF00No000000CmmIa='+sourceObjName;
        }else if(sourceObjId != null && sourceObjType == 'SMM_Implementations__c'){
            sourceObjName = [Select Id,Name From SMM_Implementations__c Where Id =:sourceObjId].Name;
            // Coaching Form 2.0 URL
            appendObjUrl += '&CF00N1N00000EuZER_lkid='+sourceObjId+'&CF00No000000DmwCD='+sourceObjName;
        }else if(sourceObjId != null && sourceObjType == 'pse__Proj__c'){
            sourceObjName = [Select Id,Name From pse__Proj__c Where Id =:sourceObjId].Name;
            // Coaching Form 2.0 URL
            appendObjUrl += '&CF00N1N00000EuZEW_lkid='+sourceObjId+'&CF00N1N00000EuZEW='+sourceObjName;
        }		
        system.debug('sourceObj Name===>>>>>'+sourceObjName);
        system.debug('sfBaseURL===>>>>>'+sfBaseURL);        
        coachingFormRecTypeList = new List<RecordType> ();
        oldCoachingFormRecTypeNameToIdMap = new Map<String,Id>();
        newCoachingFormRecTypeNameToIdMap = new Map<String,Id>();
        oldCoachingFormRecTypeIdToRecTypeDevNameList = new List<RecordType> ();
        newCoachingFormRecTypeIdToRecTypeDevNameList = new List<RecordType> ();
        OldCoachingFormRecTypeIdToNameMap();
        NewCoachingFormRecTypeIdToNameMap();
    }
    
    // Prepares a Map with RecordType Id to RecordType Name
    public void OldCoachingFormRecTypeIdToNameMap(){
        for(RecordType r : [Select Name, DeveloperName,Description,Id From RecordType where sObjectType = 'Coaching_Form__c' AND isActive=true]) {
            //Add a map entry, concatenating the sobject type + name as the key for each record type
            oldCoachingFormRecTypeIdToRecTypeDevNameList.add(r);
            // Prepare a map of Recorst Type Name to RecordType ID
            oldCoachingFormRecTypeNameToIdMap.put(r.Name, r.Id);
        }
        coachingFormRecTypeList.addAll(oldCoachingFormRecTypeIdToRecTypeDevNameList);
    }
    
    // Prepares a Map with RecordType Id to RecordType Name
    public void NewCoachingFormRecTypeIdToNameMap(){
        for(RecordType r : [Select Name, DeveloperName,Description,Id From RecordType where sObjectType = 'Coaching_Form_2_0__c' AND isActive=true]) {
            //Add a map entry, concatenating the sobject type + name as the key for each record type
            newCoachingFormRecTypeIdToRecTypeDevNameList.add(r);
            // Prepare a map of Recorst Type Name to RecordType ID
            newCoachingFormRecTypeNameToIdMap.put(r.Name, r.Id);
        }
        coachingFormRecTypeList.addAll(newCoachingFormRecTypeIdToRecTypeDevNameList);
    }
    
    public List<SelectOption> getRecTypeOptions() {
        List<SelectOption> options = new List<SelectOption>();
        for(RecordType recType : coachingFormRecTypeList){
            options.add(new SelectOption(recType.Name,recType.Name));
        }
        return options;
    }
    
    public PageReference redirectUserToEditPage(){
        if(newCoachingFormRecTypeNameToIdMap.containsKey(selectedRecordType)){
            appendObjUrl = '';
            appendObjUrl = '&CF00N1k000000O2sH_lkid='+sourceObjId+'&CF00N1k000000O2sH='+sourceObjName;
            sfBaseURL += 'aGa/e?RecordType='+newCoachingFormRecTypeNameToIdMap.get(selectedRecordType)+'&ent=01I1k0000008WqK&noOverride=1'+appendObjUrl+'&retURL=/'+sourceObjId;
        }else{
            sfBaseURL += 'a1L/e?RecordType='+oldCoachingFormRecTypeNameToIdMap.get(selectedRecordType)+'&ent=01Io0000001Ki9A&noOverride=1'+appendObjUrl+'&retURL=/'+sourceObjId;
        }
        system.debug('sfBaseURL'+sfBaseURL);
        PageReference redirectPage = new PageReference(sfBaseURL);        
        redirectPage.setRedirect(true);
        return redirectPage;
    }
    
    // Method to return user to account detail page.
    public pageReference Cancel(){     
        PageReference redirectPage = new PageReference(sfBaseURL+sourceObjId);        
        redirectPage.setRedirect(true);
        return redirectPage;
    }
}