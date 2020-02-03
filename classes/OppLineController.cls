public class OppLineController {
    public List<Opportunity> OppsList{get;set;}
    public List<Opportunity> OppsList2{get;set;} //added by Vaibhav for page of Finance and PMO
    public OppLineController(ApexPages.StandardController controller) {
        OppsList = [SELECT Id,Name,Account.Name, 
                                  (SELECT Quantity, UnitPrice, TotalPrice,PricebookEntry.Name, PricebookEntry.Product2.Family,Annual_Recurring_Revenue__c,Non_Recurring_Revenue__c,
                                  NBB_New_Account_New_Logo__c, NBB_Upsell__c, NBB_Value__c, NBB_Cross_Sell__c, MYD__c, Renewal_Value__c, UFR_Value__c, Vista_Bookings_Value__c, Total_Line_Value__c,Revenue_Team_Code__c
                                  FROM OpportunityLineItems) 
                FROM Opportunity WHERE Id =: ApexPages.currentPage().getParameters().get('ID')];
        //System.debug('OppsList ='+OppsList);
        
        //added by Vaibhav for page of Finance and PMO
        OppsList2 = [SELECT Id,Name,Account.Name, 
                                  (SELECT Quantity, UnitPrice, TotalPrice,PricebookEntry.Name, PricebookEntry.Product2.Family,Annual_Recurring_Revenue__c,Non_Recurring_Revenue__c,
                                  NBB_New_Account_New_Logo__c, NBB_Upsell__c, NBB_Value__c, NBB_Cross_Sell__c, MYD__c, Renewal_Value__c, UFR_Value__c, Vista_Bookings_Value__c, Total_Line_Value__c,Revenue_Team_Code__c
                                  FROM OpportunityLineItems) 
                FROM Opportunity WHERE Id =: ApexPages.currentPage().getParameters().get('ID')];

        
        
        //added by Vaibhav for page of Finance and PMO
    }
    public List<Opportunity> getOppsList() {
        return OppsList;
    }   
}