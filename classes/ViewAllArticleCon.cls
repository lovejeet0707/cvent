/* Name - Rishi Ojha 
   Purpose - Portal 2.0
   Test class - TestViewAllArticleCon */

Public class ViewAllArticleCon{

Public string articleCategory {get;set;}
Public List<KnowledgeArticleVersion>CategoryArticleList{get;set;}
public List<KnowledgeArticleVersion>getCategoryArticleList(){
    return CategoryArticleList;
}
Public String resultTitle{get;set;}
    
Public ViewAllArticleCon(){    
    articleCategory = ApexPages.currentPage().getParameters().get('Category');    
    try{
        CategoryArticleList=getAllarticleByCategory(articleCategory);  
    }catch(exception e){}      
}
    
Public List<KnowledgeArticleVersion> getAllarticleByCategory (String articleCategory){    
    String Categoryquery= '';
    String Query='';   
    CategoryArticleList =new List<KnowledgeArticleVersion>();
    if (articleCategory == 'Event'){
            Categoryquery='Event__c)';  
            resultTitle='Event Articles';   
    }else if (articleCategory == 'CSNSupplier'){
            Categoryquery='CSN_Supplier__c)'; 
            resultTitle='CSN-Supplier Articles';     
    }else if (articleCategory == 'CSN-Planner'){
            Categoryquery='CSN_Planner__c)'; 
            resultTitle='CSN-Planner Articles';                 
    }else if (articleCategory == 'Survey'){
            Categoryquery='Survey__c)';   
            resultTitle='Inquisium Articles';                
    }else if (articleCategory == 'eMarketing'){
            Categoryquery='eMarketing__c)';  
            resultTitle='eMarketing Articles';                
    }else if (articleCategory == 'CrowdTorch Ticketing'){
            Categoryquery='CrowdTorch_Ticketing__c)';   
            resultTitle='CrowdTorch Articles';                
    }else if (articleCategory == 'Meetings_Management'){
            Categoryquery='Meetings_Management__c)';
            resultTitle='Meetings Management Articles';                  
    }else if (articleCategory == 'OnArrival'){
            Categoryquery='OnArrival__c)';
            resultTitle='OnArrival Articles';                  
    }else if (articleCategory == 'SocialWall'){
            Categoryquery='SocialWall__c)';
            resultTitle='SocialWall Articles';                  
    }else if (articleCategory == 'CrowdCompass'){
            Categoryquery='CrowdCompass__c)';
            resultTitle='CrowdCompass Articles';                  
    }else if (articleCategory == 'All'){
            Categoryquery='Event__c, Survey__c, CSN_Planner__c, CSN_Supplier__c, eMarketing__c,  Event_Blue__c, CrowdTorch_Ticketing__c)';
            resultTitle='Popular Articles';                  
    } 
      
    Query = Query + 'SELECT ArticleNumber,ArticleType,Id,KnowledgeArticleId,Language,PublishStatus,Summary,Title,UrlName FROM KnowledgeArticleVersion WHERE ArticleNumber != \'\' AND PublishStatus = \'Online\' AND Language = \'en_US\' WITH DATA CATEGORY Products__c  AT ('+Categoryquery+' Limit 199';    
    System.debug('Query==>'+Query);
    List<KnowledgeArticleVersion>CategoryArticleList =Database.query(Query);
    System.debug('result===>'+CategoryArticleList );
    return CategoryArticleList;
}
    
 }