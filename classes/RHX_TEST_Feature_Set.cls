/*Version 24.0
Date:7th Nov 2016
Description : Migrating FEATURESET to PRODUCT/PRICEBOOK. Below are the name of the field which needs to be replaced - 
OLD FIELD NAME       = NEW FIELD NAME
Feature_Sets__r      = OpportunityLineItems;
R00N00000008aGEXEA2  = OpportunityLineItems;
Feature_Set__c       = OpportunityLineItem;
Feature__c           = Product_Name__c;
Opportunity_N__c     = OpportunityId;
//Lines Commented as Can't update CurrencyISOCode of OpportunityLineItem
*/
@isTest(SeeAllData=true)
public class RHX_TEST_Feature_Set {
  static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
      FROM Feature_Set__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Feature_Set__c()
            );
        }
      Database.upsert(sourceList);
    }
}