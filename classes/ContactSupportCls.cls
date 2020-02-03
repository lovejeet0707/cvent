public class ContactSupportCls {
    public String searchTerm {get; set;}
    public String productSel {get; set;}
    public String callUsURL {get;set;}
    public string phoneNumber{get;set;}
    Public string selectedname{get;set;}
    Public string selectedLanguage{get;set;}
    public User usr{get;set;}
    public ContactSupportCls(ApexPages.StandardController controller) {
        searchTerm = '';
        productSel = '';
        
         usr = [SELECT ID,contact.EU_Cvent_Account_ID__c,smallphotoURl,ShowLitmosTab__c,Name,Contact.Account.Service_Tier__c FROM User WHERE Id=: UserInfo.getUserId()]; //
        callUsURL = 'http://www.cvent.com/en/contact/support-hours-and-numbers.shtml';
        if(String.IsNotBlank(usr.Contact.Account.Service_Tier__c)){
            callUsURL = callUsURL+'?st='+usr.Contact.Account.Service_Tier__c;
        }
    }
    public PageReference search() {
        system.debug(searchTerm);
        system.debug(productSel);        
        PageReference pageRef = new PageReference('/apex/CommunitysearchResultPage?searchFor='+searchTerm+'&productSel='+productSel);
        pageRef.setRedirect(true);
        system.debug(pageRef);        
        return pageRef;
        
    }
    public PageReference requestCall(){
      string PhoneNo;
      //String language = UserInfo.getLanguage();
      Id userId = UserInfo.getUserId();
      User userInfoRec = [SELECT Id,ContactId,Contact.Account.Service_Tier__c FROM User WHERE Id =: userId];
      map<string,Community_Country_ISD_Codes__c> codes = Community_Country_ISD_Codes__c.getAll();           
      string countryCode = codes.get(selectedname).ISD_Code__c;
      system.debug('---countryCode'+countryCode);
      PhoneNo = phoneNumber.startsWith('0') ? countryCode+phoneNumber.substring(1):countryCode+phoneNumber;
      PhoneNo = '011'+PhoneNo;
      String callcenterURL;
      if(selectedLanguage == 'German')
      {
          
          callcenterURL = 'https://home-c29.incontact.com/inContact/Manage/Scripts/Spawn.aspx?scriptName=Spawn_ClickToCall&bus_no=4597294&scriptId=25926069&skill_no=4078033&p1='+PhoneNo+'&p2=5716354955&Guid=0789f289-3474-4647-9080-db45fa3e32cb';
      }
      else if(selectedLanguage == 'English')
      {
          if(userInfoRec.Contact.Account.Service_Tier__c!='' && (userInfoRec.Contact.Account.Service_Tier__c=='Gold' || userInfoRec.Contact.Account.Service_Tier__c=='Platinum')){
              callcenterURL = 'https://home-c29.incontact.com/inContact/Manage/Scripts/Spawn.aspx?scriptName=Spawn_ClickToCall&bus_no=4597294&scriptId=25926069&skill_no=4078033&p1='+PhoneNO+'&p2=5716354951&Guid=0789f289-3474-4647-9080-db45fa3e32cb';
          }
          else
          {
              callcenterURL = 'https://home-c29.incontact.com/inContact/Manage/Scripts/Spawn.aspx?scriptName=Spawn_ClickToCall&bus_no=4597294&scriptId=25926069&skill_no=4078033&p1='+PhoneNo+'&p2=5716354949&Guid=0789f289-3474-4647-9080-db45fa3e32cb';
          }
      }
      system.debug('---PhoneNo'+PhoneNo);
      /*PageReference pageRef = new PageReference(callcenterURL);
        pageRef.setRedirect(true);
        system.debug(pageRef);        
        return pageRef;*/
        System.debug('callcenterURL*****'+callcenterURL);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(callcenterURL);
        request.setMethod('GET');
        if(!Test.isRunningTest()){HttpResponse response = http.send(request);System.debug('response*********'+response);}
        
        PageReference pageRef = new PageReference('/');
        pageRef.setRedirect(true);
        system.debug(pageRef);        
        return pageRef;
    }   
     Public List<Selectoption> getCountryCode(){
        List<Selectoption> code = new List<selectoption>();
        code.add(new selectoption('USA','United States and Canada'));
        for(Country_Phone_Codes__c c :[SELECT name,id,Country_Name__c,ISD_Code__c FROM Country_Phone_Codes__c ORDER BY Country_Name__c]){
          if(c.name!='USA')
              code.add(new selectoption(c.name,c.Country_Name__c));
        }
        return code; 
    }
}