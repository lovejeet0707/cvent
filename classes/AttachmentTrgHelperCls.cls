/**
//////////////////////////////////////
//    @author Abhishek Pandey    //
/////////////////////////////////////
Version :  1.0
Date : 23rd July 2014
Version :  1.0
Date : 9th June 2014
Description: To update contract status
 */
public class AttachmentTrgHelperCls {
  public void OnBeforeInsert(List<Attachment> newValues){
    system.debug('DEBUG');
  }
  public void OnAfterInsert(Map<Id,Attachment> newMapValues){
        caseLastModifiedDateUpdate(newMapValues);//Method Call to update LastModifiedDate of Case
      //To update contract status
      map<Id,Id> mapIdContr = new map<Id,Id>();
      //To update contract status
    system.debug('Test');
    User instUser =  [SELECT Profile.Name FROM User WHERE Id =: Userinfo.getUserId() LIMIT 1];
    system.debug('instUser.Profile.Name++'+instUser.Profile.Name);
    if(instUser.Profile.Name=='Cvent Customer Community User'){
      map<Id,Attachment> mapCseIdAttach = new map<Id,Attachment>();
      String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm(); 
      for(Attachment instOfAttach : newMapValues.Values()){
        String strInst = String.valueOf(instOfAttach.ParentId);
        if(strInst.startsWith('500')){
          mapCseIdAttach.put(instOfAttach.ParentId,instOfAttach);
        }
        
      }
      
      
      List<Case> lstCase = [SELECT ID,Owner.Name,CaseNumber,Status,OwnerId FROM Case WHERE Id=: mapCseIdAttach.keySet()];
              
      List<Case> lstCaseSec = new List<Case>();    
      for(Case instCase : lstCase){
        instCase.Status  = 'Additional Information Received'; 
        lstCaseSec.add(instCase);                         
        /*instOfEmail.setHtmlBody('Dear '+instCase.Owner.Name+'<br><br>'+
                    'The Customer has posted an attachment to the following case:'+'<br><br>'+
                    'Updated Status: '+instCase.Status+'<br>'+
                    'Case Id: '+'<a href="'+sfdcBaseURL+'/'+instCase.Id+'">'+instCase.CaseNumber+'</a>'+'<br>'+
                    'Attachment Link: '+'<a href="'+sfdcBaseURL+'/servlet/servlet.FileDownload?file='+mapCseIdAttach.get(instCase.Id).Id+'">'+'Click Here'+'</a>'+'<br><br>'+
                    'As a matter of standard protocol the case owner has been removed and this case has been escalated to the top of the queue. Please check on this case and'+ 
                    'either re-assign the case to yourself and continue working on it or verify that another Product Consultant has picked it up.<br><br> '+
                    'Good Work,'
                    );
        instOfEmail.setSaveAsActivity(false);*/     
        //lstOfEmail.add(instOfEmail);       
      }      
      //Messaging.sendEmail(lstOfEmail);
      update lstCaseSec;  
    }
    //To update contract status
    for(Attachment instOfAttach : newMapValues.Values()){
        String strInst = String.valueOf(instOfAttach.ParentId);
        if(strInst.startsWith('800')){
            mapIdContr.put(instOfAttach.ParentId,instOfAttach.ParentId);
        }
        //To update Case LastModified Date
        /*else if(strInst.startsWith('500')){
            Case caseObj= new Case(instOfAttach.ParentId);
            lstCaseSec.add(caseObj);
            update lstCaseSec;
        }*/
        
    }
    
    List<Contract> lstContract = new List<Contract>();
      if(mapIdContr.Keyset().size()>0){
          lstContract = [SELECT Id FROM Contract WHERE Id =: mapIdContr.Keyset()  AND Status = 'Waiting for Documents'];
      }
    List<Contract> lstContractSec = new List<Contract>();
      for(Contract instCont : lstContract){if(mapIdContr.containsKey(instCont.Id)){instCont.Status = 'Received';instCont.Validation_Check__c = true;lstContractSec.add(instCont);}}
      if(lstContractSec.size()>0){update lstContractSec;}
    //To update contract status
    /*RecordType instRecType = [SELECT Name, IsActive, DeveloperName, SobjectType FROM RecordType WHERE SobjectType='Event' And IsActive = true And DeveloperName = 'SMM_BD_Presentations' ];
      String idString;    
    List<Attachment> lstAttachment = new List<Attachment>();
    List<Id> lstEventId =  new LIst<Id>();
    map<Id,Id> mapEventIdAttachmentId =  new map<Id,Id>();
    
    for(Attachment instAttachment : newMapValues.values()){      
      idString = String.valueOf(instAttachment.ParentId);
      system.debug('idString++'+idString);
      system.debug('idString++'+idString.startsWith('00U'));
      if(idString.startsWith('00U')){
        lstAttachment.add(instAttachment);
        lstEventId.add(instAttachment.ParentId);
        mapEventIdAttachmentId.put(instAttachment.ParentId,instAttachment.id);
      }
    }
    system.debug('mapEventIdAttachmentId++'+mapEventIdAttachmentId);
    system.debug('lstEventId++'+lstEventId);
    List<Event> lstEvents =  [SELECT Id,Attachment__c,Attachment_Link__c FROM Event WHERE Id =: lstEventId And RecordTypeId =: instRecType.id];
    system.debug('lstEvents++'+lstEvents);
    List<Event> lstEventsSec = new List<Event>();
    for(Event instEvent : lstEvents){
      instEvent.Attachment_Link__c = '/servlet/servlet.FileDownload?file='+mapEventIdAttachmentId.get(instEvent.id);
      instEvent.Attachment__c = true;
      lstEventsSec.add(instEvent);
    }
    update lstEventsSec;*/
    
  }
  public void OnBeforeUpdate(Map<Id,Attachment> oldMapValues,Map<Id,Attachment> newMapValues){   
    
  }
  public void OnAfterUpdate(Map<Id,Attachment> oldMapValues,Map<Id,Attachment> newMapValues){
        caseLastModifiedDateUpdate(newMapValues);//Method Call to update LastModifiedDate of Case
  }
  public void OnBeforeDelete(List<Attachment> oldValues,Map<Id,Attachment> oldMapValues){
        
    }
    public void OnAfterDelete(List<Attachment> oldValues,Map<Id,Attachment> oldMapValues){
      caseLastModifiedDateUpdate(oldMapValues);//Method Call to update LastModifiedDate of Case
      Set<Id> setIdAttachments = new Set<Id>();
      RecordType instRecType = [SELECT Name, IsActive, DeveloperName, SobjectType FROM RecordType WHERE SobjectType='Event' And IsActive = true And DeveloperName = 'SMM_BD_Presentations' ];
      String idString;
      
      for(Attachment instOfAttachment : oldValues){
        idString = String.valueOf(instOfAttachment.ParentId);
        if(idString.startsWith('00U')){
        setIdAttachments.add(instOfAttachment.ParentId);
        }        
      }      
      
      List<Event> lstEvent =  [SELECT AccountId, (SELECT Id FROM Attachments) FROM Event WHERE Id =: setIdAttachments And RecordTypeId =: instRecType.id];
      List<Event> lstUpdateableEvent =  new List<Event>(); 
      
    for(Event instEventSec : lstEvent){      
      if(instEventSec.Attachments.Size()==0){
        instEventSec.Attachment_Link__c = '';
        instEventSec.Attachment__c = false;
        instEventSec.DS_Approved__c = 'No';
        lstUpdateableEvent.add(instEventSec);
      }        
    }        
      
      update   lstUpdateableEvent;
    }
    public void OnUndelete(List<Attachment> newValues){
        
    }
    //To update Case LastModified Date
    Private void caseLastModifiedDateUpdate(Map<Id,Attachment> newMapValues)
    {
        List<Case> caseObjUpdate= new List<Case>();// List is used to update Case Object LastModified Date whenever a Attachment is inserted
        for(Attachment instOfAttach : newMapValues.Values()){
            String strInst = String.valueOf(instOfAttach.ParentId);
            if(strInst.startsWith('500')){
                Case caseObj= new Case(id=instOfAttach.ParentId);
                caseObjUpdate.add(caseObj);
                
            }
        }
        update caseObjUpdate;
        
    }
    
}