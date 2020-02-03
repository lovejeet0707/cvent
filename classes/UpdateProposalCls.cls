public class UpdateProposalCls {

    
    public Proposal__c instOfProp{get;set;}
    
    public Decimal aR1One {get;set;}
    public Decimal secYearOne{get;set;}
    public Decimal thirYearOne {get;set;}
    public Decimal foryearOne {get;set;}
    public Decimal aR1OneSec {get;set;}
    public Decimal secYearOneSec{get;set;}
    public Decimal thirYearOneSec {get;set;}
    public Decimal foryearOneSec {get;set;}
    
    public Decimal aR1Sec{get;set;}
    public Decimal secYearSec{get;set;}
    public Decimal thirYearSec{get;set;}
    public Decimal foryearSec{get;set;}
    public Decimal aR1SecSec{get;set;}
    public Decimal secYearSecSec{get;set;}
    public Decimal thirYearSecSec{get;set;}
    public Decimal foryearSecSec{get;set;}
    
    public Decimal aR1Thir{get;set;}
    public Decimal secYearThir{get;set;}
    public Decimal thirYearThir{get;set;}
    public Decimal foryearThir{get;set;}
    public Decimal aR1ThirSec{get;set;}
    public Decimal secYearThirSec{get;set;}
    public Decimal thirYearThirSec{get;set;}
    public Decimal foryearThirSec{get;set;}
    
    public Decimal aR1For{get;set;}
    public Decimal secYearFor{get;set;}
    public Decimal thirYearFor{get;set;}
    public Decimal foryearFor{get;set;}
    public Decimal aR1ForSec{get;set;}
    public Decimal secYearForSec{get;set;}
    public Decimal thirYearForSec{get;set;}
    public Decimal foryearForSec{get;set;}
    
    //CC changes
    public Decimal aR1OneCC{get;set;}
    public Decimal secYearOneCC{get;set;}
    public Decimal thirYearOneCC{get;set;}
    public Decimal foryearOneCC{get;set;}
    public Decimal aR1OneSecCC{get;set;}
    public Decimal secYearOneSecCC{get;set;}
    public Decimal thirYearOneSecCC{get;set;}
    public Decimal foryearOneSecCC{get;set;}
    
    public Decimal aR1SecCC{get;set;}
    public Decimal secYearSecCC{get;set;}
    public Decimal thirYearSecCC{get;set;}
    public Decimal foryearSecCC{get;set;}
    public Decimal aR1SecSecCC{get;set;}
    public Decimal secYearSecSecCC{get;set;}
    public Decimal thirYearSecSecCC{get;set;}
    public Decimal foryearSecSecCC{get;set;}
    
    public Decimal aR1ThirCC{get;set;}
    public Decimal secYearThirCC{get;set;}
    public Decimal thirYearThirCC{get;set;}
    public Decimal foryearThirCC{get;set;}
    public Decimal aR1ThirSecCC{get;set;}
    public Decimal secYearThirSecCC{get;set;}
    public Decimal thirYearThirSecCC{get;set;}
    public Decimal foryearThirSecCC{get;set;}
    
    public Decimal aR1ForCC{get;set;}
    public Decimal secYearForCC{get;set;}
    public Decimal thirYearForCC{get;set;}
    public Decimal foryearForCC{get;set;}
    public Decimal aR1ForSecCC{get;set;}
    public Decimal secYearForSecCC{get;set;}
    public Decimal thirYearForSecCC{get;set;}
    public Decimal foryearForSecCC{get;set;}
    //CC changes
    
    public Integer count {get;set;}
    public List<Id> lstContYear {get;set;}
    public Integer rowCheck{get;set;}
    public Integer rowCheck1{get;set;}
    public Integer rowCheck2{get;set;}
    public Integer rowCheck3{get;set;}
    public Integer rowCheck4{get;set;}
    public Integer rowCheck5{get;set;}
    public Integer rowCheck6{get;set;}
    
    public UpdateProposalCls(ApexPages.StandardController controller) {
        lstContYear = new List<Id>();
        
        instOfProp = [SELECT  Account__c, Account_Name__c,Contact_Name__c,Email__c, Feature_Total_Roll_UP__c, Grand_Total__c, 
                      Main__c, Maintenance_Fee__c,Maintenance_Fee_Rack__c, Opportunity_Name__c, OwnerId, Product__c, Name, Id, 
                      Status__c,Usage_Package_Fee__c,Usage_Package_Fee_Rack__c,(SELECT Row__c,Annual_Registrants__c, 
                      Annual_Registrants_2__c, Name, Proposal__c, Second_Year_Term__c, Second_Year_Term_Rack__c, SystemModstamp, 
                      Third_Year_Term__c, Third_Year_Term_Rack__c, Fourth_Year_Term_Rack__c, Fourth_Year_Term__c FROM Contract_Years__r 
                      ORDER BY Row__c ASC)FROM Proposal__c WHERE Id=: Apexpages.currentpage().getparameters().get('id')];
        count=0;
        for(Contract_Year__c instOfContYear : instOfProp.Contract_Years__r){
            if(instOfContYear.Annual_Registrants__c > 0 || instOfContYear.Second_Year_Term__c > 0 || instOfContYear.Third_Year_Term__c > 0 || instOfContYear.Fourth_Year_Term__c > 0){
                count++;
                if(instOfContYear.Row__c == 1){
                    lstContYear.add(instOfContYear.Id);
                    aR1One = instOfContYear.Annual_Registrants__c;
                    secYearOne = instOfContYear.Second_Year_Term__c; 
                    thirYearOne = instOfContYear.Third_Year_Term__c;
                    foryearOne = instOfContYear.Fourth_Year_Term__c;
                    aR1OneSec = instOfContYear.Annual_Registrants__c;
                    secYearOneSec = instOfContYear.Second_Year_Term_Rack__c;
                    thirYearOneSec = instOfContYear.Third_Year_Term_Rack__c;
                    foryearOneSec = instOfContYear.Fourth_Year_Term_Rack__c ;
                }
                if(instOfContYear.Row__c == 2){
                    rowCheck = 1;
                    lstContYear.add(instOfContYear.Id);
                    aR1Sec = instOfContYear.Annual_Registrants__c;
                    secYearSec = instOfContYear.Second_Year_Term__c; 
                    thirYearSec = instOfContYear.Third_Year_Term__c;
                    foryearSec = instOfContYear.Fourth_Year_Term__c;
                    aR1SecSec = instOfContYear.Annual_Registrants__c;
                    secYearSecSec = instOfContYear.Second_Year_Term_Rack__c;
                    thirYearSecSec = instOfContYear.Third_Year_Term_Rack__c;
                    foryearSecSec = instOfContYear.Fourth_Year_Term_Rack__c;
                }
                if(instOfContYear.Row__c == 3){
                    rowCheck1 = 1;
                    lstContYear.add(instOfContYear.Id);
                    aR1Thir = instOfContYear.Annual_Registrants__c;
                    secYearThir = instOfContYear.Second_Year_Term__c; 
                    thirYearThir = instOfContYear.Third_Year_Term__c;
                    foryearThir = instOfContYear.Fourth_Year_Term__c;
                    aR1ThirSec = instOfContYear.Annual_Registrants__c;
                    secYearThirSec= instOfContYear.Second_Year_Term_Rack__c;
                    thirYearThirSec = instOfContYear.Third_Year_Term_Rack__c;
                    foryearThirSec = instOfContYear.Fourth_Year_Term_Rack__c; 
                }
                if(instOfContYear.Row__c == 4){
                    rowCheck2 = 1;
                    lstContYear.add(instOfContYear.Id);
                    aR1For = instOfContYear.Annual_Registrants__c;
                    secYearFor = instOfContYear.Second_Year_Term__c; 
                    thirYearFor = instOfContYear.Third_Year_Term__c;
                    foryearFor = instOfContYear.Fourth_Year_Term__c;
                    aR1ForSec = instOfContYear.Annual_Registrants__c;
                    secYearForSec = instOfContYear.Second_Year_Term_Rack__c;
                    thirYearForSec = instOfContYear.Third_Year_Term_Rack__c;
                    foryearForSec = instOfContYear.Fourth_Year_Term_Rack__c; 
                }
                if(instOfContYear.Row__c == 5){
                    rowCheck3 = 1;
                    lstContYear.add(instOfContYear.Id);
                    aR1OneCC = instOfContYear.Annual_Registrants__c;
                    secYearOneCC = instOfContYear.Second_Year_Term__c; 
                    thirYearOneCC = instOfContYear.Third_Year_Term__c;
                    foryearOneCC = instOfContYear.Fourth_Year_Term__c;
                    aR1OneSecCC = instOfContYear.Annual_Registrants__c;
                    secYearOneSecCC = instOfContYear.Second_Year_Term_Rack__c;
                    thirYearOneSecCC = instOfContYear.Third_Year_Term_Rack__c;
                    foryearOneSecCC = instOfContYear.Fourth_Year_Term_Rack__c ;
                }
                if(instOfContYear.Row__c == 6){
                    rowCheck4 = 1;
                    lstContYear.add(instOfContYear.Id);
                    aR1SecCC = instOfContYear.Annual_Registrants__c;
                    secYearSecCC = instOfContYear.Second_Year_Term__c; 
                    thirYearSecCC = instOfContYear.Third_Year_Term__c;
                    foryearSecCC = instOfContYear.Fourth_Year_Term__c;
                    aR1SecSecCC = instOfContYear.Annual_Registrants__c;
                    secYearSecSecCC = instOfContYear.Second_Year_Term_Rack__c;
                    thirYearSecSecCC = instOfContYear.Third_Year_Term_Rack__c;
                    foryearSecSecCC = instOfContYear.Fourth_Year_Term_Rack__c;
                }
                if(instOfContYear.Row__c == 7){
                    rowCheck5 = 1;
                    lstContYear.add(instOfContYear.Id);
                    aR1ThirCC = instOfContYear.Annual_Registrants__c;
                    secYearThirCC = instOfContYear.Second_Year_Term__c; 
                    thirYearThirCC = instOfContYear.Third_Year_Term__c;
                    foryearThirCC = instOfContYear.Fourth_Year_Term__c;
                    aR1ThirSecCC = instOfContYear.Annual_Registrants__c;
                    secYearThirSecCC= instOfContYear.Second_Year_Term_Rack__c;
                    thirYearThirSecCC = instOfContYear.Third_Year_Term_Rack__c;
                    foryearThirSecCC = instOfContYear.Fourth_Year_Term_Rack__c; 
                }
                if(instOfContYear.Row__c == 8){
                    rowCheck6 = 1;
                    lstContYear.add(instOfContYear.Id);
                    aR1ForCC = instOfContYear.Annual_Registrants__c;
                    secYearForCC = instOfContYear.Second_Year_Term__c; 
                    thirYearForCC = instOfContYear.Third_Year_Term__c;
                    foryearForCC = instOfContYear.Fourth_Year_Term__c;
                    aR1ForSecCC = instOfContYear.Annual_Registrants__c;
                    secYearForSecCC = instOfContYear.Second_Year_Term_Rack__c;
                    thirYearForSecCC = instOfContYear.Third_Year_Term_Rack__c;
                    foryearForSecCC = instOfContYear.Fourth_Year_Term_Rack__c; 
                }
            }
        }  
    }

    public UpdateProposalCls(){
                     
    } 
    
    public PageReference cancelNow(){
        PageReference instOfPgRef =  new PageReference('/apex/ProposalDetailAltPage?id='+Apexpages.currentpage().getparameters().get('id'));
        instOfPgRef.setRedirect(True);
        return instOfPgRef;
    }
    
    @RemoteAction
    public static PageReference save(String allValues){
        String [] lstOfValues = allValues.split(',', -2);
        Integer intallSize = lstOfValues.size();
        Integer counterVal = Integer.valueOf(lstOfValues[intallSize-1]); 
        Integer counterIdVal = 0;
        Integer counterValCC = Integer.valueOf(lstOfValues[intallSize-2]);
        Integer counterIdValCC = 0;
        List<String> contId = new List<String>();
        List<String> contIdCC = new List<String>();
         
        List<Contract_Year__c> lstContYearUpd = new List<Contract_Year__c>();
        List<Contract_Year__c> lstContYearIns = new List<Contract_Year__c>();
        List<Contract_Year__c> lstContYeardel = new List<Contract_Year__c>();
        
        for(String insOfStr : lstOfValues){
            if(insOfStr.StartsWith('a1i')){
                contId.add(insOfStr);
            }
        }
        List<Contract_Year__c> lstContYearRowVal = [SELECT Id,Row__c FROM Contract_Year__c WHERE Id =: contId ORDER BY Row__c ASC]; 
        contId.clear();
        for(Contract_Year__c insOfStr : lstContYearRowVal){
            if(insOfStr.Row__c <= 4 ){               
                counterIdVal++;
                contId.add(insOfStr.Id);
            }else{
                counterIdValCC++;
                contIdCC.add(insOfStr.Id);
            }
        }
        
        system.debug('counterVal++'+counterVal);
        system.debug('counterIdVal++'+counterIdVal);
        if(counterVal >= 0){
            if(Decimal.valueOf(lstOfValues[0]) > 0 || Decimal.valueOf(lstOfValues[1]) > 0 || Decimal.valueOf(lstOfValues[2]) > 0 || Decimal.valueOf(lstOfValues[3]) > 0){
                Contract_Year__c instOfContYear =  new Contract_Year__c();
                //instOfContYear.Proposal__c = instOfContYear.Id;
                instOfContYear.Row__c = 1;
                if(Decimal.valueOf(lstOfValues[0])!=0){
                    instOfContYear.Annual_Registrants__c = Decimal.valueOf(lstOfValues[0]);
                }
                if(Decimal.valueOf(lstOfValues[1])!=0){
                    instOfContYear.Second_Year_Term__c = Decimal.valueOf(lstOfValues[1]);
                }
                if(Decimal.valueOf(lstOfValues[2])!=0){
                    instOfContYear.Third_Year_Term__c = Decimal.valueOf(lstOfValues[2]);
                }
                if(Decimal.valueOf(lstOfValues[3])!=0){
                    instOfContYear.Fourth_Year_Term__c = Decimal.valueOf(lstOfValues[3]);
                }
                if(Decimal.valueOf(lstOfValues[4])!=0){
                    instOfContYear.Annual_Registrants__c = Decimal.valueOf(lstOfValues[4]);
                }
                if(Decimal.valueOf(lstOfValues[5])!=0){
                    instOfContYear.Second_Year_Term_Rack__c = Decimal.valueOf(lstOfValues[5]);
                }
                if(Decimal.valueOf(lstOfValues[6])!=0){
                    instOfContYear.Third_Year_Term_Rack__c = Decimal.valueOf(lstOfValues[6]);
                }
                if(Decimal.valueOf(lstOfValues[7])!=0){
                    instOfContYear.Fourth_Year_Term_Rack__c = Decimal.valueOf(lstOfValues[7]);
                }
                
                
                if(counterIdVal >= 1){
                    instOfContYear.Id = contId[0];
                    lstContYearUpd.add(instOfContYear);
                }
                if(counterVal >= 0 && counterIdVal < 1){
                    instOfContYear.Proposal__c = lstOfValues[35];
                    lstContYearIns.add(instOfContYear);
                }
                
            }else if(counterIdVal >= 1){
                if(Decimal.valueOf(lstOfValues[0]) == 0 && Decimal.valueOf(lstOfValues[1]) == 0 && Decimal.valueOf(lstOfValues[2]) == 0 && Decimal.valueOf(lstOfValues[3]) == 0){
                    Contract_Year__c instOfContYear =  new Contract_Year__c();
                    instOfContYear.Id = contId[0];
                    lstContYeardel.add(instOfContYear);
                }
            }
        }
        
        if(counterVal >= 1){
            if(Decimal.valueOf(lstOfValues[8]) > 0 || Decimal.valueOf(lstOfValues[9]) > 0 || Decimal.valueOf(lstOfValues[10]) > 0 || Decimal.valueOf(lstOfValues[11]) > 0){
                Contract_Year__c instOfContYear =  new Contract_Year__c();
                
                instOfContYear.Row__c = 2;
                if(Decimal.valueOf(lstOfValues[8])!=0){
                    instOfContYear.Annual_Registrants__c = Decimal.valueOf(lstOfValues[8]);
                }
                if(Decimal.valueOf(lstOfValues[9])!=0){
                    instOfContYear.Second_Year_Term__c = Decimal.valueOf(lstOfValues[9]);
                }
                if(Decimal.valueOf(lstOfValues[10])!=0){
                    instOfContYear.Third_Year_Term__c = Decimal.valueOf(lstOfValues[10]);
                }
                if(Decimal.valueOf(lstOfValues[11])!=0){
                    instOfContYear.Fourth_Year_Term__c = Decimal.valueOf(lstOfValues[11]);
                }
                if(Decimal.valueOf(lstOfValues[12])!=0){
                    instOfContYear.Annual_Registrants__c = Decimal.valueOf(lstOfValues[12]);
                }
                if(Decimal.valueOf(lstOfValues[13])!=0){
                    instOfContYear.Second_Year_Term_Rack__c = Decimal.valueOf(lstOfValues[13]);
                }
                if(Decimal.valueOf(lstOfValues[14])!=0){
                    instOfContYear.Third_Year_Term_Rack__c = Decimal.valueOf(lstOfValues[14]);
                }
                if(Decimal.valueOf(lstOfValues[15])!=0){
                    instOfContYear.Fourth_Year_Term_Rack__c = Decimal.valueOf(lstOfValues[15]);
                }
                
                
                if(counterVal >= 1 && counterIdVal >= 2){
                    instOfContYear.Id = contId[1];
                    lstContYearUpd.add(instOfContYear);
                }
                if(counterVal > 0 && counterIdVal < 2){
                    instOfContYear.Proposal__c = lstOfValues[35];
                    lstContYearIns.add(instOfContYear);
                }
            }
        }else if(counterVal < 1 && counterIdVal >= 2){
            Contract_Year__c instOfContYear =  new Contract_Year__c();
            instOfContYear.Id = contId[1];
            lstContYeardel.add(instOfContYear); 
        }
        
        if(counterVal >= 2){
            if(Decimal.valueOf(lstOfValues[16]) > 0 || Decimal.valueOf(lstOfValues[17]) > 0 || Decimal.valueOf(lstOfValues[18]) > 0 || Decimal.valueOf(lstOfValues[19]) > 0){
                Contract_Year__c instOfContYear =  new Contract_Year__c();
                //instOfContYear.Proposal__c = instOfPropSec.Id;
                instOfContYear.Row__c = 3;
                if(Decimal.valueOf(lstOfValues[16])!=0){
                    instOfContYear.Annual_Registrants__c = Decimal.valueOf(lstOfValues[16]);
                }
                if(Decimal.valueOf(lstOfValues[17])!=0){
                    instOfContYear.Second_Year_Term__c = Decimal.valueOf(lstOfValues[17]);
                }
                if(Decimal.valueOf(lstOfValues[18])!=0){
                    instOfContYear.Third_Year_Term__c = Decimal.valueOf(lstOfValues[18]);
                }
                if(Decimal.valueOf(lstOfValues[19])!=0){
                    instOfContYear.Fourth_Year_Term__c = Decimal.valueOf(lstOfValues[19]);
                }
                if(Decimal.valueOf(lstOfValues[20])!=0){
                    instOfContYear.Annual_Registrants__c = Decimal.valueOf(lstOfValues[20]);
                }
                if(Decimal.valueOf(lstOfValues[21])!=0){
                    instOfContYear.Second_Year_Term_Rack__c = Decimal.valueOf(lstOfValues[21]);
                }
                if(Decimal.valueOf(lstOfValues[22])!=0){
                    instOfContYear.Third_Year_Term_Rack__c = Decimal.valueOf(lstOfValues[22]);
                }
                if(Decimal.valueOf(lstOfValues[23])!=0){
                    instOfContYear.Fourth_Year_Term_Rack__c = Decimal.valueOf(lstOfValues[23]);
                }
                
                if(counterVal >= 2 && counterIdVal >= 3){
                    instOfContYear.Id = contId[2];
                    lstContYearUpd.add(instOfContYear);
                }
                if(counterVal > 1 && counterIdVal < 3){
                    instOfContYear.Proposal__c = lstOfValues[35];
                    lstContYearIns.add(instOfContYear);
                }
            }
        }else if(counterVal < 2 && counterIdVal >= 3){
            Contract_Year__c instOfContYear =  new Contract_Year__c();
            instOfContYear.Id = contId[2];
            lstContYeardel.add(instOfContYear); 
        }
        
        if(counterVal >= 3){
            if(Decimal.valueOf(lstOfValues[24]) > 0 || Decimal.valueOf(lstOfValues[25]) > 0 || Decimal.valueOf(lstOfValues[26]) > 0 || Decimal.valueOf(lstOfValues[27]) > 0){
                Contract_Year__c instOfContYear =  new Contract_Year__c();
                //instOfContYear.Proposal__c = instOfPropSec.Id;
                instOfContYear.Row__c = 4;
                if(Decimal.valueOf(lstOfValues[24])!=0){
                    instOfContYear.Annual_Registrants__c = Decimal.valueOf(lstOfValues[24]);
                }
                if(Decimal.valueOf(lstOfValues[25])!=0){
                    instOfContYear.Second_Year_Term__c = Decimal.valueOf(lstOfValues[25]);
                }
                if(Decimal.valueOf(lstOfValues[26])!=0){
                    instOfContYear.Third_Year_Term__c = Decimal.valueOf(lstOfValues[26]);
                }
                if(Decimal.valueOf(lstOfValues[27])!=0){
                    instOfContYear.Fourth_Year_Term__c = Decimal.valueOf(lstOfValues[27]);
                }
                if(Decimal.valueOf(lstOfValues[28])!=0){
                    instOfContYear.Annual_Registrants__c = Decimal.valueOf(lstOfValues[28]);
                }
                if(Decimal.valueOf(lstOfValues[29])!=0){
                    instOfContYear.Second_Year_Term_Rack__c = Decimal.valueOf(lstOfValues[29]);
                }
                if(Decimal.valueOf(lstOfValues[30])!=0){
                    instOfContYear.Third_Year_Term_Rack__c = Decimal.valueOf(lstOfValues[30]);
                }
                if(Decimal.valueOf(lstOfValues[31])!=0){
                    instOfContYear.Fourth_Year_Term_Rack__c = Decimal.valueOf(lstOfValues[31]);
                }
                
                if(counterVal >= 3 && counterIdVal >= 4){
                    instOfContYear.Id = contId[3];
                    lstContYearUpd.add(instOfContYear);
                }
                if(counterVal > 2 && counterIdVal < 4){
                    instOfContYear.Proposal__c = lstOfValues[35];
                    lstContYearIns.add(instOfContYear);
                }  
            }
        }else if(counterVal < 3 && counterIdVal >= 4){
            Contract_Year__c instOfContYear =  new Contract_Year__c();
            instOfContYear.Id = contId[3];
            lstContYeardel.add(instOfContYear); 
        }
        //if(lstOfValues[34] == 'Event & Crowd Compass'){
            if(counterValCC >= 0){
                if(Decimal.valueOf(lstOfValues[36]) > 0 || Decimal.valueOf(lstOfValues[37]) > 0 || Decimal.valueOf(lstOfValues[38]) > 0 || Decimal.valueOf(lstOfValues[39]) > 0){
                    Contract_Year__c instOfContYear =  new Contract_Year__c();
                    //instOfContYear.Proposal__c = instOfContYear.Id;
                    instOfContYear.Row__c = 5;
                    if(Decimal.valueOf(lstOfValues[36])!=0){
                        instOfContYear.Annual_Registrants__c = Decimal.valueOf(lstOfValues[36]);
                    }
                    if(Decimal.valueOf(lstOfValues[37])!=0){
                        instOfContYear.Second_Year_Term__c = Decimal.valueOf(lstOfValues[37]);
                    }
                    if(Decimal.valueOf(lstOfValues[38])!=0){
                        instOfContYear.Third_Year_Term__c = Decimal.valueOf(lstOfValues[38]);
                    }
                    if(Decimal.valueOf(lstOfValues[39])!=0){
                        instOfContYear.Fourth_Year_Term__c = Decimal.valueOf(lstOfValues[39]);
                    }
                    if(Decimal.valueOf(lstOfValues[40])!=0){
                        instOfContYear.Annual_Registrants__c = Decimal.valueOf(lstOfValues[40]);
                    }
                    if(Decimal.valueOf(lstOfValues[41])!=0){
                        instOfContYear.Second_Year_Term_Rack__c = Decimal.valueOf(lstOfValues[41]);
                    }
                    if(Decimal.valueOf(lstOfValues[42])!=0){
                        instOfContYear.Third_Year_Term_Rack__c = Decimal.valueOf(lstOfValues[42]);
                    }
                    if(Decimal.valueOf(lstOfValues[43])!=0){
                        instOfContYear.Fourth_Year_Term_Rack__c = Decimal.valueOf(lstOfValues[43]);
                    }
                    
                    
                    if(counterIdValCC >= 1){
                        instOfContYear.Id = contIdCC[0];
                        lstContYearUpd.add(instOfContYear);
                    }
                    if(counterValCC >= 0 && counterIdValCC < 1){
                        instOfContYear.Proposal__c = lstOfValues[35];
                        lstContYearIns.add(instOfContYear);
                    }
                    
                }else if(counterIdValCC >= 1){
                    if(Decimal.valueOf(lstOfValues[36]) == 0 && Decimal.valueOf(lstOfValues[37]) == 0 && Decimal.valueOf(lstOfValues[38]) == 0 && Decimal.valueOf(lstOfValues[39]) == 0){
                        Contract_Year__c instOfContYear =  new Contract_Year__c();
                        instOfContYear.Id = contIdCC[0];
                        lstContYeardel.add(instOfContYear);
                    }
                }
            }
            
            if(counterValCC >= 1){
                if(Decimal.valueOf(lstOfValues[44]) > 0 || Decimal.valueOf(lstOfValues[45]) > 0 || Decimal.valueOf(lstOfValues[46]) > 0 || Decimal.valueOf(lstOfValues[47]) > 0){
                    Contract_Year__c instOfContYear =  new Contract_Year__c();
                    
                    instOfContYear.Row__c = 6;
                    if(Decimal.valueOf(lstOfValues[44])!=0){
                        instOfContYear.Annual_Registrants__c = Decimal.valueOf(lstOfValues[44]);
                    }
                    if(Decimal.valueOf(lstOfValues[45])!=0){
                        instOfContYear.Second_Year_Term__c = Decimal.valueOf(lstOfValues[45]);
                    }
                    if(Decimal.valueOf(lstOfValues[46])!=0){
                        instOfContYear.Third_Year_Term__c = Decimal.valueOf(lstOfValues[46]);
                    }
                    if(Decimal.valueOf(lstOfValues[47])!=0){
                        instOfContYear.Fourth_Year_Term__c = Decimal.valueOf(lstOfValues[47]);
                    }
                    if(Decimal.valueOf(lstOfValues[48])!=0){
                        instOfContYear.Annual_Registrants__c = Decimal.valueOf(lstOfValues[48]);
                    }
                    if(Decimal.valueOf(lstOfValues[49])!=0){
                        instOfContYear.Second_Year_Term_Rack__c = Decimal.valueOf(lstOfValues[49]);
                    }
                    if(Decimal.valueOf(lstOfValues[50])!=0){
                        instOfContYear.Third_Year_Term_Rack__c = Decimal.valueOf(lstOfValues[50]);
                    }
                    if(Decimal.valueOf(lstOfValues[51])!=0){
                        instOfContYear.Fourth_Year_Term_Rack__c = Decimal.valueOf(lstOfValues[51]);
                    }
                    
                    
                    if(counterValCC >= 1 && counterIdValCC >= 2){
                        instOfContYear.Id = contIdCC[1];
                        lstContYearUpd.add(instOfContYear);
                    }
                    if(counterValCC > 0 && counterIdValCC < 2){
                        instOfContYear.Proposal__c = lstOfValues[35];
                        lstContYearIns.add(instOfContYear);
                    }
                }
            }else if(counterValCC < 1 && counterIdValCC >= 2){
                Contract_Year__c instOfContYear =  new Contract_Year__c();
                instOfContYear.Id = contIdCC[1];
                lstContYeardel.add(instOfContYear); 
            }
            
            if(counterValCC >= 2){
                if(Decimal.valueOf(lstOfValues[52]) > 0 || Decimal.valueOf(lstOfValues[53]) > 0 || Decimal.valueOf(lstOfValues[54]) > 0 || Decimal.valueOf(lstOfValues[55]) > 0){
                    Contract_Year__c instOfContYear =  new Contract_Year__c();
                    //instOfContYear.Proposal__c = instOfPropSec.Id;
                    instOfContYear.Row__c = 7;
                    if(Decimal.valueOf(lstOfValues[52])!=0){
                        instOfContYear.Annual_Registrants__c = Decimal.valueOf(lstOfValues[52]);
                    }
                    if(Decimal.valueOf(lstOfValues[53])!=0){
                        instOfContYear.Second_Year_Term__c = Decimal.valueOf(lstOfValues[53]);
                    }
                    if(Decimal.valueOf(lstOfValues[54])!=0){
                        instOfContYear.Third_Year_Term__c = Decimal.valueOf(lstOfValues[54]);
                    }
                    if(Decimal.valueOf(lstOfValues[55])!=0){
                        instOfContYear.Fourth_Year_Term__c = Decimal.valueOf(lstOfValues[55]);
                    }
                    if(Decimal.valueOf(lstOfValues[56])!=0){
                        instOfContYear.Annual_Registrants__c = Decimal.valueOf(lstOfValues[56]);
                    }
                    if(Decimal.valueOf(lstOfValues[57])!=0){
                        instOfContYear.Second_Year_Term_Rack__c = Decimal.valueOf(lstOfValues[57]);
                    }
                    if(Decimal.valueOf(lstOfValues[58])!=0){
                        instOfContYear.Third_Year_Term_Rack__c = Decimal.valueOf(lstOfValues[58]);
                    }
                    if(Decimal.valueOf(lstOfValues[59])!=0){
                        instOfContYear.Fourth_Year_Term_Rack__c = Decimal.valueOf(lstOfValues[59]);
                    }
                    
                    if(counterValCC >= 2 && counterIdValCC >= 3){
                        instOfContYear.Id = contIdCC[2];
                        lstContYearUpd.add(instOfContYear);
                    }
                    if(counterValCC > 1 && counterIdValCC < 3){
                        instOfContYear.Proposal__c = lstOfValues[35];
                        lstContYearIns.add(instOfContYear);
                    }
                }
            }else if(counterValCC < 2 && counterIdValCC >= 3){
                Contract_Year__c instOfContYear =  new Contract_Year__c();
                instOfContYear.Id = contIdCC[2];
                lstContYeardel.add(instOfContYear); 
            }
            
            if(counterValCC >= 3){
                if(Decimal.valueOf(lstOfValues[60]) > 0 || Decimal.valueOf(lstOfValues[61]) > 0 || Decimal.valueOf(lstOfValues[62]) > 0 || Decimal.valueOf(lstOfValues[63]) > 0){
                    Contract_Year__c instOfContYear =  new Contract_Year__c();
                    //instOfContYear.Proposal__c = instOfPropSec.Id;
                    instOfContYear.Row__c = 8;
                    if(Decimal.valueOf(lstOfValues[60])!=0){
                        instOfContYear.Annual_Registrants__c = Decimal.valueOf(lstOfValues[60]);
                    }
                    if(Decimal.valueOf(lstOfValues[61])!=0){
                        instOfContYear.Second_Year_Term__c = Decimal.valueOf(lstOfValues[61]);
                    }
                    if(Decimal.valueOf(lstOfValues[62])!=0){
                        instOfContYear.Third_Year_Term__c = Decimal.valueOf(lstOfValues[62]);
                    }
                    if(Decimal.valueOf(lstOfValues[63])!=0){
                        instOfContYear.Fourth_Year_Term__c = Decimal.valueOf(lstOfValues[63]);
                    }
                    if(Decimal.valueOf(lstOfValues[64])!=0){
                        instOfContYear.Annual_Registrants__c = Decimal.valueOf(lstOfValues[64]);
                    }
                    if(Decimal.valueOf(lstOfValues[65])!=0){
                        instOfContYear.Second_Year_Term_Rack__c = Decimal.valueOf(lstOfValues[65]);
                    }
                    if(Decimal.valueOf(lstOfValues[66])!=0){
                        instOfContYear.Third_Year_Term_Rack__c = Decimal.valueOf(lstOfValues[66]);
                    }
                    if(Decimal.valueOf(lstOfValues[67])!=0){
                        instOfContYear.Fourth_Year_Term_Rack__c = Decimal.valueOf(lstOfValues[67]);
                    }
                    
                    if(counterValCC >= 3 && counterIdValCC >= 4){
                        instOfContYear.Id = contIdCC[3];
                        lstContYearUpd.add(instOfContYear);
                    }
                    if(counterValCC > 2 && counterIdValCC < 4){
                        instOfContYear.Proposal__c = lstOfValues[35];
                        lstContYearIns.add(instOfContYear);
                    }  
                }
            }else if(counterValCC < 3 && counterIdValCC >= 4){
                Contract_Year__c instOfContYear =  new Contract_Year__c();
                instOfContYear.Id = contIdCC[3];
                lstContYeardel.add(instOfContYear); 
            }
        //}    
        system.debug('counterValCC+++'+counterValCC);
        system.debug('counterIdValCC+++'+counterIdValCC);
        
        system.debug('lstContYeardel+++'+lstContYeardel);
        system.debug('lstContYearUpd+++'+lstContYearUpd);
        system.debug('lstContYearIns+++'+lstContYearIns);
        
        Proposal__c instOfPropSec = new Proposal__c();
        instOfPropSec.Id = lstOfValues[35];
        if(lstOfValues[33]!='000000000000000' && lstOfValues[33]!=' ')
        instOfPropSec.Opportunity_Name__c = lstOfValues[33];
        if(lstOfValues[32]!='000000000000000' && lstOfValues[32]!=' ')
        instOfPropSec.Contact_Name__c = lstOfValues[32];
        if(lstOfValues[34]!=''&& lstOfValues[34]!='undefined')
        instOfPropSec.Product__c = lstOfValues[34];
        
        update instOfPropSec;
        
        if(lstContYeardel.size()>0)
        delete lstContYeardel;
        
        if(lstContYearUpd.size()>0)
        update lstContYearUpd;
        
        if(lstContYearIns.size()>0)
        insert lstContYearIns;
        
        PageReference instOfPgRef = new PageReference('/apex/ProposalDetailAltPage?id='+lstOfValues[35]);
        instOfPgRef.setRedirect(True);
        return instOfPgRef;
    }
}