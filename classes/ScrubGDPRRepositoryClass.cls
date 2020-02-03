/* ===============================
AUTHOR     :     Hemant Rana
CREATED DATE   : 12 April 2018
PURPOSE     :    It returns a list of records from excel that are not GDPR Processed in system.
TEST CLASS :     ScrubGDPRRepositoryClassTest
============================= 
*/
public class ScrubGDPRRepositoryClass{
public Blob csvFileBody{get;set;}
public string csvAsString{get;set;}
public String[] csvFileLines{get;set;}
public Set<String> emailSet{get;set;}
public Set<String> emailSetV{get;set;}
public Map<String,Boolean> emailVsGDPRMap{get;set;}
public string contentType { get; set; }


  public ScrubGDPRRepositoryClass(){
    contentType = 'text/html';
    csvFileLines = new String[]{};
    emailSet = New Set<String>(); 
    emailSetV = New Set<String>(); 
    emailVsGDPRMap = New Map<String,Boolean>();
  }
  
  public void compareRecords(){
       try{
           contentType = 'application/vnd.ms-excel#GDPRRecords.csv';
           csvAsString = csvFileBody.toString();
           csvFileLines = csvAsString.split('\n'); 
            
           for(Integer i=1;i<csvFileLines.size();i++){
               string[] csvRecordData = csvFileLines[i].split(',');
                
               for(string s : csvRecordData){
                 emailSet.add(s.trim());  
               }
           }
           
           For(String ss : emailSet){
                 emailSetV.add(ss.trim());
           }
           For(GDPR_Central_Repository__c GDPRRepObj : [SELECT Email__c,Alternate_Email__c ,Is_GDPR__c FROM GDPR_Central_Repository__c WHERE Email__c IN : emailSetV or Alternate_Email__c IN : emailSetV])
           {
              if(emailSetV.contains(GDPRRepObj.Email__c) && GDPRRepObj.Is_GDPR__c){
                 emailSetV.remove(GDPRRepObj.Email__c);
              }
              if(emailSetV.contains(GDPRRepObj.Alternate_Email__c) && GDPRRepObj.Is_GDPR__c){
                 emailSetV.remove(GDPRRepObj.Alternate_Email__c);
              }
           }          
        }
        catch (Exception e)
        {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while importing data Please make sure input csv file is correct');
            ApexPages.addMessage(errorMessage);
        }  
  }
}