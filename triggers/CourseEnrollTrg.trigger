trigger CourseEnrollTrg on docebo_v3__CourseEnrollment__c (after insert, after update, after delete, after undelete) {
  set<id> conId = new set<id>();
  
  if(trigger.IsAfter && (trigger.IsUndelete || trigger.IsInsert)){
      for(docebo_v3__CourseEnrollment__c c : trigger.new){
        conId.add(c.Contact__c);
      }
  }
  if(trigger.IsDelete && trigger.IsAfter){
    for(docebo_v3__CourseEnrollment__c cp : trigger.old){
        conId.add(cp.Contact__c);
      }
  }
  if(trigger.IsAfter && trigger.isUpdate){
   for(docebo_v3__CourseEnrollment__c cpa : trigger.new){
    if((trigger.oldmap.get(cpa.id).Contact__c != cpa.Contact__c) || (trigger.oldmap.get(cpa.id).docebo_v3__Status__c != cpa.docebo_v3__Status__c)){
        conId.add(cpa.Contact__c);
     }
   }  
  }
  
     if(conId.size() > 0){
        List<Contact> contactList = [select id,Total_Courses_Completed__c,Total_Courses_In_Progress__c,Total_Courses_Subscribed__c,(SELECT id,docebo_v3__Status__c,Contact__c FROM Course_Enrollments__r) from Contact WHERE id =: conId];
        For(Contact con: contactList){
         integer completedCourse = 0;
         integer inProgressCourse = 0;
         integer subscribedCourse = 0;
         
           for(docebo_v3__CourseEnrollment__c  enroll : con.Course_Enrollments__r){
            if(enroll.docebo_v3__Status__c =='Completed'){
             completedCourse +=1;
            }
            if(enroll.docebo_v3__Status__c =='In_Progress'){
             inProgressCourse +=1;
            }
            if(enroll.docebo_v3__Status__c =='Subscribed'){
             subscribedCourse +=1;
            }
          }
          con.Total_Courses_Completed__c= completedCourse ;
          con.Total_Courses_In_Progress__c= inProgressCourse ;
          con.Total_Courses_Subscribed__c= subscribedCourse;
        }
        
        if(contactList.size() > 0 ){
            update contactList;
        }
    }
}