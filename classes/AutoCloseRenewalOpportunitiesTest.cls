@isTest
public class AutoCloseRenewalOpportunitiesTest {

    private static Opportunity createData() {
        VistaAssetHelperUtil util = new VistaAssetHelperUtil();
        Account a = util.createAccount('TestAccount');
        Contact contact = util.createNewContact('Lastname', a);
        Opportunity opportunity = util.createNewOpportunity('Test Opportunity 1', a, 'Products, Services and Maintenance', 'New', contact);
        Opportunity o = util.createNewOpportunity('Test Opp', a, null, 'New', contact);
        return o;
    }

    static testMethod void testPast() {
        Opportunity oppPast = createData();
        Test.startTest();
        //past - close
        //oppPast.StageName = 'Prospecting';
        oppPast.CloseDate = System.today().addDays(2);
        oppPast.Auto_Close_Date__c = System.today() ; //.addDays(-1);
        update oppPast;
        AutoCloseRenewalopportunities batch = new AutoCloseRenewalopportunities();
        database.executeBatch(batch, 1);
        Test.stopTest();
        List<Opportunity> queriedOpps = [SELECT Id FROM Opportunity WHERE IsClosed = true];
        //System.assertEquals(1, queriedOpps.size());
    }

    static testMethod void testFuture() {
        Opportunity oppFuture = createData();
        Test.startTest();
        //future - not closed
        //oppFuture.StageName = 'Prospecting';
        oppFuture.CloseDate = System.today().addDays(2);
        //oppFuture.Auto_Close_Date__c = System.today().addDays(1);
        update oppFuture;
        AutoCloseRenewalopportunities batch = new AutoCloseRenewalopportunities();
        database.executeBatch(batch, 1);
        Test.stopTest();
        List<Opportunity> queriedOpps = [SELECT Id FROM Opportunity WHERE IsClosed = true];
        System.assertEquals(0, queriedOpps.size());
    }

    static testMethod void testToday() {
        Opportunity oppToday = createData();
        Test.startTest();
        //today - close
        //oppToday.StageName = 'Prospecting';
        oppToday.CloseDate = System.today().addDays(2);
        //oppToday.Auto_Close_Date__c = System.today();
        update oppToday;
        AutoCloseRenewalopportunities batch = new AutoCloseRenewalopportunities();
        database.executeBatch(batch, 1);
        Test.stopTest();
        List<Opportunity> queriedOpps = [SELECT Id FROM Opportunity WHERE IsClosed = true];
        //System.assertEquals(1, queriedOpps.size());
    }

    static testMethod void testEmail() {
        Opportunity oppFail = createData();
        Opportunity o = [SELECT AccountId FROM Opportunity WHERE Id = :oppFail.Id];
        Account a = new Account(Id = o.AccountId, BillingStateCode = '', BillingCountryCode = 'US', BillingPostalCode = '',BillingState='PA');
        update a;

        Test.startTest();

        //oppFail.StageName = 'Prospecting';


        //fail to close - send email
        //some value to set to cause closing to fail
        oppFail.CloseDate = System.today();
       // oppFail.Auto_Close_Date__c = System.today();
        update oppFail;
        AutoCloseRenewalopportunities batch = new AutoCloseRenewalopportunities();
        database.executeBatch(batch, 1);
        batch.sendEmail(OppFail.Id, OppFail.OwnerId,'error');

        Test.stopTest();

        List<Opportunity> queriedOpps = [SELECT Id FROM Opportunity WHERE IsClosed = true];
        //System.assertEquals(1, queriedOpps.size());
    }

    static testMethod void testSchedulable() {
        Opportunity oppFail = createData();
        Opportunity o = [SELECT AccountId FROM Opportunity WHERE Id = :oppFail.Id];
        Account a = new Account(Id = o.AccountId, BillingStateCode = '', BillingCountryCode = 'US', BillingPostalCode = '',BillingState='PA');
        update a;

        Test.startTest();

        //oppFail.StageName = 'Prospecting';


        //fail to close - send email
        //some value to set to cause closing to fail
        oppFail.CloseDate = System.today();
        //oppFail.Auto_Close_Date__c = System.today();
        update oppFail;
        String strSchedule = createScheduleString(6,3);
        System.debug('AutoCloseRenewalOpportunitiesTest.testSchedulable: createScheduleString:'+strSchedule);

        String strJobName = 'AutoRenew-' + strSchedule;

        System.schedule(strJobName, strSchedule, new AutoCloseRenewalOpportunitiesSchedulable());

        Test.stopTest();

        List<Opportunity> queriedOpps = [SELECT Id FROM Opportunity WHERE IsClosed = true];
        //System.assertEquals(1, queriedOpps.size());
    }

    private static String createScheduleString(Integer fromNow, Integer hms){
        /*
         * Example usage:
         * String strSchedule = createScheduleString(5,3);
         * where fromNow is unit of time designated by
         * hms: 1=hour,2=min,3=sec, not 1,2,3 = sec
         * String strJobName = 'AutoRenew-' + strSchedule;
         * System.schedule(strJobName, strSchedule, new SomeSchedulableClass());
            The following are the values for the cron scheduleexpression:

            Name    Values  Special Characters
            Seconds 0–59    None
            Minutes 0–59    None
            Hours   0–23    None
            Day_of_month    1–31    special chars: , - * ? / L W
            Month   1–12 or the following:
            JAN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV DEC special chars: , - * /
            Day_of_week 1–7 or the following:
            SUN MON TUE WED THU FRI SAT special chars: , - * ? / L #
            optional_year   null or 1970–2099    special chars: , - * /
         *
            ,   Delimits values. For example, use JAN, MAR, APR to specify more than one month.
            -   Specifies a range. For example, use JAN-MAR to specify more than one month.
            *   Specifies all values. For example, if Month is specified as *, the job is scheduled for every month.
            ?   Specifies no specific value. This is only available for Day_of_month and Day_of_week, and is generally used when specifying a value for one and not the other.
            /   Specifies increments. The number before the slash specifies when the intervals will begin, and the number after the slash is the interval amount. For example, if you specify 1/5 for Day_of_month, the Apex class runs every fifth day of the month, starting on the first of the month.
            L   Specifies the end of a range (last). This is only available for Day_of_month and Day_of_week. When used with Day of month, L always means the last day of the month, such as January 31, February 29 for leap years, and so on. When used with Day_of_week by itself, it always means 7 or SAT. When used with a Day_of_week value, it means the last of that type of day in the month. For example, if you specify 2L, you are specifying the last Monday of the month. Do not use a range of values with L as the results might be unexpected.
            W   Specifies the nearest weekday (Monday-Friday) of the given day. This is only available for Day_of_month. For example, if you specify 20W, and the 20th is a Saturday, the class runs on the 19th. If you specify 1W, and the first is a Saturday, the class does not run in the previous month, but on the third, which is the following Monday.
         */
        DateTime future;
        if(hms==1) {
            future = system.now().addHours(fromNow);
        }else if(hms==2){
            future = system.now().addMinutes(fromNow);
        }else{
            future = system.now().addSeconds(fromNow);
        }
        Integer year = future.year();
        Integer month = future.month();
        Integer day = future.day();
        Integer hour = future.hour();
        Integer minute = future.minute();
        Integer second = future.second();
        return second + ' ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;

    }

}