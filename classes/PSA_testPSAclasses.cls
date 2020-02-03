@isTest
public class PSA_testPSAclasses {
    
    @testSetup static void setup(){
        
        User u = [SELECT Id FROM User 
                  WHERE Profile.Name = 'System Administrator'
                  AND IsActive = TRUE AND Validation_Bypass__c = FALSE
                  AND ManagerId <> NULL AND Manager.ManagerId <> NULL
                  AND Manager.IsActive = TRUE AND Manager.Manager.IsActive = TRUE LIMIT 1];
        
        PSA_generateTestData.customSettings();
        
        Account a = PSA_generateTestData.getAccount('Test PSA Account');
        
        pse__Region__c r = PSA_generateTestData.getRegion('Region');
        
        pse__Practice__c p = PSA_generateTestData.getPractice('Practice');
        
        system.debug('***************Practice Name = ' + p.Name);
        
        pse__Grp__c g = PSA_generateTestData.getGrp('Group');
        
        Contact c = PSA_generateTestData.getResource('Test', 'PSA', 'psatest@cvent.com',
                                                     a.Id, r.Id, p.Id, g.Id, u.Id);
        
        pse__Proj__c proj = PSA_generateTestData.getProject('Test Project', r.Id, p.Id, g.Id, c.Id, 'Project Manager', a.id);
        
        PSA_generateTestData.getPC(u.Id, r.Id); 
        
    }
    
    static testmethod void testPopulatePMsMgr(){
        
        pse__Proj__c p = [SELECT Id FROM pse__Proj__c WHERE Name = 'Test Project'];
        
        test.startTest();
        p.PM_s_Manager__c = null;
        p.PM_s_Manager_s_Manager__c = null;
        update p;
        test.stopTest();
        
    }
    
    static testmethod void testSumMilestoneWeight(){
        
        pse__Proj__c p = [SELECT Id FROM pse__Proj__c WHERE Name = 'Test Project'];
        
        test.startTest();
        pse__Milestone__c m = new pse__Milestone__c(Name = 'Test Milestone', pse__Target_Date__c = date.today(), pse__Project__c = p.Id,
                                                    pse__Status__c = 'Open', Milestone_Weight_for_Project__c = 100);
        insert m;
        
        m.pse__Status__c = 'Approved';
        m.pse__Actual_Date__c = date.today();
        
        update m;
    }
    
    
    static testmethod void testAllTimecardHeaderTriggerMethods(){
        
        pse__Proj__c p = [SELECT Id, pse__End_Date__c, pse__Start_Date__c,
                             pse__Project_Manager__c, pse__Project_Manager__r.pse__Salesforce_User__c 
                             FROM pse__Proj__c WHERE Name = 'Test Project'];
        
        p.pse__Is_Billable__c = TRUE;
        p.pse__Allow_Timecards_Without_Assignment__c = TRUE;
        
        update p;
        
        User u = [SELECT Id FROM User WHERE Id =: p.pse__Project_Manager__r.pse__Salesforce_User__c];
              
        pse__Milestone__c m = new pse__Milestone__c(Name = 'Test Milestone', pse__Target_Date__c = date.today(), pse__Project__c = p.Id,
                                                    pse__Status__c = 'Open', Non_Billable_Milestone__c = TRUE);
        
        insert m;
        
        system.runAs(u) {
            
            
            test.startTest();
            
            pse__Timecard_Header__c tc = new pse__Timecard_Header__c(pse__Project__c = p.Id, pse__Status__c = 'Submitted',
                                                                     pse__Resource__c = p.pse__Project_Manager__c,
                                                                     pse__Billable__c = TRUE, pse__Milestone__c = m.Id,                                                                    
                                                                     pse__Disable_Approval_Auto_Submit__c = TRUE,
                                                                     pse__Approved__c = TRUE, pse__Submitted__c = TRUE,
                                                                     pse__Start_Date__c = date.today().toStartOfWeek(),
                                                                     pse__End_Date__c = date.today().toStartOfWeek().addDays(6),
                                                                     pse__Monday_Hours__c = 1, pse__Monday_Notes__c = 'notes');
            
            insert tc;
            
            
            test.stopTest();
            
        }
    }
    
