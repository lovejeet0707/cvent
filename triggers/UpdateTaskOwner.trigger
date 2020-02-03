/*************************************************************************************
Description: Trigger to update task owner for the task
created by marketo user based on email contained in subject
*************************************************************************************/
trigger UpdateTaskOwner on Task (before insert) {

    /* Skip execution if this user is setup to exempt triggers. This helps in one time data load as well */
    if(!BypassTriggerUtility.isTriggerEnabledForThisUserOrProfileId(UserInfo.getUserId())){
            return;
    } 
    
    //Iterating over triggers created to capture subject line
    //and check user associated with it
    //List of emailids
    List<String> userEmails = new List<String>();
    //Map of task id and email
    Map<Id,String> taskEmailMap = new Map<Id,String>();
    for(Task newTask: trigger.new) {
        
        
        //Checking for sales record type and created by marketo marketing user
        if(newTask.subject != null && newTask.RecordTypeID == Label.TaskRecordTypeID && newTask.ownerId == Label.TaskMarketoUserId) {
            List<String> parts = newTask.subject.split(' ');
            
            if(parts != null && parts.size() > 0 && parts[parts.size()-1].contains('@')) {
                userEmails.add(parts[parts.size()-1].trim());
                taskEmailMap.put(newTask.Id,parts[parts.size()-1].trim());
            } 
        }
    }
    
    //Fetching users associated with email ids in subject task
    List<User> associatedUsers = [Select Id,email,isActive FROM User where email IN:userEmails and Profile.userLicense.Name = 'Salesforce' and isActive = true];
    //Map of useremail and userid
    Map<String,Id> userEmailMap = new Map<String,Id>();
    for(User usr: associatedUsers) {
        if(!userEmailMap.containsKey(usr.email)) {
            userEmailMap.put(usr.email,usr.Id);
        }
    }
    
    //Changing owner
        for(Task newTask1: trigger.new) {
        //Checking for sales record type and created by marketo marketing user
        if(newTask1.subject != null && newTask1.RecordTypeID == Label.TaskRecordTypeID && newTask1.ownerId == Label.TaskMarketoUserId) {
             if(taskEmailMap.get(newTask1.Id) != null && userEmailMap.get(taskEmailMap.get(newTask1.Id)) != null) {
                newTask1.ownerId = userEmailMap.get(taskEmailMap.get(newTask1.Id));
             } else {
                //Assigning to Sales Support India User
                newTask1.ownerId = Label.SalesSupportIndiaUserID;
            }  
            
        } 
    }
}