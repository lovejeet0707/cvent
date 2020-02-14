global class UserProvisioningScheduler Implements Schedulable {
    global map<id, string> mapOfUserIdWithUserName = new map<id, string>();
    global map<string, string> mapOfUserIdWithEmail = new map<string, string>();
    global map<id, List<Loginhistory>> mapOfUserNamewithLoginhistory = new Map<id, List<LoginHistory>>();
    global map<string, string> dataMap = new map<string, string>();
    global Integer numberOfDaysToSubtract = Integer.valueOf(Label.Number_of_Days_for_Deactivating_Users);
    global Integer numberOfHoursForSch = Integer.valueOf(Label.Number_of_Hours_for_Scheduling_User_Provisioning);
    global DateTime loginTimeToInactivate = System.now().addDays(- numberOfDaysToSubtract);
    global DateTime loginTimeToActivate = System.now().addHours(-numberOfHoursForSch);
    global DateTime timeNow = System.now();
    global String NowDateTime = timeNow.format('MM/dd/yyyy HH:mm:ss', 'America/New_York');
    global string fileName;

    global void execute(SchedulableContext sc) {
        //Getting all the users which are identified as Irregular in Salesforce
        List<User> IrregularUserList = new List<User>();
        if(Test.isRunningTest()){
            IrregularUserList = [Select id, username, Email from User where userName Like 'hjohar@cvent.com%' OR userName Like 'ankit.g@cvent.com%'];
        } else {
            IrregularUserList = [Select id, username, Email from User where Irregular__c = true];
        }
        for(User u : IrregularUserList) {
            mapOfUserIdWithUserName.put(u.id, u.username);
            mapOfUserIdWithEmail.put(u.username, u.Email);
        }

        if(mapOfUserIdWithUserName != null) {
            //Getting the login history of the users identified as Irregular
            for(LoginHistory lh :[Select status, userId, LoginTime from LoginHistory where LoginTime >= :loginTimeToInactivate and userid in :mapOfUserIdWithUserName.keyset()]) {
                if(!mapOfUserNamewithLoginhistory.containsKey(lh.userId)) {
                    mapOfUserNamewithLoginhistory.put(lh.userId, new List<LoginHistory>{ lh });
                } else {
                    mapOfUserNamewithLoginhistory.get(lh.userId).add(lh);
                }
            }

            //Mapping the users and identifying which user should be activated and deactivated
            for(ID uId :mapOfUserIdWithUserName.keyset()) {
                if(mapOfUserNamewithLoginhistory != null && mapOfUserNamewithLoginhistory.containsKey(uId)) {
                    for(LoginHistory lh :mapOfUserNamewithLoginhistory.get(uId)) {
                        if(!dataMap.containsKey(uId) && lh.Status != 'User is Inactive') {
                            dataMap.put(mapOfUserIdWithUserName.get(uId), 'Inactive');
                        } else if(lh.Status == 'User is Inactive' && lh.LoginTime > loginTimeToActivate) {
                            dataMap.put(mapOfUserIdWithUserName.get(uId), 'Active');
                        }
                    }
                } else {
                    dataMap.put(mapOfUserIdWithUserName.get(uId), 'Inactive');
                }
            }
        }

        //Generating CSV for the User Data
        string header = 'Email, UserName, Status \n';
        string finalstr = header;

        for(String uname :dataMap.keyset()) {
            string recordString = mapOfUserIdWithEmail.get(uname) + ',' + uname + ',' + dataMap.get(uname) + '\n';
            finalstr = finalstr + recordString;
        }

        fileName = 'UserData ' + NowDateTime + '.csv';
        User_Provisioning_Data__c upd = new User_Provisioning_Data__c();
        upd.User_Data_Timestamp__c = System.now();

        try{
            //Inserting the User Provisioning Data Record
            insert upd;

            //Adding the attachment if there is any

            //Used Content version so as to make it compatible for Lightning as well
            ContentVersion conVer = new ContentVersion();
            conVer.ContentLocation = 'S';
            conVer.PathOnClient = fileName;
            conVer.Title = fileName;
            conVer.VersionData = Blob.valueOf(finalstr);
            insert conVer;

            Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :conVer.Id].ContentDocumentId;

            ContentDocumentLink cDe = new ContentDocumentLink();
            cDe.ContentDocumentId = conDoc;
            cDe.LinkedEntityId = upd.id;
            cDe.ShareType = 'V';
            cDe.Visibility = 'AllUsers';
            insert cDe;

        } Catch(Exception e) {
            //Exception handling
            system.debug('Exception : ' + e.getMessage());
        }

        //Scheduling the class form within so as to keep it dynamic
        finally{

            dateTime dt = System.now().addHours(numberOfHoursForSch);
            String Csec, Cmin, Chr, Cday, Cmonth, CYear;
            Csec= String.valueof(dt.second());
            Cmin= String.valueof(dt.minute());
            Chr= String.valueof(dt.hour());
            Cday= String.valueof(dt.day());
            Cmonth= String.valueof(dt.month());
            CYear= String.valueof(dt.Year());
            String SchTimer = Csec + ' ' + Cmin + ' ' + Chr + ' ' + Cday + ' ' + Cmonth + ' ? ' + CYear;
            system.debug('*************SchTimer:' + SchTimer);
            UserProvisioningScheduler  cm = new UserProvisioningScheduler();
            if(!Test.isRunningTest())
                system.schedule('Scheduled Process User Provisioning', SchTimer, cm);

        }   
    }
}