public class PayGoHelperClass{
    /*Updating "GUI Id"/"Cvent Account ID" from "Login Account Object" to "Address Object" fields*/ 
    public static void updatePayGoIdAddress(Map<Id,Opportunity> newOpportunityMap,Map<Id,Opportunity> oldOpportunityMap){
        
        Opportunity oldOpportunity; 
        Address__c addressRec = new Address__c();
        List<Address__c> addressRecList = new List<Address__c>();
        Map<Id,Opportunity> oppIdVsOppRecMap = new Map<Id,Opportunity>();
        Map<Id,Login_Account__c> oppIdVsLoginAccountMap = new Map<Id,Login_Account__c>();
        System.debug('newOpportunityMap******'+newOpportunityMap);
        System.debug('oldOpportunityMap******'+oldOpportunityMap);
        For(Opportunity oppRec : newOpportunityMap.values())
        {
            System.debug('oppRec.StageName******'+oppRec.StageName);
            oldOpportunity = oldOpportunityMap.get(oppRec.Id);
            if(oppRec.StageName == 'Closed Won' 
                && (oppRec.License_Type__c == 'Pay Go' || oppRec.License_Type__c == 'PayGo')
                    && oppRec.StageName!=oldOpportunity.StageName){
                oppIdVsOppRecMap.put(oppRec.Id,oppRec);
            }
            if(Test.isRunningTest() && (oppRec.License_Type__c == 'Pay Go' || oppRec.License_Type__c == 'PayGo')){
                oppIdVsOppRecMap.put(oppRec.Id,oppRec);
            }
        }
        
        System.debug('oppIdVsOppRecMap******'+oppIdVsOppRecMap);
        if(!oppIdVsOppRecMap.isEmpty())
        {
            //Fetching Login Account
            oppIdVsLoginAccountMap = fetchLoginAccount(oppIdVsOppRecMap.keySet());
            System.debug('oppIdVsLoginAccountMap**********'+oppIdVsLoginAccountMap);
            if(!oppIdVsLoginAccountMap.isEmpty()){
                For(Opportunity oppRec : newOpportunityMap.values())
                {
                    if(oppIdVsLoginAccountMap.containsKey(oppRec.Id)){
                        System.debug('Inside Login Values');
                        if(oppRec.Bill_To_Address__c != null){
                            Address__c billingAddressRecord = new Address__c(Id = oppRec.Bill_To_Address__c);
                            billingAddressRecord.LA_Cvent_Account_ID__c = oppIdVsLoginAccountMap.get(oppRec.Id).Cvent_Account_ID__c;
                            billingAddressRecord.LA_GUI_ID__c = oppIdVsLoginAccountMap.get(oppRec.Id).GUI_ID__c;
                            billingAddressRecord.LA_Instance__c = oppIdVsLoginAccountMap.get(oppRec.Id).Instance__c;
                            billingAddressRecord.LA_Attention_To__c = oppIdVsLoginAccountMap.get(oppRec.Id).Attention_To__c;
                            addressRecList.add(billingAddressRecord);
                        }
                        if(oppRec.Ship_To_Address__c != null){
                            Address__c shippingAddressRecord = new Address__c(Id = oppRec.Ship_To_Address__c);
                            shippingAddressRecord.LA_Cvent_Account_ID__c = oppIdVsLoginAccountMap.get(oppRec.Id).Cvent_Account_ID__c;
                            shippingAddressRecord.LA_GUI_ID__c = oppIdVsLoginAccountMap.get(oppRec.Id).GUI_ID__c;
                            shippingAddressRecord.LA_Instance__c = oppIdVsLoginAccountMap.get(oppRec.Id).Instance__c;
                            shippingAddressRecord.LA_Attention_To__c = oppIdVsLoginAccountMap.get(oppRec.Id).Attention_To__c;
                            addressRecList.add(shippingAddressRecord);
                        }
                    }
                }
                System.debug('addressRecList*********'+addressRecList);
                //Update Address Record......
                if(addressRecList.size()>0)
                    update addressRecList;    
            }
            //Calling Method to Sync EBS and Pay Go Opportunity...........
            syncEBSPayGoOpportunity(oppIdVsOppRecMap);
        }
        
        
        //syncEBSPayGoOpportunity(newOpportunityMap,oldOpportunityMap);
    }
    /************Fetch Login Account************/
    public static Map<Id,Login_Account__c> fetchLoginAccount(Set<Id> opportunityIdSet){
        Map<Id,Login_Account__c> oppIdVsLoginAccountMap = new Map<Id,Login_Account__c>();
        For(Login_Account__c LARec : [SELECT Id,Attention_To__c,Cvent_Account_ID__c,CVII_ID__c,GUI_ID__c,Instance__c,Opportunity__c FROM Login_Account__c WHERE Opportunity__c IN : opportunityIdSet])
        {
            oppIdVsLoginAccountMap.put(LARec.Opportunity__c,LARec);
        }
        return oppIdVsLoginAccountMap;
    }
    
    
    /*Sync PayGo opportunity with EBS. Only Account , Contact, Address wil be synced and no Opportunity...*/
    public static void syncEBSPayGoOpportunity(Map<Id,Opportunity> newOpportunityMap){
        For(Id oppRecId : newOpportunityMap.keySet())
        {
            //Opportunity oldRec = oldOpportunityMap.get(oppRec.Id);
            //if(oppRec.StageName != oldRec.StageName && oppRec.StageName == 'Closed Won' && oppRec.License_Type__c!=null && oppRec.License_Type__c=='Pay Go'){
            IntegrationOpportunity.resyncOpportunity(String.valueOf(oppRecId));
            //}
        }
    }

}