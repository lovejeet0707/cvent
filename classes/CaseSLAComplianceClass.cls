/* Author : Sandeep Kumar
* Created Date : 20/04/2017
* Description :  Class responsible for enforcing SLA rule for Lanyon products. 
* Class uses case Setting to identify the SLA type and rule to be enforced.
* SLA functionality works basesd on the case record types. 
*/
public class CaseSLAComplianceClass {    
    Private Set <id> updatedCaseIdSet;
    Private Static Case_Settings__c caseSettings = null;
    private Map<Id,String>  recTypeIdToRecTypeDevNameMap;
    
    // Description : Method that Check if the Case status is updated
    public void checkStatus(Map<Id,Case> newCaseMap, Map<Id,Case> oldCaseMap){
        updatedCaseIdSet = new set<id>();
        //caseIdSet = new set<id>();
        //today = system.today();
        Set<String> caseStatus = getCaseSettings('status');
        for (Case newCase : newCaseMap.Values()){
            Case oldCase = oldCaseMap.get(newCase.Id);            
            //Check if the case status is updated
          if(caseStatus != null){  // added by udita for GDPR
            if(oldCase.Status != newCase.Status && (caseStatus.contains(newCase.Status))){                
                updatedCaseIdSet.add(newCase.Id);
            } 
          }           
        }       
        
        /**
* create timestamp when status is updated
* Populate SLA Deadline
* Open Investigating - 48 Hrs
* Updated            - 48 Hrs
* ReOpened           - 24 Hrs
* Populate dateTime field that says when the SLA indicator turns Red, Yellow or Green
*/
        BusinessHours bh = getBusinessHours();
        Set<String> caseStatus48Hrs = getCaseSettings('48');
        Set<String> caseStatus24Hrs = getCaseSettings('24');
        Set<String> x = getCaseSettings('X');
        for(Case z: newCaseMap.values()){
            if (updatedCaseIdSet.contains(z.id)){
                system.debug('---SLARED'+ z.SLA_Red__c);
                system.debug('---NOW'+ system.now());
                if(z.SLA_Red__c <= system.now()){
                    continue;
                }
                if(caseStatus48Hrs != null){  // added by udita for GDPR
                if(caseStatus48Hrs.contains(z.status)){                    
                    z.SLA_Yellow__c =  BusinessHours.addGmt(bh.Id, DateTime.now(), 1000 * 60 * 60 * 42);
                    z.SLA_Red__c =  BusinessHours.addGmt(bh.Id, DateTime.now(), 1000 * 60 * 60 * 48);
                    z.SLA_Deadline__c = BusinessHours.addGmt(bh.Id, DateTime.now(), 1000 * 60 * 60 * 48);
                }}
                else if(caseStatus24Hrs != NULL && caseStatus24Hrs.contains(z.status)){   // != NULL added by udita for GDPR
                    z.SLA_Yellow__c =  BusinessHours.addGmt(bh.Id, DateTime.now(), 1000 * 60 * 60 * 18);
                    z.SLA_Red__c =  BusinessHours.addGmt(bh.Id, DateTime.now(), 1000 * 60 * 60 * 24);
                    z.SLA_Deadline__c = BusinessHours.addGmt(bh.Id, DateTime.now(), 1000 * 60 * 60 * 24);
                }else if(z.status == 'Work in Progress'){                    
                    z.SLA_Yellow__c =  BusinessHours.addGmt(bh.Id, DateTime.now(), 1000 * 60 * 60 * 1);
                    z.SLA_Red__c =  BusinessHours.addGmt(bh.Id, DateTime.now(), 1000 * 60 * 60 * 2);
                    z.SLA_Deadline__c = BusinessHours.addGmt(bh.Id, DateTime.now(), 1000 * 60 * 60 * 2);
                }else if(z.status == 'Reassigned'){                    
                    // Do nothing. Maintains the previous SLA.
                }else{                    
                    z.SLA_Yellow__c = null;
                    z.SLA_Red__c = null;
                    z.SLA_Deadline__c = null;
                }
            }
            system.debug(z.SLA_Yellow__c+'===SLA After Status Change===='+z.SLA_Red__c+'============='+z.SLA_Deadline__c);
        }
    }    
    
