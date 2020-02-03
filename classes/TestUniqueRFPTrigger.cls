/*==========================================================================================================
//Created by Rishi Ojha 
//Unit testing for the Trigger : UpdateChildRFPs
============================================================================================================*/

@isTest(SeeAllData=True)
    
    Private class TestUniqueRFPTrigger
    
  {
    Static testmethod void testUpdateChildRFPs(){
            
            Recordtype  R1 = [select id,name from recordtype where SobjectType = 'Account' and name ='Biz A/c' ];
            
            Account Acc = new Account(Name='TestAcc',recordtypeid = R1.id);
            insert Acc;
            
            contact con = new Contact(LastName='testCon', Accountid = Acc.id);
            insert con; 
            
            Unique_RFPs__c urfp = New Unique_RFPs__c(Name='testerfp',RFP_Code__c='testcode', Contact__c=con.id);
            insert urfp;
    
            RFP__c rfp = New RFP__c(Name='testrfp', RFP_Code__c='1234256',Status__c='Awaiting Proposal', 
                                    Unique_Code__c='45461',Supplier_Account__c=Acc.id,Unique_RFP_ID__c=urfp.id);
            insert rfp;
            
            update New RFP__c(Name='testrfp222', id=rfp.id);
   
    if(urfp.Escalated_RFP__c = True)
   // For (RFP.Status__c = 'Awaiting Proposal')
    
    rfp.Escalated_RFP__c = True;
  //  rfp2.Escalated_RFP__c = True;
    //rfp3.Escalated_RFP__c = True;
   
  //  update urfp;
    
     
    List<Unique_RFPs__c> inserturfps = [SELECT Name,ID,Status__c,Escalated_RFP__c,(Select id,Name,Status__c,Escalated_RFP__c from RFPs__r) FROM Unique_RFPs__c where ID = : urfp.Id ];
    
   
    }
  }