public class ReflagTriggerHelper 
{
    public static void onAfterInsert(Map<Id,Rebrand_Reflag__c> newMap)
    {
        Id CMGRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Client_Management_Global').getRecordTypeId();
        Map<Id,Id> accountIdsVsReflagIds = new Map<Id,Id>();
        Map<Id,Id> accountIdsVsUserIds = new Map<Id,Id>();
        List<Case> caseToBeInserted = new List<Case>();
        for(Rebrand_Reflag__c reflagRec : newMap.values())
        {
            if(reflagRec.Old_Supp_Ac__c != NULL)
            {
                accountIdsVsReflagIds.put(reflagRec.Old_Supp_Ac__c,reflagRec.Id);        
            }
        }
        
        if(!accountIdsVsReflagIds.isEmpty())
        {
            List<String> productsCondition = Label.ReflagTriggerProducts.split(';');
            for(Account acc : [Select Id,(select Id,TeamMemberRole,UserId from AccountTeamMembers where TeamMemberRole = 'CS - HCloud - Implement/Onboard' LIMIT 1),(select Id,Product_Family__c,Master_Contract_End_Date__c from Customer_Assets__r) from Account where Id IN :accountIdsVsReflagIds.keySet()])
            {
                Boolean flag = false;
                
                if(acc.Customer_Assets__r.size() > 0)
                {
                    for(Customer_Asset__c custAsset : acc.Customer_Assets__r)
                    {
                        if(productsCondition.contains(custAsset.Product_Family__c) && custAsset.Master_Contract_End_Date__c > System.Today())
                        {
                            flag = true;
                            break;
                        }
                    }
                }
                
                if(flag)
                {
                    for(AccountTeamMember atm : acc.AccountTeamMembers)
                    {
                        Case newCase = new Case();
                        newCase.RecordTypeId = CMGRecordTypeId;
                        newCase.Client_Services_Category__c = 'Feature Implementation';
                        newCase.Status = 'Open';
                        newCase.Product_Type__c = 'CSN - Supplier';
                        newCase.Subject = 'Property Reflagged - Please touch base';
                        newCase.Priority = 'Medium';
                        newCase.AccountId = acc.Id;
                        newCase.OwnerId = atm.UserId;
                        caseToBeInserted.add(newCase);
                    }
                    
                    if(acc.AccountTeamMembers.size() < 1)
                    { 
                        Case newCase = new Case();
                        newCase.RecordTypeId = CMGRecordTypeId;
                        newCase.Client_Services_Category__c = 'Feature Implementation';
                        newCase.Status = 'Open';
                        newCase.Product_Type__c = 'CSN - Supplier';
                        newCase.Subject = 'Property Reflagged - Please touch base';
                        newCase.Priority = 'Medium';
                        newCase.AccountId = acc.Id;
                        newCase.OwnerId = Label.Becky;
                        caseToBeInserted.add(newCase);
                    }
                }
            }
        }
        
        if(!caseToBeInserted.isEmpty())
        {
            insert caseToBeInserted;
        }
    }
}