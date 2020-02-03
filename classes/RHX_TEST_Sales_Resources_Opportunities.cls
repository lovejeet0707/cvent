@isTest(SeeAllData=true)
public class RHX_TEST_Sales_Resources_Opportunities {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM Sales_Resources_Opportunities__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Sales_Resources_Opportunities__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}