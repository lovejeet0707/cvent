/*Author : HSR*
Created Date : 10/17/2018
Test Class : RestLeadConvertTest
Description : This class is used for Lead conversion when Lead Id along with some parameters is send from the Informatica on the request of PAYGO Project.
Components : 1) Used Custom Metadata - "Contact Field Mappings" for mapping the URL parameters with the Contact field.
It has two fields - 
> "Contact Field API Name" - This will contain the API name of the Contact Object which needs to be mapped.
> "URL Parameter Mapped" - This will contain the Parameter name which will come in the URL from the informatica side and if the value contains single quotes that means that value is hardcoded and will be stored directly in the corresponding CONTACT FIELD.
2) Used Custom Label - "PayGo_LeadConversion_Return_Value" this will contact semicolon separated parameters that needs to be send back as return value and its value can be fetched from the URL.
Version : 1.0
*/
@RestResource(urlMapping='/Lead/*')
global with sharing class RestLeadConvert{            
    //Basic Authentication.....
    @HttpGet
    global static String doGet() {
        RestRequest req = RestContext.request;
        Map<String,String> fetchParameters = new Map<String,String>();
        fetchParameters = req.params; // Fetching parameters that came in the URL.....
        String leadId = fetchParameters.get('LeadId'); //Fetching LeadId;
        String accountId = fetchParameters.get('AccountId'); //Fetching AccountId;
        String paygoGUIID = fetchParameters.get('PayGo_GUID');//Fetch GUI Id........
        Id contactId;
        String ret;
        //Check weather the Lead is already converted or not...........
        List<Lead> leadRecord = new List<Lead>();
        leadRecord = [SELECT Id,IsConverted,ConvertedContactId FROM Lead WHERE Id =: leadId];
        if(leadRecord.size()>0 && leadRecord[0].IsConverted == TRUE){
            contactId = leadRecord[0].ConvertedContactId;
            //Updating the PayGo Summary record value.........
            /*if(String.isNotBlank(paygoGUIID)){
                UpdatePayGoSummary(paygoGUIID,contactId,accountId);
            }*/
            //Setting up the return value........
            ret = SetReturnValue('Success',contactId,fetchParameters,'');
        }
        else{
            String payGoUniqueId; 
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(leadId);
            if(String.isNotBlank(accountId)){
                lc.setAccountId(accountId); //Assigning Account Id to the Lead that got converted....
            }
            
            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
            lc.setConvertedStatus(convertStatus.MasterLabel); 
            lc.setDoNotCreateOpportunity(TRUE);          
            Database.LeadConvertResult lcr ;
            
            //.....Setting Lead Id in the integration Log Object.........
            try{
                ret = '';
                lcr = Database.convertLead(lc); //Converting the Lead....
                contactId = lcr.getContactId(); //Fetching the new contactId after lead conversion....
                //Calling this method to update values on contact record....
                UpdateContact(contactId,fetchParameters,leadId);
                //Updating the PayGo Summary record value.........
                /*if(String.isNotBlank(paygoGUIID)){
                    UpdatePayGoSummary(paygoGUIID,contactId,accountId);
                }*/
                //Setting up the return value........
                ret = SetReturnValue('Success',contactId,fetchParameters,'');
            }
            catch(exception ex){
                ret = SetReturnValue('Error',null,null,ex.getMessage());
                //Calling this method to insert error logs....
                UpdateIntegrationLogs(leadId,ex.getMessage());
            }
        }
        return ret;
    }
    /*This method will update the details on Contact Level*/
    global static void UpdateContact(Id contactRecId,Map<String,String> fetchParameters,String leadId){
        /**********Accessing Field Mapping from the Custom Metadata**********/
        Map<String,String> fieldFieldMapping = new Map<String,String>();//This Map will store the contact field API Name and mapped field Name..
        Map<String,String> fieldValueMapping = new Map<String,String>();//This will store the contact field API Name and the value stored in it...
        List<contact> conList = new List<contact>();
        //Query on Custom Metadata....
        For(Contact_Field_Mapping__mdt customMetadataMapping : [SELECT Contact_Field_APIName__c,
                                                                URL_Parameter_Mapped__c FROM Contact_Field_Mapping__mdt])
        {
            if(customMetadataMapping.URL_Parameter_Mapped__c.startsWith('\'')){
                fieldValueMapping.put(customMetadataMapping.Contact_Field_APIName__c,customMetadataMapping.URL_Parameter_Mapped__c.substringBetween('\'','\''));
            }
            else{
                fieldFieldMapping.put(customMetadataMapping.Contact_Field_APIName__c,customMetadataMapping.URL_Parameter_Mapped__c);
            }
        }
        //Updating the Contact field values which gets created when the above Lead is converted.....
        Contact conObj = new Contact(Id=contactRecId);     
        for(string obj: fieldValueMapping.keyset()){                    
            conObj.put(obj,fieldValueMapping.get(obj));
            conList.add(conObj);
        }
        for(string key : fieldFieldMapping.keyset()){
            conObj.put(key,fetchParameters.get(fieldFieldMapping.get(key)));
        }
        if(conList.size() > 0){
            List<Database.SaveResult> updateResults =  Database.update(conList);
            for (Database.SaveResult r : updateResults)
            {
                if (!r.isSuccess())
                {
                    for (Database.Error e : r.getErrors())
                    {  
                        //Calling this method to insert error logs....
                        UpdateIntegrationLogs(leadId,e.getMessage());
                    }
                }
            }
        }
    }
    /*This method will update the details on PayGo Summary Object*/
    /*global static void UpdatePayGoSummary(Id paygoGUIID,Id contactId,String accountId){
        Id payGoSummaryRecordId = [SELECT Id FROM PayGo_Summary__c WHERE GUI_ID__c =:paygoGUIID].Id;
        if(payGoSummaryRecordId!=null){
            PayGo_Summary__c paygoRec = new PayGo_Summary__c(Id=payGoSummaryRecordId);
            paygoRec.Contact__c = contactId;//lcr.getContactId();
            if(String.isNotBlank(accountId))
                paygoRec.Account__c = accountId;
            update paygoRec;
        }
    }*/
    /*....While converting the Lead if there are any errors this method will create a record in the PayGo Integration Logs object....*/
    global static void UpdateIntegrationLogs(String leadId,String errorMessage){
        //initializing Object which will store the Failed logs.......
        PayGo_Integration_Logs__c integrationLogs = new PayGo_Integration_Logs__c();
        integrationLogs.Lead_Id__c = leadId;
        integrationLogs.Fail_Logs__c = errorMessage;
        insert integrationLogs;
    }
    /*....Setting the return parameters...*/
    global static String SetReturnValue(String isSuccess,Id contactId,Map<String,String> fetchParameters,String errorMessage){
        String returnValue = '';
        if(isSuccess == 'Error'){
            returnValue = errorMessage;
        }
        else if(isSuccess == 'Success'){
            returnValue = String.valueOf(contactId);
            For(String returnValues : Label.PayGo_LeadConversion_Return_Value.split(';')){
                returnValue = returnValue + ','+fetchParameters.get(returnValues);    
            }
        }
        return returnValue;
    }
}