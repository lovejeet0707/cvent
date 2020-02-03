public class cloneRelated{

     public  SBQQ__Quote__c objQuote {get;set;}
     public  List<SBQQ__Quote__c> newQuote {get;set;}
     public  String strQuery {get; set;}
     public static Boolean pass {get;set;}
     
     public cloneRelated(ApexPages.StandardController stdController) {
         objQuote = (SBQQ__Quote__c)stdController.getRecord();
         
     }
     
     
     
     public PageReference cloneQuote() {
         strQuery = getQuery(' Id = \''+ objQuote.Id +
                                                '\' limit 1');
         newQuote= Database.query(strQuery);
         System.debug('CJ---  :1');
         pass = true;
         Map<Id,SBQQ__QuoteLine__c> qLines = new Map<Id,SBQQ__QuoteLine__c>();
         SBQQ__Quote__c transformedQuote = transformQuote();
         if(transformedQuote.Multiple_Years_Commitment__c){
            System.debug('CJ---  :2');
            Map<Id,SBQQ__QuoteLineGroup__c> qlGroups = cloneQuotelinegroup(transformedQuote.Id, newQuote[0]);
            System.debug('CJ---  :3');
            qLines = cloneQuotelines( transformedQuote.Id, newQuote[0], qlGroups);
            updateQuotelines(qLines);
         }
         else{
            qLines = cloneQuoteLines(transformedQuote);
            updateQuotelines(qLines);
         }
         // if deepclone didn't works
         
         System.debug('----->' + newQuote);
         return new PageReference('//'+transformedQuote.Id);
     }
     public Map<Id,SBQQ__QuoteLine__c> cloneQuoteLines(SBQQ__Quote__c transformedQuote){
        String strInnerQueryline = getQueryWithCreatableFields('SBQQ__QuoteLine__c')+' FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = \''+objQuote.Id+'\' '; 
        List<SBQQ__QuoteLine__c> newQLs = Database.query(strInnerQueryline);
        List<SBQQ__QuoteLine__c> listQli = new List<SBQQ__QuoteLine__c>();
         Map<Id,SBQQ__QuoteLine__c> mapQli = new Map<Id,SBQQ__QuoteLine__c>();
       for (SBQQ__QuoteLine__c qli : newQLs) {
           SBQQ__QuoteLine__c convertedQuoteLine =  qli.clone(false,true,false,false); 
            
           convertedQuoteLine.SBQQ__Quote__c = transformedQuote.id;
           mapQli.put(qli.Id,convertedQuoteLine);
           listQli.add(convertedQuoteLine);
       }
          if (SBQQ.TriggerControl.isEnabled()) {
                SBQQ.TriggerControl.disable();
         }  
           insert listQli;
         return mapQli;
     }
      
     public SBQQ__Quote__c transformQuote(){
         
        SBQQ__Quote__c convertedQuote =  newQuote[0].clone(false,true,false,false); 
        convertedQuote.SBQQ__Primary__c =false;
        convertedQuote.Cloned_from_Quote__c = objQuote.Id;
        if (SBQQ.TriggerControl.isEnabled()) {
                SBQQ.TriggerControl.disable();
            }
            
        insert convertedQuote;
        
        return convertedQuote;
     
     }
     
     public Map<Id,SBQQ__QuoteLineGroup__c> cloneQuotelinegroup(String Id, SBQQ__Quote__c convertQuote){
         List<SBQQ__QuoteLineGroup__c> listQlG = new List<SBQQ__QuoteLineGroup__c>();
         Map<Id,SBQQ__QuoteLineGroup__c> mapQLG = new Map<Id,SBQQ__QuoteLineGroup__c>();
         
         for (SBQQ__QuoteLineGroup__c qlGroup : convertQuote.SBQQ__LineItemGroups__r) {
             SBQQ__QuoteLineGroup__c transformedQLG = new SBQQ__QuoteLineGroup__c(); 
             transformedQLG.SBQQ__Quote__c = Id;
             //Map<String, Schema.SObjectField> strFieldName_objToken = Schema.getGlobalDescribe().get(strObjectName.toLowerCase()).getDescribe().Fields.getMap();
             transformedQLG.jsonString__c = qlGroup.jsonString__c;
             transformedQLG.groupType__c = 'Variable MYD Group';
             transformedQLG.SBQQ__StartDate__c = qlGroup.SBQQ__StartDate__c;
             transformedQLG.SBQQ__EndDate__c = qlGroup.SBQQ__EndDate__c;
             transformedQLG.term__c = qlGroup.term__c; 
             transformedQLG.SBQQ__Optional__c = qlGroup.SBQQ__Optional__c;
             transformedQLG.termLength__c = qlGroup.termLength__c;
             transformedQLG.SBQQ__Number__c= qlGroup.SBQQ__Number__c;
             transformedQLG.SBQQ__CustomerTotal__c= qlGroup.SBQQ__CustomerTotal__c;
             transformedQLG.SBQQ__ListTotal__c= qlGroup.SBQQ__ListTotal__c;
             transformedQLG.SBQQ__NetTotal__c= qlGroup.SBQQ__NetTotal__c;
             transformedQLG.Name=qlGroup.Name;
             listQlG.add(transformedQLG);
             mapQLG.put(qlGroup.Id,transformedQLG);
                 
         }
         if (SBQQ.TriggerControl.isEnabled()) {
                SBQQ.TriggerControl.disable();
         }   
         insert listQlG;   
         
         return mapQLG;      
      
     }
     
     public Map<Id,SBQQ__QuoteLine__c> cloneQuotelines( String quoteId, SBQQ__Quote__c quote,  Map<Id,SBQQ__QuoteLineGroup__c> qlGroup) {
        String strInnerQueryline = getQueryWithCreatableFields('SBQQ__QuoteLine__c')+' FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = \''+quote.Id+'\' '; 
        List<SBQQ__QuoteLine__c> newQLs = Database.query(strInnerQueryline);
       List<SBQQ__QuoteLine__c> listQli = new List<SBQQ__QuoteLine__c>();
       Map<Id,SBQQ__QuoteLine__c> mapQli = new Map<Id,SBQQ__QuoteLine__c>();
       for (SBQQ__QuoteLine__c qli : newQLs) {
           SBQQ__QuoteLine__c convertedQuoteLine =  qli.clone(false,true,false,false); 
           if(qlGroup != null && qli.SBQQ__Group__c!=null){ 
              System.debug(qlGroup);
                convertedQuoteLine.SBQQ__Group__c = qlGroup.get(qli.SBQQ__Group__c).Id;
           } 
           convertedQuoteLine.SBQQ__Quote__c = quoteId;
           convertedQuoteLine.Cloned_from_Quote_Line__c=qli.Id;  
           listQli.add(convertedQuoteLine);
           mapQli.put(qli.Id,convertedQuoteLine);
       }
          if (SBQQ.TriggerControl.isEnabled()) {
                SBQQ.TriggerControl.disable();
         }  
           insert listQli;
           return mapQli;
         
     }
     
     
     public void updateQuotelines(Map<Id,SBQQ__QuoteLine__c> mapQLI ) {
         List<SBQQ__QuoteLine__c> qlis= new List<SBQQ__QuoteLine__c>();
         for (SBQQ__QuoteLine__c qli : mapQLI.values()){
             SBQQ__QuoteLine__c qlitobe = new SBQQ__QuoteLine__c();
             qlitobe.id = qli.id;
             if (qli.SBQQ__RequiredBy__c !=null){
             qlitobe.SBQQ__RequiredBy__c = mapQLI.get(qli.SBQQ__RequiredBy__c).Id; 
             } 
             qlis.add(qlitobe);
         } 
         if (SBQQ.TriggerControl.isEnabled()) {
                SBQQ.TriggerControl.disable();
         } 
          update qlis;
     
     }
     
     
     
     /* utilities */
     public string getQuery(String strWhereClause) {

        if (String.isBlank(strWhereClause)) {
            return null;
        }
 
        String strInnerQueryline = getQueryWithCreatableFields('SBQQ__QuoteLine__c');
        String strInnerQueryGroups = getQueryWithCreatableFields('SBQQ__QuoteLineGroup__c'); 
        
        String strFinalQuery = getQueryWithCreatableFields('SBQQ__Quote__c') +',  ('+ strInnerQueryline + ' FROM SBQQ__LineItems__r) , (' + strInnerQueryGroups + ' FROM SBQQ__LineItemGroups__r)' +  
                               + ' FROM SBQQ__Quote__c WHERE ' + strWhereClause ;
                        
        return strFinalQuery ;             
     
     }     
     
     public string getQueryWithCreatableFields(String strObjectName) {

        String strSelectedFields = 'Select Id, ';
        
        if (String.isBlank(strObjectName)) {
            return null;
        }

        Map<String, Schema.SObjectField> strFieldName_objToken = Schema.getGlobalDescribe().get(strObjectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> lstSelectFields = new list<string>();

        if (strFieldName_objToken != null) {
            for (Schema.SObjectField fieldToken : strFieldName_objToken.values()) {
                Schema.DescribeFieldResult field = fieldToken.getDescribe();
                if (field.isCreateable()) {
                    lstSelectFields.add(field.getName());
                }
            }
        }

        if (!lstSelectFields.isEmpty()) {
            for (string selectField: lstSelectFields) {
                strSelectedFields += selectField + ',';
            }
            if (strSelectedFields.endsWith(',')) {
                strSelectedFields = strSelectedFields.substring(0,strSelectedFields.lastIndexOf(','));
            }

        }

        return strSelectedFields;
    }
            
              
}