/*
	Author: Sandeep Kumar
	Version: 2.0
	Date: 2017-03-24
	Abstract class for implementing a trigger actions and enforces development standards. 
	Provides functionality for determining trigger context and tracking if trigger action has run before.
*/

public abstract class TriggerAction {
	
	/* Custom Exception for invalid contexts */
	public class InvalidContextException extends Exception {
		public InvalidContextException(TriggerAction.TriggerContext ctx){
			this.setMessage('Execution is not possible for this context: '+ctx.name());
		}
	}
	
	/* Enumeration of possible trigger contexts */
	public enum TriggerContext {
		BEFORE_INSERT,
		BEFORE_UPDATE,
		BEFORE_DELETE,
		BEFORE_UNDELETE,
		AFTER_INSERT,
		AFTER_UPDATE,
		AFTER_DELETE,
		AFTER_UNDELETE
	}
	/* Sets of context enumerations match to trigger batch data */
	// Context to use a single list for trigger batch
	private static final Set<TriggerContext> listContext = new Set<TriggerContext>{
		TriggerContext.BEFORE_INSERT
	};
	// Contexts to use a single map of new values for trigger batch
	private static final Set<TriggerContext> newMapContext = new Set<TriggerContext>{
		TriggerContext.BEFORE_UNDELETE,
		TriggerContext.AFTER_INSERT,
		TriggerContext.AFTER_UNDELETE
	};
	// Contexts to use a single map of old values for trigger batch
	private static final Set<TriggerContext> oldMapContext = new Set<TriggerContext>{
		TriggerContext.BEFORE_DELETE,
		TriggerContext.AFTER_DELETE
	};
	// Contexts to use a two map (old and new) for trigger batch
	private static final Set<TriggerContext> twoMapContext = new Set<TriggerContext>{
		TriggerContext.BEFORE_UPDATE,
		TriggerContext.AFTER_UPDATE
	};
	
	
	/* Map of number of times subclasses have been executed; to be indexed by class name */
	private static Map<String,Integer> execMap = new Map<String,Integer>();
	
	/* Instance variables */
	protected TriggerContext context; // Current context
	// Trigger batch variables */
	protected List<Sobject> triggerList;     // Simple list of sobjects used by before insert contexts
	protected Map<Id,SObject> triggerMap;    // Map of sobjects used by after insert, update and delete contexts
	protected Map<Id,SObject> triggerOldMap; // Map of old sobject values used by update contexts
	
	/* Constructors */
	// Basic constructor for all trigger contexts
	protected TriggerAction(){
		// Set context first
		this.context = TriggerAction.getContext();
		// Set batch variables from trigger context
		if(listContext.contains(this.context)){
			this.triggerList = System.Trigger.new;
			this.triggerMap = null;
			this.triggerOldMap = null;
		}
		else if(newMapContext.contains(this.context)){
			this.triggerList = null;
			this.triggerMap = System.Trigger.newMap;
			this.triggerOldMap = null;
		}
		else if(oldMapContext.contains(this.context)){
			this.triggerList = null;
			this.triggerMap = System.Trigger.oldMap;
			this.triggerOldMap = null;
		}
		else if(twoMapContext.contains(this.context)) {
			this.triggerList = null;
			this.triggerMap = System.Trigger.newMap;
			this.triggerOldMap = System.Trigger.oldMap;
		}
		else { 
			throw new TriggerAction.InvalidContextException(this.context);
		}
	}
	// Advanced constructor for Before Insert trigger contexts
	protected TriggerAction(List<SObject> Triggerlist, TriggerContext ctx) {
		// load context
		this.context = ctx;
		// check context valid
		if (!listContext.contains(this.context)){
			throw new TriggerAction.InvalidContextException(this.context);
		}
		// set variables
		this.triggerList = triggerList;
	}
	// Advanced constructor for After Insert and Delete trigger contexts
	protected TriggerAction(Map<Id,SObject> triggerMap, TriggerContext ctx) {
		// load context
		this.context = ctx;
		// check context valid
		if (!newMapContext.contains(this.context) && !oldMapContext.contains(this.context)){
			throw new TriggerAction.InvalidContextException(this.context);
		}
		// set variables
		this.triggerMap = triggerMap;
	}
	// Advanced constructor for Update trigger contexts
	protected TriggerAction(Map<Id,SObject> triggerNewMap,Map<Id,SObject> triggerOldMap, TriggerContext ctx){
		// load context
		this.context = ctx;
		// check context valid
		if (!twoMapContext.contains(this.context)){
			throw new TriggerAction.InvalidContextException(this.context);
		}
		// set variables
		this.triggerMap = triggerNewMap;
		this.triggerOldMap = triggerOldMap;
	}
	
	/* Method to determine if the trigger should take action */
	public abstract Boolean shouldRun();
	
	/* Method to perform the action of the trigger */
	public abstract void doAction();
	
