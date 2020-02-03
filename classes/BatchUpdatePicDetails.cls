//Batchclass to check for the updated profile pic of the user
//and then save it in the document folder and update the URL in the user field

global class BatchUpdatePicDetails implements Database.batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    
 String query;
 DateTime dateCriterias;
   //DataBase.executeBatch(new BatchUpdatePicDetails (DateTimeField));
 global BatchUpdatePicDetails(DateTime dateCriteria) {
    
    if(dateCriteria == null) {
        dateCriterias = System.Now() - 1;
    } else {
        dateCriterias = dateCriteria;
    }
    system.debug('$$$$$'+dateCriterias);
 }
 
 global Database.QueryLocator start(Database.BatchableContext BC) {
       //Fetching user Id  
       String prof1 = 'Customer Care%';
       String prof2 = 'Client%';
       if(!Test.isRunningTest()) {
           return Database.getQueryLocator('Select Id,PhotoURL__c FROM User where LastModifiedDate >:dateCriterias and (profile.name like:prof1 or profile.name like: prof2)');
       } else {
           return Database.getQueryLocator('Select Id,PhotoURL__c FROM User where LastModifiedDate >:dateCriterias limit 1');
       }
       
    }
    
    global void execute(Database.BatchableContext BC, List<User> scope) {
       try{

            //Set of userId and Image
            system.debug('######7'+scope.size());
            Set<String> userIdImage = new Set<String>();
            List<Id> uIds = new List<Id>();
            Map<String,User> userMap = new Map<String,User>();
            for(User usr: scope) {
                userMap.put(usr.Id+'Image',usr);
                userIdImage.add(usr.Id+'Image');
                uIds.add(usr.Id);
            }
            //Map of docname and doc
            Map<String,Document> mapNameDoc = new Map<String,Document>();
            List<Document> existingDocs = [Select Id,contenttype,body,FolderId,Name FROM Document where Name IN: userMap.keySet()];
            for(Document doc: existingDocs) {
                mapNameDoc.put(doc.Name,doc);
            }
            
            List<Document> docToInsert = new List<Document>();
            system.debug('#####1'+mapNameDoc);
            //Map of UserId and URL which needs to append to User
            for (ConnectApi.BatchResult eachResult : ConnectApi.ChatterUsers.getUserBatch(null, uIds )) {
                system.debug('####1'+Limits.getCallouts() + '$$$$' + Limits.getLimitCallouts());
                ConnectApi.User eachUser = (ConnectApi.User)eachResult.getResult();
                ConnectApi.UserDetail userId = (ConnectApi.UserDetail)eachResult.getResult();     
                ConnectApi.Photo p = ConnectApi.userprofiles.getPhoto(null, userId.id);
                Http h = new Http();
                HttpRequest req = new HttpRequest();
                req.setEndPoint(p.fullEmailPhotoUrl);
                req.setMethod('GET');
                HttpResponse res = new Http().send(req);
                Blob b = res.getBodyAsBlob();
                Document docs = new Document();
                if(mapNameDoc.containsKey(userId.Id+'Image')) {
                    system.debug('#####3');
                    docs = mapNameDoc.get(userId.Id + 'Image');
                    docs.IsPublic = true;
                    docs.body = b;
                } else {
                    system.debug('#####4');
                    docs.contenttype = 'image/jpeg';
                    docs.body = b;
                    docs.IsPublic = true;
                    docs.FolderId = Label.FolderId;
                    docs.name = userId.Id+'Image';
                }              
                docToInsert.add(docs);
            }
            system.debug('#####5'+docToInsert.size());
            List<User> usersToUpdate = new List<User>();
            if(docToInsert.size() > 0) {
                upsert docToInsert;
                for(Document d: docToInsert) {
                    if(userMap.get(d.Name).PhotoURL__c != Label.ContentURL + d.Id) {
                        userMap.get(d.Name).PhotoURL__c = Label.ContentURL + d.Id;
                        usersToUpdate.add(userMap.get(d.Name));
                    }
                    system.debug('$$$$$44');
                }
                if(usersToUpdate.size() > 0) {
                   // system.debug('$$$$$33'+usersToUpdate[0].PhotoURL__c + '%%%%%' + usersToUpdate[1].PhotoURL__c);
                    update usersToUpdate; 
                }
            }
       } catch(Exception e) {
            system.debug('######');
        }
            
    }   
    global void finish(Database.BatchableContext BC) {
    } 
}