trigger Eventtriggerbulk on Event (before delete, before insert, before update) {
    /* Skip execution if this user is setup to exempt triggers. This helps in one time data load as well */
    if(!BypassTriggerUtility.isTriggerEnabledForThisUserOrProfileId(UserInfo.getUserId())){
            return;
    }
    

    integer icount;
    icount = 0;
    // store all taskIds sent in
 Set<Id> tasksInSet = new Set<Id> {};
 if (Trigger.isInsert) {
 for (Event t : Trigger.new) {
  tasksInSet.add(t.Id);
  icount = icount +1;
 }
 }
 if (Trigger.isUpdate) {
 for (Event t : Trigger.new) {
  tasksInSet.add(t.Id);
  icount = icount +1;
 }
 }
 
 if (Trigger.isDelete) {
 for (Event t : Trigger.old) {
  tasksInSet.add(t.Id);
  icount = icount +1;
 }
 }
 
if (icount<=1)
{
Event[] accs;
if (Trigger.isInsert) {
accs = Trigger.new;
}
if (Trigger.isUpdate) {
accs = Trigger.new;
}
if (Trigger.isDelete) {
accs = Trigger.old;
}
Double x = 0;
Double x2 = 0;
Double oldvalcus  = 0;
Double oldvaltimedur  = 0;
string xd;
for (Event a:accs){
xd = a.WhoId;
//xd = UserInfo.getUserRoleId();
//if (xd != '00E00000006xENC')
if (xd != Null)
{
}
else
{
for (event tmp1 : [Select t.WhoId, t.Minutes_on_tasks__c, t.DurationInMinutes, t.Id From event t where t.id = :a.id]) {
if (tmp1.Minutes_on_tasks__c == null)
{
oldvalcus = 0;
}
else
{
oldvalcus =tmp1.Minutes_on_tasks__c;
}
if (tmp1.DurationInMinutes == null)
{
oldvaltimedur = 0;
}
else
{
oldvaltimedur=tmp1.DurationInMinutes;
}
}

if (a.Minutes_on_tasks__c == null)
{
x = 0;
}
else
{
x = (a.Minutes_on_tasks__c);

}
if (a.DurationInMinutes  == null)
{
x2 = 0;
}
else
{
x2 = (a.DurationInMinutes);

}
if (Trigger.isDelete) {
x=0;
x2=0;
}
oldvalcus   = x - oldvalcus ;
oldvaltimedur = x2 - oldvaltimedur;
//a.Minutes_on_tasks__c= x;
//a.Location= 'a'+x2;
for (EB_SB_Builder__c tmp : [Select e.Build_Out_Time_Exhausted__c,e.Talktime_Exhausted__c, e.Id From EB_SB_Builder__c e where e.id = :a.Whatid limit 1]) {
tmp.Talktime_Exhausted__c = tmp.Talktime_Exhausted__c + (oldvaltimedur/60);
tmp.Build_Out_Time_Exhausted__c = tmp.Build_Out_Time_Exhausted__c + (oldvalcus/60);
update tmp;
}
for (Project_Activity__c tmp1 : [Select e.Actual_Time_Spent__c, e.Id From  Project_Activity__c e where e.id = :a.Whatid limit 1]) {
tmp1.Actual_Time_Spent__c = tmp1.Actual_Time_Spent__c + ((oldvaltimedur+oldvalcus)/60);
//tmp.Build_Out_Time_Exhausted__c = tmp.Build_Out_Time_Exhausted__c + (oldvalcus/60);
update tmp1;
}
}
}
}
}