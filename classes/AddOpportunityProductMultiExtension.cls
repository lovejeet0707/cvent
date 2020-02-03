public without sharing class AddOpportunityProductMultiExtension {

    public Opportunity opty {get; set;}
    Set<String> proRecTypeSet;
    String masterRecType;
    public AddOpportunityProductMultiExtension (ApexPages.StandardController controller) {
        selectedName='';
        proRecTypeSet = new Set<String>();
         opty = (Opportunity) controller.getRecord();
         isEditMode = false;
         productWrapperList= new List<ProductWrapper>();
         selectedProducts = new List<ProductWrapper>();
         
        Schema.DescribeSObjectResult recTypeInfo = Product2.SObjectType.getDescribe();
        For(Schema.RecordTypeInfo proRecInfo : recTypeInfo.getRecordTypeInfos())
        {
            if(proRecInfo.isAvailable())
            {
                if(!proRecInfo.isMaster() && !proRecInfo.isDefaultRecordTypeMapping())
                    proRecTypeSet.add(proRecInfo.Name);
                else if(proRecInfo.isDefaultRecordTypeMapping())
                    masterRecType=proRecInfo.Name;
            }
        }
        loadForAddProdsAction();
        searchProdAction();
    }
    
    public List<SelectOption> productFamilyOptions {get; set;}
    
    public String selectedFamily {get; set;}
    public String selectedName {get; set;}
    public Boolean isEditMode {get; set;}
    
    public String selectedProductId {get; set;}
    public Decimal selectedUnitPrice{get; set;}
    public List<ProductWrapper> productWrapperList {get; set;}

    public PageReference cancelAction() {
        return null;
    }

    public Map<String, List<ProductWrapper>> productMap {get; set;}
 
    public List<ProductWrapper> selectedProducts{get; set;}
    Id priceBookId;
    public PageReference loadForEditProdsAction(){
        isEditMode = true;
        opty = [select Id, name from Opportunity where id =: opty.id];
        
        DescribeSObjectResult describeResult = OpportunityLineItem.sObjectType.getDescribe();
        List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
        
        String query =
          ' SELECT Product2.Name, ' +
              String.join( fieldNames, ',' ) + 
          ' FROM ' +
              describeResult.getName() +
          ' WHERE ' +
              ' OpportunityId = \'' + opty.id + '\'';
        
        System.debug('query : '+query );
        List<OpportunityLineItem> opportunityLineItems = (List<OpportunityLineItem> )Database.query( query );
        System.debug('opportunityLineItems : '+opportunityLineItems );
        
        for(OpportunityLineItem prod: opportunityLineItems){
            selectedProducts.add(new ProductWrapper(prod));
        }
            
        productMap = new Map<String, List<ProductWrapper>>();
        for(ProductWrapper pw: selectedProducts){
            List<ProductWrapper> prodList = productMap.get(pw.product.Product_Family__c);
            if(prodList == null)
                prodList = new List<ProductWrapper>();
            prodList.add(pw);
            productMap.put(pw.product.Product_Family__c, prodList);
        }
        
         return Page.QuickAddEditProductsGrid;
    }

    public PageReference loadForAddProdsAction(){
        System.debug('opty.CurrencyIsoCode*******'+opty.CurrencyIsoCode);
         isEditMode = false;
         priceBookId = [SELECT Id,CurrencyIsoCode  FROM Pricebook2 WHERE CurrencyIsoCode = : opty.CurrencyIsoCode AND IsStandard = False].Id;
         System.debug('priceBookId**********'+priceBookId);
         Set<String> productFamiliesSet= new Set<String>();                 
         for(AggregateResult aggr: [select Product2.Family family from Pricebookentry where Pricebook2Id = : priceBookId and isActive = true group by Product2.Family order by Product2.Family]){
            if(!productFamiliesSet.contains(String.valueOf(aggr.get('family')))){
                productFamiliesSet.add(String.valueOf(aggr.get('family')));
            }
         }
        
         productFamilyOptions = new List<SelectOption>();
         System.debug('masterRecType****'+masterRecType);
         if(String.isNotBlank(masterRecType))
            productFamilyOptions.add(new SelectOption(masterRecType,masterRecType));
         for(String pFamily: productFamiliesSet){ 
            if(proRecTypeSet.size()>0 && proRecTypeSet.contains(pFamily))
             productFamilyOptions.add(new SelectOption(pFamily, pFamily));
         }
         if(selectedFamily=='' || selectedFamily==null)
         {
            selectedFamily = masterRecType;
         }
        return null;
    }
      
            
      
     public PageReference selectAction() {
        for(ProductWrapper pw: productWrapperList){
            if(pw.isSelected){
                selectedProducts.add(pw);
            }
        }
            
        productMap = new Map<String, List<ProductWrapper>>();

        for(ProductWrapper pw: selectedProducts){
            pw.initializeOpportunityProduct(opty.Id);
            List<ProductWrapper> prodList = productMap.get(pw.pbe.Product2.Family);
            if(prodList == null)
                prodList = new List<ProductWrapper>();
                
            prodList.add(pw);
            productMap.put(pw.pbe.Product2.Family, prodList);
        }
        
         return Page.QuickAddEditProductsGrid;
    }
    
    public PageReference saveAction() {
        List<OpportunityLineItem> oppProds = new List<OpportunityLineItem>();
        for(List<ProductWrapper> prods: productMap.values()){
            for(ProductWrapper p: prods){
                oppProds.add(p.product);
            }
        }
        if(oppProds.size() > 0){
            try{
                upsert oppProds;
                PageReference opportunityPage = new ApexPages.StandardController(opty).view();
                opportunityPage.setRedirect(true);
                return opportunityPage;
            }
            catch(Exception e)
            {
                String errorMessage = '';
                if(e.getMessage().indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION,')>=0){
                    errorMessage = e.getMessage().substringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION,');
                    errorMessage = errorMessage.substringBeforeLast(': []');
                    System.debug('errorMessage*******'+errorMessage);
                } else {
                    errorMessage = e.getMessage();
                }
                System.debug('errorMessage***********'+errorMessage);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                                              errorMessage,''));
              return null;
           }
        }
        return null;
    }

    
    public PageReference searchProdAction()
    {
        //Capture any existing selected products before search
        for(ProductWrapper pw: productWrapperList){
            if(pw.isSelected){
                selectedProducts.add(pw);
            }
        }

        //Reinitialize search results
        productWrapperList.clear();
        System.debug('opty.CurrencyIsoCode*******'+opty.CurrencyIsoCode);
        System.debug('opty.priceBookId*******'+priceBookId);
        System.debug('Product2.Family******'+Product2.Family+'********'+selectedFamily);
        String selectedName0 ='%'+ selectedName + '%';
        List<PriceBookEntry> productList = [select Id, Name, Product2Id, Product2.Family,Product2.Name, Pricebook2Id, ProductCode, UnitPrice from PriceBookEntry where Pricebook2Id = :priceBookId and IsActive = true and Product2.Family =: selectedFamily and Name like: selectedName0 ORDER BY Name ASC limit 900];
        for(PriceBookEntry pbe: productList){
            productWrapperList.add(new ProductWrapper(pbe)); 
        }
        return null;
    }

    public PageReference selectProdAction(){
        OpportunityLineItem oli = new OpportunityLineItem (
        opportunityid = opty.id,
        unitprice = selectedUnitPrice,  
        per_item_fee__c = selectedUnitPrice,
        of_items__c = 1,
        quantity = 1,
        pricebookentryid = selectedProductId);
        
        insert oli;
        return new ApexPages.StandardController(oli).edit();
    }

      
          
    class ProductWrapper {
        public boolean isSelected;
        public PriceBookEntry pbe {get; set;}
        public OpportunityLineItem product {get; set;}
        
        public ProductWrapper(PriceBookEntry pbe0){
            pbe = pbe0;       
        }
        
        public ProductWrapper(OpportunityLineItem product0){
            product  = product0;       
        }
        
        public void setIsSelected (boolean val){
            isSelected = val;
        }
        
        public boolean getIsSelected (){
            return isSelected;
        }
        
        public OpportunityLineItem initializeOpportunityProduct(Id oppId) {
            product = new OpportunityLineItem(); 
            product.OpportunityId = oppId;
            product.unitprice = pbe.UnitPrice;  
            product.per_item_fee__c = pbe.UnitPrice;
            product.of_Comp_Items_Hrs__c = 0;
            
            product.of_items__c = 1;
            product.quantity = 1;
            product.pricebookentryid = pbe.Id;     
            return product;      
        }
    }
    
}