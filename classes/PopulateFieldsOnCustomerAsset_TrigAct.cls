/******************************************************************************************
* Author : Sandeep Kumar
* Date : 17 Jan 2017
* Description : PopulateFieldsOnCustomerAsset_TrigAct class fullfills below functionalities,
* 1) Populate Contact email on newly created Customer Assets.
* 2) Populate Opportunity Owner email on newly created Customer Assets.
*
* CRM Project Requirement : P-001462
*
* Handler called by - CustomerAssetBefore Trigger
* Test Class : PopulateFieldsOnCustmrAsset_TrigAct_Test
*******************************************************************************************/
public class PopulateFieldsOnCustomerAsset_TrigAct extends TriggerAction  {
    public Set<Id> contractSet;
    public Map<Id,Contract> customerAssetToContractMap;
    
    public PopulateFieldsOnCustomerAsset_TrigAct(){
        // Call super to set batch variables & context
        super();
        contractSet = new Set<Id>();
        customerAssetToContractMap = new Map<Id,Contract>();
    }
    
    public override Boolean shouldRun(){
        // Code should fire in after update context/ operation
        if(this.isBefore()){
            if(this.isInsert() && !this.hasRun()){
                // Code should execute in the Insert Operation.
                for(Customer_Asset__c newAsset : (List<Customer_Asset__c>)this.triggerList){
                    if(newAsset.Contract__c != null){
                        contractSet.add(newAsset.Contract__c);   
                    }   
                }
            }
        }
        return !contractSet.isEmpty();
    }
    
    public override void doAction(){
        // Fetch all contracts associated with the newly created Customer Assets.
        for(Contract conRec : [Select Id,SBQQ__Opportunity__c,SBQQ__Opportunity__r.Owner.Email,SBQQ__Opportunity__r.Bill_To_Contact__r.Email, SBQQ__Opportunity__r.Ship_To_Contact__r.Email From Contract Where Id IN :contractSet]){
            customerAssetToContractMap.put(conRec.Id, conRec);
        }
        
        // Populate fields on newly created Customer Assets.
        for(Customer_Asset__c newAsset : (List<Customer_Asset__c>)this.triggerList){
            if(customerAssetToContractMap.containsKey(newAsset.Contract__c) && customerAssetToContractMap.get(newAsset.Contract__c).SBQQ__Opportunity__c != null){
                newAsset.Customer_Email__c = customerAssetToContractMap.get(newAsset.Contract__c).SBQQ__Opportunity__r.Ship_To_Contact__r.Email;
                newAsset.Opportunity_Owner_Email__c = customerAssetToContractMap.get(newAsset.Contract__c).SBQQ__Opportunity__r.Owner.Email;
            }            
        }
    }    
}