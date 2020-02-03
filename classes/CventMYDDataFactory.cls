/***********************************************************************************
 * Class : Account_TestFactory
 * Created By : Ashwini Singh
 -----------------------------------------------------------------------------------
 * Description : Factory class Cvent MYD Batch
 -----------------------------------------------------------------------------------
 * Version History:
 * Version    Developer Name    Date          Detail Features
 * 1.0        Ashwini Singh    06/15/2018    Initial Development
 **********************************************************************************/
@isTest
public class CventMYDDataFactory {


    public static Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Biz A/c').getRecordTypeId();
    public static Id RecordTypeIdOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Event').getRecordTypeId();
    public static Id RecordTypeIdProduct = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('CPQ Product').getRecordTypeId();

    public static Account createAccounts(Integer count){
        
        Account acc = new Account(Name = 'ACCOUNT' + count,
                                BillingCountryCode ='MX',
                                recordtypeid = RecordTypeIdAccount);
        return acc;
    }

    public static Contact createContacts(Integer count,Id accountID){
        
      Contact contact = new Contact(
                            LastName = 'CONTACT' + count,
                            AccountId = accountID);
        return contact;
    }

    public static Opportunity createOpportunities(Integer count, Id accountId, Id contactId){
        
        Opportunity opport = new Opportunity(
                        Name = 'OPPORTUNITY' + count,
                        StageName = 'Closed Lost - Opted Out/Cancelled',
                        CloseDate = System.today(),
                        AccountID = accountId,
                        Contact_Associated__c = contactId,
                        Contact_Role__c = ' Influencer',
                        recordtypeid = RecordTypeIdOpportunity,
                        CurrencyIsoCode = 'USD');
       
        return opport;
    }

    public static Opportunity createOpportunities_Stage(Integer count, Id accountId, Id contactId){
        
        Opportunity opport = new Opportunity(
                        Name = 'OPPORTUNITY' + count,
                        StageName = 'Proposal Sent',
                        CloseDate = System.today(),
                        AccountID = accountId,
                        Contact_Associated__c = contactId,
                        Contact_Role__c = ' Influencer',
                        recordtypeid = RecordTypeIdOpportunity,
                        CurrencyIsoCode = 'USD');
       
        return opport;
    }

    public static List<Product2> createProducts(Integer count){
        List<Product2> lstProducts = new List<Product2>();
        for(Integer i=0; i<count;i++){
                lstProducts.add(new Product2(
                                Name = 'PRODUCT' + i,
                                ProductCode = 'PRODUCT' + i,                               
                                IsActive = true,
                                recordtypeid = RecordTypeIdProduct));
        }
        return lstProducts;
    }

    public static List<PricebookEntry> createPriceBookEntry(List<Product2> lstProducts){
        List<PricebookEntry> lstPBE = new List<PricebookEntry>();
        for(Product2 lstItr : lstProducts){
           lstPBE.add(new PricebookEntry(
                        Product2Id  = lstItr.Id,
                        Pricebook2Id  = Test.getStandardPricebookId(),
                        UnitPrice = 500));
        }
        return lstPBE;
    }

    public static SBQQ__ProductOption__c createProductOptions(Id objParentProd, Id objChildProd, Integer num){
        SBQQ__ProductOption__c productOption = new SBQQ__ProductOption__c(
                                                SBQQ__Number__c = num,
                                                SBQQ__ConfiguredSKU__c = objParentProd,
                                                SBQQ__OptionalSKU__c = objChildProd);
        return productOption;
    }

    public static SBQQ__Quote__c createQuote(Id accountId, Id oppId, Boolean myd){
        Date todayDate = date.today();
        Integer endDateYear = todayDate.year() + 1;
        Integer endDateDay = todayDate.day() - 1;
        Integer endDateMonth = todayDate.month();
        SBQQ__Quote__c objQuote = new SBQQ__Quote__c(
                                    SBQQ__Status__c = 'Draft',
                                    SBQQ__StartDate__c = todayDate ,
                                    SBQQ__EndDate__c = date.newInstance(endDateYear,endDateMonth,endDateDay),
                                    Contract_Term_Years__c = '5',
                                    Current_Year__c = 1,
                                    Multiple_Years_Commitment__c = myd,
                                    SBQQ__Opportunity2__c = oppId,
                                    SBQQ__Account__c = accountId
                                    );
        return objQuote;
    }

