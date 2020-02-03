///////////////////////////////////////////////////////////////////////
// Tuesday 24 Feb 2015 
// Author : Vaibhav Jain
// This trigger is created to update supervisor email address in field on Sales Resources so that email alerts can be sent to Sales Requester.
///////////////////////////////////////////////////////////////////////

trigger updateSupervisorEmail on Sales_Resources__c (before insert, before update) {
    Map<Id,Sales_Resources__c> srMap = new Map<Id,Sales_Resources__c>();
    if(Trigger.isInsert){                                                                                        // check if trigger is insert and check the field Sales Requester is null or has a value
        for(Sales_Resources__c sr : Trigger.new){
            if(sr.Sales_Requestor__c != null)
                srMap.put(sr.Sales_Requestor__c,sr);
        }
    }
    if(Trigger.isUpdate){                                                                                    // check if trigger is update and check the field Sales Requester is null or has been updated
        for(Sales_Resources__c sr : Trigger.new){
            Sales_Resources__c beforeUpdateSup = System.Trigger.oldMap.get(sr.id);
            if(sr.Sales_Requestor__c != null &&(beforeUpdateSup.Sales_Requestor__c != sr.Sales_Requestor__c ))
                srMap.put(sr.Sales_Requestor__c,sr);
        }
    }
    Map<Id,User> emailMap = new Map<Id,User>();
    if(srMap.size()>0){                                                                                    // find the email of the Sales requester
        for(User u : [Select email from user where id in: srMap.keyset()]){
            emailMap.put(srMap.get(u.id).id,u);
        }
    }
    
    if(emailMap.size()>0){
        for(Sales_Resources__c sr : Trigger.New){                                            // update the email of Sales Requester in corresponding field
            sr.Sales_Requester_Email__c = emailMap.get(sr.id).email;
        }
    }        

}