//Developed by Rishi Ojha
//Dated : 05/08/2013
//******************Helper class for the Account status Trigger***************


public class AccHelperClass {

   private static boolean alreadyCreated = false;


    public static boolean hasAlreadyCreatedFollowUp() {
        return alreadyCreated;
    }

    public static void setAlreadyCreatedFollowUp() {
        alreadyCreated = true;
    }
}