/*
//////////////////////////////////////
//      @author Abhishek Pandey     //
/////////////////////////////////////
Version :   1.0
Date : 20th July 2015
Description : To remove TRACT Order no. appearing in the existing TCV opportunity insert and update
Version :   2.0
Date : 14th March 2016
Description : To insert or update Contract Review Records on opps . 
Test Class in OpportunityTrgHelperClsTest

Version 2.0
Date:7th Nov 2016
Description : Migrating FEATURESET to PRODUCT/PRICEBOOK. Below are the name of the field which needs to be replaced - 
OLD FIELD NAME       = NEW FIELD NAME
Feature_Sets__r      = OpportunityLineItems;
R00N00000008aGEXEA2  = OpportunityLineItems;
Feature_Set__c       = OpportunityLineItem;
Feature__c           = Product_Name__c;
Opportunity_N__c     = OpportunityId;
//Lines Commented as Can't update CurrencyISOCode of OpportunityLineItem
*/
public class WriteOffTrgHelperCls{  
    //To insert or update Contract Review Records on opps .
    Public static Set<String> setHybPV = new Set<String>(); 
    Public static String idContractRevRecType;
    //Public static Id idContractRevRecType = new Id();
    Public static Set<String> setType1Class = new Set<String>();
    Public static Set<String> setType2Class = new Set<String>();
    Public static Set<String> setType3Class = new Set<String>();    
    Public static map<String,Id> mapDevNameId =  new map<String,Id>();
    Public static Map<String,String> mapProdUsrNameHybrid = new Map<String,String>();
    Public static Map<String,String> mapTOCUsrNameContRev = new Map<String,String>();
    static{
        List<HybridPicklistValue__c> lstHybPiVal= HybridPicklistValue__c.getall().values();
        for(HybridPicklistValue__c instOfHPLV : lstHybPiVal){
            setHybPV.add(instOfHPLV.HybridValue__c);
        }
        List<Cancellation_Categorization__c> lstCanCat = Cancellation_Categorization__c.getall().values();
        for(Cancellation_Categorization__c instOfCanCat: lstCanCat){
            if(instOfCanCat.Type__c.trim() == 'Type 1'){
                setType1Class.add(instOfCanCat.Name.trim());
            }else if(instOfCanCat.Type__c.trim() == 'Type 2'){
                setType2Class.add(instOfCanCat.Name.trim());                
            }else if(instOfCanCat.Type__c.trim() == 'Type 3'){
                setType3Class.add(instOfCanCat.Name.trim());
            }
        }
        
        List<RecordType> lstRecType =[SELECT IsActive, Name, DeveloperName, SobjectType FROM RecordType WHERE SobjectType='Contract_Reviewing__c' And IsActive=true];
        for(RecordType instOfRecType : lstRecType){
            mapDevNameId.put(instOfRecType.DeveloperName,instOfRecType.Id);
        }
        
        List<Cancellation_Assignments__c> lstCanAssign = Cancellation_Assignments__c.getall().values();
        for(Cancellation_Assignments__c instOfCNAssign : lstCanAssign){
            if(instOfCNAssign.Review_Level__c =='Hybrid')
            mapProdUsrNameHybrid.put(instOfCNAssign.Product__c,instOfCNAssign.Username__c);
            if(instOfCNAssign.Type_Of_Cancellation__c!= ''){
                if(instOfCNAssign.Review_Level__c =='Review Team')
                mapTOCUsrNameContRev.put(instOfCNAssign.Type_Of_Cancellation__c.trim(),instOfCNAssign.Username__c.trim());
            }
        }
    } 
    //To insert or update Contract Review Records on opps .
    
