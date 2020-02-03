/*
    Description: VF Page Controller tat contains all the methods and variables used in pkb_relatedLIstArticle page
    Author: Joseph Barrameda
    Modified By : Rishi Ojha 
    Date: 22-07-15
    
    History: Modified code to list the articles with respect to article number
    
*/

public class pkb_relatedListArticleController {


    private Case caseRec ; 
    private Case caseRecord;       
    public List<KnowledgeArticleVersion> relatedCaseArticleList {get;set;}            
    public string lang{get;set;}
    public pkb_relatedListArticleController (ApexPages.StandardController controller) {
        
        lang=[select LanguageLocaleKey  from user where id=:userinfo.getUserId()].LanguageLocaleKey ;
        this.caseRec = (Case)controller.getRecord();
        caseRecord = [SELECT Id,Subject FROM Case  WHERE Id=: caseRec.Id];
        relatedCaseArticleList = getArticleList();
    }

    //Method that returns the list of Articles associated in this Case record 

    public List<KnowledgeArticleVersion> getArticleList (){        
        Set<Id> articleIds = new Set<Id>(); 
        for(CaseArticle caseAssoc:[SELECT Id,CaseId,KnowledgeArticleId FROM CaseArticle WHERE CaseId =: caseRec.Id]){

            articleIds.add (caseAssoc.KnowledgeArticleId);            
        }
        List<KnowledgeArticleVersion> kavList = [SELECT Id, ArticleNumber,Title, Summary FROM KnowledgeArticleVersion WHERE KnowledgeArticleId IN:articleIds AND (PublishStatus ='Online')];        

        return kavList;
    }    
    
}