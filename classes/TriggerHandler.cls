// Generic Trigger Handler - Ricky Lowe - Cloud Perspective - Ricky@cloudperspective.co.uk
// Originally written by John Jordan (John@airspeed.co.uk)

public abstract class TriggerHandler {
    /**
     * @description When set to true will prevent the trigger handler being executed more than once
     */
    //private static Boolean preventRecursiveTrigger = false; removed as this may make other triggers for other triggers stop - think this varaible needs to be object specific not global
    
    /**
     * @description Used to prevent the trigger handler from being executed more than once
     */
    //private static Boolean beforeHasExecuted = false;
    //private static Boolean afterHasExecuted = false;

    private static set<Schema.SObjectType> beforeHasExecutedObjectNames = new set<Schema.SObjectType>();
    private static set<Schema.SObjectType> AfterHasExecutedObjectNames = new set<Schema.SObjectType>();

    
    /**
     * @description This will be called in the trigger before insert event
     * @param newObjects List of new sObjects to be inserted
     */
    public virtual void beforeInsert(List<SObject> newObjects) {}
        
    /**
     * @description This will be called in the trigger before update event
     * @param oldObjects List of the sObjects being updated with their original values
     * @param newObjects List of the sObjects being updated with their new values
     * @param oldMap Map of the sObjects being updated with their original values
     * @param newMap Map of the sObjects being updated with their new values
     */
    public virtual void beforeUpdate(List<SObject> oldObjects, List<SObject> newObjects, Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {}

    /**
     * @description This will be called in the trigger before delete event
     * @param objects List of the sObjects being deleted
     * @param objectsMap Map of the sObjects being deleted
     */
    public virtual void beforeDelete(List<SObject> objects, Map<Id, SObject> objectsMap) {}

    /**
     * @description This will be called in the trigger after insert event
     * @param newObjects List of the sObjects being inserted
     * @param newObjectsMap Map of the sObjects being inserted
     */
    public virtual void afterInsert(List<SObject> newObjects, Map<Id, SObject> newObjectsMap) {}
        
    /**
     * @description This will be called in the trigger after update event
     * @param oldObjects List of the sObjects being updated with their original values
     * @param newObjects List of the sObjects being updated with their new values
     * @param oldObjectsMap Map of the sObjects being updated with their original values
     * @param newObjectsMap Map of the sObjects being updated with their new values
     */
    public virtual void afterUpdate(List<SObject> oldObjects, List<SObject> newObjects, Map<Id, SObject> oldObjectsMap, Map<Id, SObject> newObjectsMap) {}

    /**
     * @description This will be called in the trigger after delete event
     * @param objects List of objects to be deleted
     * @param objectsMap Map of objects to be deleted
     */
    public virtual void afterDelete(List<SObject> objects, Map<Id, SObject> objectsMap) {}

    /**
     * @description This will be called in the trigger after undelete event
     * @param objects List of objects which have been undeleted
     * @param objectsMap Map of objects which have been undeleted
     */
    public virtual void afterUndelete(List<SObject> objects, Map<Id, SObject> objectsMap) {}

    /**
     * @description This will call the relevant method in the trigger handler for the current trigger event
     */
    public void execute()
    {
        
        //Get the Sobject Type
        Schema.SObjectType sobjType;
        if(Trigger.old != null){
        	sobjType = Trigger.old[0].getsObjectType();
        }
        else{
        	sobjType = Trigger.new[0].getsObjectType();
        }

        // Call the relevant trigger event method
        if (Trigger.isBefore){// && !beforeHasExecutedObjectNames.contains(sobjType)) {  
        	system.debug('Before '+ sobjType + ' Trigger firing for first time');           
            if (Trigger.isDelete) {
                beforeDelete(Trigger.old, Trigger.oldMap);
            } 
            else if (Trigger.isInsert) {
                beforeInsert(Trigger.new);
            }
            else if (Trigger.isUpdate) {
                beforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
            }

            beforeHasExecutedObjectNames.add(sobjType);		//Stops recursion on the Before Trigger for this object only
            system.debug('Before triggers fired: ' + beforeHasExecutedObjectNames);  

            //beforeHasExecuted = true;
        } 
        else if(Trigger.isAfter){// && !AfterHasExecutedObjectNames.contains(sobjType)){
        	system.debug('After '+ sobjType + ' Trigger firing for first time');  
            if (Trigger.isDelete) {
                afterDelete(Trigger.old, Trigger.oldMap);
            }
            else if (Trigger.isInsert) {
                afterInsert(Trigger.new, Trigger.newMap);
            }
            else if (Trigger.isUpdate) {
                afterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
            }
            else if (Trigger.isUndelete) {
                afterUndelete(Trigger.new, Trigger.newMap);
            }

            AfterHasExecutedObjectNames.add(sobjType);		//Stops recursion on the After Trigger for this object only
            system.debug('After triggers fired: ' + AfterHasExecutedObjectNames);  
            //afterHasExecuted = true;
        }
    }
    
    
}