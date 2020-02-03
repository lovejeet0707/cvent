trigger renewalOppDel on Opportunity (before delete) {
    
    /* Skip execution if this user is setup to exempt triggers. This helps in one time data load as well */
    if(!BypassTriggerUtility.isTriggerEnabledForThisUserOrProfileId(UserInfo.getUserId())){
            return;
    } 

    String UserId = UserInfo.getuserId();
    user userRec =  [Select id from user where id = '005000000079DxB' or id = '00500000007C9c0' or id = '00500000007CeIa' limit 1];   
    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>(); 
    String[] toAddresses = new String[]{'vaibhav.jain@cvent.com','ZMahmood@cvent.com','Ankit.Jain@cvent.com'};
    for(opportunity  opp : trigger.old){
        if(UserId != userRec.Id && opp.Master_Type__c.contains('Renewal')) {Opp.addError('You are not authorised to delete this Opportunity.');}
        else if(opp.New_Type__c.contains('Renewal')){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(toAddresses);
            mail.setSenderDisplayName('CVENT Notifications');
            mail.setSubject('Opportunity deleted!');
            mail.setBccSender(false);
            mail.setUseSignature(false);
            mail.setHtmlBody ('Hi,</br></br>'+
            'An opportunity has been deleted. Please see details below: </br>' +
            'Opportunity Name : '+ opp.Name + '</br>' +
            'Opportunity Link : https://cvent.my.salesforce.com/'+ opp.Id + '</br>' +
            'Unique Id Opp : '+ opp.Unique_ID_Opp__c + '</br>' +
            'Contract Type : '+ opp.New_Type__c + '</br>' +
            'Close Date : '+ opp.CloseDate + '</br>' +
            'Product : '+ opp.Product__c + '</br>' +
            'Opportunity Owner : '+ opp.Owner + '</br>' +
            'Contract Total : '+ opp.New_Contract_Total__c + '</br>' +
            'Account Link : https://cvent.my.salesforce.com/'+ opp.AccountId+ '</br>' +
            'Deleted by: '+ UserInfo.getName()  + '</br></br>' +
            'Regards,</br>'+ 
            'Sales Support India');
            mails.add(mail);
        }
    }
    if(mails.size()>0)
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>(mails));
}