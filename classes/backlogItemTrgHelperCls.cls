/*
//////////////////////////////////////
//      @author Vaibhav Jain     //
/////////////////////////////////////
Version :   1.0
Date : 14th July 2015
*/
    public class backlogItemTrgHelperCls{
        
        public void OnBeforeInsert(List<Backlog_Item__c> newValues){  
        }
        
        public void OnAfterInsert(Map<Id,Backlog_Item__c> newMapValues){
            
        }
        public void OnBeforeUpdate(Map<Id,Backlog_Item__c> oldMapValues,Map<Id,Backlog_Item__c> newMapValues){ 
        }
        public void OnAfterUpdate(Map<Id,Backlog_Item__c> oldMapValues,Map<Id,Backlog_Item__c> newMapValues){
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            Set<Id> setIdOfBacklog = new Set<Id>();
            for(Backlog_Item__c instOfbacklog : newMapValues.values()){
                if(instOfbacklog.Status__c == 'Closed - Released' && instOfbacklog.Status__c != oldMapValues.get(instOfbacklog.id).Status__c){
                    setIdOfBacklog.add(instOfbacklog.id);
                }
            }
            List<Enhancement_Request__c> lstEnhReq = new List<Enhancement_Request__c>();
            system.debug('setIdOfBacklog : '+setIdOfBacklog);
            if(setIdOfBacklog.size()>0)
                lstEnhReq = [Select id,Name,Contact__c,Contact__r.AccountID,OwnerId,Product__c from Enhancement_Request__c where Related_Backlog_Item__c =: setIdOfBacklog];
            
            system.debug('lstEnhReq : '+lstEnhReq);
            //EmailTemplate emTemp = [SELECT Id,Name FROM EmailTemplate WHERE DeveloperName = 'X3_Strike_for_Public_Web2Case_Case_Closed'];
            EmailTemplate emTemp2 = [SELECT Id,Name FROM EmailTemplate WHERE DeveloperName = 'X3_Strike_for_Public_Web2Case_Info_Requested'];
            Set<ID> conIDs = new Set<ID>();
            Map<Id,Set<String>> mapAccIdProd = new Map<Id,Set<String>>();
            Map<Id,List<String>> mapAccIdNameEnh = new Map<Id,List<String>>();  
            for(Enhancement_Request__c insCon : lstEnhReq){
                if(mapAccIdNameEnh.containsKey(insCon.Contact__r.AccountID)){
                    List<String> setProd = mapAccIdNameEnh.get(insCon.Contact__r.AccountID);
                    setProd.add(insCon.Name);
                    if(insCon.Contact__r.AccountID != null)
                    mapAccIdNameEnh.put(insCon.Contact__r.AccountID,setProd);
                }else{
                    List<String> setProd = new List<String>();
                    setProd.add(insCon.Name);
                    if(insCon.Contact__r.AccountID != null)
                    mapAccIdNameEnh.put(insCon.Contact__r.AccountID,setProd);
                }
                
                if(mapAccIdProd.containsKey(insCon.Contact__r.AccountID)){
                    set<String> setProd = mapAccIdProd.get(insCon.Contact__r.AccountID);
                    setProd.add('CS - '+insCon.Product__c.trim());
                    if(insCon.Contact__r.AccountID != null)
                    mapAccIdProd.put(insCon.Contact__r.AccountID,setProd);
                }else{
                    set<String> setProd = new Set<string>();
                    setProd.add('CS - '+insCon.Product__c.trim());
                    if(insCon.Contact__r.AccountID != null)
                    mapAccIdProd.put(insCon.Contact__r.AccountID,setProd);
                }
                if(insCon.Contact__r.AccountID!=null)
                    conIDs.add(insCon.Contact__c);
                /*Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTargetObjectId(insCon.Contact__c);
                mail.setSenderDisplayName('CVENT Notifications');
                mail.setTemplateId(emTemp.id);
                mails.add(mail);*/
                OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'noreply_cc@cvent.com'];
                Messaging.SingleEmailMessage mailSec = new Messaging.SingleEmailMessage();
                if ( owea.size() > 0 ) { 
                            mailSec.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                mailSec.setTargetObjectId(insCon.OwnerId);
                mailsec.setSubject('Enhancement Request Closed – Released');
                mailsec.setUseSignature(false);
                mailSec.sethtmlbody('Hello,</br></br>'+
                        + insCon.Name +' '+'has been moved to Closed-Released status. Please reach out to the customer to share this update. </br></br>' +
                        'Enhancement Request Link: https://cvent.my.salesforce.com/'+ insCon.Id + '</br></br>' +
                        'Note: This message has been sent to both the Enhancement Request Owner & the Account Team Member for the relevant Product line. Please coordinate for who is best to reach out. </br></br>' +
                        'Regards,</br>'+ 
                        'SF Notifications');
                /*mailSec.setTemplateId('00Xq0000000Hs5K');*/        
                mailSec.setsaveAsActivity(false);
                mails.add(mailSec);
            }
            List<AccountTeamMember> lstAccMem = new List<AccountTeamMember>();
            List<Id> accids = new List<Id>();
            for(Contact c : [Select AccountId from Contact where id =: conIDs]){
                accids.add(c.AccountID);
            }
            if(accids.size()>0)
            lstAccMem = [Select UserId,AccountId,TeamMemberRole from AccountTeamMember where AccountID =: accids];
            //lstAccMem = [Select UserId,AccountId,TeamMemberRole from AccountTeamMember where AccountID =: [Select AccountID from Contact where Id =: conIDs].AccountID];
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'noreply_cc@cvent.com'];


            for(AccountTeamMember instofAccMem : lstAccMem){
                if(mapAccIdProd.containsKey(instofAccMem.AccountId)){
                    system.debug('Value :'+mapAccIdProd.get(instofAccMem.AccountId));
                    system.debug('Role :'+mapAccIdProd.get(instofAccMem.AccountId).contains(instofAccMem.TeamMemberRole.trim()));
                    if(mapAccIdProd.get(instofAccMem.AccountId).contains(instofAccMem.TeamMemberRole.trim())){
                        
                        for(String strName : mapAccIdNameEnh.get(instofAccMem.AccountId)){
                            Messaging.SingleEmailMessage mailSec = new Messaging.SingleEmailMessage();
                            if ( owea.size() > 0 ) { 
                                mailSec.setOrgWideEmailAddressId(owea.get(0).Id);
                            }
                            mailSec.setTargetObjectId(instofAccMem.UserId);
                            // mailSec.setSenderDisplayName('CVENT Notifications');*/
                            mailSec.setSubject('Enhancement Request Closed – Released');
                            mailSec.setUseSignature(false);
                            mailSec.sethtmlbody('Hello,</br></br>'+
                                    strName+' '+'has been moved to Closed-Released status. Please reach out to the customer to share this update. </br></br>' +
                                    'Account Link : https://cvent.my.salesforce.com/'+ instofAccMem.AccountId + '</br></br>' +
                                    'Note: This message has been sent to both the Enhancement Request Owner & the Account Team Member for the relevant Product line. Please coordinate for who is best to reach out. </br></br>' +
                                    'Regards,</br>'+ 
                                    'SF Notifications');
                            /* mailSec.setTemplateId('00Xq0000000Hs5K'); */     
                            mailSec.setsaveAsActivity(false);
                            mails.add(mailSec);         
                        } 
                    }     
                }
            }
            system.debug('lstAccMem : '+lstAccMem);
            system.debug('mails : '+mails);
            if(mails.size()>0)
                Messaging.sendEmail(new List<Messaging.SingleEmailMessage>(mails));
        }
        public void OnBeforeDelete(List<Backlog_Item__c> oldValues,Map<Id,Backlog_Item__c> oldMapValues){    
        }
        public void OnAfterDelete(List<Backlog_Item__c> oldValues,Map<Id,Backlog_Item__c> oldMapValues){
        }
        public void OnUndelete(List<Backlog_Item__c> newValues){
        }
    }