    // Description : this will return values from custom settings    
    private static Set<String> getCaseSettings(String x) {
        Set <String> caseStatusSet = new Set<String>();
        Set <String> standardResponseSet = new Set<String>();
        Set <String> quickResponseSet = new Set<String>();
        Set <String> statusApplyDeadlineSet = new Set<String>();
        Set <String> sla24HrsSet = new Set<String>();
        caseSettings = Case_Settings__c.getValues('CaseStatus');
        
        if(caseSettings != null){
            //Get Case status from custom settings and have it in a Set
            String caseStatusString = caseSettings.Case_Status__c;
            List<String> caseStutusList = caseStatusString.split(',');
            for(String s: caseStutusList ){
                String caseStatusTrim = s.Trim(); 
                caseStatusSet.add(caseStatusTrim);
            }
            //Get Product family for Standard Response from custom settings and have it in a Set
            String standardResponseText = caseSettings.Standard_Response__c;
            List<String> standardResponseList = standardResponseText.split(',');
            for(String sr: standardResponseList){
                String srTrim = sr.Trim();
                standardResponseSet.add(srTrim);
            }
            
            //Get Product family for Quick Response from custom settings and have it in a Set
            String quickResponseText = caseSettings.Quick_Responses__c;
            List<String> quickResponseList = quickResponseText.split(',');
            for(String qr: quickResponseList){
                String qrTrim = qr.Trim();
                quickResponseSet.add(qrTrim);
            }
            
            //Get Status where to apply SLA Deadline from custom settings and have it in a Set
            String caseStatusApplyDeadline = caseSettings.Status_where_SLA_deadline_apply__c;
            List<String> statusApplyDeadlineList = caseStatusApplyDeadline.split(',');
            for(String cs: statusApplyDeadlineList){
                String csTrim = cs.Trim();
                statusApplyDeadlineSet.add(csTrim);
            }
            
            //Get Status where to apply SLA Deadline from custom settings and have it in a Set
            String sla24Hrs = caseSettings.X24_hrs_SLA__c;
            List<String> sla24HrsList = sla24Hrs.split(',');
            for(String q: sla24HrsList){
                String qTrim = q.Trim();
                sla24HrsSet.add(qTrim);
            }
            
            //Get Case Status where SLA deadline will apply
            if (x == 'status'){
                return caseStatusSet;
            }   
            else if (x == 'QR') {
                return quickResponseSet;
            } 
            else if (x == 'SR') {
                return standardResponseSet;
            }
            else if (x == '48') {
                return statusApplyDeadlineSet;
            }
            else if (x == '24') {
                return sla24HrsSet;
            }                
        }        
        return null; 
    }
    
    // This will return thw BusinessHours named 'Customer Support Hours'
    private static BusinessHours  getBusinessHours(){
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE Name ='Customer Support Hours'];
        return bh;
    }
    
    /**
* Description : for new case/ status: New
* This will populate SLA Deadline field for initial Response SLA
* For Quick Response 
* P1 - 1 Hr
* P2, P3 and P4 - 2 Hrs
* For Standard Response
* P1 - 1 Hr
* P2 - 4 Hrs
* P3 - 8 Hrs
* P4 - 24 Hrs
* Populate dateTime field that says when the SLA indicator turns Red, Yellow or Green
*/
    public void initialResponseSLA(List<Case> newCaseList){ 
        // Populate Case Record Types.
        RecTypeIdToNameMap();                
        BusinessHours bh = getBusinessHours();
        Set<String> quickResponse = getCaseSettings('QR');
        Set<String> standardResponse =  getCaseSettings('SR');
        if(quickResponse != null && standardResponse != null){
            // Call the method to update Lanyon Case Origin field.s
            updateLanyonCaseOrigin(newCaseList);
            
            for (Case newCase : newCaseList){
                //for standardResponse SLA
                if(newCase.status == 'New' && recTypeIdToRecTypeDevNameMap.containsKey(newCase.RecordTypeId) && standardResponse.contains(recTypeIdToRecTypeDevNameMap.get(newCase.RecordTypeId))){
                    system.debug('Inside Low Priority Assignment');
                    newCase.SLA_Yellow__c =  BusinessHours.addGmt(bh.Id, DateTime.now(), 1000 * 60 * 60 * 18);
                    newCase.SLA_Red__c =  BusinessHours.addGmt(bh.Id, DateTime.now(), 1000 * 60 * 60 * 24);
                    newCase.SLA_Deadline__c = BusinessHours.addGmt(bh.Id, DateTime.now(), 1000 * 60 * 60 * 24); 
                }
                //for quickResponse SLA
                if(newCase.status == 'New' && recTypeIdToRecTypeDevNameMap.containsKey(newCase.RecordTypeId) && quickResponse.contains(recTypeIdToRecTypeDevNameMap.get(newCase.RecordTypeId))){
                    newCase.SLA_Yellow__c =  BusinessHours.addGmt(bh.Id, DateTime.now(), 1000 * 60 * 60 * 1);
                    newCase.SLA_Red__c =  BusinessHours.addGmt(bh.Id, DateTime.now(), 1000 * 60 * 60 * 2);
                    newCase.SLA_Deadline__c = BusinessHours.addGmt(bh.Id, DateTime.now(), 1000 * 60 * 60 * 2); 
                }
            }
        }
    }    
    
    // This method updates the Case Origin and Lanyon Case Origin wherein the codes came from CaseUpdateProductFamilyTrigger   
    public void updateLanyonCaseOrigin(List<Case> newCaseList){        
        for (Case c : newCaseList){  
            if(c.Origin != null && c.Origin.contains('E2C:')){
                c.Lanyon_Case_Origin__c = c.Origin;
                c.Origin = 'Email';
            }
        }        
    }    
    
    // Prepares a Map with RecordType Id to RecordType Name
    public void RecTypeIdToNameMap(){
        recTypeIdToRecTypeDevNameMap = new Map<Id,String>();
        for(RecordType r : [Select Name, DeveloperName, Id From RecordType where sObjectType = 'Case' AND isActive=true]) {
            //Add a map entry, concatenating the sobject type + name as the key for each record type
            recTypeIdToRecTypeDevNameMap.put(r.Id,(r.DeveloperName));
        }
    }
}