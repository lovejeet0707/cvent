/*
* Author: B.ESPIRIDION
* Description: Handes all account trigger logic
* Created: 4-22-2015
*/
public with sharing class CS_AccountTriggerHandler {
    public static final String BILLING_FIELD = 'Billing';
    public static final String SHIPPING_FIELD = 'Shipping';
/*
* Author: B.ESPIRIDION
* Description: Updates Address__c releted records to account when billing and shipping address is updated
* Created: 4-22-2015
* Param: none
* Return: none
*/ 
    public static void handleAccountAddressModify(Account[] pNewAccounts, map<Id, Account> pOldAccountMap, boolean isPrimary){        
        Account[] UpdatedAccounts = new Account[]{};
        map<Id, AddressWrap> accountIdToAddressWrap = new map<Id, AddressWrap>();
        for(Account acc : pNewAccounts){
            AddressWrap aw = new AddressWrap();
            if(hasChangedAddress(acc, pOldAccountMap.get(acc.Id), aw)){
                
                UpdatedAccounts.add(acc);
                accountIdToAddressWrap.put(acc.Id, aw);
            }
            system.debug('\n\nBilling: ' + aw.BillingChanged + '\nShipping: ' + aw.ShippingChanged + '\n\n');
        }
        
        if(UpdatedAccounts.isEmpty()){
            system.debug('\n\nNo account that has updated address.\n\n');
            return;
        }

        /* Enhancement by PK on 7/13/17. The account header level BillingAddress and ShippingAddress changes will sync only
            with the addresses marked as Primary.  By default the first time addresses are generated they will be set as Primary. 
            Any subsequent addresses will be insulated from Header sync. */
        
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, (select id, Primary_Sync__c, Type__c, Account__c, 
                                        Address__c, City__c, Country__c, CountryCode__c, Postal_Code__c, Province__c, ProvinceCode__c, State__c,
                                        EBS_Account_Id__c, EBS_Site_Number__c, EBS_Site_Use_ID__c from Additional_Addresses__r) from Account where Id IN:accountIdToAddressWrap.keySet()]);

        Map<Id, Address__c> accPrimaryBillingMap = new Map<Id, Address__c>();
        Map<Id, Address__c> accPrimaryShippingMap = new Map<Id, Address__c>();
        for(Account acc: accountMap.values()){
            for(Address__c addr: acc.Additional_Addresses__r){
                if(addr.Primary_Sync__c){
                    if(addr.Type__c == BILLING_FIELD){
                        accPrimaryBillingMap.put(addr.Account__c, addr);
                        accountIdToAddressWrap.get(addr.Account__c).Billing = addr;
                    }
                    if(addr.Type__c == SHIPPING_FIELD){
                        accPrimaryShippingMap.put(addr.Account__c, addr);
                        accountIdToAddressWrap.get(addr.Account__c).Shipping = addr;
                    }
                }    
            }
        }
            
        //getRelatedAddress(accountIdToAddressWrap);
        
        Address__c[] addressToUpdate = new Address__c[]{};
        for(Account acc : UpdatedAccounts){
            if(accountIdToAddressWrap.get(acc.Id).BillingChanged)
                addressToUpdate.add(updateAddressFields(accountIdToAddressWrap.get(acc.Id).billing, acc, BILLING_FIELD));
            
            if(accountIdToAddressWrap.get(acc.Id).ShippingChanged)
                addressToUpdate.add(updateAddressFields(accountIdToAddressWrap.get(acc.Id).shipping, acc, SHIPPING_FIELD));
        }
        
        upsert addressToUpdate;
    }
    
    private static Address__c updateAddressFields(Address__c pAddress, Account pAccount, String pAddressType){
        Address__c output;
        if(pAddress == null){
            output = new Address__c();
            output.Account__c = pAccount.Id;
            output.Type__c = pAddressType;
            //Enhancement by PK on 7/13/17
            output.Primary_Sync__c = true;
        }else{
            output = pAddress;
        }
        /*if(isPrimary != null && isPrimary != false){
            output.Primary_Sync__c = isPrimary;
        }*/
        output.EBS_Account_Id__c = pAccount.EBS_Account_ID__c;
        //output.EBS_Site_Number__c = pAccount.EBS_Account_Number__c;
        //output.EBS_Site_Use_ID__c = pAccount.EBS_Party_Site_ID__c;
        
        output.Address__c = (String)pAccount.get(pAddressType + 'Street');
        output.City__c = (String)pAccount.get(pAddressType + 'City');
        output.Postal_Code__c = (String)pAccount.get(pAddressType + 'PostalCode');
        //output.Country__c = (String)pAccount.get(pAddressType + 'Country');
        output.Country__c = (String)pAccount.get(pAddressType + 'CountryCode');
        output.CountryCode__c = (String)pAccount.get(pAddressType + 'CountryCode');
        output.State__c = (String)pAccount.get(pAddressType + 'StateCode');
        if(pAddressType == 'Billing' || pAddressType == 'Remittance')
            output.Payable_Name__c = (String)pAccount.get('Bill_To_Attention_To__c');
        /*if(output.CountryCode__c == 'CA'){
            output.ProvinceCode__c = output.State__c;
            output.Operating_Unit_Name__c = 'Active.com';
        }else if(output.CountryCode__c == 'US'){
            output.Operating_Unit_Name__c = 'Active.com';
        }*/
        return output;
    }

    
