/*
//////////////////////////////////////
//      @author Abhishek Pandey     //
/////////////////////////////////////
Version :   1.0
Date : 6th September 2014
Description : NewEditProposalPage page controller
*/
global  class New_EditProposalCls{

    public New_EditProposalCls(ApexPages.StandardController controller) {
        instOfProp = new Proposal__c();
        lstContYear = new List<Id>();
        if(ApexPages.currentpage().getparameters().get('OppId')!=null && ApexPages.currentpage().getparameters().get('ConId')!=null){
            instOfProp.Opportunity_Name__c  = ApexPages.currentpage().getparameters().get('OppId');
            instOfProp.Contact_Name__c = ApexPages.currentpage().getparameters().get('ConId');
            idOfOppId = instOfProp.Opportunity_Name__c;
            
        }else{
            idOfOppId = null;
        }
    }


    global static Proposal__c instOfProp {get;set;}
    
    global Decimal aR1One {get;set;}
    global static Decimal secYearOne{get;set;}
    global static Decimal thirYearOne {get;set;}
    global static Decimal foryearOne {get;set;}
    global static Decimal aR1OneSec {get;set;}
    global static Decimal secYearOneSec{get;set;}
    global static Decimal thirYearOneSec {get;set;}
    global static Decimal foryearOneSec {get;set;}
    
    global static Decimal aR1Sec{get;set;}
    global static Decimal secYearSec{get;set;}
    global static Decimal thirYearSec{get;set;}
    global static Decimal foryearSec{get;set;}
    global static Decimal aR1SecSec{get;set;}
    global static Decimal secYearSecSec{get;set;}
    global static Decimal thirYearSecSec{get;set;}
    global static Decimal foryearSecSec{get;set;}
    
    global static Decimal aR1Thir{get;set;}
    global static Decimal secYearThir{get;set;}
    global static Decimal thirYearThir{get;set;}
    global static Decimal foryearThir{get;set;}
    global static Decimal aR1ThirSec{get;set;}
    global static Decimal secYearThirSec{get;set;}
    global static Decimal thirYearThirSec{get;set;}
    global static Decimal foryearThirSec{get;set;}
    
    global static Decimal aR1For{get;set;}
    global static Decimal secYearFor{get;set;}
    global static Decimal thirYearFor{get;set;}
    global static Decimal foryearFor{get;set;}
    global static Decimal aR1ForSec{get;set;}
    global static Decimal secYearForSec{get;set;}
    global static Decimal thirYearForSec{get;set;}
    global static Decimal foryearForSec{get;set;}
    
    global static Integer counter{get;set;}
    global static Integer rowCheck{get;set;}
    global static Integer rowCheck1{get;set;}
    global static Integer rowCheck2{get;set;}
    
    global static Id idOfProp{get;set;}
    global static Id idOfOppId{get;set;}
    public List<Id> lstContYear{get;set;}
    
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
    global  New_EditProposalCls(){
        /*
        if(ApexPages.currentpage().getparameters().get('id')!=null){
            instOfProp = [SELECT  Account__c, Account_Name__c,Contact_Name__c,Email__c, Feature_Total_Roll_UP__c, Grand_Total__c, 
                          Main__c, Maintenance_Fee__c,Maintenance_Fee_Rack__c, Opportunity_Name__c, OwnerId, Product__c, Name, Id, 
                          Status__c,Usage_Package_Fee__c,Usage_Package_Fee_Rack__c,(SELECT Annual_Registrants__c, 
                          Annual_Registrants_2__c, Name, Proposal__c, Second_Year_Term__c, Second_Year_Term_Rack__c, SystemModstamp, 
                          Third_Year_Term__c, Third_Year_Term_Rack__c, Fourth_Year_Term_Rack__c, Fourth_Year_Term__c FROM Contract_Years__r) 
                          FROM Proposal__c WHERE Id=: Apexpages.currentpage().getparameters().get('id')];
            Integer count=0;
            rowCheck =0;
            rowCheck1 =0;
            rowCheck2 =0;
            for(Contract_Year__c instOfContYear : instOfProp.Contract_Years__r){
                count++;
                if(instOfContYear.Annual_Registrants__c > 0 || instOfContYear.Second_Year_Term__c > 0 || instOfContYear.Third_Year_Term__c > 0 || instOfContYear.Fourth_Year_Term__c > 0){
                    if(count ==1){
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
                    if(count==2){
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
                    if(count==3){
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
                    if(count==4){
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
                }
            }
            
            idOfProp = ApexPages.currentpage().getparameters().get('id');
            system.debug('idOfProp+++'+idOfProp );
        }else{
            idOfProp = null;
        }*/
        
    }
    global PageReference cancelNow() {
        PageReference instPage;
        system.debug('+++=='+ApexPages.currentpage().getparameters().get('id'));
        system.debug('+++=OppId'+ApexPages.currentpage().getparameters().get('OppId'));
        if(ApexPages.currentpage().getparameters().get('OppId')!=null){
            instPage = new PageReference('/'+ApexPages.currentpage().getparameters().get('OppId'));
            system.debug('TEst');
        }

        if(ApexPages.currentpage().getparameters().get('id')!=null){
            instPage = new PageReference('/apex/ProposalDetailPage?id='+ApexPages.currentpage().getparameters().get('id'));
            system.debug('Test2222');
        }
        instPage.setRedirect(True);
        return instPage;
    }
    global PageReference test(){
        system.debug('aR1One++'+aR1One);
        return null;
    }
    
    @RemoteAction 
    global  static PageReference save(String allValues) {
        String [] lstOfValues = allValues.split(',', -2);
        system.debug(lstOfValues);
        //system.debug('lstOfValues[36]+++'+lstOfValues[35]);
        system.debug('lstOfValues[37]+++'+lstOfValues[36]);
        String idOfOppIdSec; 
        String idOfPropSec; 
        idOfOppIdSec = lstOfValues[36];
        //idOfPropSec = lstOfValues[35];
        system.debug('idOfOppIdSec+++'+idOfOppIdSec);
        system.debug('idOfPropSec+++'+idOfPropSec);
        if(idOfOppIdSec.startswith('006')){
            
            Proposal__c instOfPropSec = new Proposal__c();
            if(lstOfValues[33]!='000000000000000' && lstOfValues[33]!=' ')
            instOfPropSec.Opportunity_Name__c = lstOfValues[33];
            if(lstOfValues[32]!='000000000000000' && lstOfValues[32]!=' ')
            instOfPropSec.Contact_Name__c = lstOfValues[32];
            if(lstOfValues[34]!=''&& lstOfValues[34]!='undefined')
            instOfPropSec.Product__c = lstOfValues[34];
            
            insert instOfPropSec;
            system.debug('CameinINsert');
            List<Contract_Year__c> lstOfContYear = new List<Contract_Year__c>();
            if(Decimal.valueOf(lstOfValues[0]) > 0 || Decimal.valueOf(lstOfValues[1]) > 0 || Decimal.valueOf(lstOfValues[2]) > 0 || Decimal.valueOf(lstOfValues[3]) > 0){
                Contract_Year__c instOfContYear =  new Contract_Year__c();
                instOfContYear.Proposal__c = instOfPropSec.Id;
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
                lstOfContYear.add(instOfContYear);
            }
            
            if(Decimal.valueOf(lstOfValues[8]) > 0 || Decimal.valueOf(lstOfValues[9]) > 0 || Decimal.valueOf(lstOfValues[10]) > 0 || Decimal.valueOf(lstOfValues[11]) > 0){
                Contract_Year__c instOfContYear =  new Contract_Year__c();
                instOfContYear.Proposal__c = instOfPropSec.Id;
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
                lstOfContYear.add(instOfContYear);
            }
            
            if(Decimal.valueOf(lstOfValues[16]) > 0 || Decimal.valueOf(lstOfValues[17]) > 0 || Decimal.valueOf(lstOfValues[18]) > 0 || Decimal.valueOf(lstOfValues[19]) > 0){
                Contract_Year__c instOfContYear =  new Contract_Year__c();
                instOfContYear.Proposal__c = instOfPropSec.Id;
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
                lstOfContYear.add(instOfContYear);
            }
            
            if(Decimal.valueOf(lstOfValues[24]) > 0 || Decimal.valueOf(lstOfValues[25]) > 0 || Decimal.valueOf(lstOfValues[26]) > 0 || Decimal.valueOf(lstOfValues[27]) > 0){
                Contract_Year__c instOfContYear =  new Contract_Year__c();
                instOfContYear.Proposal__c = instOfPropSec.Id;
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
                lstOfContYear.add(instOfContYear);
            }
            
            //For CC
            if(lstOfValues[34] == 'Event & Crowd Compass'){
                if(Decimal.valueOf(lstOfValues[37]) > 0 || Decimal.valueOf(lstOfValues[38]) > 0 || Decimal.valueOf(lstOfValues[39]) > 0 || Decimal.valueOf(lstOfValues[40]) > 0){
                    Contract_Year__c instOfContYear =  new Contract_Year__c();
                    instOfContYear.Proposal__c = instOfPropSec.Id;
                    instOfContYear.Row__c = 5;
                    if(Decimal.valueOf(lstOfValues[37])!=0){
                        instOfContYear.Annual_Registrants__c = Decimal.valueOf(lstOfValues[37]);
                    }
                    if(Decimal.valueOf(lstOfValues[38])!=0){
                        instOfContYear.Second_Year_Term__c = Decimal.valueOf(lstOfValues[38]);
                    }
                    if(Decimal.valueOf(lstOfValues[39])!=0){
                        instOfContYear.Third_Year_Term__c = Decimal.valueOf(lstOfValues[39]);
                    }
                    if(Decimal.valueOf(lstOfValues[40])!=0){
                        instOfContYear.Fourth_Year_Term__c = Decimal.valueOf(lstOfValues[40]);
                    }
                    if(Decimal.valueOf(lstOfValues[41])!=0){
                        instOfContYear.Annual_Registrants__c = Decimal.valueOf(lstOfValues[41]);
                    }
                    if(Decimal.valueOf(lstOfValues[42])!=0){
                        instOfContYear.Second_Year_Term_Rack__c = Decimal.valueOf(lstOfValues[42]);
                    }
                    if(Decimal.valueOf(lstOfValues[43])!=0){
                        instOfContYear.Third_Year_Term_Rack__c = Decimal.valueOf(lstOfValues[43]);
                    }
                    if(Decimal.valueOf(lstOfValues[44])!=0){
                        instOfContYear.Fourth_Year_Term_Rack__c = Decimal.valueOf(lstOfValues[44]);
                    }
                    lstOfContYear.add(instOfContYear);
                }
                
                if(Decimal.valueOf(lstOfValues[45]) > 0 || Decimal.valueOf(lstOfValues[46]) > 0 || Decimal.valueOf(lstOfValues[47]) > 0 || Decimal.valueOf(lstOfValues[48]) > 0){
                    Contract_Year__c instOfContYear =  new Contract_Year__c();
                    instOfContYear.Proposal__c = instOfPropSec.Id;
                    instOfContYear.Row__c = 6;
                    if(Decimal.valueOf(lstOfValues[45])!=0){
                        instOfContYear.Annual_Registrants__c = Decimal.valueOf(lstOfValues[45]);
                    }
                    if(Decimal.valueOf(lstOfValues[46])!=0){
                        instOfContYear.Second_Year_Term__c = Decimal.valueOf(lstOfValues[46]);
                    }
                    if(Decimal.valueOf(lstOfValues[47])!=0){
                        instOfContYear.Third_Year_Term__c = Decimal.valueOf(lstOfValues[47]);
                    }
                    if(Decimal.valueOf(lstOfValues[48])!=0){
                        instOfContYear.Fourth_Year_Term__c = Decimal.valueOf(lstOfValues[48]);
                    }
                    if(Decimal.valueOf(lstOfValues[49])!=0){
                        instOfContYear.Annual_Registrants__c = Decimal.valueOf(lstOfValues[49]);
                    }
                    if(Decimal.valueOf(lstOfValues[50])!=0){
                        instOfContYear.Second_Year_Term_Rack__c = Decimal.valueOf(lstOfValues[50]);
                    }
                    if(Decimal.valueOf(lstOfValues[51])!=0){
                        instOfContYear.Third_Year_Term_Rack__c = Decimal.valueOf(lstOfValues[51]);
                    }
                    if(Decimal.valueOf(lstOfValues[52])!=0){
                        instOfContYear.Fourth_Year_Term_Rack__c = Decimal.valueOf(lstOfValues[52]);
                    }
                    lstOfContYear.add(instOfContYear);
                }
                
                if(Decimal.valueOf(lstOfValues[53]) > 0 || Decimal.valueOf(lstOfValues[54]) > 0 || Decimal.valueOf(lstOfValues[55]) > 0 || Decimal.valueOf(lstOfValues[56]) > 0){
                    Contract_Year__c instOfContYear =  new Contract_Year__c();
                    instOfContYear.Proposal__c = instOfPropSec.Id;
                    instOfContYear.Row__c = 7;
                    if(Decimal.valueOf(lstOfValues[53])!=0){
                        instOfContYear.Annual_Registrants__c = Decimal.valueOf(lstOfValues[53]);
                    }
                    if(Decimal.valueOf(lstOfValues[54])!=0){
                        instOfContYear.Second_Year_Term__c = Decimal.valueOf(lstOfValues[54]);
                    }
                    if(Decimal.valueOf(lstOfValues[55])!=0){
                        instOfContYear.Third_Year_Term__c = Decimal.valueOf(lstOfValues[55]);
                    }
                    if(Decimal.valueOf(lstOfValues[56])!=0){
                        instOfContYear.Fourth_Year_Term__c = Decimal.valueOf(lstOfValues[56]);
                    }
                    if(Decimal.valueOf(lstOfValues[57])!=0){
                        instOfContYear.Annual_Registrants__c = Decimal.valueOf(lstOfValues[57]);
                    }
                    if(Decimal.valueOf(lstOfValues[58])!=0){
                        instOfContYear.Second_Year_Term_Rack__c = Decimal.valueOf(lstOfValues[58]);
                    }
                    if(Decimal.valueOf(lstOfValues[59])!=0){
                        instOfContYear.Third_Year_Term_Rack__c = Decimal.valueOf(lstOfValues[59]);
                    }
                    if(Decimal.valueOf(lstOfValues[60])!=0){
                        instOfContYear.Fourth_Year_Term_Rack__c = Decimal.valueOf(lstOfValues[60]);
                    }
                    lstOfContYear.add(instOfContYear);
                }
                if(Decimal.valueOf(lstOfValues[61]) > 0 || Decimal.valueOf(lstOfValues[62]) > 0 || Decimal.valueOf(lstOfValues[63]) > 0 || Decimal.valueOf(lstOfValues[64]) > 0){
                    Contract_Year__c instOfContYear =  new Contract_Year__c();
                    instOfContYear.Proposal__c = instOfPropSec.Id;
                    instOfContYear.Row__c = 8;
                    if(Decimal.valueOf(lstOfValues[61])!=0){
                        instOfContYear.Annual_Registrants__c = Decimal.valueOf(lstOfValues[61]);
                    }
                    if(Decimal.valueOf(lstOfValues[62])!=0){
                        instOfContYear.Second_Year_Term__c = Decimal.valueOf(lstOfValues[62]);
                    }
                    if(Decimal.valueOf(lstOfValues[63])!=0){
                        instOfContYear.Third_Year_Term__c = Decimal.valueOf(lstOfValues[63]);
                    }
                    if(Decimal.valueOf(lstOfValues[64])!=0){
                        instOfContYear.Fourth_Year_Term__c = Decimal.valueOf(lstOfValues[64]);
                    }
                    if(Decimal.valueOf(lstOfValues[65])!=0){
                        instOfContYear.Annual_Registrants__c = Decimal.valueOf(lstOfValues[65]);
                    }
                    if(Decimal.valueOf(lstOfValues[66])!=0){
                        instOfContYear.Second_Year_Term_Rack__c = Decimal.valueOf(lstOfValues[66]);
                    }
                    if(Decimal.valueOf(lstOfValues[67])!=0){
                        instOfContYear.Third_Year_Term_Rack__c = Decimal.valueOf(lstOfValues[67]);
                    }
                    if(Decimal.valueOf(lstOfValues[68])!=0){
                        instOfContYear.Fourth_Year_Term_Rack__c = Decimal.valueOf(lstOfValues[68]);
                    }
                    lstOfContYear.add(instOfContYear);
                }
            } 
            //For CC
            if(lstOfContYear.size()>0)
            insert lstOfContYear;
            
            PageReference instPage = new PageReference('/apex/ProposalDetailAltPage?id='+instOfPropSec.id);
            instPage.setRedirect(True);
            return instPage;
        }
        
        
        return null;
    }

}