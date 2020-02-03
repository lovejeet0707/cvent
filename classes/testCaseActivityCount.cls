@isTest(SeeAlldata= true)
    private class testCaseActivityCount {
    public static Boolean didRun = false;
    static testmethod void testCaseActivityCount()

            {
                        
            Account a = new Account(name='Test');
            insert a;
    
            Case cs = new Case(Status='Open',subject='Test');
            insert cs;
    
            Task t = new Task(subject='Test Activity', whatId = cs.id);
            insert t;
    
            cs = [SELECT ID, of_Delivered_Reports__c FROM Case WHERE ID = :cs.id];
         //   System.assertEquals(0,cs.of_Delivered_Reports__c);
    
            didRun = false;
            t.whatId = null;
            update t;
            cs = [SELECT ID, of_Delivered_Reports__c FROM Case WHERE ID = :cs.id];
         //   System.assertEquals(0,cs.of_Delivered_Reports__c);
    
            didRun = false; 
            
               
            
            cs = [SELECT ID, of_Delivered_Reports__c FROM Case WHERE ID = :cs.id];
           // System.assertEquals(1,cs.of_Delivered_Reports__c);
    
           
            didRun = false; 
            t.whatId = cs.id;
            update t;
    
            cs= [SELECT ID, of_Delivered_Reports__c FROM Case WHERE ID = :cs.id];
          //  System.assertEquals(2,cs.of_Delivered_Reports__c);
    
               
            cs = [SELECT ID, of_Delivered_Reports__c FROM Case WHERE ID = :cs.id];
         //   System.assertEquals(1,cs.of_Delivered_Reports__c);
    
            didRun = false; 
            delete t;
            
            cs = [SELECT ID, of_Delivered_Reports__c FROM Case WHERE ID = :cs.id];
          //  System.assertEquals(0,cs.of_Delivered_Reports__c);
    
        }
    
    }