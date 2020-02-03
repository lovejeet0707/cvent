/**
 * Created by CrutchfieldJody on 7/11/2017.
 */

public without sharing class ProposalDocController {

    public static String qId {get; set;}

    public static Boolean matrixed {get; set;}
    public static List<Integer> quoteCounts {get; set;}
    public static Integer maxQuoteCount {get; set;}
    public static Map<Integer, String> currencySymbolMap {get; set;}
    public static Map<Integer, String> currencySignMap {get; set;}
    public static Map<Integer, Boolean> pageBreakMap {get; set;}


    /* Quotes */
    public static Map<Integer, SBQQ__Quote__c> quoteMap {get; set;}

        /* Events */
    public static Map<Integer, ProposalDocHelper.MultiYearQLTable> eventMap { get; set; }
    public static Map<Integer, ProposalDocHelper.MultiYearQLTable> eventMatrixMap { get; set; }
    public static Map<Integer, List<Decimal>> showEventMap { get; set; }
    public static Map<Integer, List<Decimal>> showEventNoPriceMap { get; set; }

    /* Hospitaliy Cloud Summary */
    public static Map<Integer, ProposalDocHelper.MultiYearQLTable> hcSummaryMap { get; set; }
    public static Map<Integer, List<Decimal>> showHcSummaryMap { get; set; }

    /* Listing Advertisement(s), Software, Services & CONNECT */
    public static Map<Integer, ProposalDocHelper.MultiYearQLTable> listingAdsMap { get; set; }
    public static Map<Integer, List<Decimal>> showListingAdsMap { get; set; }

    /* Bundle Advertisement(s) */
    public static Map<Integer, ProposalDocHelper.MultiYearQLTable> bundleAdsMap { get; set; }
    public static Map<Integer, List<Decimal>> showBundleAdsMap { get; set; }

    /* Cvent Passkey, Transient & Lanyon Group */
    public static Map<Integer, ProposalDocHelper.MultiYearQLTable> passkeyMap { get; set; }
    public static Map<Integer, List<Decimal>> showPasskeyMap { get; set; }

    /* Elite Meetings Alliance */
    public static Map<Integer, ProposalDocHelper.MultiYearQLTable> emiMap { get; set; }
    public static Map<Integer, List<Decimal>> showEmiMap { get; set; }

    /* RegOnline */
    public static Map<Integer, ProposalDocHelper.MultiYearQLTable> regOnlineMap { get; set; }
    public static Map<Integer, List<Decimal>> showRegOnlineMap { get; set; }

    /* Reporting & Analytics */
    public static Map<Integer, ProposalDocHelper.MultiYearQLTable> reportingMap { get; set; }
    public static Map<Integer, List<Decimal>> showReportingMap { get; set; }

    /* Suggested Advertisement(s) */
    public static Map<Integer, ProposalDocHelper.MultiYearQLTable> suggestedAdsMap { get; set; }
    public static Map<Integer, List<Decimal>> showSuggestedAdsMap { get; set; }

    /* Video retargeting */
    public static Map<Integer, ProposalDocHelper.MultiYearQLTable> videoRetargetingMap { get; set; }
    public static Map<Integer, List<Decimal>> showVideoRetargetingMap { get; set; }

    /* Merchant Account */
    public static Map<Integer, ProposalDocHelper.MultiYearQLTable> merchantMap { get; set; }
    public static Map<Integer, List<Decimal>> showMerchantMap { get; set; }

    /* On-demand */
    public static Map<Integer, ProposalDocHelper.MultiYearQLTable> onDemandMap { get; set; }
    public static Map<Integer, List<Decimal>> showOnDemandMap { get; set; }

    /* Professional Services */
    public static Map<Integer, ProposalDocHelper.MultiYearQLTable> professionalServicesMap { get; set; }
    public static Map<Integer, List<Decimal>> showProfessionalServicesMap { get; set; }
    
    /* Social Tables */
    public static Map<Integer, ProposalDocHelper.MultiYearQLTable> socialTableMap { get; set; }
    public static Map<Integer, List<Decimal>> showSocialTableMap { get; set; }

    /* Overages */
    public static Map<Integer, ProposalDocHelper.MultiYearQLTable> overagesMap { get; set; }
    public static Map<Integer, List<Decimal>> showOveragesMap { get; set; }


    public ProposalDocController() {
        qId = (Id) ApexPages.currentPage().getParameters().get('qid');
        matrixed = false;
        generateProposal();
    }

    public static void generateProposal() {
        // initialize everything

        quoteCounts = new List<Integer>();
        maxQuoteCount = 0;
        currencySignMap = new Map<Integer, String>();
        currencySymbolMap = new Map<Integer, String>();
        pageBreakMap = new Map<Integer, Boolean>();

        quoteMap = new Map<Integer, SBQQ__Quote__c>();

        eventMap = new Map<Integer, ProposalDocHelper.MultiYearQLTable>();
        eventMatrixMap = new Map<Integer, ProposalDocHelper.MultiYearQLTable>();
        showEventMap = new Map<Integer, List<Decimal>>();
        showEventNoPriceMap = new Map<Integer, List<Decimal>>();

        hcSummaryMap = new Map<Integer, ProposalDocHelper.MultiYearQLTable>();
        showHcSummaryMap = new Map<Integer, List<Decimal>>();

        listingAdsMap = new Map<Integer, ProposalDocHelper.MultiYearQLTable>();
        showListingAdsMap = new Map<Integer, List<Decimal>>();

        bundleAdsMap = new Map<Integer, ProposalDocHelper.MultiYearQLTable>();
        showBundleAdsMap = new Map<Integer, List<Decimal>>();

        passkeyMap = new Map<Integer, ProposalDocHelper.MultiYearQLTable>();
        showPasskeyMap = new Map<Integer, List<Decimal>>();

        emiMap = new Map<Integer, ProposalDocHelper.MultiYearQLTable>();
        showEmiMap = new Map<Integer, List<Decimal>>();

        regOnlineMap = new Map<Integer, ProposalDocHelper.MultiYearQLTable>();
        showRegOnlineMap = new Map<Integer, List<Decimal>>();

        reportingMap = new Map<Integer, ProposalDocHelper.MultiYearQLTable>();
        showReportingMap = new Map<Integer, List<Decimal>>();

        suggestedAdsMap = new Map<Integer, ProposalDocHelper.MultiYearQLTable>();
        showSuggestedAdsMap = new Map<Integer, List<Decimal>>();

        videoRetargetingMap = new Map<Integer, ProposalDocHelper.MultiYearQLTable>();
        showVideoRetargetingMap = new Map<Integer, List<Decimal>>();

        merchantMap = new Map<Integer, ProposalDocHelper.MultiYearQLTable>();
        showMerchantMap = new Map<Integer, List<Decimal>>();

        onDemandMap = new Map<Integer, ProposalDocHelper.MultiYearQLTable>();
        showOnDemandMap = new Map<Integer, List<Decimal>>();

        professionalServicesMap = new Map<Integer, ProposalDocHelper.MultiYearQLTable>();
        showProfessionalServicesMap = new Map<Integer, List<Decimal>>();
        
        socialTableMap = new Map<Integer, ProposalDocHelper.MultiYearQLTable>();
        showSocialTableMap = new Map<Integer, List<Decimal>>();

        overagesMap = new Map<Integer, ProposalDocHelper.MultiYearQLTable>();
        showOveragesMap = new Map<Integer, List<Decimal>>();

        // get input quote info
        SBQQ__Quote__c inputQuote = [select Id, SBQQ__Opportunity2__r.Id, SBQQ__Primary__c, Include_In_Proposal__c, Contract_Remaining_Term__c from SBQQ__Quote__c where Id = :qId limit 1];
        System.debug(System.LoggingLevel.INFO,'inputQuote: ' + inputQuote);
        // get Opportunity related to current quote
        Opportunity opportunity = [select Id from Opportunity where Id = :inputQuote.SBQQ__Opportunity2__r.Id];
        System.debug(System.LoggingLevel.INFO,'Opportunity: ' + opportunity);
        // Get all quotes with Include in proposal checked related to current quote and opportunity
        List<SBQQ__Quote__c> quoteList = [select Id, jsonString__c from SBQQ__Quote__c where SBQQ__Opportunity2__c = :opportunity.Id and Include_In_Proposal__c = true  Order by Total_Contract_Value__c];
        System.debug(System.LoggingLevel.INFO,'quoteList: ' + quoteList);


// call existing quote line template content controller to build output

        Integer quoteCount = 0;
        for (SBQQ__Quote__c quote : quoteList) {
            if(quote.jsonString__c != null)
            {
                quoteCount = quoteCount + 1;
                quoteCounts.add(quoteCount);
                ProposalDocHelper qltController = new ProposalDocHelper(quote.Id);

                quoteMap.put(quoteCount,qltController.quote);
                currencySignMap.put(quoteCount,qltController.currencySign);
                currencySymbolMap.put(quoteCount,qltController.currencySymbol);

                eventMap.put(quoteCount, qltController.eventTable);
                eventMatrixMap.put(quoteCount, qltController.eventMatrixTable);
                showEventMap.put(quoteCount, qltController.showEventTable);
                showEventNoPriceMap.put(quoteCount, qltController.showEventNoPriceTable);

                hcSummaryMap.put(quoteCount, qltController.hcSummaryTable);
                showHcSummaryMap.put(quoteCount, qltController.showHcSummaryTable);

                listingAdsMap.put(quoteCount, qltController.listingAdsTable);
                showListingAdsMap.put(quoteCount, qltController.showListingAdsTable);

                bundleAdsMap.put(quoteCount, qltController.bundleAdsTable);
                showBundleAdsMap.put(quoteCount, qltController.showBundleAdsTable);

                passkeyMap.put(quoteCount, qltController.passkeyTable);
                showPasskeyMap.put(quoteCount, qltController.showPasskeyTable);

                emiMap.put(quoteCount, qltController.emiTable);
                showEmiMap.put(quoteCount, qltController.showEmiTable);

                regOnlineMap.put(quoteCount, qltController.regOnlineTable);
                showRegOnlineMap.put(quoteCount, qltController.showRegOnlineTable);

                reportingMap.put(quoteCount, qltController.reportingTable);
                showReportingMap.put(quoteCount, qltController.showReportingTable);

                suggestedAdsMap.put(quoteCount, qltController.suggestedAdsTable);
                showSuggestedAdsMap.put(quoteCount, qltController.showSuggestedAdsTable);

                videoRetargetingMap.put(quoteCount, qltController.videoRetargetingTable);
                showVideoRetargetingMap.put(quoteCount, qltController.showVideoRetargetingTable);

                merchantMap.put(quoteCount, qltController.merchantTable);
                showMerchantMap.put(quoteCount, qltController.showMerchantTable);

                onDemandMap.put(quoteCount, qltController.onDemandTable);
                showOnDemandMap.put(quoteCount, qltController.showOnDemandTable);

                professionalServicesMap.put(quoteCount, qltController.professionalServicesTable);
                showProfessionalServicesMap.put(quoteCount, qltController.showProfessionalServicesTable);
                
                socialTableMap.put(quoteCount, qltController.socialTablesTable);
                showSocialTableMap.put(quoteCount, qltController.showSocialTablesTable);

                overagesMap.put(quoteCount, qltController.overagesTable);
                showOveragesMap.put(quoteCount, qltController.showOveragesTable);
            }
        }
        maxQuoteCount = quoteCount;

        Integer bc = 1;
        while(bc < maxQuoteCount){
            System.debug(System.LoggingLevel.INFO,'bc: ' + bc);
            System.debug(System.LoggingLevel.INFO,'maxQuoteCount: ' + maxQuoteCount);
            pageBreakMap.put(bc, true);
            bc = bc + 1;
        }
        pageBreakMap.put(bc,false);
        System.debug(System.LoggingLevel.INFO,'quoteCounts' + quoteCounts);
        System.debug(System.LoggingLevel.INFO,'pageBreakMap' + pageBreakMap);
    }
}