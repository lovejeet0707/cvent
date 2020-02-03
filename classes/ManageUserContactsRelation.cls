/***Test Class : EBProjectCustomRelatedList_ContExt_Test : Udita ****/
public class ManageUserContactsRelation {    

   public static void addUserContactsRelation(Set<Id> uSet)
    { 
        system.debug('Adding User Contact Relation Records ' );    
        Map<Id,User> uMap=new Map<Id,User>([SELECT Id,ContactId,AccountId,Email,isActive,(SELECT Id,PermissionSet.Label FROM PermissionSetAssignments)/*,Contact.Super_User__c  */
                                            FROM User 
                                            WHERE isActive=True AND Id IN :uSet]);//UD:Commented Super_User__c for FP:4thApril

        List<User> uList=uMap.values();
        Map<String,Id> EmailUserMap = new Map<String,Id>();        
        Map<Id,Id> ContactUserMap = new Map<Id,Id>();

        for(User u :uMap.values()) {
           EmailUserMap.put(u.Email,u.Id);
           ContactUserMap.put(u.ContactId,u.Id);
        }
        system.debug('----uMap'+uMap);
        system.debug('----ContactUserMap'+ContactUserMap);
        system.debug('----EmailUserMap'+EmailUserMap);
        Map<Id,Contact> cMap=new Map<Id,Contact>([SELECT Id,Email/*,Contact_Status__c*/,Creation_Source_System_External_Id__c,Creation_Source_System__c FROM Contact 
                                            WHERE /*Contact_Status__c!='No Longer at Company' AND*/ Email IN :EmailUserMap.KeySet()]);    //UD:Commented Contact_Status__c for FP:4thApril                                  

        Map<Id,User_Contact_Relation__c> ucrMap = new Map<Id,User_Contact_Relation__c>();

        for(Contact c: cMap.values()) {
           if(!ucrMap.KeySet().contains(c.Id) && EmailUserMap.get(c.Email)!=null){ 
               User_Contact_Relation__c ucr = new User_Contact_Relation__c(User__c=EmailUserMap.get(c.Email),Related_Contact__c=c.Id,SSO_User_Id__c=null);                                         
               if((c.Creation_Source_System__c=='ROL'||c.Creation_Source_System__c=='ROLUK'||c.Creation_Source_System__c=='ROLAINTL')&&!String.isBlank(c.Creation_Source_System_External_Id__c))
                   ucr.SSO_User_ID__c=c.Creation_Source_System_External_Id__c;               
               ucrMap.put(c.Id,ucr);            
           }         
        } 
    
        if(ucrMap.values().Size() > 0) {
           try { 
               Insert ucrMap.Values();                                                                          
               }
           catch (exception err)
               {
                System.Debug(Logginglevel.ERROR,'ManageUserContactsRelation.addUserContactsRelation - Error inserting new User Contact Relation!'+err.getMessage()+'\n'+ucrMap);
               }
        }        
    }


}