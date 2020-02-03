/*
//////////////////////////////////////
//      @author Abhishek Pandey     //
/////////////////////////////////////
Version :   1.0
Date : 6th April 2015
Description:Test class- CommunitysearchResultClsTest
*/
public class CommunityAnnouncementCls {
    public List<Announcements__c> lstAnn{get;set;}
    public CommunityAnnouncementCls(){
        lstAnn = new List<Announcements__c>();
        lstAnn = [SELECT Id,Data__c,Name,Popup_Title__c,Data_Description__c,Video_Link__c FROM Announcements__c WHERE Is_Active__c=true ORDER BY CreatedDate DESC];
    }
}