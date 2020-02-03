/*
//////////////////////////////////////
//      @author Abhishek Pandey     //
/////////////////////////////////////
Version :   1.0
Date : 7th April 2015
Description:Test class for- CommunitySearchResultsAngularCls,CommunityAnnouncementCls,CommunityHomePageCls,CommunityUserDetCls,CommunitySearchResultsAngularCls,CommunityHeaderCls
*/
@IsTest()
private class CommunitySearchResultsAngularClsTest{
    public static Map<String,Schema.SOBjectType> gd = Schema.getGlobalDescribe();
    public static Map<String,Schema.DescribeSObjectResult> kavObjPrefixMap = new Map<String,Schema.DescribeSObjectResult>();
    public static map<String,String> mapArticleTypeName{get;set;}
    public static String prodSelTest;
    public static Set<String> kavNames = new Set<String>();
    public static User instUsr = new User();
    //public static User instUsr = new User();
    public static List<Id> lstKAVId = new List<Id>();
    public static List<KnowledgeArticleVersion> lstKAV = new List<KnowledgeArticleVersion>();
    
    static{
        Account a = new Account(
            Name = 'Test Account'
        );
        insert a;
        
        Announcements__c instOfAnn = new Announcements__c();
        instOfAnn.Data__c = 'Test';
        instOfAnn.Is_Active__c = true;
        insert instOfAnn;
        
        Contact con = new Contact(LastName='Test',Product_Desired__c='Event',AccountId=a.Id);
        insert con;
        Profile p = [SELECT id FROM profile WHERE name='Cvent Customer Community User'];
        instUsr = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p.Id,
                timezonesidkey='America/Los_Angeles', username='test123@noemail.com',ContactId=con.id);
        insert instUsr;
        instUsr = [SELECT Id FROM USER WHERE Id=:instUsr.Id AND isPortalEnabled =true];
        system.debug(instUsr.Id+'++++++');
        //instUsr = [SELECT ID FROM USER WHERE ID='00517000000hxQh'];
        String id;
        FAQ__kav instOfFaq = new FAQ__kav();
        instOfFaq.Title = 'Test Test is Okf';
        instOfFaq.Summary = 'Test Test is Okf';
        instOfFaq.UrlName = 'TestINgONLY';
        instOfFaq.Question__c = 'Test Test is Okf';
        instOfFaq.IsVisibleInCsp = true;
        insert instOfFaq;
        
        
        
        FAQ__DataCategorySelection insftOfFAWDCS =  new FAQ__DataCategorySelection();
        insftOfFAWDCS.DataCategoryGroupName = 'Products';
        insftOfFAWDCS.DataCategoryName = 'CSN_Planner';
        insftOfFAWDCS.ParentId = instOfFaq.Id;
        insert insftOfFAWDCS;
        /* FAQ__DataCategorySelection insftOfFAWDCSSec =  new FAQ__DataCategorySelection();
        insftOfFAWDCSSec.DataCategoryGroupName = 'Products';
        insftOfFAWDCSSec.DataCategoryName = 'CrowdTorch_Ticketing';
        insftOfFAWDCSSec.ParentId = instOfFaq.Id;
        insert insftOfFAWDCSSec; */ //Code commented for deployment as Crowdtorch Ticketing data category is not yet live in production
        FAQ__kav insertedTestFaq = [SELECT KnowledgeArticleId FROM FAQ__kav WHERE ID = :instOfFaq.Id];
        
        Instructions__kav instOkIn = new Instructions__kav();
        instOkIn.Title = 'Test Test is Okf';
        instOkIn.Summary = 'Test Test is Okf';
        instOkIn.UrlName = 'Testu';
        instOkIn.IsVisibleInCsp = true;
        insert instOkIn;
        
