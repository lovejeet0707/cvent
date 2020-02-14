/* ===============================
AUTHOR     :     Mohsin Siddiqui
Test class - BatchUpdateTestClass
Ticket : Batch Process to update related Contact and Lead records - TICCM-826
============================= 
*/
global class BatchUpdateLeads implements Database.Batchable<sObject>, Database.Stateful
{
    Map<Id,string> errMsgMap = new Map<id,string>();
    global List<sObject> changedContactsAndLeads = new List<sObject>();
    global List<List<sObject>> lstWrapper = new List<List<sObject>>();
    global List<sObject> listOfRecordsFromStartMethod = new List<sObject>();
    global Integer batchNumber;
    global Integer totalCount;
    public Boolean batchChaining;
    global Map<String,BatchUpdateContactFields__c> fieldNames = BatchUpdateContactFields__c.getAll();
    
    global BatchUpdateLeads(Boolean batchChaining,Integer batchNumber,List<List<sObject>> lstWrapper,Integer totalCount,Map<Id,string> errMsgMap)
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
            query = query + ' from Lead where BatchFlag__c = TRUE';  //Query for getting all the records where these fields have been changed in last 6hours
            
        }
        else 
        {
            query = 'select id from lead limit 1';   //Dummy Query
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC,List<Lead> scope)
    {
        if(!batchChaining)
        {
            Map<String,Lead> mapOfEmailsVsLeads = new Map<String,Lead>();
            for(Lead leadInstance : scope)
            {
                leadInstance.BatchFlag__c = FALSE;
                listOfRecordsFromStartMethod.add(leadInstance);
                mapOfEmailsVsLeads.put(leadInstance.Email,leadInstance);
            }
            
            if(!mapOfEmailsVsLeads.isEmpty())
            {
                Set<String> emailSet = mapOfEmailsVsLeads.keySet();
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
                    Lead originalLead = mapOfEmailsVsLeads.containsKey(con.Email)?mapOfEmailsVsLeads.get(con.Email):null;
                    
                    if(originalLead != NULL)
                    {
                        for(String fieldName : fieldNames.keySet())
                        {
                            con.put(fieldName,originalLead.get(fieldName));
                        }
                        changedContactsAndLeads.add(con);
                    }
                }
                
                for(Lead lead : Database.query(leadQuery))
                {
                    Lead originalLead = mapOfEmailsVsLeads.containsKey(lead.Email)?mapOfEmailsVsLeads.get(lead.Email):null;
                    
                    if(originalLead != NULL)
                    {
                        for(String fieldName : fieldNames.keySet())
                        {
                            lead.put(fieldName,originalLead.get(fieldName));
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
                Id batchJobId = Database.executeBatch(new BatchUpdateLeads(true,batchNumber,lstWrapper,totalCount,errMsgMap), 200);
            }
        }
        else
        {
            if(batchNumber < lstWrapper.size())
            {
                Id batchJobId = Database.executeBatch(new BatchUpdateLeads(true,batchNumber,lstWrapper,totalCount,errMsgMap), 200);
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
                mail.setSubject('Batch Update Leads');
                mail.setTargetObjectId(UserInfo.getUserId());
                mail.setToAddresses(sendTo);   
                mail.setSaveAsActivity(false);
                mail.setPlainTextBody(body);
                Messaging.sendEmail(new Messaging.Email[] { mail });
            }
        }
    }        
}