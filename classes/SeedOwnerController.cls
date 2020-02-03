public class SeedOwnerController {
    
// ===============================
// AUTHOR     : Shanu Aggarwal    
// CREATED DATE     : 28/04/2016
// PURPOSE     : Seed Owner and Seed Expiration Date Field on Account
// TEST CLASS :   SeedOwnerControllerTest
// SPECIAL NOTES:
// ===============================

    ApexPages.StandardController ctr;
    
    public SeedOwnerController(ApexPages.StandardController ctr) {
    
        this.ctr = ctr;
       
    }
    
    
    public pageReference  Save(){
         ctr.save();
         return null;
    }
    
    public pageReference cancel(){
        return null;
    }

}