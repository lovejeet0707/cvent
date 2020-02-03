/*
//////////////////////////////////////
//      @author Abhishek Pandey     //
/////////////////////////////////////
Version :   1.0
Date : 6th April 2015
Description-Test Class Name-CommunitysearchResultClsTest
*/
public class CommunityUserDetCls {
    public User instOfUsr {get;set;}
    public boolean displayPopup {get; set;}  
    public Integer questCount{get;set;}
    public Integer ansCount{get;set;}
    public Integer bestAnsCount{get;set;}
    public Boolean flag{get;set;}
    public Boolean flagAbtMe{get;set;}
    
    public CommunityUserDetCls(){
        instOfUsr = new User();
        instOfUsr = [SELECT Id,FullPhotoUrl,Firstname,Lastname,AboutMe FROM User WHERE Id=:Apexpages.currentpage().getparameters().get('id')];

        flagAbtMe = false;
        if(instOfUsr.AboutMe != null && instOfUsr.AboutMe!='')
        flagAbtMe = true;
        
        List<Question> lstQues = [SELECT BestReplyId, CreatedById, CreatedDate, IsDeleted, LastModifiedById, LastModifiedDate, LastReplyDate, LastReplyId, NumReplies, Id, 
                                 Title, RecordTypeId, SystemModstamp, CommunityId, Body FROM Question WHERE CreatedById =:Apexpages.currentpage().getparameters().get('id') ];
        questCount = 0;
        questCount = lstQues.size(); 
        
        List<Reply> lstReply = [SELECT CreatedById, CreatedDate, IsDeleted, DownVotes, LastModifiedById, LastModifiedDate, Name, QuestionId, Body, Id, SystemModstamp, UpVotes, 
                                VoteTotal FROM Reply WHERE CreatedById=:Apexpages.currentpage().getparameters().get('id') ];
        ansCount = 0;
        ansCount = lstReply.size();
        
        List<Question> lstQuesSec = [SELECT CreatedById, CreatedDate, IsDeleted, LastModifiedById, LastModifiedDate, LastReplyDate, LastReplyId, NumReplies, Id, Title,
                                    RecordTypeId, SystemModstamp, CommunityId, Body, BestReplyId FROM Question WHERE BestReply.CreatedById=:Apexpages.currentpage().getparameters().get('id')];
        bestAnsCount = 0;
        bestAnsCount = lstQuesSec.size();
        
        flag = false;
        
        if(UserInfo.getUserId()==Apexpages.currentpage().getparameters().get('id'))
        flag = true;
    }
    
    /*
    public void closePopup() {        
        displayPopup = false;    
    }
         
    public void showPopup() {        
        displayPopup = true;    
    }
    */
}