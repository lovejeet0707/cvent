public class PhoneNumberValidator_Clone{
    
    public static Map<String,Country_Phone_Codes__c> ISDCodesMap = Country_Phone_Codes__c.getAll();
    //static string funcOff = Label.PhoneNumberValidator;
    //Updating the Contact Phone Format..............................
    static Map<Id,String> conIdVsoldHisCountryCode = new Map<Id,String>();
    public static void updateContactPhoneNumber(List<Contact> newContactList,Map<Id,Contact> oldContactMap){
        if(!oldContactMap.isEmpty())
        {
            For(ContactHistory contactHisRecord: [SELECT Id,OldValue FROM ContactHistory WHERE Id IN : oldContactMap.keySet() AND Field = 'MailingCountryCode' 
                                                  ORDER BY CreatedDate DESC NULLS FIRST LIMIT 1])
            {
                conIdVsoldHisCountryCode.put(contactHisRecord.Id,String.ValueOf(contactHisRecord.OldValue));
            }
        }
        string formattedPhone;
        string otherPhone;
        string MobilePhone;
        string historyISDCode;
        string ISDCode;
        string oldISDCode;
        System.debug('ISDCodesMapSize*******'+ISDCodesMap.size());
        System.debug('ISDCodesMap*******'+ISDCodesMap);
        For(Contact conRec : newContactList)
        {
            /*
            Commented due to some issue need to fix in future....
            if(conRec.Phone != NULL)
            {
                if(!Pattern.matches('^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\\s\\./0-9]*$',conRec.Phone))
                {
                    conRec.addError('Phone Number is not valid.');  
                }
                
            }*/
            formattedPhone = '';
            otherPhone = '';
            MobilePhone = '';
            historyISDCode = '';
            ISDCode = '';
            System.debug('conRec.MailingCountryCode*******'+conRec.MailingCountryCode);
            System.debug('Phone****'+conRec.Phone);
            System.debug('ISDCOdes map contains: '+ISDCodesMap.containsKey(conRec.MailingCountryCode));
            if(ISDCodesMap.containsKey(conRec.MailingCountryCode)){
                if(conRec.Phone!=null || conRec.OtherPhone!=null || conRec.MobilePhone!=null){
                    ISDCode = ISDCodesMap.get(conRec.MailingCountryCode).ISD_Code__c;
                    if(!conIdVsoldHisCountryCode.isEmpty() && conIdVsoldHisCountryCode.containsKey(conRec.Id) && ISDCodesMap.containsKey(conIdVsoldHisCountryCode.get(conRec.Id)))
                        historyISDCode = ISDCodesMap.get(conIdVsoldHisCountryCode.get(conRec.Id)).ISD_Code__c;
                    if(!oldContactMap.isEmpty() && oldContactMap.containsKey(conRec.Id) && ISDCodesMap.containsKey(oldContactMap.get(conRec.Id).MailingCountryCode))
                        oldISDCode = ISDCodesMap.get(oldContactMap.get(conRec.Id).MailingCountryCode).ISD_Code__c;
                    //If phone starts with ISD Code. Remove the same. 
                    if(conRec.Phone!=null){
                        //System.debug('Inside of this check where phone is not null');
                        //System.debug('Inside of phone validation check1: '+Pattern.matches('^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\\s\\./0-9]*$',conRec.Phone));
                        
                        //System.debug('Inside of phone validation check: '+Pattern.matches('^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\\s\\./0-9]*$',conRec.Phone));
                        formattedPhone = conRec.Phone.replaceAll('\\D', '');
                        formattedPhone = formattedPhone.startsWith('0')?formattedPhone.substringAfter('0'):formattedPhone;
                        if(formattedPhone.startsWith(ISDCode)){
                            System.debug('ISDCode**** inside');
                            formattedPhone = formattedPhone.removeStart(ISDCode);
                        }
                        
                        else if(oldISDCode !=null && formattedPhone.startsWith(oldISDCode)){
                            System.debug('ISDCode**** inside');
                            formattedPhone = formattedPhone.removeStart(oldISDCode);
                        }
                        
                        else if(historyISDCode!=null && formattedPhone.startsWith(historyISDCode)){
                            System.debug('ISDCode**** inside');
                            formattedPhone = formattedPhone.removeStart(historyISDCode);
                        }
                        
                        System.debug('formattedPhone**** formattedPhone'+formattedPhone);
                        conRec.Phone= '+' + ISDCode + formattedPhone;
                    }
                    if(conRec.OtherPhone!=null){
                        otherPhone =  conRec.OtherPhone.replaceAll('\\D', '');
                        otherPhone = otherPhone.startsWith('0')?otherPhone.substringAfter('0'):otherPhone;
                        if(otherPhone.startsWith(ISDCode)){
                            System.debug('ISDCode**** inside');
                            otherPhone = otherPhone.removeStart(ISDCode);
                        }
                        
                        else if(oldISDCode !=null && otherPhone.startsWith(oldISDCode)){
                            System.debug('ISDCode**** inside');
                            otherPhone = otherPhone.removeStart(oldISDCode);
                        }
                        
                        else if(historyISDCode!=null && otherPhone.startsWith(historyISDCode)){
                            System.debug('ISDCode**** inside');
                            otherPhone= otherPhone.removeStart(historyISDCode);
                        }
                        
                        System.debug('otherPhone**** otherPhone'+otherPhone);
                        conRec.otherPhone = '+' + ISDCode + otherPhone;
                    }
                    if(conRec.MobilePhone!=null){
                        mobilePhone =  conRec.MobilePhone.replaceAll('\\D', '');
                        MobilePhone = MobilePhone.startsWith('0')?MobilePhone.substringAfter('0'):MobilePhone;
                        if(mobilePhone.startsWith(ISDCode)){
                            System.debug('ISDCode**** inside');
                            mobilePhone= mobilePhone.removeStart(ISDCode);
                        }
                        
                        else if(oldISDCode !=null && mobilePhone.startsWith(oldISDCode)){
                            System.debug('ISDCode**** inside');
                            mobilePhone= mobilePhone.removeStart(oldISDCode);
                        }
                        
                        else if(historyISDCode!=null && mobilePhone.startsWith(historyISDCode)){
                            System.debug('ISDCode**** inside');
                            mobilePhone= mobilePhone.removeStart(historyISDCode);
                        }
                        
                        System.debug('mobilePhone**** mobilePhone'+mobilePhone);
                        conRec.mobilePhone= '+' + ISDCode + mobilePhone;
                    }
                    
                }
            }
        }
    }
    //Updating the Lead Phone Format..............................
    static Map<Id,String> leadIdVsOldHisCountryCode = new Map<Id,String>();
    public static void updateLeadPhoneNumber(List<Lead> newLeadList,Map<Id,Lead> oldLeadMap){
        if(!oldLeadMap.isEmpty())
        {
            For(LeadHistory leadHisRecord: [SELECT Id,OldValue FROM LeadHistory WHERE Id IN : oldLeadMap.keySet() AND Field = 'CountryCode' 
                                            ORDER BY CreatedDate DESC NULLS FIRST LIMIT 1])
            {
                leadIdVsOldHisCountryCode.put(leadHisRecord.Id,String.ValueOf(leadHisRecord.OldValue));
            }
        }
        string formattedPhone;
        string otherPhone;
        string MobilePhone;
        string historyISDCode;
        string ISDCode;
        string oldISDCode;
        For(Lead leadRec : newLeadList)
        {
            formattedPhone = '';
            otherPhone = '';
            MobilePhone = '';
            historyISDCode = '';
            ISDCode = '';
            /*if(leadRec.Phone != NULL)
            {
                if(!Pattern.matches('^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\\s\\./0-9]*$',leadRec.Phone))
                {
                    leadRec.addError('Phone Number is not valid.');  
                }
                
            }*/
            if(ISDCodesMap.containsKey(leadRec.CountryCode)){
                if(leadRec.Phone!=null || leadRec.Other_Phone__c!=null || leadRec.MobilePhone!=null){
                    ISDCode = ISDCodesMap.get(leadRec.CountryCode).ISD_Code__c;
                    if(!leadIdVsOldHisCountryCode.isEmpty() && leadIdVsOldHisCountryCode.containsKey(leadRec.Id) && ISDCodesMap.containsKey(conIdVsoldHisCountryCode.get(leadRec.Id)))
                        historyISDCode = ISDCodesMap.get(leadIdVsOldHisCountryCode.get(leadRec.Id)).ISD_Code__c;
                    if(!oldLeadMap.isEmpty() && oldLeadMap.containsKey(leadRec.Id) && ISDCodesMap.containsKey(oldLeadMap.get(leadRec.Id).CountryCode))
                        oldISDCode = ISDCodesMap.get(oldLeadMap.get(leadRec.Id).CountryCode).ISD_Code__c;
                    //If phone starts with ISD Code. Remove the same. 
                    if(leadRec.Phone!=null){
                        formattedPhone = leadRec.Phone.replaceAll('\\D', '');
                            formattedPhone = formattedPhone.startsWith('0')?formattedPhone.substringAfter('0'):formattedPhone;
                            if(formattedPhone.startsWith(ISDCode)){
                                System.debug('ISDCode**** inside');
                                formattedPhone = formattedPhone.removeStart(ISDCode);
                            }
                            
                            else if(oldISDCode !=null && formattedPhone.startsWith(oldISDCode)){
                                System.debug('ISDCode**** inside');
                                formattedPhone = formattedPhone.removeStart(oldISDCode);
                            }
                            
                            else if(historyISDCode!=null && formattedPhone.startsWith(historyISDCode)){
                                System.debug('ISDCode**** inside');
                                formattedPhone = formattedPhone.removeStart(historyISDCode);
                            }
                            
                            System.debug('formattedPhone**** formattedPhone'+formattedPhone);
                            leadRec.Phone= '+' + ISDCode + formattedPhone;
                    }
                    if(leadRec.Other_Phone__c!=null){
                        otherPhone =  leadRec.Other_Phone__c.replaceAll('\\D', '');
                        otherPhone = otherPhone.startsWith('0')?otherPhone.substringAfter('0'):otherPhone;
                        if(otherPhone.startsWith(ISDCode)){
                            System.debug('ISDCode**** inside');
                            otherPhone = otherPhone.removeStart(ISDCode);
                        }
                        
                        else if(oldISDCode !=null && otherPhone.startsWith(oldISDCode)){
                            System.debug('ISDCode**** inside');
                            otherPhone = otherPhone.removeStart(oldISDCode);
                        }
                        
                        else if(historyISDCode!=null && otherPhone.startsWith(historyISDCode)){
                            System.debug('ISDCode**** inside');
                            otherPhone= otherPhone.removeStart(historyISDCode);
                        }
                        
                        System.debug('otherPhone**** otherPhone'+otherPhone);
                        leadRec.Other_Phone__c = '+' + ISDCode + otherPhone;
                    }
                    if(leadRec.MobilePhone!=null){
                        mobilePhone =  leadRec.MobilePhone.replaceAll('\\D', '');
                        MobilePhone = MobilePhone.startsWith('0')?MobilePhone.substringAfter('0'):MobilePhone;
                        if(mobilePhone.startsWith(ISDCode)){
                            System.debug('ISDCode**** inside');
                            mobilePhone= mobilePhone.removeStart(ISDCode);
                        }
                        
                        else if(oldISDCode !=null && mobilePhone.startsWith(oldISDCode)){
                            System.debug('ISDCode**** inside');
                            mobilePhone= mobilePhone.removeStart(oldISDCode);
                        }
                        
                        else if(historyISDCode!=null && mobilePhone.startsWith(historyISDCode)){
                            System.debug('ISDCode**** inside');
                            mobilePhone= mobilePhone.removeStart(historyISDCode);
                        }
                        
                        System.debug('mobilePhone**** mobilePhone'+mobilePhone);
                        leadRec.mobilePhone= '+' + ISDCode + mobilePhone;
                    }
                    
                }
            }
        }
    }
    //Updating the Account Phone Format..............................
    static Map<Id,String> accIdVsOldHisCountryCode = new Map<Id,String>();
    public static void updateAccountPhoneNumber(List<Account> newAccountList,Map<Id,Account> oldAccountMap){
        if(!oldAccountMap.isEmpty())
        {
            For(AccountHistory accHisRecord: [SELECT Id,OldValue FROM AccountHistory WHERE Id IN : oldAccountMap.keySet() AND Field = 'BillingCountryCode' 
                                              ORDER BY CreatedDate DESC NULLS FIRST LIMIT 1])
            {
                accIdVsOldHisCountryCode.put(accHisRecord.Id,String.ValueOf(accHisRecord.OldValue));
            }
        }
        string formattedPhone;
        string historyISDCode;
        string ISDCode;
        string oldISDCode;
        For(Account accRec : newAccountList)
        {
            formattedPhone = '';
            historyISDCode = '';
            ISDCode = '';
            /*if(accRec.Phone != NULL)
            {
                if(!Pattern.matches('^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\\s\\./0-9]*$',accRec.Phone))
                {
                    accRec.addError('Phone Number is not valid.');  
                }
                
            }*/
            if(ISDCodesMap.containsKey(accRec.BillingCountryCode)){
                if(accRec.Phone!=null){
                    ISDCode = ISDCodesMap.get(accRec.BillingCountryCode).ISD_Code__c;
                    if(!accIdVsOldHisCountryCode.isEmpty() && accIdVsOldHisCountryCode.containsKey(accRec.Id) && ISDCodesMap.containsKey(conIdVsoldHisCountryCode.get(accRec.Id)))
                        historyISDCode = ISDCodesMap.get(accIdVsOldHisCountryCode.get(accRec.Id)).ISD_Code__c;
                    if(!oldAccountMap.isEmpty() && oldAccountMap.containsKey(accRec.Id) && ISDCodesMap.containsKey(oldAccountMap.get(accRec.Id).BillingCountryCode))
                        oldISDCode = ISDCodesMap.get(oldAccountMap.get(accRec.Id).BillingCountryCode).ISD_Code__c;
                    //If phone starts with ISD Code. Remove the same. 
                    if(accRec.Phone!=null){
                        formattedPhone = accRec.Phone.replaceAll('\\D', '');
                            formattedPhone = formattedPhone.startsWith('0')?formattedPhone.substringAfter('0'):formattedPhone;
                            if(formattedPhone.startsWith(ISDCode)){
                                System.debug('ISDCode**** inside');
                                formattedPhone = formattedPhone.removeStart(ISDCode);
                            }
                            
                            else if(oldISDCode !=null && formattedPhone.startsWith(oldISDCode)){
                                System.debug('ISDCode**** inside');
                                formattedPhone = formattedPhone.removeStart(oldISDCode);
                            }
                            
                            else if(historyISDCode!=null && formattedPhone.startsWith(historyISDCode)){
                                System.debug('ISDCode**** inside');
                                formattedPhone = formattedPhone.removeStart(historyISDCode);
                            }
                            
                            System.debug('formattedPhone**** formattedPhone'+formattedPhone);
                            accRec.Phone= '+' + ISDCode + formattedPhone;
                       }
                }
            }
        }
    }
}