    public void OnBeforeInsert(List<WriteOff__c> newValues){ 
        UpdateAMEmailOnWriteOff(newValues);
    }
    public void OnAfterInsert(Map<Id,WriteOff__c> newMapValues){
        List<String> strContractNum = new List<String>();
        List<Id> lstIdBillingCase = new List<Id>();
        for(WriteOff__c instOfWriteOff : newMapValues.values()){
            if(instOfWriteOff.New_TCV_To_Be_Moved__c == 'Yes'){
                strContractNum.add(instOfWriteOff.Contract__c.trim());
                lstIdBillingCase.add(instOfWriteOff.Customer_Name__c);
            }
        }
        
        List<Opportunity> lstOpps = new List<Opportunity>();
        List<Opportunity> lstOppsUpd = new List<Opportunity>();

        if(strContractNum.size()>0)
        lstOpps = [SELECT ID FROM Opportunity WHERE Contract_Number_New__c =: strContractNum AND StageName=:'Tract' AND AccountId=:[SELECT Id,CustomersAccount__c FROM BillingCase__c WHERE ID =:lstIdBillingCase].CustomersAccount__c];
        
        for(Opportunity instOfOpp : lstOpps){
            //instOfOpp.TRACT2__Tract_Sales_Order__c = '';
            //Commented By kumud
           // instOfOpp.New_TCV__c = true;
            lstOppsUpd.add(instOfOpp);
        }
        
        if(lstOppsUpd.size()>0)
        update lstOppsUpd;
    }
    public void OnBeforeUpdate(Map<Id,WriteOff__c> oldMapValues,Map<Id,WriteOff__c> newMapValues){ 
        UpdateAMEmailOnWriteOff(newMapValues.values());
    }
    public void OnAfterUpdate(Map<Id,WriteOff__c> oldMapValues,Map<Id,WriteOff__c> newMapValues){
        List<String> strContractNum = new List<String>();
        List<Id> lstIdBillingCase = new List<Id>();
        //To insert or update Contract Review Records on opps .              
        List<String> strListContractNum = new List<String>(); 
        Map<string,string> mapContNumType = new Map<string,string>();
        Map<String,WriteOff__c> mapContrNumWritOff = new Map<String,WriteOff__c>();
        //To insert or update Contract Review Records on opps .              
        for(WriteOff__c instOfWriteOff : newMapValues.values()){
            if(instOfWriteOff.New_TCV_To_Be_Moved__c == 'Yes' && oldMapValues.get(instOfWriteOff.Id).New_TCV_To_Be_Moved__c != instOfWriteOff.New_TCV_To_Be_Moved__c){
                strContractNum.add(instOfWriteOff.Contract__c.trim());
                lstIdBillingCase.add(instOfWriteOff.Customer_Name__c);
            }
            //To insert or update Contract Review Records on opps .              
            system.debug('====>'+instOfWriteOff.Contract__c.trim()+'======setType3Class'+setType3Class);
            if(instOfWriteOff.Write_Off_Status__c == 'Submitted for Review' && instOfWriteOff.Write_Off_Status__c != oldMapValues.get(instOfWriteOff.Id).Write_Off_Status__c){
                if(instOfWriteOff.Contract__c!=''){
                    mapContrNumWritOff.put(instOfWriteOff.Contract__c,instOfWriteOff);
                    strListContractNum.add(instOfWriteOff.Contract__c.trim());
                    if(setType1Class.contains(instOfWriteOff.Type_of_Cancellation__c.trim())){
                        mapContNumType.put(instOfWriteOff.Contract__c.trim(),'Type1');
                    }else if(setType2Class.contains(instOfWriteOff.Type_of_Cancellation__c.trim())){
                        mapContNumType.put(instOfWriteOff.Contract__c.trim(),'Type2');
                    }else if(setType3Class.contains(instOfWriteOff.Type_of_Cancellation__c.trim())){
                        mapContNumType.put(instOfWriteOff.Contract__c.trim(),'Type3');
                    }
                }
            }
            //To insert or update Contract Review Records on opps . 
        }
        //To insert or update Contract Review Records on opps. 
        List<Id> lstOfIdsRevCreate = new List<Id>();
        List<Id> lstOfIdsRevUpdate = new List<Id>();
        map<Id,Id> mapOppIdContRevId = new map<Id,Id>();
        map<Id,String> mapIdRecType = new map<Id,String>();
        Map<Id,String> mapIdContracNum = new Map<Id,String>();
        Map<Id,Opportunity> mapOppIdOpp = new Map<Id,Opportunity>();
        List<Opportunity> lstOpp = new List<Opportunity>();
        system.debug('strListContractNum++'+strListContractNum);
        system.debug('strListContractNum++'+strListContractNum);
        //if(strListContractNum.size()>0)
        //lstOpp = [SELECT Id,Contract_Number_New__c,Product_Category__c,(SELECT ID FROM Contract_Reviews__r), (SELECT Product_Name__c FROM OpportunityLineItems) FROM Opportunity WHERE Contract_Number_New__c=: strListContractNum AND StageName!= 'Tract' AND Set_Cancellation_Status__c != 'Do not open'];
        
        if(strListContractNum.size()>0)
        lstOpp = [SELECT Id,Contract_Number_New__c,Product_Category__c,(SELECT ID FROM Contract_Reviews__r), (SELECT Product_Name__c FROM OpportunityLineItems) FROM Opportunity WHERE Contract_Number_New__c=: strListContractNum AND StageName!= 'Tract'];
        
        for(Opportunity instOfOpp : lstOpp){
            mapIdContracNum.put(instOfOpp.Id,instOfOpp.Contract_Number_New__c);
            mapOppIdOpp.put(instOfOpp.Id,instOfOpp);
            for(OpportunityLineItem instOfFS: instOfOpp.OpportunityLineItems){
                if(setHybPV.contains(instOfFS.Product_Name__c))
                mapIdRecType.put(instOfOpp.Id,'Hybrid');                
            }
        }
        for(Opportunity instOfOpp : lstOpp){
            if(instOfOpp.Contract_Reviews__r.size()>0){
                lstOfIdsRevUpdate.add(instOfOpp.Id); 
                system.debug(instOfOpp.Id);
                system.debug(instOfOpp.Contract_Reviews__r[0].Id);
                mapOppIdContRevId.put(instOfOpp.Id,instOfOpp.Contract_Reviews__r[0].Id);
            }else if(instOfOpp.Contract_Reviews__r.size()==0){
                lstOfIdsRevCreate.add(instOfOpp.Id);         
            }
        }
        
        List<Contract_Reviewing__c> lstContractRevInsert = new List<Contract_Reviewing__c>();
        
        for(Id instOfId : lstOfIdsRevCreate){
            Contract_Reviewing__c instOfContRev = new Contract_Reviewing__c();
            instOfContRev.Opportunity__c = instOfId;
            if(mapContNumType.get(mapIdContracNum.get(instOfId))=='Type1'){
                instOfContRev.Type_Of_Cancellation__c = mapContrNumWritOff.get(mapIdContracNum.get(instOfId)).Type_of_Cancellation__c;
                /*if(mapIdRecType.get(instOfId)=='Hybrid'){
                    instOfContRev.RecordTypeId = mapDevNameId.get('Hybrid_Cancel');
                    instOfContRev.Canx_Accounting_Reviewer_Hybrid_Feature__c = mapProdUsrNameHybrid.get(mapOppIdOpp.get(instOfId).Product_Category__c);
                    instOfContRev.Is_Hybrid__c = true;
                    instOfContRev.Is_Cancellation__c = true;
                    //For Associating Write Off To Contract Review
                    instOfContRev.Write_Off_Associated__c = mapContrNumWritOff.get(mapIdContracNum.get(instOfId)).Name;
                    //For Associating Write Off To Contract Review
                }else{*/
                    instOfContRev.RecordTypeId = mapDevNameId.get('Contract_Review_Cancel');
                    if(mapTOCUsrNameContRev.containsKey(mapContrNumWritOff.get(mapIdContracNum.get(instOfId)).Type_of_Cancellation__c)){
                        instOfContRev.Canx_Contract_Reviewer__c = mapTOCUsrNameContRev.get(mapContrNumWritOff.get(mapIdContracNum.get(instOfId)).Type_of_Cancellation__c);
                        instOfContRev.Is_Cancellation__c = true;
                        //For Associating Write Off To Contract Review
                        instOfContRev.Write_Off_Associated__c = mapContrNumWritOff.get(mapIdContracNum.get(instOfId)).Name;
                        //For Associating Write Off To Contract Review
                    }else{
                        instOfContRev.Canx_Contract_Reviewer__c = mapTOCUsrNameContRev.get('All OTHERS');
                        instOfContRev.Is_Cancellation__c = true;
                        //For Associating Write Off To Contract Review
                        instOfContRev.Write_Off_Associated__c = mapContrNumWritOff.get(mapIdContracNum.get(instOfId)).Name;
                        //For Associating Write Off To Contract Review
                    }
                    //instOfContRev. mapContrNumWritOff.put();
                //}
            }else if(mapContNumType.get(mapIdContracNum.get(instOfId))=='Type2'){
                instOfContRev.Type_Of_Cancellation__c = mapContrNumWritOff.get(mapIdContracNum.get(instOfId)).Type_of_Cancellation__c;
                /*if(mapIdRecType.get(instOfId)=='Hybrid'){
                    instOfContRev.Canx_Accounting_Reviewer_Hybrid_Feature__c = mapProdUsrNameHybrid.get(mapOppIdOpp.get(instOfId).Product_Category__c);
                    instOfContRev.RecordTypeId = mapDevNameId.get('Hybrid_Cancel');
                    instOfContRev.Is_Hybrid__c = true;
                    instOfContRev.Is_Cancellation__c = true;
                    //For Associating Write Off To Contract Review
                    instOfContRev.Write_Off_Associated__c = mapContrNumWritOff.get(mapIdContracNum.get(instOfId)).Name;
                    //For Associating Write Off To Contract Review
                }else{*/
                    instOfContRev.RecordTypeId = mapDevNameId.get('Contract_Review_Cancel');
                    if(mapTOCUsrNameContRev.containsKey(mapContrNumWritOff.get(mapIdContracNum.get(instOfId)).Type_of_Cancellation__c)){
                        instOfContRev.Canx_Contract_Reviewer__c = mapTOCUsrNameContRev.get(mapContrNumWritOff.get(mapIdContracNum.get(instOfId)).Type_of_Cancellation__c);
                        instOfContRev.Is_Cancellation__c = true;
                        //For Associating Write Off To Contract Review
                        instOfContRev.Write_Off_Associated__c = mapContrNumWritOff.get(mapIdContracNum.get(instOfId)).Name;
                        //For Associating Write Off To Contract Review
                    }else{
                        instOfContRev.Canx_Contract_Reviewer__c = mapTOCUsrNameContRev.get('All OTHERS');
                        instOfContRev.Is_Cancellation__c = true;
                        //For Associating Write Off To Contract Review
                        instOfContRev.Write_Off_Associated__c = mapContrNumWritOff.get(mapIdContracNum.get(instOfId)).Name;
                        //For Associating Write Off To Contract Review
                    }
                //}
            }else if(mapContNumType.get(mapIdContracNum.get(instOfId))=='Type3'){
                instOfContRev.Type_Of_Cancellation__c = mapContrNumWritOff.get(mapIdContracNum.get(instOfId)).Type_of_Cancellation__c;
                /*if(mapIdRecType.get(instOfId)=='Hybrid'){
                    instOfContRev.Canx_Accounting_Reviewer_Hybrid_Feature__c = mapProdUsrNameHybrid.get(mapOppIdOpp.get(instOfId).Product_Category__c);
                    instOfContRev.RecordTypeId = mapDevNameId.get('Hybrid_Cancel');
                    instOfContRev.Is_Hybrid__c = true;
                    instOfContRev.Is_Cancellation__c = true;
                    //For Associating Write Off To Contract Review
                    instOfContRev.Write_Off_Associated__c = mapContrNumWritOff.get(mapIdContracNum.get(instOfId)).Name;
                    //For Associating Write Off To Contract Review
                }else{*/
                    instOfContRev.RecordTypeId = mapDevNameId.get('Contract_Review_Cancel');
                    if(mapTOCUsrNameContRev.containsKey(mapContrNumWritOff.get(mapIdContracNum.get(instOfId)).Type_of_Cancellation__c)){
                        instOfContRev.Canx_Contract_Reviewer__c = mapTOCUsrNameContRev.get(mapContrNumWritOff.get(mapIdContracNum.get(instOfId)).Type_of_Cancellation__c);
                        instOfContRev.Is_Cancellation__c = true;
                        //For Associating Write Off To Contract Review
                        instOfContRev.Write_Off_Associated__c = mapContrNumWritOff.get(mapIdContracNum.get(instOfId)).Name;
                        //For Associating Write Off To Contract Review
                    }else{
                        instOfContRev.Is_Cancellation__c = true;
                        instOfContRev.Canx_Contract_Reviewer__c = mapTOCUsrNameContRev.get('All OTHERS');
                        //For Associating Write Off To Contract Review
                        instOfContRev.Write_Off_Associated__c = mapContrNumWritOff.get(mapIdContracNum.get(instOfId)).Name;
                        //For Associating Write Off To Contract Review
                    }
                //}            
            }
            lstContractRevInsert.add(instOfContRev);
        }
        if(lstContractRevInsert.size()>0)
        insert lstContractRevInsert;
        
        List<Contract_Reviewing__c> lstContractRevUPd = new List<Contract_Reviewing__c>();
        for(Id instOfId : lstOfIdsRevUpdate){
            Contract_Reviewing__c instOfContRev = new Contract_Reviewing__c();  
            system.debug(instOfId);
            system.debug(mapOppIdContRevId);
            system.debug(mapOppIdContRevId.get(instOfId));
            instOfContRev.Id = mapOppIdContRevId.get(instOfId); 
//Deleting some field values when Write_Off_Status__c=='Submitted for Review'.................      
            instOfContRev.Canx_Team_OK__c=null;     
            instOfContRev.Canx_Team_Comments__c=null;       
            instOfContRev.Canx_Contract_Review_Ok__c=null;      
            instOfContRev.Canx_Contract_Review_Comments__c=null;        
            instOfContRev.Canx_Implementation_Team__c=UserInfo.getName();           
            instOfContRev.Force_Open__c = true;
              //..................................Ends Here...........................................
            if(mapContNumType.get(mapIdContracNum.get(instOfId))=='Type1'){
                instOfContRev.Type_Of_Cancellation__c = mapContrNumWritOff.get(mapIdContracNum.get(instOfId)).Type_of_Cancellation__c;
                /*if(mapIdRecType.get(instOfId)=='Hybrid'){
                    instOfContRev.RecordTypeId = mapDevNameId.get('Hybrid_Cancel');
                    instOfContRev.Canx_Accounting_Reviewer_Hybrid_Feature__c = mapProdUsrNameHybrid.get(mapOppIdOpp.get(instOfId).Product_Category__c);
                    instOfContRev.Is_Hybrid__c = true;
                    instOfContRev.Is_Cancellation__c = true;
                    //For Associating Write Off To Contract Review
                    instOfContRev.Write_Off_Associated__c = mapContrNumWritOff.get(mapIdContracNum.get(instOfId)).Name;
                    //For Associating Write Off To Contract Review
                }else{*/
                    instOfContRev.RecordTypeId = mapDevNameId.get('Contract_Review_Cancel');
                    if(mapTOCUsrNameContRev.containsKey(mapContrNumWritOff.get(mapIdContracNum.get(instOfId)).Type_of_Cancellation__c)){
                        instOfContRev.Canx_Contract_Reviewer__c = mapTOCUsrNameContRev.get(mapContrNumWritOff.get(mapIdContracNum.get(instOfId)).Type_of_Cancellation__c);
                        instOfContRev.Is_Cancellation__c = true;
                        //For Associating Write Off To Contract Review
                        instOfContRev.Write_Off_Associated__c = mapContrNumWritOff.get(mapIdContracNum.get(instOfId)).Name;
                        //For Associating Write Off To Contract Review
                    }else{
                        instOfContRev.Canx_Contract_Reviewer__c = mapTOCUsrNameContRev.get('All OTHERS');
                        instOfContRev.Is_Cancellation__c = true;
                        //For Associating Write Off To Contract Review
                        instOfContRev.Write_Off_Associated__c = mapContrNumWritOff.get(mapIdContracNum.get(instOfId)).Name;
                        //For Associating Write Off To Contract Review
                    }
                    //instOfContRev. mapContrNumWritOff.put();
                //}
            }else if(mapContNumType.get(mapIdContracNum.get(instOfId))=='Type2'){
                instOfContRev.Type_Of_Cancellation__c = mapContrNumWritOff.get(mapIdContracNum.get(instOfId)).Type_of_Cancellation__c;
                /*if(mapIdRecType.get(instOfId)=='Hybrid'){
                    instOfContRev.Canx_Accounting_Reviewer_Hybrid_Feature__c = mapProdUsrNameHybrid.get(mapOppIdOpp.get(instOfId).Product_Category__c);
                    instOfContRev.RecordTypeId = mapDevNameId.get('Hybrid_Cancel');
                    instOfContRev.Is_Hybrid__c = true;
                    instOfContRev.Is_Cancellation__c = true;
                    //For Associating Write Off To Contract Review
                    instOfContRev.Write_Off_Associated__c = mapContrNumWritOff.get(mapIdContracNum.get(instOfId)).Name;
                    //For Associating Write Off To Contract Review
                }else{*/
                    instOfContRev.RecordTypeId = mapDevNameId.get('Contract_Review_Cancel');
                    system.debug(instOfId);
                    system.debug(mapIdContracNum.get(instOfId));
                    system.debug(mapContrNumWritOff.get(mapIdContracNum.get(instOfId)).Type_of_Cancellation__c);
                    system.debug(mapTOCUsrNameContRev.get(mapContrNumWritOff.get(mapIdContracNum.get(instOfId)).Type_of_Cancellation__c));
                    system.debug(mapTOCUsrNameContRev);
                    if(mapTOCUsrNameContRev.containsKey(mapContrNumWritOff.get(mapIdContracNum.get(instOfId)).Type_of_Cancellation__c)){
                        instOfContRev.Canx_Contract_Reviewer__c = mapTOCUsrNameContRev.get(mapContrNumWritOff.get(mapIdContracNum.get(instOfId)).Type_of_Cancellation__c);
                        instOfContRev.Is_Cancellation__c = true;
                        //For Associating Write Off To Contract Review
                        instOfContRev.Write_Off_Associated__c = mapContrNumWritOff.get(mapIdContracNum.get(instOfId)).Name;
                        //For Associating Write Off To Contract Review
                    }else{
                        system.debug(mapTOCUsrNameContRev.get('All OTHERS'));
                        system.debug(mapTOCUsrNameContRev);
                        instOfContRev.Canx_Contract_Reviewer__c = mapTOCUsrNameContRev.get('All OTHERS');
                        instOfContRev.Is_Cancellation__c = true;
                        //For Associating Write Off To Contract Review
                        instOfContRev.Write_Off_Associated__c = mapContrNumWritOff.get(mapIdContracNum.get(instOfId)).Name;
                        //For Associating Write Off To Contract Review
                    }
                //}
            }else if(mapContNumType.get(mapIdContracNum.get(instOfId))=='Type3'){
                instOfContRev.Type_Of_Cancellation__c = mapContrNumWritOff.get(mapIdContracNum.get(instOfId)).Type_of_Cancellation__c;
                /*if(mapIdRecType.get(instOfId)=='Hybrid'){
                    instOfContRev.Canx_Accounting_Reviewer_Hybrid_Feature__c = mapProdUsrNameHybrid.get(mapOppIdOpp.get(instOfId).Product_Category__c);
                    instOfContRev.RecordTypeId = mapDevNameId.get('Hybrid_Cancel');
                    instOfContRev.Is_Hybrid__c = true;
                    instOfContRev.Is_Cancellation__c = true;
                    //For Associating Write Off To Contract Review
                    instOfContRev.Write_Off_Associated__c = mapContrNumWritOff.get(mapIdContracNum.get(instOfId)).Name;
                    //For Associating Write Off To Contract Review
                }else{*/
                    instOfContRev.RecordTypeId = mapDevNameId.get('Contract_Review_Cancel');
                    if(mapTOCUsrNameContRev.containsKey(mapContrNumWritOff.get(mapIdContracNum.get(instOfId)).Type_of_Cancellation__c)){
                        instOfContRev.Canx_Contract_Reviewer__c = mapTOCUsrNameContRev.get(mapContrNumWritOff.get(mapIdContracNum.get(instOfId)).Type_of_Cancellation__c);
                        instOfContRev.Is_Cancellation__c = true;
                        //For Associating Write Off To Contract Review
                        instOfContRev.Write_Off_Associated__c = mapContrNumWritOff.get(mapIdContracNum.get(instOfId)).Name;
                        //For Associating Write Off To Contract Review
                    }else{
                        instOfContRev.Is_Cancellation__c = true;
                        instOfContRev.Canx_Contract_Reviewer__c = mapTOCUsrNameContRev.get('All OTHERS');
                        //For Associating Write Off To Contract Review
                        instOfContRev.Write_Off_Associated__c = mapContrNumWritOff.get(mapIdContracNum.get(instOfId)).Name;
                        //For Associating Write Off To Contract Review
                    }
                //}            
            }
            lstContractRevUPd.add(instOfContRev); 
        }
        if(lstContractRevUPd.size()>0)
        update lstContractRevUPd;
        //To insert or update Contract Review Records on opps . 
        List<Opportunity> lstOpps = new List<Opportunity>();
        List<Opportunity> lstOppsUpd = new List<Opportunity>();
         
        if(strContractNum.size()>0)
        lstOpps = [SELECT ID FROM Opportunity WHERE Contract_Number_New__c =: strContractNum AND StageName=:'Tract' AND AccountId=:[SELECT Id,CustomersAccount__c FROM BillingCase__c WHERE ID =:lstIdBillingCase].CustomersAccount__c];
        
        for(Opportunity instOfOpp : lstOpps){
            //instOfOpp.TRACT2__Tract_Sales_Order__c = '';
            //Commented by kumud 
            //instOfOpp.New_TCV__c = true;
            lstOppsUpd.add(instOfOpp);
        }
        
        if(lstOppsUpd.size()>0)
        update lstOppsUpd;
    }
    public void OnBeforeDelete(List<WriteOff__c> oldValues,Map<Id,WriteOff__c> oldMapValues){    
    }
    public void OnAfterDelete(List<WriteOff__c> oldValues,Map<Id,WriteOff__c> oldMapValues){    
    }
    public void OnUndelete(List<WriteOff__c> newValues){
    }
    
