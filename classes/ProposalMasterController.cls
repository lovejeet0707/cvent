/**
 * Created by CrutchfieldJody on 7/13/2017.
 */

public without sharing class ProposalMasterController {

                /* usage skus to put in matrix table
        CV-SW-EC-EVT-CCMOBAPP
        CV-SW-EC-EVT-EXPPREPAYREG
        CV-SW-EC-EVT-USERFUL
        CV-SW-EC-EVT-USERF
        CV-SW-EC-EVT-ADDULOG
        CV-SW-EC-EVT-PRPYMTREGF
        CV-SW-EC-EVT-PRPYMTTRNF
        CV-SW-EC-EVT-PRPYMTEVTF
         */

    public static String qId { get; set; }
    public static Boolean matrixed { get; set; }
    public static SBQQ__Quote__c primaryQuote { get; set; }
    public static List<SBQQ__Quote__c> fullQuoteList { get; set; }
    public List<SBQQ__QuoteLine__c> quoteLines { get; set; }
    public String currencySymbol { get; set; }
    public String currencySign { get; set; }

    public List<Decimal> empty { get; set; }
    public List<Decimal> single { get; set; }

    /* Hospitaliy Cloud Summary */
    public MultiYearQLTable hcSummaryTable { get; set; }
    public List<MultiYearQLTable> hcSummaryTableList { get; set; }
    public List<Decimal> showHcSummaryTable { get; set; }

    /* Events */
    public MultiYearQLTable eventTable { get; set; }
    public List<MultiYearQLTable> eventTableList { get; set; }
    public MultiYearQLTable eventMatrixTable { get; set; }
    public List<MatrixTable> appsMatrix { get; set; }
    public List<MatrixTable> regMatrix { get; set; }
    public List<MatrixTable> eventMatrix { get; set; }
    public List<MatrixTable> userMatrix { get; set; }
    public List<Decimal> showAppsMatrix { get; set; }
    public List<Decimal> showRegMatrix { get; set; }
    public List<Decimal> showEventMatrix { get; set; }
    public List<Decimal> showUserMatrix { get; set; }
    public List<Decimal> showEventTable { get; set; }
    public List<Decimal> showEventNoPriceTable { get; set; }

    /* Listing Advertisement(s), Software, Services & CONNECT */
    public MultiYearQLTable listingAdsTable { get; set; }
    public List<MultiYearQLTable> listingAdsTableList { get; set; }
    public List<Decimal> showListingAdsTable { get; set; }

    /* Bundle Advertisement(s) */
    public MultiYearQLTable bundleAdsTable { get; set; }
    public List<MultiYearQLTable> bundleAdsTableList { get; set; }
    public List<Decimal> showBundleAdsTable { get; set; }

    /* Cvent Passkey, Transient & Lanyon Group */
    public MultiYearQLTable passkeyTable { get; set; }
    public List<MultiYearQLTable> passkeyTableList { get; set; }
    public List<Decimal> showPasskeyTable { get; set; }

    /* Elite Meetings Alliance */
    public MultiYearQLTable emiTable { get; set; }
    public List<MultiYearQLTable> emiTableList { get; set; }
    public List<Decimal> showEmiTable { get; set; }

    /* RegOnline */
    public MultiYearQLTable regOnlineTable { get; set; }
    public List<MultiYearQLTable> regOnlineTableList { get; set; }
    public List<Decimal> showRegOnlineTable { get; set; }

    /* Reporting & Analytics */
    public MultiYearQLTable reportingTable { get; set; }
    public List<MultiYearQLTable> reportingTableList { get; set; }
    public List<Decimal> showReportingTable { get; set; }

    /* Suggested Advertisement(s) */
    public MultiYearQLTable suggestedAdsTable { get; set; }
    public List<MultiYearQLTable> suggestedAdsTableList { get; set; }
    public List<Decimal> showSuggestedAdsTable { get; set; }

    /* Video retargeting */
    public MultiYearQLTable videoRetargetingTable { get; set; }
    public List<MultiYearQLTable> videoRetargetingTableList { get; set; }
    public List<Decimal> showVideoRetargetingTable { get; set; }

    /* Merchant Account */
    public MultiYearQLTable merchantTable { get; set; }
    public List<MultiYearQLTable> merchantTableList { get; set; }
    public List<Decimal> showMerchantTable { get; set; }

    /* On-demand */
    public MultiYearQLTable onDemandTable { get; set; }
    public List<MultiYearQLTable> onDemandTableList { get; set; }
    public List<Decimal> showOnDemandTable { get; set; }

    /* Professional Services */
    public MultiYearQLTable professionalServicesTable { get; set; }
    public List<MultiYearQLTable> professionalServicesTableList { get; set; }
    public List<Decimal> showProfessionalServicesTable { get; set; }

    public MultiYearQLTable overagesTable { get; set; }
    public List<MultiYearQLTable> overagesTableList { get; set; }
    public List<Decimal> showOveragesTable { get; set; }

    // first page table

    // build second page table

    // build third page table

    // build fourth page table

    // build fifth page table

    public ProposalMasterController() {
        System.debug(System.LoggingLevel.INFO, 'ProposalMasterController');
        qId = (Id) ApexPages.currentPage().getParameters().get('qid');
        System.debug(System.LoggingLevel.INFO, '&&&&&&&& - qId: ' + qId);
        matrixed = false;
        initializeData(qId);
        if (matrixed == true) {
            processMatrixPrimaryQuote();
            processMatrixQuoteLines();
            finalizeMatrixTable();
        } else {
            processQuoteLines();
        }
    }

    public void initializeData(Id quoteId) {
        System.debug(System.LoggingLevel.INFO, '&&&&&&&& - initializeData');
        matrixed = false;

        SBQQ__Quote__c inputQuote = [
                select Contract_Term_Years__c, Multiple_Years_Commitment__c, Dynamic_Quote_Template_Color__c, SBQQ__NetAmount__c,
                        SBQQ__ExpirationDate__c, Count_of_HC_Products__c, Hide_Unit_Prices_on_Contract__c,
                        Effective_Year_1_Start_Date__c, Effective_Year_1_End_Date__c,
                        Effective_Year_2_Start_Date__c, Effective_Year_2_End_Date__c,
                        Effective_Year_3_Start_Date__c, Effective_Year_3_End_Date__c,
                        Effective_Year_4_Start_Date__c, Effective_Year_4_End_Date__c,
                        Effective_Year_5_Start_Date__c, Effective_Year_5_End_Date__c, CurrencyIsoCode,
                        Count_of_RegOnline_Products__c, Count_of_Onsite_Solutions__c, OnArrival_360_Quote__c
                        ,SBQQ__Opportunity2__r.Id, SBQQ__Primary__c, Contract_Remaining_Term__c
                from SBQQ__Quote__c
                where Id = :qId
                limit 1
        ];

        Opportunity opportunity = [select Id, SBQQ__PrimaryQuote__r.Id from Opportunity where Id = :inputQuote.SBQQ__Opportunity2__r.Id];

        primaryQuote = new SBQQ__Quote__c();
        if (inputQuote.SBQQ__Primary__c == true) {
            primaryQuote = inputQuote;
        } else {
            try {
                primaryQuote = [
                        select Contract_Term_Years__c, Multiple_Years_Commitment__c, Dynamic_Quote_Template_Color__c, SBQQ__NetAmount__c,
                                SBQQ__ExpirationDate__c, Count_of_HC_Products__c, Hide_Unit_Prices_on_Contract__c,
                                Effective_Year_1_Start_Date__c, Effective_Year_1_End_Date__c,
                                Effective_Year_2_Start_Date__c, Effective_Year_2_End_Date__c,
                                Effective_Year_3_Start_Date__c, Effective_Year_3_End_Date__c,
                                Effective_Year_4_Start_Date__c, Effective_Year_4_End_Date__c,
                                Effective_Year_5_Start_Date__c, Effective_Year_5_End_Date__c, CurrencyIsoCode,
                                Count_of_RegOnline_Products__c, Count_of_Onsite_Solutions__c, OnArrival_360_Quote__c
                                , SBQQ__Opportunity2__r.Id, SBQQ__Primary__c, Contract_Remaining_Term__c
                        from SBQQ__Quote__c
                        where SBQQ__Primary__c = true
                        and SBQQ__Opportunity2__r.Id = :opportunity.Id
                        and Include_In_Proposal__c = true
                        limit 1
                ];
            } catch (Exception ex) {
                primaryQuote = inputQuote;
            }
        }

        List<SBQQ__Quote__c> nonPrimaryQuoteList = [
                select Contract_Term_Years__c, Multiple_Years_Commitment__c, Dynamic_Quote_Template_Color__c, SBQQ__NetAmount__c,
                        SBQQ__ExpirationDate__c, Count_of_HC_Products__c, Hide_Unit_Prices_on_Contract__c,
                        Effective_Year_1_Start_Date__c, Effective_Year_1_End_Date__c,
                        Effective_Year_2_Start_Date__c, Effective_Year_2_End_Date__c,
                        Effective_Year_3_Start_Date__c, Effective_Year_3_End_Date__c,
                        Effective_Year_4_Start_Date__c, Effective_Year_4_End_Date__c,
                        Effective_Year_5_Start_Date__c, Effective_Year_5_End_Date__c, CurrencyIsoCode,
                        Count_of_RegOnline_Products__c, Count_of_Onsite_Solutions__c, OnArrival_360_Quote__c,
                        Contract_Remaining_Term__c
                from SBQQ__Quote__c
                where SBQQ__Opportunity2__c = :opportunity.Id
                and SBQQ__Primary__c = false
                and Include_In_Proposal__c = true
                Order by SBQQ__NetAmount__c
        ];

        fullQuoteList = new List<SBQQ__Quote__c>();
        if (primaryQuote != null) {
            fullQuoteList.add(primaryQuote);
            currencySymbol = primaryQuote.CurrencyIsoCode;
        }
        fullQuoteList.addAll(nonPrimaryQuoteList);

        quoteLines = [
                select Id, SBQQ__Quote__c, SBQQ__Group__r.SBQQ__Number__c, Unit__c, SBQQ__Quote__r.Name
                        , SBQQ__Quote__r.SBQQ__StartDate__c, SBQQ__Quote__r.SBQQ__EndDate__c, SBQQ__Quote__r.Contract_Term_Years__c
                        , SBQQ__Quote__r.Effective_Year_1_Start_Date__c, SBQQ__Quote__r.Effective_Year_1_End_Date__c,
                        SBQQ__Quote__r.Effective_Year_2_Start_Date__c, SBQQ__Quote__r.Effective_Year_2_End_Date__c,
                        SBQQ__Quote__r.Effective_Year_3_Start_Date__c, SBQQ__Quote__r.Effective_Year_3_End_Date__c,
                        SBQQ__Quote__r.Effective_Year_4_Start_Date__c, SBQQ__Quote__r.Effective_Year_4_End_Date__c,
                        SBQQ__Quote__r.Effective_Year_5_Start_Date__c, SBQQ__Quote__r.Effective_Year_5_End_Date__c
                        , Rack_Rate__c, SBQQ__NetPrice__c, SBQQ__EffectiveQuantity__c, SBQQ__ProductName__c, Contract_Output_Grouping__c
                        , SBQQ__NetTotal__c, CurrencyIsoCode, SBQQ__Bundled__c, SBQQ__ComponentVisibility__c
                        , Number_Of_Views__c, Location_Text__c, SBQQ__Optional__c
                        , Overage_Fee__c, Year_2_Overage_Fee__c, Year_3_Overage_Fee__c, Year_4_Overage_Fee__c, Year_5_Overage_Fee__c
                        , SBQQ__RequiredBy__c, SBQQ__ProductOption__r.SBQQ__Feature__r.Name, SBQQ__ProductCode__c
                        , SBQQ__Quantity__c, Year_2_Quantity__c, Year_3_Quantity__c, Year_4_Quantity__c, Year_5_Quantity__c
                        , SBQQ__ListPrice__c, Year_2_List_Price__c, Year_3_List_Price__c, Year_4_List_Price__c, Year_5_List_Price__c
                        , Year_2_Net_Amount__c, Year_3_Net_Amount__c, Year_4_Net_Amount__c, Year_5_Net_Amount__c
                        , Editor_Net_Total__c,Number_of_RFPs__c, MMA_Text__c,Enter_Venue_Codes__c,Linked_To__c,Product_Family__c
                        , Banner_Ad_Location_Name__c, SBQQ__Hidden__c, Ad_Start_Date__c, Ad_End_Date__c, Product_Line__c
                        , Year_2_Effective_Quantity__c, Year_3_Effective_Quantity__c, Year_4_Effective_Quantity__c, Year_5_Effective_Quantity__c
                        , Year_2_Effective_Amount__c, Year_3_Effective_Amount__c, Year_4_Effective_Amount__c, Year_5_Effective_Amount__c
                        , SBQQ__Product__r.Contract_Output_Grouping__c
                        , OnArrival_360_Event_Selection__r.Name, OnArrival_360_Event_Selection__r.Dates__c
                        , OnArrival_360_Event_Selection__r.Number_of_Attendees__c, OnArrival_360_Event_Selection__r.Address_of_Event__c
                        , SBQQ__RequiredBy__r.OnArrival_360_Event_Selection__r.Name, SBQQ__RequiredBy__r.OnArrival_360_Event_Selection__r.Dates__c
                        , SBQQ__RequiredBy__r.OnArrival_360_Event_Selection__r.Address_of_Event__c
                        , SBQQ__RequiredBy__r.SBQQ__RequiredBy__r.OnArrival_360_Event_Selection__r.Address_of_Event__c
                        , SBQQ__RequiredBy__r.SBQQ__RequiredBy__r.OnArrival_360_Event_Selection__r.Dates__c
                        , SBQQ__RequiredBy__r.SBQQ__RequiredBy__r.OnArrival_360_Event_Selection__r.Name, Notes__c,
                        Enter_Individual_Markets__c,
                        SBQQ__RequiredBy__r.SBQQ__RequiredBy__r.OnArrival_360_Event_Selection__r.Venue_Name__c,
                        SBQQ__RequiredBy__r.OnArrival_360_Event_Selection__r.Venue_Name__c, OnArrival_360_Event_Selection__r.Venue_Name__c,
                        SBQQ__EffectiveStartDate__c, SBQQ__EffectiveEndDate__c, Year_2_Start_Date__c, Year_2_End_Date__c, Year_3_Start_Date__c, Year_3_End_Date__c,
                        Year_4_Start_Date__c, Year_4_End_Date__c, Year_5_Start_Date__c, Year_5_End_Date__c, SA_Start_Date__c, SA_End_Date__c,term__c
                from SBQQ__QuoteLine__c
                where SBQQ__Quote__c in :fullQuoteList
        ];

        currencySign = TemplateUtilities.getCurrencySign(currencySymbol);

        for (SBQQ__QuoteLine__c ql: quoteLines) {
            if (
                    //ql.SBQQ__ProductCode__c == 'CV-SW-EC-EVT-CCMOBAPP'
                    //||
                    ql.SBQQ__ProductCode__c == 'CV-SW-EC-EVT-EXPPREPAYREG'
                            || ql.SBQQ__ProductCode__c == 'CV-SW-EC-EVT-PRPYMTREGF'
                            || ql.SBQQ__ProductCode__c == 'CV-SW-EC-EVT-USERFUL'
                            || ql.SBQQ__ProductCode__c == 'CV-SW-EC-EVT-USERF'
                            || ql.SBQQ__ProductCode__c == 'CV-SW-EC-EVT-PRPYMTTRNF'
                            || ql.SBQQ__ProductCode__c == 'CV-SW-EC-EVT-PRPYMTEVTF'
                            || ql.SBQQ__ProductCode__c == 'CV-SW-EC-EVT-ADDULOG') {
                matrixed = true;
                break;
            }
        }
        if (matrixed == true && primaryQuote == null) {
            primaryQuote = fullQuoteList[0];
        }
        System.debug(System.LoggingLevel.INFO, 'primaryQuote: ' + primaryQuote);
        System.debug(System.LoggingLevel.INFO, 'full quote list: ' + fullQuoteList);

        Integer contractTermYears = primaryQuote.Contract_Remaining_Term__c.intValue();
        if(primaryQuote.Multiple_Years_Commitment__c) {
            eventTable = new MultiYearQLTable(contractTermYears);
            eventMatrixTable = new MultiYearQLTable(contractTermYears);
            appsMatrix = new List<MatrixTable>();
            regMatrix = new List<MatrixTable>();
            eventMatrix = new List<MatrixTable>();
            userMatrix = new List<MatrixTable>();
            listingAdsTable = new MultiYearQLTable(contractTermYears);
            hcSummaryTable = new MultiYearQLTable(contractTermYears);
            bundleAdsTable = new MultiYearQLTable(contractTermYears);
            passkeyTable = new MultiYearQLTable(contractTermYears);
            emiTable = new MultiYearQLTable(contractTermYears);
            regOnlineTable = new MultiYearQLTable(contractTermYears);
            suggestedAdsTable = new MultiYearQLTable(contractTermYears);
            reportingTable = new MultiYearQLTable(contractTermYears);
            videoRetargetingTable = new MultiYearQLTable(contractTermYears);
            merchantTable = new MultiYearQLTable(contractTermYears);
            onDemandTable = new MultiYearQLTable(contractTermYears);
            professionalServicesTable = new MultiYearQLTable(contractTermYears);
            overagesTable = new MultiYearQLTable(contractTermYears);
        } else {
            eventTable = new MultiYearQLTable(1);
            eventMatrixTable = new MultiYearQLTable(1);
            appsMatrix = new List<MatrixTable>();
            regMatrix = new List<MatrixTable>();
            eventMatrix = new List<MatrixTable>();
            userMatrix = new List<MatrixTable>();
            listingAdsTable = new MultiYearQLTable(1);
            hcSummaryTable = new MultiYearQLTable(1);
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
            overagesTable = new MultiYearQLTable(1);
        }

        bundleAdsTableList = new List<MultiYearQLTable>();
        suggestedAdsTableList = new List<MultiYearQLTable>();
        videoRetargetingTableList = new List<MultiYearQLTable>();
        eventTableList = new List<MultiYearQLTable>();
        reportingTableList = new List<MultiYearQLTable>();
        passkeyTableList = new List<MultiYearQLTable>();
        listingAdsTableList = new List<MultiYearQLTable>();
        merchantTableList = new List<MultiYearQLTable>();
        onDemandTableList = new List<MultiYearQLTable>();
        professionalServicesTableList = new List<MultiYearQLTable>();
        overagesTableList = new List<MultiYearQLTable>();
        eventTableList = new List<MultiYearQLTable>();


        empty = new List<Decimal>();
        single = new List<Decimal>();
        single.add(0.0);
        System.debug(System.LoggingLevel.INFO, '&&&&&&&& - Matrixed: ' + matrixed);
    }

    public void processMatrixPrimaryQuote() {
        System.debug(System.LoggingLevel.INFO, '&&&&&&&& - processMatrixPrimaryQuote');
        for (SBQQ__QuoteLine__c ql: quoteLines) {
            //System.debug(System.LoggingLevel.INFO, '&&&&&&&& - ql: ' + ql);
            // if it is not a bundle product and is allowed to show on the output docs
            if (!ql.SBQQ__Bundled__c
                    && ql.SBQQ__ComponentVisibility__c != 'Never'
                    && ql.SBQQ__ComponentVisibility__c != 'Editor Only'
                    && !ql.SBQQ__Hidden__c) {
                QLWrapper wrapper;
                if (ql.SBQQ__Quote__r.Id == primaryQuote.Id) {
                    if (ql.Contract_Output_Grouping__c == 'Bundle Advertisements') {
                        //System.debug(System.LoggingLevel.INFO, '&&&&&&&& - Bundle');
                        createBundleAdsTable(primaryQuote, ql, wrapper);
                    } else if (ql.Contract_Output_Grouping__c == 'Suggested Advertisements') {
                        //System.debug(System.LoggingLevel.INFO, '&&&&&&&& - Suggested');
                        createSuggestedAds(primaryQuote, ql, wrapper);
                    } else if (ql.Contract_Output_Grouping__c == 'Video Retargeting') {
                        //System.debug(System.LoggingLevel.INFO, '&&&&&&&& - Video');
                        createVideoRetargeting(primaryQuote, ql, wrapper);
                    } else if (ql.Contract_Output_Grouping__c == 'Elite Meetings Alliance') {
                        //System.debug(System.LoggingLevel.INFO, '&&&&&&&& - Elite');
                        createEliteMeetings(primaryQuote, ql, wrapper);
                    } else if (ql.Contract_Output_Grouping__c == 'Reporting & Analytics') {
                        //System.debug(System.LoggingLevel.INFO, '&&&&&&&& - Reporting');
                        createReportingAndAnalytics(primaryQuote, ql, wrapper);
                    } else if (ql.Contract_Output_Grouping__c == 'Cvent Passkey, Transient & Lanyon Group') {
                        //System.debug(System.LoggingLevel.INFO, '&&&&&&&& - Passkey');
                        createPasskeyTransientLanyon(primaryQuote, ql, wrapper);
                    } else if (ql.Contract_Output_Grouping__c == 'Listing Advertisement(s), Software, Services & CONNECT') {
                        //System.debug(System.LoggingLevel.INFO, '&&&&&&&& - Listing');
                        createListingAdsSoftwareServicesCONNECT(primaryQuote, ql, wrapper);
                    } else if (ql.Contract_Output_Grouping__c == 'Merchant') {
                        //System.debug(System.LoggingLevel.INFO, '&&&&&&&& - Merchant');
                        createMerchant(primaryQuote, ql, wrapper);
                    } else if (ql.Contract_Output_Grouping__c == 'OnDemand') {
                        //System.debug(System.LoggingLevel.INFO, '&&&&&&&& - OnDemand');
                        createOnDemand(primaryQuote, ql, wrapper);
                    } else if (ql.Contract_Output_Grouping__c == 'Professional') {
                        //System.debug(System.LoggingLevel.INFO, '&&&&&&&& - professional');
                        createProfessional(primaryQuote, ql, wrapper);
                    }

                    createOveragesTable(primaryQuote, ql, wrapper);

                    createEventTable(primaryQuote, ql, wrapper);
                }
            }
        }
        bundleAdsTableList.add(bundleAdsTable);
        suggestedAdsTableList.add(suggestedAdsTable);
        videoRetargetingTableList.add(videoRetargetingTable);
        eventTableList.add(eventTable);
        reportingTableList.add(reportingTable);
        passkeyTableList.add(passkeyTable);
        listingAdsTableList.add(listingAdsTable);
        merchantTableList.add(merchantTable);
        onDemandTableList.add(onDemandTable);
        professionalServicesTableList.add(professionalServicesTable);
        overagesTableList.add(overagesTable);
        eventTableList.add(eventTable);


//        System.debug(System.LoggingLevel.INFO, '&&&&&&&& - eventTable' + eventTable);
//        System.debug(System.LoggingLevel.INFO, '&&&&&&&& - eventMatrixTable' + eventMatrixTable);
//        System.debug(System.LoggingLevel.INFO, '&&&&&&&& - listingAdsTable' + listingAdsTable);
//        System.debug(System.LoggingLevel.INFO, '&&&&&&&& - hcSummaryTable' + hcSummaryTable);
//        System.debug(System.LoggingLevel.INFO, '&&&&&&&& - bundleAdsTable' + bundleAdsTable);
//        System.debug(System.LoggingLevel.INFO, '&&&&&&&& - passkeyTable' + passkeyTable);
//        System.debug(System.LoggingLevel.INFO, '&&&&&&&& - emiTable' + emiTable);
//        System.debug(System.LoggingLevel.INFO, '&&&&&&&& - regOnlineTable' + regOnlineTable);
//        System.debug(System.LoggingLevel.INFO, '&&&&&&&& - suggestedAdsTable' + suggestedAdsTable);
//        System.debug(System.LoggingLevel.INFO, '&&&&&&&& - reportingTable' + reportingTable);
//        System.debug(System.LoggingLevel.INFO, '&&&&&&&& - videoRetargetingTable' + videoRetargetingTable);
//        System.debug(System.LoggingLevel.INFO, '&&&&&&&& - merchantTable' + merchantTable);
//        System.debug(System.LoggingLevel.INFO, '&&&&&&&& - onDemandTable' + onDemandTable);
//        System.debug(System.LoggingLevel.INFO, '&&&&&&&& - professionalServicesTable' + professionalServicesTable);
//        System.debug(System.LoggingLevel.INFO, '&&&&&&&& - overagesTable' + overagesTable);

    }

    public void processMatrixQuoteLines() {
        System.debug(System.LoggingLevel.INFO, '&&&&&&&& - processMatrixQuoteLines');
        for (SBQQ__QuoteLine__c ql: quoteLines) {
            //System.debug(System.LoggingLevel.INFO, '&&&&&&&& - ql: ' + ql);
            // if it is not a bundle product and is allowed to show on the output docs
            if (!ql.SBQQ__Bundled__c
                    && ql.SBQQ__ComponentVisibility__c != 'Never'
                    && ql.SBQQ__ComponentVisibility__c != 'Editor Only'
                    && !ql.SBQQ__Hidden__c) {
                QLWrapper wrapper = new QLWrapper();
                createEventMatrixTable(ql, wrapper);
            }
        }
    }

    public void processQuoteLines() {
        System.debug(System.LoggingLevel.INFO, '&&&&&&&& - processQuoteLines');
        for (SBQQ__Quote__c quote : fullQuoteList) {
            for (SBQQ__QuoteLine__c ql: quoteLines) {
                //System.debug(System.LoggingLevel.INFO, '&&&&&&&& - ql: ' + ql);
                // if it is not a bundle product and is allowed to show on the output docs
                if (!ql.SBQQ__Bundled__c
                        && ql.SBQQ__ComponentVisibility__c != 'Never'
                        && ql.SBQQ__ComponentVisibility__c != 'Editor Only'
                        && !ql.SBQQ__Hidden__c
                        && ql.SBQQ__Quote__r.Id == quote.Id) {
                    QLWrapper wrapper;
                    if (ql.Contract_Output_Grouping__c == 'Bundle Advertisements') {
                        //System.debug(System.LoggingLevel.INFO, '&&&&&&&& - Bundle');
                        createBundleAdsTable(quote, ql, wrapper);
                    } else if (ql.Contract_Output_Grouping__c == 'Suggested Advertisements') {
                        //System.debug(System.LoggingLevel.INFO, '&&&&&&&& - Suggested');
                        createSuggestedAds(quote, ql, wrapper);
                    } else if (ql.Contract_Output_Grouping__c == 'Video Retargeting') {
                        //System.debug(System.LoggingLevel.INFO, '&&&&&&&& - Video');
                        createVideoRetargeting(quote, ql, wrapper);
                    } else if (ql.Contract_Output_Grouping__c == 'Elite Meetings Alliance') {
                        //System.debug(System.LoggingLevel.INFO, '&&&&&&&& - Elite');
                        createEliteMeetings(quote, ql, wrapper);
                    } else if (ql.Contract_Output_Grouping__c == 'Reporting & Analytics') {
                        //System.debug(System.LoggingLevel.INFO, '&&&&&&&& - Reporting');
                        createReportingAndAnalytics(quote, ql, wrapper);
                    } else if (ql.Contract_Output_Grouping__c == 'Cvent Passkey, Transient & Lanyon Group') {
                        //System.debug(System.LoggingLevel.INFO, '&&&&&&&& - Passkey');
                        createPasskeyTransientLanyon(quote, ql, wrapper);
                    } else if (ql.Contract_Output_Grouping__c == 'Listing Advertisement(s), Software, Services & CONNECT') {
                        //System.debug(System.LoggingLevel.INFO, '&&&&&&&& - Listing');
                        createListingAdsSoftwareServicesCONNECT(quote, ql, wrapper);
                    } else if (ql.Contract_Output_Grouping__c == 'Merchant') {
                        //System.debug(System.LoggingLevel.INFO, '&&&&&&&& - Merchant');
                        createMerchant(quote, ql, wrapper);
                    } else if (ql.Contract_Output_Grouping__c == 'OnDemand') {
                        //System.debug(System.LoggingLevel.INFO, '&&&&&&&& - OnDemand');
                        createOnDemand(quote, ql, wrapper);
                    } else if (ql.Contract_Output_Grouping__c == 'Professional') {
                        //System.debug(System.LoggingLevel.INFO, '&&&&&&&& - professional');
                        createProfessional(quote, ql, wrapper);
                    }

                    createOveragesTable(quote, ql, wrapper);

                    createEventTable(quote, ql, wrapper);
                }
            }
            if (quote.Multiple_Years_Commitment__c) {
                eventTable.addHeaders(quote);
                listingAdsTable.addHeaders(quote);
                bundleAdsTable.addHeaders(quote);
                passkeyTable.addHeaders(quote);
                emiTable.addHeaders(quote);
                regOnlineTable.addHeaders(quote);
                suggestedAdsTable.addHeaders(quote);
                reportingTable.addHeaders(quote);
                videoRetargetingTable.addHeaders(quote);
                overagesTable.addHeaders(quote);
            }
            eventTable.recalculate();

            if (quote.Count_of_HC_Products__c > 0) {
                showHcSummaryTable = single;
                showEventTable = empty;
                showEventNoPriceTable = empty;
            } else {
                if (quote.Count_of_RegOnline_Products__c == 0) {
                    if (quote.Hide_Unit_Prices_on_Contract__c) {
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
            overagesTable.recalculate();

            createHCSummaryTable(eventTable);
            if (quote.Multiple_Years_Commitment__c) {
                hcSummaryTable.addHeaders(quote);
            }
            hcSummaryTable.recalculate();

            bundleAdsTableList.add(bundleAdsTable);
            suggestedAdsTableList.add(suggestedAdsTable);
            videoRetargetingTableList.add(videoRetargetingTable);
            eventTableList.add(eventTable);
            reportingTableList.add(reportingTable);
            passkeyTableList.add(passkeyTable);
            listingAdsTableList.add(listingAdsTable);
            merchantTableList.add(merchantTable);
            onDemandTableList.add(onDemandTable);
            professionalServicesTableList.add(professionalServicesTable);
            overagesTableList.add(overagesTable);
            eventTableList.add(eventTable);

        }

        System.debug(System.LoggingLevel.INFO, '&&&&&&&& - eventTable' + eventTable);
        System.debug(System.LoggingLevel.INFO, '&&&&&&&& - eventMatrixTable' + eventMatrixTable);
        System.debug(System.LoggingLevel.INFO, '&&&&&&&& - listingAdsTable' + listingAdsTable);
        System.debug(System.LoggingLevel.INFO, '&&&&&&&& - hcSummaryTable' + hcSummaryTable);
        System.debug(System.LoggingLevel.INFO, '&&&&&&&& - bundleAdsTable' + bundleAdsTable);
        System.debug(System.LoggingLevel.INFO, '&&&&&&&& - passkeyTable' + passkeyTable);
        System.debug(System.LoggingLevel.INFO, '&&&&&&&& - emiTable' + emiTable);
        System.debug(System.LoggingLevel.INFO, '&&&&&&&& - regOnlineTable' + regOnlineTable);
        System.debug(System.LoggingLevel.INFO, '&&&&&&&& - suggestedAdsTable' + suggestedAdsTable);
        System.debug(System.LoggingLevel.INFO, '&&&&&&&& - reportingTable' + reportingTable);
        System.debug(System.LoggingLevel.INFO, '&&&&&&&& - videoRetargetingTable' + videoRetargetingTable);
        System.debug(System.LoggingLevel.INFO, '&&&&&&&& - merchantTable' + merchantTable);
        System.debug(System.LoggingLevel.INFO, '&&&&&&&& - onDemandTable' + onDemandTable);
        System.debug(System.LoggingLevel.INFO, '&&&&&&&& - professionalServicesTable' + professionalServicesTable);
        System.debug(System.LoggingLevel.INFO, '&&&&&&&& - overagesTable' + overagesTable);

    }

    public void createBundleAdsTable(SBQQ__Quote__c quote, SBQQ__QuoteLine__c ql, QLWrapper wrapper) {
        Integer contractTermYears = quote.Contract_Remaining_Term__c.intValue();
        if(ql.SBQQ__EffectiveQuantity__c <> 0) {
            Date startDate = TemplateUtilities.getStartDateFromQL(ql, 1);
            Date endDate = TemplateUtilities.getEndDateFromQL(ql, 1);
            wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Linked_To__c /*linkedTo*/, ql.Banner_Ad_Location_Name__c /*location*/, ql.SBQQ__NetTotal__c, startDate, endDate, startDate, endDate);
            if(ql.Notes__c != NULL) {
                wrapper.notes = ql.Notes__c.escapeHtml4().stripHtmlTags();
            }
            bundleAdsTable.add(1, wrapper);
        }
        if(contractTermYears > 1) {
            if(ql.Year_2_Quantity__c != NULL && quote.Multiple_Years_Commitment__c && ql.Year_2_Effective_Quantity__c > 0) {
                Date startDate = TemplateUtilities.getStartDateFromQL(ql, 2);
                Date endDate = TemplateUtilities.getEndDateFromQL(ql, 2);
                wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Linked_To__c /*linkedTo*/, ql.Banner_Ad_Location_Name__c /*location*/, ql.Year_2_Effective_Amount__c, startDate, endDate, startDate, endDate);
                bundleAdsTable.add(2, wrapper);
            } else if(ql.Year_2_Quantity__c == NULL && ql.Year_2_Effective_Quantity__c <> 0 && quote.Multiple_Years_Commitment__c) {
                wrapper = wrapper.clone();
                bundleAdsTable.add(2, wrapper);
            }
            if(ql.Notes__c != NULL) {
                wrapper.notes = ql.Notes__c.escapeHtml4().stripHtmlTags();
            }
            //bundleAdsTable.add(2, wrapper);
        }
        if(contractTermYears > 2) {
            if(ql.Year_3_Effective_Quantity__c > 0 && quote.Multiple_Years_Commitment__c && ql.Year_3_Effective_Quantity__c <> 0) {
                Date startDate = TemplateUtilities.getStartDateFromQL(ql, 3);
                Date endDate = TemplateUtilities.getEndDateFromQL(ql, 3);
                wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Linked_To__c /*linkedTo*/, ql.Banner_Ad_Location_Name__c/*location*/, ql.Year_3_Effective_Amount__c, startDate, endDate, startDate, endDate);
                bundleAdsTable.add(3, wrapper);
            } else if(ql.Year_3_Quantity__c == NULL && ql.Year_3_Effective_Quantity__c <> 0 && quote.Multiple_Years_Commitment__c) {
                wrapper = wrapper.clone();
                bundleAdsTable.add(3, wrapper);
            }
            if(ql.Notes__c != NULL) {
                wrapper.notes = ql.Notes__c.escapeHtml4().stripHtmlTags();
            }
            //bundleAdsTable.add(3, wrapper);
        }
        if(contractTermYears > 3) {
            if(ql.Year_4_Effective_Quantity__c > 0 && quote.Multiple_Years_Commitment__c && ql.Year_4_Effective_Quantity__c <> 0) {
                Date startDate = TemplateUtilities.getStartDateFromQL(ql, 4);
                Date endDate = TemplateUtilities.getEndDateFromQL(ql, 4);
                wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Linked_To__c /*linkedTo*/, ql.Banner_Ad_Location_Name__c/*location*/, ql.Year_4_Effective_Amount__c, startDate, endDate, startDate, endDate);
                bundleAdsTable.add(4, wrapper);
            } else if(ql.Year_4_Quantity__c == NULL && ql.Year_4_Effective_Quantity__c <> 0 && quote.Multiple_Years_Commitment__c) {
                wrapper = wrapper.clone();
                bundleAdsTable.add(4, wrapper);
            }
            if(ql.Notes__c != NULL) {
                wrapper.notes = ql.Notes__c.escapeHtml4().stripHtmlTags();
            }
            //bundleAdsTable.add(4, wrapper);
        }
        if(contractTermYears > 4) {
            if(ql.Year_5_Effective_Quantity__c > 0 && quote.Multiple_Years_Commitment__c && ql.Year_5_Effective_Quantity__c <> 0) {
                Date startDate = TemplateUtilities.getStartDateFromQL(ql, 5);
                Date endDate = TemplateUtilities.getEndDateFromQL(ql, 5);
                wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Linked_To__c /*linkedTo*/, ql.Banner_Ad_Location_Name__c/*location*/, ql.Year_5_Effective_Amount__c, startDate, endDate, startDate, endDate);
                bundleAdsTable.add(5, wrapper);
            } else if(ql.Year_5_Quantity__c == NULL && ql.Year_5_Effective_Quantity__c <> 0 && quote.Multiple_Years_Commitment__c) {
                wrapper = wrapper.clone();
                bundleAdsTable.add(5, wrapper);
            }
            if(ql.Notes__c != NULL) {
                wrapper.notes = ql.Notes__c.escapeHtml4().stripHtmlTags();
            }
            //bundleAdsTable.add(5, wrapper);
        }
        showBundleAdsTable = single;
    }

    public void createSuggestedAds(SBQQ__Quote__c quote, SBQQ__QuoteLine__c ql, QLWrapper wrapper) {
        //System.debug('Suggested Advertisements => ' + this);
        wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Number_of_RFPs__c, ql.MMA_Text__c /*MMAs*/, ql.Enter_Venue_Codes__c /*venueCodes*/, ql.SBQQ__NetTotal__c, ql.Ad_Start_Date__c, ql.Ad_End_Date__c, quote.Effective_Year_1_Start_Date__c, quote.Effective_Year_1_End_Date__c);
        if (ql.Notes__c != NULL) {
            wrapper.notes = ql.Notes__c.stripHtmlTags();
        }
        suggestedAdsTable.add(1, wrapper);
        if (quote.Contract_Term_Years__c > '1') {
            if (ql.Year_2_Effective_Quantity__c > 0 && quote.Multiple_Years_Commitment__c && ql.Year_2_Effective_Quantity__c <> 0) {
                wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Number_of_RFPs__c, ql.MMA_Text__c /*MMAs*/, ql.Enter_Venue_Codes__c /*venueCodes*/, ql.Year_2_Effective_Amount__c, ql.Ad_Start_Date__c, ql.Ad_End_Date__c, quote.Effective_Year_2_Start_Date__c, quote.Effective_Year_2_End_Date__c);
            } else {
                wrapper = wrapper.clone();
            }
            if (ql.Notes__c != NULL) {
                wrapper.notes = ql.Notes__c.stripHtmlTags();
            }
            suggestedAdsTable.add(2, wrapper);
        }
        if (quote.Contract_Term_Years__c > '2') {
            if (ql.Year_3_Effective_Quantity__c > 0 && quote.Multiple_Years_Commitment__c && ql.Year_3_Effective_Quantity__c <> 0) {
                wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Number_of_RFPs__c, ql.MMA_Text__c /*MMAs*/, ql.Enter_Venue_Codes__c /*venueCodes*/, ql.Year_3_Effective_Amount__c, ql.Ad_Start_Date__c, ql.Ad_End_Date__c, quote.Effective_Year_3_Start_Date__c, quote.Effective_Year_3_End_Date__c);
            } else {
                wrapper = wrapper.clone();
            }
            if (ql.Notes__c != NULL) {
               wrapper.notes = ql.Notes__c.stripHtmlTags();
            }
            suggestedAdsTable.add(3, wrapper);
        }
        if (quote.Contract_Term_Years__c > '3') {
            if (ql.Year_4_Effective_Quantity__c > 0 && quote.Multiple_Years_Commitment__c && ql.Year_4_Effective_Quantity__c <> 0) {
                wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Number_of_RFPs__c, ql.MMA_Text__c /*MMAs*/, ql.Enter_Venue_Codes__c /*venueCodes*/, ql.Year_4_Effective_Amount__c, ql.Ad_Start_Date__c, ql.Ad_End_Date__c, quote.Effective_Year_4_Start_Date__c, quote.Effective_Year_4_End_Date__c);
            } else {
                wrapper = wrapper.clone();
            }
            if (ql.Notes__c != NULL) {
               wrapper.notes = ql.Notes__c.stripHtmlTags();
            }
            suggestedAdsTable.add(4, wrapper);
        }
        if (quote.Contract_Term_Years__c > '4') {
            if (ql.Year_5_Effective_Quantity__c > 0 && quote.Multiple_Years_Commitment__c && ql.Year_5_Effective_Quantity__c <> 0) {
                wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Number_of_RFPs__c, ql.MMA_Text__c /*MMAs*/, ql.Enter_Venue_Codes__c /*venueCodes*/, ql.Year_5_Effective_Amount__c, ql.Ad_Start_Date__c, ql.Ad_End_Date__c, quote.Effective_Year_5_Start_Date__c, quote.Effective_Year_5_End_Date__c);
            } else {
                wrapper = wrapper.clone();
            }
            if (ql.Notes__c != NULL) {
                wrapper.notes = ql.Notes__c.stripHtmlTags();
            }
            suggestedAdsTable.add(5, wrapper);
        }
        showSuggestedAdsTable = single;

    }

    public void createVideoRetargeting(SBQQ__Quote__c quote, SBQQ__QuoteLine__c ql, QLWrapper wrapper) {
        wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Number_Of_Views__c, ql.SBQQ__NetTotal__c, ql.Ad_Start_Date__c, ql.Ad_End_Date__c, quote.Effective_Year_1_Start_Date__c, quote.Effective_Year_1_End_Date__c);
        if (ql.Notes__c != NULL) {
           wrapper.notes = ql.Notes__c.stripHtmlTags();
        }
        videoRetargetingTable.add(1, wrapper);
        if (quote.Contract_Term_Years__c > '1') {
            if (ql.Year_2_Effective_Quantity__c > 0 && quote.Multiple_Years_Commitment__c && ql.Year_2_Effective_Quantity__c <> 0) {
                wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Number_of_Views__c, ql.Year_2_Effective_Amount__c, ql.Ad_Start_Date__c, ql.Ad_End_Date__c, quote.Effective_Year_2_Start_Date__c, quote.Effective_Year_2_End_Date__c);
            } else {
                wrapper = wrapper.clone();
            }
            if (ql.Notes__c != NULL) {
               wrapper.notes = ql.Notes__c.stripHtmlTags();
            }
            videoRetargetingTable.add(2, wrapper);
        }
        if (quote.Contract_Term_Years__c > '2') {
            if (ql.Year_3_Effective_Quantity__c > 0 && quote.Multiple_Years_Commitment__c && ql.Year_3_Effective_Quantity__c <> 0) {
                wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Number_of_Views__c, ql.Year_3_Effective_Amount__c, ql.Ad_Start_Date__c, ql.Ad_End_Date__c, quote.Effective_Year_3_Start_Date__c, quote.Effective_Year_3_End_Date__c);
            } else {
                wrapper = wrapper.clone();
            }
            if (ql.Notes__c != NULL) {
               wrapper.notes = ql.Notes__c.stripHtmlTags();
            }
            videoRetargetingTable.add(3, wrapper);
        }
        if (quote.Contract_Term_Years__c > '3') {
            if (ql.Year_4_Effective_Quantity__c > 0 && quote.Multiple_Years_Commitment__c && ql.Year_4_Effective_Quantity__c <> 0) {
                wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Number_of_Views__c, ql.Year_4_Effective_Amount__c, ql.Ad_Start_Date__c, ql.Ad_End_Date__c, quote.Effective_Year_4_Start_Date__c, quote.Effective_Year_4_End_Date__c);
            } else {
                wrapper = wrapper.clone();
            }
            if (ql.Notes__c != NULL) {
              wrapper.notes = ql.Notes__c.stripHtmlTags();
            }
            videoRetargetingTable.add(4, wrapper);
        }
        if (quote.Contract_Term_Years__c > '4') {
            if (ql.Year_5_Effective_Quantity__c > 0 && quote.Multiple_Years_Commitment__c && ql.Year_5_Effective_Quantity__c <> 0) {
                wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Number_of_Views__c, ql.Year_5_Effective_Amount__c, ql.Ad_Start_Date__c, ql.Ad_End_Date__c, quote.Effective_Year_5_Start_Date__c, quote.Effective_Year_5_End_Date__c);
            } else {
                wrapper = wrapper.clone();
            }
            if (ql.Notes__c != NULL) {
              wrapper.notes = ql.Notes__c.stripHtmlTags();
            }
            videoRetargetingTable.add(5, wrapper);
        }
        showVideoRetargetingTable = single;

    }

    public void createEliteMeetings(SBQQ__Quote__c quote, SBQQ__QuoteLine__c ql, QLWrapper wrapper) {
        System.debug('EMA: ' + ql.SBQQ__ProductName__c + ' location: ' + ql.Location_Text__c);
        wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Location_Text__c, ql.SBQQ__NetTotal__c, ql.Ad_Start_Date__c, ql.Ad_End_Date__c, quote.Effective_Year_1_Start_Date__c, quote.Effective_Year_1_End_Date__c);
        if (ql.Notes__c != NULL) {
           wrapper.notes = ql.Notes__c.stripHtmlTags();
        }
        emiTable.add(1, wrapper);
        if (quote.Contract_Term_Years__c > '1') {
            if (ql.Year_2_Effective_Quantity__c > 0 && quote.Multiple_Years_Commitment__c && ql.Year_2_Effective_Quantity__c <> 0) {
                wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Location_Text__c, ql.Year_2_Effective_Amount__c, ql.Ad_Start_Date__c, ql.Ad_End_Date__c, quote.Effective_Year_2_Start_Date__c, quote.Effective_Year_2_End_Date__c);
            } else {
                wrapper = wrapper.clone();
            }
            if (ql.Notes__c != NULL) {
              wrapper.notes = ql.Notes__c.stripHtmlTags();
            }
            emiTable.add(2, wrapper);
        }
        if (quote.Contract_Term_Years__c > '2') {
            if (ql.Year_3_Effective_Quantity__c > 0 && quote.Multiple_Years_Commitment__c && ql.Year_3_Effective_Quantity__c <> 0) {
                wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Location_Text__c, ql.Year_3_Effective_Amount__c, ql.Ad_Start_Date__c, ql.Ad_End_Date__c, quote.Effective_Year_3_Start_Date__c, quote.Effective_Year_3_End_Date__c);
            } else {
                wrapper = wrapper.clone();
            }
            if (ql.Notes__c != NULL) {
               wrapper.notes = ql.Notes__c.stripHtmlTags();
            }
            emiTable.add(3, wrapper);
        }
        if (quote.Contract_Term_Years__c > '3') {
            if (ql.Year_4_Effective_Quantity__c > 0 && quote.Multiple_Years_Commitment__c && ql.Year_4_Effective_Quantity__c <> 0) {
                wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Location_Text__c, ql.Year_4_Effective_Amount__c, ql.Ad_Start_Date__c, ql.Ad_End_Date__c, quote.Effective_Year_4_Start_Date__c, quote.Effective_Year_4_End_Date__c);
            } else {
                wrapper = wrapper.clone();
            }
            if (ql.Notes__c != NULL) {
               wrapper.notes = ql.Notes__c.stripHtmlTags();
            }
            emiTable.add(4, wrapper);
        }
        if (quote.Contract_Term_Years__c > '4') {
            if (ql.Year_5_Effective_Quantity__c > 0 && quote.Multiple_Years_Commitment__c && ql.Year_5_Effective_Quantity__c <> 0) {
                wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Location_Text__c, ql.Year_5_Effective_Amount__c, ql.Ad_Start_Date__c, ql.Ad_End_Date__c, quote.Effective_Year_5_Start_Date__c, quote.Effective_Year_5_End_Date__c);
            } else {
                wrapper = wrapper.clone();
            }
            if (ql.Notes__c != NULL) {
              wrapper.notes = ql.Notes__c.stripHtmlTags();
            }
            emiTable.add(5, wrapper);
        }
        showEmiTable = single;

    }

    public void createReportingAndAnalytics(SBQQ__Quote__c quote, SBQQ__QuoteLine__c ql, QLWrapper wrapper) {
        wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.SBQQ__Quantity__c, ql.Enter_Venue_Codes__c, ql.SBQQ__NetTotal__c, ql.Ad_Start_Date__c, ql.Ad_End_Date__c, quote.Effective_Year_1_Start_Date__c, quote.Effective_Year_1_End_Date__c);
        if (ql.Notes__c != NULL) {
           wrapper.notes = ql.Notes__c.stripHtmlTags();
        }
        reportingTable.add(1, wrapper);
        if (quote.Contract_Term_Years__c > '1') {
            if (ql.Year_2_Effective_Quantity__c > 0 && quote.Multiple_Years_Commitment__c && ql.Year_2_Effective_Quantity__c <> 0) {
                wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Year_2_Effective_Quantity__c, ql.Enter_Venue_Codes__c, ql.Year_2_Effective_Amount__c, ql.Ad_Start_Date__c, ql.Ad_End_Date__c, quote.Effective_Year_2_Start_Date__c, quote.Effective_Year_2_End_Date__c);
            } else {
                wrapper = wrapper.clone();
            }
            if (ql.Notes__c != NULL) {
               wrapper.notes = ql.Notes__c.stripHtmlTags();
            }
            reportingTable.add(2, wrapper);
        }
        if (quote.Contract_Term_Years__c > '2') {
            if (ql.Year_3_Effective_Quantity__c > 0 && quote.Multiple_Years_Commitment__c && ql.Year_3_Effective_Quantity__c <> 0) {
                wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Year_3_Effective_Quantity__c, ql.Enter_Venue_Codes__c, ql.Year_3_Effective_Amount__c, ql.Ad_Start_Date__c, ql.Ad_End_Date__c, quote.Effective_Year_3_Start_Date__c, quote.Effective_Year_3_End_Date__c);
            } else {
                wrapper = wrapper.clone();
            }
            if (ql.Notes__c != NULL) {
               wrapper.notes = ql.Notes__c.stripHtmlTags();
            }
            reportingTable.add(3, wrapper);
        }
        if (quote.Contract_Term_Years__c > '3') {
            if (ql.Year_4_Effective_Quantity__c > 0 && quote.Multiple_Years_Commitment__c && ql.Year_4_Effective_Quantity__c <> 0) {
                wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Year_4_Effective_Quantity__c, ql.Enter_Venue_Codes__c, ql.Year_4_Effective_Amount__c, ql.Ad_Start_Date__c, ql.Ad_End_Date__c, quote.Effective_Year_4_Start_Date__c, quote.Effective_Year_4_End_Date__c);
            } else {
                wrapper = wrapper.clone();
            }
            if (ql.Notes__c != NULL) {
              wrapper.notes = ql.Notes__c.stripHtmlTags();
            }
            reportingTable.add(4, wrapper);
        }
        if (quote.Contract_Term_Years__c > '4') {
            if (ql.Year_5_Effective_Quantity__c > 0 && quote.Multiple_Years_Commitment__c && ql.Year_5_Effective_Quantity__c <> 0) {
                wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Year_5_Effective_Quantity__c, ql.Enter_Venue_Codes__c, ql.Year_5_Effective_Amount__c, ql.Ad_Start_Date__c, ql.Ad_End_Date__c, quote.Effective_Year_5_Start_Date__c, quote.Effective_Year_5_End_Date__c);
            } else {
                wrapper = wrapper.clone();
            }
            if (ql.Notes__c != NULL) {
               wrapper.notes = ql.Notes__c.stripHtmlTags();
            }
            reportingTable.add(5, wrapper);
        }
        showReportingTable = single;
    }

    public void createPasskeyTransientLanyon(SBQQ__Quote__c quote, SBQQ__QuoteLine__c ql, QLWrapper wrapper) {
        wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Product_Family__c, ql.Unit__c, ql.SBQQ__EffectiveQuantity__c, ql.SBQQ__NetTotal__c, ql.Ad_Start_Date__c, ql.Ad_End_Date__c, quote.Effective_Year_1_Start_Date__c, quote.Effective_Year_1_End_Date__c);
        wrapper.quantity = ql.SBQQ__Quantity__c;
        if (ql.Notes__c != NULL) {
           wrapper.notes = ql.Notes__c.stripHtmlTags();
        }
        passkeyTable.add(1, wrapper);
        if (quote.Contract_Term_Years__c > '1') {
            if (ql.Year_2_Effective_Quantity__c > 0 && quote.Multiple_Years_Commitment__c && ql.Year_2_Effective_Quantity__c <> 0) {
                wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Product_Family__c, ql.Unit__c, ql.Year_2_Effective_Quantity__c, ql.Year_2_Effective_Amount__c, ql.Ad_Start_Date__c, ql.Ad_End_Date__c, quote.Effective_Year_2_Start_Date__c, quote.Effective_Year_2_End_Date__c);
            } else {
                wrapper = wrapper.clone();
            }
            wrapper.quantity = ql.SBQQ__Quantity__c;
            if (ql.Notes__c != NULL) {
              wrapper.notes = ql.Notes__c.stripHtmlTags();
            }
            passkeyTable.add(2, wrapper);
        }
        if (quote.Contract_Term_Years__c > '2') {
            if (ql.Year_3_Effective_Quantity__c > 0 && quote.Multiple_Years_Commitment__c && ql.Year_3_Effective_Quantity__c <> 0) {
                wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Product_Family__c, ql.Unit__c, ql.Year_3_Effective_Quantity__c, ql.Year_3_Effective_Amount__c, ql.Ad_Start_Date__c, ql.Ad_End_Date__c, quote.Effective_Year_3_Start_Date__c, quote.Effective_Year_3_End_Date__c);
            } else {
                wrapper = wrapper.clone();
            }
            wrapper.quantity = ql.SBQQ__Quantity__c;
            if (ql.Notes__c != NULL) {
               wrapper.notes = ql.Notes__c.stripHtmlTags();
            }
            passkeyTable.add(3, wrapper);
        }
        if (quote.Contract_Term_Years__c > '3') {
            if (ql.Year_4_Effective_Quantity__c > 0 && quote.Multiple_Years_Commitment__c && ql.Year_4_Effective_Quantity__c <> 0) {
                wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Product_Family__c, ql.Unit__c, ql.Year_4_Effective_Quantity__c, ql.Year_4_Effective_Amount__c, ql.Ad_Start_Date__c, ql.Ad_End_Date__c, quote.Effective_Year_4_Start_Date__c, quote.Effective_Year_4_End_Date__c);
            } else {
                wrapper = wrapper.clone();
            }
            wrapper.quantity = ql.SBQQ__Quantity__c;
            if (ql.Notes__c != NULL) {
              wrapper.notes = ql.Notes__c.stripHtmlTags();
            }
            reportingTable.add(4, wrapper);
        }
        if (quote.Contract_Term_Years__c > '4') {
            if (ql.Year_5_Effective_Quantity__c > 0 && quote.Multiple_Years_Commitment__c && ql.Year_5_Effective_Quantity__c <> 0) {
                wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Product_Family__c, ql.Unit__c, ql.Year_5_Effective_Quantity__c, ql.Year_5_Effective_Amount__c, ql.Ad_Start_Date__c, ql.Ad_End_Date__c, quote.Effective_Year_5_Start_Date__c, quote.Effective_Year_5_End_Date__c);
            } else {
                wrapper = wrapper.clone();
            }
            wrapper.quantity = ql.SBQQ__Quantity__c;
            if (ql.Notes__c != NULL) {
              wrapper.notes = ql.Notes__c.stripHtmlTags();
            }
            passkeyTable.add(5, wrapper);
        }
        showPasskeyTable = single;
    }

    public void createListingAdsSoftwareServicesCONNECT(SBQQ__Quote__c quote, SBQQ__QuoteLine__c ql, QLWrapper wrapper) {
        wrapper = new QLWrapper(ql.SBQQ__ProductName__c, quote.Effective_Year_1_Start_Date__c, quote.Effective_Year_1_End_Date__c, ql.SBQQ__NetPrice__c);
        if (ql.Notes__c != NULL) {
           wrapper.notes = ql.Notes__c.stripHtmlTags();
        }
        listingAdsTable.add(1, wrapper);
        if (quote.Multiple_Years_Commitment__c) {
            if (quote.Contract_Term_Years__c > '1') {
                if (ql.Year_2_Effective_Quantity__c > 0 && quote.Multiple_Years_Commitment__c && ql.Year_2_Effective_Quantity__c <> 0) {
                    wrapper = new QLWrapper(ql.SBQQ__ProductName__c, quote.Effective_Year_2_Start_Date__c, quote.Effective_Year_2_End_Date__c, ql.Year_2_Effective_Amount__c);
                } else {
                    wrapper = wrapper.clone();
                }
                if (ql.Notes__c != NULL) {
                   wrapper.notes = ql.Notes__c.stripHtmlTags();
                }
                listingAdsTable.add(2, wrapper);
            }
            if (quote.Contract_Term_Years__c > '2') {
                if (ql.Year_3_Effective_Quantity__c > 0 && quote.Multiple_Years_Commitment__c && ql.Year_3_Effective_Quantity__c <> 0) {
                    wrapper = new QLWrapper(ql.SBQQ__ProductName__c, quote.Effective_Year_3_Start_Date__c, quote.Effective_Year_3_End_Date__c, ql.Year_3_Effective_Amount__c);
                } else {
                    wrapper = wrapper.clone();
                }
                if (ql.Notes__c != NULL) {
                  wrapper.notes = ql.Notes__c.stripHtmlTags();
                }
                listingAdsTable.add(3, wrapper);
            }
            if (quote.Contract_Term_Years__c > '3') {
                if (ql.Year_4_Effective_Quantity__c > 0 && quote.Multiple_Years_Commitment__c && ql.Year_4_Effective_Quantity__c <> 0) {
                    wrapper = new QLWrapper(ql.SBQQ__ProductName__c, quote.Effective_Year_4_Start_Date__c, quote.Effective_Year_4_End_Date__c, ql.Year_4_Effective_Amount__c);
                } else {
                    wrapper = wrapper.clone();
                }
                if (ql.Notes__c != NULL) {
                  wrapper.notes = ql.Notes__c.stripHtmlTags();
                }
                listingAdsTable.add(4, wrapper);
            }
            if (quote.Contract_Term_Years__c > '4') {
                if (ql.Year_5_Effective_Quantity__c > 0 && quote.Multiple_Years_Commitment__c && ql.Year_5_Effective_Quantity__c <> 0) {
                    wrapper = new QLWrapper(ql.SBQQ__ProductName__c, quote.Effective_Year_5_Start_Date__c, quote.Effective_Year_5_End_Date__c, ql.Year_5_Effective_Amount__c);
                } else {
                    wrapper = wrapper.clone();
                }
                if (ql.Notes__c != NULL) {
                   wrapper.notes = ql.Notes__c.stripHtmlTags();
                }
                listingAdsTable.add(5, wrapper);
            }
        }

        showListingAdsTable = single;
    }

    public void createMerchant(SBQQ__Quote__c quote, SBQQ__QuoteLine__c ql, QLWrapper wrapper) {
        wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.SBQQ__EffectiveQuantity__c, ql.SBQQ__NetTotal__c);
        if (ql.Notes__c != NULL) {
           wrapper.notes = ql.Notes__c.stripHtmlTags();
        }
        merchantTable.add(1, wrapper);
        showMerchantTable = single;
    }

    public void createOnDemand(SBQQ__Quote__c quote, SBQQ__QuoteLine__c ql, QLWrapper wrapper) {
        wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.SBQQ__EffectiveQuantity__c, ql.Rack_Rate__c, ql.Rack_Rate__c * ql.SBQQ__EffectiveQuantity__c, ql.SBQQ__NetPrice__c, ql.SBQQ__NetTotal__c, ql.Rack_Rate__c * ql.SBQQ__EffectiveQuantity__c - ql.SBQQ__NetTotal__c);
        if (ql.Notes__c != NULL) {
           wrapper.notes = ql.Notes__c.stripHtmlTags();
        }
        onDemandTable.add(1, wrapper);
        showOnDemandTable = single;
    }

    public void createProfessional(SBQQ__Quote__c quote, SBQQ__QuoteLine__c ql, QLWrapper wrapper) {
        wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.SBQQ__EffectiveQuantity__c, ql.Rack_Rate__c, ql.Rack_Rate__c * ql.SBQQ__EffectiveQuantity__c, ql.SBQQ__NetPrice__c, ql.SBQQ__NetTotal__c, ql.Rack_Rate__c * ql.SBQQ__EffectiveQuantity__c - ql.SBQQ__NetTotal__c);
        if (ql.Notes__c != NULL) {
           wrapper.notes = ql.Notes__c.stripHtmlTags();
        }
        professionalServicesTable.add(1, wrapper);
        showProfessionalServicesTable = single;
    }

    public void createEventTable(SBQQ__Quote__c quote, SBQQ__QuoteLine__c ql, QLWrapper wrapper) {
        /** usage skus to put in separate table
        CV-SW-EC-EVT-EXPPREPAYREG
        CV-SW-EC-EVT-PRPYMTREGF
        CV-SW-EC-EVT-USERFUL
        CV-SW-EC-EVT-USERF
        CV-SW-EC-EVT-PRPYMTTRNF
        CV-SW-EC-EVT-PRPYMTEVTF
        CV-SW-EC-EVT-ADDULOG
         */
        Integer contractTermYears = quote.Contract_Remaining_Term__c.intValue();
        System.debug(System.LoggingLevel.INFO, 'in create event table');
        Decimal rackRate;
        if(ql.SBQQ__EffectiveQuantity__c <> 0 || ql.SBQQ__ProductCode__c == 'CV-SW-EC-EVT-CCMOBAPP') {
            if (ql.term__c == 1) {
                if(ql.SBQQ__ProductCode__c != 'CV-SW-EC-EVT-CCMOBAPP') {
                    rackRate = 0;
                    if(ql.SBQQ__ListPrice__c <> 0 && ql.SBQQ__EffectiveQuantity__c <> 0 && ql.SBQQ__ListPrice__c != NULL && ql.SBQQ__ListPrice__c <> 0) {
                        //rackRate = (ql.Rack_Rate__c / ql.SBQQ__ListPrice__c) * ql.SBQQ__NetTotal__c / ql.SBQQ__EffectiveQuantity__c;
                        rackRate = ql.Rack_Rate__c;
                        
                    }
                    wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.SBQQ__EffectiveQuantity__c, rackRate, rackRate * ql.SBQQ__Quantity__c, ql.SBQQ__NetPrice__c, ql.SBQQ__NetTotal__c, rackRate * ql.SBQQ__EffectiveQuantity__c - ql.SBQQ__NetTotal__c);
                } else {
                    wrapper = aggregateCrowdCompass(ql, 1, quoteLines);
                    eventMatrixTable.add(1, wrapper);
                    System.debug('CC Year 1 Wrapper added.');
                }
                if(ql.Notes__c != NULL) {
                    wrapper.notes = ql.Notes__c.escapeHtml4().stripHtmlTags();
                }
                if(wrapper != NULL && wrapper.quantity != 0) {
                    eventTable.add(1, wrapper);
                }
            }
        }
        else if(ql.term__c == 2 && ql.Year_2_Effective_Quantity__c != NULL  && contractTermYears > 1 && quote.Multiple_Years_Commitment__c && (ql.Year_2_Effective_Quantity__c <> 0  || ql.SBQQ__ProductCode__c == 'CV-SW-EC-EVT-CCMOBAPP')) {
            if(ql.SBQQ__ProductCode__c != 'CV-SW-EC-EVT-CCMOBAPP') {
                //rackRate = 0;
                if(ql.Year_2_List_Price__c <> NULL && ql.Year_2_List_Price__c <> 0 && ql.SBQQ__ListPrice__c != NULL && ql.SBQQ__ListPrice__c <> 0) {
                    //rackRate = ql.Rack_Rate__c / ql.Year_2_List_Price__c * ql.Year_2_Effective_Amount__c / ql.Year_2_Effective_Quantity__c;
                    rackRate = (ql.Rack_Rate__c / ql.SBQQ__ListPrice__c) * ql.Year_2_List_Price__c;
                }
                System.debug('Point of error');
                System.debug(ql.SBQQ__ProductName__c);
                System.debug(rackRate);
                System.debug(ql.Year_2_Effective_Quantity__c);
                System.debug(ql.Year_2_Effective_Amount__c);
                wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Year_2_Effective_Quantity__c, rackRate, rackRate * ql.Year_2_Effective_Quantity__c, ql.Year_2_Effective_Amount__c / ql.Year_2_Effective_Quantity__c, ql.Year_2_Effective_Amount__c, rackRate * ql.Year_2_Effective_Quantity__c - ql.Year_2_Effective_Amount__c);
            } else {
                wrapper = aggregateCrowdCompass(ql, 2, quoteLines);
                eventMatrixTable.add(2, wrapper);
            }
            if(ql.Notes__c != NULL) {
                wrapper.notes = ql.Notes__c.escapeHtml4().stripHtmlTags();
            }
            if(wrapper != NULL && wrapper.quantity != 0) {
                eventTable.add(2, wrapper);
            }
        }
        else if(ql.term__c == 3 && ql.Year_3_Effective_Quantity__c != NULL && contractTermYears > 2 && quote.Multiple_Years_Commitment__c && (ql.Year_3_Effective_Quantity__c <> 0  || ql.SBQQ__ProductCode__c == 'CV-SW-EC-EVT-CCMOBAPP')) {
            if(ql.SBQQ__ProductCode__c != 'CV-SW-EC-EVT-CCMOBAPP') {
                //rackRate = 0;
                if(ql.Year_3_List_Price__c <> NULL && ql.Year_3_List_Price__c <> 0 && ql.SBQQ__ListPrice__c != NULL && ql.SBQQ__ListPrice__c <> 0) {
                    //rackRate = ql.Rack_Rate__c / ql.Year_3_List_Price__c * ql.Year_3_Effective_Amount__c / ql.Year_3_Effective_Quantity__c;
                    rackRate = (ql.Rack_Rate__c / ql.SBQQ__ListPrice__c) * ql.Year_3_List_Price__c;
                }
                wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Year_3_Effective_Quantity__c, rackRate, rackRate * ql.Year_3_Effective_Quantity__c, ql.Year_3_Effective_Amount__c / ql.Year_3_Effective_Quantity__c, ql.Year_3_Effective_Amount__c, rackRate * ql.Year_3_Effective_Quantity__c - ql.Year_3_Effective_Amount__c);
            } else {
                wrapper = aggregateCrowdCompass(ql, 3, quoteLines);
                eventMatrixTable.add(3, wrapper);
            }
            if(ql.Notes__c != NULL) {
                wrapper.notes = ql.Notes__c.escapeHtml4().stripHtmlTags();
            }
            if(wrapper != NULL && wrapper.quantity != 0) {
                eventTable.add(3, wrapper);
            }
        }
        else if(ql.term__c == 4 && ql.Year_4_Effective_Quantity__c != NULL && contractTermYears > 3 && quote.Multiple_Years_Commitment__c && (ql.Year_4_Effective_Quantity__c <> 0  || ql.SBQQ__ProductCode__c == 'CV-SW-EC-EVT-CCMOBAPP')) {
            if(ql.SBQQ__ProductCode__c != 'CV-SW-EC-EVT-CCMOBAPP') {
                //rackRate = 0;
                if(ql.Year_4_List_Price__c <> NULL && ql.Year_4_List_Price__c <> 0 && ql.SBQQ__ListPrice__c != NULL && ql.SBQQ__ListPrice__c <> 0) {
                    //rackRate = ql.Rack_Rate__c / ql.Year_4_List_Price__c * ql.Year_4_Effective_Amount__c / ql.Year_4_Effective_Quantity__c;
                    rackRate = (ql.Rack_Rate__c / ql.SBQQ__ListPrice__c) * ql.Year_4_List_Price__c;
                }
                wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Year_4_Effective_Quantity__c, rackRate, rackRate * ql.Year_4_Effective_Quantity__c, ql.Year_4_Effective_Amount__c / ql.Year_4_Effective_Quantity__c, ql.Year_4_Effective_Amount__c, rackRate * ql.Year_4_Effective_Quantity__c - ql.Year_4_Effective_Amount__c);
            } else {
                wrapper = aggregateCrowdCompass(ql, 4, quoteLines);
                eventMatrixTable.add(4, wrapper);
            }
            if(ql.Notes__c != NULL) {
                wrapper.notes = ql.Notes__c.escapeHtml4().stripHtmlTags();
            }
            if(wrapper != NULL && wrapper.quantity != 0) {
                eventTable.add(4, wrapper);
            }
        }
        else if(ql.term__c == 5 && ql.Year_5_Effective_Quantity__c != NULL && contractTermYears > 4 && quote.Multiple_Years_Commitment__c && (ql.Year_5_Effective_Quantity__c <> 0 || ql.SBQQ__ProductCode__c == 'CV-SW-EC-EVT-CCMOBAPP')) {
            if(ql.SBQQ__ProductCode__c != 'CV-SW-EC-EVT-CCMOBAPP') {
                //rackRate = 0;
                if(ql.Year_5_List_Price__c <> NULL && ql.Year_5_List_Price__c <> 0 && ql.SBQQ__ListPrice__c != NULL && ql.SBQQ__ListPrice__c <> 0) {
                    //rackRate = ql.Rack_Rate__c / ql.Year_5_List_Price__c * ql.Year_5_Effective_Amount__c / ql.Year_5_Effective_Quantity__c;
                    rackRate = (ql.Rack_Rate__c / ql.SBQQ__ListPrice__c) * ql.Year_5_List_Price__c;
                }
                wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Year_5_Effective_Quantity__c, rackRate, rackRate * ql.Year_5_Effective_Quantity__c, ql.Year_5_Effective_Amount__c / ql.Year_5_Effective_Quantity__c, ql.Year_5_Effective_Amount__c, rackRate * ql.Year_5_Effective_Quantity__c - ql.Year_5_Effective_Amount__c);
            } else {
                wrapper = aggregateCrowdCompass(ql, 5, quoteLines);
                eventMatrixTable.add(5, wrapper);
            }
            if(ql.Notes__c != NULL) {
                wrapper.notes = ql.Notes__c.escapeHtml4().stripHtmlTags();
            }
            if(wrapper != NULL && wrapper.quantity != 0) {
                eventTable.add(5, wrapper);
            }
        }
        showEventTable = single;
    }

    public void createEventMatrixTable(SBQQ__QuoteLine__c ql, QLWrapper wrapper) {
        /** usage skus to put in separate table
        CV-SW-EC-EVT-CCMOBAPP
        CV-SW-EC-EVT-EXPPREPAYREG
        CV-SW-EC-EVT-PRPYMTREGF
        CV-SW-EC-EVT-USERFUL
        CV-SW-EC-EVT-USERF
        CV-SW-EC-EVT-PRPYMTTRNF
        CV-SW-EC-EVT-PRPYMTEVTF
        CV-SW-EC-EVT-ADDULOG
         */
        System.debug(System.LoggingLevel.INFO, 'in create event matrix table');
        Decimal rackRate;
        if (ql.SBQQ__EffectiveQuantity__c <> 0) {
            System.debug(System.LoggingLevel.INFO, 'quoteline: ' + ql);
            System.debug(System.LoggingLevel.INFO, 'wrapper: ' + wrapper);
            if (ql.Notes__c != NULL) {
               wrapper.notes = ql.Notes__c.stripHtmlTags();
            }
            if (ql.SBQQ__ProductCode__c == 'CV-SW-EC-EVT-CCMOBAPP'
                    || ql.SBQQ__ProductCode__c == 'CV-SW-EC-EVT-EXPPREPAYREG'
                    || ql.SBQQ__ProductCode__c == 'CV-SW-EC-EVT-PRPYMTREGF'
                    || ql.SBQQ__ProductCode__c == 'CV-SW-EC-EVT-USERFUL'
                    || ql.SBQQ__ProductCode__c == 'CV-SW-EC-EVT-USERF'
                    || ql.SBQQ__ProductCode__c == 'CV-SW-EC-EVT-PRPYMTTRNF'
                    || ql.SBQQ__ProductCode__c == 'CV-SW-EC-EVT-PRPYMTEVTF'
                    || ql.SBQQ__ProductCode__c == 'CV-SW-EC-EVT-ADDULOG'
                    ) {
                if (ql.SBQQ__ProductCode__c == 'CV-SW-EC-EVT-CCMOBAPP') {
                    wrapper = aggregateCrowdCompass(ql, 1, quoteLines);
                } else {
                    wrapper.name = ql.SBQQ__ProductName__c;
                    wrapper.quoteNumber = ql.SBQQ__Quote__r.Name;
                    wrapper.groupNumber = ql.SBQQ__Group__r.SBQQ__Number__c;
                    wrapper.contractTerm = ql.SBQQ__Quote__r.Contract_Term_Years__c;
                    wrapper.productCode = ql.SBQQ__ProductCode__c;
                    wrapper.quantity = ql.SBQQ__Quantity__c;
                    wrapper.rackrate = ql.Rack_Rate__c;
                    wrapper.totalPrice = ql.SBQQ__NetTotal__c;
                }
                eventMatrixTable.add(1, wrapper);
            }
        }
        showEventTable = single;
    }

    public void createOveragesTable(SBQQ__Quote__c quote, SBQQ__QuoteLine__c ql, QLWrapper wrapper) {
        Integer contractTermYears = quote.Contract_Remaining_Term__c.intValue();
        if(ql.SBQQ__EffectiveQuantity__c <> 0 && ql.Overage_Fee__c != NULL && ql.Overage_Fee__c > 0 ) {
            wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Overage_Fee__c);
            overagesTable.add(1, wrapper);
        }
        if(contractTermYears > 1 && quote.Multiple_Years_Commitment__c && ql.Year_2_Effective_Quantity__c <> 0 && ql.Year_2_Overage_Fee__c != NULL && ql.Year_2_Overage_Fee__c > 0) {
            wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Year_2_Overage_Fee__c);
            overagesTable.add(2, wrapper);
        }
        if(contractTermYears > 2 && quote.Multiple_Years_Commitment__c && ql.Year_3_Effective_Quantity__c <> 0 && ql.Year_3_Overage_Fee__c != NULL && ql.Year_3_Overage_Fee__c > 0) {
            wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Year_3_Overage_Fee__c);
            overagesTable.add(3, wrapper);
        }
        if(contractTermYears > 3 && quote.Multiple_Years_Commitment__c && ql.Year_4_Effective_Quantity__c <> 0 && ql.Year_4_Overage_Fee__c != NULL && ql.Year_4_Overage_Fee__c > 0) {
            wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Year_4_Overage_Fee__c);
            overagesTable.add(4, wrapper);
        }
        if(contractTermYears > 4 && quote.Multiple_Years_Commitment__c && ql.Year_5_Effective_Quantity__c <> 0 && ql.Year_5_Overage_Fee__c != NULL && ql.Year_5_Overage_Fee__c > 0) {
            wrapper = new QLWrapper(ql.SBQQ__ProductName__c, ql.Year_5_Overage_Fee__c);
            overagesTable.add(5, wrapper);
        }

    }

    public void createHCSummaryTable(MultiYearQLTable eventTable) {
        for (QLTable table : eventTable.QLTables) {
            for (QLTable tab : hcSummaryTable.QLTables) {
                if (tab.year == table.year) {
                    System.debug('tab: ' + tab + ' table: ' + table);
                    tab.quoteLines.add(new QLWrapper('Total Price', table.rackTotal, true));
                    tab.quoteLines.add(new QLWrapper('Discount', table.savingsTotal));
                    tab.quoteLines.add(new QLWrapper('Total Fees Payable', table.linesTotal));
                }
            }
        }
    }

    public QLWrapper aggregateCrowdCompass(SBQQ__QuoteLine__c quoteLine, Decimal year, List<SBQQ__QuoteLine__c> quoteLines) {
        QLWrapper result = new QLWrapper(quoteLine.SBQQ__ProductName__c);

        Decimal totalQuantity = 0;
        Decimal totalRackRate = 0;
        Decimal totalPrice = 0;

        String productCode = '';
        for (SBQQ__QuoteLine__c ql : quoteLines) {
            productCode = '';
            if (ql.SBQQ__RequiredBy__c == quoteLine.Id && ql.SBQQ__ProductOption__r.SBQQ__Feature__r.Name == 'Event Size') {
                if (year == 1) {
                    totalQuantity += ql.SBQQ__EffectiveQuantity__c;
                    totalRackRate += ql.SBQQ__EffectiveQuantity__c * ql.Rack_Rate__c;
                    totalPrice += ql.SBQQ__NetTotal__c;
                } else if (year == 2) {
                    totalQuantity += ql.Year_2_Effective_Quantity__c;
                    totalRackRate += ql.Year_2_Effective_Quantity__c * ql.Rack_Rate__c;
                    totalPrice += ql.Year_2_Effective_Amount__c;
                } else if (year == 3) {
                    totalQuantity += ql.Year_3_Effective_Quantity__c;
                    totalRackRate += ql.Year_3_Effective_Quantity__c * ql.Rack_Rate__c;
                    totalPrice += ql.Year_3_Effective_Amount__c;
                } else if (year == 4) {
                    totalQuantity += ql.Year_4_Effective_Quantity__c;
                    totalRackRate += ql.Year_4_Effective_Quantity__c * ql.Rack_Rate__c;
                    totalPrice += ql.Year_4_Effective_Amount__c;
                } else if (year == 5) {
                    totalQuantity += ql.Year_5_Effective_Quantity__c;
                    totalRackRate += ql.Year_5_Effective_Quantity__c * ql.Rack_Rate__c;
                    totalPrice += ql.Year_5_Effective_Amount__c;
                }
                productCode = ql.SBQQ__ProductCode__c;
            }
        }

        if (totalQuantity > 0) {
            result.quantity = totalQuantity;
            result.rackRate = totalRackRate / totalQuantity;
            result.discountUnitRate = totalPrice / totalQuantity;
        }
        result.netTotalPrice = totalPrice;
        result.savingsTotal = totalRackRate - totalPrice;
        result.productCode = productCode;

        return result;
    }

    public void finalizeMatrixTable() {
        System.debug(System.LoggingLevel.INFO, 'finalizeMatrixTable');
        if (eventMatrixTable.QLTables.size() > 0) {
            Map<Decimal, List<QLWrapper>> groupQlMap = new Map<Decimal, List<QLWrapper>>();
            for (QLTable qlt : eventMatrixTable.QLTables) {
                for (QLWrapper qlw : qlt.quoteLines) {
                    System.debug(System.LoggingLevel.INFO, 'QLW qouteline: ' + qlw);
                    List<QLWrapper> qlList = new List<QLWrapper>();
                    if (groupQlMap.containsKey(qlw.groupNumber)) {
                        qlList = groupQlMap.get(qlw.groupNumber);
                    }
                    qlList.add(qlw);
                    groupQlMap.put(qlw.groupNumber, qlList);
                }
            }

            for (Decimal grp : groupQlMap.keySet()) {
                Map<String, Map<String, MatrixTable>> matrixProdMap = new Map<String, Map<String, MatrixTable>>();
                Map<String, MatrixTable> matrixTypeMap = new Map<String, MatrixTable>();
                System.debug(System.LoggingLevel.INFO, 'Group Number: ' + grp);
                for (QLWrapper qlw : groupQlMap.get(grp)) {
                    matrixTypeMap = new Map<String, MatrixTable>();
                    if (matrixProdMap.containsKey(qlw.productCode)) {
                        matrixTypeMap = matrixProdMap.get(qlw.productCode);
                    }
                    System.debug(System.LoggingLevel.INFO, 'qlw: ' + qlw);
                    String matrixType = 'none';
                    //if (qlw.productCode == 'CV-SW-EC-EVT-CCMOBAPP') {
                    //    matrixType = 'app';
                    //} else
                    if (qlw.productCode == 'CV-SW-EC-EVT-EXPPREPAYREG'
                            || qlw.productCode == 'CV-SW-EC-EVT-PRPYMTREGF') {
                        matrixType = 'reg';
                    } else if (qlw.productCode == 'CV-SW-EC-EVT-USERFUL'
                            || qlw.productCode == 'CV-SW-EC-EVT-USERF'
                            || qlw.productCode == 'CV-SW-EC-EVT-ADDULOG') {
                        matrixType = 'user';
                    } else if (qlw.productCode == 'CV-SW-EC-EVT-PRPYMTTRNF'
                            || qlw.productCode == 'CV-SW-EC-EVT-PRPYMTEVTF') {
                        matrixType = 'event';
                    }
                    System.debug(System.LoggingLevel.INFO, 'matrixType: ' + matrixType);
                    MatrixTable mt = new MatrixTable();
                    if (matrixTypeMap.containsKey(matrixType)) {
                        mt = matrixTypeMap.get(matrixType);
                    }
                    mt.unitCount = qlw.quantity;
                    if (qlw.contractTerm == '1') {
                        mt.term1 = true;
                        mt.term1Price = qlw.rackRate;
                    } else if (qlw.contractTerm == '2') {
                        mt.term2 = true;
                        mt.term2Price = qlw.rackRate;
                    } else if (qlw.contractTerm == '3') {
                        mt.term3 = true;
                        mt.term3Price = qlw.rackRate;
                    } else if (qlw.contractTerm == '4') {
                        mt.term4 = true;
                        mt.term4Price = qlw.rackRate;
                    } else if (qlw.contractTerm == '5') {
                        mt.term5 = true;
                        mt.term5Price = qlw.rackRate;
                    }
                    System.debug(System.LoggingLevel.INFO, 'MatrixTable: ' + mt);
                    matrixTypeMap.put(matrixType, mt);
                    matrixProdMap.put(qlw.productCode, matrixTypeMap);
                    System.debug(System.LoggingLevel.INFO, 'MatrixTypeMap: ' + matrixTypeMap);
                }
                if (matrixTypeMap.containsKey('app')) {
                    appsMatrix.add(matrixTypeMap.get('app'));
                    showAppsMatrix = single;
                } else if (matrixTypeMap.containsKey('reg')) {
                    regMatrix.add(matrixTypeMap.get('reg'));
                    showRegMatrix = single;
                } else if (matrixTypeMap.containsKey('user')) {
                    userMatrix.add(matrixTypeMap.get('user'));
                    showUserMatrix = single;
                } else if (matrixTypeMap.containsKey('event')) {
                    eventMatrix.add(matrixTypeMap.get('event'));
                    showEventMatrix = single;
                }
                System.debug(System.LoggingLevel.INFO, 'appsMatrix: ' + appsMatrix);
                System.debug(System.LoggingLevel.INFO, 'regMatrix: ' + regMatrix);
                System.debug(System.LoggingLevel.INFO, 'userMatrix: ' + userMatrix);
                System.debug(System.LoggingLevel.INFO, 'eventMatrix: ' + eventMatrix);
            }
        }
    }


    class MatrixTable {
        public Decimal unitCount { get; set; }
        public Boolean term1 { get; set; }
        public Boolean term2 { get; set; }
        public Boolean term3 { get; set; }
        public Boolean term4 { get; set; }
        public Boolean term5 { get; set; }
        public Decimal term1Price { get; set; }
        public Decimal term2Price { get; set; }
        public Decimal term3Price { get; set; }
        public Decimal term4Price { get; set; }
        public Decimal term5Price { get; set; }

        public MatrixTable() {
            unitCount = 0;
            term1 = false;
            term2 = false;
            term3 = false;
            term4 = false;
            term5 = false;
            term1Price = 0.0;
            term2Price = 0.0;
            term3Price = 0.0;
            term4Price = 0.0;
            term5Price = 0.0;
        }
    }

    class QLWrapper {
        public String quoteNumber { get; set; }
        public Decimal groupNumber { get; set; }
        public String contractTerm { get; set; }
        public SBQQ__QuoteLine__c quoteLine { get; set; }
        public Decimal rowNumber { get; set; }
        public String name { get; set; }
        public String productCode { get; set; }
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

        public QLWrapper() {
            quoteNumber = '';
            groupNumber = 0.0;
            contractTerm = '';
            quoteLine = null;
            rowNumber = 0.0;
            name = '';
            productCode = '';
            quantity = 0.0;
            rackRate = 0.0;
            totalPrice = 0.0;
            discountUnitRate = 0.0;
            netTotalPrice = 0.0;
            savingsTotal = 0.0;
            startDate = System.today();
            endDate = System.today();
            text1 = '';
            text2 = '';
            numberOfRfps = 0.0;
            nonNativeMMAs = '';
            venueCodes = '';
            notes = '';
            strikeThrough = false;
        }

        public QLWrapper(SBQQ__QuoteLine__c ql, Decimal row) {
            strikeThrough = false;
            quoteLine = ql;
            rowNumber = row;
            if (ql.SBQQ__ProductName__c != NULL) {
                name = ql.SBQQ__ProductName__c;
            }
        }

        public QLWrapper(String productName) {
            strikeThrough = false;
            name = productName;
        }

        public QLWrapper(String productName, String str1, String str2, Decimal netTotal, Date startD, Date endD, Date quoteStart, Date quoteEnd) {
            name = productName;
            text1 = '';
            text2 = '';
            if (str1 != NULL) {
                text1 = str1.escapeHtml4();
            }
            if (str2 != NULL) {
                text2 = str2.escapeHtml4();
            }
            if(netTotal != NULL) {
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
        }

        public QLWrapper(String productName, String str1, Decimal netTotal, Date startD, Date endD, Date quoteStart, Date quoteEnd) {
            name = productName;
            text1 = '';
            if (str1 != NULL) {
                text1 = str1.escapeHtml4();
            }
            if(netTotal != NULL) {
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
        }

        public QLWrapper(String productName, String str1, String str2, Decimal q, Decimal netTotal, Date startD, Date endD, Date quoteStart, Date quoteEnd) {
            name = '';
            quantity = q;
            if(productName != NULL) {
                name = productName.escapeHtml4();
            }
            text1 = '';
            text2 = '';
            if (str1 != NULL) {
                text1 = str1.escapeHtml4();
            }
            if (str2 != NULL) {
                text2 = str2.escapeHtml4();
            }
            if(netTotal != NULL) {
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
        }

        public QLWrapper(String productName, Decimal q, Decimal netTotal, Date startD, Date endD, Date quoteStart, Date quoteEnd) {
            name = productName;
            quantity = q;
            if(netTotal != NULL) {
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
        }

        public QLWrapper(String productName, Decimal q, String str1, Decimal netTotal, Date startD, Date endD, Date quoteStart, Date quoteEnd) {
            name = productName;
            quantity = q;
            text1 = '';
            if (str1 != NULL) {
                text1 = str1.escapeHtml4();
            }
            if(netTotal != NULL) {
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
        }

        public QLWrapper(String productName, Decimal rfps, String mmas, String codes, Decimal netTotal, Date startD, Date endD, Date quoteStart, Date quoteEnd) {
            name = productName;
            numberOfRfps = rfps;
            nonNativeMMAs = mmas;
            venueCodes = codes;
            if(netTotal != NULL) {
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
        }

        public QLWrapper(String productName, Decimal q, Decimal rate, Decimal total, Decimal discountRate, Decimal netTotal, Decimal savings) {
            strikeThrough = false;
            name = productName;
            quantity = q;
            if(rate != NULL) {
                rackRate = rate.setScale(2);
            }
            if(total != NULL){
                totalPrice = total.setScale(2);
            }
            if(discountRate != NULL) {
                discountUnitRate = discountRate.setScale(2);
            }
            if(netTotal != NULL) {
                netTotalPrice = netTotal.setScale(2);
            }
            savingsTotal = savings;
        }


        public QLWrapper(String productName, Date startD, Date endD, Decimal netTotal) {
            strikethrough = false;
            name = productName;
            startDate = startD;
            endDate = endD;
            if(netTotal != NULL) {
                netTotalPrice = netTotal.setScale(2);
            }
        }

        public QLWrapper(String productName, Decimal netTotal) {
            strikeThrough = false;
            name = productName;
            if(netTotal != NULL) {
                netTotalPrice = netTotal.setScale(2);
            }
        }

        public QLWrapper(String productName, Decimal q, Decimal netTotal) {
            strikeThrough = false;
            name = productName;
            if(netTotal != NULL) {
                netTotalPrice = netTotal.setScale(2);
            }
            quantity = q;
        }

        public QLWrapper(String productName, Decimal netTotal, Boolean strike) {
            strikeThrough = strike;
            name = productName;
            if(netTotal != NULL) {
                netTotalPrice = netTotal.setScale(2);
            }
        }

        public QLWrapper(String productName, Decimal q, Decimal rate, Decimal total, Decimal discountRate, Decimal netTotal) {
            strikeThrough = false;
            name = productName;
            quantity = q;
            if(rate != NULL) {
                rackRate = rate.setScale(2);
            }
            if(total != NULL){
                totalPrice = total.setScale(2);
            }
            if(discountRate != NULL) {
                discountUnitRate = discountRate.setScale(2);
            }
            if(netTotal != NULL) {
                netTotalPrice = netTotal.setScale(2);
            }
        }

    }

    class QLTable {

        public List<QLWrapper> quoteLines {
            get;
            set;
        }
        public Decimal linesTotal {
            get;
            set;
        }
        public Decimal savingsTotal {
            get;
            set;
        }
        public Decimal rackTotal {
            get;
            set;
        }
        public Decimal year {
            get;
            set;
        }

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

            quoteLines = copy;
        }

        public void recalculate() {
            System.debug('Low recaluclate year: ' + year);
            Integer order = 0;
            linesTotal = 0;
            savingsTotal = 0;
            rackTotal = 0;

            for (QLWrapper wrap : quoteLines) {
//System.debug('netTotalPrice ' + wrap.netTotalprice + ' savingsTotal ' + wrap.savingsTotal + ' rackRate ' + wrap.rackRate + ' quantity ' + wrap.quantity);
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

    class MultiEventTable {
        public Map<String, MultiYearQLTable> eventLinesMap {
            get;
            set;
        }
        public Map<String, Integer> tableSizes {
            get;
            set;
        }
        public Map<String, Decimal> tableTotals {
            get;
            set;
        }
        public Decimal linesSavings {
            get;
            set;
        }
        public Decimal netTotal {
            get;
            set;
        }
        public Integer years {
            get;
            set;
        }

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
        public List<QLTable> QLTables {
            get;
            set;
        }
        public Decimal linesSavings {
            get;
            set;
        }
        public Decimal netTotal {
            get;
            set;
        }
        public Integer years {
            get;
            set;
        }

        public MultiYearQLTable(Integer numberOfYears) {
            QLTables = new List<QLTable>();
            linesSavings = 0;
            netTotal = 0;
            years = numberOfYears;

            for (Integer i = 0; i < numberOfYears; i++) {
                QLTables.add(new QLTable(i + 1));
            }
        }

        public void addHeaders(SBQQ__Quote__c quote) {
            Boolean first = true;
            for (QLTable table : QLTables) {
                if(table.getSize() > 0) {
                    if(table.year == 1) {
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
        }

        public void add(Integer year, QLWrapper entry) {
            QLTables.get(year - 1).quoteLines.add(entry);
        }

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

}