public class CRMProjectCreateController {

    public CRM_Project__c proj{get;set;}
    public CRM_Project_Item__c item{get;set;}
    public attachment att {get;set;}
    
    public list<CRM_Project_Item__c> itemList{get;set;}
    public list<ItemWrapper> itemWrapperList{get;set;}
    public Integer counter{get;set;}
    private Id queuItemId;
    CRM_Project_Queue_Item__c queueItemRec;
    
    public CRMProjectCreateController(ApexPages.StandardController controller) {
        proj=new CRM_Project__c();
            
        //If project is created from 360 view
        proj.CRM_Release__c= ApexPages.currentPage().getParameters().get('releaseId');
        queuItemId=ApexPages.currentPage().getParameters().get('QueueId');
        
        if(queuItemId!=null){
            queueItemRec = [Select Id,Name,Category__c,Description__c,Related_Case__r.CaseNumber,Requestor__c,Status__c From CRM_Project_Queue_Item__c Where Id =:ApexPages.currentPage().getParameters().get('QueueId')];
            proj.Project_Name__c = queueItemRec.Name;
            proj.Reporting_Process_Improvement_Automation__c = queueItemRec.Category__c;
            proj.Description__c = queueItemRec.Description__c;
            proj.Case__c = queueItemRec.Related_Case__r.CaseNumber;
            proj.Queue__c = queueItemRec.Id;
        }
        
        
        counter = 0;
        itemList = new list<CRM_Project_Item__c>(); 
        itemWrapperList = new list<ItemWrapper>();
        
      
        
        ItemWrapper itemWrap = new ItemWrapper(new CRM_Project_Item__c()); 
        counter++;
        itemWrap.counterWrap = counter;
        itemWrapperList.add(itemWrap);
        
        
      
    }
    
   
    public PageReference addRow(){
       
        ItemWrapper itemWrap = new ItemWrapper(new CRM_Project_Item__c()); 
        
        counter++;
        itemWrap.counterWrap = counter; 
        itemWrapperList.add(itemWrap); 
        return null;    
    }
    
    public PageReference removingRow(){
    
        Integer param = Integer.valueOf(Apexpages.currentpage().getParameters().get('index'));
        
        for(Integer i=0;i<itemWrapperList.size();i++){
            if(itemWrapperList[i].counterWrap == param ){
                itemWrapperList.remove(i);     
            }
        }
        
        
        counter--;
        return null;    
    }
    public pageReference Cancel(){
        pageReference pg;
        if(queuItemId!=null){
            pg = new pageReference('/'+queuItemId);
        }else{
            pg = new pageReference('/apex/CRM360View');
        }
        
        pg.setRedirect(true);
        return pg;
        
    }
     
    public pageReference Save(){
       
        //Create Project
        insert proj;
        
        
        //Create Workitems
        list<CRM_Project_Item__c> updateItemList = new list<CRM_Project_Item__c>();
        
        if(!itemWrapperList.isEmpty()){
            for(ItemWrapper itemWrap : itemWrapperList){
            
                CRM_Project_Item__c itemVar = itemWrap.item;
                itemVar.CRM_Project__c = proj.Id;
                updateItemList.add(itemVar);
            }
        }
        
        if(!updateItemList.isEmpty()){
            upsert updateItemList;
        }
        
        if(queueItemRec!=null){
           queueItemRec.Status__c = 'Moved into Project';
           
           update queueItemRec;
        }
        
        return new pageReference('/'+proj.Id);
    }

    public class ItemWrapper{
    
        public CRM_Project_Item__c item{get;set;}
        public Integer counterWrap{get;set;}
        
        public ItemWrapper(CRM_Project_Item__c item){
            this.item= item;  
             
        }
    }

}