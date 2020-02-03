public class CventCommunityHeaderClass{
    public User usr{get;set;}
    /*HSR:2ndFeb2018:Initializing Variables to fetch if this is pblic site or authenticated community*/
    public Boolean isPublicSite{get;set;}
    public CventCommunityHeaderClass(){
        usr = [SELECT Id,ShowLitmosTab__c,SmallPhotoUrl,contact.EU_Cvent_Account_ID__c FROM User WHERE Id = : UserInfo.getUserId()];
        isPublicSite = false;
        //Checking if this is a Public Site User.... 
        if(UserInfo.getUserId() == '005o0000001zagpAAA')
            isPublicSite = true;
    }
}