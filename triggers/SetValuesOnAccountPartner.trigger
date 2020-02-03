//*********************************************************************************** 
//
//  SetValuesOnAccountPartner
//
//  Desciption:
//  This trigger was created by InSitu Software for cVent. The purpose of the trigger
//  is to mirror the value from the (multi-select picklist) Role_Select__c field to the 
//  (text) Role__c field. Due to the limitations (difficulty searching, can't sort, etc.)
//  the text field value should be used for reporting, lists, views, etc.
//
//  History:
//  InSitu  06/17/2013  Original version.
//
// ***********************************************************************************

trigger SetValuesOnAccountPartner on Account_Partner__c (before insert, before update) 
{
    // Make sure the processing is bulk safe.
    for (integer iIdx = 0; iIdx < Trigger.new.size(); iIdx++)
    {
	    // Use local variables for efficiency.
	    String sMultiFieldValueNew = (String)Trigger.New[iIdx].Role_Select__c;
	    String sMultiFieldValueOld = System.Trigger.isInsert ? null : (String)Trigger.Old[iIdx].Role_Select__c;

        // Make sure there is a value or the current value has changed.
        if ((System.Trigger.isInsert && sMultiFieldValueNew != null)
        	 || 
            (!System.Trigger.isInsert && sMultiFieldValueNew != sMultiFieldValueOld))  
        {
            // Check to see if there is a value.
            if (sMultiFieldValueNew == null)
            {
            	// Existing value was deleted, so clear out the display field.
            	Trigger.New[iIdx].Role__c = null;
            }
            else
            {
	            // Parse values.
	            List<String> listValues = sMultiFieldValueNew.split(';', 0);
	            
	            // Do we have multiple values?
	            if (listValues.size() > 1)
	            {
		            // Sort values.
		            listValues.sort();
		            
		            // Format values.
		            String sFormattedValue = String.join(listValues, '; ');
		            	
		            // Set formatted value - Field value cannot be more than 255.
		            Trigger.New[iIdx].Role__c = sFormattedValue.abbreviate(255);
	            }
	            else
	            {
	            	// Only one value, so the display name is the same as the multi-select field value.
	            	Trigger.New[iIdx].Role__c = sMultiFieldValueNew;
	            }
            }
        }
    }
}