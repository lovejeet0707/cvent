// ===============================
// AUTHOR     :  SHANU AGGARWAL
// CREATE DATE     :  5 FEB 2016
// PURPOSE     :  CALCULATE NO OF WORKING DAYS
// TEST CLASS: CalculateWorkingDaysTest
// SPECIAL NOTES:
// ===============================
// Change History:
//
//==================================
public class CalculateWorkingDays{
    
    public static integer ReturnDiffBtwDates( Date StartDate, Date EndDate ){
        
        //Difference Total Days
        Integer diffTotal = StartDate.daysBetween(EndDate);
        
        //Final Difference
        Integer finalDiff = diffTotal;
        
        
       system.debug('StartDate======>'+StartDate);
       system.debug('EndDate ======>'  +  EndDate );
        
        
        for(integer i =0; i<=diffTotal ; i++){
           
           if (isWeekendDay(StartDate) || IsHoliday(StartDate)){
               finalDiff = finalDiff - 1 ;   
           }
           StartDate = StartDate.AddDays(1);
        }
        system.debug('finalDiff======>'+finalDiff);
        return finalDiff;
    }   
    

   public static Date AddBusinessDays(Date StartDate, integer BusinessDaysToAdd ){
      //Add or decrease in BusinessDaysToAdd days 
          Date finalDate = StartDate;
          integer direction = BusinessDaysToAdd < 0 ? -1 : 1;
          
          
       while(BusinessDaysToAdd!= 0)
       {
           finalDate = finalDate.AddDays(direction);
           if (!isWeekendDay(finalDate) && !IsHoliday(finalDate))
           {
               BusinessDaysToAdd -= direction;        
           }
       }
       
       system.debug('finalDate======>'+finalDate);
       return finalDate;
    }
    
   
    
    public static Boolean IsWeekendDay(Date dateParam){
        boolean result = false;
        //Recover the day of the week
        Date startOfWeek = dateParam.toStartOfWeek();
        Integer dayOfWeek = startOfWeek.daysBetween(dateParam);
        result = dayOfWeek == 0 || dayOfWeek == 6 ? true : false;
        return result;
    
    }
	
	public static Boolean IsHoliday(Date dateParam){
		
        boolean result = false;
		// If Holiday Exist
        result = US_Holidays__c.getvalues(string.valueOf(dateParam))!=null ? true : false;
        return result;
    
    }
    
}