public class sObjectFetch{
    
    public static Set<String> kavNames{get;set;}
    public static List<String> articleKavNames = new List<String>();
    public static Map<String,Schema.SOBjectType> gd = Schema.getGlobalDescribe();
    static{
        kavNames = new Set<String>();
        gd = Schema.getGlobalDescribe();
        System.debug('gd************'+gd);
        for(String s : gd.keySet()) {
            System.debug('s******'+s);
            Schema.SObjectType objectType = gd.get(s);
            System.debug('objectType******'+objectType);
            Schema.DescribeSObjectResult drSObj = objectType.getDescribe();//Need to be commented in future
            System.debug('drSObj******'+drSObj);
            System.debug('s.contains__kav******'+s.contains('__kav'));
            System.debug('isAccessible******'+drSObj.isAccessible());
            if (s.contains('__kav') && new CheckObjectPermissionsInVisualForce(s).isAccessible())//&& drSObj.isAccessible()) {
            {    System.debug('Inside If'+s);
                kavNames.add(s);
                articleKavNames.add('\''+gd.get(s).getDescribe().getName()+'\'');
            }
        }
    }
    public static void fakeMethod(){
        integer i=1;
        i++;
    }
}