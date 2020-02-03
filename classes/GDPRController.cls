/***
*** Author : Shanu Aggarwal
*** Dated on: 05/09/2018
***/
public without sharing class GDPRController{


    public Case c {get;set;}
    public boolean agree {get;set;}
    
    public string privacyType {get;set;}
    public string fName {get;set;}
    public string lName {get;set;}
    public string showDescription{get;set;}
    
    User u;
    
    public Map<String,ProductBoxWrapper> selectedProdMap {get;set;}
    
    private Map<String,GDPRProductSetting__c> prodSettingMap;
    
    public GDPRController(){
        
        selectedProdMap = new Map<String,ProductBoxWrapper>();
        
        
        u = [Select ContactId,Contact.Email,Contact.Name From User Where Id=:UserInfo.getUserId()];
       
        c= new Case();
        //Load prepopulated values
        c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('GDPR Request').getRecordTypeId();
        c.Submitter_Email__c=u.Contact.Email;
        c.Submitter_Name__c=u.Contact.Name;
        
        //load setting values
        prodSettingMap = GDPRProductSetting__c.getAll();
        
     }
     
    
    public void GetProducts(){
            
            Set<String> updatedSelection= new Set<String>();
            
            if(c.Products_Affected_Dev__c!=null){
                
                for(string prod : c.Products_Affected_Dev__c.split(';')){
                
                    //get the actual prod value defined in picklist
                    if( prodSettingMap.containsKey(prod) && !selectedProdMap.containsKey(prod)){
                        selectedProdMap.put(prod,new ProductBoxWrapper(prod + ' ' + prodSettingMap.get(prod).GDPR_Form_Field_Label__c,'',true));
                    }
                    updatedSelection.add(prod);
                }
                
                //Remove boxes if producted is removed from picklist
                for(string existingProd : selectedProdMap.keySet()){
                    
                    if(!updatedSelection.contains(existingProd)){
                        selectedProdMap.remove(existingProd);
                    }
                } 
                
            }
    }  
    
    public PageReference submitRequest(){
    
        try{
            
            //All fields are mandotory
            if(c.Submitter_Name__c==null || c.Submitter_Email__c==null || fName==null || lName==null || c.Requester_s_Email__c==null || c.GDPR_Type__c==null 
            || c.GDPR_Submitted_Date__c==null || c.Products_Affected_Dev__c==null ||  showDescription==null || (showDescription=='Yes' && c.Description==null) || agree==null || c.Data_Subject__c == NULL){
                
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please fill all the details.');
                ApexPages.addMessage(myMsg);
                return null;
                
            }

            //All product box should not be blank
            for(ProductBoxWrapper pwrap : selectedProdMap.values()){
                if(pwrap.value==null || pwrap.value==''){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, pwrap.label + ' is required.' );
                    ApexPages.addMessage(myMsg);
                    return null;
                }
            
            }
            
            if(agree==true){
                
                List<String> productAffectedList = new List<String>();
                
                //Set few fields
                c.Subject = 'GDPR Request';
                c.Requestors_Name__c = lName + ', ' + fName;
                c.ContactId = u.ContactId;
                c.Type = privacyType;
                
                //Get actual values from custom setting on product multi picklist 
                for(String product : selectedProdMap.keySet()){
                    productAffectedList.add(prodSettingMap.get(product).Product__c);
                }

                //Set Product Affected multipicklist Field
                if(productAffectedList.size()>0)
                c.Products_Affected__c  = String.join(productAffectedList,';');
                
                //set owner to queue
                Group q = [Select Id From Group Where Name = 'GDPR Request' and Type ='Queue'];
                c.OwnerId = q.Id;
                insert c;
                
                //create comments for selected products
                List<CaseComment> commentList = new List<CaseComment>();
                                
                for(ProductBoxWrapper wrapper: selectedProdMap.values()){
                
                    CaseComment comment1= new CaseComment(ParentId=c.Id);
                    comment1.CommentBody= wrapper.Label + ' : ' + wrapper.value;
                    commentList.add(comment1);
                
                }
                                
                if(commentList.size()>0)
                    insert commentList;
                
                
                /*
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM,'Request is submitted.');
                    ApexPages.addMessage(myMsg);
                    return null;
                */
                if(Boolean.ValueOf(Label.GDPRTaskSubProcessor)){
                 /****** Enhancements : Udita - to create task for each product selected ******/
                map<string,list<GDPRTaskSubProcessor__c>> gdprTaskMap= new map<string,list<GDPRTaskSubProcessor__c>>();               
                for(GDPRTaskSubProcessor__c objTask : [select Assigned_To__c,Product__c,Subject__c from GDPRTaskSubProcessor__c]){
                 system.debug('----****'+objTask.Product__c);
                 system.debug('----****gdprTaskMap'+gdprTaskMap);
                 if(!gdprTaskMap.containsKey(objTask.Product__c)){
                   gdprTaskMap.put(objTask.Product__c,new list<GDPRTaskSubProcessor__c>());
                 }
                   gdprTaskMap.get(objTask.Product__c).add(objTask);
                }
                system.debug('----gdprTask'+gdprTaskMap);
                list<string> productsSelectedList = new list<string>();
                productsSelectedList = c.Products_Affected_Dev__c.split(';');
                system.debug('----productsSelectedList'+productsSelectedList);
                List<Task> TaskList= new List<Task>();
                map<string,task> taskSubjectMap = new map<string,task>();// not to repeat the task having same subject lines 
                for(string prod : productsSelectedList){
                  system.debug('----gdprTaskMap.containskey(prod)'+gdprTaskMap.containskey(prod));
                  if(gdprTaskMap.containskey(prod)){
                    system.debug('----gdprTaskMap.get(prod)'+gdprTaskMap.get(prod));
                    for(GDPRTaskSubProcessor__c gdprSubProcess : gdprTaskMap.get(prod)){
                      if(!taskSubjectMap.containsKey(gdprSubProcess.Subject__c)){
                          Task tObj = new Task();
                          tObj.Status = 'Not Started';
                          tObj.Description= gdprSubProcess.Subject__c;
                          tObj.OwnerId = gdprSubProcess.Assigned_To__c;
                          tObj.WhatId = c.id;
                          tObj.Subject = gdprSubProcess.Subject__c;
                          tObj.Priority = 'High'; 
                          tObj.ActivityDate = system.today();
                          TaskList.add(tObj);
                          taskSubjectMap.put(gdprSubProcess.Subject__c,tObj);
                      }
                    }  
                  }             
                }
                system.debug('----taskList'+TaskList);
                if(TaskList.size() > 0){
                 insert TaskList;
                } 
                }
                /**** Udita - code ends****/
                
                //Redirect to thank you page
                //return new PageReference('http://www.cvent.com/uk/gdpr/cvents-affiliates-and-subprocessors-reject-thank-you.shtml');
                return new PageReference(Label.GDPRSubmitThankYou);
                
            }else{
            
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Please confirm the checkbox');
                ApexPages.addMessage(myMsg);
                return null;
            
            }
        
        
        }catch(Exception e){
        
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
            ApexPages.addMessage(myMsg);
            return null;
        }
      
       
       
    }
   
   
    public class ProductBoxWrapper{
    
        public string  label{get;set;}
        public string  value{get;set;}
        public boolean isRendered{get;set;}
        
        
        public ProductBoxWrapper(string  label,string  value,boolean isRendered){
        
            this.label=label;
            this.value=value;
            this.isRendered=isRendered;
            
        }
    }
        
}