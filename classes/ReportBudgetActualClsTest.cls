/*
//////////////////////////////////////
//		@author Abhishek Pandey		//
/////////////////////////////////////
Version :	1.0
Date : 1 July 2014
Description : Test Class to test controller ReportBudgetActualCls
*/
@isTest
private class ReportBudgetActualClsTest {
	
	public static Opportunity instOfOpp = new Opportunity();  	
	
    static testMethod void myUnitTest() {
        ReportBudgetActualCls instOfRepBudCls = new ReportBudgetActualCls();
        String month = 'Jan';
        Decimal data1 =1;
        Decimal data2= 1;
        ReportBudgetActualCls.OpportunityData instOfOppData  =  new ReportBudgetActualCls.OpportunityData(month, data1,data2);     
            
        String product = 'Event';
        String teamValue = 'AM';
        Integer monthFromJs = 1;
        Integer monthToJs = 2 ;
		ReportBudgetActualCls.monthFrom = null;
		ReportBudgetActualCls.monthTo = null;
		        
        ReportBudgetActualCls.loadOpps(product, teamValue, monthFromJs, monthToJs);
        product = '';
        ReportBudgetActualCls.loadOpps(product, teamValue, monthFromJs, monthToJs);      
        teamValue = '';
        product = 'Event';
        ReportBudgetActualCls.loadOpps(product, teamValue, monthFromJs, monthToJs);
        teamValue = 'AM';
        monthFromJs = null;
        monthToJs = null;
        ReportBudgetActualCls.loadOpps(product, teamValue, monthFromJs, monthToJs);   
    }
}