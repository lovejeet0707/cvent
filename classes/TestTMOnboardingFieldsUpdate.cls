@Istest(SeeAllData=True)
    
    private class TestTMOnboardingFieldsUpdate
    {
      static testmethod void testFieldUpdate()
      {
        List<TM_Buildout__c> tmList=new  List<TM_Buildout__c> ();
        for(integer i=0;i<=12;i++)
        {
        TM_Buildout__c tm=new TM_Buildout__c(Name='Test'+i);
        tmList.add(tm);
        }
        insert tmList;
        List<Task> tList=new List<Task>();
        for(integer i=0;i<12;i++)
        {
          Task t=new Task(Status='Completed',ActivityDate=system.today().adddays(-1),Priority='Normal',WhatId=tmList[0].id);
          
          if(i==0)
          {
            t.Subject='Client Launch Date';
            Task t0=new Task(Status='Completed',ActivityDate=system.today().adddays(-1),Priority='Normal',WhatId=tmList[1].id);
            t0.Subject='Client Launch Date';
            tList.add(t0);
            
          }
          if(i==1)
          {
            t.Subject='Add/Verify Service Fee';
            Task t1=new Task(Status='Completed',ActivityDate=system.today().adddays(-1),Priority='Normal',WhatId=tmList[2].id);
            t1.Subject='Add/Verify Service Fee';
            tList.add(t1);
            
          }
          if(i==2)
          {
            t.Subject='Create Events';
            Task t2=new Task(Status='Completed',ActivityDate=system.today().adddays(-1),Priority='Normal',WhatId=tmList[3].id);
            t2.Subject='Create Events';
             tList.add(t2);
          }
          if(i==3)
          {
            t.Subject='Designed Approved';
            Task t3=new Task(Status='Completed',ActivityDate=system.today().adddays(-1),Priority='Normal',WhatId=tmList[4].id);
            t3.Subject='Designed Approved';
             tList.add(t3);
          }
          if(i==4)
          {
            t.Subject='Equipment Training';
            Task t4=new Task(Status='Completed',ActivityDate=system.today().adddays(-1),Priority='Normal',WhatId=tmList[5].id);
             t4.Subject='Equipment Training';
              tList.add(t4);
          }
          if(i==5)
          {
            t.Subject='Import Previous TB Data';
            Task t5=new Task(Status='Completed',ActivityDate=system.today().adddays(-1),Priority='Normal',WhatId=tmList[6].id);
            t5.Subject='Import Previous TB Data';
             tList.add(t5);
          }
          if(i==6)
          {
            t.Subject='Design Approved';
            Task t6=new Task(Status='Completed',ActivityDate=system.today().adddays(-1),Priority='Normal',WhatId=tmList[7].id);
            t6.Subject='Design Approved';
             tList.add(t6);
          }
          if(i==7)
          {
            t.Subject='Merchant A/C Setup Date';
            Task t7=new Task(Status='Completed',ActivityDate=system.today().adddays(-1),Priority='Normal',WhatId=tmList[8].id);
            t7.Subject='Merchant A/C Setup Date';
             tList.add(t7);
          }
          if(i==8)
          {
            t.Subject='Collect W9';
            Task t8=new Task(Status='Completed',ActivityDate=system.today().adddays(-1),Priority='Normal',WhatId=tmList[9].id);
            t8.Subject='Collect W9';
             tList.add(t8);
          }
          if(i==9)
          {
            t.Subject='Verify Gateway Info';
            Task t9=new Task(Status='Completed',ActivityDate=system.today().adddays(-1),Priority='Normal',WhatId=tmList[10].id);
            t9.Subject='Verify Gateway Info';
             tList.add(t9);
          }
          
          if(i==10)
          {
            t.Subject='Q/A Testing';
            Task t10=new Task(Status='Completed',ActivityDate=system.today().adddays(-1),Priority='Normal',WhatId=tmList[11].id);
            t10.Subject='Q/A Testing';
             tList.add(t10);
          }
          
          if(i==11)
          {
            t.Subject='Sent to Client for Approval';
            Task t11=new Task(Status='Completed',ActivityDate=system.today().adddays(-1),Priority='Normal',WhatId=tmList[12].id);
            t11.Subject='Sent to Client for Approval';
             tList.add(t11);
          }
          
         if(i==12)
          {
            t.Subject='Site Design Completion Date';
            Task t12=new Task(Status='Completed',ActivityDate=system.today().adddays(-1),Priority='Normal',WhatId=tmList[13].id);
            t12.Subject='Q/A Testing';
             tList.add(t12);
          }
          
      /*    if(i==13)
          {
            t.Subject='Walkthrough & Training';
            Task t13=new Task(Status='Completed',ActivityDate=system.today().adddays(-1),Priority='Normal',WhatId=tmList[14].id);
            t13.Subject='Walkthrough & Training';
             tList.add(t13);
          } */
            tList.add(t);
            
        }
           if(tList.size()>0)
           {
           Test.StartTest();
            insert tList;
            update tList;
            Test.StopTest();
           }
      
      }
    
    }