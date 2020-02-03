/*
File :WriteOffTrgHelperClsTest
Desc: Test class for WriteOffTrgHelperCls
Date: 4 June 2018
Author :kumud thakur
Version 1.0

*/
@istest
public class WriteOffTrgHelperClsTest{
    
    
    static{
        
        List<HybridPicklistValue__c>  listHybrid=new List<HybridPicklistValue__c>();
        HybridPicklistValue__c instOfHydPLV = new HybridPicklistValue__c();
        instOfHydPLV.HybridValue__c = 'Custom Work SLM';
        instOfHydPLV.Name = '1000';
        listHybrid.add(instOfHydPLV);
        
        
        instOfHydPLV = new HybridPicklistValue__c();
        instOfHydPLV.HybridValue__c = 'Diamond Plus';
        instOfHydPLV.Name = '2000';
        listHybrid.add(instOfHydPLV);
       
        
        instOfHydPLV = new HybridPicklistValue__c();
        instOfHydPLV.HybridValue__c = ' Diamond Plus SLM';
        instOfHydPLV.Name = '3000';
        listHybrid.add(instOfHydPLV);
        insert listHybrid;
        
        List<Cancellation_Categorization__c> listCancel=new List<Cancellation_Categorization__c>();
        
        Cancellation_Categorization__c instOfCanCat = new Cancellation_Categorization__c();
        instOfCanCat.Type__c = 'Type 1';
        instOfCanCat.Name = 'Bad Debts';
        listCancel.add(instOfCanCat);
        //insert instOfCanCat;
        
        instOfCanCat = new Cancellation_Categorization__c();
        instOfCanCat.Type__c = 'Type 2';
        instOfCanCat.Name = 'Billing Errors';
        listCancel.add(instOfCanCat);
        
        instOfCanCat = new Cancellation_Categorization__c();
        instOfCanCat.Type__c = 'Type 3';
        instOfCanCat.Name = 'Withhold Tax Cancellations';
        listCancel.add(instOfCanCat);
        
        instOfCanCat = new Cancellation_Categorization__c();
        instOfCanCat.Type__c = 'Type 1';
        instOfCanCat.Name = 'Dissatisfactions';
        listCancel.add(instOfCanCat);
        
        instOfCanCat = new Cancellation_Categorization__c();
        instOfCanCat.Type__c = 'Type 1';
        instOfCanCat.Name = 'Flagged For Revenues';
        listCancel.add(instOfCanCat);
        insert listCancel;
        
        List<Cancellation_Assignments__c> listOFCS=new List<Cancellation_Assignments__c>();
        Cancellation_Assignments__c instOfCanAss = new Cancellation_Assignments__c();
        instOfCanAss.Username__c = 'Abhishek Pandey';
        instOfCanAss.Product__c = 'Event';
        instOfCanAss.UserId__c = UserInfo.getUserId();
        instOfCanAss.Review_Level__c = 'AccLevel1';
        instOfCanAss.Name = '1000';
        listOFCS.add(instOfCanAss);
        
        instOfCanAss = new Cancellation_Assignments__c();
        instOfCanAss.Username__c = 'Abhishek Pandey';
        instOfCanAss.Product__c = 'Event';
        instOfCanAss.UserId__c = UserInfo.getUserId();
        instOfCanAss.Review_Level__c = 'AccLevel2';
        instOfCanAss.Name = '2000';
        listOFCS.add(instOfCanAss);
        
        instOfCanAss = new Cancellation_Assignments__c();
        instOfCanAss.Username__c = 'Abhishek Pandey';
        instOfCanAss.Product__c = 'Event';
        instOfCanAss.UserId__c = UserInfo.getUserId();
        instOfCanAss.Review_Level__c = 'Hybrid';
        instOfCanAss.Name = '3000';
        listOFCS.add(instOfCanAss);
        
        instOfCanAss = new Cancellation_Assignments__c();
        instOfCanAss.Username__c = 'Abhishek Pandey';
        instOfCanAss.UserId__c = UserInfo.getUserId();
        instOfCanAss.Review_Level__c = 'Tax';
        instOfCanAss.Name = '4000';
        listOFCS.add(instOfCanAss);
        
        instOfCanAss = new Cancellation_Assignments__c();
        instOfCanAss.Username__c = 'Abhishek Pandey';
        instOfCanAss.Type_Of_Cancellation__c = 'Implementation Error';
        instOfCanAss.UserId__c = UserInfo.getUserId();
        instOfCanAss.Review_Level__c = 'Review Team';
        instOfCanAss.Name = '5000';
        listOFCS.add(instOfCanAss);
        
        insert listOFCS;
        
        //added by kumud on 30/05/18
        UserAssignment__c instUA = new UserAssignment__c();
        instUA.Name = 'Integrated_Events';
        instUA.User_id__c = userinfo.getUserID();
        instUA.UserName__c = 'Brett Wischow';
        insert instUA;
        
        
    }
    static Account instofAcc;
    public static void createMasterData(){
        
        instofAcc=TestUtil.createAccount('Test Account','Biz_Ac');
        instOfAcc.BillingCountryCode = 'US';
        instOfAcc.BillingStateCode = 'NY';
        insert instofAcc;
        
        Contact con=TestUtil.createContact(instofAcc.id);
        insert con;
        
        BillingCase__c instOfBilC = new BillingCase__c();
        instOfBilC.CustomersAccount__c = instofAcc.id;
        instOfBilC.CVII_Number__c = '32323';
        instOfBilC.Name = 'Test';
        insert instOfBilC;
        
        List<Product2> listOFProduct =TestUtil.createProducts(new List<String>{'Diamond Plus'});
        insert listOFProduct;
        PricebookEntry instPBE= TestUtil.createPricebookEntry(listOFProduct[0],100);
        
        insert instPBE;
        
        Opportunity instOpp=TestUtil.createOpportunity('Test Opp','Event','Qualified');
        instOpp.Pricebook2Id = Test.getStandardPricebookId();
        instOpp.CurrencyIsoCode = 'USD';
        instOpp.Send_This_To_Tract__c = true;
        insert instOpp;
        
        OpportunityLineItem  instOfFSetForYearDGSecond = new OpportunityLineItem ();
        //instofFeatSet.Feature__c = 'Data Entry';
        instOfFSetForYearDGSecond.OpportunityID = instOpp.Id;
        instOfFSetForYearDGSecond.PriceBookEntryID=instPBE.Id;
        instOfFSetForYearDGSecond.Product__c = 'Lead Capture';
        instOfFSetForYearDGSecond.quantity=4;
        instOfFSetForYearDGSecond.totalprice=200;
        insert instOfFSetForYearDGSecond;
        //insert instOLItem;
        
        /*instOfOppFIF.StageName = 'Closed Won';
        instOfOppFIF.Contract_Implemented__c = true;
        update instOfOppFIF;*/
        
    }
    
