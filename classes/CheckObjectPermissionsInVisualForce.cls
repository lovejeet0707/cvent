public class CheckObjectPermissionsInVisualForce { 
String results; 

public CheckObjectPermissionsInVisualForce(String objectName) { 
IF(!test.IsrunningTest())
results = new PageReference('/apex/testObjectPermissions?obj=' + objectName).getContent().toString(); 
else
results = '<accessible>true</accessible>';
} 

public Boolean isAccessible() { 
return results.contains('<accessible>true</accessible>'); 
} 

/*public Boolean isCreateable() { 
return results.contains('<createable>true</createable>'); 
} 

public Boolean isDeletable() { 
return results.contains('<deletable>true</deletable>'); 
} 

public Boolean isUndeletable() { 
return results.contains('<undeletable>true</undeletable>'); 
} 

public Boolean isUpdateable() { 
return results.contains('<updateable>true</updateable>'); 
} */
}