        Instructions__DataCategorySelection insftOfInDCS =  new Instructions__DataCategorySelection();
        insftOfInDCS.DataCategoryGroupName = 'Products';
        insftOfInDCS.DataCategoryName = 'CSN_Planner';
        insftOfInDCS.ParentId = instOkIn.Id;
        insert insftOfInDCS;
        
        //Testing translated articles
        //id = KbManagement.PublishingService.submitForTranslation(instOkIn.KnowledgeArticleId,'de',UserInfo.getUserId(),system.today());
        //KbManagement.PublishingService.completeTranslation(id);
        //KbManagement.PublishingService.publishArticle(id, true);
        //Testing translated articles
        
        Instructions__kav instOkInQ = [SELECT KnowledgeArticleId FROM Instructions__kav WHERE ID = :instOkIn.Id];
        KbManagement.PublishingService.publishArticle(instOkInQ.KnowledgeArticleId, true); 
        
        
        Instructions__kav instOkInSec = new Instructions__kav();
        instOkInSec.Title = 'Test Test is Okf';
        instOkInSec.Summary = 'Test Test is Okf';
        instOkInSec.UrlName = 'Testusdfgsdfg';
        instOkInSec.IsVisibleInCsp = true;
        insert instOkInSec;
        
        Instructions__DataCategorySelection insftOfInDCSSec =  new Instructions__DataCategorySelection();
        insftOfInDCSSec.DataCategoryGroupName = 'Products';
        insftOfInDCSSec.DataCategoryName = 'CSN_Supplier';
        insftOfInDCSSec.ParentId = instOkInSec.Id;
        insert insftOfInDCSSec;
        Instructions__kav instOkInQSec = [SELECT KnowledgeArticleId FROM Instructions__kav WHERE ID = :instOkInSec.Id];
        KbManagement.PublishingService.publishArticle(instOkInQSec.KnowledgeArticleId, true);
        
        
        Instructions__kav instOkInTHir = new Instructions__kav();
        instOkInTHir.Title = 'Test Test is Okf';
        instOkInTHir.Summary = 'Test Test is Okf';
        instOkInTHir.UrlName = 'Testudfjkjtgj234523';
        instOkInTHir.IsVisibleInCsp = true;
        insert instOkInTHir;
        
        Instructions__DataCategorySelection insftOfInDCSThir =  new Instructions__DataCategorySelection();
        insftOfInDCSThir.DataCategoryGroupName = 'Products';
        insftOfInDCSThir.DataCategoryName = 'eMarketing';
        insftOfInDCSThir.ParentId = instOkInTHir.Id;
        insert insftOfInDCSThir;
        Instructions__kav instOkInQThir = [SELECT KnowledgeArticleId FROM Instructions__kav WHERE ID = :instOkInTHir.Id];
        KbManagement.PublishingService.publishArticle(instOkInQThir.KnowledgeArticleId, true);
        
        //Testing translated articles
        id = KbManagement.PublishingService.submitForTranslation(instOkInQThir.KnowledgeArticleId,'de',UserInfo.getUserId(),system.today());
        KbManagement.PublishingService.completeTranslation(id);
        //Instructions__kav instOkInQThirTrans = [SELECT KnowledgeArticleId FROM Instructions__kav WHERE ID = :id];
        //KbManagement.PublishingService.publishArticle(instOkInQThirTrans.KnowledgeArticleId, true);
        //Testing translated articles
        
        Marketing_Materials__kav instOkMarkM = new Marketing_Materials__kav();
        instOkMarkM.Title = 'Test Test is Okf';
        instOkMarkM.Summary = 'Test Test is Okf';
        instOkMarkM.UrlName = 'Teste';
        instOkMarkM.IsVisibleInCsp = true;
        insert instOkMarkM;
        Marketing_Materials__DataCategorySelection insftOfMarkM =  new Marketing_Materials__DataCategorySelection();
        insftOfMarkM.DataCategoryGroupName = 'Products';
        insftOfMarkM.DataCategoryName = 'CSN_Planner';
        insftOfMarkM.ParentId = instOkMarkM.Id;
        insert insftOfMarkM;
        Marketing_Materials__kav instOkMarkMSec = [SELECT KnowledgeArticleId FROM Marketing_Materials__kav WHERE ID = :instOkMarkM.Id];
        KbManagement.PublishingService.publishArticle(instOkMarkMSec.KnowledgeArticleId, true); 
        
