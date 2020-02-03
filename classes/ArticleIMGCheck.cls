public class ArticleIMGCheck{
    //SELECT Solution__c FROM Manual_User_Guide__kav WHERE ArticleNumber = '000005904' AND PublishStatus = 'Online' AND Language = 'en_US'
    public static void methodValue(){
        Article_Img_Count_Dev__c artImg ;
        List<Article_Img_Count_Dev__c> artImgList;
        artImg = new Article_Img_Count_Dev__c();
        artImgList = new List<Article_Img_Count_Dev__c>();
        /*......................Article type..........................*/
        For(Download__kav artKav : [SELECT Id,UrlName,Keywords__c,ArticleNumber,KnowledgeArticleId,ArticleType,Related_Article__c,Body__c,Chat_Text__c,Internal_Information__c,Summary,Title FROM Download__kav WHERE PublishStatus ='Online' AND Language  = 'en_US'])
        {
            if(
            (artKav.UrlName!=null && artKav.UrlName.contains('na17')) ||
            (artKav.Related_Article__c!=null && artKav.Related_Article__c.contains('na17')) ||
            (artKav.Body__c!=null && artKav.Body__c.contains('na17')) ||
            (artKav.Chat_Text__c!=null && artKav.Chat_Text__c.contains('na17')) ||
            (artKav.Internal_Information__c!=null && artKav.Internal_Information__c.contains('na17')) ||
            (artKav.Summary!=null && artKav.Summary.contains('na17')) ||
            (artKav.Keywords__c!=null && artKav.Keywords__c.contains('na17')) ||
            (artKav.Title!=null && artKav.Title.contains('na17'))
            )
            {
                artImg = new Article_Img_Count_Dev__c();
                artImg.Article_Id__c = artKav.Id;
                artImg.Article_Number__c = artKav.ArticleNumber;
                artImg.Article_Type__c = artKav.ArticleType;
                artImg.Article_Title__c = artKav.Title;
                artImg.Solution__c = artKav.Body__c;
                artImg.IMG_Count__c = (artKav.Body__c.split('na17').size()-1);
                artImg.KnowledgeArticleId__c  = artKav.KnowledgeArticleId;
                //artImg.Searched_Text__c=descriptionVal;
                artImgList.add(artImg);
            }
        }
        /*......................Videos type..........................*/
        For(FAQ__kav artKav : [SELECT Id,Keywords__c,UrlName,Question__c,ArticleNumber,KnowledgeArticleId,ArticleType,Related_Article__c,Internal_Information__c,Summary,Title FROM FAQ__kav WHERE PublishStatus ='Online' AND Language  = 'en_US'])
        {
            if(
            (artKav.UrlName!=null && artKav.UrlName.contains('na17')) ||
            (artKav.Related_Article__c!=null && artKav.Related_Article__c.contains('na17')) ||
            (artKav.Internal_Information__c!=null && artKav.Internal_Information__c.contains('na17')) ||
            (artKav.Summary!=null && artKav.Summary.contains('na17')) ||
            (artKav.Question__c!=null && artKav.Question__c.contains('na17')) ||
            (artKav.Keywords__c!=null && artKav.Keywords__c.contains('na17')) ||
            (artKav.Title!=null && artKav.Title.contains('na17'))
            )
            {
                artImg = new Article_Img_Count_Dev__c();
                artImg.Article_Id__c = artKav.Id;
                artImg.Article_Number__c = artKav.ArticleNumber;
                artImg.Article_Type__c = artKav.ArticleType;
                artImg.Article_Title__c = artKav.Title;
                artImg.KnowledgeArticleId__c  = artKav.KnowledgeArticleId;
                //artImg.Solution__c = artKav.Body__c;
                //artImg.IMG_Count__c = (artKav.Body__c.split('na17').size()-1);
                //artImg.Searched_Text__c=descriptionVal;
                artImgList.add(artImg);
            }
        }
        /*......................Release Notes type..........................*/
        For(Instructions__kav artKav : [SELECT Id,Related_Articles__c,UrlName,Body__c,KnowledgeArticleId,Keywords__c,ArticleNumber,ArticleType,Chat_Text__c,Internal_Information__c,Summary,Title FROM Instructions__kav WHERE PublishStatus ='Online' AND Language  = 'en_US'])
        {
            if(
            (artKav.UrlName!=null && artKav.UrlName.contains('na17')) ||
            (artKav.Chat_Text__c!=null && artKav.Chat_Text__c.contains('na17')) ||
            (artKav.Internal_Information__c!=null && artKav.Internal_Information__c.contains('na17')) ||
            (artKav.Summary!=null && artKav.Summary.contains('na17')) ||
            (artKav.Body__c!=null && artKav.Body__c.contains('na17')) ||
            (artKav.Keywords__c!=null && artKav.Keywords__c.contains('na17')) ||
            (artKav.Related_Articles__c!=null && artKav.Related_Articles__c.contains('na17')) ||
            (artKav.Title!=null && artKav.Title.contains('na17'))
            )
            {
                artImg = new Article_Img_Count_Dev__c();
                artImg.Article_Id__c = artKav.Id;
                artImg.Article_Number__c = artKav.ArticleNumber;
                artImg.Article_Type__c = artKav.ArticleType;
                artImg.Article_Title__c = artKav.Title;
                artImg.Solution__c = artKav.Body__c;
                artImg.IMG_Count__c = (artKav.Body__c.split('na17').size()-1);
                artImg.KnowledgeArticleId__c  = artKav.KnowledgeArticleId;
                //artImg.Searched_Text__c=descriptionVal;
                artImgList.add(artImg);
            }
        }
        /*......................Manual_User_Guide__kav Notes type..........................*/
        For(Release_Notes__kav artKav : [SELECT Id,Body__c,Keywords__c,UrlName,KnowledgeArticleId,ArticleNumber,ArticleType,Related_Article__c,Summary,Title FROM Release_Notes__kav WHERE PublishStatus ='Online' AND Language  = 'en_US'])
        {
            if(
            (artKav.UrlName!=null && artKav.UrlName.contains('na17')) ||
            (artKav.Related_Article__c!=null && artKav.Related_Article__c.contains('na17')) ||
            (artKav.Summary!=null && artKav.Summary.contains('na17')) ||
            (artKav.Body__c!=null && artKav.Body__c.contains('na17')) ||
            (artKav.Keywords__c!=null && artKav.Keywords__c.contains('na17')) ||
            (artKav.Title!=null && artKav.Title.contains('na17'))
            )
            {
                artImg = new Article_Img_Count_Dev__c();
                artImg.Article_Id__c = artKav.Id;
                artImg.Article_Number__c = artKav.ArticleNumber;
                artImg.Article_Type__c = artKav.ArticleType;
                artImg.Article_Title__c = artKav.Title;
                artImg.Solution__c = artKav.Body__c;
                artImg.IMG_Count__c = (artKav.Body__c.split('na17').size()-1);
                artImg.KnowledgeArticleId__c  = artKav.KnowledgeArticleId;
                //artImg.Searched_Text__c=descriptionVal;
                artImgList.add(artImg);
            }
        }
        /*......................Manual_User_Guide__kav Notes type..........................*/
        For(Topic_Hub__kav artKav : [SELECT Id,Keywords__c,UrlName,ArticleNumber,KnowledgeArticleId,ArticleType,Related_Article__c,Body__c,Summary,Title FROM Topic_Hub__kav WHERE PublishStatus ='Online' AND Language  = 'en_US'])
        {
            if(
            (artKav.UrlName!=null && artKav.UrlName.contains('na17')) ||
            (artKav.Related_Article__c!=null && artKav.Related_Article__c.contains('na17')) ||
            (artKav.Body__c!=null && artKav.Body__c.contains('na17')) ||
            (artKav.Summary!=null && artKav.Summary.contains('na17')) ||
            (artKav.Keywords__c!=null && artKav.Keywords__c.contains('na17')) ||
            (artKav.Title!=null && artKav.Title.contains('na17'))
            )
            {
                artImg = new Article_Img_Count_Dev__c();
                artImg.Article_Id__c = artKav.Id;
                artImg.Article_Number__c = artKav.ArticleNumber;
                artImg.Article_Type__c = artKav.ArticleType;
                artImg.Article_Title__c = artKav.Title;
                artImg.Solution__c = artKav.Body__c;
                artImg.IMG_Count__c = (artKav.Body__c.split('na17').size()-1);
                artImg.KnowledgeArticleId__c  = artKav.KnowledgeArticleId;
                //artImg.Searched_Text__c=descriptionVal;
                artImgList.add(artImg);
            }
        }
        /*......................Manual_User_Guide__kav Notes type..........................*/
        For(Marketing_Materials__kav artKav : [SELECT Id,Body__c,UrlName,KnowledgeArticleId,Keywords__c,Related_Articles__c,ArticleNumber,ArticleType,Chat_Text__c,Internal_Information__c,Summary,Title FROM Marketing_Materials__kav WHERE PublishStatus ='Online' AND Language  = 'en_US'])
        {
            if(
            (artKav.UrlName!=null && artKav.UrlName.contains('na17')) ||
            (artKav.Chat_Text__c!=null && artKav.Chat_Text__c.contains('na17')) ||
            (artKav.Internal_Information__c!=null && artKav.Internal_Information__c.contains('na17')) ||
            (artKav.Summary!=null && artKav.Summary.contains('na17')) ||
            (artKav.Related_Articles__c!=null && artKav.Related_Articles__c.contains('na17')) ||
            (artKav.Keywords__c!=null && artKav.Keywords__c.contains('na17')) ||
            (artKav.Body__c!=null && artKav.Body__c.contains('na17')) ||
            (artKav.Title!=null && artKav.Title.contains('na17'))
            )
            {
                artImg = new Article_Img_Count_Dev__c();
                artImg.Article_Id__c = artKav.Id;
                artImg.Article_Number__c = artKav.ArticleNumber;
                artImg.Article_Type__c = artKav.ArticleType;
                artImg.Article_Title__c = artKav.Title;
                artImg.Solution__c = artKav.Body__c;
                artImg.IMG_Count__c = (artKav.Body__c.split('na17').size()-1);
                artImg.KnowledgeArticleId__c  = artKav.KnowledgeArticleId;
                //artImg.Searched_Text__c=descriptionVal;
                artImgList.add(artImg);
            }
        }
        /*......................Manual_User_Guide__kav Notes type..........................*/
        For(Video__kav artKav : [SELECT Id,UrlName,KnowledgeArticleId,Body__c,Keywords__c,ArticleNumber,ArticleType,Related_Article__c,Chat_Text__c,Internal_Information__c,Summary,Title FROM Video__kav WHERE PublishStatus ='Online' AND Language  = 'en_US'])
        {
            if(
            (artKav.UrlName!=null && artKav.UrlName.contains('na17')) ||
            (artKav.Related_Article__c!=null && artKav.Related_Article__c.contains('na17')) ||
            (artKav.Chat_Text__c!=null && artKav.Chat_Text__c.contains('na17')) ||
            (artKav.Internal_Information__c!=null && artKav.Internal_Information__c.contains('na17')) ||
            (artKav.Summary!=null && artKav.Summary.contains('na17')) ||
            (artKav.Keywords__c!=null && artKav.Keywords__c.contains('na17')) ||
            (artKav.Body__c!=null && artKav.Body__c.contains('na17')) ||
            (artKav.Title!=null && artKav.Title.contains('na17'))
            )
            {
                artImg = new Article_Img_Count_Dev__c();
                artImg.Article_Id__c = artKav.Id;
                artImg.Article_Number__c = artKav.ArticleNumber;
                artImg.Article_Type__c = artKav.ArticleType;
                artImg.Article_Title__c = artKav.Title;
                artImg.Solution__c = artKav.Body__c;
                artImg.IMG_Count__c = (artKav.Body__c.split('na17').size()-1);
                artImg.KnowledgeArticleId__c  = artKav.KnowledgeArticleId;
                //artImg.Searched_Text__c=descriptionVal;
                artImgList.add(artImg);
            }
        }
        if(artImgList.size()>0)
            insert artImgList;
    }
}