    static testmethod void testPopulateTimePeriods(){
        
        pse__Proj__c p = [SELECT Id, pse__Project_Manager__c, pse__Region__c,
                          pse__Project_Manager__r.pse__Salesforce_User__c 
                          FROM pse__Proj__c 
                          WHERE Name = 'Test Project'];
        
        p.pse__Start_Date__c = date.parse('08/01/2017');
        p.pse__End_Date__c = date.parse('08/31/2017');
        p.MBO_Time_Excluded__c = TRUE;
        p.Internal_MBO__c = TRUE;
        p.pse__Allow_Timecards_Without_Assignment__c = TRUE;
        
        update p;
        
        User u = [SELECT Id FROM User WHERE Id =: p.pse__Project_Manager__r.pse__Salesforce_User__c];
        
        pse__Milestone__c m = new pse__Milestone__c(Name = 'Test Milestone', pse__Target_Date__c = date.today(), 
                                                    pse__Project__c = p.Id, pse__Status__c = 'Open');
        
        insert m;
        
        //Create Time Periods
        list<pse__Time_Period__c> tpInsert = new list<pse__Time_Period__c>();
        for(integer i = 1; i < 4; i++) {
            string tpType;
            string tpName;
            date startDate;
            date endDate;
            
            if(i == 1) {
                tpType = 'Month';
                tpName = 'Test Month TP';
                startDate = date.parse('08/01/2017');
                endDate = date.parse('08/31/2017');
            }
            else if(i == 2) {
                tpType = 'Quarter';
                tpName = 'Test Quarter TP';
                startDate = date.parse('07/01/2017');
                endDate = date.parse('9/30/2017');
            }
            else if(i == 3) {
                tpType = 'Year';
                tpName = 'Test Year TP';
                startDate = date.parse('01/01/2017');
                endDate = date.parse('12/31/2017');
            }
            
            pse__Time_Period__c tp = new pse__Time_Period__c(pse__Type__c = tpType, pse__Start_Date__c = startDate,
                                                             pse__End_Date__c = endDate, Name = tpName);
            tpInsert.add(tp);
                        
        }
        
        insert tpInsert;
        
        system.runAs(u) {
        
            test.startTest();
                
                list<pse__Timecard_Header__c> tcList = new list<pse__Timecard_Header__c>();
                for(integer i = 0; i < 2; i++) {
                    pse__Timecard_Header__c tc = new pse__Timecard_Header__c(pse__Project__c = p.Id, pse__Status__c = 'Approved',
                                                                             pse__Resource__c = p.pse__Project_Manager__c,
                                                                             pse__Milestone__c = m.Id, pse__Billable__c = FALSE,                                                                  
                                                                             pse__Disable_Approval_Auto_Submit__c = TRUE,
                                                                             pse__Approved__c = TRUE, pse__Submitted__c = TRUE,
                                                                             pse__Start_Date__c = date.parse('08/20/2017'),
                                                                             pse__End_Date__c = date.parse('08/26/2017'),
                                                                             pse__Monday_Hours__c = 1, pse__Monday_Notes__c = 'notes');
                    
                    tcList.add(tc);    
                    
                }
                    
                insert tcList;
            
                //Create UC record
                pse__Utilization_Calculation__c uc = new pse__Utilization_Calculation__c();
                    uc.pse__Region__c = p.pse__Region__c;
                    uc.pse__Time_Period_Types__c = 'Month; Quarter; Year';
                    uc.pse__Status__c = 'Complete';
                    uc.Name = 'Test UC record';
                    uc.pse__Type__c = 'Current Year';
                
                insert uc;
                
                //Create UD records
                list<pse__Utilization_Detail__c> udInsert = new list<pse__Utilization_Detail__c>();
                for(pse__Time_Period__c tp : [SELECT Id, pse__Type__c FROM pse__Time_Period__c]) {
                    pse__Utilization_Detail__c ud = new pse__Utilization_Detail__c();
                        ud.pse__Time_Period__c = tp.Id;
                        ud.pse__Time_Period_Type__c = tp.pse__Type__c;
                        ud.pse__Resource__c = p.pse__Project_Manager__c;
                        ud.pse__Utilization_Calculation__c = uc.Id;
                        ud.pse__Type__c = 'Resource';
                    
                    udInsert.add(ud);
                }
                insert udInsert;
            
                PSA_MBOcalculationsBatch b = new PSA_MBOcalculationsBatch(); 
                database.executebatch(b);              
                
            test.stopTest();
        }
    }

