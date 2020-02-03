/* ===============================
AUTHOR     :     Udita Dwivedi
Test class - salesResourcesTrgHelperClsTest
Ticket : Automation to map CSN-P Account Status in Account Hierarchy - TICCM-536 JIRA
============================= 
*/
global class BatchUpdateAccountCSN implements Database.Batchable<sObject>, Database.Stateful{
    Map<id,string> errMsgMap = new Map<id,string>();
    global Database.QueryLocator start(Database.BatchableContext BC){
      string query ='select id,CSN_P_Account_Status__c,Account_18_digit_id__c ,Purchased_License__c,Ultimate_ParentId__c,Ultimate_ParentId_18D__c  from Account where CSN_P_Account_Status__c=\'Closed Won\' OR Purchased_License__c INCLUDES (\'CSN Planner - Professional\',\'CSN Planner - Enterprise \',\'CSN Planner - Professional Plus\' )';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC,list<Account> scope){
        set<id> accountParentId = new set<id>();
        set<id> accountId = new set<id>();
        
        List<account> updateAccList= new list<account>();
        List<account> updateAccList1= new list<account>();
            for(Account instAcc : scope){      
              if((instAcc.CSN_P_Account_Status__c!= null && instAcc.CSN_P_Account_Status__c=='Closed Won') || (instAcc.Purchased_License__c!= null && (instAcc.Purchased_License__c.contains('CSN Planner - Professional') || instAcc.Purchased_License__c.contains('CSN Planner - Enterprise') || instAcc.Purchased_License__c.contains('CSN Planner - Professional Plus')))){
                if(instAcc.Account_18_digit_id__c != instAcc.Ultimate_ParentId_18D__c)
                   accountId.add(instAcc.Ultimate_ParentId_18D__c);
                if(instAcc.Account_18_digit_id__c == instAcc.Ultimate_ParentId_18D__c)
                   accountParentId.add(instAcc.Account_18_digit_id__c);
            }
            system.debug('---accountParentId'+accountParentId);
          }
        //Automation to map CSN-P Account Status in Account Hierarchy : Udita
        Boolean MethodIsActive = ExecuteMethodHelper.isActive('AccountStatusAccountHierarch');
        If(MethodIsActive){
       if(accountId.size() > 0  || accountParentId.size() > 0 ){
           List<Account> accountCSNPStatus = [select id,CSN_P_Account_Status__c from account where (Ultimate_ParentId_18D__c in:accountId or Ultimate_ParentId_18D__c in:accountParentId) AND (CSN_P_Account_Status__c !='Closed Won')];
           system.debug('----accountCSNPStatus'+accountCSNPStatus);
           for(Account acc : accountCSNPStatus){
              acc.CSN_P_Account_Status__c='Closed Won';
              updateAccList.add(acc);
           }
           system.debug('----updateAccList'+updateAccList);
        } if(accountParentId != null){
           for(id accId: accountParentId){
             account acc =new account(id =accId );
             acc.CSN_P_Account_Status__c='Closed Won';
             updateAccList.add(acc);
           }
        }
        if(updateAccList.size() > 0){
           //Database.upsert(updateAccList, false);
           
           Database.SaveResult[] srList = Database.update(updateAccList, false);
           // Iterate through each returned result 
           for (integer i =0;i<srList.size();i++) {
             if (srList.get(i).isSuccess()) {
             }else if(!srList.get(i).isSuccess()){
                    Database.Error err = srList.get(i).getErrors().get(0);
                    string failedDML= err.getMessage();
                    errMsgMap.put(updateAccList.get(i).id,failedDML);
                    }
            }
         }
        
        }
        
       }
       
       
    
        
    global void finish(Database.BatchableContext BC){
     String body = ''; 
      if(!errMsgMap.isEmpty()) {
       
            body = '<table border = "1"><tr><th>Account List </th></tr>';
            for(Id setItr : errMsgMap.keyset()){
                  body +='<tr><td>'+ setItr + '</td></tr>';
            }
            body += '</table>';           
      }
      
       List<String> sendTo = new List<String>();
       sendTo.add('udwivedi@cvent.com');
       //sendTo.add('b.verma@cvent.com');
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject('Errors occurred during batch process.');
        mail.setTargetObjectId(UserInfo.getUserId());
        mail.setToAddresses(sendTo);   
        mail.setSaveAsActivity(false);
        mail.setPlainTextBody(body);
        Messaging.sendEmail(new Messaging.Email[] { mail });
      }        
    }