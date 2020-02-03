public class contractCreationController {

    public PageReference test() {
        return null;
    }

    
    public Contract contractRec { get; set; }
    public Opportunity opp { get; set; }
    public contractCreationController( ) {
        
        //this.oppRec =  (Opportunity)controller.getRecord();
        contractRec = new Contract();
        contractRec.Document_Type__c = 'Cvent Standard Terms';
        contractRec.Is_there_an_information_security_review__c = 'No';
        contractRec.Product_Enhancement__c = 'No';
        contractRec.Finance_Review_Required__c = 'No';
        contractRec.SLA_Type__c ='No SLA provided';
        //this.oppRec = 
        //system.debug('@@@Opp Name: '+oppRec.Name);
    }

    /*public contractCreationController() {
        contractRec = new Contract ();
    }*/
    public PageReference SubmitSec() {
        system.debug('contractRec.Finance_Review_Comments__c++'+contractRec.Finance_Review_Comments__c);
        if(contractRec.Finance_Review_Required__c=='Yes' && (contractRec.Finance_Review_Comments__c == '' || contractRec.Finance_Review_Comments__c == null)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'You must enter a value in Finance Review Comments'));
            return null;
        }
        String oppId = apexpages.currentpage().getparameters().get('id');
        Opportunity opp = [Select Id,Name,Account.Name,AccountId,CurrencyIsoCode,New_Contract_Total__c,Exchange_Rate__c from opportunity where id =: oppId];
        system.debug('contractRec+++'+contractRec);
        ///800/e?RecordType=012q00000004Lbc&CF00Nq0000000PykP={!Opportunity.Name}&ctrc7={!Account.Name}&retURL=%2F800%2Fo
        RecordType rt = [Select id from RecordType where developername = 'Customer_Contracts'];
        string url;
        string text1 = contractRec.Document_Type__c;
        Boolean res =false; 
        
        if(text1.contains('Cvent Standard Terms'))
        res = true;
        else if(text1.contains('Upsell – No Review Required'))
        res = true;
        
        string text2 = contractRec.Security_Review_Required__c;
        string text3 = contractRec.SLA_Type__c;
        Boolean res1 = text3.contains('Nonstandard SLA');
        string text4 = contractRec.Finance_Review_Required__c;
        //string text5 = contractRec.Priority__c;
        string text6 = contractRec.Product_Enhancement__c;
        system.debug('contractRec+++'+contractRec);
        Boolean res2 = text6.contains('Yes');
        system.debug('@@@@@text1 : '+text1);
        contractRec.RecordTypeId = rt.id;
        contractRec.Primary_Opportunity__c = opp.Id;
        contractRec.AccountId = opp.AccountId;
        contractRec.CurrencyIsoCode = opp.CurrencyIsoCode;
        system.debug('contractRec+++'+contractRec);
        
        if(contractRec.Is_there_an_information_security_review__c == 'Yes'){
            contractRec.Legal_Review_Required__c = 'Yes';
            contractRec.Security_Review_Required__c = 'No';
        }
        
        Double tempCntTotal;
        tempCntTotal = opp.New_Contract_Total__c;
        if(opp.Exchange_Rate__c!= null && opp.Exchange_Rate__c !=0 && opp.Exchange_Rate__c!= 1)
        tempCntTotal = opp.New_Contract_Total__c/opp.Exchange_Rate__c;
        system.debug('contractRec+++'+contractRec);
        if(tempCntTotal <=10000){
            contractRec.Priority__c = 'Low';
        }else if(tempCntTotal > 10000){
            contractRec.Priority__c = 'Normal';
        }
        
        if(res == true){
             if(res1 == true){
                 contractRec.Legal_Review_Required__c = 'No';
                 contractRec.SLA_Tech_Review_Required__c= 'Yes';
             }
             else{
                 contractRec.Legal_Review_Required__c = 'No';
                 contractRec.SLA_Tech_Review_Required__c= 'No';
             }
         }
         else{
              if(res1 == true){
                  contractRec.Legal_Review_Required__c = 'Yes';
                  contractRec.SLA_Tech_Review_Required__c= 'Yes';
              }else{
                  contractRec.Legal_Review_Required__c = 'Yes';
                  contractRec.SLA_Tech_Review_Required__c= 'No';
              }
         }
         
         if(res != true || contractRec.Is_there_an_information_security_review__c == 'Yes'){
             contractRec.Legal_Review_Required__c = 'Yes';
         }
         if(contractRec.Security_Review_Required__c == 'Yes' || contractRec.Legal_Review_Required__c=='Yes' || contractRec.Finance_Review_Required__c=='Yes' || contractRec.SLA_Tech_Review_Required__c=='Yes' || contractRec.Is_there_an_information_security_review__c == 'Yes' || contractRec.Product_Enhancement__c == 'Yes')
         contractRec.Status = 'Waiting for Documents';
        
         if(contractRec.Legal_Review_Required__c=='No' && contractRec.Finance_Review_Required__c=='No' && contractRec.SLA_Tech_Review_Required__c=='No' && contractRec.Is_there_an_information_security_review__c == 'No' && contractRec.Product_Enhancement__c == 'No')
         contractRec.Status = 'Ready for Signature';
         
         
         PageReference  contractPage;
         try{
             system.debug(contractRec.Document_Type__c);
             system.debug(contractRec.AccountId );
             system.debug('contractRec+++'+contractRec);
             insert contractRec;
             system.debug('contractRec+++'+contractRec);
             system.debug('contractRecId+++'+contractRec.Id);
             Id tempId = contractRec.Id;
             if(tempId  != null){
                 contractPage = new PageReference  ('/'+tempId );
                 contractPage.setRedirect(true);
                 return contractPage;
             }
         }catch(Exception e){
              system.debug(e);
              ApexPages.addMessages(e);
         }
         return null;
         
        /*
        if(res == true){
            if(res1 == true)
                url = '/800/e?RecordType=012q00000004Lbc&CF00Nq0000000PykP='+opp.Name+'&CF00Nq0000000PykP_lkid='+opp.id+'&ctrc7_lkid='+opp.AccountId+'&00Nq0000000Q07U='+text1+'&00Nq0000000Q07j=No&00Nq0000000Q08c='+text2+'&00Nq0000000Q091=Yes&00Nq0000000Q088='+text4+'&00Nq0000000Q07A='+text5+'&ctrc15=Received&CurrencyIsoCode='+opp.CurrencyIsoCode+'&00Nq0000000d4qO='+text6+'&retURL=%2F800%2Fo';
            else
                url = '/800/e?RecordType=012q00000004Lbc&CF00Nq0000000PykP='+opp.Name+'&CF00Nq0000000PykP_lkid='+opp.id+'&ctrc7_lkid='+opp.AccountId+'&00Nq0000000Q07U='+text1+'&00Nq0000000Q07j=No&00Nq0000000Q08c='+text2+'&00Nq0000000Q091=No&00Nq0000000Q088='+text4+'&00Nq0000000Q07A='+text5+'&ctrc15=Received&CurrencyIsoCode='+opp.CurrencyIsoCode+'&00Nq0000000d4qO='+text6+'&retURL=%2F800%2Fo';                                            
        }    
        else{
            if(res1 == true)
                url = '/800/e?RecordType=012q00000004Lbc&CF00Nq0000000PykP='+opp.Name+'&CF00Nq0000000PykP_lkid='+opp.id+'&ctrc7_lkid='+opp.AccountId+'&00Nq0000000Q07U='+text1+'&00Nq0000000Q07j=Yes&00Nq0000000Q08c='+text2+'&00Nq0000000Q091=Yes&00Nq0000000Q088='+text4+'&00Nq0000000Q07A='+text5+'&ctrc15=Received&CurrencyIsoCode='+opp.CurrencyIsoCode+'&00Nq0000000d4qO='+text6+'&retURL=%2F800%2Fo'; 
            else
                url = '/800/e?RecordType=012q00000004Lbc&CF00Nq0000000PykP='+opp.Name+'&CF00Nq0000000PykP_lkid='+opp.id+'&ctrc7_lkid='+opp.AccountId+'&00Nq0000000Q07U='+text1+'&00Nq0000000Q07j=Yes&00Nq0000000Q08c='+text2+'&00Nq0000000Q091=No&00Nq0000000Q088='+text4+'&00Nq0000000Q07A='+text5+'&ctrc15=Received&CurrencyIsoCode='+opp.CurrencyIsoCode+'&00Nq0000000d4qO='+text6+'&retURL=%2F800%2Fo';                 
        } 
        system.debug('@@@@URL : '+url);
        PageReference  contractPage = new PageReference  (url);
        contractPage.setRedirect(true);*/
        
    }
}