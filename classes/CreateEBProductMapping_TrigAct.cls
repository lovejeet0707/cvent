/*Author: Sandeep Kumar
* Date: 02 April 2017
* Description: EB Project Auto Assignemnt Rollup. 
* Class is reponsible for updating "EB_Project_Assignment__c" fields based on the EB projects assigned to 
* a Agent. It is updating # of Projects(In Progress), # of Projects(Completed), Agent Workload etc.
* Test Class : EBProjectAssignmentRollup_TrigAct_Test
*/
public class CreateEBProductMapping_TrigAct extends TriggerAction{
    private Set<String> newProdNameSet;
    private Map<String,Product2> newProdNameToObjMap;
    private Map<String,Product2> oldProdNameToObjMap;
    private List<EB_Project_Products_Mapping__c> newMappingToBeCreatedList;
    private List<Messaging.SingleEmailMessage> listMailstoSend;
    private Messaging.SingleEmailMessage mail;
    
    public CreateEBProductMapping_TrigAct(){
        // Call super to set batch variables & context
        super();
        newprodNameSet = new Set<String>();
        newProdNameToObjMap = new Map<String,Product2>();
        oldProdNameToObjMap = new Map<String,Product2>();
        newMappingToBeCreatedList = new List<EB_Project_Products_Mapping__c>();
        
        // Get all the exisitng SFDC products. Prepare a Map with Product Name as key.
        for(Product2 prodName : [Select Id,Name,Family,ProductCode From Product2]){
            if(prodName.Name.contains('Event Builder')){
                oldProdNameToObjMap.put(prodName.Name, prodName);
            }            
        }
    }
    
    public override Boolean shouldRun(){
        if(this.isInsert() && this.isAfter() && !this.hasRun()){
            for(Product2 newProd: (List<Product2>)this.triggerMap.values()){
                // Check if the same products exits.
                if(oldProdNameToObjMap.containsKey(newProd.Name)){
                    newProdNameToObjMap.put(newProd.Name, newProd);
                }                
            }
            
        }        
        return !newProdNameToObjMap.isEmpty();
    }
    
    public override void doAction(){
        EB_Project_Products_Mapping__c eBProdMapObj;
        
        for(String prodMappingName : newProdNameToObjMap.keySet()){
            eBProdMapObj = new EB_Project_Products_Mapping__c();
            // Conditional check for checking the complexity.
            if(prodMappingName.contains('Advanced')){
                eBProdMapObj.EB_Project_Complexity__c = '4-Advanced';
            }else if(prodMappingName.contains('Complex')){
                eBProdMapObj.EB_Project_Complexity__c = '3-Complex';
            }else if(prodMappingName.contains('Medium')){
                eBProdMapObj.EB_Project_Complexity__c = '2-Medium';
            }else{
                eBProdMapObj.EB_Project_Complexity__c = '1-Simple';
            }
            
            // Conditional check for checking the project Type.
            if(prodMappingName.contains('Premium Services')){
                eBProdMapObj.EB_Project_Type__c = 'Event Builder - Premium';
            }else if(prodMappingName.contains('Quarterback')){
                eBProdMapObj.EB_Project_Type__c = 'Event Quarterback Project';
            }else if(prodMappingName.contains('Express')){
                eBProdMapObj.EB_Project_Type__c = 'Event Builder - Express';
            }else if(prodMappingName.contains('Enterprise')){
                eBProdMapObj.EB_Project_Type__c = 'Enterprise Project';
            }else if(prodMappingName.contains('Additional')){
                eBProdMapObj.EB_Project_Type__c = 'Additional Changes';
            }else{
                eBProdMapObj.EB_Project_Type__c = 'Event Builder - Regular';
            }
            if(eBProdMapObj.EB_Project_Complexity__c != null && eBProdMapObj.EB_Project_Type__c != null){
                eBProdMapObj.Name = prodMappingName;  
                newMappingToBeCreatedList.add(eBProdMapObj); 
            }
        }      
        
        try{
            if(!newMappingToBeCreatedList.isEmpty()){                
                Database.insert(newMappingToBeCreatedList, false) ;
                // Send Email to Leadership.            
                sendNotificationToEBLeadership(newMappingToBeCreatedList);
                this.markRun();
            }            
            
        }catch(Exception exp){
            exp.getMessage();
        }            
    }    
    
    public void sendNotificationToEBLeadership(List<EB_Project_Products_Mapping__c> eBProdMappingList){
        system.debug('Inside sendNotificationToEBLeadership');
        String prodMappingTable = '';
        String emailBody = '';
        String prodURL;
        string sfdcURL = System.URL.getSalesforceBaseUrl().toExternalForm();    
        for(EB_Project_Products_Mapping__c prdMapping :eBProdMappingList){
            prodURL = '';
            prodMappingTable += '<tr>';
            prodMappingTable += '<td>'+prdMapping.Name+'</td>';
            prodMappingTable += '<td>'+prdMapping.EB_Project_Complexity__c+'</td>';
            prodMappingTable += '<td>'+prdMapping.EB_Project_Type__c+'</td>';
            prodURL = sfdcURL+'/'+prdMapping.Id;
            prodMappingTable += '<td>'+'<a href="'+prodURL+'"><font color="#0B6099">Click here</font></a>'+'</td>';
            prodMappingTable += '</tr>';
        }
        
        emailBody += '<html><head><meta http-equiv="Content-Type" content="text/html; charset=windows-1252"> <title>New Page 1</title><style>td, th { border: 1px solid #dddddd;text-align: left;padding: 8px;}tr:nth-child(even) {background-color: #dddddd;}</style> </head> <body></body> </html> <div align="center" style="margin:0; border:1px"> <p align="left" style="margin-left: 5px"><font face="Arial" color="#333333" style="font-size: 9.5pt">Dear Leadership,</font></p> <p align="left" style="margin-left: 5px"><font face="Arial" color="#333333" style="font-size: 9.5pt">New Event Builder product\'s are added in Salesforce. Refer to the details mentioned below and if you wish to change the <b>"Project Complexity"</b> and <b>"Project Type"</b>, Kindly use the record link.</font></p> <table style="font-family: arial, sans-serif;border-collapse: collapse;width: 100%;margin-left: 5px; margin-right:5px" cellpadding="0"> <tr><th>Product Name</th><th>Project Complexity</th><th>Project Type</th><th>Record Link</th></tr>';
        emailBody += prodMappingTable;
        emailBody += '</table><p align="left" style="margin-left: 5px"><font face="Arial" color="#333333" style="font-size: 9.5pt"><b>Note: </b> Event Builder project\'s created by the new automated process uses above Product Mapping.</font></p> <p align="left" style="margin-left: 5px"><font face="Arial" color="#333333" style="font-size: 9.5pt">Thank you,</font></p> <p align="left" style="margin-left: 5px"><font face="Arial" color="#333333" style="font-size: 9.5pt">Event Builder Team</font></p> </div>';
        
        // Initialize Objects.
        listMailstoSend = new  List<Messaging.SingleEmailMessage>();
        String[] toAddresses = new String[]{'CSEBmgrs@cvent.com','sandeepk@cvent.com'}; 
        mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);         
        mail.setSubject('Action Required : Event Builder product\'s added in Salesforce.com');
        mail.emailPriority = 'Highest';
        mail.sethtmlbody(emailBody);
        listMailstoSend.add(mail); 
        // Check if the there are any emails to be sent
        if(listMailstoSend != null && !listMailstoSend.isEmpty()){
            Messaging.SendEmail(listMailstoSend);
        }       
    }
}