    static testmethod void testExpenseReportTriggerMethods(){
        
        pse__Proj__c p = [SELECT Id, pse__Project_Manager__c, pse__Region__c,
                          pse__Project_Manager__r.pse__Salesforce_User__c 
                          FROM pse__Proj__c 
                          WHERE Name = 'Test Project'];
        
        p.pse__Allow_Expenses_Without_Assignment__c = TRUE;
        update p;
        
        User u = [SELECT Id FROM User WHERE Id =: p.pse__Project_Manager__r.pse__Salesforce_User__c];
        
        list<EBS_Integration__c> ebsList = new list<EBS_Integration__c>();
        for(integer i = 0; i < 6; i++) {
            EBS_Integration__c ebs = new EBS_Integration__c();
            ebs.Object__c = 'pse__Expense_Report__c';
            ebs.Map__c = TRUE;
            if(i == 0){
                ebs.Name = 'expense_number__c';
                ebs.Field__c = 'expense_number__c';
                ebs.Map_To__c = 'Field1__c';
                ebs.Validate__c = TRUE;                
            }
            else if(i == 1){
                ebs.Name = 'EBS_Vendor_Num__c';
                ebs.Field__c = 'EBS_Vendor_Num__c';
                ebs.Map_To__c = 'Field2__c';
                ebs.Validate__c = TRUE;                
            }
            else if(i == 2){
                ebs.Name = 'pse__Total_Reimbursement_Amount__c';
                ebs.Field__c = 'pse__Total_Reimbursement_Amount__c';
                ebs.Map_To__c = 'Field3__c';
                ebs.Validate__c = TRUE;                
            }
            else if(i == 3){
                ebs.Name = 'Approved_Date__c';
                ebs.Field__c = 'Approved_Date__c';
                ebs.Map_To__c = 'Field4__c';
                ebs.Validate__c = TRUE;                
            }
            else if(i == 4){
                ebs.Name = 'pse__Reimbursement_Currency__c';
                ebs.Field__c = 'pse__Reimbursement_Currency__c';
                ebs.Map_To__c = 'Field5__c';
                ebs.Validate__c = TRUE;                
            }
            else if(i == 5){
                ebs.Name = 'pse__Project__r.pse__Project_ID__c';
                ebs.Field__c = 'pse__Project__r.pse__Project_ID__c';
                ebs.Map_To__c = 'Field6__c';
                ebs.Validate__c = FALSE;                
            }
            
            ebsList.add(ebs);
        }
        
        insert ebsList;
        
        
        
        Expense_Type__c et = new Expense_Type__c(Name = 'Airfare', COGS_Account_Number__c = '12345', Internal_Account_Number__c = '54321');
        insert et;
        
        system.runAs(u) {
            test.startTest();
            
            pse__Expense_Report__c er = new pse__Expense_Report__c(Name = 'Test ER', pse__Resource__c = p.pse__Project_Manager__c,
                                                                   pse__Project__c = p.Id, pse__Status__c = 'Draft');
        
            insert er;
            
            pse__Expense__c e = new pse__Expense__c(pse__Expense_Report__c = er.Id, pse__Resource__c = p.pse__Project_Manager__c,
                                                    pse__Project__c = p.Id, pse__Status__c = 'Draft', pse__Type__c = 'Airfare',
                                                    pse__Amount__c = 500, pse__Expense_Date__c = date.today());
            
            insert e;
            
            er.pse__Status__c = 'Submitted';
            er.pse__Disable_Approval_Auto_Submit__c = TRUE;
            er.pse__Submitted__c = TRUE;
            update er;
            
            er.pse__Status__c = 'Approved';
            er.pse__Include_In_Financials__c = TRUE;
            er.pse__Approved__c = TRUE;
            er.Approved_Date__c = date.today();
            update er;
            
            test.stopTest();
            
        }               
    }
    
