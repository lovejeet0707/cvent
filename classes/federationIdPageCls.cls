/*
//////////////////////////////////////
//      @author Abhishek Pandey     //
/////////////////////////////////////
Version :   1.0
Date : 1st Oct 2014
Description : Supplies user data to page federationIdPage with provided federation Id. 
*/
public class federationIdPageCls {
    public static string fedIdStr {get;set;}
    public List<User> lstUsers {get;set;}
    public String infoMessage {get;set;}
    public Boolean userNameFilter {get;set;}
    public federationIdPageCls (){
        fedIdStr = '';
        lstUsers = new List<User>();
        infoMessage = 'No such user found';
        userNameFilter = false;
    }
    
    public pagereference test(){
        return null;
    }
    public pagereference search(){
        system.debug('fedIdStr+++'+fedIdStr);
        userNameFilter = false;
        fedIdStr = fedIdStr.trim();
        lstUsers = [SELECT ID,Name,FederationIdentifier FROM USER WHERE FederationIdentifier =: fedIdStr And FederationIdentifier !=null];
        if(lstUsers.isEmpty())
        {
            lstUsers = [SELECT Id,Name,Username FROM USER WHERE Username =: fedIdStr And Username !=null];
            System.debug('inside of user filer');
            if(!lstUsers.isEmpty())
                userNameFilter = true;
        }
        system.debug('fedIdStr++'+fedIdStr.length());
        system.debug('fedIdStr++'+fedIdStr != '');
        system.debug('lstUsers.size()++'+lstUsers.size());
        /*if((fedIdStr.length() > 0) && (lstUsers.size()==0)){
            infoMessage = 'No such user found';
            system.debug('infoMessage+++'+infoMessage);
        }else if(fedIdStr.length() > 0 && (lstUsers.size()>0)){
            infoMessage = '';
        }else if((fedIdStr.length() == 0) && (lstUsers.size()==0)){
            infoMessage = 'Please enter some value';
            system.debug('infoMessage+++'+infoMessage);
        }*/
        system.debug(lstUsers);
        return null;
    }
}