    public static SBQQ__Quote__c createNewQuote(Id accountId, Id oppId, Boolean myd, SBQQ__Quote__c quoteId){
        Date todayDate = date.today();
        Integer endDateYear = todayDate.year() + 1;
        Integer endDateDay = todayDate.day() - 1;
        Integer endDateMonth = todayDate.month();
        SBQQ__Quote__c objQuote = new SBQQ__Quote__c(
                                    SBQQ__Status__c = 'Draft',
                                    SBQQ__StartDate__c = todayDate ,
                                    SBQQ__EndDate__c = date.newInstance(endDateYear,endDateMonth,endDateDay),
                                    Contract_Term_Years__c = '5',
                                    Current_Year__c = 1,
                                    Multiple_Years_Commitment__c = myd,
                                    SBQQ__Opportunity2__c = oppId,
                                    SBQQ__Account__c = accountId,
                                    Cloned_from_Quote__c = quoteId.Id
                                    );
        return objQuote;
    }

    public static SBQQ__QuoteLine__c createQuoteLine(SBQQ__Quote__c quoteId,Id productId, Double listPrice){

        SBQQ__QuoteLine__c objQuoteLine = new SBQQ__QuoteLine__c(
                                            Year_2_List_Price__c = 100,
                                            SBQQ__SpecialPrice__c = 100,
                                            SBQQ__PriorQuantity__c = null,
                                            Year_2_Quantity__c = 1,
                                            Year_2_Discount__c = 10,
                                            Year_2_Overage_Fee__c = 150,
                                            Year_2_Previous_Default_Overage_Fee__c = 100,
                                            Year_2_Price_Editable_Calculated__c = true,
                                            Year_2_Rate_Parity_Quantity__c = 1,
                                            Year_2_Room_Night_Net_Total__c = 50,
                                            Year_2_Room_Nights_RFPs__c = 1,
                                            Year_2_Event_Registration_Quantity__c = 1,
                                            Y02Brand__c = 100,
                                            Y02Property__c = 100,
                                            Y02Total__c = 100,
                                            Year_2_Effective_Amount__c = 100,
                                            SBQQ__ListPrice__c = listPrice,
                                            Year_3_List_Price__c = 100,
                                            Year_3_Quantity__c = 1,
                                            Year_3_Discount__c = 10,
                                            Year_3_Overage_Fee__c = 150,
                                            Year_3_Previous_Default_Overage_Fee__c = 100,
                                            Year_3_Price_Editable_Calculated__c = true,
                                            Year_3_Rate_Parity_Quantity__c = 1,
                                            Year_3_Room_Night_Net_Total__c = 50,
                                            Year_3_Room_Nights_RFPs__c = 1,
                                            Year_3_Event_Registration_Quantity__c = 1,
                                            Y03Brand__c = 100,
                                            Y03Property__c = 100,
                                            Y03Total__c = 100,
                                            Year_3_Effective_Amount__c = 100,
                                            Year_4_List_Price__c = 100,
                                            Year_4_Quantity__c = 1,
                                            Year_4_Discount__c = 10,
                                            Year_4_Overage_Fee__c = 150,
                                            Year_4_Previous_Default_Overage_Fee__c = 100,
                                            Year_4_Price_Editable_Calculated__c = true,
                                            Year_4_Rate_Parity_Quantity__c = 1,
                                            Year_4_Room_Night_Net_Total__c = 50,
                                            Year_4_Room_Nights_RFPs__c = 1,
                                            Year_4_Event_Registration_Quantity__c = 1,
                                            Y04Brand__c = 100,
                                            Y04Property__c = 100,
                                            Y04Total__c = 100,
                                            Year_4_Effective_Amount__c = 100,
                                            Year_5_List_Price__c = 100,
                                            Year_5_Quantity__c = 1,
                                            Year_5_Discount__c = 10,
                                            Year_5_Overage_Fee__c = 150,
                                            Year_5_Previous_Default_Overage_Fee__c = 100,
                                            Year_5_Price_Editable_Calculated__c = true,
                                            Year_5_Rate_Parity_Quantity__c = 1,
                                            Year_5_Room_Night_Net_Total__c = 50,
                                            Year_5_Room_Nights_RFPs__c = 1,
                                            Year_5_Event_Registration_Quantity__c = 1,
                                            Y05Brand__c = 100,
                                            Y05Property__c = 100,
                                            Y05Total__c = 100,
                                            Year_5_Effective_Amount__c = 100,
                                            SBQQ__Product__c = productId,
                                            SBQQ__Quote__c = quoteId.Id,
                                            SBQQ__ProrateMultiplier__c = 1,
                                            Rack_Rate__c = 0
                                            );
        objQuoteLine.jsonString__c = JSON.serialize(getTestQuoteLineObject());
        return objQuoteLine;
    }

