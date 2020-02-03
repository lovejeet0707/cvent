public class QuoteLinesRelatedListController {
    
    /* LOCAL VARIABLES */
    private final ApexPages.StandardController oController;
    private Id iQuoteId;

    public SBQQ__Quote__c Quote {get; set;}
    public SBQQ__QuoteLine__c QuoteLinerecord;
    public SBQQ__QuoteLine__c QuoteLinerecord2;
    public SBQQ__QuoteLine__c QuoteLinerecord3;
    public SBQQ__QuoteLine__c QuoteLinerecord4;
    public SBQQ__QuoteLine__c QuoteLinerecord5;
    
    public boolean DisplayAll = False;
    
    /******************/            
    /* Constructor */
    /******************/            
    public QuoteLinesRelatedListController(ApexPages.StandardController oStandardController) 
    {   
        try {
            oController = oStandardController;
            Quote = (SBQQ__Quote__c )oController.getRecord();
            
            //ID test = Apexpages.CurrentPage().getparameters().get('qid');
            //System.debug('Quote: ' + test);
            if(Quote != null) Quote = [select id, name from SBQQ__Quote__c where Id = :Quote.Id];
            iQuoteId = Apexpages.CurrentPage().getparameters().get('id');
            Quote = [select id, Name from SBQQ__Quote__c where id = :iQuoteid].get(0);        
        }
        catch (System.CalloutException e) {
             System.debug('ERROR:' + e);
        }
    }

    Public List<SBQQ__QuoteLine__c> QuoteLineItems;


    public List<QuoteLinewrapper> getQuoteLines()
    {
        List<QuoteLinewrapper> QuoteLineList = new List<QuoteLinewrapper>();
        for(SBQQ__QuoteLine__c a : [select Name, SBQQ__Number__c, SBQQ__Product__c, 
                                           SBQQ__ListPrice__c, SBQQ__Quantity__c, 
                                           SBQQ__NetTotal__c, Year_2_Effective_Amount__c, Year_3_Effective_Amount__c, 
                                           Year_4_Effective_Amount__c, Year_5_Effective_Amount__c, Year_2_Net_Amount__c,
			                           	   Year_3_Net_Amount__c, Year_4_Net_Amount__c, Year_5_Net_Amount__c, Year_2_Quantity__c,
                                    	   Year_3_Quantity__c, Year_4_Quantity__c, Year_5_Quantity__c, Year_2_List_Price__c,
                                      	   Year_3_List_Price__c, Year_4_List_Price__c, Year_5_List_Price__c,Discount_Type__c,Custom_Discount__c,SBQQ__AdditionalDiscount__c
                         from SBQQ__QuoteLine__c 
                        where SBQQ__Quote__c =:iQuoteId AND SBQQ__Quantity__c<>0 AND SBQQ__Quantity__c!=NULL Order by Name])
        
        {

               QuoteLineList.add(new QuoteLinewrapper(a));        
        }
        return QuoteLineList;
    }
    
    public SBQQ__QuoteLine__c getQuoteLinerecord()
    {
        return QuoteLinerecord;
    }

    public void setQuoteLinerecord(SBQQ__QuoteLine__c QuoteLinerec)
    {
        QuoteLinerecord = QuoteLinerec;
        
    }

    public class QuoteLinewrapper
    {
        public SBQQ__QuoteLine__c QuoteLinerecord{get; set;}
        public boolean selected{get; set;}
        public QuoteLinewrapper(SBQQ__QuoteLine__c a)
        {
            QuoteLinerecord = a;
            selected = false;
        }
    }
    
//Bryce's Test Code
//Year 2 Replication
    Public List<SBQQ__QuoteLine__c> QuoteLineItems2;


    public List<QuoteLinewrapper2> getQuoteLines2()
    {
        List<QuoteLinewrapper2> QuoteLineList2 = new List<QuoteLinewrapper2>();
        for(SBQQ__QuoteLine__c b : [select Name, SBQQ__Number__c, SBQQ__Product__c, 
                                           SBQQ__ListPrice__c, SBQQ__Quantity__c, 
                                           SBQQ__NetTotal__c, Year_2_Effective_Amount__c, Year_3_Effective_Amount__c, 
                                           Year_4_Effective_Amount__c, Year_5_Effective_Amount__c, Year_2_Net_Amount__c,
			                           	   Year_3_Net_Amount__c, Year_4_Net_Amount__c, Year_5_Net_Amount__c, Year_2_Quantity__c,
                                    	   Year_3_Quantity__c, Year_4_Quantity__c, Year_5_Quantity__c, Year_2_List_Price__c,
                                      	   Year_3_List_Price__c, Year_4_List_Price__c,Discount_Type__c,Custom_Discount__c,Year_2_Discount__c, Year_5_List_Price__c
                         from SBQQ__QuoteLine__c 
                        where SBQQ__Quote__c =:iQuoteId Order by Name])
        
        {

               QuoteLineList2.add(new QuoteLinewrapper2(b));        
        }
        return QuoteLineList2;
    }
    
    public SBQQ__QuoteLine__c getQuoteLinerecord2()
    {
        return QuoteLinerecord2;
    }

    public void setQuoteLinerecord2(SBQQ__QuoteLine__c QuoteLinerec2)
    {
        QuoteLinerecord2 = QuoteLinerec2;
        
    }

    public class QuoteLinewrapper2
    {
        public SBQQ__QuoteLine__c QuoteLinerecord2{get; set;}
        public boolean selected{get; set;}
        public QuoteLinewrapper2(SBQQ__QuoteLine__c b)
        {
            QuoteLinerecord2 = b;
            selected = false;
        }
    }
//Year 3 Replication
    Public List<SBQQ__QuoteLine__c> QuoteLineItems3;


    public List<QuoteLinewrapper3> getQuoteLines3()
    {
        List<QuoteLinewrapper3> QuoteLineList3 = new List<QuoteLinewrapper3>();
        for(SBQQ__QuoteLine__c c : [select Name, SBQQ__Number__c, SBQQ__Product__c, 
                                           SBQQ__ListPrice__c, SBQQ__Quantity__c, 
                                           SBQQ__NetTotal__c, Year_2_Effective_Amount__c, Year_3_Effective_Amount__c, 
                                           Year_4_Effective_Amount__c, Year_5_Effective_Amount__c, Year_2_Net_Amount__c,
			                           	   Year_3_Net_Amount__c, Year_4_Net_Amount__c, Year_5_Net_Amount__c, Year_2_Quantity__c,
                                    	   Year_3_Quantity__c, Year_4_Quantity__c, Year_5_Quantity__c, Year_2_List_Price__c,
                                      	   Year_3_List_Price__c, Year_4_List_Price__c,Discount_Type__c,Custom_Discount__c,Year_3_Discount__c, Year_5_List_Price__c
                         from SBQQ__QuoteLine__c 
                        where SBQQ__Quote__c =:iQuoteId Order by Name])
        
        {

               QuoteLineList3.add(new QuoteLinewrapper3(c));        
        }
        return QuoteLineList3;
    }
    
    public SBQQ__QuoteLine__c getQuoteLinerecord3()
    {
        return QuoteLinerecord3;
    }

    public void setQuoteLinerecord3(SBQQ__QuoteLine__c QuoteLinerec3)
    {
        QuoteLinerecord3 = QuoteLinerec3;
        
    }

    public class QuoteLinewrapper3
    {
        public SBQQ__QuoteLine__c QuoteLinerecord3{get; set;}
        public boolean selected{get; set;}
        public QuoteLinewrapper3(SBQQ__QuoteLine__c c)
        {
            QuoteLinerecord3 = c;
            selected = false;
        }
    }
//Year 4 Replication
    Public List<SBQQ__QuoteLine__c> QuoteLineItems4;


    public List<QuoteLinewrapper4> getQuoteLines4()
    {
        List<QuoteLinewrapper4> QuoteLineList4 = new List<QuoteLinewrapper4>();
        for(SBQQ__QuoteLine__c d : [select Name, SBQQ__Number__c, SBQQ__Product__c, 
                                           SBQQ__ListPrice__c, SBQQ__Quantity__c, 
                                           SBQQ__NetTotal__c, Year_2_Effective_Amount__c, Year_3_Effective_Amount__c, 
                                           Year_4_Effective_Amount__c, Year_5_Effective_Amount__c, Year_2_Net_Amount__c,
			                           	   Year_3_Net_Amount__c, Year_4_Net_Amount__c, Year_5_Net_Amount__c, Year_2_Quantity__c,
                                    	   Year_3_Quantity__c, Year_4_Quantity__c, Year_5_Quantity__c, Year_2_List_Price__c,
                                      	   Year_3_List_Price__c, Year_4_List_Price__c,Discount_Type__c,Custom_Discount__c, Year_4_Discount__c,Year_5_List_Price__c
                         from SBQQ__QuoteLine__c 
                        where SBQQ__Quote__c =:iQuoteId Order by Name])
        
        {

               QuoteLineList4.add(new QuoteLinewrapper4(d));        
        }
        return QuoteLineList4;
    }
    
    public SBQQ__QuoteLine__c getQuoteLinerecord4()
    {
        return QuoteLinerecord4;
    }

    public void setQuoteLinerecord4(SBQQ__QuoteLine__c QuoteLinerec4)
    {
        QuoteLinerecord4 = QuoteLinerec4;
        
    }

    public class QuoteLinewrapper4
    {
        public SBQQ__QuoteLine__c QuoteLinerecord4{get; set;}
        public boolean selected{get; set;}
        public QuoteLinewrapper4(SBQQ__QuoteLine__c d)
        {
            QuoteLinerecord4 = d;
            selected = false;
        }
    }
//Year 5 Replication
    Public List<SBQQ__QuoteLine__c> QuoteLineItems5;


    public List<QuoteLinewrapper5> getQuoteLines5()
    {
        List<QuoteLinewrapper5> QuoteLineList5 = new List<QuoteLinewrapper5>();
        for(SBQQ__QuoteLine__c e : [select Name, SBQQ__Number__c, SBQQ__Product__c, 
                                           SBQQ__ListPrice__c, SBQQ__Quantity__c, 
                                           SBQQ__NetTotal__c, Year_2_Effective_Amount__c, Year_3_Effective_Amount__c, 
                                           Year_4_Effective_Amount__c, Year_5_Effective_Amount__c, Year_2_Net_Amount__c,
			                           	   Year_3_Net_Amount__c, Year_4_Net_Amount__c, Year_5_Net_Amount__c, Year_2_Quantity__c,
                                    	   Year_3_Quantity__c, Year_4_Quantity__c, Year_5_Quantity__c, Year_2_List_Price__c,
                                      	   Year_3_List_Price__c, Year_4_List_Price__c, Discount_Type__c,Custom_Discount__c,Year_5_Discount__c,Year_5_List_Price__c
                         from SBQQ__QuoteLine__c 
                        where SBQQ__Quote__c =:iQuoteId Order by Name])
        
        {

               QuoteLineList5.add(new QuoteLinewrapper5(e));        
        }
        return QuoteLineList5;
    }
    
    public SBQQ__QuoteLine__c getQuoteLinerecord5()
    {
        return QuoteLinerecord5;
    }

    public void setQuoteLinerecord5(SBQQ__QuoteLine__c QuoteLinerec5)
    {
        QuoteLinerecord5 = QuoteLinerec5;
        
    }

    public class QuoteLinewrapper5
    {
        public SBQQ__QuoteLine__c QuoteLinerecord5{get; set;}
        public boolean selected{get; set;}
        public QuoteLinewrapper5(SBQQ__QuoteLine__c e)
        {
            QuoteLinerecord5 = e;
            selected = false;
        }
    }
//End Test Code
    
    public pagereference DisplayAllLines()
    {
        Id iQuoteId;
        PageReference oPage = Page.QuoteLinesRelatedList;
        
        try {
            iQuoteId = Apexpages.CurrentPage().getparameters().get('id');
            oPage = new PageReference('/apex/quotelinesrelatedlist?id='+iQuoteId);
            //oPage.getparameters().putall(apexpages.currentpage().getparameters());
            oPage.setRedirect(true); 
        }
        catch (System.CalloutException e) {
             System.debug('ERROR:' + e);
        }
        
        return oPage;
    }
    
    public pagereference DisplayQuote()
    {
        PageReference oPage;
        Id iQuoteId;
        
        try {
            iQuoteId = Apexpages.CurrentPage().getparameters().get('id');
            oPage = new PageReference('/'+iQuoteId);
            //oPage.getparameters().putall(apexpages.currentpage().getparameters());
            oPage.setRedirect(true); 
        }
        catch (System.CalloutException e) {
             System.debug('ERROR:' + e);
        }
        
        return oPage;
    }
}