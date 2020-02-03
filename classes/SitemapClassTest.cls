/*
//////////////////////////////////////
//      @author Hemant Rana     //
/////////////////////////////////////
Version :   1.0
Date : 20th March 2018
Description:Test class for- SitemapClass
*/
@IsTest()
private class SitemapClassTest{
    static testMethod void myUnitTest(){
        //Inserting Community Articles
        /*FAQ__kav Article type*/
        FAQ__kav instOfFaq = new FAQ__kav();
        instOfFaq.Title = 'Test Test is Okf';
        instOfFaq.Summary = 'Test Test is Okf';
        instOfFaq.UrlName = 'TestINgONLY';
        instOfFaq.Question__c = 'Test Test is Okf';
        instOfFaq.IsVisibleInCsp = true;
        instOfFaq.IsVisibleInPkb = true;
        insert instOfFaq;

        FAQ__DataCategorySelection insftOfFAWDCS =  new FAQ__DataCategorySelection();
        insftOfFAWDCS.DataCategoryGroupName = 'Products';
        insftOfFAWDCS.DataCategoryName = 'CSN_Planner';
        insftOfFAWDCS.ParentId = instOfFaq.Id;
        insert insftOfFAWDCS;

        FAQ__kav FAQRec = [SELECT KnowledgeArticleId FROM FAQ__kav WHERE ID = :instOfFaq.Id];
        KbManagement.PublishingService.publishArticle(FAQRec.KnowledgeArticleId, true);

        /*Instructions__kav Article type*/
        Instructions__kav instOkInSec = new Instructions__kav();
        instOkInSec.Title = 'Test Test is Okf';
        instOkInSec.Summary = 'Test Test is Okf';
        instOkInSec.UrlName = 'Testusdfgsdfg';
        instOkInSec.IsVisibleInCsp = true;
        instOkInSec.IsVisibleInPkb = true;
        insert instOkInSec;

        Instructions__DataCategorySelection insftOfInDCSSec =  new Instructions__DataCategorySelection();
        insftOfInDCSSec.DataCategoryGroupName = 'Products';
        insftOfInDCSSec.DataCategoryName = 'CSN_Supplier';
        insftOfInDCSSec.ParentId = instOkInSec.Id;
        insert insftOfInDCSSec;

        Instructions__kav instOkInQSec = [SELECT KnowledgeArticleId FROM Instructions__kav WHERE ID = :instOkInSec.Id];
        KbManagement.PublishingService.publishArticle(instOkInQSec.KnowledgeArticleId, true);


        /*Marketing_Materials__kav Article type*/
        Marketing_Materials__kav instOkMarkM = new Marketing_Materials__kav();
        instOkMarkM.Title = 'Test Test is Okf';
        instOkMarkM.Summary = 'Test Test is Okf';
        instOkMarkM.UrlName = 'Teste';
        instOkMarkM.IsVisibleInCsp = true;
        instOkMarkM.IsVisibleInPkb = true;
        insert instOkMarkM;

        Marketing_Materials__DataCategorySelection insftOfMarkM =  new Marketing_Materials__DataCategorySelection();
        insftOfMarkM.DataCategoryGroupName = 'Products';
        insftOfMarkM.DataCategoryName = 'CSN_Planner';
        insftOfMarkM.ParentId = instOkMarkM.Id;
        insert insftOfMarkM;

        Marketing_Materials__kav instOkMarkMSec = [SELECT KnowledgeArticleId FROM Marketing_Materials__kav WHERE ID = :instOkMarkM.Id];
        KbManagement.PublishingService.publishArticle(instOkMarkMSec.KnowledgeArticleId, true); 

        /*Topic_Hub__kav Article type*/
        Topic_Hub__kav instOkTopH = new Topic_Hub__kav();
        instOkTopH.Title = 'Test Test is Okf';
        instOkTopH.Summary = 'Test Test is Okf';
        instOkTopH.UrlName = 'Testr';
        instOkTopH.IsVisibleInCsp = true;
        instOkTopH.IsVisibleInPkb = true;
        insert instOkTopH;

        Topic_Hub__DataCategorySelection insftOfTopH =  new Topic_Hub__DataCategorySelection();
        insftOfTopH.DataCategoryGroupName = 'Products';
        insftOfTopH.DataCategoryName = 'SocialWall';
        insftOfTopH.ParentId = instOkTopH.Id;
        insert insftOfTopH;

        Topic_Hub__kav instOkTopHSec = [SELECT KnowledgeArticleId FROM Topic_Hub__kav WHERE ID = :instOkTopH.Id];
        KbManagement.PublishingService.publishArticle(instOkTopHSec.KnowledgeArticleId, true); 


        /*Video__kav Article type*/
        Video__kav instOkVideo = new Video__kav();
        instOkVideo.Title = 'Test Test is Okf';
        instOkVideo.Summary = 'Test Test is Okf';
        instOkVideo.UrlName = 'Testy';
        instOkVideo.IsVisibleInCsp = true;
        instOkVideo.IsVisibleInPkb = true;
        insert instOkVideo;

        Video__DataCategorySelection insftOfVideo =  new Video__DataCategorySelection();
        insftOfVideo.DataCategoryGroupName = 'Products';
        insftOfVideo.DataCategoryName = 'OnArrival';
        insftOfVideo.ParentId = instOkVideo.Id;
        insert insftOfVideo;

        Video__kav instOkVideoSec = [SELECT KnowledgeArticleId FROM Video__kav WHERE ID = :instOkVideo.Id];
        KbManagement.PublishingService.publishArticle(instOkVideoSec.KnowledgeArticleId, true); 


        /*Download__kav Article type*/
        Download__kav instOkDownL = new Download__kav();
        instOkDownL.Title = 'Test Test is Okf';
        instOkDownL.Summary = 'Test Test is Okf';
        instOkDownL.UrlName = 'Testyssssww';
        instOkDownL.IsVisibleInCsp = true;
        instOkDownL.IsVisibleInPkb = true;
        insert instOkDownL;

        Download__DataCategorySelection insftOfDownDCS =  new Download__DataCategorySelection();
        insftOfDownDCS.DataCategoryGroupName = 'Products';
        insftOfDownDCS.DataCategoryName = 'OnArrival';
        insftOfDownDCS.ParentId = instOkDownL.Id;
        insert insftOfDownDCS;

        Download__kav instOkDownLSec = [SELECT KnowledgeArticleId FROM Download__kav WHERE ID = :instOkDownL.Id];
        KbManagement.PublishingService.publishArticle(instOkDownLSec.KnowledgeArticleId, true);

        /*Release_Notes__kav Article type*/

        Release_Notes__kav instOfReleaseNote = new Release_Notes__kav();
        instOfReleaseNote.Title = 'Test Test is Okf';
        instOfReleaseNote.Summary = 'Test Test is Okf';
        instOfReleaseNote.UrlName = 'TestysssswwTest';
        instOfReleaseNote.IsVisibleInCsp = true;
        instOfReleaseNote.IsVisibleInPkb = true;
        insert instOfReleaseNote;

        Release_Notes__DataCategorySelection instOfReleaseNoteDCSONA = new Release_Notes__DataCategorySelection();
        instOfReleaseNoteDCSONA.DataCategoryGroupName = 'Products';
        instOfReleaseNoteDCSONA.DataCategoryName = 'OnArrival';
        instOfReleaseNoteDCSONA.ParentId = instOfReleaseNote.Id;
        insert instOfReleaseNoteDCSONA;

        Release_Notes__kav instOkReleaseSec = [SELECT KnowledgeArticleId FROM Release_Notes__kav WHERE ID = :instOfReleaseNote.Id];
        KbManagement.PublishingService.publishArticle(instOkReleaseSec.KnowledgeArticleId, true);

        //Setting Vf Page Name.....
        PageReference pageRef = Page.Sitemap;
        Test.setCurrentPage(pageRef);
        //Calling Controller Class...
        SitemapClass controller = new SitemapClass();
    }
}