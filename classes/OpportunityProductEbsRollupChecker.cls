public class OpportunityProductEbsRollupChecker {

    public static Map<Id,List<OpportunityLineItem>> opportunityIdToLineItems = new Map<Id,List<OpportunityLineItem>>();

    public static void checkOpportunityProductRollupBooleans() {

        System.debug('is this code being called: ');

        List<OpportunityLineItem> opportunityLineItems = (Trigger.isDelete) ? Trigger.old : Trigger.new ;

        Set<Id> opportunityIdsToQuery = new Set<Id>();

        if(Trigger.isDelete) {

            opportunityIdToLineItems = new Map<Id,List<OpportunityLineItem>>();

        }
        
        for(OpportunityLineItem oli : opportunityLineItems) {

            if(!opportunityIdToLineItems.containsKey(oli.OpportunityId) && oli.Id != null) {

                opportunityIdsToQuery.add(oli.OpportunityId);

            }

            System.debug('oppotunityIdsToQuery: ' + opportunityIdsToQuery);

        }

        if(Trigger.isInsert && Trigger.isBefore) {

            System.debug('in before insert opportunity product rollup: ');

            for(OpportunityLineItem oli : opportunityLineItems) {

                System.debug('oli.Opportunity.Id: ' + oli.OpportunityId);

                if(opportunityIdToLineItems.get(oli.OpportunityId) == null) {

                    opportunityIdToLineItems.put(oli.OpportunityId, new List<OpportunityLineItem>());

                }

                opportunityIdToLineItems.get(oli.OpportunityId).add(oli);                    

            }

            System.debug('opportunityIdToLineItems: ' + opportunityIdToLineItems);

        }

        for(List<OpportunityLineItem> lineItemList : opportunityIdToLineItems.values()) {
            for(OpportunityLineItem lineItem : lineItemList) {
                if(lineItem.SBQQ__QuoteLine__r == null && lineItem.SBQQ__QuoteLine__c != null) {
                    opportunityIdsToQuery.add(lineItem.OpportunityId);
                }
            }
        }

        if(!opportunityIdsToQuery.isEmpty()) {

            for(OpportunityLineItem oli : [SELECT 

                Id,Name,OpportunityId,Product2.Name,

                Product2.rollupIntoBundleForEbs__c,

                Send_Rollup_To_EBS__c,SBQQ__QuoteLine__c,

                SBQQ__QuoteLine__r.SBQQ__RequiredBy__c,

                isMissingParentBundle__c,productRollsIntoBundle__c

                FROM OpportunityLineItem

                WHERE OpportunityId IN: opportunityIdsToQuery

            ]) {

                if(opportunityIdToLineItems.get(oli.OpportunityId) == null) {

                    opportunityIdToLineItems.put(oli.OpportunityId, new List<OpportunityLineItem>());

                }

                List<OpportunityLineItem> existingLineItems = opportunityIdToLineItems.get(oli.OpportunityId);

                Set<Id> lineItemIds = new Set<Id>();

                for(OpportunityLineItem oli1 : existingLineItems) {

                    if(oli1.Id != null) {lineItemIds.add(oli1.Id);}

                }

                if(!lineItemIds.contains(oli.Id)) {

                    existingLineItems.add(oli);

                }

                for(OpportunityLineItem oli1 : existingLineItems) {

                    System.debug('checking existing line items to populate quote line....');

                    System.debug('oli.SBQQ__QuoteLine__c: ' + oli.SBQQ__QuoteLine__c);

                    System.debug('oli1.SBQQ__QuoteLine__c: ' + oli1.SBQQ__QuoteLine__c);

                    if(oli1.SBQQ__QuoteLine__c == oli.SBQQ__QuoteLine__c && oli1.SBQQ__QuoteLine__c != null) {

                        System.debug('this should be happening at least once');

                        oli1.SBQQ__QuoteLine__r = oli.SBQQ__QuoteLine__r;

                        oli1.Product2 = oli.Product2;

                    }

                }         

                System.debug('existingLineItems.size(): ' + existingLineItems.size());

                opportunityIdToLineItems.put(oli.OpportunityId,existingLineItems);

            }

        }

        Set<Id> allChildrenLineItemIds = new Set<Id>();

        Set<Id> lineItemIdsWithNoParentBundle = new Set<Id>();

        for(Id opportunityId : opportunityIdToLineItems.keySet()) {

            List<OpportunityLineItem> lineItems = opportunityIdToLineItems.get(opportunityId);

            for(Integer i = 0; i < lineItems.size(); i++) {

                if(lineItems[i].Product2.rollupIntoBundleForEbs__c || lineItems[i].productRollsIntoBundle__c) {

                    Boolean parentBundleProductFound = false;

                    OpportunityLineItem oli0 = lineItems[i];

                    allChildrenLineItemIds.add(oli0.Id);

                    System.debug('checking oli0: ' + oli0);

                    System.debug('oli0.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c: ' + oli0.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c);

                    // below j loop looks through ole's compared to top level ole

                    for(Integer j = 0; j < lineItems.size(); j++) {

                        OpportunityLineItem oli1 = lineItems[j];

                        System.debug('oli1.SBQQ__QuoteLine__c: ' + oli1.SBQQ__QuoteLine__c);

                        if(oli0.SBQQ__QuoteLine__c != null && oli1.SBQQ__QuoteLine__c != null && oli0 != oli1) {

                            if(oli0.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c == oli1.SBQQ__QuoteLine__c) {

                                if(oli1.Send_Rollup_To_EBS__c) {

                                    System.debug('parent bundle found, and oli0 rolls up into the parent. done with oli0, and oli1 is : ' + oli1);

                                    parentBundleProductFound = true;

                                    break;

                                }

                                // below k loop looks for parent-parent bundles

                                System.debug('parent bundle found, but oli0 does not roll up into oli1, so we must keep looking. oli1 is : ' + oli1);

                                for(Integer k = 0; k < lineItems.size(); k++) {

                                    OpportunityLineItem ole2 = lineItems[k];

                                    if(oli1.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c == ole2.SBQQ__QuoteLine__c && oli1.SBQQ__QuoteLine__c != null && ole2.SBQQ__QuoteLine__c != null) {

                                        if(ole2.Send_Rollup_To_EBS__c) {

                                            parentBundleProductFound = true;

                                            break;

                                        }

                                        else {

                                            oli1 = ole2;

                                            k = 0;

                                        }

                                    }

                                }

                            }

                        }

                    }

                    System.debug('was the parent product bundle line for oli0?: ' + parentBundleProductFound + ' oli0 is: ' + oli0);

                    if(!parentBundleProductFound) {lineItemIdsWithNoParentBundle.add(oli0.Id);}

                }

            }

        }

        System.debug('lineItemIdsWithNoParentBundle: ' + lineItemIdsWithNoParentBundle);

        if(Trigger.isBefore && !Trigger.isDelete) {

            for(OpportunityLineItem ole : (List<OpportunityLineItem>)Trigger.new) {
                
                if(ole.isMissingParentBundle__c != true && lineItemIdsWithNoParentBundle.contains(ole.Id)){

                    ole.isMissingParentBundle__c = true;

                }

                else if(ole.isMissingParentBundle__c != false && !lineItemIdsWithNoParentBundle.contains(ole.Id)){

                    ole.isMissingParentBundle__c = false;

                }

            }

        }

        else if(Trigger.isAfter && Trigger.isDelete) {

            List<OpportunityLineItem> lineItemsToUpdate = new List<OpportunityLineItem>();

            for(Id opportunityId : opportunityIdToLineItems.keySet()) {

                List<OpportunityLineItem> lineItems = opportunityIdToLineItems.get(opportunityId);

                for(OpportunityLineItem lineItem : lineItems) {

                    if(lineItem.isMissingParentBundle__c != true && lineItemIdsWithNoParentBundle.contains(lineItem.Id)) {

                        lineItem.isMissingParentBundle__c = true;

                        lineItemsToUpdate.add(lineItem);

                    }

                    else if(lineItem.isMissingParentBundle__c != false && !lineItemIdsWithNoParentBundle.contains(lineItem.Id)) {

                        lineItem.isMissingParentBundle__c = false;

                        lineItemsToUpdate.add(lineItem);

                    }

                }

            }

            update lineItemsToUpdate;

        }

    }

}