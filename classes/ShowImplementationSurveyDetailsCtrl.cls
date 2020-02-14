public class ShowImplementationSurveyDetailsCtrl 
{
    public boolean editSection {get;set;}
    public Boolean editSectionExtraCondition {get;set;}
    public Boolean errorFree {get;set;}
    public Boolean showTaxValidation{get;set;}
    private ApexPages.StandardController stdController;
    public Implementation_Survey__c implementationSurvey{ get; set; }
    public Id oppId{get;set;}
    public Id userRoleId{get;set;}
    public String userRoleName {get;set;}
    public List<String> HCSpecialRoles {get;set;}
    public String redirectUrl {public get; private set;}
    public String helpUrl {public get; public set;}
    public String recordTypeDeveloperName{get;set;}
    public Boolean eventCloud{get;set;}
    public Boolean hospitalityCloud{get;set;}
    public List<Schema.FieldSetMember> selectedFields{get;set;}
    public List<Schema.FieldSetMember> additionalFields{get;set;}
    public List<Schema.FieldSetMember> extraAdditionalFields{get;set;}
    public List<Schema.FieldSetMember> extraAdditionalFieldsEC{get;set;}
    public Opportunity opp{get;set;}
    public Opportunity opp2{get;set;}
    public ApexPages.StandardController controller;
    public Boolean listOutUserLoginsToBeDeactivated;
    public String LabelForHCCloud{get;set;}
    public Boolean renderExtraAddSection{get;set;}
    public Boolean renderAddSection{get;set;}
    public Boolean amendedContract{get;set;}
    public Boolean hideRenewalFields{get;set;}
    public Boolean hideUpsellFields{get;set;}
    public Boolean hidecrosssellFields{get;set;}
    public Boolean shouldRedirect {public get; private set;}
    public Map<String,Opportunity_Record_Types__c> oppRecordTypes;
    public Map<String,Opportunity_Products__c> oppProducts;
    public static Attachment oAttachment;
    public static Attachment oAttachment2;
    public Attachment getAttachment() {
        if( oAttachment == null){
            oAttachment = new Attachment();
        }   
        return oAttachment;
    }
    public void setAttachment(Attachment att) {
        oAttachment = att; 
    }
    public Attachment getAttachment2() {
        if( oAttachment2 == null){
            oAttachment2 = new Attachment();
        }   
        return oAttachment2;
    }
    public void setAttachment2(Attachment att) {
        oAttachment2 = att; 
    }
    public ShowImplementationSurveyDetailsCtrl(ApexPages.StandardController controller) 
    {
        userRoleId = Id.valueOf(UserInfo.getUserRoleId());
        helpUrl = Label.HelpURL;
        HCSpecialRoles = Label.HCImpSurveyRoles.split(',');
        oppRecordTypes = Opportunity_Record_Types__c.getAll();
        oppProducts = Opportunity_Products__c.getAll();
        LabelForHCCloud = 'Brand Pages & Microsites (If Applicable)';
        listOutUserLoginsToBeDeactivated = false;
        shouldRedirect = false;
        errorFree = false;
        showTaxValidation = false;
        this.controller = controller;
        eventCloud = false;
        hospitalityCloud = false;
        renderExtraAddSection = false;
        renderAddSection = false;
        hideRenewalFields = false;
        hideUpsellFields = false;
        hidecrosssellFields = false;
        selectedFields = new List<Schema.FieldSetMember>();
        additionalFields = new List<Schema.FieldSetMember>();
        extraAdditionalFields = new List<Schema.FieldSetMember>();
        extraAdditionalFieldsEC = SObjectType.Implementation_Survey__c.FieldSets.ImplementationSurveyExtraAddFieldsEC.getFields();
        oppId = ApexPages.currentPage().getParameters().get('id');
        opp = [SELECT Opportunity_Type__c,RecordType.DeveloperName,Opp_Owner_Role__c,Owner.UserRoleId,AccountId,SBQQ__PrimaryQuote__c,SBQQ__PrimaryQuote__r.SBQQ__Type__c,StageName,Product__c,SBQQ__AmendedContract__c,Net_Amount_opp_USD__c,SBQQ__RenewedContract__c FROM Opportunity where id =:oppId LIMIT 1];
        opp2 = (Opportunity)controller.getRecord();
        recordTypeDeveloperName = opp.RecordType.DeveloperName;
        Map<String,TaxValidationUsersOnIMPSurvey__c> taxValidationUsers = TaxValidationUsersOnIMPSurvey__c.getall();
        for(String userId : taxValidationUsers.keySet())
        {
            System.debug('UserId>>>'+userId);
            System.debug('UserInfo.getUserId()>>>'+UserInfo.getUserId());
            System.debug('userId.contains(UserInfo.getUserId())>>>'+userId.contains(UserInfo.getUserId()));
            if(UserInfo.getUserId().contains(userId))
            {
                showTaxValidation = true;
            }
        }
        System.debug('showTaxValidation>>>'+showTaxValidation);
        if(String.isNotBlank(opp.Owner.UserRoleId))
        {
            for(UserRole userRole : [select Name from UserRole where Id =:opp.Owner.UserRoleId LIMIT 1])
            {
                userRoleName = userRole.Name;
                break;
            }
        }
        if(opp.Opportunity_Type__c == 'Renewal' && opp.SBQQ__PrimaryQuote__r.SBQQ__Type__c == 'Renewal')
        {
            hideRenewalFields = true;
        }
        else if(opp.Opportunity_Type__c == 'NBB' && opp.SBQQ__PrimaryQuote__r.SBQQ__Type__c == 'Amendment')
        {
            hideUpsellFields = true;
        }
        
        if(opp.SBQQ__RenewedContract__c != NULL)
        {
            hideRenewalFields = true;
        }
        if(opp.SBQQ__AmendedContract__c != NULL)
            amendedContract = true;
        else
            amendedContract = false;
        if(oppRecordTypes.containsKey(recordTypeDeveloperName))
        {
            if(oppRecordTypes.get(recordTypeDeveloperName).Type__c == 'EC')
            {
                eventCloud = true;
            }
            else if(oppRecordTypes.get(recordTypeDeveloperName).Type__c == 'HC')
            {
                hospitalityCloud = true;
            }
            else if(oppRecordTypes.get(recordTypeDeveloperName).Type__c == 'Both')
            {
                if(userRoleName.contains('CSN') || userRoleName.contains('SI') || HCSpecialRoles.contains(userRoleName))
                {
                    hospitalityCloud = true;
                }
                else
                {
                    eventCloud = true;
                }
            }
        }
        editSectionExtraCondition = true;
        if(opp.StageName == 'Closed Won' || opp.StageName == 'Closed Won – Do Not Send to EBS')
        {
            editSectionExtraCondition = false;
        }
        this.implementationSurvey = getImplementationSurvey();
        //createSelectedFieldsList();
        //System.debug('oppId>>>'+oppId);
        //System.debug('selectedFields>>'+selectedFields);
    }
    
    /*
    public void createSelectedFieldsList()
    {
        List<Schema.FieldSetMember> allFields = getFields();
        Boolean showProvideCventAccId = false;
        String query = '';
        for(Booking_Classification__c bc : [select id,Cross_Sell_Total__c,Renewal_Value_Total__c,UpSell_Total__c from Booking_Classification__c where Opportunity__c =:oppId LIMIT 1])
        {
            if(bc.Cross_Sell_Total__c > 0 || bc.Renewal_Value_Total__c > 0 || bc.UpSell_Total__c > 0)
                showProvideCventAccId = true;
        }
        for(Schema.FieldSetMember f : allFields) 
        {
            if(f.getFieldPath().equalsIgnoreCase('Provide_Cvent_Account_ID_If_Applicable__c '))
            {
                if(showProvideCventAccId)
                    query += f.getFieldPath() + ', ';
            }
            else
            {
                query += f.getFieldPath() + ', ';
            }
        }
        System.debug(query+'><<query');
    }
*/
    public void EdittheSection()
    {
        editSection = true;
        //return null;
    }
    
    public List<Schema.FieldSetMember> getFields() 
    {
        List<Schema.FieldSetMember> fieldSetMem;
        if(oppRecordTypes.containsKey(recordTypeDeveloperName))
        {
            if(oppRecordTypes.get(recordTypeDeveloperName).Type__c == 'EC')
            {
                fieldSetMem = SObjectType.Implementation_Survey__c.FieldSets.ImplementationSurveyFields.getFields();
            }
            else if(oppRecordTypes.get(recordTypeDeveloperName).Type__c == 'HC')
            {
                fieldSetMem = SObjectType.Implementation_Survey__c.FieldSets.ImplementationSurveyFieldsForHC.getFields();
            }
            else if(oppRecordTypes.get(recordTypeDeveloperName).Type__c == 'Both')
            {
                if(userRoleName.contains('CSN') || userRoleName.contains('SI') || HCSpecialRoles.contains(userRoleName))
                {
                    fieldSetMem = SObjectType.Implementation_Survey__c.FieldSets.ImplementationSurveyFieldsForHC.getFields();
                }
                else
                {
                    fieldSetMem = SObjectType.Implementation_Survey__c.FieldSets.ImplementationSurveyFields.getFields();
                }
            }
        }
        System.debug('Field set memeber>?>'+fieldSetMem);
        return fieldSetMem;
    }
    
    public List<Schema.FieldSetMember> getAdditionalFields() 
    {
        List<Schema.FieldSetMember> fieldSetMem;
        if(oppRecordTypes.containsKey(recordTypeDeveloperName))
        {
            if(oppRecordTypes.get(recordTypeDeveloperName).Type__c == 'EC')
            {
                fieldSetMem = SObjectType.Implementation_Survey__c.FieldSets.ImplementationSurveyAddFieldsEC.getFields();
            }
            else if(oppRecordTypes.get(recordTypeDeveloperName).Type__c == 'HC')
            {
                fieldSetMem = SObjectType.Implementation_Survey__c.FieldSets.ImplementationSurveyAddFieldsForHC.getFields();
            }
            else if(oppRecordTypes.get(recordTypeDeveloperName).Type__c == 'Both')
            {
                if(userRoleName.contains('CSN') || userRoleName.contains('SI') || HCSpecialRoles.contains(userRoleName))
                {
                   fieldSetMem = SObjectType.Implementation_Survey__c.FieldSets.ImplementationSurveyAddFieldsForHC.getFields(); 
                }
                else
                {
                    fieldSetMem = SObjectType.Implementation_Survey__c.FieldSets.ImplementationSurveyAddFieldsEC.getFields();
                }
            }
        }
        System.debug('Field set memeber>?>'+fieldSetMem);
        return fieldSetMem;
    }
    private Implementation_Survey__c getImplementationSurvey() 
    {
        String query = 'SELECT ';
        Boolean showProvideCventAccId = false;
        Boolean showFirstPresentationDate = false;
        Boolean showLanguageSpecs = false;
        Boolean atPCN = false;
        Boolean atPCN2 = false;
        Boolean showSurveyLimits = false;
        Boolean showSurveyLimits2 = false;
        
        for(Booking_Classification__c bc : [select id,Cross_Sell_Total__c,Renewal_Value_Total__c,UpSell_Total__c,Total_NBB_Total__c,New_Logo_Total__c from Booking_Classification__c where Opportunity__c =:oppId LIMIT 1])
        {
            System.debug('bct??'+bc.Id);
            if(bc.Cross_Sell_Total__c > 0 || bc.Renewal_Value_Total__c > 0 || bc.UpSell_Total__c > 0)
            {
                showProvideCventAccId = true;
                //showFirstPresentationDate = true; //MS: Commented on Lauren and Cristina request as this was originally requested.
            }
            if(bc.Renewal_Value_Total__c > 0)
            {
                listOutUserLoginsToBeDeactivated = true;
                //showLanguageSpecs = true;   - Hidden this field on the request of Cristina. Date - 16th April, 2019
                //hideRenewalFields = true;
            }
            if(bc.Total_NBB_Total__c > 0)
            {
                //showFirstPresentationDate = true;     //MS: Commented on Lauren and Cristina request as this was originally requested.
                showSurveyLimits = true;
                showLanguageSpecs = true;
            }
            if(bc.New_Logo_Total__c > 0)
            {
                showFirstPresentationDate = true;
                showLanguageSpecs = true;
            }
            if(bc.UpSell_Total__c > 0)
            {
                atPCN = true;
                showSurveyLimits = true;
                //hideUpsellFields = true;
            }
            if(bc.Cross_Sell_Total__c > 0)
            {
                atPCN = true;
                showFirstPresentationDate = true;
                showSurveyLimits = true;
                hidecrosssellFields = true;
            }
        }
        if(eventCloud)
        {
            renderAddSection = true;
            //Integer productFamilyFilter = [SELECT count() FROM OpportunityLineItem WHERE Product_Family__c = 'CrowdCompass' AND OpportunityId =:oppId];
            Boolean containsCrowdCompassProductFamily = false;
            for(SBQQ__QuoteLine__c ql : [SELECT SBQQ__ProductFamily__c,SBQQ__Quantity__c,SBQQ__EffectiveQuantity__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =:opp.SBQQ__PrimaryQuote__c AND (SBQQ__ProductFamily__c = 'CrowdCompass' OR SBQQ__ProductFamily__c = 'Onsite Solutions' OR SBQQ__ProductFamily__c = 'Survey')])
            {
                System.debug('product family:'+ql.SBQQ__ProductFamily__c);
                if(amendedContract)
                {
                    if((ql.SBQQ__Quantity__c > ql.SBQQ__EffectiveQuantity__c && ql.SBQQ__EffectiveQuantity__c > 0) || (ql.SBQQ__Quantity__c == ql.SBQQ__EffectiveQuantity__c))
                    {
                        if(ql.SBQQ__ProductFamily__c == 'CrowdCompass')
                        {
                            System.debug('inside of crowdcompasss');
                            renderAddSection = true;
                            containsCrowdCompassProductFamily = true;
                        }
                        if(ql.SBQQ__ProductFamily__c == 'Onsite Solutions')
                        {
                            renderAddSection = true;
                            atPCN2 = true;
                        }
                        if(ql.SBQQ__ProductFamily__c == 'Survey')
                        {
                            renderAddSection = true;
                            showSurveyLimits2 = true;
                        }
                    }
                }
                else
                {
                    if(ql.SBQQ__ProductFamily__c == 'CrowdCompass')
                    {
                        System.debug('inside of crowdcompasss');
                        renderAddSection = true;
                        containsCrowdCompassProductFamily = true;
                    }
                    if(ql.SBQQ__ProductFamily__c == 'Onsite Solutions')
                    {
                        renderAddSection = true;
                        atPCN2 = true;
                    }
                    if(ql.SBQQ__ProductFamily__c == 'Survey')
                    {
                        renderAddSection = true;
                        showSurveyLimits2 = true;
                    }
                }
            }
            System.debug('containsCrowdCompassProductFamily>>>'+containsCrowdCompassProductFamily);
            for(Schema.FieldSetMember f : this.getFields()) 
            {
                switch on f.getFieldPath() {
                    when 'Provide_Cvent_Account_ID_If_Applicable__c' {
                        if(showProvideCventAccId)
                        {
                            query += f.getFieldPath() + ', ';
                            selectedFields.add(f);
                        }
                    }
                    when 'Language_Specifications__c' {
                        if(!hideRenewalFields && !hideUpsellFields)  //showLanguageSpecs
                        {
                            query += f.getFieldPath() + ', ';
                            selectedFields.add(f);
                        }
                    }
                    when 'List_out_User_Logins_to_be_deactivated__c','User_Login_Instructions_for_deactivation__c' {
                        if(hideRenewalFields)
                        {
                            query += f.getFieldPath() + ', ';
                            selectedFields.add(f);
                        }
                    }
                   when 'Upgrade_account_from_Renewal_Desk_to_AM__c','Give_Specific_Details__c' {
                        if(opp.Net_Amount_opp_USD__c != NULL && !hideRenewalFields && !hideUpsellFields)   //Opp_Owner_Role__c
                        {
                            if(opp.Net_Amount_opp_USD__c <= 5000)   //opp.Opp_Owner_Role__c.equalsIgnoreCase('AM (Renewal Desk)')
                            {
                                query += f.getFieldPath() + ', ';
                                selectedFields.add(f); 
                            }
                        }
                    }
                    when 'Does_someone_else_get_board_credit__c','Did_this_deal_renew_365_days_in_advance__c' {
                        if(userRoleName != NULL)   //Opp_Owner_Role__c
                        {
                            if(userRoleName != 'AM (Event)' && userRoleName != 'Direct Sales (Event)' && userRoleName != 'Direct Sales (CrowdCompass)')   //opp.Opp_Owner_Role__c.equalsIgnoreCase('AM (Renewal Desk)')
                            {
                                query += f.getFieldPath() + ', ';
                                selectedFields.add(f); 
                            }
                        }
                    }
                    when 'First_Presentation_Date__c' {
                        if(showFirstPresentationDate)
                        {
                            query += f.getFieldPath() + ', ';
                            selectedFields.add(f);
                        }
                    }
                    when 'Sandbox_Account__c' {
                        if(!hideRenewalFields && !hideUpsellFields)
                        {
                            query += f.getFieldPath() + ', ';
                            selectedFields.add(f);
                        }
                    }
                    when 'Primary_User__c'{
                        if(!hideRenewalFields && !hideUpsellFields) // && !hidecrosssellFields
                        {
                            query += f.getFieldPath() + ', ';
                            selectedFields.add(f);
                        }
                    }
                    when 'Welcome_Email_Contact_2__c','Welcome_Email_Contact_3__c','Welcome_Email_Contact_4__c','Additional_Contacts_for_Welcome_Email__c' {
                        if(!hideRenewalFields && !hideUpsellFields)  // && !hidecrosssellFields
                        {
                            query += f.getFieldPath() + ', ';
                            selectedFields.add(f);
                        }
                    }
                    when else {
                        query += f.getFieldPath() + ', ';
                    selectedFields.add(f);
                    }
                }
            }
            
            for(Schema.FieldSetMember f : this.getAdditionalFields()) 
            {
                switch on f.getFieldPath() {
                    when 'AT_PCN_Upsell_or_Credit_Back__c' {
                        if(atPCN && atPCN2)
                        {
                            query += f.getFieldPath() + ', ';
                            additionalFields.add(f); 
                        }
                    }
                    when 'Survey_limits__c' {
                        if(showSurveyLimits && showSurveyLimits2)
                        {
                            query += f.getFieldPath() + ', ';
                            additionalFields.add(f); 
                        }
                    }
                    when 'Standard_Account__c' {
                        if(!hideUpsellFields)
                        {
                            query += f.getFieldPath() + ', ';
                            additionalFields.add(f); 
                        }
                    }
                    when 'First_Mobile_Event_Launch_Date__c' {
                        if(containsCrowdCompassProductFamily)
                        {
                            query += f.getFieldPath() + ', ';
                            additionalFields.add(f); 
                        }
                    }
                    when 'First_Mobile_Event_Date__c' {
                        if(containsCrowdCompassProductFamily)
                        {
                            query += f.getFieldPath() + ', ';
                            additionalFields.add(f); 
                        }
                    }
                     when 'Mobile_Delivery_Date__c' {
                        if(containsCrowdCompassProductFamily)
                        {
                            query += f.getFieldPath() + ', ';
                            additionalFields.add(f); 
                        }
                    }
                     when 'How_Many_Mobile_Apps_Purchased_in_Year_1__c' {
                        if(containsCrowdCompassProductFamily)
                        {
                            query += f.getFieldPath() + ', ';
                            additionalFields.add(f); 
                        }
                    }
                     when 'Rush_Request__c' {
                        if(containsCrowdCompassProductFamily)
                        {
                            System.debug('uinside of field');
                            query += f.getFieldPath() + ', ';
                            additionalFields.add(f); 
                        }
                    }
                    when 'End_of_the_Year_Promo__c'{
                        if(userRoleName.equalsIgnoreCase('Direct Sales (Event)') || userRoleName.equalsIgnoreCase('Direct Sales (CrowdCompass)') || userRoleName.equalsIgnoreCase('Direct Sales (Ent)'))
                        {
                            System.debug('inside of End_of_the_Year_Promo__c');
                            query += f.getFieldPath() + ', ';
                            additionalFields.add(f); 
                        }
                    }
                   /* when 'X2019_Mid_Year_Promo_influence_on_Deal__c' {
                        if(userRoleName.equalsIgnoreCase('Direct Sales (Event)') || userRoleName.equalsIgnoreCase('Direct Sales (CrowdCompass)') || userRoleName.equalsIgnoreCase('Director, Sales (RegOnline)'))
                        {
                            System.debug('Inside of mid year');
                            query += f.getFieldPath() + ', ';
                            additionalFields.add(f); 
                        }
                    } 
                    This is commented because Kathy Dam request, we are not sending this in prod.
                    */
                    when else {
                        query += f.getFieldPath() + ', ';
                    additionalFields.add(f);
                    }
                }
            }
            
            for(Schema.FieldSetMember f : extraAdditionalFieldsEC) 
            {
                query += f.getFieldPath() + ', ';
             }
                        
        }
        else if(hospitalityCloud)
        {
            Set<String> setOfSKUsOfBundles = new Set<String>{'CV-AD-HC-CSN-DGBRP','CV-SW-HC-COT-DEDCMS','CV-SW-HC-COT-DEDCMSAYP'};
            Set<String> setOfSKUsOfEMA = new Set<String>{'CV-PE-HC-CEV-ELMALPKG','CV-PE-HC-CEV-ELMALMGZADV','CV-PE-HC-CEV-ELMALNONMGZADV'};
            Set<String> setOfSKUsOfCventConnect = new Set<String>{'CV-PE-HC-CEV-DEDCCEES','CV-HW-HC-CSN-CCONPRMBO','CV-PE-HC-CSN-CVTCONEX','CV-PE-HC-CSN-CVTCONSP','CV-PE-HC-CSN-CVTCONEXDBL'};
            Integer bundleCheck = 0,emaCheck = 0, cventConnect = 0;
            for(SBQQ__QuoteLine__c opl : [SELECT SBQQ__ProductCode__c,SBQQ__Quantity__c,SBQQ__EffectiveQuantity__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =:opp.SBQQ__PrimaryQuote__c AND (SBQQ__ProductCode__c IN :setOfSKUsOfBundles OR SBQQ__ProductCode__c IN :setOfSKUsOfEMA OR SBQQ__ProductCode__c IN :setOfSKUsOfCventConnect)])
            {
                if(amendedContract)
                {
                    if((opl.SBQQ__Quantity__c > opl.SBQQ__EffectiveQuantity__c && opl.SBQQ__EffectiveQuantity__c > 0) || (opl.SBQQ__Quantity__c == opl.SBQQ__EffectiveQuantity__c))
                    {
                        if(setOfSKUsOfBundles.contains(opl.SBQQ__ProductCode__c))
                        {
                            bundleCheck = 1;
                            renderAddSection = true;
                        }
                        else if(setOfSKUsOfEMA.contains(opl.SBQQ__ProductCode__c))
                        {
                            emaCheck = 1;
                            renderExtraAddSection = true;
                        }
                        else if(setOfSKUsOfCventConnect.contains(opl.SBQQ__ProductCode__c))
                        {
                            cventConnect = 1;
                            renderExtraAddSection = true;
                        } 
                    }
                }
                else
                {
                    if(setOfSKUsOfBundles.contains(opl.SBQQ__ProductCode__c))
                    {
                        bundleCheck = 1;
                        renderAddSection = true;
                    }
                    else if(setOfSKUsOfEMA.contains(opl.SBQQ__ProductCode__c))
                    {
                        emaCheck = 1;
                        renderExtraAddSection = true;
                    }
                    else if(setOfSKUsOfCventConnect.contains(opl.SBQQ__ProductCode__c))
                    {
                        cventConnect = 1;
                        renderExtraAddSection = true;
                    }
                }
            }
            System.debug('bundlecheck>>>'+bundleCheck);
            //System.debug('bundlecheck>>>'+bundleCheck);
            for(Schema.FieldSetMember f : this.getFields()) 
            {
                switch on f.getFieldPath() {
                    when 'EMA_Point_of_Contact__c' {
                        if(emaCheck > 0)
                        {
                            query += f.getFieldPath() + ', ';
                            extraAdditionalFields.add(f);
                        }
                    }
                    when 'CONNECT_Exhibitor_Point_of_Contact__c' {
                        if(cventConnect > 0)
                        {
                            query += f.getFieldPath() + ', ';
                            extraAdditionalFields.add(f);
                        }
                    }
                    when 'First_Presentation_Date__c' {
                        if(showFirstPresentationDate)
                        {
                            query += f.getFieldPath() + ', ';
                            selectedFields.add(f);
                        }
                    }
                    when else {
                        query += f.getFieldPath() + ', ';
                        selectedFields.add(f);
                    }
                }
            }
            for(Schema.FieldSetMember f : this.getAdditionalFields()) 
            {
                switch on f.getFieldPath() {
                    when 'Brand_Page_Code__c','Main_POC_Managing_Microsite__c','Account_Microsite_is_Created_Within__c','Are_all_properties_associated_correctly__c' {
                        if(bundleCheck > 0)
                        {
                            query += f.getFieldPath() + ', ';
                            additionalFields.add(f);
                        }
                    }
                    when else {
                        query += f.getFieldPath() + ', ';
                        additionalFields.add(f);
                    }
                }
            }
        } 
        query += 'Id,Opportunity__c FROM Implementation_Survey__c WHERE Opportunity__c =\''+oppId+'\' LIMIT 1';
        Implementation_Survey__c implementationSurvey = new Implementation_Survey__c();
        /*
        if(listOutUserLoginsToBeDeactivated)
        {
            implementationSurvey.List_out_User_Logins_to_be_deactivated__c = 'Yes';
            implementationSurvey.User_Login_Instructions_for_deactivation__c = 'Yes';
        } */
        List<Implementation_Survey__c> surveys = Database.query(query);
        if(surveys.size() > 0)
            implementationSurvey = surveys[0];
        else
        {
            /*for(Integer i = 0; i< selectedFields.size(); i++) 
            {
                if(selectedFields[i].getFieldPath().equalsIgnoreCase('Name')) 
                {
                    selectedFields.remove(i);
                }
            }*/
            if(eventCloud)
                implementationSurvey.RecordTypeId = Schema.SObjectType.Implementation_Survey__c.getRecordTypeInfosByName().get('Event Cloud').getRecordTypeId();
            else if(hospitalityCloud)
            {
                implementationSurvey.RecordTypeId = Schema.SObjectType.Implementation_Survey__c.getRecordTypeInfosByName().get('Hospitality Cloud').getRecordTypeId();
            }
            implementationSurvey.Account__c = opp.AccountId;
            implementationSurvey.Quote__c = opp.SBQQ__PrimaryQuote__c;
        }
        return implementationSurvey;
    }
    public PageReference OnCancel()
    {
        editSection = false;
        return null;
    }
    public PageReference OnSave()
    {
        //String attachmentBodyString = String.valueOf(oAttachment.body);
        //System.debug('attachmentBodyString: ' + attachmentBodyString);
        editSection = false;
        //oAttachment.ParentId = oppId;
        //insert oAttachment;
        if(implementationSurvey.Opportunity__c != NULL)
        {
            if(implementationSurvey.Tax_Exempt__c == 'Yes, but certificate on file is expired' || implementationSurvey.Tax_Exempt__c == 'Yes, and we have no certificate on file')
            {
                if(implementationSurvey.Upload_Tax_Exempt_Cert__c != 'Yes')
                {
                    if(oAttachment.Body != NULL && oAttachment.Name != NULL)
                    {
                        //System.debug('Upload_Tax_Exempt_Cert__c>>'+implementationSurvey.Upload_Tax_Exempt_Cert__c);
                        oAttachment.ParentId = oppId;
                        insert oAttachment;
                        implementationSurvey.Upload_Tax_Exempt_Cert__c = 'Yes';
                        //System.debug('Upload_Tax_Exempt_Cert__c After>>'+implementationSurvey.Upload_Tax_Exempt_Cert__c);
                    }
                    else
                    {
                        editSection = true;
                        System.debug('oAttachment.body>>'+oAttachment.Body);
                        errorFree = true;
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Upload Tax Exempt Cert.'));
                    }
                }
            }
            
            if(implementationSurvey.K_has_mult_Bill_to_or_Ship_to_addresses__c == 'Yes')
            {
                if(implementationSurvey.Upload_Exhibit__c != 'Yes')
                {
                    if(oAttachment2.Body != NULL && oAttachment2.Name != NULL)
                    {
                        //System.debug('Upload_Tax_Exempt_Cert__c>>'+implementationSurvey.Upload_Tax_Exempt_Cert__c);
                        oAttachment2.ParentId = oppId;
                        insert oAttachment2;
                        implementationSurvey.Upload_Exhibit__c = 'Yes';
                        //System.debug('Upload_Tax_Exempt_Cert__c After>>'+implementationSurvey.Upload_Tax_Exempt_Cert__c);
                    }
                    else
                    {
                        editSection = true;
                        System.debug('oAttachment.body>>'+oAttachment2.Body);
                        errorFree = true;
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Upload Exhibit.'));
                    }
                }
            }
            
            if(eventCloud)
            {
                if(opp.Net_Amount_opp_USD__c != NULL && !hideRenewalFields && !hideUpsellFields && opp.Net_Amount_opp_USD__c <= 5000)
                {
                    if(implementationSurvey.Upgrade_account_from_Renewal_Desk_to_AM__c == 'Yes')
                    {
                        if(implementationSurvey.Give_Specific_Details__c == NULL)
                        {
                            editSection = true;
                            errorFree = true;
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Please Fill Give Specific Details.'));
                            //return null;
                        }
                    }
                }
            }
            if(!errorFree)
            {
                update implementationSurvey; 
                shouldRedirect = true;
                redirectUrl = controller.view().getUrl();
            }
            errorFree = false;
        }
        else
        {
            if(eventCloud)
            {
                if(opp.Net_Amount_opp_USD__c != NULL && !hideRenewalFields && !hideUpsellFields && opp.Net_Amount_opp_USD__c <= 5000)
                {
                    if(implementationSurvey.Upgrade_account_from_Renewal_Desk_to_AM__c == 'Yes')
                    {
                        if(implementationSurvey.Give_Specific_Details__c == NULL)
                        {
                            editSection = true;
                            errorFree = true;
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Please Fill Give Specific Details.'));
                            //return null;
                        }
                    }
                }
            }
            System.debug('errorFree>>>'+errorFree);
            if((implementationSurvey.Tax_Exempt__c == 'Yes, but certificate on file is expired' || implementationSurvey.Tax_Exempt__c == 'Yes, and we have no certificate on file') && !errorFree)
            {
                if(oAttachment.Body != NULL && oAttachment.Name != NULL)
                {
                    oAttachment.ParentId = oppId;
                    insert oAttachment;
                    implementationSurvey.Upload_Tax_Exempt_Cert__c = 'Yes';
                    
                }
                else
                {
                    editSection = true;
                    errorFree = true;
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Upload Tax Exempt Cert.'));
                    //return null;
                }

            }
            
            if((implementationSurvey.K_has_mult_Bill_to_or_Ship_to_addresses__c == 'Yes') && !errorFree)
            {
                if(oAttachment2.Body != NULL && oAttachment2.Name != NULL)
                {
                    oAttachment2.ParentId = oppId;
                    insert oAttachment2;
                    implementationSurvey.Upload_Exhibit__c = 'Yes';
                    
                }
                else
                {
                    editSection = true;
                    errorFree = true;
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Upload Exhibit.'));
                    //return null;
                }

            }
            
            if(!errorFree)
            {
                
                Database.SaveResult result = Database.insert(implementationSurvey,false); 
                if(result.isSuccess())
                {
                    implementationSurvey.Opportunity__c = oppId; 
                    shouldRedirect = true;
                    redirectUrl = controller.view().getUrl();
                }
                else
                {
                    for(Database.Error err : result.getErrors()) 
                    {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, err.getStatusCode() + ': ' + err.getMessage()));
                        editSection = true;
                        errorFree = true;
                    }
                }
            }
            errorFree = false;
        }
        return null;
    }
}