    static testmethod void testResourceRequestMethods(){
        
        pse__Proj__c p = [SELECT Id, pse__Project_Manager__c, pse__Group__c,
                          pse__Region__c, pse__Practice__c, pse__Start_Date__c, pse__End_Date__c,
                          pse__Project_Manager__r.pse__Salesforce_User__c 
                          FROM pse__Proj__c 
                          WHERE Name = 'Test Project'];
               
        User u = [SELECT Id FROM User WHERE Id =: p.pse__Project_Manager__r.pse__Salesforce_User__c];
        
        pse__Grp__c g = [SELECT Id FROM pse__Grp__c WHERE Id =: p.pse__Group__c];
        g.Resource_Manager__c = p.pse__Project_Manager__c;
        update g;
        
        system.runAs(u) {
            
            test.startTest();
            pse__Resource_Request__c rr = new pse__Resource_Request__c(pse__Project__c = p.Id, pse__Resource_Role__c = 'Developer',
                                                                       pse__SOW_Hours__c = 20, pse__Start_Date__c = p.pse__Start_Date__c,
                                                                       pse__End_Date__c = p.pse__End_Date__c, pse__Region__c = p.pse__Region__c,
                                                                       pse__Practice__c = p.pse__Practice__c, pse__Group__c = p.pse__Group__c,
                                                                       pse__Status__c = 'Ready to Staff');
            
            insert rr;
            test.stopTest();
            
        }        
    }
    
    static testmethod void testClientMeetingMethods(){
        
        Account a = [SELECT Id FROM Account];
        
        test.startTest();
        
        Client_Meeting__c cm = new Client_Meeting__c(Client_Account__c = a.Id, Meeting_Date__c = date.today().addDays(-60), Active__c = TRUE);
        
        insert cm;
        
        test.stopTest();
        
    }
    
    static testmethod void testSurveyMethods(){
        
        pse__Proj__c p = [SELECT Id, pse__Project_Manager__c, pse__Account__c,
                          pse__Project_Manager__r.Email
                          FROM pse__Proj__c 
                          WHERE Name = 'Test Project'];
        
        
        test.startTest();
        
        Survey_Header__c sh = new Survey_Header__c(Account__c = p.pse__Account__c, Contact__c = p.pse__Project_Manager__c, Project__c = p.Id);
        
        insert sh;
        
        list<Survey_Q__c> sqList = new list<Survey_Q__c>();
        for(integer i = 1; i < 6; i++) {
           Survey_Q__c sq = new Survey_Q__c();
           sq.SurveyHeader__c = sh.Id; 
           sq.Name = 'Test Survey Q ' + string.valueOf(i); 
           if(i == 1) { sq.Answere__c = 'Very Satisfied'; }
           else if(i == 2) { sq.Answere__c = 'Satisfied'; }
           else if(i == 3) { sq.Answere__c = 'Neutral'; }
           else if(i == 4) { sq.Answere__c = 'Dissatisfied'; }
           else if(i == 5) { sq.Answere__c = 'Very Dissatisfied'; }
           sqList.add(sq);
        }
        
        
        insert sqList;
        
        delete sqList;
        
        test.stopTest();
        
        
    }
    
    
    static testmethod void testDemoScopingRequestMethods(){
        
        Contact c = [SELECT Id, pse__Salesforce_User__c FROM Contact];
        User u = [SELECT Id FROM User WHERE Id = : c.pse__Salesforce_User__c];
        
        Demo_Scoping_Request__c dsr = new Demo_Scoping_Request__c();
        insert dsr;
        
        dsr.Primary_Reviewer_1__c = u.Id;
        dsr.Primary_Reviewer_2__c = u.Id;
        dsr.Primary_Reviewer_3__c = u.Id;
        dsr.Primary_Reviewer_4__c = u.Id;
        dsr.Primary_Reviewer_5__c = u.Id;
        dsr.Primary_Reviewer_6__c = u.Id;
        
        update dsr;
        
        dsr.Reviewer_1_Status__c = 'Review Complete';
        dsr.Reviewer_2_Status__c = 'Review Complete';
        dsr.Reviewer_3_Status__c = 'Review Complete';
        dsr.Reviewer_4_Status__c = 'Review Complete';
        dsr.Reviewer_5_Status__c = 'Review Complete';
        dsr.Reviewer_6_Status__c = 'Review Complete';
        
        update dsr;
        
    }
    
    
    
