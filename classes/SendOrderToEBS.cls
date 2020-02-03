/**
*    
*   Author: Mohsin Siddiqui
*   Date Added : 11-11-2018
*   This class creates Service Order and Customer records whenever someone click on SendOrderToEBS button on Opportunity.
* 
*/
global class SendOrderToEBS 
{
    webservice static void createCustomerAndServiceOrder(Id oppId)
    {
        Opportunity opp = [select Id,SF_Org_ID__c,Account.Name,Bill_To_Address__r.Country__c,Bill_To_Address__r.Postal_Code__c,Bill_To_Address__r.State__c,Bill_To_Address__r.City__c from Opportunity WHERE Id = :oppId LIMIT 1];
        List<CHANNEL_ORDERS__Customer__c> existingCustomer = [select id,CHANNEL_ORDERS__Customer_Org_ID__c from CHANNEL_ORDERS__Customer__c where CHANNEL_ORDERS__Customer_Org_ID__c = :opp.SF_Org_ID__c LIMIT 1];
        
        CHANNEL_ORDERS__Service_Order__c serviceOrder = new CHANNEL_ORDERS__Service_Order__c();
        serviceOrder.CHANNEL_ORDERS__Partner_Contract_Rules__c  = Id.valueOf('a5Ko00000008RqmEAE');
        serviceOrder.CHANNEL_ORDERS__Order_Type__c = 'Initial';
        serviceOrder.CHANNEL_ORDERS__Related_Opportunity__c = opp.Id;
        serviceOrder.CHANNEL_ORDERS__Invoice_Description__c = opp.Account.Name;
        if(existingCustomer.size() > 0 && !existingCustomer.isEmpty())
        {
            serviceOrder.CHANNEL_ORDERS__Customer__c = existingCustomer[0].Id;
            serviceOrder.CHANNEL_ORDERS__Customer_Org_ID__c = existingCustomer[0].CHANNEL_ORDERS__Customer_Org_ID__c;
         }
        else
        {
            CHANNEL_ORDERS__Customer__c customer = new CHANNEL_ORDERS__Customer__c();
            customer.CHANNEL_ORDERS__Customer_City__c = opp.Bill_To_Address__r.City__c;
            customer.CHANNEL_ORDERS__Customer_Country__c = opp.Bill_To_Address__r.Country__c;
            customer.CHANNEL_ORDERS__Customer_State__c = opp.Bill_To_Address__r.State__c;
            customer.CHANNEL_ORDERS__Customer_ZIP_Postal_Code__c = opp.Bill_To_Address__r.Postal_Code__c;
            customer.CHANNEL_ORDERS__Customer_Company_Name__c = opp.Account.Name;
            customer.CHANNEL_ORDERS__Customer_Org_ID__c = opp.SF_Org_ID__c;
            insert customer;
            
            serviceOrder.CHANNEL_ORDERS__Customer__c = customer.Id;
            serviceOrder.CHANNEL_ORDERS__Customer_Org_ID__c = customer.CHANNEL_ORDERS__Customer_Org_ID__c;
        }
        
        insert serviceOrder;
    }
}