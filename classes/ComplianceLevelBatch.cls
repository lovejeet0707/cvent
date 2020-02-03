/**=====================================================================
* Cvent
* Name: ComplianceLevelBatch
* Description: Batch Class for updating the Compliance Level of the Opportunities
* Created Date: [14/03/2017]
* Created By: Hemant Rana
* 
 * Date Modified                Modified By                  Description of the update
* [MON DD, YYYY]               [FirstName LastName]         [Short description for changes]
*/
global class ComplianceLevelBatch implements Database.Batchable<sObject> , Schedulable {
    //Declaring variables....
    Id recTypeId ; 
    //List<Compliance_Level__c> complianceLevelObj;
    List<Opportunity> oppList;
    //Integer counter;
    /* Initializing the constructor*/
    global ComplianceLevelBatch(){
        //Initializing the Custom Setting Objects.....
        //complianceLevelObj = new List<Compliance_Level__c>();
        //Accessing the "Renewal" recordtype of Opportunity.....
        recTypeId =  Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
        //Qerying the Compliance Level Custom Object..............
        /*For(Compliance_Level__c compLevelRec : [SELECT Id,Current_Compliance_Level__c,Name,RD_End_Range__c,RD_Start_Range__c,Stage_Name__c FROM Compliance_Level__c ORDER BY Sequence_Dev__c ASC])
        {
            complianceLevelObj.add(compLevelRec);
        }*/
    }
    /*...............Executing Start Method.....................*/
    global Database.queryLocator start(Database.BatchableContext BC){
        String oppQuery = 'SELECT Id,Days_until_renewal_date__c,Days_out_of_Compliance__c,StageName FROM Opportunity WHERE StageName!='+'\''+'Closed Lost'+'\''+' AND StageName!='+'\''+'Closed Won'+'\''+' AND  RecordTypeId = '+'\''+recTypeId+'\''; //Compliance_Level_Dev__c
        System.debug('oppQuery*******'+oppQuery);
        return Database.getQueryLocator(oppQuery);
    }
    /*...............Executing Execute Method.....................*/
    global void execute(Database.BatchableContext BC, List<Opportunity> oppRecList)
    {
        oppList =new List<Opportunity>();
        For(Opportunity oppRec : oppRecList)
        {
            /*if(oppRec.Compliance_Level_Dev__c == 'Out Of Compliance')
            {
                if(oppRec.Days_out_of_Compliance__c == null)
                    oppRec.Days_out_of_Compliance__c = 0+1;
                else
                    oppRec.Days_out_of_Compliance__c = oppRec.Days_out_of_Compliance__c+1;
                oppList.add(oppRec);
            }
            else{
               
            }*/
             oppRec.Days_out_of_Compliance__c =0;
              oppList.add(oppRec);  // comment by kd
        }
            System.debug('oppList*****'+oppList);
            if(oppList.size()>0)
                Database.Update(oppList,true);
    }
    /*...............Executing Finish Method.....................*/
    global void finish(Database.BatchableContext BC){}
    
    /*...............Schedulable Class method...................*/
    global void execute(SchedulableContext SC) {
        ComplianceLevelBatch compBatch=new ComplianceLevelBatch();
        Database.executeBatch(compBatch,200);
   }
    

}