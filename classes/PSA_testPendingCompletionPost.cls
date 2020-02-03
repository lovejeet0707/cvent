@isTest(SeeAllData = TRUE)
public class PSA_testPendingCompletionPost {
    
    static testmethod void testPendingCompletionPost(){
        
        User u = [SELECT Id FROM User 
                  WHERE Profile.Name = 'System Administrator'
                  AND IsActive = TRUE AND Validation_Bypass__c = FALSE
                  AND ManagerId <> NULL AND Manager.ManagerId <> NULL
                  AND Manager.IsActive = TRUE AND Manager.Manager.IsActive = TRUE LIMIT 1];
        
        Account a = PSA_generateTestData.getAccount('Test PSA Account');
        
        pse__Region__c r = PSA_generateTestData.getRegion('Region');
        
        pse__Practice__c p = PSA_generateTestData.getPractice('Practice');
               
        pse__Grp__c g = PSA_generateTestData.getGrp('Group');
        
        Contact c = PSA_generateTestData.getResource('Test', 'PSA', 'psatest@cvent.com',
                                                     a.Id, r.Id, p.Id, g.Id, u.Id);
        
        pse__Proj__c proj = PSA_generateTestData.getProject('Test Project', r.Id, p.Id, g.Id, c.Id, 'Project Manager');
        
        PSA_generateTestData.getPC(u.Id, r.Id);
        
        pse__Schedule__c s = new pse__Schedule__c (pse__Start_Date__c = proj.pse__Start_Date__c, pse__End_Date__c = proj.pse__End_Date__c);
        insert s;
        
        system.runAs(u) {
            
            test.startTest();
            pse__Assignment__c assig = new pse__Assignment__c (pse__Project__c = proj.Id, pse__Resource__c = c.Id,
                                                       	   pse__Bill_Rate__c = 0, pse__Schedule__c = s.Id);
        	
            insert assig;
            
            proj.pse__Stage__c = 'Pending Completion';
            update proj;
			
        	test.stopTest(); 
        }
        
    }
    
}