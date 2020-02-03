/*
Global User util class for looking up Profile and UserRole Ids
Authored by: Sandeep Kumar
written 29 March, 2017
*/

public with sharing class UserProfileUtil{
    // Holds the master map of all User Profiles in the system
    private static Map<String,Id> allProfiles;
    
    // Holds the master map of all User Role in the system
    private static Map<String,Id> allRoles;
    
    // Method returns true if Profile Id provided is the the user profile map
    public static Boolean validProfile(Id profileId){
        UserProfileUtil.getProfiles();
        // Convert map values to set and check if contains profile Id
        return new Set<Id>(allProfiles.values()).contains(profileId);
    }    
    
    // Helper Method to get Profiles
    private static void getProfiles(){
        // If profile map not populated
        if(allProfiles==null) {
            UserProfileUtil.allProfiles = new Map<String, Id>();
            //Create the record type map
            for(Profile p : [Select Id, Name From Profile]) {
                //Add a map entry, force to lowercase
                UserProfileUtil.allProfiles.put(p.Name.toLowerCase(), p.Id);
            }
        }
    }
    // Method returns the Id of the User Profile with a matching Name, case insensitive.
    // Will query all user Profiles in the system on first call, but returns from map after initialized.
    public static Id getProfileIDByName(String profileName) {
        UserProfileUtil.getProfiles();
        // return the profile Id from the map (match to lowercase)
        return allProfiles.get(profileName.toLowerCase());
    }
    /*
    // Method returns the Id of the UserRole with a matching DeveloperName, case insensitive.
    // Will query all UserRoles in the system on first call, but returns from map after initialized.
    public static Id getRoleIDByDevName(String roleDeveloperName) {
        UserProfileUtil.getRoles();
        // return the role Id from the map (match to lowercase)
        return allRoles.get(roleDeveloperName.toLowerCase());
    }
    
    // Helper method to get Roles
    private static void getRoles(){
        // If role map not populated
        if(allRoles==null) {
            UserProfileUtil.allRoles = new Map<String, Id>();
            //Create the record type map
            for(UserRole r : [Select Id, Name, DeveloperName From UserRole]) {
                //Add a map entry, force to lowercase
                UserProfileUtil.allRoles.put(r.DeveloperName.toLowerCase(), r.Id);
            }
        }
    }
    
    // Method returns true if UserRole Id provided is the the user role map
    public static Boolean validRole(Id profileId){
        UserProfileUtil.getRoles();
        // Convert map values to set and check if contains role Id
        return new Set<Id>(allRoles.values()).contains(profileId);
    }
	*/
}