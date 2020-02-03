@Istest(seealldata='true')

private class TestBrowseKnowledgeController {

public static testMethod void TestBrowseKnowledgeController() {
       
       //Use the PageReference Apex class to instantiate a page
       PageReference pageRef = Page.KnowledgeCategory;
       
       //In this case, the Visualforce page named 'KnowledgeCategory' is the starting point of this test method. 
       Test.setCurrentPage(pageRef);
     
       //Instantiate and construct the controller class.   
       BrowseKnowledgeController controller = new BrowseKnowledgeController();

       //Example of calling an Action method. Same as calling any other Apex method. 
       //Normally this is executed by a user clicking a button or a link from the Visualforce
       //page, but in the test method, just test the action method the same as any 
       //other method by calling it directly. 

       //The .getURL will return the page url the Save() method returns.
      // String nextPage = controller.save().getUrl();

       //Check that the save() method returns the proper URL.
    //   System.assertEquals('/apex/failure?error=noParam' ,'BrowseKnowledgeController');

       //Add parameters to page URL
       ApexPages.currentPage().getParameters().put('qp', 'yyyy');
     
       //Instantiate a new controller with all parameters in the page
       controller = new BrowseKnowledgeController(); 

       //Example of calling the 'setter' method for several properties. 
       //Normally these setter methods are initiated by a user interacting with the Visualforce page, 
       //but in a test method, just call the setter method directly. 
    //   controller.setLastName('lastname');
     //  controller.setFirstName('firstname');
     //  controller.setCompany('acme');
       //controller.setEmail('firstlast@acme.com');
     //  nextPage = controller.save().getUrl();

       //Verify that the KnowledgeCategory page displays
     //  System.assertEquals('/apex/KnowledgeCategory?core.apexpages.devmode.url=1','true');
       
   }
   }