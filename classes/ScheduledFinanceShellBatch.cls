global class ScheduledFinanceShellBatch implements Schedulable {
    global void execute(SchedulableContext sc) {
      Date todayDate = Date.today();
      Integer dateValue = Integer.valueof(Label.Finance_Shell_Date_Range);
      Date lastWeekDate = todayDate.addDays(dateValue);
      Set<Id> opportunityIds = new Set<Id>();
      

      List<Contract_Reviewing__c> lstContractReviewed = [SELECT Opportunity__c
                                                           FROM Contract_Reviewing__c 
                                                          WHERE Final_Review_Date__c >= :lastWeekDate 
                                                            AND Final_Review_Date__c <= :todayDate
                                                            AND Contract_Review_Ok__c = 'Yes'];

      for(Contract_Reviewing__c lstItr : lstContractReviewed){
            opportunityIds.add(lstItr.Opportunity__c);
      }
      // Dishank - updated to work only for Closed Won opportunities
      /*List<Opportunity> lstOpportunities = [SELECT Id 
                                              FROM Opportunity 
                                             WHERE CloseDate>=:lastWeekDate 
                                               AND CloseDate <= :todayDate
                                               AND StageName IN ('Closed Lost',
                                                                  'Closed -- Never Qualified',
                                                                  'Cancelled', 
                                                                  'Opted-Out', 
                                                                  'Closed Lost - Opted Out/Cancelled', 
                                                                  'Closed Reassigned')];

      for(Opportunity lstItr : lstOpportunities){
            opportunityIds.add(lstItr.Id);
      }*/
      String mailSubject = 'Finance Shell Opportunities for Date ' + lastWeekDate.day() +'/'+ lastWeekDate.month() + '/' + lastWeekDate.year() 
                         + ' - ' + todayDate.day() + '/' + todayDate.month() + '/' +todayDate.year();
      String body = '';
       if(opportunityIds.size()>0){
            body = '<table border = "1"><tr><th>Opportunity List </th></tr>';
            for(Id setItr : opportunityIds){
                  body +='<tr><td>'+ setItr + '</td></tr>';
            }
            body += '</table>';           
      }
      else {
            body += '<b>No Opportunities</b>';
      }
      String emailRecevierList = Label.Opportunity_Email_Receivers;
      String[] sendingTo= emailRecevierList.split(',');
      sendEmail(opportunityIds,mailSubject,body,sendingTo);

      CreateFincanceShallFromOpp b = new CreateFincanceShallFromOpp(opportunityIds); 
      Database.executeBatch(b,1);
   }

   public void sendEmail(Set<Id> opportunityIds,String mailSubject ,String mailBody, String[] strReceipent){
      Messaging.SingleEmailMessage semail=new Messaging.SingleEmailMessage();
      semail.setToAddresses(strReceipent);
      semail.setSubject(mailSubject);
      semail.setHtmlBody(mailBody);
      Messaging.SendEmail(new Messaging.SingleEmailMessage[]{semail});
   }
}