    public static testMethod void  myUnitTest_1(){
        
        createMasterData();
        User instUsr = TestUtil.CreateDeploymentUser();
        insert instUsr;
        
        Cancellations_Super_Users__c cc= new Cancellations_Super_Users__c();        
        cc.Name =instUsr.id;      
        cc.Username__c ='deploymentuser@cvent.com.testclass';
        insert cc;
        
        BillingCase__c instBillCase=[select id from BillingCase__c limit 1];
        Opportunity instOfOpp=[Select id,stagename,CFC_Check__c,Set_Cancellation_Status__c from opportunity limit 1];
        instOfOpp.stagename='Closed Won';
        instOfOpp.CFC_Check__c='Tanuj';
        //instOfOpp.Set_Cancellation_Status__c='Edit & Clone';
        update instOfOpp;
        
        Test.StartTest();
        system.RunAs(instUsr){
            List<WriteOff__c> listWROFF=new List<WriteOff__c>();
            List<WriteOff__c> listupdat=new List<WriteOff__c>();
            WriteOff__c instOfWriteOff = new WriteOff__c();
            instOfWriteOff.Type_of_Cancellation__c = 'Dissatisfactions';
            instOfWriteOff.Product__c = 'Event';
            instOfWriteOff.Contract__c = '25512';
            instOfWriteOff.Write_Off_Status__c = 'Initially Approved';
            instOfWriteOff.New_TCV_To_Be_Moved__c ='Yes';
            instOfWriteOff.Customer_Name__c = instBillCase.id;
            instOfWriteOff.Office_Location__c = 'US';
            listWROFF.add(instOfWriteOff);
            
            instOfWriteOff = new WriteOff__c();
            instOfWriteOff.Type_of_Cancellation__c = 'Billing Errors';
            instOfWriteOff.Product__c = 'Event';
            instOfWriteOff.Contract__c = '25512';
            instOfWriteOff.Write_Off_Status__c = 'Initially Approved';
            instOfWriteOff.New_TCV_To_Be_Moved__c ='Yes';
            instOfWriteOff.Customer_Name__c = instBillCase.id;
            instOfWriteOff.Office_Location__c = 'US';
            listWROFF.add(instOfWriteOff);
            
            instOfWriteOff = new WriteOff__c();
            instOfWriteOff.Type_of_Cancellation__c = 'Withhold Tax Cancellations';
            instOfWriteOff.Product__c = 'Event';
            instOfWriteOff.Contract__c = '25512';
            instOfWriteOff.Write_Off_Status__c = 'Initially Approved';
            instOfWriteOff.New_TCV_To_Be_Moved__c ='Yes';
            instOfWriteOff.Customer_Name__c = instBillCase.id;
            instOfWriteOff.Office_Location__c = 'US';
            listWROFF.add(instOfWriteOff);
            
            insert listWROFF;
            
           
            try{
            
                instOfWriteOff.Write_Off_Status__c = 'Submitted for Review';
                instOfWriteOff.New_TCV_To_Be_Moved__c ='No';
            
                update instOfWriteOff;
                instOfWriteOff.New_TCV_To_Be_Moved__c ='Yes';
                update instOfWriteOff;
            }catch(Exception e){
                
                
            }
            
            
            delete instOfWriteOff;
            undelete instOfWriteOff;
            
            
        }
        
        Test.stopTest();
        
    } // end of test method
    
    
    public static testMethod void  myUnitTest_2(){
        
        createMasterData();
        User instUsr = TestUtil.CreateDeploymentUser();
        insert instUsr;
        
        Cancellations_Super_Users__c cc= new Cancellations_Super_Users__c();        
        cc.Name =instUsr.id;      
        cc.Username__c ='deploymentuser@cvent.com.testclass';
        insert cc;
        
        BillingCase__c instBillCase=[select id from BillingCase__c limit 1];
        Opportunity instOfOpp=[Select id,stagename,CFC_Check__c,Set_Cancellation_Status__c from opportunity limit 1];
        instOfOpp.stagename='Closed Won';
        instOfOpp.CFC_Check__c='Tanuj';
        //instOfOpp.Set_Cancellation_Status__c='Edit & Clone';
        update instOfOpp;
        Test.StartTest();
        system.RunAs(instUsr){
            
            
            List<WriteOff__c> listWROFF=new List<WriteOff__c>();
            List<WriteOff__c> listupdat=new List<WriteOff__c>();
            WriteOff__c instOfWriteOff = new WriteOff__c();
            instOfWriteOff.Type_of_Cancellation__c = 'Dissatisfactions';
            instOfWriteOff.Product__c = 'Event';
            instOfWriteOff.Contract__c = '25512';
            instOfWriteOff.Write_Off_Status__c = 'Initially Approved';
            instOfWriteOff.New_TCV_To_Be_Moved__c ='Yes';
            instOfWriteOff.Customer_Name__c = instBillCase.id;
            instOfWriteOff.Office_Location__c = 'US';
            listWROFF.add(instOfWriteOff);
            
            insert listWROFF;
            
           
            try{
            
                instOfWriteOff.Write_Off_Status__c = 'Submitted for Review';
                instOfWriteOff.New_TCV_To_Be_Moved__c ='No';
            
                update instOfWriteOff;
                instOfWriteOff.New_TCV_To_Be_Moved__c ='Yes';
                update instOfWriteOff;
            }catch(Exception e){
                
                
            }
            
            
            
            
            
        }
        
        Test.stopTest();
        
    } // end of test method
    