    static testmethod void testCreateCreditedTCsBatch(){
        
        PSA_Daily_Rate_Utilization_Settings__c drus = new PSA_Daily_Rate_Utilization_Settings__c(Name = 'Default', Org_Default__c = 8);
        insert drus;
        
        pse__Proj__c p = [SELECT Id, pse__Project_Manager__c, pse__Region__c,
                          pse__Project_Manager__r.pse__Salesforce_User__c 
                          FROM pse__Proj__c 
                          WHERE Name = 'Test Project'];
        
        p.pse__Is_Billable__c = TRUE;
        p.pse__Allow_Timecards_Without_Assignment__c = TRUE;
        
        update p;
        
        User u = [SELECT Id FROM User WHERE Id =: p.pse__Project_Manager__r.pse__Salesforce_User__c];
        
        pse__Milestone__c m = new pse__Milestone__c(Name = 'Test Milestone', pse__Target_Date__c = date.today(), 
                                                    pse__Project__c = p.Id, pse__Status__c = 'Open');
        
        insert m;
        
        system.runAs(u) {
                
            list<pse__Timecard_Header__c> tcList = new list<pse__Timecard_Header__c>();
            for(integer i = 0; i < 2; i++) {
                pse__Timecard_Header__c tc = new pse__Timecard_Header__c(pse__Project__c = p.Id, pse__Status__c = 'Approved',
                                                                         pse__Resource__c = p.pse__Project_Manager__c,
                                                                         pse__Milestone__c = m.Id, pse__Billable__c = TRUE,
                                                                         pse__Daily_Bill_Rate__c = TRUE, pse__Bill_Rate__c = 1000,
                                                                         pse__Disable_Approval_Auto_Submit__c = TRUE,
                                                                         pse__Approved__c = TRUE, pse__Submitted__c = TRUE,
                                                                         pse__Start_Date__c = date.today().toStartOfWeek(),
                                                                         pse__End_Date__c = date.today().toStartOfWeek().addDays(6),
                                                                         pse__Monday_Hours__c = 10, pse__Monday_Notes__c = 'notes',
                                                                         pse__Tuesday_Hours__c = 10, pse__Tuesday_Notes__c = 'notes',
                                                                         pse__Wednesday_Hours__c = 10, pse__Wednesday_Notes__c = 'notes',
                                                                         pse__Thursday_Hours__c = 10, pse__Thursday_Notes__c = 'notes',
                                                                         pse__Friday_Hours__c = 10, pse__Friday_Notes__c = 'notes',
                                                                         pse__Saturday_Hours__c = 10, pse__Saturday_Notes__c = 'notes',
                                                                         pse__Sunday_Hours__c = 10, pse__Sunday_Notes__c = 'notes');
                
                tcList.add(tc);    
                
            }
            
            insert tcList;
            
            test.startTest();
            PSA_createCreditedTCsBatch b = new PSA_createCreditedTCsBatch(); 
            database.executebatch(b);
            test.stopTest();   
        }
        
    }
    
