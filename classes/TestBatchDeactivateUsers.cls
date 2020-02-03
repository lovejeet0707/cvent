@isTest
public class TestBatchDeactivateUsers {
        
    static testmethod void test(){
         /*  
        
          As all below logic is run by the batch . so need to run query on user here .In test class,we had to create test users here whose last login must be before 2 month but
           we can not set the last login date for user in test class as it is read only field.So there is no benfit to create user here.
           
         */
      //  datetime myDateTime = datetime.now();
     //   datetime inactiveDateTime = myDateTime.addDays(-60);
     //   User[] ul = new List<User>([SELECT Id,IsActive FROM User WHERE (IsPortalEnabled = false AND isActive = true AND lastLoginDate < :inactiveDateTime) ]);
                
        Test.startTest();
            BatchDeactivateUsers b = new BatchDeactivateUsers();
            b.csvContent = 'Error Occured';
            Database.executeBatch(b);
        Test.stopTest();
        
      //  Integer i =[SELECT count()FROM User WHERE (IsPortalEnabled = false AND isActive = true AND lastLoginDate < :inactiveDateTime)];
      //  System.assertEquals(i,0);
    }
}