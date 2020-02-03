/****************************************************************************************
Name            : PSA_surveyInfoTriggerHandler
Author(s)       : TOP Step Consulting - Andy Heidrich (aheidrich@topstepconsulting.com)
:
Created Date    : July 14, 2017
Description     : Contains methods called from SurveyInformation.apxt on Survey_Q__c.
: (Survey Information)
: answerToNumber - converts Survey answers that are on a 5-point verbal
: scale (e.g. Very Satisfied, Satisfied, Neutral, Dissatisfied, 
: Very Dissatisfied) to 5,4,3,2,1 in the "PS Points" field
: sumTotalScore - sums total score across all surveys for this Project into
: Total_Survey_Points__c field on Project.  Also sums total number of Surveys
: sent into Total_Surveys_Sent__c field.
******************************************************************************************/

public class PSA_surveyInfoTriggerHandler {    
    
    //Called before insert/update - convert long text area Answere__c field
    //to a numeric value in PS_Points__c field when the answer is a VerySatisfied...
    //Very Dissatisfied drop down (using a trigger because it's a long text field)
    public static void answerToNumber(list<Survey_Q__c> questionList) {
        if(PSA_Utils.isTriggerDisabled('answerToNumber')) { return; }
        
        //Variable to hold points value
        double points;            
        
        for(Survey_Q__c sq : questionList){
            points = 0;
            //Check for each answer type and assign 
            //corresponding value to points variable
            if(sq.Answere__c == 'Very Satisfied') {
                points = 5;
            } 
            else if(sq.Answere__c == 'Satisfied') {
                points = 4;
            } 
            else if(sq.Answere__c == 'Neither Satisfied nor Dissatisfied') {
                points = 3;
            }
            else if(sq.Answere__c == 'Dissatisfied') {
                points = 2;
            } 
            else if(sq.Answere__c == 'Very Dissatisfied') {
                points = 1;
            }            
            //Set the value in PS Points field
            sq.PS_Points__c = points;
        }
    }
    
    
    //Called after insert/update.  Sums total points across all Survey 
    //questions onto Project.  Also sums total number of Surveys.
    public static void sumTotalScore(map<Id,Survey_Q__c> questionMap) {
        
        if(PSA_Utils.isTriggerDisabled('sumTotalScore')) { return; }
        
        //Declare sets to hold querying Ids
        set<Id> projIds = new set<Id>();
        //Declare sets to hold survey Header Ids
        set<Id> surveyHeaderIds = new set<Id>();
        
        //Put the Project Ids in set
        for(Survey_Q__c sq : [SELECT SurveyHeader__r.Project__c 
                              FROM Survey_Q__c WHERE Id IN : questionMap.keySet()]){
                                  if(sq.SurveyHeader__r.Project__c != NULL){
                                      projIds.add(sq.SurveyHeader__r.Project__c);
                                      surveyHeaderIds.add(sq.SurveyHeader__c);
                                  }
                              }
        
        //Only proceed if these are PS Surveys
        if(!projIds.isEmpty()) {
            //Declare maps to hold totals
            map<Id,double> totalPoints = new map<Id,double>();
            map<Id,double> totalNumQuestions = new map<Id,double>();
            
            //Populate total points from Survey Questions into map
            for(aggregateResult ar : [SELECT SurveyHeader__r.Project__c projId, SUM(PS_Points__c) totPoints,
                                      SUM(PowerOfOne__c) totQuestions
                                      FROM Survey_Q__c WHERE SurveyHeader__r.Project__c IN : projIds
                                      AND PS_Points__c > 0 GROUP BY SurveyHeader__r.Project__c LIMIT 50000]){
                                          totalPoints.put((Id)ar.get('projId'),(double)ar.get('totPoints'));
                                          totalNumQuestions.put((Id)ar.get('projId'),(double)ar.get('totQuestions'));
                                      }
            //Declare list for updating Projects
            list<pse__Proj__c> projUpdate = new list<pse__Proj__c>();
            
            //Loop through the Projects and update the values in memory
            for(pse__Proj__c p : [SELECT Id, Total_Survey_Score_Questions__c, Total_Survey_Score__c
                                  FROM pse__Proj__c
                                  WHERE Id IN : projIds]){
                                      p.Total_Survey_Score__c = totalPoints.get(p.Id);
                                      p.Total_Survey_Score_Questions__c = totalNumQuestions.get(p.Id);
                                      projUpdate.add(p);
                                  }
            
            //Update results to the database
            if(!projUpdate.isEmpty()){
                update projUpdate;
            }
            
            //Declare list for updating Survey Header
            list<Survey_Header__c> surveyHeaderToUpdate = new list<Survey_Header__c>();
            
            for(Survey_Header__c surveyHedObj :[Select Id,Response_Received__c from Survey_Header__c where Id IN :surveyHeaderIds]){
                if(surveyHedObj.Response_Received__c == null){
                    surveyHedObj.Response_Received__c = DateTime.now();
                    surveyHeaderToUpdate.add(surveyHedObj);
                }
            }
            // Update results to the database
            if(!surveyHeaderToUpdate.isEmpty()){
                update surveyHeaderToUpdate;
            }
        }
    }
}