        Topic_Hub__kav instOkTopH = new Topic_Hub__kav();
        instOkTopH.Title = 'Test Test is Okf';
        instOkTopH.Summary = 'Test Test is Okf';
        instOkTopH.UrlName = 'Testr';
        instOkTopH.IsVisibleInCsp = true;
        insert instOkTopH;
        Topic_Hub__DataCategorySelection insftOfTopH =  new Topic_Hub__DataCategorySelection();
        insftOfTopH.DataCategoryGroupName = 'Products';
        insftOfTopH.DataCategoryName = 'SocialWall';
        insftOfTopH.ParentId = instOkTopH.Id;
        insert insftOfTopH;
        Topic_Hub__kav instOkTopHSec = [SELECT KnowledgeArticleId FROM Topic_Hub__kav WHERE ID = :instOkTopH.Id];
        KbManagement.PublishingService.publishArticle(instOkTopHSec.KnowledgeArticleId, true); 
        
        //Testing translated articles
        id = KbManagement.PublishingService.submitForTranslation(instOkTopHSec.KnowledgeArticleId,'de',UserInfo.getUserId(),system.today());
        KbManagement.PublishingService.completeTranslation(id);
        //KbManagement.PublishingService.publishArticle(id, true);
        //Testing translated articles
        
        Video__kav instOkVideo = new Video__kav();
        instOkVideo.Title = 'Test Test is Okf';
        instOkVideo.Summary = 'Test Test is Okf';
        instOkVideo.UrlName = 'Testy';
        instOkVideo.IsVisibleInCsp = true;
        insert instOkVideo;
        Video__DataCategorySelection insftOfVideo =  new Video__DataCategorySelection();
        insftOfVideo.DataCategoryGroupName = 'Products';
        insftOfVideo.DataCategoryName = 'OnArrival';
        insftOfVideo.ParentId = instOkVideo.Id;
        insert insftOfVideo;
        Video__DataCategorySelection insftOfVideoSec =  new Video__DataCategorySelection();
        insftOfVideoSec.DataCategoryGroupName = 'Products';
        insftOfVideoSec.DataCategoryName = 'CrowdCompass';
        insftOfVideoSec.ParentId = instOkVideo.Id;
        insert insftOfVideoSec;
        
        Video__kav instOkVideoSec = [SELECT KnowledgeArticleId FROM Video__kav WHERE ID = :instOkVideo.Id];
        KbManagement.PublishingService.publishArticle(instOkVideoSec.KnowledgeArticleId, true); 
        
        id = KbManagement.PublishingService.submitForTranslation(instOkVideoSec.KnowledgeArticleId,'de',UserInfo.getUserId(),system.today());
        KbManagement.PublishingService.completeTranslation(id);
        
        Download__kav instOkDownL = new Download__kav();
        instOkDownL.Title = 'Test Test is Okf';
        instOkDownL.Summary = 'Test Test is Okf';
        instOkDownL.UrlName = 'Testyssssww';
        instOkDownL.IsVisibleInCsp = true;
        insert instOkDownL;
        Download__DataCategorySelection insftOfDownDCS =  new Download__DataCategorySelection();
        insftOfDownDCS.DataCategoryGroupName = 'Products';
        insftOfDownDCS.DataCategoryName = 'OnArrival';
        insftOfDownDCS.ParentId = instOkDownL.Id;
        insert insftOfDownDCS;
        Download__DataCategorySelection insftOfDownDCSSec =  new Download__DataCategorySelection();
        insftOfDownDCSSec.DataCategoryGroupName = 'Products';
        insftOfDownDCSSec.DataCategoryName = 'CrowdCompass';
        insftOfDownDCSSec.ParentId = instOkDownL.Id;
        insert insftOfDownDCSSec;
        
