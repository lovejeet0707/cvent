@isTest(SeeAllData=true)
public class RHX_TEST_Project_Activity {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM Project_Activity__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Project_Activity__c()
            );
        }
    	Database.upsert(sourceList);
    }
}