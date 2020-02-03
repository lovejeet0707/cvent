/*Logic for the browse knowledge component ----------------------*/
/*Vf used for this class is Tree --------------------------------*/
/*Writing Wrapper class to contain the nodes and their children */
/*Test class - TestBrowseKnowledgeController */

public class BrowseKnowledgeController {

public class ArticleMapper{

public string linkvalue {get;set;}
public string linkname {get;set;}

}

/* Wrapper class to contain the nodes and their children */
public class cNodes
{

 public List <BrowseKnowledgeController.ArticleMapper>  parent {get; set;}
 Public String gparent {get;set;}

 public cNodes(String gp, List<BrowseKnowledgeController.ArticleMapper> p)
 {
     parent = p;
     gparent = gp;
 }
}

/* end of Wrapper class */ 

Public List<cNodes> hierarchy;

Public List<cNodes> getmainnodes()
{
    hierarchy = new List<cNodes>();
    List<String> tempparent = new List<String> { 'Event', 'CSN-Supplier' ,'CSN-Planner', 'Inquisium' , 'eMarketing', 'CrowdCompass', 'OnArrival' , 'SocialWall'};
    List <BrowseKnowledge__c>  templink = [SELECT Category__c,Link_Description__c,Link__c,Name,Order_No__c FROM BrowseKnowledge__c order by Category__c,Order_No__c asc limit 100];
    List<ArticleMapper> eventcollectedlist = new List <ArticleMapper> ();
    List<ArticleMapper> Suppliercollectedlist = new List <ArticleMapper> ();
    List<ArticleMapper> Plannercollectedlist = new List <ArticleMapper> ();
    List<ArticleMapper> Inquisiumcollectedlist = new List <ArticleMapper> ();
    List<ArticleMapper> eMarketingcollectedlist = new List <ArticleMapper> ();
    List<ArticleMapper> CrowdCompasscollectedlist = new List <ArticleMapper> ();
    List<ArticleMapper> OnArrivalcollectedlist = new List <ArticleMapper> ();
    List<ArticleMapper> SocialWallcollectedlist = new List <ArticleMapper> ();
    
    for (Integer i =0; i< templink.size() ; i++)
    
    {
    if ( templink[i].Category__c == 'Event' ) 
    {
       ArticleMapper var = new ArticleMapper();
       var.linkvalue = templink[i].Link__c;
       var.linkname = templink[i].Link_Description__c;
       eventcollectedlist.add(var);
     
    } else if ( templink[i].Category__c == 'CSN-Supplier' ) {
       ArticleMapper var = new ArticleMapper();
       var.linkvalue = templink[i].Link__c;
       var.linkname = templink[i].Link_Description__c;
       Suppliercollectedlist.add(var);
    } else if ( templink[i].Category__c == 'CSN-Planner' ) {
       ArticleMapper var = new ArticleMapper();
       var.linkvalue = templink[i].Link__c;
       var.linkname = templink[i].Link_Description__c;
       Plannercollectedlist.add(var);
    } else if ( templink[i].Category__c == 'Inquisium' ) {
       ArticleMapper var = new ArticleMapper();
       var.linkvalue = templink[i].Link__c;
       var.linkname = templink[i].Link_Description__c;
       Inquisiumcollectedlist.add(var);
    } else if ( templink[i].Category__c == 'eMarketing' ) {
       ArticleMapper var = new ArticleMapper();
       var.linkvalue = templink[i].Link__c;
       var.linkname = templink[i].Link_Description__c;
       eMarketingcollectedlist.add(var);
    } else if ( templink[i].Category__c == 'CrowdCompass' ) {
       ArticleMapper var = new ArticleMapper();
       var.linkvalue = templink[i].Link__c;
       var.linkname = templink[i].Link_Description__c;
       CrowdCompasscollectedlist.add(var);
    } else if ( templink[i].Category__c == 'OnArrival' ) {
       ArticleMapper var = new ArticleMapper();
       var.linkvalue = templink[i].Link__c;
       var.linkname = templink[i].Link_Description__c;
       OnArrivalcollectedlist.add(var);
    } else if ( templink[i].Category__c == 'SocialWall' ) {
       ArticleMapper var = new ArticleMapper();
       var.linkvalue = templink[i].Link__c;
       var.linkname = templink[i].Link_Description__c;
       SocialWallcollectedlist.add(var);
    } 
    
     }  

       hierarchy.add(new cNodes('Event',eventcollectedlist ));
       hierarchy.add(new cNodes('CSN-Supplier',Suppliercollectedlist));
       hierarchy.add(new cNodes('CSN-Planner',Plannercollectedlist));
       hierarchy.add(new cNodes('Inquisium',Inquisiumcollectedlist));
       hierarchy.add(new cNodes('eMarketing',eMarketingcollectedlist));
       hierarchy.add(new cNodes('CrowdCompass',CrowdCompasscollectedlist));
       hierarchy.add(new cNodes('OnArrival',OnArrivalcollectedlist));
       hierarchy.add(new cNodes('SocialWall',SocialWallcollectedlist));
       return hierarchy;
}   
}