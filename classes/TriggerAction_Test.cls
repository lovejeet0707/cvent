/*
	Author: Sandeep Kumar
	Version: 1.0
	Date: 20 March 2017
	Test class for TriggerAction
*/

@isTest
private class TriggerAction_Test {
	
	// Test of run history tracking
	static testMethod void historyTest(){
		// setup some faux data/variables for use later
		List<SObject> fauxList = new List<SObject>();
		// test trigger action variable declaration
		FauxTrigAct trig;
		// first instantiation
		trig = new FauxTrigAct(fauxList,TriggerAction.TriggerContext.BEFORE_INSERT);
		trig.shouldRun();
		// assert not run yet
		System.assert(!trig.hasRun());
		System.assertEquals(trig.timesRun(), 0);
		// first run
		trig.doAction();
		// assert run once
		System.assert(trig.hasRun());
		System.assertEquals(trig.timesRun(), 1);
		// second instantiation
		trig = new FauxTrigAct(fauxList,TriggerAction.TriggerContext.BEFORE_INSERT);
		trig.shouldRun();
		// second run
		trig.doAction();
		// assert run twice
		System.assert(trig.hasRun());
		System.assertEquals(trig.timesRun(), 2);
		// increment run and test
		trig.markRun();
		System.assertEquals(trig.timesRun(), 3);
		trig.markRun();
		System.assertEquals(trig.timesRun(), 4);
		// test reset (instance & static)
		trig.resetHasRun();
		System.assertEquals(trig.timesRun(), 0);
		trig.markRun();
		System.assertEquals(trig.timesRun(), 1);
		TriggerAction.resetAllHasRun();
		System.assertEquals(trig.timesRun(), 0);
	}
	
	// Exhaustive test of the context set & inspect methods
	static testMethod void contextTest() {
		// setup some faux data/variables for use later
		List<SObject> fauxList = new List<SObject>();
		Map<Id,SObject> fauxMap = new Map<Id,SObject>();
		// test trigger action variable declaration
		FauxTrigAct trig;
		// first test case (Before Insert)
		trig = new FauxTrigAct(fauxList,TriggerAction.TriggerContext.BEFORE_INSERT);
		System.assert(trig.isBefore() && !trig.isAfter());
		System.assert(trig.isInsert() && !trig.isUpdate() && !trig.isDelete() && !trig.isUndelete());
		// second test case (After Insert)
		trig = new FauxTrigAct(fauxMap,TriggerAction.TriggerContext.AFTER_INSERT);
		System.assert(!trig.isBefore() && trig.isAfter());
		System.assert(trig.isInsert() && !trig.isUpdate() && !trig.isDelete() && !trig.isUndelete());
		// third test case (Before Update)
		trig = new FauxTrigAct(fauxMap, fauxMap,TriggerAction.TriggerContext.BEFORE_UPDATE);
		System.assert(trig.isBefore() && !trig.isAfter());
		System.assert(!trig.isInsert() && trig.isUpdate() && !trig.isDelete() && !trig.isUndelete());
		// fourth test case (After Update)
		trig = new FauxTrigAct(fauxMap, fauxMap,TriggerAction.TriggerContext.AFTER_UPDATE);
		System.assert(!trig.isBefore() && trig.isAfter());
		System.assert(!trig.isInsert() && trig.isUpdate() && !trig.isDelete() && !trig.isUndelete());
		// fifth test case (Before Delete)
		trig = new FauxTrigAct(fauxMap,TriggerAction.TriggerContext.BEFORE_DELETE);
		System.assert(trig.isBefore() && !trig.isAfter());
		System.assert(!trig.isInsert() && !trig.isUpdate() && trig.isDelete() && !trig.isUndelete());
		// sixth test case (After Delete)
		trig = new FauxTrigAct(fauxMap,TriggerAction.TriggerContext.AFTER_DELETE);
		System.assert(!trig.isBefore() && trig.isAfter());
		System.assert(!trig.isInsert() && !trig.isUpdate() && trig.isDelete() && !trig.isUndelete());
		// seventh test case (Before Undelete)
		trig = new FauxTrigAct(fauxMap,TriggerAction.TriggerContext.BEFORE_UNDELETE);
		System.assert(trig.isBefore() && !trig.isAfter());
		System.assert(!trig.isInsert() && !trig.isUpdate() && !trig.isDelete() && trig.isUndelete());
		// eighth test case (After Undelete)
		trig = new FauxTrigAct(fauxMap,TriggerAction.TriggerContext.AFTER_UNDELETE);
		System.assert(!trig.isBefore() && trig.isAfter());
		System.assert(!trig.isInsert() && !trig.isUpdate() && !trig.isDelete() && trig.isUndelete());
	}
	