    static testmethod void testProjectHealthBatch(){
        try{
        pse__Proj__c p = [SELECT Id, pse__Project_Manager__c, pse__Region__c,
                          pse__Account__c,
                          pse__Project_Manager__r.pse__Salesforce_User__c 
                          FROM pse__Proj__c 
                          WHERE Name = 'Test Project'];
        
        p.pse__Is_Billable__c = TRUE;
        p.pse__Start_Date__c = date.today().toStartOfMonth().addMonths(-1);
        p.pse__End_Date__c = date.today().toStartOfMonth().addMonths(2).addDays(-1);
        
        update p;
        
        pse__Milestone__c m = new pse__Milestone__c(Name = 'Test Milestone', pse__Target_Date__c = date.today(), 
                                                    pse__Project__c = p.Id, pse__Status__c = 'Open');
        
        User u = [SELECT Id FROM User WHERE Id =: p.pse__Project_Manager__r.pse__Salesforce_User__c];
        u.Validation_Bypass__c = TRUE;
        update u;
        
        list<pse__Time_Period__c> tpInsert = new list<pse__Time_Period__c>();
        pse__Time_Period__c tp1 = new pse__Time_Period__c(pse__Type__c = 'Month', pse__Start_Date__c = date.today().toStartOfMonth(),
                                                          pse__End_Date__c = date.today().toStartOfMonth().addMonths(1).addDays(-1),
                                                          Name = 'Month1');
        tpInsert.add(tp1);
        
        pse__Time_Period__c tp2 = new pse__Time_Period__c(pse__Type__c = 'Month', pse__Start_Date__c = date.today().toStartOfMonth().addMonths(1),
                                                          pse__End_Date__c = date.today().toStartOfMonth().addMonths(2).addDays(-1),
                                                          Name = 'Month2');
        tpInsert.add(tp2);
        
        insert tpInsert;
        
        pse__Schedule__c s = new pse__Schedule__c (pse__Start_Date__c = p.pse__Start_Date__c, pse__End_Date__c = p.pse__End_Date__c,
                                                   pse__Monday_Hours__c = 8,pse__Tuesday_Hours__c = 8);
        insert s;
        
        system.runAs(u) {
            
            pse__Assignment__c assig = new pse__Assignment__c (pse__Project__c = p.Id, pse__Resource__c = p.pse__Project_Manager__c,
                                                               pse__Bill_Rate__c = 0, pse__Schedule__c = s.Id, pse__Is_Billable__c = TRUE);
            
            insert assig;
            

            pse__Timecard_Header__c tc = new pse__Timecard_Header__c(pse__Project__c = p.Id, pse__Status__c = 'Approved',
                                                                     pse__Resource__c = p.pse__Project_Manager__c,
                                                                     pse__Billable__c = TRUE, pse__Milestone__c = m.Id,                                                                    
                                                                     pse__Disable_Approval_Auto_Submit__c = TRUE,
                                                                     pse__Assignment__c = assig.Id,
                                                                     pse__Approved__c = TRUE, pse__Submitted__c = TRUE,
                                                                     pse__Start_Date__c = date.today().toStartOfMonth().addDays(-1).
                                                                     toStartOfWeek().addDays(-1).toStartOfWeek(),
                                                                     pse__End_Date__c = date.today().toStartOfMonth().addDays(-1).
                                                                     toStartOfWeek().addDays(-1).toStartOfWeek().addDays(6),
                                                                     pse__Monday_Hours__c = 1, pse__Monday_Notes__c = 'notes');
            
            insert tc;
            
            pse__Est_vs_Actuals__c eva = new pse__Est_vs_Actuals__c(pse__Project__c = p.Id, pse__Assignment__c = assig.Id, pse__Time_Period_Type__c = 'Month',
                                                                    pse__Time_Period__c = tp2.Id, pse__Estimated_Hours__c = 64, pse__Start_Date__c = tp2.pse__Start_Date__c,
                                                                    pse__End_Date__c = tp2.pse__End_Date__c, pse__Actual_Hours__c = 0);
            insert eva;
            
            Events_QA_Major_Deliverable__c eqmd = new Events_QA_Major_Deliverable__c(Name = 'Test EQMD', Account__c = p.pse__Account__c, Project__c = p.Id,
                                                                                     Degree_of_Scope_Changes__c = '5 – More than one major change',
                                                                                     Remediation_Required__c = TRUE);
            
            insert eqmd;
            
            Events_Minor_Deliverable_Incident_Report__c emdir = new Events_Minor_Deliverable_Incident_Report__c
                (Severity_Index__c = '4 - Major issue with client', Project__c = p.Id);
            
            insert emdir;
            
            test.startTest();
            PSA_updateProjectHealthBatch b = new PSA_updateProjectHealthBatch(); 
            database.executebatch(b);
            test.stopTest();
        
        }    
        }Catch(Exception e){}  
    }
    
    
    static testmethod void testScheduleClasses(){
       
        PSA_createCreditedTCsSchedule tcs = new PSA_createCreditedTCsSchedule();
        PSA_MBOcalculationsSchedule mcs = new PSA_MBOcalculationsSchedule();
        PSA_updateProjectHealthSchedule phs = new PSA_updateProjectHealthSchedule();
        String cron = '0 0 02 * * ?';        
        Test.startTest();    
        System.schedule('Testing tcs', cron, tcs);
        System.schedule('Testing mcs', cron, mcs);
        System.schedule('Testing phs', cron, phs);
        Test.stopTest();
        
    }
}