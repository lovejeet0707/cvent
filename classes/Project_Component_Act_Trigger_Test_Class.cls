@isTest
private class Project_Component_Act_Trigger_Test_Class {

    static testMethod void myUnitTest() {
         
        //User u1 = [SELECT Id FROM User WHERE Alias='Sam'];
       //System.runAs(u1){
       Date s_Date = Date.Today();
       s_Date = s_Date.addDays(5);
       String ap_id, ownername;
       ownername = 'Sid Dasgupta(00500000006rFIC)';
       ap_id = 'a0500000002fcfn';  // Prod
       Date e_Date = s_Date.addDays(8);
        
        for (Analysis_Projects__c check_ap : [Select a.Id From Analysis_Projects__c a limit 1])
        {
            ap_id = check_ap.id ;
        }
        
        Project_Activity__c Pro_Act = new  Project_Activity__c (Report_Description__c='sa',Analysis_Project__c =ap_id, Entitled_Hours__c = 26, Name='Test', Activity_Status__c ='Yet to Start',Activity_Start_Date__c=s_Date ,Activity_End_Date__c=e_Date);
        insert Pro_Act;
        ID x = Pro_Act.id;
        Project_Activity__c accs1 = [Select Activity_Start_Date__c ,Activity_End_Date__c, Component_Owner__c, Entitled_Hours__c from Project_Activity__c where Id = :x];
        //accs1.Component_Owner__c = 'Sandeep Bhat(00500000006xrtu)';
        update accs1;
        
        
        Project_Activity__c Pro_Act2 = new  Project_Activity__c (Report_Description__c='sa',Analysis_Project__c =ap_id, Entitled_Hours__c = 10, Name='Test', Activity_Status__c ='Yet to Start',Activity_Start_Date__c=s_Date ,Activity_End_Date__c=e_Date);
        insert Pro_Act2;
        x = Pro_Act2.id;
        Project_Activity__c accs12 = [Select Activity_Start_Date__c ,Activity_End_Date__c, Component_Owner__c, Entitled_Hours__c from Project_Activity__c where Id = :x];
        //accs12.Component_Owner__c = 'Sandeep Bhat(00500000006xrtu)';
        accs12.Entitled_Hours__c = 9;
        update accs12;
        
        
        
        Project_Activity__c Pro_Act_new = new  Project_Activity__c (Report_Description__c='sa',Type_of_Project__c= 'Data Dump  Assigned dynamically', Analysis_Project__c =ap_id, Entitled_Hours__c = 40, Name='Test',  Activity_Status__c ='Yet to Start',Activity_Start_Date__c=s_Date ,Activity_End_Date__c=e_Date);
        insert Pro_Act_new;
        x = Pro_Act_new.id;
        Project_Activity__c accs2 = [Select Type_of_Project__c, Id, Component_Owner__c from Project_Activity__c where Id = :x];
        accs2.Type_of_Project__c = 'Data Dump  Assigned dynamically';   
        update accs2;
        
        
}
}
//}