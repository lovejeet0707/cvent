/* ===============================
AUTHOR     :     Mohsin Siddiqui
Test class - 
Ticket : Batch Process to update related Contact and Lead records - TICCM-826
============================= 
*/
global class BatchUpdateContacts implements Database.Batchable<sObject>, Database.Stateful
{
    Map<Id,string> errMsgMap = new Map<id,string>();
    global List<sObject> changedContactsAndLeads = new List<sObject>();
    global List<List<sObject>> lstWrapper = new List<List<sObject>>();
    global List<sObject> listOfRecordsFromStartMethod = new List<sObject>();
    global Integer batchNumber;
    global Integer totalCount;
    public Boolean batchChaining;
    global Map<String,BatchUpdateContactFields__c> fieldNames = BatchUpdateContactFields__c.getAll();
    
    global BatchUpdateContacts(Boolean batchChaining,Integer batchNumber,List<List<sObject>> lstWrapper,Integer totalCount,Map<Id,string> errMsgMap)
    {
        this.batchChaining = batchChaining;
        this.batchNumber = batchNumber;
        this.lstWrapper = lstWrapper;
        this.totalCount = totalCount;
        this.errMsgMap = errMsgMap;
    }
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query='';
        if(!batchChaining)
        {
            query ='Select Id,Email';
            for(String fieldName : fieldNames.keySet())
            {
                query = query + ',' + fieldName;
            }
            query = query + ' from Contact where BatchFlag__c = TRUE';  //Query for getting all the records where these fields have been changed in last 6hours
            
        }
        else 
        {
            query = 'select id from contact limit 1';   //Dummy Query
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC,List<Contact> scope)
    {
        if(!batchChaining)
        {
            Map<String,Contact> mapOfEmailsVsContacts = new Map<String,Contact>();
            for(Contact conInstance : scope)
            {
                conInstance.BatchFlag__c = FALSE;
                listOfRecordsFromStartMethod.add(conInstance);
                mapOfEmailsVsContacts.put(conInstance.Email,conInstance);
            }
            
            if(!mapOfEmailsVsContacts.isEmpty())
            {
                Set<String> emailSet = mapOfEmailsVsContacts.keySet();
                String contactQuery = 'Select Id';
                String leadQuery = 'Select Id';
                for(String fieldName : fieldNames.keySet())
                {
                    contactQuery = contactQuery + ',' + fieldName;
                    leadQuery = leadQuery + ',' + fieldName;
                }
                contactQuery = contactQuery + ',Email from Contact where BatchFlag__c = FALSE AND Email IN :emailSet';
                leadQuery = leadQuery + ',Email from Lead where BatchFlag__c = FALSE AND Email IN :emailSet';
                
                for(Contact con : Database.query(contactQuery))
                {
                    Contact originalContact = mapOfEmailsVsContacts.containsKey(con.Email)?mapOfEmailsVsContacts.get(con.Email):null;
                    
                    if(originalContact != NULL)
                    {
                        for(String fieldName : fieldNames.keySet())
                        {
                            con.put(fieldName,originalContact.get(fieldName));
                        }
                        changedContactsAndLeads.add(con);
                    }
                }
                
                for(Lead lead : Database.query(leadQuery))
                {
                    Contact originalContact = mapOfEmailsVsContacts.containsKey(lead.Email)?mapOfEmailsVsContacts.get(lead.Email):null;
                    
                    if(originalContact != NULL)
                    {
                        for(String fieldName : fieldNames.keySet())
                        {
                            lead.put(fieldName,originalContact.get(fieldName));
                        }
                        changedContactsAndLeads.add(lead);
                    }
                }
            }
        }
        else
        {
            Boolean triggerOff = CheckRecursive.runFifty();
            List<sObject> recordList = lstWrapper.get(batchNumber);
            Database.SaveResult[] srList = Database.update(recordList, false);
            for (Integer i =0;i<srList.size();i++) 
            {
                if (srList.get(i).isSuccess()) {
                }
                else if(!srList.get(i).isSuccess())
                {
                    Database.Error err = srList.get(i).getErrors().get(0);
                    string failedDML= err.getMessage();
                    errMsgMap.put(recordList.get(i).id,failedDML);
                }
            }
            batchNumber++;
        }
    }
    
    global void finish(Database.BatchableContext BC)
    {
        if(!batchChaining)
        {
            totalCount = changedContactsAndLeads.size();
            if(!listOfRecordsFromStartMethod.isEmpty())
            {
                changedContactsAndLeads.addAll(listOfRecordsFromStartMethod);
            }
            List<sObject> lstTemp;
            if(!changedContactsAndLeads.isEmpty())
            {
                for(Integer i = 0 ; i < (changedContactsAndLeads.size() / 500)+1 ; i++)
                {
                    lstTemp = new List<sObject>();
                    for(Integer j=(i*500);(j<(i*500)+500) && j<changedContactsAndLeads.size() ; j++)
                    {
                        lstTemp.add(changedContactsAndLeads.get(j));
                    }
                    lstWrapper.add(lstTemp);
                }
            }
            if(!lstWrapper.isEmpty())
            {
                Id batchJobId = Database.executeBatch(new BatchUpdateContacts(true,batchNumber,lstWrapper,totalCount,errMsgMap), 200);
            }
        }
        else
        {
            if(batchNumber < lstWrapper.size())
            {
                Id batchJobId = Database.executeBatch(new BatchUpdateContacts(true,batchNumber,lstWrapper,totalCount,errMsgMap), 200);
            }
            else
            {
                String body = ''; 
                if(!errMsgMap.isEmpty()) 
                {
                    //totalCount = totalCount - errMsgMap.size();
                    body = '<table border = "1"><tr><th>Error Contact List </th></tr>';
                    for(Id setItr : errMsgMap.keyset()){
                        body +='<tr><td>'+ setItr + '</td></tr>';
                    }
                    body += '</table><br /><br />';           
                }
                body = 'Contact & Lead Batch Has been Completed. '+(totalCount - errMsgMap.size())+' out of '+totalCount+' got success.';
                List<String> sendTo = new List<String>();
                sendTo.add('msiddiqui@cvent.com');
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setSubject('Batch Update Contacts');
                mail.setTargetObjectId(UserInfo.getUserId());
                mail.setToAddresses(sendTo);   
                mail.setSaveAsActivity(false);
                mail.setPlainTextBody(body);
                Messaging.sendEmail(new Messaging.Email[] { mail });
            }
        }
    }        
}