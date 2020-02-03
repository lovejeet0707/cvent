@isTest
public class CventMyd_QuoteLineObject_Test {
    static testmethod void checkValues(){
        
        test.startTest();
        
        //Instantiate test values
        String qleIdStr = '35945_jay_58325';
        String quoteNameStr = 'Q-248013';
        
        Map<String,List<String>> preCalculationFieldValueMap = new Map<String,List<String>>{
            'SBQQ__Quantity__c' => new List<String>{'1'},
            'SBQQ__Discount__c' => new List<String>{null},
            'SBQQ__DistributorDiscount__c' => new List<String>{null}, 
            'Custom_Discount__c' => new List<String>{null},  
            'Discount_Type__c' => new List<String>{'%'},
            'Rate__c' => new List<String>{null},
            'Zone_Level__c' => new List<String>{null}, 
            'Number_of_Guest_Rooms__c' => new List<String>{null},
            'Lanyon_Chain_Affiliation__c' => new List<String>{null},
            'Chain_Affiliation__c' => new List<String>{null},
            'Group_Business_Mix__c' => new List<String>{'N/A'},
            'Setup_Days__c' => new List<String>{'1'},
            'Travel_Days__c' => new List<String>{'1'},
            'Event_Start_Date__c' => new List<String>{null},
            'Event_End_Date__c' => new List<String>{null},
            'Attendees__c' => new List<String>{null},
            'OnArrival_360_Event_Selection__c' => new List<String>{null},
            'Complexity__c' => new List<String>{null},
            'SBQQ__StartDate__c' => new List<String>{'2019-06-18'},
            'SBQQ__EndDate__c' => new List<String>{'2020-06-20'},
            'Search_Screen_Region__c' => new List<String>{null},
            'CSN_Tier__c' => new List<String>{null}
        };
            
        Map<String,List<String>> calculatedFieldValueMap = new Map<String,List<String>>{
            'SBQQ__OriginalPrice__c' => new List<String>{'0'},
            'SBQQ__ListPrice__c' => new List<String>{'0'},
            'SBQQ__RegularPrice__c' => new List<String>{'0'},
            'SBQQ__CustomerPrice__c' => new List<String>{'0'},
            'SBQQ__PartnerPrice__c' => new List<String>{'0'},
            'SBQQ__NetPrice__c' => new List<String>{'0'},
            'Rack_Rate__c' => new List<String>{'0'},
            'SBQQ__ProrateMultiplier__c' => new List<String>{'1.0082191780821919'}
        }; 
            
        Map<String,String> contractedFieldValueMap = new Map<String,String>{
             'SBQQ__OriginalPrice__c' => '0',
             'SBQQ__ListPrice__c' => '0',
             'SBQQ__RegularPrice__c' => '0',
             'SBQQ__CustomerPrice__c' => '0',
             'SBQQ__PartnerPrice__c' => '0',
             'SBQQ__NetPrice__c' => '0',
             'Rack_Rate__c' => '0',
             'SBQQ__ProrateMultiplier__c' => '1.0027397260273971'
        };
        
        List<String> clonedFromQleIds = new List<String> {'78956_ogt_07423', '81175_pes_22673'};
        Boolean insertOnNextCurrentYear = false;
        String requiredByQleId = '96094_oul_68113';
        
        Boolean insertedWithApex = true;
        Boolean deleteThisLine = false;
        String nextYearQleId = '35945_jay_58326';
        Boolean legacySubscriptionUpdated = true;
        String requiredBySubscriptionIdString = '96094_oul_68113';
    
        //Instantiate the apex class
        CventMyd_QuoteLineObject qliObj = new CventMyd_QuoteLineObject();
        
        //Insert values on the object
        qliObj.qleId = qleIdStr;
        qliObj.quoteName = quoteNameStr;
        qliObj.preCalculationFieldValueMap = preCalculationFieldValueMap;
        qliObj.calculatedFieldValueMap = calculatedFieldValueMap;
        qliObj.contractedFieldValueMap = contractedFieldValueMap;
        qliObj.clonedFromQleIds = clonedFromQleIds;
        qliObj.insertOnNextCurrentYear = insertOnNextCurrentYear;
        qliObj.requiredByQleId = requiredByQleId;
        qliObj.insertedWithApex = insertedWithApex;
        qliObj.deleteThisLine =  deleteThisLine;
        qliObj.nextYearQleId = nextYearQleId;
        qliObj.legacySubscriptionUpdated = legacySubscriptionUpdated;
        qliObj.requiredBySubscriptionIdString = requiredBySubscriptionIdString;
        
        test.stopTest();
        
        //Assert values
        System.assertEquals(qleIdStr, qliObj.qleId);
        System.assertEquals(quoteNameStr, qliObj.quoteName);
        System.assertEquals(preCalculationFieldValueMap, qliObj.preCalculationFieldValueMap);
        System.assertEquals(calculatedFieldValueMap, qliObj.calculatedFieldValueMap);
        System.assertEquals(contractedFieldValueMap, qliObj.contractedFieldValueMap);
        System.assertEquals(clonedFromQleIds, qliObj.clonedFromQleIds);
        System.assertEquals(insertOnNextCurrentYear, qliObj.insertOnNextCurrentYear);
        System.assertEquals(requiredByQleId, qliObj.requiredByQleId);
        System.assertEquals(insertedWithApex, qliObj.insertedWithApex);
        System.assertEquals(deleteThisLine, qliObj.deleteThisLine);
        System.assertEquals(nextYearQleId, qliObj.nextYearQleId);
        System.assertEquals(legacySubscriptionUpdated, qliObj.legacySubscriptionUpdated);
        System.assertEquals(requiredBySubscriptionIdString, qliObj.requiredBySubscriptionIdString);
       
    }
    
}