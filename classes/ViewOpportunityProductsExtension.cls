/**=====================================================================
 * Cvent India
 * Name: ViewOpportunityProductsExtension
 * Description: This class is a controller to VF page "ViewOpportunityProducts" and helps in redirecting to the "CloneOpportunityProducts" Page.
 * Created Date: [30/11/2016]
 * Created By: Hemant Rana
 *
 * Date Modified                Modified By                  Description of the update
 * []                           []                          []
 =====================================================================*/ 
public class ViewOpportunityProductsExtension {
    //OpportunityLineItem Id variable
    Id oppItemId;
    //Opportunity Id variable
    Id oppId;
    //OpportunityLineItem record
    private final OpportunityLineItem oppLineItemObj;
    /***
    * Constructor for the Class.
    ***/ 
    public ViewOpportunityProductsExtension(ApexPages.StandardController controller) {
        oppItemId = ApexPages.currentPage().getParameters().get('id');
        oppId = [SELECT Id,OpportunityId FROM OpportunityLineItem WHERE Id = : oppItemId].OpportunityId ; 
        oppLineItemObj = (OpportunityLineItem)controller.getRecord();
    }
    /***
    * clonePageRedirect - redirecting to "CloneOpportunityProducts" Page
    ***/  
    public pageReference clonePageRedirect(){
        String clonePageURL = '/apex/CloneOpportunityProducts?id='+oppItemId;
        PageReference oppProClone = new PageReference(clonePageURL);
        oppProClone.setRedirect(true);
        return oppProClone;
    }
    /***
    * deleteOpportunityLineItem - deleting OpportunityLineItem and redirecting to Opportunity Page
    ***/  
    public pageReference deleteOpportunityLineItem(){
        delete oppLineItemObj;
        String oppPageURL = '/'+oppId;
        PageReference opp = new PageReference(oppPageURL);
        opp.setRedirect(true);
        return opp;
    }
}