@isTest
public class testUpdateCSATrigger{
    private static testMethod void testUpdateCsat(){
    
    
        PSA_Custom_Trigger_Settings__c cts = new PSA_Custom_Trigger_Settings__c(Name = 'Default');
        insert cts;
        
        PSA_Chatter_Settings__c cs = new PSA_Chatter_Settings__c(Name = 'Default', Pending_Completion_Message__c = 'Test Message');
        insert cs;      
    
        Case c = new Case(Status='Open',subject='Test');
        insert c;
        
        
        Survey_Q__c s = new Survey_Q__c(Name = 'test',Case__c = c.id);
        insert s;
    }
    
    private static testMethod void testUpdateMobileAppSurvey(){
    
    
        PSA_Custom_Trigger_Settings__c cts = new PSA_Custom_Trigger_Settings__c(Name = 'Default');
        insert cts;
        
        PSA_Chatter_Settings__c cs = new PSA_Chatter_Settings__c(Name = 'Default', Pending_Completion_Message__c = 'Test Message');
        insert cs;      
    
        Mobile_Card__c mc = new Mobile_Card__c();
        mc.Name = 'Test 1';
        mc.App_Name__c = 'Test App'; 
        insert mc;
        
        
        Survey_Q__c s = new Survey_Q__c(Name = 'test 2',MobileApp__c = mc.id);
        insert s;
    }
    
     private static testMethod void testUpdateOnBoardingSurvey(){
    
    
        PSA_Custom_Trigger_Settings__c cts = new PSA_Custom_Trigger_Settings__c(Name = 'Default');
        insert cts;
        
        PSA_Chatter_Settings__c cs = new PSA_Chatter_Settings__c(Name = 'Default', Pending_Completion_Message__c = 'Test Message');
        insert cs;      
    
        Onboarding__c ob = new Onboarding__c();
         insert ob;
        
        
        Survey_Q__c s = new Survey_Q__c(Name = 'test 2',Onboarding__c = ob.id);
        insert s;
    }
    
     private static testMethod void testUpdateEBSBSurvey(){
    
    
        PSA_Custom_Trigger_Settings__c cts = new PSA_Custom_Trigger_Settings__c(Name = 'Default');
        insert cts;
        
        PSA_Chatter_Settings__c cs = new PSA_Chatter_Settings__c(Name = 'Default', Pending_Completion_Message__c = 'Test Message');
        insert cs;      
    
        EB_SB_Builder__c ebsb = new EB_SB_Builder__c();
         ebsb.Integration__c = 'Marketo';
        insert ebsb;
        
        
        Survey_Q__c s = new Survey_Q__c(Name = 'test 2',EBSB__c = ebsb.id);
        insert s;
    }
    
        
}