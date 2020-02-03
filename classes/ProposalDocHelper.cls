/**
 * Created by CrutchfieldJody on 7/13/2017.
 */

public without sharing class ProposalDocHelper {

    public String qId { get; set; }
    public List<SBQQ__QuoteLine__c> quoteLines { get; set; }
    public Integer contractTermYears { get; set; }
    public Integer contractFinalYears { get; set; }
    public String currencySymbol { get; set; }
    public String currencySign { get; set; }
    public SBQQ__Quote__c quote { get; set; }
    public List<Decimal> empty { get; set; }
    public List<Decimal> single { get; set; }

    /* Hospitaliy Cloud Summary */
    public MultiYearQLTable hcSummaryTable { get; set; }
    public List<Decimal> showHcSummaryTable { get; set; }

    /* Events */
    public MultiYearQLTable eventTable { get; set; }
    public MultiYearQLTable eventMatrixTable { get; set; }
    public List<Decimal> showEventTable { get; set; }
    public List<Decimal> showEventNoPriceTable { get; set; }

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
    
    /* Social Tables */
    public MultiYearQLTable socialTablesTable { get; set; }
    public List<Decimal> showSocialTablesTable { get; set; }

    public List<SBQQ__QuoteLine__c> groupLines { get; set; }
    //public Map<Id, SBQQ__QuoteLine__c> (List<SBQQ__QuoteLine__c> groupLines) {get; set;}
    //End Additions Bryce Baker 6.23.17

    public MultiYearQLTable overagesTable { get; set; }
    public List<Decimal> showOveragesTable { get; set; }

    public Decimal convenienceFee { get; set; }
    public static Integer currentYearValue ;
    
    //Adding Custom Setting For Bundled Products - Mohsin
    public static Map<String,ProductCodesUsedInProposalDocument__c> productCodes;
    
    public ProposalDocHelper(Id quoteId) {
        empty = new List<Decimal>();
        single = new List<Decimal>();
        single.add(0.0);
        qId = quoteId;
        productCodes = ProductCodesUsedInProposalDocument__c.getAll();
        initializeData();
        executeData();
    }

    public Map<Integer, SBQQ__QuoteLineGroup__c> MapreturnDates()
    {
        CventMyd_QuoteObject quoteObj = new CventMyd_QuoteObject();

        List<Integer> yearsSorted = new List<Integer>();
        Map<Integer, SBQQ__QuoteLineGroup__c> map_quoteLineGroups = new Map<Integer, SBQQ__QuoteLineGroup__c>();

        quoteObj = (CventMyd_QuoteObject)JSON.deserialize(quote.jsonString__c,CventMyd_QuoteObject.class);

        for(Integer year : quoteObj.outYearMap.keySet()) {
            yearsSorted.add(year);
            }

        yearsSorted.sort();
        for(Integer year : yearsSorted) {
            SBQQ__QuoteLineGroup__c yearGroup = new SBQQ__QuoteLineGroup__c();
            yearGroup.Name = 'Year ' + String.valueOf(year);
            yearGroup.term__c = year;
            yearGroup.SBQQ__StartDate__c = quoteObj.outYearMap.get(year).startDate;
            yearGroup.SBQQ__EndDate__c = quoteObj.outYearMap.get(year).endDate;
            map_quoteLineGroups.put(year, yearGroup);

        }
        return  map_quoteLineGroups;
    }

    public void initializeData() {

        quoteLines = new List<SBQQ__QuoteLine__c>();

        quote = [
                select Name, Contract_Term_Years__c, Multiple_Years_Commitment__c, Dynamic_Quote_Template_Color__c, SBQQ__NetAmount__c,
                        SBQQ__ExpirationDate__c, Count_of_HC_Products__c, Hide_Unit_Prices_on_Contract__c,
                        CurrencyIsoCode,
                        Count_of_RegOnline_Products__c, Count_of_Onsite_Solutions__c, OnArrival_360_Quote__c, Contract_Remaining_Term__c,
                        Current_Year__c, jsonString__c, SBQQ__StartDate__c, SBQQ__EndDate__c, HC_Logo_Conditional_Print__c
                from SBQQ__Quote__c
                where Id = :qid
        ];
        System.debug(qid);
        currencySymbol = quote.CurrencyIsoCode;
        //currencySign = TemplateUtilities.getCurrencySign(currencySymbol);
        currencySign =  currencySymbol + ' ';

        contractTermYears = quote.Contract_Remaining_Term__c.intValue();
        contractFinalYears = Integer.valueOf(quote.Contract_Term_Years__c);
        currentYearValue = quote.Current_Year__c.intValue();

        System.debug('Contract Term Years: ' + contractTermYears);

        if (quote.Multiple_Years_Commitment__c || quote.HC_Logo_Conditional_Print__c == 'true') {
            eventTable = new MultiYearQLTable(contractFinalYears, currentYearValue);
            eventMatrixTable = new MultiYearQLTable(contractFinalYears, currentYearValue);
            listingAdsTable = new MultiYearQLTable(contractFinalYears, currentYearValue);
            //hcSummaryTable = new MultiYearQLTable(contractTermYears);
            hcSummaryTable = new MultiYearQLTable(contractFinalYears, currentYearValue);
            bundleAdsTable = new MultiYearQLTable(contractFinalYears,currentYearValue);
            passkeyTable = new MultiYearQLTable(contractFinalYears, currentYearValue);
            emiTable = new MultiYearQLTable(contractFinalYears, currentYearValue);
            regOnlineTable = new MultiYearQLTable(contractFinalYears, currentYearValue);
            suggestedAdsTable = new MultiYearQLTable(contractFinalYears, currentYearValue);
            reportingTable = new MultiYearQLTable(contractFinalYears, currentYearValue);
            videoRetargetingTable = new MultiYearQLTable(contractFinalYears, currentYearValue);
            merchantTable = new MultiYearQLTable(contractFinalYears, currentYearValue);
            onDemandTable = new MultiYearQLTable(contractFinalYears, currentYearValue);
            professionalServicesTable = new MultiYearQLTable(contractFinalYears, currentYearValue);
            socialTablesTable = new MultiYearQLTable(contractFinalYears, currentYearValue);
            overagesTable = new MultiYearQLTable(contractFinalYears, currentYearValue);

        } else {
            eventTable = new MultiYearQLTable(1);
            eventMatrixTable = new MultiYearQLTable(1);
            listingAdsTable = new MultiYearQLTable(1);
            hcSummaryTable = new MultiYearQLTable(contractFinalYears, currentYearValue);
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
            socialTablesTable = new MultiYearQLTable(1);
            overagesTable = new MultiYearQLTable(1);
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
        showSocialTablesTable = empty;


        quoteLines = [
                select Id, SBQQ__Quote__r.SBQQ__StartDate__c, SBQQ__Quote__r.SBQQ__EndDate__c, Rack_Rate__c,
                        //SBQQ__Quote__r.Effective_Year_2_Start_Date__c, SBQQ__Quote__r.Effective_Year_2_End_Date__c,
                        //SBQQ__Quote__r.Effective_Year_3_Start_Date__c, SBQQ__Quote__r.Effective_Year_3_End_Date__c,
                        //SBQQ__Quote__r.Effective_Year_4_Start_Date__c, SBQQ__Quote__r.Effective_Year_4_End_Date__c,
                        //SBQQ__Quote__r.Effective_Year_5_Start_Date__c, SBQQ__Quote__r.Effective_Year_5_End_Date__c,
                        SBQQ__NetPrice__c, SBQQ__Quantity__c, SBQQ__EffectiveQuantity__c, SBQQ__ProductName__c, Contract_Output_Grouping__c,
                        SBQQ__NetTotal__c, CurrencyIsoCode, SBQQ__Bundled__c, SBQQ__ComponentVisibility__c,
                        Number_Of_Views__c, Location_Text__c, Overage_Fee__c, 
                        //Year_2_Overage_Fee__c, Year_3_Overage_Fee__c,
                        //Year_4_Overage_Fee__c, Year_5_Overage_Fee__c,
                        SBQQ__RequiredBy__c, SBQQ__ProductOption__r.SBQQ__Feature__r.Name, SBQQ__ProductCode__c,
                        //Year_2_Quantity__c, Year_3_Quantity__c, Year_4_Quantity__c, Year_5_Quantity__c,Year_2_List_Price__c, Year_3_List_Price__c, Year_4_List_Price__c, Year_5_List_Price__c,
                        SBQQ__ListPrice__c, 
                        //Year_2_Net_Amount__c, Year_3_Net_Amount__c, Year_4_Net_Amount__c, Year_5_Net_Amount__c,Year_2_Effective_Quantity__c, Year_3_Effective_Quantity__c, Year_4_Effective_Quantity__c,
                        Editor_Net_Total__c,Number_of_RFPs__c, MMA_Text__c,Enter_Venue_Codes__c,Linked_To__c,Product_Family__c, Banner_Ad_Location_Name__c, SBQQ__Hidden__c, Ad_Start_Date__c, Ad_End_Date__c, Product_Line__c,
                        Unit__c, 
                        //Year_5_Effective_Quantity__c, Year_2_Effective_Amount__c, Year_3_Effective_Amount__c,Year_4_Effective_Amount__c, Year_5_Effective_Amount__c, 
                        SBQQ__Product__r.Contract_Output_Grouping__c,
                        OnArrival_360_Event_Selection__r.Name, OnArrival_360_Event_Selection__r.Dates__c,
                        OnArrival_360_Event_Selection__r.Number_of_Attendees__c, 
                        OnArrival_360_Event_Selection__r.Address_of_Event__c,
                        SBQQ__RequiredBy__r.OnArrival_360_Event_Selection__r.Name, SBQQ__RequiredBy__r.OnArrival_360_Event_Selection__r.Dates__c, SBQQ__RequiredBy__r.OnArrival_360_Event_Selection__r.Address_of_Event__c,
                        SBQQ__RequiredBy__r.SBQQ__RequiredBy__r.OnArrival_360_Event_Selection__r.Address_of_Event__c,SBQQ__RequiredBy__r.SBQQ__RequiredBy__r.OnArrival_360_Event_Selection__r.Dates__c,
                        SBQQ__RequiredBy__r.SBQQ__RequiredBy__r.OnArrival_360_Event_Selection__r.Name, Notes__c, Enter_Individual_Markets__c,
                        SBQQ__RequiredBy__r.SBQQ__RequiredBy__r.OnArrival_360_Event_Selection__r.Venue_Name__c,
                        SBQQ__RequiredBy__r.OnArrival_360_Event_Selection__r.Venue_Name__c, OnArrival_360_Event_Selection__r.Venue_Name__c,
                        SBQQ__EffectiveStartDate__c, SBQQ__EffectiveEndDate__c, 
                        //Year_2_Start_Date__c, Year_2_End_Date__c, Year_3_Start_Date__c, Year_3_End_Date__c,
                        //Year_4_Start_Date__c, Year_4_End_Date__c, Year_5_Start_Date__c, Year_5_End_Date__c, 
                        SBQQ__PricingMethod__c, SBQQ__DiscountScheduleType__c,rollupQuantityIntoThisBundle__c,
                        SBQQ__PriorQuantity__c, SA_Start_Date__c, SA_End_Date__c, SBQQ__PriceEditable__c, term__c, SBQQ__Product__r.Show_True_Quantity__c,Retargeting_Tracking__c,
                        SBQQ__Optional__c,totalRollupPrice__c
                from SBQQ__QuoteLine__c
                where SBQQ__Quote__c = :qid
                AND(SBQQ__EffectiveQuantity__c != 0  OR rollupQuantityIntoThisBundle__c =true)
                ORDER BY SBQQ__Number__c ASC
        ];
    }

    public void executeData() {

        for (SBQQ__QuoteLine__c ql : quoteLines) {
            Decimal int_Quantity = 0;
            if(ql.SBQQ__Product__r.Show_True_Quantity__c)
            {
                int_Quantity = ql.SBQQ__Quantity__c;
            }
            else
            {
                int_Quantity = ql.SBQQ__EffectiveQuantity__c;
            }

            if (!ql.SBQQ__Bundled__c && ql.SBQQ__ComponentVisibility__c != 'Never' && ql.SBQQ__ComponentVisibility__c != 'Editor Only' && !ql.SBQQ__Hidden__c) {
                QLWrapper wrapper;
                if (ql.Contract_Output_Grouping__c == 'Bundle Advertisements') {
                    System.debug(System.LoggingLevel.INFO, 'Bundle Advertisements');
                    //createBundleAdsTable(ql, wrapper);
                    createBundleAdsTable(ql, int_Quantity, quote.Multiple_Years_Commitment__c, quote);
                } else if (ql.Contract_Output_Grouping__c == 'Suggested Advertisements') {
                    System.debug(System.LoggingLevel.INFO, 'Suggested Advertisements');
                    createSuggestedAds(ql, int_Quantity, quote.Multiple_Years_Commitment__c, quote);
                } else if (ql.Contract_Output_Grouping__c == 'Video Retargeting') {
                    System.debug(System.LoggingLevel.INFO, 'Video Retargeting');
                    createVideoRetargeting(ql, int_Quantity, quote.Multiple_Years_Commitment__c, quote);
                    //createVideoRetargeting(ql, wrapper);
                } else if (ql.Contract_Output_Grouping__c == 'Elite Meetings Alliance') {
                    System.debug(System.LoggingLevel.INFO, 'Elite Meetings Alliance');
                    //createEliteMeetings(ql, wrapper);
                    createEliteMeetings(ql, int_Quantity, quote.Multiple_Years_Commitment__c, quote);
                } else if (ql.Contract_Output_Grouping__c == 'Reporting & Analytics') {
                    System.debug(System.LoggingLevel.INFO, 'Reporting & Analytics');
                    //createReportingAndAnalytics(ql, wrapper);
                    createReportingAndAnalytics(ql, int_Quantity, quote.Multiple_Years_Commitment__c, quote);
                } else if (ql.Contract_Output_Grouping__c == 'Cvent Passkey, Transient & Lanyon Group') {
                    System.debug(System.LoggingLevel.INFO, 'Cvent Passkey, Transient & Lanyon Group');
                    //createPasskeyTransientLanyon(ql, wrapper);
                    createPasskeyTransientLanyon(ql, int_Quantity, quote.Multiple_Years_Commitment__c, quote);
                } else if (ql.Contract_Output_Grouping__c == 'Listing Advertisement(s), Software, Services & CONNECT') {
                    System.debug(System.LoggingLevel.INFO, 'Listing Advertisement(s), Software, Services & CONNECT');
                    //createListingAdsSoftwareServicesCONNECT(ql, wrapper);
                    createListingAdsSoftwareServicesCONNECT(ql, int_Quantity, quote.Multiple_Years_Commitment__c, quote);
                }else if ((ql.Contract_Output_Grouping__c == 'Social Tables' && Boolean.valueOf(Label.SocialTableDocument))) {
                    System.debug(System.LoggingLevel.INFO, 'Social Tables');
                    if(productCodes.containsKey(ql.SBQQ__ProductCode__c)){createSocialTables(ql, int_Quantity, quote.Multiple_Years_Commitment__c, quote,ql.totalRollupPrice__c); }                                    
                       else{createSocialTables(ql, int_Quantity, quote.Multiple_Years_Commitment__c, quote,ql.SBQQ__NetTotal__c);}                    
                    //createProfessional(ql, int_Quantity, quote.Multiple_Years_Commitment__c, quote);
                }else if (ql.Contract_Output_Grouping__c == 'Merchant') {System.debug(System.LoggingLevel.INFO, 'Merchant'); createMerchant(ql, wrapper);
                    //createMerchant(ql, int_Quantity, quote.Multiple_Years_Commitment__c, quote); } else if (ql.Contract_Output_Grouping__c == 'OnDemand') {
                    System.debug(System.LoggingLevel.INFO, 'OnDemand');
                    createOnDemand(ql, wrapper);
                    //createOnDemand(ql, int_Quantity, quote.Multiple_Years_Commitment__c, quote);
                } else if (ql.Contract_Output_Grouping__c == 'Professional') {
                    System.debug(System.LoggingLevel.INFO, 'Professional');
                    createProfessional(ql, wrapper);
                    //createProfessional(ql, int_Quantity, quote.Multiple_Years_Commitment__c, quote);
                }
                //createOveragesTable(ql, wrapper);
                createOveragesTable(ql, int_Quantity, quote.Multiple_Years_Commitment__c, quote);
                createEventTable(ql, wrapper);
            }

        }

        System.debug(quote.jsonString__c);
        if ((quote.Multiple_Years_Commitment__c || quote.HC_Logo_Conditional_Print__c == 'true') && quote.Contract_Remaining_Term__c >1){
            eventTable.addHeaders(quote);
            listingAdsTable.addHeaders(quote);
            bundleAdsTable.addHeaders(quote);
            passkeyTable.addHeaders(quote);
            emiTable.addHeaders(quote);
            regOnlineTable.addHeaders(quote);
            suggestedAdsTable.addHeaders(quote);
            reportingTable.addHeaders(quote);
            videoRetargetingTable.addHeaders(quote);
            socialTablesTable.addHeaders(quote);
            overagesTable.addHeaders(quote);
        }
        eventTable.recalculate();

        if (quote.Count_of_HC_Products__c > 0) {
            //if(hcSummaryTable.QLTables.get(0).quoteLines.size()>0){
            //    showHcSummaryTable = single;
            //}
            //else{
            //    showHcSummaryTable = empty;
            //}
            showHcSummaryTable = single;
            showEventTable = empty;
            showEventNoPriceTable = empty;
        } else {
            if (quote.Count_of_RegOnline_Products__c == 0){
                if (quote.Hide_Unit_Prices_on_Contract__c){
                    showHcSummaryTable = empty;
                    showEventTable = empty;
                    showEventNoPriceTable = single;
                } else {
                    showHcSummaryTable = empty;
                    showEventTable = single;
                    showEventNoPriceTable = empty;
                }
            } else {
                showHcSummaryTable = empty;
                showEventTable = empty;
                showEventNoPriceTable = empty;
            }
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
        socialTablesTable.recalculate();
        overagesTable.recalculate();

        convenienceFee = aggregateConvenienceFee(quoteLines);

        if(quote.Contract_Remaining_Term__c >= 1 ) {
            createHCSummaryTable(eventTable, convenienceFee);
            //if (quote.Multiple_Years_Commitment__c)
            if (quote.Contract_Remaining_Term__c > 1)
            {
                hcSummaryTable.addHeaders(quote);
            }
        }
        hcSummaryTable.recalculate();
    }

    // --- Bundle Advertisements --- //
    //public void createBundleAdsTable(SBQQ__QuoteLine__c ql, QLWrapper wrapper) {
    public void createBundleAdsTable(SBQQ__QuoteLine__c obj_QL, Decimal int_Quantity, Boolean boo_MYD, SBQQ__Quote__c obj_quote) {
        QLWrapper wrapper = NULL;
        Date startDate = TemplateUtilities.getStartDateFromQL(obj_QL, obj_QL.term__c);
        Date endDate = TemplateUtilities.getEndDateFromQL(obj_QL, obj_QL.term__c);
        String showBannerAdLocation = (obj_QL.SBQQ__ProductCode__c =='CV-AD-HC-CSN-CVBCFEA') ? obj_QL.MMA_Text__c : obj_QL.Banner_Ad_Location_Name__c;  // Updated for P-005050 by Dishank
        if (int_Quantity <> 0) {
            if(obj_QL.term__c == 1 || (boo_MYD && obj_QL.term__c >1)) {
                if(quote.Contract_Remaining_Term__c > 1 && !quote.Multiple_Years_Commitment__c && obj_QL.term__c == 1 && quote.HC_Logo_Conditional_Print__c == 'true') {
                    Map<Integer, SBQQ__QuoteLineGroup__c> map_quoteLineGroups = MapreturnDates();
                    for (QLTable table : eventTable.QLTables)
                    {
                        for (QLTable tab : bundleAdsTable.QLTables) {
                            if (tab.year == table.year) {
                                QLWrapper wrapperTemp = NULL;
                                if(tab.year == 1)
                                {
                                    wrapperTemp = new QLWrapper(obj_QL.SBQQ__ProductName__c, obj_QL.Linked_To__c/*linkedTo*/, showBannerAdLocation  /*location*/, obj_QL.SBQQ__NetTotal__c, startDate, endDate, startDate, endDate);
                                    //tab.quoteLines.add(wrapperTemp);
                                }else{
                                    wrapperTemp = new QLWrapper(obj_QL.SBQQ__ProductName__c, obj_QL.Linked_To__c/*linkedTo*/, showBannerAdLocation /*location*/, obj_QL.SBQQ__NetTotal__c, map_quoteLineGroups.get((Integer)table.year).SBQQ__StartDate__c, map_quoteLineGroups.get((Integer)table.year).SBQQ__EndDate__c, map_quoteLineGroups.get((Integer)table.year).SBQQ__StartDate__c, map_quoteLineGroups.get((Integer)table.year).SBQQ__EndDate__c);
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
                else {
                    wrapper = new QLWrapper(obj_QL.SBQQ__ProductName__c, obj_QL.Linked_To__c/*linkedTo*/, showBannerAdLocation /*location*/, obj_QL.SBQQ__NetTotal__c, startDate, endDate, startDate, endDate);
                }
                showBundleAdsTable = single;
            }
        }
        if (wrapper != null && obj_QL != null) {
            wrapper.notes = TemplateUtilities.escapeNotesString(obj_QL.Notes__c);
            bundleAdsTable.add((Integer)obj_QL.term__c, wrapper);
            wrapper.quantity = int_Quantity;
        }
    }

    // --- Suggested Advertisements --- //
    //public void createSuggestedAds(SBQQ__QuoteLine__c ql, QLWrapper wrapper) {
    public void createSuggestedAds(SBQQ__QuoteLine__c obj_QL, Decimal int_Quantity, Boolean boo_MYD, SBQQ__Quote__c obj_quote) {
        QLWrapper wrapper = NULL;
        Date startDate = TemplateUtilities.getStartDateFromQL(obj_QL, obj_QL.term__c);
        Date endDate = TemplateUtilities.getEndDateFromQL(obj_QL, obj_QL.term__c);
        if(int_Quantity <> 0)
        {
            if(obj_QL.term__c == 1 || (boo_MYD && obj_QL.term__c >1))
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
            suggestedAdsTable.add((Integer)obj_QL.term__c, wrapper);
            wrapper.quantity = int_Quantity;
        }
    }

    // --- Video Retargeting --- //
    public void createVideoRetargeting(SBQQ__QuoteLine__c obj_QL, Decimal int_Quantity, Boolean boo_MYD, SBQQ__Quote__c obj_quote) {
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
            if(obj_QL.term__c == 1 || (boo_MYD && obj_QL.term__c >1))
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
            videoRetargetingTable.add((Integer)obj_QL.term__c, wrapper);
            wrapper.quantity = int_Quantity;
        }
    }
    /*
        Decimal int_Quantity = 0;
        if(ql.SBQQ__Product__r.Show_True_Quantity__c)
        {
            int_Quantity = ql.SBQQ__Quantity__c;
        }
        else
        {
            int_Quantity = ql.SBQQ__EffectiveQuantity__c;
        }
        if (ql.SBQQ__EffectiveQuantity__c <> 0) {
            if (ql.term__c == 1 && int_Quantity <> 0) {
                Date startDate = TemplateUtilities.getStartDateFromQL(ql, 1);
                Date endDate = TemplateUtilities.getEndDateFromQL(ql, 1);
                wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Number_Of_Views__c, ql.SBQQ__NetTotal__c, startDate, endDate, startDate, endDate);
                if (wrapper != null && ql != null) {
                    wrapper.notes = TemplateUtilities.escapeNotesString(ql.Notes__c);
                }
                videoRetargetingTable.add(1, wrapper);
                showVideoRetargetingTable = single;
            }
            else if (ql.term__c == 2 && contractTermYears > 1) {
                if (int_Quantity > 0 && quote.Multiple_Years_Commitment__c && int_Quantity <> 0) {
                    Date startDate = TemplateUtilities.getStartDateFromQL(ql, 2);
                    Date endDate = TemplateUtilities.getEndDateFromQL(ql, 2);
                    wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Number_of_Views__c, ql.SBQQ__NetTotal__c, startDate, endDate, startDate, endDate);
                    videoRetargetingTable.add(2, wrapper);
                } else if (ql.SBQQ__Quantity__c == NULL && int_Quantity <> 0 && quote.Multiple_Years_Commitment__c) {
                    wrapper = wrapper.clone();
                    videoRetargetingTable.add(2, wrapper);
                }
                if (wrapper != null && ql != null) {
                    wrapper.notes = TemplateUtilities.escapeNotesString(ql.Notes__c);
                }
                showVideoRetargetingTable = single;
                videoRetargetingTable.add(2, wrapper);
            }
            else if (ql.term__c == 3 && contractTermYears > 2) {
                if (int_Quantity > 0 && quote.Multiple_Years_Commitment__c && int_Quantity <> 0) {
                    Date startDate = TemplateUtilities.getStartDateFromQL(ql, 3);
                    Date endDate = TemplateUtilities.getEndDateFromQL(ql, 3);
                    wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Number_of_Views__c, ql.SBQQ__NetTotal__c, startDate, endDate, startDate, endDate);
                    videoRetargetingTable.add(3, wrapper);
                } else if (ql.SBQQ__Quantity__c == NULL && int_Quantity <> 0 && quote.Multiple_Years_Commitment__c) {
                    wrapper = wrapper.clone();
                    videoRetargetingTable.add(3, wrapper);
                }
                if (wrapper != null && ql != null) {
                    wrapper.notes = TemplateUtilities.escapeNotesString(ql.Notes__c);
                }
                showVideoRetargetingTable = single;
                videoRetargetingTable.add(3, wrapper);
            }
            else if (ql.term__c == 4 && contractTermYears > 3) {
                if (int_Quantity > 0 && quote.Multiple_Years_Commitment__c && int_Quantity <> 0) {
                    Date startDate = TemplateUtilities.getStartDateFromQL(ql, 4);
                    Date endDate = TemplateUtilities.getEndDateFromQL(ql, 4);
                    wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Number_of_Views__c, ql.SBQQ__NetTotal__c, startDate, endDate, startDate, endDate);
                    videoRetargetingTable.add(4, wrapper);
                } else if (ql.SBQQ__Quantity__c == NULL && int_Quantity <> 0 && quote.Multiple_Years_Commitment__c) {
                    wrapper = wrapper.clone();
                    videoRetargetingTable.add(4, wrapper);
                }
                if (wrapper != null && ql != null) {
                    wrapper.notes = TemplateUtilities.escapeNotesString(ql.Notes__c);
                }
                showVideoRetargetingTable = single;
                videoRetargetingTable.add(4, wrapper);
            }
            else if (ql.term__c == 5 && contractTermYears > 4) {
                if (int_Quantity > 0 && quote.Multiple_Years_Commitment__c && int_Quantity <> 0) {
                    Date startDate = TemplateUtilities.getStartDateFromQL(ql, 5);
                    Date endDate = TemplateUtilities.getEndDateFromQL(ql, 5);
                    wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Number_of_Views__c, ql.SBQQ__NetTotal__c, startDate, endDate, startDate, endDate);
                    videoRetargetingTable.add(5, wrapper);
                } else if (ql.SBQQ__Quantity__c == NULL && int_Quantity <> 0 && quote.Multiple_Years_Commitment__c) {
                    wrapper = wrapper.clone();
                    videoRetargetingTable.add(5, wrapper);
                }
                if (wrapper != null && ql != null) {
                    wrapper.notes = TemplateUtilities.escapeNotesString(ql.Notes__c);
                }
                showVideoRetargetingTable = single;
                videoRetargetingTable.add(5, wrapper);
            }
            wrapper.quantity = int_Quantity;
        }
    }
*/
    // --- Elite Meetings Alliance --- //
    public void createEliteMeetings(SBQQ__QuoteLine__c obj_QL, Decimal int_Quantity, Boolean boo_MYD, SBQQ__Quote__c obj_quote) {
        QLWrapper wrapper = NULL;
        Date startDate = TemplateUtilities.getStartDateFromQL(obj_QL, obj_QL.term__c);
        Date endDate = TemplateUtilities.getEndDateFromQL(obj_QL, obj_QL.term__c);
        if (int_Quantity <> 0) {
            if (obj_QL.term__c == 1 || (boo_MYD && obj_QL.term__c > 1)) {
                if(quote.Contract_Remaining_Term__c > 1 && !quote.Multiple_Years_Commitment__c && obj_QL.term__c == 1 && quote.HC_Logo_Conditional_Print__c == 'true') {
                        Map<Integer, SBQQ__QuoteLineGroup__c> map_quoteLineGroups = MapreturnDates();
                        for(QLTable table: eventTable.QLTables) {
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
                    else {
                            wrapper = new QLWrapper(obj_QL.SBQQ__ProductName__c, obj_QL.Location_Text__c, obj_QL.SBQQ__NetTotal__c, startDate, endDate, startDate, endDate);
                    }
                    showEmiTable = single;
                }
            }
            if (wrapper != null && obj_QL != null) {
                wrapper.notes = TemplateUtilities.escapeNotesString(obj_QL.Notes__c);
                emiTable.add((Integer)obj_QL.term__c, wrapper);
                wrapper.quantity = int_Quantity;
            }
        }

    // --- Reporting & Analytics --- //
    public void createReportingAndAnalytics(SBQQ__QuoteLine__c obj_QL, Decimal int_Quantity, Boolean boo_MYD, SBQQ__Quote__c obj_Quote) {
        QLWrapper wrapper = NULL;
        Date startDate = TemplateUtilities.getStartDateFromQL(obj_QL, obj_QL.term__c);
        Date endDate = TemplateUtilities.getEndDateFromQL(obj_QL, obj_QL.term__c);

        if (int_Quantity <> 0) {
            if(obj_QL.term__c == 1 || (boo_MYD && obj_QL.term__c > 1)) {
                if(quote.Contract_Remaining_Term__c > 1 && !quote.Multiple_Years_Commitment__c && obj_QL.term__c == 1 && quote.HC_Logo_Conditional_Print__c == 'true') {
                    Map<Integer, SBQQ__QuoteLineGroup__c> map_quoteLineGroups = MapreturnDates();
                    for(QLTable table : eventTable.QLTables) {
                        for(QLTable tab : reportingTable.QLTables) {
                            if (tab.year == table.year) {
                                QLWrapper wrapperTemp = NULL;
                                if(tab.year == 1) {
                                    wrapperTemp = new QLWrapper(obj_QL.SBQQ__ProductName__c, int_Quantity, obj_QL.Enter_Venue_Codes__c, obj_QL.SBQQ__NetTotal__c, startDate, endDate, startDate, endDate);
                                } else {
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
                } else {
                    wrapper = new QLWrapper(obj_QL.SBQQ__ProductName__c, int_Quantity, obj_QL.Enter_Venue_Codes__c, obj_QL.SBQQ__NetTotal__c, startDate, endDate, startDate, endDate);
                }
                showReportingTable = single;
            }
        }
        if (wrapper != null && obj_QL != null) {
            wrapper.notes = TemplateUtilities.escapeNotesString(obj_QL.Notes__c);
            reportingTable.add((Integer)obj_QL.term__c, wrapper);
            wrapper.quantity = int_Quantity;
        }
    }

    //
    //         }
    //         else if (ql.term__c == 2 && contractTermYears > 1) {
    //             Date startDate = TemplateUtilities.getStartDateFromQL(ql, 2);
    //             Date endDate = TemplateUtilities.getEndDateFromQL(ql, 2);
    //             if (int_Quantity > 0 && quote.Multiple_Years_Commitment__c && int_Quantity <> 0) {
    //                 wrapper = new QLWrapper(ql.SBQQ__ProductName__c, int_Quantity, ql.Enter_Venue_Codes__c, ql.SBQQ__NetTotal__c, startDate, endDate, startDate, endDate);
    //                 reportingTable.add(2, wrapper);
    //             } else if (ql.SBQQ__Quantity__c == NULL && int_Quantity <> 0 && quote.Multiple_Years_Commitment__c) {
    //                 wrapper = wrapper.clone();
    //                 reportingTable.add(2, wrapper);
    //             }
    //             if (wrapper != null && ql != null) {
    //                 wrapper.notes = TemplateUtilities.escapeNotesString(ql.Notes__c);
    //             }
    //             showReportingTable = single;
    //             reportingTable.add(2, wrapper);
    //         }
    //         else if (ql.term__c == 3 && contractTermYears > 2) {
    //             Date startDate = TemplateUtilities.getStartDateFromQL(ql, 3);
    //             Date endDate = TemplateUtilities.getEndDateFromQL(ql, 3);
    //             if (int_Quantity > 0 && quote.Multiple_Years_Commitment__c && int_Quantity <> 0) {
    //                 wrapper = new QLWrapper(ql.SBQQ__ProductName__c, int_Quantity, ql.Enter_Venue_Codes__c, ql.SBQQ__NetTotal__c, startDate, endDate, startDate, endDate);
    //                 reportingTable.add(3, wrapper);
    //             } else if (ql.SBQQ__Quantity__c == NULL && int_Quantity <> 0 && quote.Multiple_Years_Commitment__c) {
    //                 wrapper = wrapper.clone();
    //                 reportingTable.add(3, wrapper);
    //             }
    //             if (wrapper != null && ql != null) {
    //                 wrapper.notes = TemplateUtilities.escapeNotesString(ql.Notes__c);
    //             }
    //             showReportingTable = single;
    //             reportingTable.add(3, wrapper);
    //         }
    //         else if (ql.term__c == 4 && contractTermYears > 3) {
    //             Date startDate = TemplateUtilities.getStartDateFromQL(ql, 4);
    //             Date endDate = TemplateUtilities.getEndDateFromQL(ql, 4);
    //             if (int_Quantity > 0 && quote.Multiple_Years_Commitment__c && int_Quantity <> 0) {
    //                 wrapper = new QLWrapper(ql.SBQQ__ProductName__c, int_Quantity, ql.Enter_Venue_Codes__c, ql.SBQQ__NetTotal__c, startDate, endDate, startDate, endDate);
    //                 reportingTable.add(4, wrapper);
    //             } else if (ql.SBQQ__Quantity__c == NULL && int_Quantity <> 0 && quote.Multiple_Years_Commitment__c) {
    //                 wrapper = wrapper.clone();
    //                 reportingTable.add(4, wrapper);
    //             }
    //             if (wrapper != null && ql != null) {
    //                 wrapper.notes = TemplateUtilities.escapeNotesString(ql.Notes__c);
    //             }
    //             showReportingTable = single;
    //             reportingTable.add(4, wrapper);
    //         }
    //         else if (ql.term__c == 5 && contractTermYears > 4) {
    //             Date startDate = TemplateUtilities.getStartDateFromQL(ql, 5);
    //             Date endDate = TemplateUtilities.getEndDateFromQL(ql, 5);
    //             if (int_Quantity > 0 && quote.Multiple_Years_Commitment__c && int_Quantity <> 0) {
    //                 wrapper = new QLWrapper(ql.SBQQ__ProductName__c, int_Quantity, ql.Enter_Venue_Codes__c, ql.SBQQ__NetTotal__c, startDate, endDate, startDate, endDate);
    //                 reportingTable.add(5, wrapper);
    //             } else if (ql.SBQQ__Quantity__c == NULL && int_Quantity <> 0 && quote.Multiple_Years_Commitment__c) {
    //                 wrapper = wrapper.clone();
    //                 reportingTable.add(5, wrapper);
    //             }
    //             if (wrapper != null && ql != null) {
    //                 wrapper.notes = TemplateUtilities.escapeNotesString(ql.Notes__c);
    //             }
    //             showReportingTable = single;
    //             reportingTable.add(5, wrapper);
    //         }
    //         wrapper.quantity = int_Quantity;
    //     }
    // }

    // --- Cvent Passkey, Transient & Lanyon Group --- //
    //public void createPasskeyTransientLanyon(SBQQ__QuoteLine__c ql, QLWrapper wrapper) {
    public void createPasskeyTransientLanyon(SBQQ__QuoteLine__c obj_QL, Decimal int_Quantity, Boolean boo_MYD, SBQQ__Quote__c obj_Quote) {
        QLWrapper wrapper = NULL;
        Date startDate = TemplateUtilities.getStartDateFromQL(obj_QL, obj_QL.term__c);
        Date endDate = TemplateUtilities.getEndDateFromQL(obj_QL, obj_QL.term__c);
        if (int_Quantity <> 0) {
            if(obj_QL.term__c == 1 || (boo_MYD && obj_QL.term__c > 1))  {
                if(quote.Contract_Remaining_Term__c > 1 && !quote.Multiple_Years_Commitment__c && obj_QL.term__c == 1 && quote.HC_Logo_Conditional_Print__c == 'true') {
                    Map<Integer, SBQQ__QuoteLineGroup__c> map_quoteLineGroups = MapreturnDates();
                    for(QLTable table : eventTable.QLTables) {
                        for(QLTable tab : passkeyTable.QLTables) {
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
                } else {
                    wrapper = new QLWrapper(obj_QL.SBQQ__ProductName__c, obj_QL.Product_Family__c, obj_QL.Unit__c, int_Quantity, obj_QL.SBQQ__NetTotal__c, startDate, endDate, startDate, endDate);
                }
                showPasskeyTable = single;
            }
        }
        if (wrapper != null && obj_QL != null) {
            wrapper.notes = TemplateUtilities.escapeNotesString(obj_QL.Notes__c);
            passkeyTable.add((Integer)obj_QL.term__c, wrapper);
            wrapper.quantity = int_Quantity;
        }
    }
    //         else if (ql.term__c == 2 && contractTermYears > 1) {
    //             startDate = TemplateUtilities.getStartDateFromQL(ql, 2);
    //             endDate = TemplateUtilities.getEndDateFromQL(ql, 2);
    //             if (int_Quantity > 0 && quote.Multiple_Years_Commitment__c && int_Quantity <> 0) {
    //                 wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Product_Family__c, ql.Unit__c, int_Quantity, ql.SBQQ__NetTotal__c, startDate, endDate, startDate, endDate);
    //                 passkeyTable.add(2, wrapper);
    //             } else if (ql.SBQQ__Quantity__c == NULL && int_Quantity <> 0 && quote.Multiple_Years_Commitment__c) {
    //                 wrapper = wrapper.clone();
    //                 passkeyTable.add(2, wrapper);
    //             }
    //             //wrapper.quantity = ql.SBQQ__Quantity__c;
    //             if (wrapper != null && ql != null) {
    //                 wrapper.notes = TemplateUtilities.escapeNotesString(ql.Notes__c);
    //             }
    //             showPasskeyTable = single;
    //             //passkeyTable.add(2, wrapper);
    //         }
    //         else if (ql.term__c == 3 && contractTermYears > 2) {
    //             startDate = TemplateUtilities.getStartDateFromQL(ql, 3);
    //             endDate = TemplateUtilities.getEndDateFromQL(ql, 3);
    //             if (int_Quantity > 0 && quote.Multiple_Years_Commitment__c && int_Quantity <> 0) {
    //                 wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Product_Family__c, ql.Unit__c, int_Quantity, ql.SBQQ__NetTotal__c, startDate, endDate, startDate, endDate);
    //                 passkeyTable.add(3, wrapper);
    //             } else if (ql.SBQQ__Quantity__c == NULL && int_Quantity <> 0 && quote.Multiple_Years_Commitment__c) {
    //                 wrapper = wrapper.clone();
    //                 passkeyTable.add(3, wrapper);
    //             }
    //             //wrapper.quantity = ql.SBQQ__Quantity__c;
    //             if (wrapper != null && ql != null) {
    //                 wrapper.notes = TemplateUtilities.escapeNotesString(ql.Notes__c);
    //             }
    //             showPasskeyTable = single;
    //             //passkeyTable.add(3, wrapper);
    //         }
    //         else if (ql.term__c == 4 && contractTermYears > 3) {
    //             startDate = TemplateUtilities.getStartDateFromQL(ql, 4);
    //             endDate = TemplateUtilities.getEndDateFromQL(ql, 4);
    //             if (int_Quantity > 0 && quote.Multiple_Years_Commitment__c && int_Quantity <> 0) {
    //                 wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Product_Family__c, ql.Unit__c, int_Quantity, ql.SBQQ__NetTotal__c, startDate, endDate, startDate, endDate);
    //                 passkeyTable.add(4, wrapper);
    //             } else if (ql.SBQQ__Quantity__c == NULL && int_Quantity <> 0 && quote.Multiple_Years_Commitment__c) {
    //                 wrapper = wrapper.clone();
    //                 passkeyTable.add(4, wrapper);
    //             }
    //             //wrapper.quantity = ql.SBQQ__Quantity__c;
    //             if (wrapper != null && ql != null) {
    //                 wrapper.notes = TemplateUtilities.escapeNotesString(ql.Notes__c);
    //             }
    //             showPasskeyTable = single;
    //             //reportingTable.add(4, wrapper);
    //         }
    //         else if (ql.term__c == 5 && contractTermYears > 4) {
    //             startDate = TemplateUtilities.getStartDateFromQL(ql, 5);
    //             endDate = TemplateUtilities.getEndDateFromQL(ql, 5);
    //             if (int_Quantity > 0 && quote.Multiple_Years_Commitment__c && int_Quantity <> 0) {
    //                 wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Product_Family__c, ql.Unit__c, int_Quantity, ql.SBQQ__NetTotal__c, startDate, endDate, startDate, endDate);
    //                 passkeyTable.add(5, wrapper);
    //             } else if (ql.SBQQ__Quantity__c == NULL && int_Quantity <> 0 && quote.Multiple_Years_Commitment__c) {
    //                 wrapper = wrapper.clone();
    //                 passkeyTable.add(5, wrapper);
    //             }
    //             //wrapper.quantity = ql.SBQQ__Quantity__c;
    //             if (wrapper != null && ql != null) {
    //                 wrapper.notes = TemplateUtilities.escapeNotesString(ql.Notes__c);
    //             }
    //             showPasskeyTable = single;
    //             //passkeyTable.add(5, wrapper);
    //         }
    //         wrapper.quantity = int_Quantity;
    //     }
    // }

    // --- Listing Advertisement(s), Software, Services & CONNECT --- //
    public void createListingAdsSoftwareServicesCONNECT(SBQQ__QuoteLine__c obj_QL, Decimal int_Quantity, Boolean boo_MYD, SBQQ__Quote__c obj_Quote) {
        QLWrapper wrapper = NULL;
        Date startDate = TemplateUtilities.getStartDateFromQL(obj_QL, obj_QL.term__c);
        Date endDate = TemplateUtilities.getEndDateFromQL(obj_QL, obj_QL.term__c);

        if (int_Quantity <> 0) {
            if(obj_QL.term__c == 1 || (boo_MYD && obj_QL.term__c >1))
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
                                    wrapperTemp = new QLWrapper(obj_QL.SBQQ__ProductName__c, startDate, endDate, obj_QL.SBQQ__NetTotal__c,obj_QL.MMA_Text__c);
                                }else{
                                    wrapperTemp = new QLWrapper(obj_QL.SBQQ__ProductName__c, map_quoteLineGroups.get((Integer)table.year).SBQQ__StartDate__c, map_quoteLineGroups.get((Integer)table.year).SBQQ__EndDate__c, obj_QL.SBQQ__NetTotal__c,obj_QL.MMA_Text__c);
                                }
                                if (wrapperTemp != null) {
                                    wrapperTemp.notes = TemplateUtilities.escapeNotesString(obj_QL.Notes__c);
                                    wrapperTemp.quantity = int_Quantity;
                                    tab.quoteLines.add(wrapperTemp);
                                }
                            }
                        }
                    }
                } else {
                    wrapper = new QLWrapper(obj_QL.SBQQ__ProductName__c, startDate, endDate, obj_QL.SBQQ__NetTotal__c,obj_QL.MMA_Text__c);
                }
                showListingAdsTable = single;
            }
        }
        //add notes check wrapper
        if (wrapper != null && obj_QL != null) {
            wrapper.notes = TemplateUtilities.escapeNotesString(obj_QL.Notes__c);
            listingAdsTable.add((Integer)obj_QL.term__c, wrapper);
            wrapper.quantity = int_Quantity;
        }
    }
  
    // --- Social Tables --- //
    public void createSocialTables(SBQQ__QuoteLine__c obj_QL, Decimal int_Quantity, Boolean boo_MYD, SBQQ__Quote__c obj_Quote,Decimal priceTotal) {
       QLWrapper wrapper = NULL;
        Date startDate = TemplateUtilities.getStartDateFromQL(obj_QL, obj_QL.term__c);
        Date endDate = TemplateUtilities.getEndDateFromQL(obj_QL, obj_QL.term__c);
        if (int_Quantity <> 0) {
            if(obj_QL.term__c == 1 || (boo_MYD && obj_QL.term__c > 1))  {
                if(quote.Contract_Remaining_Term__c > 1 && !quote.Multiple_Years_Commitment__c && obj_QL.term__c == 1 && quote.HC_Logo_Conditional_Print__c == 'true') {
                    Map<Integer, SBQQ__QuoteLineGroup__c> map_quoteLineGroups = MapreturnDates();
                    for(QLTable table : eventTable.QLTables) {
                        for(QLTable tab : socialTablesTable.QLTables) {
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
                } else {
                    wrapper = new QLWrapper(obj_QL.SBQQ__ProductName__c, obj_QL.Product_Family__c, obj_QL.Unit__c, int_Quantity, priceTotal, startDate, endDate, startDate, endDate);
                }
                showSocialTablesTable = single;
            }
        }
        if (wrapper != null && obj_QL != null) {
            wrapper.notes = TemplateUtilities.escapeNotesString(obj_QL.Notes__c);
            socialTablesTable.add((Integer)obj_QL.term__c, wrapper);
            wrapper.quantity = int_Quantity;
        }
    }

    // --- Merchant --- //


    /*
    public void createMerchant(SBQQ__QuoteLine__c obj_QL, Decimal int_Quantity, Boolean boo_MYD, SBQQ__Quote__c obj_Quote) {
        QLWrapper wrapper = NULL;
        if(int_Quantity <> 0) {
            wrapper = new QLWrapper(obj_QL.SBQQ__ProductName__c, int_Quantity, obj_QL.SBQQ__NetTotal__c);
            showMerchantTable = single;
        }
        if (wrapper != null && obj_QL != null) {
            wrapper.notes = TemplateUtilities.escapeNotesString(obj_QL.Notes__c);
            merchantTable.add((Integer)obj_QL.term__c, wrapper);
            wrapper.quantity = int_Quantity;
        }
    }*/

    public void createMerchant(SBQQ__QuoteLine__c ql, QLWrapper wrapper) {
        Decimal int_Quantity = 0;
        if(ql.SBQQ__Product__r.Show_True_Quantity__c)
        {
            int_Quantity = ql.SBQQ__Quantity__c;
        }
        else
        {
            int_Quantity = ql.SBQQ__EffectiveQuantity__c;
        }
        if(ql.SBQQ__EffectiveQuantity__c <> 0) {
            wrapper = new QLWrapper(ql.SBQQ__ProductName__c, int_Quantity, ql.SBQQ__NetTotal__c);
            if(int_Quantity <> 0) {
                showMerchantTable = single;
                if (wrapper != null && ql != null) {
                    wrapper.notes = TemplateUtilities.escapeNotesString(ql.Notes__c);
                }
                merchantTable.add(1, wrapper);
            }
            wrapper.quantity = int_Quantity;
        }
    }

    // --- OnDemand --- //
    /*
    public void createOnDemand(SBQQ__QuoteLine__c obj_QL, Decimal int_Quantity, Boolean boo_MYD, SBQQ__Quote__c obj_Quote){
        QLWrapper wrapper = NULL;
        if(int_Quantity <> 0) {
            wrapper = new QLWrapper(obj_QL.SBQQ__ProductName__c, int_Quantity, obj_QL.Rack_Rate__c, obj_QL.Rack_Rate__c * int_Quantity, obj_QL.SBQQ__NetPrice__c, obj_QL.SBQQ__NetTotal__c, obj_QL.Rack_Rate__c * int_Quantity - obj_QL.SBQQ__NetTotal__c);
            showOnDemandTable = single;
        }
        if (wrapper != null && obj_QL != null) {
            wrapper.notes = TemplateUtilities.escapeNotesString(obj_QL.Notes__c);
            onDemandTable.add((Integer)obj_QL.term__c, wrapper);
            wrapper.quantity = int_Quantity;
        }
    }*/

    public void createOnDemand(SBQQ__QuoteLine__c ql, QLWrapper wrapper) {
        Decimal int_Quantity = 0;
        if(ql.SBQQ__Product__r.Show_True_Quantity__c)
        {
            int_Quantity = ql.SBQQ__Quantity__c;
        }
        else
        {
            int_Quantity = ql.SBQQ__EffectiveQuantity__c;
        }
        if(ql.SBQQ__EffectiveQuantity__c <> 0) {
            wrapper = new QLWrapper(ql.SBQQ__ProductName__c, int_Quantity, ql.Rack_Rate__c, ql.Rack_Rate__c * int_Quantity, ql.SBQQ__NetPrice__c, ql.SBQQ__NetTotal__c, ql.Rack_Rate__c * int_Quantity - ql.SBQQ__NetTotal__c);
            if(int_Quantity <> 0) {
                showOnDemandTable = single;
                if (wrapper != null && ql != null) {
                    wrapper.notes = TemplateUtilities.escapeNotesString(ql.Notes__c);
                }
                onDemandTable.add(1, wrapper);
            }
            wrapper.quantity = int_Quantity;
        }
    }

    // --- Professional --- //
    /*
    public void createProfessional(SBQQ__QuoteLine__c obj_QL, Decimal int_Quantity, Boolean boo_MYD, SBQQ__Quote__c obj_Quote) {
        QLWrapper wrapper = NULL;
        if(int_Quantity <> 0) {
            wrapper = new QLWrapper(obj_QL.SBQQ__ProductName__c, obj_QL.SBQQ__EffectiveQuantity__c, obj_QL.Rack_Rate__c, obj_QL.Rack_Rate__c * obj_QL.SBQQ__EffectiveQuantity__c, obj_QL.SBQQ__NetPrice__c, obj_QL.SBQQ__NetTotal__c, obj_QL.Rack_Rate__c * obj_QL.SBQQ__EffectiveQuantity__c - obj_QL.SBQQ__NetTotal__c);
            showProfessionalServicesTable = single;
        }
        if (wrapper != null && obj_QL != null) {
            wrapper.notes = TemplateUtilities.escapeNotesString(obj_QL.Notes__c);
            professionalServicesTable.add((Integer)obj_QL.term__c, wrapper);
            wrapper.quantity = int_Quantity;
        }
    }*/

    public void createProfessional(SBQQ__QuoteLine__c ql, QLWrapper wrapper) {
        Decimal int_Quantity = 0;
        if(ql.SBQQ__Product__r.Show_True_Quantity__c)
        {
            int_Quantity = ql.SBQQ__Quantity__c;
        }
        else
        {
            int_Quantity = ql.SBQQ__EffectiveQuantity__c;
        }
        if(ql.SBQQ__EffectiveQuantity__c <> 0) {
            wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.SBQQ__EffectiveQuantity__c, ql.Rack_Rate__c, ql.Rack_Rate__c * ql.SBQQ__EffectiveQuantity__c, ql.SBQQ__NetPrice__c, ql.SBQQ__NetTotal__c, ql.Rack_Rate__c * ql.SBQQ__EffectiveQuantity__c - ql.SBQQ__NetTotal__c);
            if(int_Quantity <> 0) {
                showProfessionalServicesTable = single;
                if (wrapper != null && ql != null) {
                    wrapper.notes = TemplateUtilities.escapeNotesString(ql.Notes__c);
                }
                professionalServicesTable.add(1, wrapper);
            }
            wrapper.quantity = int_Quantity;
        }
    }

    // --- EventTable --- //
    public void createEventTable(SBQQ__QuoteLine__c ql, QLWrapper wrapper) {
        Decimal int_Quantity = 0;
        if(ql.SBQQ__Product__r.Show_True_Quantity__c)
        {
            int_Quantity = ql.SBQQ__Quantity__c;
        }
        else
        {
            int_Quantity = ql.SBQQ__EffectiveQuantity__c;
        }
        /** usage skus to put in separate table
        CV-SW-EC-EVT-EXPPREPAYREG
        CV-SW-EC-EVT-PRPYMTREGF
        CV-SW-EC-EVT-USERFUL
        CV-SW-EC-EVT-USERF
        CV-SW-EC-EVT-PRPYMTTRNF
        CV-SW-EC-EVT-PRPYMTEVTF
        CV-SW-EC-EVT-ADDULOG
         */
        System.debug(System.LoggingLevel.INFO, 'in create event table');
        Decimal rackRate;
        /** PANKAJ**/
            Decimal quantity = ql.SBQQ__Quantity__c;
            System.debug('>>> EventTable quantity: '+quantity);
            //CJ---

            Decimal effectiveQuantity = int_Quantity;
            Decimal netPrice = ql.SBQQ__NetPrice__c;
            Decimal netTotal = ql.SBQQ__NetTotal__c;
            if(ql.SBQQ__PricingMethod__c == 'Block' && netPrice < 0) {
                effectiveQuantity = -1 * effectiveQuantity;
                netPrice = Math.abs(netPrice);
            }
            if(ql.SBQQ__DiscountScheduleType__c == 'Slab') {
                effectiveQuantity = ql.SBQQ__Quantity__c;
                if(ql.SBQQ__PriorQuantity__c > 0) {
                    effectiveQuantity = ql.SBQQ__Quantity__c - ql.SBQQ__PriorQuantity__c;
                }
                netPrice = Math.abs(netPrice / effectiveQuantity);
                rackRate = rackRate / effectiveQuantity;
            }
            System.debug('>>> EventTable effectiveQuantity: '+effectiveQuantity);
        /*****/
        if((!quote.Multiple_Years_Commitment__c && !ql.SBQQ__Optional__c ) || quote.Multiple_Years_Commitment__c) {
            System.debug('CJ---  start1');
            //this was added
            
            if(effectiveQuantity <> 0 || ql.SBQQ__ProductCode__c != 'CV-SW-EC-EVT-CCMOBAPP' || ql.SBQQ__ProductCode__c == 'CV-SW-EC-EVT-OAPREM'){
                System.debug('CJ---  start2');

                if (ql.term__c == 1) {
                    System.debug(System.LoggingLevel.INFO, 'create year 1');
                    System.debug('ql.SBQQ__ProductCode__c>>>>'+ql.SBQQ__ProductCode__c);
                    if (!productCodes.containsKey(ql.SBQQ__ProductCode__c)) {
                        rackRate = 0;
                        if (ql.SBQQ__ListPrice__c <> 0 && ql.SBQQ__EffectiveQuantity__c <> 0) {
                        // NEW // if (ql.SBQQ__ListPrice__c <> 0 && effectiveQuantity <> 0) {
                            rackRate = ql.Rack_Rate__c;
                        }
                        //wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.SBQQ__EffectiveQuantity__c, rackRate, rackRate * ql.SBQQ__Quantity__c, ql.SBQQ__NetPrice__c, ql.SBQQ__NetTotal__c, rackRate * ql.SBQQ__EffectiveQuantity__c - ql.SBQQ__NetTotal__c);
                        wrapper = new QLWrapper(ql.SBQQ__ProductName__c, effectiveQuantity, rackRate, rackRate * quantity, netPrice, netTotal, rackRate * ql.SBQQ__EffectiveQuantity__c - netTotal);
                        
                    } else {
                        wrapper = aggregateCrowdCompass(ql, 1, quoteLines);
                    }
                    if (wrapper != null && ql != null) {
                        wrapper.notes = TemplateUtilities.escapeNotesString(ql.Notes__c);
                    }
                    if (wrapper != NULL && wrapper.quantity != 0) {
                        eventMatrixTable.add(1, wrapper);
                        eventTable.add(1, wrapper);
                    }
                    showEventTable = single;
                }
                else if (ql.term__c == 2 && effectiveQuantity != NULL  && (quote.Multiple_Years_Commitment__c || quote.Current_Year__c == 2) ) {
                    System.debug(System.LoggingLevel.INFO, 'create year 2');
                    if (!productCodes.containsKey(ql.SBQQ__ProductCode__c)) {
                        rackRate = ql.Rack_Rate__c;
                        if (ql.SBQQ__ListPrice__c != NULL && ql.SBQQ__ListPrice__c <> 0) {
                            rackRate = (ql.Rack_Rate__c / ql.SBQQ__ListPrice__c) * ql.SBQQ__ListPrice__c;
                        }
                        //wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Year_2_Effective_Quantity__c, rackRate, rackRate * ql.Year_2_Effective_Quantity__c, ql.Year_2_Effective_Amount__c / ql.Year_2_Effective_Quantity__c, ql.Year_2_Effective_Amount__c, rackRate * ql.Year_2_Effective_Quantity__c - ql.Year_2_Effective_Amount__c);
                        wrapper = new QLWrapper(ql.SBQQ__ProductName__c, effectiveQuantity, rackRate, rackRate * effectiveQuantity, netPrice, netTotal, rackRate * ql.SBQQ__EffectiveQuantity__c - netTotal);
                        
                    } else {
                        wrapper = aggregateCrowdCompass(ql, 2, quoteLines);
                    }
                    if (wrapper != null && ql != null) {
                        wrapper.notes = TemplateUtilities.escapeNotesString(ql.Notes__c);
                    }
                    if (wrapper != NULL && wrapper.quantity != 0) {
                        eventMatrixTable.add(2, wrapper);
                        eventTable.add(2, wrapper);
                    }
                    System.debug('CJ---  eventTable'+ eventTable);
                }
                else if (ql.term__c == 3 && effectiveQuantity != NULL && (quote.Multiple_Years_Commitment__c || quote.Current_Year__c == 3)) {
                    System.debug(System.LoggingLevel.INFO, 'create year 3');
                    if (!productCodes.containsKey(ql.SBQQ__ProductCode__c)) {
                        rackRate = ql.Rack_Rate__c;
                        if (ql.SBQQ__ListPrice__c != NULL && ql.SBQQ__ListPrice__c <> 0) {
                            rackRate = (ql.Rack_Rate__c / ql.SBQQ__ListPrice__c) * ql.SBQQ__ListPrice__c;
                        }
                        //wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Year_3_Effective_Quantity__c, rackRate, rackRate * ql.Year_3_Effective_Quantity__c, ql.Year_3_Effective_Amount__c / ql.Year_3_Effective_Quantity__c, ql.Year_3_Effective_Amount__c, rackRate * ql.Year_3_Effective_Quantity__c - ql.Year_3_Effective_Amount__c);
                        wrapper = new QLWrapper(ql.SBQQ__ProductName__c, effectiveQuantity, rackRate, rackRate * effectiveQuantity, netPrice, netTotal, rackRate * ql.SBQQ__EffectiveQuantity__c - netTotal);
                        //eventTable.add(3, wrapper);
                    } else {
                        wrapper = aggregateCrowdCompass(ql, 3, quoteLines);
                    }
                    if (wrapper != null && ql != null) {
                        wrapper.notes = TemplateUtilities.escapeNotesString(ql.Notes__c);
                    }
                    if (wrapper != NULL && wrapper.quantity != 0) {
                        eventMatrixTable.add(3, wrapper);
                        eventTable.add(3, wrapper);
                    }
                }
                else if (ql.term__c == 4 && effectiveQuantity != NULL && (quote.Multiple_Years_Commitment__c || quote.Current_Year__c == 4)) {
                    System.debug(System.LoggingLevel.INFO, 'create year 4');
                    if (!productCodes.containsKey(ql.SBQQ__ProductCode__c)) {
                        rackRate = ql.Rack_Rate__c;
                        if (ql.SBQQ__ListPrice__c != NULL && ql.SBQQ__ListPrice__c <> 0) {
                            rackRate = (ql.Rack_Rate__c / ql.SBQQ__ListPrice__c) * ql.SBQQ__ListPrice__c;
                        }
                        //wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Year_4_Effective_Quantity__c, rackRate, rackRate * ql.Year_4_Effective_Quantity__c, ql.Year_4_Effective_Amount__c / ql.Year_4_Effective_Quantity__c, ql.Year_4_Effective_Amount__c, rackRate * ql.Year_4_Effective_Quantity__c - ql.Year_4_Effective_Amount__c);
                        wrapper = new QLWrapper(ql.SBQQ__ProductName__c, effectiveQuantity, rackRate, rackRate * effectiveQuantity, netPrice, netTotal, rackRate * ql.SBQQ__EffectiveQuantity__c - netTotal);
                        //eventTable.add(4, wrapper);
                    } else {
                        wrapper = aggregateCrowdCompass(ql, 4, quoteLines);
                    }
                    if (wrapper != null && ql != null) {
                        wrapper.notes = TemplateUtilities.escapeNotesString(ql.Notes__c);
                    }
                    if (wrapper != NULL && wrapper.quantity != 0) {
                        eventMatrixTable.add(4, wrapper);
                        eventTable.add(4, wrapper);
                    }
                }
                else if (ql.term__c == 5 && effectiveQuantity != NULL &&(quote.Multiple_Years_Commitment__c || quote.Current_Year__c == 5)) {
                    System.debug(System.LoggingLevel.INFO, 'create year 5');
                    if (!productCodes.containsKey(ql.SBQQ__ProductCode__c)) {
                        rackRate = ql.Rack_Rate__c;
                        if (ql.SBQQ__ListPrice__c != NULL && ql.SBQQ__ListPrice__c <> 0) {
                            rackRate = (ql.Rack_Rate__c / ql.SBQQ__ListPrice__c) * ql.SBQQ__ListPrice__c;
                        }
                        //wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Year_5_Effective_Quantity__c, rackRate, rackRate * ql.Year_5_Effective_Quantity__c, ql.Year_5_Effective_Amount__c / ql.Year_5_Effective_Quantity__c, ql.Year_5_Effective_Amount__c, rackRate * ql.Year_5_Effective_Quantity__c - ql.Year_5_Effective_Amount__c);
                        wrapper = new QLWrapper(ql.SBQQ__ProductName__c, effectiveQuantity, rackRate, rackRate * effectiveQuantity, netPrice, netTotal, rackRate * ql.SBQQ__EffectiveQuantity__c - netTotal);
                        //eventTable.add(5, wrapper);
                    } else {
                        wrapper = aggregateCrowdCompass(ql, 5, quoteLines);
                    }
                    if (wrapper != null && ql != null) {
                        wrapper.notes = TemplateUtilities.escapeNotesString(ql.Notes__c);
                    }
                    if (wrapper != NULL && wrapper.quantity != 0) {
                        eventMatrixTable.add(5, wrapper);
                        eventTable.add(5, wrapper);
                    }
                }
            }
        }
    }
    // --- OveragesTable --- //
    public void createOveragesTable(SBQQ__QuoteLine__c obj_QL, Decimal int_Quantity, Boolean boo_MYD, SBQQ__Quote__c obj_Quote) {
        QLWrapper wrapper = NULL;
        if(int_Quantity <> 0 && obj_QL.Overage_Fee__c != NULL && obj_QL.Overage_Fee__c > 0) {
            if(quote.Contract_Remaining_Term__c > 1 && !quote.Multiple_Years_Commitment__c && obj_QL.term__c == 1 && quote.HC_Logo_Conditional_Print__c == 'true') {
                for(QLTable table : eventTable.QLTables) {
                    for(QLTable tab: overagesTable.QLTables) {
                        if (tab.year == table.year) {
                            tab.quoteLines.add(new QLWrapper(obj_QL.SBQQ__ProductName__c, obj_QL.Overage_Fee__c));
                        }
                    }
                }
            }
            else if((!quote.Multiple_Years_Commitment__c && !obj_QL.SBQQ__Optional__c ) || quote.Multiple_Years_Commitment__c) {
                if (obj_QL.term__c == 1 && int_Quantity <> 0 && obj_QL.Overage_Fee__c != NULL && obj_QL.Overage_Fee__c > 0) {
                    wrapper = new QLWrapper(obj_QL.SBQQ__ProductName__c, obj_QL.Overage_Fee__c);
                    overagesTable.add(1, wrapper);
                }
                else if (obj_QL.term__c == 2 && contractTermYears > 1 && quote.Multiple_Years_Commitment__c && int_Quantity <> 0 && obj_QL.Overage_Fee__c != NULL && obj_QL.Overage_Fee__c > 0) {
                    wrapper = new QLWrapper(obj_QL.SBQQ__ProductName__c, obj_QL.Overage_Fee__c);
                    overagesTable.add(2, wrapper);
                }
                else if (obj_QL.term__c == 3 && contractTermYears > 2 && quote.Multiple_Years_Commitment__c && int_Quantity <> 0 && obj_QL.Overage_Fee__c != NULL && obj_QL.Overage_Fee__c > 0) {
                    wrapper = new QLWrapper(obj_QL.SBQQ__ProductName__c, obj_QL.Overage_Fee__c);
                    overagesTable.add(3, wrapper);
                }
                else if (obj_QL.term__c == 4 && contractTermYears > 3 && quote.Multiple_Years_Commitment__c && int_Quantity <> 0 && obj_QL.Overage_Fee__c != NULL && obj_QL.Overage_Fee__c > 0) {
                    wrapper = new QLWrapper(obj_QL.SBQQ__ProductName__c, obj_QL.Overage_Fee__c);
                    overagesTable.add(4, wrapper);
                }
                else if (obj_QL.term__c == 5 && contractTermYears > 4 && quote.Multiple_Years_Commitment__c && int_Quantity <> 0 && obj_QL.Overage_Fee__c != NULL && obj_QL.Overage_Fee__c > 0) {
                    wrapper = new QLWrapper(obj_QL.SBQQ__ProductName__c, obj_QL.Overage_Fee__c);
                    overagesTable.add(5, wrapper);
                }
            }
        }

    }
    /*
    public void createOveragesTable(SBQQ__QuoteLine__c ql, QLWrapper wrapper) {
        Decimal int_Quantity = 0;
        if(ql.SBQQ__Product__r.Show_True_Quantity__c)
        {
            int_Quantity = ql.SBQQ__Quantity__c;
        }
        else
        {
            int_Quantity = ql.SBQQ__EffectiveQuantity__c;
        }
        Integer contractTermYears = quote.Contract_Remaining_Term__c.intValue();
        if (ql.term__c == 1 && int_Quantity <> 0 && ql.Overage_Fee__c != NULL && ql.Overage_Fee__c > 0) {
            wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Overage_Fee__c);
            overagesTable.add(1, wrapper);
        }
        else if (ql.term__c == 2 && contractTermYears > 1 && quote.Multiple_Years_Commitment__c && int_Quantity <> 0 && ql.Overage_Fee__c != NULL && ql.Overage_Fee__c > 0) {
            wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Overage_Fee__c);
            overagesTable.add(2, wrapper);
        }
        else if (ql.term__c == 3 && contractTermYears > 2 && quote.Multiple_Years_Commitment__c && int_Quantity <> 0 && ql.Overage_Fee__c != NULL && ql.Overage_Fee__c > 0) {
            wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Overage_Fee__c);
            overagesTable.add(3, wrapper);
        }
        else if (ql.term__c == 4 && contractTermYears > 3 && quote.Multiple_Years_Commitment__c && int_Quantity <> 0 && ql.Overage_Fee__c != NULL && ql.Overage_Fee__c > 0) {
            wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Overage_Fee__c);
            overagesTable.add(4, wrapper);
        }
        else if (ql.term__c == 5 && contractTermYears > 4 && quote.Multiple_Years_Commitment__c && int_Quantity <> 0 && ql.Overage_Fee__c != NULL && ql.Overage_Fee__c > 0) {
            wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Overage_Fee__c);
            overagesTable.add(5, wrapper);
        }
    } */

    // --- HCSummaryTable --- //
    public void createHCSummaryTable(MultiYearQLTable eventTable, Decimal convenienceFee) {
        if (quote.Multiple_Years_Commitment__c)
        {
            System.debug('CJ--- 1 ' + eventTable.QLTables.size());
            for (QLTable table : eventTable.QLTables)
            {
                System.debug('CJ--- 2 '+table);
                for (QLTable tab : hcSummaryTable.QLTables) {
                    System.debug('CJ--- 3 '+tab);
                    if (tab.year == table.year) {
                        tab.quoteLines.add(new QLWrapper('Total Price', table.rackTotal, true));
                        tab.quoteLines.add(new QLWrapper('Discount', table.savingsTotal));
                        if (convenienceFee > 0) {
                            //tab.quoteLines.add(new QLWrapper('Covenience Fee', convenienceFee));
                        
                        tab.quoteLines.add(new QLWrapper('Total Fees Payable in ' +currencySymbol, (table.linesTotal-convenienceFee)));
                        }
                        else
                        {
                           tab.quoteLines.add(new QLWrapper('Total Fees Payable in ' +currencySymbol, table.linesTotal)); 
                        }
                    }
                }
            }
        }
        else
        {
            for (QLTable table : eventTable.QLTables)
            {
                for (QLTable tab : hcSummaryTable.QLTables) {
                    //if (tab.year == table.year) {
                        tab.quoteLines.add(new QLWrapper('Total Price', table.rackTotal, true));
                        tab.quoteLines.add(new QLWrapper('Discount', table.savingsTotal));
                        if (convenienceFee > 0) {
                            //tab.quoteLines.add(new QLWrapper('Covenience Fee', convenienceFee));
                        
                        tab.quoteLines.add(new QLWrapper('Total Fees Payable in ' +currencySymbol, (table.linesTotal-convenienceFee)));
                        }
                        else
                        {
                           tab.quoteLines.add(new QLWrapper('Total Fees Payable in ' +currencySymbol, table.linesTotal)); 
                        }
                    //}
                }
            }
        }
    }
            /*
            for (QLTable table : eventTable.QLTables) {
                for (QLTable tab : hcSummaryTable.QLTables) {
                    if (tab.year == table.year) {
                        System.debug('tab: ' + tab + ' table: ' + table);
                        tab.quoteLines.add(new QLWrapper('Total Price', table.rackTotal, true));
                        tab.quoteLines.add(new QLWrapper('Discount', table.savingsTotal.setScale(2)));
                        if (convenienceFee > 0) {
                            tab.quoteLines.add(new QLWrapper('Covenience Fee', convenienceFee));
                        }
                        tab.quoteLines.add(new QLWrapper('Total Fees Payable in ' +currencySymbol, table.linesTotal));

                    }
                }
                //hcSummaryTable.QLTables.get(Integer.valueof(table.year-1)).quoteLines.add(new QLWrapper('Total Price', table.linesTotal));
            }
        } */

    Decimal aggregateConvenienceFee(List<SBQQ__QuoteLine__c> quoteLines) {

        Decimal result = 0;

        for (SBQQ__QuoteLine__c ql : quoteLines) {
            if (ql.SBQQ__ProductCode__c == 'CV-AD-HC-CSN-CONV') { //Replaced SKU - Requested By Lauren --- OLD SKU --->>> CV-OT-HC-CSN-CVNCFEE
                result += ql.SBQQ__NetTotal__c;
            }
        }

        return result;
    }

    public QLWrapper aggregateCrowdCompass(SBQQ__QuoteLine__c quoteLine, Decimal year, List<SBQQ__QuoteLine__c> quoteLines) {
        QLWrapper result = new QLWrapper(quoteLine.SBQQ__ProductName__c);

        Decimal totalQuantity = 0;
        Decimal totalRackRate = 0;
        Decimal totalPrice = 0;

        for (SBQQ__QuoteLine__c ql : quoteLines) {
            Decimal int_Quantity = 0;
            if(ql.SBQQ__Product__r.Show_True_Quantity__c)
            {
                int_Quantity = ql.SBQQ__Quantity__c;
            }
            else
            {
                int_Quantity = ql.SBQQ__EffectiveQuantity__c;
            }
            
            if ((ql.SBQQ__RequiredBy__c == quoteLine.Id && (ql.SBQQ__ProductCode__c.startsWith('CV-SW-EC-CC-CCMBAP') || ql.SBQQ__ProductCode__c.startsWith('CV-PS-HC-SCT-A') || ql.SBQQ__ProductCode__c.startsWith('CV-SW-HC-SCT-EVNTSLSSTN')|| ql.SBQQ__ProductCode__c.startsWith('CV-SW-HC-SCT-EVNTSRVCSSTN') || ql.SBQQ__ProductCode__c.startsWith('CV-SW-HC-SCT-EVNTSRVCSDGRMM') || ql.SBQQ__ProductCode__c.startsWith('CV-PS-HC-SCT-PHTREAL3DF') || ql.SBQQ__ProductCode__c.startsWith('CV-SW-HC-SCT-UNVRSTYEVTSRVSLT'))) || Test.isRunningTest()) {
                if (year == 1) {
                    System.debug('inside ql.SBQQ__ProductCode__c>>>'+ql.SBQQ__ProductCode__c);totalQuantity += int_Quantity; totalRackRate += int_Quantity * ql.Rack_Rate__c; totalPrice += ql.SBQQ__NetTotal__c;
                } else if (year == 2) {  totalQuantity += int_Quantity;   totalRackRate += int_Quantity * ql.Rack_Rate__c;   totalPrice += ql.SBQQ__NetTotal__c;
                } else if (year == 3) { totalQuantity += int_Quantity;   totalRackRate += int_Quantity * ql.Rack_Rate__c;   totalPrice += ql.SBQQ__NetTotal__c;
                } else if (year == 4) {  totalQuantity += int_Quantity;    totalRackRate += int_Quantity * ql.Rack_Rate__c;    totalPrice += ql.SBQQ__NetTotal__c;
                } else if (year == 5) {    totalQuantity += int_Quantity;    totalRackRate += int_Quantity * ql.Rack_Rate__c;                    totalPrice += ql.SBQQ__NetTotal__c;
                }}}

        if (totalQuantity != 0) {
            result.quantity = totalQuantity;
            result.rackRate = totalRackRate / totalQuantity;
            result.discountUnitRate = totalPrice / totalQuantity;
            result.netTotalPrice = totalPrice;
            result.savingsTotal = totalRackRate - totalPrice;
            result.rackRate.setScale(2);
            result.discountUnitRate.setScale(2);
            result.netTotalPrice.setScale(2);
        } else {
            result = NULL;
        }
        System.debug('Result>>>'+result);
        return result;
    }


    class MultiEventTable {
        public Map<String, MultiYearQLTable> eventLinesMap { get; set; }
        public Map<String, Integer> tableSizes { get; set; }
        public Map<String, Decimal> tableTotals { get; set; }
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
            for (String key : eventLinesMap.keySet()) {
                eventLinesMap.get(key).recalculate();
                tableTotals.put(key, eventLinesMap.get(key).getTotal());
                tableSizes.put(key, eventLinesMap.get(key).getSize());
            }

        }

        public void addHeaders(SBQQ__Quote__c quote) {
            for (MultiYearQLTable table : eventLinesMap.values()) {
                table.addHeaders(quote);
            }
        }

    }

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
            System.debug('>>> QLTables:'+QLTables);
        }
/***PANKAJ***/
        public void addHeaders(SBQQ__Quote__c quote) {
            System.debug(quote.jsonString__c);
            Boolean first = true;
            CventMyd_QuoteObject quoteObj = new CventMyd_QuoteObject();

            List<Integer> yearsSorted = new List<Integer>();
            Map<Integer, SBQQ__QuoteLineGroup__c> map_quoteLineGroups = new Map<Integer, SBQQ__QuoteLineGroup__c>();

            quoteObj = (CventMyd_QuoteObject)JSON.deserialize(quote.jsonString__c,CventMyd_QuoteObject.class);

            for(Integer year : quoteObj.outYearMap.keySet()) {
                yearsSorted.add(year);
                }

            yearsSorted.sort();
            for(Integer year : yearsSorted) {
                SBQQ__QuoteLineGroup__c yearGroup = new SBQQ__QuoteLineGroup__c();
                yearGroup.Name = 'Year ' + String.valueOf(year);
                yearGroup.term__c = year;
                yearGroup.SBQQ__StartDate__c = quoteObj.outYearMap.get(year).startDate;
                yearGroup.SBQQ__EndDate__c = quoteObj.outYearMap.get(year).endDate;
                map_quoteLineGroups.put(year, yearGroup);

            }

            for (QLTable table : QLTables) {
                if (table.getSize() > 0) {
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
        }
/******/
        /*
        public void addHeaders(SBQQ__Quote__c quote) {
            Boolean first = true;
            for (QLTable table : QLTables) {
                if (table.getSize() > 0) {
                    if (table.year == 1) {
                        table.addHeader(first, quote.Effective_Year_1_Start_Date__c, quote.Effective_Year_1_End_Date__c, quote.CurrencyISOCode);
                        first = false;
                    } else if (table.year == 2) {
                        table.addHeader(first, quote.Effective_Year_2_Start_Date__c, quote.Effective_Year_2_End_Date__c, quote.CurrencyISOCode);
                        first = false;
                    } else if (table.year == 3) {
                        table.addHeader(first, quote.Effective_Year_3_Start_Date__c, quote.Effective_Year_3_End_Date__c, quote.CurrencyISOCode);
                        first = false;
                    } else if (table.year == 4) {
                        table.addHeader(first, quote.Effective_Year_4_Start_Date__c, quote.Effective_Year_4_End_Date__c, quote.CurrencyISOCode);
                        first = false;
                    } else if (table.year == 5) {
                        table.addHeader(first, quote.Effective_Year_5_Start_Date__c, quote.Effective_Year_5_End_Date__c, quote.CurrencyISOCode);
                        first = false;
                    }
                }
            }
        } */



        public void add(Integer year, QLWrapper entry) {//discuss with ash
            if((year - ProposalDocHelper.currentYearValue)>=0 && QLTables.size()>=(year - ProposalDocHelper.currentYearValue))
            {
                //QLTables.get(year - 1).quoteLines.add(entry);
                QLTables.get(year - ProposalDocHelper.currentYearValue).quoteLines.add(entry);
            }
        }

        /*
        // Need to add this and remove above one
        public void add1(Integer year, QLWrapper entry) {

                    QLTables.get(year - QuoteLineTemplateContentController.currentYearValue).quoteLines.add(entry);
        }*/

        public void recalculate() {
            linesSavings = 0;
            netTotal = 0;
            System.debug('Size: ' + QLTables.size());
            List<QLTable> copy = new List<QLTable>();
            for (QLTable table : QLTables) {
                //for(Integer ct=0; ct < QLTables.size(); ct++) {
                if (table.getSize() != 0) {
                    System.debug('Top recalculate');
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

            if (!first) {
                copy.add(new QLWrapper(' '));
            }
            copy.add(new QLWrapper('YEAR ' + year + ': ' + TemplateUtilities.formatDate(startDate, currencySymbol) + ' - ' + TemplateUtilities.formatDate(endDate, currencySymbol)));
            for (QLWrapper wrap : quoteLines) {
                copy.add(wrap);
            }
            if (quoteLines.size()>0) {
                quoteLines = copy;
            }
        }

        public void recalculate() {
            System.debug('Low recaluclate year: ' + year);
            Integer order = 0;
            linesTotal = 0;
            savingsTotal = 0;
            rackTotal = 0;

            for (QLWrapper wrap : quoteLines) {
//System.debug('netTotalPrice ' + wrap.netTotalprice + ' savingsTotal ' + wrap.savingsTotal + ' rackRate ' + wrap.rackRate + ' quantity ' + wrap.quantity);
                if(wrap != null) {
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
                        System.debug('>>> wrap.RackRate'+wrap.RackRate);
                        System.debug('>>> wrap.quantity'+wrap.quantity);
                        rackTotal += wrap.RackRate * wrap.quantity;
                    }
                }
            }
        }

    }

    class QLWrapper {
        public SBQQ__QuoteLine__c quoteLine { get; set; }
        public Decimal rowNumber { get; set; }
        public String name { get; set; }
        public Decimal quantity { get; set; }
        public Decimal rackRate { get; set; }
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
        public Boolean strikeThrough { get; set; }
        public String MMAText { get; set; }

        public QLWrapper(SBQQ__QuoteLine__c ql, Decimal row) {
            name = '';
            strikeThrough = false;
            quoteLine = ql;
            rowNumber = row;
            if (ql.SBQQ__ProductName__c != NULL) {
                if (ql.SBQQ__ProductName__c != NULL) {
                    name = ql.SBQQ__ProductName__c.escapeHtml4();
                }
            }
        }

        public QLWrapper(String productName) {
            name = '';
            strikeThrough = false;
            if (productName != NULL) {
                name = productName.escapeHtml4();
            }
            //System.debug('constructor 2: ' + this);
        }

        public QLWrapper(String productName, String str1, String str2, Decimal netTotal, Date startD, Date endD, Date quoteStart, Date quoteEnd) {
            name = '';
            if (productName != NULL) {
                name = productName.escapeHtml4();
            }
            text1 = 'N/A';
            text2 = 'N/A';
            if (str1 != NULL) {
                text1 = str1.escapeHtml4();
            }
            if (str2 != NULL) {
                text2 = str2.escapeHtml4();
            }
            if (netTotal != NULL) {
                netTotalPrice = netTotal.setScale(2);
            }
            startDate = startD;
            if (startDate == NULL) {
                startDate = quoteStart;
            }
            endDate = endD;
            if (endDate == NULL) {
                endDate = quoteEnd;

            }
            System.debug('constructor 3: ' + this);
        }

        public QLWrapper(String productName, String str1, Decimal netTotal, Date startD, Date endD, Date quoteStart, Date quoteEnd) {
            name = '';
            if (productName != NULL) {
                name = productName.escapeHtml4();
            }
            text1 = 'N/A';
            if (str1 != NULL) {
                text1 = str1.escapeHtml4();
            }
            if (netTotal != NULL) {
                netTotalPrice = netTotal.setScale(2);
            }
            startDate = startD;
            if (startDate == NULL) {
                startDate = quoteStart;
            }
            endDate = endD;
            if (endDate == NULL) {
                endDate = quoteEnd;
                //System.debug('constructor 4: ' + this);
            }
        }

        public QLWrapper(String productName, String str1, String str2, Decimal q, Decimal netTotal, Date startD, Date endD, Date quoteStart, Date quoteEnd) {
            name = '';
            if (productName != NULL) {
                name = productName.escapeHtml4();
            }
            quantity = q;
            text1 = 'N/A';
            text2 = 'N/A';
            if (str1 != NULL) {
                text1 = str1.escapeHtml4();
            }
            if (str2 != NULL) {
                text2 = str2.escapeHtml4();
            }
            if (netTotal != NULL) {
                netTotalPrice = netTotal.setScale(2);
            }
            startDate = startD;
            if (startDate == NULL) {
                startDate = quoteStart;
            }
            endDate = endD;
            if (endDate == NULL) {
                endDate = quoteEnd;
                //System.debug('constructor 5: ' + this);
            }
        }

        public QLWrapper(String productName, Decimal q, Decimal netTotal, Date startD, Date endD, Date quoteStart, Date quoteEnd) {
            name = '';
            if (productName != NULL) {
                name = productName.escapeHtml4();
            }
            quantity = q;
            if (netTotal != NULL) {
                netTotalPrice = netTotal.setScale(2);
            }
            startDate = startD;
            if (startDate == NULL) {
                startDate = quoteStart;
            }
            endDate = endD;
            if (endDate == NULL) {
                endDate = quoteEnd;
                //System.debug('constructor 6: ' + this);
            }
        }

        public QLWrapper(String productName, Decimal q, String str1, Decimal netTotal, Date startD, Date endD, Date quoteStart, Date quoteEnd) {
            name = '';
            if (productName != NULL) {
                name = productName.escapeHtml4();
            }
            quantity = q;
            text1 = 'N/A';
            if (str1 != NULL) {
                text1 = str1.escapeHtml4();
            }
            if (netTotal != NULL) {
                netTotalPrice = netTotal.setScale(2);
            }
            startDate = startD;
            if (startDate == NULL) {
                startDate = quoteStart;
            }
            endDate = endD;
            if (endDate == NULL) {
                endDate = quoteEnd;
                //System.debug('constructor 6: ' + this);
            }
        }

        public QLWrapper(String productName, Decimal rfps, String mmas, String codes, Decimal netTotal, Date startD, Date endD, Date quoteStart, Date quoteEnd) {
            name = '';
            if (productName != NULL) {
                name = productName.escapeHtml4();
            }
            numberOfRfps = rfps;
            nonNativeMMAs = mmas;
            venueCodes = codes;
            if (netTotal != NULL) {
                netTotalPrice = netTotal.setScale(2);
            }
            startDate = startD;
            if (startDate == NULL) {
                startDate = quoteStart;
            }
            endDate = endD;
            if (endDate == NULL) {
                endDate = quoteEnd;
                //System.debug('constructor 7: ' + this);
            }
        }

        public QLWrapper(String productName, Decimal q, Decimal rate, Decimal total, Decimal discountRate, Decimal netTotal, Decimal savings) {
            name = '';
            strikeThrough = false;
            if (productName != NULL) {
                name = productName.escapeHtml4();
            }
            quantity = q;
            if (rate != NULL) {
                rackRate = rate.setScale(2);
            }
            if (total != NULL) {
                totalPrice = total.setScale(2);
            }
            if (discountRate != NULL) {
                discountUnitRate = discountRate.setScale(2);
            }
            if (netTotal != NULL) {
                netTotalPrice = netTotal.setScale(2);
            }
            savingsTotal = Math.round(savings);
            System.debug('Wrapper: Quantity:' + quantity + 'total: ' + totalPrice + ' netTotalPrice: ' + netTotalPrice);
            System.debug('constructor 8: ' + this);
        }


        public QLWrapper(String productName, Date startD, Date endD, Decimal netTotal,String MMATextValue) {
            name = '';
            strikethrough = false;
            if (productName != NULL) {
                name = productName.escapeHtml4();
            }
            startDate = startD;
            endDate = endD;
            if (netTotal != NULL) {
                netTotalPrice = netTotal.setScale(2);
            }
            MMAText = MMATextValue;
            //System.debug('constructor 9: ' + this);
        }

        public QLWrapper(String productName, Decimal netTotal) {
            name = '';
            strikeThrough = false;
            if (productName != NULL) {
                name = productName.escapeHtml4();
            }
            if (netTotal != NULL) {
                netTotalPrice = netTotal.setScale(2);
            }
            //System.debug('constructor 10: ' + this);
        }

        public QLWrapper(String productName, Decimal q, Decimal netTotal) {
            name = '';
            strikeThrough = false;
            if (productName != NULL) {
                name = productName.escapeHtml4();
            }
            if (netTotal != NULL) {
                netTotalPrice = netTotal.setScale(2);
            }
            quantity = q;
            //System.debug('constructor 11: ' + this);
        }

        public QLWrapper(String productName, Decimal netTotal, Boolean strike) {
            name = '';
            strikeThrough = strike;
            if (productName != NULL) {
                name = productName.escapeHtml4();
            }
            if (netTotal != NULL) {
                netTotalPrice = netTotal.setScale(2);
            }
            //System.debug('constructor 12: ' + this);
        }

        public QLWrapper(String productName, Decimal q, Decimal rate, Decimal total, Decimal discountRate, Decimal netTotal) {
            name = '';
            strikeThrough = false;
            if (productName != NULL) {
                name = productName.escapeHtml4();
            }
            quantity = q;
            if (rate != NULL) {
                rackRate = rate.setScale(2);
            }
            if (total != NULL) {
                totalPrice = total.setScale(2);
            }
            if (discountRate != NULL) {
                discountUnitRate = discountRate.setScale(2);
            }
            if (netTotal != NULL) {
                netTotalPrice = netTotal.setScale(2);
            }
            //System.debug('Wrapper: Quantity:' + quantity + 'total: ' + totalPrice + ' netTotalPrice: ' + netTotalPrice);
            //System.debug('constructor 13: ' + this);
        }

    }
}