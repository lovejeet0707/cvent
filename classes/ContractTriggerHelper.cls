/*   
   Author :Kumud thakur
   SOC :22-Dec-2015
   DESC: It is call by contract review on update
//////////////////////////////////////
//      @author Abhishek Pandey     //
/////////////////////////////////////
Version :   2.0
Date : 16th March 2016
Description : Cancellation Review Process. 
Version :   3.0
Date : 11th April 2016
Description : Review Date Changes

//////////////////////////////////////
//      @author Kumud Thakur     //
/////////////////////////////////////

Version :   2.1
Date : 11th April 2016
Description : Tract order number validation [tract number should not be blank  in the deal year 1 opportunity during the contract review of deal year 2 Opportunity ] 
*/

 Public class ContractTriggerHelper{
    //Cancellation Review Process.
    Public static Boolean isRunOnce=false;
    Public static Map<String,String> mapUserNameId = new Map<String,String>();
    Public static Map<String,Id> mapDevNameId = new Map<String,Id>();
    Public static Set<String> setType1Class = new Set<String>();
    Public static Set<String> setType2Class = new Set<String>();
    Public static Set<String> setType3Class = new Set<String>();
    Public static Map<String,String> mapTOCUsrNameContRev = new Map<String,String>(); 
    Public static Map<String,String> mapTaxUsrNameId = new Map<String,String>(); 
    Public static Map<String,String> mapAccLev1ProdUsrName = new Map<String,String>();
    Public static Map<String,String> mapAccLev2ProdUsrName = new Map<String,String>();
    Public static Map<String,String> mapAccLev0ProdUsrName = new Map<String,String>();
    Public static Map<String,String> mapAccLev1IdUsrName = new Map<String,String>();
    Public static Map<String,String> mapAccLev2IdUsrName = new Map<String,String>();
    Public static Map<String,String> mapAccLev0IdUsrName = new Map<String,String>();
    Public static Map<String,Cancellations_Super_Users__c> mapSuperUserCanc = new Map<String,Cancellations_Super_Users__c>();
    Public static String strTaxUsrName; 
    Public static Set<Id> setIdsSupUsr = new Set<Id>();
    
    static{
        strTaxUsrName = '';
        mapSuperUserCanc = Cancellations_Super_Users__c.getAll();
        List<Cancellation_Assignments__c> lstCanAssign = Cancellation_Assignments__c.getall().values();
        
        List<Contract_Review__c> lstContRev = Contract_Review__c.getall().values();     
        for(Contract_Review__c instConRev :lstContRev){     
            setIdsSupUsr.add(instConRev.Name);      
        }
        for(Cancellation_Assignments__c instOfCNAssign : lstCanAssign){
            mapUserNameId.put(instOfCNAssign.Username__c.trim(),instOfCNAssign.UserId__c.trim());
            //if(instOfCNAssign.Review_Level__c =='Hybrid')
            //mapProdUsrNameHybrid.put(instOfCNAssign.Product__c,instOfCNAssign.Username__c);
            if(instOfCNAssign.Type_Of_Cancellation__c != ''){
                if(instOfCNAssign.Review_Level__c =='Review Team')
                mapTOCUsrNameContRev.put(instOfCNAssign.Type_Of_Cancellation__c.trim(),instOfCNAssign.Username__c.trim());
            }
            if(instOfCNAssign.Review_Level__c =='Tax'){
                mapTaxUsrNameId.put(instOfCNAssign.UserId__c.trim(),instOfCNAssign.Username__c.trim());
                strTaxUsrName = instOfCNAssign.Username__c.trim();
            }
            if(instOfCNAssign.Review_Level__c =='AccLevel1'){
                mapAccLev1ProdUsrName.put(instOfCNAssign.product__c.trim(),instOfCNAssign.Username__c.trim());
                mapAccLev1IdUsrName.put(instOfCNAssign.Username__c.trim(),instOfCNAssign.UserId__c.trim());
                //strTaxUsrName = instOfCNAssign.Username__c.trim();
            }
            if(instOfCNAssign.Review_Level__c =='AccLevel2'){
                mapAccLev2ProdUsrName.put(instOfCNAssign.product__c.trim(),instOfCNAssign.Username__c.trim());
                mapAccLev2IdUsrName.put(instOfCNAssign.Username__c.trim(),instOfCNAssign.UserId__c.trim());
                //strTaxUsrName = instOfCNAssign.Username__c.trim();
            }
            if(instOfCNAssign.Review_Level__c =='Cancellation'){
                mapAccLev0ProdUsrName.put(instOfCNAssign.product__c.trim(),instOfCNAssign.Username__c.trim());
                mapAccLev0IdUsrName.put(instOfCNAssign.Username__c.trim(),instOfCNAssign.UserId__c.trim());
            }
        }
        List<RecordType> lstRecType =[SELECT IsActive, Name, DeveloperName, SobjectType FROM RecordType WHERE SobjectType='Contract_Reviewing__c' And IsActive=true];
        for(RecordType instOfRecType : lstRecType){
            mapDevNameId.put(instOfRecType.DeveloperName,instOfRecType.Id);
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
    }
    //Cancellation Review Process. 
    Public static Map<Id,Contract_Reviewing__c> onBeforeUpdate(List<Contract_Reviewing__c> listContractReview,Map<Id,Contract_Reviewing__c> newMap,Map<Id,Contract_Reviewing__c> oldMap){
        
        isRunOnce=true;
        
        Set<ID> setOpptyId=new Set<ID>();
        Map<String,Superuser__c> mapSuperUser=Superuser__c.getAll();
        Set<String> setAuthoriseUser=new Set<String>();
        Set<String> setSuperUser=new Set<String>();
        setAuthoriseUser.add(UserInfo.getName());
        for(Superuser__c superObj:mapSuperUser.values()){
           setSuperUser.add(superObj.SuperUserName__c);
        }
        
       
        Set<String> setContractNumber=new set<String>();
        //Map<Id,String> mapIDvsProduct=new Map<Id,String>();
        Map<Id,Contract_Reviewing__c> mapIdContract=new Map<Id,Contract_Reviewing__c>();
        Map<String,String> mapProductVsName2=new Map<String,String>();
        Map<String,String> mapProductVsName3=new Map<String,String>();
        Set<Id> setIds=new set<Id>();
                
         // Add [on 8 April 2016]       
        Set<String> setContractNumer=new Set<String>();     
       // Set<String> setDealYear=new Set<String>();
        for(Contract_Reviewing__c objContract:listContractReview){
            setOpptyId.add(objContract.opportunity__c);
            setIds.add(objContract.id);
            // Add [on 8 April 2016] Tract order number validation      
            setContractNumer.add(objContract.Opportunity_Contract__c);      
            String dealYear;
           /* if(objContract.Deal_Year__c!=null){
               // dealYear=String.valueOf(Integer.valueOf(objContract.Deal_Year__c));        
               setDealYear.add('1');   
            }  */ 
            
            // end 
        }
          //Map<Id,Opportunity> mapOpportunity=new Map<id,Opportunity>([Select product__C from opportunity where id in :setOpptyId]);               Map<Id,Opportunity> mapOpportunity=new Map<id,Opportunity>([Select product__C from opportunity where id in :setOpptyId]);
        Map<Id,Opportunity> mapOpportunity=new Map<id,Opportunity>();       
        Map<String,Opportunity> mapDealOpportunity=new Map<String,Opportunity>();       
        Map<String,string> mapDealVsCRStatus=new Map<String,string> ();     
        //for(Opportunity instanceOpp:[Select Deal_Year__c,Contract_Number_New__c,Product_Category__c,product__C,TRACT2__Tract_Sales_Order__c,(select Contract_Review_Ok__c from Contract_Reviews__r limit 1) from opportunity where (Deal_Year__c ='1' and Contract_Number_New__c in :setContractNumer) OR id in :setOpptyId]){       
        for(Opportunity instanceOpp:[Select Deal_Year__c,Contract_Number_New__c,Product_Category__c,product__C,(select Contract_Review_Ok__c from Contract_Reviews__r limit 1) from opportunity where (Deal_Year__c ='1' and Contract_Number_New__c in :setContractNumer) OR id in :setOpptyId]){       
                    
            if(setOpptyId.contains(instanceOpp.id))     
                mapOpportunity.put(instanceOpp.id,instanceOpp);  // used in below code for assignment .     
                    
            for(Contract_Reviewing__c instnceCR: instanceOpp.Contract_Reviews__r){      
                //if(instnceCR.Contract_Review_Ok__c=='Yes'){       
                            
                    mapDealOpportunity.put(instanceOpp.Contract_Number_New__c+instanceOpp.Deal_Year__c,instanceOpp);        
                    mapDealVsCRStatus.put(instanceOpp.Contract_Number_New__c+instanceOpp.Deal_Year__c,instnceCR.Contract_Review_Ok__c);     
                //}     
                        
            }       
                    
                    
                    
                    
        }   // End of for loop[Tract order number validation]
        
        Map<String,TrackUser__c> mapIDVsTrackUSer=TrackUser__c.getAll();
        List<TractLevel4User__C> listTractTopLevelUser=TractLevel4User__C.getAll().values(); //Custom setting to get 4level user name
        for(TrackUser__c trackUser:mapIDVsTrackUSer.values()){
            mapProductVsName2.put(trackUser.product_name__C,trackUser.Name_Level_2__c);
            mapProductVsName3.put(trackUser.product_name__C,trackUser.Name_Level_3__c);
            
      
        }//End of loop
        //Map<Id,RecordType> mapIDVsRecordType=new Map<ID,RecordType>([select id,developername from recordtype where sobjecttype='Contract_Reviewing__c']); // To get all current oppty RT
        Map<String,Id> mapNameVsRTId=new Map<String,Id>();
        for(RecordType objRecordtype:[select id,developername from recordtype where sobjecttype='Contract_Reviewing__c']){
            mapNameVsRTId.put(objRecordtype.developername,objRecordtype.id);
            
        }
        Boolean flag=false;
        //Cancellation Review Process. 
        //List<String> lstContractNum = new List<String>();
        List<String> lstOppTobeLocked = new List<String>();
        List<String> lstConTNumFindTCVs = new List<String>();
        List<String> lstFindTCVs  = new List<String>();
        List<String> lstOfCntNumOppsTBR = new List<String>();
        //Cancellation Review Process. 
        
        for(Contract_Reviewing__c objContract : listContractReview){
            
            /*   Below code for Tract order# validation */   
       
       
       system.debug('objContract+++++ '+objContract.Accounting_Review_Ok__c);
         
                
            if(objContract.Deal_Year__c!='1'){      
                        
                Integer dealYear;    
                if(objContract.Opportunity_Stage__c!= 'Tract'){   
                    if(objContract.Deal_Year__c==null){     
                            objContract.addError('Deal year should not be null at opportunity Level');      
                    }else{      
                        dealYear=Integer.valueOf(objContract.Deal_Year__c);     
                    }    
                }   
                        
                //Integer dealYear=objContract.Deal_Year__c==null?objContract.addError('Deal year should not be null at opportunity Level'):Integer.valueOf(objContract.Deal_Year__c);      
                //for(Integer i=1;i<=dealYear;i++){        
                    Integer i=1;   
                    String key=objContract.Opportunity_Contract__c+String.valueOf(i);       
                    system.debug('***************+'+key+'*---------------************mapDealOpportunity'+mapDealOpportunity);       
                            
                    if((objContract.Contract_Review_Ok__c =='Yes' && objContract.Contract_Review_Ok__c != oldMap.get(objContract.id).Contract_Review_Ok__c) && (mapDealOpportunity.keyset().contains(key) && (mapDealOpportunity.get(key).Product__c!='SignUp4' && mapDealOpportunity.get(key).Product__c!='TicketMob' && mapDealOpportunity.get(key).Product__c!='EMI' && mapDealOpportunity.get(key).Product__c!='Decision Street' && mapDealOpportunity.get(key).Product__c!='RappidApp' && mapDealOpportunity.get(key).Product__c!='Onsite Solutions'))){     
                                
                //        objContract.addError('TRACT Order # should not be  blank in the opportunity deal year '+i);     
                    }       
               // }       
                        
                        
            }  // End here [Tract order# validation] 
            
            
            
                if(!objContract.Is_Cancellation__c){
                   //Level 2 Assignment
                   if(!setSuperUser.contains(UserInfo.getName()) && !setAuthoriseUser.contains(objContract.Accounting_Team_Reviewer__c) && (newMap.get(objContract.id).Accounting_Review_Ok__c!=oldMap.get(objContract.id).Accounting_Review_Ok__c || newMap.get(objContract.id).Accounting_Team_Reviewer__c !=oldMap.get(objContract.id).Accounting_Team_Reviewer__c) && newMap.get(objContract.id).Accounting_Review_Ok__c!='Error Correct'){
                       
                       objContract.addError('You are not allowed to edit');
                       
                   }else{
                        system.debug('**************newMap.get(objContract.id).Accounting_Review_Ok__c'+newMap.get(objContract.id).Accounting_Review_Ok__c);
                        system.debug('***---***oldMap.get(objContract.id).Accounting_Review_Ok__c'+oldMap.get(objContract.id).Accounting_Review_Ok__c);
                        
                           if(newMap.get(objContract.id).Accounting_Review_Ok__c!=oldMap.get(objContract.id).Accounting_Review_Ok__c){
                                if(oldMap.get(objContract.id).Accounting_Review_Ok__c!='Re-Review' && oldMap.get(objContract.id).Accounting_Review_Ok__c!='Error Correct'  && objContract.Accounting_Review_Ok__c=='Yes'){//&& objContract.Opportunity_Contract_Total_Converted__c>5000
                                    objContract.Acc_Review_Post_Rev_Rec__c=mapProductVsName2.get(mapOpportunity.get(objContract.opportunity__c).product__C);
                                    objContract.recordtypeID=mapNameVsRTId.get('Account_Team_Level_2');
                                    
                                }else if(objContract.Accounting_Review_Ok__c=='No'){
                                    
                                    objContract.recordtypeID=mapNameVsRTId.get('Account_Team_Level_1');
                                    //objContract.Contract_Review_Ok__c='Re-Review';
                                    setContractNumber.add(objContract.Opportunity_Contract__c);
                                } else if((oldMap.get(objContract.id).Accounting_Review_Ok__c=='Re-Review' || oldMap.get(objContract.id).Accounting_Review_Ok__c=='Error Correct') && objContract.Accounting_Review_Ok__c=='Yes'){
                                    
                                    
                                    objContract.recordtypeID=mapNameVsRTId.get('Account_Team_Level_2');
                                    objContract.Acc_Review_Post_Rev_Rec_OK__c='Error Correct';
                                    if( objContract.Acc_Review_Post_Rev_Rec__c==null || objContract.Acc_Review_Post_Rev_Rec__c==''){
                                         objContract.Acc_Review_Post_Rev_Rec__c=mapProductVsName2.get(mapOpportunity.get(objContract.opportunity__c).product__C);
                                         objContract.Acc_Review_Post_Rev_Rec_OK__c='';
                                    }
                                }
                             flag=true;                         
                            }
                   }        
                    // Level 3 assignment
                     if(!setSuperUser.contains(UserInfo.getName()) && !flag && (newMap.get(objContract.id).Acc_Review_Post_Rev_Rec_OK__c!=oldMap.get(objContract.id).Acc_Review_Post_Rev_Rec_OK__c || newMap.get(objContract.id).Acc_Review_Post_Rev_Rec__c !=oldMap.get(objContract.id).Acc_Review_Post_Rev_Rec__c) && objContract.Acc_Review_Post_Rev_Rec__c  !=UserInfo.getName()){
                       
                                objContract.addError('You are not allowed to edit');
                       
                   }else{
                                if(newMap.get(objContract.id).Acc_Review_Post_Rev_Rec_OK__c!=oldMap.get(objContract.id).Acc_Review_Post_Rev_Rec_OK__c){
                                    if(oldMap.get(objContract.id).Acc_Review_Post_Rev_Rec_OK__c!='Re-Review' && oldMap.get(objContract.id).Acc_Review_Post_Rev_Rec_OK__c!='Error Correct' && objContract.Acc_Review_Post_Rev_Rec_OK__c=='Yes') {// && objContract.Opportunity_Contract_Total_Converted__c>50000
                                     // objContract.IsLockedLevel2__c=true;
                                      objContract.Contract_Value_50k__c=mapProductVsName3.get(mapOpportunity.get(objContract.opportunity__c).product__C);
                                      objContract.recordtypeID=mapNameVsRTId.get('Account_Team_Level_3');
                                    
                                    }else if(objContract.Acc_Review_Post_Rev_Rec_OK__c=='No'){
                                        objContract.Accounting_Review_Ok__c='Re-Review';
                                        objContract.recordtypeID=mapNameVsRTId.get('Account_Team_Level_1_Read_only');
                                       // objContract.IsLockedLevel1__c=false;
                                        //setContractNumber.add(objContract.Opportunity_Contract__c);
                                    }else if((oldMap.get(objContract.id).Acc_Review_Post_Rev_Rec_OK__c=='Re-Review' || oldMap.get(objContract.id).Acc_Review_Post_Rev_Rec_OK__c=='Error Correct' ) && objContract.Acc_Review_Post_Rev_Rec_OK__c=='Yes'){
                                          
                                          objContract.recordtypeID=mapNameVsRTId.get('Account_Team_Level_3');
                                          objContract.Contract_Value_50k_review_Ok__c='Error Correct';
                                          if(objContract.Contract_Value_50k__c==null || objContract.Contract_Value_50k__c==''){
                                              objContract.Contract_Value_50k__c=mapProductVsName3.get(mapOpportunity.get(objContract.opportunity__c).product__C);
                                              objContract.Contract_Value_50k_review_Ok__c='';
                                          }
                                                
                                }      
                                    flag=true;
                                }       
                   }
                    //Level 4 assingment
                    if(!setSuperUser.contains(UserInfo.getName()) && !flag && !setAuthoriseUser.contains(objContract.Contract_Value_50k__c)&& (newMap.get(objContract.id).Contract_Value_50k_review_Ok__c!=oldMap.get(objContract.id).Contract_Value_50k_review_Ok__c || newMap.get(objContract.id).Contract_Value_50k__c !=oldMap.get(objContract.id).Contract_Value_50k__c)){
                       
                                objContract.addError('You are not allowed to edit');
                       
                   }else{
                                if(newMap.get(objContract.id).Contract_Value_50k_review_Ok__c!=oldMap.get(objContract.id).Contract_Value_50k_review_Ok__c){
                                    
                                    if(oldMap.get(objContract.id).Contract_Value_50k_review_Ok__c!='Re-Review' && oldMap.get(objContract.id).Contract_Value_50k_review_Ok__c!='Error Correct' && objContract.Contract_Value_50k_review_Ok__c=='Yes') {// && objContract.Opportunity_Contract_Total_Converted__c>100000
                                          objContract.Contract_Value_100k__c=listTractTopLevelUser[0].name__C ;//'Courtney Hansen';//mapProductVsName3.get(mapOpportunity.get(objContract.opportunity__c).product__C);
                                          objContract.recordtypeID=mapNameVsRTId.get('Account_Team_Level_4');
                                       //objContract.Level3__c=true;
                                    }else if(objContract.Contract_Value_50k_review_Ok__c=='No'){
                                          objContract.Acc_Review_Post_Rev_Rec_OK__c='Re-Review';
                                          objContract.recordtypeID=mapNameVsRTId.get('Account_Team_Level_2_Read_only');
                                         // objContract.Level2__c=false;
                                          //setContractNumber.add(objContract.Opportunity_Contract__c);
                                    }else if((oldMap.get(objContract.id).Contract_Value_50k_review_Ok__c=='Re-Review' || oldMap.get(objContract.id).Contract_Value_50k_review_Ok__c=='Error Correct') && objContract.Contract_Value_50k_review_Ok__c=='Yes'){// && objContract.Opportunity_Contract_Total_Converted__c>100000
                                           
                                            objContract.recordtypeID=mapNameVsRTId.get('Account_Team_Level_4');
                                            objContract.Contract_Value_100k_review_Ok__c='Error Correct';
                                            
                                             if(objContract.Contract_Value_100k__c==null || objContract.Contract_Value_100k__c==''){
                                                 objContract.Contract_Value_100k__c=listTractTopLevelUser[0].name__C;
                                                 objContract.Contract_Value_100k_review_Ok__c='';
                                             }
                                                
                                }    
                                   flag=true;   
                                }   
                   }// Level 4 review
                   if(!setSuperUser.contains(UserInfo.getName()) && !flag && !setAuthoriseUser.contains(objContract.Contract_Value_100k__c) && (newMap.get(objContract.id).Contract_Value_100k_review_Ok__c !=oldMap.get(objContract.id).Contract_Value_100k_review_Ok__c  || newMap.get(objContract.id).Contract_Value_100k__c  !=oldMap.get(objContract.id).Contract_Value_100k__c )){
                       
                                objContract.addError('You are not allowed to edit');
                       
                   }else{
                                if(newMap.get(objContract.id).Contract_Value_100k_review_Ok__c !=oldMap.get(objContract.id).Contract_Value_100k_review_Ok__c ){
                                    
                                    if(objContract.Contract_Value_100k_review_Ok__c =='Yes') {
                                      //objContract.Acc_Review_Post_Rev_Rec__c=mapProductVsName3.get(mapOpportunity.get(objContract.opportunity__c).product__C);
                                      //objContract.recordtypeID=mapNameVsRTId.get('Account_Team_Level_4');Account_Team_Level_4_Read_Only
                                      objContract.recordtypeID=mapNameVsRTId.get('Account_Team_Level_4_Read_Only');
                                       //objContract.Level4__c=true;
                                    }else if(objContract.Contract_Value_100k_review_Ok__c=='No'){
                                            objContract.Contract_Value_50k_review_Ok__c='Re-Review';
                                          objContract.recordtypeID=mapNameVsRTId.get('Account_Team_Level_3_Read_Only');
                                          //setContractNumber.add(objContract.Opportunity_Contract__c);
                                          //objContract.Level3__c=false;
                                    }
                                    
                                }   
                   }            
                   mapIdContract.put(objContract.id,objContract); 
                system.debug('------------------>'+objContract);
            //Cancellation Review Process. 
            }else if(objContract.Is_Cancellation__c == true || objContract.Opportunity_Stage__c == 'Tract'){
                if(objContract.Is_Hybrid__c == true && objContract.Opportunity_Stage__c != 'Tract'){
                        flag=false;
                        system.debug('flag--'+flag);
                        if(!mapSuperUserCanc.keyset().contains(UserInfo.getUserId())&& mapUserNameId.get(objContract.Canx_Implementation_Team__c) != UserInfo.getUserId() && (objContract.Canx_Team_OK__c != oldMap.get(objContract.Id).Canx_Team_OK__c || objContract.Canx_Implementation_Team__c!=oldMap.get(objContract.Id).Canx_Implementation_Team__c || objContract.Canx_Team_Comments__c != oldMap.get(objContract.Id).Canx_Team_Comments__c) ){
                            objContract.addError('You are not allowed to edit this record+++');
                        }else{
                            if(objContract.Canx_Team_OK__c!= oldMap.get(objContract.Id).Canx_Team_OK__c && objContract.Canx_Team_OK__c == 'Yes' && oldMap.get(objContract.Id).Canx_Team_OK__c!='Re-Review'){
                                //lstContractNum.add(objContract.Opportunity_Contract__c);
                                objContract.RecordTypeId = mapDevNameId.get('Hybrid_Cancel');
                                objContract.Canx_Accounting_Hybrid_Review_Ok__c = 'Error Correct';
                            }else if(objContract.Canx_Contract_Review_Ok__c=='No'&& objContract.Canx_Team_OK__c!= oldMap.get(objContract.Id).Canx_Team_OK__c && oldMap.get(objContract.Id).Canx_Team_OK__c=='Re-Review' && objContract.Canx_Team_OK__c=='Yes' ) {
                                objContract.Canx_Contract_Review_Ok__c='Error Correct';
                                objContract.RecordTypeId = mapDevNameId.get('Contract_Review_Cancel');
                            }else if(objContract.Canx_Accounting_Hybrid_Review_Ok__c=='No'&& objContract.Canx_Team_OK__c!= oldMap.get(objContract.Id).Canx_Team_OK__c && oldMap.get(objContract.Id).Canx_Team_OK__c=='Re-Review' && objContract.Canx_Team_OK__c=='Yes' ) {
                                 objContract.Canx_Accounting_Hybrid_Review_Ok__c='Error Correct';
                                 objContract.RecordTypeId = mapDevNameId.get('Hybrid_Cancel');
                            }
                            if(objContract.Canx_Team_OK__c != oldMap.get(objContract.Id).Canx_Team_OK__c || objContract.Canx_Implementation_Team__c!=oldMap.get(objContract.Id).Canx_Implementation_Team__c || objContract.Canx_Team_Comments__c != oldMap.get(objContract.Id).Canx_Team_Comments__c){
                                flag=true;
                            }
                       }
                    system.debug('flag--'+flag);
                    if(!mapSuperUserCanc.keyset().contains(UserInfo.getUserId()) && !flag && objContract.Force_Open__c==false && mapUserNameId.get(objContract.Canx_Accounting_Reviewer_Hybrid_Feature__c) != UserInfo.getUserId() && (objContract.Canx_Accounting_Hybrid_Review_Ok__c != oldMap.get(objContract.Id).Canx_Accounting_Hybrid_Review_Ok__c || objContract.Canx_Accounting_Reviewer_Hybrid_Feature__c!=oldMap.get(objContract.Id).Canx_Accounting_Reviewer_Hybrid_Feature__c || objContract.Canx_Acc_Reviewer_Comments_Hybrid__c != oldMap.get(objContract.Id).Canx_Acc_Reviewer_Comments_Hybrid__c) ){
                        objContract.addError('You are not allowed to edit this record----');
                    }else{
                        if(objContract.Canx_Accounting_Hybrid_Review_Ok__c!= oldMap.get(objContract.Id).Canx_Accounting_Hybrid_Review_Ok__c && objContract.Canx_Accounting_Hybrid_Review_Ok__c == 'Yes'){
                            //lstContractNum.add(objContract.Opportunity_Contract__c);
                            objContract.RecordTypeId = mapDevNameId.get('Contract_Review_Cancel');
                            if(mapTOCUsrNameContRev.containsKey(objContract.Type_Of_Cancellation__c)){
                                objContract.Canx_Contract_Reviewer__c = mapTOCUsrNameContRev.get(objContract.Type_Of_Cancellation__c);
                            }else{
                                objContract.Canx_Contract_Reviewer__c = mapTOCUsrNameContRev.get('All OTHERS');
                            }
                            flag=true;
                        }
                        
                        if(objContract.Canx_Accounting_Hybrid_Review_Ok__c != oldMap.get(objContract.Id).Canx_Accounting_Hybrid_Review_Ok__c || objContract.Canx_Accounting_Reviewer_Hybrid_Feature__c!=oldMap.get(objContract.Id).Canx_Accounting_Reviewer_Hybrid_Feature__c || objContract.Canx_Acc_Reviewer_Comments_Hybrid__c != oldMap.get(objContract.Id).Canx_Acc_Reviewer_Comments_Hybrid__c){
                            flag=true;
                        }
                        objContract.Force_Open__c = false;
                        /*else if(objContract.Canx_Accounting_Hybrid_Review_Ok__c!= oldMap.get(objContract.Id).Canx_Accounting_Hybrid_Review_Ok__c && objContract.Canx_Accounting_Hybrid_Review_Ok__c == 'Error Correct'){
                            //lstContractNum.add(objContract.Opportunity_Contract__c);
                            objContract.RecordTypeId = mapDevNameId.get('Contract_Review_Cancel');
                            if(mapTOCUsrNameContRev.containsKey(objContract.Type_Of_Cancellation__c)){
                                objContract.Canx_Contract_Reviewer__c = mapTOCUsrNameContRev.get(objContract.Type_Of_Cancellation__c);
                            }else{
                                objContract.Canx_Contract_Reviewer__c = mapTOCUsrNameContRev.get('All OTHERS');
                            }
                            flag=true;
                        }*/
                        if(objContract.Canx_Accounting_Hybrid_Review_Ok__c != oldMap.get(objContract.Id).Canx_Accounting_Hybrid_Review_Ok__c && objContract.Canx_Accounting_Hybrid_Review_Ok__c == 'No'){
                            objContract.RecordTypeId = mapDevNameId.get('Cancellation');
                            objContract.Canx_Team_OK__c = 'Re-Review';
                            if(mapAccLev0ProdUsrName.containsKey(objContract.Product_Category_Tract__c)){
                                objContract.Canx_Implementation_Team__c = mapAccLev0ProdUsrName.get(objContract.Product_Category_Tract__c); 
                            }else{
                                objContract.Canx_Implementation_Team__c = mapAccLev0ProdUsrName.get('Other');
                            }
                            flag=true;
                        }
                    }
                    system.debug('Super User--'+!mapSuperUserCanc.keyset().contains(UserInfo.getUserId()));
                    system.debug('flag--'+flag);
                    system.debug('!flag--'+!flag);
                    system.debug('objContract.Force_Open__c--'+objContract.Force_Open__c);
                    system.debug('mapUserNameId.get(objContract.Canx_Contract_Reviewer__c)--'+mapUserNameId.get(objContract.Canx_Contract_Reviewer__c));
                    system.debug('UserInfo.getUserId()--'+UserInfo.getUserId());
                    system.debug('objContract.Canx_Contract_Reviewer__c--'+objContract.Canx_Contract_Reviewer__c);
                    system.debug('oldMap.get(objContract.Id).Canx_Contract_Reviewer__c--'+oldMap.get(objContract.Id).Canx_Contract_Reviewer__c);
                    
                    if(!mapSuperUserCanc.keyset().contains(UserInfo.getUserId()) && !flag && mapUserNameId.get(objContract.Canx_Contract_Reviewer__c) != UserInfo.getUserId() && (objContract.Canx_Contract_Review_Ok__c != oldMap.get(objContract.Id).Canx_Contract_Review_Ok__c || objContract.Canx_Contract_Review_Comments__c !=oldMap.get(objContract.Id).Canx_Contract_Review_Comments__c || objContract.Canx_Contract_Reviewer__c != oldMap.get(objContract.Id).Canx_Contract_Reviewer__c ) ){
                        objContract.addError('You are not allowed to edit this record');
                    }else{
                        //If YES OR ERROR CORRECT
                        if(objContract.Canx_Contract_Review_Ok__c !=  oldMap.get(objContract.Id).Canx_Contract_Review_Ok__c && objContract.Canx_Contract_Review_Ok__c == 'Yes' && (objContract.Tax_Review_Ok__c==''||objContract.Tax_Review_Ok__c==null) ){
                            //lstContractNum.add(objContract.Opportunity_Contract__c);
                            if(setType1Class.contains(objContract.Type_Of_Cancellation__c)){
                                objContract.RecordTypeId = mapDevNameId.get('Annual_And_TCV_Lock');
                                //lstConTNumFindTCVs.add(objContract.Opportunity_Contract__c);  
                            }else if(setType2Class.contains(objContract.Type_Of_Cancellation__c)){
                                objContract.RecordTypeId = mapDevNameId.get('Annual_And_TCV_Lock');
                                lstOppTobeLocked.add(objContract.Opportunity__c);
                            }else if(setType3Class.contains(objContract.Type_Of_Cancellation__c)){
                                objContract.RecordTypeId = mapDevNameId.get('Tax_Cancel');
                                objContract.Tax_Reviewer__c = strTaxUsrName;
                            }
                        }else if(objContract.Tax_Review_Ok__c=='No' && objContract.Canx_Contract_Review_Ok__c !=  oldMap.get(objContract.Id).Canx_Contract_Review_Ok__c && objContract.Canx_Contract_Review_Ok__c == 'Yes'  ){
                              
                               if(setType3Class.contains(objContract.Type_Of_Cancellation__c)){
                                    objContract.RecordTypeId = mapDevNameId.get('Tax_Cancel');
                                    //objContract.Tax_Reviewer__c = strTaxUsrName;
                                     objContract.Tax_Review_Ok__c='Error Correct';
                               }
                        }
                        
                        if(objContract.Canx_Contract_Review_Ok__c != oldMap.get(objContract.Id).Canx_Contract_Review_Ok__c || objContract.Canx_Contract_Review_Comments__c !=oldMap.get(objContract.Id).Canx_Contract_Review_Comments__c || objContract.Canx_Contract_Reviewer__c != oldMap.get(objContract.Id).Canx_Contract_Reviewer__c ){
                            flag=true;
                        }
                        /*else if(objContract.Canx_Contract_Review_Ok__c !=  oldMap.get(objContract.Id).Canx_Contract_Review_Ok__c && objContract.Canx_Contract_Review_Ok__c == 'Error Correct'){
                            //lstContractNum.add(objContract.Opportunity_Contract__c);
                            if(setType1Class.contains(objContract.Type_Of_Cancellation__c)){
                                objContract.RecordTypeId = mapDevNameId.get('Annual_And_TCV_Lock');
                                lstFindTCVs.add(objContract.Opportunity__c);  
                            }else if(setType2Class.contains(objContract.Type_Of_Cancellation__c)){
                                objContract.RecordTypeId = mapDevNameId.get('Annual_And_TCV_Lock');
                                lstOppTobeLocked.add(objContract.Opportunity__c);
                            }else if(setType3Class.contains(objContract.Type_Of_Cancellation__c)){
                                objContract.RecordTypeId = mapDevNameId.get('Tax_Cancel');
                                objContract.Tax_Reviewer__c = strTaxUsrName;
                            }
                            flag=true;
                        }*/
                        //If YES OR ERROR CORRECT
                        
                        //If No OR Re-Review
                        if(objContract.Canx_Contract_Review_Ok__c != oldMap.get(objContract.Id).Canx_Contract_Review_Ok__c && objContract.Canx_Contract_Review_Ok__c == 'No'){
                            //objContract.RecordTypeId = mapDevNameId.get('Hybrid_Cancel');  //  comment by kumud 
                            //objContract.Canx_Accounting_Hybrid_Review_Ok__c = 'Re-Review'; //  comment by kumud [27 may 16]
                            //[Add by Kumud]
                            objContract.RecordTypeId = mapDevNameId.get('Contract_Review_Cancel');
                            objContract.Canx_Team_OK__c = 'Re-Review';
                            if(mapAccLev0ProdUsrName.containsKey(objContract.Product_Category_Tract__c)){
                                objContract.Canx_Implementation_Team__c = mapAccLev0ProdUsrName.get(objContract.Product_Category_Tract__c); 
                            }else{
                                objContract.Canx_Implementation_Team__c = mapAccLev0ProdUsrName.get('Other');
                            }
                            //objContract.Canx_Implementation_Team__c=mapAccLev0ProdUsrName.get(objContract.Product_Category_Tract__c); 
                            // End here 
                            flag=true;
                        }
                        //If No OR Re-Review
                    }
                    
                    if(!mapSuperUserCanc.keyset().contains(UserInfo.getUserId()) && !flag && !mapTaxUsrNameId.keyset().contains(UserInfo.getUserId())  && (objContract.Tax_Reviewer__c != oldMap.get(objContract.Id).Tax_Reviewer__c || objContract.Tax_Reviewer_Comments__c !=oldMap.get(objContract.Id).Tax_Reviewer_Comments__c || objContract.Tax_Reviewer_Rejection_Reason__c != oldMap.get(objContract.Id).Tax_Reviewer_Rejection_Reason__c ||  objContract.Tax_Review_Ok__c != oldMap.get(objContract.Id).Tax_Review_Ok__c ) ){
                        objContract.addError('You are not allowed to edit this record');
                    }else{
                        if(objContract.Tax_Review_Ok__c != oldMap.get(objContract.Id).Tax_Review_Ok__c  && objContract.Tax_Review_Ok__c == 'Yes'){
                            //lstContractNum.add(objContract.Opportunity_Contract__c);
                            objContract.RecordTypeId = mapDevNameId.get('Annual_And_TCV_Lock');
                        }
                        //else if(objContract.Tax_Review_Ok__c != oldMap.get(objContract.Id).Tax_Review_Ok__c  && objContract.Tax_Review_Ok__c == 'Error Correct'){
                            //lstContractNum.add(objContract.Opportunity_Contract__c);
                            //objContract.RecordTypeId = mapDevNameId.get('Annual_And_TCV_Lock');
                        //}
                        //If No OR Re-Review
                        if(objContract.Tax_Review_Ok__c != oldMap.get(objContract.Id).Tax_Review_Ok__c  && objContract.Tax_Review_Ok__c == 'No'){
                            //lstContractNum.add(objContract.Opportunity_Contract__c);
                            objContract.RecordTypeId = mapDevNameId.get('Contract_Review_Cancel');
                            objContract.Canx_Contract_Review_Ok__c = 'Re-Review';
                        }
                        //If No OR Re-Review
                    }
                    
                }else if(objContract.Opportunity_Stage__c != 'Tract' && objContract.Is_Hybrid__c ==false){
                    //NOT HYBRID 
                    flag=false;
                    if(!mapSuperUserCanc.keyset().contains(UserInfo.getUserId()) && mapUserNameId.get(objContract.Canx_Implementation_Team__c) != UserInfo.getUserId() && (objContract.Canx_Team_OK__c != oldMap.get(objContract.Id).Canx_Team_OK__c || objContract.Canx_Implementation_Team__c!=oldMap.get(objContract.Id).Canx_Implementation_Team__c || objContract.Canx_Team_Comments__c != oldMap.get(objContract.Id).Canx_Team_Comments__c) ){
                        objContract.addError('You are not allowed to edit this record+++--');
                    }else{
                        
                        if(objContract.Canx_Team_OK__c!= oldMap.get(objContract.Id).Canx_Team_OK__c && objContract.Canx_Team_OK__c == 'Yes'){
                            //lstContractNum.add(objContract.Opportunity_Contract__c);
                            objContract.RecordTypeId = mapDevNameId.get('Contract_Review_Cancel');
                            objContract.Canx_Contract_Review_Ok__c= 'Error Correct';
                        }
                        if(objContract.Canx_Team_OK__c != oldMap.get(objContract.Id).Canx_Team_OK__c || objContract.Canx_Implementation_Team__c!=oldMap.get(objContract.Id).Canx_Implementation_Team__c || objContract.Canx_Team_Comments__c != oldMap.get(objContract.Id).Canx_Team_Comments__c){
                            flag=true;
                        }
                    }
                    
                   
                    if(!mapSuperUserCanc.keyset().contains(UserInfo.getUserId()) && !flag && objContract.Force_Open__c == false && mapUserNameId.get(objContract.Canx_Contract_Reviewer__c) != UserInfo.getUserId() && (objContract.Canx_Contract_Review_Ok__c != oldMap.get(objContract.Id).Canx_Contract_Review_Ok__c || objContract.Canx_Contract_Review_Comments__c !=oldMap.get(objContract.Id).Canx_Contract_Review_Comments__c || objContract.Canx_Contract_Reviewer__c != oldMap.get(objContract.Id).Canx_Contract_Reviewer__c ) ){
                        objContract.addError('You are not allowed to edit this record---+++------------');
                    }else{
                        system.debug(objContract.Canx_Contract_Review_Ok__c);
                        system.debug(objContract.Canx_Contract_Review_Ok__c);
                        if(objContract.Canx_Contract_Review_Ok__c!= oldMap.get(objContract.Id).Canx_Contract_Review_Ok__c && objContract.Canx_Contract_Review_Ok__c == 'Yes'){
                            system.debug(objContract.Canx_Contract_Review_Ok__c);
                            if(setType1Class.contains(objContract.Type_Of_Cancellation__c)){
                                objContract.RecordTypeId = mapDevNameId.get('Annual_And_TCV_Lock');
                                //lstConTNumFindTCVs.add(objContract.Opportunity_Contract__c);  
                            }else if(setType2Class.contains(objContract.Type_Of_Cancellation__c)){
                                objContract.RecordTypeId = mapDevNameId.get('Annual_And_TCV_Lock');
                                lstOppTobeLocked.add(objContract.Opportunity__c);
                            }else if(setType3Class.contains(objContract.Type_Of_Cancellation__c)){
                                objContract.RecordTypeId = mapDevNameId.get('Tax_Cancel');
                                objContract.Tax_Reviewer__c = strTaxUsrName;
                            }
                        }
                        if(objContract.Canx_Contract_Review_Ok__c != oldMap.get(objContract.Id).Canx_Contract_Review_Ok__c || objContract.Canx_Contract_Review_Comments__c !=oldMap.get(objContract.Id).Canx_Contract_Review_Comments__c || objContract.Canx_Contract_Reviewer__c != oldMap.get(objContract.Id).Canx_Contract_Reviewer__c){
                            flag=true;
                        }
                        objContract.Force_Open__c = false;
                        if(objContract.Canx_Contract_Review_Ok__c!= oldMap.get(objContract.Id).Canx_Contract_Review_Ok__c && objContract.Canx_Contract_Review_Ok__c == 'No'){
                            objContract.RecordTypeId = mapDevNameId.get('Cancellation');
                            objContract.Canx_Team_OK__c = 'Re-Review';
                            if(mapAccLev0ProdUsrName.containsKey(objContract.Product_Category_Tract__c)){
                                objContract.Canx_Implementation_Team__c = mapAccLev0ProdUsrName.get(objContract.Product_Category_Tract__c); 
                            }else{
                                objContract.Canx_Implementation_Team__c = mapAccLev0ProdUsrName.get('Other');
                            }
                        }
                        /*else if(objContract.Canx_Contract_Review_Ok__c!= oldMap.get(objContract.Id).Canx_Contract_Review_Ok__c && objContract.Canx_Contract_Review_Ok__c == 'Error Correct'){
                            if(setType1Class.contains(objContract.Type_Of_Cancellation__c)){
                                objContract.RecordTypeId = mapDevNameId.get('Annual_And_TCV_Lock');
                                lstFindTCVs.add(objContract.Opportunity__c);  
                            }else if(setType2Class.contains(objContract.Type_Of_Cancellation__c)){
                                objContract.RecordTypeId = mapDevNameId.get('Annual_And_TCV_Lock');
                                lstOppTobeLocked.add(objContract.Opportunity__c);
                            }else if(setType3Class.contains(objContract.Type_Of_Cancellation__c)){
                                objContract.RecordTypeId = mapDevNameId.get('Tax_Cancel');
                                objContract.Tax_Reviewer__c = strTaxUsrName;
                                flag=true;
                            }
                        }*/
                        //If No 
                        //if(objContract.Tax_Review_Ok__c!= oldMap.get(objContract.Id).Tax_Review_Ok__c && objContract.Tax_Review_Ok__c== 'No'){
                            //objContract.RecordTypeId = mapDevNameId.get('Contract_Review_Cancel');
                            //objContract.Canx_Contract_Review_Ok__c = 'Re-Review';
                        //}
                        //If No 
                        
                    }
                    if(!mapSuperUserCanc.keyset().contains(UserInfo.getUserId()) && !flag && !mapTaxUsrNameId.keyset().contains(UserInfo.getUserId())  && (objContract.Tax_Reviewer__c != oldMap.get(objContract.Id).Tax_Reviewer__c || objContract.Tax_Reviewer_Comments__c !=oldMap.get(objContract.Id).Tax_Reviewer_Comments__c || objContract.Tax_Reviewer_Rejection_Reason__c != oldMap.get(objContract.Id).Tax_Reviewer_Rejection_Reason__c ||  objContract.Tax_Review_Ok__c != oldMap.get(objContract.Id).Tax_Review_Ok__c ) ){
                        objContract.addError('You are not allowed to edit this record');
                    }else{
                        if(objContract.Tax_Review_Ok__c!= oldMap.get(objContract.Id).Tax_Review_Ok__c && objContract.Tax_Review_Ok__c== 'Yes'){
                            objContract.RecordTypeId = mapDevNameId.get('Annual_And_TCV_Lock');
                        }
                        //If No 
                        if(objContract.Tax_Review_Ok__c!= oldMap.get(objContract.Id).Tax_Review_Ok__c && objContract.Tax_Review_Ok__c== 'No'){
                            objContract.RecordTypeId = mapDevNameId.get('Contract_Review_Cancel');
                            objContract.Canx_Contract_Review_Ok__c = 'Re-Review';
                        }
                        //If No 
                    }
                }else if(objContract.Opportunity_Stage__c == 'Tract'){
                    flag=false;
                    if(!mapSuperUserCanc.keyset().contains(UserInfo.getUserId()) && mapUserNameId.get(objContract.Canx_Accounting_Team_Level_1_Reviewer__c ) != UserInfo.getUserId() && (objContract.Canx_Accounting_Team_Level_1_Reviewer__c != oldMap.get(objContract.Id).Canx_Accounting_Team_Level_1_Reviewer__c || objContract.Canx_Accounting_Team_Level_1_Review_Ok__c !=oldMap.get(objContract.Id).Canx_Accounting_Team_Level_1_Review_Ok__c) ){
                        objContract.addError('You are not allowed to edit this record');
                    }else{
                        if(objContract.Canx_Accounting_Team_Level_1_Review_Ok__c != oldMap.get(objContract.Id).Canx_Accounting_Team_Level_1_Review_Ok__c && objContract.Canx_Accounting_Team_Level_1_Review_Ok__c=='Yes'){
                            objContract.Canx_Accounting_Team_Level_2_Reviewer__c = mapAccLev2ProdUsrName.get(objContract.Product_Category_Tract__c);
                            objContract.RecordTypeId = mapDevNameId.get('Acc_Level_2_Cancel');
                            
                            if((oldMap.get(objContract.Id).Canx_Accounting_Team_Level_1_Review_Ok__c == 'Re-Review' ||oldMap.get(objContract.Id).Canx_Accounting_Team_Level_1_Review_Ok__c == 'Error Correct')&& objContract.Canx_Accounting_Team_Level_1_Review_Ok__c == 'Yes' && objContract.Canx_Accounting_Team_Level_2_Review_OK__c=='No')
                                objContract.Canx_Accounting_Team_Level_2_Review_OK__c = 'Error Correct';
                        }
                        
                        if(objContract.Canx_Accounting_Team_Level_1_Reviewer__c != oldMap.get(objContract.Id).Canx_Accounting_Team_Level_1_Reviewer__c || objContract.Canx_Accounting_Team_Level_1_Review_Ok__c !=oldMap.get(objContract.Id).Canx_Accounting_Team_Level_1_Review_Ok__c){
                            flag=true;
                        }
                        //else if(objContract.Canx_Accounting_Team_Level_1_Review_Ok__c != oldMap.get(objContract.Id).Canx_Accounting_Team_Level_1_Review_Ok__c && objContract.Canx_Accounting_Team_Level_1_Review_Ok__c=='Error Correct'){
                            //objContract.Canx_Accounting_Team_Level_2_Reviewer__c = mapAccLev2ProdUsrName.get(objContract.Product_Category_Tract__c);
                            //objContract.RecordTypeId = mapDevNameId.get('Acc_Level_2_Cancel');
                            //flag=true;
                        //}
                        //If No 
                        if(objContract.Canx_Accounting_Team_Level_1_Review_Ok__c != oldMap.get(objContract.Id).Canx_Accounting_Team_Level_1_Review_Ok__c && objContract.Canx_Accounting_Team_Level_1_Review_Ok__c =='No'){
                            objContract.RecordTypeId = mapDevNameId.get('Annual_And_TCV_Lock');
                            //lstOfCntNumOppsTBR.add(objContract.Opportunity_Contract__c);
                        }
                        //If No 
                    }
                    if(!mapSuperUserCanc.keyset().contains(UserInfo.getUserId()) && !flag && mapUserNameId.get(objContract.Canx_Accounting_Team_Level_2_Reviewer__c ) != UserInfo.getUserId() && (objContract.Canx_Accounting_Team_Level_2_Reviewer__c != oldMap.get(objContract.Id).Canx_Accounting_Team_Level_2_Reviewer__c || objContract.Canx_Accounting_Team_Level_2_Review_OK__c !=oldMap.get(objContract.Id).Canx_Accounting_Team_Level_2_Review_OK__c) ){
                        objContract.addError('You are not allowed to edit this record');
                    }else{
                        if(objContract.Canx_Accounting_Team_Level_2_Review_OK__c != oldMap.get(objContract.Id).Canx_Accounting_Team_Level_2_Review_OK__c && objContract.Canx_Accounting_Team_Level_2_Review_OK__c=='Yes'){
                            objContract.RecordTypeId = mapDevNameId.get('Annual_And_TCV_Lock');
                        }
                        //If No 
                        if(objContract.Canx_Accounting_Team_Level_2_Review_OK__c != oldMap.get(objContract.Id).Canx_Accounting_Team_Level_2_Review_OK__c && objContract.Canx_Accounting_Team_Level_2_Review_OK__c=='No'){
                            objContract.RecordTypeId = mapDevNameId.get('Acc_Level_1_Cancel');
                            objContract.Canx_Accounting_Team_Level_1_Review_Ok__c = 'Re-Review';
                        }
                        //If No 
                    }
                }
            }  
            //Cancellation Review Process. 
        }
        //Cancellation Review Process. 
        /*
        List<Opportunity> lstContrRev = new List<Opportunity>();
        if(lstConTNumFindTCVs.size()>0)
        lstContrRev = [SELECT Id,(SELECT ID,Product_Category_Tract__c FROM Contract_Reviews__r) FROM Opportunity WHERE Contract_Number_New__c =:lstConTNumFindTCVs AND StageName ='Tract'];
        
        List<Contract_Reviewing__c> lstOppTCVCntRev = new List<Contract_Reviewing__c>();
        for(Opportunity instOfOpp : lstContrRev){
            for(Contract_Reviewing__c instOfContrRev : instOfOpp.Contract_Reviews__r){
                instOfContrRev.RecordTypeId = mapDevNameId.get('Acc_Level_1_Cancel');
                instOfContrRev.Canx_Accounting_Team_Level_1_Reviewer__c = mapAccLev1ProdUsrName.get(instOfContrRev.Product_Category_Tract__c);
                lstOppTCVCntRev.add(instOfContrRev);
            }
        }
        if(lstOppTCVCntRev.size()>0)
        update lstOppTCVCntRev;*/
        /*
        List<Opportunity> lstOppToBeReOpen = new List<Opportunity>();
        if(lstOfCntNumOppsTBR.size()>0)
        lstOppToBeReOpen = [SELECT Id,__c,(SELECT ID,RecordTypeId FROM Contract_Reviews__r) FROM Opportunity WHERE Contract_Number_New__c=:lstOfCntNumOppsTBR AND StageName !='Tract'];
        
        List<Opportunity> lstOfOppOpenUpd = new List<Opportunity>();
        List<Contract_Reviewing__c> lstOfConRevUpd = new List<Contract_Reviewing__c>();
        
        for(Opportunity instOpp : lstOppToBeReOpen){
            instOpp.__c = false;
            for(Contract_Reviewing__c instOfCntRev: instOpp.Contract_Reviews__r){
                instOfCntRev.RecordTypeId = mapDevNameId.get('Contract_Review_Cancel');
                instOfCntRev.Canx_Contract_Review_Ok__c = 'Re-Review';
                lstOfConRevUpd.add(instOfCntRev);
            }
            lstOfOppOpenUpd.add(instOpp);
        }
         
        
        if(lstOfOppOpenUpd.size()>0){
            update lstOfOppOpenUpd;
        }
        if(lstOfConRevUpd.size()>0){
            update lstOfConRevUpd;
        }*/
        //Cancellation Review Process.
        List<Contract_Reviewing__c> listTobeupdatecontract=new  List<Contract_Reviewing__c>();
        for(Contract_Reviewing__c objCReviw:[select Contract_Review_Ok__c from Contract_Reviewing__c where Opportunity_Contract__c in:setContractNumber and id not in :setIds]){
             objCReviw.Contract_Review_Ok__c='Re-Review';
             objCReviw.recordtypeID=mapNameVsRTId.get('Contract_Review_level_0');
             listTobeupdatecontract.add(objCReviw);
        
        }
        
        if(listTobeupdatecontract.size()>0)
        update listTobeupdatecontract;
       /* List<Opportunity> listToBeupdate=new List<Opportunity>();
        for(Opportunity objOpp:[Select __C from opportunity where recordtype.name!='Tract' and __C =true and Contract_Number_New__c in :setContractNumber]){
                 objOpp.isLocked__C =false;
                 listToBeupdate.add(objOpp);
        } 
         if(listToBeupdate.size()>0){
             update listToBeupdate;
         }*/
        return mapIdContract;
    }   
    Public static Map<Id,Contract_Reviewing__c> updateTractContract(List<Contract_Reviewing__c> listContractReview,Map<Id,Contract_Reviewing__c> newMap,Map<Id,Contract_Reviewing__c> oldMap){
        
        Set<String> setSuperUser=new Set<String>();
        Set<String> setAuthoriseUser =new set<String>();
        Set<String> setContractNumber=new Set<String>();
       
        Set<String> setContractNumberoppty=new Set<String>();
        Set<Id> setopptyId=new Set<Id>();//P-004264 : Set for those Opportunities whose Contratc Review is marked as NO
        List<Contract_Reviewing__c> listcontractUpdate =new List<Contract_Reviewing__c>();
        Map<Id,Contract_Reviewing__c> mapIdContract=new Map<Id,Contract_Reviewing__c>();
        Map<Id,Contract_Reviewing__c> mapOppIdContract=new Map<Id,Contract_Reviewing__c>();
        
        Map<String,Boolean> mapContractNoVsisError=new Map<String,Boolean>();
        
        setAuthoriseUser.add(UserInfo.getName());
        Map<String,Superuser__c> mapSuperUser=Superuser__c.getAll();
        //Set<String> setAuthoriseUser=new Set<String>();
        setAuthoriseUser.add(UserInfo.getName());
        
        //Review Date Changes
        Map<String,Date> mapOppsIdDate = new Map<String,Date>();
        //Review Date Changes
        
        for(Superuser__c superObj:mapSuperUser.values()){
           setSuperUser.add(superObj.SuperUserName__c);
        }
        
         Map<String,Id> mapNameVsRTId=new Map<String,Id>();
        for(RecordType objRecordtype:[select id,developername from recordtype where sobjecttype='Contract_Reviewing__c']){
            mapNameVsRTId.put(objRecordtype.developername,objRecordtype.id);
            
        } 
        
        
        for(Contract_Reviewing__c objcontract:listContractReview){
            
            if(!objContract.Is_Cancellation__c){
               if(!(String.isBlank(objContract.Accounting_Reviewer_Hybrid_Feature__c))){
                       if(!setSuperUser.contains(UserInfo.getName()) && !setAuthoriseUser.contains(objContract.Accounting_Reviewer_Hybrid_Feature__c) && (newMap.get(objContract.id).Accounting_Hybrid_Review_Ok__c !=oldMap.get(objContract.id).Accounting_Hybrid_Review_Ok__c  || newMap.get(objContract.id).Accounting_Reviewer_Hybrid_Feature__c !=oldMap.get(objContract.id).Accounting_Reviewer_Hybrid_Feature__c ) && !(oldMap.get(objContract.id).Accounting_Hybrid_Review_Ok__c=='No' && newMap.get(objContract.id).Accounting_Hybrid_Review_Ok__c=='Error Correct')){
                           
                           objContract.addError('You are not allowed to edit');
                           
                        }else if(objContract.Accounting_Hybrid_Review_Ok__c=='Yes'){
                                 mapOppIdContract.put(objContract.opportunity__c,objContract);
                                //updateHybridContractReview(mapOppIdContract);
                           
                        }else if(objContract.Accounting_Hybrid_Review_Ok__c=='No'){
                                setopptyId.add(objContract.Opportunity__c);//P-004264
                                setContractNumberoppty.add(objContract.Opportunity_Contract__c);
                                mapIdContract.put(objContract.Id,objcontract);
                        }
                        List<Opportunity> listOppty=new List<Opportunity>();
      
                            /*P-004264:Commented for this project and added new enhancement below
                            for(Opportunity oppty:[Select isLocked__C  from Opportunity where Contract_Number_New__c in :setContractNumberoppty and recordType.developername!='Tract']){
                                    oppty.isLocked__C=false;
                                    oppty.Contract_Implemented__c=false;
                                    listOppty.add(oppty);
                               
                            }*/
                            if(setopptyId.size()>0)
                            {
                                for(Opportunity oppty:[Select isLocked__C,Contract_Implemented__c  from Opportunity where Id in :setopptyId and recordType.developername!='Tract']){
                                    oppty.isLocked__C=false;
                                    oppty.Contract_Implemented__c=false;
                                    listOppty.add(oppty);
                               
                                }
                                if(listOppty.size()>0)
                                    update listOppty;
                            }
                }//else if((String.isBlank(objContract.Accounting_Reviewer_Hybrid_Feature__c)) || objContract.Accounting_Hybrid_Review_Ok__c=='Yes'){
                
                if(!setSuperUser.contains(UserInfo.getName()) && !setAuthoriseUser.contains(objContract.Contract_Reviewer__c) && (newMap.get(objContract.id).Contract_Review_Ok__c !=oldMap.get(objContract.id).Contract_Review_Ok__c  || newMap.get(objContract.id).Contract_Reviewer__c !=oldMap.get(objContract.id).Contract_Reviewer__c || newMap.get(objContract.id).CR_Comments__c !=oldMap.get(objContract.id).CR_Comments__c) && objContract.Contract_Review_Ok__c!='Re-Review'){
                   
                   objContract.addError('You are not allowed to edit');
                   
                }else if((oldMap.get(objContract.id).Contract_Review_Ok__c=='Error in other opp' || oldMap.get(objContract.id).Contract_Review_Ok__c=='Re-Review' || oldMap.get(objContract.id).Contract_Review_Ok__c=='Error Correct')&& objContract.Contract_Review_Ok__c=='Yes') {
                    
                        setContractNumber.add(objContract.Opportunity_Contract__c);
                        
                }else if(oldMap.get(objContract.id).Contract_Review_Ok__c!=newMap.get(objContract.id).Contract_Review_Ok__c && objContract.Contract_Review_Ok__c=='No'){
                         objContract.Implementation_Review_ok__c='Re-Review';
                          
                }
                
                // Below code add by kumud[29 April 2016] to remove all contract from the review team when contract review equal "Error in other opp"
                else if(oldMap.get(objContract.id).Contract_Review_Ok__c!=newMap.get(objContract.id).Contract_Review_Ok__c && objContract.Contract_Review_Ok__c=='Error in other opp' ){
                    
                        objContract.Implementation_Review_ok__c='Re-Review';
                        objContract.Is_Error_in_Other_Opp__c=true;
                        setContractNumber.add(objContract.Opportunity_Contract__c);
                        mapContractNoVsisError.put(objContract.Opportunity_Contract__c,true);
                }  
                system.debug('Contract review debug if else'+objContract.Contract_Review_Ok__c);
               /* if(oldMap.get(objContract.id).Contract_Review_Ok__c!=newMap.get(objContract.id).Contract_Review_Ok__c && objContract.Contract_Review_Ok__c!='Error in other opp' && oldMap.get(objContract.id).Is_Error_in_Other_Opp__c){
                    
                       objContract.Is_Error_in_Other_Opp__c=false;
                       setContractNumber.add(objContract.Opportunity_Contract__c);
                       mapContractNoVsisError.put(objContract.Opportunity_Contract__c,false);
                }*/
                
                
                if(oldMap.get(objContract.id).Contract_Review_Ok__c != objContract.Contract_Review_Ok__c && objContract.Contract_Review_Ok__c == 'Yes' ){
                    //Review Date Changes
                    //if(objContract.Contract_Review_Ok__c == 'Yes'){
                        if(objContract.Contract_Review_Date__c == null)
                        objContract.Contract_Review_Date__c = system.today();
                        objContract.Final_Review_Date__c = system.today();
                        
                        mapOppsIdDate.put(objContract.Opportunity__c,objContract.Final_Review_Date__c);
                    //}
                    //Review Date Changes
                }
                if (oldMap.get(objContract.id).Contract_Review_Ok__c != objContract.Contract_Review_Ok__c && objContract.Contract_Review_Ok__c == 'No' ){
                    //Review Date Changes
                     //if(objContract.Contract_Review_Ok__c == 'No'){
                        if(objContract.Contract_Review_Date__c == null)
                            objContract.Contract_Review_Date__c = system.today();
                     //}
                     //Review Date Changes
                }
                
                if(oldMap.get(objContract.id).Implementation_Review_ok__c=='Re-Review' && oldMap.get(objContract.id).Contract_Review_Ok__c!='Error in other opp'){
                
                     objContract.Contract_Review_Ok__c='Error Correct';
                }else if(oldMap.get(objContract.id).Implementation_Review_ok__c=='Re-Review' && oldMap.get(objContract.id).Contract_Review_Ok__c=='Error in other opp' && newMap.get(objContract.id).Implementation_Review_ok__c=='Yes'){
                     objContract.Contract_Review_Ok__c='Error Rectify';
                }
                if(oldMap.get(objContract.id).Implementation_Review_ok__c=='Re-Review' && newMap.get(objContract.id).Implementation_Review_ok__c=='Yes' && oldMap.get(objContract.id).Is_Error_in_Other_Opp__c){
                    
                        objContract.Is_Error_in_Other_Opp__c=false;
                        setContractNumber.add(objContract.Opportunity_Contract__c);
                        mapContractNoVsisError.put(objContract.Opportunity_Contract__c,false);
                    
                }
            
                mapIdContract.put(objContract.Id,objcontract);
                if(objcontract.Contract_Review_Ok__c=='No'){
                setContractNumberoppty.add(objContract.Opportunity_Contract__c);
                setopptyId.add(objContract.Opportunity__c);//P-004264
                }
            

                      
                //}
      
            }
            //Cancellation Review Process.
            
            //Cancellation Review Process.
        }
        
        List<Opportunity> listOfOppty=new List<Opportunity>();
        /*if(setContractNumberoppty.size()>0){
            for(Opportunity oppty:[Select isLocked__C  from Opportunity where Contract_Number_New__c in :setContractNumberoppty and recordType.developername!='Tract']){
                    oppty.isLocked__C=false;
                    oppty.Contract_Implemented__c=false;
                    listOfOppty.add(oppty);
               
            }
        }*/
        if(setopptyId.size()>0)
        {
            for(Opportunity oppty:[Select isLocked__C,Contract_Implemented__c  from Opportunity where Id in :setopptyId and recordType.developername!='Tract']){
                oppty.isLocked__C=false;
                oppty.Contract_Implemented__c=false;
                listOfOppty.add(oppty);
           
            }
        }
        if(listOfOppty.size()>0)
                update listOfOppty;
                                
        if(setContractNumber.size()>0){
            //Change code here add conditions [by kumud ]
            for(Contract_Reviewing__c objCReviw:[select Opportunity_Contract__c,Accounting_Review_Ok__c,opportunity__r.recordType.developername,Contract_Review_Ok__c from Contract_Reviewing__c where (Opportunity_Contract__c in:setContractNumber) and id not in :oldMap.keySet()]){
                    /*if(objCReviw.opportunity__r.recordType.developername=='Tract') // no rec type  named Tract on oppo
                    {
                            objCReviw.Accounting_Review_Ok__c='Error Correct';
                            objCReviw.recordtypeID=mapNameVsRTId.get('Account_Team_Level_1');
                            listcontractUpdate.add(objCReviw);
                    }else */
                if(mapContractNoVsisError.containsKey(objCReviw.Opportunity_Contract__c)){
                            objCReviw.Is_Error_in_Other_Opp__c=mapContractNoVsisError.get(objCReviw.Opportunity_Contract__c);
                            listcontractUpdate.add(objCReviw);
                    }
                    
                    
                     
            }
        }   
        if(listcontractUpdate.size()>0){
             update listcontractUpdate;
        }
        
        //Review Date Changes
        List<Opportunity> lstOpps = new List<Opportunity>();
        if(mapOppsIdDate.KeySet().size() > 0)
        lstOpps = [SELECT ID,(SELECT Id FROM Invoicing_Details__r) FROM Opportunity WHERE Id =: mapOppsIdDate.KeySet()];
        
        map<String,String> mapOppIdInvDetId = new map<String,String>();
        
        for(Opportunity instOpp : lstOpps){
            for(Invoicing_Details__c instOfInvDet : instOpp.Invoicing_Details__r){
                mapOppIdInvDetId.put(instOfInvDet.Id,instOpp.Id);      
            }
        }
       
        List<Invoicing_Details__c> lstInvDets = new List<Invoicing_Details__c>();
        if(mapOppIdInvDetId.KeySet().size()>0)
        lstInvDets = [SELECT Id,(SELECT Id,Billing_Date__c FROM Invoicing_Line_Items__r) FROM Invoicing_Details__c WHERE Id=:mapOppIdInvDetId.KeySet()];
        
        List<Invoicing_Line_Items__c> lstInvLineItem = new List<Invoicing_Line_Items__c>();
        for(Invoicing_Details__c instOfInvDet : lstInvDets){
            for(Invoicing_Line_Items__c instOfLinItem : instOfInvDet.Invoicing_Line_Items__r){
                if(instOfLinItem.Billing_Date__c < mapOppsIdDate.get(mapOppIdInvDetId.get(instOfInvDet.Id))){
                    instOfLinItem.Billing_Date__c = mapOppsIdDate.get(mapOppIdInvDetId.get(instOfInvDet.Id)); 
                    lstInvLineItem.add(instOfLinItem);
                }
            }
        }
        
        if(lstInvLineItem.size()>0)
        update lstInvLineItem;
        //Review Date Changes
        
         if(mapOppIdContract.size()>0){
            List<Opportunity> listOppty=[select Contract_Number_New__c from opportunity where id in :mapOppIdContract.keySet()] ;
             mapIdContract=updateHybridContractReview(listOppty,mapOppIdContract);
             
         }
    return  mapIdContract;
    }
    
    public void OnAfterUpdate(Map<Id,Contract_Reviewing__c> oldMapValues,Map<Id,Contract_Reviewing__c> newMapValues){
        
        //Cancellation Review Process.
        Set<String> setStatusErrorC = new Set<String>();
        List<String> lstConTNumFindTCVs = new List<String>();
        List<String> lstOfCntNumOppsTBR = new List<String>();
        List<String> lstOfCntNumOppsNHydWOSCanx = new List<String>();
        List<String> lstOfCntNumOppsNHydWOSTy2 = new List<String>();
        List<String> lstOfCntNumOppsNHydWOS = new List<String>();
        List<String> lstOfCntNumOppsHydWOS = new List<String>();
        List<String> lstOfCntNumOppsHydWosCntRevDoneTy1 = new List<String>();
        List<String> lstOfCntNumOppsHydWosCntRevDoneTy2 = new List<String>();
        List<String> lstOfCntNumOppsHydWosCntRevDoneTy3 = new List<String>();
        List<String> lstOfTaxHydWosCntTy3 = new List<String>();
        List<String> lstOfAccLev1WosCnt = new List<String>();
        List<String> lstOfAccLev2WosCnt = new List<String>();
        List<String> lstOppTobeLocked = new List<String>();
        Set<Id> lstOppMoveToTract = new Set<Id>();
        map<String,String> mapCntNum = new map<String,String>();
        
        //For setting status on respective Write-Off form
        List<String> lstOfCntNumOppsNHydWOSCanxName = new List<String>();
        List<String> lstOfCntNumOppsNHydWOSTy2Name = new List<String>();
        List<String> lstOfCntNumOppsNHydWOSName = new List<String>();
        List<String> lstOfCntNumOppsHydWOSName = new List<String>();
        List<String> lstOfCntNumOppsHydWosCntRevDoneTy1Name = new List<String>();
        List<String> lstOfCntNumOppsHydWosCntRevDoneTy2Name = new List<String>();
        List<String> lstOfCntNumOppsHydWosCntRevDoneTy3Name = new List<String>();
        List<String> lstOfTaxHydWosCntTy3Name = new List<String>();
        List<String> lstOfAccLev1WosCntName = new List<String>();
        List<String> lstOfAccLev2WosCntName = new List<String>();
        
        //For setting status on respective Write-Off form
        
        //For No
        
        List<String> lstOfCntNumOppsNHydWOSTy2NameNo = new List<String>();
        List<String> lstOfCntNumOppsNHydWOSNameNo = new List<String>();
        List<String> lstOfCntNumOppsHydWOSNameNo = new List<String>();
        List<String> lstOfCntNumOppsHydWosCntRevDoneTy1NameNo = new List<String>();
        List<String> lstOfCntNumOppsHydWosCntRevDoneTy2NameNo = new List<String>();
        List<String> lstOfCntNumOppsHydWosCntRevDoneTy3NameNo = new List<String>();
        List<String> lstOfTaxHydWosCntTy3NameNo = new List<String>();
        List<String> lstOfAccLev1WosCntNameNo = new List<String>();
        List<String> lstOfAccLev2WosCntNameNo = new List<String>();
        List<String> lstOfCntNumOppsTBRNoName = new List<String>();
        //For No
        
        //For No
        List<String> lstOfCntNumOppsTBRNo = new List<String>();
        List<String> lstOfCntNumOppsNHydWOSTy2No = new List<String>();
        List<String> lstOfCntNumOppsNHydWOSNo = new List<String>();
        List<String> lstOfCntNumOppsHydWOSNo = new List<String>();
        List<String> lstOfCntNumOppsHydWosCntRevDoneTy1No = new List<String>();
        List<String> lstOfCntNumOppsHydWosCntRevDoneTy2No = new List<String>();
        List<String> lstOfCntNumOppsHydWosCntRevDoneTy3No = new List<String>();
        List<String> lstOfTaxHydWosCntTy3No = new List<String>();
        List<String> lstOfAccLev1WosCntNo = new List<String>();
        List<String> lstOfAccLev2WosCntNo = new List<String>();
        //For No
        
        //Review Date Changes
        Map<String,Date> mapOppsIdDate = new Map<String,Date>();
        //Review Date Changes
        //Boolean checkRecursion=false;
        
        //system.debug('checkRecursion++'+checkRecursion);
        if(CheckRecursive.runFortyNine() && ExecuteMethodHelper.isActive('SendAlertToRFPBuilder'))
        	sendAlertToRFPBuilder(oldMapValues,newMapValues);
        system.debug('newMapValues.values()'+newMapValues.values());
        for(Contract_Reviewing__c objContract : newMapValues.values()){
            //checkRecursion = CheckRecursiveCancellaltion.runOnce();
            //system.debug('checkRecursion++'+checkRecursion);
            //if(Test.isRunningTest())
            //checkRecursion = true;
            
            //if(checkRecursion){
                if(objContract.Is_Cancellation__c == true || objContract.Opportunity_Stage__c == 'Tract'){
                    if(objContract.Is_Hybrid__c == true && objContract.Opportunity_Stage__c != 'Tract'){
                        
                        //For Yes
                        
                        if(objContract.Canx_Team_OK__c!= oldMapValues.get(objContract.Id).Canx_Team_OK__c && objContract.Canx_Team_OK__c == 'Yes' && oldMapValues.get(objContract.Id).Canx_Team_OK__c == 'Re-Review'){
                            lstOfCntNumOppsNHydWOSCanx.add(objContract.Opportunity_Contract__c);
                            lstOfCntNumOppsNHydWOSCanxName.add(objContract.Write_Off_Associated__c);
                        }
                        if(objContract.Canx_Accounting_Hybrid_Review_Ok__c != oldMapValues.get(objContract.Id).Canx_Accounting_Hybrid_Review_Ok__c && (objContract.Canx_Accounting_Hybrid_Review_Ok__c == 'Yes')){
                            if(setType1Class.contains(objContract.Type_Of_Cancellation__c)){   
                                lstOfCntNumOppsHydWOS.add(objContract.Opportunity_Contract__c);
                                lstOfCntNumOppsHydWOSName.add(objContract.Write_Off_Associated__c);
                                //lstOppMoveToTract.add(objContract.Opportunity__c);
                            }else if(setType2Class.contains(objContract.Type_Of_Cancellation__c)){
                                lstOfCntNumOppsHydWOS.add(objContract.Opportunity_Contract__c);  
                                lstOfCntNumOppsHydWOSName.add(objContract.Write_Off_Associated__c);                   
                            }else if(setType3Class.contains(objContract.Type_Of_Cancellation__c)){
                                lstOfCntNumOppsHydWOS.add(objContract.Opportunity_Contract__c);
                                lstOfCntNumOppsHydWOSName.add(objContract.Write_Off_Associated__c);
                            }
                        }                
                        system.debug(objContract.Canx_Contract_Review_Ok__c);
                        system.debug(oldMapValues.get(objContract.Id).Canx_Contract_Review_Ok__c);
                        system.debug(setType2Class);
                        system.debug(lstOppTobeLocked);
                        system.debug(setType1Class);
                        system.debug('objContract.Opportunity_Contract__c'+objContract.Opportunity_Contract__c);
                        if(objContract.Canx_Contract_Review_Ok__c != oldMapValues.get(objContract.Id).Canx_Contract_Review_Ok__c && (objContract.Canx_Contract_Review_Ok__c == 'Yes')){
                            if(setType1Class.contains(objContract.Type_Of_Cancellation__c)){
                                lstConTNumFindTCVs.add(objContract.Opportunity_Contract__c);
                                system.debug('objContract.Opportunity_Contract__c'+objContract.Opportunity_Contract__c);
                                
                                if(objContract.Canx_Contract_Review_Ok__c == 'Yes' && (oldMapValues.get(objContract.Id).Canx_Contract_Review_Ok__c == 'Re-Review' || oldMapValues.get(objContract.Id).Canx_Contract_Review_Ok__c == 'Error Correct'))
                                setStatusErrorC.add(objContract.Opportunity_Contract__c);
                                
                                lstOfCntNumOppsHydWosCntRevDoneTy1.add(objContract.Opportunity_Contract__c);
                                lstOfCntNumOppsHydWosCntRevDoneTy1Name.add(objContract.Write_Off_Associated__c);
                                lstOppTobeLocked.add(objContract.Opportunity__c);
                                system.debug('objContract.Reviewed_By__c++'+objContract.Reviewed_By__c);
                                if(objContract.Reviewed_By__c != '' && objContract.Reviewed_By__c!= null)
                                mapCntNum.put(objContract.Opportunity_Contract__c,objContract.Reviewed_By__c );
                                else
                                mapCntNum.put(objContract.Opportunity_Contract__c,'Reviewed1');
                                
                                system.debug('mapCntNum++'+mapCntNum);
                                if(objContract.Canx_Contract_Review_Ok__c == 'Yes' )//&& (objContract.Order_Number__c == '' || objContract.Order_Number__c == null))
                                lstOppMoveToTract.add(objContract.Opportunity__c);//Movement
                            }else if(setType2Class.contains(objContract.Type_Of_Cancellation__c)){
                                lstOfCntNumOppsHydWosCntRevDoneTy2.add(objContract.Opportunity_Contract__c);
                                lstOfCntNumOppsHydWosCntRevDoneTy2Name.add(objContract.Write_Off_Associated__c);
                                lstOppTobeLocked.add(objContract.Opportunity__c);
                                if(objContract.Canx_Contract_Review_Ok__c == 'Yes')// && (objContract.Order_Number__c == '' || objContract.Order_Number__c == null))
                                lstOppMoveToTract.add(objContract.Opportunity__c);//Movement
                                
                                if(objContract.Reviewed_By__c != '' && objContract.Reviewed_By__c!= null)
                                mapCntNum.put(objContract.Opportunity_Contract__c,objContract.Reviewed_By__c );
                                else
                                mapCntNum.put(objContract.Opportunity_Contract__c,'Reviewed1');
                                
                            }else if(setType3Class.contains(objContract.Type_Of_Cancellation__c)){
                                lstOfCntNumOppsHydWosCntRevDoneTy3.add(objContract.Opportunity_Contract__c);
                                lstOfCntNumOppsHydWosCntRevDoneTy3Name.add(objContract.Write_Off_Associated__c);
                                if(objContract.Canx_Contract_Review_Ok__c == 'Yes')// && (objContract.Order_Number__c == '' || objContract.Order_Number__c == null))
                                lstOppMoveToTract.add(objContract.Opportunity__c);//Movement
                                
                                if(objContract.Reviewed_By__c != '' && objContract.Reviewed_By__c!= null)
                                mapCntNum.put(objContract.Opportunity_Contract__c,objContract.Reviewed_By__c );
                                else
                                mapCntNum.put(objContract.Opportunity_Contract__c,'Reviewed1');
                            }
                        }
                        system.debug('lstConTNumFindTCVs:::+++'+lstConTNumFindTCVs);
                        
                        if(objContract.Tax_Review_Ok__c!= oldMapValues.get(objContract.Id).Tax_Review_Ok__c && objContract.Tax_Review_Ok__c== 'Yes'){
                            lstOfTaxHydWosCntTy3.add(objContract.Opportunity_Contract__c);
                            lstOfTaxHydWosCntTy3Name.add(objContract.Write_Off_Associated__c);
                            lstOppTobeLocked.add(objContract.Opportunity__c);
                        }
                        //For Yes
                        
                        //For No
                        if(objContract.Canx_Accounting_Hybrid_Review_Ok__c != oldMapValues.get(objContract.Id).Canx_Accounting_Hybrid_Review_Ok__c && (objContract.Canx_Accounting_Hybrid_Review_Ok__c == 'No')){
                            if(setType1Class.contains(objContract.Type_Of_Cancellation__c)){   
                                lstOfCntNumOppsHydWOSNo.add(objContract.Opportunity_Contract__c);
                                lstOfCntNumOppsHydWOSNameNo.add(objContract.Write_Off_Associated__c);
                                //lstOppMoveToTract.add(objContract.Opportunity__c);
                            }else if(setType2Class.contains(objContract.Type_Of_Cancellation__c)){
                                lstOfCntNumOppsHydWOSNo.add(objContract.Opportunity_Contract__c);  
                                lstOfCntNumOppsHydWOSNameNo.add(objContract.Write_Off_Associated__c);                   
                            }else if(setType3Class.contains(objContract.Type_Of_Cancellation__c)){
                                lstOfCntNumOppsHydWOSNo.add(objContract.Opportunity_Contract__c);
                                lstOfCntNumOppsHydWOSNameNo.add(objContract.Write_Off_Associated__c);
                            }
                        }                
                        system.debug(objContract.Canx_Contract_Review_Ok__c);
                        system.debug(oldMapValues.get(objContract.Id).Canx_Contract_Review_Ok__c);
                        system.debug(setType2Class);
                        system.debug(lstOppTobeLocked);
                        system.debug(setType1Class);
                        if(objContract.Canx_Contract_Review_Ok__c != oldMapValues.get(objContract.Id).Canx_Contract_Review_Ok__c && (objContract.Canx_Contract_Review_Ok__c == 'No')){
                            if(setType1Class.contains(objContract.Type_Of_Cancellation__c)){
                                //lstConTNumFindTCVs.add(objContract.Opportunity_Contract__c); 
                                lstOfCntNumOppsHydWosCntRevDoneTy1No.add(objContract.Opportunity_Contract__c);
                                lstOfCntNumOppsHydWosCntRevDoneTy1NameNo.add(objContract.Write_Off_Associated__c);
                                //lstOppTobeLocked.add(objContract.Opportunity__c);
                                //if(objContract.Canx_Contract_Review_Ok__c == 'Yes' && objContract.Order_Number__c == '')
                                //lstOppMoveToTract.add(objContract.Opportunity__c);//Movement
                            }else if(setType2Class.contains(objContract.Type_Of_Cancellation__c)){
                                lstOfCntNumOppsHydWosCntRevDoneTy2No.add(objContract.Opportunity_Contract__c);
                                lstOfCntNumOppsHydWosCntRevDoneTy2NameNo.add(objContract.Write_Off_Associated__c);
                                //lstOppTobeLocked.add(objContract.Opportunity__c);
                                //if(objContract.Canx_Contract_Review_Ok__c == 'Yes' && objContract.Order_Number__c == '')
                                //lstOppMoveToTract.add(objContract.Opportunity__c);//Movement
                            }else if(setType3Class.contains(objContract.Type_Of_Cancellation__c)){
                                lstOfCntNumOppsHydWosCntRevDoneTy3No.add(objContract.Opportunity_Contract__c);
                                lstOfCntNumOppsHydWosCntRevDoneTy3NameNo.add(objContract.Write_Off_Associated__c);
                                //if(objContract.Canx_Contract_Review_Ok__c == 'Yes' && objContract.Order_Number__c == '')
                                //lstOppMoveToTract.add(objContract.Opportunity__c);//Movement
                            }
                        }
                        
                        if(objContract.Tax_Review_Ok__c!= oldMapValues.get(objContract.Id).Tax_Review_Ok__c && objContract.Tax_Review_Ok__c== 'No'){
                            lstOfTaxHydWosCntTy3No.add(objContract.Opportunity_Contract__c);
                            lstOfTaxHydWosCntTy3NameNo.add(objContract.Write_Off_Associated__c);
                            //lstOppTobeLocked.add(objContract.Opportunity__c);
                        }
                        //For No
                        
                        
                    }else if(objContract.Opportunity_Stage__c != 'Tract' && objContract.Is_Hybrid__c == false){
                        //For Yes
                        system.debug('objContract.Canx_Contract_Review_Ok__c++'+objContract.Canx_Contract_Review_Ok__c);
                        system.debug('oldMapValues.get(objContract.Id).Canx_Contract_Review_Ok__c++'+oldMapValues.get(objContract.Id).Canx_Contract_Review_Ok__c);
                        
                        if(objContract.Canx_Team_OK__c!= oldMapValues.get(objContract.Id).Canx_Team_OK__c && objContract.Canx_Team_OK__c == 'Yes' && oldMapValues.get(objContract.Id).Canx_Team_OK__c == 'Re-Review'){
                            lstOfCntNumOppsNHydWOSCanx.add(objContract.Opportunity_Contract__c);
                            lstOfCntNumOppsNHydWOSCanxName.add(objContract.Write_Off_Associated__c);
                        }
                        
                        if(objContract.Canx_Contract_Review_Ok__c != oldMapValues.get(objContract.Id).Canx_Contract_Review_Ok__c && (objContract.Canx_Contract_Review_Ok__c == 'Yes')){
                            if(setType1Class.contains(objContract.Type_Of_Cancellation__c)){
                                lstConTNumFindTCVs.add(objContract.Opportunity_Contract__c);
                                if(objContract.Canx_Contract_Review_Ok__c == 'Yes' && (oldMapValues.get(objContract.Id).Canx_Contract_Review_Ok__c == 'Re-Review' || oldMapValues.get(objContract.Id).Canx_Contract_Review_Ok__c == 'Error Correct'))
                                setStatusErrorC.add(objContract.Opportunity_Contract__c);
                                lstOppTobeLocked.add(objContract.Opportunity__c);
                                
                                if(objContract.Reviewed_By__c != '' && objContract.Reviewed_By__c!= null)
                                mapCntNum.put(objContract.Opportunity_Contract__c,objContract.Reviewed_By__c );
                                else
                                mapCntNum.put(objContract.Opportunity_Contract__c,'Reviewed1');
                                
                                system.debug('objContract.Reviewed_By__c++'+objContract.Reviewed_By__c);
                                system.debug('mapCntNum++'+mapCntNum);
                                
                                lstOfCntNumOppsNHydWOS.add(objContract.Opportunity_Contract__c);  
                                lstOfCntNumOppsNHydWOSName.add(objContract.Write_Off_Associated__c);
                                if(objContract.Canx_Contract_Review_Ok__c == 'Yes')// && (objContract.Order_Number__c == '' || objContract.Order_Number__c == null))
                                lstOppMoveToTract.add(objContract.Opportunity__c);//Movement  
                            }
                            
                            if(setType2Class.contains(objContract.Type_Of_Cancellation__c)){
                                lstOfCntNumOppsNHydWOSTy2.add(objContract.Opportunity_Contract__c);
                                lstOfCntNumOppsNHydWOSTy2Name.add(objContract.Write_Off_Associated__c);
                                lstOppTobeLocked.add(objContract.Opportunity__c);
                                if(objContract.Canx_Contract_Review_Ok__c == 'Yes')// && (objContract.Order_Number__c == '' || objContract.Order_Number__c == null))
                                lstOppMoveToTract.add(objContract.Opportunity__c);//Movement
                                
                                if(objContract.Reviewed_By__c != '' && objContract.Reviewed_By__c!= null)
                                mapCntNum.put(objContract.Opportunity_Contract__c,objContract.Reviewed_By__c );
                                else
                                mapCntNum.put(objContract.Opportunity_Contract__c,'Reviewed1');
                            }
                            if(setType3Class.contains(objContract.Type_Of_Cancellation__c)){
                                if(objContract.Canx_Contract_Review_Ok__c == 'Yes')// && (objContract.Order_Number__c == '' || objContract.Order_Number__c == null))
                                lstOppMoveToTract.add(objContract.Opportunity__c);//Movement
                                
                                if(objContract.Reviewed_By__c != '' && objContract.Reviewed_By__c!= null)
                                mapCntNum.put(objContract.Opportunity_Contract__c,objContract.Reviewed_By__c );
                                else
                                mapCntNum.put(objContract.Opportunity_Contract__c,'Reviewed1');
                            }
                        } 
                        if(objContract.Tax_Review_Ok__c!= oldMapValues.get(objContract.Id).Tax_Review_Ok__c && objContract.Tax_Review_Ok__c== 'Yes'){
                            lstOfTaxHydWosCntTy3.add(objContract.Opportunity_Contract__c);
                            lstOfTaxHydWosCntTy3Name.add(objContract.Write_Off_Associated__c);
                            lstOppTobeLocked.add(objContract.Opportunity__c);
                        }
                        //For Yes
                        
                        //For No
                        if(objContract.Canx_Contract_Review_Ok__c != oldMapValues.get(objContract.Id).Canx_Contract_Review_Ok__c && (objContract.Canx_Contract_Review_Ok__c == 'No')){
                            if(setType1Class.contains(objContract.Type_Of_Cancellation__c)){
                                //lstConTNumFindTCVs.add(objContract.Opportunity_Contract__c);
                                lstOfCntNumOppsNHydWOSNo.add(objContract.Opportunity_Contract__c);  
                                lstOfCntNumOppsNHydWOSNameNo.add(objContract.Write_Off_Associated__c);
                                //if(objContract.Canx_Contract_Review_Ok__c == 'Yes' && objContract.Order_Number__c == '')
                                //lstOppMoveToTract.add(objContract.Opportunity__c);//Movement  
                            }
                            
                            if(setType2Class.contains(objContract.Type_Of_Cancellation__c)){
                                lstOfCntNumOppsNHydWOSTy2No.add(objContract.Opportunity_Contract__c);
                                lstOfCntNumOppsNHydWOSTy2NameNo.add(objContract.Write_Off_Associated__c);
                                //lstOppTobeLocked.add(objContract.Opportunity__c);
                                //if(objContract.Canx_Contract_Review_Ok__c == 'Yes' && objContract.Order_Number__c == '')
                                //lstOppMoveToTract.add(objContract.Opportunity__c);//Movement
                            }
                            if(setType3Class.contains(objContract.Type_Of_Cancellation__c)){
                                //if(objContract.Canx_Contract_Review_Ok__c == 'Yes' && objContract.Order_Number__c == '')
                                //lstOppMoveToTract.add(objContract.Opportunity__c);//Movement
                            }
                        } 
                        if(objContract.Tax_Review_Ok__c!= oldMapValues.get(objContract.Id).Tax_Review_Ok__c && objContract.Tax_Review_Ok__c== 'No'){
                            lstOfTaxHydWosCntTy3No.add(objContract.Opportunity_Contract__c);
                            lstOfTaxHydWosCntTy3NameNo.add(objContract.Write_Off_Associated__c);
                            //lstOppTobeLocked.add(objContract.Opportunity__c);
                        }
                        //For No
                        
                    }else if(objContract.Opportunity_Stage__c == 'Tract'){
                        //If No 
                        if(objContract.Canx_Accounting_Team_Level_1_Review_Ok__c != oldMapValues.get(objContract.Id).Canx_Accounting_Team_Level_1_Review_Ok__c && objContract.Canx_Accounting_Team_Level_1_Review_Ok__c =='No'){
                            lstOfCntNumOppsTBR.add(objContract.Opportunity_Contract__c);
                            lstOfCntNumOppsTBRNo.add(objContract.Opportunity_Contract__c);
                            lstOfCntNumOppsTBRNoName.add(objContract.Write_Off_Associated__c);
                            
                        }
                        //If No 
                        
                        //If Yes 
                        if(objContract.Canx_Accounting_Team_Level_1_Review_Ok__c != oldMapValues.get(objContract.Id).Canx_Accounting_Team_Level_1_Review_Ok__c && (objContract.Canx_Accounting_Team_Level_1_Review_Ok__c=='Yes') ){
                            lstOfAccLev1WosCnt.add(objContract.Opportunity_Contract__c);
                            lstOfAccLev1WosCntName.add(objContract.Write_Off_Associated__c);
                        }
                        if(objContract.Canx_Accounting_Team_Level_2_Review_OK__c != oldMapValues.get(objContract.Id).Canx_Accounting_Team_Level_2_Review_OK__c && objContract.Canx_Accounting_Team_Level_2_Review_OK__c=='Yes'){
                            lstOfAccLev2WosCnt.add(objContract.Opportunity_Contract__c);
                            lstOfAccLev2WosCntName.add(objContract.Write_Off_Associated__c);
                            //lstOppTobeLocked.add(objContract.Opportunity__c);
                        }
                        //If Yes
                        
                        //If No
                        //if(objContract.Canx_Accounting_Team_Level_1_Review_Ok__c != oldMapValues.get(objContract.Id).Canx_Accounting_Team_Level_1_Review_Ok__c && (objContract.Canx_Accounting_Team_Level_1_Review_Ok__c=='No') ){
                            //lstOfAccLev1WosCntNo.add(objContract.Opportunity_Contract__c);
                            //lstOfAccLev1WosCntNameNo.add(objContract.Write_Off_Associated__c);
                        //}
                        if(objContract.Canx_Accounting_Team_Level_2_Review_OK__c != oldMapValues.get(objContract.Id).Canx_Accounting_Team_Level_2_Review_OK__c && objContract.Canx_Accounting_Team_Level_2_Review_OK__c=='No'){
                            lstOfAccLev2WosCntNo.add(objContract.Opportunity_Contract__c);
                            lstOfAccLev2WosCntNameNo.add(objContract.Write_Off_Associated__c);
                            //lstOppTobeLocked.add(objContract.Opportunity__c);
                        }
                        //If No
                    }
                }
            //}
            //Review Date Changes
            //if (oldMapValues.get(objContract.id).Contract_Review_Ok__c != objContract.Contract_Review_Ok__c && objContract.Contract_Review_Ok__c == 'Yes' ){
                //mapOppsIdDate.put(objContract.Opportunity__c,objContract.Final_Review_Date__c);
            //}
            //Review Date Changes
            
        }
        
        
        List<WriteOff__c> lstWrtOffs  = new List<WriteOff__c>();
         
        //For Yes Status on Write-Off Form 
        if(lstOfCntNumOppsNHydWOSCanx.size()>0)
        lstWrtOffs = [SELECT Id FROM WriteOff__c WHERE Contract__c =: lstOfCntNumOppsNHydWOSCanx AND Name=: lstOfCntNumOppsNHydWOSCanxName];
        
        List<WriteOff__c> lstWrtOffsNHydUpdCanx  = new List<WriteOff__c>();
        for(WriteOff__c isntOfWritOff : lstWrtOffs){
            isntOfWritOff.Write_Off_Status__c  = 'Error Corrected By Canx';
            lstWrtOffsNHydUpdCanx.add(isntOfWritOff);
        }
        
        if(lstWrtOffsNHydUpdCanx.size()>0)
        update lstWrtOffsNHydUpdCanx;
        
        //For No Status on Write-Off Form
        lstWrtOffs = new List<WriteOff__c>();
        if(lstOfCntNumOppsNHydWOSNo.size()>0)
        lstWrtOffs = [SELECT Id FROM WriteOff__c WHERE Contract__c =: lstOfCntNumOppsNHydWOSNo AND Name=: lstOfCntNumOppsNHydWOSNameNo];
        
        List<WriteOff__c> lstWrtOffsNHydUpdNo  = new List<WriteOff__c>();
        for(WriteOff__c isntOfWritOff : lstWrtOffs){
            isntOfWritOff.Write_Off_Status__c = 'Error with Canx Team';
            lstWrtOffsNHydUpdNo.add(isntOfWritOff);
        }
        
        if(lstWrtOffsNHydUpdNo.size()>0)
        update lstWrtOffsNHydUpdNo;
        
        lstWrtOffs = new List<WriteOff__c>();
        
        if(lstOfCntNumOppsHydWOSNo.size()>0)
        lstWrtOffs = [SELECT Id FROM WriteOff__c WHERE Contract__c =: lstOfCntNumOppsHydWOSNo AND Name =: lstOfCntNumOppsHydWOSNameNo];   
        
        List<WriteOff__c> lstWrtOffsHydUpdNo  = new List<WriteOff__c>();
        
        for(WriteOff__c instOfWritOff : lstWrtOffs){
            instOfWritOff.Write_Off_Status__c = 'Error with Canx Team';
            lstWrtOffsHydUpdNo.add(instOfWritOff);
        }
        
        if(lstWrtOffsHydUpdNo.size()>0)
        update lstWrtOffsHydUpdNo;
        lstWrtOffs = new List<WriteOff__c>();
        
        if(lstOfCntNumOppsNHydWOSTy2No.size()>0)
        lstWrtOffs = [SELECT Id FROM WriteOff__c WHERE Contract__c =: lstOfCntNumOppsNHydWOSTy2No AND Name =: lstOfCntNumOppsNHydWOSTy2NameNo];
        
        List<WriteOff__c> lstWrtOffsNHydUpdTy2No = new List<WriteOff__c>();
        for(WriteOff__c instOfWritOff : lstWrtOffs){
            instOfWritOff.Write_Off_Status__c = 'Error with Canx Team';
            lstWrtOffsNHydUpdTy2No.add(instOfWritOff);
        }
        
        if(lstWrtOffsNHydUpdTy2No.size()>0)
        update lstWrtOffsNHydUpdTy2No;
        
        
        lstWrtOffs = new List<WriteOff__c>();
        if(lstOfCntNumOppsHydWosCntRevDoneTy1No.size()>0 || lstOfCntNumOppsHydWosCntRevDoneTy3No.size()>0 || lstOfCntNumOppsHydWosCntRevDoneTy2No.size()>0)
        lstWrtOffs = [SELECT Id FROM WriteOff__c WHERE (Contract__c =: lstOfCntNumOppsHydWosCntRevDoneTy1No AND Name =: lstOfCntNumOppsHydWosCntRevDoneTy1NameNo) OR (Contract__c =: lstOfCntNumOppsHydWosCntRevDoneTy3No AND Name =: lstOfCntNumOppsHydWosCntRevDoneTy3NameNo) OR(Contract__c =: lstOfCntNumOppsHydWosCntRevDoneTy2No AND Name =: lstOfCntNumOppsHydWosCntRevDoneTy2NameNo)];
        
        List<WriteOff__c> lstOfCntNumOppsHydWosCntRevDoneTy1n3UPdNo = new List<WriteOff__c>();
        for(WriteOff__c instOfWritOff : lstWrtOffs){
            instOfWritOff.Write_Off_Status__c = 'Error with Canx Team';
            lstOfCntNumOppsHydWosCntRevDoneTy1n3UPdNo.add(instOfWritOff);
        }
        
        if(lstOfCntNumOppsHydWosCntRevDoneTy1n3UPdNo.size()>0)
        update lstOfCntNumOppsHydWosCntRevDoneTy1n3UPdNo;
        
        lstWrtOffs = new List<WriteOff__c>();
        if(lstOfTaxHydWosCntTy3No.size()>0)
        lstWrtOffs = [SELECT Id FROM WriteOff__c WHERE Contract__c =: lstOfTaxHydWosCntTy3No AND Name =: lstOfTaxHydWosCntTy3NameNo];
        
        List<WriteOff__c> lstOfTaxHydWosCntTy3UpdNo = new List<WriteOff__c>();
        for(WriteOff__c instOfWritOff : lstWrtOffs){
            instOfWritOff.Write_Off_Status__c = 'Error with Canx Team';
            lstOfTaxHydWosCntTy3UpdNo.add(instOfWritOff);
        }
        
        if(lstOfTaxHydWosCntTy3UpdNo.size()>0)
        update lstOfTaxHydWosCntTy3UpdNo;
        
        lstWrtOffs = new List<WriteOff__c>();
        if(lstOfAccLev1WosCntNo.size()>0)
        lstWrtOffs = [SELECT Id FROM WriteOff__c WHERE Contract__c =: lstOfAccLev1WosCntNo AND Name =: lstOfAccLev1WosCntNameNo];
        List<WriteOff__c> lstOfAccLev1WosCntUpdNo = new List<WriteOff__c>();
        for(WriteOff__c instOfWritOff : lstWrtOffs){
            instOfWritOff.Write_Off_Status__c = 'Error with Canx Team';
            lstOfAccLev1WosCntUpdNo.add(instOfWritOff);
        }
        if(lstOfAccLev1WosCntUpdNo.size()>0)
        update lstOfAccLev1WosCntUpdNo;
        
        lstWrtOffs = new List<WriteOff__c>();
        if(lstOfAccLev2WosCntNo.size()>0)
        lstWrtOffs = [SELECT Id FROM WriteOff__c WHERE Contract__c =: lstOfAccLev2WosCntNo AND Name=: lstOfAccLev2WosCntNameNo];
        
        List<WriteOff__c> lstOfAccLev2WosCntUpdNo = new List<WriteOff__c>();
        for(WriteOff__c instOfWritOff : lstWrtOffs){
            instOfWritOff.Write_Off_Status__c = 'InProgress – Contract Review Done';
            lstOfAccLev2WosCntUpdNo.add(instOfWritOff);
        }
        
        if(lstOfAccLev2WosCntUpdNo.size()>0)
        update lstOfAccLev2WosCntUpdNo;
        
        lstWrtOffs = new List<WriteOff__c>();
        if(lstOfCntNumOppsTBRNo.size()>0)
        lstWrtOffs = [SELECT Id FROM WriteOff__c WHERE Contract__c =: lstOfCntNumOppsTBRNo AND Name=: lstOfCntNumOppsTBRNoName];
        
        system.debug('lstWrtOffs++'+lstWrtOffs);
        
        List<WriteOff__c> lstOfCntNumOppsTBRUpdNo = new List<WriteOff__c>();
        for(WriteOff__c instOfWritOff: lstWrtOffs){
            instOfWritOff.Write_Off_Status__c = 'Error with review team';
            lstOfCntNumOppsTBRUpdNo.add(instOfWritOff);
        }
        //system.debug("lstOfCntNumOppsTBRUpdNo++"+lstOfCntNumOppsTBRUpdNo);
        if(lstOfCntNumOppsTBRUpdNo.size()>0)
        update lstOfCntNumOppsTBRUpdNo;
        
        //For No Status on Write-Off Form
        
        //Opps to be locked
        List<Opportunity> lstOppLockedUpd = new List<Opportunity>();
        List<Opportunity> lstOppLockedQuery = new List<Opportunity>();
        if(lstOppTobeLocked.size()>0)
        lstOppLockedQuery = [SELECT Id,Contract_Number_New__c FROM Opportunity WHERE Id =: lstOppTobeLocked];
        
        for(Opportunity instOfOpp: lstOppLockedQuery){
            instOfOpp.IsLocked__c = true;
            system.debug('instOfOpp.Contract_Number_New__c++'+instOfOpp.Contract_Number_New__c);
            system.debug('mapCntNum++'+mapCntNum);
            if(mapCntNum.containsKey(instOfOpp.Contract_Number_New__c)){
                String tempStr = mapCntNum.get(instOfOpp.Contract_Number_New__c);
                if(tempStr.contains('Reviewed')){
                    String[] tempStrArr = tempStr.split('1', -2);
                    system.debug(tempStrArr);
                    system.debug(tempStrArr[0]);
                    system.debug(tempStrArr[1]);
                    if(tempStrArr[0] == 'Reviewed' && tempStrArr[1] == '2'){
                        instOfOpp.CFC_Check__c = tempStrArr[0]+'1';
                    }else if(tempStrArr[0] == 'Reviewed' && tempStrArr[1] != '2'){
                        instOfOpp.CFC_Check__c = tempStrArr[0]+'12';
                    }
                }else{
                    instOfOpp.CFC_Check__c = 'Reviewed1';
                }
            }
            lstOppLockedUpd.add(instOfOpp);
        }
        if(lstOppLockedUpd.size()>0)
        update lstOppLockedUpd;
        //Opps to be locked
         system.debug('test++'+lstConTNumFindTCVs.size());
         system.debug('lstConTNumFindTCVs'+lstConTNumFindTCVs);
        List<Opportunity> lstContrRev = new List<Opportunity>();
        if(lstConTNumFindTCVs.size()>0)
        lstContrRev = [SELECT Id,Contract_Number_New__c,Product_Category_Tract__c,(SELECT ID,Product_Category_Tract__c,Opportunity_Contract__c,Canx_Accounting_Team_Level_1_Review_Ok__c FROM Contract_Reviews__r) FROM Opportunity WHERE Contract_Number_New__c =:lstConTNumFindTCVs AND StageName ='Tract'];
         system.debug('LstContrrev+++:'+lstContrRev);
        List<Contract_Reviewing__c> lstOppTCVNoCR = new List<Contract_Reviewing__c>();
        if(lstConTNumFindTCVs.size()>0)
        lstOppTCVNoCR  = [SELECT ID,Opportunity_Contract__c,Product_Category_Tract__c,Is_Cancellation__c,Write_Off_Associated__c   FROM Contract_Reviewing__c WHERE Opportunity_Contract__c =: lstConTNumFindTCVs AND Opportunity_Stage__c=:'Other'];
        
        Map<String,String> mapContrNoWritOff = new Map<String,String>();
        for(Contract_Reviewing__c instOfCntRev : lstOppTCVNoCR){
            if(instOfCntRev.Is_Cancellation__c == true){
                //setContractNum.add(instOfCntRev.Opportunity_Contract__c);
                mapContrNoWritOff.put(instOfCntRev.Opportunity_Contract__c,instOfCntRev.Write_Off_Associated__c);
            }
        }
        system.debug('setStatusErrorC++'+setStatusErrorC);
        
        List<Contract_Reviewing__c> lstOppTCVCntRev = new List<Contract_Reviewing__c>();
        List<Contract_Reviewing__c> lstOppTCVCntRevIns = new List<Contract_Reviewing__c>();
        for(Opportunity instOfOpp : lstContrRev){
            if(instOfOpp.Contract_Reviews__r.size()>0){
                for(Contract_Reviewing__c instOfContrRev : instOfOpp.Contract_Reviews__r){
                    instOfContrRev.RecordTypeId = mapDevNameId.get('Acc_Level_1_Cancel');
                    instOfContrRev.Is_Cancellation__c = true;
                    instOfContrRev.Canx_Accounting_Team_Level_1_Reviewer__c = mapAccLev1ProdUsrName.get(instOfContrRev.Product_Category_Tract__c);
                    
                    
                    if(setStatusErrorC.contains(instOfContrRev.Opportunity_Contract__c) && instOfContrRev.Canx_Accounting_Team_Level_1_Review_Ok__c=='No')
                            instOfContrRev.Canx_Accounting_Team_Level_1_Review_Ok__c = 'Error Correct';
                    instOfContrRev.Write_Off_Associated__c = mapContrNoWritOff.get(instOfOpp.Contract_Number_New__c);
                    lstOppTCVCntRev.add(instOfContrRev);
                }   
            }else{
                Contract_Reviewing__c instOfContrRev = new Contract_Reviewing__c();
                instOfContrRev.RecordTypeId = mapDevNameId.get('Acc_Level_1_Cancel');
                instOfContrRev.Is_Cancellation__c = true;
                instOfContrRev.Write_Off_Associated__c = mapContrNoWritOff.get(instOfOpp.Contract_Number_New__c);
                instOfContrRev.Opportunity__c = instOfOpp.Id;
                instOfContrRev.Canx_Accounting_Team_Level_1_Reviewer__c = mapAccLev1ProdUsrName.get(instOfOpp.Product_Category_Tract__c);
                lstOppTCVCntRevIns.add(instOfContrRev);
            }
            
        }
        
        if(lstOppTCVCntRevIns.size()>0)
        insert lstOppTCVCntRevIns;
        
        if(lstOppTCVCntRev.size()>0)
        update lstOppTCVCntRev;
        
        //For updatin Write Off status
       
        lstWrtOffs = new List<WriteOff__c>();
        if(lstOfCntNumOppsNHydWOS.size()>0)
        lstWrtOffs = [SELECT Id FROM WriteOff__c WHERE Contract__c =: lstOfCntNumOppsNHydWOS AND Name=: lstOfCntNumOppsNHydWOSName];
        
        List<WriteOff__c> lstWrtOffsNHydUpd  = new List<WriteOff__c>();
        for(WriteOff__c isntOfWritOff : lstWrtOffs){
            isntOfWritOff.Write_Off_Status__c = 'InProgress – Contract Review Done';
            lstWrtOffsNHydUpd.add(isntOfWritOff);
        }
        
        if(lstWrtOffsNHydUpd.size()>0)
        update lstWrtOffsNHydUpd;
        
        lstWrtOffs = new List<WriteOff__c>();
        
        if(lstOfCntNumOppsHydWOS.size()>0)
        lstWrtOffs = [SELECT Id FROM WriteOff__c WHERE Contract__c =: lstOfCntNumOppsHydWOS AND Name =: lstOfCntNumOppsHydWOSName];   
        
        List<WriteOff__c> lstWrtOffsHydUpd  = new List<WriteOff__c>();
        
        for(WriteOff__c instOfWritOff : lstWrtOffs){
            instOfWritOff.Write_Off_Status__c = 'InProgress – Accounting Hybrid Review Done';
            lstWrtOffsHydUpd.add(instOfWritOff);
        }
        
        if(lstWrtOffsHydUpd.size()>0)
        update lstWrtOffsHydUpd;
        
        lstWrtOffs = new List<WriteOff__c>();
        if(lstOfCntNumOppsNHydWOSTy2.size()>0)
        lstWrtOffs = [SELECT Id FROM WriteOff__c WHERE Contract__c =: lstOfCntNumOppsNHydWOSTy2 AND Name =: lstOfCntNumOppsNHydWOSTy2Name];
        
        List<WriteOff__c> lstWrtOffsNHydUpdTy2 = new List<WriteOff__c>();
        for(WriteOff__c instOfWritOff : lstWrtOffs){
            instOfWritOff.Write_Off_Status__c = 'Completed';
            lstWrtOffsNHydUpdTy2.add(instOfWritOff);
        }
        
        if(lstWrtOffsNHydUpdTy2.size()>0)
        update lstWrtOffsNHydUpdTy2;
        
        
        lstWrtOffs = new List<WriteOff__c>();
        if(lstOfCntNumOppsHydWosCntRevDoneTy1.size()>0 || lstOfCntNumOppsHydWosCntRevDoneTy3.size()>0)
        lstWrtOffs = [SELECT Id FROM WriteOff__c WHERE (Contract__c =: lstOfCntNumOppsHydWosCntRevDoneTy1 AND Name =: lstOfCntNumOppsHydWosCntRevDoneTy1Name) OR (Contract__c =: lstOfCntNumOppsHydWosCntRevDoneTy3 AND Name =: lstOfCntNumOppsHydWosCntRevDoneTy3Name)];
        
        List<WriteOff__c> lstOfCntNumOppsHydWosCntRevDoneTy1n3UPd = new List<WriteOff__c>();
        for(WriteOff__c instOfWritOff : lstWrtOffs){
            instOfWritOff.Write_Off_Status__c = 'InProgress – Contract Review Done';
            lstOfCntNumOppsHydWosCntRevDoneTy1n3UPd.add(instOfWritOff);
        }
        
        if(lstOfCntNumOppsHydWosCntRevDoneTy1n3UPd.size()>0)
        update lstOfCntNumOppsHydWosCntRevDoneTy1n3UPd;
        
        lstWrtOffs = new List<WriteOff__c>();
        if(lstOfCntNumOppsHydWosCntRevDoneTy2.size()>0)
        lstWrtOffs = [SELECT Id FROM WriteOff__c WHERE Contract__c =: lstOfCntNumOppsHydWosCntRevDoneTy2 AND Name =: lstOfCntNumOppsHydWosCntRevDoneTy2Name];
        
        List<WriteOff__c> lstOfCntNumOppsHydWosCntRevDoneTy2UPd = new List<WriteOff__c>();
        for(WriteOff__c instOfWritOff : lstWrtOffs){
            instOfWritOff.Write_Off_Status__c = 'Completed';
            lstOfCntNumOppsHydWosCntRevDoneTy2UPd.add(instOfWritOff);
        }
        if(lstOfCntNumOppsHydWosCntRevDoneTy2UPd.size()>0)
        update lstOfCntNumOppsHydWosCntRevDoneTy2UPd;
        
        lstWrtOffs = new List<WriteOff__c>();
        if(lstOfTaxHydWosCntTy3.size()>0)
        lstWrtOffs = [SELECT Id FROM WriteOff__c WHERE Contract__c =: lstOfTaxHydWosCntTy3 AND Name =: lstOfTaxHydWosCntTy3Name];
        
        List<WriteOff__c> lstOfTaxHydWosCntTy3Upd = new List<WriteOff__c>();
        for(WriteOff__c instOfWritOff : lstWrtOffs){
            instOfWritOff.Write_Off_Status__c = 'Completed';
            lstOfTaxHydWosCntTy3Upd.add(instOfWritOff);
        }
        
        if(lstOfTaxHydWosCntTy3Upd.size()>0)
        update lstOfTaxHydWosCntTy3Upd;
        
        lstWrtOffs = new List<WriteOff__c>();
        if(lstOfAccLev1WosCnt.size()>0)
        lstWrtOffs = [SELECT Id FROM WriteOff__c WHERE Contract__c =: lstOfAccLev1WosCnt AND Name =: lstOfAccLev1WosCntName];
        List<WriteOff__c> lstOfAccLev1WosCntUpd = new List<WriteOff__c>();
        for(WriteOff__c instOfWritOff : lstWrtOffs){
            instOfWritOff.Write_Off_Status__c = 'InProgress – Accounting Level 1 Review Done';
            lstOfAccLev1WosCntUpd.add(instOfWritOff);
        }
        if(lstOfAccLev1WosCntUpd.size()>0)
        update lstOfAccLev1WosCntUpd;
        
        lstWrtOffs = new List<WriteOff__c>();
        if(lstOfAccLev2WosCnt.size()>0)
        lstWrtOffs = [SELECT Id FROM WriteOff__c WHERE Contract__c =: lstOfAccLev2WosCnt AND Name=: lstOfAccLev2WosCntName];
        
        List<WriteOff__c> lstOfAccLev2WosCntUpd = new List<WriteOff__c>();
        for(WriteOff__c instOfWritOff : lstWrtOffs){
            instOfWritOff.Write_Off_Status__c = 'Completed';
            lstOfAccLev2WosCntUpd.add(instOfWritOff);
        }
        
        if(lstOfAccLev2WosCntUpd.size()>0)
        update lstOfAccLev2WosCntUpd;
        //For updatin Write Off status
        
        List<Opportunity> lstOppToBeReOpen = new List<Opportunity>();
        if(lstOfCntNumOppsTBR.size()>0)
        lstOppToBeReOpen = [SELECT Id,IsLocked__c,(SELECT ID,RecordTypeId FROM Contract_Reviews__r) FROM Opportunity WHERE Contract_Number_New__c=:lstOfCntNumOppsTBR AND StageName !='Tract' AND Set_Cancellation_Status__c!=' Do not open'];
        
        List<Opportunity> lstOfOppOpenUpd = new List<Opportunity>();
        List<Contract_Reviewing__c> lstOfConRevUpd = new List<Contract_Reviewing__c>();
        
        for(Opportunity instOpp : lstOppToBeReOpen){
            instOpp.IsLocked__c = false;
            for(Contract_Reviewing__c instOfCntRev: instOpp.Contract_Reviews__r){
                instOfCntRev.RecordTypeId = mapDevNameId.get('Contract_Review_Cancel');
                instOfCntRev.Canx_Contract_Review_Ok__c = 'Re-Review';
                lstOfConRevUpd.add(instOfCntRev);
            }
            lstOfOppOpenUpd.add(instOpp);
        }
         
        if(lstOfOppOpenUpd.size()>0){
            update lstOfOppOpenUpd;
        }
        if(lstOfConRevUpd.size()>0){
            update lstOfConRevUpd;
        }
        //Cancellation Review Process.
        
        //Auto movement to tract .
        system.debug('lstOppMoveToTract++'+lstOppMoveToTract);
        if(!System.isBatch()){
            if(lstOppMoveToTract.size()>0){
                //TRACT2.TractBatchCreateSalesOrder CreateOrder = new  TRACT2.TractBatchCreateSalesOrder(lstOppMoveToTract);
                if(!Test.isRunningTest()){ 
                  //Database.executeBatch(CreateOrder , 1);
                }    
            } // commented on 12/18/2015 Deactivate Opportunity Movement
        }
        //Auto movement to tract. 
    }
    /**  Below method call hybrid accounting  */
    private  static Map<Id,Contract_Reviewing__c> updateHybridContractReview(List<Opportunity> listCurrentOppty,Map<Id,Contract_Reviewing__c> mapOppVsHybridContract ){
           List<Contract_Reviewing__c> contractReviewList= new List<Contract_Reviewing__c>();
           Set<String>  ContractNumberSet=new Set<String>();
           List<Opportunity> opportunityRecord;
           Set<Id> setOpptyId=new Set<Id>();
           Map<id,Contract_Reviewing__c> mapOppVsContract=new Map<id,Contract_Reviewing__c>();
           Map<id,Contract_Reviewing__c> mapIdVsContract =new Map<id,Contract_Reviewing__c>();
           for(Opportunity oppObj:listCurrentOppty){
               setOpptyId.add(oppObj.id);
              ContractNumberSet.add(oppObj.Contract_Number_New__c); 
               
           }
           if(ContractNumberSet.size()>0){
               opportunityRecord=[SELECT Id,CurrencyIsoCode,Contract_Number_New__c,CFC_Check__c,To_Be_Reviewed_By__c FROM Opportunity WHERE Contract_Number_New__c IN : ContractNumberSet];
           }
            
            map<String,RRATracker__c> mapRRATracker=RRATracker__c.getAll();
            Map<String,Integer> mapNameVsRRId=new Map<String,Integer>();
            Map<Integer,String> mapRRIdVsName=new Map<Integer,String>();
            Integer startIndex=-1,totalCustomSettingRecords=0;
            totalCustomSettingRecords=mapRRATracker.size();
            for(RRATracker__c objRRtracker :mapRRATracker.values()){
                    mapNameVsRRId.put(objRRtracker.User_Name__c,Integer.valueOF(objRRtracker.RoundRobinId__c));
                    mapRRIdVsName.put(Integer.valueOF(objRRtracker.RoundRobinId__c),objRRtracker.User_Name__c);
            } 
             Set<String> setContractNumber=new Set<String>();   
             For(Opportunity oppObj : opportunityRecord)
             {
                setContractNumber.add(oppObj.Contract_Number_New__c);    
             }  
             List<Contract_Reviewing__c> listContractReview;
             if(setContractNumber.size()>0)
                listContractReview=new List<Contract_Reviewing__c>([select Contract_Reviewer__c, Opportunity_Contract__c,Opportunity__c from Contract_Reviewing__c where (Opportunity_Contract__c in :setContractNumber or Opportunity__c in:setOpptyId) and Contract_Reviewer__c!=null]);
            List<Contract_Reviewing__c> latestContractObj=new List<Contract_Reviewing__c>([select Contract_Reviewer__c, Opportunity_Contract__c from Contract_Reviewing__c order by createdDate desc limit 1]);
            if(latestContractObj.size()>0){
                startIndex=mapNameVsRRId.keyset().contains(latestContractObj[0].Contract_Reviewer__c)?Integer.valueOF(mapNameVsRRId.get(latestContractObj[0].Contract_Reviewer__c)) :-1  ;
            }
            Map<String,String> mapNumberVsAssignUser=new Map<String,String>();
           for(Contract_Reviewing__c objReview:listContractReview){
                  mapNumberVsAssignUser.put(objReview.Opportunity_Contract__c,objReview.Contract_Reviewer__c);
                  mapOppVsContract.put(objReview.Opportunity__c,objReview);
            }
            For(Opportunity oppObj :listCurrentOppty)
            {
                            if(!mapOppVsContract.keySet().Contains(oppObj.id) ){
                                    Contract_Reviewing__c contractReview =mapOppVsHybridContract.get(oppObj.id) ;
                                    if(mapNumberVsAssignUser.keyset().contains(oppObj.Contract_Number_New__c)){
                                            contractReview.Contract_Reviewer__c=mapNumberVsAssignUser.get(oppObj.Contract_Number_New__c);
                                    }       
                                    else {
                                            if(startIndex<totalCustomSettingRecords-1){
                                                startIndex=startIndex+1;
                                            }else {
                                                startIndex=0;
                                            }   
                                        System.debug('*********************'+startIndex);
                                        contractReview.Contract_Reviewer__c=mapRRIdVsName.get(startIndex);
                                    }
                                    System.debug('------------------->'+contractReview.Contract_Reviewer__c);
                                    //contractReview.Opportunity__c=oppObj.Id;
                                    //contractReview.CurrencyIsoCode=oppObj.CurrencyIsoCode;
                                    //contractReviewList.add(contractReview);
                                    contractReview.recordTypeID=Schema.SObjectType.Contract_Reviewing__c.getRecordTypeInfosByName().get('Accounting Review(hybrid level 1)').getRecordTypeId();
                                    mapIdVsContract.put(contractReview.id,contractReview);
                            }   
                    
            }
         return    mapIdVsContract;
    }   
    
    public void OnBeforeDelete(List<Contract_Reviewing__c > oldValues,Map<Id,Contract_Reviewing__c > oldMapValues){
        for(Contract_Reviewing__c instOFContRev : oldValues){
            if(!setIdsSupUsr.contains(UserInfo.getUserId())){
                instOFContRev.addError('You are not allowed to delete this record.');
            }
        }
    } // end of method
	
     public static void sendAlertToRFPBuilder(Map<Id,Contract_Reviewing__c > oldMapValues,Map<Id,Contract_Reviewing__c> newMapValues)
     {
         Map<Id,Id> oppIdsVsContractIds = new Map<Id,Id>();
         Map<Id,Opportunity> finalOpps = new Map<Id,Opportunity>();
         List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>(); 
         for(Contract_Reviewing__c reviewRec : newMapValues.values())
         {
             if(reviewRec.Contract_Review_Ok__c != oldMapValues.get(reviewRec.Id).Contract_Review_Ok__c && reviewRec.Contract_Review_Ok__c == 'Yes')
             {
                 oppIdsVsContractIds.put(reviewRec.Opportunity__c,reviewRec.id);
             }
         }
         
         if(!oppIdsVsContractIds.isEmpty())
         {
             List<String> skus = Label.ContractReviewOkProducts.split(',');
             
             for(Opportunity opp : [select id,Contract_Type_2_0__c,Implementation_Response__c,Account.Name,(select id,productcode from OpportunityLineItems) from Opportunity where Id IN :oppIdsVsContractIds.keySet()])
             {
                 if(opp.Contract_Type_2_0__c == null)
                 {
                     for(OpportunityLineItem oli : opp.OpportunityLineItems)
                     {
                         if(skus.contains(oli.productcode))
                         {
                             finalOpps.put(opp.Id,opp);
                             break;
                         }
                     }
                 }
             }
         }
         
         if(!finalOpps.isEmpty())
         {
             for(Id oppId : finalOpps.keySet())
             {
                 String bodyText = 'Hi Team,<br /><br />We have implemented the below “RFP Report” contract. Please take care of the user logins.<br /><br />Opportunity Link: '+System.URL.getSalesforceBaseUrl().toExternalForm()+'/'+oppId+' <br/><br />Thanks,<br />Contracts Management Team';
                 List<String> emailAddresses = Label.RFPBuilderSupportTeamEmail.split(',');
                 Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                 message.setToAddresses(emailAddresses);
                 message.optOutPolicy = 'FILTER';
                 message.subject = finalOpps.get(oppId).Implementation_Response__c+' - '+finalOpps.get(oppId).Account.Name;
                 message.setHtmlBody(bodyText);
                 messages.add(message);
             }
             if(!messages.isEmpty())
             {
                 Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                 if (results[0].success) 
                 {
                     System.debug('The email was sent successfully.');
                 }
                 else 
                 {
                     System.debug('The email failed to send: ' + results[0].errors[0].message);
                 }
             }
         }
     }
      
}// end of class