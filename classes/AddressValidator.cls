/*
** Author: Shanu Aggarwal
** Added on: 03/13/2018
** Validate addresses on submitting quote for an approval 
**/
global with sharing class AddressValidator{
    
    /**
    ** Added on 03/13/2018 - Shanu Aggarwal
    ** SUBMIT FOR APPROVAL - Button on Quote
    ** This method performs check on Country,City,State,PostalCode agains the external database. 
    ** The JSON response returns the ProcessStatus based on the inputs and if status is not betwween V1 > V4, Address becoms invalid. 
    **/
    webservice static boolean validateAddress(Id quoteId) { 
        
        string status;
        
        //Sample URL 
        string endpoint ='https://rest-adcloud.informaticadaas.com/adcloud/verifyaddress?'
            +'Login=165520&Password=im22NUdN&MatchingScope=LOCALITY_LEVEL&FormatWithCountry=True&CountryOfOriginISO3CountryOfOriginISO3=US'
            +'&street=&Locality=ORLEANS&Province=LA&postalcode=70128-3503&Country=US&FORMATType=ALL&Format=json';
        endpoint ='https://rest-adcloud.informaticadaas.com/adcloud/verifyaddress?Login=165520&Password=im22NUdN&MatchingScope=LOCALITY_LEVEL&FormatWithCountry=True&CountryOfOriginISO3CountryOfOriginISO3=US&street=&Locality=New%20Orleans&Province=LA&postalcode=70128-3503&Country=US&FORMATType=ALL&Format=json';
        //custom setting to build the URL with parameters defined in the setting  
        AddressValidator__c  validator = AddressValidator__c.getAll().Values()[0];
        
        SBQQ__Quote__c quote = [Select SBQQ__Opportunity2__r.Ship_To_Address__r.CountryCode__c,SBQQ__Opportunity2__r.Ship_To_Address__r.City__c,SBQQ__Opportunity2__r.Ship_To_Address__r.State__c,SBQQ__Opportunity2__r.Ship_To_Address__r.Postal_Code__c From SBQQ__Quote__c Where Id=:quoteId ];
        
        if(quote.SBQQ__Opportunity2__r.Ship_To_Address__r.CountryCode__c!='US' && quote.SBQQ__Opportunity2__r.Ship_To_Address__r.CountryCode__c!='CA'){return true;}
        
        //If country and zip code is blank, address is invalid 
        if(quote.SBQQ__Opportunity2__r.Ship_To_Address__r.CountryCode__c==null || quote.SBQQ__Opportunity2__r.Ship_To_Address__r.Postal_Code__c==null){return false;}
        
        string city = quote.SBQQ__Opportunity2__r.Ship_To_Address__r.City__c;
        string postalCode = quote.SBQQ__Opportunity2__r.Ship_To_Address__r.Postal_Code__c;
                
        if(city!=null)
            city= city.replaceAll( '\\s+', '%20');
        if(postalCode!=null)
            postalCode= postalCode.replaceAll( '\\s+', '%20');
        
        //build URL    
        endpoint = validator.Rest_URL__c + 'Login='+ validator.Login_Id__c + '&Password='+ validator.Password__c + '&MatchingScope=' + validator.MatchingScope__c 
            +  '&FormatWithCountry=True&CountryOfOriginISO3CountryOfOriginISO3='+quote.SBQQ__Opportunity2__r.Ship_To_Address__r.CountryCode__c+
            +  '&street=&Locality='+ city +'&Province='+ quote.SBQQ__Opportunity2__r.Ship_To_Address__r.State__c + '&postalcode=' + postalCode +'&Country='+quote.SBQQ__Opportunity2__r.Ship_To_Address__r.CountryCode__c+'&FORMATType='+ validator.FormatType__c+'&Format=json';  
        
        System.debug('***endpoint***'+ endpoint);
        //make callout         
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        
        HttpResponse res;
        JSONParser parser;
        
        if(!test.isRunningTest()){
            res = h.send(req); parser = JSON.createParser(res.getBody());
        }else{
            parser = JSON.createParser('{"ResultPercentage":"78.00"}');
        }
        
        while (parser.nextToken() != null) {
            System.debug('***parser.getCurrentToken()***'+ parser.getCurrentToken());
            System.debug('***JSONToken.FIELD_NAME***'+ JSONToken.FIELD_NAME);
            System.debug('***parser.getText()***'+ parser.getText());
            
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                (parser.getText() == 'ProcessStatus')) {
                    // Get the value.
                    parser.nextToken();
                    status = parser.getText();
                }
        }
                
        
        
        //If process status is either of these
        if(status=='V1' || status=='V2' || status=='V3' || status=='V4' ){
            return true;
        }else{
            return false;
        }
        
    }
    /**
    ** Added on 04/05/2018 - Shanu Aggarwal
    ** ADDRESS LEVEL
    ** This method performs check on Country,City,State,PostalCode against the external database. 
    ** Updates the flag on Is EBS Sync ? AND Address Validation field on Address level
    **/
    @future(callout=true)
    public static void validateShippingAddressBulk(Set<ID> addIds){ 
        
        string userId = UserInfo.getUserId().substring(0,15);
        string profileId = UserInfo.getProfileId().substring(0,15);
        
        //Only 100 Addresses are allowed in one transaction for call outs
        //Validation works only for these two users 
        if(addIds.size()<101 && (AddressValidationUsers__c.getValues(userId)!=null || AddressValidationUsers__c.getValues(profileId)!=null)){
            
            Map<Id,Address__c> updateAddMap = new Map<Id,Address__c>();
            string status;
            string endpoint;
            //custom setting to build the URL with parameters defined in the setting  
            AddressValidator__c  validator = AddressValidator__c.getAll().Values()[0];


            for( Address__c adr : [Select Id,Type__c,EBS_Account_Id__c,CountryCode__c,City__c,State__c,Postal_Code__c  From Address__c Where Type__c = 'Shipping' and ID IN:addIds]){
                
                
                //IF country is rather than US and CANADA , the address become valid
                if(adr.CountryCode__c!='US' && adr.CountryCode__c!='CA'){
                    adr.Address_Validation__c = 'VALID';
                    adr.Is_EBS_Synced__c=true;
                    updateAddMap.put(adr.Id, adr);
                    continue;
                }

                //If country and zip code is blank, address is invalid 
                if(adr.CountryCode__c==null || adr.Postal_Code__c==null){
                    adr.Address_Validation__c = 'INVALID';
                    adr.Is_EBS_Synced__c=false;
                    updateAddMap.put(adr.Id, adr);
                    continue;
                }
                                
                string city = adr.City__c;
                string postalCode = adr.Postal_Code__c;
                
                if(city!=null)
                    city= city.replaceAll( '\\s+', '%20');
                if(postalCode!=null)
                    postalCode= postalCode.replaceAll( '\\s+', '%20');
                
                //build URL    
                endpoint = validator.Rest_URL__c + 'Login='+ validator.Login_Id__c + '&Password='+ validator.Password__c + '&MatchingScope=' + validator.MatchingScope__c 
                    +  '&FormatWithCountry=True&CountryOfOriginISO3CountryOfOriginISO3='+adr.CountryCode__c+
                    +  '&street=&Locality='+ city +'&Province='+ adr.State__c + '&postalcode=' + postalCode +'&Country='+adr.CountryCode__c+'&FORMATType='+ validator.FormatType__c+'&Format=json';  
                
                System.debug('***endpoint***'+ endpoint);
                //make callout         
                Http h = new Http();
                HttpRequest req = new HttpRequest();
                req.setEndpoint(endpoint);
                req.setMethod('GET');
                
                HttpResponse res;
                JSONParser parser;
                
                if(!test.isRunningTest()){
                    res = h.send(req); parser = JSON.createParser(res.getBody());
                }else{
                    parser = JSON.createParser('{"ResultPercentage":"78.00"}');
                }
                
                while (parser.nextToken() != null) {
                    System.debug('***parser.getCurrentToken()***'+ parser.getCurrentToken());
                    System.debug('***JSONToken.FIELD_NAME***'+ JSONToken.FIELD_NAME);
                    System.debug('***parser.getText()***'+ parser.getText());
                    
                    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                        (parser.getText() == 'ProcessStatus')) {
                            // Get the value.
                            parser.nextToken();
                            status = parser.getText();
                        }
                }
                        
                
                //If process status is either of these
                if(status=='V1' || status=='V2' || status=='V3' || status=='V4' ){
                    adr.Address_Validation__c = 'VALID';
                    adr.Is_EBS_Synced__c=true;
                }else{
                    adr.Address_Validation__c = 'INVALID';
                    adr.Is_EBS_Synced__c=false;
                }

                updateAddMap.put(adr.Id, adr);
            }
            
            //Update Addresses 
            if(!updateAddMap.isEmpty())
                update updateAddMap.values();

        }
   
        
    }


    /**
    ** Added on -03/19/2018
    ** Validate country codes against the codes stored in custom setting 
    **
    **/
    public static void validateCountryCode(List<Address__c> newList, Map<Id,Address__c> oldMap){
        /*
        Map<String,CountryCode__c> codes = CountryCode__c.getAll();
        
        for(Address__c adr : newList){
        
            if(adr.Country__c!=null && (oldMap==null || (oldMap!=null && adr.Country__c!=oldMap.get(adr.id).Country__c))){
                if(!codes.containsKey(adr.Country__c)){//&& UserInfo.getUserId()!='005o0000002QzQsAAK'
                    adr.addError('Country Code is Invalid');
                }
                //sync country code
                adr.CountryCode__c = adr.Country__c;
            }
        }*/
    }
    
}