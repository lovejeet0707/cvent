public class CloneWriteOffObj_ControllerExt{
    
    public WriteOff__c writeOffObj {get;set;} 
    private String errorMessage = '';
    // The extension constructor initializes the private member
    // variable writeOff by using the getRecord method from the standard
    // controller.
    public CloneWriteOffObj_ControllerExt(ApexPages.StandardController stdController){
        writeOffObj = new WriteOff__c();
        string str = apexpages.currentpage().getparameters().get('id');
        WriteOff__c[] writeOffArray = [select Id,
                                       Name,
                                       Product__c,
                                       Contract__c,
                                       OwnerId,
                                       Total_Contract_Billed__c,
                                       Total_Tax_Billed__c,
                                       Total_Overage_Billed__c,
                                       Office_Location__c,
                                       CurrencyIsoCode,
                                       Customer_Name__c,
                                       Shut_Down_Required__c,
                                       Type_of_Shut_Down__c,
                                       Suggested_Shut_Down_Date__c,
                                       CVII_Link_for_Contract__c,
                                       Contract_Value__c,
                                       Total_Paid__c,
                                       Amount_to_be_Written_Off__c,
                                       Currency_Conversion_Rate__c
                                       from WriteOff__c where Id =:str]; 
        
        if(writeOffArray != null && writeOffArray.size() > 0){
            this.writeOffObj.Product__c = writeOffArray[0].Product__c;
            this.writeOffObj.Total_Contract_Billed__c = writeOffArray[0].Total_Contract_Billed__c;
            this.writeOffObj.Contract__c = writeOffArray[0].Contract__c;
            this.writeOffObj.Total_Tax_Billed__c = writeOffArray[0].Total_Tax_Billed__c;
            this.writeOffObj.Total_Overage_Billed__c = writeOffArray[0].Total_Overage_Billed__c;
            this.writeOffObj.Office_Location__c = writeOffArray[0].Office_Location__c;
            this.writeOffObj.CurrencyIsoCode = writeOffArray[0].CurrencyIsoCode;
            this.writeOffObj.Customer_Name__c = writeOffArray[0].Customer_Name__c;
            this.writeOffObj.Shut_Down_Required__c = writeOffArray[0].Shut_Down_Required__c;
            this.writeOffObj.Type_of_Shut_Down__c = writeOffArray[0].Type_of_Shut_Down__c;
            this.writeOffObj.Suggested_Shut_Down_Date__c = writeOffArray[0].Suggested_Shut_Down_Date__c;
            this.writeOffObj.CVII_Link_for_Contract__c = writeOffArray[0].CVII_Link_for_Contract__c;
            this.writeOffObj.OwnerId = writeOffArray[0].OwnerId;
            this.writeOffObj.Contract_Value__c = writeOffArray[0].Contract_Value__c;
            this.writeOffObj.Total_Paid__c = writeOffArray[0].Total_Paid__c;
            this.writeOffObj.Amount_to_be_Written_Off__c = writeOffArray[0].Amount_to_be_Written_Off__c;
            this.writeOffObj.Currency_Conversion_Rate__c = writeOffArray[0].Currency_Conversion_Rate__c;
        }
    }
    
    // Declared pageReference Object.
    pageReference pr;
    
    // Creates new write off record and redirect user to the detail page of newly inserted record.
    public pageReference saveWriteOff(){
        pr = null;
        try{
            insert writeOffObj;
            pr = new pageReference('/'+writeOffObj.id);
            pr.setRedirect(true);            
        }Catch(Exception exp){
            if(exp.getMessage().indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION,')>=0){
                errorMessage = exp.getMessage().substringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION,');
                errorMessage = errorMessage.substringBeforeLast(': []');
            } else {
                errorMessage = exp.getMessage();
            }
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessage,''));
        }
        return pr;
    }
    
    // Creates new write off record and redirect user for creating additional writeoff record.
    public pageReference saveAndNewWriteOff(){
        pr = null;
        try{
            insert writeOffObj; 
            pr = new pageReference('/apex/CloneWriteOffObj_Page');
            pr.getParameters().put('id',writeOffObj.id);
            pr.setRedirect(true);            
        }Catch(Exception exp){
            if(exp.getMessage().indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION,')>=0){
                errorMessage = exp.getMessage().substringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION,');
                errorMessage = errorMessage.substringBeforeLast(': []');
            } else {
                errorMessage = exp.getMessage();
            }
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessage,''));
        }
        return pr;
    }
}