	/* Helper methods for tracking if a subclass has been run before */
	// Kludge for getting class name in apex
	public String getClassName(){
		return String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));
	}
	// Marks that a child class has been run;
	// leverages the execMap static map for tracking
	public void markRun(){
		String clsNm = this.getClassName();
		if(TriggerAction.execMap.containsKey(clsNm)){
			TriggerAction.execMap.put(clsNm,TriggerAction.execMap.get(clsNm)+1);
		} else {
			TriggerAction.execMap.put(clsNm,1);
		}
	}
	// Return the number of times a class has been run;
	// leverages the execMap static map for tracking
	public Integer timesRun(){
		String clsNm = this.getClassName();
		if(TriggerAction.execMap.containsKey(clsNm)){
			return TriggerAction.execMap.get(clsNm);
		} else {
			return 0;
		}
	}
	// Return if class has run before;
	// leverages timesRun() instance method
	public Boolean hasRun(){
		return this.timesRun() > 0;
	}
	// Reset hasRun count for this class
	public void resetHasRun(){
		TriggerAction.execMap.put(this.getClassName(),0);
	}
	// Reset hasRun counts for all trigger action classes
	public static void resetAllHasRun(){
		TriggerAction.execMap.clear();
	}
	
	/* Helper methods for dealing with trigger context */
	// Static method for taking current System.Trigger context variables 
	// and return the equivolent TriggerContext enum values
	public static TriggerContext getContext(){
		TriggerContext rtn = null;
		try { // try catch because non-trigger context will explode this
			if (System.Trigger.isBefore){
				if (System.Trigger.isInsert){
					rtn = TriggerAction.TriggerContext.BEFORE_INSERT;
				}
				else if (System.Trigger.isUpdate){
					rtn = TriggerAction.TriggerContext.BEFORE_UPDATE;
				}
				else if (System.Trigger.isDelete){
					rtn = TriggerAction.TriggerContext.BEFORE_DELETE;
				}
				else if (System.Trigger.isUndelete){
					rtn = TriggerAction.TriggerContext.BEFORE_UNDELETE;
				}
				else { 
					throw new TriggerAction.InvalidContextException();
				}
			}
			else if (System.Trigger.isAfter){
				if (System.Trigger.isInsert){
					rtn = TriggerAction.TriggerContext.AFTER_INSERT;
				}
				else if (System.Trigger.isUpdate){
					rtn = TriggerAction.TriggerContext.AFTER_UPDATE;
				}
				else if (System.Trigger.isDelete){
					rtn = TriggerAction.TriggerContext.AFTER_DELETE;
				}
				else if (System.Trigger.isUndelete){
					rtn = TriggerAction.TriggerContext.AFTER_UNDELETE;
				}
				else { 
					throw new TriggerAction.InvalidContextException();
				}
			}
			else { 
				throw new TriggerAction.InvalidContextException();
			}
		} catch (System.NullPointerException e) {
			throw new TriggerAction.InvalidContextException();
		}
		return rtn;
	}
	// Returns true if the given TriggerContext enum value represents a before trigger context;
	// Works statically on an enum value
	public static Boolean isBefore(TriggerContext tc){
		return tc == TriggerAction.TriggerContext.BEFORE_INSERT
			|| tc == TriggerAction.TriggerContext.BEFORE_UPDATE
			|| tc == TriggerAction.TriggerContext.BEFORE_DELETE
			|| tc == TriggerAction.TriggerContext.BEFORE_UNDELETE;
	}
	// Returns true if the given TriggerContext enum value represents a before trigger context;
	// Works on class instance
	public Boolean isBefore(){
		return TriggerAction.isBefore(this.context);
	}
	
	// Returns true if the given TriggerContext enum value represents an after trigger context;
	// Works statically on an enum value
	public static Boolean isAfter(TriggerContext tc){
		return tc == TriggerAction.TriggerContext.AFTER_INSERT
			|| tc == TriggerAction.TriggerContext.AFTER_UPDATE
			|| tc == TriggerAction.TriggerContext.AFTER_DELETE
			|| tc == TriggerAction.TriggerContext.AFTER_UNDELETE;
	}
	// Returns true if the given TriggerContext enum value represents an after trigger context;
	// Works on class instance
	public Boolean isAfter(){
		return TriggerAction.isAfter(this.context);
	}
	// Returns true if the given TriggerContext enum value represents an insert trigger context;
	// Works statically on an enum value
	public static Boolean isInsert(TriggerContext tc){
		return tc == TriggerAction.TriggerContext.BEFORE_INSERT
			|| tc == TriggerAction.TriggerContext.AFTER_INSERT;
	}
	// Returns true if the given TriggerContext enum value represents an insert trigger context;
	// Works on class instance
	public Boolean isInsert(){
		return TriggerAction.isInsert(this.context);
	}
	// Returns true if the given TriggerContext enum value represents an update trigger context;
	// Works statically on an enum value
	public static Boolean isUpdate(TriggerContext tc){
		return tc == TriggerAction.TriggerContext.BEFORE_UPDATE
			|| tc == TriggerAction.TriggerContext.AFTER_UPDATE;
	}
	// Returns true if the given TriggerContext enum value represents an update trigger context
	// Works on class instance
	public Boolean isUpdate(){
		return TriggerAction.isUpdate(this.context);
	}
	// Returns true if the given TriggerContext enum value represents an delete trigger context;
	// Works statically on an enum value
	public static Boolean isDelete(TriggerContext tc){
		return tc == TriggerAction.TriggerContext.BEFORE_DELETE
			|| tc == TriggerAction.TriggerContext.AFTER_DELETE;
	}
	// Returns true if the given TriggerContext enum value represents an delete trigger context;
	// Works on class instance
	public Boolean isDelete(){
		return TriggerAction.isDelete(this.context);
	}
	// Returns true if the given TriggerContext enum value represents an undelete trigger context;
	// Works statically on an enum value
	public static Boolean isUndelete(TriggerContext tc){
		return tc == TriggerAction.TriggerContext.BEFORE_UNDELETE
			|| tc == TriggerAction.TriggerContext.AFTER_UNDELETE;
	}
	// Returns true if the given TriggerContext enum value represents an undelete trigger context;
	// Works on class instance
	public Boolean isUndelete(){
		return TriggerAction.isUndelete(this.context);
	}
	
}