/**
 * @author         L. Lavapie
 * @date           4/9/2015
 * @description    Test Class for CaseSLAComplianceClass. 
 */
@isTest
public class CaseSLAComplianceClassTest{

    private static testMethod void testSLADeadline(){
        Test.startTest();
            setupCaseSettings();
            //Set<String> x = getCaseSettings('x');
            Account testAccount = createAccount('Lanyon Master');
            Contact testContact = createContact('Test Contact', testAccount.id );
            
            //for Standard Response
            Case testCaseP1S    = createCase('Travel', testContact, 'P1 - Site Down/System Outage' );
            Case testCaseP2S    = createCase('Travel', testContact, 'P2 - High/Critical' );
            Case testCaseP3S    = createCase('Travel', testContact, 'P3 - Medium' );
            Case testCaseP4S    = createCase('Travel', testContact, 'P4 - Low/None' );

            //for Quick Response 
            Case testCaseP1Q    = createCase('StarCite', testContact, 'P1 - Site Down/System Outage' );
            Case testCaseP2Q    = createCase('StarCite', testContact, 'P2 - High/Critical' );

            
            List <case> checkCase = [Select Id, SLA_Deadline__c, Status From Case where Id =: testCaseP1S.id OR
                                                                                Id =: testCaseP2S.id OR
                                                                                Id =: testCaseP3S.id OR
                                                                                Id =: testCaseP4S.id OR
                                                                                Id =: testCaseP1Q.id OR
                                                                                Id =: testCaseP2Q.id ];

            for(case c: checkCase){
                //Assert that the case SLA deadline is populated
                //System.assertNotEquals(null,c.SLA_Deadline__c,'SLA Deadline should be populated');

            }
            List <case> updatedCase = new List<case>();
            Set <String> updatedID  = new Set<String>();
            Set <String> updatedID2 = new Set<String>();
            checkCase[0].status = 'Updated';
            checkCase[1].status = 'ReOpened';
            checkCase[2].status = 'Open - Investigating';
            checkCase[3].status = 'Open - Waiting on 3rd Party';
            checkCase[4].status = 'Open - Waiting on Customer Information';
            updatedCase.add(checkCase[0]);
            updatedCase.add(checkCase[2]);
            updatedCase.add(checkCase[1]);
            updatedCase.add(checkCase[3]);
            updatedCase.add(checkCase[4]);

            update updatedCase;
            updatedID.add(checkCase[0].id);
            updatedID.add(checkCase[2].id);
            updatedID.add(checkCase[1].id);
            updatedID2.add(checkCase[3].id);
            updatedID2.add(checkCase[4].id);

            List <case> checkCase2 = [Select Id, SLA_Deadline__c, Status From Case where Id in: updatedID];
            List <case> checkCase3 = [Select Id, SLA_Deadline__c, Status From Case where Id in: updatedID2];

            for(case p: checkCase2){
                //Assert that the case SLA deadline is populated
                //System.assertNotEquals(null,p.SLA_Deadline__c,'SLA Deadline should be populated');

            }
            for(case n: checkCase3){
                //Assert that the case SLA deadline is null
                //System.assertEquals(null,n.SLA_Deadline__c,'SLA Deadline should be null');

            }


         Test.stopTest();
        
    }
    //Create Account
    static Account createAccount(String name) {
        Account testAccount             = new Account();
        testAccount.Name                = name;
        insert testAccount;
        return testAccount;
    }
    //create Case
    static Case createCase(String productFamily, Contact contact, String priority) {
        Case testCase = new Case();
        //testCase.Product_Family_Name__c = productFamily;
        testCase.Status                 = 'New'; 
        testCase.Contact                = contact; 
        testCase.Subject                = 'Test Subject';
        testCase.Description            = 'Test Description';
        testCase.Priority               = priority;
        insert testCase;    
        return testCase;
    }
    //create Contact
    static Contact createContact(String name, Id account ){
        Contact testContact             = new Contact();
        testContact.FirstName           = name;
        testContact.LastName            = 'Contact'; 
        testContact.AccountId           = account; 
        insert testContact;
        return testContact;
    }
    //Create Custom Settings 
    static void setupCaseSettings() {
        Case_Settings__c settings       = new Case_Settings__c();
        settings.Name                   = 'CaseStatus';
        settings.X24_hrs_SLA__c         = 'ReOpened,Escalated';
        settings.Case_Status__c         = 'Open - Investigating, Open - Waiting on 3rd Party, Open - Waiting on Customer Information, Updated,ReOpened,Re-Close,Closed by System,Updated Development/IT,Scheduled for Later,Repeating Task,Work in Progress,Escalated,Closed';
        settings.Quick_Responses__c     = 'StarCite,New_Passkey,New_Group_Meetings,New_Meeting';
        settings.Standard_Response__c   = 'New_Business_Transient,New_RegOnline,New_GenieConnect,New_Conference';
        settings.Status_where_SLA_deadline_apply__c = 'Open - Investigating, Updated, ReOpened';
        insert settings;

    }

}