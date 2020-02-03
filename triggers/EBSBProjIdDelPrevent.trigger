trigger EBSBProjIdDelPrevent on EB_SB_Builder__c (before delete) 
{    if(System.Trigger.isDelete){
    for(EB_SB_Builder__c Ebs: trigger.old)
        if(Ebs.Name == 'Project-201308-7659' || Ebs.Name == 'Project-201308-7800')
                {Ebs.addError('Error: You Cannot Delete This Project ID');
                }
                                }
}