	// Test context combinations where the contructors should/shouldn't fail
	static testMethod void constructTest(){
		// setup some faux data/variables for use later
		List<SObject> fauxList = new List<SObject>();
		Map<Id,SObject> fauxMap = new Map<Id,SObject>();
		// test trigger action variable declaration
		FauxTrigAct trig;
		
		// first case - default constructor positive ![not possible using DML-less testing]!
			//NOOP
		
		// second case - default constructor negative
		try {
			trig = null;
			trig = new FauxTrigAct();
			System.assertEquals(trig, null);
		} catch (TriggerAction.InvalidContextException e){}
		
		// third case - list constructor positive
		trig = null;
		trig = new FauxTrigAct(fauxList,TriggerAction.TriggerContext.BEFORE_INSERT);
		System.assertNotEquals(trig, null);
		
		// fourth case - list constructor negative
		try {
			trig = null;
			trig = new FauxTrigAct(fauxList,TriggerAction.TriggerContext.AFTER_INSERT);
			System.assertEquals(trig, null);
		} catch (TriggerAction.InvalidContextException e){}
		
		// fifth case - map constructor positive
		trig = null;
		trig = new FauxTrigAct(fauxMap,TriggerAction.TriggerContext.AFTER_INSERT);
		System.assertNotEquals(trig, null);
		
		// sixth case - map constructor negative
		try {
			trig = null;
			trig = new FauxTrigAct(fauxMap,TriggerAction.TriggerContext.BEFORE_INSERT);
			System.assertEquals(trig, null);
		} catch (TriggerAction.InvalidContextException e){}
		
		// seventh case - twoMap constructor positive
		trig = null;
		trig = new FauxTrigAct(fauxMap, fauxMap,TriggerAction.TriggerContext.BEFORE_UPDATE);
		System.assertNotEquals(trig, null);
		
		// eighth case - twoMap constructor negative
		try {
			trig = null;
			trig = new FauxTrigAct(fauxMap, fauxMap,TriggerAction.TriggerContext.BEFORE_INSERT);
			System.assertEquals(trig, null);
		} catch (TriggerAction.InvalidContextException e){}
	}
	
	// Helper class to implement superclass for testing
	private class FauxTrigAct extends TriggerAction {
		// add constructors because reasons
		public FauxTrigAct(){
			super();
		}
		public FauxTrigAct(List<Sobject> Triggerlist, TriggerContext ctx){
			super(Triggerlist, ctx);
		}
		public FauxTrigAct(Map<Id,SObject> triggerMap, TriggerContext ctx){
			super(triggerMap, ctx);
		}
		public FauxTrigAct(Map<Id,SObject> triggerNewMap,Map<Id,SObject> triggerOldMap, TriggerContext ctx){
			super(triggerNewMap, triggerOldMap, ctx);
		}
		// very simple override of shouldRun
		public override Boolean shouldRun(){
			// very simplistic criteria
			return this.isUpdate() || this.isDelete();
		}
		// very simple doAction
		public override void doAction(){
			// do the super
			this.markRun();
			
		}
	}	
}