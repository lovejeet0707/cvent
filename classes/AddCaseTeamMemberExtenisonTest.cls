// ===============================
// AUTHOR     : Shanu Aggarwal    
// CREATED DATE    : 29/03/2016
// PURPOSE     :   Add Case Team Member for GOMP Cases created by clicking on a Button On Contact level
// LASS :   AddCaseTeamMemberExtenison
// SPECIAL NOTES:
// ===============================

@istest
public class AddCaseTeamMemberExtenisonTest {
    
    static Case caseRec ;
    
    static{
    Id recTypeCase = [SELECT Id from RecordType where SObjectType='Case' and Name='Support Sales Cases'].Id ;
            
            
            
            caseRec = new Case();
            caseRec.recordTypeId = recTypeCase;
            caseRec.Product_Type__c = 'CSN - Planner';
            caseRec.Status = 'Open';
            caseRec.Request_Type__c='Escalation';
            caseRec.Subject = 'Test Case';
            caseRec.Description = 'Test Case Desc' ;
            
            insert caseRec;
    }
    
    static testmethod void createTest(){
        
        PageReference pgRef = Page.AddCaseTeamMemberPage ;
        pgRef.getParameters().put('newid', caseRec.Id);
        Test.setCurrentPage(pgRef);
        
        ApexPages.StandardController cont = new ApexPages.StandardController(caseRec);
        
        AddCaseTeamMemberExtenison addTeamext = new AddCaseTeamMemberExtenison(cont );
        
        addTeamext.AddCaseTeamMember();
        
    }
    

}