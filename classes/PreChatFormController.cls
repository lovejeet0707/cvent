public class PreChatFormController 
{
    public String CventAccountId {get;set;}
    public String CventContactId {get;set;}
    public String ContactPhoneNumber{get;set;}
    public PreChatFormController()
    {
        Id userId = UserInfo.getUserId();
        List<Account> associatedAccount;
        List<Contact> associatedContact;
        List<User> currentLoggedInUser = [select id,Account_ID__c,Contact_ID__c from User where Id =:userId LIMIT 1];
        System.debug('currentLoggedInUser[0].Account_ID__c>>>'+currentLoggedInUser[0].Account_ID__c);
       	if(!currentLoggedInUser.isEmpty())
        {
            associatedAccount = [select Id,Cvent_Account_ID__c from Account where Id =:currentLoggedInUser[0].Account_ID__c]; 
            associatedContact = [select Id,Phone from Contact where Id =:currentLoggedInUser[0].Contact_ID__c];
            CventContactId = currentLoggedInUser[0].Contact_ID__c;
        }
        if(!associatedAccount.isEmpty())
        {
            CventAccountId = associatedAccount[0].Cvent_Account_ID__c;
            System.debug('CventAccountId>>>>'+CventAccountId);
        }
        if(!associatedContact.isEmpty())
        {
            ContactPhoneNumber = associatedContact[0].Phone;
        }
    }
    
    public PageReference updateControllerForCheckbox()
    {
        return null;
    }
}