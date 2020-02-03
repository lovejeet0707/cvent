/**
 * @File Name          : QuoteLineTemplateContentController.cls
 * @Description        : 
 * @Author             : MS Simplus August
 * @Group              : 
 * @Last Modified By   : MS Simplus August
 * @Last Modified On   : 11/12/2019, 8:28:32 am
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    11/12/2019   MS Simplus August     Initial Version
**/
public class QuoteLineTemplateContentController {
    public String qId { get; set; }
    public List<SBQQ__QuoteLine__c> quoteLines { get; set; }
    
    public Boolean showDiscountColumnHeader { get; set; }
    public String currencySymbol { get; set; }
    public String currencySign { get; set; }
    public SBQQ__Quote__c quote { get; set; }
    
    /* Events */
    public MultiYearQLTable eventTable { get; set; }
    public List<Decimal> showEventTable { get; set; }
    public List<Decimal> showEventNoPriceTable { get; set; }
    
    /* Social Table */      //Added By Mohsin
    public MultiYearQLTable socialTable { get; set; }
    public List<Decimal> showSocialTable { get; set; }
    public List<Decimal> showSocialNoPriceTable { get; set; }                                    
    /* Hospitaliy Cloud Summary */
    public MultiYearQLTable hcSummaryTable { get; set; }
    public List<Decimal> showHcSummaryTable { get; set; }
    
    /* Listing Advertisement(s), Software, Services & CONNECT */
    public MultiYearQLTable listingAdsTable { get; set; }
    public List<Decimal> showListingAdsTable { get; set; }
    
    /* Bundle Advertisement(s) */
    public MultiYearQLTable bundleAdsTable { get; set; }
    public List<Decimal> showBundleAdsTable { get; set; }
    
    /* Cvent Passkey, Transient & Lanyon Group */
    public MultiYearQLTable passkeyTable { get; set; }
    public List<Decimal> showPasskeyTable { get; set; }
    
    /* Elite Meetings Alliance */
    public MultiYearQLTable emiTable { get; set; }
    public List<Decimal> showEmiTable { get; set; }
    
    /* RegOnline */
    public MultiYearQLTable regOnlineTable { get; set; }
    public List<Decimal> showRegOnlineTable { get; set; }
    
    /* Reporting & Analytics */
    public MultiYearQLTable reportingTable { get; set; }
    public List<Decimal> showReportingTable { get; set; }
    
    /* Suggested Advertisement(s) */
    public MultiYearQLTable suggestedAdsTable { get; set; }
    public List<Decimal> showSuggestedAdsTable { get; set; }
    
    /* Video retargeting */
    public MultiYearQLTable videoRetargetingTable { get; set; }
    public List<Decimal> showVideoRetargetingTable { get; set; }
    
    /* Merchant Account */
    public MultiYearQLTable merchantTable { get; set; }
    public List<Decimal> showMerchantTable { get; set; }
    
    /* On-demand */
    public MultiYearQLTable onDemandTable { get; set; }
    public List<Decimal> showOnDemandTable { get; set; }
    
    /* Professional Services */
    public MultiYearQLTable professionalServicesTable { get; set; }
    public List<Decimal> showProfessionalServicesTable { get; set; }
    
    
    // Start Additions by Bryce Baker 6.23.17
    /* OA360 Support */
    public List<Decimal> showOA360 { get; set; }
    public List<Decimal> showOA360NoPrices { get; set; }
    public MultiYearQLTable oa360Support { get; set; }
    // public OA360Event oa360Support {get; set;}
    public List<Decimal> showOA360SupportTable { get; set; }
    
    /* OA360 Equipment */
    public MultiYearQLTable oa360Equipment { get; set; }
    // public OA360Event oa360Equipment {get; set;}    
    public List<Decimal> showOA360EquipmentTable { get; set; }
    
    /* OA360 Supplies */
    public MultiYearQLTable oa360Supplies { get; set; }
    // public OA360Event oa360Supplies {get; set;}
    public List<Decimal> showOA360Supplies { get; set; }
    
    /* OA360 Software */
    public MultiYearQLTable oa360Software { get; set; }
    // public OA360Event oa360Software {get; set;}
    public List<Decimal> showOA360Software { get; set; }
    
    /* OA360 Software Platform */
    public MultiYearQLTable oa360SoftwarePlatform { get; set; }
    // public OA360Event oa360SoftwarePlatform {get; set;}
    public List<Decimal> showOA360SoftwarePlatform { get; set; }
    
    /* OA360 List */
    
    public List<SBQQ__QuoteLine__c> groupLines { get; set; }
    //public Map<Id, SBQQ__QuoteLine__c> (List<SBQQ__QuoteLine__c> groupLines) {get; set;}
    //End Additions Bryce Baker 6.23.17
    
    public MultiYearQLTable overagesTable { get; set; }
    public List<Decimal> showOveragesTable { get; set; }
    
    //---
    public MultiEventTable oa360SupportMulti { get; set; }
    public MultiEventTable oa360EquipmentMulti { get; set; }
    public MultiEventTable oa360SuppliesMulti { get; set; }
    public MultiEventTable oa360SoftwareMulti { get; set; }
    public MultiEventTable oa360SWPlatformMulti { get; set; }
    public Map<String, OA360Event> oa360eventsMap { get; set; }
    public Map<String, OA360Event> oa360eventsMapNoPrices { get; set; }
    public List<Decimal> empty { get; set; }// Added by Jody Crutchfield 7/11/2017 to separate main logic from constructor
    public List<Decimal> single { get; set; }// Added by Jody Crutchfield 7/11/2017 to separate main logic from constructor
    Decimal convenienceFee { get; set; }
    public static Integer contractTermYears ;
    public static Integer contractFinalYears;
    public static Integer currentYearValue;
    //Project # P-004348
    public static Boolean boo_BlockPricing {get; set;}
    public static Boolean boo_DontShowDiscountC {get; set;}
    
    //Adding Custom Setting For Bundled Products
    public static Map<String,ProductCodesUsedInQuoteDocument__c> productCodes;
    
    // added new constructor by Jody Crutchfield 7/11/2017 for proposal docs
    public QuoteLineTemplateContentController(Id quoteId) {
        empty = new List<Decimal>();
        single = new List<Decimal>();
        single.add(0.0);
        qId = quoteId;
        showDiscountColumnHeader = false;
        productCodes = ProductCodesUsedInQuoteDocument__c.getAll();
        
        quoteLines = new List<SBQQ__QuoteLine__c>();
        
        quote = [
            select Contract_Term_Years__c, Show_Savings__c, Multiple_Years_Commitment__c, Dynamic_Quote_Template_Color__c, SBQQ__NetAmount__c,
            SBQQ__ExpirationDate__c, Count_of_HC_Products__c, Hide_Unit_Prices_on_Contract__c,
            SBQQ__StartDate__c,Current_Year__c,HC_Logo_Conditional_Print__c,EC_Logo_Conditional_Print__c,
            SBQQ__EndDate__c,jsonString__c,CurrencyIsoCode,Count_of_EC_Products__c,
            Count_of_RegOnline_Products__c, Count_of_Onsite_Solutions__c, OnArrival_360_Quote__c,
            Contract_Remaining_Term__c
            from SBQQ__Quote__c
            where Id = :qid
        ];
        

        executeData();// Added by Jody Crutchfield 7/11/2017 to separate main logic from constructor
    }
    // end new contstructor by Jody Crutchfield 7/11/2017
    
