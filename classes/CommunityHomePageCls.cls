/*
//////////////////////////////////////
//      @author Abhishek Pandey     //
/////////////////////////////////////
Version :   1.0
Date : 18th Feb 2015
Description-Test Class Name-CommunitysearchResultClsTest
*/
global class CommunityHomePageCls{
    //---------------------google Serahc Console...........
    public User usr{get;set;}
    /*HSR:2ndFeb2018:Initializing Variables to fetch if this is pblic site or authenticated community*/
    public Boolean isPublicSite{get;set;}
    /*HSR:9th Jan :Initializing Variables to make the Banners Dynamic*/
    Map<Id,String> commBannerBannerMap ;
    public Map<Id,String> attachId{get;set;}
    /*........................ENDS HERE..............................*/
    public String search { get; set; }
    // Instance fields
    public String searchTerm {get; set;}
    public String productSel {get; set;}
    public String selectedMovie {get; set;}
    public integer classvalue {get;set;}
    public integer counter {get;set;}
    public List<Announcements__c> lstAnnounce = new List<Announcements__c>();
    //public List<searchResult> lstSearchResult{get;set;}
    public List<DataList> dataLst{get;set;}
    public List<NetworkMem> lstNetMem{get;set;}
    public Boolean showPrime{get;set;}
    Public String primeString{get;set;}
    //public string testVariable{get;set;}
    public List<Community_Banner__c> commBanner{get;set;}
    User userObj ;
    public Boolean announcementCheck{get;set;}
    public String callUsURL {get;set;}
    public string phoneNumber{get;set;}
    Public string selectedname{get;set;}
    Public string selectedLanguage{get;set;}
    //public String tempString{get;set;}
    public PageReference search() { 
        //testVariable='Inside Method Checkpoint';
        system.debug(searchTerm);
        system.debug(productSel);        
        PageReference pageRef = new PageReference('/apex/CommunitysearchResultPage?searchFor='+searchTerm+'&productSel='+productSel+'&nooverride=1');
        pageRef.setRedirect(true);
        system.debug(pageRef);        
        return pageRef;
        
    }
    public PageReference pageDirect(){
        PageReference pg = new PageReference('https://community.cvent.com/home');
        pg.setRedirect(true);
        return pg;
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
    public void announcementCheckTrue(){

        //announcementCheck = userObj.Announcement_Clicked_Dev__c;
        //tempString ='Inside Method';
    }
    public CommunityHomePageCls(){
        //---------------------google Serahc Console........... 
        usr = [SELECT ID,smallphotoURl,ShowLitmosTab__c,Name,Contact.Account.Service_Tier__c FROM User WHERE Id=: UserInfo.getUserId()]; //
        callUsURL = 'http://www.cvent.com/en/contact/support-hours-and-numbers.shtml';
        if(String.IsNotBlank(usr.Contact.Account.Service_Tier__c)){
            callUsURL = callUsURL+'?st='+usr.Contact.Account.Service_Tier__c;
        }
        
        isPublicSite = false;
        //Checking if this is a Public Site User.... 
        if(UserInfo.getUserId() == '005o0000001zagpAAA')
            isPublicSite = true;
        System.debug('Inside Constructor');
        /*HSR:9th Jan :Community Banner Id Set......................*/
        commBannerBannerMap = new Map<Id,String>();
        attachId = new Map<Id,String>();
        commBanner = new List<Community_Banner__c>();
        For(Community_Banner__c commBan : [SELECT Id,Banner_Link__c,(SELECT Id,parentId FROM Attachments) FROM Community_Banner__c WHERE IsDisplayed__c=TRUE AND Order__c!=null ORDER BY Order__c ASC])
        {
            if(commBan.Banner_Link__c!=null)
            commBannerBannerMap.put(commBan.Id,commBan.Banner_Link__c);
            else
            commBannerBannerMap.put(commBan.Id,'NoLink');
            commBanner.add(commBan);
        }
        /*For(Attachment attachObj : [SELECT Id,parentId FROM Attachment WHERE parentId IN : commBannerBannerMap.KeySet()])
        {
            attachId.put(attachObj.Id,commBannerBannerMap.get(attachObj.parentId));
        }*/
        System.debug('attachId***************'+attachId);
        /*..........................ENDS HERE.......................*/
        userObj = [SELECT Announcement_Clicked_Dev__c FROM User WHERE Id = : UserInfo.getUserId() LIMIT 1];
        announcementCheck = userObj.Announcement_Clicked_Dev__c;
        //commBanner = new List<Community_Banner__c>([SELECT Id,Banner_Image__c FROM Community_Banner__c WHERE Active__c = true]);
        searchTerm = '';
        productSel = '';
        lstAnnounce = new List<Announcements__c>();
        lstAnnounce = [SELECT Id,Data__c,Is_it_Pime__c FROM Announcements__c WHERE Is_Active__c = true ORDER BY CreatedDate ASC];
        dataLst = new List<DataList>();
        Integer counter=0;
        for(Announcements__c instA : lstAnnounce){
            counter++;
            DataList instDatList = new DataList('*'+' '+instA.Data__c);
            if(instA.Is_it_Pime__c == false)
            dataLst.add(instDatList);
            
            if(instA.Is_it_Pime__c == true && instA.Data__c!= '' && instA.Data__c!=null){
                showPrime = true;
                primeString = instA.Data__c;
            }
        }
        system.debug('+++++++'+Network.getNetworkId());
        List<NetworkMember> lstNetMemAc = new List<NetworkMember>();
        
        //if(Test.isRunningTest())
        //lstNetMemAc  = [SELECT Id, Member.SmallPhotoUrl,Member.FullPhotoUrl,MemberId,Member.Name,Member.FirstName,Member.LastName FROM NetworkMember WHERE MemberId=:UserInfo.getUserId()];
        //else
        //lstNetMemAc = [SELECT Id, Member.SmallPhotoUrl,Member.FullPhotoUrl,MemberId,Member.Name,Member.FirstName,Member.LastName FROM NetworkMember WHERE (Not Member.CompanyName like '%Cvent%') AND Member.IsActive=true AND NetworkId=:Network.getNetworkId() ORDER BY ReputationPoints DESC Limit 10  ];
        //lstNetMemAc = [SELECT Id, Member.SmallPhotoUrl,Member.FullPhotoUrl,MemberId,Member.Name,Member.FirstName,Member.LastName FROM NetworkMember WHERE (Not Member.Name like '%SOPS%') Limit 10  ];
        lstNetMemAc = [SELECT Id, Member.SmallPhotoUrl,Member.FullPhotoUrl,MemberId,Member.Name,Member.FirstName,Member.LastName FROM NetworkMember WHERE (Not Member.CompanyName like '%Cvent%') AND Member.IsActive=true AND NetworkId=:Network.getNetworkId() ORDER BY ReputationPoints DESC Limit 10 ];
        lstNetMem = new List<NetworkMem>();
        for(NetworkMember instNetMem : lstNetMemAc){
            NetworkMem netMem;
            if(instNetMem.Member.SmallPhotoUrl != null)
            netMem = new NetworkMem(instNetMem.MemberId,instNetMem.Member.SmallPhotoUrl,instNetMem.Member.FullPhotoUrl,instNetMem.Member.Name);
            else
            netMem = new NetworkMem(instNetMem.MemberId,'/profilephoto/005/F','/profilephoto/005/F',instNetMem.Member.FirstName +' '+ instNetMem.Member.LastName);
            lstNetMem.add(netMem);
        }
    }
    
    public class NetworkMem{
        public Id UserId{get;set;}
        public string sphoto{get;set;}
        public string fphoto{get;set;}
        public string uname{get;set;}
        public NetworkMem(Id UserId, String sphoto,String fphoto,String uname){
            this.UserId = UserId;
            this.sphoto = sphoto;
            this.fphoto = fphoto;
            this.uname = uname;
        }
    }
    public class DataList{  
        public String Announcement{get; set;}
        public DataList(String Announcement){
            this.Announcement = Announcement;
        }
    }
    //Calling remote method to update the checkbox in the User Object to show/hide the announcement....
    @RemoteAction
    global static String updateAnnouncement() {
        User userRec=new User(Id=UserInfo.getUserId());
        userRec.Announcement_Clicked_Dev__c =True;
        update userRec;
        return userRec.Id;
    }

}