    public static testMethod void  myUnitTest_3(){
        
        createMasterData();
        User instUsr = TestUtil.CreateDeploymentUser();
        insert instUsr;
        
        Cancellations_Super_Users__c cc= new Cancellations_Super_Users__c();        
        cc.Name =instUsr.id;      
        cc.Username__c ='deploymentuser@cvent.com.testclass';
        insert cc;
        
        BillingCase__c instBillCase=[select id from BillingCase__c limit 1];
        Opportunity instOfOpp=[Select id,stagename,CFC_Check__c,Set_Cancellation_Status__c from opportunity limit 1];
        instOfOpp.stagename='Closed Won';
        instOfOpp.CFC_Check__c='Tanuj';
        //instOfOpp.Set_Cancellation_Status__c='Edit & Clone';
        update instOfOpp;
        
        Test.StartTest();
        system.RunAs(instUsr){
            Opportunity instOpp=TestUtil.createOpportunity('Test Opp','Event','Tract');
            instOpp.accountid=instofAcc.id;
            insert instOpp;
            List<WriteOff__c> listWROFF=new List<WriteOff__c>();
            List<WriteOff__c> listupdat=new List<WriteOff__c>();
            
            WriteOff__c instOfWriteOff = new WriteOff__c();
            instOfWriteOff.Type_of_Cancellation__c = 'Billing Errors';
            instOfWriteOff.Product__c = 'Event';
            instOfWriteOff.Contract__c = '25512';
            instOfWriteOff.Write_Off_Status__c = 'Initially Approved';
            instOfWriteOff.New_TCV_To_Be_Moved__c ='Yes';
            instOfWriteOff.Customer_Name__c = instBillCase.id;
            listWROFF.add(instOfWriteOff);
            instOfWriteOff.Office_Location__c = 'US';
            instOfWriteOff.Net_bookings_Impact_counted_sales__c = 1234567;
            instOfWriteOff.Net_bookings_Impact_Uncounted_sales__c = 1231241;
            insert listWROFF;
            
            instOfWriteOff.Write_Off_Status__c = 'Submitted for Review';
            instOfWriteOff.New_TCV_To_Be_Moved__c ='Yes';
            update instOfWriteOff;
        }
        
        Test.stopTest();
        
    } // end of test method

