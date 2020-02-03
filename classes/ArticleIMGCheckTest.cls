@IsTest
private Class ArticleIMGCheckTest{

    static testmethod void unitTestMethod(){
        //create the Download__kav instance 
        Download__kav article = new Download__kav(
            Title = 'test apex',
            Summary = 'test from apex',
            URLName = 'testDownloadURLCheck',
            Body__c = 'https://na17.force.com/',
            Language  = 'en_US'
        );
        insert article;
        
        //retrieve master article Id created on Download__kav record insertion
        //in order to get the KnowledgeArticleId
        article = [SELECT KnowledgeArticleId FROM Download__kav WHERE Id = :article.Id];
        
        //publish it
        KbManagement.PublishingService.publishArticle(article.KnowledgeArticleId, true);
        
        //create the Video__kav  instance 
        Video__kav  videoArticle = new Video__kav(
            Title = 'test apex',
            Summary = 'test from apex',
            URLName = 'testVideoURLCheck',
            Body__c = 'https://na17.force.com/',
            Language  = 'en_US'
        );
        insert videoArticle;
        
        //retrieve master videoArticle Id created on Video__kav record insertion
        //in order to get the KnowledgeArticleId
        videoArticle = [SELECT KnowledgeArticleId FROM Video__kav WHERE Id = :videoArticle.Id];
        
        //publish it
        KbManagement.PublishingService.publishArticle(videoArticle.KnowledgeArticleId, true);
        
        //create the FAQ__kav  instance 
        FAQ__kav  FAQArticle = new FAQ__kav (
            Title = 'test apex',
            
            URLName = 'testFAQURLCheck',
            Summary = 'https://na17.force.com/',
            Language  = 'en_US'
        );
        insert FAQArticle;
        
        //retrieve master FAQArticle Id created on FAQ__kav record insertion
        //in order to get the KnowledgeArticleId
        FAQArticle = [SELECT KnowledgeArticleId FROM FAQ__kav  WHERE Id = :FAQArticle.Id];
        
        //publish it
        KbManagement.PublishingService.publishArticle(FAQArticle.KnowledgeArticleId, true);
        
        //create the Instructions__kav instance 
        Instructions__kav manualArticle = new Instructions__kav(
            Title = 'test apex',
            Summary = 'test from apex',
            URLName = 'testInstructionURLCheck',
            Body__c = 'https://na17.force.com/',
            Language  = 'en_US'
        );
        insert manualArticle;
        
        //retrieve master manualArticle Id created on Instructions__kav record insertion
        //in order to get the KnowledgeArticleId
        manualArticle = [SELECT KnowledgeArticleId FROM Instructions__kav WHERE Id = :manualArticle.Id];
        
        //publish it
        KbManagement.PublishingService.publishArticle(manualArticle.KnowledgeArticleId, true);
        
        
        
        //create the Release_Notes__kav instance 
        Release_Notes__kav releaseArticle = new Release_Notes__kav(
            Title = 'test apex',
            Summary = 'test from apex',
            URLName = 'testreleaseURLCheck',
            Body__c = 'https://na17.force.com/',
            Language  = 'en_US'
        );
        insert releaseArticle;
        
        //retrieve master releaseArticle Id created on Release_Notes__kav record insertion
        //in order to get the KnowledgeArticleId
        releaseArticle = [SELECT KnowledgeArticleId FROM Release_Notes__kav WHERE Id = :releaseArticle.Id];
        
        //publish it
        KbManagement.PublishingService.publishArticle(releaseArticle.KnowledgeArticleId, true);
        
        
        //create the Topic_Hub__kav instance 
        Topic_Hub__kav topicArticle = new Topic_Hub__kav(
            Title = 'test apex',
            Summary = 'test from apex',
            URLName = 'testTopicURLCheck',
            Body__c = 'https://na17.force.com/',
            Language  = 'en_US'
        );
        insert topicArticle;
        
        //retrieve master topicArticle Id created on Topic_Hub__kav record insertion
        //in order to get the KnowledgeArticleId
        topicArticle = [SELECT KnowledgeArticleId FROM Topic_Hub__kav WHERE Id = :topicArticle.Id];
        
        //publish it
        KbManagement.PublishingService.publishArticle(topicArticle.KnowledgeArticleId, true);
        
                
        //create the Marketing_Materials__kav instance 
        Marketing_Materials__kav marketArticle = new Marketing_Materials__kav(
            Title = 'test apex',
            Summary = 'test from apex',
            URLName = 'testMarketingURLCheck',
            Body__c = 'https://na17.force.com/',
            Language  = 'en_US'
        );
        insert marketArticle;
        
        //retrieve master marketArticle Id created on Marketing_Materials__kav record insertion
        //in order to get the KnowledgeArticleId
        marketArticle = [SELECT KnowledgeArticleId FROM Marketing_Materials__kav WHERE Id = :marketArticle.Id];
        
        //publish it
        KbManagement.PublishingService.publishArticle(marketArticle.KnowledgeArticleId, true);
     
        ArticleIMGCheck.methodValue();
    }
}