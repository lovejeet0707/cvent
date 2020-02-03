public with sharing class ro_VoteController {
 
 public Integer nLikes {get;set;}
 public Integer nDislikes {get;set;}
 public Id voteIdTemp{get;set;}
 public Id kaId {get;set;}
 public String kaNumber {get;set;}
 public String kaTitle {get;set;}
 public String testDev {get;set;}
 public Vote__c oVote {get;set;} 
 public String sVoted {get;set;}
 public string sPublicIp{get;set;}
 public string sComments{get;set;}
 
 public ro_VoteController(){
  System.debug('@Developer -->ro_VoteController:' ); 
  
 }
 
 public Boolean getValidToRender(){
  System.debug('@Developer --> getValidToRender --> kaId:' + kaId);
  oVote = null;
  sVoted = '';
  fetchVoteDetails();
  if(oVote==null){
    oVote = new Vote__c();
  }
  return true;  
 }
 
 public void setIP(){
   System.debug('@Developer -->setIP :' );
   system.debug('@Developer -->setIP:' );
   system.debug('@developer -->sPublicIp:'+sPublicIp);
   
 }
 
 private void fetchVoteDetails(){
   System.debug('@Developer -->fetchVoteDetails :' );
   nLikes = 0;
   nDislikes = 0;
    
    for(Vote__c v: [Select Id, Type__c,CreatedById,Article_Id__c,IP_address__c,Vote_Up_Down__c,User_Id__c,Comments__c 
                                    From Vote__c Where Article_Id__c=:kaId]){
        if(v.Type__c == 'Up' ){
         nLikes++;
         if(v.CreatedById == userInfo.getUserId() && v.IP_address__c==sPublicIp){
            oVote = v;
            sVoted = 'Up';
         }
        }
        else if(v.Type__c == 'Down'){
            nDislikes ++;
            if(v.CreatedById == userInfo.getUserId() && v.IP_address__c==sPublicIp){
              oVote = v;
              sVoted = 'Down';
               }
        }
    }
 }
 
 public void addComment(){
   System.debug('@Developer -->addComment :' );  
  
  Vote__c oComment = new Vote__c();
  oComment.Type__c = 'Comment';
  oComment.Article_Id__c = kaId;
  oComment.Article__c = kaNumber;
  oComment.Article_Title__c = kaTitle;
  
  oComment.IP_address__c = sPublicIp;
    oComment.Comments__c = sComments;
          
  if(sPublicIp != null && sPublicIp != ''){
    insert oComment;
  }
 }
 
 public void hitLike(){
   System.debug('@Developer -->hitLike :' );  
    /*if(oVote != null){
        delete oVote;
    }
    
    oVote = new Vote__c();*/
    oVote.Type__c = 'Up';
    oVote.Article_Id__c = kaId;
    oVote.Article__c = kaNumber;
    oVote.Article_Title__c = kaTitle;
    oVote.IP_address__c = sPublicIp;
    
    if(sPublicIp != null && sPublicIp != ''){
      upsert oVote;
      voteIdTemp = oVote.Id;
      fetchVoteDetails();
    }
 }
 
 public void hitDislike(){
 testDev = 'testValue';
   System.debug('@Developer -->hitLike :' );
   /* if(oVote != null){
        delete oVote;
    }
    
    oVote = new Vote__c();*/
    oVote.Type__c = 'Down';
    oVote.Article_Id__c = kaId;
    oVote.Article__c = kaNumber;
    oVote.Article_Title__c = kaTitle;
    oVote.IP_address__c = sPublicIp;
    
    if(sPublicIp != null && sPublicIp != ''){
      upsert oVote;
      voteIdTemp = oVote.Id;

      fetchVoteDetails();
    }
 }
}