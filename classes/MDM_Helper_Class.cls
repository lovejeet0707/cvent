public with sharing class MDM_Helper_Class {
	private string ObjectName;

	public MDM_Helper_Class(string objName) {
		ObjectName = objName;
	}

	public Map <String, Schema.SObjectField> fieldMap{
        get{
            if(fieldMap == null){
                Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
                fieldMap = gd.get(ObjectName).getDescribe().fields.getMap();
            }
            return fieldMap;
        }
        set;
    }

    public set<String> AllFields 
    {
        get{
            if(AllFields == null){
                AllFields = new set<string>();
                for(Schema.SObjectField sfield : fieldMap.Values())
                {
                    schema.describefieldresult dfield = sfield.getDescribe();               
                    AllFields.add(dfield.getname().toUpperCase());
                }  
                system.debug('Build Field Set for object ' + ObjectName + ' = ' + AllFields);
            }
            return AllFields;
        }
        set; 
    }

    public set<String> WritableFields 
    {
        get{
            if(WritableFields  == null){
                WritableFields  = new set<string>();
                for(Schema.SObjectField sfield : fieldMap.Values())
                {
                    schema.describefieldresult dfield = sfield.getDescribe(); 
                    if(dfield.isUpdateable()){
                        WritableFields.add(dfield.getname().toUpperCase());
                    }           
                }  
                system.debug('Build Field Set for object ' + ObjectName + ' = ' + WritableFields);
            }
            return WritableFields;
        }
        set; 
    }
}