global class ProposalDetailAltCls{
    public Proposal__c instOfProp{get;set;}
    global List<wrapperPropFields> instOfWrpPF{get;set;}
    public List<wrapperFeeStructure> instOfwrapperFS{get;set;} 
    public Decimal counter;
    global ProposalDetailAltCls(ApexPages.StandardController controller) {
        instOfProp = [SELECT  Account__c, Account_Name__c,Contact_Name__c,Email__c, Feature_Total_Roll_UP__c, Grand_Total__c, 
                      Main__c, Maintenance_Fee__c,Maintenance_Fee_Rack__c, Opportunity_Name__c, OwnerId, Product__c, Name, Id, 
                      Status__c,Usage_Package_Fee__c,Usage_Package_Fee_Rack__c,(SELECT Row__c ,Annual_Registrants__c, 
                      Annual_Registrants_2__c, Name, Proposal__c, Second_Year_Term__c, Second_Year_Term_Rack__c, SystemModstamp, 
                      Third_Year_Term__c, Third_Year_Term_Rack__c, Fourth_Year_Term_Rack__c, Fourth_Year_Term__c FROM Contract_Years__r ORDER BY Row__c ASC) 
                      FROM Proposal__c WHERE Id=: Apexpages.currentpage().getparameters().get('id')];
        counter = 0;
        instOfWrpPF = getData();
        instOfwrapperFS = getDataFeeStructure();
    }
    
    public List<wrapperPropFields> getData(){
        List<wrapperPropFields> instOfWrpPF = new List<wrapperPropFields>(); 
        /*for(Contract_Year__c instOfContYear :  instOfProp.Contract_Years__r){
            system.debug('++'+instOfContYear.Row__c);
            if(instOfContYear.Row__c == counter){
                counter++;
            }
            system.debug('1stdebugRow++'+instOfContYear.Row__c);
            system.debug('1stdebugCounter++'+counter);
            if(instOfContYear.Row__c == counter){ 
                instOfWrpPF.add(new wrapperPropFields(instOfContYear.Annual_Registrants__c,instOfContYear.Second_Year_Term__c,instOfContYear.Third_Year_Term__c,instOfContYear.Fourth_Year_Term__c,instOfContYear.Annual_Registrants__c,instOfContYear.Second_Year_Term_Rack__c,instOfContYear.Third_Year_Term_Rack__c,instOfContYear.Fourth_Year_Term_Rack__c));    
                counter++;
                system.debug('2stdebugRow++'+instOfContYear.Row__c);
                system.debug('2stdebugCounter++'+counter);
            }else{
                counter = instOfContYear.Row__c - counter;
                for(Integer i=1; i<counter; i++){
                    instOfWrpPF.add(new wrapperPropFields(0,0,0,0,0,0,0,0));
                }
                instOfWrpPF.add(new wrapperPropFields(instOfContYear.Annual_Registrants__c,instOfContYear.Second_Year_Term__c,instOfContYear.Third_Year_Term__c,instOfContYear.Fourth_Year_Term__c,instOfContYear.Annual_Registrants__c,instOfContYear.Second_Year_Term_Rack__c,instOfContYear.Third_Year_Term_Rack__c,instOfContYear.Fourth_Year_Term_Rack__c));    
                counter = instOfContYear.Row__c;
                counter ++;
            }
        }*/
        Integer counterSec;
        map<Decimal,Contract_Year__c> mapRowCont = new map<Decimal,Contract_Year__c>();
        for(Contract_Year__c instOfContYear : instOfProp.Contract_Years__r){
            mapRowCont.put(instOfContYear.Row__c,instOfContYear);           
        }
        
        for(Integer  i=1; i<=8; i++ ){
            try{
                Contract_Year__c instOfContYear = mapRowCont.get(i);
                instOfWrpPF.add(new wrapperPropFields(instOfContYear.Annual_Registrants__c,instOfContYear.Second_Year_Term__c,instOfContYear.Third_Year_Term__c,instOfContYear.Fourth_Year_Term__c,instOfContYear.Annual_Registrants__c,instOfContYear.Second_Year_Term_Rack__c,instOfContYear.Third_Year_Term_Rack__c,instOfContYear.Fourth_Year_Term_Rack__c));    
            }catch(exception e){
                instOfWrpPF.add(new wrapperPropFields(0,0,0,0,0,0,0,0));
            }    
        }
        return instOfWrpPF;
    }   
    
    public List<wrapperFeeStructure> getDataFeeStructure(){
        List<wrapperFeeStructure> instOfWrpFS = new List<wrapperFeeStructure>();
        instOfWrpFS.add(new wrapperFeeStructure(instOfProp.Maintenance_Fee__c,instOfProp.Usage_Package_Fee__c,instOfProp.Maintenance_Fee_Rack__c,instOfProp.Usage_Package_Fee_Rack__c,instOfProp.Feature_Total_Roll_UP__c));
        return instOfWrpFS;
    }
     
    global class wrapperPropFields{
        global Decimal aR1One {get;set;}
        global Decimal secYearOne{get;set;}
        global Decimal thirYearOne {get;set;}
        global Decimal foryearOne {get;set;}
        global Decimal aR1OneSec {get;set;}
        global Decimal secYearOneSec{get;set;}
        global Decimal thirYearOneSec {get;set;}
        global Decimal foryearOneSec {get;set;}
        
        global wrapperPropFields(Decimal aR1One,Decimal secYearOne,Decimal thirYearOne,Decimal foryearOne,Decimal aR1OneSec,Decimal secYearOneSec,Decimal thirYearOneSec,Decimal foryearOneSec){
            system.debug('aR1One+++'+aR1One);
            if(aR1One!=null){
                this.aR1One = aR1One;
            }else{
                this.aR1One = 0;
            }
            if(secYearOne !=null){
                this.secYearOne =  secYearOne;
            }else{
                this.secYearOne = 0;
            } 
            if(thirYearOne != null){
                this.thirYearOne = thirYearOne;
            }else{
                this.thirYearOne = 0;
            }
            if(foryearOne!= null){
                this.foryearOne= foryearOne;
            }else{
                this.foryearOne = 0;
            }
            if(aR1OneSec!= null){
                this.aR1OneSec= aR1OneSec;
            }else{
                this.aR1OneSec= 0;
            }
            if(secYearOneSec!= null){
                this.secYearOneSec = secYearOneSec;
            }else{
                this.secYearOneSec = 0;
            }
            if(thirYearOneSec!= null){
                this.thirYearOneSec = thirYearOneSec;
            }else{
                this.thirYearOneSec = 0;
            }
            if(foryearOneSec!= null){
                this.foryearOneSec = foryearOneSec;
            }else{
                this.foryearOneSec = 0;
            }

        }
    }
    
    public class wrapperFeeStructure{
        public Decimal maintenanceFee {get;set;}
        public Decimal usagePackageFee {get;set;}
        public Decimal maintenanceFeeRack {get;set;}
        public Decimal usagePackageFeeRack {get;set;}
        public Decimal featureTotalRollUP {get;set;}
        
        public wrapperFeeStructure(Decimal maintenanceFee,Decimal usagePackageFee,Decimal maintenanceFeeRack,Decimal usagePackageFeeRack,Decimal featureTotalRollUP){
            this.maintenanceFee = maintenanceFee;
            this.usagePackageFee = usagePackageFee;
            this.maintenanceFeeRack = maintenanceFeeRack;
            this.usagePackageFeeRack = usagePackageFeeRack; 
            this.featureTotalRollUP = featureTotalRollUP ;
        }
    }
    public PageReference editNow(){
        PageReference instOfPageRef = new PageReference('/apex/UpdateProposalPage?id='+Apexpages.currentpage().getparameters().get('id'));
        instOfPageRef.setRedirect(True);
        return instOfPageRef; 
    }
    public PageReference deleteNow(){
        Proposal__c instOFProp = new Proposal__c();
        instOFProp = [SELECT Id,Opportunity_Name__c,(SELECT Id FROM Contract_Years__r) FROM Proposal__c WHERE Id=: Apexpages.currentpage().getparameters().get('id')];
        
        List<Contract_Year__c> lstContYear = [SELECT Id FROM Contract_Year__c WHERE Proposal__c =: Apexpages.currentpage().getparameters().get('id') ];        
        
        if(lstContYear.size()>0)
        delete lstContYear;
        
        delete instOFProp; 
        
        PageReference instOfPageRef = new PageReference('/'+instOfProp.Opportunity_Name__c);
        instOfPageRef.setRedirect(True);
        return instOfPageRef; 
    }
    public PageReference sendPropNow(){
        PageReference instOfPageRef = new PageReference('/apex/loop__looplus?eid='+instOfProp.Id+'&OpportunityId='+instOfProp.Opportunity_Name__c+'&sessionId='+UserInfo.getSessionId()+'&ContactId='+instOfProp.Contact_Name__c);
        instOfPageRef.setRedirect(True);
        return instOfPageRef;
    }
}