    public static Clone_Quote_Refernces__c createCloneQuoteRefernces(SBQQ__Quote__c quoteId, Opportunity oppId, Account accID){       
        Clone_Quote_Refernces__c objCloneQuote = new Clone_Quote_Refernces__c(
                                        Old_Quote__c = quoteId.Id,
                                        Opportunity__c = oppId.Id,
                                        Account__c = accID.Id
                                    );
        return objCloneQuote;
    }

    public static CventMyd_QuoteLineObject getTestQuoteLineObject() {

       CventMyd_QuoteLineObject quoteLineObject = new CventMyd_QuoteLineObject();

       quoteLineObject.qleId = CventMyd_UtilityMethods.getQleId();

       quoteLineObject.insertOnNextCurrentYear = false;

       quoteLineObject.deleteThisLine = false;

       quoteLineObject.clonedFromQleIds = new List<String>();

       quoteLineObject.preCalculationFieldValueMap = new Map<String,List<String>>();

       quoteLineObject.calculatedFieldValueMap = new Map<String,List<String>>();

       for(List<String> fieldNameList : CventMyd_Settings.fieldValueMapFieldNameLists) {

           Integer index = CventMyd_Settings.fieldValueMapFieldNameLists.indexOf(fieldNameList);

           for(String fieldName : fieldNameList) {

               if(index == 0) {

                   quoteLineObject.preCalculationFieldValueMap.put(fieldName, new List<String>());

                 // quoteLineObject.preCalculationFieldValueMap.get(fieldName).add('dummyString');
                 //Added By ashwini : need Date in String format
                  quoteLineObject.preCalculationFieldValueMap.get(fieldName).add('2018-1-1');

               }

           }

       }

       quoteLineObject.nextYearQleId = CventMyd_UtilityMethods.getQleId();

       return quoteLineObject;


   }

    public static SBQQ__QuoteLineGroup__c createQuoteLineGroup(Id accountId, Id quoteId, Integer term){
        SBQQ__QuoteLineGroup__c objQuoteLineGroup = new SBQQ__QuoteLineGroup__c(
            SBQQ__Account__c = accountId,
            SBQQ__Quote__c = quoteId,
            SBQQ__Number__c = term,
            term__c = term,
            Name = 'Year' + term
        );
        return objQuoteLineGroup;
    }
    
    public static Map<Integer,CventMyd_Outyear> createCventMyd_Outyear(Integer startYear, Integer term){
        Map<Integer,CventMyd_Outyear> outYear = new Map<Integer,CventMyd_Outyear>();
        for(Integer i = 1; i <= term; i++){
            CventMyd_Outyear newOutYear = new CventMyd_Outyear();
            newOutYear.startDate = date.newInstance((startYear+i), 1, 1);
            newOutYear.endDate = date.newInstance((startYear+i), 12, 31);
            outYear.put(i, newOutYear);
        }
        return outYear;
    }
}