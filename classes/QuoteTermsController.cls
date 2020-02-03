/****Udita : Enhancements done to fetch merge field values from the Quote term body : 1/18/2019 : P-004923 ****/
public class QuoteTermsController {
    
    public Id objId {get; set;}
    public String myListString;
    public set<string> setOfField = new set<string>();
    public map<string,string> mapOfFieldValues = new map<string,string>();
    
    public List<DisplayWrapper> getQuoteTermList() {
        List<SBQQ__QuoteTerm__c> quoteTerms = [SELECT Id, SBQQ__Body__c FROM SBQQ__QuoteTerm__c WHERE SBQQ__Active__c = True and SBQQ__Quote__c = :objId];
        string quoteTermbody;
        List<string> strListOfFields = new list<string>();
        List<DisplayWrapper> qlWrappers = new List<DisplayWrapper>();
        map<string,string> mapOfFieldValues = new map<string,string>();
        Map<String, Schema.SObjectField> fieldMap = SBQQ__Quote__c.sObjectType.getDescribe().fields.getMap();
        SObjectType r = ((SObject)(Type.forName('Schema.'+'SBQQ__Quote__c').newInstance())).getSObjectType();
        DescribeSObjectResult d = r.getDescribe();
        if(quoteTerms.size() > 0){
        for(SBQQ__QuoteTerm__c quoteTerm: quoteTerms){
          if(quoteTerm.SBQQ__Body__c != null){
            quoteTermbody = quoteTerm.SBQQ__Body__c;
            system.debug('----quoteTermbody '+ quoteTermbody );
            List<String> lstName = quoteTermbody.split(' ');    
            list<string> fieldsStr = new list<string>(); 
               string field;
                for(string s : lstName){
                  if(s.contains('{')){            
                    field = s.substringBetween('{!quote.','}');
                    if(!fieldsStr.contains(field.tolowercase()))
                        fieldsStr.add(field.tolowercase());
                  }
                }    
            strListOfFields.addAll(fieldsStr);
            setOfField.addAll(strListOfFields);
            myListString = string.join(strListOfFields,',');
            }
        }
        if(strListOfFields.size() > 0){
        string query;
        query = 'select ' +  myListString + ' from SBQQ__Quote__c where id = ' + ' \'' + objId + '\'';
        SBQQ__Quote__c[] quotes= Database.query(query);
        system.debug('---quotes'+ quotes);
        for(SBQQ__Quote__c q : quotes){
            for ( String fieldName : fieldMap.keySet() ){
                system.Debug('--fieldName'+fieldName);
                if(setOfField.contains(fieldName)){
                   string sdataType= string.valueOf(d.fields.getMap().get(fieldName).getDescribe().getType()); // Getting datatype of the field
                  if(sdataType == 'DATE' || sdataType == 'DATETIME'){
                      date dt = (Date)(q.get(fieldName)); // Typecast object to date 
                      system.debug('dt*****'+ dt);
                      string dates = dt.format();
                      mapOfFieldValues.put(fieldName,dates); 
                   }else{
                      mapOfFieldValues.put(fieldName,string.valueOf( q.get(fieldName)));   // Populating map of field api vs field value 
                   }
                }
            }
        }
        }
        system.Debug('--mapOfFieldValues'+mapOfFieldValues);
        string body ='';
        
        for(SBQQ__QuoteTerm__c quoteTerm: quoteTerms){
         body = '';
         if(quoteTerm.SBQQ__Body__c!= null){
         List<String> lstBody = quoteTerm.SBQQ__Body__c.split(' '); 
         //quoteTermbody = quoteTerm.SBQQ__Body__c;
         for(string s : lstBody){           
           if(s.contains('{')){
             string fieldAPI = s.substringBetween('{!quote.','}').tolowercase();
              if(mapOfFieldValues.containsKey(fieldAPI)){
                s = mapOfFieldValues.get(fieldAPI);
              }
           }
           body = body +' '+ s + '';
        } 
            DisplayWrapper dWrapper = new DisplayWrapper();            
            dWrapper.body = body;
            qlWrappers.add(dWrapper);
        }  
       } 
      } 
        if (qlWrappers.isEmpty())
            return null;
        return qlWrappers;
    }
    
    public class DisplayWrapper {
        public String body {get; set;}        
    }
    // Method to fetch all the merge fields in the body : Udita
    public List<string> fetchMergeFields(string quoteTermbody){ 
     List<String> lstName = quoteTermbody.split(' ');    
       list<string> fieldsStr = new list<string>(); 
       string field;
        for(string s : lstName){
          if(s.contains('{')){            
            field = s.substringBetween('{!quote.','}');
            if(!fieldsStr.contains(field.tolowercase()))
                fieldsStr.add(field.tolowercase());
          }
        }   
        return fieldsStr;
    }
}