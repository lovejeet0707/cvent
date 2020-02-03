public class SeedOwnerAccController {
    
// ===============================
// AUTHOR     : Shanu Aggarwal    
// CREATED DATE     : 28/04/2016
// PURPOSE     : Seed Owner and Seed Expiration Date Field on Account
// TEST CLASS :   SeedOwnerAccControllerTest
// SPECIAL NOTES:
// ===============================

    Account acc;
    public boolean showBtn {get;set;}
    
    public SeedOwnerAccController(ApexPages.StandardController controller) {
        acc= (Account)controller.getRecord();
        showBtn =true;
    }
    
    
    public pageReference  Save(){
         update acc;
         return null;
    }
    
    public pageReference cancel(){
        return null;
    }

}