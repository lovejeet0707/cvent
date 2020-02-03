/*==========================================================================================================
    //Created by Rishi Ojha 
    //Unit testing for the Trigger : UpdateChildRFP_from_UniqueRFP
    ============================================================================================================*/
    
    @isTest(SeeAllData=True)
    
    Private class TestRFPTrigger{
    
        Static testmethod void testUpdateChildRFP_from_UniqueRFP(){
            
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
            
            
    
       }
       /*
     Static testmethod void testupdateUpdateChildRFP_from_UniqueRFP(){
            
             RFP__c rfp = New RFP__c(Name='testrfp', 
                                     Id= ' a0CP0000002Au2dMAC', RFP_Code__c='1234256',
                                     Status__c='Awaiting Proposal', 
                                     Unique_Code__c='45461',
             Supplier_Account__c='001P000000bCJwJ');
     update rfp;
     }*/
    
    }