/*
HSR : 20th March 2018
Description : Class to create SiteMap for indexing the Community Article.....
*/
public class SitemapClass {
    public List<KnowledgeArticleVersion> knowledgeArticleList{get;set;}
    public List<String> communityArticleURL{get;set;}
    private String baseURL;
    public SitemapClass(){
        knowledgeArticleList = new List<KnowledgeArticleVersion>();
        communityArticleURL = new List<String>();
        /*Download__kav Article type*/
        For(KnowledgeArticleVersion downLoadArticle : [SELECT Id,ArticleNumber,Language FROM KnowledgeArticleVersion WHERE (NOT Title LIKE '%Internal%') AND PublishStatus = 'Online' AND IsVisibleInPkb = TRUE AND ArticleType = 'Download__kav'])
        {
            baseURL = '';
            baseURL = 'https://support.cvent.com/apex/CommunityArticle?id='+downLoadArticle.ArticleNumber;
            communityArticleURL.add(baseURL);
            //knowledgeArticleList.add(baseURL);
        }
        
        /*FAQ__kav Article type*/
        For(KnowledgeArticleVersion FAQArticle : [SELECT Id,ArticleNumber,Language FROM KnowledgeArticleVersion WHERE (NOT Title LIKE '%Internal%') AND PublishStatus = 'Online' AND IsVisibleInPkb = TRUE AND ArticleType = 'FAQ__kav'])
        {
            baseURL = '';
            baseURL = 'https://support.cvent.com/apex/CommunityArticle?id='+FAQArticle.ArticleNumber;
            communityArticleURL.add(baseURL);
            //knowledgeArticleList.add(baseURL);
        }
        /*Instructions__kav Article type*/
        For(KnowledgeArticleVersion instructionArticle : [SELECT Id,ArticleNumber,Language FROM KnowledgeArticleVersion WHERE (NOT Title LIKE '%Internal%') AND PublishStatus = 'Online' AND IsVisibleInPkb = TRUE AND ArticleType = 'Instructions__kav'])
        {
            baseURL = '';
            baseURL = 'https://support.cvent.com/apex/CommunityArticle?id='+instructionArticle.ArticleNumber;
            communityArticleURL.add(baseURL);
            //knowledgeArticleList.add(baseURL);
        }
        /*Release_Notes__kav Article type*/
        For(KnowledgeArticleVersion releaseArticle : [SELECT Id,ArticleNumber,Language FROM KnowledgeArticleVersion WHERE (NOT Title LIKE '%Internal%') AND PublishStatus = 'Online' AND IsVisibleInPkb = TRUE AND ArticleType = 'Release_Notes__kav'])
        {
            baseURL = '';
            baseURL = 'https://support.cvent.com/apex/CommunityArticle?id='+releaseArticle.ArticleNumber;
            communityArticleURL.add(baseURL);
            //knowledgeArticleList.add(baseURL);
        }
        /*Topic_Hub__kav Article type*/
        For(KnowledgeArticleVersion topicHubArticle : [SELECT Id,ArticleNumber,Language FROM KnowledgeArticleVersion WHERE (NOT Title LIKE '%Internal%') AND PublishStatus = 'Online' AND IsVisibleInPkb = TRUE AND ArticleType = 'Topic_Hub__kav'])
        {
            baseURL = '';
            baseURL = 'https://support.cvent.com/apex/CommunityArticle?id='+topicHubArticle.ArticleNumber;
            communityArticleURL.add(baseURL);
            //knowledgeArticleList.add(baseURL);
        }
        /*Marketing_Materials__kav Article type*/
        For(KnowledgeArticleVersion marketingArticle : [SELECT Id,ArticleNumber,Language FROM KnowledgeArticleVersion WHERE (NOT Title LIKE '%Internal%') AND PublishStatus = 'Online' AND IsVisibleInPkb = TRUE AND ArticleType = 'Marketing_Materials__kav'])
        {
            baseURL = '';
            baseURL = 'https://support.cvent.com/apex/CommunityArticle?id='+marketingArticle.ArticleNumber;
            communityArticleURL.add(baseURL);
            //knowledgeArticleList.add(baseURL);
        }
        /*Video__kav Article type*/
        For(KnowledgeArticleVersion videoArticle : [SELECT Id,ArticleNumber,Language FROM KnowledgeArticleVersion WHERE (NOT Title LIKE '%Internal%') AND PublishStatus = 'Online' AND IsVisibleInPkb = TRUE AND ArticleType = 'Video__kav'])
        {
            baseURL = '';
            baseURL = 'https://support.cvent.com/apex/CommunityArticle?id='+videoArticle.ArticleNumber;
            communityArticleURL.add(baseURL);
            //knowledgeArticleList.add(baseURL);
        }
    }
}