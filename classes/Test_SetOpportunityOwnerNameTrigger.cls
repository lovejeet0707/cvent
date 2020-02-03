@isTest private class Test_SetOpportunityOwnerNameTrigger {

                 static testMethod void myUnitTest() {       

                                     Opportunity opp = new Opportunity(Name = 'TestName',StageName = 'FooName',CloseDate = date.today());    //,True_Product__c = 'Biz Dev'  commented by kd
                                           

                                                          insert opp;              

                                     system.assertequals(opp.Owner.Name, opp.Owner_Name__c);    

                                     }

}