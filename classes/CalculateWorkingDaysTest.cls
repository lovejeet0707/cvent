@isTest
Public Class CalculateWorkingDaysTest{


  @isTest Public static void testAddBusinessDays(){
  
      CalculateWorkingDays.AddBusinessDays(System.Today(),2);
      CalculateWorkingDays.ReturnDiffBtwDates(System.Today(), System.Today() + 3);
  
  }

}