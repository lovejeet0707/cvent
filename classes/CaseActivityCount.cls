//Created By Rishi Ojha
       //=========================================================================================
      //Utility class is created for the trigger on task TaskUpdateCase
     //===========================================================================================    
    
    public with sharing class CaseActivityCount {
    
        public static Boolean didRun = false;
        public static String casePrefix =  Case.sObjectType.getDescribe().getKeyPrefix();
    
        public static void updateCaseCounts(Set<ID> CaseIds) {
    
            if (didRun == false) { 
                didRun = true;
    
                List<Case> cs = [SELECT ID, of_Delivered_Reports__c, (SELECT ID FROM Tasks where Status = 'Completed') FROM Case WHERE ID IN :CaseIds and RecordTypeId = '0120000000098vb'];
                List<Case> updateCases = new List<Case>();
    
                for (Case C : cs) {
                    Integer count = C.tasks.size() + C.events.size();
    
                    if (C.of_Delivered_Reports__c != count) {
                        C.of_Delivered_Reports__c = count;
                        updateCases.add(C); 
                    }
                }
    
                            try {
                    update updateCases;
                } catch (Exception e) {
                }
            }
        }
        }