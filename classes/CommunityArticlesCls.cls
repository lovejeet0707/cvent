public class CommunityArticlesCls {

    public PageReference Text() {
        String str=  ApexPages.currentPage().getParameters().get('id');
        List<KnowledgeArticleVersion> instOfKAV = new List<KnowledgeArticleVersion>();
        instOfKAV = [SELECT KnowledgeArticleId FROM KnowledgeArticleVersion WHERE KnowledgeArticleId=:str AND PublishStatus ='Online' AND IsLatestVersion=true];
        pagereference pageref = new pagereference('/apex/CommunityArticle?id='+instOfKAV[0].id);
        pageref.setredirect(true);
        return pageref;
    }

}