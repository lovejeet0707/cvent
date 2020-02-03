public with sharing class BeanCompanyNameSanitise {

    private static Pattern dissallowedCharsP 
    {
        get 
        {
            if(dissallowedCharsP == null)
            {
                dissallowedCharsP = Pattern.compile('[\\s\\p{Punct}´ªº’€£₤©®™℠]');
            }
            return dissallowedCharsP;
        }
        set;
    }

    public static String sanitiseName(String name){
        if(name == null || name == ''){
            return name;
        }
        
        String s = name.toUpperCase().replaceAll('[ÀÂÁÃ]','A').replaceAll('[ÉÈẼÊË]','E').replaceAll('[ÎÏÌÍĨ]','I').replaceAll('[ÔÓÒÕ]','O').replaceAll('[ÛÚÙŨ]','U').replaceAll('[Ñ]','N').replaceAll('[Ç]','C').replaceAll('[Ü]','UE').replaceAll('[ŒÖ]','OE').replaceAll('[ÆÄ]','AE');
        
        Matcher m = nameP.matcher(s);
        
        m = dissallowedCharsP.matcher(m.replaceAll(''));
        
        return m.replaceAll('');
    }

    private static Pattern nameP 
    {
        get 
        {
            if(nameP == null)
            {
                //Added OF, THE (Shanu)
                string s = 'ASSOCIATION|SOCIETY|COUNCIL|COALITION|FOUNDATION|AMERICAN|NATIONAL|CANADIAN|UNITED STATES|UNIVERSITY|INSTITUTE|ALABAMA|ALASKA|ARIZONA|ARKANSAS|CALIFORNIA|COLORADO|CONNECTICUT|DELAWARE|FLORIDA|GEORGIA|HAWAII|IDAHO|ILLINOIS|INDIANA|IOWA|KANSAS|KENTUCKY|LOUISIANA|MAINE|MARYLAND|MASSACHUSETTS|MICHIGAN|MINNESOTA|MISSISSIPPI|MISSOURI|MONTANA|NEBRASKA|NEVADA|NEW HAMPSHIRE|NEW JERSEY|NEW MEXICO|NEW YORK|NORTH CAROLINA|NORTH DAKOTA|OHIO|OKLAHOMA|OREGON|PENNSYLVANIA|RHODE ISLAND|SOUTH CAROLINA|SOUTH DAKOTA|TENNESSEE|TEXAS|UTAH|VERMONT|VIRGINIA|WASHINGTON|WEST VIRGINIA|WISCONSIN|WYOMING|AMERICA|UNIVERSITIES|CHAPTER|LIMITED|INTERNATIONAL|FEDERAL|COLLEGE|CORPORATIONS|CORPORATION|PUBLIC|PRIVATE|CENTRAL|AUSTRALIA|AUSTRALIAN|OF|THE';
                nameP = Pattern.compile(s);
            }
            return nameP;
        }
        set;
    }
}