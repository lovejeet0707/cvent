// ===============================
// AUTHOR           : Shanu Aggarwal    
// CREATED DATE     : 20 Apr 2017
// PURPOSE          : Onsite Troubleshooting Hardware Page
// TEST CLASS       :   
// SPECIAL NOTES    :
// ===============================
public class OnsiteTroubleShootingController{
    
    public string answer {get;set;}
  
    public Onsite_Troubleshooting__c currentQues{get;set;}
    
    Map<Id,Onsite_Troubleshooting__c> quesVsOnsiteMap;
    Map<Integer,Id> SNoVscurrentQuesIdMap;
    Onsite_Troubleshooting__c previousQues ; 
    
    //Loading Questions (Constructor)
    public OnsiteTroubleShootingController (ApexPages.StandardController std){
        answer=null;
        previousQues=new Onsite_Troubleshooting__c();
        quesVsOnsiteMap = new Map<Id,Onsite_Troubleshooting__c>((List<Onsite_Troubleshooting__c>)Database.query(getQuery()));
        SNoVscurrentQuesIdMap = new Map<Integer,Id>();
        
        for(Onsite_Troubleshooting__c ot : quesVsOnsiteMap.values()){
            SNoVscurrentQuesIdMap.put(Integer.ValueOf(ot.Name), ot.Id);
        }
        //Get First Question
        currentQues = quesVsOnsiteMap.get(SNoVscurrentQuesIdMap.get(1));
        
    }

    
    //Next Button 
    public PageReference doNext(){
        previousQues=currentQues;
        if(answer!=null){
            Id nextQuesId = SNoVscurrentQuesIdMap.get(Integer.valueOf(answer));
            currentQues = quesVsOnsiteMap.get(nextQuesId);
        }else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select an Answer'));
            return null;
        }
        
        answer=null;
        return null;
        
    }
    

    //Previous Button 
    public PageReference doPrevious(){
          
        if(previousQues!=null){
            currentQues=previousQues;
            answer=null;
        }
        
        return null;
                
    }

    //Loading Answers
    public List<SelectOption> getOptions(){
        
        List<SelectOption> optionsList = new List<SelectOption>(); 

        if(currentQues!=null && quesVsOnsiteMap.containsKey(currentQues.Id)){

                //First Question 
                if(currentQues.Name == '1'){
                    optionsList.add(new SelectOption('2','The printer is not printing.')); 
                    optionsList.add(new SelectOption('7','The iPads won\'t connect to the printer.'));
                    optionsList.add(new SelectOption('14','Printer calibration failed.'));
                    optionsList.add(new SelectOption('11','The router isn\'t connecting.'));
                    optionsList.add(new SelectOption('17','My badges don\'t look right.'));
                }else if(currentQues.Name == '17'){
                    optionsList.add(new SelectOption('22','They\'re spotty.'));
                    optionsList.add(new SelectOption('23','Some are being skipped.'));
                    optionsList.add(new SelectOption('20','Text is off center, squished, or overlapping.'));
                }else if(currentQues.Answer_1__c!=null && currentQues.Answer_2__c!=null){
                        optionsList.add(new SelectOption(currentQues.Answer_1__c,'Yes'));
                        optionsList.add(new SelectOption(currentQues.Answer_2__c,'No'));
                }
            

            return optionsList;
        }
        return null;
    }
    

    //Querying All Questions (Dynamic)
    public string getQuery(){
        
        DescribeSObjectResult describeResult = Onsite_Troubleshooting__c.getSObjectType().getDescribe();        
        
        List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet() );      
       
        String query =' SELECT ' + String.join( fieldNames, ',' ) +' FROM ' + describeResult.getName() + ' ORDER BY Name ASC';  
              
        return query;
    }

    


}