        Download__kav instOkDownLSec = [SELECT KnowledgeArticleId FROM Download__kav WHERE ID = :instOkDownL.Id];
        KbManagement.PublishingService.publishArticle(instOkDownLSec.KnowledgeArticleId, true);
        //Testing translated articles
        id = KbManagement.PublishingService.submitForTranslation(instOkDownLSec.KnowledgeArticleId,'de',UserInfo.getUserId(),system.today());
        KbManagement.PublishingService.completeTranslation(id);
        //KbManagement.PublishingService.publishArticle(id, true);
        //Testing translated articles
        
        KbManagement.PublishingService.publishArticle(insertedTestFaq.KnowledgeArticleId, true); 
        //Testing translated articles
        id = KbManagement.PublishingService.submitForTranslation(insertedTestFaq.KnowledgeArticleId,'de',UserInfo.getUserId(),system.today());
        KbManagement.PublishingService.completeTranslation(id);
        //KbManagement.PublishingService.publishArticle(id, true);
        //Testing translated articles
        
        Release_Notes__kav instOfReleaseNote = new Release_Notes__kav();
        instOfReleaseNote.Title = 'Test Test is Okf';
        instOfReleaseNote.Summary = 'Test Test is Okf';
        instOfReleaseNote.UrlName = 'TestysssswwTest';
        instOfReleaseNote.IsVisibleInCsp = true;
        insert instOfReleaseNote;
        
        Release_Notes__DataCategorySelection instOfReleaseNoteDCSONA = new Release_Notes__DataCategorySelection();
        instOfReleaseNoteDCSONA.DataCategoryGroupName = 'Products';
        instOfReleaseNoteDCSONA.DataCategoryName = 'OnArrival';
        instOfReleaseNoteDCSONA.ParentId = instOfReleaseNote.Id;
        insert instOfReleaseNoteDCSONA;
        
        Release_Notes__DataCategorySelection instOfReleaseNoteDCS = new Release_Notes__DataCategorySelection();
        instOfReleaseNoteDCS.DataCategoryGroupName = 'Products';
        instOfReleaseNoteDCS.DataCategoryName = 'CrowdCompass';
        instOfReleaseNoteDCS.ParentId = instOfReleaseNote.Id;
        insert instOfReleaseNoteDCS;
        
        Release_Notes__kav instOfReleaseNoteSec = [SELECT KnowledgeArticleId FROM Release_Notes__kav WHERE ID = :instOfReleaseNote.Id];
        KbManagement.PublishingService.publishArticle(instOfReleaseNoteSec.KnowledgeArticleId, true);
        
        id = KbManagement.PublishingService.submitForTranslation(instOfReleaseNoteSec.KnowledgeArticleId,'de',UserInfo.getUserId(),system.today());
        KbManagement.PublishingService.completeTranslation(id);
        
        lstKAV = [SELECT ID,PublishStatus FROM KnowledgeArticleVersion WHERE PublishStatus='Online' AND Language = 'en_US' AND IsLatestVersion=true];
        for(KnowledgeArticleVersion instKAV :  lstKAV){
            lstKAVId.add(instKAV.Id);
        }
        lstKAV = [SELECT ID,PublishStatus FROM KnowledgeArticleVersion WHERE PublishStatus='Online' AND Language = 'de' AND IsLatestVersion=true];
        for(KnowledgeArticleVersion instKAV :  lstKAV){
            lstKAVId.add(instKAV.Id);
        }
        //system.debug('instOfFaq.PublishStatus++'+instKAV.PublishStatus);
        
        gd = Schema.getGlobalDescribe();
        for(String s : gd.keySet()) {
            if (s.contains('__kav')) {
                kavNames.add(s);
            }
        }
        
