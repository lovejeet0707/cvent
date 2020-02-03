/*Version 1.0
Date:7th Nov 2016
Description : Migrating FEATURESET to PRODUCT/PRICEBOOK. Below are the name of the field which needs to be replaced - 
OLD FIELD NAME       = NEW FIELD NAME
Feature_Sets__r      = OpportunityLineItems;
R00N00000008aGEXEA2  = OpportunityLineItems;
Feature_Set__c       = OpportunityLineItem;
Feature__c           = Product_Name__c;
Opportunity_N__c     = OpportunityId; 
RecordType.DeveloperName = Product_Family__c; // Changed this from RecordType.DeveloperName to ProductFamily as now the concept of recordtype is finished
//Lines Commented as Can't update CurrencyISOCode of OpportunityLineItem
//Lines Commented as no need to update the PRODUCT NAME as it's a formula field in the OpportunityLineItem earlier was Picklist in FEATURESET
//Lines Commented as their is no concept left of recordtype....
*/
trigger OpportunityLineItemTrg on OpportunityLineItem (after delete, after insert, after undelete, after update, before delete, before insert, before update) {

    /* Skip execution if this user is setup to exempt triggers. This helps in one time data load as well */

    if(!BypassTriggerUtility.isTriggerEnabledForThisUserOrProfileId(UserInfo.getUserId()) ) {

        return;

    }

    // 1-26-2018: below method loops through opportunity products to find children product options that do not exist with their parent bundle EBS products. These lone options must also be sent to EBS.

    if( (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) || (Trigger.isDelete && Trigger.isAfter) ) {

        OpportunityProductEbsRollupChecker.checkOpportunityProductRollupBooleans();

    }
    
    FeatureSetTrgHelperCls handler = new FeatureSetTrgHelperCls();
       
    if(Trigger.isInsert && Trigger.isBefore){

        handler.OnBeforeInsert(Trigger.new);  

    }

    else if(Trigger.isInsert && Trigger.isAfter){

        handler.OnAfterInsert(Trigger.newMap);        

    }

    else if(Trigger.isUpdate && Trigger.isBefore){

        handler.OnBeforeUpdate(Trigger.oldMap, Trigger.newMap);  

    }

    else if(Trigger.isUpdate && Trigger.isAfter){

        handler.OnAfterUpdate(Trigger.oldMap, Trigger.newMap);   

    }    

    else if(Trigger.isDelete && Trigger.isBefore){

        handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);        

    }

    else if(Trigger.isDelete && Trigger.isAfter){

        handler.OnAfterDelete(Trigger.old, Trigger.oldMap);        

    }    

    else if(Trigger.isUnDelete){

        handler.OnUndelete(Trigger.new);          

    }

}