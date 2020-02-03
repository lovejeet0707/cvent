trigger OwnerRoleTrigger on Opportunity (before insert, before update) {
Set<Id> uIds = new Set<Id>();
for(Opportunity o : Trigger.New)
{
uIds.add(o.OwnerId);
}

Map<Id,User> uList = new Map<Id,User>([Select id, UserRole.Name from User where Id IN :uIDs]);
for(Opportunity o : Trigger.New)
{
    //Fixed the Null Pointer exception - PK 8/11/2017
    if(uList.get(o.OwnerId) != null && uList.get(o.OwnerId).UserRole != null){
        o.opp_owner_role__c = uList.get(o.OwnerId).UserRole.Name;
    }
}
}