        mapArticleTypeName = new Map<String,String>();
        Schema.DescribeSObjectResult sor;
        for (String s : kavNames) {
            system.debug(s);
            sor = gd.get(s).getDescribe();
            system.debug(sor);
            mapArticleTypeName.put(sor.getName(),sor.getLabel());
            
            system.debug(mapArticleTypeName);
            kavObjPrefixMap.put(sor.getKeyPrefix().toLowerCase(), sor);
            system.debug(sor.getKeyPrefix().toLowerCase());
        }
        
        
        for(String instSTR : mapArticleTypeName.Keyset()){
            
            if(prodSelTest != '' && prodSelTest!=null)
            prodSelTest = prodSelTest+';'+instSTR;
            else
            prodSelTest = instSTR;
            
            system.debug('prodSelTest++'+prodSelTest);
        }
        //ConnectApi.CommunityPage instOfAPI = ConnectApi.Communities.getCommunities();
        List<NetworkMember> netMem = [SELECT id,NetworkId,MemberId FROM NetworkMember WHERE MemberId=:instUsr.Id];
        system.debug(netMem);
        /*
        NetworkMemberGroup nmgInsert = new NetworkMemberGroup();
        nmgInsert.AssignmentStatus = 'Added';
        nmgInsert.NetworkId = instOfAPI.Communities[0].id;
        nmgInsert.ParentId = instUsr.Id;
        Database.SaveResult[] results = connection.create(new SObject[] { nmgInsert });
        */
    }
    static testMethod void myUnitTest(){
        system.runAs(instUsr){
            
            Community comm =  [SELECT ID FROM Community WHERE Name='Products'];
            List<Question> lstQues = new List<Question>();
            List<Id> lstQuesId = new List<Id>();
            for(Integer i=0;i<9;i++){
                Question instOfSev = new Question();
                instOfSev.Body = 'Test Test is Okf';
                instOfSev.Title ='Test Test is Okf';
                instOfSev.CommunityId = comm.Id;
                lstQues.add(instOfSev);
            }
            insert lstQues;
            for(Question instOfQues : lstQues){
                lstQuesId.add(instOfQues.Id);
            }
            
            String[] lstStr = new String[]{'CSN_Planner','CSN_Supplier','eMarketing','Event','Survey','CrowdTorch_Ticketing','OnArrival','SocialWall','CrowdCompass'};
            Integer Counter = 0;
            system.debug(lstStr[0]);
            List<QuestionDataCategorySelection> lstQuesDCS = new List<QuestionDataCategorySelection>();
            for(Question instQues :  lstQues){
                QuestionDataCategorySelection instOfQDCSSev = new QuestionDataCategorySelection();
                instOfQDCSSev.DataCategoryGroupName = 'Products';
                system.debug('lstStr[Counter]+++'+lstStr[Counter]);
                instOfQDCSSev.DataCategoryName = lstStr[Counter];
                instOfQDCSSev.ParentId = instQues.id;
                lstQuesDCS.add(instOfQDCSSev);
                Counter++;
            }
            insert lstQuesDCS;
            
            List<Id> fixedSearchResults = new List<Id>();
            fixedSearchResults.addall(lstQuesId);
            Test.setFixedSearchResults(fixedSearchResults);
            
            Apexpages.currentPage().getParameters().put('searchFor','Test');
            CommunitySearchResultsAngularCls instOfCSR = new CommunitySearchResultsAngularCls();
            instOfCSR.productSel = 'CSN_Planner;CSN_Supplier;eMarketing;Event;Survey;CrowdTorch_Ticketing;OnArrival;SocialWall;CrowdCompass';
        }
    }
    static testMethod void myUnitTestSec(){
        system.runAs(instUsr){
            
            
            List<Id> fixedSearchResults = new List<Id>();
            fixedSearchResults.addAll(lstKAVId);
            system.debug(fixedSearchResults);
            Test.setFixedSearchResults(fixedSearchResults);
            
            Apexpages.currentPage().getParameters().put('searchFor','Test');
            CommunitySearchResultsAngularCls instOfCSR = new CommunitySearchResultsAngularCls();
            instOfCSR.productSel = 'CSN_Planner;CSN_Supplier;eMarketing;Event;Survey;CrowdTorch_Ticketing;OnArrival;SocialWall;CrowdCompass';
        }
    }
    static testMethod void myUnitTestSecThir(){
        system.runAs(instUsr){
            
            
            List<Id> fixedSearchResults = new List<Id>();
            fixedSearchResults.addAll(lstKAVId);
            system.debug(fixedSearchResults);
            Test.setFixedSearchResults(fixedSearchResults);
            
            Apexpages.currentPage().getParameters().put('searchFor','Test');
            CommunitySearchResultsAngularCls instOfCSR = new CommunitySearchResultsAngularCls();
            instOfCSR.productSel = 'CSN_Planner;CSN_Supplier;eMarketing;Event;Survey;CrowdTorch_Ticketing;OnArrival;SocialWall;CrowdCompass';
            instOfCSR.productSel = 'All';
        }
    }
    static testMethod void myUnitTestFor(){
        system.runAs(instUsr){
            
            Community comm =  [SELECT ID FROM Community WHERE Name='Products'];
            List<Question> lstQues = new List<Question>();
            List<Id> lstQuesId = new List<Id>();
            for(Integer i=0;i<9;i++){
                Question instOfSev = new Question();
                instOfSev.Body = 'Test Test is Okf';
                instOfSev.Title ='Test Test is Okf';
                instOfSev.CommunityId = comm.Id;
                lstQues.add(instOfSev);
            }
            insert lstQues;
            for(Question instOfQues : lstQues){
                lstQuesId.add(instOfQues.Id);
            }
            
            String[] lstStr = new String[]{'CSN_Planner','CSN_Supplier','eMarketing','Event','Survey','CrowdTorch_Ticketing','OnArrival','SocialWall','CrowdCompass'};
            Integer Counter = 0;
            system.debug(lstStr[0]);
            List<QuestionDataCategorySelection> lstQuesDCS = new List<QuestionDataCategorySelection>();
            for(Question instQues :  lstQues){
                QuestionDataCategorySelection instOfQDCSSev = new QuestionDataCategorySelection();
                instOfQDCSSev.DataCategoryGroupName = 'Products';
                system.debug('lstStr[Counter]+++'+lstStr[Counter]);
                instOfQDCSSev.DataCategoryName = lstStr[Counter];
                instOfQDCSSev.ParentId = instQues.id;
                lstQuesDCS.add(instOfQDCSSev);
                Counter++;
            }
            insert lstQuesDCS;
            
            List<Id> fixedSearchResults = new List<Id>();
            fixedSearchResults.addall(lstQuesId);
            Test.setFixedSearchResults(fixedSearchResults);
            
            Apexpages.currentPage().getParameters().put('searchFor','Test');
            CommunitySearchResultsAngularCls instOfCSR = new CommunitySearchResultsAngularCls();
        }
    }
    
    static testMethod void myUnitTestFifth(){
        system.runAs(instUsr){
            system.debug('Network.getNetworkId()++++'+Network.getNetworkId());
            CommunityHomePageCls instOfCHPGC = new CommunityHomePageCls();
            instOfCHPGC.searchTerm = 'Test';
            instOfCHPGC.search = 'Test';
            instOfCHPGC.selectedMovie = 'Test';
            instOfCHPGC.classvalue = 0;
            instOfCHPGC.counter = 0;
            //instOfCHPGC.Lang = 'de';
            instOfCHPGC.search();
        }
    }
    static testMethod void myUnitTestSixth(){
        Apexpages.currentpage().getparameters().put('id',instUsr.Id);
        CommunityUserDetCls instCUDS = new CommunityUserDetCls();
    } 
    static testMethod void myUnitTestSeventh(){
        CommunityAnnouncementCls instCUDS = new CommunityAnnouncementCls();
    } 
    static testMethod void myUnitTestEight(){
        FAQ__kav instOfFaq = new FAQ__kav();
        instOfFaq.Title = 'Test Test is Okf';
        instOfFaq.Summary = 'Test Test is Okf';
        instOfFaq.UrlName = 'Testpopo';
        instOfFaq.Question__c = 'Test Test is Okf';
        instOfFaq.IsVisibleInPkb = true;
        insert instOfFaq;
        
        FAQ__DataCategorySelection insftOfFAWDCS =  new FAQ__DataCategorySelection();
        insftOfFAWDCS.DataCategoryGroupName = 'Products';
        insftOfFAWDCS.DataCategoryName = 'CSN_Planner';
        insftOfFAWDCS.ParentId = instOfFaq.Id;
        insert insftOfFAWDCS;
        FAQ__DataCategorySelection insftOfFAWDCSSec =  new FAQ__DataCategorySelection();
        insftOfFAWDCSSec.DataCategoryGroupName = 'Products';
        insftOfFAWDCSSec.DataCategoryName = 'CrowdTorch_Ticketing';
        insftOfFAWDCSSec.ParentId = instOfFaq.Id;
        insert insftOfFAWDCSSec;
        FAQ__kav insertedTestFaq = [SELECT KnowledgeArticleId FROM FAQ__kav WHERE ID = :instOfFaq.Id];
        KbManagement.PublishingService.publishArticle(insertedTestFaq.KnowledgeArticleId, true);
        
        system.runAs(instUsr){
            List<KnowledgeArticleVersion>lstKAVSec = [SELECT ID,ArticleNumber,SourceId,PublishStatus,Title FROM KnowledgeArticleVersion WHERE PublishStatus='Online' AND Language = 'en_US' AND IsLatestVersion=true];
            //KnowledgeArticleVersion instOfKAVSec = [SELECT KnowledgeArticleId,Summary,ArticleType,title,ArticleNumber FROM KnowledgeArticleVersion WHERE KnowledgeArticleId=:instOfFaq.Id AND PublishStatus = 'Online'];
            //KnowledgeArticleVersion instOfKAV = [SELECT KnowledgeArticleId,Summary,ArticleType,title,ArticleNumber FROM KnowledgeArticleVersion WHERE Id=:lstKAVId[0] AND IsLatestVersion=true];
            system.debug('string.valueof(lstKAVId[0])++'+string.valueof(lstKAVSec[0].PublishStatus));
            Apexpages.currentpage().getparameters().put('Id',string.valueof(lstKAVSec[0].ArticleNumber));//latest code
            Apexpages.currentpage().getparameters().put('Lang','en_US');
            Apexpages.currentpage().getparameters().put('searchFor','Test');
            CommunitySearchResultsAngularCls  instCUDS = new CommunitySearchResultsAngularCls();
            Apexpages.currentpage().getparameters().put('Id',string.valueof(lstKAVSec[1].ArticleNumber));//latest code
            
            Apexpages.currentpage().getparameters().put('Id',string.valueof(lstKAVSec[2].ArticleNumber));//latest code
            CommunitySearchResultsAngularCls  instCUDSThir = new CommunitySearchResultsAngularCls();
            
            Apexpages.currentpage().getparameters().put('Id',string.valueof(lstKAVSec[3].ArticleNumber));//latest code ArticleNumber instead of Id
            CommunitySearchResultsAngularCls  instCUDSFor = new CommunitySearchResultsAngularCls();
        }
    }    
    
    static testMethod void myUnitTestNine(){
        FAQ__kav instOfFaq = new FAQ__kav();
        instOfFaq.Title = 'Test Test is Okf';
        instOfFaq.Summary = 'Test Test is Okf';
        instOfFaq.UrlName = 'Testpopouu';
        instOfFaq.Question__c = 'Test Test is Okf';
        instOfFaq.IsVisibleInPkb = true;
        insert instOfFaq;
        
        FAQ__DataCategorySelection insftOfFAWDCS =  new FAQ__DataCategorySelection();
        insftOfFAWDCS.DataCategoryGroupName = 'Products';
        insftOfFAWDCS.DataCategoryName = 'CSN_Planner';
        insftOfFAWDCS.ParentId = instOfFaq.Id;
        insert insftOfFAWDCS;
        FAQ__DataCategorySelection insftOfFAWDCSSec =  new FAQ__DataCategorySelection();
        insftOfFAWDCSSec.DataCategoryGroupName = 'Products';
        insftOfFAWDCSSec.DataCategoryName = 'CrowdTorch_Ticketing';
        insftOfFAWDCSSec.ParentId = instOfFaq.Id;
        insert insftOfFAWDCSSec;
        FAQ__kav insertedTestFaq = [SELECT KnowledgeArticleId FROM FAQ__kav WHERE ID = :instOfFaq.Id];
        KbManagement.PublishingService.publishArticle(insertedTestFaq.KnowledgeArticleId, true);
        
        List<KnowledgeArticleVersion>lstKAVSec = [SELECT ID,ArticleNumber,PublishStatus,KnowledgeArticleId FROM KnowledgeArticleVersion WHERE PublishStatus='Online' AND Language = 'en_US' AND IsLatestVersion=true];
        
        Community comm =  [SELECT ID FROM Community WHERE Name='Products'];
            List<Question> lstQues = new List<Question>();
            List<Id> lstQuesId = new List<Id>();
            for(Integer i=0;i<9;i++){
                Question instOfSev = new Question();
                instOfSev.Body = 'Test Test is Okf';
                instOfSev.Title ='Test Test is Okf';
                instOfSev.CommunityId = comm.Id;
                lstQues.add(instOfSev);
            }
            insert lstQues;
            for(Question instOfQues : lstQues){
                lstQuesId.add(instOfQues.Id);
            }
            
            String[] lstStr = new String[]{'CSN_Planner','CSN_Supplier','eMarketing','Event','Survey','CrowdTorch_Ticketing','OnArrival','SocialWall','CrowdCompass'};
            Integer Counter = 0;
            system.debug(lstStr[0]);
            List<QuestionDataCategorySelection> lstQuesDCS = new List<QuestionDataCategorySelection>();
            for(Question instQues :  lstQues){
                QuestionDataCategorySelection instOfQDCSSev = new QuestionDataCategorySelection();
                instOfQDCSSev.DataCategoryGroupName = 'Products';
                system.debug('lstStr[Counter]+++'+lstStr[Counter]);
                instOfQDCSSev.DataCategoryName = lstStr[Counter];
                instOfQDCSSev.ParentId = instQues.id;
                lstQuesDCS.add(instOfQDCSSev);
                Counter++;
            }
            insert lstQuesDCS;
            
            List<Id> fixedSearchResults = new List<Id>();
            fixedSearchResults.addall(lstQuesId);
            Test.setFixedSearchResults(fixedSearchResults);
            
        CommunityHeaderCls instOfCHC = new CommunityHeaderCls();
        CommunityHeaderCls.returnId(string.valueof(lstKAVSec[0].Id));
        Apexpages.currentpage().getparameters().put('id',lstKAVSec[0].KnowledgeArticleId );
        Apexpages.currentpage().getparameters().put('Lang','en_US');
        Apexpages.currentpage().getparameters().put('searchFor','Test');
        CommunitySearchResultsAngularCls instCommunityArti =  new CommunitySearchResultsAngularCls();
        
    }
    public static testMethod void fakeMethod(){
        CommunitySearchResultsAngularCls.fakeMethod();
    }
}