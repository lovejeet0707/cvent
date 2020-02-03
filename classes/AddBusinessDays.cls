/**=====================================================================
 * Cvent
 * Name: AddBuisnessDays
 * Description: Utility Class to add Buisness Days
 * Created Date: [15/11/2016]
 * Created By: Hemant Rana
 * 
 * Date Modified                Modified By                  Description of the update
 * [MON DD, YYYY]               [FirstName LastName]         [Short description for changes]
 =====================================================================*/ 

public class AddBusinessDays{
    public static Boolean IsWeekendDay(Date dateParam)
    {
        /*boolean result     = false;
        system.debug('dateParam = '+dateParam); 
        //Recover the day of the week
        Date startOfWeek   = dateParam.toStartOfWeek();
        system.debug('startOfWeek = '+startOfWeek);
        Integer dayOfWeek  = dateParam.day() - startOfWeek.day();
        system.debug('dayOfWeek = '+dayOfWeek);   
        result = dayOfWeek == 0 || dayOfWeek == 6 ? true : false;
        system.debug('result = '+result); 
        return result;*/
        //Recover the day of the week
        boolean result     = false;
        Date startOfWeek = dateParam.toStartOfWeek();
        Integer dayOfWeek = startOfWeek.daysBetween(dateParam);
        result = dayOfWeek == 0 || dayOfWeek == 6 ? true : false;
        return result;
    }
    public static Date AddDaysMethod(Date StartDate, Decimal BusinessDaysToAdd )
    {
        //Add or decrease in BusinessDaysToAdd days 
        Date finalDate = StartDate;
        system.debug('finaldate = '+finalDate);
        integer direction = BusinessDaysToAdd < 0 ? -1 : 1;
        system.debug('direction = '+direction);
        while(BusinessDaysToAdd != 0)
        {
            finalDate = finalDate.AddDays(direction);
            system.debug('BusinessDaysToAdd = '+BusinessDaysToAdd);            
            system.debug('finaldate = '+finalDate);
            if (!isWeekendDay(finalDate))
            {
                BusinessDaysToAdd -= direction;
            }
        }
        System.debug('finalDate***********'+finalDate);
        return finalDate;
    }
}