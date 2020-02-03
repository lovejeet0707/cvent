@isTest/*(seeAllData=true)*/
private class TestEBSBTrigger
{
    static testMethod void testpreventEBProjdelete(){
        
        Profile p = [select id from profile where name='Standard User'];
        User u = new User(alias = 'standt', email='standarduser@testorg.com',
                          emailencodingkey='UTF-8', lastname='Testing', 
                          languagelocalekey='en_US',localesidkey='en_US',
                          profileid = p.Id,timezonesidkey='America/Los_Angeles',
                          username='teststandarduser66464@testorg.com', Department ='IT', ManagerId =UserInfo.getUserId());
        
        System.runAs(u){
            EB_SB_Builder__c eb = new EB_SB_Builder__c();
            
            eb.Project__c='Event Builder';
            eb.Project_Status__c='Completed';
            eb.Project_Type_del__c='Demo Event';
            eb.Project_Complexity__c = '1-Simple';
            eb.Event_Code__c = '1111';
            eb.Integration__c ='Crowd Compass';
            insert eb;
            try{
                {
                    delete eb;
                }
            }catch(Exception ex){
                Boolean Message = false;          
                if(ex.getMessage().contains('You are not authorised to delete this Project ID')){
                    Message = true;      
                }else{
                    Message = false;      
                }
                system.debug('########Message : '+ Message);
                
                System.AssertEquals(Message, false);
            }
        }
    }
    static testMethod void UpdateProjectRiskCategoryClassTest(){
        List<Account> accRecList = new List<Account>();
        
        Account accRec = new Account();
        accRec.Name = 'Test Account';
        accRec.Active_ARA__c = TRUE;
        accRec.Service_Tier__c = 'Bronze';
        accRecList.add(accRec);
        
        accRec = new Account();
        accRec.Name = 'Test Account';
        accRec.Active_ARA__c = TRUE;
        accRec.Service_Tier__c = 'Gold';
        accRecList.add(accRec);
        
        insert accRecList;
        
        List<ARA__c> araObjList = new List<ARA__c>();
        
        ARA__c araObj = new ARA__c();
        araObj.Account__c =accRecList[0].Id;
        araObj.Status__c = 'Open';
        araObj.Severity_Level__c = 'Moderate';
        araObjList.add(araObj);
        
        araObj = new ARA__c();
        araObj.Account__c =accRecList[1].Id;
        araObj.Status__c = 'Open';
        araObj.Severity_Level__c = 'Moderate';
        araObjList.add(araObj);
        
        insert araObjList;
        
        List<EB_SB_Builder__c> ebList = new List<EB_SB_Builder__c>();
        
        EB_SB_Builder__c eb = new EB_SB_Builder__c();
        eb.Project__c='Event Builder';
        eb.Project_Status__c='Completed';
        eb.Project_Type_del__c='Demo Event';
        eb.Project_Complexity__c = '1-Simple';
        eb.Event_Code__c = '1111';
        eb.Integration__c ='Crowd Compass';
        eb.AccountCustom__c = accRecList[0].Id;
        eb.External_Escalation__c = TRUE;
        eb.Project_Health__c='Red';
        ebList.add(eb);
        
        eb = new EB_SB_Builder__c();
        eb.Project__c='Event Builder';
        eb.Project_Status__c='Completed';
        eb.Project_Type_del__c='Demo Event';
        eb.Project_Complexity__c = '1-Simple';
        eb.Event_Code__c = '1111';
        eb.Integration__c ='Crowd Compass';
        eb.AccountCustom__c = accRecList[1].Id;
        eb.External_Escalation__c = TRUE;
        eb.Project_Health__c='Red';
        ebList.add(eb);
        
        insert ebList;
    }
    
    
}