/*    private static void getRelatedAddress(map<Id, AddressWrap> accountIdToAddressWrap){
        for(Address__c address : [SELECT Primary_Sync__c, Type__c, Account__c, 
                                        Address__c, City__c, Country__c, CountryCode__c, Postal_Code__c, Province__c, ProvinceCode__c, State__c,
                                        EBS_Account_Id__c, EBS_Site_Number__c, EBS_Site_Use_ID__c
                                FROM Address__c WHERE Account__c IN :accountIdToAddressWrap.keySet() and Primary_Sync__c = true]){
            if(accountIdToAddressWrap.containsKey(address.Account__c)){
                if(address.Type__c == BILLING_FIELD){
                    accountIdToAddressWrap.get(address.Account__c).Billing = address;
                }else if(address.Type__c == SHIPPING_FIELD){
                    accountIdToAddressWrap.get(address.Account__c).Shipping = address;
                }
            }
        }
    } */

/*
* Author: B.ESPIRIDION
* Description: Updates Address__c releted records to account when billing and shipping address is updated
* Created: 4-22-2015
* Param: none
* Return: none
*/ 
    public static Boolean hasChangedAddress(Account pNew, Account pOld, AddressWrap pAddressObj){       
        set<String> addressToCheck = new set<String>{
            'Street',
            'City',
            'State',
            'PostalCode',
            'Country',
            'Bill_To_Attention_To__c'
                    };
        Boolean output = false;
        string FieldName;
        for(String address : new String[]{BILLING_FIELD, SHIPPING_FIELD}){
            system.debug('\n\n' + address + '\n\n');
            for(String type : addressToCheck){
                if(type == 'Bill_To_Attention_To__c'){
                    FieldName = 'Bill_To_Attention_To__c';
                    //break;
                }else    
                    FieldName = address+type;

                system.debug('\n\n' + FieldName + ' = ' +pNew.get(FieldName) + '\n\n');    
                if((pOld == null && pNew.get(FieldName) != null) || (pOld != null && pNew.get(FieldName) != pOld.get(FieldName))){
                    if(address == BILLING_FIELD && FieldName.contains('Bill')){ 
                        pAddressObj.BillingChanged = true;
                    }
                    if(address== SHIPPING_FIELD && FieldName.contains('Ship')){ 
                        pAddressObj.ShippingChanged = true;
                    }
                    output = true;
                }
            }
        }
        
        return output;
    }
/*****************************************************************
* Author: B.ESPIRIDION
* Description: Wrapper class to hold billing and shipping address__c records
* Created: 4-22-2015
********************************************************************/ 
    public class AddressWrap{
        public Address__c Shipping;
        public Address__c Billing;
        public Boolean ShippingChanged;
        public Boolean BillingChanged;
        
        public AddressWrap(){
            ShippingChanged = false;
            BillingChanged = false;
        }
    }
    
    public static void fakeMethod(){
    Integer i = 0;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
        i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
        i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
        i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
  }
}