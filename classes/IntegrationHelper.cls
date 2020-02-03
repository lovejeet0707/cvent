public class IntegrationHelper
{

//Copies all the fields on a queue item to another item.    
    public static void copyQueueItem(Integration_Queue__c curItem, Integration_Queue__c newValues, List<EBS_Integration__c> fieldList)
    {
        System.Debug(Logginglevel.DEBUG,'INTEGRATIONHELPER.COPYQUEUEITEM - Copying fields to existing queue item');
        for(EBS_Integration__c f:fieldList)
        {
            try
            {
                curItem.put(f.Map_To__c,newValues.get(f.Map_To__c));
                System.Debug(Logginglevel.FINE,'INTEGRATIONHELPER.COPYQUEUEITEM - Copying field: '+f.Map_To__c);
            }
            catch(Exception e)
            {
                System.Debug(Logginglevel.FINE,'INTEGRATIONHELPER.COPYQUEUEITEM - Error copying field: '+f.Map_to__c);
            }
        }
        curItem.Queue__c=newValues.Queue__c;
        curItem.Status__c=newValues.Status__c;
        curItem.Type__c=newVAlues.Type__c;
    }

//Map object to queue item    
    public static Integration_Queue__c mapToQueue(sObject sourceObj, List<EBS_Integration__c> fieldList)
    {
        if (fieldList.isEmpty())
        {
            System.Debug(Logginglevel.ERROR, 'INTEGRATIONHELPER.MAPTOQUEUE - Empty field list used while comparing two objects!');
            return null;
        }
        else
        {
            System.Debug(LoggingLevel.FINE, 'INTEGRATIONHELPER.MAPTOQUEUE - Mapping fields to Integration Queue');
            Integration_Queue__c tmpItem = new Integration_Queue__c();
            for(EBS_Integration__c i:fieldList)
            {
                if(i.Map__c)
                {
                    try
                    {
                        if (i.Field__c.IndexOf('.') > 0)
                        {
                            System.Debug(LoggingLevel.FINER,'INTEGRATIONHELPER.MAPTOQUEUE - Mapping '+i.Field__c);
                            sObject innerObj=sourceObj;
                            List<String> fieldParam=i.Field__c.split('\\.',0);
                            for(Integer objs=0;objs<fieldParam.size()-1;objs++)
                            {
                                if(innerObj!=null)
                                {
                                    System.Debug(Logginglevel.FINEST,'INTEGRATIONHELPER.MAPTOQUEUE - Getting child object('+fieldParam[objs]+') for '+i.Field__c+'.');
                                    innerObj=innerObj.getSObject(fieldParam[objs]);
                                }
                                else
                                {
                                    System.Debug(Logginglevel.FINEST,'INTEGRATIONHELPER.MAPTOQUEUE - Couldn\'t find child('+fieldParam[objs]+') for '+i.Field__c+'.');
                                    break;
                                }    
                            }
                            if(innerObj!=null)
                            {
                                System.Debug(Logginglevel.FINE,'INTEGRATIONHELPER.MAPTOQUEUE - Mapping '+i.Field__c+' to '+i.Map_To__c+' with value of '+String.valueOf(innerObj.get(fieldParam[fieldParam.size()-1])));
                                tmpItem.put(i.Map_To__c, String.valueOf(innerObj.get(fieldParam[fieldParam.size()-1])));
                            }
                            else
                            {
                                System.Debug(Logginglevel.FINE,'INTEGRATIONHELPER.MAPTOQUEUE - Couldn\'t get traverse object for '+i.Field__c);
                            }
                        }
                        else
                        {
                                System.Debug(Logginglevel.FINE,'INTEGRATIONHELPER.MAPTOQUEUE - Mapping '+i.Field__c+' to '+i.Map_To__c+' with value of '+String.valueOf(sourceObj.get(i.Field__c)));
                            tmpItem.put(i.Map_To__c, String.valueOf(sourceObj.get(i.Field__c)));
                        }
                    }
                    catch(Exception e)
                    {
                        System.Debug(Logginglevel.ERROR, 'INTEGRATIONHELPER.MAPTOQUEUE - Error encountered will assigning values to new Integration Queue item: '+e.getMessage());
                    }
                }
            }
            return tmpItem;
        }
    }

//Compares two objects for any changes based on the field list
    public static Integer compare(sObject obj1, sObject obj2, List<EBS_Integration__c> fieldList)
    {
        System.Debug(Logginglevel.DEBUG,'INTEGRATIONHELPER.COMPARE - Start');
        if (fieldList.isEmpty())
        {
            System.Debug(Logginglevel.ERROR, 'INTEGRATIONHELPER.COMPARE - Empty field list used while comparing two objects!');
            return -1;
        }
        else
        {
            System.Debug(LoggingLevel.FINE, 'INTEGRATIONHELPER.COMPARE - Comparing fields');
            Integer comp = 0;
            for (EBS_Integration__c f: fieldList)
            {
                try
                {
                    System.Debug(Logginglevel.FINER, 'INTEGRATIONHELPER.COMPARE - Comparing '+f.Field__c);
                    if(f.Validate__c&&(!f.Field__c.contains('.'))&&obj1.get(f.Field__c)!=obj2.get(f.Field__c))
                    {
                        comp = 1;
                        break;
                    }
                    System.Debug(Logginglevel.FINER, 'INTEGRATIONHELPER.COMPARE - Comparing '+f.Field__c);
                }
                catch(Exception e) 
                {
                    System.Debug(Logginglevel.FINER, 'INTEGRATIONHELPER.COMPARE - Error encountered while comparing fields between two objects: '+e.getMessage());
                }
            }
            return comp;
        }
    }

    public static void addToQueue(Map<String,Integration_Queue__c> newList,List<EBS_Integration__c> fieldList,String qName)
    {
        System.Debug(Logginglevel.DEBUG,'INTEGRATIONHELPER.ADDTOQUEUE - Start');
        System.Debug('****fieldList***' +  fieldList);
        String queryString='SELECT ';
        for(EBS_Integration__c f:fieldList)
        {
            if(!queryString.contains(f.Map_To__c+','))
                queryString+=f.Map_To__c+',';
        }
        System.Debug('****queryString1***' +  queryString);
        if(queryString!='SELECT ')
        {
            Set<String> newSet=newList.keySet();
            queryString+='id,Queue__c,Status__c,Object_ID__c,Type__c FROM Integration_Queue__c WHERE Queue__c=:qName AND Status__c=\'Queued\' AND Object_Id__c IN :newSet';
            System.Debug(Logginglevel.FINER,'INTEGRATIONHELPER.ADDTOQUEUE - Running query: '+queryString);
            System.Debug('****queryString2***' +  queryString);
            try
            {
                List<Integration_Queue__c> eList=Database.query(queryString);
                System.Debug(Logginglevel.FINER,'INTEGRATIONHELPER.ADDTOQUEUE - Found '+eList.size()+' existing items.');

                for(Integration_Queue__c i:eList)
                {
                    System.Debug(Logginglevel.FINEST,'INTEGRATIONHELPER.ADDTOQUEUE - Found existing queued item: '+i.Object_Id__c);
                    Integration_Queue__c newer=newList.get(i.Object_Id__c);
                    if(newer!=null)
                    {
                        copyQueueItem(i, newer, fieldList);
                        System.Debug(Logginglevel.FINEST,'INTEGRATIONHELPER.ADDTOQUEUE - Updating queue item: '+i.Name);
                        
                        //Moved to line# 162 as same list is being update and causing DML Statement Limit issue
                        //update i;
                        
                        System.Debug(Logginglevel.FINEST,'INTEGRATIONHELPER.ADDTOQUEUE - Old size: '+newList.size());
                        newList.remove(i.Object_Id__c);
                        System.Debug(Logginglevel.FINEST,'INTEGRATIONHELPER.ADDTOQUEUE - New size: '+newList.size());
                    }
                }
                

                update eList;
            }
            catch(Exception e)
            {
                System.Debug(Logginglevel.ERROR,'INTEGRATIONHELPER.ADDTOQUEUE - Error '+e.getMessage());
            }
        }
        if(!newList.isEmpty())
        {
            System.Debug(Logginglevel.FINE,'INTEGRATIONHELPER.ADDTOQUEUE - Adding '+newList.size()+' to the queue');
            insert newList.Values();
        }
    }

/*
//Fuzzy search for country code
    public static CountryCodes__c findCountry(String country)
    {
        System.Debug(Logginglevel.DEBUG,'INTEGRATIONHELPER.FINDCOUNTRY - Start');
        if(country!=null&&country!='')
        {
            String search=country.toUpperCase();
            Map<String,CountryCodes__c> ccList=CountryCodes__c.getall();
            CountryCodes__c bestmatch=ccList.get(search);
            if(bestmatch==null)
            {
                System.Debug(Logginglevel.FINE,'INTEGRATIONHELPER.FINDCOUNTRY - Starting ngram search');
                Integer nsize=3;
                Integer tolerance=2;
                List<String> ngram=new List<String>();
                if(search.length()<=nsize)
                {
                    nsize=1;
                    System.Debug(Logginglevel.FINER,'INTEGRATIONHELPER.FINDCOUNTRY - String too short. Switching to ngram size of 1');
                }
                String queryString='SELECT Name, CountryCode__c FROM CountryCodes__c WHERE Name like ';
                for(Integer i=0;i<search.length()-nsize+1;i++)
                {
                    String stub=search.mid(i,nsize);
                    ngram.Add(stub);
                    queryString+='\'%'+stub+'%\' OR Name like ';
                }
                queryString+='\''+search.left(1)+'%\'';
                System.Debug(Logginglevel.FINER,'INTEGRATIONHELPER.FINDCOUNTRY - Running query string: '+queryString);
                List<CountryCodes__c> countryList=Database.query(queryString);
                Integer leasterrors=999;
                Integer errors;
                String check;
                for(CountryCodes__c c:countryList)
                {
                    check=c.Name;
                    if(check.Length()<search.Length()-tolerance)
                        errors=search.Length()-check.Length()-tolerance;
                    else if(check.Length()>search.Length()+tolerance)
                        errors=check.Length()-search.Length()-tolerance;
                    else
                        errors=0;
                    if(search.left(1)==check.left(1))
                        errors--;
                    if(check.Length()>=nsize)
                    {    
                        for(String s:ngram)
                        {
                            if(!check.Contains(s))
                                errors++;
                            if(errors>=leasterrors)
                                break;
                        }
                    }
                    else
                        errors+=ngram.size();
                    System.Debug(Logginglevel.FINEST,'INTEGRATIONHELPER.FINDCOUNTRY - Checking '+c.Name+'. Found '+errors+' errors');
                    if(errors<leasterrors)
                    {
                        leasterrors=errors;
                        bestmatch=c;
                    }
                    if(leasterrors<=tolerance)
                        break;
                }
                if(bestmatch!=null)
                {
                    System.Debug(Logginglevel.FINEST,'INTEGRATIONHELPER.FINDCOUNTRY - Best match for '+country+': '+bestmatch.Name+' with '+leasterrors+' errors');
                    return bestmatch;
                }
                else
                {
                    System.Debug(Logginglevel.ERROR,'INTEGRATIONHELPER.FINDCOUNTRY - No suitable match found for '+country+'. Defaulting to US');
                    return CountryCodes__c.getAll().get('UNITED STATES');
                }
            }
            else
            {
                System.Debug(Logginglevel.FINE,'INTEGRATIONHELPER.FINDCOUNTRY - Found exact match: '+bestmatch.CountryCode__c);
                return bestmatch;
            }
        }
        return null;
    }

//Looking for Canadian provinces
    public static CAProvinceLookup__c findProvince(String findP)
    {
        System.Debug(Logginglevel.DEBUG,'INTEGRATIONHELPER.FINDPROVINCE - Start');
        if(String.isNotBlank(findP))
        {
            String search=findP.toUpperCase();
            CAProvinceLookup__c bestmatch=CAProvinceLookup__c.getAll().get(search);
            if(bestmatch==null)
            {
                System.Debug(Logginglevel.FINE,'INTEGRATIONHELPER.FINDPROVINCE - Running ngram search for '+findP);
                Integer nsize=3;
                Integer tolerance=2;
                if(search.length()<=nsize)
                {
                    nsize=1;
                    System.Debug(Logginglevel.FINER,'INTEGRATIONHELPER.FINDPROVINCE - Search string too short. Changing ngram size to 1');
                }
                List<CAProvinceLookup__c> pList=CAProvinceLookup__c.getAll().Values();
                List<String> ngram=new List<String>();
                Integer leasterrors=999;
                Integer errors;
                String check;
                for(Integer i=0;i<search.length()-nsize+1;i++)
                {
                    ngram.Add(search.mid(i,nsize));
                }
                for(CAProvinceLookup__c p:pList)
                {
                    check=p.Name;
                    if(check.Length()<search.Length()-tolerance)
                        errors=search.Length()-check.Length()-tolerance;
                    else if(check.Length()>search.Length()+tolerance)
                        errors=check.Length()-search.Length()-tolerance;
                    else
                        errors=0;
                    if(search.left(1)==check.left(1))
                        errors--;
                    if(check.Length()>=nsize)
                    {    
                        for(String s:ngram)
                        {
                            if(!check.Contains(s))
                                errors++;
                            if(errors>=leasterrors)
                                break;
                        }
                    }
                    else
                        errors+=ngram.size();
                    System.Debug(Logginglevel.FINEST,'INTEGRATIONHELPER.FINDPROVINCE - Checking '+p.Name+'. Found '+errors+' errors');
                    if(errors<leasterrors)
                    {
                        leasterrors=errors;
                        bestmatch=p;
                    }
                    if(leasterrors<=tolerance)
                        break;
                }
                //System.Debug(Logginglevel.FINEST,'INTEGRATIONHELPER.FINDCOUNTRY - Best match for '+findP+': '+bestmatch.Name+' with '+leasterrors+' errors');
                return bestmatch;
            }
            else
            {
                System.Debug(Logginglevel.FINE,'INTEGRATIONHELPER.FINDPROVINCE - Exact match for '+findP+' found.');
                return bestmatch;
            }
        }
        else
            return null;
    }

    public static USStateLookup__c findState(String findS)
    {
        //System.Debug(Logginglevel.DEBUG,'INTEGRATIONHELPER.FINDSTATE - Start');
        if(String.isNotBlank(findS))
        {
        //do an exact match first
            String search=findS.toUpperCase();
            USStateLookup__c bestmatch=USStateLookup__c.getAll().get(search);
            if(bestmatch==null)
            {
                //System.Debug(Logginglevel.FINE,'INTEGRATIONHELPER.FINDSTATE - Running ngram search for '+findS);
                Integer nsize=3;
                Integer tolerance=2;
                if(search.length()<=nsize)
                {
                    //System.Debug(Logginglevel.FINER,'INTEGRATIONHELPER.FINDSTATE - Search string too short. Changing ngram size to 1');
                    nsize=1;
                }
                List<USStateLookup__c> sList=USStateLookup__c.getAll().Values();
                List<String> ngram=new List<String>();
                Integer leasterrors=999;
                Integer errors;
                String check;
                for(Integer i=0;i<search.length()-nsize+1;i++)
                {
                    ngram.Add(search.mid(i,nsize));
                }
                for(USStateLookup__c s:sList)
                {
                    check=s.Name;
                    if(check.Length()<search.Length()-tolerance)
                        errors=search.Length()-check.Length()-tolerance;
                    else if(check.Length()>search.Length()+tolerance)
                        errors=check.Length()-search.Length()-tolerance;
                    else
                        errors=0;
                    if(search.left(1)==check.left(1))
                        errors--;
                    if(check.Length()>=nsize)
                    {    
                        for(String t:ngram)
                        {
                            if(!check.Contains(t))
                                errors++;
                            if(errors>=leasterrors)
                                break;
                        }
                    }
                    else
                        errors+=ngram.size();
                    //System.Debug(Logginglevel.FINEST,'INTEGRATIONHELPER.FINDSTATE - Checking '+s.Name+'. Found '+errors+' errors');
                    if(errors<leasterrors)
                    {
                        leasterrors=errors;
                        bestmatch=s;
                    }
                    if(leasterrors<=tolerance)
                        break;
                }
                //System.Debug(Logginglevel.FINEST,'INTEGRATIONHELPER.FINDSTATE - Best match for '+findS+': '+bestmatch.Name+' with '+leasterrors+' errors');
                return bestmatch;
            }
            else
                return bestmatch;
        }
        else
            return null;
    }
*/
}