    //Added by Shanu on 16 September 2016
    public void UpdateAMEmailOnWriteOff(List<WriteOff__c> newValues){
            
        Set<ID> billingIds = new Set<ID>();
        //Getting AM Fields from Account
        Map<Id,Account> mapbillingCase = new Map<Id,Account>();
        Map<Id,String> writeOffVSAM = new Map<Id,String>();
        
        //User full name VS Email
        Map<String,String> mapUserVsEmail = new Map<String,String>();
        
        
        //Getting Billing Case Id's
        for(WriteOff__c wo : newValues){
            
            if(wo.Customer_Name__c!=null)
                billingIds.add(wo.Customer_Name__c); 
        }
        
        //Getting AM Fields from Account 
        for(BillingCase__c bc : [ Select Id, CustomersAccount__r.AM_CSN__c, /*CustomersAccount__r.AM_CT_TM__c,*/ CustomersAccount__r.AM_Event__c,
                                    CustomersAccount__r.AM_Survey__c,CustomersAccount__r.AM_CrowdCompass__c,CustomersAccount__r.AM_OS__c  From BillingCase__c Where ID IN:  billingIds and CustomersAccount__c!=null]){
            mapbillingCase.put(bc.Id, bc.CustomersAccount__r);
        }
        
        
        if(mapbillingCase.values().size()>0){
            
            
            for(WriteOff__c wo : newValues){
                
                //AM Field API Name Based on the product of Write-Off
                String AMfieldAPIName = AccountTeamMultiProductSetting__c.getValues(wo.Product__c)!=null ? + AccountTeamMultiProductSetting__c.getValues(wo.Product__c).API_Name_AM__c : '';
                System.debug('**** AMfieldAPIName *** ' + AMfieldAPIName );
                if(AMfieldAPIName!='' && mapbillingCase.containsKey(wo.Customer_Name__c) ){
                        writeOffVSAM.put(wo.Id, String.valueOf(mapbillingCase.get(wo.Customer_Name__c).get(AMfieldAPIName)));
                }
                    
            }
            
           //System.debug('-******' + writeOffVSAM.values());
          
         //  System.debug('-******' + Select Id,Name,Email From User Where Name IN: writeOffVSAM.values());
            
            for(User u : [Select Id,Name,Email From User Where Name IN: writeOffVSAM.values()]){
                mapUserVsEmail.put(u.Name,u.Email);
            }
            
            
            for(WriteOff__c wo : newValues){
                
                if(writeOffVSAM.containsKey(wo.Id)){}
                    wo.AM_Email__c = mapUserVsEmail.get( writeOffVSAM.get(wo.Id));
            }
                
        }
    }    
}//