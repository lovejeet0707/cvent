trigger updateSurveyDateOnEBSB on EB_SB_Builder__c (after update,after insert) 
{
    if(Trigger.isAfter && Trigger.isUpdate)
    {
        Map<Id,EB_SB_Builder__c> ebsbMap = new Map<Id,EB_SB_Builder__c>();
        List<Contact> contactList = new List<Contact>();
        List<Contact> updateContacts = new List<Contact>();
        
        /*Map<Id,Mobile_Card__c> testCase = new Map<Id,Mobile_Card__c>();
Map<Id,User> emailCase = new Map<Id,User>();
Id profileId=userinfo.getProfileId();
String profileName = [Select Id,Name from Profile where Id=:profileId].Name;
Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Case.getRecordTypeInfosById();*/
        
        
        for(EB_SB_Builder__c cs : Trigger.new){
            if(cs.Contact__c!=null && cs.Survey_Invitation_Sent__c!=null && (cs.Survey_Invitation_Sent__c!=System.Trigger.oldMap.get(cs.id).Survey_Invitation_Sent__c)){
                ebsbMap.put(cs.Contact__c,cs);
            }
        }
        if(ebsbMap.size()>0){
            contactList = [Select /*Profile_Name__c,*/Last_Experiential_Survey_Invitation__c from Contact where id in : ebsbMap.keySet()];//UD:Commented Profile_Name__c for FP:4thApril
        }     
        for(Contact c : contactList){
            c.Last_Experiential_Survey_Invitation__c = ebsbMap.get(c.id).Survey_Invitation_Sent__c;
            updateContacts.add(c);
        }
        
        if(updateContacts.size()>0)
            update updateContacts;
        
        //Added by Mohsin on 07th Dec 2018
        List<EB_SB_Builder__c> newebsb = new List<EB_SB_Builder__c>();
        for(EB_SB_Builder__c ebsb : Trigger.new)
        {
            if(ebsb.Oversold__c == true && ebsb.Oversold__c!=Trigger.oldMap.get(ebsb.id).Oversold__c)
                newebsb.add(ebsb);
        }
        
        if(CheckRecursive.runThirtySix() && newebsb.size() > 0 && !newebsb.isEmpty())
        {
            ChatterPostNotification.chatterPost(newebsb,'EB SB Project','Oversold__c','AccountCustom__c',false,'EB SB Project');
        } 
    }
    
    if(Trigger.isAfter && Trigger.isInsert)
    {
        if(CheckRecursive.runFortyOne())
        {
            ChatterPostNotification.chatterPost(Trigger.new,'EB SB Project','Oversold__c','AccountCustom__c',false,'EB SB Project');
        } 
    }
}