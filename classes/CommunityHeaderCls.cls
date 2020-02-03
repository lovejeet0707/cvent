/*
//////////////////////////////////////
//      @author Abhishek Pandey     //
/////////////////////////////////////
Version :   1.0
Date : 23rd April 2015
Description:Test class for- CommunitysearchResultClsTest
*/
public class CommunityHeaderCls {
    public User usr{get;set;}
    public CommunityHeaderCls(){
        usr = [SELECT ID,smallphotoURl,ShowLitmosTab__c,Name FROM User WHERE Id=: UserInfo.getUserId()];
    }
    @RemoteAction   
    public static String returnId(String id){
        List<KnowledgeArticleVersion> instOfKAV = new List<KnowledgeArticleVersion>();
        instOfKAV = [SELECT KnowledgeArticleId,ArticleNumber FROM KnowledgeArticleVersion WHERE KnowledgeArticleId=:id AND PublishStatus ='Online'];
        if(instOfKAV.size()>0)
        return instOfKAV[0].ArticleNumber;
        else
        return null;
    }
}