    public static testMethod void  myUnitTest_4(){
        
        createMasterData();
        User instUsr = TestUtil.CreateDeploymentUser();
        insert instUsr;
        
        Cancellations_Super_Users__c cc= new Cancellations_Super_Users__c();        
        cc.Name =instUsr.id;      
        cc.Username__c ='deploymentuser@cvent.com.testclass';
        insert cc;
        
        BillingCase__c instBillCase=[select id from BillingCase__c limit 1];
        Opportunity instOfOpp=[Select id,stagename,CFC_Check__c,Set_Cancellation_Status__c from opportunity limit 1];
        instOfOpp.stagename='Closed Won';
        instOfOpp.CFC_Check__c='Tanuj';
        //instOfOpp.Set_Cancellation_Status__c='Edit & Clone';
        update instOfOpp;
        
        Test.StartTest();
        system.RunAs(instUsr){
            Opportunity instOpp=TestUtil.createOpportunity('Test Opp','Event','Verbal');
            instOpp.accountid=instofAcc.id;
            insert instOpp;
            List<WriteOff__c> listWROFF=new List<WriteOff__c>();
            List<WriteOff__c> listupdat=new List<WriteOff__c>();
            
            WriteOff__c instOfWriteOff = new WriteOff__c();
            instOfWriteOff.Type_of_Cancellation__c = 'Bad Debts';
            instOfWriteOff.Product__c = 'Event';
            instOfWriteOff.Contract__c = '25512';
            instOfWriteOff.Write_Off_Status__c = 'Initially Approved';
            instOfWriteOff.New_TCV_To_Be_Moved__c ='Yes';
            instOfWriteOff.Customer_Name__c = instBillCase.id;
            listWROFF.add(instOfWriteOff);
            instOfWriteOff.Office_Location__c = 'US';
            instOfWriteOff.Net_bookings_Impact_counted_sales__c = 12414124;
            instOfWriteOff.Net_bookings_Impact_Uncounted_sales__c = 1245541;
            insert listWROFF;
            
            instOfWriteOff.Write_Off_Status__c = 'Submitted for Review';
            instOfWriteOff.New_TCV_To_Be_Moved__c ='Yes';
            update instOfWriteOff;
        }
        
        Test.stopTest();
        
    } // end of test method
    
    public static testMethod void  myUnitTest_5(){
        
        createMasterData();
        User instUsr = TestUtil.CreateDeploymentUser();
        insert instUsr;
        
        Cancellations_Super_Users__c cc= new Cancellations_Super_Users__c();        
        cc.Name =instUsr.id;      
        cc.Username__c ='deploymentuser@cvent.com.testclass';
        insert cc;
        
        BillingCase__c instBillCase=[select id from BillingCase__c limit 1];
        Opportunity instOfOpp=[Select id,stagename,CFC_Check__c,Set_Cancellation_Status__c from opportunity limit 1];
        instOfOpp.stagename='Closed Won';
        instOfOpp.CFC_Check__c='Tanuj';
        //instOfOpp.Set_Cancellation_Status__c='Edit & Clone';
        update instOfOpp;
        
        Test.StartTest();
        system.RunAs(instUsr){
            Opportunity instOpp=TestUtil.createOpportunity('Test Opp','Event','Verbal');
            instOpp.accountid=instofAcc.id;
            insert instOpp;
            List<WriteOff__c> listWROFF=new List<WriteOff__c>();
            List<WriteOff__c> listupdat=new List<WriteOff__c>();
            
            WriteOff__c instOfWriteOff = new WriteOff__c();
            instOfWriteOff.Type_of_Cancellation__c = 'Withhold Tax Cancellations';
            instOfWriteOff.Product__c = 'Event';
            instOfWriteOff.Contract__c = '25512';
            instOfWriteOff.Write_Off_Status__c = 'Initially Approved';
            instOfWriteOff.New_TCV_To_Be_Moved__c ='Yes';
            instOfWriteOff.Customer_Name__c = instBillCase.id;
            listWROFF.add(instOfWriteOff);
            instOfWriteOff.Office_Location__c = 'US';
            instOfWriteOff.Net_bookings_Impact_counted_sales__c = 15123523;
            instOfWriteOff.Net_bookings_Impact_Uncounted_sales__c = 12335355;
            insert listWROFF;
            
            instOfWriteOff.Write_Off_Status__c = 'Submitted for Review';
            instOfWriteOff.New_TCV_To_Be_Moved__c ='Yes';
            update instOfWriteOff;
        }
        
        Test.stopTest();
        
    } // end of test method
    
} // end of class