    public QuoteLineTemplateContentController(){
        empty = new List<Decimal>();
        single = new List<Decimal>();
        single.add(0.0);
        showDiscountColumnHeader = false;
        productCodes = ProductCodesUsedInQuoteDocument__c.getAll();
        
        qId = (Id) ApexPages.currentPage().getParameters().get('qid');
        ////////System.debug('QuoteLineTemplateContentController');
        
        quoteLines = new List<SBQQ__QuoteLine__c>();
        
        quote = [
            select Contract_Term_Years__c, Show_Savings__c, Multiple_Years_Commitment__c, Dynamic_Quote_Template_Color__c, SBQQ__NetAmount__c,
            SBQQ__ExpirationDate__c, Count_of_HC_Products__c, Hide_Unit_Prices_on_Contract__c,Current_Year__c,EC_Logo_Conditional_Print__c,
            SBQQ__StartDate__c,SBQQ__EndDate__c,CurrencyIsoCode,Count_of_EC_Products__c,
            Count_of_RegOnline_Products__c, Count_of_Onsite_Solutions__c, OnArrival_360_Quote__c,HC_Logo_Conditional_Print__c,
            Contract_Remaining_Term__c,jsonString__c
            from SBQQ__Quote__c
            where Id = :qid
        ];
        
        executeData();// Added by Jody Crutchfield 7/11/2017 to separate main logic from constructor
       
        
    }
    //return map of years/dates
    public Map<Integer, SBQQ__QuoteLineGroup__c> MapreturnDates()
    {
        CventMyd_QuoteObject quoteObj = new CventMyd_QuoteObject();

        List<Integer> yearsSorted = new List<Integer>();
        Map<Integer, SBQQ__QuoteLineGroup__c> map_quoteLineGroups = new Map<Integer, SBQQ__QuoteLineGroup__c>();

        quoteObj = (CventMyd_QuoteObject)JSON.deserialize(quote.jsonString__c,CventMyd_QuoteObject.class);

        for(Integer year : quoteObj.outyearMap.keySet()) {
            yearsSorted.add(year);
            }

        yearsSorted.sort();       
        for(Integer year : yearsSorted) {
            SBQQ__QuoteLineGroup__c yearGroup = new SBQQ__QuoteLineGroup__c();
            yearGroup.Name = 'Year ' + String.valueOf(year);
            yearGroup.term__c = year;
            yearGroup.SBQQ__StartDate__c = quoteObj.outyearMap.get(year).startDate;
            yearGroup.SBQQ__EndDate__c = quoteObj.outyearMap.get(year).endDate;
            map_quoteLineGroups.put(year, yearGroup);

        } 
        return  map_quoteLineGroups;       
    }
    //Group Bundle Advertisements 
    public void BundleAdvertisements(SBQQ__QuoteLine__c obj_QL, Decimal int_Quantity, Boolean boo_MYD, SBQQ__Quote__c obj_quote)
    {
        QLWrapper wrapper = NULL;
        Date startDate = TemplateUtilities.getStartDateFromQL(obj_QL, obj_QL.term__c);
        Date endDate = TemplateUtilities.getEndDateFromQL(obj_QL, obj_QL.term__c);
        String showBannerAdLocation = (obj_QL.SBQQ__ProductCode__c =='CV-AD-HC-CSN-CVBCFEA') ? obj_QL.MMA_Text__c : obj_QL.Banner_Ad_Location_Name__c; // Updated for P-005050 by Dishank
        if(int_Quantity <> 0)
        {   
            if(obj_QL.term__c == 1 || ((boo_MYD || obj_quote.Current_Year__c ==obj_QL.term__c) && obj_QL.term__c >1))
            {
                if(quote.Contract_Remaining_Term__c > 1 && !quote.Multiple_Years_Commitment__c && obj_QL.term__c == 1 && quote.HC_Logo_Conditional_Print__c == 'true')
                {
                    Map<Integer, SBQQ__QuoteLineGroup__c> map_quoteLineGroups = MapreturnDates();
                    for (QLTable table : eventTable.QLTables) 
                    {
                        for (QLTable tab : bundleAdsTable.QLTables) {
                            if (tab.year == table.year) { 
                                QLWrapper wrapperTemp = NULL;
                                if(tab.year == 1)
                                {
                                    wrapperTemp = new QLWrapper(obj_QL.SBQQ__ProductName__c, obj_QL.Linked_To__c /*linkedTo*/, showBannerAdLocation  /*location*/, obj_QL.SBQQ__NetTotal__c, startDate, endDate, startDate, endDate);
                                    //tab.quoteLines.add(wrapperTemp); 
                                }else{
                                    wrapperTemp = new QLWrapper(obj_QL.SBQQ__ProductName__c, obj_QL.Linked_To__c /*linkedTo*/, showBannerAdLocation  /*location*/, obj_QL.SBQQ__NetTotal__c, map_quoteLineGroups.get((Integer)table.year).SBQQ__StartDate__c, map_quoteLineGroups.get((Integer)table.year).SBQQ__EndDate__c, map_quoteLineGroups.get((Integer)table.year).SBQQ__StartDate__c, map_quoteLineGroups.get((Integer)table.year).SBQQ__EndDate__c);
                                    //tab.quoteLines.add(new QLWrapper(obj_QL.SBQQ__ProductName__c, obj_QL.Linked_To__c /*linkedTo*/, obj_QL.Banner_Ad_Location_Name__c /*location*/, obj_QL.SBQQ__NetTotal__c, map_quoteLineGroups.get((Integer)table.year).SBQQ__StartDate__c, map_quoteLineGroups.get((Integer)table.year).SBQQ__EndDate__c, map_quoteLineGroups.get((Integer)table.year).SBQQ__StartDate__c, map_quoteLineGroups.get((Integer)table.year).SBQQ__EndDate__c)); 
                                }
                                if (wrapperTemp != null) {
                                    wrapperTemp.notes = TemplateUtilities.escapeNotesString(obj_QL.Notes__c);
                                    wrapperTemp.quantity = int_Quantity;
                                    tab.quoteLines.add(wrapperTemp);    
                                }
                            }
                        }
                    }
                    
                }
                else{
                    wrapper = new QLWrapper(obj_QL.SBQQ__ProductName__c, obj_QL.Linked_To__c /*linkedTo*/, showBannerAdLocation  /*location*/, obj_QL.SBQQ__NetTotal__c, startDate, endDate, startDate, endDate);
                }
                showBundleAdsTable = single;
            }     
        }
        //add notes check wrapper
        if (wrapper != null && obj_QL != null) {
            System.debug('CJ__ : '+bundleAdsTable);
            wrapper.notes = TemplateUtilities.escapeNotesString(obj_QL.Notes__c);
            bundleAdsTable.add((Integer)obj_QL.term__c, wrapper);    
            wrapper.quantity = int_Quantity;
            wrapper.quantityOfOne = obj_QL.SBQQ__Product__r.Quantity_of_One__c;
        }
        //bundleAdsTable.add((Integer)obj_QL.term__c, wrapper);
        
        
    }
    //Group Suggested Advertisements 
    public void SuggestedAdvertisements(SBQQ__QuoteLine__c obj_QL, Decimal int_Quantity, Boolean boo_MYD, SBQQ__Quote__c obj_quote)
    {
        QLWrapper wrapper = NULL;
        Date startDate = TemplateUtilities.getStartDateFromQL(obj_QL, obj_QL.term__c);
        Date endDate = TemplateUtilities.getEndDateFromQL(obj_QL, obj_QL.term__c);
        if(int_Quantity <> 0)
        {
            if(obj_QL.term__c == 1 || ((boo_MYD || obj_quote.Current_Year__c ==obj_QL.term__c) && obj_QL.term__c >1))
            {
                if(quote.Contract_Remaining_Term__c > 1 && !quote.Multiple_Years_Commitment__c && obj_QL.term__c == 1 && quote.HC_Logo_Conditional_Print__c == 'true')
                {
                    Map<Integer, SBQQ__QuoteLineGroup__c> map_quoteLineGroups = MapreturnDates();
                    for (QLTable table : eventTable.QLTables) 
                    {
                        for (QLTable tab : suggestedAdsTable.QLTables) {
                            if (tab.year == table.year) { 
                                QLWrapper wrapperTemp = NULL;
                                if(tab.year == 1)
                                {
                                    wrapperTemp = new QLWrapper(obj_QL.SBQQ__ProductName__c, obj_QL.Number_of_RFPs__c, obj_QL.Enter_Individual_Markets__c /*MMAs*/, obj_QL.Enter_Venue_Codes__c /*venueCodes*/, obj_QL.SBQQ__NetTotal__c, startDate, endDate, startDate, endDate); 
                                }else{
                                    wrapperTemp = new QLWrapper(obj_QL.SBQQ__ProductName__c, obj_QL.Number_of_RFPs__c, obj_QL.Enter_Individual_Markets__c /*MMAs*/, obj_QL.Enter_Venue_Codes__c /*venueCodes*/, obj_QL.SBQQ__NetTotal__c, map_quoteLineGroups.get((Integer)table.year).SBQQ__StartDate__c, map_quoteLineGroups.get((Integer)table.year).SBQQ__EndDate__c, map_quoteLineGroups.get((Integer)table.year).SBQQ__StartDate__c, map_quoteLineGroups.get((Integer)table.year).SBQQ__EndDate__c); 
                                }
                                if (wrapperTemp != null) {
                                    wrapperTemp.notes = TemplateUtilities.escapeNotesString(obj_QL.Notes__c);
                                    wrapperTemp.quantity = int_Quantity;
                                    tab.quoteLines.add(wrapperTemp);    
                                }
                            }
                        }
                    }
                }
                else{
                    wrapper = new QLWrapper(obj_QL.SBQQ__ProductName__c, obj_QL.Number_of_RFPs__c, obj_QL.Enter_Individual_Markets__c /*MMAs*/, obj_QL.Enter_Venue_Codes__c /*venueCodes*/, obj_QL.SBQQ__NetTotal__c, startDate, endDate, startDate, endDate);
                }
                showSuggestedAdsTable = single;
            }
        }
        //add notes check wrapper
        if (wrapper != null && obj_QL != null) {
            wrapper.notes = TemplateUtilities.escapeNotesString(obj_QL.Notes__c);
            wrapper.quantity = int_Quantity;
            wrapper.quantityOfOne = obj_QL.SBQQ__Product__r.Quantity_of_One__c; 
            suggestedAdsTable.add((Integer)obj_QL.term__c, wrapper);
            
        }
    }
    //Group Video Retargeting 
    public void VideoRetargeting(SBQQ__QuoteLine__c obj_QL, Decimal int_Quantity, Boolean boo_MYD, SBQQ__Quote__c obj_quote)
    {
        QLWrapper wrapper = NULL;
        Date startDate = TemplateUtilities.getStartDateFromQL(obj_QL, obj_QL.term__c);
        Date endDate = TemplateUtilities.getEndDateFromQL(obj_QL, obj_QL.term__c);
        if (int_Quantity <> 0) {
        // Updated for P-005051 by Dishank
            String showVideoTargettingProductName;
            if(obj_QL.SBQQ__ProductName__c == 'Video Retargeting - 30 seconds' || obj_QL.SBQQ__ProductName__c == 'Video Retargeting - 15 seconds' || obj_QL.SBQQ__ProductName__c == 'Google Display ADs'){
                showVideoTargettingProductName = obj_QL.SBQQ__ProductName__c + ' - ' + obj_QL.Retargeting_Tracking__c;
            }
            else{
                showVideoTargettingProductName = obj_QL.SBQQ__ProductName__c;
            }
            if(obj_QL.term__c == 1 || ((boo_MYD || obj_quote.Current_Year__c ==obj_QL.term__c) && obj_QL.term__c >1))
            {
                if(quote.Contract_Remaining_Term__c > 1 && !quote.Multiple_Years_Commitment__c && obj_QL.term__c == 1 && quote.HC_Logo_Conditional_Print__c == 'true')
                {
                    Map<Integer, SBQQ__QuoteLineGroup__c> map_quoteLineGroups = MapreturnDates();
                    for (QLTable table : eventTable.QLTables) 
                    {
                        for (QLTable tab : videoRetargetingTable.QLTables) {
                            if (tab.year == table.year) { 
                                QLWrapper wrapperTemp = NULL;
                                if(tab.year == 1)
                                {
                                    wrapperTemp = new QLWrapper(showVideoTargettingProductName, obj_QL.Number_Of_Views__c, obj_QL.SBQQ__NetTotal__c, startDate, endDate, startDate, endDate); 
                                }else{
                                    wrapperTemp = new QLWrapper(showVideoTargettingProductName, obj_QL.Number_Of_Views__c, obj_QL.SBQQ__NetTotal__c, map_quoteLineGroups.get((Integer)table.year).SBQQ__StartDate__c, map_quoteLineGroups.get((Integer)table.year).SBQQ__EndDate__c, map_quoteLineGroups.get((Integer)table.year).SBQQ__StartDate__c, map_quoteLineGroups.get((Integer)table.year).SBQQ__EndDate__c); 
                                }
                                if (wrapperTemp != null) {
                                    wrapperTemp.notes = TemplateUtilities.escapeNotesString(obj_QL.Notes__c);
                                    wrapperTemp.quantity = int_Quantity;
                                    tab.quoteLines.add(wrapperTemp);  
                                }
                            }
                        }
                    }
                }
                else{wrapper = new QLWrapper(showVideoTargettingProductName, obj_QL.Number_Of_Views__c, obj_QL.SBQQ__NetTotal__c, startDate, endDate, startDate, endDate);
                }
                showVideoRetargetingTable = single;
            }
        }
        //add notes check wrapper
        if (wrapper != null && obj_QL != null) {
            wrapper.notes = TemplateUtilities.escapeNotesString(obj_QL.Notes__c);
            wrapper.quantityOfOne = obj_QL.SBQQ__Product__r.Quantity_of_One__c; 
            videoRetargetingTable.add((Integer)obj_QL.term__c, wrapper);
            wrapper.quantity = int_Quantity;
        }
    }
    //Group Elite Meetings Alliance
    public void EliteMeetingsAlliance(SBQQ__QuoteLine__c obj_QL, Decimal int_Quantity, Boolean boo_MYD, SBQQ__Quote__c obj_quote)
    {
        QLWrapper wrapper = NULL;
        Date startDate = TemplateUtilities.getStartDateFromQL(obj_QL, obj_QL.term__c);
        Date endDate = TemplateUtilities.getEndDateFromQL(obj_QL, obj_QL.term__c);
        if (int_Quantity <> 0) {
            if(obj_QL.term__c == 1 || ((boo_MYD || obj_quote.Current_Year__c ==obj_QL.term__c) && obj_QL.term__c >1))
            {
                if(quote.Contract_Remaining_Term__c > 1 && !quote.Multiple_Years_Commitment__c && obj_QL.term__c == 1 && quote.HC_Logo_Conditional_Print__c == 'true')
                {
                    Map<Integer, SBQQ__QuoteLineGroup__c> map_quoteLineGroups = MapreturnDates();
                    for (QLTable table : eventTable.QLTables) 
                    {
                        for (QLTable tab : emiTable.QLTables) {
                            if (tab.year == table.year) { 
                                QLWrapper wrapperTemp = NULL;
                                if(tab.year == 1)
                                {
                                    wrapperTemp = new QLWrapper(obj_QL.SBQQ__ProductName__c, obj_QL.Location_Text__c, obj_QL.SBQQ__NetTotal__c, startDate, endDate, startDate, endDate); 
                                }else{
                                    wrapperTemp = new QLWrapper(obj_QL.SBQQ__ProductName__c, obj_QL.Location_Text__c, obj_QL.SBQQ__NetTotal__c, map_quoteLineGroups.get((Integer)table.year).SBQQ__StartDate__c, map_quoteLineGroups.get((Integer)table.year).SBQQ__EndDate__c, map_quoteLineGroups.get((Integer)table.year).SBQQ__StartDate__c, map_quoteLineGroups.get((Integer)table.year).SBQQ__EndDate__c); 
                                }
                                if (wrapperTemp != null) {
                                    wrapperTemp.notes = TemplateUtilities.escapeNotesString(obj_QL.Notes__c);
                                    wrapperTemp.quantity = int_Quantity;
                                    tab.quoteLines.add(wrapperTemp);  
                                }
                            }
                        }
                    }
                }
                else{wrapper = new QLWrapper(obj_QL.SBQQ__ProductName__c, obj_QL.Location_Text__c, obj_QL.SBQQ__NetTotal__c, startDate, endDate, startDate, endDate);
                }
                showEmiTable = single;
            }
        }
        //add notes check wrapper
        if (wrapper != null && obj_QL != null) {
            wrapper.notes = TemplateUtilities.escapeNotesString(obj_QL.Notes__c);
            wrapper.quantityOfOne = obj_QL.SBQQ__Product__r.Quantity_of_One__c; 
            emiTable.add((Integer)obj_QL.term__c, wrapper);
            wrapper.quantity = int_Quantity;
        }
    }
    //Group Reporting & Analytics
    public void ReportingNAnalytics(SBQQ__QuoteLine__c obj_QL, Decimal int_Quantity, Boolean boo_MYD, SBQQ__Quote__c obj_quote)
    {
        QLWrapper wrapper = NULL;
        Date startDate = TemplateUtilities.getStartDateFromQL(obj_QL, obj_QL.term__c);
        Date endDate = TemplateUtilities.getEndDateFromQL(obj_QL, obj_QL.term__c);
        if (int_Quantity <> 0) {
            if(obj_QL.term__c == 1 || ((boo_MYD || obj_quote.Current_Year__c ==obj_QL.term__c) && obj_QL.term__c >1))
            {
                if(quote.Contract_Remaining_Term__c > 1 && !quote.Multiple_Years_Commitment__c && obj_QL.term__c == 1 && quote.HC_Logo_Conditional_Print__c == 'true')
                {
                    Map<Integer, SBQQ__QuoteLineGroup__c> map_quoteLineGroups = MapreturnDates();
                    for (QLTable table : eventTable.QLTables) 
                    {
                        for (QLTable tab : reportingTable.QLTables) {
                            if (tab.year == table.year) { 
                                QLWrapper wrapperTemp = NULL;
                                if(tab.year == 1)
                                {
                                    wrapperTemp = new QLWrapper(obj_QL.SBQQ__ProductName__c, int_Quantity, obj_QL.Enter_Venue_Codes__c, obj_QL.SBQQ__NetTotal__c, startDate, endDate, startDate, endDate); 
                                }else{
                                    wrapperTemp = new QLWrapper(obj_QL.SBQQ__ProductName__c, int_Quantity, obj_QL.Enter_Venue_Codes__c, obj_QL.SBQQ__NetTotal__c, map_quoteLineGroups.get((Integer)table.year).SBQQ__StartDate__c, map_quoteLineGroups.get((Integer)table.year).SBQQ__EndDate__c, map_quoteLineGroups.get((Integer)table.year).SBQQ__StartDate__c, map_quoteLineGroups.get((Integer)table.year).SBQQ__EndDate__c); 
                                }
                                if (wrapperTemp != null) {
                                    wrapperTemp.notes = TemplateUtilities.escapeNotesString(obj_QL.Notes__c);
                                    wrapperTemp.quantity = int_Quantity;
                                    tab.quoteLines.add(wrapperTemp);  
                                }
                            }
                        }
                    }
                }
                else{wrapper = new QLWrapper(obj_QL.SBQQ__ProductName__c, int_Quantity, obj_QL.Enter_Venue_Codes__c, obj_QL.SBQQ__NetTotal__c, startDate, endDate, startDate, endDate);
                }
                showReportingTable = single;
            }
        }
        //add notes check wrapper
        if (wrapper != null && obj_QL != null) {
            wrapper.notes = TemplateUtilities.escapeNotesString(obj_QL.Notes__c);
            wrapper.quantityOfOne = obj_QL.SBQQ__Product__r.Quantity_of_One__c; 
            reportingTable.add((Integer)obj_QL.term__c, wrapper);
            wrapper.quantity = int_Quantity;
        }
        
    }
    // Group Passkey
    public void Passkey(SBQQ__QuoteLine__c obj_QL, Decimal int_Quantity, Boolean boo_MYD, SBQQ__Quote__c obj_quote)
    {
        QLWrapper wrapper = NULL;
        Date startDate = TemplateUtilities.getStartDateFromQL(obj_QL, obj_QL.term__c);
        Date endDate = TemplateUtilities.getEndDateFromQL(obj_QL, obj_QL.term__c);
        if (int_Quantity <> 0) {
            if(obj_QL.term__c == 1 || ((boo_MYD || obj_quote.Current_Year__c ==obj_QL.term__c) && obj_QL.term__c >1))
            {
                if(quote.Contract_Remaining_Term__c > 1 && !quote.Multiple_Years_Commitment__c && obj_QL.term__c == 1 && quote.HC_Logo_Conditional_Print__c == 'true')
                {
                    Map<Integer, SBQQ__QuoteLineGroup__c> map_quoteLineGroups = MapreturnDates();
                    for (QLTable table : eventTable.QLTables) 
                    {
                        for (QLTable tab : passkeyTable.QLTables) {
                            if (tab.year == table.year) { 
                                QLWrapper wrapperTemp = NULL;
                                if(tab.year == 1)
                                {
                                    wrapperTemp = new QLWrapper(obj_QL.SBQQ__ProductName__c, obj_QL.Product_Family__c, obj_QL.Unit__c, int_Quantity, obj_QL.SBQQ__NetTotal__c, startDate, endDate, startDate, endDate); 
                                }else{
                                    wrapperTemp = new QLWrapper(obj_QL.SBQQ__ProductName__c, obj_QL.Product_Family__c, obj_QL.Unit__c, int_Quantity, obj_QL.SBQQ__NetTotal__c, map_quoteLineGroups.get((Integer)table.year).SBQQ__StartDate__c, map_quoteLineGroups.get((Integer)table.year).SBQQ__EndDate__c, map_quoteLineGroups.get((Integer)table.year).SBQQ__StartDate__c, map_quoteLineGroups.get((Integer)table.year).SBQQ__EndDate__c); 
                                }
                                if (wrapperTemp != null) {
                                    wrapperTemp.notes = TemplateUtilities.escapeNotesString(obj_QL.Notes__c);
                                    wrapperTemp.quantity = int_Quantity;
                                    tab.quoteLines.add(wrapperTemp);  
                                }
                            }
                        }
                    }
                }
                else{wrapper = new QLWrapper(obj_QL.SBQQ__ProductName__c, obj_QL.Product_Family__c, obj_QL.Unit__c, int_Quantity, obj_QL.SBQQ__NetTotal__c, startDate, endDate, startDate, endDate);
                }
                showPasskeyTable = single;
            }
        }
        //add notes check wrapper
        if (wrapper != null && obj_QL != null) {
            wrapper.notes = TemplateUtilities.escapeNotesString(obj_QL.Notes__c);
            wrapper.quantityOfOne = obj_QL.SBQQ__Product__r.Quantity_of_One__c; 
            passkeyTable.add((Integer)obj_QL.term__c, wrapper);
            wrapper.quantity = int_Quantity;
        }
    }
    // Group Social Tables - Added by Mohsin
    public void SocialTables(SBQQ__QuoteLine__c obj_QL, Decimal int_Quantity, Boolean boo_MYD, SBQQ__Quote__c obj_quote,Decimal priceTotal)
    {
        QLWrapper wrapper = NULL;
        Date startDate = TemplateUtilities.getStartDateFromQL(obj_QL, obj_QL.term__c);
        Date endDate = TemplateUtilities.getEndDateFromQL(obj_QL, obj_QL.term__c);
        if (int_Quantity <> 0) {
            if(obj_QL.term__c == 1 || ((boo_MYD || obj_quote.Current_Year__c ==obj_QL.term__c) && obj_QL.term__c >1))
            {
                if(quote.Contract_Remaining_Term__c > 1 && !quote.Multiple_Years_Commitment__c && obj_QL.term__c == 1 && quote.HC_Logo_Conditional_Print__c == 'true')
                {
                    Map<Integer, SBQQ__QuoteLineGroup__c> map_quoteLineGroups = MapreturnDates();
                    for (QLTable table : eventTable.QLTables) 
                    {
                        for (QLTable tab : socialTable.QLTables) {
                            if (tab.year == table.year) { 
                                QLWrapper wrapperTemp = NULL;
                                if(tab.year == 1)
                                {
                                    wrapperTemp = new QLWrapper(obj_QL.SBQQ__ProductName__c, obj_QL.Product_Family__c, obj_QL.Unit__c, int_Quantity, priceTotal, startDate, endDate, startDate, endDate); 
                                }else{
                                    wrapperTemp = new QLWrapper(obj_QL.SBQQ__ProductName__c, obj_QL.Product_Family__c, obj_QL.Unit__c, int_Quantity, priceTotal, map_quoteLineGroups.get((Integer)table.year).SBQQ__StartDate__c, map_quoteLineGroups.get((Integer)table.year).SBQQ__EndDate__c, map_quoteLineGroups.get((Integer)table.year).SBQQ__StartDate__c, map_quoteLineGroups.get((Integer)table.year).SBQQ__EndDate__c); 
                                }
                                if (wrapperTemp != null) {
                                    wrapperTemp.notes = TemplateUtilities.escapeNotesString(obj_QL.Notes__c);
                                    wrapperTemp.quantity = int_Quantity;
                                    tab.quoteLines.add(wrapperTemp);  
                                }
                            }
                        }
                    }
                }
                else{wrapper = new QLWrapper(obj_QL.SBQQ__ProductName__c, obj_QL.Product_Family__c, obj_QL.Unit__c, int_Quantity, priceTotal, startDate, endDate, startDate, endDate);
                }
                System.debug('Inside of social table method');
                showSocialTable = single;
            }
        }
        //add notes check wrapper
        if (wrapper != null && obj_QL != null) {
            wrapper.notes = TemplateUtilities.escapeNotesString(obj_QL.Notes__c);
            wrapper.quantityOfOne = obj_QL.SBQQ__Product__r.Quantity_of_One__c; 
            socialTable.add((Integer)obj_QL.term__c, wrapper);
            wrapper.quantity = int_Quantity;
        }
    }
    //Group Listing Advertisement(s), Software, Services & CONNECT
    public void ListingAdvertisement(SBQQ__QuoteLine__c obj_QL, Decimal int_Quantity, Boolean boo_MYD, SBQQ__Quote__c obj_quote)
    {
        QLWrapper wrapper = NULL;
        Date startDate = TemplateUtilities.getStartDateFromQL(obj_QL, obj_QL.term__c);
        Date endDate = TemplateUtilities.getEndDateFromQL(obj_QL, obj_QL.term__c);
        //String showBannerAdLocation = (obj_QL.SBQQ__ProductCode__c =='CV-AD-HC-CSN-CVBCFEA') ? obj_QL.MMA_Text__c : obj_QL.Banner_Ad_Location_Name__c; // Updated for P-005050 by Dishank
        String showDiamondPlusMicroSitewithName = (obj_QL.SBQQ__ProductCode__c =='CV-AD-HC-CSN-DIAPLS') ? obj_QL.SBQQ__ProductName__c + ' - ' + obj_QL.Linked_To__c  : ((obj_QL.SBQQ__ProductCode__c =='CV-SW-HC-COT-MLUPRPTUSRACS') ? obj_QL.SBQQ__ProductName__c + ' - ' + obj_QL.Number_of_Users__c + ' Users for ' + obj_QL.Number_of_Venues__c + ' Venues' : obj_QL.SBQQ__ProductName__c); // Updated for JIRA 101 by Dishank // Update by HJ on 12/3 for TICCM-952
        if (int_Quantity <> 0) {
            if(obj_QL.term__c == 1 || ((boo_MYD || obj_quote.Current_Year__c ==obj_QL.term__c) && obj_QL.term__c >1))
            {
                if(quote.Contract_Remaining_Term__c > 1 && !quote.Multiple_Years_Commitment__c && obj_QL.term__c == 1 && quote.HC_Logo_Conditional_Print__c == 'true')
                {
                    Map<Integer, SBQQ__QuoteLineGroup__c> map_quoteLineGroups = MapreturnDates();
                    for (QLTable table : eventTable.QLTables) 
                    {
                        for (QLTable tab : listingAdsTable.QLTables) {
                            if (tab.year == table.year) { 
                                QLWrapper wrapperTemp = NULL;
                                if(tab.year == 1)
                                {
                                    wrapperTemp = new QLWrapper(showDiamondPlusMicroSitewithName, startDate, endDate, obj_QL.SBQQ__NetTotal__c,obj_QL.MMA_Text__c); 
                                }else{
                                    wrapperTemp = new QLWrapper(showDiamondPlusMicroSitewithName, map_quoteLineGroups.get((Integer)table.year).SBQQ__StartDate__c, map_quoteLineGroups.get((Integer)table.year).SBQQ__EndDate__c, obj_QL.SBQQ__NetTotal__c,obj_QL.MMA_Text__c); 
                                }
                                if (wrapperTemp != null) {
                                    wrapperTemp.notes = TemplateUtilities.escapeNotesString(obj_QL.Notes__c);
                                    wrapperTemp.quantity = int_Quantity;
                                    tab.quoteLines.add(wrapperTemp);  
                                }
                            }
                        }
                    }
                }
                else{wrapper = new QLWrapper(showDiamondPlusMicroSitewithName, startDate, endDate, obj_QL.SBQQ__NetTotal__c,obj_QL.MMA_Text__c);
                }
                showListingAdsTable = single;
            }
        }
        //add notes check wrapper
        if (wrapper != null && obj_QL != null) {
            wrapper.notes = TemplateUtilities.escapeNotesString(obj_QL.Notes__c);
            wrapper.quantityOfOne = obj_QL.SBQQ__Product__r.Quantity_of_One__c; 
            listingAdsTable.add((Integer)obj_QL.term__c, wrapper);
            wrapper.quantity = int_Quantity;
        }
    }
    //Group OA360
    public QLWrapper OA360GROUP(SBQQ__QuoteLine__c obj_QL, Decimal int_Quantity, Boolean boo_MYD, SBQQ__Quote__c obj_quote)
    {
        Decimal rackRate;
        rackRate = obj_QL.Rack_Rate__c;
        QLWrapper wrapper;
        if (int_Quantity <> 0) {
            if(obj_QL.term__c == 1){wrapper = new QLWrapper(obj_QL.SBQQ__ProductName__c, int_Quantity, rackRate, rackRate * obj_QL.SBQQ__Quantity__c, obj_QL.SBQQ__NetPrice__c, obj_QL.SBQQ__NetTotal__c);}else if(boo_MYD && obj_QL.term__c >1){wrapper = new QLWrapper(obj_QL.SBQQ__ProductName__c, int_Quantity, rackRate, rackRate * int_Quantity, obj_QL.SBQQ__NetPrice__c / int_Quantity, obj_QL.SBQQ__NetPrice__c);}
        }
        //add notes check wrapper
        if (wrapper != null && obj_QL != null) {wrapper.notes = TemplateUtilities.escapeNotesString(obj_QL.Notes__c);wrapper.quantity = int_Quantity;wrapper.quantityOfOne = obj_QL.SBQQ__Product__r.Quantity_of_One__c;}
        return wrapper;
    }
    // separated from constructor by Jody Crutchfield 7/11/2017 to allow multiple constructors
    public void executeData() {
        
        currencySymbol = quote.CurrencyIsoCode;
        
        currencySign =  currencySymbol + ' ';
       
        contractTermYears = quote.Contract_Remaining_Term__c.intValue();
        contractFinalYears =Integer.valueOf(quote.Contract_Term_Years__c);
        currentYearValue = quote.Current_Year__c.intValue();
        
        oa360SupportMulti = new MultiEventTable();
        oa360EquipmentMulti = new MultiEventTable();
        oa360SuppliesMulti = new MultiEventTable();
        oa360SoftwareMulti = new MultiEventTable();
        oa360SWPlatformMulti = new MultiEventTable();
        oa360eventsMap = new Map<String, OA360Event>();
        if (quote.Multiple_Years_Commitment__c || quote.HC_Logo_Conditional_Print__c == 'true') {
            
            eventTable = new MultiYearQLTable(contractFinalYears,currentYearValue);
            listingAdsTable = new MultiYearQLTable(contractFinalYears,currentYearValue);
            hcSummaryTable = new MultiYearQLTable(contractFinalYears,currentYearValue);
            //hcSummaryTable = new MultiYearQLTable(contractFinalYears,currentYearValue);
            bundleAdsTable = new MultiYearQLTable(contractFinalYears,currentYearValue);
            passkeyTable = new MultiYearQLTable(contractFinalYears,currentYearValue);
            emiTable = new MultiYearQLTable(contractFinalYears,currentYearValue);
            regOnlineTable = new MultiYearQLTable(contractFinalYears,currentYearValue);
            suggestedAdsTable = new MultiYearQLTable(contractFinalYears,currentYearValue);
            reportingTable = new MultiYearQLTable(contractFinalYears,currentYearValue);
            videoRetargetingTable = new MultiYearQLTable(contractFinalYears,currentYearValue);
            merchantTable = new MultiYearQLTable(contractFinalYears,currentYearValue);
            onDemandTable = new MultiYearQLTable(contractFinalYears,currentYearValue);
            professionalServicesTable = new MultiYearQLTable(contractFinalYears,currentYearValue);
            oa360Support = new MultiYearQLTable(contractFinalYears,currentYearValue);
            oa360Equipment = new MultiYearQLTable(contractFinalYears,currentYearValue);
            oa360Supplies = new MultiYearQLTable(contractFinalYears,currentYearValue);
            oa360Software = new MultiYearQLTable(contractFinalYears,currentYearValue);
            oa360SoftwarePlatform = new MultiYearQLTable(contractFinalYears,currentYearValue);
            //overagesTable = new MultiYearQLTable(contractTermYears);
            overagesTable = new MultiYearQLTable(contractFinalYears,currentYearValue);
            socialTable = new MultiYearQLTable(contractFinalYears,currentYearValue);    //Added By Mohsin
            
        } else {
            eventTable = new MultiYearQLTable(1);
            listingAdsTable = new MultiYearQLTable(1);
            //hcSummaryTable = new MultiYearQLTable(contractTermYears);
            hcSummaryTable = new MultiYearQLTable(contractFinalYears,currentYearValue);
            //hcSummaryTable = new MultiYearQLTable(1);
            bundleAdsTable = new MultiYearQLTable(1);
            passkeyTable = new MultiYearQLTable(1);
            emiTable = new MultiYearQLTable(1);
            regOnlineTable = new MultiYearQLTable(1);
            suggestedAdsTable = new MultiYearQLTable(1);
            reportingTable = new MultiYearQLTable(1);
            videoRetargetingTable = new MultiYearQLTable(1);
            merchantTable = new MultiYearQLTable(1);
            onDemandTable = new MultiYearQLTable(1);
            professionalServicesTable = new MultiYearQLTable(1);
            oa360Support = new MultiYearQLTable(1);
            oa360Equipment = new MultiYearQLTable(1);
            oa360Supplies = new MultiYearQLTable(1);
            oa360Software = new MultiYearQLTable(1);
            oa360SoftwarePlatform = new MultiYearQLTable(1);
            
            overagesTable = new MultiYearQLTable(1);
            socialTable = new MultiYearQLTable(1);  //Added By Mohsin
            contractTermYears = 1;
        }
        showEventTable = empty;
        showListingAdsTable = empty;
        showBundleAdsTable = empty;
        showPasskeyTable = empty;
        showEmiTable = empty;
        showRegOnlineTable = empty;
        showSuggestedAdsTable = empty;
        showReportingTable = empty;
        showVideoRetargetingTable = empty;
        showMerchantTable = empty;
        showOnDemandTable = empty;
        showProfessionalServicesTable = empty;
        showOA360SupportTable = empty;
        showOA360EquipmentTable = empty;
        showOA360Supplies = empty;
        showOA360Software = empty;
        showOA360SoftwarePlatform = empty;
        showOA360 = empty;
        showOA360NoPrices = empty;
        showSocialTable = empty;    //Added By Mohsin
        
        List<SBQQ__QuoteLine__c> quoteLines = [
            select Id,SBQQ__Quote__r.SBQQ__StartDate__c, SBQQ__Quote__r.SBQQ__EndDate__c, Rack_Rate__c,SBQQ__Optional__c,
            SBQQ__Quote__r.SBQQ__Type__c,SBQQ__Quote__r.Current_Year__c,
            SBQQ__Quote__r.itemsToBypass__c,
            SBQQ__NetPrice__c, SBQQ__Quantity__c, SBQQ__ProductName__c, Contract_Output_Grouping__c,
            CurrencyIsoCode, SBQQ__Bundled__c, SBQQ__ComponentVisibility__c,
            Number_Of_Views__c, Location_Text__c, Overage_Fee__c, SBQQ__ProductOption__r.SBQQ__QuoteLineVisibility__c,
            SBQQ__RequiredBy__c, SBQQ__ProductOption__r.SBQQ__Feature__r.Name, SBQQ__ProductCode__c,
            totalRollupPrice__c, Rollup_Price__c, Rollup_Quantity__c, 
            SBQQ__ListPrice__c, 
            SBQQ__NetTotal__c, 
            Editor_Net_Total__c,Number_of_RFPs__c, MMA_Text__c,Enter_Venue_Codes__c,Linked_To__c,Product_Family__c, Banner_Ad_Location_Name__c, SBQQ__Hidden__c, Ad_Start_Date__c, Ad_End_Date__c, Product_Line__c,
            Unit__c, term__c, jsonString__c,
            SBQQ__EffectiveQuantity__c, SBQQ__RegularPrice__c,
            SBQQ__Product__r.Contract_Output_Grouping__c,
            SBQQ__Product__r.Quantity_of_One__c,
            OnArrival_360_Event_Selection__r.Name, OnArrival_360_Event_Selection__r.Dates__c,
            OnArrival_360_Event_Selection__r.Number_of_Attendees__c,OnArrival_360_Event_Selection__r.Number_of_Exhibitors__c, SBQQ__TotalDiscountAmount__c,
            OnArrival_360_Event_Selection__r.Address_of_Event__c,
            SBQQ__RequiredBy__r.OnArrival_360_Event_Selection__r.Name, SBQQ__RequiredBy__r.OnArrival_360_Event_Selection__r.Dates__c, 
            SBQQ__RequiredBy__r.OnArrival_360_Event_Selection__r.Number_of_Attendees__c, 
            SBQQ__RequiredBy__r.OnArrival_360_Event_Selection__r.Number_of_Exhibitors__c,
            SBQQ__RequiredBy__r.OnArrival_360_Event_Selection__r.Address_of_Event__c,
            SBQQ__RequiredBy__r.SBQQ__RequiredBy__r.OnArrival_360_Event_Selection__r.Address_of_Event__c,SBQQ__RequiredBy__r.SBQQ__RequiredBy__r.OnArrival_360_Event_Selection__r.Dates__c,
            SBQQ__RequiredBy__r.SBQQ__RequiredBy__r.OnArrival_360_Event_Selection__r.Name, 
            SBQQ__RequiredBy__r.SBQQ__RequiredBy__r.OnArrival_360_Event_Selection__r.Number_of_Attendees__c, 
            SBQQ__RequiredBy__r.SBQQ__RequiredBy__r.OnArrival_360_Event_Selection__r.Number_of_Exhibitors__c,
            Notes__c, Enter_Individual_Markets__c,
            SBQQ__RequiredBy__r.SBQQ__RequiredBy__r.OnArrival_360_Event_Selection__r.Venue_Name__c,
            SBQQ__Product__r.Show_True_Quantity__c, SBQQ__RequiredBy__r.OnArrival_360_Event_Selection__r.Venue_Name__c, OnArrival_360_Event_Selection__r.Venue_Name__c,
            SBQQ__EffectiveStartDate__c, SBQQ__EffectiveEndDate__c, SBQQ__StartDate__c, SBQQ__EndDate__c,
            SBQQ__PricingMethod__c, SBQQ__DiscountScheduleType__c,rollupQuantityIntoThisBundle__c,
            SBQQ__PriorQuantity__c, SA_Start_Date__c, SA_End_Date__c, SBQQ__PriceEditable__c,Total_Discount_Percent__c,SBQQ__Product__r.Name,SBQQ__Number__c,Retargeting_Tracking__c,Number_of_Venues__c, Number_of_Users__c,(select Overage_Fee__c,SBQQ__EffectiveQuantity__c,SBQQ__Quantity__c from SBQQ__Quote_Lines__r)
            from SBQQ__QuoteLine__c
            where SBQQ__Quote__c = :qid  
            AND(SBQQ__EffectiveQuantity__c != 0  OR rollupQuantityIntoThisBundle__c =true) 
            ORDER BY SBQQ__Number__c ASC
        ];
        if(CventMyd_ValidationHandler.settings.groupingValidationSettings.validateOnDocument) {
            CventMyd_ValidationHandler.validateOnArrivalLineCounts(quoteLines);
        }          
        System.debug('quoteLines SIZE: '+quoteLines.size());
        for (SBQQ__QuoteLine__c ql : quoteLines) {
            System.debug('EffectiveQuantity>>>'+ql.SBQQ__EffectiveQuantity__c);
            System.debug('Contract Output Grouping>>>'+ql.Contract_Output_Grouping__c);
            boo_DontShowDiscountC = ql.SBQQ__Product__r.Quantity_of_One__c;
            if(!showDiscountColumnHeader){
                if(ql.SBQQ__Quantity__c != null && ql.SBQQ__Quantity__c != 0 && ql.Rack_Rate__c != null && ql.SBQQ__NetPrice__c != null && ql.SBQQ__NetPrice__c != ql.Rack_Rate__c){
                    showDiscountColumnHeader = true;
                    if(ql.SBQQ__ProductOption__c != null && ql.SBQQ__ProductOption__r.SBQQ__QuoteLineVisibility__c == 'Never'){showDiscountColumnHeader = false; }
                }                    
            }
            
            if(ql.SBQQ__NetPrice__c == null){ql.SBQQ__NetPrice__c = 0.00;}
            Boolean isAssociationStation = ql.SBQQ__Product__r.Name.contains('Association Stations - Software');
            Boolean isOnArrival360 = ql.SBQQ__Product__r.Name.contains('OnArrival 360');
            Boolean isInBundle = (ql.SBQQ__RequiredBy__c != null);
            Boolean isAssociationStationOption = (isAssociationStation && isInBundle);
            Decimal int_Quantity = 0;
            //Project #  P-004348
            if(ql.SBQQ__Product__r.Show_True_Quantity__c){
                int_Quantity = ql.SBQQ__Quantity__c; 
                boo_BlockPricing = true;
                }else{
                    int_Quantity = ql.SBQQ__EffectiveQuantity__c; 
                    boo_BlockPricing = false;}

            if (!ql.SBQQ__Bundled__c && ql.SBQQ__ComponentVisibility__c != 'Never' && ql.SBQQ__ComponentVisibility__c != 'Editor Only' && !ql.SBQQ__Hidden__c && !isAssociationStationOption ) {
                
                if (ql.Contract_Output_Grouping__c == 'Bundle Advertisements' && ql.SBQQ__EffectiveQuantity__c <> 0) {
                    
                    
                    BundleAdvertisements(ql, int_Quantity, quote.Multiple_Years_Commitment__c, quote);
                    
                } else if (ql.Contract_Output_Grouping__c == 'Suggested Advertisements' && ql.SBQQ__EffectiveQuantity__c <> 0 ) {
                    
                    SuggestedAdvertisements(ql, int_Quantity, quote.Multiple_Years_Commitment__c, quote);
                } else if (ql.Contract_Output_Grouping__c == 'Video Retargeting' && ql.SBQQ__EffectiveQuantity__c <> 0) {
                    
                    VideoRetargeting(ql, int_Quantity, quote.Multiple_Years_Commitment__c, quote);
                } else if (ql.Contract_Output_Grouping__c == 'Elite Meetings Alliance' && ql.SBQQ__EffectiveQuantity__c <> 0) {
                    
                    EliteMeetingsAlliance(ql, int_Quantity, quote.Multiple_Years_Commitment__c, quote);
                } else if (ql.Contract_Output_Grouping__c == 'Reporting & Analytics' && ql.SBQQ__EffectiveQuantity__c <> 0) {
                
                ReportingNAnalytics(ql, int_Quantity, quote.Multiple_Years_Commitment__c, quote);
                } else if (ql.Contract_Output_Grouping__c == 'Cvent Passkey, Transient & Lanyon Group' && ql.SBQQ__EffectiveQuantity__c <> 0) {
                    
                    Passkey(ql, int_Quantity, quote.Multiple_Years_Commitment__c, quote);
                    
                } else if (ql.Contract_Output_Grouping__c == 'Listing Advertisement(s), Software, Services & CONNECT' && ql.SBQQ__EffectiveQuantity__c <> 0) {
                    
                    ListingAdvertisement(ql, int_Quantity, quote.Multiple_Years_Commitment__c, quote);
                } else if (ql.Contract_Output_Grouping__c == 'Social Tables' && ql.SBQQ__EffectiveQuantity__c <> 0 && Boolean.valueOf(Label.SocialTableDocument)) { 
                    if(productCodes.containsKey(ql.SBQQ__ProductCode__c))
                    {
                        SocialTables(ql, ql.Rollup_Quantity__c, quote.Multiple_Years_Commitment__c, quote,ql.totalRollupPrice__c);
                    }
                    else
                    {
                        SocialTables(ql, int_Quantity, quote.Multiple_Years_Commitment__c, quote,ql.SBQQ__NetTotal__c);
                    }
                }else if (ql.Contract_Output_Grouping__c == 'Merchant' && ql.SBQQ__EffectiveQuantity__c <> 0) {
                    QLWrapper wrapper = new QLWrapper(ql.SBQQ__ProductName__c, int_Quantity, ql.SBQQ__NetTotal__c);
                    if (int_Quantity <> 0) {
                        showMerchantTable = single;
                        
                        if (wrapper != null && ql != null) {
                            wrapper.notes = TemplateUtilities.escapeNotesString(ql.Notes__c);
                        }
                        merchantTable.add((Integer)ql.term__c, wrapper); // merchantTable.add(1, wrapper); had to change logic to work with terms
                    }
                    wrapper.quantity = int_Quantity;
                    wrapper.quantityOfOne = ql.SBQQ__Product__r.Quantity_of_One__c; 
                } else if (ql.Contract_Output_Grouping__c == 'OnDemand' && ql.SBQQ__EffectiveQuantity__c <> 0) {
                    QLWrapper wrapper = new QLWrapper(ql.SBQQ__ProductName__c, int_Quantity, ql.Rack_Rate__c, ql.Rack_Rate__c * int_Quantity, ql.SBQQ__NetPrice__c, ql.SBQQ__NetTotal__c, ql.Rack_Rate__c * int_Quantity - ql.SBQQ__NetTotal__c);
                    if (int_Quantity <> 0) {
                        showOnDemandTable = single;
                        
                        if (wrapper != null && ql != null) {
                            wrapper.notes = TemplateUtilities.escapeNotesString(ql.Notes__c);
                        }
                        onDemandTable.add((Integer)ql.term__c, wrapper);
                    }
                    wrapper.quantity = int_Quantity;
                    wrapper.quantityOfOne = ql.SBQQ__Product__r.Quantity_of_One__c; 
                } else if (ql.Contract_Output_Grouping__c == 'Professional' && ql.SBQQ__EffectiveQuantity__c <> 0) {
                    QLWrapper wrapper = new QLWrapper(ql.SBQQ__ProductName__c, int_Quantity, ql.Rack_Rate__c, ql.Rack_Rate__c * int_Quantity, ql.SBQQ__NetPrice__c, ql.SBQQ__NetTotal__c, ql.Rack_Rate__c * int_Quantity - ql.SBQQ__NetTotal__c);
                    if (int_Quantity <> 0) {
                        showProfessionalServicesTable = single;
                        
                        if (wrapper != null && ql != null) {
                            wrapper.notes = TemplateUtilities.escapeNotesString(ql.Notes__c);
                        }
                        professionalServicesTable.add((Integer)ql.term__c, wrapper);
                    }
                    wrapper.quantity = int_Quantity;
                    wrapper.quantityOfOne = ql.SBQQ__Product__r.Quantity_of_One__c; 
                }
                else if ((ql.Contract_Output_Grouping__c == 'Event Cloud' || ql.Contract_Output_Grouping__c == 'OA360 Support' || ql.Contract_Output_Grouping__c == 'OA360 Equipment' || ql.Contract_Output_Grouping__c == 'OA360 Supplies' || ql.Contract_Output_Grouping__c == 'OA 360 Software' || ql.Contract_Output_Grouping__c == 'Software Platform') && ql.SBQQ__EffectiveQuantity__c <> 0) {
                    
                    System.debug('Inside of last If');
                    OA360Event event;
                    String eventName = ql.OnArrival_360_Event_Selection__r.Name;
                    String address = ql.OnArrival_360_Event_Selection__r.Address_of_Event__c;
                    String dates = ql.OnArrival_360_Event_Selection__r.Dates__c;
                    String venue = ql.OnArrival_360_Event_Selection__r.Venue_Name__c;
                    String attendees = ql.OnArrival_360_Event_Selection__r.Number_of_Attendees__c;
                    String exhibitors = ql.OnArrival_360_Event_Selection__r.Number_of_Exhibitors__c; 
                    if (eventName == NULL) {
                        eventName = ql.SBQQ__RequiredBy__r.OnArrival_360_Event_Selection__r.Name;
                        address = ql.SBQQ__RequiredBy__r.OnArrival_360_Event_Selection__r.Address_of_Event__c;
                        dates = ql.SBQQ__RequiredBy__r.OnArrival_360_Event_Selection__r.Dates__c;
                        venue = ql.SBQQ__RequiredBy__r.OnArrival_360_Event_Selection__r.Venue_Name__c;
                        attendees = ql.SBQQ__RequiredBy__r.OnArrival_360_Event_Selection__r.Number_of_Attendees__c;
                        exhibitors = ql.SBQQ__RequiredBy__r.OnArrival_360_Event_Selection__r.Number_of_Exhibitors__c; 
                        if (eventName == NULL) {
                            eventName = ql.SBQQ__RequiredBy__r.SBQQ__RequiredBy__r.OnArrival_360_Event_Selection__r.Name;
                            address = ql.SBQQ__RequiredBy__r.SBQQ__RequiredBy__r.OnArrival_360_Event_Selection__r.Address_of_Event__c;
                            dates = ql.SBQQ__RequiredBy__r.SBQQ__RequiredBy__r.OnArrival_360_Event_Selection__r.Dates__c;
                            venue = ql.SBQQ__RequiredBy__r.SBQQ__RequiredBy__r.OnArrival_360_Event_Selection__r.Venue_Name__c;
                            attendees = ql.SBQQ__RequiredBy__r.SBQQ__RequiredBy__r.OnArrival_360_Event_Selection__r.Number_of_Attendees__c;
                            exhibitors = ql.SBQQ__RequiredBy__r.SBQQ__RequiredBy__r.OnArrival_360_Event_Selection__r.Number_of_Exhibitors__c; 
                        }
                    }

                    //eventName = eventName.escapeHtml3();
                    if(!String.isEmpty(eventName))
                    {
                        eventName = eventName.escapeHtml3();
                    }
                    //address = address.escapeHtml3();
                    if(!String.isEmpty(address))
                    {
                        address = address.escapeHtml3();
                    }
                    //dates = dates.escapeHtml3();
                    if(!String.isEmpty(dates))
                    {
                        dates = dates.escapeHtml3();
                    }
                    //venue = venue.escapeHtml3();
                    if(!String.isEmpty(venue))
                    {
                        venue = venue.escapeHtml3();
                    }
                    event = oa360eventsMap.get(eventName);
                    
                    if (event == NULL) {
                        event = new OA360Event(eventName, dates, address, venue, attendees,exhibitors);
                        event.eventName = eventName;
                        oa360eventsMap.put(eventName, event);
                        if (quote.Multiple_Years_Commitment__c == TRUE || quote.HC_Logo_Conditional_Print__c == 'true') {
                            oa360SupportMulti.eventLinesMap.put(eventName, new MultiYearQLTable(contractTermYears));
                            oa360EquipmentMulti.eventLinesMap.put(eventName, new MultiYearQLTable(contractTermYears));
                            oa360SuppliesMulti.eventLinesMap.put(eventName, new MultiYearQLTable(contractTermYears));
                            oa360SoftwareMulti.eventLinesMap.put(eventName, new MultiYearQLTable(contractTermYears));
                            oa360SWPlatformMulti.eventLinesMap.put(eventName, new MultiYearQLTable(contractTermYears));
                        } else {
                            oa360SupportMulti.eventLinesMap.put(eventName, new MultiYearQLTable(1));
                            oa360EquipmentMulti.eventLinesMap.put(eventName, new MultiYearQLTable(1));
                            oa360SuppliesMulti.eventLinesMap.put(eventName, new MultiYearQLTable(1));
                            oa360SoftwareMulti.eventLinesMap.put(eventName, new MultiYearQLTable(1));
                            oa360SWPlatformMulti.eventLinesMap.put(eventName, new MultiYearQLTable(1));
                        }
                    }
                    if (ql.Contract_Output_Grouping__c == 'OA360 Support' && ql.SBQQ__EffectiveQuantity__c <> 0) {
                        Decimal rackRate;
                        rackRate = ql.Rack_Rate__c;
                        QLWrapper wrapper;
                        if (ql.term__c ==1 && int_Quantity != 0) {
                            wrapper = new QLWrapper(ql.SBQQ__ProductName__c, int_Quantity, rackRate, rackRate * ql.SBQQ__Quantity__c, ql.SBQQ__NetPrice__c, ql.SBQQ__NetTotal__c);
                            if (wrapper != null && ql != null) {
                                wrapper.notes = TemplateUtilities.escapeNotesString(ql.Notes__c);
                            }
                            oa360SupportMulti.add(1, eventName, wrapper);
                            showOA360SupportTable = single;
                        }
                        else if (ql.term__c ==2 && int_Quantity != NULL && int_Quantity <> 0) {
                            if (quote.Multiple_Years_Commitment__c ) {wrapper = new QLWrapper(ql.SBQQ__ProductName__c, int_Quantity, rackRate, rackRate * ql.SBQQ__Quantity__c, ql.SBQQ__NetPrice__c, ql.SBQQ__NetTotal__c);}
                                //wrapper = new QLWrapper(ql.SBQQ__ProductName__c, int_Quantity, rackRate, rackRate * int_Quantity, ql.SBQQ__NetPrice__c / int_Quantity, ql.SBQQ__NetPrice__c);}
                            if (wrapper != null && ql != null) {wrapper.notes = TemplateUtilities.escapeNotesString(ql.Notes__c);}
                            oa360SupportMulti.add(2, eventName, wrapper);
                            System.debug('oa360SupportMulti : '+oa360SupportMulti);
                        }
                        else if (ql.term__c ==3 && int_Quantity != NULL && int_Quantity <> 0) {
                            if (quote.Multiple_Years_Commitment__c ) {wrapper = new QLWrapper(ql.SBQQ__ProductName__c, int_Quantity, rackRate, rackRate * ql.SBQQ__Quantity__c, ql.SBQQ__NetPrice__c, ql.SBQQ__NetTotal__c);}
                                //wrapper = new QLWrapper(ql.SBQQ__ProductName__c, int_Quantity, rackRate, rackRate * int_Quantity, ql.SBQQ__NetPrice__c / int_Quantity, ql.SBQQ__NetPrice__c);}
                            if (wrapper != null && ql != null) {wrapper.notes = TemplateUtilities.escapeNotesString(ql.Notes__c);}
                            oa360SupportMulti.add(3, eventName, wrapper);
                        }
                        else if (ql.term__c ==4 && int_Quantity != NULL && int_Quantity <> 0) {
                            if (quote.Multiple_Years_Commitment__c ) {wrapper = new QLWrapper(ql.SBQQ__ProductName__c, int_Quantity, rackRate, rackRate * ql.SBQQ__Quantity__c, ql.SBQQ__NetPrice__c, ql.SBQQ__NetTotal__c);}
                                //wrapper = new QLWrapper(ql.SBQQ__ProductName__c, int_Quantity, rackRate, rackRate * int_Quantity, ql.SBQQ__NetPrice__c / int_Quantity, ql.SBQQ__NetPrice__c);}
                            if (wrapper != null && ql != null) {wrapper.notes = TemplateUtilities.escapeNotesString(ql.Notes__c);
                            }oa360SupportMulti.add(4, eventName, wrapper);
                        }
                        else if (ql.term__c ==5 && int_Quantity != NULL && int_Quantity <> 0) {
                            if (quote.Multiple_Years_Commitment__c ) {wrapper = new QLWrapper(ql.SBQQ__ProductName__c, int_Quantity, rackRate, rackRate * ql.SBQQ__Quantity__c, ql.SBQQ__NetPrice__c, ql.SBQQ__NetTotal__c);}
                                //wrapper = new QLWrapper(ql.SBQQ__ProductName__c, int_Quantity, rackRate, rackRate * int_Quantity, ql.SBQQ__NetPrice__c / int_Quantity, ql.SBQQ__NetPrice__c);}
                            if (wrapper != null && ql != null) {wrapper.notes = TemplateUtilities.escapeNotesString(ql.Notes__c);}
                            oa360SupportMulti.add(5, eventName, wrapper);
                        }
                        showOA360SupportTable = single;
                        if (wrapper != null && ql != null) {    //Added By Mohsin - Bug fix -- TICCM-625
                            wrapper.quantityOfOne = ql.SBQQ__Product__r.Quantity_of_One__c; 
                        }
                        System.debug('showOA360SupportTable : '+showOA360SupportTable);
                    }
                    
                    else if (ql.Contract_Output_Grouping__c == 'OA360 Equipment' && ql.SBQQ__EffectiveQuantity__c <> 0) {
                        Decimal rackRate;
                        rackRate = ql.Rack_Rate__c;
                        QLWrapper wrapper;
                        if (ql.term__c ==1 && int_Quantity != 0) {
                            wrapper = new QLWrapper(ql.SBQQ__ProductName__c, int_Quantity, rackRate, rackRate * ql.SBQQ__Quantity__c, ql.SBQQ__NetPrice__c, ql.SBQQ__NetTotal__c);
                            
                            if (wrapper != null && ql != null) {
                                wrapper.notes = TemplateUtilities.escapeNotesString(ql.Notes__c);
                            }
                            oa360EquipmentMulti.add(1, eventName, wrapper);
                            showOA360EquipmentTable = single;
                        }
                        else if (ql.term__c ==2 && int_Quantity != NULL  && int_Quantity <> 0) {
                            if (quote.Multiple_Years_Commitment__c ) {wrapper = new QLWrapper(ql.SBQQ__ProductName__c, int_Quantity, rackRate, rackRate * ql.SBQQ__Quantity__c, ql.SBQQ__NetPrice__c, ql.SBQQ__NetTotal__c);
                            } 
                            if (wrapper != null && ql != null) {wrapper.notes = TemplateUtilities.escapeNotesString(ql.Notes__c);
                            }
                            oa360EquipmentMulti.add(2, eventName, wrapper);
                            
                        }
                        else if (ql.term__c ==3 && int_Quantity != NULL && int_Quantity <> 0) {
                            if (quote.Multiple_Years_Commitment__c ) {wrapper = new QLWrapper(ql.SBQQ__ProductName__c, int_Quantity, rackRate, rackRate * ql.SBQQ__Quantity__c, ql.SBQQ__NetPrice__c, ql.SBQQ__NetTotal__c);
                            } 
                            if (wrapper != null && ql != null) {wrapper.notes = TemplateUtilities.escapeNotesString(ql.Notes__c);
                            }
                            oa360EquipmentMulti.add(3, eventName, wrapper);
                            
                        }
                        else if (ql.term__c ==4 && int_Quantity != NULL && int_Quantity <> 0) {
                            if (quote.Multiple_Years_Commitment__c ) {wrapper = new QLWrapper(ql.SBQQ__ProductName__c, int_Quantity, rackRate, rackRate * ql.SBQQ__Quantity__c, ql.SBQQ__NetPrice__c, ql.SBQQ__NetTotal__c);
                            } 
                            if (wrapper != null && ql != null) {wrapper.notes = TemplateUtilities.escapeNotesString(ql.Notes__c);
                            }
                            oa360EquipmentMulti.add(4, eventName, wrapper);
                            
                        }
                        else if (ql.term__c ==5 && int_Quantity != NULL && int_Quantity <> 0) {
                            if (quote.Multiple_Years_Commitment__c ) {wrapper = new QLWrapper(ql.SBQQ__ProductName__c, int_Quantity, rackRate, rackRate * ql.SBQQ__Quantity__c, ql.SBQQ__NetPrice__c, ql.SBQQ__NetTotal__c);
                            } 
                            if (wrapper != null && ql != null) {wrapper.notes = TemplateUtilities.escapeNotesString(ql.Notes__c);
                            }
                            oa360EquipmentMulti.add(5, eventName, wrapper);
                        }
                        wrapper.quantityOfOne = ql.SBQQ__Product__r.Quantity_of_One__c;
                        showOA360EquipmentTable = single;
                    }
                    
                    else if (ql.Contract_Output_Grouping__c == 'OA360 Supplies' && ql.SBQQ__EffectiveQuantity__c <> 0) {
                        Decimal rackRate;
                        rackRate = ql.Rack_Rate__c;
                        QLWrapper wrapper;
                        if (ql.term__c ==1 && int_Quantity != 0) { wrapper = new QLWrapper(ql.SBQQ__ProductName__c, int_Quantity, rackRate, rackRate * ql.SBQQ__Quantity__c, ql.SBQQ__NetPrice__c, ql.SBQQ__NetTotal__c);
                            if (wrapper != null && ql != null) {wrapper.notes = TemplateUtilities.escapeNotesString(ql.Notes__c);
                            }
                            oa360SuppliesMulti.add(1, eventName, wrapper);
                            showOA360Supplies = single;
                        }
                        else if (ql.term__c ==2 && int_Quantity != NULL && int_Quantity <> 0) {
                            if (quote.Multiple_Years_Commitment__c ) {wrapper = new QLWrapper(ql.SBQQ__ProductName__c, int_Quantity, rackRate, rackRate * ql.SBQQ__Quantity__c, ql.SBQQ__NetPrice__c, ql.SBQQ__NetTotal__c);
                            }
                            if (wrapper != null && ql != null) {wrapper.notes = TemplateUtilities.escapeNotesString(ql.Notes__c);
                            }
                            oa360SuppliesMulti.add(2, eventName, wrapper);
                            
                        }
                        else if (ql.term__c ==3 && int_Quantity != NULL && int_Quantity <> 0) {
                            if (quote.Multiple_Years_Commitment__c ) {wrapper = new QLWrapper(ql.SBQQ__ProductName__c, int_Quantity, rackRate, rackRate * ql.SBQQ__Quantity__c, ql.SBQQ__NetPrice__c, ql.SBQQ__NetTotal__c);
                            } 
                            if (wrapper != null && ql != null) {wrapper.notes = TemplateUtilities.escapeNotesString(ql.Notes__c);
                            }
                            oa360SuppliesMulti.add(3, eventName, wrapper);
                            
                        }
                        else if (ql.term__c ==4 && int_Quantity != NULL && int_Quantity <> 0) {
                            if (quote.Multiple_Years_Commitment__c ) {wrapper = new QLWrapper(ql.SBQQ__ProductName__c, int_Quantity, rackRate, rackRate * ql.SBQQ__Quantity__c, ql.SBQQ__NetPrice__c, ql.SBQQ__NetTotal__c);
                            }
                            if (wrapper != null && ql != null) {wrapper.notes = TemplateUtilities.escapeNotesString(ql.Notes__c);
                            }
                            oa360SuppliesMulti.add(4, eventName, wrapper);
                            
                        }
                        else if (ql.term__c ==5 && int_Quantity != NULL && int_Quantity <> 0) {
                            if (quote.Multiple_Years_Commitment__c ) {wrapper = new QLWrapper(ql.SBQQ__ProductName__c, int_Quantity, rackRate, rackRate * ql.SBQQ__Quantity__c, ql.SBQQ__NetPrice__c, ql.SBQQ__NetTotal__c);
                            }
                            if (wrapper != null && ql != null) {wrapper.notes = TemplateUtilities.escapeNotesString(ql.Notes__c);
                            }
                            oa360SuppliesMulti.add(5, eventName, wrapper);
                        }
                        wrapper.quantityOfOne = ql.SBQQ__Product__r.Quantity_of_One__c;
                        showOA360Supplies = single;
                    }
                    
                    else if ((ql.Contract_Output_Grouping__c == 'OA 360 Software' || ql.Contract_Output_Grouping__c == 'Event Cloud' ) && ql.SBQQ__EffectiveQuantity__c <> 0) {
                        Decimal rackRate;
                        rackRate = ql.Rack_Rate__c;
                        QLWrapper wrapper;
                        String str_productCode = ql.SBQQ__ProductCode__c;
                        

                        
                        if (ql.term__c == 1 &&  (str_productCode.startsWith('CV-SW-EC-EVT-OAPREM') || int_Quantity <> 0 || ql.SBQQ__ProductCode__c == 'CV-SW-EC-OSS-OA360(OSS)') ) {
                            if (ql.SBQQ__ProductCode__c != 'CV-SW-EC-OSS-OA360(OSS)' ) {
                                rackRate = 0;
                                if (ql.SBQQ__ListPrice__c != NULL && ql.SBQQ__ListPrice__c <> 0 && int_Quantity <> 0) {
                                    rackRate = ql.Rack_Rate__c;
                                }
                                if(rackRate == 0.00 && (ql.totalRollupPrice__c != null && ql.Rollup_Price__c != null)){rackRate = ql.Rollup_Price__c;wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Rollup_Quantity__c, rackRate, rackRate * ql.SBQQ__Quantity__c,  rackRate, ql.totalRollupPrice__c);}       
                                else
                                {
                                    wrapper = new QLWrapper(ql.SBQQ__ProductName__c, int_Quantity, rackRate, rackRate * ql.SBQQ__Quantity__c, ql.SBQQ__NetPrice__c, ql.SBQQ__NetTotal__c);
                                }
                            } 
                            else {wrapper = new QLWrapper(ql.SBQQ__ProductName__c, int_Quantity, rackRate, rackRate * ql.SBQQ__Quantity__c, ql.SBQQ__NetPrice__c, ql.SBQQ__NetTotal__c);if(wrapper.quantity == 0) { wrapper = NULL;}
                                //wrapper = aggregateOA360(ql, 1, quoteLines, eventName);if(wrapper.quantity == 0) { wrapper = NULL;}
                            }

                            if (wrapper != null && ql != null) {
                                wrapper.notes = TemplateUtilities.escapeNotesString(ql.Notes__c);
                            }
                            if (wrapper != NULL) {
                                if(ql.term__c == 1){
                                      oa360SoftwareMulti.add(1, eventName, wrapper);                                    
                                }
                            }
                            showOA360Software = single;
                        }
                        else if (ql.term__c ==2 && (quote.Multiple_Years_Commitment__c || quote.HC_Logo_Conditional_Print__c == 'true') && (str_productCode.startsWith('CV-SW-EC-EVT-OAPREM') || int_Quantity <> 0 || ql.SBQQ__ProductCode__c == 'CV-SW-EC-OSS-OA360(OSS)')) {
                            
                            if (ql.SBQQ__ProductCode__c != 'CV-SW-EC-OSS-OA360(OSS)' ) {
                                if (ql.SBQQ__ListPrice__c <> NULL && ql.SBQQ__ListPrice__c <> 0) {
                                    rackRate = ql.Rack_Rate__c;
                                }
                                wrapper = new QLWrapper(ql.SBQQ__ProductName__c, int_Quantity, rackRate, rackRate * ql.SBQQ__Quantity__c, ql.SBQQ__NetPrice__c, ql.SBQQ__NetTotal__c);
                            } else {
                                wrapper = new QLWrapper(ql.SBQQ__ProductName__c, int_Quantity, rackRate, rackRate * ql.SBQQ__Quantity__c, ql.SBQQ__NetPrice__c, ql.SBQQ__NetTotal__c);
                                //wrapper = aggregateOA360(ql, 2, quoteLines, eventName);
                                if(wrapper.quantity == 0) {
                                    wrapper = NULL;
                                }
                            }
                            if (wrapper != null && ql != null) {
                                wrapper.notes = TemplateUtilities.escapeNotesString(ql.Notes__c);
                            }
                            if (wrapper != NULL) {
                                oa360SoftwareMulti.add(2, eventName, wrapper);
                            }
                        }
                        else if (ql.term__c ==3  && (quote.Multiple_Years_Commitment__c || quote.HC_Logo_Conditional_Print__c == 'true') && (str_productCode.startsWith('CV-SW-EC-EVT-OAPREM') || int_Quantity <> 0 || ql.SBQQ__ProductCode__c == 'CV-SW-EC-OSS-OA360(OSS)')) {
                            if (ql.SBQQ__ProductCode__c != 'CV-SW-EC-OSS-OA360(OSS)' ) {
                                if (ql.SBQQ__ListPrice__c <> NULL && ql.SBQQ__ListPrice__c <> 0) {
                                    rackRate = ql.Rack_Rate__c;
                                }
                                wrapper = new QLWrapper(ql.SBQQ__ProductName__c, int_Quantity, rackRate, rackRate * ql.SBQQ__Quantity__c, ql.SBQQ__NetPrice__c, ql.SBQQ__NetTotal__c);
                            } else {
                                wrapper = new QLWrapper(ql.SBQQ__ProductName__c, int_Quantity, rackRate, rackRate * ql.SBQQ__Quantity__c, ql.SBQQ__NetPrice__c, ql.SBQQ__NetTotal__c);
                                //wrapper = aggregateOA360(ql, 3, quoteLines, eventName);
                                if(wrapper.quantity == 0) {
                                    wrapper = NULL;
                                }
                            }
                            if (wrapper != null && ql != null) {
                                wrapper.notes = TemplateUtilities.escapeNotesString(ql.Notes__c);
                            }
                            if (wrapper != NULL) {
                                oa360SoftwareMulti.add(3, eventName, wrapper);
                            }
                        }
                        else if (ql.term__c ==4  && (quote.Multiple_Years_Commitment__c || quote.HC_Logo_Conditional_Print__c == 'true') && (str_productCode.startsWith('CV-SW-EC-EVT-OAPREM') || int_Quantity <> 0 || ql.SBQQ__ProductCode__c == 'CV-SW-EC-OSS-OA360(OSS)')) {
                            if (ql.SBQQ__ProductCode__c != 'CV-SW-EC-OSS-OA360(OSS)' ) {
                                //rackRate = 0;
                                if (ql.SBQQ__ListPrice__c <> NULL && ql.SBQQ__ListPrice__c <> 0) {
                                    rackRate = ql.Rack_Rate__c;
                                }
                                wrapper = new QLWrapper(ql.SBQQ__ProductName__c, int_Quantity, rackRate, rackRate * ql.SBQQ__Quantity__c, ql.SBQQ__NetPrice__c, ql.SBQQ__NetTotal__c);
                            } else {
                                wrapper = new QLWrapper(ql.SBQQ__ProductName__c, int_Quantity, rackRate, rackRate * ql.SBQQ__Quantity__c, ql.SBQQ__NetPrice__c, ql.SBQQ__NetTotal__c);
                                //wrapper = aggregateOA360(ql, 4, quoteLines, eventName);
                                if(wrapper.quantity == 0) {
                                    wrapper = NULL;
                                }
                            }
                            if (wrapper != null && ql != null) {
                                wrapper.notes = TemplateUtilities.escapeNotesString(ql.Notes__c);
                            }
                            if (wrapper != NULL) {
                                oa360SoftwareMulti.add(4, eventName, wrapper);
                            }
                        }
                        else if (ql.term__c ==5 && (quote.Multiple_Years_Commitment__c || quote.HC_Logo_Conditional_Print__c == 'true') && (str_productCode.startsWith('CV-SW-EC-EVT-OAPREM') || int_Quantity <> 0 || ql.SBQQ__ProductCode__c == 'CV-SW-EC-OSS-OA360(OSS)')) {
                            if (ql.SBQQ__ProductCode__c != 'CV-SW-EC-OSS-OA360(OSS)' ) {
                                //rackRate = 0;
                                if (ql.SBQQ__ListPrice__c <> NULL && ql.SBQQ__ListPrice__c <> 0) {
                                    rackRate = ql.Rack_Rate__c;
                                }
                                wrapper = new QLWrapper(ql.SBQQ__ProductName__c, int_Quantity, rackRate, rackRate * int_Quantity, ql.SBQQ__NetPrice__c / int_Quantity, ql.SBQQ__NetPrice__c);
                            } else {
                                wrapper = new QLWrapper(ql.SBQQ__ProductName__c, int_Quantity, rackRate, rackRate * int_Quantity, ql.SBQQ__NetPrice__c / int_Quantity, ql.SBQQ__NetPrice__c);
                                //wrapper = aggregateOA360(ql, 5, quoteLines, eventName);
                                if(wrapper.quantity == 0) {
                                    wrapper = NULL;
                                }
                            }
                            if (wrapper != null && ql != null) {
                                wrapper.notes = TemplateUtilities.escapeNotesString(ql.Notes__c);
                                wrapper.quantity = int_Quantity;
                            }
                            if (wrapper != NULL) {
                                oa360SoftwareMulti.add(5, eventName, wrapper);
                            }
                        }
                        if (wrapper != null && ql != null) {
                            wrapper.quantityOfOne = ql.SBQQ__Product__r.Quantity_of_One__c;
                        }
                    }
                    
                    else if (ql.Contract_Output_Grouping__c == 'Software Platform' && ql.SBQQ__EffectiveQuantity__c <> 0) {
                        Decimal rackRate;
                        rackRate = ql.Rack_Rate__c;
                        QLWrapper wrapper;
                        if (ql.term__c ==1 && int_Quantity != 0) {
                            wrapper = new QLWrapper(ql.SBQQ__ProductName__c, int_Quantity, rackRate, rackRate * ql.SBQQ__Quantity__c, ql.SBQQ__NetPrice__c, ql.SBQQ__NetTotal__c);
                            if (wrapper != null && ql != null) {
                                wrapper.notes = TemplateUtilities.escapeNotesString(ql.Notes__c);
                            }
                            oa360SWPlatformMulti.add(1, eventName, wrapper);
                            showOA360SoftwarePlatform = single;
                        }
                        else if (ql.term__c ==2 && int_Quantity != NULL && int_Quantity <> 0) {
                            if (int_Quantity != NULL && quote.Multiple_Years_Commitment__c) {
                                //wrapper = new QLWrapper(ql.SBQQ__ProductName__c, int_Quantity, rackRate, rackRate * int_Quantity, ql.SBQQ__NetPrice__c / int_Quantity, ql.SBQQ__NetPrice__c);
                                wrapper = new QLWrapper(ql.SBQQ__ProductName__c, int_Quantity, rackRate, rackRate * ql.SBQQ__Quantity__c, ql.SBQQ__NetPrice__c, ql.SBQQ__NetTotal__c);
                            } else {
                                wrapper = wrapper.clone();
                            }
                            if (wrapper != null && ql != null) {
                                wrapper.notes = TemplateUtilities.escapeNotesString(ql.Notes__c);
                            }
                            oa360SWPlatformMulti.add(2, eventName, wrapper);
                        }
                        else if (ql.term__c ==3 && int_Quantity != NULL && int_Quantity <> 0) {
                            if (int_Quantity > 0 && quote.Multiple_Years_Commitment__c) {
                                //wrapper = new QLWrapper(ql.SBQQ__ProductName__c, int_Quantity, rackRate, rackRate * int_Quantity, ql.SBQQ__NetPrice__c / int_Quantity, ql.SBQQ__NetPrice__c);
                                wrapper = new QLWrapper(ql.SBQQ__ProductName__c, int_Quantity, rackRate, rackRate * ql.SBQQ__Quantity__c, ql.SBQQ__NetPrice__c, ql.SBQQ__NetTotal__c);
                            } else {
                                wrapper = wrapper.clone();
                            }
                            oa360SWPlatformMulti.add(3, eventName, wrapper);
                           // //////System.debug('OA360: oa360SWPlatformMulti adding wrapper to eventName: ' + eventName + ' for year: 3');
                            if (wrapper != null && ql != null) {
                                wrapper.notes = TemplateUtilities.escapeNotesString(ql.Notes__c);
                            }
                        }
                        else if (ql.term__c ==4 && int_Quantity != NULL && int_Quantity <> 0) {
                            if (quote.Multiple_Years_Commitment__c ) {
                                //wrapper = new QLWrapper(ql.SBQQ__ProductName__c, int_Quantity, rackRate, rackRate * int_Quantity, ql.SBQQ__NetPrice__c / int_Quantity, ql.SBQQ__NetPrice__c);
                                wrapper = new QLWrapper(ql.SBQQ__ProductName__c, int_Quantity, rackRate, rackRate * ql.SBQQ__Quantity__c, ql.SBQQ__NetPrice__c, ql.SBQQ__NetTotal__c);
                            } else {
                                wrapper = wrapper.clone();
                            }
                            if (wrapper != null && ql != null) {
                                wrapper.notes = TemplateUtilities.escapeNotesString(ql.Notes__c);
                            }
                            oa360SWPlatformMulti.add(4, eventName, wrapper);
                        }
                        else if (ql.term__c ==5 && int_Quantity != NULL && int_Quantity <> 0) {
                            if (quote.Multiple_Years_Commitment__c) {
                                //wrapper = new QLWrapper(ql.SBQQ__ProductName__c, int_Quantity, rackRate, rackRate * int_Quantity, ql.SBQQ__NetPrice__c / int_Quantity, ql.SBQQ__NetPrice__c);
                                wrapper = new QLWrapper(ql.SBQQ__ProductName__c, int_Quantity, rackRate, rackRate * ql.SBQQ__Quantity__c, ql.SBQQ__NetPrice__c, ql.SBQQ__NetTotal__c);
                            } else {
                                wrapper = wrapper.clone();
                            }
                            if (wrapper != null && ql != null) {
                                wrapper.notes = TemplateUtilities.escapeNotesString(ql.Notes__c);
                            }
                            oa360SWPlatformMulti.add(5, eventName, wrapper);
                        }
                        wrapper.quantityOfOne = ql.SBQQ__Product__r.Quantity_of_One__c; 
                        showOA360SoftwarePlatform = single;
                    }
                }
                
                QLWrapper wrapper;
                if(int_Quantity <> 0 && ql.Overage_Fee__c != NULL && ql.Overage_Fee__c > 0)
                {
                    if(quote.Contract_Remaining_Term__c > 1 && !quote.Multiple_Years_Commitment__c && ql.term__c == 1 && quote.HC_Logo_Conditional_Print__c == 'true')
                    {
                        for (QLTable table : eventTable.QLTables) 
                        {
                            for (QLTable tab : overagesTable.QLTables) {
                                if (tab.year == table.year) { 
                                    tab.quoteLines.add(new QLWrapper(ql.SBQQ__ProductName__c, ql.Overage_Fee__c)); 
                                }
                            }
                        }
                    }
                    else if((!quote.Multiple_Years_Commitment__c && !ql.SBQQ__Optional__c ) || quote.Multiple_Years_Commitment__c)
                    {
                        if (ql.term__c ==1 && int_Quantity <> 0 && ql.Overage_Fee__c != NULL && ql.Overage_Fee__c > 0) {
                            wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Overage_Fee__c);
                            overagesTable.add(1, wrapper);
                        }
                        else if (ql.term__c ==2  && quote.Multiple_Years_Commitment__c  && int_Quantity <> 0 && ql.Overage_Fee__c != NULL && ql.Overage_Fee__c > 0) {
                            wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Overage_Fee__c);
                           overagesTable.add(2, wrapper);
                        }
                        else if (ql.term__c ==3  && quote.Multiple_Years_Commitment__c  && int_Quantity <> 0 && ql.Overage_Fee__c != NULL && ql.Overage_Fee__c > 0) {
                            wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Overage_Fee__c);
                            overagesTable.add(3, wrapper);
                        }
                        else if (ql.term__c ==4  && quote.Multiple_Years_Commitment__c && int_Quantity <> 0 && ql.Overage_Fee__c != NULL && ql.Overage_Fee__c > 0) {
                            wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Overage_Fee__c);
                            overagesTable.add(4, wrapper);
                        }
                        else if (ql.term__c ==5  && quote.Multiple_Years_Commitment__c && int_Quantity <> 0 && ql.Overage_Fee__c != NULL && ql.Overage_Fee__c > 0) {
                            wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Overage_Fee__c);
                            overagesTable.add(5, wrapper);
                        }
                    } 
                    if (wrapper != null && ql != null) {
                        wrapper.quantityOfOne = ql.SBQQ__Product__r.Quantity_of_One__c;
                    }
                }
                //Added By Mohsin
                if(Boolean.valueOf(Label.OAPOverage))
                {
                    if((int_Quantity <> 0 || ql.Rollup_Quantity__c <> 0) && ql.SBQQ__ProductCode__c == 'CV-SW-EC-EVT-OAPREM')
                    {
                        Decimal rollUpOverageFee = 0.0;
                        for(SBQQ__QuoteLine__c subQuoteLine : ql.SBQQ__Quote_Lines__r)
                        {
                            if(subQuoteLine.Overage_Fee__c != NULL && subQuoteLine.SBQQ__EffectiveQuantity__c <> 0)
                                rollUpOverageFee = (subQuoteLine.Overage_Fee__c * subQuoteLine.SBQQ__EffectiveQuantity__c) + rollUpOverageFee;
                        }
                        System.debug('rollUpOverageFee>>>>'+rollUpOverageFee);
                        if(rollUpOverageFee <> 0)
                        {
                            if(quote.Contract_Remaining_Term__c > 1 && !quote.Multiple_Years_Commitment__c && ql.term__c == 1 && quote.HC_Logo_Conditional_Print__c == 'true')
                            {
                                for (QLTable table : eventTable.QLTables) 
                                {
                                    for (QLTable tab : overagesTable.QLTables) {
                                        if (tab.year == table.year) { 
                                            tab.quoteLines.add(new QLWrapper(ql.SBQQ__ProductName__c, rollUpOverageFee/ql.Rollup_Quantity__c)); 
                                        }
                                    }
                                }
                            }
                            else if((!quote.Multiple_Years_Commitment__c && !ql.SBQQ__Optional__c ) || quote.Multiple_Years_Commitment__c)
                            {
                                if (ql.term__c ==1 && (int_Quantity <> 0 || ql.Rollup_Quantity__c <> 0) && rollUpOverageFee != NULL && rollUpOverageFee > 0) {
                                    wrapper = new QLWrapper(ql.SBQQ__ProductName__c, rollUpOverageFee/ql.Rollup_Quantity__c);
                                    overagesTable.add(1, wrapper);
                                }
                                else if (ql.term__c ==2  && quote.Multiple_Years_Commitment__c  && (int_Quantity <> 0 || ql.Rollup_Quantity__c <> 0) && rollUpOverageFee != NULL && rollUpOverageFee > 0) {
                                    wrapper = new QLWrapper(ql.SBQQ__ProductName__c, rollUpOverageFee/ql.Rollup_Quantity__c);
                                    overagesTable.add(2, wrapper);
                                }
                                else if (ql.term__c ==3  && quote.Multiple_Years_Commitment__c  && (int_Quantity <> 0 || ql.Rollup_Quantity__c <> 0) && rollUpOverageFee != NULL && rollUpOverageFee > 0) {
                                    wrapper = new QLWrapper(ql.SBQQ__ProductName__c, rollUpOverageFee/ql.Rollup_Quantity__c);
                                    overagesTable.add(3, wrapper);
                                }
                                else if (ql.term__c ==4  && quote.Multiple_Years_Commitment__c && (int_Quantity <> 0 || ql.Rollup_Quantity__c <> 0) && rollUpOverageFee != NULL && rollUpOverageFee > 0) {
                                    wrapper = new QLWrapper(ql.SBQQ__ProductName__c, rollUpOverageFee/ql.Rollup_Quantity__c);
                                    overagesTable.add(4, wrapper);
                                }
                                else if (ql.term__c ==5  && quote.Multiple_Years_Commitment__c && (int_Quantity <> 0 || ql.Rollup_Quantity__c <> 0) && rollUpOverageFee != NULL && rollUpOverageFee > 0) {
                                    wrapper = new QLWrapper(ql.SBQQ__ProductName__c, rollUpOverageFee/ql.Rollup_Quantity__c);
                                    overagesTable.add(5, wrapper);
                                }
                            } 
                            if (wrapper != null && ql != null) {
                                wrapper.quantityOfOne = ql.SBQQ__Product__r.Quantity_of_One__c;
                            }
                        }
                    }
                }
                
                /* Event summary */
                Decimal rackRate;
                Decimal quantity = ql.SBQQ__Quantity__c;
                
                
                Decimal effectiveQuantity = int_Quantity;
                Decimal netPrice = ql.SBQQ__NetPrice__c;
                Decimal netTotal = ql.SBQQ__NetTotal__c;
                System.debug('effectiveQuantity before>>>'+effectiveQuantity);
                if(ql.SBQQ__PricingMethod__c == 'Block' && netPrice < 0) {effectiveQuantity = -1 * effectiveQuantity; netPrice = Math.abs(netPrice);}
                if(ql.SBQQ__DiscountScheduleType__c == 'Slab') {effectiveQuantity = ql.SBQQ__Quantity__c;if(ql.SBQQ__PriorQuantity__c > 0) {effectiveQuantity = ql.SBQQ__Quantity__c - ql.SBQQ__PriorQuantity__c;}netPrice = Math.abs(netPrice / effectiveQuantity);rackRate = rackRate / effectiveQuantity;}
                if(((!quote.Multiple_Years_Commitment__c && !ql.SBQQ__Optional__c ) || quote.Multiple_Years_Commitment__c))
                 {//aggregateCrowdCompass
                    System.debug('effectiveQuantity after>>>'+effectiveQuantity);
                    if (effectiveQuantity <> 0 || productCodes.containsKey(ql.SBQQ__ProductCode__c)) {
                    System.debug('aggregate crowd compass condition');
                        if (ql.term__c ==1) {
                            if (!productCodes.containsKey(ql.SBQQ__ProductCode__c)) {
                                rackRate = 0;
                                rackRate = (ql.Rack_Rate__c);
                                //wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.SBQQ__EffectiveQuantity__c, rackRate, rackRate * ql.SBQQ__Quantity__c, ql.SBQQ__NetPrice__c, ql.SBQQ__NetTotal__c, rackRate * ql.SBQQ__EffectiveQuantity__c - ql.SBQQ__NetTotal__c);
                                wrapper = new QLWrapper(ql.SBQQ__ProductName__c, effectiveQuantity, rackRate, rackRate * quantity, netPrice, netTotal, rackRate * ql.SBQQ__EffectiveQuantity__c - netTotal);

                            } else {
                                System.debug('aggregate crowd compass for term 1');
                                System.debug('ql.productcode='+ql.SBQQ__ProductCode__c);
                                wrapper = aggregateCrowdCompass(ql, 1, quoteLines);
                                
                            }
                            if (wrapper != null && ql != null) {
                                wrapper.notes = TemplateUtilities.escapeNotesString(ql.Notes__c);
                            }
                            if (wrapper != NULL && wrapper.quantity != 0) {
                                eventTable.add(1, wrapper);
                            }
                        }
                        else if (ql.term__c ==2 && effectiveQuantity != NULL && (quote.Multiple_Years_Commitment__c || quote.Current_Year__c == 2)) {
                            if (!productCodes.containsKey(ql.SBQQ__ProductCode__c)) {
                                rackRate =( ql.Rack_Rate__c);
                                
                                wrapper = new QLWrapper(ql.SBQQ__ProductName__c, effectiveQuantity, rackRate, rackRate * quantity, netPrice, netTotal, rackRate * ql.SBQQ__EffectiveQuantity__c - netTotal);
                            } else {wrapper = aggregateCrowdCompass(ql, 2, quoteLines);}
                            if (wrapper != null && ql != null) {
                                wrapper.notes = TemplateUtilities.escapeNotesString(ql.Notes__c);
                            }
                            if (wrapper != NULL && wrapper.quantity != 0) {
                                eventTable.add(2, wrapper);
                            }
                        }
                        else if (ql.term__c ==3 && effectiveQuantity != NULL  && (quote.Multiple_Years_Commitment__c || quote.Current_Year__c == 3) ) {
                            if (!productCodes.containsKey(ql.SBQQ__ProductCode__c)) {
                                rackRate = (ql.Rack_Rate__c);

                                wrapper = new QLWrapper(ql.SBQQ__ProductName__c, effectiveQuantity, rackRate, rackRate * quantity, netPrice, netTotal, rackRate * ql.SBQQ__EffectiveQuantity__c - netTotal);
                                
                            } else {
                                wrapper = aggregateCrowdCompass(ql, 3, quoteLines);
                            }
                            if (wrapper != null && ql != null) {
                                wrapper.notes = TemplateUtilities.escapeNotesString(ql.Notes__c);
                            }
                            if (wrapper != NULL && wrapper.quantity != 0) {
                                eventTable.add(3, wrapper);
                            }
                        }
                        else if (ql.term__c ==4 && effectiveQuantity != NULL && (quote.Multiple_Years_Commitment__c || quote.Current_Year__c == 4) ) {
                            if (!productCodes.containsKey(ql.SBQQ__ProductCode__c)) {
                                rackRate = (ql.Rack_Rate__c);

                                wrapper = new QLWrapper(ql.SBQQ__ProductName__c, effectiveQuantity, rackRate, rackRate * quantity, netPrice, netTotal, rackRate * ql.SBQQ__EffectiveQuantity__c - netTotal);
                            } else {
                                wrapper = aggregateCrowdCompass(ql, 4, quoteLines);
                            }
                            if (wrapper != null && ql != null) {
                                wrapper.notes = TemplateUtilities.escapeNotesString(ql.Notes__c);
                            }
                            if (wrapper != NULL && wrapper.quantity != 0) {
                                eventTable.add(4, wrapper);
                            }
                        }
                        else if (ql.term__c ==5 && effectiveQuantity != NULL && (quote.Multiple_Years_Commitment__c || quote.Current_Year__c == 5) ) {
                            if (!productCodes.containsKey(ql.SBQQ__ProductCode__c)) 
                            {
                                rackRate = (ql.Rack_Rate__c);
                                wrapper = new QLWrapper(ql.SBQQ__ProductName__c, effectiveQuantity, rackRate, rackRate * quantity, netPrice, netTotal, rackRate * ql.SBQQ__EffectiveQuantity__c - netTotal);
                            } else {
                                wrapper = aggregateCrowdCompass(ql, 5, quoteLines);
                            }
                            if (wrapper != null && ql != null) {
                                wrapper.notes = TemplateUtilities.escapeNotesString(ql.Notes__c);
                            }
                            if (wrapper != NULL && wrapper.quantity != 0) {
                                eventTable.add(5, wrapper);
                            }
                        }
                        if (wrapper != null && ql != null) {
                            wrapper.quantityOfOne = ql.SBQQ__Product__r.Quantity_of_One__c;
                        }
                    }
                }
                if (effectiveQuantity <> 0) {
                    showEventTable = single;
                }
                /* End of Event summary */
            }
        }        
        
        System.debug('socialTable>>>>'+socialTable.QLTables);
        if (quote.Multiple_Years_Commitment__c || (quote.HC_Logo_Conditional_Print__c == 'true' && quote.Contract_Remaining_Term__c>1)) {
            eventTable.addHeaders(quote);
            listingAdsTable.addHeaders(quote);
            bundleAdsTable.addHeaders(quote);
            passkeyTable.addHeaders(quote);
            emiTable.addHeaders(quote);
            regOnlineTable.addHeaders(quote);
            suggestedAdsTable.addHeaders(quote);
            reportingTable.addHeaders(quote);
            videoRetargetingTable.addHeaders(quote);
            oa360support.addHeaders(quote);
            oa360Equipment.addHeaders(quote);
            oa360Supplies.addHeaders(quote);
            oa360Software.addHeaders(quote);
            oa360SoftwarePlatform.addHeaders(quote);
            overagesTable.addHeaders(quote);
            socialTable.addHeaders(quote);
            /*oa360SupportMulti.addHeaders(quote);
            oa360EquipmentMulti.addHeaders(quote);
            oa360SuppliesMulti.addHeaders(quote);
            oa360SoftwareMulti.addHeaders(quote);
            oa360SWPlatformMulti.addHeaders(quote);
            */
            
        }
        eventTable.recalculate();
        if (quote.Count_of_HC_Products__c > 0) {
            showHcSummaryTable = single;
            showEventTable = empty;
            showEventNoPriceTable = empty;
        } else {
            if (quote.Count_of_RegOnline_Products__c == 0 && quote.OnArrival_360_Quote__c == FALSE && quote.Count_of_EC_Products__c>0) {
                if (quote.Hide_Unit_Prices_on_Contract__c) {showHcSummaryTable = empty; showEventTable = empty;showEventNoPriceTable = single;} else {showHcSummaryTable = empty;showEventTable = single;showEventNoPriceTable = empty;}
            } 
            else {showHcSummaryTable = empty;showEventTable = empty;showEventNoPriceTable = empty;}//showEventTable = quote.Count_of_EC_Products__c>0 ? single: empty;
        }
        if(quote.OnArrival_360_Quote__c){if (quote.Hide_Unit_Prices_on_Contract__c) {showOA360NoPrices = single;} else {showOA360 = single;}
        }
        if (overagesTable.getSize() > 0) {
            showOveragesTable = single;
        }
        listingAdsTable.recalculate();
        bundleAdsTable.recalculate();
        passkeyTable.recalculate();
        emiTable.recalculate();
        regOnlineTable.recalculate();
        suggestedAdsTable.recalculate();
        reportingTable.recalculate();
        videoRetargetingTable.recalculate();
        merchantTable.recalculate();
        onDemandTable.recalculate();
        professionalServicesTable.recalculate();
        oa360support.recalculate();
        oa360Equipment.recalculate();
        oa360Supplies.recalculate();
        oa360Software.recalculate();
        oa360SoftwarePlatform.recalculate();
        overagesTable.recalculate();
        oa360SupportMulti.recalculate();
        oa360EquipmentMulti.recalculate();
        oa360SuppliesMulti.recalculate();
        oa360SoftwareMulti.recalculate();
        oa360SWPlatformMulti.recalculate();
        
        convenienceFee = aggregateConvenienceFee(quoteLines);
        if(quote.Contract_Remaining_Term__c >= 1 )
        {
            System.debug('eventTable>>'+eventTable);
            createHCSummaryTable(eventTable, convenienceFee);
            if (quote.Contract_Remaining_Term__c > 1) 
            {
                hcSummaryTable.addHeaders(quote);
            }
        }
        hcSummaryTable.recalculate();
        socialTable.recalculate();
        aggregateOA360EventsTotals();
    }
    
    public void aggregateOA360EventsTotals() {
        for (String eventName : oa360eventsMap.keySet()) {
            oa360eventsMap.get(eventName).addToTotal(oa360SupportMulti.eventLinesMap.get(eventName).getTotal());
            oa360eventsMap.get(eventName).addToTotal(oa360EquipmentMulti.eventLinesMap.get(eventName).getTotal());
            oa360eventsMap.get(eventName).addToTotal(oa360SuppliesMulti.eventLinesMap.get(eventName).getTotal());
            oa360eventsMap.get(eventName).addToTotal(oa360SoftwareMulti.eventLinesMap.get(eventName).getTotal());
            oa360eventsMap.get(eventName).addToTotal(oa360SWPlatformMulti.eventLinesMap.get(eventName).getTotal());
            oa360eventsMap.get(eventName).addtoSize(oa360SupportMulti.eventLinesMap.get(eventName).getSize());
            oa360eventsMap.get(eventName).addtoSize(oa360EquipmentMulti.eventLinesMap.get(eventName).getSize());
            oa360eventsMap.get(eventName).addtoSize(oa360SuppliesMulti.eventLinesMap.get(eventName).getSize());
            oa360eventsMap.get(eventName).addtoSize(oa360SoftwareMulti.eventLinesMap.get(eventName).getSize());
            oa360eventsMap.get(eventName).addtoSize(oa360SWPlatformMulti.eventLinesMap.get(eventName).getSize());
            
        }
    }
    
    public void createHCSummaryTable(MultiYearQLTable eventTable, Decimal convenienceFee) {
        
        Integer tempInt = 0;
        Boolean strikeThrough = false;
        if (quote.Multiple_Years_Commitment__c) 
        {
            for (QLTable table : eventTable.QLTables) 
            {
                for (QLTable tab : hcSummaryTable.QLTables) {
                    if (tab.year == table.year) {
                        if(table.savingsTotal> 0){strikeThrough = true;}
                        tab.quoteLines.add(new QLWrapper('Total Price', table.rackTotal, strikeThrough));
                        tab.quoteLines.add(new QLWrapper('Discount', table.savingsTotal));
                        if (convenienceFee > 0) {tab.quoteLines.add(new QLWrapper('Covenience Fee', convenienceFee));}
                        tab.quoteLines.add(new QLWrapper('Total Fees Payable in ' +currencySymbol, table.linesTotal)); 

                    }
                }
            }
        }
        else
        {
            for (QLTable table : eventTable.QLTables) 
            {
                for (QLTable tab : hcSummaryTable.QLTables) {
                        if(table.savingsTotal> 0){strikeThrough = true;}
                        tab.quoteLines.add(new QLWrapper('Total Price', table.rackTotal, strikeThrough));
                        tab.quoteLines.add(new QLWrapper('Discount', table.savingsTotal));
                        if (convenienceFee > 0) {tab.quoteLines.add(new QLWrapper('Convenience Fee', convenienceFee));}
                        tab.quoteLines.add(new QLWrapper('Total Fees Payable in ' +currencySymbol, table.linesTotal)); 
                }
            }
        }



    }
    Decimal aggregateConvenienceFee(List<SBQQ__QuoteLine__c> quoteLines) {
        
        Decimal result = 0;
        
        for (SBQQ__QuoteLine__c ql : quoteLines) {
            if (ql.SBQQ__ProductCode__c == 'CV-AD-HC-CSN-CONV') {result += ql.SBQQ__NetTotal__c;}   //Replaced SKU - Requested By Lauren --- OLD SKU --->>> CV-OT-HC-CSN-CVNCFEE
        }
        
        return result;
    }
    
    
    public static QLWrapper aggregateCrowdCompass(SBQQ__QuoteLine__c quoteLine, Decimal year, List<SBQQ__QuoteLine__c> quoteLines) {
        QLWrapper result = new QLWrapper(quoteLine.SBQQ__ProductName__c);
        
        Decimal totalQuantity = 0;
        Decimal totalRackRate = 0;
        Decimal totalPrice = 0;
        Decimal discountRate = 0;
        System.debug('quotelines---'+quoteLines.size());
        for (SBQQ__QuoteLine__c ql : quoteLines) {
            Decimal int_Quantity = 0;
            if(ql.SBQQ__Product__r.Show_True_Quantity__c){int_Quantity = ql.SBQQ__Quantity__c;}
            else
            {
                int_Quantity = ql.SBQQ__EffectiveQuantity__c;
            }
            
            /*      
                if (ql.SBQQ__RequiredBy__c == quoteLine.Id && ( ql.SBQQ__ProductCode__c.startsWith('CV-SW-EC-CC-CCMBAP') || ql.SBQQ__ProductCode__c.startsWith('CV-SW-EC-EVT-OAPREM') || ql.SBQQ__ProductCode__c.startsWith('CV-PS-HC-SCT-A') || ql.SBQQ__ProductCode__c.startsWith('CV-SW-HC-SCT-EVNTSLSSTN')|| ql.SBQQ__ProductCode__c.startsWith('CV-SW-HC-SCT-EVNTSRVCSSTN') || ql.SBQQ__ProductCode__c.startsWith('CV-SW-HC-SCT-EVNTSRVCSDGRMM') || ql.SBQQ__ProductCode__c.startsWith('CV-PS-HC-SCT-PHTREAL3DF'))) {//( ql.SBQQ__ProductCode__c.startsWith('CV-SW-EC-CC-CCMBAP') || ql.SBQQ__ProductCode__c.startsWith('CV-SW-EC-EVT-OAPREM'))  
                
                *****Commented Above Line and Added a method in the below line to check the productcode dynamically*****
                ***** Added By Mohsin*****
                *****Date - 11th Sept 2019*****
            */
                if (ql.SBQQ__RequiredBy__c == quoteLine.Id && startsWithCustom(ql.SBQQ__ProductCode__c)) {
                if (year == 1) {
                    totalQuantity += int_Quantity;
                    totalRackRate += int_Quantity * ql.Rack_Rate__c;
                    totalPrice += ql.SBQQ__NetTotal__c;
                } else if (year == 2) {
                    totalQuantity += int_Quantity;
                    totalRackRate += int_Quantity * ql.Rack_Rate__c;
                    totalPrice += ql.SBQQ__NetTotal__c;
                } else if (year == 3) {
                    totalQuantity += int_Quantity;
                    totalRackRate += int_Quantity * ql.Rack_Rate__c;
                    totalPrice += ql.SBQQ__NetTotal__c;
                } else if (year == 4) {
                    totalQuantity += int_Quantity;
                    totalRackRate += int_Quantity * ql.Rack_Rate__c;
                    totalPrice += ql.SBQQ__NetTotal__c;
                } else if (year == 5) {
                    totalQuantity += int_Quantity;
                    totalRackRate += int_Quantity *ql.Rack_Rate__c;
                    totalPrice += ql.SBQQ__NetTotal__c;
                }  
            }
            result.quantityOfOne = ql.SBQQ__Product__r.Quantity_of_One__c;
            if(ql.SBQQ__RequiredBy__c == quoteLine.Id && ql.SBQQ__ProductCode__c.startsWith('CV-SW-EC-CC-CCMBAP'))
            {
                System.debug('ql.SBQQ__ProductCode__c in aggregatecrowdcompassmethod-'+ql.SBQQ__ProductCode__c);
                System.debug('Inside of showKeyword');
                result.showKeywordForEC = true;
            }
        }
        if (totalQuantity != 0) {
            result.quantity = totalQuantity;
            result.rackRate = totalRackRate / totalQuantity;
            result.discountUnitRate = totalPrice / totalQuantity;
            result.netTotalPrice = totalPrice;
            result.savingsTotal = totalRackRate - totalPrice;        
        } else {
            result = NULL;
        }
        return result;
    }
    //Begin additions by Bryce Baker 6.26.17
    
    public static QLWrapper aggregateOA360(SBQQ__QuoteLine__c quoteLine, Decimal year, List<SBQQ__QuoteLine__c> quoteLines, String event) {
        QLWrapper result = new QLWrapper(quoteLine.SBQQ__ProductName__c);
        
        Decimal totalQuantity = 0;
        Decimal totalRackRate = 0;
        Decimal totalPrice = 0;
        for (SBQQ__QuoteLine__c ql : quoteLines) {
            String eventName = ql.OnArrival_360_Event_Selection__r.Name;
            if (eventName == NULL) {
                eventName = ql.SBQQ__RequiredBy__r.OnArrival_360_Event_Selection__r.Name;
                if (eventName == NULL) {
                    eventName = ql.SBQQ__RequiredBy__r.SBQQ__RequiredBy__r.OnArrival_360_Event_Selection__r.Name;
                }
            }
            //eventName = eventName.escapeHtml3();
            if(!String.isEmpty(eventName))
            {
                eventName = eventName.escapeHtml3();
            }
            // CJ Added: if statement to only grab items in the same product family
            if(event == 'OnArrival Premium' && eventName.contains('OnArrival Premium'))
            {
                eventName = event;
            }
            String str_productCode = ql.SBQQ__ProductCode__c;
            Decimal int_Quantity = 0;
            if(ql.SBQQ__Product__r.Show_True_Quantity__c)
            {
                int_Quantity = ql.SBQQ__Quantity__c;
            }
            else
            {
                int_Quantity = ql.SBQQ__EffectiveQuantity__c;
            }
            if(quoteLine.Product_Family__c == ql.Product_Family__c)
            {
                if(ql.Contract_Output_Grouping__c == quoteLine.Contract_Output_Grouping__c )
                {
                    if (ql.SBQQ__ProductCode__c != 'CV-SW-EC-OSS-BYODLCS' && ql.SBQQ__ProductCode__c != 'CV-PS-HC-OSS-OA360T1' && ql.SBQQ__ProductCode__c != 'CV-PS-HC-OSS-OA360STD' && eventName == event && ql.SBQQ__ProductCode__c != 'CV-PS-HC-OSS-CMPLFEE' && ql.SBQQ__ProductCode__c != 'CV-SW-EC-OSS-DVCRNTL') {
                        
                       if (year == 1) {
                        totalQuantity += int_Quantity;
                        totalRackRate += int_Quantity * ql.Rack_Rate__c;
                        totalPrice += ql.SBQQ__NetTotal__c;
                        } else if (year == 2) {
                            totalQuantity += int_Quantity;
                            totalRackRate += int_Quantity * ql.Rack_Rate__c;
                            totalPrice += ql.SBQQ__NetPrice__c;
                        } else if (year == 3) {
                            totalQuantity += int_Quantity;
                            totalRackRate += int_Quantity * ql.Rack_Rate__c;
                            totalPrice += ql.SBQQ__NetPrice__c;
                        } else if (year == 4) {
                            totalQuantity += int_Quantity;
                            totalRackRate += int_Quantity * ql.Rack_Rate__c;
                            totalPrice += ql.SBQQ__NetPrice__c;
                        } else if (year == 5) {
                            totalQuantity += int_Quantity;
                            totalRackRate += int_Quantity * ql.Rack_Rate__c;
                            totalPrice += ql.SBQQ__NetPrice__c;
                        }
                        
                    }
                }
            }
            result.quantityOfOne = ql.SBQQ__Product__r.Quantity_of_One__c; 
        }
        
        if(totalQuantity > 0) {
            result.quantity = 1;//totalQuantity;
        } else {
            result.quantity = 0;
        }
        result.rackRate = totalRackRate;
        result.discountUnitRate = totalPrice;
        result.netTotalPrice = totalPrice;
        result.savingsTotal = totalRackRate - totalPrice;
        
        return result;
    }
    
    public static Boolean startsWithCustom(String qlProductCode)
    {
        Boolean result = false;
        Map<String,StartsWithCustomSetting__c> startsWith = StartsWithCustomSetting__c.getAll();
        for(String code : startsWith.keySet())
        {
            if(qlProductCode.startsWith(code))
            {
                result = true;
                break;
            }
        }

        return result;
    }
    // End additions by Bryce Baker 6.26.17
    
    
    class MultiEventTable {
        public Map<String, MultiYearQLTable> eventLinesMap { get; set; }
        public Map<String, Integer> tableSizes { get; set; }
        public Map<String, Decimal> tableTotals { get; set; }
        public Integer totalSize { get; set; }
        public Decimal linesSavings { get; set; }
        public Decimal netTotal { get; set; }
        public Integer years { get; set; }
        
        public MultiEventTable() {
            eventLinesMap = new Map<String, MultiYearQLTable>();
            tableSizes = new Map<String, Integer>();
            tableTotals = new Map<String, Decimal>();
        }
        
        public void add(Integer year, String eventName, QLWrapper entry) {
            eventLinesMap.get(eventName).add(year, entry);
        }
        
        public void recalculate() {
            totalSize = 0;
            for (String key : eventLinesMap.keySet()) {
                eventLinesMap.get(key).recalculate();
                tableTotals.put(key, eventLinesMap.get(key).getTotal());
                tableSizes.put(key, eventLinesMap.get(key).getSize());
                totalSize += eventLinesMap.get(key).getSize();
            }            
        }
        
        public void addHeaders(SBQQ__Quote__c quote) {
            for (MultiYearQLTable table : eventLinesMap.values()) {
                table.addHeaders(quote);
            }
        }
        
    }
    
    class OA360Event {
        public String eventName { get; set; }
        public Decimal netTotal { get; set; }
        public String dates { get; set; }
        public String address { get; set; }
        public String venue { get; set; }
        public String attendees {get; set; }
        public String exhibitors{get;set;}
        public Integer size { get; set; }
        
        public OA360Event() {
        }
        
        public OA360Event(String name, String dates, String address, String venue, String attendees,String exhibitors) {
            this.eventName = name;
            this.dates = dates;
            this.address = address;
            this.venue = venue;
            this.netTotal = 0;
            this.attendees = attendees;
            this.exhibitors = exhibitors;
            this.size = 0;
            
        }
        
        public void addToTotal(Decimal total) {
            netTotal += total;
        }
        
        public void addToSize(Integer count) {
            size += count;
        }
        
    }
    
    // changed to public by Jody Crutchfield 7/11/2017
    public class MultiYearQLTable {
        public List<QLTable> QLTables { get; set; }
        public Decimal linesSavings { get; set; }
        public Decimal netTotal { get; set; }
        public Integer years { get; set; }
        
        public MultiYearQLTable(Integer numberOfYears) {
            QLTables = new List<QLTable>();
            linesSavings = 0;
            netTotal = 0;
            years = numberOfYears;
            for (Integer i = 0; i < numberOfYears; i++) {
                QLTables.add(new QLTable(i + 1));
              
            }
        }

        public MultiYearQLTable(Integer numberOfYears,Integer currentYearDate) {
            QLTables = new List<QLTable>();
            linesSavings = 0;
            netTotal = 0;
            years = numberOfYears;
            for (Integer i = currentYearDate; i <= numberOfYears; i++) {
                QLTables.add(new QLTable(i));
            }
        }
        
        public void addHeaders(SBQQ__Quote__c quote) {
            Boolean first = true;
            CventMyd_QuoteObject quoteObj = new CventMyd_QuoteObject();

            List<Integer> yearsSorted = new List<Integer>();
            Map<Integer, SBQQ__QuoteLineGroup__c> map_quoteLineGroups = new Map<Integer, SBQQ__QuoteLineGroup__c>();

            quoteObj = (CventMyd_QuoteObject)JSON.deserialize(quote.jsonString__c,CventMyd_QuoteObject.class);

            for(Integer year : quoteObj.outyearMap.keySet()) {
                yearsSorted.add(year);
                }

            yearsSorted.sort();        
            for(Integer year : yearsSorted) {
                SBQQ__QuoteLineGroup__c yearGroup = new SBQQ__QuoteLineGroup__c();
                yearGroup.Name = 'Year ' + String.valueOf(year);
                yearGroup.term__c = year;
                yearGroup.SBQQ__StartDate__c = quoteObj.outyearMap.get(year).startDate;
                yearGroup.SBQQ__EndDate__c = quoteObj.outyearMap.get(year).endDate;
                map_quoteLineGroups.put(year, yearGroup);

            }            
            for (QLTable table : QLTables) 
            {
                if (table.year == 1) {
                    table.addHeader(first, quote.SBQQ__StartDate__c, quote.SBQQ__EndDate__c, quote.CurrencyISOCode);
                    first = false;
                } else if (table.year == 2 || table.year == 3 || table.year == 4 || table.year == 5 ) {
                    if(map_quoteLineGroups.containsKey((Integer)table.year)){
                        table.addHeader(first, map_quoteLineGroups.get((Integer)table.year).SBQQ__StartDate__c, map_quoteLineGroups.get((Integer)table.year).SBQQ__EndDate__c, quote.CurrencyISOCode);
                    }
                    else {
                        table.addHeader(first, quote.SBQQ__StartDate__c, quote.SBQQ__EndDate__c, quote.CurrencyISOCode);
                    }
                    first = false;
                }
            }
        }       
        
        public void add(Integer year, QLWrapper entry) {  
            System.debug(QuoteLineTemplateContentController.currentYearValue);
            System.debug(year);
            System.debug(QLTables.size());
            //CJ: had to add logic for user having MYD field as true
            if((year - QuoteLineTemplateContentController.currentYearValue)>=0 && QLTables.size()>=(year - QuoteLineTemplateContentController.currentYearValue))
            {
                QLTables.get(year - QuoteLineTemplateContentController.currentYearValue).quoteLines.add(entry);//QuoteLineTemplateContentController.currentYearValue
            }
        }         
        
        public void recalculate() {
            linesSavings = 0;
            netTotal = 0;
            List<QLTable> copy = new List<QLTable>();
            for (QLTable table : QLTables) {
                if (table.getSize() != 0) {
                    table.recalculate();
                    linesSavings += table.savingsTotal;
                    netTotal += table.linesTotal;
                    copy.add(table);
                }
            }
            QLTables = copy;
        }
        
        public Integer getSize() {
            Integer result = 0;
            
            for (QLTable table : QLTables) {
                result += table.getSize();
            }
            
            return result;
        }
        
        public Decimal getTotal() {
            return netTotal;
        }
        
    }
    
    class QLTable {
        
        public List<QLWrapper> quoteLines { get; set; }
        public Decimal linesTotal { get; set; }
        public Decimal savingsTotal { get; set; }
        public Decimal rackTotal { get; set; }
        public Decimal year { get; set; }
        
        public QLTable(Decimal y) {
            quoteLines = new List<QLWrapper>();
            linesTotal = 0;
            savingsTotal = 0;
            year = y;
        }
        
        public Integer getSize() {
            return quoteLines.size();
        }
        
        public void addHeader(Boolean first, Date startDate, Date endDate, String currencySymbol) {
            List<QLWrapper> copy = new List<QLWrapper>();
            
            copy.add(new QLWrapper('YEAR ' + year + ': ' + TemplateUtilities.formatDate(startDate, currencySymbol) + ' - ' + TemplateUtilities.formatDate(endDate, currencySymbol)));
            for (QLWrapper wrap : quoteLines) {
                copy.add(wrap);
               
            }
            if (quoteLines.size()>0){
                
                quoteLines = copy;

            }
        }
        
        public void recalculate() {
            Integer order = 0;
            linesTotal = 0;
            savingsTotal = 0;
            rackTotal = 0;
            
            for (QLWrapper wrap : quoteLines) {
                if (wrap != NULL) {
                    if (wrap.name == ' ') {
                        wrap.rowNumber = 0;
                    } else {
                        wrap.rowNumber = order++;
                    }
                    if (wrap.netTotalPrice != NULL) {
                        linesTotal += wrap.netTotalPrice;
                    }
                    if (wrap.savingsTotal != NULL) {
                        savingsTotal += wrap.savingsTotal;
                    }
                    if (wrap.rackRate != NULL) {
                        rackTotal += wrap.RackRate * wrap.quantity;
                    }
                }
            }
        }
        
    }
    //Ashwini --> No Changes in Wrapper Classes Required.
    
    public class QLWrapper {

        public SBQQ__QuoteLine__c quoteLine { get; set; }
        public Decimal rowNumber { get; set; }
        public String name { get; set; }
        public Decimal quantity { get; set; }
        public Boolean quantityOfOne { get; set; }
        public Boolean showKeywordForEC;
        public Boolean getShowKeywordForEC()
        {
            if(showKeywordForEC == NULL)
                return false;
            else
                return showKeywordForEC;
        }
        public void setShowKeywordForEC(Boolean input)
        {
            this.showKeywordForEC = input;
        }
        public String getQuantityWithText()
        {
            return quantity + ' Event';
        }
        public Decimal rackRate { get; set; }
        public Decimal rackRateSum { get; set; }
        public Decimal totalPrice { get; set; }
        public Decimal discountUnitRate { get; set; }
        public Decimal netTotalPrice { get; set; }
        public Decimal savingsTotal { get; set; }
        public Date startDate { get; set; }
        public Date endDate { get; set; }
        public String text1 { get; set; }
        public String text2 { get; set; }
        public Decimal numberOfRfps { get; set; }
        public String nonNativeMMAs { get; set; }
        public String venueCodes { get; set; }
        public String notes { get; set; }
        public String MMAText{get;set;}
        public Boolean strikeThrough { get; set; }
        public Boolean header { get; set{header = false;} }
        public Decimal term { get; set; }
        
        public QLWrapper(SBQQ__QuoteLine__c ql, Decimal row) {
            name = '';
            strikeThrough = false;
            quoteLine = ql;
            rowNumber = row;
            if (ql.SBQQ__ProductName__c != NULL) {
                if (ql.SBQQ__ProductName__c != NULL) {
                    name = ql.SBQQ__ProductName__c.escapeHtml3();
                }
            }
            rackRateSum = ql.totalRollupPrice__c;
            
        }
        
        public QLWrapper(String productName) {
            name = '';
            
            strikeThrough = false;
            if (productName != NULL) {
                name = productName.escapeHtml3();
            }
            if(name.contains('YEAR'))
            {
                header = true;
            }
        }
        
        public QLWrapper(String productName, String str1, String str2, Decimal netTotal, Date startD, Date endD, Date quoteStart, Date quoteEnd) {
            name = '';
            if (productName != NULL) {
                name = productName.escapeHtml3();
            }
            text1 = '';
            text2 = '';
            if (str1 != NULL) {
                text1 = str1.escapeHtml3();
            }
            if (str2 != NULL) {
                text2 = str2.escapeHtml3();
            }
            if(netTotal != null) {
                netTotalPrice = netTotal;
            }
            startDate = startD;
            if (startDate == NULL) {
                startDate = quoteStart;
            }
            endDate = endD;
            if (endDate == NULL) {
                endDate = quoteEnd;
                
            }
        }
        
        public QLWrapper(String productName, String str1, Decimal netTotal, Date startD, Date endD, Date quoteStart, Date quoteEnd) {
            name = '';
            if (productName != NULL) {
                name = productName.escapeHtml3();
            }
            text1 = '';
            if (str1 != NULL) {
                text1 = str1.escapeHtml3();
            }
            if (netTotal != NULL) {
                netTotalPrice = netTotal;
            }
            
            startDate = startD;
            if (startDate == NULL) {
                startDate = quoteStart;
            }
            endDate = endD;
            if (endDate == NULL) {
                endDate = quoteEnd;
            }
        }
        
        public QLWrapper(String productName, String str1, String str2, Decimal q, Decimal netTotal, Date startD, Date endD, Date quoteStart, Date quoteEnd) {
            name = '';
            if (productName != NULL) {
                name = productName.escapeHtml3();
            }
            quantity = q;
            text1 = '';
            text2 = '';
            if (str1 != NULL) {
                text1 = str1.escapeHtml3();
            }
            if (str2 != NULL) {
                text2 = str2.escapeHtml3();
            }
            if (netTotal != NULL) {
                netTotalPrice = netTotal;
            }
            startDate = startD;
            if (startDate == NULL) {
                startDate = quoteStart;
            }
            endDate = endD;
            if (endDate == NULL) {
                endDate = quoteEnd;
                ////////System.debug('constructor 5: ' + this);
            }
        }
        
        public QLWrapper(String productName, Decimal q, Decimal netTotal, Date startD, Date endD, Date quoteStart, Date quoteEnd) {
            name = '';
            if (productName != NULL) {
                name = productName.escapeHtml3();
            }
            quantity = q;
            if (netTotal != NULL) {
                netTotalPrice = netTotal;
            }
            startDate = startD;
            if (startDate == NULL) {
                startDate = quoteStart;
            }
            endDate = endD;
            if (endDate == NULL) {
                endDate = quoteEnd;
                ////////System.debug('constructor 6: ' + this);
            }
        }
        
        public QLWrapper(String productName, Decimal q, String str1, Decimal netTotal, Date startD, Date endD, Date quoteStart, Date quoteEnd) {
            name = '';
            if (productName != NULL) {
                name = productName.escapeHtml3();
            }
            quantity = q;
            text1 = '';
            if (str1 != NULL) {
                text1 = str1.escapeHtml3();
            }
            if (netTotal != NULL) {
                netTotalPrice = netTotal;
            }
            startDate = startD;
            if (startDate == NULL) {
                startDate = quoteStart;
            }
            endDate = endD;
            if (endDate == NULL) {
                endDate = quoteEnd;
            }
        }
        
        public QLWrapper(String productName, Decimal rfps, String mmas, String codes, Decimal netTotal, Date startD, Date endD, Date quoteStart, Date quoteEnd) {
            name = '';
            if (productName != NULL) {
                name = productName.escapeHtml3();
            }
            numberOfRfps = rfps;
            nonNativeMMAs = mmas;
            venueCodes = codes;
            if (netTotal != NULL) {
                netTotalPrice = netTotal;
            }
            startDate = startD;
            if (startDate == NULL) {
                startDate = quoteStart;
            }
            endDate = endD;
            if (endDate == NULL) {
                endDate = quoteEnd;
            }
        }
        
        public QLWrapper(String productName, Decimal q, Decimal rate, Decimal total, Decimal discountRate, Decimal netTotal, Decimal savings) {
            name = '';
            strikeThrough = false;
            if (productName != NULL) {
                name = productName.escapeHtml3();
            }
            quantity = q;
            if (rate != NULL) {
                rackRate = rate;
            }
            if (total != NULL) {
                totalPrice = total;
            }
            if (discountRate != NULL) {
                discountUnitRate = discountRate;
            }
            
            if (netTotal != NULL) {
                netTotalPrice = netTotal;
            }
           // savingsTotal = Math.round(savings); /*commented by Udita*/
            savingsTotal = savings;  //  added by udita for P-003747
           
        }
                
        public QLWrapper(String productName, Date startD, Date endD, Decimal netTotal,String MMAtextVal) {
            name = '';
            strikethrough = false;
            if (productName != NULL) {
                name = productName.escapeHtml3();
            }
            startDate = startD;
            endDate = endD;
            if (netTotal != NULL) {
                netTotalPrice = netTotal;
            }
            MMAtext = MMAtextVal;
            ////////System.debug('constructor 9: ' + this);
        }
        
        public QLWrapper(String productName, Decimal netTotal) {
            name = '';
            strikeThrough = false;
            if (productName != NULL) {
                name = productName.escapeHtml3();
            }
            netTotalPrice = netTotal;
            ////////System.debug('constructor 10: ' + this);
        }
        
        public QLWrapper(String productName, Decimal q, Decimal netTotal) {
            name = '';
            strikeThrough = false;
            if (productName != NULL) {
                name = productName.escapeHtml3();
            }
            if (netTotal != NULL) {
                netTotalPrice = netTotal;
            }
            quantity = q;
            ////////System.debug('constructor 11: ' + this);
        }
        
        public QLWrapper(String productName, Decimal netTotal, Boolean strike) {
            name = '';
            strikeThrough = strike;
            if (productName != NULL) {
                name = productName.escapeHtml3();
            }
            if (netTotal != NULL) {
                netTotalPrice = netTotal;
            }
            ////////System.debug('constructor 12: ' + this);
        }
        
        public QLWrapper(String productName, Decimal q, Decimal rate, Decimal total, Decimal discountRate, Decimal netTotal) {
            name = '';
            strikeThrough = false;
            if (productName != NULL) {
                name = productName.escapeHtml3();
            }
            quantity = q;
            if (rate != NULL) {
                rackRate = rate;
            }
            if (total != NULL) {
                totalPrice = total;
            }
            if (discountRate != NULL) {
                discountUnitRate = discountRate;
            }
            if (netTotal != NULL) {
                netTotalPrice = netTotal;
            }
            ////////System.debug('Wrapper: Quantity:' + quantity + 'total: ' + totalPrice + ' netTotalPrice: ' + netTotalPrice);
        }        
    }
}